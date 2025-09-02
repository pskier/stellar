class Group {
  final String id;
  final String name;

  Group({required this.id, required this.name});

  factory Group.fromMap(Map<String, dynamic> data, String id) {
    return Group(id: id, name: data['name']);
  }
}
