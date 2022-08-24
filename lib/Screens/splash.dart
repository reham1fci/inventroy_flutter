
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:inventroy_flutter/Screens/AddInventoryPoint.dart';
import 'package:inventroy_flutter/Screens/Home.dart';
import 'package:inventroy_flutter/Screens/productDetails.dart';
import 'package:inventroy_flutter/Screens/setting.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:splashscreen/splashscreen.dart';
import '../app_localizations.dart';
import '../my_colors.dart';
import 'Login.dart';
import 'ProductsList.dart';
import 'inventoryPoints.dart';

class Splash extends StatefulWidget {
  @override
  _MySplashState createState() => new _MySplashState();
}

class _MySplashState extends State<Splash> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkLogin() ;
  }
   SharedPreferences sharedPrefs ;
   void checkLogin ()async {
     SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
     setState(() {
      this .sharedPrefs = sharedPrefs ;
      print("shared0") ;
    });
     //sharedPrefs.commit() ;
   }

  @override
  Widget build(BuildContext context) {
    return new SplashScreen(

imageBackground: AssetImage('images/background.jpg') ,

        seconds: 5,
        navigateAfterSeconds: Login(),
        title: new Text( AppLocalizations.of(context).translate("app_name"),
          style: new TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20.0 ,
               color: MyColors.blue
          ),),
      //  image: new Image.network('https://i.imgur.com/TyCSG9A.png'),
         image: Image.asset('images/logo.png' ),

        photoSize: 150,
        styleTextUnderTheLoader: new TextStyle(),
       // onClick: ()=>print("Flu tter Egypt"),
        loaderColor: MyColors.semoni
    );
  }
}

