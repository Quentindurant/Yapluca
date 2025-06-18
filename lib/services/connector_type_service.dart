import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/connector_type.dart';

class ConnectorTypeService {
  final CollectionReference connectorTypesCollection = FirebaseFirestore.instance.collection('connector_types');

  Future<List<ConnectorType>> getConnectorTypes() async {
    final snapshot = await connectorTypesCollection.get();
    return snapshot.docs.map((doc) => ConnectorType.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
  }

  Future<ConnectorType?> getConnectorTypeById(String id) async {
    final doc = await connectorTypesCollection.doc(id).get();
    if (doc.exists) {
      return ConnectorType.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }
    return null;
  }
}
