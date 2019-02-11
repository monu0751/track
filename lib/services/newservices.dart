
import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Shrine/model/model.dart';
import 'package:Shrine/globals.dart' as globals;
import 'dart:async';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:geocoder/geocoder.dart';
import 'package:location/location.dart';
import 'dart:async';
import 'package:Shrine/globals.dart';
import 'services.dart';


class RequestTimeOffService{

  var dio = new Dio();
  requestTimeOff(TimeOff timeoff) async{
    try {
      print(timeoff.OrgId);
      print(timeoff.EmpId + "----");
      print(timeoff.TimeofDate + "----");
      print(timeoff.TimeFrom + "----");
      print(timeoff.TimeTo + "----");
      print(timeoff.Reason + "----");
      FormData formData = new FormData.from({
        "orgid": timeoff.OrgId,
        "uid": timeoff.EmpId,
        "date": timeoff.TimeofDate,
        "stime": timeoff.TimeFrom,
        "etime": timeoff.TimeTo,
        "reason": timeoff.Reason
      });

      Response response1 = await dio.post(globals.path+"reqForTimeOff", data: formData);
      print("----->timeoff response "+response1.toString());
      if (response1.statusCode == 200) {
        Map timeoffMap = json.decode(response1.data);
        //print(timeoffMap["status"]);
        if(timeoffMap["status"]==true){
          return "success";
        }else{
          return timeoffMap["errorMsg"];
        }
      }else{
        return "No Connection";
      }

    }catch(e){
      //print(e.toString());
      return "No Connection";
    }
  }
}

class NewServices{

  var dio = new Dio();

  getProfile(String empid) async{
  //  print('---------------------------------------------------------');
    try {
      FormData formData = new FormData.from({
        "uid": empid,
      });//print('##############################################################');
      //Response response = await dio.post("https://sandbox.ubiattendance.com/index.php/services/getInfo", data: formData);
      Response response = await dio.post(
          globals.path+"getProfile",
          data: formData);
    //  print('##############################################################');
     // print(response.toString());
      if (response.statusCode == 200) {
        Map profileMap = json.decode(response.data);
        return profileMap;
      }else{
        return "No Connection";
      }
    }catch(e){
      //print(e.toString());
      return "Poor network connection";
    }

  }

  updateProfile(Profile profile) async{

    try {
      FormData formData = new FormData.from({
        "uid": profile.uid,
        "refno": profile.orgid,
        "no": profile.mobile,
        "con": profile.countryid
      });
      //Response response = await dio.post("https://sandbox.ubiattendance.com/index.php/services/getInfo", data: formData);
      Response response = await dio.post(
          globals.path+"updateProfile",
          data: formData);
      //print(response.toString());
      if (response.statusCode == 200) {
        Map profileMap = json.decode(response.data);
        //print(profileMap["res"]);
        if(profileMap["res"]==1){
          return "success";
        }else{
          return "failure";
        }
      }else{
        return "No Connection";
      }
    }catch(e){
      //print(e.toString());
      return "Poor network connection";
    }

  }


  Future<bool> updateProfilePhoto(int uploadtype, String empid, String orgid) async {
    try{

      File imagei = null;
      imageCache.clear();
      //for gallery
      if(uploadtype==1){
        imagei = await ImagePicker.pickImage(source: ImageSource.gallery);
      }
      //for camera
      if(uploadtype==2){
        imagei = await ImagePicker.pickImage(source: ImageSource.camera);
      }
      //for removing photo
      if(uploadtype==3){
        imagei = null;
      }
      print("Selected image information ****************************");
      print(imagei.toString());
      if(imagei!=null ) {
        //// sending this base64image string +to rest api
        FormData formData = new FormData.from({
          "uid": empid,
          "refno": orgid,
          "file": new UploadFileInfo(imagei, "sample.png"),
        });
        //print("5");
        Response<String> response1=await dio.post(globals.path_hrm_india+"updateProfilePhoto",data:formData);

        //imagei.deleteSync();
        imageCache.clear();
        /*getTempImageDirectory();*/
        Map MarkAttMap = json.decode(response1.data);
        //print(MarkAttMap["status"].toString());
        if (MarkAttMap["status"])
          return true;
        else
          return false;
      }else if(uploadtype==3 && imagei==null){
        FormData formData = new FormData.from({
          "uid": empid,
          "refno": orgid,
        });
        Response<String> response1=await dio.post(globals.path_hrm_india+"updateProfilePhoto",data:formData);
        //print(response1.toString());
        Map MarkAttMap = json.decode(response1.data);
        //print(MarkAttMap["status"].toString());
        if (MarkAttMap["status"])
          return true;
        else
          return false;
      }else{
        return false;
      }
    } catch (e) {
      print("this is catch.. of updateprofilephoto**************************");
      print(e.toString());
      return false;
    }
  }

