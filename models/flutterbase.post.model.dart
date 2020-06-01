import 'package:flutter/material.dart';
import 'package:fluttercms/flutterbase/etc/flutterbase.comment.helper.dart';
import 'package:fluttercms/flutterbase/etc/flutterbase.globals.dart';
import 'package:fluttercms/flutterbase/etc/flutterbase.post.helper.dart';

/// 글 하나에 대한 Model
///
/// - 코멘트를 `Firestore` 에서 읽기
/// - 코멘트 관리
class FlutterbasePostModel extends ChangeNotifier {
  FlutterbasePostModel({
    @required this.post,
  }) {
    // print(post);
    _loadComments();
  }

  FlutterbasePost post;
  List<FlutterbaseComment> comments = [];

  _loadComments() async {
    // print('_loadComments()');
    comments = await fb.commentsGet(post.id);
    // print('comments');
    // print(comments);
    notifyListeners();
  }

  /// 코멘트를 코멘트 목록에 집어 넣는다.
  ///
  /// order 가 작은 것이 있으면 바로 그 앞에 집어 넣으면 된다.
  addComment(FlutterbaseComment comment) {
    if (comment == null) return;
    int index =
        comments.indexWhere(((c) => c.order.compareTo(comment.order) < 0));
    if (index == -1) {
      comments.add(comment);
    } else {
      comments.insert(index, comment);
    }
    notifyListeners();
  }

  /// 코멘트를 수정하고, 기존의 코멘트와 바꿔치기 한다.
  ///
  /// [comment] 업데이트된 코멘트
  /// - notifyListeners 를 한다.
  updateComment(FlutterbaseComment comment) {
    if (comment == null) return;

    int i = comments
        .indexWhere((element) => element.commentId == comment.commentId);
    comments.removeAt(i);
    comments.insert(i, comment);
    notifyListeners();
  }
}
