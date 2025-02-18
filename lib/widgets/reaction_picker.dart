import 'package:flutter/material.dart';

class ReactionPicker extends StatelessWidget {
  final Function(String) onReactionSelected;

  const ReactionPicker({required this.onReactionSelected});

  @override
  Widget build(BuildContext context) {
    const reactions = ['❤️', '😂', '😮', '😢', '👍', '👎'];

    return Container(
      height: 60,
      color: Colors.white,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: reactions.length,
        itemBuilder: (ctx, index) => IconButton(
          icon: Text(reactions[index], style: TextStyle(fontSize: 28)),
          onPressed: () => onReactionSelected(reactions[index]),
        ),
      ),
    );
  }
}
