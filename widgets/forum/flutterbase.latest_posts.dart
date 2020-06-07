import 'package:flutter/material.dart';
import '../../etc/flutterbase.globals.dart';
import '../../services/flutterbase.forum.service.dart';
import '../../etc/flutterbase.post.helper.dart';

class FlutterbaseLatestPosts extends StatefulWidget {
  FlutterbaseLatestPosts({this.route});

  String route;

  @override
  _FlutterbaseLatestPostsState createState() => _FlutterbaseLatestPostsState();
}

class _FlutterbaseLatestPostsState extends State<FlutterbaseLatestPosts> {
  List<FlutterbasePost> posts = [];
  @override
  void initState() {
    init();
    super.initState();
  }

  init() async {
    var ffs = FlutterbaseForumService();
    posts = await ffs.loadPage(
      id: 'discussion',
      limit: 30,
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text('${posts[index].title}'),
          trailing: Icon(Icons.keyboard_arrow_right),
          onTap: () {
            open(widget.route, arguments: {'post': posts[index]});
          },
        );
      },
    );
  }
}
