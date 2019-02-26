// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'package:flutter/material.dart';
import 'package:Shrine/services/fetch_location.dart';
import 'package:simple_permissions/simple_permissions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'askregister.dart';
import 'package:Shrine/services/gethome.dart';
import 'package:Shrine/services/saveimage.dart';
import 'package:Shrine/model/timeinout.dart';
import 'attendance_summary.dart';
import 'punchlocation.dart';
import 'drawer.dart';
import 'timeoff_summary.dart';
import 'package:Shrine/services/services.dart';
import 'globals.dart';
import 'package:Shrine/services/newservices.dart';
import 'leave_summary.dart';
import 'package:flutter/services.dart';
import 'package:geocoder/geocoder.dart';
import 'package:location/location.dart';
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';
import 'globals.dart';
import 'punchlocation_summary.dart';
import 'settings.dart';
import 'profile.dart';
import 'reports.dart';
import 'timeoff_new.dart';
import 'services/services.dart';
import 'bulkatt.dart';
/*import 'openCameraInActivity.dart';
import 'package:camera/camera.dart';*/
import 'package:connectivity/connectivity.dart';

// This app is a stateful, it tracks the user's current choice.
class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  StreamLocation sl = new StreamLocation();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  /*var _defaultimage =
      new NetworkImage("http://ubiattendance.ubihrm.com/assets/img/avatar.png");*/
  var profileimage;
  bool _checkLoaded = true;
  int _currentIndex = 1;
  String userpwd = "new";
  String newpwd = "new";
  int Is_Delete=0;
  bool _visible = true;
  String location_addr = "";
  String location_addr1 = "";
  String streamlocationaddr = "";
  String admin_sts = '0';
  String mail_varified = '1';
  String lat = "";
  String long = "";
  String act = "";
  String act1 = "";
  int alertdialogcount = 0;
  Timer timer;
  Timer timer1;
  int response;
  final Widget removedChild = Center();
  String fname = "",
      lname = "",
      empid = "",
      email = "",
      status = "",
      orgid = "",
      orgdir = "",
      sstatus = "",
      org_name = "",
      desination = "",
      desinationId = "",
      profile,
      latit = "",
      longi = "";
  String aid = "";
  String shiftId = "";
  List<Widget> widgets;


  @override
  void initState() {
    super.initState();

    initPlatformState();
    setLocationAddress();
    startTimer();

  }


  @override
  void dispose() {
    super.dispose();
    timer.cancel();
  }
  startTimer() {
    const fiveSec = const Duration(seconds: 5);
    int count = 0;
    timer = new Timer.periodic(fiveSec, (Timer t) {
      //print("timmer is running");
      count++;
      //print("timer counter" + count.toString());
      setLocationAddress();
      if (stopstreamingstatus) {
        t.cancel();
        //print("timer canceled");
      }
    });
  }

  startTimer1() {
    const fiveSec = const Duration(seconds: 1);
    int count = 0;
    timer1 = new Timer.periodic(fiveSec, (Timer t) {
      print("timmer is running");
    });
  }

  setLocationAddress() async {
    if(this.mounted) {
      setState(() {
        streamlocationaddr = globalstreamlocationaddr;
        if (list != null && list.length > 0) {
          lat = list[list.length - 1]['latitude'].toString();
          long = list[list.length - 1]["longitude"].toString();
          if (streamlocationaddr == '') {
            streamlocationaddr = lat + ", " + long;
          }
        }
        if (streamlocationaddr == '') {
          sl.startStreaming(5);
          startTimer();
        }
        //print("home addr" + streamlocationaddr);
        //print(lat + ", " + long);
        //print(stopstreamingstatus.toString());
      });
    }
  }

  launchMap(String lat, String long) async {
    String url = "https://maps.google.com/?q=" + lat + "," + long;
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      //print('Could not launch $url');
    }
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  initPlatformState() async {



    /*await availableCameras();*/
    final prefs = await SharedPreferences.getInstance();
    empid = prefs.getString('empid') ?? '';
    orgdir = prefs.getString('orgdir') ?? '';
    desinationId = prefs.getString('desinationId') ?? '';
    response = prefs.getInt('response') ?? 0;


    if (response == 1) {

      Loc lock = new Loc();
      location_addr = await lock.initPlatformState();
      Home ho = new Home();
      act = await ho.checkTimeIn(empid, orgdir);
      ho.managePermission(empid, orgdir, desinationId);
      // //print(act);
      ////print("this is-----> "+act);
      ////print("this is main "+location_addr);
      setState(() {
        Is_Delete = prefs.getInt('Is_Delete') ?? 0;
        newpwd = prefs.getString('newpwd') ?? "";
        userpwd = prefs.getString('usrpwd') ?? "";
        print("New pwd"+newpwd+"  User ped"+userpwd);
        location_addr1 = location_addr;
        admin_sts = prefs.getString('sstatus').toString() ?? '0';
        mail_varified = prefs.getString('mail_varified').toString() ?? '0';
        alertdialogcount = globalalertcount;
        response = prefs.getInt('response') ?? 0;
        fname = prefs.getString('fname') ?? '';
        lname = prefs.getString('lname') ?? '';
        empid = prefs.getString('empid') ?? '';
        email = prefs.getString('email') ?? '';
        status = prefs.getString('status') ?? '';
        orgid = prefs.getString('orgid') ?? '';
        orgdir = prefs.getString('orgdir') ?? '';
        org_name = prefs.getString('org_name') ?? '';
        desination = prefs.getString('desination') ?? '';
        profile = prefs.getString('profile') ?? '';
        profileimage = new NetworkImage(profile);
        // //print("1-"+profile);
        profileimage.resolve(new ImageConfiguration()).addListener((_, __) {
          if (mounted) {
            setState(() {
              _checkLoaded = false;
            });
          }
        });
        // //print("2-"+_checkLoaded.toString());
        latit = prefs.getString('latit') ?? '';
        longi = prefs.getString('longi') ?? '';
        aid = prefs.getString('aid') ?? "";
        shiftId = prefs.getString('shiftId') ?? "";
        ////print("this is set state "+location_addr1);
        act1 = act;
        // //print(act1);
        streamlocationaddr = globalstreamlocationaddr;
      });

    /*  if(tracking==1) {
        try {
          const platform = const MethodChannel('attendance.flutter.io/back_ground_services');
          print("Tracking permission "+tracking.toString());
          //stoping previous background service
          *//*print("this is stop location background");
          final int result1 = await platform.invokeMethod(
            'stopLocationBackgroundService',{"empid":empid});*//*

          //starting new background service
          print("this is start location background");
          final int result = await platform.invokeMethod(
              'startLocationBackgroundService',{"empid":empid});
        } on PlatformException catch (e) {}
      }*/

    }
  }

  @override
  Widget build(BuildContext context) {
    (mail_varified=='0' && alertdialogcount==0 && admin_sts=='1')?Future.delayed(Duration.zero, () => _showAlert(context)):"";

    return (response == 0 || userpwd!=newpwd || Is_Delete!=0) ? new AskRegisterationPage() : getmainhomewidget();

    /* return MaterialApp(
      home: (response==0) ? new AskRegisterationPage() : getmainhomewidget(),
    );*/
  }

  void showInSnackBar(String value) {
    final snackBar = SnackBar(
        content: Text(
      value,
      textAlign: TextAlign.center,
    ));
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }

  getmainhomewidget() {
    return new WillPopScope(
        onWillPop: () async => true,
        child: new Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                new Text(org_name, style: new TextStyle(fontSize: 20.0)),
              ],
            ),
            automaticallyImplyLeading: false,
              backgroundColor: Colors.teal,
           // backgroundColor: Color.fromARGB(255,63,163,128),
          ),
          //bottomSheet: getQuickLinksWidget(),
          persistentFooterButtons: <Widget>[
            quickLinkList1(),

          ],

          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (newIndex) {
              if (newIndex == 2) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Settings()),
                );
                return;
              } else if (newIndex == 0) {
                (admin_sts == '1')
                    ? Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Reports()),
                      )
                    : Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ProfilePage()),
                      );

                return;
              }

              setState(() {
                _currentIndex = newIndex;
              });
            }, // this will be set when a new tab is tapped
            items: [
              (admin_sts == '1')
                  ? BottomNavigationBarItem(
                      icon: new Icon(
                        Icons.library_books,
                      ),
                      title: new Text('Reports'),
                    )
                  : BottomNavigationBarItem(
                      icon: new Icon(
                        Icons.person,
                      ),
                      title: new Text('Profile'),
                    ),
              BottomNavigationBarItem(
                icon: new Icon(
                  Icons.home,
                  color: Colors.orangeAccent,
                ),
                title: new Text('Home',
                    style: TextStyle(color: Colors.orangeAccent)),
              ),
              BottomNavigationBarItem(
                  icon: Icon(
                    Icons.settings,
                  ),
                  title: Text('Settings'))
            ],
          ),

          endDrawer: new AppDrawer(),
          body: (act1 == '') ? Center(child: loader()) : checkalreadylogin(),
        ));
  }

  checkalreadylogin() {

    ////print("---->"+response.toString());
    if (response == 1) {
      return new IndexedStack(
        index: _currentIndex,
        children: <Widget>[
          underdevelopment(),
         (streamlocationaddr != '') ? mainbodyWidget() : refreshPageWidgit(),
          //(false) ? mainbodyWidget() : refreshPageWidgit(),
          underdevelopment()
        ],
      );
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => AskRegisterationPage()),
        (Route<dynamic> route) => false,
      );
    }

   /* if(userpwd!=newpwd){
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => AskRegisterationPage()),
            (Route<dynamic> route) => false,
      );
    }*/
  }

  refreshPageWidgit() {

    if (location_addr1 != "PermissionStatus.deniedNeverAsk") {
      return new Container(
        child: Center(
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(width: 20.0,),
                    Icon(
                      Icons.all_inclusive,
                      color: Colors.teal,
                    ),
                    Text(
                      " Fetching location, please wait..",
                      style: new TextStyle(fontSize: 20.0, color: Colors.teal),
                    )
                  ]),
              SizedBox(height: 15.0),
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(width: 20.0,),
                    Text(
                      "Note: ",
                      style: new TextStyle(
                          fontSize: 15.0,
                          color: Colors.black,
                          fontWeight: FontWeight.bold),
                      textAlign: TextAlign.right,
                    ),
                    Text(
                      " If Location not being fetched automatically?",
                      style: new TextStyle(fontSize: 12.0, color: Colors.black),
                      textAlign: TextAlign.left,
                    ),
                   /* new InkWell(
                      child: new Text(
                        "Fetch Location now",
                        style: new TextStyle(
                            color: Colors.teal,
                            decoration: TextDecoration.underline),
                      ),
                      onTap: () {
                        sl.startStreaming(5);
                        startTimer();
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => HomePage()),
                        );
                      },
                    )*/
                  ]),

              FlatButton(
                child: new Text(
                  "Fetch Location now",
                  style: new TextStyle(
                      color: Colors.teal, decoration: TextDecoration.underline),
                ),
                onPressed: () {
                  sl.startStreaming(5);
                  startTimer();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HomePage()),
                  );
                },
              ),
            ],
          ),
        ),
      );
    } else {
      return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
        Text(
            'Location permission is restricted from app settings, click "Open Settings" to allow permission.',
            textAlign: TextAlign.center,
            style: new TextStyle(fontSize: 14.0, color: Colors.red)),
        RaisedButton(
          child: Text('Open Settings'),
          onPressed: () {
            SimplePermissions.openSettings();
          },
        ),
      ]);
    }
  }

  loader() {
    return new Container(
      child: Center(
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Image.asset('assets/spinner.gif', height: 50.0, width: 50.0),
            ]),
      ),
    );
  }

  underdevelopment() {
    return new Container(
      child: Center(
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Icon(
                Icons.android,
                color: Colors.teal,
              ),
              Text(
                "Under development",
                style: new TextStyle(fontSize: 30.0, color: Colors.teal),
              )
            ]),
      ),
    );
  }

  poorNetworkWidget() {
    return Container(
      child: Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Icons.error,
                      color: Colors.teal,
                    ),
                    Text(
                      " Poor network connection.",
                      style: new TextStyle(fontSize: 20.0, color: Colors.teal),
                    ),
                  ]),
              SizedBox(height: 5.0),
              FlatButton(
                child: new Text(
                  "Refresh location",
                  style: new TextStyle(
                      color: Colors.teal, decoration: TextDecoration.underline),
                ),
                onPressed: () {
                  sl.startStreaming(5);
                  startTimer();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HomePage()),
                  );
                },
              ),
            ]),
      ),
    );
  }

  mainbodyWidget() {
    ////to do check act1 for poor network connection

    if (act1 == "Poor network connection") {
      return poorNetworkWidget();
    } else {
      return SafeArea(
        child: ListView(
          physics: NeverScrollableScrollPhysics(),
          children: <Widget>[
            Container(
              // foregroundDecoration: BoxDecoration(color:Colors.red ),
              height: MediaQuery.of(context).size.height * 0.80,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  SizedBox(height: MediaQuery.of(context).size.height * .06),
                  new GestureDetector(
                    onTap: () {
                      // profile navigation
                      /* Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilePage()));*/
                    },
                    child: new Stack(children: <Widget>[
                      Container(
                          //   foregroundDecoration: BoxDecoration(color:Colors.yellow ),
                          width: MediaQuery.of(context).size.height * .18,
                          height: MediaQuery.of(context).size.height * .18,
                          decoration: new BoxDecoration(
                              shape: BoxShape.circle,
                              image: new DecorationImage(
                                fit: BoxFit.fill,
                                image:_checkLoaded ? AssetImage('assets/avatar.png') : profileimage,
                               //image: AssetImage('assets/avatar.png')
                              ))),
                  /*new Positioned(
                    left: MediaQuery.of(context).size.width*.14,
                    top: MediaQuery.of(context).size.height*.11,
                    child: new RawMaterialButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilePage()));
                      },
                      child: new Icon(
                        Icons.edit,
                        size: 18.0,
                      ),
                      shape: new CircleBorder(),
                      elevation: 0.5,
                      fillColor: Colors.teal,
                      padding: const EdgeInsets.all(1.0),
                    ),
                  ),*/
                    ]),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * .01),
                  //Image.asset('assets/logo.png',height: 150.0,width: 150.0),
                  // SizedBox(height: 5.0),
                  Text("Hi " + fname, style: new TextStyle(fontSize: 16.0)),

                  SizedBox(height: MediaQuery.of(context).size.height * .01),
                  // SizedBox(height: MediaQuery.of(context).size.height*.01),
                  (act1 == '') ? loader() : getMarkAttendanceWidgit(),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }

  getMarkAttendanceWidgit() {
    if (act1 == "Imposed") {
      return getAlreadyMarkedWidgit();
    } else {
      return Container(
        // height: MediaQuery.of(context).size.height*0.5,
        //foregroundDecoration: BoxDecoration(color:Colors.green ),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              /* Text('Mark Attendance',
                style: new TextStyle(fontSize: 30.0, color: Colors.teal)),
            SizedBox(height: 10.0),*/
              getwidget(location_addr1),
              //    SizedBox(height: MediaQuery.of(context).size.height*.1),
              /*      Container(
            //foregroundDecoration: BoxDecoration(color:Colors.green ),
            margin: EdgeInsets.only(bottom:MediaQuery.of(context).size.height*0),
            //padding: EdgeInsets.only(top:MediaQuery.of(context).size.height*0.02,bottom:MediaQuery.of(context).size.height*0.02),
              height: MediaQuery.of(context).size.height*.10,
              color: Colors.teal.withOpacity(0.8),
              child: Column(
                  children:[
                    SizedBox(height: 10.0,),
                    getQuickLinksWidget()
                  ]),
            ),
*/
            ]),
      );
    }
  }

  Widget quickLinkList1() {
    return Container(
      color: Colors.teal.withOpacity(0.8),

      width: MediaQuery.of(context).size.width * 0.95,
      // padding: EdgeInsets.only(top:MediaQuery.of(context).size.height*0.03,bottom:MediaQuery.of(context).size.height*0.03, ),
      child: getBulkAttnWid(),
    );
  }
 Widget getBulkAttnWid() {
   List <Widget> widList = List<Widget>();

   if (bulkAttn.toString() == '1' && admin_sts == '1') {
     widList.add(Container(
       padding: EdgeInsets.only(top: 10.0),
       constraints: BoxConstraints(
         maxHeight: 78.0,
         minHeight: 20.0,
       ),
       child: new GestureDetector(
           onTap: () {
             Navigator.push(
               context,
               MaterialPageRoute(builder: (context) => Bulkatt()),
             );
           },
           child: Column(
             children: [
               Icon(
                 Icons.group,
                 size: 30.0,
                 color: Colors.white,
               ),

               Text('Group \n Attendnace',
                   textAlign: TextAlign.center,
                   style:
                   new TextStyle(fontSize: 15.0, color: Colors.white)),
             ],
           )),
     ));
   }
   widList.add(Container(
     padding: EdgeInsets.only(top: 10.0),
     constraints: BoxConstraints(
       maxHeight: 60.0,
       minHeight: 20.0,
     ),
     child: new GestureDetector(
         onTap: () {
           Navigator.push(
             context,
             MaterialPageRoute(builder: (context) => MyApp()),
           );
         },
         child: Column(
           children: [
             Icon(
               Icons.calendar_today,
               size: 30.0,
               color: Colors.white,
             ),
             Text('Log',
                 textAlign: TextAlign.center,
                 style:
                 new TextStyle(fontSize: 15.0, color: Colors.white)),
           ],
         )),
   ));
   if(visitpunch.toString()=='1') {
   widList.add(Container(
     padding: EdgeInsets.only(top: 10.0),
     constraints: BoxConstraints(
       maxHeight: 60.0,
       minHeight: 20.0,
     ),
     child: new GestureDetector(
         onTap: () {
           /*showInSnackBar("Under development.");*/
           Navigator.push(
             context,
             MaterialPageRoute(
                 builder: (context) => PunchLocationSummary()),
           );
         },
         child: Row(
             children: [
               SizedBox(width: MediaQuery
                   .of(context)
                   .size
                   .width * .08),
               Column(
                 children: [
                   Icon(
                     Icons.add_location,
                     size: 30.0,
                     color: Colors.white,
                   ),
                   Text('Visits',
                       textAlign: TextAlign.center,
                       style:
                       new TextStyle(fontSize: 15.0, color: Colors.white)),
                 ],
               )
             ])),
   ));
 }

   if(timeOff.toString()=='1') {
     widList.add(Container(
       padding: EdgeInsets.only(top: 10.0),
       constraints: BoxConstraints(
         maxHeight: 60.0,
         minHeight: 20.0,
       ),
       child: new GestureDetector(
           onTap: () {
             //  //print('----->>>>>'+getOrgPerm(1).toString());
             getOrgPerm(1).then((res) {
               {
                 //   //print('----->>>>>'+res.toString());
                 if (res) {
                   Navigator.push(
                     context,
                     MaterialPageRoute(
                         builder: (context) => TimeoffSummary()),
                   );
                 } else
                   showInSnackBar('Please buy this feature');
               }
             });
           },
           child: Column(
             children: [
               Icon(
                 Icons.access_alarm,
                 size: 30.0,
                 color: Colors.white,
               ),
               Text('Time Off',
                   textAlign: TextAlign.center,
                   style:
                   new TextStyle(fontSize: 15.0, color: Colors.white)),
             ],
           )),
     ));
   }

   /* widList.add();
    widList.add();*/
    return (Row(children: widList,mainAxisAlignment: MainAxisAlignment.spaceEvenly,));
 }
  List<GestureDetector> quickLinkList() {
    List<GestureDetector> list = new List<GestureDetector>();
    // //print("permission list-->>>>>>"+data.toString());
    list.add(new GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MyApp()),
          );
        },
        child: Column(
          children: [
            Icon(
              Icons.calendar_today,
              size: 30.0,
              color: Colors.white,
            ),
            Text('Attendance',
                textAlign: TextAlign.center,
                style: new TextStyle(fontSize: 15.0, color: Colors.white)),
          ],
        )));

    if (punchlocation_permission == 1) {
      list.add(new GestureDetector(
          onTap: () {
            /*showInSnackBar("Under development.");*/
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PunchLocation()),
            );
          },
          child: Column(
            children: [
              Icon(
                Icons.add_location,
                size: 30.0,
                color: Colors.white,
              ),
              Text('Visits',
                  textAlign: TextAlign.center,
                  style: new TextStyle(fontSize: 15.0, color: Colors.white)),
            ],
          )));
    }

    if (timeoff_permission == 1) {
      list.add(new GestureDetector(
          onTap: () {
            //  //print('----->>>>>'+getOrgPerm(1).toString());
            getOrgPerm(1).then((res) {
              {
                //   //print('----->>>>>'+res.toString());
                if (res) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => TimeoffSummary()),
                  );
                } else
                  showInSnackBar('Please buy this feature');
              }
            });
          },
          child: Column(
            children: [
              Icon(
                Icons.access_alarm,
                size: 30.0,
                color: Colors.white,
              ),
              Text('Time Off',
                  textAlign: TextAlign.center,
                  style: new TextStyle(fontSize: 15.0, color: Colors.white)),
            ],
          )));
    }

    if (leave_permission == 1) {
      list.add(new GestureDetector(
          onTap: () {
            getOrgPerm(1).then((res) {
              {
                //   //print('----->>>>>'+res.toString());
                if (res) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LeaveSummary()),
                  );
                } else
                  showInSnackBar('Please buy this feature');
              }
            });
          },
          child: Column(
            children: [
              Icon(
                Icons.exit_to_app,
                size: 30.0,
                color: Colors.white,
              ),
              Text('Leave',
                  textAlign: TextAlign.center,
                  style: new TextStyle(fontSize: 15.0, color: Colors.white)),
            ],
          )));
    }
    return list;
  }

  getQuickLinksWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: quickLinkList(),
    );
  }

  getAlreadyMarkedWidgit() {
    return Column(children: <Widget>[
      SizedBox(
        height: 27.0,
      ),
      Container(
        decoration: new ShapeDecoration(
            shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(13.0)),
            color: Colors.teal),
        child: Text(
          '\nToday\'s attendance has been marked. Thank You!',
          textAlign: TextAlign.center,
          style: new TextStyle(color: Colors.white, fontSize: 15.0),
        ),
        width: 220.0,
        height: 70.0,
      ),
      /*SizedBox(height: MediaQuery.of(context).size.height*.25),
          Container(
            height: MediaQuery.of(context).size.height*.10,
            color: Colors.teal.withOpacity(0.8),
            child: Column(
                children:[
                  SizedBox(height: 10.0,),
                  getQuickLinksWidget()
                ]
            ),
          )*/
    ]);
  }

  getwidget(String addrloc) {
    if (addrloc != "PermissionStatus.deniedNeverAsk") {
      return Column(children: [
        ButtonTheme(
          minWidth: 120.0,
          height: 45.0,
          child: getTimeInOutButton(),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * .04),
        Container(
            color: Colors.teal.withOpacity(0.1),
            height: MediaQuery.of(context).size.height * .15,
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              FlatButton(
                child: new Text('You are at: ' + streamlocationaddr,
                    textAlign: TextAlign.center,
                    style: new TextStyle(fontSize: 14.0)),
                onPressed: () {
                  launchMap(lat, long);
                  /* Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HomePage()),
                  );*/
                },
              ),
              new Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    new Text('Location not correct? ',style: TextStyle(color: Colors.teal),),
                    SizedBox(width: 5.0,),
                    new InkWell(
                      child: new Text(
                        "Refresh location",
                        style: new TextStyle(
                            color: Colors.teal,
                            decoration: TextDecoration.underline),
                      ),
                      onTap: () {
                        startTimer();
                        sl.startStreaming(5);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => HomePage()),
                        );
                      },
                    )
                  ],
                ),
              ),
            ])),
      ]);
    } else {
      return Column(children: [
        Text(
            'Location permission is restricted from app settings, click "Open Settings" to allow permission.',
            textAlign: TextAlign.center,
            style: new TextStyle(fontSize: 14.0, color: Colors.red)),
        RaisedButton(
          child: Text('Open Settings'),
          onPressed: () {
            SimplePermissions.openSettings();
          },
        ),
      ]);
    }
    return Container(width: 0.0, height: 0.0);
  }

  getTimeInOutButton() {
    if (act1 == 'TimeIn') {
      return RaisedButton(
        child: Text('TIME IN',
            style: new TextStyle(fontSize: 22.0, color: Colors.white)),
        color: Colors.orangeAccent,
        onPressed: () {
          // //print("Time out button pressed");
          saveImage();
          //Navigator.pushNamed(context, '/home');
        },
      );
    } else if (act1 == 'TimeOut') {
      return RaisedButton(
        child: Text('TIME OUT',
            style: new TextStyle(fontSize: 22.0, color: Colors.white)),
        color: Colors.orangeAccent,
        onPressed: () {
          // //print("Time out button pressed");
          saveImage();
        },
      );
    }
  }

  Text getText(String addrloc) {
    if (addrloc != "PermissionStatus.deniedNeverAsk") {
      return Text('You are at: ' + addrloc,
          textAlign: TextAlign.center, style: new TextStyle(fontSize: 14.0));
    } else {
      return new Text(
          'Location access is denied. Enable the access through the settings.',
          textAlign: TextAlign.center,
          style: new TextStyle(fontSize: 14.0, color: Colors.red));
      /*return new  Text('Location is restricted from app settings, click here to allow location permission and refresh', textAlign: TextAlign.center, style: new TextStyle(fontSize: 14.0,color: Colors.red));*/
    }
  }

  saveImage() async {
    sl.startStreaming(5);

    MarkTime mk = new MarkTime(
        empid, streamlocationaddr, aid, act1, shiftId, orgdir, lat, long);
   /* mk1 = mk;*/

    var connectivityResult = await (new Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile || connectivityResult == ConnectivityResult.wifi) {
       /* Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CameraExampleHome()),
      );*/
      SaveImage saveImage = new SaveImage();
      bool issave = false;
      setState(() {
        act1 = "";
      });
      issave = await saveImage.saveTimeInOutImagePicker(mk);
      ////print(issave);
      if (issave) {
        showDialog(context: context, child:
        new AlertDialog(
          content: new Text("Attendance marked successfully!"),
        )
        );
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MyApp()),
        );
        setState(() {
          act1 = act;
        });
      } else {
        showDialog(context: context, child:
        new AlertDialog(
          title: new Text("Warning!"),
          content: new Text("Problem while marking attendance, try again."),
        )
        );
        setState(() {
          act1 = act;
        });
      }
    }else{
      showDialog(context: context, child:
      new AlertDialog(

        content: new Text("Internet connection not found!."),
      )
      );
    }


  /*SaveImage saveImage = new SaveImage();
    bool issave = false;
    setState(() {
      act1 = "";
    });
    issave = await saveImage.saveTimeInOut(mk);
    ////print(issave);
    if (issave) {

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MyApp()),
      );
      setState(() {
        act1 = act;
      });
    } else {
      setState(() {
        act1 = act;
      });
    }*/
  }

