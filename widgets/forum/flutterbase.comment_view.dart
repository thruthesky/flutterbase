import 'package:fluttercms/flutterbase/etc/flutterbase.comment.helper.dart';
import 'package:fluttercms/flutterbase/etc/flutterbase.defines.dart';
import 'package:fluttercms/flutterbase/etc/flutterbase.globals.dart';
import 'package:fluttercms/flutterbase/etc/flutterbase.post.helper.dart';
import 'package:fluttercms/flutterbase/models/flutterbase.forum_list.model.dart';
import 'package:fluttercms/flutterbase/models/flutterbase.post.model.dart';
import 'package:fluttercms/flutterbase/widgets/flutterbase.text_button.dart';
import 'package:fluttercms/flutterbase/widgets/forum/flutterbase.comment_edit_form.dart';
import 'package:fluttercms/flutterbase/widgets/forum/flutterbase.comment_view_content.dart';
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
      color: Colors.black12,
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
    // this.onReply,
    // this.onUpdate,
    // this.onDelete,
  });
  // final Function onReply;
  // final Function onUpdate;
  // final Function onDelete;
  final FlutterbasePost post;
  final FlutterbaseForumModel forum;
  final FlutterbaseComment comment;

  @override
  _FlutterbaseCommentButtonsState createState() =>
      _FlutterbaseCommentButtonsState();
}

class _FlutterbaseCommentButtonsState extends State<FlutterbaseCommentButtons> {
  bool inDelete = false;
  bool inLike = false;
  bool inDisike = false;

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

            /// last sibling 찾기

            ////

            FlutterbaseComment _comment = await openDialog(
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
          text: t('reply'),
        ),
        FlutterbaseTextButton(
          text: t('edit'),
          onTap: () async {
            // @TODO: /// 삭제되면 수정 불가
            // if (fb.isDeleted(widget.comment)) return alert(t(ALREADY_DELETED));

            // /// 자신의 글이 아니면, 에러
            // if (!fb.isMine(widget.comment)) return alert(t(NOT_MINE));

            FlutterbaseComment _comment = await openDialog(
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
          showSpinner: inLike,
          text: t('Like') + ' ' + widget.comment.likes.toString(),
          onTap: () async {
            /// 이미 vote 중이면 불가
            if (inLike || inDisike) return;

            alert('삭제된 글인지, 자신의 글이 아닌지는 fluterbase model 에서 캡슐화 한다.');
            alert(
                'inLike 를  fb.inVoting 으로 변경. vote()함수 안에서 캡슐화 해서 코드를 간결하게 한다.');

            /// 글이 삭제되면  불가
            // if (fb.isDeleted(widget.comment)) return alert(t(ALREADY_DELETED));

            // /// 본인의 글이면 불가
            // if (fb.isMine(widget.comment)) return alert(t(CANNOT_VOTE_ON_MINE));
            setState(() => inLike = true);
            final re =
                await fb.vote({'id': widget.comment.commentId, 'vote': 'like'});
            setState(() {
              inLike = false;
              widget.comment.likes = re['likes'];
              widget.comment.dislikes = re['dislikes'];
            });
            // print(re);
          },
        ),
        FlutterbaseTextButton(
          showSpinner: inDisike,
          text: t('dislike') + ' ' + widget.comment.dislikes.toString(),
          onTap: () async {
            /// 이미 vote 중이면 불가
            if (inLike || inDisike) return;

            alert('삭제된 글인지, 자신의 글이 아닌지는 fluterbase model 에서 캡슐화 한다.');
            alert(
                'inLike 를  fb.inVoting 으로 변경. vote()함수 안에서 캡슐화 해서 코드를 간결하게 한다.');

            /// 글이 삭제되면  불가
            // if (fb.isDeleted(widget.comment)) return alert(t(ALREADY_DELETED));

            // /// 본인의 글이면 불가
            // if (fb.isMine(widget.comment)) return alert(t(CANNOT_VOTE_ON_MINE));
            setState(() => inDisike = true);
            final re = await fb
                .vote({'id': widget.comment.commentId, 'vote': 'dislike'});
            setState(() {
              inDisike = false;
              widget.comment.likes = re['likes'];
              widget.comment.dislikes = re['dislikes'];
            });
            // print(re);
          },
        ),
        FlutterbaseTextButton(
          showSpinner: inDelete,
          onTap: () async {
            /// 코멘트 삭제

            alert('삭제된 글인지, 자신의 글이 아닌지는 fluterbase model 에서 캡슐화 한다.');
            // /// 삭제되면 재 삭제 불가
            // if (fb.isDeleted(widget.comment)) return alert(t(ALREADY_DELETED));
            // /// 자신의 글이 아니면, 에러
            // if (!fb.isMine(widget.comment)) return alert(t(NOT_MINE));

            confirm(
              title: t(CONFIRM_COMMENT_DELETE_TITLE),
              content: t(CONFIRM_COMMENT_DELETE_CONTENT),
              onYes: () async {
                setState(() => inDelete = true);
                try {
                  var comment = await fb.commentDelete(
                      postId: widget.post.id, comment: widget.comment);
                      postModel.updateComment(comment);
                } catch (e) {
                  alert(e);
                }
                setState(() => inDelete = false);
              },
              onNo: () {
                // print('no');
              },
            );
          },
          text: t('delete'),
        ),
      ],
    );
  }
}
