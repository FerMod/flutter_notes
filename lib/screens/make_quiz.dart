import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../data/db.dart';
import '../data/models.dart';
import '../menu/loader.dart';

// ignore: prefer_mixin
class QuizState with ChangeNotifier {
  double _progress = 0;
  Option _selected;

  final PageController controller = PageController();

  double get progress => _progress;
  Option get selected => _selected;

  set progress(double newValue) {
    _progress = newValue;
    notifyListeners();
  }

  set selected(Option newValue) {
    _selected = newValue;
    notifyListeners();
  }

  void nextPage() async {
    await controller.nextPage(
      duration: Duration(milliseconds: 500),
      curve: Curves.easeOut,
    );
  }
}

class MakeQuiz extends StatelessWidget {
  MakeQuiz({this.quizId});
  final int quizId;

  Future<Quiz> _fetchQuiz() async {
    final _db = DBProvider.instance;
    return await _db.getQuiz(quizId);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => QuizState(),
      child: FutureBuilder(
        future: _fetchQuiz(),
        builder: (context, snapshot) {
          var state = Provider.of<QuizState>(context);

          if (!snapshot.hasData || snapshot.hasError) {
            return LoadingScreen();
          }

          Quiz quiz = snapshot.data;
          return Scaffold(
            appBar: AppBar(
              title: Text(quiz.title),
            ),
            body: PageView.builder(
              physics: NeverScrollableScrollPhysics(),
              controller: state.controller,
              onPageChanged: (index) => state.progress = (index / (quiz.questions.length + 1)),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return StartPage(quiz: quiz);
                } else if (index == quiz.questions.length + 1) {
                  return CongratsPage(quiz: quiz);
                } else {
                  return QuestionPage(question: quiz.questions[index - 1]);
                }
              },
            ),
          );
        },
      ),
    );
  }
}

class StartPage extends StatelessWidget {
  final Quiz quiz;
  final PageController controller;
  StartPage({this.quiz, this.controller});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    var state = Provider.of<QuizState>(context);

    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(quiz.title, style: Theme.of(context).textTheme.headline5),
          Divider(),
          Expanded(child: Text(quiz.description)),
          ButtonBar(
            alignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: state.nextPage,
                label: Text(localizations.startQuiz),
                icon: Icon(Icons.poll),
                style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(Colors.green)),
              )
            ],
          )
        ],
      ),
    );
  }
}

class CongratsPage extends StatelessWidget {
  final Quiz quiz;
  CongratsPage({this.quiz});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Padding(
      padding: EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            localizations.congratsQuiz(quiz.title),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class QuestionPage extends StatelessWidget {
  final Question question;
  QuestionPage({this.question});

  @override
  Widget build(BuildContext context) {
    var state = Provider.of<QuizState>(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(
          child: Container(
            alignment: Alignment.center,
            child: Text(question.text, style: Theme.of(context).textTheme.headline6),
          ),
        ),
        Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: question.options.map((option) => _createOptionWidget(context, option, state)).toList(),
          ),
        )
      ],
    );
  }

  Widget _createOptionWidget(BuildContext context, Option option, QuizState state) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      color: Colors.black26,
      child: InkWell(
        onTap: () {
          state.selected = option;
          _bottomSheet(context, option, state);
        },
        child: Container(
          padding: EdgeInsets.all(16),
          child: Scrollbar(
            child: Row(
              children: [
                Icon(state.selected == option ? Icons.check_circle : Icons.circle, size: 30),
                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(left: 16),
                    child: Text(
                      option.value,
                      style: Theme.of(context).textTheme.bodyText2,
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Bottom sheet shown when Question is answered
  void _bottomSheet(BuildContext context, Option option, QuizState state) {
    final localizations = AppLocalizations.of(context);
    var isCorrect = option.isCorrect;

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          height: 250,
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(isCorrect ? localizations.goodJob : localizations.wrong),
              ElevatedButton(
                style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(isCorrect ? Colors.green : Colors.red)),
                child: Text(
                  isCorrect ? localizations.onward : localizations.tryAgain,
                  style: TextStyle(
                    color: Colors.white,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () {
                  if (isCorrect) {
                    state.nextPage();
                  }
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
