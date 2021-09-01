import 'dart:ui';
import 'package:note_app/models/note_list.dart';
import 'package:note_app/widgets/note_item.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:provider/provider.dart';
import '../widgets/add_note.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../providers/auth.dart';
import 'package:flutter/services.dart';
import 'note_display.dart';

class NoteScreen extends StatefulWidget {
  static const routeName = '/noteScreen';

  @override
  _NoteScreenState createState() => _NoteScreenState();
}

class _NoteScreenState extends State<NoteScreen> {
  Widget currentPage;
  String search;
  bool isLoading = false;

  Future<void> _notes() async {
    print('_notes()');
    try {
      final authData = Provider.of<Auth>(context, listen: false);
      await Provider.of<NoteList>(context, listen: false)
          .fetchAndSetNotes(search, authData.userId);

      print('Note Screen FetchAndSetNotes');
    } catch (err) {
      print(err.toString());
    }
  }

  @override
  void didUpdateWidget(covariant NoteScreen oldWidget) {
    _notes();
    super.didUpdateWidget(oldWidget);
  }

  @override
  void initState() {
    _notes();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final note = Provider.of<NoteList>(context);
    print(note.items.length);
    SystemChrome.setEnabledSystemUIOverlays([]);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(alignment: Alignment.topCenter, children: <Widget>[
        Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.teal, Colors.purple])),
            child: Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                  actions: [
                    IconButton(
                      icon: Icon(Icons.add),
                      onPressed: () {
                        Navigator.of(context).pushNamed(AddNote.routeName);
                      },
                    ),
                    IconButton(
                        icon: Icon(Icons.logout),
                        onPressed: () {
                          Provider.of<Auth>(context, listen: false).logout();
                        })
                  ],
                  title: Text(
                    'NoteApp',
                    style: TextStyle(fontSize: 20),
                  ),
                  elevation: 0.0,
                  backgroundColor: Colors.transparent),
              body: SingleChildScrollView(
                child: Column(children: [
                  Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.10,
                        width: MediaQuery.of(context).size.width,
                        child: FloatingSearchBar(
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                          hint: 'Search',
                          actions: [],
                          onQueryChanged: (querry) {
                            setState(() {
                              try {
                                search = querry;
                              } catch (err) {
                                print(err.toString());
                              }

                              _notes();
                            });
                          },
                          builder: (context, transition) {
                            return ClipRRect();
                          },
                        ),
                      )),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.80,
                      width: MediaQuery.of(context).size.width,
                      child: FutureBuilder(
                        builder: (context, snapshot) =>
                            snapshot.connectionState == ConnectionState.waiting
                                ? CircularProgressIndicator()
                                : RefreshIndicator(
                                    onRefresh: () => _notes(),
                                    child: ListView.builder(
                                      padding: EdgeInsets.all(10),
                                      itemCount: note.items.length,
                                      itemBuilder: (context, i) => Column(
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      NoteDisplay(
                                                    noteItem: note.items[i],
                                                  ),
                                                ),
                                              );
                                            },
                                            child: note.items[i] != null
                                                ? Padding(
                                                    padding: EdgeInsets.all(5),
                                                    child: NoteItem(
                                                        note.items[i].content,
                                                        note.items[i].dateTime,
                                                        note.items[i].title,
                                                        note.items[i].id),
                                                  )
                                                : Container(
                                                    child: Center(
                                                      child: Text(
                                                          'No notes Available'),
                                                    ),
                                                  ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                      ),
                    ),
                  ),
                ]),
              ),
            )),
      ]),
    );
  }
}
