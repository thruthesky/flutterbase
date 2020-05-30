import 'package:fluttercms/flutterbase/etc/flutterbase.category.helper.dart';

class FlutterbaseCategoryList {
  List<dynamic> ids;
  List<FlutterbaseCategory> categories;
  FlutterbaseCategoryList({
    this.ids,
    this.categories,
  });
  factory FlutterbaseCategoryList.fromEngineData(Map<dynamic, dynamic> data) {
    // data.keys;

    var _ids = data.keys.toList();
    List<FlutterbaseCategory> arr = [];
    for (String id in _ids) {
      var _data = Map.from(data[id]);
      _data['id'] = id;
      // print('data: ');
      // print(_data);
      arr.add(FlutterbaseCategory.fromEngineData(_data));
    }

    return FlutterbaseCategoryList(
      ids: data.keys.toList(),
      categories: arr,
    );
  }

  @override
  String toString() {
    return "$ids $categories";
  }
}
