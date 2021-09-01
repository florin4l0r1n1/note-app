import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:note_app/models/note_list.dart';
import 'package:provider/provider.dart';
import 'package:note_app/models/note.dart';

class NoteDisplay extends StatefulWidget {
  static const routeName = '/noteDisplay';

  final Notes noteItem;
  NoteDisplay({Key key, this.noteItem}) : super(key: key);

  @override
  _NoteDisplayState createState() => _NoteDisplayState();
}

class _NoteDisplayState extends State<NoteDisplay> {
  TextEditingController contentControler;
  String contentvalue = '';
  bool isEdit = false;
  String newValue = '';

  @override
  void initState() {
    contentControler = TextEditingController(text: widget.noteItem.content);
    super.initState();
  }

  @override
  void dispose() {
    contentControler.dispose();
    super.dispose();
  }

  Future<void> _saveContent(String val) async {
    final DateTime dateTime = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd – kk:mm').format(dateTime);
    final newNote = Notes(
        title: widget.noteItem.title,
        id: widget.noteItem.id,
        content: val,
        dateTime: formattedDate);

    try {
      await Provider.of<NoteList>(context, listen: false)
          .updateNotes(widget.noteItem.id, newNote);
    } catch (err) {
      print(err.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.noteItem.title),
        actions: [
          isEdit
              ? IconButton(
                  icon: Icon(Icons.save),
                  onPressed: () {
                    setState(() {
                      _saveContent(contentvalue);
                      isEdit = false;
                    });
                  })
              : IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    setState(() {
                      isEdit = true;
                    });
                  })
        ],
      ),
      body: Container(
        padding: EdgeInsets.all(10),
        child: isEdit
            ? TextField(
                style: TextStyle(
                  fontSize: 18,
                ),
                enabled: true,
                onSubmitted: (newContent) {
                  setState(
                    () {
                      _saveContent(newContent);
                      isEdit = false;
                    },
                  );
                },
                autofocus: true,
                controller: contentControler,
                onChanged: (text) => {contentvalue = text},
              )
            : TextField(
                enabled: false,
                onSubmitted: (newContent) {
                  setState(
                    () {
                      _saveContent(newContent);
                      isEdit = false;
                    },
                  );
                },
                autofocus: true,
                controller: contentControler,
              ),
      ),
    );
  }
}