  ///////////////////// SERVICES TO RE-SEND VERIFACATION MAIL TO ORGANIATION /////////////////
  resendVerificationMail(String orgid) async{
    print("this is our resendVerificationMail");
    try{
      FormData formData = new FormData.from({
        "orgid": orgid,
      });
      Response response1 = await dio.post(globals.path+"resend_verification_mail", data: formData);
      print("*****************resend verification response ******************");
      print(response1.toString());
      if (response1.statusCode == 200) {
        Map veriMap = json.decode(response1.data);
        return veriMap["status"];
      }else{
        return false;
      }
    }catch(e){
      return false;
    }
  }
  ///////////////////// SERVICES TO RE-SEND VERIFACATION MAIL TO ORGANIATION /////////////////


  //////////////////// SERVICE TO REQUEST FOR LEAVE /////////////////////

  requestLeave(Leave leave) async{
    try {
      //print(leave.orgid);
      //print(leave.uid);
      //print(leave.leavefrom);
      //print(leave.leaveto);
      //print(leave.leavetypefrom);
      //print(leave.leavetypeto);
      //print(leave.halfdayfromtype);
      //print(leave.halfdaytotype);
      //print(leave.leavetypeid);
      //print(leave.reason);

      FormData formData = new FormData.from({
        "orgid": leave.orgid,
        "uid": leave.uid,
        "leavefrom": leave.leavefrom,
        "leaveto": leave.leaveto,
        "leavetypefrom": leave.leavetypefrom,
        "leavetypeto": leave.leavetypeto,
        "halfdayfromtype": leave.halfdayfromtype,
        "halfdaytotype": leave.halfdaytotype,
        "leavetypeid": leave.leavetypeid,
        "reason": leave.reason
      });

      Response response1 = await dio.post(globals.path_hrm_india+"reqForLeave", data: formData);
      //print(response1.toString());
      if (response1.statusCode == 200) {
        Map leaveMap = json.decode(response1.data);
        //print(leaveMap["status"]);
        return leaveMap["status"].toString();
      }else{
        return "No Connection";
      }

    }catch(e){
      //print(e.toString());
      return "No Connection";
    }
  }

  Future<List<Leave>> getLeaveSummary(String empid) async{
    try {
      FormData formData = new FormData.from({
        "uid": empid,
      });
      //Response response = await dio.post("https://sandbox.ubiattendance.com/index.php/services/getInfo", data: formData);
      Response response = await dio.post(
          globals.path+"getLeaveList",
          data: formData);
      //print(response.data.toString());
      //print('--------------------getLeaveSummary Called-----------------------');
      List responseJson = json.decode(response.data.toString());
      List<Leave> userList = createLeaveList(responseJson);
      return userList;
    }catch(e){
      //print(e.toString());
    }
  }

