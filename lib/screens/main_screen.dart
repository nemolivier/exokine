
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/protocol.dart';
import '../models/protocol_exercise.dart';
import '../models/exercise.dart';
import '../services/api_service.dart';
import '../widgets/multi_select_dropdown.dart';
import './main/principal_view.dart';
import './main/programmes_view.dart';
import './main/exercices_view.dart';

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
  final TextEditingController _remarksController = TextEditingController();

  bool _isProgrammesGridView = false;
  bool _isExercicesGridView = false;

  final List<String> _dayAbbreviations = ['Lu', 'Ma', 'Me', 'Je', 'Ve', 'Sa', 'Di'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {}); // Rebuild to update FAB and view switcher
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

  @override
  void dispose() {
    _tabController.dispose();
    _remarksController.dispose();
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
          _buildViewSwitcherButton(),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          PrincipalView(
            currentProtocolExercises: _currentProtocolExercises,
            exercisesFuture: _exercisesFuture,
            onRemoveExercise: _removeExercise,
            onAddExerciseRow: () {
              setState(() {
                _addEmptyExercise();
              });
            },
            onUpdateExerciseValue: _updateProtocolExerciseValue,
            remarksController: _remarksController,
          ),
          ProgrammesView(
            protocolsFuture: _protocolsFuture,
            isGridView: _isProgrammesGridView,
            onSelectProtocol: (protocol) {
              setState(() {
                _currentProtocolExercises = protocol.exercises;
                _remarksController.text = protocol.remarks ?? '';
              });
              _tabController.animateTo(0);
            },
            onDeleteProtocol: _showDeleteConfirmDialog,
          ),
          ExercicesView(
            exercisesFuture: _exercisesFuture,
            isGridView: _isExercicesGridView,
            onAddExercise: _showAddExerciseDialog,
            onEditExercise: _showEditExerciseDialog,
            onDeleteExercise: _showDeleteExerciseConfirmDialog,
            onAddToProtocol: _addExerciseToCurrentProtocol,
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  void _updateProtocolExerciseValue(ProtocolExercise exercise, String field, dynamic value) {
    setState(() {
      switch (field) {
        case 'days':
          exercise.days = value as List<String>;
          break;
        case 'exercise':
          final selectedExercise = value as Exercise;
          exercise.exerciseId = selectedExercise.id;
          exercise.exerciseName = selectedExercise.name;
          break;
        case 'exerciseName':
           exercise.exerciseName = value as String;
          break;
        case 'repetitions':
          exercise.repetitions = value as int;
          break;
        case 'series':
          exercise.series = value as int;
          break;
        case 'pause':
          exercise.pause = value as int;
          break;
        case 'tempo':
          exercise.tempo = value as String;
          break;
        case 'notes':
          exercise.notes = value as String;
          break;
      }
    });
  }

  Widget _buildViewSwitcherButton() {
    if (_tabController.index == 1) {
      return IconButton(
        icon: Icon(_isProgrammesGridView ? Icons.view_list : Icons.grid_view),
        onPressed: () {
          setState(() {
            _isProgrammesGridView = !_isProgrammesGridView;
          });
        },
        tooltip: _isProgrammesGridView ? 'Afficher la liste' : 'Afficher la grille',
      );
    } else if (_tabController.index == 2) {
      return IconButton(
        icon: Icon(_isExercicesGridView ? Icons.view_list : Icons.grid_view),
        onPressed: () {
          setState(() {
            _isExercicesGridView = !_isExercicesGridView;
          });
        },
        tooltip: _isExercicesGridView ? 'Afficher la liste' : 'Afficher la grille',
      );
    }
    return const SizedBox.shrink(); // No button on the first tab
  }

  Widget? _buildFloatingActionButton() {
    switch (_tabController.index) {
      case 0: // Principal
        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton.extended(
              heroTag: 'print_protocol',
              onPressed: _showPrintDialog,
              label: const Text('Imprimer'),
              icon: const Icon(Icons.print),
            ),
            const SizedBox(width: 16),
            FloatingActionButton.extended(
              heroTag: 'save_protocol',
              onPressed: _saveProtocol,
              label: const Text('Sauvegarder'),
              icon: const Icon(Icons.save),
            ),
          ],
        );
      case 2: // Exercices
        return FloatingActionButton(
          heroTag: 'add_base_exercise',
          onPressed: _showAddExerciseDialog,
          tooltip: 'Ajouter un nouvel exercice de base',
          child: const Icon(Icons.add),
        );
      default: // Programmes
        return null;
    }
  }

  void _showDeleteConfirmDialog(Protocol protocol) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmer la suppression'),
          content: Text('Êtes-vous sûr de vouloir supprimer le programme "${protocol.name}" ? Cette action est irréversible.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Annuler'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
              child: const Text('Supprimer'),
              onPressed: () async {
                try {
                  await _apiService.deleteProtocol(protocol.id);
                  setState(() {
                    _protocolsFuture = _apiService.getProtocols();
                  });
                  Navigator.of(context).pop(); // Close the dialog
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Programme supprimé avec succès.')),
                  );
                } catch (e) {
                  Navigator.of(context).pop(); // Close the dialog
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erreur lors de la suppression: ${e.toString()}')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showDeleteExerciseConfirmDialog(Exercise exercise) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmer la suppression'),
          content: Text('Êtes-vous sûr de vouloir supprimer l\'exercice "${exercise.name}" ? Cette action est irréversible.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Annuler'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
              child: const Text('Supprimer'),
              onPressed: () async {
                try {
                  await _apiService.deleteExercise(exercise.id);
                  setState(() {
                    _exercisesFuture = _apiService.getExercises();
                  });
                  Navigator.of(context).pop(); // Close the dialog
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Exercice supprimé avec succès.')),
                  );
                } catch (e) {
                  Navigator.of(context).pop(); // Close the dialog
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erreur lors de la suppression: ${e.toString()}')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showAddExerciseDialog() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController articulationController = TextEditingController();
    final TextEditingController musclesController = TextEditingController();
    final TextEditingController typeController = TextEditingController();

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
                TextField(
                  controller: typeController,
                  decoration: const InputDecoration(hintText: "Type (ex: Équilibre, Renforcement)"),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty) {
                  try {
                    await _apiService.createExercise(
                      nameController.text,
                      articulationController.text.split(',').map((e) => e.trim()).toList(),
                      musclesController.text.split(',').map((e) => e.trim()).toList(),
                      typeController.text,
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
    final TextEditingController typeController = TextEditingController(text: exercise.type);

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
                  decoration: const InputDecoration(hintText: "Muscles (séparées par des virgules)"),
                ),
                TextField(
                  controller: typeController,
                  decoration: const InputDecoration(hintText: "Type (ex: Équilibre, Renforcement)"),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty) {
                  try {
                    final updatedExercise = Exercise(
                      id: exercise.id,
                      name: nameController.text,
                      articulation: articulationController.text.split(',').map((e) => e.trim()).toList(),
                      muscles: musclesController.text.split(',').map((e) => e.trim()).toList(),
                      type: typeController.text,
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

  void _addExerciseToCurrentProtocol(Exercise exercise) {
    setState(() {
      final newProtocolExercise = _createEmptyExercise();
      newProtocolExercise.exerciseId = exercise.id;
      newProtocolExercise.exerciseName = exercise.name;

      // Try to replace the first empty row
      final emptyRowIndex = _currentProtocolExercises.indexWhere((ex) => ex.exerciseId == 0);

      if (emptyRowIndex != -1) {
        _currentProtocolExercises[emptyRowIndex] = newProtocolExercise;
      } else {
        _currentProtocolExercises.add(newProtocolExercise);
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('"${exercise.name}" ajouté au programme.'),
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'VOIR',
          onPressed: () {
            _tabController.animateTo(0);
          },
        ),
      ),
    );
  }

  void _removeExercise(int id) {
    setState(() {
      _currentProtocolExercises.removeWhere((exercise) => exercise.id == id);
      if (_currentProtocolExercises.isEmpty) {
        _remarksController.clear();
      }
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
              FilledButton(
                onPressed: () async {
                  if (nameController.text.isNotEmpty) {
                    final newProtocol = Protocol(
                      id: 0,
                      name: nameController.text,
                      remarks: _remarksController.text,
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

  void _showPrintDialog() {
    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Imprimer le programme'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(hintText: "Nom de la personne"),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () {
                final name = nameController.text;
                if (name.isNotEmpty) {
                  Navigator.of(context).pop();
                  _doGeneratePdf(name);
                }
              },
              child: const Text('Imprimer'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _doGeneratePdf(String personName) async {
    final pdf = pw.Document();
    final now = DateTime.now();
    final formattedDate = "${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}";
    final displayDate = "${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}";
    final fileName = "$personName - $formattedDate.pdf";

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        header: (pw.Context context) {
          return pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Programme d\'exercices pour : $personName', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.Text('Date: $displayDate', style: const pw.TextStyle(fontSize: 14)),
            ]
          );
        },
        build: (pw.Context context) => [
          pw.SizedBox(height: 20),
          pw.Table.fromTextArray(
            headers: ['Jour', 'Exercice', 'Répétitions', 'Séries', 'Pause (s)', 'Tempo', 'Remarques'],
            data: _currentProtocolExercises.map((ex) => [
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
        footer: (pw.Context context) {
          return pw.Container(
            alignment: pw.Alignment.centerRight,
            child: pw.Text(
              'Nom du fichier : $fileName',
              style: const pw.TextStyle(color: PdfColors.grey, fontSize: 10),
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: fileName,
    );
  }
}
