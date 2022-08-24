import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:inventroy_flutter/ApiConnection/Api.dart';
import 'package:inventroy_flutter/Model/User.dart';
import 'package:inventroy_flutter/app_localizations.dart';
import 'package:inventroy_flutter/my_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Home.dart';

class Login  extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
   return new  LoginState()  ;
  }

}
class LoginState  extends State<Login>{
  TextEditingController userNameEd  = new TextEditingController()  ;
  TextEditingController passEd  = new TextEditingController()  ;
  TextEditingController orgEd  = new TextEditingController()  ;
  String nameError , passError  , orgIdError;
  SharedPreferences sharedPrefs ;
  bool loading = false ;
  Api api  = new Api();
  bool isLoading = true ;

  @override
  void initState()  {
    // TODO: implement initState
    super.initState();
   checkLogin()  ;
     }
void checkLogin()async {
  SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
  if(sharedPrefs.containsKey("user")){
    User  user = User.fromJsonShared(json.decode(sharedPrefs.getString("user") )) ;
    loading  = false  ;
     isLoading = false ;

    Navigator.pushReplacement( context,
        MaterialPageRoute(builder: (context) => Home())) ;
  /*  api.login(userId:user.userId , orgId:user.orgId , onError:  onError, onLogin:
    onLogin, password: user.userPassword) ;*/
  }
  else{
    setState(() {
      isLoading  = false   ;
    });
  }
}
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Scaffold(
      body: new Container(
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage("images/background.jpg"), fit: BoxFit.cover)),
         child:  new Center(child:
         isLoading? new Center(
           child: CircularProgressIndicator(),
         ):
           SingleChildScrollView(child:
         new Column(

           mainAxisAlignment: MainAxisAlignment.center,
           crossAxisAlignment: CrossAxisAlignment.center,
           children: [
             loading? new Center(
               child: CircularProgressIndicator(),
             ):SizedBox(),
           new  Image.asset('images/logo.png'  , height: 100, width: 150,),
             orgIdEdFun() ,
             userNameEdFun(),
             passEdFun(),
             sendRequestBtn(),


           ],)))) ,
    )  ;
  }
  void onSendRequestBtn() {
    setState(() {
String user_id  = userNameEd.text ;
String password  = passEd.text ;
String org_id  = orgEd.text ;
setState(() {
  bool isValidate =   loginValidation(user_id ,password , org_id)  ;
  if(isValidate){
    loading = true  ;
    isLoading  = false ;
    api.login(userId:user_id , orgId:org_id , onError:  onError, onLogin:
    onLogin, password: password) ;
  }
  else{
    onError(AppLocalizations.of(context).translate("fill_data"))  ;
  }
});
    });
  }
  void onLogin (User  user ) {
    setState(() {
      loading = false ;
      isLoading = false  ;
      print(user.toString());
      saveUserData(user);
      Navigator.pushReplacement( context,
          MaterialPageRoute(builder: (context) => Home())) ;
    });
  }
  void saveUserData (User user )async {
    sharedPrefs = await SharedPreferences.getInstance();
    user.isSellingPriceView = true ;
    user.isCostPriceView  = false  ;
    sharedPrefs.setString("user", json.encode(user.toJson()) );
    sharedPrefs.commit() ;
  }
  Future<void> onError(String message ) async {
    setState(() {
      loading = false ;
    });
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context).translate("error")),
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
              },
            ),
          ],
        );
      },
    );
  }
  bool loginValidation (String name  , String password , String orgId){
    if(name.isEmpty) {
      return false  ;
    }
   else if(password.isEmpty){
      return false  ;
    }
   else if(orgId.isEmpty){
      return false  ;
    }
   else{
    return true ;}

  }



  Padding sendRequestBtn() {
    return new Padding(
        padding:
        EdgeInsets.only(bottom: 8.0, left: 40.0, right: 40.0, top: 8.0),
        child: Align(
            alignment: Alignment.bottomCenter,
            child: new Container(
              decoration: new BoxDecoration(
                  color: MyColors.redColor,
                  borderRadius: const BorderRadius.all(
                    const Radius.circular(8.0),
                  )),
              width: double.infinity,
              child:
                new FlatButton(
                  onPressed: onSendRequestBtn,

                  child:

                 new Row(
                   children: [
                     new Expanded(child:
                  new Text(
                    AppLocalizations.of(context).translate("login"),
                    style: new TextStyle(color: Colors.white),
                    textAlign:  TextAlign.center,
                  )),
                 new Icon(Icons.arrow_forward,
                   color: Colors.white,
                 ),
                 ],
                ),

              )
            ))
    )
    ;
  }
  Padding userNameEdFun() {
    return new Padding(padding:
        EdgeInsets.only(bottom: 8.0, left: 40.0, right: 40.0, top: 8.0),
        child:
            new Container(
              width: double.infinity,
           child : new Row(
              children: [
               new Container(
                   padding:EdgeInsets.all(5),

                   height:40 ,
                 decoration: new BoxDecoration(
                 color: MyColors.redColor,

                     ),
      child:Image.asset('images/user.png'  ,
        color: MyColors.white,

      )),
        new Flexible(
        child:  Container(
          decoration: new BoxDecoration(
            color: MyColors.white,

          ),
            height: 40,
            child: TextField(
              controller: userNameEd,

              maxLines: 1,
              decoration: InputDecoration(
                hintText:   AppLocalizations.of(context).translate("user_name"),
                fillColor: Colors.grey[300],
                filled: false,
               // errorText: nameError,

              ),
            ),
        ),
          )  ],
           )
            )

)

    ;
  }
  Padding passEdFun() {
    return new Padding(padding:
    EdgeInsets.only(bottom: 8.0, left: 40.0, right: 40.0, top: 8.0),
        child:
        new Container(
            width: double.infinity,
            child : new Row(
              children: [
                new Container(
                    padding:EdgeInsets.all(5),

                    height:40 ,
                    decoration: new BoxDecoration(
                      color: MyColors.redColor,


                    ),
                    child:Image.asset('images/password.png'  ,
                      color: MyColors.white,

                    )),
                new Flexible(
                  child:  Container(
                    decoration: new BoxDecoration(
                      color: MyColors.white,

                    ),
                    height: 40,
                    child: TextField(
                      controller: passEd,

                      maxLines: 1,
                      decoration: InputDecoration(
                        hintText:   AppLocalizations.of(context).translate("password"),
                        fillColor: Colors.grey[300],
                        filled: false,
                      //  errorText: passError,

                      ),
                    ),
                  ),
                )  ],
            )
        )

    )

    ;
  }
  Padding orgIdEdFun() {
    return new Padding(padding:
    EdgeInsets.only(bottom: 8.0, left: 40.0, right: 40.0, top: 8.0),
        child:
        new Container(
            width: double.infinity,
            child : new Row(
              children: [
                new Container(
                  padding:EdgeInsets.all(5),
                    height:40 ,
                    decoration: new BoxDecoration(
                      color: MyColors.redColor,

                    ),
                    child:Image.asset('images/company.png'  ,
                      color: MyColors.white,

                    )),
                new Flexible(
                  child:  Container(
                    decoration: new BoxDecoration(
                      color: MyColors.white,

                    ),
                    height: 40,
                    child: TextField(
                      controller: orgEd,
                      maxLines: 1,
                      decoration: InputDecoration(
                        hintText:   AppLocalizations.of(context).translate("org_id"),
                        fillColor: Colors.grey[300],
                        filled: false,
                      //  errorText: orgIdError,

                      ),
                    ),
                  ),
                )  ],
            )
        )

    )

    ;
  }
}