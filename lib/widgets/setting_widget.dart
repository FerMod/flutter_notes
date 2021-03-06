import 'package:flutter/material.dart';

typedef DisplayWidgetBuilder<T> = Widget? Function(BuildContext context, T value);

@immutable
class DisplayOption {
  const DisplayOption({
    required this.title,
    this.subtitle,
    DisplayWidgetBuilder<String>? titleBuilder,
    DisplayWidgetBuilder<String?>? subtitleBuilder,
  })  : _titleBuilder = titleBuilder,
        _subtitleBuilder = subtitleBuilder;

  final String title;
  final String? subtitle;

  Widget? _defaultWidgetBuilder(BuildContext context, String? value) {
    Widget? textWidget;
    if (value != null) {
      textWidget = Text(value);
    }
    return textWidget;
  }

  DisplayWidgetBuilder<String> get titleBuilder => _titleBuilder ?? _defaultWidgetBuilder;
  final DisplayWidgetBuilder<String>? _titleBuilder;

  DisplayWidgetBuilder<String?> get subtitleBuilder => _subtitleBuilder ?? _defaultWidgetBuilder;
  final DisplayWidgetBuilder<String?>? _subtitleBuilder;

  /// Creates a copy of this class object but with the given fields replaced
  /// with the new values.
  DisplayOption copyWith({
    String? title,
    String? subtitle,
    DisplayWidgetBuilder<String>? titleBuilder,
    DisplayWidgetBuilder<String?>? subtitleBuilder,
  }) {
    return DisplayOption(
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      titleBuilder: titleBuilder ?? this.titleBuilder,
      subtitleBuilder: subtitleBuilder ?? this.subtitleBuilder,
    );
  }
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
    this.onChanged,
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
  /// The widget passes [selectedOption] as a parameter to this callback. The
  /// widget does not change state until the parent widget rebuilds the radio
  /// list items with the new [selectedOption].
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
  final ValueChanged<T>? onChanged;

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
          title: displayOption.titleBuilder(context, displayOption.title),
          subtitle: displayOption.subtitleBuilder(context, displayOption.subtitle),
          onChanged: onChanged != null
              ? (value) {
                  // Can only be null if RadioListTile's `toggleable` parameter is true, but it can't be
                  onChanged?.call(value!);
                }
              : null,
        );
      },
    );
  }
}
