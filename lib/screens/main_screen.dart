
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/protocol.dart';
import '../models/protocol_exercise.dart';
import '../models/exercise.dart';
import '../services/api_service.dart';
import '../widgets/multi_select_dropdown.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  late Future<List<Protocol>> _protocolsFuture;
  late Future<List<Exercise>> _exercisesFuture;
  late TabController _tabController;

  List<ProtocolExercise> _currentProtocolExercises = [];
  final Map<int, Map<String, TextEditingController>> _controllers = {};

  final List<String> _dayAbbreviations = ['Lu', 'Ma', 'Me', 'Je', 'Ve', 'Sa', 'Di'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {}); // Rebuild to update FAB
    });
    _protocolsFuture = _apiService.getProtocols();
    _exercisesFuture = _apiService.getExercises();

    // Add 3 default rows
    _addEmptyExercise();
    _addEmptyExercise();
    _addEmptyExercise();
  }

  void _addEmptyExercise() {
    final newExercise = _createEmptyExercise();
    _currentProtocolExercises.add(newExercise);
    _initControllers(newExercise);
  }

  ProtocolExercise _createEmptyExercise() {
    return ProtocolExercise(
      id: DateTime.now().millisecondsSinceEpoch + _currentProtocolExercises.length,
      exerciseId: 0,
      exerciseName: '',
      repetitions: 10,
      series: 3,
      pause: 60,
      tempo: '2010',
      notes: '',
      days: [],
    );
  }

  void _initControllers(ProtocolExercise exercise) {
    _controllers[exercise.id] = {
      'repetitions': TextEditingController(text: exercise.repetitions.toString()),
      'series': TextEditingController(text: exercise.series.toString()),
      'pause': TextEditingController(text: exercise.pause.toString()),
      'tempo': TextEditingController(text: exercise.tempo),
      'notes': TextEditingController(text: exercise.notes ?? ''),
    };
  }

  @override
  void dispose() {
    _tabController.dispose();
    _controllers.values.forEach((map) {
      map.values.forEach((controller) => controller.dispose());
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exokin'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Principal'),
            Tab(text: 'Programmes'),
            Tab(text: 'Exercices'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: () => _generatePdf(_currentProtocolExercises),
            tooltip: 'Imprimer',
          ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveProtocol,
            tooltip: 'Sauvegarder',
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPrincipalView(),
          _buildProgrammesView(),
          _buildExercicesView(),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget? _buildFloatingActionButton() {
    switch (_tabController.index) {
      case 0: // Principal
        return FloatingActionButton(
          onPressed: () {
            setState(() {
              _addEmptyExercise();
            });
          },
          tooltip: 'Ajouter une ligne',
          child: const Icon(Icons.add),
        );
      case 2: // Exercices
        return FloatingActionButton(
          onPressed: _showAddExerciseDialog,
          tooltip: 'Ajouter un nouvel exercice de base',
          child: const Icon(Icons.add),
        );
      default: // Programmes
        return null;
    }
  }

  Widget _buildPrincipalView() {
    return SingleChildScrollView(
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
        rows: _currentProtocolExercises.map((protocolExercise) {
          if (_controllers[protocolExercise.id] == null) {
            _initControllers(protocolExercise);
          }
          return DataRow(
            cells: [
              DataCell(
                MultiSelectDropdown(
                  items: _dayAbbreviations,
                  selectedItems: protocolExercise.days,
                  onSelectionChanged: (selectedDays) {
                    setState(() {
                      protocolExercise.days = selectedDays;
                    });
                  },
                ),
              ),
              DataCell(
                FutureBuilder<List<Exercise>>(
                  future: _exercisesFuture,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const Text('...');
                    final exercises = snapshot.data!;
                    return Autocomplete<Exercise>(
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
                        setState(() {
                          protocolExercise.exerciseId = selection.id;
                          protocolExercise.exerciseName = selection.name;
                        });
                      },
                      fieldViewBuilder: (BuildContext context, TextEditingController fieldController, FocusNode fieldFocusNode, VoidCallback onFieldSubmitted) {
                        return TextFormField(
                          controller: fieldController,
                          focusNode: fieldFocusNode,
                          decoration: const InputDecoration(
                            hintText: 'Sélectionner...', 
                          ),
                          onChanged: (value) {
                             setState(() {
                              protocolExercise.exerciseName = value;
                            });
                          },
                          onFieldSubmitted: (value) {
                            final options = exercises.where((exercise) => exercise.name
                                .toLowerCase()
                                .contains(value.toLowerCase()));
                            if (options.isNotEmpty) {
                              setState(() {
                                protocolExercise.exerciseId = options.first.id;
                                protocolExercise.exerciseName = options.first.name;
                                fieldController.text = options.first.name;
                              });
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
                  controller: _controllers[protocolExercise.id]!['repetitions'],
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    protocolExercise.repetitions = int.tryParse(value) ?? 0;
                  },
                ),
              ),
              DataCell(
                TextFormField(
                  controller: _controllers[protocolExercise.id]!['series'],
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    protocolExercise.series = int.tryParse(value) ?? 0;
                  },
                ),
              ),
              DataCell(
                TextFormField(
                  controller: _controllers[protocolExercise.id]!['pause'],
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    protocolExercise.pause = int.tryParse(value) ?? 0;
                  },
                ),
              ),
              DataCell(
                TextFormField(
                  controller: _controllers[protocolExercise.id]!['tempo'],
                  onChanged: (value) {
                    protocolExercise.tempo = value;
                  },
                ),
              ),
              DataCell(
                TextFormField(
                  controller: _controllers[protocolExercise.id]!['notes'],
                  onChanged: (value) {
                    protocolExercise.notes = value;
                  },
                ),
              ),
              DataCell(
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _removeExercise(protocolExercise.id),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildProgrammesView() {
    return FutureBuilder<List<Protocol>>(
      future: _protocolsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Aucun programme trouvé.'));
        }
        final protocols = snapshot.data!;
        return ListView.builder(
          itemCount: protocols.length,
          itemBuilder: (context, index) {
            final protocol = protocols[index];
            return ListTile(
              title: Text(protocol.name),
              onTap: () {
                setState(() {
                  _currentProtocolExercises = protocol.exercises;
                  _currentProtocolExercises.forEach(_initControllers);
                });
                _tabController.animateTo(0);
              },
            );
          },
        );
      },
    );
  }

  Widget _buildExercicesView() {
    return FutureBuilder<List<Exercise>>(
      future: _exercisesFuture,
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
            return Card(
              margin: const EdgeInsets.all(8.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exercise.name,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text('Articulations: ${exercise.articulation.join(', ')}'),
                    Text('Muscles: ${exercise.muscles.join(', ')}'),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _showEditExerciseDialog(exercise),
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

  void _showAddExerciseDialog() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController articulationController = TextEditingController();
    final TextEditingController musclesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Ajouter un nouvel exercice'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(hintText: "Nom de l'exercice"),
                ),
                TextField(
                  controller: articulationController,
                  decoration: const InputDecoration(hintText: "Articulations (séparées par des virgules)"),
                ),
                TextField(
                  controller: musclesController,
                  decoration: const InputDecoration(hintText: "Muscles (séparées par des virgules)"),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty) {
                  try {
                    await _apiService.createExercise(
                      nameController.text,
                      articulationController.text.split(',').map((e) => e.trim()).toList(),
                      musclesController.text.split(',').map((e) => e.trim()).toList(),
                    );
                    setState(() {
                      _exercisesFuture = _apiService.getExercises();
                    });
                    Navigator.of(context).pop();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erreur: ${e.toString()}')),
                    );
                  }
                }
              },
              child: const Text('Créer'),
            ),
          ],
        );
      },
    );
  }

  void _showEditExerciseDialog(Exercise exercise) {
    final TextEditingController nameController = TextEditingController(text: exercise.name);
    final TextEditingController articulationController = TextEditingController(text: exercise.articulation.join(', '));
    final TextEditingController musclesController = TextEditingController(text: exercise.muscles.join(', '));

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Modifier l\'exercice'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(hintText: "Nom de l\'exercice"),
                ),
                TextField(
                  controller: articulationController,
                  decoration: const InputDecoration(hintText: "Articulations (séparées par des virgules)"),
                ),
                TextField(
                  controller: musclesController,
                  decoration: const InputDecoration(hintText: "Muscles (séparés par des virgules)"),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty) {
                  try {
                    final updatedExercise = Exercise(
                      id: exercise.id,
                      name: nameController.text,
                      articulation: articulationController.text.split(',').map((e) => e.trim()).toList(),
                      muscles: musclesController.text.split(',').map((e) => e.trim()).toList(),
                    );
                    await _apiService.updateExercise(updatedExercise);
                    setState(() {
                      _exercisesFuture = _apiService.getExercises();
                    });
                    Navigator.of(context).pop();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erreur: ${e.toString()}')),
                    );
                  }
                }
              },
              child: const Text('Sauvegarder'),
            ),
          ],
        );
      },
    );
  }

  void _removeExercise(int id) {
    setState(() {
      _currentProtocolExercises.removeWhere((exercise) => exercise.id == id);
      _controllers.remove(id)?.values.forEach((controller) => controller.dispose());
    });
    if (id > 0 && !id.toString().startsWith('1')) { // Don't delete default exercises
      _apiService.deleteProtocolExercise(id).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ${error.toString()}')),
        );
      });
    }
  }

  void _saveProtocol() async {
    final nameController = TextEditingController();
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Nom du programme'),
            content: TextField(
              controller: nameController,
              decoration: const InputDecoration(hintText: "Entrez un nom"),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Annuler'),
              ),
              TextButton(
                onPressed: () async {
                  if (nameController.text.isNotEmpty) {
                    final newProtocol = Protocol(
                      id: 0,
                      name: nameController.text,
                      exercises: _currentProtocolExercises
                          .where((ex) => ex.exerciseId != 0)
                          .toList(),
                    );
                    try {
                      await _apiService.createProtocol(newProtocol);
                      setState(() {
                        _protocolsFuture = _apiService.getProtocols();
                      });
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Programme sauvegardé!')), 
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Erreur: ${e.toString()}')),
                      );
                    }
                  }
                },
                child: const Text('Sauvegarder'),
              ),
            ],
          );
        });
  }

  Future<void> _generatePdf(List<ProtocolExercise> exercises) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Programme d\'exercices', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 20),
              pw.Table.fromTextArray(
                headers: ['Jour', 'Exercice', 'Répétitions', 'Séries', 'Pause (s)', 'Tempo', 'Remarques'],
                data: exercises.map((ex) => [
                  ex.days.join(', '),
                  ex.exerciseName,
                  ex.repetitions.toString(),
                  ex.series.toString(),
                  ex.pause.toString(),
                  ex.tempo,
                  ex.notes ?? '',
                ]).toList(),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }
}
