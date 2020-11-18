import 'dart:developer' as developer;

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_notes/menu/fade_page_route.dart';
import 'package:provider/provider.dart';

import '../data/models.dart';
import '../menu/card_hero.dart';
import '../menu/drawer_menu.dart';
import '../menu/loader.dart';
import 'edit_note.dart';

class NotesListScreen extends StatelessWidget {
  const NotesListScreen({Key key}) : super(key: key);

  void _newNote(BuildContext context) async {
    final resultNote = await _navigateEditNote(context, Note());
    if (resultNote != null) {
      Provider.of<NotesListModel>(context, listen: false).addNote(resultNote);
    }
  }

  void _editNote(BuildContext context, Note note) async {
    final resultNote = await _navigateEditNote(context, note);
    if (resultNote != null) {
      Provider.of<NotesListModel>(context, listen: false).updateNote(resultNote);
    }
  }

  PageRoute _pageRoutBuilder(Widget widget) {
    // return FadePageRoute(builder: (context) => widget);
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

  Future<Note> _navigateEditNote(BuildContext context, Note note) async {
    final result = await Navigator.push(
      context,
      _pageRoutBuilder(EditNoteScreen(note: note)),
    );
    developer.log('Edit note result: $result');
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return ChangeNotifierProvider(
      create: (context) => NotesListModel()..loadDelayed(),
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
  final void Function(Note) onTap;
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
          return Hero(
            tag: 'note-${note.id}',
            child: NoteWidget(
              note: note,
              onTap: onTap,
            ),
          );
        },
      ),
      onRefresh: notesList.refreshDelayed,
    );
  }
}

class NoteWidget extends StatelessWidget {
  final Note note;
  final void Function(Note) onTap;
  // final void Function() onRemove;
  const NoteWidget({Key key, this.note, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4.0),
      ),
      elevation: 8,
      margin: EdgeInsets.all(4),
      child: InkWell(
        onTap: () => onTap(note),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: note.color, width: 4),
            ),
          ),
          child: Column(
            children: [
              ListTile(
                // leading: Icon(Icons.note),
                title: Text(note.title),
                subtitle: Text(
                  note.content,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
