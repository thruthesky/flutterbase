import 'package:flutter/material.dart';
import 'package:fluttercms/flutterbase/etc/flutterbase.comment.helper.dart';
import 'package:fluttercms/flutterbase/etc/flutterbase.globals.dart';
import 'package:fluttercms/flutterbase/widgets/user/flutterbase.user_photo.dart';
import 'package:time_formatter/time_formatter.dart';

class FlutterbaseCommentViewContent extends StatelessWidget {
  const FlutterbaseCommentViewContent({
    Key key,
    @required this.comment,
  }) : super(key: key);

  final FlutterbaseComment comment;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Container(
        color: Colors.white70,
        margin: EdgeInsets.only(left: 32.0 * comment.depth),
        padding: EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                FlutterbaseUserPhoto(
                  comment.photoUrl,
                  onTap: () => alert('tap on user photo'),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('author: ' + (comment.displayName ?? comment.uid)),
                      Text('created: ' + formatTime(comment.createdAt)),
                    ],
                  ),
                ),
              ],
            ),
            // EngineDisplayUploadedImages(
            //   comment,
            // ),
            Text(comment.content),
          ],
        ),
      ),
    );
  }
}
