import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:guardiao_cliente/models/entidade_militar_model.dart';

class EntidadeMilitarRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collectionName = "entidades_militares_policiais";


  Future<List<EntidadeMilitarModel>> fetchByEstado(String estado) async {
    try {
      final querySnapshot = await _firestore
          .collection(collectionName)
          .where('estado', isEqualTo: estado)
          .get();

      return querySnapshot.docs
          .map((doc) => EntidadeMilitarModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      throw Exception("Erro ao buscar Raps por título: $e");
    }
  }
}