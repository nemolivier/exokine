
import 'package:flutter/material.dart';

import '../../models/exercise.dart';
import '../../services/api_service.dart';
import '../../widgets/empty_state_view.dart';

class ExercicesView extends StatelessWidget {
  final Future<List<Exercise>> exercisesFuture;
  final Function() onAddExercise;
  final Function(Exercise) onEditExercise;
  final Function(Exercise) onDeleteExercise;

  const ExercicesView({
    super.key,
    required this.exercisesFuture,
    required this.onAddExercise,
    required this.onEditExercise,
    required this.onDeleteExercise,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Exercise>>(
      future: exercisesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const EmptyStateView(
            icon: Icons.fitness_center_outlined,
            message: 'Aucun exercice trouvé.',
          );
        }
        final exercises = snapshot.data!;
        return ListView.builder(
          itemCount: exercises.length,
          itemBuilder: (context, index) {
            final exercise = exercises[index];
            return Card.outlined(
              margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exercise.name,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Articulations: ${exercise.articulation.join(', ')}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      'Muscles: ${exercise.muscles.join(', ')}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FloatingActionButton.small(
                            heroTag: 'edit_exercise_${exercise.id}',
                            onPressed: () => onEditExercise(exercise),
                            child: const Icon(Icons.edit),
                          ),
                          const SizedBox(width: 8),
                          FloatingActionButton.small(
                            heroTag: 'delete_exercise_${exercise.id}',
                            backgroundColor: Theme.of(context).colorScheme.error,
                            onPressed: () => onDeleteExercise(exercise),
                            child: const Icon(Icons.delete),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
