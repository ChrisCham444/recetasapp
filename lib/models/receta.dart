class Receta {
  final int id;
  final String nombre;
  final List<String> ingredientes;
  final List<String> instrucciones;
  final int tiempoPreparacion;
  final int tiempoCoccion;
  final int porciones;
  final int calorias;
  final String imagen;
  final double calificacion;
  final String dificultad;
  final String cocina;

  Receta({
    required this.id,
    required this.nombre,
    required this.ingredientes,
    required this.instrucciones,
    required this.tiempoPreparacion,
    required this.tiempoCoccion,
    required this.porciones,
    required this.calorias,
    required this.imagen,
    required this.calificacion,
    required this.dificultad,
    required this.cocina,
  });

  factory Receta.fromJson(Map<String, dynamic> json) {
    return Receta(
      id: (json['id'] as num).toInt(),
      nombre: json['name'] ?? '',
      ingredientes: List<String>.from(json['ingredients'] ?? []),
      instrucciones: List<String>.from(json['instructions'] ?? []),
      tiempoPreparacion: json['prepTimeMinutes'] ?? 0,
      tiempoCoccion: json['cookTimeMinutes'] ?? 0,
      porciones: json['servings'] ?? 0,
      calorias: json['caloriesPerServing'] ?? 0,
      imagen: json['image'] ?? '',
      calificacion: (json['rating'] ?? 0.0).toDouble(),
      dificultad: json['difficulty'] ?? 'Desconocida',
      cocina: json['cuisine'] ?? 'Desconocida',
    );
  }

  int get tiempoTotal => tiempoPreparacion + tiempoCoccion;
}
