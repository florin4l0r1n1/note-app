import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:note_app/models/note_list.dart';
import 'package:provider/provider.dart';
import '../providers/auth.dart';

class NoteItem extends StatelessWidget {
  final String dateTime;
  final String name;
  final String content;
  final String noteId;

  NoteItem(this.content, this.dateTime, this.name, this.noteId);

  @override
  Widget build(BuildContext context) {
    final authData = Provider.of<Auth>(context, listen: false);
    final note = Provider.of<NoteList>(context);
    return Dismissible(
      key: UniqueKey(),
      background: Container(
        decoration: BoxDecoration(color: Colors.red[900].withOpacity(0.5)),
        child: Icon(
          Icons.delete,
          color: Colors.white,
          size: 40,
        ),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20),
      ),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) {
        return showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
                  title: Text('Are you sure?'),
                  content: Text('Do you want to remove the note?'),
                  backgroundColor: Colors.red[900].withOpacity(0.2),
                  actions: <Widget>[
                    TextButton(
                      child: Text('No', style: TextStyle(color: Colors.red)),
                      onPressed: () {
                        Navigator.of(ctx).pop(false);
                      },
                    ),
                    TextButton(
                      child: Text('Yes', style: TextStyle(color: Colors.green)),
                      onPressed: () {
                        Navigator.of(ctx).pop(true);
                      },
                    ),
                  ],
                ));
      },
      onDismissed: (direction) {
        note.items.remove(noteId);

        note.items.removeWhere((element) => element.id == noteId);
        Provider.of<NoteList>(context, listen: false)
            .removeItem(noteId, authData.userId);
      },
      child: Container(
        padding: EdgeInsets.all(5),
        decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [BoxShadow(offset: Offset(0, 10), blurRadius: 10)],
            borderRadius: BorderRadius.all(Radius.circular(20))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                            fontSize: 16, letterSpacing: 1, color: Colors.red),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        content.length > 50
                            ? '${content.substring(0, 50)}.....'
                            : content,
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                )
              ],
            ),
            Text(dateTime.toString())
          ],
        ),
      ),
      // ),
    );
  }
}
