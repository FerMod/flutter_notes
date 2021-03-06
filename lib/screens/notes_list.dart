import 'dart:developer' as developer;

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../data/firebase_service.dart';
import '../data/models.dart';
import '../data/models/note_model.dart';
import '../widgets/card_hero.dart';
import '../widgets/drawer_menu.dart';
import '../widgets/loader.dart';
import '../widgets/user_account.dart';
import 'edit_note.dart';
import 'settings.dart';
import 'sign_in.dart';

enum MenuAction {
  // share,
  delete,
}

class NotesListScreen extends StatelessWidget {
  NotesListScreen({Key? key}) : super(key: key);

  final NotesListModel notesListModel = NotesListModel();

  Future<NoteModel?> _navigateEditNote(BuildContext context, NoteModel note) async {
    final result = await Navigator.push<NoteModel>(
      context,
      NoteRouteBuilder(
        builder: (context) {
          return EditNoteScreen(note: note);
        },
      ),
    );
    developer.log('Edit note result: $result');
    return result;
  }

  void _navigate(BuildContext context, Widget widget) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => widget,
      ),
    );
  }

  void _newNote(BuildContext context) async {
    final user = notesListModel.userData.currentUser;
    final note = NoteModel(userId: user?.uid);

    final resultNote = await _navigateEditNote(context, note);
    if (resultNote == null) return;

    if (resultNote.title.isNotEmpty || resultNote.content.isNotEmpty) {
      notesListModel.addNote(resultNote);
    }
  }

  void _editNote(BuildContext context, NoteModel note) async {
    final lastEdit = note.lastEdit;
    final resultNote = await _navigateEditNote(context, note);
    if (resultNote == null) return;

    if (lastEdit.isBefore(resultNote.lastEdit)) {
      notesListModel.updateNote(resultNote);
    }
  }

  void _removeNote(BuildContext context, NoteModel note) async {
    final shouldRemove = await _showAlertDialog(context);
    if (shouldRemove) notesListModel.removeNote(note);
  }

  Future<bool> _showAlertDialog(BuildContext context) async {
    final dialogResult = await showDialog<bool>(
      context: context,
      builder: (context) => _DeleteAlertDialog(),
    );
    return dialogResult ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final userData = DataProvider.userData;

    return Scaffold(
      appBar: AppBar(
        title: _AccountWidget(
          onTap: userData.isSignedIn && !userData.currentUser!.isAnonymous
              ? null
              : () {
                  _navigate(context, SignInScreen());
                },
          userData: notesListModel.userData,
        ),
        titleSpacing: 0.0,
        actions: [
          SettingsScreenButton(),
        ],
      ),
      drawer: DrawerMenu(),
      body: StreamBuilder<List<NoteModel>>(
        initialData: notesListModel.notes,
        stream: notesListModel.streamData(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            developer.log('Snapshot Error: ${snapshot.error}');
          }
          developer.log('ConnectionState: ${snapshot.connectionState}');
          switch (snapshot.connectionState) {
            case ConnectionState.active:
            case ConnectionState.done:
              return NoteListWidget(
                notes: snapshot.data,
                onTap: (note) => _editNote(context, note),
                onMenuTap: (note, action) => _removeNote(context, note),
              );
            case ConnectionState.waiting:
              return const LinearProgressIndicator();
            case ConnectionState.none:
            default:
              return const Loader();
          }
        },
      ),
      floatingActionButton: Visibility(
        visible: userData.isSignedIn,
        child: FloatingActionButton(
          onPressed: () => _newNote(context),
          tooltip: localizations.addNote,
          heroTag: 'note-new',
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

class _AccountWidget extends StatelessWidget {
  const _AccountWidget({
    Key? key,
    required this.userData,
    this.onTap,
    this.onTapImage,
  }) : super(key: key);

  final UserData userData;
  final VoidCallback? onTap;
  final VoidCallback? onTapImage;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final user = userData.currentUser;

    Widget? imageWidget;
    Widget? nameWidget;
    Widget? emailWidget;
    if (user != null && !user.isAnonymous) {
      final displayName = user.displayName;
      final email = user.email;

      if (displayName != null && displayName.isNotEmpty) {
        nameWidget = Text(displayName);
      }

      if (email != null && email.isNotEmpty) {
        emailWidget = Text(email);
      }

      imageWidget = UserAvatar(
        imageUrl: user.photoURL,
        nameText: displayName,
        onTap: onTapImage,
      );
    } else {
      imageWidget = const Icon(
        Icons.account_circle,
        size: UserAvatar.alternativeImageIconSize,
      );
      nameWidget = Text(localizations!.signIn);
    }

    return FutureBuilder(
      future: userData.data(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Loader();
        }
        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: imageWidget,
          title: nameWidget,
          subtitle: emailWidget,
          onTap: onTap,
        );
      },
    );
  }
}

