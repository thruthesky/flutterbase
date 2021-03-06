import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import './flutterbase.spinner.dart';

class FlutterbaseImage extends StatelessWidget {
  FlutterbaseImage(this.url);
  final String url;
  @override
  Widget build(BuildContext context) {
    if (url.indexOf('http') != 0) return Icon(Icons.error);

    // print('egine image url: $url');

    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      placeholder: (context, url) => FlutterbaseSpinner(),
      errorWidget: (context, url, error) => Icon(Icons.error),
    );
  }
}