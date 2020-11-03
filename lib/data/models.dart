import 'package:flutter/foundation.dart';

class Option {
  String value;
  bool isCorrect;

  Option({this.value, this.isCorrect = false});

  factory Option.fromMap(Map<String, dynamic> data) {
    return Option(
      value: data['value'] ?? '',
      isCorrect: data['isCorrect'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'value': value,
      'isCorrect': isCorrect,
    };
  }

  @override
  String toString() => '${objectRuntimeType(this, 'Option')}("$value", $isCorrect)';
}

class Question {
  int id;
  String text;
  // String image;
  int difficulty;
  int rating;
  String subject;
  List<Option> options;

  Question({this.id, this.text, this.difficulty, this.rating, this.subject, this.options});

  factory Question.fromMap(Map<String, dynamic> data) {
    return Question(
      id: data['id'] ?? 0,
      text: data['text'] ?? '',
      difficulty: data['difficulty'] ?? 0,
      rating: data['rating'] ?? 0,
      subject: data['subject'] ?? '',
      options: (data['options'] as List ?? []).map((v) => Option.fromMap(v)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'difficulty': difficulty,
      'rating': rating,
      'subject': subject,
      'options': options.map((e) => e.toJson()).toList(),
    };
  }

  @override
  String toString() => '${objectRuntimeType(this, 'Question')}($id, "$text", $difficulty, $rating, "$subject", $options)';
}

class Quiz {
  int id;
  String title;
  String description;
  List<Question> questions;

  Quiz({this.id, this.title, this.description, this.questions});

  factory Quiz.fromMap(Map<String, dynamic> data) {
    return Quiz(
      id: data['id'] ?? 0,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      questions: (data['questions'] as List ?? []).map((v) => Question.fromMap(v)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'questions': questions.map((e) => e.toJson()).toList(),
    };
  }

  @override
  String toString() {
    return '${objectRuntimeType(this, 'Quiz')}($id, "$title", "$description", $questions}';
  }
}

/*
// Question fields //
id
email
statement
options -> ( option1 , option2, ...)
complexity
subject
img
rating

// Options fields //
value
isCorrect
*/
