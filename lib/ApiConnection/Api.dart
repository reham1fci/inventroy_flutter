import 'dart:io';
import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart'  as http ;
import 'package:inventroy_flutter/DataBase/database_helper.dart';
import 'package:inventroy_flutter/Model/Branch.dart';
import 'package:inventroy_flutter/Model/InventoryPoint.dart';
import 'package:inventroy_flutter/Model/Item.dart';
import 'package:inventroy_flutter/Model/PrTyps.dart';
import 'package:inventroy_flutter/Model/Store.dart';
import 'package:inventroy_flutter/Model/User.dart';
import 'package:inventroy_flutter/Model/Vendor.dart';
import 'package:inventroy_flutter/Screens/Home.dart';
import 'package:inventroy_flutter/Tools/FuncTools.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'dart:async';

import 'dart:convert' show json, jsonEncode;
import 'package:shared_preferences/shared_preferences.dart';
class Api  {
   static String  baseUrl  = "http://174.142.60.74:8091/api/"  ;
  Future login({String userId , String password  ,  String orgId, Function  onLogin  , Function onError}  )async{
    String url  = baseUrl+"Users";
    User mUser = new User.login(userId , password , orgId) ;
    String mobileMacID  = await _getId();

    http.post(url ,body  : mUser.toMap(mobileMacID) ) .then((http.Response response) {
      print(response)  ;
      print(response.statusCode)  ;
      print(response.body)  ;
      if(response.statusCode == 200) {
        String jsonStr = json.decode(response.body);
        var jsonObj = json.decode(jsonStr);

        String  msg  = jsonObj['Msg']  ;
        print(msg)  ;
        if(msg  == "Success") {
          print(jsonObj) ;
          User c = User.fromJson(jsonObj,userId , password , orgId ) ;
          onLogin(c)  ;
          return c ;
        }
        else
        {
          onError(msg) ;
          return null  ;
        }
      }
          else {
           onError("Connection Error") ;
          return null ;
      }

    }
    );

  }
  Future getCountItems(  Function onProgress , Function onDismiss)async{
    SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
     User user = User.fromJsonShared(json.decode(sharedPrefs.getString("user") )) ;
    String orgId  =user.orgId  ;
    String url  = baseUrl+"Inventory";
    var map = new Map<String, dynamic>();
    map["Org_id"]= orgId ;
    map["FuncationType"] ="GetItemShortCount";

    http.post(url ,body  : map ) .then((http.Response response) {
      if (response.statusCode == 200) {
        String jsonObj = json.decode(response.body);
        var ob = json.decode(jsonObj);


        print(jsonObj);

        var arr = ob["JS_WH_DTL"];
        print(arr);
        Map<String, dynamic> obj = arr[0];
        double numOfItems = obj["COUNT(*)"];
        int count = numOfItems.toInt();

        print(count.toString());
        if (numOfItems > 5000) {
          getDoubleData(count, onProgress, onDismiss, orgId);
        }
        else {
          getSmallData(count , orgId ,  onProgress, onDismiss);
        }



      }
    } );

         }
   Future getSmallData(int itemCount , String orgId  , Function onProgress , Function onDismiss) async{
     var map = new Map<String, dynamic>();
     List<Item>itemsList  = new List()  ;
     String url  = baseUrl+"Inventory";
     map["Org_id"]= orgId;
     map["FuncationType"] ="GetItemShortList";
     map["skip"] ="0";
     map["take"] =itemCount.toString();
     print(map.toString())  ;
     final dbHelper = DatabaseHelper.instance;

     http.post(url,body  : map).then((http.Response response) async {
       onProgress("downloding " + itemCount.toString()+ " item"  , 100.0)  ;


       String jsonStr = json.decode(response.body);
       jsonStr.replaceAll("\\" , "") ;
       var jsonObj = json.decode(jsonStr);
       var  itemsArr  = jsonObj['JS_WH_DTL']  ;
       for(int i  =  0 ; i  <itemsArr.length  ; i++) {
         var itemObj    =  itemsArr[i]  ;
         Item item = Item.fromJson(itemObj) ;
          if(item.unit != null) {
         itemsList.add(item)  ;
         final id = await dbHelper.insert(item.allItemsDB() , DatabaseHelper.allItemTable);
         print('inserted row id: $id');}
         //   value.add(jsonObj)  ;
       }
       onDismiss(itemCount) ;

     }
     );

   }
  Future<List<Map<String, dynamic>>> getDoubleData( int numOfItems  ,Function onProgress , Function onDismiss , String orgId) async {
     int count  = 0 ;
     var value = <Map<String, dynamic>>[];
     List<Item>itemsList  = new List()  ;
     int NUM  = 5000 ;
    double div = numOfItems / NUM;
    int numOfLoop = div.toInt();
    ////
    double p =  100/numOfLoop  ;
    int  percentage  = p.toInt()  ;
    print(percentage.toString()) ;
    print(numOfLoop.toString()) ;
    String num = p.toStringAsFixed(0); // 5
   // int percentage  = int.parse(num) ;
     double progress=0 ;
  ////
 // int remind  =  100 -(percentage*numOfLoop)  ;
    // int c  = numOfLoop-remind  ;
    // double  percentage  =  100/c  ;
    // double progress=0 ;
    // HomeState h  = new HomeState() ;

     List < Future <http.Response>> arr  = new List()  ;
     int remindItems = numOfItems - (numOfLoop * NUM);
     String url  = baseUrl+"Inventory";
     for( int i  =  0  ;   i  <  numOfLoop  ;  i++) {
      int skip  =  i * NUM  ;
      int take  = (  i+1) * NUM ;
      count  = count+1  ;
      var map = new Map<String, dynamic>();
      map["Org_id"]= orgId;
      map["FuncationType"] ="GetItemShortList";
      map["skip"] =skip.toString();
      map["take"] =take.toString();
      print(map.toString())  ;
      var r1 = http.post(url,body  : map);
      arr.add(r1)  ;
    }
     if (remindItems>0) {
       int skip = numOfLoop * NUM;
       int take = skip+remindItems;
       count = count +1   ;
       var map = new Map<String, dynamic>();
       map["Org_id"]= orgId;
       map["FuncationType"] = "GetItemShortList";
       map["skip"] = skip.toString();
       map["take"] = take.toString();
       var r1 = http.post(url,body: map);
       arr.add(r1) ;
     }

     print (arr.length) ;
     int loopNum  = arr.length  ;
    var results = await Future.wait(arr); // list of Responses
     final dbHelper = DatabaseHelper.instance;
     int countt  = 0 ;
     int countloop  =  0   ;
     for (var response in results) {
      print("statuesCode");
      print(response.statusCode);
      print(response.body);
      countloop  = countloop  +1  ;
      countt= countt+NUM;
      progress = progress+percentage;
     // h.updateProgressDialog("downloding " + countt.toString()+"item" , progress);
       if(countloop  == loopNum){
         onProgress("downloding " + countt.toString()+ " item"  , 100.0)  ;
       }
       else{
      onProgress("downloding " + countt.toString()+"item"  , progress)  ; }
      // todo - parse the response - perhaps JSON
      String jsonStr = json.decode(response.body);
      jsonStr.replaceAll("\\" , "") ;
      var jsonObj = json.decode(jsonStr);
      var  itemsArr  = jsonObj['JS_WH_DTL']  ;
      for(int i  =  0 ; i  <itemsArr.length  ; i++) {
        var itemObj    =  itemsArr[i]  ;
        Item item = Item.fromJson(itemObj) ;
        itemsList.add(item)  ;
        final id = await dbHelper.insert(item.allItemsDB() , DatabaseHelper.allItemTable);
        print('inserted row id: $id');
        value.add(jsonObj)  ;

    }
      print (itemsList.length) ;

    }
     //h.dismissDialog()  ;
     onDismiss(numOfItems) ;
    return value;
  }

Future getStores({  String orgId  , String userID , Function  onSuccess  , Function onError}  )async{
  String url  = baseUrl+"Inventory";
  var map = new Map<String, dynamic>();
  List<Store> storesList  =  new List()  ;
  map["Org_id"]= orgId;
  map["user_id"]= userID;
  map["FuncationType"] ="GetInveontryList";
  http.post(url ,body  : map ) .then((http.Response response) {
    if(response.statusCode == 200) {
      String jsonStr = json.decode(response.body);
      jsonStr.replaceAll("\\" , "") ;
print(jsonStr)  ;
      var jsonObj = json.decode(jsonStr);
      var  storesArr  = jsonObj['JS_WH_DTL']  ;
       for(int i  =  0 ; i  <storesArr.length  ; i++) {
         var jsonStore    =  storesArr[i]  ;
         Store store = Store.fromJson( jsonStore) ;
storesList.add(store)  ;

       }
      onSuccess(storesList)  ;

    }
    else{
      onError();
    }

});
  }


