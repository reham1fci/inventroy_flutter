import 'package:flutter/material.dart';
import 'package:inventroy_flutter/ApiConnection/Api.dart';
import 'package:inventroy_flutter/DataBase/database_helper.dart';
import 'package:inventroy_flutter/Model/InventoryPoint.dart';
import 'package:inventroy_flutter/Screens/Login.dart';
import 'package:inventroy_flutter/Screens/RequestsPurchase.dart';
import 'package:inventroy_flutter/Screens/setting.dart';
import 'package:inventroy_flutter/Tools/FuncTools.dart';
import 'package:inventroy_flutter/app_localizations.dart';
import 'package:inventroy_flutter/my_colors.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'inventoryPoints.dart';


class Home  extends  StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return  new HomeState ();
  }}
  class  HomeState extends State<Home>{
    final dbHelper = DatabaseHelper.instance;
    ProgressDialog  pr  ;
    Api api  = new Api();
  @override
  Widget build(BuildContext context) {

    // TODO: implement build
    return new Scaffold(
      appBar: new AppBar(actions: [
        IconButton(
          icon: Icon(
            Icons.logout,
            color: Colors.white,
          ),
          onPressed: () async {
            SharedPreferences    sharedPrefs = await SharedPreferences.getInstance();
            sharedPrefs.remove("user");
            sharedPrefs.clear()  ;
            sharedPrefs.commit()  ;
            int delete = await dbHelper.deleteTb(table: DatabaseHelper.allItemTable)  ;
            int delete2 = await dbHelper.deleteTb(table: DatabaseHelper.inv_table_name)  ;
            int delete3 = await dbHelper.deleteTb(table: DatabaseHelper.invItemsTable)  ;
            int delete4 = await dbHelper.deleteTb(table: DatabaseHelper.REQTable)  ;
            int delete5 = await dbHelper.deleteTb(table: DatabaseHelper.REQ_ITEM_TB)  ;
            Navigator.pushReplacement( context,
                MaterialPageRoute(builder: (context) => Login())) ;
            // do something
          },),
      IconButton(
      icon: Icon(
          Icons.settings,
          color: Colors.white,
        ),
        onPressed: () {
          Navigator.push( context,
              MaterialPageRoute(builder: (context) => Setting())) ;
          // do something
        },)   ,


      ],backgroundColor: MyColors.colorPrimary,),
      body: new Container(
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage("images/background.jpg"), fit: BoxFit.cover)),
          child:  new Center(child:new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
            new  Image.asset('images/logo.png'  , height: 100, width: 150,),
              new Padding(padding: EdgeInsets.only(top: 50) , child:
              downloadItemsBtn() ) ,
              inventoryBtn(),
              requestsPurchaseBtn(),

          ],))) ,
    )  ;  }

  void onDownloadItemsBtn() {
    setState(() {
      showProgressDialog();
api.getCountItems((String s , double d){

  updateProgressDialog(s, d)  ;
} ,
        (int itemsCount){
  dismissDialog(itemsCount) ;
        }  ) ;
    });
  }
  Padding downloadItemsBtn() {
   return new Padding(
        padding:
        EdgeInsets.only(bottom: 8.0, left: 40.0, right: 40.0, top: 8.0),
        child: new Container(
            decoration: new BoxDecoration(
                color: MyColors.colorPrimary,
                borderRadius: const BorderRadius.all(
                  const Radius.circular(8.0),
                )),
            width: double.infinity,
            child:
            new FlatButton(
              onPressed: onDownloadItemsBtn,
              child:
              new Row(
                children: [
                  new Expanded(child:
                  new Text(
                    AppLocalizations.of(context).translate("download_items"),
                    style: new TextStyle(color: Colors.white),
                    textAlign:  TextAlign.center,
                  )),
                  new Image.asset("images/download.png" , color: Colors.white,)
                  ,
                ],
              ),

            )


        )
    )
    ;
  }
  void onInventoryBtnClick() {
    setState(() {
   /*   final allRows = await dbHelper.queryAllRows();
      print('query all rows:');
      allRows.forEach((row) => print(row)); */
      Navigator.push( context,
          MaterialPageRoute(builder: (context) => InventroyPoints())) ;

       }

      );

  }
  Padding inventoryBtn() {
    return new Padding(
        padding:
        EdgeInsets.only(bottom: 8.0, left: 40.0, right: 40.0, top: 8.0),
        child: new Container(
            decoration: new BoxDecoration(
                color: MyColors.colorPrimary,
                borderRadius: const BorderRadius.all(
                  const Radius.circular(8.0),
                )),
            width: double.infinity,
            child:
            new FlatButton(
              onPressed: onInventoryBtnClick,

              child:

              new Row(
                children: [
                  new Expanded(child:
                  new Text(
                    AppLocalizations.of(context).translate("inventory"),
                    style: new TextStyle(color: Colors.white),
                    textAlign:  TextAlign.center,
                  )),
                  new Image.asset("images/inventory.png" , color: Colors.white,)
                  ,
                ],
              ),

            )


        )
    )
    ;
  }
  void onRequestBtnClick() {
    setState(() {
      Navigator.push( context,
          MaterialPageRoute(builder: (context) => PurchaseRequest())) ;

    }
    );
  }
  Padding requestsPurchaseBtn() {
    return new Padding(
        padding:
        EdgeInsets.only(bottom: 8.0, left: 40.0, right: 40.0, top: 8.0 ),
            child: new Container(
                decoration: new BoxDecoration(
                    color: MyColors.colorPrimary,
                    borderRadius: const BorderRadius.all(
                      const Radius.circular(8.0),
                    )),
                width: double.infinity,
                child:
                new FlatButton(
                  onPressed: onRequestBtnClick,

                  child:

                  new Row(
                    children: [
                      new Expanded(child:
                      new Text(
                        AppLocalizations.of(context).translate("add_request"),
                        style: new TextStyle(color: Colors.white),
                        textAlign:  TextAlign.center,
                      )),
                      new Image.asset("images/cart.png" , color: Colors.white,)
                      ,
                    ],
                  ),

                )
                   
                  
            )
    )
    ;
  }
    showProgressDialog (){
     pr = new ProgressDialog(context);
      pr = new ProgressDialog(context,type: ProgressDialogType.Download,
          isDismissible: false,
          showLogs: true);
//For normal dialog
      pr.style(
          message: 'Downloading ......',
          borderRadius: 10.0,
          backgroundColor: Colors.white,
          progressWidget: Container(
              padding: EdgeInsets.all(8.0),child:
          SizedBox( width: 30, height: 30,

              child: CircularProgressIndicator() )),
          elevation: 10.0,
          insetAnimCurve: Curves.easeInOut,
          progress: 0.0,
          maxProgress: 100.0,
          progressTextStyle: TextStyle(
              color: Colors.black, fontSize: 13.0, fontWeight: FontWeight.w400),
          messageTextStyle: TextStyle(
              color: Colors.black, fontSize: 19.0, fontWeight: FontWeight.w600)
      );

      pr.show();


//For showing progress percentage
    }

  void   updateProgressDialog  ( String message  , double progress){
      pr.update(
        progress: progress,
        message: message,
        progressWidget: Container(
            padding: EdgeInsets.all(8.0),child:
            SizedBox( width: 30, height: 30,

      child: CircularProgressIndicator() )),
        maxProgress: 100.0,
        progressTextStyle: TextStyle(
            color: Colors.black, fontSize: 13.0, fontWeight: FontWeight.w400),
        messageTextStyle: TextStyle(
            color: Colors.black, fontSize: 19.0, fontWeight: FontWeight.w600),
      );
    }
    dismissDialog  ( int itemsCount){
      pr.hide().then((isHidden) {

Tools t  =  new Tools()  ;
t.dialogMsg( itemsCount.toString() + " " +  AppLocalizations.of(context).translate("item")
    ,    AppLocalizations.of(context).translate("download_done"), context , false)  ;
        print(isHidden);
      });
    }


  }
