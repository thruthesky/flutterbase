import 'package:flutter/material.dart';
import 'package:fluttercms/flutterbase/etc/flutterbase.defines.dart';
import 'package:fluttercms/flutterbase/etc/flutterbase.globals.dart';
import 'package:fluttercms/flutterbase/etc/flutterbase.post.helper.dart';
import 'package:fluttercms/flutterbase/models/flutterbase.forum_list.model.dart';
import 'package:fluttercms/flutterbase/widgets/forum/flutterbase.post_edit_form.dart';

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
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Icon(Icons.add),
      ),
      onTap: () async {
        /// 글 생성 버튼 클릭 한 경우. 수정은 아님.
        if (fb.notLoggedIn) return alert(t(LOGIN_FIRST));
        FlutterbasePost _post = await openDialog(
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