   Future getItemByBarCode({String orgId  , String userID, String barCode,  String storeId,
     Function  onSuccess  , Function onError}  )async{
String url  = baseUrl+"Inventory";
var map = new Map<String, dynamic>();
List<Item> itemsList  =  new List()  ;
map["Org_id"]= orgId;
map["user_id"]= userID;
map["FuncationType"]  ="GetItem_ByID/Barcode";
map["ID_BarCode"]  = barCode ;
map["WH_Code"] =  storeId;
print(map.toString()) ;
http.post(url ,body  : map ) .then((http.Response response) {
  print(response.statusCode)  ;

  if(response.statusCode == 200) {

    String jsonStr = json.decode(response.body);
    jsonStr.replaceAll("\\" , "") ;
    print(jsonStr)  ;
    var jsonObj = json.decode(jsonStr);
    var  itemsArr  = jsonObj['JS_WH_DTL']  ;
    for(int i  =  0 ; i  <itemsArr.length  ; i++) {
      var jsonStore    =  itemsArr[i]  ;
      Item item = Item.fromJson( jsonStore) ;
      itemsList.add(item)  ;

    }
    onSuccess(itemsList)  ;

  }
  else{
    onError();
  }

});

  }
  Future getItemByUnit({ String userID  ,  String orgId  , String barCode,  String unit,
    Function  onSuccess  , Function onError}  )async{
    String url  = baseUrl+"Inventory";
    var map = new Map<String, dynamic>();
    List<Item> itemList  =  new List()  ;
    Item item ;
    map["Org_id"]= orgId;
    map["user_id"]= userID;
    map["FuncationType"] =  "GetItem_ByID_And_Unit";
    map["ID_BarCode"] =  barCode ;
    map["Unit"] =  unit;
    http.post(url ,body  : map ) .then((http.Response response) {
      if(response.statusCode == 200) {
        String jsonStr = json.decode(response.body);
        print(jsonStr)  ;
        var jsonObj = json.decode(jsonStr);
        var  storesArr  = jsonObj['JS_WH_DTL']  ;
        for(int i  =  0 ; i  <storesArr.length  ; i++) {
          var jsonStore    =  storesArr[i]  ;
           item = Item.fromJson2( jsonStore) ;

        }
        onSuccess(item)  ;

      }
      else{
        onError();
      }

    });

  }


