
import 'package:flutter/material.dart';

import '../../models/protocol.dart';
import '../../services/api_service.dart';
import '../../widgets/empty_state_view.dart';

class ProgrammesView extends StatelessWidget {
  final Future<List<Protocol>> protocolsFuture;
  final Function(Protocol) onSelectProtocol;
  final Function(Protocol) onDeleteProtocol;


  const ProgrammesView({
    super.key,
    required this.protocolsFuture,
    required this.onSelectProtocol,
    required this.onDeleteProtocol,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Protocol>>(
      future: protocolsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const EmptyStateView(
            icon: Icons.folder_off_outlined,
            message: 'Aucun programme trouvé.',
          );
        }
        final protocols = snapshot.data!;
        return ListView.builder(
          itemCount: protocols.length,
          itemBuilder: (context, index) {
            final protocol = protocols[index];
            return Card.outlined(
              margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: ListTile(
                title: Text(protocol.name, style: Theme.of(context).textTheme.titleLarge),
                trailing: FloatingActionButton.small(
                  heroTag: 'delete_protocol_${protocol.id}',
                  backgroundColor: Theme.of(context).colorScheme.error,
                  onPressed: () => onDeleteProtocol(protocol),
                  child: const Icon(Icons.delete),
                ),
                onTap: () => onSelectProtocol(protocol),
              ),
            );
          },
        );
      },
    );
  }
}
