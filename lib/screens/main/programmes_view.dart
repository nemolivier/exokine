
import 'package:flutter/material.dart';

import '../../models/protocol.dart';
import '../../services/api_service.dart';
import '../../widgets/empty_state_view.dart';

class ProgrammesView extends StatelessWidget {
  final Future<List<Protocol>> protocolsFuture;
  final Function(Protocol) onSelectProtocol;
  final Function(Protocol) onDeleteProtocol;
  final bool isGridView;


  const ProgrammesView({
    super.key,
    required this.protocolsFuture,
    required this.onSelectProtocol,
    required this.onDeleteProtocol,
    required this.isGridView,
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

        if (isGridView) {
          return GridView.builder(
            padding: const EdgeInsets.all(16.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 16.0,
              mainAxisSpacing: 16.0,
              childAspectRatio: 1 / 1.2,
            ),
            itemCount: protocols.length,
            itemBuilder: (context, index) {
              final protocol = protocols[index];
              return Card.outlined(
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => onSelectProtocol(protocol),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Container(
                          color: Theme.of(context).colorScheme.secondaryContainer,
                          child: Center(
                            child: Text(
                              protocol.name,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                protocol.name,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                            ),
                            FloatingActionButton.small(
                              heroTag: 'delete_protocol_grid_${protocol.id}',
                              backgroundColor: Theme.of(context).colorScheme.error,
                              onPressed: () => onDeleteProtocol(protocol),
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
        }

        return ListView.builder(
          itemCount: protocols.length,
          itemBuilder: (context, index) {
            final protocol = protocols[index];
            return Card.outlined(
              margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
                side: BorderSide(color: Theme.of(context).colorScheme.secondary, width: 1),
              ),
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
