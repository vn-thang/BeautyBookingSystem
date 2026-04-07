import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class NetworkImageWidget extends StatelessWidget {

  final String imageUrl;

  const NetworkImageWidget({
    super.key,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {

    if (imageUrl.isEmpty) {
      return const Icon(Icons.image_not_supported);
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      placeholder: (context, url) =>
          const Center(child: CircularProgressIndicator()),
      errorWidget: (context, url, error) {
        debugPrint("IMAGE LOAD ERROR: $url");
        debugPrint(error.toString());
        return const Icon(Icons.error);
      },
    );
  }
}