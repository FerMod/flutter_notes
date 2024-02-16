import 'package:flutter/material.dart';

/// Delegate for [SearchScreen] to define the content of the search page.
///
/// The search page always shows an [AppBar] at the top where users can
/// enter their search queries. The buttons shown before and after the title and
/// search query text field can be customized via [SearchScreenDelegate.buildLeading]
/// and [SearchScreenDelegate.buildActions]. Additonally, a widget can be placed
/// across the bottom of the [AppBar] via [SearchScreenDelegate.buildBottom].
///
/// The body below the [AppBar] can show the results of the search as returned
/// by [SearchScreenDelegate.buildResults].
///
/// [SearchScreenDelegate.query] always contains the current query entered by
/// the user and should be used to build the results.
///
/// The results can be brought on screen by calling [SearchScreenDelegate.showResults].
///
/// See also:
///
///  * [SearchDelegate], a search screen that is able to show suggestions.
abstract class SearchScreenDelegate<T> {
  /// Constructor to be called by subclasses.
  ///
  /// The [searchFieldHintStyle] and [searchFieldDecorationTheme] arguments
  /// cannot both be supplied, since it would potentially result in the hint
  /// style being overriden with the hint style defined in the input decoration
  /// theme. To supply a decoration with a color, use
  /// `searchFieldDecorationTheme: InputDecorationTheme(hintStyle: searchFieldHintStyle)`.
  SearchScreenDelegate({
    this.title,
    this.searchFieldHint,
    this.searchFieldHintStyle,
    this.searchFieldDecorationTheme,
    this.keyboardType,
    this.textInputAction = TextInputAction.search,
  }) : assert(
          searchFieldHintStyle == null || searchFieldDecorationTheme == null,
          'Cannot provide both a searchFieldStyle and a searchFieldDecorationTheme\n'
          'To provide both, use "searchFieldDecorationTheme: InputDecorationTheme(hintStyle: searchFieldHintStyle)".',
        );

  /// The results shown after the user submits a search.
  ///
  /// The current value of [query] can be used to determine what the user
  /// searched for.
  ///
  /// This method might be applied more than once to the same query.
  /// If your [buildResults] method is computationally expensive, you may want
  /// to cache the search results for one or more queries.
  ///
  /// Typically, this method returns a [ListView] with the search results.
  /// When the user taps on a particular search result.
  Widget buildResults(BuildContext context);

  /// A widget to display before the current query in the [AppBar].
  ///
  /// Typically an [IconButton] configured with a [BackButtonIcon]. One can also
  /// use an [AnimatedIcon] to animate from an icon to another. For example, an
  /// [AnimatedIcon] that animates from a hamburger menu to the back button as
  /// the search overlay fades in.
  ///
  /// As default, when the search field is not visible, it uses the default
  /// [AppBar.leading] widget. When the search field is visible a [BackButton]
  /// is used. When pressed, it hides and clears the search field.
  ///
  /// Return null if no widget should be shown.
  ///
  /// See also:
  ///
  ///  * [AppBar.leading], the intended use for the return value of this method.
  Widget? buildLeading(BuildContext context) {
    Widget? leadingWidget;
    if (isSearchFieldVisible) {
      leadingWidget = WillPopScope(
        onWillPop: () async {
          final isVisible = isSearchFieldVisible;
          if (isVisible) {
            hideSearchField(context);
          }
          return !isVisible;
        },
        child: const BackButton(),
      );
    }
    return leadingWidget;
  }

