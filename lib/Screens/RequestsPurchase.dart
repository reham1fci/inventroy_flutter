import 'package:flutter/material.dart';
import 'package:inventroy_flutter/ApiConnection/Api.dart';
import 'package:inventroy_flutter/DataBase/database_helper.dart';
import 'package:inventroy_flutter/Model/InventoryPoint.dart';
import 'package:inventroy_flutter/Model/User.dart';
import 'package:inventroy_flutter/Screens/AddNewRequest.dart';
import 'package:inventroy_flutter/Tools/FuncTools.dart';
import 'package:inventroy_flutter/app_localizations.dart';
import 'package:popup_menu/popup_menu.dart';

import '../my_colors.dart';
import 'ProductsList.dart';

class PurchaseRequest  extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new PurchaseRequestStatus();
  }


}



class  PurchaseRequestStatus extends State<PurchaseRequest>with SingleTickerProviderStateMixin {
  TabController _tabController;
  Api api  = new Api()  ;
  User user  ;
  int count  = 0  ;
  Tools tools  = new Tools() ;


  List<InventoryPoint> invList = new List() ;
  List<InventoryPoint> localPurchaseReq = new List() ;
  final dbHelper = DatabaseHelper.instance;

  bool loading = true ;
  void initState() {

  super.initState();
  _tabController = TabController(length: 2, vsync: this);
  getPurchaseRequest();

  }
  Future<void> getPurchaseRequest() async {
    List<InventoryPoint> list = new List() ;
    final allRows = await dbHelper.queryAllRows(DatabaseHelper.REQTable)  ;
    for(int i  =  0  ;  i  < allRows.length  ;  i++)     {
      Map<String, dynamic> map = allRows[i]  ;
      InventoryPoint inv  = InventoryPoint.fromSqlReq(map)  ;
      list.add(inv) ;

    }
    setState(() {
      loading  = false ;
      localPurchaseReq  = list ;
    });


  }
  void onFloatingActionClick() {
    setState(() {
      Navigator.pushReplacement( context,
          MaterialPageRoute(builder: (context) => AddNewRequest(null))) ;
    });
  }
  @override
  Widget build(BuildContext context) {
    final List<Tab> myTabs = <Tab>[
      new Tab(text:AppLocalizations.of(context).translate("save_purchase_request")),
      new Tab(text:AppLocalizations.of(context).translate("purchase_request")),
    ];
    // TODO: implement build
    return new Scaffold(

    floatingActionButton: new FloatingActionButton(onPressed: onFloatingActionClick ,  child: Icon(Icons.add , color: MyColors.white,),
      backgroundColor: MyColors.colorPrimary,),
    appBar: new AppBar(
    backgroundColor: MyColors.colorPrimary,
    title: new Text(AppLocalizations.of(context).translate("purchase_request")),
    bottom: new TabBar(
    controller: _tabController,
    tabs: myTabs,
    labelColor: MyColors.white,
    indicatorColor: MyColors.white,
    ),
    ),
    body: loading? new Center(
    child: CircularProgressIndicator(),
    ): new TabBarView(
    controller: _tabController,
    children:
    myTabs.map((Tab tab) {
    int index = myTabs.indexOf(tab);
    if (index == 0) {


    return  getView(localPurchaseReq , 1) ;


    }
    else if (index == 1) {
    if(count  == 0){
    //getInventoryPointLocal();
    count =count+1 ;


    }
    return  getView(localPurchaseReq ,0) ;

    }
    else{
    return new Center(child: new Text(tab.text));
    }
    }).toList()
    ));


  }
  Widget getView(List<InventoryPoint>list , int type ){
    if(list.length>0){
      return new ListView.builder(
        itemBuilder: (context  , index ){
          return listCard( list[index] , type) ;
        } ,itemCount:  list.length , ) ;

    }
    else{
      return    noThingView()  ;
    }
  }
  Widget noThingView(){
    return new Container(child:
    new Center(
      child:  new Column( children: <Widget>[
        //  Image.asset('images/nothing.png', fit: BoxFit.contain),
        Text (AppLocalizations.of(context).translate("no_requests"))
      ], mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,),
    ) , height: double.infinity, ) ;
  }
  GestureDetector  listCard  (  InventoryPoint inv  ,  int type ) {
    //  InventoryPoint inv  = list[index] ;
    // getBackgroundColor(requestItem ) ;
    return  GestureDetector(
        onTap:(){
         Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ProductsList(inv)),
          );

          // String name  =  list[index].  name ;
          //  print(name )  ;
        } ,
        onLongPressEnd: (LongPressEndDetails details){
          if(type ==0){ // local
            showPopupMenu(inv ,details.globalPosition) ;
          }

        },
        child : new Padding(padding: EdgeInsets.only(top: 8.0  , bottom:  8.0  , right: 16.0 , left:  16.0 )  ,
            child :   new Card(

              child:new Container(
                // color: backgroundReq,
                //  padding:  new EdgeInsets.all(8.0),
                child:  new Column(

                  children: <Widget>[
                    new Container(
                      padding:  new EdgeInsets.all(8.0),

                      child:
                      new Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,

                        children: <Widget>[
                          new Align(child: new Text(AppLocalizations.of(context).translate("inventory_point") +inv.invId.toString()) ,alignment: Alignment.centerLeft,),
                          new Align(child: new Text(inv.invDate) ,alignment: Alignment.centerRight,),

                        ],mainAxisSize: MainAxisSize.max,) ,)  ,



                    new Padding(padding: EdgeInsets.all(16.0)  , child: new Text(inv.invDesc) ,) ,
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

  showPopupMenu(InventoryPoint item , Offset offset) {
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
  onEditClick(InventoryPoint item){
    setState(() {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AddNewRequest(item)),
      );
    });

  }
  onDeleteClick(InventoryPoint inv){
    setState(() {
      tools.confirmDialog(AppLocalizations.of(context).translate("confirm_delete"),
          AppLocalizations.of(context).translate("delete"), context, () async {
            int delete = await dbHelper.delete(id: inv.invId ,
                columnIdName: DatabaseHelper.REQ_INV_REQ_ID ,
                table: DatabaseHelper.REQ_ITEM_TB ) ;
              // itemsList.remove(item) ;
              int delete2 = await dbHelper.delete(id: inv.invId ,
                  columnIdName: DatabaseHelper.REQ_REQ_ID ,
                  table: DatabaseHelper.REQTable ) ;
              setState(() {
                localPurchaseReq.remove(inv) ;


              tools.dialogMsg( AppLocalizations.of(context).translate("delete"), AppLocalizations.of(context).translate("delete"), context, false) ;
            });



          });


    });}


}