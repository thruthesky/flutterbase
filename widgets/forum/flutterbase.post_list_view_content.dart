import 'package:flutter/material.dart';
import '../../etc/flutterbase.globals.dart';
import '../../etc/flutterbase.post.helper.dart';
import '../../widgets/flutterbase.space.dart';
import '../../widgets/upload/flutterbase.display_uploaded_image.dart';
import '../../widgets/user/flutterbase.user_photo.dart';
import 'package:time_formatter/time_formatter.dart';

class FlutterbasePostListViewContent extends StatelessWidget {
  const FlutterbasePostListViewContent(
    this.post, {
    Key key,
  }) : super(key: key);

  final FlutterbasePost post;

  @override
  Widget build(BuildContext context) {
    if (post == null) return SizedBox.shrink();

    // print(post);

    String formatted = formatTime(post.createdAt);
    return Container(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              FlutterbaseUserPhoto(
                post.photoUrl,
                onTap: () => alert('tap'),
              ),
              FlutterbaseSpace(),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      '${post.title}',
                      style: TextStyle(fontSize: 24),
                    ),
                    Row(
                      children: <Widget>[
                        Text(
                          'By: ' + post.displayName,
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          '  ($formatted)',
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
          FlutterbaseSpace(),
          Container(
            width: double.infinity,
            color: Color(0xfff3f3f3),
            padding: EdgeInsets.all(12.0),
            child: Text('${post.content}'),
          ),
          FlutterbaseDisplayUploadedImages(
            post,
          ),
        ],
      ),
    );
  }
}
