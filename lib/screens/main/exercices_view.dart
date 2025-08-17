
import 'package:flutter/material.dart';

import '../../models/exercise.dart';
import '../../services/api_service.dart';
import '../../widgets/empty_state_view.dart';

class ExercicesView extends StatelessWidget {
  final Future<List<Exercise>> exercisesFuture;
  final Function() onAddExercise;
  final Function(Exercise) onEditExercise;
  final Function(Exercise) onDeleteExercise;
  final Function(Exercise) onAddToProtocol;
  final bool isGridView;

  const ExercicesView({
    super.key,
    required this.exercisesFuture,
    required this.onAddExercise,
    required this.onEditExercise,
    required this.onDeleteExercise,
    required this.onAddToProtocol,
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
              crossAxisCount: 5,
              crossAxisSpacing: 16.0,
              mainAxisSpacing: 16.0,
              childAspectRatio: 1.0,
            ),
            itemCount: exercises.length,
            itemBuilder: (context, index) {
              final exercise = exercises[index];
              return Card.outlined(
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => onEditExercise(exercise),
                  child: Stack(
                    children: [
                      Container(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              exercise.name,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 4,
                        right: 4,
                        child: Row(
                          children: [
                            IconButton.filledTonal(
                              tooltip: 'Ajouter au programme',
                              icon: const Icon(Icons.add),
                              onPressed: () => onAddToProtocol(exercise),
                            ),
                            const SizedBox(width: 4),
                            IconButton.filledTonal(
                              icon: const Icon(Icons.edit),
                              onPressed: () => onEditExercise(exercise),
                            ),
                            const SizedBox(width: 4),
                            IconButton.filled(
                              icon: const Icon(Icons.delete),
                              style: IconButton.styleFrom(
                                backgroundColor: Theme.of(context).colorScheme.error,
                                foregroundColor: Theme.of(context).colorScheme.onError,
                              ),
                              onPressed: () => onDeleteExercise(exercise),
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
        }

        return ListView.builder(
          itemCount: exercises.length,
          itemBuilder: (context, index) {
            final exercise = exercises[index];
            return Card.outlined(
              margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
              child: ListTile(
                title: Text(exercise.name),
                onTap: () => onEditExercise(exercise),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: () => onAddToProtocol(exercise),
                      tooltip: 'Ajouter au programme',
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => onEditExercise(exercise),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      color: Theme.of(context).colorScheme.error,
                      onPressed: () => onDeleteExercise(exercise),
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
