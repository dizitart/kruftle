// SPDX-License-Identifier: GPL-3.0-or-later

import '../models/stack.dart';
import 'stacks/dartlang.dart';
import 'stacks/jvm.dart';
import 'stacks/native.dart';
import 'stacks/scripting.dart';
import 'stacks/systems.dart';
import 'stacks/web.dart';

/// Every stack Kruftle can detect and clean.
///
/// **To add language support:** add a [StackId] value, write a
/// [StackDefinition] in the appropriate file under `stacks/`, and add it to
/// this list. That is the whole extension point — there is deliberately no
/// class to subclass and no plugin lifecycle to implement.
const List<StackDefinition> kStacks = [
  rustStack,
  goStack,
  zigStack,
  flutterStack,
  dartStack,
  mavenStack,
  gradleStack,
  nodeStack,
  pythonStack,
  rubyStack,
  elixirStack,
  cmakeStack,
  makeStack,
  dotnetStack,
  swiftStack,
  xcodeStack,
];

/// Looks up stack definitions and matches directories against them.
class StackRegistry {
  const StackRegistry([this.stacks = kStacks]);

  final List<StackDefinition> stacks;

  StackDefinition? byId(StackId id) =>
      stacks.where((s) => s.id == id).firstOrNull;

  /// Every stack that claims [listing], highest [StackDefinition.priority]
  /// first.
  ///
  /// A directory legitimately matches more than one stack — a Flutter app also
  /// has a Gradle build, a Rust crate can carry a Makefile — so this returns
  /// all of them rather than picking a winner. The cleaner runs each one's
  /// command; the tools themselves know which files are theirs.
  List<StackDefinition> detect(DirListing listing) {
    final matched = stacks.where((s) => s.detect(listing)).toList()
      ..sort((a, b) => b.priority.compareTo(a.priority));
    return matched;
  }

  /// True when any stack could claim this directory, used by the scanner to
  /// decide whether to stop descending.
  bool isProjectRoot(DirListing listing) => stacks.any((s) => s.detect(listing));
}

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
