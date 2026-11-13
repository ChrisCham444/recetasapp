import 'package:flutter/material.dart';
import 'package:recetasapp/models/receta.dart';
import 'package:recetasapp/models/resena.dart';
import 'package:recetasapp/services/resenas_db.dart';

class DetalleRecetaScreen extends StatefulWidget {
  final Receta receta;

  const DetalleRecetaScreen({super.key, required this.receta});

  @override
  State<DetalleRecetaScreen> createState() => _DetalleRecetaScreenState();
}

class _DetalleRecetaScreenState extends State<DetalleRecetaScreen> {
  late Future<List<Resena>> _reviewsFuture;

  @override
  void initState() {
    super.initState();
    _reviewsFuture = ResenasDb.instancia.obtenerPorReceta(widget.receta.id);
  }

  Future<void> _writeReview() async {
    final review = await showDialog<_RecipeReview>(
      context: context,
      builder: (context) => const _RecipeReviewDialog(),
    );

    if (review == null || !mounted) return;

    try {
      await ResenasDb.instancia.insertarResena(
        Resena(
          recetaId: widget.receta.id,
          autor: review.author,
          calificacion: review.rating,
          comentario: review.comment,
          fechaCreacion: DateTime.now(),
        ),
      );
      if (!mounted) return;
      setState(() {
        _reviewsFuture = ResenasDb.instancia.obtenerPorReceta(widget.receta.id);
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Reseña guardada.')));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo guardar la reseña: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final receta = widget.receta;

    final tiempoTotal = receta.tiempoPreparacion + receta.tiempoCoccion;

    return Scaffold(
      appBar: AppBar(title: const Text("Detalle de la receta")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.network(
              receta.imagen,
              height: 200,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stack) => Image.asset(
                "assets/images/plato-placeholder.jpg",
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            children: [
              Chip(label: Text('$tiempoTotal min')),
              Chip(label: Text(receta.dificultad)),
              Chip(label: Text(receta.cocina)),
              Chip(label: Text('${receta.calorias} kcal')),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            "Ingredientes: ",
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...receta.ingredientes.map(
            (ingrediente) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  const Icon(Icons.circle, size: 6, color: Colors.orange),
                  const SizedBox(width: 8),
                  Expanded(child: Text(ingrediente)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "Preparación: ",
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...receta.instrucciones.asMap().entries.map(
            (entrada) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: Colors.deepOrange,
                    child: Text(
                      '${entrada.key + 1}',
                      style: const TextStyle(color: Colors.white, fontSize: 11),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Text(entrada.value)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Reseñas',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton.icon(
                onPressed: _writeReview,
                icon: const Icon(Icons.rate_review_outlined),
                label: const Text('Escribir reseña'),
              ),
            ],
          ),
          FutureBuilder<List<Resena>>(
            future: _reviewsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (snapshot.hasError) {
                return Text(
                  'No se pudieron cargar las reseñas: ${snapshot.error}',
                );
              }

              final reviews = snapshot.data ?? const <Resena>[];
              if (reviews.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    'Aún no hay reseñas. ¡Sé la primera persona en compartir tu opinión!',
                  ),
                );
              }

              return Column(
                children: reviews
                    .map(
                      (review) => Card(
                        margin: const EdgeInsets.only(top: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.person_outline),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      review.autor,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  ...List.generate(
                                    5,
                                    (index) => Icon(
                                      index < review.calificacion
                                          ? Icons.star
                                          : Icons.star_border,
                                      size: 18,
                                      color: Colors.amber,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(review.comentario),
                            ],
                          ),
                        ),
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _RecipeReview {
  const _RecipeReview({
    required this.author,
    required this.rating,
    required this.comment,
  });

  final String author;
  final int rating;
  final String comment;
}

class _RecipeReviewDialog extends StatefulWidget {
  const _RecipeReviewDialog();

  @override
  State<_RecipeReviewDialog> createState() => _RecipeReviewDialogState();
}

class _RecipeReviewDialogState extends State<_RecipeReviewDialog> {
  final _formKey = GlobalKey<FormState>();
  final _authorController = TextEditingController();
  final _commentController = TextEditingController();
  int _rating = 0;

  @override
  void dispose() {
    _authorController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  void _submitReview() {
    if (_rating == 0 || !_formKey.currentState!.validate()) return;

    Navigator.of(context).pop(
      _RecipeReview(
        author: _authorController.text.trim(),
        rating: _rating,
        comment: _commentController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      title: const Text('Escribir reseña'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('¿Cuántas estrellas le das a esta receta?'),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                5,
                (index) => IconButton(
                  tooltip:
                      '${index + 1} ${index == 0 ? 'estrella' : 'estrellas'}',
                  onPressed: () => setState(() => _rating = index + 1),
                  icon: Icon(
                    index < _rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                  ),
                ),
              ),
            ),
            TextFormField(
              controller: _authorController,
              decoration: const InputDecoration(
                labelText: 'Nombre del autor',
                hintText: '¿Quién escribe esta reseña?',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.words,
              maxLength: 50,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Escribe tu nombre para continuar';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _commentController,
              decoration: const InputDecoration(
                labelText: 'Tu comentario',
                hintText: '¿Qué te pareció esta receta?',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              minLines: 3,
              maxLines: 5,
              maxLength: 500,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Escribe un comentario para continuar';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _rating == 0 ? null : _submitReview,
          child: const Text('Publicar'),
        ),
      ],
    );
  }
}
