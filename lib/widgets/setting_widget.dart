import 'package:flutter/material.dart';

class DisplayOption {
  const DisplayOption({
    @required this.title,
    this.subtitle,
  });

  final Widget title;
  final Widget subtitle;

  bool get hasTitle => title != null;
  bool get hasSubtitle => subtitle != null;
}

class SettingsHeader extends StatelessWidget {
  const SettingsHeader({
    Key key,
    @required this.title,
    this.subtitle,
  })  : assert(title != null),
        super(key: key);

  final Widget title;
  final Widget subtitle;

  @override
  Widget build(BuildContext context) {
    // final theme = Theme.of(context);
    // theme.textTheme.subtitle1,
    return ListTile(
      title: title,
      subtitle: subtitle,
      dense: true,
    );
  }
}

class SettingListTile extends StatelessWidget {
  const SettingListTile({
    Key key,
    @required this.title,
    this.subtitle,
    this.icon,
    this.onTap,
  }) : super(key: key);

  final Widget title;
  final Widget subtitle;
  final Icon icon;
  final GestureTapCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return StatefulBuilder(
      builder: (context, setState) {
        return ListTile(
          leading: icon,
          title: title,
          subtitle: subtitle,
          trailing: Icon(Icons.chevron_right, color: theme.dividerColor),
          onTap: onTap,
        );
      },
    );
  }
}

class SettingRadioListItems<T> extends StatefulWidget {
  SettingRadioListItems({
    Key key,
    @required this.selectedOption,
    @required this.optionsMap,
    @required this.onChanged,
  }) : super(key: key);

  final T selectedOption;
  final Map<T, DisplayOption> optionsMap;

  final ValueChanged<T> onChanged;

  @override
  _SettingRadioListItemsState createState() => _SettingRadioListItemsState<T>();
}

class _SettingRadioListItemsState<T> extends State<SettingRadioListItems<T>> {
  T _selectedOption;

  // For ease of use. Correspond to the keys and values of `widget.optionsMap`.
  Iterable<T> _options;
  Iterable<DisplayOption> _displayOptions;

  @override
  void initState() {
    super.initState();
    _options = widget.optionsMap.keys;
    _displayOptions = widget.optionsMap.values;
    _selectedOption = widget.selectedOption;
  }

  @override
  void didUpdateWidget(SettingRadioListItems<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.optionsMap != oldWidget.optionsMap) {
      _options = widget.optionsMap.keys;
      _displayOptions = widget.optionsMap.values;
    }
  }

  void _handleOnChanged(T value) {
    setState(() {
      _selectedOption = value;
    });
    // Notify of the value change
    widget.onChanged(value);
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: _options.length,
      itemBuilder: (context, index) {
        final value = _options.elementAt(index);
        final displayOption = _displayOptions.elementAt(index);
        return RadioListTile<T>(
          value: value,
          groupValue: _selectedOption,
          title: displayOption.title,
          subtitle: displayOption.subtitle,
          onChanged: _handleOnChanged,
        );
      },
    );
  }
}

class SettingsRouteBuilder<T> extends PageRouteBuilder<T> {
  SettingsRouteBuilder({
    @required this.builder,
    RouteSettings settings,
    bool maintainState = true,
    bool fullscreenDialog = false,
  })  : assert(builder != null),
        assert(maintainState != null),
        assert(fullscreenDialog != null),
        super(
          pageBuilder: (context, animation, secondaryAnimation) {
            return builder(context);
          },
          settings: settings,
          maintainState: maintainState,
          fullscreenDialog: fullscreenDialog,
        ) {
    assert(opaque);
  }

  final WidgetBuilder builder;

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
    var begin = Offset(1.0, 0.0);
    var end = Offset.zero;
    var curve = Curves.easeIn;

    var tween = Tween(begin: begin, end: end);
    tween.chain(CurveTween(curve: curve));

    return SlideTransition(
      position: animation.drive(tween),
      child: child,
    );
  }
}
