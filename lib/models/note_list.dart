import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'note.dart';

class NoteList with ChangeNotifier {
  List<Notes> _items = [];

  String authToken;
  String userId;

  void update(
    String token,
    String id,
  ) {
    authToken = token;
    userId = id;
  }

  List<Notes> get items {
    return [..._items];
  }

  Notes fiindById(String id) {
    return _items.firstWhere((element) => element.id == id);
  }

  Future<void> addNotes(Notes notes) async {
    final url =
        'https://noteapp-b9d54-default-rtdb.firebaseio.com/Notes/$userId.json?auth=$authToken';

    try {
      final response = await http.post(url,
          body: json.encode({
            'title': notes.title,
            'id': notes.id,
            'content': notes.content,
            'dateTime': notes.dateTime
          }));

      final newNote = Notes(
          id: json.decode(response.body)['name'],
          title: notes.title,
          content: notes.content,
          dateTime: notes.dateTime);
      items.add(newNote);

      notifyListeners();
    } catch (error) {
      print('notes.err');
      print(error.toString());
    }
  }

  updateNotes(String id, Notes newNotes) {
    final notesIndex = _items.indexWhere((notes) => notes.id == id);
    try {
      if (notesIndex >= 0) {
        final url =
            'https://noteapp-b9d54-default-rtdb.firebaseio.com/Notes/$userId/$id.json?auth=$authToken';
        http.patch(url,
            body: json.encode({
              'title': newNotes.title,
              'content': newNotes.content,
              'dateTime': newNotes.dateTime
            }));
        _items[notesIndex] = newNotes;
        notifyListeners();
      } else {
        print('updatefaield');
      }
    } catch (err) {
      print(err.toString());
    }
  }

  Future<void> fetchAndSetNotes(String querry, String uid) async {
    final url =
        'https://noteapp-b9d54-default-rtdb.firebaseio.com/Notes/$userId.json?auth=$authToken';
    try {
      final resp = await http.get(url);
      final extracted = json.decode(resp.body) as Map<String, dynamic>;
      print('Note list fetchNotes');
      if (extracted == null) {
        return;
      }
      final List<Notes> notes = [];
      final List<Notes> search = [];
      extracted.forEach((notesId, notesData) {
        addNote(notes, notesData, notesId);
        _items = notes.reversed.toList();
        notifyListeners();
      });

      if (querry != null) {
        extracted.forEach((notesId, notesData) {
          String title = notesData['title'].toString();
          String content = notesData['content'].toString();

          if (title.contains(querry) ||
              (title.toLowerCase().contains(querry) ||
                  (content.contains(querry)) ||
                  content.toLowerCase().contains(querry))) {
            addNote(search, notesData, notesId);
            _items = search.reversed.toList();
            notifyListeners();
          }
        });
      }
    } catch (err) {
      print(err.toString());
    }
  }

  void addNote(List<Notes> notes, dynamic data, String id) {
    notes.add(Notes(
        title: data['title'],
        id: id.toString(),
        content: data['content'],
        dateTime: data['dateTime']));
  }

  void removeItem(String noteId, String uid) async {
    final notesIndex = _items.indexWhere((notes) => notes.id == noteId);
    _items.removeWhere((element) => element.id == noteId);

    print(_items.length);
    print('reoveCalled');

    if (notesIndex >= 0) {
      try {
        final url =
            'https://noteapp-b9d54-default-rtdb.firebaseio.com/Notes/$userId/$noteId.json?auth=$authToken';

        http.delete(url);
      } catch (err) {
        print(err.toString());
      }
    }
  }
}
