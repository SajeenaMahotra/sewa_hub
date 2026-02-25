import 'package:flutter/material.dart';
import 'package:sewa_hub/core/widgets/button_outline.dart';
import 'package:sewa_hub/core/widgets/primary_button.dart';

class BottomActionCard extends StatelessWidget {
  final VoidCallback onMessageTap;
  final VoidCallback onBookTap;

  const BottomActionCard({
    super.key,
    required this.onMessageTap,
    required this.onBookTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 50,
              child: ButtonOutline(
                text: 'Message',
                onPressed: onMessageTap,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SizedBox(
              height: 50,
              child: PrimaryButton(
                label: 'Book now',
                onTap: onBookTap,
                borderRadius: 15,
                fontSize: 17,
                fontWeight: FontWeight.w700,
                padding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }
}