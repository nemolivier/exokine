class Exercise {
  final int id;
  String name;
  List<String> articulation;
  List<String> muscles;

  Exercise({
    required this.id,
    required this.name,
    this.articulation = const [],
    this.muscles = const [],
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'],
      name: json['name'],
      articulation: json['articulation'] != null ? List<String>.from(json['articulation']) : [],
      muscles: json['muscles'] != null ? List<String>.from(json['muscles']) : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'articulation': articulation,
      'muscles': muscles,
    };
  }
}