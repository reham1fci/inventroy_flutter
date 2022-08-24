import 'dart:convert';
import 'dart:ffi';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart'  ;
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/services.dart';
import 'package:inventroy_flutter/ApiConnection/Api.dart';
import 'package:inventroy_flutter/DataBase/database_helper.dart';
import 'package:inventroy_flutter/Model/InventoryPoint.dart';
import 'package:inventroy_flutter/Model/Item.dart';
import 'package:inventroy_flutter/Model/User.dart';
import 'package:inventroy_flutter/Screens/ProductListWindow.dart';
import 'package:inventroy_flutter/Screens/productDetails.dart';
import 'package:inventroy_flutter/Tools/FuncTools.dart';
import 'package:inventroy_flutter/app_localizations.dart';
import 'package:inventroy_flutter/my_colors.dart';
import 'package:popup_menu/popup_menu.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';


class ProductsList  extends StatefulWidget {
  InventoryPoint inv ;
  ProductsList(this.inv ,{Key key}): super(key: key);
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new ProductsListState();
  }

  
  
}
class ProductsListState  extends State<ProductsList>{
  InventoryPoint myInv ;

  TextEditingController _searchQueryController = TextEditingController();
  bool _isSearching = true;
  String searchQuery = "";
  String barcode = "";
  bool loading  = false  ;

  Api api  = new Api()  ;
  Tools tools  = new Tools()  ;
  DatabaseHelper dbHelper = DatabaseHelper.instance;
List<Item> itemsList  = new List();
  User user  ;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    myInv = widget.inv;
    //handleAppLifecycleState()  ;
    getUserData();
  }


  handleAppLifecycleState() {
    AppLifecycleState _lastLifecyleState;
    SystemChannels.lifecycle.setMessageHandler((msg) {

      print('SystemChannels> $msg');

      switch (msg) {
        case "AppLifecycleState.paused":
          _lastLifecyleState = AppLifecycleState.paused;
          break;
        case "AppLifecycleState.inactive":
          _lastLifecyleState = AppLifecycleState.inactive;
          break;
        case "AppLifecycleState.resumed":
          _lastLifecyleState = AppLifecycleState.resumed;
          break;
        case "AppLifecycleState.suspending":
          break;
        default:
      }
    });
  }
    Future <void>getUserData () async{
      SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
      user = User.fromJsonShared(json.decode(sharedPrefs.getString("user") )) ;
      if (myInv.invDone == 1) {
        api.getItemByInvIdApi(inv: myInv,
            orgId: user.orgId,
            onError: () {},
            onSuccess: (List<Item> list) {
              setState(() {
                itemsList = list;
              });
            });
      }
      else if (myInv.invDone == 0){
        getInvItems();
      }
      else if(myInv.invDone ==2){
        getReqItems() ;
      }
    }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new  Scaffold(
      floatingActionButton: new FloatingActionButton(onPressed: onSaveCLick ,
        child: Text(AppLocalizations.of(context).translate("save")),
        backgroundColor: MyColors.colorPrimary,),
      appBar: AppBar(
        backgroundColor: MyColors.colorPrimary,
        leading: _isSearching ? const BackButton() : Container(),
        title: _isSearching ? _buildSearchField() : new Text("search"),
        actions: _buildActions(),
      ),
      body: loading? new Center(
        child: CircularProgressIndicator(),
      ): getView(itemsList),

    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchQueryController,
      autofocus: true,
      decoration: InputDecoration(
        hintText: "Search Data...",
        border: InputBorder.none,
        hintStyle: TextStyle(color: Colors.white30),
      ),
      style: TextStyle(color: Colors.white, fontSize: 16.0),
      textInputAction: TextInputAction.search,
      onChanged: (query) => updateSearchQuery,
      onSubmitted: (query){
        print("hgsdhgfhgfh"+query) ;
        setState(() {
          loading  = true ;
          searchItem(query)  ;
        });

      },

    );
  }

  List<Widget> _buildActions() {
    if (_isSearching) {
      return <Widget>[
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            if (_searchQueryController == null ||
                _searchQueryController.text.isEmpty) {
              Navigator.pop(context);
              return;
            }
            _clearSearchQuery();
          },
        ),
        new FlatButton(onPressed: scan, child: Image.asset("images/barCode.png" ,color: MyColors.white,width: 30 , height: 30,),),

      ];
    }

    return <Widget>[
      IconButton(
        icon: const Icon(Icons.search),
        onPressed: _startSearch,
      ),
      new FlatButton(onPressed: scan, child: Image.asset("images/barCode.png" ,color: MyColors.white,width: 30 , height: 30,),),

    ];
  }

  void _startSearch() {
    ModalRoute.of(context)
        .addLocalHistoryEntry(LocalHistoryEntry(onRemove: _stopSearching));

    setState(() {
      _isSearching = true;
    });
  }

  void updateSearchQuery(String newQuery) {
    setState(() {
     // loading  = true ;
     // searchItem(newQuery) ;
    });
  }

  void _stopSearching() {
    _clearSearchQuery();

    setState(() {
      _isSearching = false;
    });
  }

  void _clearSearchQuery() {
    setState(() {
      _searchQueryController.clear();
      updateSearchQuery("");
    });
  }
  Future<void> searchItem(String id) async {
    final count = await dbHelper.queryRowCount(DatabaseHelper.allItemTable);
           print("search" ) ;
    if(count>0){
      getItemsByIdOfLineData(id)  ;
    }
    else{
      getItemsByIdOnlineData(id)  ;

    }

}
  Future<void> searchItemByBarcode(String id) async {
    final count = await dbHelper.queryRowCount(DatabaseHelper.allItemTable);

    if(count>0){
      getItemsByBarcodeSqlite(id)  ;
    }
    else{
      getItemsByIdOnlineData(id)  ;

    }

  }
