

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttercms/flutterbase/etc/flutterbase.globals.dart';
import 'package:fluttercms/flutterbase/etc/flutterbase.post.helper.dart';
import 'package:fluttercms/flutterbase/models/flutterbase.post.model.dart';

/// `Firestore` 에 직접 접속해서  목록을 가져오기 위해서 사용.
///
/// 문제: `Engine`으로 접속을 하면 속도가 매우 느리게 나온다.
///   - 게시글 20개 가지고 오는데, 평균 10초에서 13초 걸린다.
///   - 하지만 `Firestorea`로 직접 접속하면 평균 0.3초에서 0.4초 걸린다.
///
/// 글 쓰기, 수정 등은 `Engine` 으로 해야 한다. 그 이유는 대부분의 작업이 한 번의 쿼리로 되는 것이 아니라, 여러번의 작업이 필요하기 때문이다.
///   - 예를 들어, 추천, 비추천 테스를 할 때만 해도 추천을 하기 위해서 `like` collection 을 수정해야하고, 해당 글/코멘트 도큐먼트의 `likes`, `dislikes`를 수정해야 한다.
///     이 처럼, `Firestore`로 모든 것을 다 하기에는 여러가지 번거로운 점이 있으므로,
///     게시판 목록만 사용을 한다.
///
///   - 게시판 록록 외에는 조금 느려도 괜찮다.
///
///
class FlutterbaseForumModel extends ChangeNotifier {
  FlutterbaseForumModel();

  /// 하나의 게시판을 목록
  String id;
  int limit;

  /// 에러가 있을 때, `onError` 로 전달한다. 만약, `onError` 가 지정되지 않으면, 기본 `alert`로 에러 표시를 한다.
  Function onError;

  /// 글 목록이 로드 될 때 마다 (첫 페이지에서 캐시를 하는 경우 두번 호출) 호출
  Function onLoad;

  /// 첫 번째 목록을 캐시.
  ///
  /// 인터넷이 안되거나 느린 경우, 첫 페이지를 볼 수 있음.
  // String cacheKey;

  /// 첫 페이지인 경우만 캐시를 하도록 조건 검사
  // bool get cache {
  //   return cacheKey != null && pageNo == 1;
  // }

  bool noMorePosts = false;
  bool inLoading = false;

  int pageNo = 1;

  List<FlutterbasePost> posts = [];

  /// 스크롤을 감지해서, 다음 페이지 로드
  /// 만약, 첫 페이지만 로드하는 경우, scrollController 를 그냥 무시하면 된다.
  final scrollController =
      ScrollController(initialScrollOffset: 0.0, keepScrollOffset: true);

  /// 위젯이 dispose 되었으면, notify 를 하지 않는다.
  /// 이 기능을 활요하기 위해서는 위젯의 dispose 에서 이 변수의 값을 true 로 지정한다.
  bool disposed = false;

  dynamic startAfter;

  void _scrollListener() {
    if (noMorePosts) {
      // print('_scrollListener():: no more posts on $id');
      return;
    }

    bool isBottom = scrollController.offset >=
        scrollController.position.maxScrollExtent - 200;

    if (!isBottom) return;
    if (inLoading) return;

    /// @warning `mount` check is needed here?

    // print('_scrollListener() going to load on $_id');
    _loadPage();
  }

  /// notifyListener 를 담당하는 메소드
  ///
  /// disposed 이면, notify 를 하지 않는다.
  notify() {
    if (disposed) return;
    // print('notify(): notifyListeners');
    notifyListeners();
  }

  init({
    String id,
    int limit = 20,
    Function onError,
    Function onLoad,
    String cacheKey,
  }) async {
    this.id = id;
    this.limit = limit;
    this.onError = onError;
    this.onLoad = onLoad;
    // this.cacheKey = cacheKey;
    scrollController.addListener(_scrollListener);
    _loadPage();
  }

  /// 글 목록을 한다.
  ///
  /// Model 객체를 생성하면 바로 실행된다. 그리고 ListView 등에 scroll controller 를 연결하고, 스크롤읋 할 때마다 자동으로 다음 페이지를 로드한다.
  ///
  /// [onLoad] 이 것은 페이지가 로드 될 때 마다 호출 된다. setState() 와 같은 필요한 작업을 하면 된다.
  ///
  ///
  ///
  /// * 첫번째 페이지만 캐시를 한다.
  /// * 게시판을 목록 할 때 마다 `notifyListeners()` 가 되며, callback handler 인 `_onLoad()`가 호출 된다.
  /// * 그리고 첫 페이지에서는 `await ... init()` 를 통해서 페이지 목록을 기다릴 수 있다.
  /// * 첫 페이지를 로드 할 때, `onLoad`가 두번 호출 된다.
  ///
  /// @return async 로 작업하고, 현재 글 목록 전체를 리턴한다.
  ///
  /// @attention 첫페이지 캐시를 하지 않는다.
  ///   - 서버 Timestamp 를 변환해야하는등 로직이 복잡하다.
  ///   - 대신 인터넷이 연결되어져 있지 않으면, 알림 페이지를 표시한다.
  _loadPage() async {
    if (noMorePosts) return;
    if (inLoading) return;
    inLoading = true;
    notify();
    Query q = Firestore.instance.collection('posts');
    q = q.where('category', isEqualTo: id);
    q = q.orderBy('createdAt', descending: true);

    /// 주의:startAtter 값을  배열로 넘겨주어야 한다.
    if (startAfter != null) q = q.startAfter([startAfter]);

    q = q.limit(limit);
    QuerySnapshot qs = await q.getDocuments();
    final docs = qs.documents;

    if (docs.length == 0) {
      noMorePosts = true;
      inLoading = false;
      notify();
      return;
    }

    startAfter = docs.last.data['createdAt'];
    // print('startAFter: $startAfter');

    List<FlutterbasePost> _posts = [];
    // List _docs = [];
    docs.forEach(
      (doc) {
        final docData = doc.data;
        // docData['id'] = doc.documentID;
        var _re = FlutterbasePost.fromMap(docData, id: doc.documentID);
        // print('_re: ');
        // print(_re);
        // _docs.add(docData);
        _posts.add(_re);
        // print('title: ${_re.title}');
      },
    );

    posts.addAll(_posts);

    // print('posts from firestore: limit: $limit length: ${_posts.length}');
    if (onLoad != null) onLoad(posts);
    if (_posts.length < limit) {
      noMorePosts = true;
    }
    pageNo++;
    inLoading = false;
    // print('notify: $pageNo');
    notify();
  }

  addPost(FlutterbasePost post) {
    if (post == null) return;
    posts.insert(0, post);
    scrollController.jumpTo(0);
    notify();
  }

  /// 글을 수정한다.
  ///
  /// 만약, 글 카테고리가 변경되어, 현재 게시판 카테고리에 더 이상 속하지 않는다면, 글을 목록에서 뺀다.
  updatePost(FlutterbasePost oldPost, FlutterbasePost updatedPost) {
    // print('updatePost: $updatedPost');

    /// @see `README 캐시를 하는 경우 글/코멘트 수정 삭제` 참고
    oldPost = this.posts.firstWhere((p) => p.id == oldPost.id);

    if (updatedPost.category == id) {
      // print('replace');
      oldPost.replaceWith(updatedPost);
    } else {
      // print('remove');
      posts.removeWhere((p) => p.id == updatedPost.id);
    }
    notify();
  }

  /// 글 삭제
  ///
  /// 에러가 있으면 throw 된다.
  deletePost(FlutterbasePostModel postModel) {
    return fb.postDelete(postModel);
  }
}
