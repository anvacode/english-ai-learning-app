import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/activity_result.dart';

class ActivityResultService {
  static const String _resultsKey = 'activity_results';

  /// Agrega un nuevo resultado de actividad al almacenamiento local.
  /// 
  /// [result] es la instancia de [ActivityResult] a persistir.
  /// Los resultados se guardan como lista JSON en shared_preferences.
  static Future<void> saveActivityResult(ActivityResult result) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Obtener lista actual de resultados
    final jsonString = prefs.getString(_resultsKey);
    final List<dynamic> jsonList = jsonString != null 
        ? jsonDecode(jsonString) 
        : [];
    
    // Agregar nuevo resultado
    jsonList.add(result.toJson());
    
    // Guardar lista actualizada
    await prefs.setString(_resultsKey, jsonEncode(jsonList));
  }

  /// Recupera todos los resultados de actividad guardados.
  /// 
  /// Retorna una lista vacía si no hay resultados previos.
  static Future<List<ActivityResult>> getActivityResults() async {
    final prefs = await SharedPreferences.getInstance();
    
    final jsonString = prefs.getString(_resultsKey);
    if (jsonString == null) {
      return [];
    }
    
    try {
      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      return jsonList
          .cast<Map<String, dynamic>>()
          .map((json) => ActivityResult.fromJson(json))
          .toList();
    } catch (e) {
      // Si ocurre un error al deserializar, retornar lista vacía
      return [];
    }
  }

  /// Limpia todos los resultados guardados
  static Future<void> clearActivityResults() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_resultsKey);
  }
}
