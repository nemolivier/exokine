class ProtocolExercise {
  final int id;
  final int exerciseId;
  final String exerciseName; // Pour un accès facile
  int repetitions;
  int series;
  int pause; // en secondes
  String tempo;
  String? notes;

  ProtocolExercise({
    required this.id,
    required this.exerciseId,
    required this.exerciseName,
    required this.repetitions,
    required this.series,
    required this.pause,
    required this.tempo,
    this.notes,
  });

  // Méthode pour la sérialisation/désérialisation JSON si nécessaire plus tard
}