   Future getInvList( { String  userID , String orgId   ,
       Function onSuccess ,Function onError}
       ) async {
     String url = baseUrl + "Inventory";
     String mobileID  = await _getId();

     var map = new Map<String, dynamic>();
     List<InventoryPoint> invList  =  new List()  ;
     map["Org_id"]= orgId;
     map["user_id"]= userID;
     map["FuncationType"] =  "GET_MACH_INV_MST";
     map["Device_Name"] =  mobileID;
     print(map.toString()) ;
     Tools tools  = new Tools();
   // bool check =    await  tools.checkInternetConn() ;
    // print(check) ;
    // if(check) {
try{
     await  http.post(url, body: map,).then((http.Response response) {
         print(response.statusCode);
         if (response.statusCode == 200) {
           String jsonStr = json.decode(response.body);
           var jsonObj = json.decode(jsonStr);
           print(jsonObj);
           var invArr = jsonObj['JS_MACH_INV_MST'];
           for (int i = 0; i < invArr.length; i++) {
             var invPoint = invArr[i];
             InventoryPoint point = InventoryPoint.fromJson(invPoint, 1);
             invList.add(point);
           }
           onSuccess(invList);
         }
         else {
           onError();
         }
       });
     }
on SocketException catch(_){
  print("exception");
  onSuccess(invList);
}

   }

