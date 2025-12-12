import 'package:flutter/material.dart';

class ImageCarousal extends StatefulWidget {
  const ImageCarousal({super.key, required this.imageList});
  final List<String> imageList;

  @override
  State<ImageCarousal> createState() => _ImageCarousalState();
}

class _ImageCarousalState extends State<ImageCarousal> {
  late String mainImage;

  @override
  void initState() {
    super.initState();
    mainImage = widget.imageList.isNotEmpty ? widget.imageList[0] : '';
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
                  horizontal: 0,
                  vertical: 4.0,
                ),
                itemCount: widget.imageList.length,
                itemBuilder: (context, index) {
                  final imageUrl = widget.imageList[index];
                  final isSelected = mainImage == imageUrl;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 0.0),
                    child: InkWell(
                      onTap: () => onHover(imageUrl),
                      borderRadius: BorderRadius.circular(4),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isSelected
                                ? Colors.blue
                                : Colors.transparent,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Image.network(
                            imageUrl,
                            height: 80,
                            width: 80,
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
