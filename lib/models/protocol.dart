import './protocol_exercise.dart';

class Protocol {
  final int id;
  String name;
  List<ProtocolExercise> exercises;

  Protocol({
    required this.id,
    required this.name,
    required this.exercises,
  });
}
