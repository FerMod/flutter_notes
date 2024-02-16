import 'dart:developer' as developer;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';

import '../data/data_provider.dart';
import '../data/firebase/firebase_service.dart';
import '../data/models.dart';
import '../data/models/note_model.dart';
import '../routes.dart';
import '../widgets/card_hero.dart';
import '../widgets/drawer_menu.dart';
import '../widgets/loader.dart';
import '../widgets/user_account_tile.dart';
import '../widgets/user_avatar.dart';
import 'edit_note.dart';
import 'settings.dart';

enum MenuAction {
  // share,
  delete,
}

class NotesListScreen extends StatelessWidget {
  NotesListScreen({super.key});

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

  Future<void> _newNote(BuildContext context, String userId) async {
    final note = NoteModel(userId: userId);
    final resultNote = await _navigateEditNote(context, note);

    if (resultNote != null && (resultNote.title.isNotEmpty || resultNote.content.isNotEmpty)) {
      notesListModel.addNote(resultNote);
    }
  }

  Future<void> _editNote(BuildContext context, NoteModel note) async {
    final lastEdit = note.lastEdit;
    final resultNote = await _navigateEditNote(context, note);

    if (resultNote != null && lastEdit.isBefore(resultNote.lastEdit)) {
      notesListModel.updateNote(resultNote);
    }
  }

  Future<void> _removeNote(BuildContext context, NoteModel note) async {
    final shouldRemove = await _showAlertDialog(context);
    if (shouldRemove) notesListModel.removeNote(note);
  }

  Future<bool> _showAlertDialog(BuildContext context) async {
    final dialogResult = await showDialog<bool>(
      context: context,
      builder: (context) => const _DeleteAlertDialog(),
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
                  Navigator.pushReplacementNamed(context, AppRoute.signIn);
                },
          userData: notesListModel.userData,
        ),
        titleSpacing: 0.0,
        actions: const [
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
          onPressed: () => _newNote(context, userData.currentUser!.uid),
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
    super.key,
    required this.userData,
    this.onTap,
    this.onTapImage,
  });

  final UserData userData;
  final VoidCallback? onTap;
  final VoidCallback? onTapImage;

  @override
  Widget build(BuildContext context) {
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
      final localizations = AppLocalizations.of(context)!;
      imageWidget = const Icon(
        Icons.account_circle,
        size: UserAvatar.defaultRadius * 2.0,
      );
      nameWidget = Text(localizations.signIn);
    }

    return UserAccountTile(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      image: imageWidget,
      imageSize: const Size.fromRadius(UserAvatar.defaultRadius),
      title: nameWidget,
      subtitle: emailWidget,
      onTap: onTap,
    );
  }
}

class _DeleteAlertDialog extends StatelessWidget {
  const _DeleteAlertDialog({super.key});

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
    super.key,
    required List<NoteModel>? notes,
    this.onTap,
    this.onMenuTap,
    this.onRefresh,
    this.controller,
  })  : notes = notes ?? const [];

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
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
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

  /// Returns true if the [date] is from a day ago.
  bool _isFromDayAgo(DateTime date) {
    final now = DateTime.now();
    final dayAgo = now.subtract(const Duration(days: 1));
    return !dayAgo.difference(date).isNegative;
  }

  /// Returns a string that represents the [date] formatted in a format
  /// according to the given [localeName].
  ///
  /// When the date is from less than a day, the returned value is shortened and
  /// only returns the time of the date. Otherwise, if the date is from more
  /// than a day, the returned value is the full date with the time.
  String _formatDate(String localeName, DateTime date) {
    final DateFormat dateFormat;
    if (_isFromDayAgo(date)) {
      dateFormat = DateFormat.yMd(localeName).add_Hm();
    } else {
      dateFormat = DateFormat.Hm(localeName);
    }
    return dateFormat.format(date);
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scrollbar(
      controller: controller,
      trackVisibility: true,
      radius: Radius.zero,
      child: ListView.builder(
        controller: controller,
        dragStartBehavior: DragStartBehavior.down,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: listBottomPadding), // Prevent FAB from blocking ListTiles
        itemCount: notes.length,
        itemBuilder: (context, index) {
          final note = notes[index];

          Widget? titleWidget;
          if (note.title.isNotEmpty) {
            titleWidget = Text(
              note.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            );
          }

          Widget? contentWidget;
          if (note.content.isNotEmpty) {
            contentWidget = Text(
              note.content,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            );
          }

          return CardHero(
            tag: 'note-${note.id}',
            color: note.color,
            onTap: () => onTap?.call(note),
            onLongPress: () => developer.log('Long press'),
            child: Stack(
              alignment: AlignmentDirectional.topEnd,
              children: [
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Text(
                    _formatDate(localizations.localeName, note.lastEdit),
                    style: theme.textTheme.bodySmall,
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ListTile(
                        contentPadding: const EdgeInsets.only(left: 16.0),
                        mouseCursor: MouseCursor.defer, // Defer the cursor choice to widgets behind
                        title: titleWidget,
                        subtitle: contentWidget,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: PopupMenuButton<MenuAction>(
                        itemBuilder: (context) => [
                          _buildPopMenuItem(MenuAction.delete, localizations.delete, const Icon(Icons.delete)),
                        ],
                        onSelected: (value) => onMenuTap?.call(note, value),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