  List<Leave> createLeaveList(List data){
    List<Leave> list = new List();
    for (int i = 0; i < data.length; i++) {
      String LeaveDate = data[i]["date"];
      String LeaveFrom=data[i]["from"];
      String LeaveTo=data[i]["to"];
      String LeaveDays=data[i]["days"];
      String Reason=data[i]["reason"];
      String ApprovalSts=data[i]["status"];
      String ApproverComment=data[i]["comment"];
      String LeaveId=data[i]["leaveid"];
      bool withdrawlsts=data[i]["withdrawlsts"];
      Leave leave = new Leave(attendancedate: LeaveDate, leavefrom: LeaveFrom, leaveto: LeaveTo, leavedays: LeaveDays, reason: Reason, approverstatus: ApprovalSts, comment: ApproverComment, leaveid: LeaveId, withdrawlsts: withdrawlsts);
      list.add(leave);
    }
    return list;
  }
  ///////////////////////////
  ///////////////////////////////// SERVICE TO WIDRAWL LEAVE /////////////////////////////////
  //////////////////////////////

  withdrawLeave(Leave leave) async{
    try {
      FormData formData = new FormData.from({
        "leaveid": leave.leaveid,
        "uid": leave.uid,
        "orgid": leave.orgid,
        "leavests": leave.approverstatus
      });
      //Response response = await dio.post("https://sandbox.ubiattendance.com/index.php/services/getInfo", data: formData);
      Response response = await dio.post(
          globals.path_hrm_india+"changeleavests",
          data: formData);
      //print(response.toString());
      if (response.statusCode == 200) {
        Map leaveMap = json.decode(response.data);
        if(leaveMap["status"]==true){
          return "success";
        }else{
          return "failure";
        }
      }else{
        return "No Connection";
      }
    }catch(e){
      //print(e.toString());
      return "Poor network connection";
    }
  }

  withdrawTimeOff(TimeOff timeoff) async{
    try {
      FormData formData = new FormData.from({
        "timeoffid": timeoff.TimeOffId,
        "uid": timeoff.EmpId,
        "orgid": timeoff.OrgId,
        "timeoffsts": timeoff.ApprovalSts
      });
      //Response response = await dio.post("https://sandbox.ubiattendance.com/index.php/services/getInfo", data: formData);
      Response response = await dio.post(
          globals.path+"changetimeoffsts",
          data: formData);
      //print(response.toString());
      if (response.statusCode == 200) {
        Map leaveMap = json.decode(response.data);
        if(leaveMap["status"]==true){
          return "success";
        }else{
          return "failure";
        }
      }else{
        return "No Connection";
      }
    }catch(e){
      //print(e.toString());
      return "Poor network connection";
    }
  }

  ////////////// Service to get Leave Summary ////////////////

  /* Future<List<TimeOff>> getTimeOffSummary() async {
    final prefs = await SharedPreferences.getInstance();
    String empid = prefs.getString('empid') ?? '';
    //final response = await http.get('https://ubiattendance.ubihrm.com/index.php/services/getHistory?uid=$empid&refno=$orgdir');
    //final response = await http.get('https://ubiattendance.ubihrm.com/index.php/services/getHistory?uid=$empid&refno=$orgdir');
    final response = await http.get(globals.path+'fetchTimeOffList?uid=$empid');
    //print(response.body);
    //print('--------------------getTimeOffList Called-----------------------');
    List responseJson = json.decode(response.body.toString());
    List<TimeOff> userList = createTimeOffList(responseJson);
    return userList;
  }

  List<TimeOff> createTimeOffList(List data){
    List<TimeOff> list = new List();
    for (int i = 0; i < data.length; i++) {
      String TimeofDate = data[i]["date"];
      String TimeFrom=data[i]["from"];
      String TimeTo=data[i]["to"];
      String hrs=data[i]["hrs"];
      String Reason=data[i]["reason"];
      String ApprovalSts=data[i]["status"];
      String ApproverComment=data[i]["comment"];
      TimeOff tos = new TimeOff(
          TimeofDate: TimeofDate,TimeFrom: TimeFrom,TimeTo: TimeTo,hrs:hrs,Reason:Reason,ApprovalSts:ApprovalSts,ApproverComment:ApproverComment);
      list.add(tos);
    }
    return list;
  } */

