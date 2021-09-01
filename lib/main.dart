import 'package:flutter/material.dart';
import 'package:note_app/providers/auth.dart';
import 'package:note_app/screens/auth_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:note_app/screens/note_display.dart';
import 'package:note_app/widgets/add_note.dart';
import 'package:provider/provider.dart';
import './screens/note_screen.dart';
import 'models/note_list.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Firebase.initializeApp(),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return MultiProvider(
                providers: [
                  ChangeNotifierProvider.value(value: Auth()),
                  ChangeNotifierProxyProvider<Auth, NoteList>(
                      create: (ctx) => NoteList(),
                      update: (ctx, auth, notes) =>
                          notes..update(auth.token, auth.userId)),
                ],
                child: Consumer<Auth>(
                  builder: (ctx, auth, _) => MaterialApp(
                      debugShowCheckedModeBanner: false,
                      title: 'OnNotes',
                      theme: ThemeData(
                          backgroundColor: Colors.limeAccent[100],
                          primaryColor: Colors.grey[800],
                          accentColor: Colors.indigo[400],
                          buttonTheme: ButtonTheme.of(context)
                              .copyWith(buttonColor: Colors.red[300])),
                      home: auth.isAuth
                          ? NoteScreen()
                          : FutureBuilder(
                              future: auth.tryAutologin(),
                              builder: (ctx, authResultSnapshot) =>
                                  authResultSnapshot.connectionState ==
                                          ConnectionState.waiting
                                      ? Center(
                                          child: CircularProgressIndicator())
                                      : AuthScreen(),
                            ),
                      routes: {
                        AddNote.routeName: (ctx) => AddNote(),
                        NoteScreen.routeName: (ctx) => NoteScreen(),
                        NoteDisplay.routeName: (ctx) => NoteDisplay(),
                      }),
                ));
            // }
          } else {
            if (snapshot.connectionState != ConnectionState.done) {
              return Container(
                  // child: Text(
                  //     'An error has occured. Please check the internet connection')
                  );
            }
          }
        });
  }

  @override
  void initState() {
    Firebase.initializeApp().whenComplete(() => print('completed'));
    super.initState();
  }
}
