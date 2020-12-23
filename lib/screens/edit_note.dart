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
  const EditNoteScreen({Key key, this.note}) : super(key: key);

  final NoteModel note;

  @override
  _EditNoteScreenState createState() => _EditNoteScreenState();
}

class _EditNoteScreenState extends State<EditNoteScreen> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController _titleEditingController;
  TextEditingController _contentEditingController;
  Color _color;

  @override
  void initState() {
    super.initState();
    _titleEditingController = TextEditingController(text: widget.note.title);
    _contentEditingController = TextEditingController(text: widget.note.content);
    _color = widget.note.color;
  }

  @override
  void dispose() {
    _titleEditingController.dispose();
    _contentEditingController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    final form = _formKey.currentState;
    // Validate returns true if the form is valid, or false otherwise.
    if (form.validate()) {
      form.save();

      widget.note
        ..title = _titleEditingController.text
        ..content = _contentEditingController.text
        ..color = _color;
      Navigator.of(context).pop(widget.note);
      //widget.onEdit(_titleEditingController.text, _contentEditingController.text, widget.note.color);
    }
  }

  PopupMenuButton _popupMenuButton() {
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
          _popupMenuButton(),
        ],
        elevation: 0, // Prevents the shadow from darkening other colors
      ),
      body: Form(
        key: _formKey,
        child: CardHero(
          tag: 'note-${widget.note.id}',
          color: _color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(4.0)),
          ),
          margin: EdgeInsets.zero,
          child: _buildCardContent(),
        ),
      ),
    );
  }

  Widget _buildCardContent() {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: TextFormField(
            controller: _titleEditingController,
            decoration: InputDecoration(
              hintText: localizations.titleHint,
            ),
            style: Theme.of(context).textTheme.headline6,
          ),
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              controller: _contentEditingController,
              keyboardType: TextInputType.multiline,
              decoration: InputDecoration.collapsed(
                hintText: localizations.contentHint,
              ),
              textAlignVertical: TextAlignVertical.top,
              autofocus: false,
              maxLines: null, // No limit of lines
              expands: true,
            ),
          ),
        ),
        Container(
          // margin: const EdgeInsets.all(0),
          // padding: const EdgeInsets.all(0),
          alignment: Alignment.center,
          child: ColorToggleButtons(
            initialValue: widget.note.color,
            colors: PredefinedColor.values.map((e) => e.color).toList(),
            onPressed: (index) {
              setState(() {
                _color = PredefinedColor.values[index].color;
                developer.log('Color: ${widget.note.color}, Value: ${widget.note.color.value}');
              });
            },
          ),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: theme.colorScheme.onSurface, width: 0.2),
            ),
            //borderRadius: BorderRadius.all(Radius.zero),
          ),
        ),
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
