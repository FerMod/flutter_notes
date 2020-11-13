import 'dart:developer' as developer;

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../data/models.dart';
import '../menu/drawer_menu.dart';
import '../menu/loader.dart';
import 'edit_note.dart';

class NotesListScreen extends StatelessWidget {
  void _newNote(BuildContext context) async {
    final resultNote = await _navigateEditNote(context, Note());
    Provider.of<NotesListModel>(context, listen: false).updateNote(resultNote);
  }

  void _editNote(BuildContext context, Note note) async {
    final resultNote = await _navigateEditNote(context, note);
    Provider.of<NotesListModel>(context, listen: false).add(resultNote);
  }

  Future<Note> _navigateEditNote(BuildContext context, Note note) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditNoteScreen(note: note),
      ),
    );
    developer.log('Edit note result: $result');
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => NotesListModel()..load(),
      builder: (context, child) => Scaffold(
        appBar: AppBar(),
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
          tooltip: AppLocalizations.of(context).addNote,
          child: Icon(Icons.add),
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
    return ListView.builder(
      itemCount: notesList.notes.length,
      itemBuilder: (context, index) {
        return NoteWidget(
          note: notesList.notes[index],
          onTap: onTap,
        );
      },
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      elevation: 8,
      margin: EdgeInsets.all(4),
      child: InkWell(
        onTap: () => onTap(note),
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
    );
  }
}
