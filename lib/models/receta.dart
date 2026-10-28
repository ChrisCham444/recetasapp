class Receta {
  final int id;
  final String nombre;
  final List<String> ingredientes;
  final List<String> instrucciones;
  final int tiempoPreparacion;
  final int tiempoCoccion;
  final int porciones;
  final int calorias;
  final String imagenUrl;
  final double calificacion;

  const Receta({
    required this.id,
    required this.nombre,
    required this.ingredientes,
    required this.instrucciones,
    required this.tiempoPreparacion,
    required this.tiempoCoccion,
    required this.porciones,
    required this.calorias,
    required this.imagenUrl,
    required this.calificacion,
  });
  factory Receta.fromJson(Map<String, dynamic> json) {
    return Receta(
      id: json['id'] as int,
      nombre: json['name'] as String,
      ingredientes: List<String>.from(json['ingredients'] as List),
      instrucciones: List<String>.from(json['instructions'] as List),
      tiempoPreparacion: json['prepTimeMinutes'] as int,
      tiempoCoccion: json['cookTimeMinutes'] as int,
      porciones: json['servings'] as int,
      calorias: json['caloriesPerServing'] as int,
      imagenUrl: json['image'] as String,
      calificacion: (json['rating'] as num).toDouble(),
    );
  }

  int get tiempoTotal => tiempoPreparacion + tiempoCoccion;
}