/*  saveImage() async {

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CameraApp()),
      );

  }*/

  resendVarification() async{
    NewServices ns= new NewServices();
    bool res = await ns.resendVerificationMail(orgid);
    if(res){
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
              content: Row( children:<Widget>[
                Text("Verification link has been sent to \nyour organization's registered Email."),
              ]
              )
          )
      );
    }
  }

  void _showAlert(BuildContext context) {
    globalalertcount = 1;
    setState(() {
      alertdialogcount = 1;
    });
    showDialog(

        context: context,
        builder: (context) => AlertDialog(
          title: Text("Verify Email"),
          content: Container(
              height: MediaQuery.of(context).size.height*0.22,
              child:Column(
              children:<Widget>[
              Container(width:MediaQuery.of(context).size.width*0.6, child:Text("Your organization's Email is not verified. Please verify now.")),

              new Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children:<Widget>[
                    ButtonBar(
                      children: <Widget>[
                        FlatButton(
                          child: Text('Later'),
                          shape: Border.all(color: Colors.black54),
                          onPressed: () {
                            Navigator.of(context, rootNavigator: true).pop();
                          },
                        ),
                        new RaisedButton(
                          child: new Text(
                            "Verify",
                            style: new TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          color: Colors.orangeAccent,
                          onPressed: () {
                            Navigator.of(context, rootNavigator: true).pop();
                            resendVarification();
                          },
                        ),
                      ],
                    ),
             ])
          ]
          ))
        )
    );
  }

}
