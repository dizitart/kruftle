// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kruftle/src/ui/widgets/common.dart';

/// A `SnackBar` given an action defaults to `persist: true`, and a persistent
/// snack bar never times out. The "log exported" toast therefore sat over the
/// report until the user clicked it. `showToast` is what pins the default.
void main() {
  Future<void> pumpToast(WidgetTester tester, {SnackBarAction? action}) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => showToast(context, 'Exported', action: action),
              child: const Text('go'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('go'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }

  for (final (name, action) in [
    ('without an action', null),
    ('with an action', SnackBarAction(label: 'Show', onPressed: () {})),
  ]) {
    testWidgets('a toast $name goes away on its own', (tester) async {
      await pumpToast(tester, action: action);
      expect(find.text('Exported'), findsOneWidget);

      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
      expect(find.text('Exported'), findsNothing);
    });
  }
}
