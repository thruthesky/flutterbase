class FlutterbaseCategory {
  String id;
  String title;
  String description;
  int createdAt;
  FlutterbaseCategory({
    this.id,
    this.title,
    this.description,
    this.createdAt,
  });
  factory FlutterbaseCategory.fromEngineData(Map<dynamic, dynamic> data) {
    var re = FlutterbaseCategory(
      id: data['id'],
      title: data['title'],
      description: data['description'],
      createdAt: data['createdAt'],
    );
    return re;
  }

  @override
  String toString() {
    return "id: $id, title: $title, description: $description";
  }
}
