// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'package:flutter/material.dart';
import 'package:Shrine/services/services.dart';
import 'outside_label.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'drawer.dart';
// This app is a stateful, it tracks the user's current choice.
class TrackEmployee extends StatefulWidget {
  @override
  _TrackEmployee createState() => _TrackEmployee();
}
TextEditingController today;
class _TrackEmployee extends State<TrackEmployee> with SingleTickerProviderStateMixin {
  TabController _controller;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  String _orgName;
  String desg='0';
  var formatter = new DateFormat('dd-MMM-yyyy');
  bool res = true;
  List<Map<String,String>> chartData;
  void showInSnackBar(String value) {
    final snackBar = SnackBar(
        content: Text(value,textAlign: TextAlign.center,));
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }
  getOrgName() async{
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _orgName= prefs.getString('org_name') ?? '';
    });
  }
  @override
  void initState() {
    super.initState();
    _controller = new TabController(length: 4, vsync: this);
    getOrgName();
    today = new TextEditingController();
    today.text = formatter.format(DateTime.now());
  }
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
        title: new Text(_orgName, style: new TextStyle(fontSize: 20.0)),
        backgroundColor: Colors.teal,
      ),
      endDrawer: new AppDrawer(),
      body: new ListView(
        physics: NeverScrollableScrollPhysics(),
        children: <Widget>[
          SizedBox(height:3.0),
          new Container(
            child: Center(child:Text("Employee Wise Tracking",style: TextStyle(fontSize: 22.0,color: Colors.black54,),),),
          ),
          Container(
            child: DateTimePickerFormField(
              dateOnly: true,
              format: formatter,
              controller: today,
              decoration: InputDecoration(
                prefixIcon: Padding(
                  padding: EdgeInsets.all(0.0),
                  child: Icon(
                    Icons.date_range,
                    color: Colors.grey,
                  ), // icon is 48px widget.
                ), // icon is 48px widget.
                labelText: 'Select Date',
              ),
              onChanged: (date) {
                setState(() {
                  if (date != null && date.toString()!='')
                    res = true; //showInSnackBar(date.toString());
                  else
                    res = false;
                });
              },
              validator: (date) {
                if (date == null) {
                  return 'Please select date';
                }
              },
            ),
          ),
          getDesignations_DD(),

          /* res==true?new Container(
            padding: EdgeInsets.all(0.1),
            margin: EdgeInsets.all(0.1),
            child: new ListTile(
              title: new SizedBox(height: MediaQuery.of(context).size.height*0.27,

                child: new FutureBuilder<List<Map<String,String>>>(
                    future: getChartDataCDate(today.text),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        if (snapshot.data.length > 0) {
                          return new PieOutsideLabelChart.withRandomData(snapshot.data);
                        }
                      }
                      return new Center( child: CircularProgressIndicator());
                    }
                ),

                //  child: new PieOutsideLabelChart.withRandomData(),

                width: MediaQuery.of(context).size.width*1.0,),
            ),
          ):Container(
            height: MediaQuery.of(context).size.height*0.25,
            child: Center(
              child:Text('No Chart Available'),
            ),
          ),
          res==true?new Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Text('Early Leavers(EL)',style: TextStyle(color:Colors.black87,fontSize: 12.0),),
              Text('Late Comers(LC)',style: TextStyle(color:Colors.black87,fontSize: 12.0),),
              Text('Absent(A)',style: TextStyle(color:Colors.black87,fontSize: 12.0),),
              Text('Present(P)',style: TextStyle(color:Colors.black87,fontSize: 12.0),),
            ],
          ):Center(),*/
          /*new Container(
            decoration: new BoxDecoration(color: Colors.black54),
            child: new TabBar(
              indicator: BoxDecoration(color: Colors.orangeAccent,),
              controller: _controller,
              tabs: [
                new Tab(
                  text: 'Present',
                ),
                new Tab(
                  text: 'Absent',
                ),
                new Tab(
                  text: 'Late \nComers',
                ),
                new Tab(
                  text: 'Early \nLeavers',
                ),
              ],
            ),
          ),*/
          new Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(height: 50.0,),
              Container(
                width: MediaQuery.of(context).size.width*0.22,
                child:Text('  Time',style: TextStyle(color: Colors.teal,fontWeight:FontWeight.bold,fontSize: 16.0),),
              ),
              SizedBox(height: 50.0,),
              Container(
                width: MediaQuery.of(context).size.width*0.45,
                child:Text('Location',style: TextStyle(color: Colors.teal,fontWeight:FontWeight.bold,fontSize: 16.0),),
              ),
              SizedBox(height: 50.0,),
              Container(
                width: MediaQuery.of(context).size.width*0.25,
                child:Text('Out of fence',style: TextStyle(color: Colors.teal,fontWeight:FontWeight.bold,fontSize: 16.0),),
              ),
            ],
          ),
          new Divider(height: 1.0,),
          res==true?new Container(
            height: MediaQuery.of(context).size.height*1,
            child: new TabBarView(
              controller: _controller,
              children: <Widget>[
                new Container(
                  height: MediaQuery.of(context).size.height*0.30,
                  //   shape: Border.all(color: Colors.deepOrange),
                  child: new ListTile(
                    title:
                    Container( height: MediaQuery.of(context).size.height*.45,
                      //width: MediaQuery.of(context).size.width*.99,
                      color: Colors.white,
                      //////////////////////////////////////////////////////////////////////---------------------------------
                      child: new FutureBuilder<List<EmployeeTracking>>(
                        future: getEmplolyeeTrackTime(today.text,desg),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            if(snapshot.data.length>0) {
                              return new ListView.builder(
                                  scrollDirection: Axis.vertical,
                                  itemCount: snapshot.data.length,
                                  itemBuilder: (BuildContext context, int index) {
                                    return new Column(
                                        children: <Widget>[
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment
                                                .spaceAround,
                                            children: <Widget>[
                                              SizedBox(height: 40.0,),
                                              Container(
                                                width: MediaQuery
                                                    .of(context)
                                                    .size
                                                    .width * 0.20,
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment
                                                      .start,
                                                  children: <Widget>[
                                                    Text(snapshot.data[index].time
                                                        .toString(), style: TextStyle(
                                                        color: Colors.black87,
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 16.0),),





                                                  ],
                                                ),
                                              ),

                                              Container(
                                                  width: MediaQuery
                                                      .of(context)
                                                      .size
                                                      .width * 0.45,
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment
                                                        .center,
                                                    children: <Widget>[
                                                      InkWell(
                                                        child: Text(
                                                            snapshot.data[index]
                                                                .address.toString(),
                                                            style: TextStyle(
                                                                color: Colors.black54,
                                                                fontSize: 12.0)),
                                                        onTap: () {
                                                          goToMap(
                                                              snapshot.data[index]
                                                                  .latitude ,
                                                              snapshot.data[index]
                                                                  .longitude);
                                                        },
                                                      ),

                                                    ],
                                                  )

                                              ),
                                              Container(
                                                  width: MediaQuery
                                                      .of(context)
                                                      .size
                                                      .width * 0.22,
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment
                                                        .center,
                                                    children: <Widget>[
                                                      /*Text(snapshot.data[index].isOutOfBound
                                                          .toString(),style: TextStyle(fontWeight: FontWeight.bold),),*/
                                                      Container(
                                                        width: MediaQuery
                                                            .of(context)
                                                            .size
                                                            .width * 0.22,
                                                        decoration: new ShapeDecoration(
                                                          shape: new RoundedRectangleBorder(
                                                              borderRadius: new BorderRadius
                                                                  .circular(2.0)),
                                                          color: snapshot.data[index]
                                                              .isOutOfBound.toString() ==
                                                              '0' ? Colors.green
                                                              .withOpacity(0.75) : Colors.red.withOpacity(0.75) ,
                                                        ),

                                                        //color: Colors.black12, // withdrawn
                                                        //color: Colors.orangeAccent, // pending
                                                        //color: Colors.red.withOpacity(0.65), // rejected,cancel
                                                        // color: Colors.green.withOpacity(0.75), // approved
                                                        padding: EdgeInsets.only(top: 1.5,
                                                            bottom: 1.5,
                                                            left: 8.0,
                                                            right: 8.0),
                                                        margin: EdgeInsets.only(top: 4.0),
                                                        child: snapshot.data[index]
                                                            .isOutOfBound.toString() ==
                                                            '0' ? Text(
                                                         "In", style: TextStyle(
                                                          color: Colors.white, fontSize: 14.0,),
                                                          textAlign: TextAlign.center,): Text(
                                                          "Out", style: TextStyle(
                                                          color: Colors.white, fontSize: 14.0,),
                                                          textAlign: TextAlign.center,),
                                                      ),
                                                    ],
                                                  )

                                              ),
                                            ],

                                          ),
                                          Divider(color: Colors.black26,),
                                        ]);}
                              );
                            }else{
                              return new Container(
                                  height: MediaQuery.of(context).size.height*0.30,
                                  child:Center(
                                    child: Container(
                                      width: MediaQuery.of(context).size.width*1,
                                      color: Colors.teal.withOpacity(0.1),
                                      padding:EdgeInsets.only(top:5.0,bottom: 5.0),
                                      child:Text("No Employee tracking record found. ",style: TextStyle(fontSize: 18.0),textAlign: TextAlign.center,),
                                    ),
                                  )
                              );
                            }
                          }
                          else if (snapshot.hasError) {
                            return new Text("Unable to connect server");
                            //  return new Text("${snapshot.error}");
                          }

                          // By default, show a loading spinner
                          return new Center( child: CircularProgressIndicator());
                        },
                      ),
                      //////////////////////////////////////////////////////////////////////---------------------------------
                    ),
                  ),
                ),
                //////////////TABB 2 Start

                ///////////////////TAB 4 Ends
              ],
            ),
          ):Container(
            height: MediaQuery.of(context).size.height*0.25,
            child:Center(
              child: Text('Please select the date'),
            ),
          ),
        ],
      ),
    );
  }

  Widget getDesignations_DD() {
    String dc = "0";
    return new FutureBuilder<List<Map>>(
        future: getEmployeesList(0),// with -All- label
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            try {
              return new Container(
                //    width: MediaQuery.of(context).size.width*.45,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Select Employee',
                    prefixIcon: Padding(
                      padding: EdgeInsets.all(1.0),
                      child: Icon(
                        Icons.attach_file,
                        color: Colors.grey,
                      ), // icon is 48px widget.
                    ),
                  ),

                  child: new DropdownButton<String>(
                    isDense: true,
                    style: new TextStyle(
                        fontSize: 15.0,
                        color: Colors.black
                    ),
                    value: desg,
                    onChanged: (String newValue) {
                      setState(() {
                        //  showInSnackBar(newValue);
                        setState(() {
                          desg = newValue;
                          res = true;
                          print('state set----');
                        });
                      });
                    },
                    items: snapshot.data.map((Map map) {
                      return new DropdownMenuItem<String>(
                        value: map["Id"].toString(),
                        child: new SizedBox(
                            width: 200.0,
                            child: new Text(
                              map["Name"],
                            )
                        ),
                      );
                    }).toList(),

                  ),
                ),
              );
            }catch(e){
              return Text("EX: Unable to fetch designations");
            }
          } else if (snapshot.hasError) {
            return new Text("ER: Unable to fetch designations");
          }
          // return loader();
          return new Center(child: SizedBox(
            child: CircularProgressIndicator(strokeWidth: 2.2,),
            height: 20.0,
            width: 20.0,
          ),);
        });
  }


}
