class ProtocolExercise {
  int id;
  int exerciseId;
  String exerciseName; // Pour un accès facile
  int repetitions;
  int series;
  int pause; // en secondes
  String tempo;
  String? notes;
  List<String> days;

  ProtocolExercise({
    required this.id,
    required this.exerciseId,
    required this.exerciseName,
    required this.repetitions,
    required this.series,
    required this.pause,
    required this.tempo,
    this.notes,
    this.days = const [],
  });

  factory ProtocolExercise.fromJson(Map<String, dynamic> json) {
    return ProtocolExercise(
      id: json['id'],
      exerciseId: json['exerciseId'],
      exerciseName: json['exercise']?['name'] ?? '', // Handle nested exercise name
      repetitions: json['repetitions'],
      series: json['series'],
      pause: json['pause'],
      tempo: json['tempo'],
      notes: json['notes'],
      days: json['days'] != null ? List<String>.from(json['days']) : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'exerciseId': exerciseId,
      'repetitions': repetitions,
      'series': series,
      'pause': pause,
      'tempo': tempo,
      'notes': notes,
      'days': days,
    };
  }
}