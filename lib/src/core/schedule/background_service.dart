// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:io';

import 'schedule.dart';

/// Hands the schedule to the operating system, so a cleanup happens whether or
/// not Kruftle is open.
///
/// **There is no daemon.** Every desktop already ships a scheduler that starts
/// with the session and survives reboots — launchd on macOS, Task Scheduler on
/// Windows, systemd user timers on Linux — and all three can start a program at
/// a wall-clock time. Writing a resident process to do the same thing would put
/// an idle app in the user's login items, in their menu bar or tray, and in
/// their `ps` output, to spend 364 days a year waiting for the 365th. So
/// Kruftle registers a job and exits; the OS wakes it at the appointed minute.
///
/// The job runs `<this executable> --background-clean`, with
/// `KRUFTLE_BACKGROUND=1` in its environment. Two signals rather than one
/// because macOS's Flutter runner does not forward argv to the Dart entrypoint,
/// so there the environment variable is the only one that arrives; the Swift
/// side, which does see argv, uses that to keep the window off the screen.
///
/// **Two limits worth knowing, both of them the platform's and not ours.** A
/// systemd user timer stops with the login session unless the account has
/// lingering enabled (`loginctl enable-linger`), and a Task Scheduler entry
/// created this way runs only while its user is signed in. Neither is worked
/// around here: both match what a launchd LaunchAgent already does, and both
/// fit a tool that cleans up after the person using the machine.
///
/// **What the background run is allowed to do.** Exactly what the user has
/// already agreed to and nothing more: each toolchain's own clean command, plus
/// raw deletion of only the categories pre-selected in Settings — empty on a
/// fresh install. Safety rail 7 says the user opts into deletion; nobody is at
/// the keyboard at 03:00 to be asked, so an unattended run cannot widen the
/// opt-in, only honour it.
class BackgroundService {
  const BackgroundService();

  /// Reverse-DNS, because launchd insists and the other two do not mind.
  static const label = 'com.dizitart.kruftle.agent';

  /// Passed to the app so it knows to run headless instead of showing a
  /// window. Also checked by the macOS runner, which sees argv when Dart does
  /// not.
  static const flag = '--background-clean';

  /// The same instruction again, for macOS where argv does not reach Dart.
  static const environmentKey = 'KRUFTLE_BACKGROUND';

  /// True when the running process was started by the scheduler.
  static bool get isBackgroundRun =>
      Platform.environment[environmentKey] == '1';

  /// Registers, or re-registers, the job for [schedule].
  ///
  /// Returns false when the platform refused — an unwritable
  /// `~/Library/LaunchAgents`, a machine with no `systemctl`, a locked-down
  /// Task Scheduler. The caller reports that rather than pretending the
  /// cleanup is now automatic, because a schedule that silently does nothing
  /// is worse than no schedule.
  Future<bool> install(CleanupSchedule schedule) async {
    if (!schedule.isConfigured) return false;
    final executable = executablePath();

    try {
      if (Platform.isMacOS) return await _installLaunchd(schedule, executable);
      if (Platform.isLinux) return await _installSystemd(schedule, executable);
      if (Platform.isWindows) return await _installTask(schedule, executable);
    } on Object {
      // A missing `launchctl`, a read-only home, an antivirus veto. None of
      // them is a reason to take down the settings screen.
      return false;
    }
    return false;
  }

  /// Removes the job. Safe to call when nothing is registered.
  Future<void> uninstall() async {
    try {
      if (Platform.isMacOS) {
        await Process.run('launchctl', ['bootout', 'gui/${_uid()}/$label']);
        final plist = File(_launchAgentPath());
        if (plist.existsSync()) plist.deleteSync();
      } else if (Platform.isLinux) {
        await Process.run('systemctl', [
          '--user',
          'disable',
          '--now',
          '$label.timer',
        ]);
        for (final path in [_systemdPath('service'), _systemdPath('timer')]) {
          final file = File(path);
          if (file.existsSync()) file.deleteSync();
        }
        await Process.run('systemctl', ['--user', 'daemon-reload']);
      } else if (Platform.isWindows) {
        await Process.run('schtasks', ['/Delete', '/TN', label, '/F']);
      }
    } on Object {
      // Nothing to report: the caller is turning the feature off either way.
    }
  }

