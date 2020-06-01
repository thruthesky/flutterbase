import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttercms/flutterbase/etc/flutterbase.category.helper.dart';
import 'package:fluttercms/flutterbase/etc/flutterbase.defines.dart';
import 'package:fluttercms/flutterbase/etc/flutterbase.globals.dart';
import 'package:fluttercms/flutterbase/etc/flutterbase.post.helper.dart';
import 'package:fluttercms/flutterbase/widgets/flutterbase.button.dart';
import 'package:fluttercms/flutterbase/widgets/flutterbase.space.dart';
import 'package:fluttercms/flutterbase/widgets/flutterbase.text.dart';

class FlutterbasePostEditForm extends StatefulWidget {
  FlutterbasePostEditForm({this.id, this.post});
  final String id;
  final FlutterbasePost post;
  @override
  _FlutterbasePostEditFormState createState() =>
      _FlutterbasePostEditFormState();
}

class _FlutterbasePostEditFormState extends State<FlutterbasePostEditForm> {
  FlutterbasePost post = FlutterbasePost();
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

  // bool get isCreate => widget.id != null;
  // bool get isUpdate => !isCreate;

  // List<dynamic> _categorySelected = [];
  // Iterable<Widget> get categoryChips sync* {
  //   for (var cat in categories) {
  //     yield FilterChip(
  //       label: T(cat.id),
  //       selected: _categorySelected.contains(cat.id),
  //       onSelected: (selected) {
  //         setState(() {
  //           if (selected) {
  //             _categorySelected.add(cat.id);
  //           } else {
  //             _categorySelected.remove(cat.id);
  //           }
  //         });
  //       },
  //       selectedColor: Theme.of(context).primaryColorDark,
  //     );
  //   }
  // }

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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // categories == null
            //     ? PlatformCircularProgressIndicator()
            //     : Wrap(
            //         spacing: 6.0,
            //         runSpacing: 0.0,
            //         children: categoryChips.toList(),
            //       ),

            if (categories != null)
              DropdownButton<String>(
                  value: dropdownValue,
                  icon: Icon(Icons.arrow_downward),
                  iconSize: 24,
                  elevation: 16,
                  style: TextStyle(color: Colors.deepPurple),
                  underline: Container(
                    height: 2,
                    color: Colors.deepPurpleAccent,
                  ),
                  onChanged: (String newValue) {
                    setState(() {
                      dropdownValue = newValue;
                    });
                  },
                  items: categories
                      .map<DropdownMenuItem<String>>((FlutterbaseCategory cat) {
                    return DropdownMenuItem<String>(
                      value: cat.id,
                      child: Text(cat.title),
                    );
                  }).toList()),

            Divider(),
            TextField(
              controller: _titleController,
              onSubmitted: (text) {},
              decoration: InputDecoration(
                hintText: t('input title'),
              ),
            ),
            FlutterbaseSpace(),
            TextField(
              controller: _contentController,
              keyboardType: TextInputType.multiline,
              maxLines: null,
              onSubmitted: (text) {},
              decoration: InputDecoration(
                hintText: t('input content'),
              ),
            ),
            FlutterbaseSpace(),
            // EngineProgressBar(0),
            // EngineDisplayUploadedImages(
            //   post,
            //   editable: true,
            // ),
            // FlutterbaseSpace(),
            // EngineProgressBar(progress),
            FlutterbaseSpace(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                // EngineUploadIcon(
                //   post,
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
                FlutterbaseButton(
                  showSpinner: inSubmit,
                  text: widget.post?.id == null ? CREATE_POST : UPDATE_POST,
                  onPressed: () async {
                    if (inSubmit) return;
                    setState(() => inSubmit = true);
                    try {
                      FlutterbasePost p = await fb.postEdit(getFormData());
                      // print('created: $p');
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
