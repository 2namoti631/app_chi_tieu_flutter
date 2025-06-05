class Category {
  final String id;
  final String userId;
  final String name;
  final String icon;
  final String type;

  Category({
    required this.id,
    required this.userId,
    required this.name,
    required this.icon,
    required this.type,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['_id'],
      userId: json['user_id'],
      name: json['name'],
      icon: json['icon'],
      type: json['type'],
    );
  }
  @override
  String toString() {
    return 'Category(name: $name, icon: $icon)';
  }
}

