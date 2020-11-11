import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../screens/home_page.dart';
import '../screens/notes_list.dart';

class DrawerMenu extends StatelessWidget {
  Future _navigate(BuildContext context, Widget widget) {
    return Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => widget),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          Container(
            height: 90,
            padding: EdgeInsets.zero,
            margin: EdgeInsets.zero,
            child: DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child: Text(
                localizations.drawerTitle,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: Theme.of(context).textTheme.headline5.fontSize,
                ),
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text(localizations.homepage),
            onTap: () => _navigate(context, HomePage()),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.sticky_note_2),
            title: Text(localizations.note(2)),
            onTap: () => _navigate(context, NotesListScreen()),
          ),
          /* 
         ListTile(
            leading: Icon(Icons.storage),
            title: Text(localizations.questions),
            onTap: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => QuestionList()),
              );
            },
          ),
          */
        ],
      ),
    );
  }
}
