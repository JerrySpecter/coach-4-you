import 'dart:io';
import 'package:flutter/material.dart';
import 'package:health_factory/widgets/hf_paragraph.dart';

class HFImage extends StatelessWidget {
  const HFImage({
    Key? key,
    this.imageUrl = '',
    this.network = true,
  }) : super(key: key);

  final String imageUrl;
  final bool network;

  @override
  Widget build(BuildContext context) {
    if (imageUrl == '') {
      return const Image(
        image: AssetImage('assets/placeholder.jpg'),
        fit: BoxFit.cover,
      );
    }

    if (network) {
      return FadeInImage.assetNetwork(
        placeholder: 'assets/placeholder.jpg',
        image: imageUrl,
        placeholderErrorBuilder: (context, error, stackTrace) {
          print('placeholderErrorBuilder');
          return HFParagrpah(
            text: error.toString(),
          );
        },
        imageErrorBuilder: (context, error, stackTrace) {
          print('imageErrorBuilder');
          return HFParagrpah(
            text: error.toString(),
          );
        },
        fit: BoxFit.cover,
        fadeOutDuration: const Duration(milliseconds: 200),
        fadeInDuration: const Duration(milliseconds: 200),
        fadeInCurve: Curves.easeInOut,
        fadeOutCurve: Curves.easeInOut,
      );
    }

    return Image(
      image: FileImage(File(imageUrl)),
      fit: BoxFit.cover,
    );
  }
}
