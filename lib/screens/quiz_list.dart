import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../data/db.dart';
import '../data/models.dart';
import '../menu/drawer_menu.dart';
import '../menu/loader.dart';
import 'make_quiz.dart';

class QuizzesList extends StatelessWidget {
  QuizzesList({Key key});

  Future<List<Quiz>> _fetchQuizzes() async {
    final _db = DBProvider.instance;
    return await _db.getAllQuizzes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
      ),
      drawer: DrawerMenu(),
      body: FutureBuilder(
        future: _fetchQuizzes(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.hasError) {
            return LoadingScreen();
          }

          List<Quiz> quizzes = snapshot.data;
          return Column(
            children: quizzes.map((quiz) => _createQuizCard(context, quiz)).toList(),
          );
        },
      ),
    );
  }

  Card _createQuizCard(BuildContext context, Quiz quiz) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      elevation: 4,
      margin: EdgeInsets.all(4),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => MakeQuiz(quizId: quiz.id),
            ),
          );
        },
        child: Container(
          padding: EdgeInsets.all(8),
          child: ListTile(
              title: Text(
                quiz.title,
                style: Theme.of(context).textTheme.headline6,
              ),
              subtitle: Text(
                quiz.description,
                overflow: TextOverflow.fade,
                style: Theme.of(context).textTheme.subtitle1,
              )),
        ),
      ),
    );
  }
}
