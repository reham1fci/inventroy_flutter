import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:inventroy_flutter/ApiConnection/Api.dart';
import 'package:inventroy_flutter/DataBase/database_helper.dart';
import 'package:inventroy_flutter/Model/InventoryPoint.dart';
import 'package:inventroy_flutter/Model/Store.dart';
import 'package:inventroy_flutter/Model/User.dart';
import 'package:inventroy_flutter/Screens/ProductsList.dart';
import 'package:inventroy_flutter/app_localizations.dart';
import 'package:inventroy_flutter/my_colors.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddInventoryPoint extends StatefulWidget {
   InventoryPoint myInv  ;
   AddInventoryPoint(this.myInv ,{Key key}): super(key: key);

   @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new InventoryPointState()  ;
  }

}
class InventoryPointState  extends State<AddInventoryPoint> {

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(backgroundColor: MyColors.colorPrimary,
        title: Text(AppLocalizations.of(context).translate("add_inventory_point")),),

      body:
    new Container(
    height: double.infinity,
    child:new Column(
    children: <Widget>[
    new Expanded(child:
    Align(alignment: Alignment.center , child:
    SingleChildScrollView(
      child:new Column(

        children: [
          createDropDownList(),
          refField(),
          descriptionField(),
          saveBtn()
        ],
      ),
    )
    )
    )
   ] )
    )
    )
    ;
  }
  String selectStore  = "المخازن" ;
  List <String> branchNameList = new  List() ; // هنغيرها ب class المخازن
  TextEditingController descEd   = new TextEditingController()  ;
  TextEditingController refEd    = new TextEditingController()  ;
 InventoryPoint myEditInv  ;
  final dbHelper = DatabaseHelper.instance;
  String storeErr  ;
  Api api  = new Api()   ;
List<Store> storesList   = new List();
User user  ;
int selectStoreId  =-1 ;
bool isEdit  =  false  ;
 @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getStoreList();
    myEditInv  = widget.myInv  ;
    if(myEditInv  != null ) {
      isEdit  = true  ;
   int store_id  = myEditInv.invStore    ;
   print(store_id) ;
      //storesList.indexo

      descEd.text  = myEditInv.invDesc == null ?"" :myEditInv.invDesc  ;
      refEd.text   =   myEditInv.invRef  ==  null  ?  "": myEditInv.invRef;
    }

  }
  void onSelectBranch(Store branch){
    setState(() {
      selectStoreId  = branch.storeID  ;
      selectStore  = branch.storeName  ;
    });
  }
  Padding createDropDownList(){
    // selectBranch =  "test2" ;
    return
      new Padding(padding:new EdgeInsets.only(bottom: 8.0 , left: 40.0  , right: 40.0 , top: 40.0) ,child:
      new DropdownButton<Store>(

        isExpanded: true,
        items: storesList.map((Store value) {
          return new DropdownMenuItem<Store>(
            value: value,
            child: new Text(value.storeName),
          );
        }).toList(),

        onChanged: onSelectBranch,
        hint:   new Text(
            selectStore),
        iconEnabledColor: MyColors.semoni,
      )) ;
  }

  Future <void>getStoreList () async{
    SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
    user = User.fromJsonShared(json.decode(sharedPrefs.getString("user") )) ;
    api.getStores(userID: user.userId  , orgId:  user.orgId  , onError:  dialogMsg , onSuccess: (List<Store>list){
      setState(() {
        storesList  = list  ;
        if(isEdit){
        for(int i = 0  ; i  <storesList .length  ; i++)
        {
          if(storesList[i].storeID == myEditInv.invStore ) {
            setState(() {
              selectStoreId  = storesList[i].storeID  ;
              selectStore    = storesList[i].storeName  ;
            }
            );
          }
        }}
      });

    })  ;
  }

  Future<void> addInventoryToSQLite( ) async {
  if(validation()) {
    var now = new DateTime.now();
    var formatter = new DateFormat("EEE, MMM d, yyyy","en");
    String formattedDate = formatter.format(now);
    print( formattedDate)  ;
    InventoryPoint inv  = new InventoryPoint(invStore:selectStoreId ,invRef:refEd.text    , invDone: 0 , invDesc:descEd.text  , invDate: formattedDate);
    if (isEdit){
     final  id = await dbHelper.updateInv(inv.DB(), myEditInv.invId);
     print(id) ;
     inv.invId = id ;
     confirmDialog(inv) ;
    }
    else{
    final id = await dbHelper.insert(inv.DB() , DatabaseHelper.inv_table_name);
    print(id) ;
    inv.invId = id ;
    Navigator.pushReplacement( context,
        MaterialPageRoute(builder: (context) => ProductsList(inv))) ;
    }



    // done
    // finish
    //


  }
  else{
    storeErr  = AppLocalizations.of(context).translate("select_store");
    dialogMsg(storeErr ,  AppLocalizations.of(context).translate("error"))  ;

  }

  }
  bool validation (){

    if(selectStoreId == -1) {
      return false  ;
    }

    else{
      return true ;

    }

  }

  Future<void> confirmDialog(InventoryPoint inv)async {return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(AppLocalizations.of(context).translate("edit_done")),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text(AppLocalizations.of(context).translate('continue')),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacement( context,
                    MaterialPageRoute(builder: (context) => ProductsList(inv))) ;
              },
            ),
            FlatButton(
              child: Text(AppLocalizations.of(context).translate("back")),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                Navigator.of(context).pop();

              },
            ),
          ],
        );
      },
    );
  }

  Future<void> dialogMsg(String message  , String title   ) async {
    setState(() {
     // loading = false ;
    });
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
              },
            ),
          ],
        );
      },
    );
  }
  showProgressDialog (){
    ProgressDialog  pr = new ProgressDialog(context);
    pr = new ProgressDialog(context,type: ProgressDialogType.Normal,
        isDismissible: false,
        showLogs: true);
//For normal dialog
    pr.style(
        message: 'Downloading file...',
        borderRadius: 10.0,
        backgroundColor: Colors.white,
        progressWidget: CircularProgressIndicator(),
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

  Padding refField(){
    return
      new Padding(padding:new EdgeInsets.only(bottom: 8.0 , left: 30.0  , right: 30.0 , top: 8.0) ,
          child:
          new TextField(controller:  refEd,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context).translate("ref"),
              fillColor: Colors.white,
              filled: false,
            ) ,) );
  }
  Padding descriptionField(){
    return
      new Padding(padding:new EdgeInsets.only(bottom: 8.0 , left: 30.0  , right: 30.0 , top: 8.0) ,
          child:
          new TextField(controller:  descEd,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context).translate("description"),
              fillColor: Colors.white,
              filled: false,
            ) ,) );
  }
  void onSaveClick() {
    setState(() {
      addInventoryToSQLite() ;

    });
  }
  Padding saveBtn() {
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
              onPressed: onSaveClick,
              child:
              new Row(
                children: [
                  new Expanded(child:
                  new Text(
                    AppLocalizations.of(context).translate("save"),
                    style: new TextStyle(color: Colors.white),
                    textAlign:  TextAlign.center,
                  )),

                ],
              ),

            )


        )
    )
    ;
  }

}
