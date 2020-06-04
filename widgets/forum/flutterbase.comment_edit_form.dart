import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:fluttercms/flutterbase/etc/flutterbase.comment.helper.dart';
import 'package:fluttercms/flutterbase/etc/flutterbase.globals.dart';
import 'package:fluttercms/flutterbase/etc/flutterbase.post.helper.dart';
import 'package:fluttercms/flutterbase/models/flutterbase.post.model.dart';
import 'package:fluttercms/flutterbase/widgets/flutterbase.space.dart';
import 'package:fluttercms/flutterbase/widgets/flutterbase.text.dart';
import 'package:fluttercms/flutterbase/widgets/forum/flutterbase.comment_view_content.dart';
import 'package:fluttercms/flutterbase/widgets/forum/flutterbase.post_list_view_content.dart';
import 'package:fluttercms/flutterbase/widgets/upload/flutterbase.display_uploaded_image.dart';
import 'package:fluttercms/flutterbase/widgets/upload/flutterbase.upload_icon.dart';
import 'package:fluttercms/flutterbase/widgets/user/flutterbase.upload_progress_bar.dart';
import 'package:fluttercms/widgets/app.padding.dart';

class FlutterbaseCommentEditForm extends StatefulWidget {
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
  _FlutterbaseCommentEditFormState createState() =>
      _FlutterbaseCommentEditFormState();
}

class _FlutterbaseCommentEditFormState
    extends State<FlutterbaseCommentEditForm> {
  final TextEditingController _contentController = TextEditingController();

  bool inSubmit = false;
  int progress = 0;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: T('edit comment'),
      ),
      bottomNavigationBar: SafeArea(
        child: AppPadding(
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
                        ? PlatformCircularProgressIndicator()
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
      body: Container(
        color: Colors.black38,
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(10.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  FlutterbasePostListViewContent(widget.post),
                  Column(
                    children: <Widget>[
                      if (widget.postModel.comments != null)
                        for (var c in widget.postModel.comments) ...[
                          FlutterbaseCommentViewContent(comment: c),
                          FlutterbaseSpace()
                        ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
