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
            'https://images.unsplash.com/photo-1692185175217-6714aefe7ac9?w=900&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Nnx8ZnJlZSUyMGltYWdlfGVufDB8fDB8fHww',
            'https://images.unsplash.com/photo-1697396187315-479d481b84a9?w=900&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MjZ8fGZyZWUlMjBpbWFnZXxlbnwwfHwwfHx8MA%3D%3D',
            'https://plus.unsplash.com/premium_photo-1673288399224-5d0ddc581fd5?w=900&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MzN8fGZyZWUlMjBpbWFnZXxlbnwwfHwwfHx8MA%3D%3D',
            'https://images.unsplash.com/photo-1729991162904-41abea34127b?w=900&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MzR8fGZyZWUlMjBpbWFnZXxlbnwwfHwwfHx8MA%3D%3D',
            'https://images.unsplash.com/photo-1692185273945-5038163040e9?w=900&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NDZ8fGZyZWUlMjBpbWFnZXxlbnwwfHwwfHx8MA%3D%3D',
            'https://images.unsplash.com/photo-1694985198543-b67810b69748?w=900&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NDB8fGZyZWUlMjBpbWFnZXxlbnwwfHwwfHx8MA%3D%3D',
            'https://images.unsplash.com/photo-1586429182146-1787a6be082f?w=900&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NjB8fGZyZWUlMjBpbWFnZXxlbnwwfHwwfHx8MA%3D%3D',
            'https://images.unsplash.com/photo-1697135776289-cd613b43f2e9?w=900&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8ODB8fGZyZWUlMjBpbWFnZXxlbnwwfHwwfHx8MA%3D%3D',
          ],
        ),
      ),
    );
  }
}
