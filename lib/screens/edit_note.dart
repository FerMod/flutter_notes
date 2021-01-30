import 'dart:developer' as developer;
import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../data/models/note_model.dart';
import '../widgets/card_hero.dart';
import '../widgets/color_toggle_buttons.dart';

enum Commands {
  delete,
}

class EditNoteScreen extends StatefulWidget {
  const EditNoteScreen({
    Key key,
    @required this.note,
  }) : super(key: key);

  final NoteModel note;

  @override
  _EditNoteScreenState createState() => _EditNoteScreenState();
}

class _EditNoteScreenState extends State<EditNoteScreen> {
  final _scrollController = ScrollController();

  TextEditingController _titleEditingController;
  TextEditingController _contentEditingController;
  Color _color;
  DateTime _lastEdit;

  @override
  void initState() {
    super.initState();
    _titleEditingController = TextEditingController(text: widget.note.title);
    _contentEditingController = TextEditingController(text: widget.note.content);
    _color = widget.note.color;
    _lastEdit = widget.note.lastEdit;

    _titleEditingController.addListener(_updateLastEdit);
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

  void _handleSubmit() {
    widget.note
      ..title = _titleEditingController.text
      ..content = _contentEditingController.text
      ..color = _color
      ..lastEdit = _lastEdit;

    Navigator.of(context).pop(widget.note);
    //widget.onEdit(_titleEditingController.text, _contentEditingController.text, widget.note.color);
  }

  Widget _createMenuButton() {
    final localizations = AppLocalizations.of(context);
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
          child: ListTile(leading: Icon(Icons.delete), title: Text(localizations.delete)),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Scaffold(
      //backgroundColor: Colors.transparent,
      appBar: AppBar(
        leading: BackButton(
          onPressed: _handleSubmit,
        ),
        title: Text(localizations.edit),
        actions: [
          _createMenuButton(),
        ],
        elevation: 0.0, // Prevents the shadow from darkening other colors
      ),
      body: SafeArea(
        child: CardHero(
          tag: 'note-${widget.note.id}',
          color: _color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(4.0)),
          ),
          margin: EdgeInsets.zero,
          child: Column(
            children: [
              Expanded(
                child: _ScrollableContent(
                  scrollController: _scrollController,
                  titleEditingController: _titleEditingController,
                  contentEditingController: _contentEditingController,
                ),
              ),
              _ColorButtons(
                initialValue: _color,
                onPressed: (index) {
                  setState(() {
                    _color = PredefinedColor.values[index].color;
                    developer.log('Color: ${widget.note.color}, Value: ${widget.note.color.value}');
                  });
                  _updateLastEdit();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScrollableContent extends StatelessWidget {
  const _ScrollableContent({
    Key key,
    @required this.scrollController,
    @required this.titleEditingController,
    @required this.contentEditingController,
  }) : super(key: key);

  final ScrollController scrollController;
  final TextEditingController titleEditingController;
  final TextEditingController contentEditingController;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _NoteTitleInput(
          titleEditingController: titleEditingController,
        ),
        const _SectionDivider(),
        Expanded(
          child: Scrollbar(
            controller: scrollController,
            child: _NoteContentInput(
              contentEditingController: contentEditingController,
            ),
          ),
        ),
      ],
    );
  }
}

class _NoteTitleInput extends StatelessWidget {
  const _NoteTitleInput({
    Key key,
    @required this.titleEditingController,
  }) : super(key: key);

  final TextEditingController titleEditingController;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
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
    Key key,
    @required this.contentEditingController,
  }) : super(key: key);

  final TextEditingController contentEditingController;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
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

class _ColorButtons extends StatelessWidget {
  const _ColorButtons({
    Key key,
    @required this.initialValue,
    @required this.onPressed,
  }) : super(key: key);

  final Color initialValue;
  final void Function(int index) onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      // margin: const EdgeInsets.all(0),
      // padding: const EdgeInsets.all(0),
      alignment: Alignment.center,
      child: ColorToggleButtons(
        initialValue: initialValue,
        colors: PredefinedColor.values.map((e) => e.color).toList(),
        onPressed: onPressed,
      ),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: theme.colorScheme.onSurface, width: 0.2),
        ),
        //borderRadius: BorderRadius.all(Radius.zero),
      ),
    );
  }
}

class _SectionDivider extends StatelessWidget {
  const _SectionDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(
      thickness: 1.1,
      indent: 10,
      endIndent: 10,
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
  custom,
}

extension PredefinedColorExtension on PredefinedColor {
  String get name => describeEnum(this);
  int get value => color.value;

  Color get color {
    switch (this) {
      case PredefinedColor.yellow:
        return Color(0xFFE6B904);
      case PredefinedColor.green:
        return Color(0xFF65BA5A);
      case PredefinedColor.pink:
        return Color(0xFFEA86C2);
      case PredefinedColor.purple:
        return Color(0xFFC78EFF);
      case PredefinedColor.blue:
        return Color(0xFF5AC0E7);
      case PredefinedColor.grey:
        return Color(0xFFAAAAAA);
      case PredefinedColor.black:
        return Color(0xFF454545);
      case PredefinedColor.custom:
        return Color((math.Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0);
    }
    return null;
  }
}