  Future<List<Desg>> getAllDesgPermission(String orgid, String desinationId) async{
    try {
      FormData formData = new FormData.from({
        "orgid": orgid,
        "roleid": desinationId
      });
      //Response response = await dio.post("https://sandbox.ubiattendance.com/index.php/services/getInfo", data: formData);
      Response response = await dio.post(
          globals.path+"getAllDesgPermission",
          data: formData
      );
      //print(response.data.toString());
      //print('--------------------getAllDesgPermission Called-----------------------');
      List responseJson = json.decode(response.data.toString());
      List<Desg> desigList = createDesgPermissionList(responseJson);
      //print("------------->permissions list >>>>>>>>>>>>>>>>"+responseJson[0]["permissions"].toString());
      //List<Leave> userList = createLeaveList(responseJson);
      return desigList;
    }catch(e){
      //print(e.toString());
    }
  }

  List<Desg> createDesgPermissionList(List data){
    List<Desg> list = new List();
    for (int i = 0; i < data.length; i++) {
      String desg = data[i]["rolename"];
     // String status=data[i]["archive"]=='1'?'Active':'Inactive';
      String id =data[i]["id"];
      List permissionlist = data[i]["permissions"];
      Desg dpt = new Desg(desg: desg,id:id,modulepermissions: permissionlist);
      list.add(dpt);
    }
    return list;
  }

  savePermission(List<Desg> data, String orgid, String empid) async{

    List<Map> list = new List();

    //print(data);
    //print(list);
    for (int i = 0; i < data.length; i++) {
      Map per = {
                "id":data[i].id.toString(),
                "rolename":data[i].desg.toString(),
                "permissions":data[i].modulepermissions
                };

      list.add(per);
    }
    var jsonlist;
    jsonlist = json.encode(list);
    //print(jsonlist);
    try {
      FormData formData = new FormData.from({
        "jsondata": jsonlist,
        "orgid": orgid,
        "userid": empid
      });
      Response response = await dio.post(
        globals.path+"saveAllDesgPermission/",data: formData, options: new Options(contentType:ContentType.parse("application/json"))
      );
      //print(response.data.toString());
      //Map permissionMap = json.decode(response.data.toString());
      if (response.statusCode == 200) {
        //print("successfully");
        return "success";
      }else{
        //print("failed");
        return "failed";
      }
    }catch(e){
      //print("connection error");
      return "connection error";
      //print(e.toString());
    }
  }

}

class StreamLocation{
  Map<String, double> _currentLocation;
  StreamSubscription<Map<String, double>> _locationSubscription;
  Location _location = new Location();
  String streamlocationaddr="";
  String lat="";
  String long="";
  void startStreaming(int listlength) async{
    int counter = 0;
    stopstreamingstatus = false;
    _locationSubscription =
        _location.onLocationChanged().listen((Map<String,double> result) {
            _currentLocation = result;
            list.add(result);
            getAddress(list[list.length-1]);
            //print("counter"+counter.toString());
            //print("List length  ->>>>>> "+list.length.toString());
            if(counter>listlength) {
              list.removeAt(0);
              stopstreamingstatus = true;
              // //print("index 0 is removed");
              _locationSubscription.cancel();
              //print("subscription canceled");
            }
            counter++;
          //print("----------> Running");
        });
  }

  getAddress( Map<String, double> _currentLocation) async{
    try {
      ////print(_currentLocation);
      //print("${_currentLocation["latitude"]},${_currentLocation["longitude"]}");
      if (_currentLocation != null) {
        var addresses = await Geocoder.local.findAddressesFromCoordinates(
            Coordinates(
                _currentLocation['latitude'], _currentLocation['longitude']));
        var first = addresses.first;
        //streamlocationaddr = "${first.featureName} : ${first.addressLine}";
        streamlocationaddr = "${first.addressLine}";
        globalstreamlocationaddr = streamlocationaddr;
      }
    }catch(e){
      //print(e.toString());
      if (_currentLocation != null) {
        globalstreamlocationaddr = "${_currentLocation["latitude"]},${_currentLocation["longitude"]}";
      }

    }
  }


}



