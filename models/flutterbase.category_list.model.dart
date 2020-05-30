import 'package:flutter/material.dart';
import 'package:fluttercms/flutterbase/etc/flutterbase.category.helper.dart';
import 'package:fluttercms/flutterbase/etc/flutterbase.globals.dart';

class FlutterbaseCategoryListModel extends ChangeNotifier {
  FlutterbaseCategoryListModel() {
    loadCategories();
  }

  bool inLoading = false;
  List<FlutterbaseCategory> categories = [];
  loadCategories() async {
    inLoading = true;
    notifyListeners();
    try {
      categories = await fb.loadCategories();
    } catch (e) {
      alert(t(e));
    }
    inLoading = false;
    notifyListeners();
  }
}
