import 'package:flutter/material.dart';

class BottomActionCard extends StatelessWidget {
  final VoidCallback? onMessageTap;
  final VoidCallback? onBookTap;

  const BottomActionCard({
    super.key,
    this.onMessageTap,
    this.onBookTap,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(16, 14, 16, 14 + bottomPadding),
      child: Row(
        children: [
          
  

          const SizedBox(width: 12),

          // ── Book Now (filled gradient) button ─────────────────────────
          Expanded(
            flex: 2,
            child: GestureDetector(
              onTap: onBookTap,
              child: Container(
                height: 50,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF6B35), Color(0xFFFF9A6C)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF6B35).withOpacity(0.38),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Text(
                  'Book now',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.1,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}