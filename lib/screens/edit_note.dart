import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_notes/menu/card_hero.dart';

import '../data/models.dart';

class EditNoteScreen extends StatefulWidget {
  EditNoteScreen({Key key, this.note}) : super(key: key);

  final Note note;

  @override
  _EditNoteScreenState createState() => _EditNoteScreenState();
}

//https://github.com/flutter/gallery/blob/master/lib/demos/material/text_field_demo.dart
class _EditNoteScreenState extends State<EditNoteScreen> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController _titleEditingController;
  TextEditingController _contentEditingController;

  @override
  void initState() {
    super.initState();
    _titleEditingController = TextEditingController(text: widget.note.title);
    _contentEditingController = TextEditingController(text: widget.note.content);
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
        ..content = _contentEditingController.text;
      //Navigator.of(context).pop(widget.note);
      Navigator.of(context).pop();
    }
  }

  String _validateName(String value) {
    // if (value.isEmpty) {
    //   return AppLocalizations.of(context).titleFieldRequired;
    // }
    // final nameExp = RegExp(r'^[A-Za-z ]+$');
    // if (!nameExp.hasMatch(value)) {
    //   return AppLocalizations.of(context).demoTextFieldOnlyAlphabeticalChars;
    // }
    return null;
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
      ),
      body: Form(
        key: _formKey,
        child:
         CardHero(
          tag: 'note-${widget.note.id}',
          color: widget.note.color,
          margin: EdgeInsets.zero,
          child: _buildCardContent(localizations, context),
        ),
      ),
    );
  }

  Padding _buildCardContent(AppLocalizations localizations, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _titleEditingController,
            decoration: InputDecoration(
              hintText: localizations.titleHint,
            ),
            style: Theme.of(context).textTheme.headline6,
          ),
          Expanded(
            child: TextFormField(
              controller: _contentEditingController,
              decoration: InputDecoration(
                hintText: localizations.contentHint,
                //border: OutlineInputBorder(borderSide: BorderSide.none),
              ),
              textAlignVertical: TextAlignVertical.top,
              autofocus: false,
              maxLines: null,
              expands: true,
            ),
          ),
          // Align(
          //   alignment: Alignment.centerRight,
          //   child: ElevatedButton.icon(
          //     onPressed: _handleSubmit,
          //     icon: const Icon(Icons.save),
          //     label: Text(localizations.save),
          //   ),
          // ),
        ],
      ),
    );
  }
}
