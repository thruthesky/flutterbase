import 'dart:async';

import 'package:flutter/material.dart';
import '../flutterbase.spinner.dart';
import '../../../flutterbase/etc/flutterbase.defines.dart';
import '../flutterbase.space.dart';
import '../../etc/flutterbase.comment.helper.dart';
import '../../etc/flutterbase.globals.dart';
import '../../etc/flutterbase.post.helper.dart';
import '../../models/flutterbase.post.model.dart';
import '../flutterbase.text.dart';
import '../forum/flutterbase.comment_view_content.dart';
import '../forum/flutterbase.post_list_view_content.dart';
import '../upload/flutterbase.display_uploaded_image.dart';
import '../upload/flutterbase.upload_icon.dart';
import '../user/flutterbase.upload_progress_bar.dart';
import '../flutterbase.page_padding.dart';

class FlutterbaseCommentEditForm extends StatelessWidget {
  FlutterbaseCommentEditForm({
    @required this.postModel,
    @required this.post,
    this.parentComment,
    this.currentComment,
    this.lastSiblingComment,
    Key key,
  }) : super(key: key) {
    if (currentComment == null || !(currentComment.urls is List)) {
      alert('currentComment.urls is not a list in FlutterbaseCommentEditForm');
    }
  }

  final FlutterbasePostModel postModel;
  final FlutterbasePost post;

  /// When user creates a new comment, [parentComment] will be set.
  final FlutterbaseComment parentComment;

  /// When user updates a comment, [currentComemnt] will be set.
  final FlutterbaseComment currentComment;

  /// 새 코멘트를 작성하는 경우, 부모 코멘트의 자식 중 order 가 가장 낮은 코멘트.
  final FlutterbaseComment lastSiblingComment;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: T(COMMENT_EDIT_TITLE),
      ),
      body: Container(
        // color: Colors.black38,
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(10.0),
            child: Stack(
              children: <Widget>[
                SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      FlutterbasePostListViewContent(post),
                      FlutterbaseSpace(),
                      Column(
                        children: <Widget>[
                          if (postModel.comments != null)
                            for (var c in postModel.comments) ...[
                              FlutterbaseCommentViewContent(comment: c),
                              FlutterbaseSpace()
                            ],
                        ],
                      ),
                      SizedBox(height: 200)
                    ],
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: FlutterbaseCommentEditFormInputBox(
                    post: post,
                    currentComment: currentComment,
                    parentComment: parentComment,
                    lastSiblingComment: lastSiblingComment,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class FlutterbaseCommentEditFormInputBox extends StatefulWidget {
  FlutterbaseCommentEditFormInputBox({
    this.parentComment,
    this.currentComment,
    this.post,
    this.lastSiblingComment,
  });

  final FlutterbasePost post;
  final FlutterbaseComment currentComment;

  /// When user creates a new comment, [parentComment] will be set.
  final FlutterbaseComment parentComment;

  /// 새 코멘트를 작성하는 경우, 부모 코멘트의 자식 중 order 가 가장 낮은 코멘트.
  final FlutterbaseComment lastSiblingComment;

  @override
  _FlutterbaseCommentEditFormInputBoxState createState() =>
      _FlutterbaseCommentEditFormInputBoxState();
}

class _FlutterbaseCommentEditFormInputBoxState
    extends State<FlutterbaseCommentEditFormInputBox> {
  final TextEditingController _contentController = TextEditingController();

  bool get isCreate {
    return widget.currentComment?.commentId == null;
  }

  bool get isUpdate {
    return !isCreate;
  }

  @override
  void initState() {
    Timer.run(() {
      if (isUpdate) {
        _contentController.text = widget.currentComment.content;
      }
    });
    super.initState();
  }

  bool inSubmit = false;
  int progress = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).backgroundColor,
      child: SafeArea(
        child: FlutterbasePagePadding(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                children: <Widget>[
                  FlutterbaseUploadIcon(
                    widget.currentComment,
                    onProgress: (p) {
                      setState(() {
                        progress = p;
                      });
                    },
                    onUploadComplete: (String url) {
                      setState(() {});
                    },
                    onError: alert,
                  ),
                  FlutterbaseSpace(),
                  Expanded(
                    child: TextField(
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      controller: _contentController,
                      onSubmitted: (text) {},
                      onChanged: (String content) {
                        /// 글 내용을 입력하면 화면에 바인딩되어 나타난다.
                        /// 사진을 업로드해도 마찬가지이다.
                        setState(() {
                          widget.currentComment.content = content;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: t('input comment'),
                      ),
                    ),
                  ),
                  GestureDetector(
                    /// 코멘트 편집 버튼 클릭
                    child: inSubmit
                        ? FlutterbaseSpinner()
                        : Icon(Icons.send),
                    onTap: () async {
                      /// 코멘트 생성 또는 수정.
                      if (inSubmit) return;
                      setState(() => inSubmit = true);
                      try {
                        /// 코멘트 생성. 코멘트를 생성해서 리턴한다.
                        FlutterbaseComment comment = await fb.commentEdit(
                          postId: widget.post.id,
                          commentId: widget.currentComment.commentId,
                          parentCommentDepth: widget.parentComment?.depth ?? 0,
                          lastSiblingCommentOrder:
                              widget.lastSiblingComment?.order,
                          data: {
                            'content': _contentController.text,
                            'urls': widget.currentComment.urls,
                          },
                        );
                        back(arguments: comment);
                      } catch (e) {
                        alert(e);
                      }
                      setState(() => inSubmit = false);
                    },
                  ),
                ],
              ),
              FlutterbaseSpace(),
              FlutterbaseUploadProgressBar(progress),
              FlutterbaseDisplayUploadedImages(
                widget.currentComment,
                editable: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
