// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:io';

/// Sends a desktop notification.
///
/// An interface so the schedule can be tested without a notification centre,
/// and so the platform command can be swapped without touching the caller.
abstract interface class DesktopNotifier {
  /// Posts a notification. Returns false when the platform could not, which
  /// is information rather than an error: the in-app banner is the reminder
  /// that always works, and this is the one that reaches the user when the
  /// window is behind something else.
  Future<bool> notify({required String title, required String body});
}

/// Posts through whatever the operating system already provides.
///
/// **No notification package.** macOS and Linux each expose this as one
/// command that ships with the system — `osascript` and `notify-send` — and
/// shelling out to them is a dozen lines with nothing to keep up to date.
///
/// **ponytail: Windows gets no OS notification.** A toast there needs a
/// registered AppUserModelID and a WinRT call, which is real work rather than
/// a command line, and the app is unsigned so the registration is awkward too.
/// The in-app banner still appears, which given that Kruftle has to be running
/// for the schedule to fire at all is most of the value. If Windows toasts are
/// wanted, `local_notifier` is the package that does it, and this class is the
/// one place that would change.
class SystemNotifier implements DesktopNotifier {
  const SystemNotifier();

  @override
  Future<bool> notify({required String title, required String body}) async {
    try {
      if (Platform.isMacOS) {
        // The script text is built with both values escaped as AppleScript
        // string literals, and handed over as an argument rather than through
        // a shell. A folder name containing a quote must not be able to end
        // the string and start a new statement.
        final result = await Process.run('osascript', [
          '-e',
          'display notification ${_escape(body)} '
              'with title ${_escape(title)}',
        ]);
        return result.exitCode == 0;
      }

      if (Platform.isLinux) {
        final result = await Process.run('notify-send', [
          '--app-name=Kruftle',
          title,
          body,
        ]);
        return result.exitCode == 0;
      }
    } on Object {
      // A machine with no `notify-send`, or a locked-down `osascript`, is not
      // a reason to fail whatever the caller was doing.
      return false;
    }
    return false;
  }

  /// AppleScript string literal: wrap in quotes, escape backslashes and
  /// quotes. Without this a path containing a quote becomes executable script.
  static String _escape(String value) {
    final escaped = value.replaceAll(r'\', r'\\').replaceAll('"', r'\"');
    return '"$escaped"';
  }
}

/// Records notifications instead of posting them.
class RecordingNotifier implements DesktopNotifier {
  final List<({String title, String body})> sent = [];

  @override
  Future<bool> notify({required String title, required String body}) async {
    sent.add((title: title, body: body));
    return true;
  }
}
