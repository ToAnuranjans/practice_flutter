import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/address.dart';
import '../models/user.dart';

class ImageCarousal extends StatefulWidget {
  const ImageCarousal({
    super.key,
    required this.imageList,
    this.maxImages = 4,
    this.onViewAllClick, // optional callback when the "View All" thumbnail is tapped
  });
  final List<String> imageList;
  final int? maxImages;
  final void Function(String imageUrl)? onViewAllClick;

  @override
  State<ImageCarousal> createState() => _ImageCarousalState();
}

class _ImageCarousalState extends State<ImageCarousal> {
  late String mainImage;

  @override
  void initState() {
    super.initState();
    mainImage = widget.imageList.isNotEmpty ? widget.imageList[0] : '';

    Address address = Address('My st.', 'New York', 'NY', 'USA', '12345');
    User user = User('John', 'Doe', address);
    if (kDebugMode) {
      print(user.toJson());
    }
    //fix this json format
    var json = {
      'name': 'John',
      'email': 'Doe',
      'address': {
        'street': 'My st.',
        'city': 'New York',
        'stateCode': 'NY',
        'countryName': 'USA',
        'zipcode': '12345',
      },
    };
    var user1 = User.fromJson(json);
    if (kDebugMode) {
      print(user1.address?.country);
      print(user1.address?.pincode);
    }
  }

  void onHover(String imageUrl) {
    setState(() {
      mainImage = imageUrl;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Guard against empty list
    if (widget.imageList.isEmpty) {
      return const Card(child: Center(child: Text('No images available')));
    }

    final maxItemCountAllowed = min(
      widget.maxImages ?? 4,
      widget.imageList.length,
    );

    const double thumbSize = 100;
    const double thumbRadius = 8;

    return SizedBox(
      height: 300,
      child: Card(
        clipBehavior: Clip.hardEdge,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Main image with loading & error states
            Expanded(
              flex: 3,
              child: Container(
                width: double.maxFinite,
                color: Colors.grey.shade200,
                child: Image.network(
                  mainImage,
                  fit: BoxFit.cover,
                  semanticLabel: 'Main carousel image',
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.image_not_supported,
                            size: 48,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Failed to load image',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            // Thumbnail carousel
            Expanded(
              flex: 1,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: 2.0,
                  vertical: 2.0,
                ),
                itemCount: maxItemCountAllowed,
                itemBuilder: (context, index) {
                  final imageUrl = widget.imageList[index];
                  final isSelected = mainImage == imageUrl;
                  final isLast = index == maxItemCountAllowed - 1;

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2.0),
                    child: InkWell(
                      onTap: () {
                        if (isLast && widget.onViewAllClick != null) {
                          widget.onViewAllClick!(imageUrl);
                        } else {
                          onHover(imageUrl);
                        }
                      },
                      borderRadius: BorderRadius.circular(thumbRadius),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: thumbSize,
                        height: thumbSize,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isSelected
                                ? Colors.blue
                                : Colors.transparent,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(thumbRadius),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(thumbRadius),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.network(
                                imageUrl,
                                height: thumbSize,
                                width: thumbSize,
                                fit: BoxFit.cover,
                                semanticLabel: 'Thumbnail ${index + 1}',
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey.shade300,
                                    child: const Icon(
                                      Icons.broken_image,
                                      color: Colors.grey,
                                    ),
                                  );
                                },
                              ),
                              // Add glassy overlay only on the last visible thumbnail
                              if (isLast)
                                // Slightly darken/blur the thumbnail so label stands out
                                Positioned.fill(
                                  child: Container(
                                    alignment: Alignment.center,
                                    // We use a combination: a semi-transparent gradient to improve contrast,
                                    // plus BackdropFilter blur to create a frosted-glass feel.
                                    child: Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        // Backdrop blur
                                        BackdropFilter(
                                          filter: ui.ImageFilter.blur(
                                            sigmaX: 1.0,
                                            sigmaY: 1.0,
                                          ),
                                          child: Container(
                                            color: Colors.black.withValues(
                                              alpha: 0.4,
                                            ),
                                          ),
                                        ),
                                        // Gradient overlay to add more contrast towards the bottom-right
                                        Container(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                              colors: [
                                                Colors.black.withValues(
                                                  alpha: .10,
                                                ),
                                                Colors.black.withValues(
                                                  alpha: .30,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        // Centered prominent badge
                                        Center(
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withAlpha(1),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              border: Border.all(
                                                color: Colors.white.withAlpha(
                                                  1,
                                                ),
                                                width: 0.5,
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black.withAlpha(
                                                    1,
                                                  ),
                                                  blurRadius: 6,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: const Text(
                                              'View All',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                shadows: [
                                                  Shadow(
                                                    color: Colors.black38,
                                                    offset: Offset(0, 1),
                                                    blurRadius: 2,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
