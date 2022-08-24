import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:inventroy_flutter/ApiConnection/Api.dart';
import 'package:inventroy_flutter/DataBase/database_helper.dart';
import 'package:inventroy_flutter/Model/InventoryPoint.dart';
import 'package:inventroy_flutter/Model/Item.dart';
import 'package:inventroy_flutter/Model/User.dart';
import 'package:inventroy_flutter/Screens/ProductsList.dart';
import 'package:inventroy_flutter/Tools/FuncTools.dart';
import 'package:inventroy_flutter/app_localizations.dart';
import 'package:inventroy_flutter/my_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
class ProductDetails extends StatefulWidget{
  Item item ;
  InventoryPoint inv  ;
   bool isItemEdit ;
  ProductDetails(this.item  , this.inv,  this.isItemEdit  ,{Key key}): super(key: key);
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new productDetailsState();
  }
}
class productDetailsState extends State<ProductDetails>{
  Item _item  ;
  InventoryPoint _inv  ;
  bool isEdit ;
  Api  api  = new Api()  ;
  User user  ;
  String storeNum  ;

  TextEditingController countEd  = new TextEditingController()  ;
  final dbHelper = DatabaseHelper.instance;
  int count  =  0      ;
  Tools t = new Tools()  ;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _item = widget.item  ;
    _inv  = widget.inv ;
    print(  _inv.invStore.toString())  ;
    print(  _item.storeCode.toString())  ;
    setState(() {
      countEd.text = count.toString() ;
      if(_inv.invStore.toString()== "null"){
        storeNum=_item.storeCode.toString() ;
      }
      else{
        storeNum  =  _inv.invStore.toString() ;
      }
    });

