class Resena {
  const Resena({
    this.id,
    required this.recetaId,
    required this.autor,
    required this.calificacion,
    required this.comentario,
    required this.fechaCreacion,
  });

  final int? id;
  final int recetaId;
  final String autor;
  final int calificacion;
  final String comentario;
  final DateTime fechaCreacion;

  factory Resena.fromMap(Map<String, Object?> map) {
    return Resena(
      id: map['id'] as int,
      recetaId: map['receta_id'] as int,
      autor: map['autor'] as String,
      calificacion: map['calificacion'] as int,
      comentario: map['comentario'] as String,
      fechaCreacion: DateTime.parse(map['fecha_creacion'] as String),
    );
  }

  Map<String, Object?> toMap() {
    return {
      if (id != null) 'id': id,
      'receta_id': recetaId,
      'autor': autor,
      'calificacion': calificacion,
      'comentario': comentario,
      'fecha_creacion': fechaCreacion.toIso8601String(),
    };
  }
}
