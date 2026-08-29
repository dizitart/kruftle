// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kruftle/src/core/update/swap_scripts.dart';

/// The Inno Setup script's contract with two callers that cannot speak up when
/// it changes: the Microsoft Store, which runs it unattended, and Kruftle's own
/// updater, which falls back to it for installs it cannot replace itself.
void main() {
  final inno = File('packaging/windows/kruftle.iss').readAsStringSync();

  test('an unattended install neither prompts nor reboots', () {
    // /VERYSILENT and /NORESTART are Inno's own switches and always accepted;
    // what has to be true is that nothing in the script makes the installer
    // want a reboot or a dialog anyway.
    expect(inno, contains('RestartIfNeededByRun=no'));
    expect(inno, contains('/VERYSILENT /NORESTART'));

    // `skipifsilent` on the [Run] entry: an unattended install starts nothing.
    expect(inno, contains('skipifsilent'));
  });

  test('a silent install closes a running Kruftle instead of failing', () {
    // Without this, Setup finds its own files locked by the running app and
    // either fails or asks for a reboot — the two things a Store submission
    // may not do.
    expect(inno, contains('CloseApplications=yes'));
    expect(inno, contains('RestartApplications=yes'));
  });

  test('the default install is one the app can replace itself inside', () {
    // Kruftle's self-update renames the install directory, which needs its
    // parent writable. Under C:\Program Files it is not, and the app has to
    // fall back to downloading and running this installer. Per-user is what
    // keeps the quiet path the normal one; /ALLUSERS still gives a
    // machine-wide install to anyone who asks for one.
    expect(inno, contains('PrivilegesRequired=lowest'));
    expect(inno, contains('PrivilegesRequiredOverridesAllowed=commandline'));
    expect(
      inno,
      contains('UsePreviousPrivileges=yes'),
      reason: 'an existing machine-wide install must stay machine-wide',
    );
  });

  test('the self-update fallback passes switches the script honours', () {
    // These are the arguments `Updater.install` hands a downloaded .exe.
    final updater = File('lib/src/core/update/updater.dart').readAsStringSync();
    for (final switchName in const [
      '/SILENT',
      '/NORESTART',
      '/CLOSEAPPLICATIONS',
      '/RESTARTAPPLICATIONS',
    ]) {
      expect(updater, contains("'$switchName'"), reason: switchName);
    }
  });

  test('the swap helper keeps the uninstaller Inno leaves behind', () {
    // It is written into the install directory by Setup and is not part of the
    // build output, so a directory swap that did not carry it over would leave
    // an Add/Remove Programs entry pointing at nothing.
    expect(windowsSwapScript, contains("-Filter 'unins*'"));
  });

  test('the swap helper puts the old install back when it cannot finish', () {
    expect(windowsSwapScript, contains('Move-WithRetry \$old \$Dir'));
  });

  test('the swap helper writes down what it did', () {
    // It runs entirely after Kruftle has exited, so this file is the only
    // trace it can leave. Without it a swap that silently did nothing was
    // indistinguishable from one that never started.
    expect(windowsSwapScript, contains(r'[string]$Log'));
    expect(windowsSwapScript, contains('function Note'));
    expect(
      windowsSwapScript,
      contains(r"$ProgressPreference = 'SilentlyContinue'"),
      reason: 'a progress bar with no console to draw it on is a hazard here',
    );
  });
}
