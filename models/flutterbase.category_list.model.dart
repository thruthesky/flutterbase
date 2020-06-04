import 'package:flutter/material.dart';
import '../etc/flutterbase.category.helper.dart';
import '../etc/flutterbase.globals.dart';

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
