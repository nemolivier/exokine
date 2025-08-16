
import 'package:flutter/material.dart';

import '../../models/exercise.dart';
import '../../services/api_service.dart';
import '../../widgets/empty_state_view.dart';

class ExercicesView extends StatelessWidget {
  final Future<List<Exercise>> exercisesFuture;
  final Function() onAddExercise;
  final Function(Exercise) onEditExercise;
  final Function(Exercise) onDeleteExercise;
  final bool isGridView;

  const ExercicesView({
    super.key,
    required this.exercisesFuture,
    required this.onAddExercise,
    required this.onEditExercise,
    required this.onDeleteExercise,
    required this.isGridView,
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

        if (isGridView) {
          return GridView.builder(
            padding: const EdgeInsets.all(16.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16.0,
              mainAxisSpacing: 16.0,
              childAspectRatio: 3 / 2,
            ),
            itemCount: exercises.length,
            itemBuilder: (context, index) {
              final exercise = exercises[index];
              return Card.outlined(
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => onEditExercise(exercise),
                  child: GridTile(
                    footer: GridTileBar(
                      backgroundColor: Colors.black45,
                      title: Text(exercise.name, overflow: TextOverflow.ellipsis),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.white),
                            onPressed: () => onEditExercise(exercise),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.white),
                            onPressed: () => onDeleteExercise(exercise),
                          ),
                        ],
                      ),
                    ),
                    child: Center(
                      child: Icon(Icons.fitness_center, size: 48, color: Theme.of(context).colorScheme.primary),
                    ),
                  ),
                ),
              );
            },
          );
        }

        return ListView.builder(
          itemCount: exercises.length,
          itemBuilder: (context, index) {
            final exercise = exercises[index];
            return Card.outlined(
              margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
                side: BorderSide(color: Theme.of(context).colorScheme.primary, width: 1),
              ),
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
