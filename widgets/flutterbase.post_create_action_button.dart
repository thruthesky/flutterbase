import 'package:flutter/material.dart';
import '../etc/flutterbase.defines.dart';
import '../etc/flutterbase.globals.dart';
import '../etc/flutterbase.post.helper.dart';
import '../models/flutterbase.forum_list.model.dart';
import '../widgets/forum/flutterbase.post_edit_form.dart';

class FlutterbasePostCreateActionButton extends StatelessWidget {
  FlutterbasePostCreateActionButton({
    this.id,
    this.forum,
  });

  // final Function onTap;
  final String id;

  /// forum 모델이 DI 로 호환될 수 있도록 Type 을 주지 않는다.
  final FlutterbaseForumModel forum;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Icon(Icons.create),
      ),
      onTap: () async {
        /// 글 생성 버튼 클릭 한 경우. 수정은 아님.
        if (fb.notLoggedIn) return alert(t(LOGIN_FIRST));
        FlutterbasePost _post = await openForumBox(
          FlutterbasePostEditForm(id: id),
        );

        /// 글 생성 완료
        if (_post == null) return;

        /// TODO: 중복 라우터를 없애는 것이 좋겠다.
        return open(
          EngineRoutes.postList,
          arguments: {'id': _post.category},
        );
      },
    );
  }
}
