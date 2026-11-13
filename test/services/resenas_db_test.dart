import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:recetasapp/models/resena.dart';
import 'package:recetasapp/services/resenas_db.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late Directory directorio;
  late ResenasDb resenasDb;

  setUpAll(sqfliteFfiInit);

  setUp(() async {
    directorio = await Directory.systemTemp.createTemp('resenas_db_test_');
    resenasDb = ResenasDb.testing(
      databaseFactory: databaseFactoryFfi,
      directorio: directorio.path,
    );
  });

  tearDown(() async {
    await resenasDb.cerrar();
    await directorio.delete(recursive: true);
  });

  test('guarda y consulta reseñas asociadas a cada receta', () async {
    final fecha = DateTime.utc(2026, 11, 13);
    final id = await resenasDb.insertarResena(
      Resena(
        recetaId: 42,
        autor: 'Ana',
        calificacion: 5,
        comentario: 'Muy rica',
        fechaCreacion: fecha,
      ),
    );
    await resenasDb.insertarResena(
      Resena(
        recetaId: 7,
        autor: 'Luis',
        calificacion: 3,
        comentario: 'Buena',
        fechaCreacion: fecha,
      ),
    );

    await resenasDb.cerrar();
    resenasDb = ResenasDb.testing(
      databaseFactory: databaseFactoryFfi,
      directorio: directorio.path,
    );
    final resenas = await resenasDb.obtenerPorReceta(42);

    expect(resenas, hasLength(1));
    expect(resenas.single.id, id);
    expect(resenas.single.autor, 'Ana');
    expect(resenas.single.calificacion, 5);
    expect(resenas.single.comentario, 'Muy rica');
    expect(resenas.single.fechaCreacion, fecha);

    final actualizadas = await resenasDb.actualizarResena(
      Resena(
        id: id,
        recetaId: 42,
        autor: 'Ana',
        calificacion: 4,
        comentario: 'Sigue siendo muy rica',
        fechaCreacion: fecha,
      ),
    );
    expect(actualizadas, 1);
    expect((await resenasDb.obtenerPorReceta(42)).single.calificacion, 4);

    expect(await resenasDb.eliminarResena(id), 1);
    expect(await resenasDb.obtenerPorReceta(42), isEmpty);
    expect(await resenasDb.obtenerPorReceta(7), hasLength(1));
  });

  test('migra reseñas antiguas y les asigna un autor predeterminado', () async {
    final oldDatabase = await databaseFactoryFfi.openDatabase(
      path.join(directorio.path, 'misresenas.db'),
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE resenas (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              receta_id INTEGER NOT NULL,
              calificacion INTEGER NOT NULL,
              comentario TEXT NOT NULL,
              fecha_creacion TEXT NOT NULL
            )
          ''');
        },
      ),
    );
    await oldDatabase.insert('resenas', {
      'receta_id': 42,
      'calificacion': 5,
      'comentario': 'Muy rica',
      'fecha_creacion': DateTime.utc(2026, 11, 13).toIso8601String(),
    });
    await oldDatabase.close();

    final resenas = await resenasDb.obtenerPorReceta(42);

    expect(resenas, hasLength(1));
    expect(resenas.single.autor, 'Anónimo');
    expect(resenas.single.comentario, 'Muy rica');
  });

  test(
    'repara la columna autor si falta aunque la base ya sea versión 2',
    () async {
      final oldDatabase = await databaseFactoryFfi.openDatabase(
        path.join(directorio.path, 'misresenas.db'),
        options: OpenDatabaseOptions(
          version: 2,
          onCreate: (db, version) async {
            await db.execute('''
            CREATE TABLE resenas (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              receta_id INTEGER NOT NULL,
              calificacion INTEGER NOT NULL,
              comentario TEXT NOT NULL,
              fecha_creacion TEXT NOT NULL
            )
          ''');
          },
        ),
      );
      await oldDatabase.insert('resenas', {
        'receta_id': 42,
        'calificacion': 5,
        'comentario': 'Muy rica',
        'fecha_creacion': DateTime.utc(2026, 11, 13).toIso8601String(),
      });
      await oldDatabase.close();

      final resenas = await resenasDb.obtenerPorReceta(42);

      expect(resenas, hasLength(1));
      expect(resenas.single.autor, 'Anónimo');
      expect(
        await resenasDb.insertarResena(
          Resena(
            recetaId: 42,
            autor: 'Ana',
            calificacion: 4,
            comentario: 'También muy rica',
            fechaCreacion: DateTime.utc(2026, 11, 14),
          ),
        ),
        greaterThan(0),
      );
    },
  );
}
