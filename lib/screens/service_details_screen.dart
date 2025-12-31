import 'package:flutter/material.dart';
import 'package:sewa_hub/core/widgets/service_datails_card.dart';
import 'package:sewa_hub/core/widgets/service_included_card.dart';
import 'package:sewa_hub/core/widgets/bottom_action_card.dart';

class ServiceDetailsScreen extends StatelessWidget {
  const ServiceDetailsScreen({
    super.key,
    required this.imagePath,
    required this.title,
    required this.provider,
    required this.rating,
    required this.ratingCount,
    required this.location,
    required this.price,
    required this.experience,
    required this.description,
    required this.serviceIncludes,
  });

  final String imagePath;
  final String title;
  final String provider;
  final double rating;
  final int ratingCount;
  final String location;
  final String price;
  final String experience;
  final String description;
  final List<String> serviceIncludes;

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final double imageHeight = size.height * 0.45;
    final double minSheetSize = 0.6;
    final bool isTablet = size.width > 600;

    // Font size scaling
    final double titleFontSize = isTablet ? 28 : 22;
    final double subtitleFontSize = isTablet ? 20 : 16;
    final double normalFontSize = isTablet ? 18 : 14;
    final double spacing = isTablet ? 16.0 : 10.0;

    return Scaffold(
      body: Stack(
        children: [
          /// Background Image
          Image.asset(
            imagePath,
            height: imageHeight,
            width: double.infinity,
            fit: BoxFit.cover,
          ),

          /// Back Button
          SafeArea(
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          /// Draggable Sheet
          DraggableScrollableSheet(
            initialChildSize: minSheetSize,
            minChildSize: minSheetSize, // cannot go below image
            maxChildSize: 0.95, // can drag UP
            builder: (context, scrollController) {
              return ServiceDatailsCard(
                scrollController: scrollController,
                title: title,
                provider: provider,
                rating: rating,
                ratingCount: ratingCount,
                location: location,
                price: price,
                experience: experience,
                description: description,
                serviceIncludes: serviceIncludes,
                titleFontSize: titleFontSize,
                subtitleFontSize: subtitleFontSize,
                normalFontSize: normalFontSize,
                spacing: spacing,
              );
            },
          ),

          // Bottom Buttons Card
          const Positioned(
            bottom: 10,
            left: 0,
            right: 0,
            child: BottomActionCard(),
          ),
        ],
      ),
    );
  }
}