import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../data/db.dart';
import '../data/models.dart';
import '../menu/drawer_menu.dart';
import '../menu/loader.dart';
import 'make_quiz.dart';

class NotesList extends StatelessWidget {
  NotesList({Key key}) : super(key: key);

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
            children: quizzes.map((quiz) => _createCard(context, quiz)).toList(),
          );
        },
      ),
    );
  }

  Card _createCard(BuildContext context, Quiz quiz) {
    return Card(
      //shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      //elevation: 4,
      //margin: EdgeInsets.all(4),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => MakeQuiz(quizId: quiz.id),
            ),
          );
        },
        child: Column(
          children: [
            ListTile(
              // leading: Icon(Icons.note),
              title: const Text('Card title 2'),
              subtitle: Text(
                'Secondary Text',
                style: TextStyle(color: Colors.black.withOpacity(0.6)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Greyhound divisively hello coldly wonderfully marginally far upon excluding.',
                style: TextStyle(color: Colors.black.withOpacity(0.6)),
              ),
            ),
            ButtonBar(
              alignment: MainAxisAlignment.start,
              children: [
                FlatButton(
                  textColor: const Color(0xFF6200EE),
                  onPressed: () {
                    // Perform some action
                  },
                  child: const Text('ACTION 1'),
                ),
                FlatButton(
                  textColor: const Color(0xFF6200EE),
                  onPressed: () {
                    // Perform some action
                  },
                  child: const Text('ACTION 2'),
                ),
              ],
            ),
            //Image.asset('assets/card-sample-image-2.jpg'),
          ],
        ),
      ),
    );
  }
}
