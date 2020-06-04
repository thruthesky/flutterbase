import 'package:cloud_firestore/cloud_firestore.dart';
import '../../flutterbase/etc/flutterbase.post.helper.dart';

class FlutterbaseForumService {
  Future<List<FlutterbasePost>> loadPage({String id, int limit}) async {
    Query q = Firestore.instance.collection('posts');
    q = q.where('category', isEqualTo: id);
    q = q.orderBy('createdAt', descending: true);

    q = q.limit(limit);
    QuerySnapshot qs = await q.getDocuments();
    final docs = qs.documents;

    if (docs.length == 0) {
      return [];
    }

    List<FlutterbasePost> _posts = [];

    docs.forEach(
      (doc) {
        final docData = doc.data;
        var _re = FlutterbasePost.fromMap(docData, id: doc.documentID);
        _posts.add(_re);
      },
    );

    return _posts;
  }
}
