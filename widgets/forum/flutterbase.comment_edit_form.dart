import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:fluttercms/flutterbase/etc/flutterbase.comment.helper.dart';
import 'package:fluttercms/flutterbase/etc/flutterbase.globals.dart';
import 'package:fluttercms/flutterbase/etc/flutterbase.post.helper.dart';
import 'package:fluttercms/flutterbase/widgets/flutterbase.space.dart';
import 'package:fluttercms/flutterbase/widgets/flutterbase.text.dart';
import 'package:fluttercms/flutterbase/widgets/forum/flutterbase.comment_view_content.dart';
import 'package:fluttercms/flutterbase/widgets/forum/flutterbase.post_list_view_content.dart';

class FlutterbaseCommentEditForm extends StatefulWidget {
  FlutterbaseCommentEditForm(
    this.post, {
    this.parentComment,
    this.currentComment,
    Key key,
  }) : super(key: key);
  final FlutterbasePost post;

  /// When user creates a new comment, [parentComment] will be set.
  final FlutterbaseComment parentComment;

  /// When user updates a comment, [currentComemnt] will be set.
  final FlutterbaseComment currentComment;

  @override
  _FlutterbaseCommentEditFormState createState() =>
      _FlutterbaseCommentEditFormState();
}

class _FlutterbaseCommentEditFormState
    extends State<FlutterbaseCommentEditForm> {
  final TextEditingController _contentController = TextEditingController();

  bool inSubmit = false;
  int progress = 0;

  /// TODO: app model 로 이동할 것
  // File _imageFile;

  /// TODO: app model 로 이동 할 것.
  // Future<void> _pickImage(ImageSource source) async {
  //   _imageFile = await ImagePicker.pickImage(source: source);
  //   _startUpload();
  // }

  ///소스 참고: https://fireship.io/lessons/flutter-file-uploads-cloud-storage/
  /// 파일 업로드. 코멘트, 게시글, 사용자 사진을 업로드한다.
  ///업로드하는 사진은, quality 를 90% 로 하고, 너비를 024px 로 자동으로 줄인다.
  ///
  /// * 주의: storageBucket 는 파이어프로젝트마다 틀리다. 올바로 지정 해 주어야 한다.
  /// * 주의: 업로드된 이미지의 경로에서 슬래쉬가 %2F 로 되어져있는데, 웹브라우저로 접속할 때, 이걸 슬래쉬(/)로 하면 안되고, %2F 로 해야한다.
  ///   자등으로 바뀌는 경우가 있으므로, 가능하면 Postman 에서 확인을 한다.
  ///
  // final FirebaseStorage _storage =
  //     FirebaseStorage(storageBucket: 'gs://enginf-856e7.appspot.com');

  // StorageUploadTask _uploadTask;

  /// TODO - form validation
  getFormData() {
    final String content = _contentController.text;

    final Map<String, dynamic> data = {
      'content': content,
    };

    if (isCreate && widget.parentComment != null) {
      // comment under another comemnt
      data['postId'] = widget.post.id;
      data['parentId'] = widget.parentComment.id;
      data['depth'] = widget.parentComment.depth + 1;
    } else if (isUpdate) {
      // comment update
      data['id'] = widget.currentComment.id;
    } else {
      // comment under post
      data['postId'] = widget.post.id;
      data['depth'] = 0;
    }
    data['urls'] = widget.currentComment.urls;
    // print('data: ');
    // print(data);
    return data;
  }

  bool get isCreate {
    return widget.currentComment?.id == null;
  }

  bool get isUpdate {
    return !isCreate;
  }

  @override
  void initState() {
    // print(widget.currentComment);
    Timer.run(() {
      // if (isCreate) {
      //   /// 임시 코멘트 생성. README 참고.
      //   widget.currentComment = FlutterbaseComment();
      // }
      if (isUpdate) {
        // print('if(isUpdate');
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
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            children: <Widget>[
              // EngineUploadIcon(
              //   widget.currentComment,
              //   onProgress: (p) {
              //     setState(() {
              //       progress = p;
              //     });
              //   },
              //   onUploadComplete: (String url) {
              //     setState(() {});
              //   },
              //   onError: alert,
              // ),
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

                  var data = getFormData();
                  try {
                    alert('코멘트 create, update 를 하나로 합친다.');
                    if (isCreate) {
                      /// 코멘트 생성. 코멘트를 생성해서 리턴한다.
                      FlutterbaseComment comment = await fb.commentCreate(data);
                      back(arguments: comment);
                    } else {
                      /// 코멘트 수정. 수정된 코멘트를 리턴한다.
                      FlutterbaseComment comment =
                          await fb.commentUpdate(getFormData());
                      back(arguments: comment);
                    }
                  } catch (e) {
                    alert(e);
                  }
                  setState(() => inSubmit = false);
                },
              ),
            ],
          ),
          Container(height: 100, color: Colors.black45),
          // EngineProgressBar(progress),
          // EngineDisplayUploadedImages(
          //   widget.currentComment,
          //   editable: true,
          // ),
        ],
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
                      if (widget.post.comments != null)
                        for (var c in widget.post.comments) ...[
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
