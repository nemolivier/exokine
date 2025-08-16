
import 'package:flutter/material.dart';

import '../../models/protocol_exercise.dart';
import '../../models/exercise.dart';
import '../../widgets/multi_select_dropdown.dart';

class PrincipalView extends StatefulWidget {
  final List<ProtocolExercise> currentProtocolExercises;
  final Future<List<Exercise>> exercisesFuture;
  final Function(int) onRemoveExercise;
  final Function(ProtocolExercise, String, dynamic) onUpdateExerciseValue;
  final TextEditingController remarksController;

  const PrincipalView({
    super.key,
    required this.currentProtocolExercises,
    required this.exercisesFuture,
    required this.onRemoveExercise,
    required this.onUpdateExerciseValue,
    required this.remarksController,
  });

  @override
  State<PrincipalView> createState() => _PrincipalViewState();
}

class _PrincipalViewState extends State<PrincipalView> {
  final List<String> _dayAbbreviations = ['Lu', 'Ma', 'Me', 'Je', 'Ve', 'Sa', 'Di'];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Expanded(
            child: Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              clipBehavior: Clip.antiAlias,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Jour')),
                    DataColumn(label: Text('Exercice')),
                    DataColumn(label: Text('Répétitions')),
                    DataColumn(label: Text('Séries')),
                    DataColumn(label: Text('Pause (s)')),
                    DataColumn(label: Text('Tempo')),
                    DataColumn(label: Text('Remarques')),
                    DataColumn(label: Text('Actions')),
                  ],
                  rows: widget.currentProtocolExercises.map((protocolExercise) {
                    return DataRow(
                      cells: [
                        DataCell(
                          MultiSelectDropdown(
                            key: ValueKey(protocolExercise.id),
                            items: _dayAbbreviations,
                            selectedItems: protocolExercise.days,
                            onSelectionChanged: (selectedDays) {
                              widget.onUpdateExerciseValue(protocolExercise, 'days', selectedDays);
                            },
                          ),
                        ),
                        DataCell(
                          FutureBuilder<List<Exercise>>(
                            future: widget.exercisesFuture,
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) return const Text('...');
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
                                fieldViewBuilder: (BuildContext context, TextEditingController fieldController, FocusNode fieldFocusNode, VoidCallback onFieldSubmitted) {
                                  return TextFormField(
                                    controller: fieldController,
                                    focusNode: fieldFocusNode,
                                    decoration: const InputDecoration(
                                      hintText: 'Sélectionner...',
                                      border: InputBorder.none,
                                      filled: true,
                                    ),
                                    onChanged: (value) {
                                       widget.onUpdateExerciseValue(protocolExercise, 'exerciseName', value);
                                    },
                                    onFieldSubmitted: (value) {
                                      final options = exercises.where((exercise) => exercise.name
                                          .toLowerCase()
                                          .contains(value.toLowerCase()));
                                      if (options.isNotEmpty) {
                                        widget.onUpdateExerciseValue(protocolExercise, 'exercise', options.first);
                                        fieldController.text = options.first.name;
                                      }
                                    },
                                  );
                                },
                              );
                            },
                          ),
                        ),
                        DataCell(
                          TextFormField(
                            key: ValueKey('reps_${protocolExercise.id}'),
                            initialValue: protocolExercise.repetitions.toString(),
                            keyboardType: TextInputType.number,
                             decoration: const InputDecoration(border: InputBorder.none, filled: true),
                            onChanged: (value) {
                              widget.onUpdateExerciseValue(protocolExercise, 'repetitions', int.tryParse(value) ?? 0);
                            },
                          ),
                        ),
                        DataCell(
                          TextFormField(
                            key: ValueKey('series_${protocolExercise.id}'),
                            initialValue: protocolExercise.series.toString(),
                            keyboardType: TextInputType.number,
                             decoration: const InputDecoration(border: InputBorder.none, filled: true),
                            onChanged: (value) {
                              widget.onUpdateExerciseValue(protocolExercise, 'series', int.tryParse(value) ?? 0);
                            },
                          ),
                        ),
                        DataCell(
                          TextFormField(
                            key: ValueKey('pause_${protocolExercise.id}'),
                            initialValue: protocolExercise.pause.toString(),
                            keyboardType: TextInputType.number,
                             decoration: const InputDecoration(border: InputBorder.none, filled: true),
                            onChanged: (value) {
                              widget.onUpdateExerciseValue(protocolExercise, 'pause', int.tryParse(value) ?? 0);
                            },
                          ),
                        ),
                        DataCell(
                          TextFormField(
                            key: ValueKey('tempo_${protocolExercise.id}'),
                            initialValue: protocolExercise.tempo,
                             decoration: const InputDecoration(border: InputBorder.none, filled: true),
                            onChanged: (value) {
                              widget.onUpdateExerciseValue(protocolExercise, 'tempo', value);
                            },
                          ),
                        ),
                        DataCell(
                          TextFormField(
                            key: ValueKey('notes_${protocolExercise.id}'),
                            initialValue: protocolExercise.notes,
                             decoration: const InputDecoration(border: InputBorder.none, filled: true),
                            onChanged: (value) {
                              widget.onUpdateExerciseValue(protocolExercise, 'notes', value);
                            },
                          ),
                        ),
                        DataCell(
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => widget.onRemoveExercise(protocolExercise.id),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
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
    );
  }
}
