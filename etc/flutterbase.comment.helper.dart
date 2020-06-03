import 'package:flutter/material.dart';
import 'package:fluttercms/flutterbase/etc/flutterbase.globals.dart';

class FlutterbaseComment {
  String content;
  int createdAt;
  int updatedAt;
  int deletedAt;
  String uid;
  String commentId;
  String postId;
  String parentId;
  int depth;
  String order;

  /// [inLoading] is used only for [post.tempComment] to indiate whether the comment in submission to backend.
  bool inLoading;

  /// 파일 업로드에서 초기화 필요함. .fromMap() 을 호출 하지 않는 경우 필요.
  List<dynamic> urls = [];

  /// 글 쓴이 이름과 photoURL
  ///
  /// `displayName` 과 `photoUrl`은 `Firebase Auth` 에 저장되어져 있는 것을 가져온다.
  String displayName;
  String photoUrl;

  int like;
  int dislike;


  bool inDeleting = false;
  bool inVoting = false;

  FlutterbaseComment({
    this.postId,
    this.commentId,
    this.uid,
    this.content,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.depth,
    this.order,
    this.urls,
    this.displayName,
    this.photoUrl,
    this.like,
    this.dislike,
  });

  /// 글 ID 와 코멘트 ID 를 데이터에 추가한다.
  factory FlutterbaseComment.fromMap(Map<dynamic, dynamic> data,
      {@required String postId, @required String commentId}) {
    int createdAt = 0;
    if (!isEmpty(data['createdAt'])) {
      createdAt = data['createdAt'].millisecondsSinceEpoch;
    }
    int updatedAt = 0;
    if (!isEmpty(data['updatedAt'])) {
      updatedAt = data['updatedAt'].millisecondsSinceEpoch;
    }
    int deletedAt = 0;
    if (!isEmpty(data['deletedAt'])) {
      deletedAt = data['deletedAt'].millisecondsSinceEpoch;
    }

    return FlutterbaseComment(
      commentId: commentId,
      postId: postId,
      content: data['content'],
      uid: data['uid'],
      createdAt: createdAt,
      updatedAt: updatedAt,
      deletedAt: deletedAt,

      urls: data['urls'] != null
          ? List<dynamic>.from(data['urls'])
          : [], // To preved 'fixed-length' error.

      displayName: data['displayName'] ?? '',
      photoUrl: data['photoUrl'] ?? '',
      like: data['like'] ?? 0,
      dislike: data['dislike'] ?? 0,
      order: data['order'],
      depth: data['depth'],
    );
  }

  @override
  String toString() {
    return "commentId: $commentId, uid: $uid, postId: $postId, parentId: $parentId, content: $content, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, dpeth: $depth, urls: $urls, order: $order";
  }
}
