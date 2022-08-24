import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:inventroy_flutter/ApiConnection/Api.dart';
import 'package:inventroy_flutter/DataBase/database_helper.dart';
import 'package:inventroy_flutter/Model/Branch.dart';
import 'package:inventroy_flutter/Model/InventoryPoint.dart';
import 'package:inventroy_flutter/Model/PrTyps.dart';
import 'package:inventroy_flutter/Model/Store.dart';
import 'package:inventroy_flutter/Model/User.dart';
import 'package:inventroy_flutter/Model/Vendor.dart';
import 'package:inventroy_flutter/Screens/ProductsList.dart';
import 'package:inventroy_flutter/Tools/FuncTools.dart';
import 'package:inventroy_flutter/app_localizations.dart';
import 'package:inventroy_flutter/my_colors.dart';
import 'package:searchable_dropdown/searchable_dropdown.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dropdown_search/dropdown_search.dart';

class AddNewRequest extends StatefulWidget {
  InventoryPoint myInv  ;
  AddNewRequest(this.myInv ,{Key key}): super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new RequestState()  ;
  }

}
class RequestState  extends State<AddNewRequest> {


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
          loading? new Center(
            child: CircularProgressIndicator(),
          ):SizedBox(),
          createBranchDropDown(),
          createPrDropDown() ,
          createDropDownList(),
          createVendorDropDown() ,
          createCCDropDown()  ,
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
  TextEditingController refEd   = new TextEditingController()  ;
  Vendor selectedValue ;
  PrTypes prSelected ;
  Branch  branch  ;
  Branch  cc  ;
  String prTypeName = "نوع الطلب "  ;
  String branchNameSelect = "الفرع"  ;
  String ccNameSelect = "مركز التكلفه "  ;

  bool loading = true ;

  final List<DropdownMenuItem> items = [];

