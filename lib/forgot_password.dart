// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'package:flutter/material.dart';
import 'package:Shrine/drawer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Shrine/services/gethome.dart';
import 'package:Shrine/services/services.dart';
import 'package:intl/intl.dart';
import 'package:datetime_picker_formfield/time_picker_formfield.dart';
import 'home.dart';
import 'login.dart';


class ForgotPassword extends StatefulWidget {
  @override
  _ForgotPassword createState() => _ForgotPassword();
}
class _ForgotPassword extends State<ForgotPassword> {
  bool isloading = false;
  String username="";
  final _username = TextEditingController();
  FocusNode __username = new FocusNode();
  final _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  int response=0;
  bool err=false;
  bool succ=false;
  bool _isButtonDisabled=false;
  bool login=false;

  int _currentIndex = 2;
  @override
  void initState() {
    super.initState();
    initPlatformState();
  }
  // Platform messages are asynchronous, so we initialize in an async method.
  initPlatformState() async {

  }


  @override
  Widget build(BuildContext context) {
    return getmainhomewidget();
  }

  void showInSnackBar(String value) {
    final snackBar = SnackBar(
        content: Text(value,textAlign: TextAlign.center,));
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }

  getmainhomewidget(){
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            new Text('ubiAttendance', style: new TextStyle(fontSize: 20.0)),
          ],
        ),
        leading: IconButton(icon:Icon(Icons.arrow_back),onPressed:(){
          Navigator.pop(context);
          /*  Navigator.push(
            context,
           MaterialPageRoute(builder: (context) => TimeoffSummary()),
          );*/
        },),
        backgroundColor: Colors.teal,
      ),
      body:  mainbodyWidget(),
    );

  }
  loader(){
    return new Container(
      child: Center(
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Image.asset(
                  'assets/spinner.gif', height: 80.0, width: 80.0),
            ]),
      ),
    );
  }


  mainbodyWidget(){
    return Center(
      child: Form(
        key: _formKey,
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            children: <Widget>[
          Center(
            child:Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(height: MediaQuery.of(context).size.height*0.1),
            Center(child:
            Text("Reset Password",style: new TextStyle(fontSize: 22.0,color: Colors.black54)),
            ),
                  SizedBox(height: 10.0),
                  succ==false?Container(
                      child: Row(
                        children: <Widget>[
                          Container(
                            width: MediaQuery.of(context).size.width*.8,
                            child: TextFormField(
                              controller: _username,
                              focusNode: __username,
                              keyboardType: TextInputType.text,
                              decoration: InputDecoration(
                                  labelText: 'Email/Phone',
                                  prefixIcon: Padding(
                                    padding: EdgeInsets.all(0.0),
                                    child: Icon(
                                      Icons.person_outline,
                                      color: Colors.grey,
                                    ), // icon is 48px widget.
                                  )
                              ),
                              validator: (value) {
                                if (value.isEmpty || value==null) {
//                                  FocusScope.of(context).requestFocus(__oldPass);
                                  return 'Please enter valid Email or Phone';
                                }
                              },

                            ),
                          ),
                        ],
                      )
                  ):Center(), //Enter date
                  SizedBox(height: 12.0),

                  succ==false?ButtonBar(
                    children: <Widget>[
                      FlatButton(
                        shape: Border.all(color: Colors.black54),
                        child: Text('CANCEL'),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      RaisedButton(
                        child: _isButtonDisabled==false?Text('SUBMIT',style: TextStyle(color: Colors.white),):Text('WAIT...',style: TextStyle(color: Colors.white),),
                        color: Colors.orangeAccent,
                        onPressed: () {
                          if (_formKey.currentState.validate()) {
                            if (_username.text == ''||_username.text == null) {
                              showInSnackBar("Please Enter Email/Phone");
                              FocusScope.of(context).requestFocus(__username);
                            } else {
                              if(_isButtonDisabled)
                                return null;
                              setState(() {
                                _isButtonDisabled=true;
                              });
                              resetMyPassword(_username.text).then((res){
                                if(res==1) {
                                  username = _username.text;
                                  _username.text='';
                                 /* showInSnackBar(
                                      "Request submitted successfully");*/
                                  showDialog(context: context, child:
                                  new AlertDialog(
                                    content: new Text("Please check your mail for the Password reset link."),
                                  )
                                  );
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => LoginPage()),
                                  );
                                  setState(() {
                                    login=true;
                                    succ=true;
                                    err=false;
                                    _isButtonDisabled=false;
                                  });
                                }
                                else {
                                  showInSnackBar("Email Not Found.");
                                  setState(() {
                                    login=false;
                                    succ=false;
                                    err=true;
                                    _isButtonDisabled=false;
                                  });
                                }
                              }).catchError((onError){
                                showInSnackBar("Unable to call reset password service");
                                setState(() {
                                  login=false;
                                  succ=false;
                                  err=false;
                                  _isButtonDisabled=false;
                                });
                               // showInSnackBar("Unable to call reset password service::"+onError.toString());
                                print(onError);
                              });
                            }
                          }
                        },
                      ),
                    ],
                  ):Center(),
                  err==true?Text('Invalid Email/Phone.',style: TextStyle(color: Colors.red,fontSize: 16.0),):Center(),
                /*  succ==true?Text('Please check your mail for the Password reset link. After you have reset the password, please click below link to login.',style: TextStyle(fontSize: 16.0),):Center(),
                  login==true?InkWell(
                    child: Text('\nClick here to Login',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16.0,color: Colors.teal),),
                    onTap:() async{
                      final prefs = await SharedPreferences.getInstance();
                      prefs.setString('username', username);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                      );
                    } ,
                  ):Center(),*/
                ],
              ),
          )
            ],
          ),
        ),
      ),
    );
  }
}