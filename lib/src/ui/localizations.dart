// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:material_ui/material_ui.dart';

import '../../l10n/app_localizations.dart';

/// Every delegate the app's `MaterialApp`s need. Material and Cupertino strings
/// come from material_ui rather than flutter_localizations, because the
/// widgets look their localizations up by type and would not find the old ones.
final List<LocalizationsDelegate<dynamic>> kLocalizationsDelegates = [
  L.delegate,
  ...GlobalMaterialLocalizations.delegates,
];
