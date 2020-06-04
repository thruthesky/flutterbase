import '../../etc/flutterbase.comment.helper.dart';
import '../../etc/flutterbase.defines.dart';
import '../../etc/flutterbase.globals.dart';
import '../../etc/flutterbase.post.helper.dart';
import '../../models/flutterbase.forum_list.model.dart';
import '../../models/flutterbase.post.model.dart';
import '../../widgets/flutterbase.text_button.dart';
import '../../widgets/forum/flutterbase.comment_edit_form.dart';
import '../../widgets/forum/flutterbase.comment_view_content.dart';
import 'package:provider/provider.dart';

import 'package:flutter/material.dart';

class FlutterbaseCommentView extends StatelessWidget {
  FlutterbaseCommentView(
    this.post,
    this.comment, {
    Key key,
  }) : super(key: key);
  final FlutterbasePost post;
  final FlutterbaseComment comment;

  @override
  Widget build(BuildContext context) {
    if (comment == null) return SizedBox.shrink();

    FlutterbaseForumModel forum =
        Provider.of<FlutterbaseForumModel>(context, listen: false);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(8.0),
      // color: Colors.black12,
      child: Column(
        children: <Widget>[
          Column(
            children: <Widget>[
              FlutterbaseCommentViewContent(comment: comment),
              FlutterbaseCommentButtons(
                post: post,
                forum: forum,
                comment: comment,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class FlutterbaseCommentButtons extends StatefulWidget {
  FlutterbaseCommentButtons({
    this.post,
    this.forum,
    this.comment,
  });
  final FlutterbasePost post;
  final FlutterbaseForumModel forum;
  final FlutterbaseComment comment;

  @override
  _FlutterbaseCommentButtonsState createState() =>
      _FlutterbaseCommentButtonsState();
}

class _FlutterbaseCommentButtonsState extends State<FlutterbaseCommentButtons> {
  // bool inLike = false;
  // bool inDisike = false;

  @override
  Widget build(BuildContext context) {
    FlutterbasePostModel postModel =
        Provider.of<FlutterbasePostModel>(context, listen: false);

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        FlutterbaseTextButton(
          onTap: () async {
            /// 코멘트 보기에서 Reply 버튼을 클릭한 경우, 코멘트 수정 창을 열고, 결과를 리턴 받음.

            FlutterbaseComment _comment = await openForumBox(
              FlutterbaseCommentEditForm(
                postModel: postModel,
                post: widget.post,
                currentComment: FlutterbaseComment(),
                parentComment: widget.comment,
                lastSiblingComment: fb.findLastSiblingComment(
                  parentComment: widget.comment,
                  comments: postModel.comments,
                ),
              ),
            );

            /// 결과를 목록에 집어 넣는다.
            /// TODO: 코멘트 업데이트
            // widget.forum
            //     .addComment(_comment, widget.post, widget.comment.commentId);

            postModel.addComment(_comment);
          },
          text: t(REPLY),
        ),
        if (fb.myDoc(widget.comment) && !fb.deleted(widget.comment))
          FlutterbaseTextButton(
            text: t(EDIT),
            onTap: () async {
              // @TODO: /// 삭제되면 수정 불가
              // if (fb.isDeleted(widget.comment)) return alert(t(ALREADY_DELETED));

              // /// 자신의 글이 아니면, 에러
              // if (!fb.isMine(widget.comment)) return alert(t(NOT_MINE));

              FlutterbaseComment _comment = await openForumBox(
                FlutterbaseCommentEditForm(
                  postModel: postModel,
                  post: widget.post,
                  currentComment: widget.comment,
                ),
              );
              postModel.updateComment(_comment);
            },
          ),
        FlutterbaseTextButton(
          showSpinner: widget.comment.inVoting,
          text: t(LIKE) + '(' + widget.comment.like.toString() + ')',
          onTap: () => fb
              .vote(
                postModel: postModel,
                comment: widget.comment,
                voteFor: LIKE,
              )
              .catchError(alert),
        ),
        FlutterbaseTextButton(
          showSpinner: widget.comment.inVoting,
          text: t(DISLIKE) + '(' + widget.comment.dislike.toString() + ')',
          onTap: () => fb
              .vote(
                postModel: postModel,
                comment: widget.comment,
                voteFor: DISLIKE,
              )
              .catchError(alert),
        ),
        if (fb.myDoc(widget.comment) && !fb.deleted(widget.comment))
          FlutterbaseTextButton(
            showSpinner: widget.comment.inDeleting,
            onTap: () => confirm(
              title: t(CONFIRM_COMMENT_DELETE_TITLE),
              content: t(CONFIRM_COMMENT_DELETE_CONTENT),
              onYes: () => fb
                  .commentDelete(postModel: postModel, comment: widget.comment)
                  .catchError(alert),
            ),
            text: t(DELETE),
          ),
      ],
    );
  }
}
