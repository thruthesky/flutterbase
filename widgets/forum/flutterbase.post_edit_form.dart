import 'dart:async';

import 'package:flutter/material.dart';
import '../../etc/flutterbase.category.helper.dart';
import '../../etc/flutterbase.defines.dart';
import '../../etc/flutterbase.globals.dart';
import '../../etc/flutterbase.post.helper.dart';
import '../../widgets/flutterbase.space.dart';
import '../../widgets/flutterbase.text.dart';
import '../../widgets/flutterbase.text_button.dart';
import '../../widgets/upload/flutterbase.display_uploaded_image.dart';
import '../../widgets/upload/flutterbase.upload_icon.dart';
import '../../widgets/user/flutterbase.upload_progress_bar.dart';
import '../../widgets/flutterbase.page_padding.dart';

class FlutterbasePostEditForm extends StatefulWidget {
  FlutterbasePostEditForm({this.id, this.post});
  final String id;
  final FlutterbasePost post;
  @override
  _FlutterbasePostEditFormState createState() =>
      _FlutterbasePostEditFormState();
}

class _FlutterbasePostEditFormState extends State<FlutterbasePostEditForm> {
  FlutterbasePost post = FlutterbasePost.fromMap({}, id: null);
  int progress = 0;
  bool inSubmit = false;

  List<FlutterbaseCategory> categories;
  String dropdownValue = 'discussion';

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  @override
  void initState() {
    initLoadCategories();
    super.initState();

    Timer(Duration(milliseconds: 10), () {
      setState(() {
        /// 글 수정시, post document.
        var _post = widget.post;
        if (_post != null) {
          setState(() {
            post = _post;
            _titleController.text = post.title;
            _contentController.text = post.content;
          });
        }

        /// 게시판 아이디가 있는 경우, 카테고리 선택
        if (widget?.id != null) {
          setState(() {
            dropdownValue = widget.id;
          });
        }
      });
    });
  }

  initLoadCategories() async {
    categories = await fb.loadCategories();
    if (mounted) setState(() => null);
  }

  getFormData() {
    final String title = _titleController.text;
    final String content = _contentController.text;

    final data = {
      'id': post?.id,
      'category': dropdownValue,
      'title': title,
      'content': content,
      'urls': post.urls,
    };
    return data;
  }

  String get title {
    if (widget.id != null)
      return widget.id;
    else if (post != null && post.title != null)
      return post.title;
    else
      return POST_CREATE;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: T(title),
      ),
      body: FlutterbasePagePadding(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (categories != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  T(SELECT_CATEGORY),
                  FlutterbasePostEditCategories(
                      categories: categories,
                      defaultValue: dropdownValue,
                      onChanged: (String newValue) {
                        setState(() {
                          dropdownValue = newValue;
                        });
                      }),
                ],
              ),
            Divider(),
            TextField(
              controller: _titleController,
              onSubmitted: (text) {},
              decoration: InputDecoration(
                hintText: t(INPUT_TITLE),
              ),
            ),
            FlutterbaseSpace(),
            TextField(
              controller: _contentController,
              keyboardType: TextInputType.multiline,
              minLines: 10,
              maxLines: null,
              onSubmitted: (text) {},
              decoration: InputDecoration(
                hintText: t(INPUT_CONTENT),
              ),
            ),
            FlutterbaseDisplayUploadedImages(
              post,
              editable: true,
            ),
            FlutterbaseSpace(),
            FlutterbaseUploadProgressBar(progress),
            FlutterbaseSpace(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                FlutterbaseUploadIcon(
                  post,
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
                FlutterbaseTextButton(
                  showSpinner: inSubmit,
                  text: t(widget.post?.id == null ? CREATE_POST : UPDATE_POST),
                  onTap: () async {
                    if (inSubmit) return;
                    setState(() => inSubmit = true);
                    try {
                      FlutterbasePost p = await fb.postEdit(getFormData());
                      back(arguments: p);
                    } catch (e) {
                      alert(e);
                      setState(() => inSubmit = false);
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class FlutterbasePostEditCategories extends StatelessWidget {
  FlutterbasePostEditCategories({
    @required this.categories,
    @required this.defaultValue,
    @required this.onChanged,
  });

  final List<FlutterbaseCategory> categories;
  final String defaultValue;
  final Function onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
        value: defaultValue,
        icon: Icon(Icons.arrow_downward),
        iconSize: 24,
        elevation: 16,
        style: TextStyle(color: Colors.deepPurple),
        underline: Container(
          height: 2,
          color: Colors.deepPurpleAccent,
        ),
        onChanged: onChanged,
        items:
            categories.map<DropdownMenuItem<String>>((FlutterbaseCategory cat) {
          return DropdownMenuItem<String>(
            value: cat.id,
            child: Text(cat.title),
          );
        }).toList());
  }
}
