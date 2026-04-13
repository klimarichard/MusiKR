import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/constants/layout_constants.dart';
import '../../../domain/models/section.dart';

/// A tappable header band displayed above a section's bars.
///
/// Shows the section name (e.g. "A", "Verse") and, when the section has a
/// [RepeatInfo], a small repeat-count badge ("×2").
class SectionHeader extends StatelessWidget {
  final Section section;
  final VoidCallback onTap;

  const SectionHeader({
    super.key,
    required this.section,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: kSectionHeaderHeightDp,
        color: AppColors.sectionBand,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            Text(
              section.name.isEmpty ? '—' : section.name,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const Spacer(),
            if (section.repeatInfo != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: AppColors.chartLines,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '×${section.repeatInfo!.repeatCount}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