  /// Whether the operating system currently holds a job for Kruftle.
  ///
  /// Asked of the OS rather than remembered in settings, so a job removed
  /// behind Kruftle's back — a reinstalled machine, a `launchctl bootout` by
  /// hand — shows as off instead of as a lie.
  Future<bool> isInstalled() async {
    try {
      if (Platform.isMacOS) {
        if (!File(_launchAgentPath()).existsSync()) return false;
        final result = await Process.run('launchctl', [
          'print',
          'gui/${_uid()}/$label',
        ]);
        return result.exitCode == 0;
      }
      if (Platform.isLinux) {
        final result = await Process.run('systemctl', [
          '--user',
          'is-enabled',
          '$label.timer',
        ]);
        return result.exitCode == 0;
      }
      if (Platform.isWindows) {
        final result = await Process.run('schtasks', ['/Query', '/TN', label]);
        return result.exitCode == 0;
      }
    } on Object {
      return false;
    }
    return false;
  }

  /// What the scheduler should be told to run.
  ///
  /// [Platform.resolvedExecutable] everywhere except inside an AppImage, where
  /// it is a lie with a shelf life: the AppImage runtime mounts the payload on
  /// a FUSE filesystem under `/tmp/.mount_XXXXXX` and unmounts it the moment
  /// the process exits, so a unit file pointing there names a path that is
  /// gone before the timer ever fires. The runtime exports `APPIMAGE` with the
  /// real location of the `.AppImage` itself, which is the thing that can
  /// still be run tomorrow.
  ///
  /// The `.deb`, the `.exe` install and the `.app` bundle all have a stable
  /// path already, so they need nothing.
  /// [environment] is a parameter only so a test can hand it a map; nothing
  /// but the default is ever passed in production.
  static String executablePath([Map<String, String>? environment]) {
    final appImage = (environment ?? Platform.environment)['APPIMAGE'];
    if (appImage != null && appImage.isNotEmpty) return appImage;
    return Platform.resolvedExecutable;
  }

  // ------------------------------------------------------------------ macOS

  Future<bool> _installLaunchd(
    CleanupSchedule schedule,
    String executable,
  ) async {
    final path = _launchAgentPath();
    File(path).parent.createSync(recursive: true);
    File(path).writeAsStringSync(launchAgentPlist(schedule, executable));

    // Booting out first is what makes this idempotent: launchd refuses to load
    // a label it already holds, so an edited schedule would otherwise keep the
    // old times for ever. A failure here is expected on the first install.
    await Process.run('launchctl', ['bootout', 'gui/${_uid()}/$label']);
    final result = await Process.run('launchctl', [
      'bootstrap',
      'gui/${_uid()}',
      path,
    ]);
    return result.exitCode == 0;
  }

  static String _launchAgentPath() =>
      '${_home()}/Library/LaunchAgents/$label.plist';

  /// The plist launchd loads at login and fires on the schedule.
  ///
  /// Pure, so the XML can be asserted in a test without a `launchctl` on the
  /// machine running it.
  static String launchAgentPlist(CleanupSchedule schedule, String executable) {
    final interval = <String, int>{
      'Hour': schedule.hour,
      'Minute': schedule.minute,
      if (schedule.frequency == ScheduleFrequency.weekly)
        // launchd numbers Sunday 0, and accepts 7 for it as well, which is
        // exactly what `DateTime.sunday` is. So `dayOfWeek` maps straight
        // across with no table.
        'Weekday': schedule.dayOfWeek,
      if (schedule.frequency == ScheduleFrequency.monthly)
        'Day': schedule.dayOfMonth,
    };

    final entries = interval.entries
        .map(
          (e) =>
              '      <key>${e.key}</key>\n'
              '      <integer>${e.value}</integer>',
        )
        .join('\n');

    return '''
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>$label</string>
  <key>ProgramArguments</key>
  <array>
    <string>${_xml(executable)}</string>
    <string>$flag</string>
  </array>
  <key>EnvironmentVariables</key>
  <dict>
    <key>$environmentKey</key>
    <string>1</string>
  </dict>
  <key>StartCalendarInterval</key>
  <dict>
$entries
  </dict>
  <key>RunAtLoad</key>
  <false/>
  <key>ProcessType</key>
  <string>Background</string>
</dict>
</plist>
''';
  }

  // ------------------------------------------------------------------ Linux

