import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth.dart';

enum AuthMode { SignUp, LogIn }

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  AuthMode _authMode = AuthMode.LogIn;
  final _passContrler = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey();

  // var _isLoading = false;
  // var _signInMode = true;

  Map<String, String> _authData = {
    'email': '',
    'password': '',
  };

  void _switchAuthMode() {
    if (_authMode == AuthMode.LogIn) {
      setState(() {
        _authMode = AuthMode.SignUp;
      });
    } else {
      setState(() {
        _authMode = AuthMode.LogIn;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState.validate()) {
      print('validate');
      return;
    }
    _formKey.currentState.save();
    print('saved');
    setState(() {
      // _isLoading = true;
    });

    try {
      if (_authMode == AuthMode.LogIn) {
        await Provider.of<Auth>(context, listen: false)
            .logIn(_authData['email'], _authData['password']);
      } else {
        await Provider.of<Auth>(context, listen: false)
            .singUp(_authData['email'], _authData['password']);
      }
    } on HttpException catch (error) {
      print(error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;

    return Scaffold(
      body: Form(
        key: _formKey,
        child: Stack(children: [
          Container(
            height: deviceSize.height * 1.0,
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.teal, Colors.purple])),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Card(
                    elevation: 40.0,
                    shadowColor: Colors.black,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Container(
                      height: deviceSize.height * 0.5,
                      width: deviceSize.width * 0.6,
                      margin: EdgeInsets.all(20),
                      color: Colors.white,
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            TextFormField(
                                decoration:
                                    InputDecoration(labelText: 'E-mail'),
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value.isEmpty || !value.contains('@')) {
                                    return 'Invalid email';
                                  }
                                  return null;
                                },
                                onSaved: (value) {
                                  _authData['email'] = value;
                                  print(_authData['email']);
                                }),
                            TextFormField(
                              // ignore: missing_return
                              validator: (value) {
                                if (value.isEmpty || value.length < 5) {
                                  return 'Password is too short!';
                                }
                              },
                              controller: _passContrler,
                              decoration: InputDecoration(
                                labelText: 'Password',
                              ),
                              obscureText: true,
                              onSaved: (value) {
                                _authData['password'] = value;
                              },
                            ),
                            if (_authMode == AuthMode.SignUp)
                              TextFormField(
                                // controller: _passContrler,
                                decoration: InputDecoration(
                                  labelText: 'Comfirm password',
                                ),
                                obscureText: true,
                                validator: _authMode == AuthMode.SignUp
                                    // ignore: missing_return
                                    ? (value) {
                                        if (value != _passContrler.text) {
                                          return "Password don't match";
                                        }
                                      }
                                    : null,
                              ),
                            SizedBox(
                              height: 3,
                            ),
                            ElevatedButton(
                                onPressed: _submit,
                                child: Text(_authMode == AuthMode.LogIn
                                    ? 'LogIn'
                                    : 'SIGN UP')),
                            SizedBox(
                              height: 1,
                            ),
                            TextButton(
                                onPressed: _switchAuthMode,
                                child: Text("You don't have an account?"))
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ]),
      ),
    );
  }
}
