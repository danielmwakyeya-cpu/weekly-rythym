import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// A shimmer placeholder that mimics the shape of a SlotCardWidget.
class ShimmerSlotCard extends StatelessWidget {
  final Color baseColor;
  final Color highlightColor;

  const ShimmerSlotCard({
    super.key,
    this.baseColor = const Color(0xFF2A2035),
    this.highlightColor = const Color(0xFF3D3048),
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: baseColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            // Checkbox placeholder
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: baseColor,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 14,
                    width: 140,
                    decoration: BoxDecoration(
                      color: baseColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    height: 10,
                    width: 80,
                    decoration: BoxDecoration(
                      color: baseColor,
                      borderRadius: BorderRadius.circular(4),
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

/// A shimmer placeholder for the stats bar.
class ShimmerStatsBar extends StatelessWidget {
  final Color baseColor;
  final Color highlightColor;

  const ShimmerStatsBar({
    super.key,
    this.baseColor = const Color(0xFF2A2035),
    this.highlightColor = const Color(0xFF3D3048),
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: baseColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(
            4,
            (_) => Column(
              children: [
                Container(
                  width: 36,
                  height: 14,
                  decoration: BoxDecoration(
                    color: baseColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: 46,
                  height: 10,
                  decoration: BoxDecoration(
                    color: baseColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A shimmer placeholder for Keep notes grid.
class ShimmerKeepGrid extends StatelessWidget {
  final Color baseColor;
  final Color highlightColor;

  const ShimmerKeepGrid({
    super.key,
    this.baseColor = const Color(0xFF2A2035),
    this.highlightColor = const Color(0xFF3D3048),
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: List.generate(
            6,
            (i) => Container(
              width: (MediaQuery.of(context).size.width - 44) / 2,
              height: 100 + (i % 3) * 30.0,
              decoration: BoxDecoration(
                color: baseColor,
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Full loading screen with shimmer cards.
class ShimmerDayView extends StatelessWidget {
  final Color baseColor;
  final Color highlightColor;

  const ShimmerDayView({
    super.key,
    this.baseColor = const Color(0xFF2A2035),
    this.highlightColor = const Color(0xFF3D3048),
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 30),
      child: Column(
        children: [
          ShimmerStatsBar(baseColor: baseColor, highlightColor: highlightColor),
          const SizedBox(height: 8),
          // Day selector placeholder
          Shimmer.fromColors(
            baseColor: baseColor,
            highlightColor: highlightColor,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              height: 36,
              decoration: BoxDecoration(
                color: baseColor,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Card placeholders
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: List.generate(
                5,
                (_) => ShimmerSlotCard(baseColor: baseColor, highlightColor: highlightColor),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
