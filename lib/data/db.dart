import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'models.dart';

class DBProvider {
  String databaseName = 'database.db';

  static final DBProvider _instance = DBProvider._internal();
  static DBProvider get instance => _instance;

  // factory DBProvider({String databaseName = 'database.db'}) {
  //   instance.databaseName = databaseName;
  //   return instance;
  // }

  DBProvider._internal();

  static Database _database;
  Future<Database> get database async => _database ??= await initDB();

  Future<Database> initDB() async {
    var documentsDirectory = await getApplicationDocumentsDirectory();
    var path = join(documentsDirectory.path, databaseName);
    return await openDatabase(path, version: 1, onConfigure: _onConfigureHandler, onCreate: _onCreateHandler, onOpen: _onOpenHandler);
  }

  Future<void> _onConfigureHandler(Database db) async {
    if (kDebugMode) {
      await Sqflite.devSetDebugModeOn(true); // TODO: Implement logger
    }
    await db.execute("PRAGMA foreign_keys = ON");
  }

  Future<void> _onCreateHandler(Database db, int version) async {
    await _createTables(db);
  }

  Future<void> _onOpenHandler(Database db) async {
    if (kDebugMode) {
      await _insertData(db);
    }
  }

  Future<void> _createTables(Database db) async {
    developer.log('Create tables');

    await db.execute('''CREATE TABLE Quizzes (
      id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
      title TEXT,
      description TEXT
    )''');

    await db.execute('''CREATE TABLE Questions (
      id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
      quizId INTEGER NOT NULL,
      text TEXT,
      difficulty INTEGER,
      rating INTEGER,
      subject TEXT,
      image TEXT,
      FOREIGN KEY (quizId) REFERENCES Quizzes(id) ON DELETE CASCADE
    )''');

    await db.execute('''CREATE TABLE Options (
      id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
      questionId INTEGER NOT NULL,
      value TEXT,
      isCorrect BOOLEAN DEFAULT 0,
      FOREIGN KEY (questionId) REFERENCES Questions(id) ON DELETE CASCADE
    )''');
  }

  Future<void> _insertData(Database db) async {
    developer.log('Insert data');

    await db.insert('Quizzes', {'id': 1, 'title': 'Test quiz', 'description': 'Quiz containing test questions'}, conflictAlgorithm: ConflictAlgorithm.replace);

    await db.insert('Questions', {'id': 1, 'quizId': 1, 'text': 'Is this a question?', 'difficulty': 1, 'rating': 10, 'subject': 'Test', 'image': ''},
        conflictAlgorithm: ConflictAlgorithm.replace);
    await db.insert('Options', {'id': 1, 'questionId': 1, 'value': 'Yes', 'isCorrect': 1}, conflictAlgorithm: ConflictAlgorithm.replace);
    await db.insert('Options', {'id': 2, 'questionId': 1, 'value': 'No', 'isCorrect': 0}, conflictAlgorithm: ConflictAlgorithm.replace);

    await db.insert('Questions', {'id': 2, 'quizId': 1, 'text': 'Another question in the quiz.', 'difficulty': 4, 'rating': 7, 'subject': 'Test', 'image': ''},
        conflictAlgorithm: ConflictAlgorithm.replace);
    await db.insert('Options', {'id': 4, 'questionId': 2, 'value': 'Yes', 'isCorrect': 0}, conflictAlgorithm: ConflictAlgorithm.replace);
    await db.insert('Options', {'id': 5, 'questionId': 2, 'value': 'No', 'isCorrect': 1}, conflictAlgorithm: ConflictAlgorithm.replace);
    await db.insert('Options', {'id': 3, 'questionId': 2, 'value': 'Maybe', 'isCorrect': 0}, conflictAlgorithm: ConflictAlgorithm.replace);

    await db.insert('Questions', {'id': 3, 'quizId': 1, 'text': 'Test question?', 'difficulty': 10, 'rating': 1, 'subject': 'Test', 'image': ''},
        conflictAlgorithm: ConflictAlgorithm.replace);
    await db.insert('Options', {'id': 6, 'questionId': 3, 'value': 'It is', 'isCorrect': 1}, conflictAlgorithm: ConflictAlgorithm.replace);
    await db.insert('Options', {'id': 7, 'questionId': 3, 'value': 'Maybe', 'isCorrect': 0}, conflictAlgorithm: ConflictAlgorithm.replace);
    await db.insert('Options', {'id': 8, 'questionId': 3, 'value': 'Always', 'isCorrect': 0}, conflictAlgorithm: ConflictAlgorithm.replace);
    await db.insert('Options', {'id': 9, 'questionId': 3, 'value': 'It isn\'t', 'isCorrect': 0}, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> close() async => database.then((db) => db.close());

  Future<List<Question>> getAllQuestions() async {
    final db = await database;
    var questionsQuery = await db.query("Questions");
    var result = questionsQuery.map((row) => Question.fromMap(row)).toList();
    for (var question in result) {
      question.options = await getOptions(question.id);
    }
    return result;
  }

  Future<List<Quiz>> getAllQuizzes() async {
    final db = await database;
    var quizzesQuery = await db.query('Quizzes');
    var result = quizzesQuery.map((row) => Quiz.fromMap(row)).toList();
    for (var quiz in result) {
      quiz.questions = await getQuestions(quiz.id);
    }
    return result;
  }

  Future<Quiz> getQuiz(int quizId) async {
    final db = await database;
    var quizQuery = await db.query('Quizzes', where: 'id = ?', whereArgs: [quizId]);
    Quiz quiz;
    if (quizQuery.isNotEmpty) {
      quiz = Quiz.fromMap(quizQuery.first);
      quiz.questions = await getQuestions(quiz.id);
    }
    return quiz;
  }

  Future<List<Question>> getQuestions(int quizId) async {
    final db = await database;
    var questionsQuery = await db.query('Questions', where: 'quizId = ?', whereArgs: [quizId]);
    var result = questionsQuery.map((row) => Question.fromMap(row)).toList();
    for (var question in result) {
      question.options = await getOptions(question.id);
    }
    return result;
  }

  Future<List<Option>> getOptions(int questionId) async {
    final db = await database;
    final optionsQuery = await db.query('Options', where: 'questionId = ?', whereArgs: [questionId]);
    return optionsQuery.map((row) => Option(value: row['value'], isCorrect: row['isCorrect'] == 1)).toList();
  }

  // Future<int> insert(Product product) async {
  //   final db = await database;
  //   var maxIdResult = await db.rawQuery("SELECT MAX(id)+1 as last_inserted_id FROM Product");
  //   var id = maxIdResult.first["last_inserted_id"];
  //   var result = await db.rawInsert(
  //       "INSERT Into Product (id, name, description, price, image)"
  //       " VALUES (?, ?, ?, ?, ?)",
  //       [id, product.name, product.description, product.price, product.image]);
  //   return result;
  // }

  // Future<int> update(Product product) async {
  //   final db = await database;
  //   var result = await db.update("Product", product.toMap(), where: "id = ?", whereArgs: [product.id]);
  //   return result;
  // }

  // Future<int> delete(int id) async {
  //   final db = await database;
  //   var result = db.delete("Product", where: "id = ?", whereArgs: [id]);
  //   return result;
  // }

}