  /// Widgets to display after the search query in the [AppBar].
  ///
  /// By default, if the search field is hidden, this shows a button that makes
  /// visible the search field. If the search field is already visible the button
  /// does not show.
  ///
  /// Return null or an empty list if no widget should be shown.
  ///
  /// See also:
  ///
  ///  * [AppBar.actions], the intended use for the return value of this method.
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (!isSearchFieldVisible)
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {
            showSearchField(context);
          },
        ),
    ];
  }

  /// Widget to display across the bottom of the [AppBar].
  ///
  /// Returns null by default, this is, a bottom widget is not included.
  ///
  /// See also:
  ///
  ///  * [AppBar.bottom], the intended use for the return value of this method.
  PreferredSizeWidget? buildBottom(BuildContext context) => null;

  /// The theme used to configure the search page.
  ///
  /// The returned [ThemeData] will be used to wrap the entire search page,
  /// so it can be used to configure any of its components with the appropriate
  /// theme properties.
  ///
  /// See also:
  ///
  ///  * [AppBarTheme], which configures the AppBar's appearance.
  ///  * [InputDecorationTheme], which configures the appearance of the search
  ///   text field.
  ThemeData appBarTheme(BuildContext context) {
    final theme = Theme.of(context);
    final inputBorder = UnderlineInputBorder(
      borderSide: BorderSide(color: theme.hintColor),
    );
    return theme.copyWith(
      inputDecorationTheme: searchFieldDecorationTheme ??
          InputDecorationTheme(
            isDense: true,
            hintStyle: searchFieldHintStyle,
            border: const UnderlineInputBorder(),
            enabledBorder: inputBorder,
            focusedBorder: inputBorder,
          ),
    );
  }

  /// The current query string shown in the [AppBar].
  ///
  /// The user manipulates this string via the keyboard.
  String get query => _queryTextController.text;
  set query(String value) {
    _queryTextController.text = value;
  }

  /// Shows search results for the [query] results returned by [buildResults].
  /// This function removes the focus on the search field.
  void showResults(BuildContext context) {
    _focusNode?.unfocus();
    _isSearchFieldVisible = true;
  }

  /// Clears the search results by clearing the [query] content.
  void clearResults(BuildContext context) {
    query = '';
  }

  /// Shows the search field and requests focus.
  void showSearchField(BuildContext context) {
    _focusNode?.requestFocus();
    _isSearchFieldVisible = true;
  }

  /// Hides the search field, removes focus and clears the [query] content.
  void hideSearchField(BuildContext context) {
    _isSearchFieldVisible = false;
    clearResults(context);
    _focusNode?.unfocus();
  }

  /// Closes the search page and returns to the underlying route.
  ///
  /// The value provided for [result] is used as the return value of the call
  /// to [showSearch] that launched the search initially.
  void close(BuildContext context, [T? result]) {
    hideSearchField(context);
    Navigator.pop(context, result);
  }

  /// The primary widget displayed in the app bar when the search field has not
  /// focus and it is empty.
  ///
  /// Typically a [Text] widget that contains a description of the current
  /// contents of the app.
  ///
  /// If this value is set to null, no title will be shown.
  final Widget? title;

  /// The hint text that is shown in the search field when it is empty.
  ///
  /// If this value is set to null, the value of
  /// [MaterialLocalizations.searchFieldLabel] will be used instead.
  final String? searchFieldHint;

  /// The style of the [searchFieldHint].
  ///
  /// If this value is set to null, the value of the ambient [Theme]'s
  /// [InputDecorationTheme.hintStyle] will be used instead.
  ///
  /// Only one of [searchFieldHintStyle] or [searchFieldDecorationTheme] can
  /// be non-null.
  final TextStyle? searchFieldHintStyle;

  /// The [InputDecorationTheme] used to configure the search field's visuals.
  ///
  /// Only one of [searchFieldHintStyle] or [searchFieldDecorationTheme] can
  /// be non-null.
  final InputDecorationTheme? searchFieldDecorationTheme;

  /// The type of action button to use for the keyboard.
  ///
  /// Defaults to the default value specified in [TextField].
  final TextInputType? keyboardType;

  /// The text input action configuring the soft keyboard to a particular action
  /// button.
  ///
  /// Defaults to [TextInputAction.search].
  final TextInputAction textInputAction;

  /// [Animation] triggered when the search pages fades in or out.
  ///
  /// This animation is commonly used to animate [AnimatedIcon]s of
  /// [IconButton]s returned by [buildLeading] or [buildActions]. It can also be
  /// used to animate [IconButton]s contained within the route below the search
  /// page.
  @Deprecated('Not used in the widget.')
  Animation<double> get transitionAnimation => _proxyAnimation;

  // The focus node to use for manipulating focus on the search page. This is
  // managed, owned, and set by the _SearchScreenState using this delegate.
  FocusNode? _focusNode;

  final TextEditingController _queryTextController = TextEditingController();

  final ProxyAnimation _proxyAnimation = ProxyAnimation(kAlwaysDismissedAnimation);

  final ValueNotifier<bool> _isSearchFieldVisibleNotifier = ValueNotifier<bool>(false);

  bool get isSearchFieldVisible => _isSearchFieldVisibleNotifier.value;
  set _isSearchFieldVisible(bool value) {
    _isSearchFieldVisibleNotifier.value = value;
  }
}

