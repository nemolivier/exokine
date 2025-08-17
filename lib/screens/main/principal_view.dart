
import 'package:flutter/material.dart';

import '../../models/protocol_exercise.dart';
import '../../models/exercise.dart';
import '../../widgets/multi_select_dropdown.dart';

class PrincipalView extends StatefulWidget {
  final List<ProtocolExercise> currentProtocolExercises;
  final Future<List<Exercise>> exercisesFuture;
  final Function(int) onRemoveExercise;
  final Function() onAddExerciseRow;
  final Function(ProtocolExercise, String, dynamic) onUpdateExerciseValue;
  final TextEditingController remarksController;

  const PrincipalView({
    super.key,
    required this.currentProtocolExercises,
    required this.exercisesFuture,
    required this.onRemoveExercise,
    required this.onAddExerciseRow,
    required this.onUpdateExerciseValue,
    required this.remarksController,
  });

  @override
  State<PrincipalView> createState() => _PrincipalViewState();
}

class _PrincipalViewState extends State<PrincipalView> {
  final _formKey = GlobalKey<FormState>();
  final List<String> _dayAbbreviations = ['Lu', 'Ma', 'Me', 'Je', 'Ve', 'Sa', 'Di'];

  Widget _buildHeader(BuildContext context) {
    final textTheme = Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text('Jour', style: textTheme)),
          Expanded(flex: 4, child: Text('Exercice', style: textTheme)),
          Expanded(flex: 2, child: Text('Répétitions', style: textTheme, textAlign: TextAlign.center)),
          Expanded(flex: 2, child: Text('Séries', style: textTheme, textAlign: TextAlign.center)),
          Expanded(flex: 2, child: Text('Pause (s)', style: textTheme, textAlign: TextAlign.center)),
          Expanded(flex: 2, child: Text('Tempo', style: textTheme, textAlign: TextAlign.center)),
          Expanded(flex: 4, child: Text('Remarques', style: textTheme)),
          const SizedBox(width: 48), // For the delete button
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildHeader(context),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.currentProtocolExercises.length,
                itemBuilder: (context, index) {
                  final protocolExercise = widget.currentProtocolExercises[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 4.0),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                      child: IntrinsicHeight(
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: MultiSelectDropdown(
                                key: ValueKey(protocolExercise.id),
                                items: _dayAbbreviations,
                                selectedItems: protocolExercise.days,
                                onSelectionChanged: (selectedDays) {
                                  widget.onUpdateExerciseValue(protocolExercise, 'days', selectedDays);
                                },
                              ),
                            ),
                            Expanded(
                              flex: 4,
                              child: FutureBuilder<List<Exercise>>(
                                future: widget.exercisesFuture,
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) return const Center(child: Text('...'));
                                  final exercises = snapshot.data!;
                                  return Autocomplete<Exercise>(
                                    key: ValueKey('autocomplete_${protocolExercise.id}'),
                                    displayStringForOption: (option) => option.name,
                                    initialValue: TextEditingValue(text: protocolExercise.exerciseName),
                                    optionsBuilder: (TextEditingValue textEditingValue) {
                                      if (textEditingValue.text.isEmpty) {
                                        return const Iterable<Exercise>.empty();
                                      }
                                      return exercises.where((exercise) => exercise.name
                                          .toLowerCase()
                                          .contains(textEditingValue.text.toLowerCase()));
                                    },
                                    onSelected: (Exercise selection) {
                                      widget.onUpdateExerciseValue(protocolExercise, 'exercise', selection);
                                    },
                                    fieldViewBuilder: (context, fieldController, fieldFocusNode, onFieldSubmitted) {
                                      return TextFormField(
                                        controller: fieldController,
                                        focusNode: fieldFocusNode,
                                        decoration: const InputDecoration(
                                          hintText: 'Taper pour chercher...',
                                          border: OutlineInputBorder(),
                                          contentPadding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                                        ),
                                        onChanged: (value) {
                                          widget.onUpdateExerciseValue(protocolExercise, 'exerciseName', value);
                                        },
                                        onFieldSubmitted: (String value) {
                                          onFieldSubmitted();
                                        },
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: TextFormField(
                                key: ValueKey('reps_${protocolExercise.id}'),
                                textAlign: TextAlign.center,
                                initialValue: protocolExercise.repetitions.toString(),
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.all(8)),
                                autovalidateMode: AutovalidateMode.onUserInteraction,
                                validator: (value) {
                                  if (value != null && value.isNotEmpty && int.tryParse(value) == null) {
                                    return 'Invalide';
                                  }
                                  return null;
                                },
                                onChanged: (value) {
                                  final intValue = int.tryParse(value);
                                  if (intValue != null) {
                                    widget.onUpdateExerciseValue(protocolExercise, 'repetitions', intValue);
                                  } else if (value.isEmpty) {
                                    widget.onUpdateExerciseValue(protocolExercise, 'repetitions', 0);
                                  }
                                },
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: TextFormField(
                                key: ValueKey('series_${protocolExercise.id}'),
                                textAlign: TextAlign.center,
                                initialValue: protocolExercise.series.toString(),
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.all(8)),
                                autovalidateMode: AutovalidateMode.onUserInteraction,
                                validator: (value) {
                                  if (value != null && value.isNotEmpty && int.tryParse(value) == null) {
                                    return 'Invalide';
                                  }
                                  return null;
                                },
                                onChanged: (value) {
                                  final intValue = int.tryParse(value);
                                  if (intValue != null) {
                                    widget.onUpdateExerciseValue(protocolExercise, 'series', intValue);
                                  } else if (value.isEmpty) {
                                    widget.onUpdateExerciseValue(protocolExercise, 'series', 0);
                                  }
                                },
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: TextFormField(
                                key: ValueKey('pause_${protocolExercise.id}'),
                                textAlign: TextAlign.center,
                                initialValue: protocolExercise.pause.toString(),
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.all(8)),
                                autovalidateMode: AutovalidateMode.onUserInteraction,
                                validator: (value) {
                                  if (value != null && value.isNotEmpty && int.tryParse(value) == null) {
                                    return 'Invalide';
                                  }
                                  return null;
                                },
                                onChanged: (value) {
                                  final intValue = int.tryParse(value);
                                  if (intValue != null) {
                                    widget.onUpdateExerciseValue(protocolExercise, 'pause', intValue);
                                  } else if (value.isEmpty) {
                                    widget.onUpdateExerciseValue(protocolExercise, 'pause', 0);
                                  }
                                },
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: TextFormField(
                                key: ValueKey('tempo_${protocolExercise.id}'),
                                textAlign: TextAlign.center,
                                initialValue: protocolExercise.tempo,
                                decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.all(8)),
                                onChanged: (value) {
                                  widget.onUpdateExerciseValue(protocolExercise, 'tempo', value);
                                },
                              ),
                            ),
                            Expanded(
                              flex: 4,
                              child: TextFormField(
                                key: ValueKey('notes_${protocolExercise.id}'),
                                initialValue: protocolExercise.notes,
                                decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.all(8)),
                                onChanged: (value) {
                                  widget.onUpdateExerciseValue(protocolExercise, 'notes', value);
                                },
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              color: Theme.of(context).colorScheme.error,
                              tooltip: 'Supprimer la ligne',
                              onPressed: () => widget.onRemoveExercise(protocolExercise.id),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0, right: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    FloatingActionButton.extended(
                      heroTag: 'add_exercise_row',
                      onPressed: widget.onAddExerciseRow,
                      label: const Text('Ajouter une ligne'),
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: widget.remarksController,
                decoration: const InputDecoration(
                  labelText: 'Remarques globales',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
