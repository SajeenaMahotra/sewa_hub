import 'package:flutter/material.dart';
import 'button2.dart';
import 'button_outline.dart';

class BottomActionCard extends StatelessWidget {
  const BottomActionCard({super.key});

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
            child: ButtonOutline(
              text: 'Message',
              onPressed: () {},
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Button2(
              text: 'Book now',
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }
}