class SearchScreen<T> extends StatefulWidget {
  const SearchScreen({
    super.key,
    required this.delegate,
  });

  final SearchScreenDelegate<T> delegate;

  @override
  State<StatefulWidget> createState() => _SearchScreenState<T>();
}

class _SearchScreenState<T> extends State<SearchScreen<T>> {
  // This node is owned, but not hosted by, the search page. Hosting is done by
  // the text field.
  FocusNode focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    widget.delegate._queryTextController.addListener(_onQueryChanged);
    widget.delegate._isSearchFieldVisibleNotifier.addListener(_onSearchFieldChanged);
    focusNode.addListener(_onFocusChanged);
    widget.delegate._focusNode = focusNode;
  }

  @override
  void dispose() {
    widget.delegate._queryTextController.dispose();
    widget.delegate._isSearchFieldVisibleNotifier.dispose();
    widget.delegate._focusNode = null;
    focusNode.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(SearchScreen<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.delegate._queryTextController != oldWidget.delegate._queryTextController) {
      oldWidget.delegate._queryTextController.removeListener(_onQueryChanged);
      widget.delegate._queryTextController
        ..addListener(_onQueryChanged)
        ..value = oldWidget.delegate._queryTextController.value;
    }

    if (widget.delegate._isSearchFieldVisibleNotifier != oldWidget.delegate._isSearchFieldVisibleNotifier) {
      oldWidget.delegate._isSearchFieldVisibleNotifier.removeListener(_onSearchFieldChanged);
      widget.delegate._isSearchFieldVisibleNotifier
        ..addListener(_onSearchFieldChanged)
        ..value = oldWidget.delegate._isSearchFieldVisibleNotifier.value;
    }

    if (widget.delegate._focusNode != oldWidget.delegate._focusNode) {
      oldWidget.delegate._focusNode = null;
      widget.delegate._focusNode = focusNode;
    }
  }

  void _onFocusChanged() {
    if (focusNode.hasFocus && !widget.delegate.isSearchFieldVisible) {
      widget.delegate.showSearchField(context);
    }
  }

  void _onQueryChanged() {
    setState(() {
      // Rebuild ourselves because query changed.
    });
  }

  void _onSearchFieldChanged() {
    setState(() {
      // Rebuild ourselves because search field changed.
    });
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMaterialLocalizations(context));

    final theme = widget.delegate.appBarTheme(context);

    Widget? titleWidget;
    if (widget.delegate.isSearchFieldVisible) {
      Widget? clearButton;
      if (widget.delegate.query.isNotEmpty) {
        clearButton = IconButton(
          visualDensity: VisualDensity.compact,
          icon: Icon(Icons.clear, color: theme.iconTheme.color),
          onPressed: () {
            widget.delegate.clearResults(context);
          },
        );
      }

      titleWidget = TextField(
        controller: widget.delegate._queryTextController,
        focusNode: focusNode,
        style: theme.textTheme.titleLarge,
        textInputAction: widget.delegate.textInputAction,
        keyboardType: widget.delegate.keyboardType,
        onSubmitted: (value) {
          widget.delegate.showResults(context);
        },
        decoration: InputDecoration(
          hintText: widget.delegate.searchFieldHint ?? MaterialLocalizations.of(context).searchFieldLabel,
          isDense: true,
          suffixIcon: clearButton,
          suffixIconConstraints: const BoxConstraints(
            minHeight: 32.0,
            minWidth: 32.0,
          ),
        ),
      );
    }

    return Theme(
      data: theme,
      child: Scaffold(
        appBar: AppBar(
          leading: widget.delegate.buildLeading(context),
          title: titleWidget ?? widget.delegate.title,
          actions: widget.delegate.buildActions(context),
          bottom: widget.delegate.buildBottom(context),
        ),
        body: KeyedSubtree(
          key: ValueKey<String>(widget.delegate.query),
          child: widget.delegate.buildResults(context),
        ),
      ),
    );
  }
}
