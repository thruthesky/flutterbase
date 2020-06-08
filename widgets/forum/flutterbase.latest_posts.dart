import 'package:flutter/material.dart';
import '../../etc/flutterbase.globals.dart';
import '../../services/flutterbase.forum.service.dart';
import '../../etc/flutterbase.post.helper.dart';

class FlutterbaseLatestPosts extends StatefulWidget {
  FlutterbaseLatestPosts({@required this.route, this.subtitle: false});

  final String route;
  final bool subtitle;

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
          contentPadding: EdgeInsets.only(top: 4.0, left: 16.0, right: 16.0, bottom: 0.0),
          title: Text('${posts[index].title}'),
          subtitle: widget.subtitle ? Text('${posts[index].displayName}') : null,
          trailing: Icon(Icons.keyboard_arrow_right),
          onTap: () {
            open(widget.route, arguments: {'post': posts[index]});
          },
        );
      },
    );
  }
}
