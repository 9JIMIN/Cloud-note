import 'package:flutter/material.dart';

import 'text_field.dart';

class Toolbar extends StatelessWidget {
  const Toolbar({Key key, this.onSelected, this.selectedType}): super(key: key);

  final InputType selectedType;
  final ValueChanged<InputType> onSelected;

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: Size.fromHeight(56),
      child: Material(
        elevation: 4.0,
        color: Colors.white,
        child: Row(
          children: <Widget>[
            IconButton(
              icon: Icon(
                Icons.format_size,
                color: selectedType == InputType.H1
                  ? Colors.deepPurple
                  : Colors.black
              ),
              onPressed: () => onSelected(InputType.H1)
            ),
            IconButton(
              icon: Icon(
                Icons.format_quote,
                color: selectedType == InputType.QUOTE
                  ? Colors.deepPurple
                  : Colors.black
              ),
              onPressed: () => onSelected(InputType.QUOTE)
            ),
            IconButton(
              icon: Icon(
                Icons.format_list_bulleted,
                color: selectedType == InputType.BULLET
                  ? Colors.deepPurple
                  : Colors.black
              ),
              onPressed: () => onSelected(InputType.BULLET)
            ),
            IconButton(
              icon: Icon(
                Icons.photo,
                color: selectedType == InputType.IMG
                  ? Colors.deepPurple
                  : Colors.black
              ),
              onPressed: () => onSelected(InputType.IMG)
            )
          ]
        )
      ),
    );
  }
}