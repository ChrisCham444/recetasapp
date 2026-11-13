import 'dart:convert';
import 'package:recetasapp/models/receta.dart';
import 'package:http/http.dart' as http;

class RecipeService {
  static const String _baseUrl = 'https://dummyjson.com/recipes';

  Future<List<Receta>> obtenerRecetas() async {
    final url = Uri.parse(_baseUrl);
    final respuesta = await http.get(url);

    if (respuesta.statusCode == 200) {
      final Map<String, dynamic> datos = jsonDecode(respuesta.body);
      final List<dynamic> listarecetas = datos['recipes'];

      return listarecetas
          .map((recipeJson) => Receta.fromJson(recipeJson))
          .toList();
    } else {
      throw Exception('Error al obtener las recetas: ${respuesta.statusCode}');
    }
  }
}