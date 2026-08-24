// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kruftle/src/core/schedule/background_service.dart';
import 'package:kruftle/src/core/schedule/schedule.dart';

/// The job descriptions handed to launchd, systemd and Task Scheduler.
///
/// These are the part that can be wrong without anything failing: a plist that
/// loads but fires on the wrong weekday, a `OnCalendar` a day out, a `/TR` that
/// splits on the space in "Program Files". Nothing notices until the cleanup
/// silently does not happen, so the generated text is asserted here rather than
/// trusted. Installing them is three `Process.run` calls and is exercised by
/// hand — this file never touches the machine it runs on.
void main() {
  const daily = CleanupSchedule(
    enabled: true,
    root: '/Users/dev/code',
    frequency: ScheduleFrequency.daily,
    hour: 3,
    minute: 5,
  );
  final weekly = daily.copyWith(
    frequency: ScheduleFrequency.weekly,
    dayOfWeek: DateTime.thursday,
  );
  final monthly = daily.copyWith(
    frequency: ScheduleFrequency.monthly,
    dayOfMonth: 9,
  );

  group('the launchd plist', () {
    String plist(CleanupSchedule s) =>
        BackgroundService.launchAgentPlist(s, '/Applications/Kruftle.app/x');

    test('carries the label, the executable and both background signals', () {
      final xml = plist(daily);
      expect(xml, contains('<string>${BackgroundService.label}</string>'));
      expect(xml, contains('<string>/Applications/Kruftle.app/x</string>'));
      expect(xml, contains('<string>${BackgroundService.flag}</string>'));
      expect(xml, contains('<key>${BackgroundService.environmentKey}</key>'));
    });

    test('does not clean at login, only on the calendar', () {
      // RunAtLoad would clean every time the user signed in, which is not what
      // "weekly" means and would be a surprise on a laptop opened twice a day.
      expect(plist(daily), contains('<key>RunAtLoad</key>\n  <false/>'));
      expect(plist(daily), contains('<key>StartCalendarInterval</key>'));
    });

    test('a daily schedule names only the time', () {
      final xml = plist(daily);
      expect(xml, contains('<key>Hour</key>\n      <integer>3</integer>'));
      expect(xml, contains('<key>Minute</key>\n      <integer>5</integer>'));
      expect(xml, isNot(contains('<key>Weekday</key>')));
      expect(xml, isNot(contains('<key>Day</key>')));
    });

    test('a weekly schedule adds the weekday launchd numbers the same way', () {
      // DateTime.thursday is 4 and so is launchd's Thursday, which is the
      // whole reason there is no lookup table in the source.
      expect(
        plist(weekly),
        contains('<key>Weekday</key>\n      <integer>4</integer>'),
      );
    });

    test('Sunday survives the two numbering systems', () {
      // launchd documents Sunday as 0 and accepts 7 for it too; DateTime uses
      // 7. Passing 7 through unchanged is only correct because of that, so it
      // is asserted rather than assumed.
      final sunday = weekly.copyWith(dayOfWeek: DateTime.sunday);
      expect(
        plist(sunday),
        contains('<key>Weekday</key>\n      <integer>7</integer>'),
      );
    });

    test('a monthly schedule adds the day of the month', () {
      expect(
        plist(monthly),
        contains('<key>Day</key>\n      <integer>9</integer>'),
      );
    });

    test('an ampersand in the path does not break the XML', () {
      final xml = BackgroundService.launchAgentPlist(
        daily,
        '/Volumes/Work & Play/Kruftle.app/x',
      );
      expect(xml, contains('/Volumes/Work &amp; Play/Kruftle.app/x'));
      expect(xml, isNot(contains('Work & Play')));
    });
  });

  group('the systemd timer', () {
    test('a daily schedule fires every day at the chosen minute', () {
      expect(BackgroundService.onCalendar(daily), '*-*-* 03:05:00');
    });

    test('a weekly schedule names the day systemd expects', () {
      expect(BackgroundService.onCalendar(weekly), 'Thu *-*-* 03:05:00');
      expect(
        BackgroundService.onCalendar(
          weekly.copyWith(dayOfWeek: DateTime.sunday),
        ),
        'Sun *-*-* 03:05:00',
      );
      expect(
        BackgroundService.onCalendar(
          weekly.copyWith(dayOfWeek: DateTime.monday),
        ),
        'Mon *-*-* 03:05:00',
      );
    });

    test('a monthly schedule pads the day', () {
      expect(BackgroundService.onCalendar(monthly), '*-*-09 03:05:00');
    });

    test('a missed run is caught up rather than skipped', () {
      // Without Persistent, a machine switched off overnight simply never gets
      // the cleanup it asked for.
      expect(
        BackgroundService.systemdTimer(daily),
        contains('Persistent=true'),
      );
      expect(
        BackgroundService.systemdTimer(daily),
        contains('WantedBy=timers.target'),
      );
    });

    test('the service runs the executable with both signals set', () {
      final unit = BackgroundService.systemdService('/opt/kruftle/kruftle');
      expect(
        unit,
        contains('ExecStart=/opt/kruftle/kruftle ${BackgroundService.flag}'),
      );
      expect(
        unit,
        contains('Environment=${BackgroundService.environmentKey}=1'),
      );
      expect(unit, contains('Type=oneshot'));
    });
  });

  group('the Task Scheduler entry', () {
    test('overwrites rather than failing on an existing task', () {
      // Without /F, editing a schedule leaves Windows running the old one.
      final args = BackgroundService.schtasksArguments(daily, r'C:\k\k.exe');
      expect(args, containsAllInOrder(['/Create', '/F']));
      expect(args, containsAllInOrder(['/TN', BackgroundService.label]));
    });

    test('quotes the executable so a path with a space survives', () {
      final args = BackgroundService.schtasksArguments(
        daily,
        r'C:\Program Files\Kruftle\kruftle.exe',
      );
      expect(
        args[args.indexOf('/TR') + 1],
        r'"C:\Program Files\Kruftle\kruftle.exe" --background-clean',
      );
    });

    test('the time is 24-hour and zero-padded', () {
      final args = BackgroundService.schtasksArguments(daily, 'k.exe');
      expect(args[args.indexOf('/ST') + 1], '03:05');
    });

    test('each frequency maps to the switch schtasks understands', () {
      expect(
        BackgroundService.schtasksArguments(daily, 'k.exe'),
        containsAllInOrder(['/SC', 'DAILY']),
      );
      expect(
        BackgroundService.schtasksArguments(weekly, 'k.exe'),
        containsAllInOrder(['/SC', 'WEEKLY', '/D', 'THU']),
      );
      expect(
        BackgroundService.schtasksArguments(monthly, 'k.exe'),
        containsAllInOrder(['/SC', 'MONTHLY', '/D', '9']),
      );
    });
  });

  group('what the scheduler is told to run', () {
    test('normally the running executable', () {
      // Everything but the AppImage has a stable path already.
      expect(
        BackgroundService.executablePath(),
        Platform.resolvedExecutable,
        skip: Platform.environment.containsKey('APPIMAGE')
            ? 'this machine is itself running from an AppImage'
            : null,
      );
    });

    test('inside an AppImage, the .AppImage rather than the FUSE mount', () {
      // The bug this stops is invisible until the first scheduled run never
      // happens: the AppImage payload is mounted under /tmp and unmounted the
      // instant the app exits, so a unit pointing at `resolvedExecutable`
      // names a path that no longer exists by the time the timer fires.
      expect(
        BackgroundService.executablePath({
          'APPIMAGE': '/home/dev/Apps/Kruftle-0.2.0.AppImage',
        }),
        '/home/dev/Apps/Kruftle-0.2.0.AppImage',
      );
    });

    test('an empty APPIMAGE is ignored rather than obeyed', () {
      expect(
        BackgroundService.executablePath({'APPIMAGE': ''}),
        Platform.resolvedExecutable,
      );
    });
  });

  group('installing', () {
    test('a schedule with no folder is refused before anything is written', () {
      // `isConfigured` is false without a root, and a job that scans nothing
      // would run every week to no purpose.
      expect(
        const BackgroundService().install(const CleanupSchedule(enabled: true)),
        completion(isFalse),
      );
    });
  });

  group('the schedule itself', () {
    test('background running is off until it is asked for', () {
      expect(const CleanupSchedule().runInBackground, isFalse);
    });

    test('the choice survives a round trip through storage', () {
      final saved = daily.copyWith(runInBackground: true);
      expect(CleanupSchedule.decode(saved.encode()).runInBackground, isTrue);
    });

    test('a schedule written before the field existed still loads', () {
      // v0.2.0 wrote no `runInBackground`. Reading one must not throw and must
      // not silently turn unattended cleaning on.
      const old =
          '{"enabled":true,"frequency":"daily","hour":3,"minute":5,'
          '"root":"/Users/dev/code"}';
      final loaded = CleanupSchedule.decode(old);
      expect(loaded.runInBackground, isFalse);
      expect(loaded.root, '/Users/dev/code');
    });
  });
}