    getUserData() ;
     isEdit  = widget.isItemEdit  ;
   if(isEdit) {
     setState(() {
       countEd.text = _item.itemQty.toString() ;
     });

   }

  }
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
    appBar: new AppBar(backgroundColor: MyColors.colorPrimary,
    title: Text(AppLocalizations.of(context).translate("product_details")),actions: [
      FlatButton(child:
       new Column(

        children: <Widget>[
      Image.asset("images/load_more.png" , width:30, height: 30,)
,
        Text( AppLocalizations.of(context).translate("show_more")   ,
          style: TextStyle(color: MyColors.white), ),

      ])

      ,onPressed: getItemDetails
        ,hoverColor:MyColors.redColor ,
        focusColor:MyColors.redColor ,)
      ],),

    body:
    new Container(
         height: double.infinity,
      /*  decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage("images/background.jpg"), fit: BoxFit.cover)),*/

    //new Padding(padding:EdgeInsets.all(10),
   child: SingleChildScrollView(
    child:new Column(
    //  crossAxisAlignment: CrossAxisAlignment.start ,
    //  mainAxisSize: MainAxisSize.min,
    children: [
       // new  Flexible( child:
      dataTable()   ,
      Container(
          width: MediaQuery.of(context).size.width, // Full Width of Screen
          child:
          Column( mainAxisAlignment: MainAxisAlignment.center, children: [countView()])
      ),

    ],
    ),
    )


     ),
        bottomNavigationBar: BottomAppBar(child: saveBtn(),),

    )
    ;

  }
  void onSaveClick() {
    setState(() async {
      _item.storeCode = storeNum ;
      //_item.itemQty  = int.parse(countEd.text) ;
      if (countEd.text.isEmpty) {
        t.dialogMsg(AppLocalizations.of(context).translate("enter_count"),
            AppLocalizations.of(context).translate("error"), context, false);
      }
      else {
        count = int.parse(countEd.text);
        if (count > 0) {
          _item.itemQty = count;
          if(isEdit){
            if(_inv.invDone  == 0) {
              final id = await dbHelper.update(
                  _item.invItemDB(_inv.invId), _item.recordID);
            /* t.dialogMsg(
                  AppLocalizations.of(context).translate("add_item"), "", context,
                  true);*/
              t.toastMessage(AppLocalizations.of(context).translate("add_item")) ;
              Navigator.of(context).pop();

              print("edit"+id.toString());
            }
            if(_inv.invDone  == 1) {
              saveInvItemAPi(_item, "Edit_MACH_INV_OneItem")  ;

            }
            if(_inv.invDone  == 2) {
              final id = await dbHelper. updateReq(
                  _item.reqItemDB(_inv.invId), _item.recordID);
              t.toastMessage(AppLocalizations.of(context).translate("add_item")) ;
              Navigator.of(context).pop();
            }
          }
          else{
            if(_inv.invDone ==0){
              final id = await dbHelper.insert(
                  _item.invItemDB(_inv.invId), DatabaseHelper.invItemsTable);
             refresh("add_item");


            }
            if(_inv.invDone  ==1){
              saveInvItemAPi(_item, "AddNew_MACH_INV_OneItem")  ;

            }
            if(_inv.invDone  ==2){
              final id = await dbHelper.insert(_item.reqItemDB(_inv.invId), DatabaseHelper.REQ_ITEM_TB);

                  refresh("add_item") ;
            }

          }
        }
      }
    });
  }
  Future<void> dialogMsg(String message  , String title   , BuildContext context ) async {
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
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                Navigator.of(context).pop();
               Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProductsList(_inv)),
                );
              },
            ),
          ],
        );
      },
    );
  }
  void refresh(String message){
    t.toastMessage(message)  ;
    Navigator.of(context).pop();
    Navigator.of(context).pop();
  // Navigator.of(context).pop();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ProductsList(_inv)),
    );
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
  void onSelectBranch(String branch){
    setState(() {

    });
  }
  String selectStore  = "" ;

  List <String> branchNameList = new  List() ;
  Widget createDropDownList(){
    // selectBranch =  "test2" ;
    return
    /*  new  Expanded(child: Container(
        padding: EdgeInsets.only(left: 10 ,right: 10),
          decoration: new BoxDecoration(
            color: MyColors.white,
          borderRadius: const BorderRadius.all(
          const Radius.circular(8.0),
    )),

    child:*/
      new DropdownButton<String>(

        isExpanded: true,
        items: branchNameList.map((String value) {
          return new DropdownMenuItem<String>(
            value: value,
            child: new Text(value),
          );
        }).toList(),

        onChanged: onSelectBranch,
        hint:   new Text(
            selectStore),
      );
    //),flex: 1, );
  }
  Widget dataTable() {
    return Table(
        border: TableBorder(horizontalInside: BorderSide(
            width: 1.0, color: MyColors.colorPrimary),
          verticalInside: BorderSide.none,
          left: BorderSide(width: 1.0, color: MyColors.colorPrimary),
          right: BorderSide(width: 1.0, color: MyColors.colorPrimary),
          bottom: BorderSide(width: 1.0, color: MyColors.colorPrimary),
          top: BorderSide(width: 1.0, color: MyColors.colorPrimary),
        ),

        children: [
          TableRow(
              children: [
                new Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(AppLocalizations.of(context).translate("name")),
                ),
                new Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(_item.itemName)),
              ]),
          TableRow(
              children: [
                new Padding(padding: EdgeInsets.all(8.0),
                  child: Text(AppLocalizations.of(context).translate("id")),
                ),
                new Padding(padding: EdgeInsets.all(8.0),
                    child: Text(_item.itemId)),
              ]),
          TableRow(
              children: [
                new Padding(padding: EdgeInsets.all(8.0),
                  child: Text(AppLocalizations.of(context).translate("unit")),
                ),
                new Padding(padding: EdgeInsets.all(8.0),
                    child: Text(_item.unit)),
              ]),
          TableRow(
              children: [
                new Padding(padding: EdgeInsets.all(8.0),
                  child: Text(AppLocalizations.of(context).translate("cost_price")),
                ),
                new Padding(padding: EdgeInsets.all(8.0),
                    child: Text(_item.costPrice.toString()=="null"?"":_item.costPrice.toString())),
              ]),
          TableRow(
              children: [
                new Padding(padding: EdgeInsets.all(8.0),
                  child: Text(AppLocalizations.of(context).translate("selling_price")),
                ),
                new Padding(padding: EdgeInsets.all(8.0),
                    child: Text(_item.sellingPrice.toString()=="null"?"":_item.sellingPrice.toString())),
              ]),
          TableRow(
              children: [
                new Padding(padding: EdgeInsets.all(8.0),
                  child: Text(AppLocalizations.of(context).translate("store_num")),
                ),
                new Padding(padding: EdgeInsets.all(8.0),
                    child: Text(storeNum=="null"?"":storeNum),)
              ]),
          TableRow(
              children: [
                new Padding(padding: EdgeInsets.all(8.0),
                  child: Text(AppLocalizations.of(context).translate("store_avl_qty")),
                ),
                new Padding(padding: EdgeInsets.all(8.0),
                    child: Text(_item.avlQty.toString()=="null"?"":_item.avlQty.toString())),
              ]),
        isExp?  TableRow(
              children: [
                new Padding(padding: EdgeInsets.all(8.0),
                  child: Text(AppLocalizations.of(context).translate(
                      "expire_date")),
                ),
               // new Padding(padding: EdgeInsets.all(8.0),child:
                new Padding(padding: EdgeInsets.all(8.0),
                    child: Text(_item.expireDate.toString()=="null"?"":_item.expireDate)),
                    //  createDropDownList()

              ]):TableRow(children: [SizedBox() ,SizedBox()]),
        isBatchNum? TableRow(
              children: [
                new Padding(padding: EdgeInsets.all(8.0),
                  child: Text(AppLocalizations.of(context).translate(
                      "batch_num")),
                ),
                new Padding(padding: EdgeInsets.all(8.0),
                    child: Text(_item.batchNum.toString()=="null"?"":_item.batchNum)),
              //  new Padding(padding: EdgeInsets.all(8.0), child:
               // createDropDownList()
               // ),
              ]):TableRow(children: [SizedBox(),SizedBox()]),
        ]);
  }
   bool isExp    = false ;
  bool isBatchNum  = false  ;
   void addCount(){
    setState(() {
   count  =   int.parse( countEd.text)  +1;
   countEd.text =count.toString() ;
    });
   }
  void subCount(){
    setState(() {
      if(count>0){
      count  =   int.parse( countEd.text)-1;
      countEd.text =count.toString() ;}
    });
  }
  Future <void>getUserData () async{
    SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
    user = User.fromJsonShared(json.decode(sharedPrefs.getString("user") )) ;
    setState(() {
      isExp  =  isView( user.isExpireView)  ;
      isBatchNum  =  isView( user.isBatchView)  ;

    });



  }
  bool isView( int num){
    if(num == 1){ return  true   ;
    }
    return false  ;
  }
  Padding countView(){
    return new Padding(padding: EdgeInsets.all(10) ,
      child:
      new Container(child: new Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
        new Text(AppLocalizations.of(context).translate("count") ),
          new Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              FlatButton(onPressed: addCount, child: new Text("+",
                  style :new TextStyle(fontSize: 50,color: MyColors.colorPrimary))) ,
              new Flexible(child:new Padding(padding: EdgeInsets.only(left: 40 , right: 40 ,),
                child: TextField(
                decoration: new InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.greenAccent, width: 5.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: MyColors.colorPrimary, width: 5.0),
                  ),

                  hintText: count.toString(),

                ),

             controller: countEd,

                ),
              )
              ),
              FlatButton(onPressed: subCount, child: new Text("-",
                  style :new TextStyle(fontSize: 50,color: MyColors.colorPrimary)))


              ////////////////////
            ],)

      ],),),
    ) ;
  }
  saveInvItemAPi(Item item , String functionName){
    List <Item>itemsList  = new List()  ;
    itemsList.add(item)  ;
    api.saveInvPoint(functionName: functionName ,
        userID: user.userId  ,
        items: itemsList,
        inv:  _inv,
        orgId: user.orgId ,
        invID: _inv.invId.toString(),
        onError: (){

        } ,
        onSuccess:(){
       refresh("add_item") ;


        } )  ;


  }
  getItemDetails(){
setState(() {
  api.getItemByUnit(orgId:user.orgId  , userID: user.userId , barCode: _item.itemId , unit: _item.unit , onSuccess:(Item item){
    setState(() {
      _item  = item   ;

    });

  }  , onError:(){

  }
  ) ;
});

  }
}