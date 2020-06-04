import 'package:flutter/material.dart';
import 'package:fluttercms/flutterbase/etc/flutterbase.comment.helper.dart';
import 'package:fluttercms/flutterbase/etc/flutterbase.globals.dart';
import 'package:fluttercms/flutterbase/widgets/flutterbase.space.dart';
import 'package:fluttercms/flutterbase/widgets/upload/flutterbase.display_uploaded_image.dart';
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
    double n = 16.0;
    switch (comment.depth) {
      case 1:
        n = 16.0;
        break;
      case 2:
        n = 48.0;
        break;
      case 3:
        n = 80.0;
        break;
      case 4:
        n = 112.0;
        break;
      default:
        n = 130.0;
    }
    return Container(
      width: double.infinity,
      child: Container(
        color: Color(0xffefeff4),
        margin: EdgeInsets.only(left: n),
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
                FlutterbaseSpace(),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(comment.displayName),
                      Text(formatTime(comment.createdAt)),
                    ],
                  ),
                ),
              ],
            ),
            FlutterbaseDisplayUploadedImages(
              comment,
            ),
            Container(
              padding: EdgeInsets.all(12.0),
              child: Text(
                comment.content,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
