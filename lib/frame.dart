import 'package:flutter/material.dart';
import 'package:practice_flutter/feature/image_carousal.dart';

class Frame extends StatelessWidget {
  const Frame({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      appBar: AppBar(title: Text('Frame')),
      body: ListView.builder(
        itemCount: 1,
        shrinkWrap: true,
        itemBuilder: (context, index) => ImageCarousal(
          maxImages: 10,
          onViewAllClick: (String imageUrl) => {
            showDialog(
              context: context,
              builder: (context) =>
                  AlertDialog(content: Image.network(imageUrl)),
            ),
          },
          imageList: [
            'https://i.travelapi.com/lodging/1000000/150000/140600/140596/0eb63980_z.jpg',
            'https://i.travelapi.com/lodging/3000000/2570000/2565800/2565776/3dde5432_z.jpg',
            'https://i.travelapi.com/lodging/3000000/2570000/2565800/2565776/9dcc462b_z.jpg',
            'https://i.travelapi.com/lodging/2000000/1420000/1418800/1418701/1a8536be_z.jpg',
            'https://i.travelapi.com/lodging/2000000/1420000/1418800/1418701/w3194h2129x2y4-4b3391e1_z.jpg',
            'https://i.travelapi.com/lodging/9000000/8760000/8753200/8753178/e560b639_z.jpg',
            'https://i.travelapi.com/lodging/2000000/1850000/1847200/1847179/c4d05f9e_z.jpg',
            'https://i.travelapi.com/lodging/2000000/1850000/1847200/1847179/7a89ade0_z.jpg',
          ],
        ),
      ),
    );
  }
}