onSaveCLick(){
     if(itemsList.length>0) {
tools.confirmDialog(AppLocalizations.of(context).translate("confirm_save"),
    AppLocalizations.of(context).translate("save"), context,
    (){
   if(myInv.invDone==0)
   {
      onSaveConfirm();
   }
   else if(myInv.invDone==2){
     onSaveReq ()  ;
   }
    });

     }
     else{
       tools.dialogMsg(AppLocalizations.of(context).translate("no_item_found"),
           AppLocalizations.of(context).translate("error"), context, false)  ;
     }



}
onSaveConfirm(){
setState(() {
  api.saveInvPoint(userID: user.userId , functionName: "AddNew_MACH_INV",
      invID:  "",
      onSuccess:(String msg) async {

      int isDelete = await dbHelper.delete(table: DatabaseHelper.invItemsTable  , columnIdName:  DatabaseHelper.foreignInvID, id: myInv.invId) ;
      if(isDelete>0){
        int isDelete = await dbHelper.delete(table: DatabaseHelper.inv_table_name  , columnIdName:  DatabaseHelper.inv_id_column, id: myInv.invId) ;
      }
    tools.dialogMsg(AppLocalizations.of(context).translate("inv_point_saved"),
       msg, context, true)  ;

  }  , onError:(String msg){
  tools.dialogMsg(msg, AppLocalizations.of(context).translate("error"), context, false)  ;}

      , orgId:user.orgId  , inv: myInv , items: itemsList)  ;


});
}

  onSaveReq(){
    setState(() {
      api.savePurchaseREQ(
          userID: user.userId ,
          onSuccess:(String msg) async {
            int isDelete = await dbHelper.delete(table: DatabaseHelper.REQ_ITEM_TB
                , columnIdName:  DatabaseHelper.REQ_INV_REQ_ID,
                id: myInv.invId) ;
            if(isDelete>0){
              int isDelete = await dbHelper.delete(table: DatabaseHelper.REQTable  , columnIdName:  DatabaseHelper.REQ_REQ_ID, id: myInv.invId) ;
            }
            tools.dialogMsg(AppLocalizations.of(context).translate("request_saved"),
                msg, context, true)  ;

          }  , onError:(String msg){
            tools.dialogMsg(msg, AppLocalizations.of(context).translate("error"), context, false)  ;}

          , orgId:user.orgId
          , inv: myInv ,
          items: itemsList)  ;


    });
  }
  Future scan() async {
    try {
      ScanResult qrScanResult = await BarcodeScanner.scan();
      String barcode = qrScanResult.rawContent;
      setState(()  {
        loading  = true ;
        this.barcode = barcode;
        print("barcode") ;
        print("barcode"+this.barcode) ;
        _searchQueryController.text  = barcode  ;
        setState(() {
         String s  = this.barcode.replaceAll(" ", "");
          searchItemByBarcode(s) ;
        });

      });
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.cameraAccessDenied) {
        setState(() {
          this.barcode = 'The user did not grant the camera permission!';
        });
      } else {
        setState(() => this.barcode = 'Unknown error: $e');
      }
    } on FormatException{
      setState(() => this.barcode = 'null (User returned using the "back"-button before scanning anything. Result)');
    } catch (e) {
      setState(() => this.barcode = 'Unknown error: $e');
    }
  }
  getItemsByIdOnlineData(String itemId){
    api.getItemByBarCode(orgId: user.orgId ,
        onError: onGetItemError() ,
        onSuccess:  onGetItemSuccess ,
        userID: user.userId  ,
        barCode: itemId ,
        storeId:  myInv.invStore.toString()
    ) ;

  }
   showPopupMenu(Item item , Offset offset) {
     PopupMenu menu = PopupMenu(
        backgroundColor: MyColors.colorPrimary2,
       // lineColor: Colors.tealAccent,
       maxColumn: 2,

       context: context,
       items: [
         MenuItem(title: AppLocalizations.of(context).translate("edit"), image: Icon(Icons.edit, color: Colors.white , )),
         MenuItem(title: AppLocalizations.of(context).translate("delete"), image: Icon(Icons.delete, color: Colors.white,)),
       ],
       onClickMenu: (MenuItemProvider menuItem){
         if(menuItem.menuTitle ==  AppLocalizations.of(context).translate("edit") ) {
            onEditClick(item)  ;
         }
         else{
           onDeleteClick(item) ;
         }

       },
     );
     menu.show(rect: Rect.fromPoints(offset, offset));
   }


  void onClickMenu(MenuItemProvider item) {
    print('Click menu -> ${item.menuTitle}');





  }



  onEditClick(Item item){
setState(() {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => ProductDetails(item , myInv  , true )),
  );
});

  }
   onDeleteClick(Item item){
    setState(() {
      tools.confirmDialog(AppLocalizations.of(context).translate("confirm_delete"),
          AppLocalizations.of(context).translate("delete"), context, () async {
if(myInv.invDone  ==0){
      int delete = await dbHelper.delete(id: item.recordID ,
      columnIdName: DatabaseHelper.item_record_id ,
      table: DatabaseHelper.invItemsTable ) ;
      if(delete>=1) {
        setState(() {
          itemsList.remove(item) ;
          tools.dialogMsg( AppLocalizations.of(context).translate("delete"), AppLocalizations.of(context).translate("delete"), context, false) ;

        });
       }
      }
else if(myInv.invDone  ==1) {
  List<Item > deleteItems = new List()  ;
  deleteItems.add(item) ;
  api.deleteItemFromApi(orgId:  user.orgId, inv: myInv , items: deleteItems , userID: user.userId ,onSuccess: (String msg){
    setState(() {
      itemsList.remove(item) ;

    });
    tools.dialogMsg( AppLocalizations.of(context).translate("delete"), AppLocalizations.of(context).translate("delete"), context, false) ;

  } , onError:(String msg){
print (msg)  ;
  } )  ;
}
else if( myInv.invDone  == 2){
  int delete = await dbHelper.delete(id: item.recordID ,
      columnIdName: DatabaseHelper.REQ_ITEM_RERDNO ,
      table: DatabaseHelper.REQ_ITEM_TB ) ;
  if(delete>=1) {
    setState(() {
      itemsList.remove(item) ;
      tools.dialogMsg( AppLocalizations.of(context).translate("delete"), AppLocalizations.of(context).translate("delete"), context, false) ;

    });
  }
}




      }) ;
    });


  }
  onGetItemError(){

  }
  onGetItemSuccess(List<Item>list){
    setState(() {
      loading = false ;
      showDialog(
        context: context,
        builder: (_) => ProductListWindow(list , myInv),
      );
    });


  }
  Future getItemsByIdOfLineData(String barCodeID ) async {
     print('itemresult $barCodeID')  ;

     final allRows = await dbHelper.getItemsById(barCodeID);
     List<Item>itemList  = new List() ;
for(int i  =  0  ;  i  <allRows.length  ;  i++)     {
  Map<String, dynamic> map = allRows[i]  ;
 Item item  = Item.fromSql(map)  ;
 print(item)  ;
  print('itemresult $item')  ;
  itemList.add(item) ;

}
     print('itemresult $itemList')  ;
     onGetItemSuccess(itemList)  ;
   }
  Future<void> getItemsByBarcodeSqlite(String barCodeID ) async{
    final allRows = await dbHelper.getItemsByBarcode(barCodeID);
      List<Item>itemList  = new List() ;
      for(int i  =  0  ;  i  <allRows.length  ;  i++)     {
        Map<String, dynamic> map = allRows[i]  ;
        Item item  = Item.fromSql(map)  ;
        print('itemresult $item')  ;
        itemList.add(item) ;
      }
      onGetItemSuccess(itemList)  ;

  }
  getInvItems( ) async{
    final allRows = await dbHelper.getItemsByInvId(myInv.invId.toString());
    List<Item>itemList  = new List() ;
    for(int i  =  0  ;  i  <allRows.length  ;  i++)     {
      Map<String, dynamic> map = allRows[i]  ;
      Item item  = Item.invItemFromSql(map)  ;
      itemList.add(item) ;

    }
    setState(() {
      this.itemsList  = itemList  ;
    });
  }
  getReqItems( ) async{
    final allRows = await dbHelper.getItemsByReqId(myInv.invId.toString());
    List<Item>itemList  = new List() ;
    for(int i  =  0  ;  i  <allRows.length  ;  i++)     {
      Map<String, dynamic> map = allRows[i]  ;
      Item item  = Item.reqItemFromSql(map)  ;
      itemList.add(item) ;

    }
    setState(() {
      this.itemsList  = itemList  ;
    });
  }
   showItemsWindow(){

   }
  Widget getView(List<Item>list){
    print(list.toString())  ;
    if(list.length>0){
      return new ListView.builder(
        itemBuilder: (context  , index ){
          return listCard( list[index]) ;
        } ,itemCount:  list.length , ) ;

    }
    else{

      return SizedBox();

    }
  }

  GestureDetector  listCard  (Item item) {
    // getBackgroundColor(requestItem ) ;
    return  GestureDetector(
       onTapUp: (TapUpDetails details){
      showPopupMenu(item ,details.globalPosition) ;
    },
        child : new Padding(padding: EdgeInsets.only(top: 8.0  , bottom:  8.0  , right: 16.0 , left:  16.0 )  ,
            child :   new Card(

              child:new Container(
                // color: backgroundReq,
                //  padding:  new EdgeInsets.all(8.0),
                child:  new Column(

                  children: <Widget>[
                    new Center(child:
                    new Text(item.itemName)),
                    new Row(
                      // mainAxisAlignment: MainAxisAlignment.spaceBetween,

                      children: <Widget>[
                        Expanded(
                          flex: 1,
                          child: Container(
                            child:
                            new Center(child:
                            Text(AppLocalizations.of(context).translate("id"))
                              ,),
                            width: MediaQuery.of(context).size.width * 0.33,
                            decoration: BoxDecoration(
                              border: Border.all(width: 1 ,color: MyColors.colorPrimary),

                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Container(
                            child:
                            new Center(child:
                            Text(AppLocalizations.of(context).translate("unit"))
                              ,),
                            width: MediaQuery.of(context).size.width * 0.33,
                            decoration: BoxDecoration(
                              border: Border.all(width: 1 ,color: MyColors.colorPrimary),

                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Container(
                            child:
                            new Center(child:
                            Text(AppLocalizations.of(context).translate("count"))
                              ,),
                            width: MediaQuery.of(context).size.width * 0.33,
                            decoration: BoxDecoration(
                              border: Border.all(width: 1 ,color: MyColors.colorPrimary),

                            ),
                          ),
                        ),
                        // new Align(child: new Text(AppLocalizations.of(context).translate("inventory_point") +inv.invId.toString()) ,alignment: Alignment.centerLeft,),
                        //  new Align(child: new Text(inv.invDate) ,alignment: Alignment.centerRight,),

                      ],

                      mainAxisSize: MainAxisSize.max,) ,


                    new Row(
                      // mainAxisAlignment: MainAxisAlignment.spaceBetween,

                      children: <Widget>[
                        Expanded(
                          flex: 1,
                          child: Container(
                            child:
                            new Center(child:
                            Text(item.itemId)
                              ,),
                            width: MediaQuery.of(context).size.width * 0.33,

                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Container(
                            child:
                            new Center(child:
                            Text(item.unit)
                              ,),
                            width: MediaQuery.of(context).size.width * 0.33,

                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Container(
                            child:
                            new Center(child:
                            Text(item.itemQty.toString())
                              ,),
                            width: MediaQuery.of(context).size.width * 0.33,

                          ),
                        ),
                        // new Align(child: new Text(AppLocalizations.of(context).translate("inventory_point") +inv.invId.toString()) ,alignment: Alignment.centerLeft,),
                        //  new Align(child: new Text(inv.invDate) ,alignment: Alignment.centerRight,),

                      ],

                      mainAxisSize: MainAxisSize.max,) ,



                    //  new Padding(padding: EdgeInsets.all(16.0)  , child: new Text(inv.invDesc) ,) ,
                  ],),
              ) ,

              color: Theme.of(context).cardColor,
              //RoundedRectangleBorder, BeveledRectangleBorder, StadiumBorder
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(10.0),
                    top: Radius.circular(10.0)),
              ),

            ) ));
  }
  
}
class LifecycleEventHandler extends WidgetsBindingObserver {
  final AsyncCallback resumeCallBack;
  final AsyncCallback suspendingCallBack;

  LifecycleEventHandler({
    this.resumeCallBack,
    this.suspendingCallBack,
  });
 
  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.resumed:
        if (resumeCallBack != null) {
          await resumeCallBack();
        }
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        if (suspendingCallBack != null) {
          await suspendingCallBack();
        }
        break;
    }
  }
}