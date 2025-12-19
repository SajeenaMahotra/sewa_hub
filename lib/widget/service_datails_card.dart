import 'package:flutter/material.dart';
import 'package:sewa_hub/widget/service_included_card.dart';

class ServiceDatailsCard extends StatelessWidget {
  const ServiceDatailsCard({
    super.key,
    required this.title,
    required this.provider,
    required this.rating,
    required this.ratingCount,
    required this.location,
    required this.price,
    required this.experience,
    required this.description,
    required this.serviceIncludes,
    required this.scrollController,
    required this.titleFontSize,
    required this.subtitleFontSize,
    required this.normalFontSize,
    required this.spacing,
  });

  final String title;
  final String provider;
  final double rating;
  final int ratingCount;
  final String location;
  final String price;
  final String experience;
  final String description;
  final List<String> serviceIncludes;
  final ScrollController scrollController;
  final double titleFontSize;
  final double subtitleFontSize;
  final double normalFontSize;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(spacing * 1.5),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: SingleChildScrollView(
        controller: scrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: spacing * 2),
            Text(
              title,
              style: TextStyle(
                fontSize: titleFontSize,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: spacing / 2),
            Row(
              children: [
                Text(provider, style: TextStyle(fontSize: normalFontSize)),
                const Spacer(),
                Icon(Icons.star, size: normalFontSize, color: Colors.orange),
                SizedBox(width: spacing / 4),
                Text(
                  '$rating ($ratingCount)',
                  style: TextStyle(fontSize: normalFontSize),
                ),
              ],
            ),

            SizedBox(height: spacing),
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  size: normalFontSize,
                  color: Colors.red,
                ),
                SizedBox(width: spacing / 2),
                Text(location, style: TextStyle(fontSize: normalFontSize)),
              ],
            ),
            SizedBox(height: spacing),
            /// Price
            Text(
              price,
              style: TextStyle(
                fontSize: subtitleFontSize,
                color: const Color(0xFFFF7940),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: spacing / 2),
            Text(
              'Experience: $experience',
              style: TextStyle(fontSize: normalFontSize),
            ),

            SizedBox(height: spacing * 2),
            Text(
              'Service Includes',
              style: TextStyle(
                fontSize: subtitleFontSize,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: spacing),
            Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: serviceIncludes
                  .map(
                    (item) => ServiceIncludedCard(
                      text: item,
                      fontSize: normalFontSize, 
                      horizontalPadding: spacing,
                      verticalPadding: spacing / 2, 
                    ),
                  )
                  .toList(),
            ),

            SizedBox(height: spacing * 2),

            /// Description
            Text(
              'Description',
              style: TextStyle(
                fontSize: subtitleFontSize,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: spacing / 2),

            Text(
              description,
              style: TextStyle(fontSize: normalFontSize, height: 1.5),
            ),

            SizedBox(height: spacing * 5), // bottom padding for scroll
          ],
        ),
      ),
    );
  }
}
