import 'package:flutter/material.dart';

class DisplayOption {
  const DisplayOption({
    required this.title,
    this.subtitle,
  });

  final Widget title;
  final Widget? subtitle;
}

class SettingsHeader extends StatelessWidget {
  const SettingsHeader({
    Key? key,
    required this.title,
    this.subtitle,
  }) : super(key: key);

  final Widget title;
  final Widget? subtitle;

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
    Key? key,
    required this.title,
    this.icon,
    this.subtitle,
    this.trailing,
    this.onTap,
  }) : super(key: key);

  final Widget? icon;
  final Widget title;
  final Widget? subtitle;
  final Widget? trailing;
  final GestureTapCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      leading: icon,
      title: title,
      subtitle: subtitle,
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          trailing ??
              Icon(
                Icons.chevron_right,
                color: theme.textTheme.caption!.color,
              ),
        ],
      ),
      onTap: onTap,
    );
  }
}

class SettingRadioListItems<T> extends StatelessWidget {
  SettingRadioListItems({
    Key? key,
    required this.selectedOption,
    required this.optionsMap,
    required this.onChanged,
  }) : super(key: key);

  /// The currently selected value.
  final T selectedOption;

  /// The map of options value and [DisplayOption] pairs. The map keys,
  /// represent the values of the available options. The map values, are the
  /// [DisplayOption] associated to given option.
  ///
  /// A radio list tile button is considered selected if its [selectedOption]
  /// matches a key in the [optionsMap].
  final Map<T, DisplayOption> optionsMap;

  /// Called when the user selects a radio list item.
  ///
  /// The widget passes [value] as a parameter to this callback. The widget does
  /// not change state until the parent widget rebuilds the radio list items
  /// with the new [selectedOption].
  ///
  /// If `null`, the radio list items will be displayed as disabled.
  ///
  /// The provided callback will not be invoked if this radio button is already
  /// selected.
  ///
  /// The callback provided to [onChanged] should update the state of the parent
  /// [StatefulWidget] using the [State.setState] method, so that the parent
  /// gets rebuilt. For example:
  ///
  /// ```dart
  /// SettingRadioListItems<int>(
  ///   selectedOption: _amount,
  ///   optionsMap: _amountOptions,
  ///   onChanged: (value) {
  ///     setState(() {
  ///       _amount = value;
  ///     });
  ///   },
  /// )
  /// ```
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    final _options = optionsMap.keys;
    final _displayOptions = optionsMap.values;

    return ListView.builder(
      shrinkWrap: true,
      itemCount: optionsMap.length,
      itemBuilder: (context, index) {
        final value = _options.elementAt(index);
        final displayOption = _displayOptions.elementAt(index);
        return RadioListTile<T>(
          value: value,
          groupValue: selectedOption,
          title: displayOption.title,
          subtitle: displayOption.subtitle,
          onChanged: onChanged,
        );
      },
    );
  }
}

class SettingsRouteBuilder<T> extends PageRouteBuilder<T> {
  SettingsRouteBuilder({
    required this.builder,
    RouteSettings? settings,
    bool maintainState = true,
    bool fullscreenDialog = false,
  }) : super(
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
