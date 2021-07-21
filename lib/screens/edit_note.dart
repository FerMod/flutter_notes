import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_notes/src/cache/cached_color.dart';

import '../data/models/note_model.dart';
import '../widgets/card_hero.dart';
import '../widgets/color_toggle_buttons.dart';

enum Commands {
  delete,
}

enum ChangesAction {
  none,
  save,
  discard,
}

class EditNoteScreen extends StatefulWidget {
  const EditNoteScreen({
    Key? key,
    required this.note,
  }) : super(key: key);

  final NoteModel note;

  @override
  _EditNoteScreenState createState() => _EditNoteScreenState();
}

class _EditNoteScreenState extends State<EditNoteScreen> {
  final ScrollController _scrollController = ScrollController();

  late TextEditingController _titleEditingController;
  late TextEditingController _contentEditingController;
  late Color _color;
  late DateTime _lastEdit;

  int _currentIndex = 0;
  late List<Color> _colorOptions;

  @override
  void initState() {
    super.initState();

    _colorOptions = PredefinedColor.values.map((e) => e.color).toList();

    _titleEditingController = TextEditingController(text: widget.note.title);
    _contentEditingController = TextEditingController(text: widget.note.content);
    _color = widget.note.color;
    _lastEdit = widget.note.lastEdit;

    _titleEditingController.addListener(_updateLastEdit);
    _contentEditingController.addListener(_updateLastEdit);

    final resolvedIndex = _colorOptions.indexOf(widget.note.color);
    _currentIndex = resolvedIndex != -1 ? resolvedIndex : 0;
  }

  @override
  void dispose() {
    _titleEditingController.dispose();
    _contentEditingController.dispose();
    super.dispose();
  }

  void _updateLastEdit() {
    _lastEdit = DateTime.now();
  }

  void _saveChanges() {
    widget.note
      ..title = _titleEditingController.text
      ..content = _contentEditingController.text
      ..color = _color
      ..lastEdit = _lastEdit;
  }

  bool _valuesChanged(NoteModel note) {
    return note.title != _titleEditingController.text || note.content != _contentEditingController.text || note.color != _color;
  }

  Future<void> _handleClose() async {
    if (_valuesChanged(widget.note)) {
      FocusScope.of(context).unfocus(); // Hide the keyboard
      final saveChangesAction = await _showSaveChangesDialog();
      if (saveChangesAction == ChangesAction.none) return;

      if (saveChangesAction == ChangesAction.save) {
        _saveChanges();
      }
    }

    Navigator.of(context).pop(widget.note);
    //widget.onEdit(_titleEditingController.text, _contentEditingController.text, widget.note.color);
  }

  Widget _createSaveButton() {
    final localizations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return TextButton(
      onPressed: () {
        if (_valuesChanged(widget.note)) {
          _saveChanges();
        }
        Navigator.of(context).pop(widget.note);
      },
      style: TextButton.styleFrom(primary: theme.primaryIconTheme.color),
      child: Text(localizations.save),
    );
  }

  Widget _createMenuButton() {
    final localizations = AppLocalizations.of(context)!;
    return PopupMenuButton<Commands>(
      tooltip: localizations.changeColor,
      onSelected: (result) {
        switch (result) {
          case Commands.delete:
            // TODO: Handle this case.
            break;
          default:
            break;
        }
      },
      itemBuilder: (context) => [
        const PopupMenuDivider(),
        PopupMenuItem(
          value: Commands.delete,
          child: ListTile(leading: const Icon(Icons.delete), title: Text(localizations.delete)),
        ),
        const PopupMenuDivider(),
      ],
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
      _color = _colorOptions[index];
    });
    _updateLastEdit();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: CloseButton(
          onPressed: _handleClose,
        ),
        title: Text(localizations.edit),
        actions: [
          _createSaveButton(),
          //_createMenuButton(),
        ],
        elevation: 0.0, // Prevents the shadow from darkening other colors
      ),
      body: SafeArea(
        child: CardHero(
          tag: 'note-${widget.note.id}',
          color: _color,
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
                  data: theme.copyWith(accentColor: _color),
                  child: _ScrollableContent(
                    scrollController: _scrollController,
                    titleEditingController: _titleEditingController,
                    contentEditingController: _contentEditingController,
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

class _ColorOptionsNavBar extends StatefulWidget {
  const _ColorOptionsNavBar({
    Key? key,
    required this.selectedIndex,
    required this.colors,
    this.backgroundColor,
    required this.onTap,
  }) : super(key: key);

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
    _bottomNavBarItems = _buildNavBarItems(widget.colors);
  }

  List<BottomNavigationBarItem> _buildNavBarItems(List<Color> values) {
    return List.generate(
      values.length,
      (index) {
        final cachedColor = CachedColor(values[index]);
        return BottomNavigationBarItem(
          icon: ColorButton(color: cachedColor.value),
          activeIcon: ColorButton(
            color: cachedColor.value,
            icon: Icon(Icons.check, color: cachedColor.contrastingColor()),
          ),
          label: '', // Prevents tooltip from displaying
          tooltip: '', // Prevents tooltip from displaying
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget bottomNavigationBar = BottomNavigationBar(
      backgroundColor: widget.backgroundColor,
      type: BottomNavigationBarType.fixed,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      currentIndex: widget.selectedIndex,
      onTap: widget.onTap,
      items: _bottomNavBarItems,
    );

    bottomNavigationBar = DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: theme.colorScheme.onSurface, width: 0.3),
        ),
      ),
      child: bottomNavigationBar,
    );

    return bottomNavigationBar;
  }
}

class _ScrollableContent extends StatelessWidget {
  const _ScrollableContent({
    Key? key,
    required this.scrollController,
    required this.titleEditingController,
    required this.contentEditingController,
  }) : super(key: key);

  final ScrollController scrollController;
  final TextEditingController? titleEditingController;
  final TextEditingController? contentEditingController;

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      controller: scrollController,
      showTrackOnHover: true,
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
    Key? key,
    required this.titleEditingController,
  }) : super(key: key);

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
        style: theme.textTheme.headline6,
      ),
    );
  }
}

class _NoteContentInput extends StatelessWidget {
  const _NoteContentInput({
    Key? key,
    required this.contentEditingController,
  }) : super(key: key);

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
  const _SectionDivider({Key? key}) : super(key: key);

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
  const _SaveChangesAlertDialog({Key? key}) : super(key: key);

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
      content: SingleChildScrollView(
        child: ListBody(
          children: [
            Text(localizations.saveChangesDialogContent),
          ],
        ),
      ),
      actions: [
        _createButton(context, localizations.discard, ChangesAction.discard),
        _createButton(context, localizations.save, ChangesAction.save),
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
  String get name => describeEnum(this);
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

@Deprecated('Will be replaced with BottomNavigationBar')
class _ColorButtons extends StatelessWidget {
  const _ColorButtons({
    Key? key,
    required this.initialValue,
    required this.colors,
    required this.onPressed,
  }) : super(key: key);

  final List<Color> colors;
  final Color? initialValue;
  final void Function(int index) onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      // alignment: Alignment.center,
      // margin: EdgeInsets.zero,
      // padding: EdgeInsets.zero,
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: theme.colorScheme.onSurface, width: 0.2),
        ),
        //borderRadius: BorderRadius.all(Radius.zero),
      ),
      child: ColorToggleButtons(
        initialValue: initialValue,
        colors: colors,
        onPressed: onPressed,
      ),
    );
  }
}
