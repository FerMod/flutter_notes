import 'dart:developer' as developer;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../data/firebase_service.dart';
import '../data/models.dart';
import '../menu/card_hero.dart';
import '../menu/drawer_menu.dart';
import '../menu/loader.dart';
import 'edit_note.dart';

enum Operation {
  insert,
  update,
  delete,
}

class NotesListScreen extends StatelessWidget {
  const NotesListScreen({Key key}) : super(key: key);

  PageRoute _pageRouteBuilder(Widget widget) {
    // return MaterialPageRoute(builder: (context) => widget);
    // return PageRouteBuilder(
    //   pageBuilder: (context, animation, secondaryAnimation) => widget,
    // );
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) {
        return AnimatedBuilder(
          animation: animation,
          child: widget,
          builder: (context, child) {
            return FadeTransition(
              opacity: animation.drive(
                CurveTween(curve: Curves.easeInOut),
              ),
              child: child,
            );
          },
        );
      },
      transitionDuration: Duration(milliseconds: 400),
      reverseTransitionDuration: Duration(milliseconds: 400),
    );
  }

  Future<NoteModel> _navigateEditNote(BuildContext context, NoteModel note) async {
    final result = await Navigator.push(
      context,
      _pageRouteBuilder(EditNoteScreen(note: note)),
    );
    developer.log('Edit note result: $result');
    return result;
  }

  void _newNote(BuildContext context) async {
    final user = Provider.of<User>(context, listen: false);
    final note = NoteModel(userId: user?.uid);
    final resultNote = await _navigateEditNote(context, note);
    if (resultNote == null) return;

    final notesListModel = Provider.of<NotesListModel>(context, listen: false);
    notesListModel.addNote(resultNote);
  }

  void _editNote(BuildContext context, NoteModel note) async {
    final resultNote = await _navigateEditNote(context, note);
    if (resultNote == null) return;

    final notesListModel = Provider.of<NotesListModel>(context, listen: false);
    notesListModel.updateNote(resultNote);
  }

  void _removeNote(BuildContext context, NoteModel note) async {
    final resultNote = await _navigateEditNote(context, note);
    if (resultNote == null) return;

    final notesListModel = Provider.of<NotesListModel>(context, listen: false);
    notesListModel.removeNote(resultNote);
  }

  Future<T> _showAlertDialog<T>(BuildContext context) async {
    final localizations = AppLocalizations.of(context);
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Alert Dialog"),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                Text("Would you like to continue learning how to use Flutter alerts?"),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text("Cancel"),
              onPressed: () {},
            ),
            TextButton(
              child: Text("Continue"),
              onPressed: () {},
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return ChangeNotifierProvider(
      create: (context) => NotesListModel()..loadDelayed(), //loadData(),
      builder: (context, child) => Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              tooltip: localizations.settings,
              onPressed: () {
                //ScaffoldMessenger.of(context).showSnackBar(snackBar);
              },
            ),
          ],
        ),
        drawer: DrawerMenu(),
        body: Selector<NotesListModel, bool>(
          selector: (context, model) => model.isLoading,
          builder: (context, isLoading, child) {
            if (isLoading) {
              return Loader();
            }
            return NoteListWidget(
              onTap: (note) => _editNote(context, note),
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _newNote(context),
          tooltip: localizations.addNote,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

class NoteListWidget extends StatelessWidget {
  final void Function(NoteModel) onTap;
  const NoteListWidget({Key key, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final notesList = Provider.of<NotesListModel>(context);
    return RefreshIndicator(
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: notesList.notes.length,
        itemBuilder: (context, index) {
          final note = notesList.notes[index];
          return CardHero(
            tag: 'note-${note.id}',
            color: note.color,
            onTap: () => onTap(note),
            onLongPress: () => developer.log("Long press"),
            child: Column(
              children: [
                ListTile(
                  mouseCursor: MouseCursor.defer,
                  title: Text(note.title),
                  subtitle: Text(
                    note.content,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        },
      ),
      onRefresh: notesList.refresh, // refreshDelayed,
    );
  }
}