  final dbHelper = DatabaseHelper.instance;
  String errStr  ;
  Api api  = new Api()   ;
  List<Store> storesList   = new List();
  List<Vendor> vendorList   = new List();
  List<PrTypes> prList   = new List();
  List<Branch> branchList   = new List();
  List<Branch> ccList   = new List();
  User user  ;
  int selectStoreId  =-1 ;
  int selectVendorId  =-1 ;
  Tools tools  = new Tools()  ;
  bool isEdit  =  false  ;
  InventoryPoint myEditReq  ;
  // ignore: unrelated_type_equality_checks
  Vendor findVendor(int id) => vendorList.firstWhere((v) => v.id.toString() == id.toString()) ;
  Store findStore(int id) => storesList.firstWhere((v) => v.storeID.toString() == id.toString()) ;
  Branch findBranch(int id) => branchList.firstWhere((v) => v.id.toString() == id.toString()) ;
  Branch findCC(int id) => ccList.firstWhere((v) => v.id.toString() == id.toString()) ;
  PrTypes findPrType(int id) => prList.firstWhere((v) => v.prType.toString() == id.toString()) ;



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserData() ;
    getStoreList();
    myEditReq  = widget.myInv  ;
    if(myEditReq  != null ) {
      isEdit  = true  ;
      int store_id  = myEditReq.invStore    ;
      selectStoreId = store_id ;
      selectVendorId = int.parse( myEditReq.supplierId);
     // prSelected.prType = myEditReq.prType;
     // findVendor(selectVendorId) ;
      
      
      
      


      print(selectVendorId) ;
      //storesList.indexo

      descEd.text  = myEditReq.invDesc == null ?"" :myEditReq.invDesc  ;
      refEd.text   =   myEditReq.invRef  ==  null  ?  "": myEditReq.invRef;
    }

  }
  void onSelectStore(Store branch){
    setState(() {
      selectStoreId  = branch.storeID  ;
      selectStore    =   branch.storeName  ;
    });
  }void onSelectPrType(PrTypes type){
    setState(() {
      prSelected = type  ;
      prTypeName = type.name  ;

    });
  }
  void onSelectCC(Branch cc){
    setState(() {
     this. cc = cc  ;
      ccNameSelect = cc.name  ;

    });
  }void onSelectBranch(Branch branch){
    setState(() {
      this.branch = branch  ;
      branchNameSelect = branch.name  ;

    });
  }
  void getVendor(){
    api.getVendor(user.orgId, user.userId, (List<Vendor> list ){
      setState(() {
        vendorList  = list  ;
        print(vendorList);

        if(isEdit){
      selectedValue  =    findVendor(int.parse(myEditReq.supplierId));
      selectVendorId =  int.parse(selectedValue .id) ;
       print(selectedValue) ;

        }
        loading  = false ;

      });

    }, (){

    })  ;
  }
  void getPrType(){
    api.getPrType(user.orgId, user.userId, (List<PrTypes>list ,
        List<Branch>branchList  , List<Branch>ccList ){
      setState(() {
      });
prList = list;
this.branchList = branchList;
this.ccList = ccList;
 if(isEdit){
prSelected = findPrType(myEditReq.prType) ;
prTypeName = prSelected.name ;
branch = findBranch(myEditReq.branchID) ;
 branchNameSelect  = branch.name;
cc = findCC(myEditReq.CST_CNT_ID) ;
ccNameSelect = cc.name ;
 }
    }, (){

    })  ;
  }

  Padding createPrDropDown(){

    return new Padding(padding:new EdgeInsets.only(bottom: 8.0 , left: 40.0  , right: 40.0 , top: 8.0) ,child:
    new DropdownButton<PrTypes>(

      isExpanded: true,
      items: prList.map((PrTypes value) {
        return new DropdownMenuItem<PrTypes>(
          value: value,
          child: new Text(value.name),
        );
      }).toList(),

      onChanged: onSelectPrType,
      hint:   new Text(
          prTypeName),
      iconEnabledColor: MyColors.colorPrimary,
    )) ;

  }
  Padding createBranchDropDown(){

    return new Padding(padding:new EdgeInsets.only(bottom: 8.0 , left: 40.0  , right: 40.0 , top: 8.0) ,child:
    new DropdownButton<Branch>(

      isExpanded: true,
      items: branchList.map((Branch value) {
        return new DropdownMenuItem<Branch>(
          value: value,
          child: new Text(value.name),
        );
      }).toList(),

      onChanged: onSelectBranch,
      hint:   new Text(
          branchNameSelect),
      iconEnabledColor: MyColors.colorPrimary,
    )) ;

  }
  Padding createCCDropDown(){

    return new Padding(padding:new EdgeInsets.only(bottom: 8.0 , left: 40.0  , right: 40.0 , top: 8.0) ,child:
    new DropdownButton<Branch>(

      isExpanded: true,
      items: ccList.map((Branch value) {
        return new DropdownMenuItem<Branch>(
          value: value,
          child: new Text(value.name),
        );
      }).toList(),

      onChanged: onSelectCC,
      hint:   new Text(
          ccNameSelect),
      iconEnabledColor: MyColors.colorPrimary,
    )) ;

  }
  Padding createVendorDropDown(){
    return new Padding(padding:new EdgeInsets.only(bottom: 8.0 , left: 30.0  , right: 30.0 , top: 8.0) ,child:
           SearchableDropdown(
      items: vendorList.map((item) {
        return new DropdownMenuItem<Vendor>(
            child: Text(item.name), value: item);
      }).toList(),
      isExpanded: true,
      value: selectedValue,
      isCaseSensitiveSearch: true,
      searchHint: new Text(
        "select",
        style: new TextStyle(fontSize: 20 ,),
      ),
      hint:new Text(
        "اسم المورد"
      ),
             iconEnabledColor: MyColors.colorPrimary,
             onChanged: (value) {
        setState(() {
          selectedValue = value;
          print(selectedValue);
        });
      },
    ) ) ;

}
  bool validation (){
     if(branch==null) {
    errStr  = AppLocalizations.of(context).translate("select_br");

    return false  ;
    }
     else if(prSelected==null) {
       errStr  = AppLocalizations.of(context).translate("select_pr_type");

       return false  ;
     }
    if(selectStoreId == -1) {
      errStr  = AppLocalizations.of(context).translate("select_store");

      return false  ;

    }
    else if(selectedValue==null) {
      errStr  = AppLocalizations.of(context).translate("select_vendor");

      return false  ;
    }
    else{
      return true ;

    }

  }
  Padding createDropDownList(){
    // selectBranch =  "test2" ;
    return
      new Padding(padding:new EdgeInsets.only(bottom: 8.0 , left: 40.0  , right: 40.0 , top: 8.0) ,child:
      new DropdownButton<Store>(

        isExpanded: true,
        items: storesList.map((Store value) {
          return new DropdownMenuItem<Store>(
            value: value,
            child: new Text(value.storeName),
          );
        }).toList(),

        onChanged: onSelectStore,
        hint:   new Text(
            selectStore),
        iconEnabledColor: MyColors.colorPrimary,
      )) ;
  }

  Future <void>getStoreList () async{
    SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
    user = User.fromJsonShared(json.decode(sharedPrefs.getString("user") )) ;
    api.getStores(userID: user.userId  , orgId:  user.orgId  , onError:
    (){
    }
        , onSuccess: (List<Store>list){
      setState(() {
        storesList  = list  ;
        if(isEdit) {
     Store     store = findStore(myEditReq.invStore)  ;
      selectStore   = store.storeName  ;
      selectStoreId = store.storeID  ;
        }
      });

    })  ;
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
              errorText: "",
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
              errorText: "",
            ) ,) );
  }
  void onSaveClick() {
    setState(() {


      if(validation()){
        addNewRequest()  ;
        //  add rquest
      }
      else{
       tools. dialogMsg(errStr ,  AppLocalizations.of(context).translate("error") , context,false)  ;
      }

    });
  }

  addNewRequest() async {
    var now = new DateTime.now();
    var formatter = new DateFormat("MMM,d,yyyy","en");
    String formattedDate = formatter.format(now);
    print( formattedDate)  ;
    InventoryPoint inv  = new InventoryPoint.request(invStore:selectStoreId ,invRef:refEd.text ,
        invDone: 2, invDesc:descEd.text ,
      invDate: formattedDate  ,supplierId: selectedValue.id ,supplierName: selectedValue.name
    );
    inv.prType = prSelected .prType;
    inv.branchID  = branch.id ;
    if(cc!=null){
    inv.CST_CNT_ID = cc.id ;
    }
    if (isEdit){
      final  id = await dbHelper.updateReqData(inv.requestDB(), myEditReq.invId);
      print(id) ;
      inv.invId = id ;
      confirmDialog(inv) ;
    }
    else {
      final id = await dbHelper.insert(
          inv.requestDB(), DatabaseHelper.REQTable);
      print(id);
      inv.invId = id;
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => ProductsList(inv)));
    }
    // done
    // finish
    //


  }
  Future <void>getUserData () async{
    SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
    user = User.fromJsonShared(json.decode(sharedPrefs.getString("user") )) ;
    getPrType() ;
    getVendor()  ;

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

}
