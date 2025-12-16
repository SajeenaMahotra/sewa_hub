import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sewa_hub/widget/category_card_widget.dart';
import 'package:sewa_hub/widget/home_card_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const HomeCardWidget(),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 20.0),
              child: Text(
                "What service are you\nlooking for ?",
                style: const TextStyle(
                  fontFamily: 'Inter Bold',
                  fontSize: 30,
                ),
                textAlign: TextAlign.left,
              ),
            ),
            const SizedBox(height: 20),
            // 🔍 Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF7940),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Search what you need .......",
                      prefixIcon: const Icon(Icons.search),
                      border: InputBorder.none,
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

Padding(
  padding: const EdgeInsets.symmetric(horizontal: 20),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: const [
      Text(
        "Categories",
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      Text(
        "See all",
        style: TextStyle(
          color: Color(0xFFFF7940),
          fontWeight: FontWeight.w500,
        ),
      ),
    ],
  ),
),

const SizedBox(height: 12),

SizedBox(
  height: 150,
  child: ListView(
    scrollDirection: Axis.horizontal,
    padding: const EdgeInsets.only(left: 20),
    children: const [
      CategoryCardWidget(icon: Icons.plumbing, title: "Plumbing"),
      CategoryCardWidget(icon: Icons.electrical_services, title: "Electrician"),
      CategoryCardWidget(icon: Icons.format_paint, title: "Painting"),
      CategoryCardWidget(icon: Icons.build, title: "Carpenter"),
    ],
  ),
),

          ],
        ),
      ),
    );
  }
}