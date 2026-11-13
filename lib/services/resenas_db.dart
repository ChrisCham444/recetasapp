import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/resena.dart';

class ResenasDb {
  ResenasDb._({this._databaseFactory, this._directorio});

  static final ResenasDb instancia = ResenasDb._();
  static const _nombreArchivo = 'misresenas.db';
  static const _tabla = 'resenas';

  final DatabaseFactory? _databaseFactory;
  final String? _directorio;
  Future<Database>? _dbFuture;

  ResenasDb.testing({
    required DatabaseFactory databaseFactory,
    required String directorio,
  }) : this._(databaseFactory: databaseFactory, directorio: directorio);

  Future<Database> get dbAsync => _dbFuture ??= _abrir();

  Future<Database> _abrir() async {
    final factory = _databaseFactory ?? databaseFactory;
    final directorio = _directorio ?? await getDatabasesPath();
    final ruta = join(directorio, _nombreArchivo);

    return factory.openDatabase(
      ruta,
      options: OpenDatabaseOptions(
        version: 2,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE $_tabla (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              receta_id INTEGER NOT NULL,
              autor TEXT NOT NULL,
              calificacion INTEGER NOT NULL
                CHECK (calificacion >= 1 AND calificacion <= 5),
              comentario TEXT NOT NULL,
              fecha_creacion TEXT NOT NULL
            )
          ''');
          await db.execute(
            'CREATE INDEX idx_resenas_receta_id ON $_tabla (receta_id)',
          );
        },
        onUpgrade: (db, oldVersion, newVersion) async {
          if (oldVersion < 2) {
            await _agregarAutorSiFalta(db);
          }
        },
        onOpen: _agregarAutorSiFalta,
      ),
    );
  }

  Future<void> _agregarAutorSiFalta(Database db) async {
    final columnas = await db.rawQuery('PRAGMA table_info($_tabla)');
    if (columnas.any((columna) => columna['name'] == 'autor')) return;

    await db.execute(
      "ALTER TABLE $_tabla ADD COLUMN autor TEXT NOT NULL DEFAULT 'Anónimo'",
    );
  }

  Future<int> insertarResena(Resena resena) async {
    final db = await dbAsync;
    return db.insert(_tabla, resena.toMap());
  }

  Future<List<Resena>> obtenerPorReceta(int recetaId) async {
    final db = await dbAsync;
    final filas = await db.query(
      _tabla,
      where: 'receta_id = ?',
      whereArgs: [recetaId],
      orderBy: 'fecha_creacion DESC, id DESC',
    );
    return filas.map(Resena.fromMap).toList();
  }

  Future<int> actualizarResena(Resena resena) async {
    if (resena.id == null) {
      throw ArgumentError('La reseña debe tener un id para actualizarse.');
    }

    final db = await dbAsync;
    return db.update(
      _tabla,
      resena.toMap(),
      where: 'id = ?',
      whereArgs: [resena.id],
    );
  }

  Future<int> eliminarResena(int id) async {
    final db = await dbAsync;
    return db.delete(_tabla, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> cerrar() async {
    final dbFuture = _dbFuture;
    if (dbFuture == null) return;
    final db = await dbFuture;
    await db.close();
    _dbFuture = null;
  }
}
