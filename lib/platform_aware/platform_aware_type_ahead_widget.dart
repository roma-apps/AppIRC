import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/platform_aware/platform_aware.dart';
import 'package:flutter_typeahead/cupertino_flutter_typeahead.dart' as CupertinoTypeAhead;
import 'package:flutter_typeahead/flutter_typeahead.dart' as MaterialTypeAhead;


typedef FutureOr<List<T>> SuggestionsCallback<T>(String pattern);
typedef Widget ItemBuilder<T>(BuildContext context, T itemData);
typedef void SuggestionSelectionCallback<T>(T suggestion);
typedef Widget ErrorBuilder(BuildContext context, Object error);

typedef AnimationTransitionBuilder(BuildContext context, Widget child,
    AnimationController controller);

class AndroidTypeAheadData {
  final MaterialTypeAhead.TextFieldConfiguration textFieldConfiguration;

  MaterialTypeAhead.SuggestionsBoxDecoration suggestionsBoxDecoration;

  MaterialTypeAhead.SuggestionsBoxController suggestionsBoxController;

  AndroidTypeAheadData(
      {this.textFieldConfiguration: const MaterialTypeAhead.TextFieldConfiguration(),
        this.suggestionsBoxDecoration: const MaterialTypeAhead.SuggestionsBoxDecoration(),
        this.suggestionsBoxController});
}

class CupertinoTypeAheadData {
  final CupertinoTypeAhead
      .CupertinoTextFieldConfiguration textFieldConfiguration;
  final CupertinoTypeAhead
      .CupertinoSuggestionsBoxDecoration suggestionsBoxDecoration;
  final CupertinoTypeAhead
      .CupertinoSuggestionsBoxController suggestionsBoxController;

  CupertinoTypeAheadData({ this.textFieldConfiguration: const CupertinoTypeAhead
      .CupertinoTextFieldConfiguration(),
    this.suggestionsBoxDecoration: const CupertinoTypeAhead
        .CupertinoSuggestionsBoxDecoration(),
    this.suggestionsBoxController});


}

Widget createPlatformTypeAhead<T>(BuildContext context, {Key key,
  @required SuggestionsCallback suggestionsCallback,
  @required ItemBuilder<T> itemBuilder,
  @required SuggestionSelectionCallback<T> onSuggestionSelected,
  @required CupertinoTypeAheadData Function() ios,
  @required AndroidTypeAheadData Function() android,
  Duration debounceDuration: const Duration(milliseconds: 300),
  WidgetBuilder loadingBuilder,
  WidgetBuilder noItemsFoundBuilder,
  ErrorBuilder errorBuilder,
  AnimationTransitionBuilder transitionBuilder,
  double animationStart: 0.25,
  Duration animationDuration: const Duration(milliseconds: 500),
  bool getImmediateSuggestions: false,
  double suggestionsBoxVerticalOffset: 5.0,
  AxisDirection direction: AxisDirection.down,
  bool hideOnLoading: false,
  bool hideOnEmpty: false,
  bool hideOnError: false,
  bool hideSuggestionsOnKeyboardHide: true,
  bool keepSuggestionsOnLoading: true,
  bool keepSuggestionsOnSuggestionSelected: false,
  bool autoFlipDirection: false}) {
  switch (detectCurrentUIPlatform()) {
    case UIPlatform.MATERIAL:
      var data = android();
      return MaterialTypeAhead.TypeAheadField(
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
          keepSuggestionsOnSuggestionSelected: keepSuggestionsOnSuggestionSelected,
          autoFlipDirection: autoFlipDirection

      );
      break;
    case UIPlatform.CUPERTINO:
      var data = ios();

      return CupertinoTypeAhead.CupertinoTypeAheadField(
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
          keepSuggestionsOnSuggestionSelected: keepSuggestionsOnSuggestionSelected,
          autoFlipDirection: autoFlipDirection

      );
      break;
  }
  throw Exception("invalid platform");
}
