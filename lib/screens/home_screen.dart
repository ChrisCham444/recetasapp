import 'package:flutter/material.dart';
import 'package:recetasapp/models/receta.dart';
import 'package:recetasapp/services/recipes_service.dart';
import 'package:recetasapp/widgets/receta_card.dart';
import 'package:recetasapp/screens/detalle_receta_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final RecipeService _recipeService = RecipeService();
  late Future<List<Receta>> _futureRecetas;

  @override
  void initState() {
    super.initState();
    _futureRecetas = _recipeService.obtenerRecetas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recetas del Rayah'),
        backgroundColor: const Color.fromARGB(255, 4, 153, 143),
      ),
      body: FutureBuilder<List<Receta>>(
        future: _futureRecetas,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final recetas = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: recetas.length,
            itemBuilder: (context, index) {
              return RecetaCard(
                receta: recetas[index],
                onTap: () async {
                  await Navigator.push<void>(
                    context,
                    MaterialPageRoute<void>(
                      builder: (context) =>
                          DetalleRecetaScreen(receta: recetas[index]),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
