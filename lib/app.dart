// Copyright 2018-present the Flutter authors. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:flutter/material.dart';


import 'home.dart';
import 'login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'globals.dart';
import 'package:flutter/services.dart';
import 'package:geocoder/geocoder.dart';
import 'package:location/location.dart';
import 'dart:async';
import 'check_update.dart';
import 'package:Shrine/services/services.dart';


class ShrineApp extends StatefulWidget {

  @override
  _ShrineAppState createState() => _ShrineAppState();
}
class _ShrineAppState extends State<ShrineApp> {
  Map<String, double> _currentLocation;
  StreamSubscription<Map<String, double>> _locationSubscription;
  Location _location = new Location();
  String streamlocationaddr="";
  String lat="";
  String long="";
  int response;
  int responsestate;
  int mand_login=0; // mandatory update is false by default.
  String cur_ver='3.0.8',new_ver='3.0.8';
  Widget _defaultHome = new LoginPage();
  @override
  void initState() {
    super.initState();
    getShared();
    checkNow().then((res){
      setState(() {
        new_ver=res;
      });
    });
  }

  getShared() async{
    final prefs = await SharedPreferences.getInstance();
      setState(() {
        response = prefs.getInt('response') ?? 0;
        //print("Response "+response.toString());
      });
  }
  // Set default home.
  // Get result of the login function.

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ubiAttendance',
      home: (cur_ver == new_ver)?HomePage():CheckUpdate(),
      //home: (true)?HomePage():CheckUpdate(),
      routes: {
        // When we navigate to the "/" route, build the FirstScreen Widget
        '/login': (context) => LoginPage(),
        // When we navigate to the "/second" route, build the SecondScreen Widget
        '/home': (context) => HomePage()

  },
    );
  }
  getUpdate(response){
    return (response==1) ? new HomePage() : new LoginPage();
  }
}