   Future <String> saveInvPoint( { String  userID , String orgId   , List<Item>items , InventoryPoint inv
       ,  Function onSuccess ,Function onError  , String functionName , String invID}
       ) async {
     String url = baseUrl + "Inventory";
     String mobileID  = await _getId();
     var map = new Map<String, dynamic>();
     var map2 = new Map<String, dynamic>();
     List itemsMap = new List< Map<String, dynamic>>();
     for (int i = 0; i < items.length; i++) {

       itemsMap.add(  items[i].toJson(i+1));
     }
     map["Org_id"]= orgId;
     map["user_id"]= userID;
     map["FuncationType"] =  functionName;
     map["Device_Name"] =  mobileID;
     map2["INV_NO"] =  invID;
     map2["INV_Date"] =  inv.invDate;
     map2["INV_DESC"] =  inv.invDesc;
     map2["REF_NO"] =  inv.invRef;
     map2["MACH_INV_DTL"] =  itemsMap;
     map["MACH_INV"] = map2 ;

     print(map.toString()) ;
     print( jsonEncode(map) ) ;

     http.post(url ,body  :jsonEncode(map)  ,headers: {"Content-Type": "application/json"}, ) .then((http.Response response) {
       if(response.statusCode == 200) {
         String msg = json.decode(response.body);

         if(msg  == "Success") {
           onSuccess(msg) ;
           return msg;
         }
         else
         {
           onError(msg) ;
           return msg  ;
         }
       }
       else {
         onError("Connection Error") ;
         return null ;
       }

     });

   }
   Future <String> savePurchaseREQ( { String  userID , String orgId
     , List<Item>items , InventoryPoint inv
     ,  Function onSuccess ,Function onError  }
       ) async {
     String url = baseUrl + "Inv_Process";
     String mobileID  = await _getId();
     var map = new Map<String, dynamic>();
     var map2 = new Map<String, dynamic>();
     List itemsMap = new List< Map<String, dynamic>>();
     for (int i = 0; i < items.length; i++) {

       itemsMap.add(  items[i].reqToJson(i+1));
     }
     map["Org_id"]= orgId;
     map["user_id"]= userID;
     map["FuncationType"] =  "Insert_New_Request";
     map["Device_Name"] =  mobileID;
     map2=  inv.reqToJson();
     map2["PUR_REQ_DTL"] =  itemsMap;
     map["PUR_REQ_MST"] = map2 ;


     print(map.toString()) ;
     print( jsonEncode(map) ) ;

     http.post(url ,body  :jsonEncode(map)  ,headers: {"Content-Type": "application/json"}, ) .then((http.Response response) {
       if(response.statusCode == 200) {
         var jsonObj = json.decode(response.body);
print(jsonObj)  ;
String  msg  = jsonObj["msg"]   ;
         if(msg  == "Success") {
           onSuccess(msg) ;
           return msg;
         }
         else
         {
           onError(msg) ;
           return msg  ;
         }
       }
       else {
         onError("Connection Error") ;
         return null ;
       }

     });

   }
   Future <String> deleteItemFromApi( { String  userID , String orgId   ,
     List<Item>items , InventoryPoint inv
     ,  Function onSuccess ,Function onError }
       ) async {
     String url = baseUrl + "Inventory";
     String mobileID  = await _getId();
     var map = new Map<String, dynamic>();
     var map2 = new Map<String, dynamic>();
     List itemsMap = new List< Map<String, dynamic>>();
     for (int i = 0; i < items.length; i++) {

       itemsMap.add(  items[i].deleteToJson(inv.invId));
     }
     map["Org_id"]= orgId;
     map["user_id"]= userID;
     map["FuncationType"] =  "Delete_MACH_INV_OneItem";
     map["Device_Name"] =  mobileID;
     map2["INV_NO"]      = inv.invId  ;
     map2["MACH_INV_DTL"] =  itemsMap;
     map["MACH_INV"]    = map2  ;


     print(map.toString()) ;
     print( jsonEncode(map) ) ;

     http.post(url ,body  :jsonEncode(map)  ,headers: {"Content-Type": "application/json"}, ) .then((http.Response response) {
       if(response.statusCode == 200) {
         String msg = json.decode(response.body);

         if(msg  == "Success") {
           onSuccess(msg) ;
           return msg;
         }
         else
         {
           onError(msg) ;
           return msg  ;
         }
       }
       else {
         onError("Connection Error") ;
         return null ;
       }

     });

   }
   Future getItemByInvIdApi( { String orgId , InventoryPoint inv
     ,  Function onSuccess ,Function onError }
       ) async {
     String url = baseUrl + "Inventory";
     var map = new Map<String, dynamic>();
     List<Item>itemsList  = new List()  ;
     map["Org_id"]= orgId;
     map["FuncationType"] =  "GET_MACH_INV_DTL";
     map["MACH_INV"] =  inv.toJsonInv(inv.invId)  ;

     print(map.toString()) ;
     print( jsonEncode(map) ) ;

     http.post(url ,body  :jsonEncode(map)  ,headers: {"Content-Type": "application/json"}, ) .then((http.Response response) {
       if(response.statusCode == 200) {
           String jsonStr = json.decode(response.body);
           var jsonObj = json.decode(jsonStr);
           print(jsonObj)  ;
           var  storesArr  = jsonObj['JS_MACH_INV_DTL']  ;
           for(int i  =  0 ; i  <storesArr.length  ; i++) {
             var jsonStore    =  storesArr[i]  ;
             Item item = Item.fromJsonByInv( jsonStore) ;
             itemsList.add(item)  ;

           }
           onSuccess(itemsList)  ;

         }
         else{
           onError();
         }

     });

   }
   Future  getVendor( String orgId , String userID , Function onSuccess , Function onError ) async {
     String url = baseUrl + "Inventory";
     String mobileID  = await _getId();
     var map = new Map<String, dynamic>();
     List<Vendor> vendorsList  =  new List()  ;
     map["Org_id"]= orgId;
     map["user_id"]= userID;
     map["FuncationType"] =  "GET_VNDR";
     map["Device_Name"] =  mobileID;
     print(map.toString()) ;

     http.post(url ,body  : map ) .then((http.Response response) {
       if(response.statusCode == 200) {
         String jsonStr = json.decode(response.body);
         var jsonObj = json.decode(jsonStr);
         var  vendorsArr  = jsonObj['JS_VNDR_DTL']  ;
         for(int i  =  0 ; i  <vendorsArr.length  ; i++) {
           var vendorObj    =  vendorsArr[i]  ;
           Vendor vendor = Vendor.fromJson( vendorObj)  ;
           vendorsList.add(vendor)  ;

         }
         onSuccess(vendorsList)  ;

       }
       else{
         onError();
       }

     });

   }
   Future  getPrType( String orgId , String userID , Function onSuccess , Function onError ) async {
     String url = baseUrl + "Inv_Process";
     String mobileID  = await _getId();
     var map = new Map<String, dynamic>();
     List<PrTypes> prTypesList  =  new List()  ;
     List<Branch> costCenterList  =  new List()  ;
     List<Branch> branchList  =  new List()  ;
     map["Org_id"]= orgId;
     map["user_id"]= userID;
     map["FuncationType"] =  "GetInventoryDefination";
     map["Device_Name"] =  mobileID;
     print(map.toString()) ;

     http.post(url ,body  : map ) .then((http.Response response) {
       if(response.statusCode == 200) {
         String jsonStr = json.decode(response.body);
         print("infoData"+jsonStr)  ;

         var jsonObj = json.decode(jsonStr);
         var  arr  = jsonObj['JS_PREQ_TYPES']  ;
         var  centerCostArr  = jsonObj['JS_CST_CNTR']  ;
         var  depArr  = jsonObj['JS_BRAN_DTL']  ;
         print(centerCostArr)  ;
         print(depArr)  ;

         for(int i  =  0 ; i  <arr.length  ; i++) {
           var prObject    =  arr[i]  ;
           PrTypes pr = PrTypes.fromJson( prObject)  ;
           prTypesList.add(pr)  ;

         }
         for(int i  =  0 ; i  <centerCostArr.length  ; i++) {
           var centersObj    =  centerCostArr[i]  ;
          // print(" center data"+centersObj) ;
           Branch cc = Branch.centerJson( centersObj)  ;
           costCenterList.add(cc)  ;

         }
         for(int i  =  0 ; i  <depArr.length  ; i++) {

           var branchObj    =  depArr[i]  ;
           Branch branch = Branch.fromJson( branchObj)  ;
           branchList.add(branch)  ;
         }
         onSuccess(prTypesList ,branchList , costCenterList )  ;

       }
       else{
        onError();
       }

     });

   }
Future<String> _getId() async {
  var deviceInfo = DeviceInfoPlugin();
  if (Platform.isIOS) { // import 'dart:io'
    var iosDeviceInfo = await deviceInfo.iosInfo;
    return iosDeviceInfo.identifierForVendor; // unique ID on iOS
  } else {
    var androidDeviceInfo = await deviceInfo.androidInfo;
    return androidDeviceInfo.androidId; // unique ID on Android
  }
}

}