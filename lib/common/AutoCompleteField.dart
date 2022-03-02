import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:flutter/material.dart';

class AutoCompleteTextField extends StatelessWidget {
  AutoCompleteTextField(@required this.candidates, this.decoration,
      @required this.onSelected, this.initialValue) {
    _typeAheadController = TextEditingController(text: initialValue);
  }

  TextEditingController _typeAheadController;

  final List<String> candidates;
  final Function(String value) onSelected;
  final String initialValue;

  InputDecoration decoration = InputDecoration(border: InputBorder.none);

  List<String> getSuggestions(String query) {
    List<String> matches = List();
    matches.addAll(candidates);

    matches.retainWhere((s) => s.toLowerCase().startsWith(query.toLowerCase()));
    return matches;
  }

  @override
  Widget build(BuildContext context) {
    return TypeAheadFormField(
      textFieldConfiguration: TextFieldConfiguration(
          decoration: this.decoration, controller: this._typeAheadController),
      suggestionsCallback: (pattern) {
        return getSuggestions(pattern);
      },
      itemBuilder: (context, suggestion) {
        return ListTile(
          title: Text(suggestion),
        );
      },
      transitionBuilder: (context, suggestionBox, controller) {
        return suggestionBox;
      },
      onSuggestionSelected: (suggestion) {
        this._typeAheadController.text = suggestion;
        onSelected(suggestion);
      },
    );
  }
}
