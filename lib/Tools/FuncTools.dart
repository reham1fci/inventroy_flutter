
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:connectivity/connectivity.dart';

 class  Tools  {


   Future<void> dialogMsg(String message  , String title   , BuildContext context ,
       bool closeScreen) async {
     return showDialog<void>(
       context: context,
       barrierDismissible: false, // user must tap button!
       builder: (BuildContext context) {
         return AlertDialog(
           title: Text(title),
           content: SingleChildScrollView(
             child: ListBody(
               children: <Widget>[
                 Text(message),
               ],
             ),
           ),
           actions: <Widget>[
             FlatButton(
               child: Text('ok'),
               onPressed: () {
                 Navigator.of(context).pop();
                 if(closeScreen) {
                   Navigator.of(context).pop();

                 }
               },
             ),
           ],
         );
       },
     );
   }

   Future<void> confirmDialog(String message  , String title   , BuildContext context , Function onOkClick) async {
     return showDialog<void>(
       context: context,
       barrierDismissible: false, // user must tap button!
       builder: (BuildContext context) {
         return AlertDialog(
           title: Text(title),
           content: SingleChildScrollView(
             child: ListBody(
               children: <Widget>[
                 Text(message),
               ],
             ),
           ),
           actions: <Widget>[
             FlatButton(
               child: Text('Ok'),
               onPressed: () {
                 Navigator.of(context).pop();
                 onOkClick();
               },
             ),
             FlatButton(
               child: Text('Cancel'),
               onPressed: () {
                 Navigator.of(context).pop();

               },
             ),
           ],
         );
       },
     );
   }


   void  toastMessage(String message){

     Fluttertoast.showToast(
         msg: message,
         toastLength: Toast.LENGTH_SHORT,
         gravity: ToastGravity.CENTER,
         timeInSecForIosWeb: 1,
         backgroundColor: Colors.black,
         textColor: Colors.white,
         fontSize: 16.0
     );

   }
   Future<bool> checkInternetConn() async {
     var connectivityResult = await (Connectivity().checkConnectivity());
     if (connectivityResult == ConnectivityResult.mobile) {
       return true;
     } else if (connectivityResult == ConnectivityResult.wifi) {
       return true;
     }
     return false;
   }
 }