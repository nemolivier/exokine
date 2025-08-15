import './protocol_exercise.dart';

class Protocol {
  final int id;
  String name;
  String? remarks; // Global remarks
  List<ProtocolExercise> exercises;

  Protocol({
    required this.id,
    required this.name,
    this.remarks,
    required this.exercises,
  });

  factory Protocol.fromJson(Map<String, dynamic> json) {
    return Protocol(
      id: json['id'],
      name: json['name'],
      remarks: json['remarks'],
      exercises: (json['exercises'] as List)
          .map((i) => ProtocolExercise.fromJson(i))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'remarks': remarks,
      'exercises': exercises.map((e) => e.toJson()).toList(),
    };
  }
}
