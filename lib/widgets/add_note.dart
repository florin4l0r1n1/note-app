import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:note_app/models/note.dart';
import '../models/note.dart';
import 'package:provider/provider.dart';
import '../models/note_list.dart';
// import '../providers/auth.dart';

class AddNote extends StatefulWidget {
  static const routeName = '/addNotes';
  @override
  _AddNoteState createState() => _AddNoteState();
}

class _AddNoteState extends State<AddNote> {
  final _form = GlobalKey<FormState>();
  TextEditingController titleControler = new TextEditingController();

  var _newNotes = Notes(id: null, title: '', content: '', dateTime: '');

  Future<void> _saveNote() async {
    final isvalid = _form.currentState.validate();
    if (!isvalid) {
      return;
    }
    _form.currentState.save();
    Navigator.of(context).pop();

    try {
      await Provider.of<NoteList>(context, listen: false).addNotes(_newNotes);
    } catch (err) {
      print(err.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final DateTime dateTime = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd – kk:mm').format(dateTime);
    Size size = MediaQuery.of(context).size;
    return Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.teal, Colors.purple])),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          elevation: 0.0,
          backgroundColor: Colors.transparent,
          title: Text('Add notes '),
          actions: [IconButton(icon: Icon(Icons.save), onPressed: _saveNote)],
        ),
        body: Center(
          child: Form(
            key: _form,
            child: Container(
              height: size.height * 0.7,
              margin: EdgeInsets.all(20),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(30))),
              child: Card(
                margin: EdgeInsets.all(30),
                elevation: 20,
                child: SingleChildScrollView(
                  child: Container(
                    padding: EdgeInsets.all(10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        TextFormField(
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please enter a Title';
                            }
                            return null;
                          },
                          controller: titleControler,
                          decoration: InputDecoration(
                            hintText: 'Title',
                          ),
                          onSaved: (value) {
                            _newNotes = Notes(
                                title: value,
                                id: _newNotes.id,
                                content: _newNotes.content,
                                dateTime: formattedDate);
                            print(value.toString());
                          },
                          textInputAction: TextInputAction.next,
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        TextFormField(
                          validator: (value) {
                            if (value.isEmpty) {
                              return "The content cannon't be empty";
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _newNotes = Notes(
                                title: _newNotes.title,
                                content: value,
                                id: _newNotes.id,
                                dateTime: formattedDate);
                            print(value.toString());
                          },
                          maxLines: null,
                          keyboardType: TextInputType.multiline,
                          decoration: InputDecoration(hintText: 'Note content'),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text('$formattedDate')
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
