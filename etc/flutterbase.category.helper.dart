class FlutterbaseCategory {
  String id;
  String title;
  String description;
  FlutterbaseCategory({
    this.id,
    this.title,
    this.description,
  });
  factory FlutterbaseCategory.fromMap(Map<dynamic, dynamic> data) {
    var re = FlutterbaseCategory(
      id: data['id'],
      title: data['title'],
      description: data['description'],
    );
    return re;
  }

  @override
  String toString() {
    return "id: $id, title: $title, description: $description";
  }
}
