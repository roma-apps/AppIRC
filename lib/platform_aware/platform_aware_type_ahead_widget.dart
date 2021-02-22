import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_typeahead/cupertino_flutter_typeahead.dart'
    as cupertino_flutter_typeahead;
import 'package:flutter_typeahead/flutter_typeahead.dart' as flutter_typeahead;

typedef FutureOr<List<T>> SuggestionsCallback<T>(String pattern);
typedef Widget ItemBuilder<T>(BuildContext context, T itemData);
typedef void SuggestionSelectionCallback<T>(T suggestion);
typedef Widget ErrorBuilder(BuildContext context, Object error);

typedef Widget AnimationTransitionBuilder(
    BuildContext context, Widget child, AnimationController controller);

class AndroidTypeAheadData {
  final flutter_typeahead.TextFieldConfiguration textFieldConfiguration;

  flutter_typeahead.SuggestionsBoxDecoration suggestionsBoxDecoration;

  flutter_typeahead.SuggestionsBoxController suggestionsBoxController;

  AndroidTypeAheadData({
    this.textFieldConfiguration =
        const flutter_typeahead.TextFieldConfiguration(),
    this.suggestionsBoxDecoration =
        const flutter_typeahead.SuggestionsBoxDecoration(),
    this.suggestionsBoxController,
  });
}

class CupertinoTypeAheadData {
  final cupertino_flutter_typeahead.CupertinoTextFieldConfiguration
      textFieldConfiguration;
  final cupertino_flutter_typeahead.CupertinoSuggestionsBoxDecoration
      suggestionsBoxDecoration;
  final cupertino_flutter_typeahead.CupertinoSuggestionsBoxController
      suggestionsBoxController;

  CupertinoTypeAheadData({
    this.textFieldConfiguration =
        const cupertino_flutter_typeahead.CupertinoTextFieldConfiguration(),
    this.suggestionsBoxDecoration =
        const cupertino_flutter_typeahead.CupertinoSuggestionsBoxDecoration(),
    this.suggestionsBoxController,
  });
}

Widget createPlatformTypeAhead<T>(
  BuildContext context, {
  Key key,
  @required SuggestionsCallback suggestionsCallback,
  @required ItemBuilder<T> itemBuilder,
  @required SuggestionSelectionCallback<T> onSuggestionSelected,
  @required CupertinoTypeAheadData Function() ios,
  @required AndroidTypeAheadData Function() android,
  Duration debounceDuration = const Duration(milliseconds: 300),
  WidgetBuilder loadingBuilder,
  WidgetBuilder noItemsFoundBuilder,
  ErrorBuilder errorBuilder,
  AnimationTransitionBuilder transitionBuilder,
  double animationStart = 0.25,
  Duration animationDuration = const Duration(milliseconds: 500),
  bool getImmediateSuggestions = false,
  double suggestionsBoxVerticalOffset = 5.0,
  AxisDirection direction = AxisDirection.down,
  bool hideOnLoading = false,
  bool hideOnEmpty = false,
  bool hideOnError = false,
  bool hideSuggestionsOnKeyboardHide = true,
  bool keepSuggestionsOnLoading = true,
  bool keepSuggestionsOnSuggestionSelected = false,
  bool autoFlipDirection = false,
}) {
  var platformProviderState = PlatformProvider.of(context);

  switch (platformProviderState.platform) {
    case TargetPlatform.android:
      var data = android();
      return flutter_typeahead.TypeAheadField(
        suggestionsCallback: (pattern) => suggestionsCallback(pattern),
        itemBuilder: (context, item) => itemBuilder(context, item),
        onSuggestionSelected: (selected) => onSuggestionSelected(selected),
        textFieldConfiguration: data.textFieldConfiguration,
        suggestionsBoxDecoration: data.suggestionsBoxDecoration,
        suggestionsBoxController: data.suggestionsBoxController,
        debounceDuration: debounceDuration,
        loadingBuilder: loadingBuilder,
        noItemsFoundBuilder: noItemsFoundBuilder,
        errorBuilder: errorBuilder,
        transitionBuilder: transitionBuilder,
        animationStart: animationStart,
        animationDuration: animationDuration,
        getImmediateSuggestions: getImmediateSuggestions,
        suggestionsBoxVerticalOffset: suggestionsBoxVerticalOffset,
        direction: direction,
        hideOnLoading: hideOnLoading,
        hideOnEmpty: hideOnEmpty,
        hideOnError: hideOnError,
        hideSuggestionsOnKeyboardHide: hideSuggestionsOnKeyboardHide,
        keepSuggestionsOnLoading: keepSuggestionsOnLoading,
        keepSuggestionsOnSuggestionSelected:
            keepSuggestionsOnSuggestionSelected,
        autoFlipDirection: autoFlipDirection,
      );
      break;
    case TargetPlatform.iOS:
      var data = ios();

      return cupertino_flutter_typeahead.CupertinoTypeAheadField(
        suggestionsCallback: (pattern) => suggestionsCallback(pattern),
        itemBuilder: (context, item) => itemBuilder(context, item),
        onSuggestionSelected: (selected) => onSuggestionSelected(selected),
        textFieldConfiguration: data.textFieldConfiguration,
        suggestionsBoxDecoration: data.suggestionsBoxDecoration,
        suggestionsBoxController: data.suggestionsBoxController,
        debounceDuration: debounceDuration,
        loadingBuilder: loadingBuilder,
        noItemsFoundBuilder: noItemsFoundBuilder,
        errorBuilder: errorBuilder,
        transitionBuilder: transitionBuilder,
        animationStart: animationStart,
        animationDuration: animationDuration,
        getImmediateSuggestions: getImmediateSuggestions,
        suggestionsBoxVerticalOffset: suggestionsBoxVerticalOffset,
        direction: direction,
        hideOnLoading: hideOnLoading,
        hideOnEmpty: hideOnEmpty,
        hideOnError: hideOnError,
        hideSuggestionsOnKeyboardHide: hideSuggestionsOnKeyboardHide,
        keepSuggestionsOnLoading: keepSuggestionsOnLoading,
        keepSuggestionsOnSuggestionSelected:
            keepSuggestionsOnSuggestionSelected,
        autoFlipDirection: autoFlipDirection,
      );
      break;
    default:
      throw Exception("invalid platform");
  }
}
