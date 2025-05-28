// Hero Model
class HeroModel {
  final int id;
  final String name;

  HeroModel({required this.id, required this.name});

  factory HeroModel.fromJson(Map<String, dynamic> json) {
    return HeroModel(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }

  @override
  String toString() {
    return 'HeroModel{id: $id, name: $name}';
  }
}