class _DeleteAlertDialog extends StatelessWidget {
  const _DeleteAlertDialog({Key? key}) : super(key: key);

  TextButton _createButton(BuildContext context, String text, bool result) {
    return TextButton(
      onPressed: () => Navigator.of(context, rootNavigator: true).pop(result),
      child: Text(text),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(localizations.deleteDialogTitle),
      content: SingleChildScrollView(
        child: ListBody(
          children: [
            Text(localizations.deleteDialogContent),
          ],
        ),
      ),
      actions: [
        _createButton(context, localizations.cancelButton, false),
        _createButton(context, localizations.deleteButton, true),
      ],
    );
  }
}

class NoteListWidget extends StatelessWidget {
  const NoteListWidget({
    Key? key,
    required List<NoteModel>? notes,
    this.onTap,
    this.onMenuTap,
    this.onRefresh,
    this.controller,
  })  : notes = notes ?? const [],
        super(key: key);

  final List<NoteModel> notes;
  final void Function(NoteModel)? onTap;
  final void Function(NoteModel, MenuAction action)? onMenuTap;
  final Future<void> Function()? onRefresh;

  /// An object that can be used to control the position to which this scroll
  /// view is scrolled.
  final ScrollController? controller;

  /// Padding that prevents the FloatingActionButton from blocking ListTiles.
  static const double listBottomPadding = kFloatingActionButtonMargin * 2.0 + 48.0;

  PopupMenuItem<MenuAction> _buildPopMenuItem(MenuAction action, String text, Icon icon) {
    return PopupMenuItem<MenuAction>(
      value: action,
      child: ListTile(
        leading: icon,
        title: Text(text),
        dense: true,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        contentPadding: EdgeInsets.zero,
        mouseCursor: MouseCursor.defer,
        //horizontalTitleGap: 0.0,
        minVerticalPadding: 0.0,
        minLeadingWidth: 0.0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Scrollbar(
      controller: controller,
      showTrackOnHover: true,
      radius: Radius.zero,
      child: ListView.builder(
        controller: controller,
        dragStartBehavior: DragStartBehavior.down,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: listBottomPadding), // Prevent FAB from blocking ListTiles
        itemCount: notes.length,
        itemBuilder: (context, index) {
          final note = notes[index];
          return CardHero(
            tag: 'note-${note.id}',
            color: note.color,
            onTap: () => onTap?.call(note),
            onLongPress: () => developer.log('Long press'),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ListTile(
                    // contentPadding: EdgeInsets.symmetric(horizontal: 8.0),
                    mouseCursor: MouseCursor.defer, // Defer the cursor choice to widgets behind
                    title: Text(note.title),
                    subtitle: Text(
                      note.content,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                PopupMenuButton<MenuAction>(
                  itemBuilder: (context) => [
                    _buildPopMenuItem(MenuAction.delete, localizations!.delete, const Icon(Icons.delete)),
                  ],
                  onSelected: (value) => onMenuTap!(note, value),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class NoteRouteBuilder<T> extends PageRouteBuilder<T> {
  NoteRouteBuilder({
    required this.builder,
    RouteSettings? settings,
    Duration transitionDuration = const Duration(milliseconds: 400),
    Duration reverseTransitionDuration = const Duration(milliseconds: 400),
    bool maintainState = true,
    bool fullscreenDialog = true,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) {
            return builder(context);
          },
          settings: settings,
          transitionDuration: transitionDuration,
          reverseTransitionDuration: reverseTransitionDuration,
          maintainState: maintainState,
          fullscreenDialog: fullscreenDialog,
        ) {
    assert(opaque);
  }

  final WidgetBuilder builder;

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
    var curve = Curves.easeInOut;
    var tween = CurveTween(curve: curve);
    return FadeTransition(
      opacity: animation.drive(tween),
      child: child,
    );
  }
}
