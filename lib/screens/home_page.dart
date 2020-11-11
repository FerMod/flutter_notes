import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../data/app_options.dart';
import '../menu/drawer_menu.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final options = AppOptions.of(context);
    final localizations = AppLocalizations.of(context);
    final _dropdownMenuItems = _buildDropDownMenuItems(AppLocalizations.supportedLocales);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.homepage),
      ),
      drawer: DrawerMenu(),
      body: Container(
        padding: EdgeInsets.all(20.0),
        child: DropdownButton(
          value: options.locale.languageCode,
          items: _dropdownMenuItems,
          onChanged: (value) => AppOptions.update(
            context,
            options.copyWith(locale: Locale(value)),
          ),
        ),
      ),
    );
  }

  List<DropdownMenuItem<String>> _buildDropDownMenuItems(List<Locale> listItems) {
    return listItems.map((e) => DropdownMenuItem(value: e.languageCode, child: Text(e.languageCode))).toList();
  }
}
