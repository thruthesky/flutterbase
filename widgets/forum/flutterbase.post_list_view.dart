import 'package:flutter/material.dart';
import '../../etc/flutterbase.comment.helper.dart';
import '../../etc/flutterbase.defines.dart';
import '../../etc/flutterbase.globals.dart';
import '../../etc/flutterbase.post.helper.dart';
import '../../models/flutterbase.forum_list.model.dart';
import '../../models/flutterbase.post.model.dart';
import '../../widgets/flutterbase.text_button.dart';
import '../../widgets/forum/flutterbase.comment_edit_form.dart';
import '../../widgets/forum/flutterbase.comment_view.dart';
import '../../widgets/forum/flutterbase.post_edit_form.dart';
import '../../widgets/forum/flutterbase.post_list_view_content.dart';
import 'package:provider/provider.dart';

class FlutterbasePostListView extends StatefulWidget {
  FlutterbasePostListView(this.post);
  final FlutterbasePost post;

  @override
  _FlutterbasePostListViewState createState() =>
      _FlutterbasePostListViewState();
}

class _FlutterbasePostListViewState extends State<FlutterbasePostListView> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FlutterbasePostModel>(builder: (context, model, child) {
      return Column(children: <Widget>[
        FlutterbasePostListViewContent(widget.post),
        FlutterbasePostListViewButtons(widget.post),
        Column(
          children: <Widget>[
            if (model.comments != null)
              for (var c in model.comments)
                FlutterbaseCommentView(
                  widget.post,
                  c,
                  key: ValueKey(c.commentId ?? randomString()),
                ),
          ],
        ),
      ]);
    });
  }
}

class FlutterbasePostListViewButtons extends StatefulWidget {
  const FlutterbasePostListViewButtons(
    this.post, {
    Key key,
  }) : super(key: key);

  final FlutterbasePost post;

  @override
  _FlutterbasePostListViewButtonsState createState() =>
      _FlutterbasePostListViewButtonsState();
}

class _FlutterbasePostListViewButtonsState
    extends State<FlutterbasePostListViewButtons> {
  // bool inDelete = false;
  // bool inLike = false;
  // bool inDisike = false;
  @override
  Widget build(BuildContext context) {
    FlutterbaseForumModel forum =
        Provider.of<FlutterbaseForumModel>(context, listen: false);
    FlutterbasePostModel postModel =
        Provider.of<FlutterbasePostModel>(context, listen: false);
    return Row(
      children: <Widget>[
        FlutterbaseTextButton(
          text: t(REPLY),
          onTap: () async {
            /// 글에서 Reply 버튼을 클릭한 경우
            ///
            /// 글이 삭제되어도 코멘트를 달 수 있다.
            FlutterbaseComment nc = FlutterbaseComment();
            // print('nc: $nc');
            FlutterbaseComment comment = await openForumBox(
              FlutterbaseCommentEditForm(
                postModel: postModel,
                post: widget.post,
                currentComment: nc,
                lastSiblingComment: fb.findLastSiblingComment(
                    parentComment: null, comments: postModel.comments),
              ),
            );

            /// TODO: 코멘트를 생성하고 집어 넣기.
            // forum.addComment(comment, widget.post, null);

            postModel.addComment(comment);

            // forum.notify();
          },
        ),
        if (fb.myDoc(widget.post) && !fb.deleted(widget.post))
          FlutterbaseTextButton(
            text: t(EDIT),
            onTap: () async {
              FlutterbasePost _post = await openForumBox(
                  FlutterbasePostEditForm(post: widget.post));
              if (_post == null) return;
              forum.updatePost(widget.post, _post);

              /// 글 수정 후, 카테고리가 변경되면, 변경된 카테고리로 이동한다.
              if (_post.category != forum.id) {
                return open(
                  EngineRoutes.postList,
                  arguments: {'id': _post.category},
                );
              }
            },
          ),
        FlutterbaseTextButton(
          showSpinner: widget.post.inVoting,
          text: t(LIKE) + '(' + widget.post.like.toString() +')',
          onTap: () => fb
              .vote(
                postModel: postModel,
                voteFor: LIKE,
              )
              .catchError(alert),
        ),
        FlutterbaseTextButton(
          showSpinner: widget.post.inVoting,
          text: t(DISLIKE) + '(' + widget.post.dislike.toString()+')',
          onTap: () => fb
              .vote(
                postModel: postModel,
                voteFor: DISLIKE,
              )
              .catchError(alert),
        ),
        if (!fb.deleted(widget.post))
          FlutterbaseTextButton(
            text: t(DELETE),
            showSpinner: widget.post.inDeleting,
            onTap: () => confirm(
              title: t(CONFIRM_POST_DELETE_TITLE),
              content: t(CONFIRM_POST_DELETE_CONTENT),
              onYes: () => forum.deletePost(postModel).catchError(alert),
            ),
          ),
      ],
    );
  }
}
