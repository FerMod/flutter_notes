import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../data/models/note_model.dart';
import '../src/cache/cached_color.dart';
import '../src/restorable_state.dart';
import '../widgets/card_hero.dart';
import '../widgets/color_toggle_buttons.dart';

enum ChangesAction {
  none,
  save,
  discard,
}

class EditNoteScreen extends StatefulWidget {
  const EditNoteScreen({
    super.key,
    required this.note,
  });

  final NoteModel note;

  @override
  State<EditNoteScreen> createState() => _EditNoteScreenState();
}

class _EditNoteScreenState extends State<EditNoteScreen> {
  final ScrollController _scrollController = ScrollController();

  late List<Color> _colorOptions;
  late NoteEditingController noteEditingController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();

    _colorOptions = PredefinedColor.values.map((e) => e.color).toList(growable: false);

    final resolvedIndex = _colorOptions.indexOf(widget.note.color);
    _currentIndex = resolvedIndex != -1 ? resolvedIndex : 0;

    noteEditingController = NoteEditingController(widget.note);
  }

  @override
  void dispose() {
    noteEditingController.dispose();
    super.dispose();
  }

  Future<void> _handleClose() async {
    // Is not dirty and it can close without losing data.
    if (!noteEditingController.dirty) {
      return Navigator.pop(context);
    }

    // Hide the keyboard. This prevents keyboard and dialog overlapping issues.
    FocusScope.of(context).unfocus();

    var changesAction = await _showSaveChangesDialog();
    if (changesAction == ChangesAction.save) {
      noteEditingController.save();
    } else if (changesAction == ChangesAction.discard) {
      noteEditingController.restore();
    }

    // Check if the user did not dismissed the dialog.
    if (changesAction != ChangesAction.none) {
      // In this section the NoteEditingController should contain clean data.
      assert(!noteEditingController.dirty);
      if (!mounted) return;
      Navigator.pop(context, noteEditingController.value);
    }
  }

  void _handleSave() {
    if (noteEditingController.dirty) {
      noteEditingController.save();
    }
    Navigator.pop(context, noteEditingController.value);
  }

  Widget _createSaveButton() {
    final localizations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return TextButton(
      onPressed: _handleSave,
      style: TextButton.styleFrom(foregroundColor: theme.primaryIconTheme.color),
      child: Text(localizations.saveButton),
    );
  }

  Future<ChangesAction> _showSaveChangesDialog() async {
    final dialogResult = await showDialog<ChangesAction>(
      context: context,
      builder: (context) => const _SaveChangesAlertDialog(),
    );
    return dialogResult ?? ChangesAction.none;
  }

  void _handleOnTap(int index) {
    if (_currentIndex == index) return;
    setState(() {
      _currentIndex = index;
    });
    noteEditingController.updateWith(color: _colorOptions[index]);
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final note = noteEditingController.value;

    return Scaffold(
      appBar: AppBar(
        leading: CloseButton(
          onPressed: _handleClose,
        ),
        title: Text(localizations.edit),
        actions: [
          _createSaveButton(),
        ],
      ),
      body: SafeArea(
        child: CardHero(
          tag: 'note-${note.id}',
          color: note.color,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(4.0)),
          ),
          margin: EdgeInsets.zero,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: Theme(
                  // Set overscroll color same as the note border
                  data: theme.copyWith(
                    colorScheme: theme.colorScheme.copyWith(secondary: note.color),
                  ),
                  child: _ScrollableContent(
                    scrollController: _scrollController,
                    titleEditingController: noteEditingController.titleController,
                    contentEditingController: noteEditingController.contentController,
                  ),
                ),
              ),
              _ColorOptionsNavBar(
                selectedIndex: _currentIndex,
                colors: _colorOptions,
                onTap: _handleOnTap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NoteEditingController extends DataStateNotifier<NoteModel> {
  NoteEditingController(super.value)
      : titleController = TextEditingController(text: value.title),
        contentController = TextEditingController(text: value.content) {
    titleController.addListener(_onTitleChanged);
    contentController.addListener(_onContentChanged);
  }

  final TextEditingController titleController;
  final TextEditingController contentController;

  void _onTitleChanged() {
    updateWith(title: titleController.text);
  }

  void _onContentChanged() {
    updateWith(content: contentController.text);
  }

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    super.dispose();
  }

  /// Updates this object with the given fields replaced with the new values.
  void updateWith({
    String? title,
    String? content,
    Color? color,
  }) {
    var newTitle = title ?? value.title;
    var newContent = content ?? value.content;
    var newColor = color ?? value.color;

    if (newTitle != value.title || newContent != value.content || newColor != value.color) {
      value = value.copyWith(
        title: title,
        content: content,
        color: color,
        lastEdit: DateTime.now(),
      );
    }
  }
}

class _ColorOptionsNavBar extends StatefulWidget {
  const _ColorOptionsNavBar({
    super.key,
    required this.selectedIndex,
    required this.colors,
    this.backgroundColor,
    required this.onTap,
  });

  final int selectedIndex;
  final List<Color> colors;
  final ValueChanged<int> onTap;
  final Color? backgroundColor;

  @override
  _ColorOptionsNavBarState createState() => _ColorOptionsNavBarState();
}

class _ColorOptionsNavBarState extends State<_ColorOptionsNavBar> {
  late List<BottomNavigationBarItem> _bottomNavBarItems;

  @override
  void initState() {
    super.initState();
    _bottomNavBarItems = _buildNavBarItemsList(widget.colors);
  }

  List<BottomNavigationBarItem> _buildNavBarItemsList(List<Color> values) {
    return List.generate(
      values.length,
      (index) => _buildNavBarItem(values[index]),
      growable: false,
    );
  }

  BottomNavigationBarItem _buildNavBarItem(Color color) {
    final cachedColor = CachedColor(color);
    return BottomNavigationBarItem(
      icon: ColorButton(color: cachedColor.value),
      activeIcon: ColorButton(
        color: cachedColor.value,
        icon: Icon(Icons.check, color: cachedColor.contrastingColor()),
      ),
      label: '', // Prevents tooltip from displaying.
      tooltip: '', // Prevents tooltip from displaying.
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: theme.colorScheme.onSurface, width: 0.3),
        ),
      ),
      child: BottomNavigationBar(
        backgroundColor: widget.backgroundColor,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        currentIndex: widget.selectedIndex,
        onTap: widget.onTap,
        items: _bottomNavBarItems,
      ),
    );
  }
}

