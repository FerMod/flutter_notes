import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

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
  final _scaffoldKey = GlobalKey<ScaffoldState>();

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
      Navigator.of(context).pop(widget.note);
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
    return Form(
      key: _formKey,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: TextFormField(
            controller: _titleEditingController,
            decoration: InputDecoration(
              hintText: 'Title...',
            ),
            style: Theme.of(context).textTheme.headline5,
          ),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: TextFormField(
                controller: _contentEditingController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(borderSide: BorderSide.none),
                ),
                textAlignVertical: TextAlignVertical.top,
                autofocus: false,
                maxLines: null,
                expands: true,
              ),
            ),
            Center(
              child: ElevatedButton(
                child: Text(AppLocalizations.of(context).save),
                onPressed: _handleSubmit,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
