import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class FloatingBottomBarItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const FloatingBottomBarItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

class FloatingBottomBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<FloatingBottomBarItem> items;

  const FloatingBottomBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20, bottom: 24),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.vantaSurfaceDark.withValues(alpha: 0.95), // Glassmorphic Dark Surface
        borderRadius: BorderRadius.circular(38), // Capsule pill shape
        border: Border.all(color: AppTheme.vantaBorder, width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x99000000),
            blurRadius: 24,
            spreadRadius: 2,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (index) {
          final isSelected = currentIndex == index;
          final item = items[index];

          return GestureDetector(
            onTap: () => onTap(index),
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutCubic,
              width: isSelected ? 135 : 46,
              height: 46,
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.vantaBlue : AppTheme.vantaCardDark,
                borderRadius: BorderRadius.circular(30),
                border: isSelected ? null : Border.all(color: AppTheme.vantaBorder, width: 1),
                boxShadow: isSelected
                    ? const [
                        BoxShadow(
                          color: Color(0x5500B4D8),
                          blurRadius: 12,
                          offset: Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const NeverScrollableScrollPhysics(),
                  child: SizedBox(
                    width: isSelected ? 135 : 46,
                    height: 46,
                    child: Center(
                      child: isSelected
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  item.activeIcon,
                                  color: AppTheme.vantaTextLight,
                                  size: 20,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  item.label,
                                  style: const TextStyle(
                                    color: AppTheme.vantaTextLight,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 13,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ],
                            )
                          : Icon(
                              item.icon,
                              color: AppTheme.vantaTextMuted,
                              size: 20,
                            ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
