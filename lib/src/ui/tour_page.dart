// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../core/disk/native_disk.dart';
import 'anim/animated_bytes.dart';
import 'anim/cleaning_sweep.dart';
import 'anim/motion.dart';
import 'anim/radar_sweep.dart';
import 'state/app_state.dart';
import 'theme.dart';
import 'viz/disk_gauge.dart';

/// One page of the tour.
class TourPage {
  const TourPage({
    required this.title,
    required this.body,
    required this.illustration,
  });

  final String title;
  final String body;
  final Widget illustration;
}

/// First-run welcome and a short tour of what the app does.
///
/// Replayable from Settings, so it is not a one-shot the user can never see
/// again — which is what makes it worth writing at all. Each page is
/// illustrated with the actual widget it describes rather than a picture of
/// one: the radar page shows the radar, the cleaning page shows the cleaning
/// bar. No screenshots to keep in step with the app.
class TourScreen extends ConsumerStatefulWidget {
  const TourScreen({super.key, this.onFinished});

  /// Called when the tour is finished or skipped. Defaults to popping the
  /// route, which is what the "show it again" entry point wants.
  final VoidCallback? onFinished;

  @override
  ConsumerState<TourScreen> createState() => _TourScreenState();
}

class _TourScreenState extends ConsumerState<TourScreen> {
  final _pages = PageController();
  var _index = 0;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  List<TourPage> _content(L l) => [
    TourPage(
      title: l.tourWelcomeTitle,
      body: l.tourWelcomeBody,
      illustration: const _Sweeping(),
    ),
    TourPage(
      title: l.tourScanTitle,
      body: l.tourScanBody,
      illustration: const RadarSweep(blipCount: 21, size: 150),
    ),
    TourPage(
      title: l.tourReviewTitle,
      body: l.tourReviewBody,
      illustration: const _Counting(),
    ),
    TourPage(
      title: l.tourSafetyTitle,
      body: l.tourSafetyBody,
      illustration: const _Glyph(Icons.shield_outlined),
    ),
    TourPage(
      title: l.tourCachesTitle,
      body: l.tourCachesBody,
      illustration: const _Gauge(),
    ),
    TourPage(
      title: l.tourScheduleTitle,
      body: l.tourScheduleBody,
      illustration: const _Glyph(Icons.schedule_rounded),
    ),
    TourPage(
      title: l.tourFinishTitle,
      body: l.tourFinishBody,
      illustration: const _Glyph(Icons.verified_user_outlined),
    ),
  ];

  Future<void> _finish() async {
    await ref
        .read(settingsProvider.notifier)
        .update((s) => s.copyWith(hasSeenTour: true));
    if (!mounted) return;
    final onFinished = widget.onFinished;
    if (onFinished != null) {
      onFinished();
    } else {
      await Navigator.of(context).maybePop();
    }
  }

  void _next(int total) {
    if (_index >= total - 1) {
      _finish();
      return;
    }
    _pages.nextPage(duration: Motion.quick, curve: Motion.change);
  }

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final pages = _content(l);
    final isLast = _index == pages.length - 1;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pages,
                onPageChanged: (i) => setState(() => _index = i),
                itemCount: pages.length,
                itemBuilder: (context, i) => _Page(page: pages[i]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 8, 32, 26),
              child: Row(
                children: [
                  // Skip is on every page, not only the first. Someone who
                  // decides on page four that they have seen enough should not
                  // have to page through the rest to escape.
                  TextButton(
                    onPressed: _finish,
                    child: Text(_index == 0 ? l.tourWelcomeSkip : l.actionSkip),
                  ),
                  const Spacer(),
                  for (var i = 0; i < pages.length; i++)
                    _Dot(active: i == _index),
                  const Spacer(),
                  FilledButton(
                    onPressed: () => _next(pages.length),
                    child: Text(
                      isLast
                          ? l.tourFinishAction
                          : _index == 0
                          ? l.tourWelcomeStart
                          : l.actionNext,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Page extends StatelessWidget {
  const _Page({required this.page});

  final TourPage page;

  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 560),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 170, child: Center(child: page.illustration)),
            const SizedBox(height: 34),
            Text(
              page.title,
              textAlign: TextAlign.center,
              style: context.text.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              page.body,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.5,
                height: 1.6,
                color: context.colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _Dot extends StatelessWidget {
  const _Dot({required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) => AnimatedContainer(
    duration: Motion.quick,
    curve: Motion.change,
    margin: const EdgeInsets.symmetric(horizontal: 3),
    width: active ? 18 : 6,
    height: 6,
    decoration: BoxDecoration(
      color: active
          ? context.colors.primary
          : context.colors.onSurfaceVariant.withValues(alpha: 0.3),
      borderRadius: BorderRadius.circular(3),
    ),
  );
}

class _Sweeping extends StatelessWidget {
  const _Sweeping();

  @override
  Widget build(BuildContext context) => const SizedBox(
    width: 300,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CleaningSweep(value: 0.72, height: 12),
        SizedBox(height: 18),
        CleaningSweep(value: 0.44, height: 12),
        SizedBox(height: 18),
        CleaningSweep(value: 0.9, height: 12),
      ],
    ),
  );
}

class _Counting extends StatelessWidget {
  const _Counting();

  @override
  Widget build(BuildContext context) => AnimatedBytes(
    94 * 1024 * 1024 * 1024,
    duration: const Duration(milliseconds: 1800),
    style: TextStyle(
      fontSize: 44,
      fontWeight: FontWeight.w700,
      letterSpacing: -1,
      color: context.colors.primary,
    ),
  );
}

class _Gauge extends StatelessWidget {
  const _Gauge();

  @override
  Widget build(BuildContext context) => const SizedBox(
    width: 320,
    child: DiskGauge(
      before: DiskSpace(totalBytes: 1000, freeBytes: 120, availableBytes: 120),
      after: DiskSpace(totalBytes: 1000, freeBytes: 460, availableBytes: 460),
      beforeLabel: '',
      afterLabel: '',
      height: 30,
    ),
  );
}

class _Glyph extends StatelessWidget {
  const _Glyph(this.icon);

  final IconData icon;

  @override
  Widget build(BuildContext context) => Container(
    width: 132,
    height: 132,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: context.colors.primary.withValues(alpha: 0.1),
      border: Border.all(color: context.colors.primary.withValues(alpha: 0.3)),
    ),
    child: Icon(icon, size: 54, color: context.colors.primary),
  );
}
