
import 'package:flutter/material.dart';

import '../../models/protocol.dart';
import '../../services/api_service.dart';

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
          return const Center(child: Text('Aucun programme trouvé.'));
        }
        final protocols = snapshot.data!;
        return ListView.builder(
          itemCount: protocols.length,
          itemBuilder: (context, index) {
            final protocol = protocols[index];
            return ListTile(
              title: Text(protocol.name),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => onDeleteProtocol(protocol),
              ),
              onTap: () => onSelectProtocol(protocol),
            );
          },
        );
      },
    );
  }
}
