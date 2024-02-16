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

  final DisplayWidgetBuilder<String>? _titleBuilder;
  final DisplayWidgetBuilder<String?>? _subtitleBuilder;

  Widget? _defaultWidgetBuilder(BuildContext context, String? value) {
    return value != null ? Text(value) : null;
  }

  Widget? buildTitle(BuildContext context) {
    return (_titleBuilder ?? _defaultWidgetBuilder).call(context, title);
  }

  Widget? buildSubtitle(BuildContext context) {
    return (_subtitleBuilder ?? _defaultWidgetBuilder).call(context, subtitle);
  }

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
      titleBuilder: titleBuilder ?? _titleBuilder,
      subtitleBuilder: subtitleBuilder ?? _subtitleBuilder,
    );
  }

  @override
  String toString() {
    return '$DisplayOption(title: $title, subtitle: $subtitle)';
  }
}

class SettingsGroup extends StatelessWidget {
  const SettingsGroup({
    super.key,
    this.title,
    this.children = const <Widget>[],
  });

  final Widget? title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) title!,
        ...children,
      ],
    );
  }
}

class SettingsHeader extends StatelessWidget {
  const SettingsHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.padding = const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
  });

  final Widget title;
  final Widget? subtitle;
  final EdgeInsetsGeometry padding;

  Color? _textColor(ThemeData theme, ListTileThemeData tileTheme, Color? defaultColor) {
    return tileTheme.textColor ?? defaultColor;
  }

  TextStyle _titleTextStyle(ThemeData theme, ListTileThemeData tileTheme) {
    final TextStyle style = theme.textTheme.titleMedium!;
    final Color? color = _textColor(theme, tileTheme, style.color);
    return style.copyWith(color: color, fontSize: 13.0);
  }

  TextStyle _subtitleTextStyle(ThemeData theme, ListTileThemeData tileTheme) {
    final TextStyle style = theme.textTheme.bodyMedium!;
    final Color? color = _textColor(theme, tileTheme, theme.textTheme.bodySmall!.color);
    return style.copyWith(color: color, fontSize: 12.0);
  }

  Widget _buildTextWidget(Widget child, TextStyle textStyle) {
    return AnimatedDefaultTextStyle(
      style: textStyle,
      duration: kThemeChangeDuration,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tileTheme = ListTileTheme.of(context);

    final titleWidget = _buildTextWidget(title, _titleTextStyle(theme, tileTheme));

    Widget? subtitleWidget;
    if (subtitle != null) {
      subtitleWidget = _buildTextWidget(subtitle!, _subtitleTextStyle(theme, tileTheme));
    }

    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          titleWidget,
          if (subtitleWidget != null) subtitleWidget,
        ],
      ),
    );
  }
}

class SettingListTile extends StatelessWidget {
  const SettingListTile({
    super.key,
    required this.title,
    this.icon,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

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
                color: theme.textTheme.bodySmall!.color,
              ),
        ],
      ),
      onTap: onTap,
    );
  }
}

class SettingRadioListItems<T> extends StatelessWidget {
  const SettingRadioListItems({
    super.key,
    required this.selectedOption,
    required this.optionsMap,
    this.onChanged,
  });

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
    final optionsList = optionsMap.entries.toList(growable: false);
    return ListView.builder(
      shrinkWrap: true,
      itemCount: optionsMap.length,
      itemBuilder: (context, index) {
        final value = optionsList[index].key;
        final displayOption = optionsList[index].value;

        return RadioListTile<T>(
          value: value,
          groupValue: selectedOption,
          title: displayOption.buildTitle(context),
          subtitle: displayOption.buildSubtitle(context),
          onChanged: onChanged != null
              ? (value) {
                  // Can only be null if RadioListTile's `toggleable` parameter
                  // is true, but it can't be
                  onChanged?.call(value as T);
                }
              : null,
        );
      },
    );
  }
}
