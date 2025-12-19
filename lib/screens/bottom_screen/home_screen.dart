import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sewa_hub/screens/service_details_screen.dart';
import 'package:sewa_hub/widget/category_card_widget.dart';
import 'package:sewa_hub/widget/home_card_widget.dart';
import 'package:sewa_hub/widget/service_card_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const List<Map<String, String>> categories = [
    {'title': 'Plumbing', 'imagePath': 'assets/icons/plumbing.png'},
    {'title': 'Electrician', 'imagePath': 'assets/icons/electrician.png'},
    {'title': 'Painter', 'imagePath': 'assets/icons/paintroller.png'},
    {'title': 'Carpenter', 'imagePath': 'assets/icons/carpenter.png'},
  ];
  static const List<Map<String, dynamic>> popularServices = [
    {
      'imagePath': 'assets/images/serviceelectricity.png',
      'title': 'Electrical grid connection',
      'provider': 'William James',
      'price': 600.0,
      'rating': 4.0,
      'ratingCount': 10,
      'location': 'Creighton Avenue, Eastham',
      'experience': '3+ years',
      'description':
          'I provide full electrical grid connection services including installation, wiring, diagnostics and safety checks.',
      'serviceIncludes': [
        'Meter Installations',
        'Fault Diagnosis',
        'New Wiring Setup',
        'Fuse Setup',
      ],
    },
    {
      'imagePath': 'assets/images/serviceplumbing.png',
      'title': 'Plumbing Fix',
      'provider': 'John Doe',
      'price': 500.0,
      'rating': 4.5,
      'ratingCount': 12,
    },
    {
      'imagePath': 'assets/images/serviceelectricity.png',
      'title': 'AC Repair & Installation',
      'provider': 'Mike Johnson',
      'price': 750.0,
      'rating': 4.7,
      'ratingCount': 18,
    },
    {
      'imagePath': 'assets/images/watertankcleaning.png',
      'title': 'Water Tank Cleaning',
      'provider': 'Sarah Williams',
      'price': 450.0,
      'rating': 4.3,
      'ratingCount': 9,
    },
    {
      'imagePath': 'assets/images/serviceelectricity.png',
      'title': 'Home Wiring',
      'provider': 'Robert Brown',
      'price': 800.0,
      'rating': 4.8,
      'ratingCount': 22,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isTablet = screenWidth >= 600;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 25),
            const HomeCardWidget(),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 20.0),
              child: Text(
                "What service are you\nlooking for ?",
                style: TextStyle(
                  fontFamily: 'Inter Bold',
                  fontSize: isTablet ? 36 : 30,
                ),
                textAlign: TextAlign.left,
              ),
            ),
            const SizedBox(height: 20),
            // Search Bar
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
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
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
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
              height: isTablet ? 180 : 150,

              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(left: 20),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return CategoryCardWidget(
                    title: category['title']!,
                    imagePath: category['imagePath']!,
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Popular Services",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
              height: 260,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(left: 20, right: 20),
                physics: const BouncingScrollPhysics(),
                itemCount: popularServices.length,
                itemBuilder: (context, index) {
                  final service = popularServices[index];
                  return ServiceCardWidget(
                    imagePath: service['imagePath'] as String,
                    title: service['title'] as String,
                    provider: service['provider'] as String,
                    price: service['price'] as double,
                    rating: service['rating'] as double,
                    ratingCount: service['ratingCount'] as int,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ServiceDetailsScreen(
                            imagePath: service['imagePath'],
                            title: service['title'],
                            provider: service['provider'],
                            rating: service['rating'],
                            ratingCount: service['ratingCount'],
                            location: service['location'],
                            price: 'Rs. ${service['price']} / hr',
                            experience: service['experience'],
                            description: service['description'],
                            serviceIncludes: List<String>.from(
                              service['serviceIncludes'],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "All Services",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(), // parent scrolls
              padding: const EdgeInsets.only(left: 20),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isTablet ? 2 : 2,
                crossAxisSpacing: 5,
                mainAxisSpacing: 20,
                childAspectRatio: isTablet ? 1.6 : 0.8,
              ),
              itemCount: 10, // later dynamic / endless
              itemBuilder: (context, index) {
                return ServiceCardWidget(
                  imagePath: 'assets/images/serviceelectricity.png',
                  title: 'Service #$index',
                  provider: 'Provider Name',
                  price: 500 + index * 10,
                  rating: 4.3,
                  ratingCount: 12,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
