import 'package:flutter/material.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onSeeAll;
  final double sf;

  const SectionHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.sf,
    this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16 * sf),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16 * sf,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 2 * sf),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 11.5 * sf, color: Colors.grey),
                ),
              ],
            ),
          ),
          if (onSeeAll != null)
            GestureDetector(
              onTap: onSeeAll,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 11 * sf,
                  vertical: 6 * sf,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Text(
                      'See all',
                      style: TextStyle(
                        color: Colors.orange,
                        fontSize: 11.5 * sf,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 3 * sf),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 9 * sf,
                      color: Colors.orange,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}