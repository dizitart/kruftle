// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';

/// Holds the app icons to each platform's own layout.
///
/// The three do not agree. Windows and GNOME draw a square icon edge to edge.
/// macOS does not: its grid puts the body of an app icon in the middle 824 of
/// 1024 points and leaves the rest transparent, and the Dock lays every icon
/// out on that assumption. An icon drawn to the edge is not scaled down to fit
/// — it is drawn at the size it was given, a quarter larger than everything
/// beside it, which is exactly what Kruftle used to look like.
///
/// Regenerate with `./tool/make_icons.sh`.
void main() {
  /// The transparent margin on the left of the opaque part of [file], in
  /// pixels, and the image's width.
  Future<({int inset, int width})> measure(String file) async {
    final codec = await ui.instantiateImageCodec(File(file).readAsBytesSync());
    final image = (await codec.getNextFrame()).image;
    final pixels = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    final width = image.width;

    var left = width;
    for (var y = 0; y < image.height; y++) {
      for (var x = 0; x < width; x++) {
        final alpha = pixels!.getUint8((y * width + x) * 4 + 3);
        if (alpha != 0 && x < left) left = x;
      }
    }
    image.dispose();
    return (inset: left, width: width);
  }

  group('macOS', () {
    const sizes = [16, 32, 64, 128, 256, 512, 1024];
    const path = 'macos/Runner/Assets.xcassets/AppIcon.appiconset';

    for (final size in sizes) {
      test('app_icon_$size sits inside the macOS icon grid', () async {
        final measured = await measure('$path/app_icon_$size.png');
        expect(measured.width, size);

        // Apple's grid, scaled to this size and rounded to whole pixels: the
        // body is 824/1024 of the canvas and the rest is transparent.
        final body = (size * 824 + 512) ~/ 1024;
        expect(
          measured.inset,
          (size - body) ~/ 2,
          reason:
              'app_icon_$size does not sit on the macOS icon grid; drawn to '
              'the edge it renders a quarter oversized in the Dock',
        );
      });
    }
  });

  group('Linux and Windows', () {
    for (final size in const [16, 32, 48, 64, 128, 256, 512]) {
      test('the ${size}px hicolor icon is full bleed', () async {
        // GNOME does the insetting itself, so an icon that arrived pre-inset
        // would come out too small.
        final measured = await measure(
          'assets/icon/linux/${size}x$size/kruftle.png',
        );
        expect(measured.width, size);
        expect(measured.inset, 0);
      });
    }
  });
}
