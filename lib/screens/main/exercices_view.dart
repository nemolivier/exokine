
import 'package:flutter/material.dart';

import '../../models/exercise.dart';
import '../../services/api_service.dart';

class ExercicesView extends StatelessWidget {
  final Future<List<Exercise>> exercisesFuture;
  final Function() onAddExercise;
  final Function(Exercise) onEditExercise;

  const ExercicesView({
    super.key,
    required this.exercisesFuture,
    required this.onAddExercise,
    required this.onEditExercise,
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
          return const Center(child: Text('Aucun exercice trouvé.'));
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
                      child: IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => onEditExercise(exercise),
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
