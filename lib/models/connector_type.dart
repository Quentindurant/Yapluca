import 'package:cloud_firestore/cloud_firestore.dart';

class ConnectorType {
  final String id;
  final String name;
  final String icon; // chemin asset ou URL
  final String? description;

  ConnectorType({
    required this.id,
    required this.name,
    required this.icon,
    this.description,
  });

  factory ConnectorType.fromMap(Map<String, dynamic> data, String documentId) {
    return ConnectorType(
      id: documentId,
      name: data['name'] ?? '',
      icon: data['icon'] ?? '',
      description: data['description'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'icon': icon,
      'description': description,
    };
  }
}
