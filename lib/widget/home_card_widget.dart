import 'package:flutter/material.dart';

class HomeCardWidget extends StatelessWidget {
  const HomeCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
        ),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 24,
              backgroundColor: const Color(0xFFFFD54F),
              child: Icon(
                Icons.person,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            // Greeting text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Hello !',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.black,
                      fontFamily: 'Inter Bold'
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'John Doe',
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
            // Location Icon
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.location_on,
                color: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}