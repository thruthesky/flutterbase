
import 'package:flutter/material.dart';
import 'package:fluttercms/flutterbase/etc/flutterbase.comment.helper.dart';
import 'package:fluttercms/flutterbase/etc/flutterbase.defines.dart';
import 'package:fluttercms/flutterbase/etc/flutterbase.globals.dart';
import 'package:fluttercms/flutterbase/etc/flutterbase.post.helper.dart';
import 'package:fluttercms/flutterbase/models/flutterbase.forum_list.model.dart';
import 'package:fluttercms/flutterbase/widgets/flutterbase.text_button.dart';
import 'package:fluttercms/flutterbase/widgets/forum/flutterbase.comment_edit_form.dart';
import 'package:fluttercms/flutterbase/widgets/forum/flutterbase.comment_view.dart';
import 'package:fluttercms/flutterbase/widgets/forum/flutterbase.post_edit_form.dart';
import 'package:fluttercms/flutterbase/widgets/forum/flutterbase.post_list_view_content.dart';
import 'package:provider/provider.dart';

class FlutterbasePostListView extends StatefulWidget {
  FlutterbasePostListView(this.post);
  final FlutterbasePost post;

  @override
  _FlutterbasePostListViewState createState() => _FlutterbasePostListViewState();
}

class _FlutterbasePostListViewState extends State<FlutterbasePostListView> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        FlutterbasePostListViewContent(widget.post),
        FlutterbasePostListViewButtons(widget.post),
        if (widget.post.comments != null)
          for (var c in widget.post.comments)
            FlutterbaseCommentView(
              widget.post,
              c,
              key: ValueKey(c.id ?? randomString()),
            ),
      ],
    );
  }
}

class FlutterbasePostListViewButtons extends StatefulWidget {
  const FlutterbasePostListViewButtons(
    this.post, {
    Key key,
  }) : super(key: key);

  final FlutterbasePost post;

  @override
  _FlutterbasePostListViewButtonsState createState() => _FlutterbasePostListViewButtonsState();
}

class _FlutterbasePostListViewButtonsState extends State<FlutterbasePostListViewButtons> {
  bool inDelete = false;
  bool inLike = false;
  bool inDisike = false;
  @override
  Widget build(BuildContext context) {
    FlutterbaseForumModel forum =
        Provider.of<FlutterbaseForumModel>(context, listen: false);
    return Row(
      children: <Widget>[
        FlutterbaseTextButton(
          text: t('Reply'),
          onTap: () async {
            /// 글에서 Reply 버튼을 클릭한 경우
            ///
            /// 글이 삭제되어도 코멘트를 달 수 있다.
            FlutterbaseComment comment = await openDialog(
              FlutterbaseCommentEditForm(
                widget.post,
                currentComment: FlutterbaseComment(),
              ),
            );

            forum.addComment(comment, widget.post, null);

            // forum.notify();
          },
        ),
        FlutterbaseTextButton(
          text: t('Edit'),
          onTap: () async {
            /// 글 수정


            alert('삭제된 글인지, 자신의 글이 아닌지는 fluterbase model 에서 캡슐화 한다.');
alert('inLike 를  fb.inVoting 으로 변경. vote()함수 안에서 캡슐화 해서 코드를 간결하게 한다.');
            // /// 글이 삭제되면 수정 불가
            // if (fb.isDeleted(widget.post)) return alert(t(ALREADY_DELETED));

            // /// 자신의 글이 아니면, 에러
            // if (!fb.isMine(widget.post)) return alert(t(NOT_MINE));

            FlutterbasePost _post = await openDialog(
              FlutterbasePostEditForm(post: widget.post),
            );
            if (_post == null) return;
            forum.updatePost(widget.post, _post);

            /// 글 수정 후, 카테고리가 변경되어, 현재 카테고리가 글에 포함되지 않으면, 첫번째 카테고리로 이동한다.
            if (!_post.categories.contains(forum.id)) {
              return open(
                EngineRoutes.postList,
                arguments: {'id': _post.categories.first},
              );
            }
          },
        ),
        FlutterbaseTextButton(
          loader: inLike,
          text: t('Like') + ' ' + widget.post.likes.toString(),
          onTap: () async {
            /// 이미 vote 중이면 불가
            if (inLike || inDisike) return;


            alert('삭제된 글인지, 자신의 글이 아닌지는 fluterbase model 에서 캡슐화 한다.');
alert('inLike 를  fb.inVoting 으로 변경. vote()함수 안에서 캡슐화 해서 코드를 간결하게 한다.');
            // /// 글이 삭제되면  불가
            // if (fb.isDeleted(widget.post)) return alert(t(ALREADY_DELETED));

            // /// 본인의 글이면 불가
            // if (fb.isMine(widget.post)) return alert(t(CANNOT_VOTE_ON_MINE));
            setState(() => inLike = true);
            final re =
                await fb.vote({'id': widget.post.id, 'vote': 'like'});
            setState(() {
              inLike = false;
              widget.post.likes = re['likes'];
              widget.post.dislikes = re['dislikes'];
            });
            print(re);
          },
        ),
        FlutterbaseTextButton(
          loader: inDisike,
          text: t('dislike') + ' ' + widget.post.dislikes.toString(),
          onTap: () async {
            /// 이미 vote 중이면 불가
            if (inLike || inDisike) return;


            alert('삭제된 글인지, 자신의 글이 아닌지는 fluterbase model 에서 캡슐화 한다.');
alert('inLike 를  fb.inVoting 으로 변경. vote()함수 안에서 캡슐화 해서 코드를 간결하게 한다.');
            /// 글이 삭제되면  불가
            // if (fb.isDeleted(widget.post)) return alert(t(ALREADY_DELETED));

            // /// 본인의 글이면 불가
            // if (fb.isMine(widget.post)) return alert(t(CANNOT_VOTE_ON_MINE));
            setState(() => inDisike = true);
            final re =
                await fb.vote({'id': widget.post.id, 'vote': 'dislike'});
            setState(() {
              inDisike = false;
              widget.post.likes = re['likes'];
              widget.post.dislikes = re['dislikes'];
            });
            print(re);
          },
        ),
        FlutterbaseTextButton(
          loader: inDelete,
          onTap: () async {

            alert('삭제된 글인지, 자신의 글이 아닌지는 fluterbase model 에서 캡슐화 한다.');
            // /// 글이 삭제되면 재 삭제 불가
            // if (fb.isDeleted(widget.post)) return alert(t(ALREADY_DELETED));

            // /// 자신의 글이 아니면, 에러
            // if (!fb.isMine(widget.post)) return alert(t(NOT_MINE));

            confirm(
              title: t(CONFIRM_POST_DELETE_TITLE),
              content: t(CONFIRM_POST_DELETE_CONTENT),
              onYes: () async {
                setState(() => inDelete = true);
                await forum.deletePost(widget.post);
                setState(() => inDelete = false);
              },
              onNo: () {},
            );
          },
          text: t('Delete'),
        ),
      ],
    );
  }
}
