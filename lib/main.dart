import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'Screens/splash.dart';
import 'app_localizations.dart';
void main() => runApp(new MaterialApp(
  debugShowCheckedModeBanner: false,
  localizationsDelegates: [
    AppLocalizations.delegate,
    // Built-in localization of basic text for Material widgets
    GlobalMaterialLocalizations.delegate,
    // Built-in localization for text direction LTR/RTL
    GlobalWidgetsLocalizations.delegate,
  ],
  supportedLocales: [
    Locale('en'),
    Locale('ar'),
  ],
  home: new Splash(),
));
class testApp  extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return  new Scaffold(
        appBar: new AppBar(
          title: new Text(AppLocalizations.of(context).translate("app_name")),
          backgroundColor: new Color(0xFF651211) ,

        ));
  }

}