  Future<bool> _installSystemd(
    CleanupSchedule schedule,
    String executable,
  ) async {
    for (final (kind, body) in [
      ('service', systemdService(executable)),
      ('timer', systemdTimer(schedule)),
    ]) {
      final file = File(_systemdPath(kind));
      file.parent.createSync(recursive: true);
      file.writeAsStringSync(body);
    }

    await Process.run('systemctl', ['--user', 'daemon-reload']);
    final result = await Process.run('systemctl', [
      '--user',
      'enable',
      '--now',
      '$label.timer',
    ]);
    return result.exitCode == 0;
  }

  /// Where systemd looks for a user unit.
  ///
  /// `XDG_CONFIG_HOME` first, because a user who has moved their config
  /// directory has moved it for systemd too, and writing to the hard-coded
  /// `~/.config` would put the units somewhere systemd never reads.
  static String _systemdPath(String kind) {
    final config = Platform.environment['XDG_CONFIG_HOME'];
    final base = (config == null || config.isEmpty)
        ? '${_home()}/.config'
        : config;
    return '$base/systemd/user/$label.$kind';
  }

  static String systemdService(String executable) =>
      '''
[Unit]
Description=Kruftle scheduled cleanup

[Service]
Type=oneshot
Environment=$environmentKey=1
ExecStart=$executable $flag
''';

  /// The timer half. `Persistent=true` is what covers a machine that was
  /// asleep or switched off at the appointed minute: systemd notices the
  /// missed run at the next boot and does it then.
  static String systemdTimer(CleanupSchedule schedule) =>
      '''
[Unit]
Description=Kruftle scheduled cleanup

[Timer]
OnCalendar=${onCalendar(schedule)}
Persistent=true

[Install]
WantedBy=timers.target
''';

  /// systemd's calendar syntax for [schedule].
  static String onCalendar(CleanupSchedule schedule) {
    final time = '${_two(schedule.hour)}:${_two(schedule.minute)}:00';
    return switch (schedule.frequency) {
      ScheduleFrequency.daily => '*-*-* $time',
      ScheduleFrequency.weekly =>
        '${_systemdWeekdays[schedule.dayOfWeek - 1]} *-*-* $time',
      // systemd simply skips a month that has no such day, where launchd and
      // Kruftle's own arithmetic clamp to the last one. Documented rather than
      // worked around: emulating the clamp would mean twelve OnCalendar lines.
      ScheduleFrequency.monthly => '*-*-${_two(schedule.dayOfMonth)} $time',
    };
  }

  static const _systemdWeekdays = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  // ---------------------------------------------------------------- Windows

  Future<bool> _installTask(CleanupSchedule schedule, String executable) async {
    final result = await Process.run(
      'schtasks',
      schtasksArguments(schedule, executable),
    );
    return result.exitCode == 0;
  }

  /// The argv for `schtasks /Create`.
  ///
  /// `/F` overwrites an existing task, which is what makes re-registering an
  /// edited schedule work. The command is one argument holding a quoted path,
  /// because Task Scheduler re-parses `/TR` itself and a `C:\Program Files`
  /// path splits in two without the inner quotes.
  static List<String> schtasksArguments(
    CleanupSchedule schedule,
    String executable,
  ) => [
    '/Create',
    '/F',
    '/TN',
    label,
    '/TR',
    '"$executable" $flag',
    '/ST',
    '${_two(schedule.hour)}:${_two(schedule.minute)}',
    ...switch (schedule.frequency) {
      ScheduleFrequency.daily => ['/SC', 'DAILY'],
      ScheduleFrequency.weekly => [
        '/SC',
        'WEEKLY',
        '/D',
        _schtasksWeekdays[schedule.dayOfWeek - 1],
      ],
      ScheduleFrequency.monthly => [
        '/SC',
        'MONTHLY',
        '/D',
        '${schedule.dayOfMonth}',
      ],
    },
  ];

  static const _schtasksWeekdays = [
    'MON',
    'TUE',
    'WED',
    'THU',
    'FRI',
    'SAT',
    'SUN',
  ];

  // ------------------------------------------------------------------ bits

  static String _two(int value) => value.toString().padLeft(2, '0');

  static String _home() =>
      Platform.environment['HOME'] ??
      Platform.environment['USERPROFILE'] ??
      Directory.current.path;

  static String _uid() =>
      Process.runSync('id', ['-u']).stdout.toString().trim();

  /// The five XML entities, for a path containing an ampersand.
  static String _xml(String value) => value
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;')
      .replaceAll("'", '&apos;');
}
