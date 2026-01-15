/// Modelo que representa una transacción de estrellas.
/// 
/// Registra todas las operaciones relacionadas con estrellas:
/// - Ganancia de estrellas (completar lecciones, login diario, bonos)
/// - Gasto de estrellas (compras en la tienda)
class StarTransaction {
  final String id;
  final String type; // 'lesson_complete', 'daily_login', 'streak_bonus', 'shop_purchase', 'perfect_score', etc.
  final int amount; // Positivo para ganancias, negativo para gastos
  final String description;
  final DateTime timestamp;
  final String? lessonId; // Si está relacionado con una lección
  final String? itemName; // Si es una compra, nombre del ítem

  StarTransaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.description,
    required this.timestamp,
    this.lessonId,
    this.itemName,
  });

  /// Convierte StarTransaction a JSON para persistencia.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'amount': amount,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      if (lessonId != null) 'lessonId': lessonId,
      if (itemName != null) 'itemName': itemName,
    };
  }

  /// Crea una instancia de StarTransaction desde JSON.
  factory StarTransaction.fromJson(Map<String, dynamic> json) {
    return StarTransaction(
      id: json['id'] as String,
      type: json['type'] as String,
      amount: json['amount'] as int,
      description: json['description'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      lessonId: json['lessonId'] as String?,
      itemName: json['itemName'] as String?,
    );
  }

  /// Verifica si es una transacción de ganancia (amount positivo).
  bool get isEarning => amount > 0;

  /// Verifica si es una transacción de gasto (amount negativo).
  bool get isSpending => amount < 0;
}