class _ScrollableContent extends StatelessWidget {
  const _ScrollableContent({
    super.key,
    required this.scrollController,
    required this.titleEditingController,
    required this.contentEditingController,
  });

  final ScrollController scrollController;
  final TextEditingController? titleEditingController;
  final TextEditingController? contentEditingController;

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      controller: scrollController,
      trackVisibility: true,
      child: CustomScrollView(
        controller: scrollController,
        slivers: [
          SliverList(
            delegate: SliverChildListDelegate.fixed([
              _NoteTitleInput(
                titleEditingController: titleEditingController,
              ),
              const _SectionDivider(),
            ]),
          ),
          SliverFillRemaining(
            hasScrollBody: false,
            child: _NoteContentInput(
              contentEditingController: contentEditingController,
            ),
          ),
        ],
      ),
    );
  }
}

class _NoteTitleInput extends StatelessWidget {
  const _NoteTitleInput({
    super.key,
    required this.titleEditingController,
  });

  final TextEditingController? titleEditingController;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.only(left: 8.0, top: 8.0, right: 8.0),
      child: TextFormField(
        controller: titleEditingController,
        decoration: InputDecoration.collapsed(
          hintText: localizations.titleHint,
        ),
        style: theme.textTheme.titleLarge,
      ),
    );
  }
}

class _NoteContentInput extends StatelessWidget {
  const _NoteContentInput({
    super.key,
    required this.contentEditingController,
  });

  final TextEditingController? contentEditingController;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.only(left: 8.0, bottom: 8.0, right: 8.0),
      child: TextFormField(
        controller: contentEditingController,
        decoration: InputDecoration.collapsed(
          hintText: localizations.contentHint,
        ),
        textAlignVertical: TextAlignVertical.top,
        keyboardType: TextInputType.multiline,
        maxLines: null, // No limit of lines
        expands: true,
      ),
    );
  }
}

class _SectionDivider extends StatelessWidget {
  const _SectionDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const Divider(
      thickness: 1.1,
      indent: 10,
      endIndent: 10,
    );
  }
}

class _SaveChangesAlertDialog extends StatelessWidget {
  const _SaveChangesAlertDialog({super.key});

  Widget _createButton(BuildContext context, String text, ChangesAction action) {
    return TextButton(
      onPressed: () => Navigator.of(context, rootNavigator: true).pop(action),
      child: Text(text),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(localizations.saveChangesDialogTitle),
      content: SingleChildScrollView(
        child: ListBody(
          children: [
            Text(localizations.saveChangesDialogContent),
          ],
        ),
      ),
      actions: [
        _createButton(context, localizations.discardButton, ChangesAction.discard),
        _createButton(context, localizations.saveButton, ChangesAction.save),
      ],
    );
  }
}

enum PredefinedColor {
  yellow,
  green,
  pink,
  purple,
  blue,
  grey,
  black,
}

extension PredefinedColorExtension on PredefinedColor {
  int get value => color.value;

  Color get color {
    switch (this) {
      case PredefinedColor.yellow:
        return const Color(0xFFE6B904);
      case PredefinedColor.green:
        return const Color(0xFF65BA5A);
      case PredefinedColor.pink:
        return const Color(0xFFEA86C2);
      case PredefinedColor.purple:
        return const Color(0xFFC78EFF);
      case PredefinedColor.blue:
        return const Color(0xFF5AC0E7);
      case PredefinedColor.grey:
        return const Color(0xFFAAAAAA);
      case PredefinedColor.black:
        return const Color(0xFF454545);
    }
  }
}
