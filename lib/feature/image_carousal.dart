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
    mainImage = widget.imageList[0];
  }

  void onHover(String imageUrl) {
    setState(() {
      mainImage = imageUrl;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: Card(
        clipBehavior: Clip.hardEdge,
        child: Column(
          spacing: 2.0,
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.network(
              mainImage,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            Expanded(
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(right: 8.0),
                children: widget.imageList
                    .map(
                      (e) => GestureDetector(
                        onTap: () => onHover(e),
                        child: Image.network(e),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
