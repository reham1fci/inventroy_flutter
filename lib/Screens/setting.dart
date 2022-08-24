import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:inventroy_flutter/Model/User.dart';
import 'package:inventroy_flutter/my_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app_localizations.dart';

class Setting extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new SettingState();
  }


}
class SettingState extends State<Setting> {
  bool batchVisibility = false  ;
  bool expVisibility   =   false  ;
  bool descriptionVisibility   =   false  ;
  User  user  ;
  SharedPreferences sharedPrefs;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserData()  ;
  }
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(backgroundColor: MyColors.colorPrimary,title: Text(AppLocalizations.of(context).translate("setting")),),

      body: new Container(
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage("images/background.jpg"), fit: BoxFit.cover)),
          child:  new Center(child:new Column(
            children: [
              sellingPriceCheck (),
              costPriceCheck(),
              descriptionVisibility?   descriptionCheck():SizedBox(),
            batchVisibility? batchNumCheck():SizedBox(),
            expVisibility  ?  expireDateCheck() : SizedBox(),



            ],))) ,
    )  ;  }
    bool  costCheck=  false ;
    bool  sellingCheck=  false ;
    bool  batchCheck=  false ;
    bool  expCheck=  false ;
    bool  descCheck=  false ;


  Future <void>getUserData () async{
     sharedPrefs = await SharedPreferences.getInstance();
    user = User.fromJsonShared(json.decode(sharedPrefs.getString("user") )) ;
     setState(() {
      batchVisibility  = isView(user.isBatchView) ;
      expVisibility  = isView(user.isExpireView) ;
      descriptionVisibility  = isView(user.isDescriptionView) ;
      sellingCheck  = user.isSellingPriceView ;
      costCheck  = user.isCostPriceView ;

     });

  }
   bool isView( int num){
    if(num == 1){ return  true   ;
    }
    return false  ;
  }

Padding  sellingPriceCheck (){
    return Padding(padding:EdgeInsets.all(10)  , child:CheckboxListTile(
      title:Text(AppLocalizations.of(context).translate("selling_price")),
      value: sellingCheck,
      onChanged: (newValue) {
        setState(() {
          sellingCheck = newValue;
          user.isSellingPriceView  = sellingCheck  ;
          sharedPrefs.setString("user", json.encode( user.toJson()) );
          sharedPrefs.commit() ;
        });
      },
      controlAffinity: ListTileControlAffinity.leading,  //  <-- leading Checkbox
    ));
}
  Padding  costPriceCheck (){
    return Padding(padding:EdgeInsets.all(10)  , child:CheckboxListTile(
      title: Text(AppLocalizations.of(context).translate("cost_price")),
      value: costCheck,
      onChanged: (newValue) {
        setState(() {
          costCheck = newValue;
          user.isCostPriceView  = costCheck  ;
          sharedPrefs.setString("user", json.encode( user.toJson()) );
          sharedPrefs.commit() ;
        });
      },
      controlAffinity: ListTileControlAffinity.leading,  //  <-- leading Checkbox
    ));
  }
  Padding  descriptionCheck (){
    return Padding(padding:EdgeInsets.all(10)  , child:CheckboxListTile(
      title: Text(AppLocalizations.of(context).translate("description")),
      value: descriptionVisibility,
      controlAffinity: ListTileControlAffinity.leading,  //  <-- leading Checkbox
    ));
  }
  Padding  batchNumCheck (){
    return Padding(padding:EdgeInsets.all(10)  , child:CheckboxListTile(
      title: Text(AppLocalizations.of(context).translate("batch_num")),
      value: batchVisibility,
      controlAffinity: ListTileControlAffinity.leading,  //  <-- leading Checkbox
    ));
  }
  Padding  expireDateCheck (){
    return Padding(padding:EdgeInsets.all(10)  , child:CheckboxListTile(
      title: Text(AppLocalizations.of(context).translate("expire_date")),
      value: expVisibility,
      controlAffinity: ListTileControlAffinity.leading,  //  <-- leading Checkbox
    ));
  }
}