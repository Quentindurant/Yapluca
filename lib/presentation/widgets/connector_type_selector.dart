import 'package:flutter/material.dart';
import '../../models/connector_type.dart';

class ConnectorTypeSelector extends StatelessWidget {
  final List<ConnectorType> connectorTypes;
  final String? selectedId;
  final Function(String?) onChanged;
  final bool showNone;

  const ConnectorTypeSelector({
    Key? key,
    required this.connectorTypes,
    required this.selectedId,
    required this.onChanged,
    this.showNone = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sortedTypes = List<ConnectorType>.from(connectorTypes)
      ..sort((a, b) => a.name.compareTo(b.name));
    return DropdownButtonFormField<String>(
      value: selectedId?.isNotEmpty == true ? selectedId : null,
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'Type de connecteur favori',
        border: OutlineInputBorder(),
      ),
      items: [
        if (showNone)
          const DropdownMenuItem<String>(
            value: null,
            child: Text('Aucun'),
          ),
        ...sortedTypes.map((type) => DropdownMenuItem<String>(
              value: type.id,
              child: Row(
                children: [
                  type.icon.isNotEmpty
                      ? Image.asset(type.icon, height: 24, width: 24, errorBuilder: (c, o, s) => const Icon(Icons.bolt))
                      : const Icon(Icons.bolt),
                  const SizedBox(width: 8),
                  Text(type.name),
                ],
              ),
            )),
      ],
      onChanged: onChanged,
    );
  }
}
