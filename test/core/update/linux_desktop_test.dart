// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Holds the Linux packaging to the one name the desktop actually sees.
///
/// `linux/runner/my_application.cc` calls `g_set_prgname(APPLICATION_ID)`, so
/// a Kruftle window announces itself as `com.dizitart.kruftle` — as the Wayland
/// app_id, as the X11 WM_CLASS, and as `_GTK_APPLICATION_ID`. GNOME matches a
/// window to an application by looking for a desktop entry of that name and
/// then by StartupWMClass. Shipping `kruftle.desktop` with
/// `StartupWMClass=kruftle` matched on neither, and an unmatched window gets
/// the generic icon — which is what Kruftle looked like in the Ubuntu dock.
///
/// Three files have to agree on the string for that to work, and nothing at
/// build time notices when they stop. This is what notices.
void main() {
  const appId = 'com.dizitart.kruftle';

  String read(String path) => File(path).readAsStringSync();

  test('the GTK application id is what the packaging assumes', () {
    expect(
      read('linux/CMakeLists.txt'),
      contains('set(APPLICATION_ID "$appId")'),
    );
  });

  test('the runner announces itself under the application id', () {
    // Not the binary name: `g_set_prgname(APPLICATION_ID)` is what makes the
    // application id the name every desktop protocol carries.
    expect(
      read('linux/runner/my_application.cc'),
      contains('g_set_prgname(APPLICATION_ID)'),
    );
  });

  test('the desktop entry is named for the application id', () {
    expect(
      File('packaging/linux/$appId.desktop').existsSync(),
      isTrue,
      reason: 'GNOME looks for <application id>.desktop and nothing else',
    );
    expect(
      File('packaging/linux/kruftle.desktop').existsSync(),
      isFalse,
      reason: 'the old name matched no window and must not come back',
    );
  });

  test('the desktop entry points at an icon of the same name', () {
    final desktop = read('packaging/linux/$appId.desktop');
    expect(desktop, contains('\nIcon=$appId\n'));
    expect(desktop, contains('\nStartupWMClass=$appId\n'));
    expect(desktop, contains('\nExec=kruftle\n'));
  });

  test('every package installs the entry and the icons under that name', () {
    final script = read('packaging/linux/build-packages.sh');
    expect(script, contains('APP_ID=$appId'));
    expect(
      script,
      contains(r'"$prefix/usr/share/applications/$APP_ID.desktop"'),
    );
    expect(script, contains(r'"$dir/$APP_ID.png"'));
    // AppImage reads these two from the AppDir root, and the icon's basename
    // has to equal the entry's Icon= key.
    expect(script, contains(r'"$APPDIR/$APP_ID.desktop"'));
    expect(script, contains(r'"$APPDIR/$APP_ID.png"'));
  });

  test('the .deb refreshes the caches GTK reads icons out of', () {
    // GTK prefers /usr/share/icons/hicolor/icon-theme.cache over the directory
    // itself, so a freshly installed icon can stay invisible until something
    // rebuilds it. dpkg's triggers normally do; a plain `dpkg -i` on a slim
    // system does not.
    final script = read('packaging/linux/build-packages.sh');
    expect(script, contains('gtk-update-icon-cache'));
    expect(script, contains('update-desktop-database'));
    expect(script, contains('DEBIAN/\$script'));
  });
}
