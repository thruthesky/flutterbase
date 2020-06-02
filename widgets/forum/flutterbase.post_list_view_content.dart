import 'package:flutter/material.dart';
import 'package:fluttercms/flutterbase/etc/flutterbase.post.helper.dart';

class FlutterbasePostListViewContent extends StatelessWidget {
  const FlutterbasePostListViewContent(
    this.post, {
    Key key,
  }) : super(key: key);

  final FlutterbasePost post;

  @override
  Widget build(BuildContext context) {
    if (post == null) return SizedBox.shrink();
    // print('FlutterbasePostItem content: $post');
    // String dt = DateTime.fromMillisecondsSinceEpoch(post.createdAt).toLocal().toString();

    // String formatted = formatTime(post.createdAt);
    int formatted = post.createdAt;
    return Container(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              // EngineUserPhoto(
              //   post.photoUrl,
              //   onTap: () => alert('tap'),
              // ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      '${post.title}',
                      style: TextStyle(fontSize: 24),
                    ),
                    Text('author: ' + post.displayName),
                    Text('created: $formatted'),
                  ],
                ),
              )
            ],
          ),
          Container(
            width: double.infinity,
            color: Colors.black12,
            padding: EdgeInsets.all(8.0),
            child: Text('${post.content}'),
          ),
          // EngineDisplayUploadedImages(
          //   post,
          // ),
        ],
      ),
    );
  }
}
