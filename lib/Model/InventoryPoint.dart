import 'package:inventroy_flutter/DataBase/database_helper.dart';

class InventoryPoint {
  int invId ;
  String invDesc ;
  String invDate ;
  String invRef  ;
  int invDone   ;
  int invStore ;
  int prType  ;
  String supplierName ;
  int CST_CNT_ID ;
  int branchID ;
  String supplierId ;

  InventoryPoint({this.invId, this.invDesc, this.invDate, this.invRef,
      this.invDone , this.invStore ,this.prType});

  InventoryPoint.request({this.invId, this.invDesc, this.invDate, this.invRef,
    this.invDone , this.invStore , this.supplierName , this.supplierId , this.prType ,
    this.CST_CNT_ID , this.branchID});

  factory InventoryPoint.fromJson (Map<String  ,dynamic> json  ,
      int isDone){
    return  InventoryPoint(invDate: json["INV_DATE"] ,
        invDesc: json["INV_DESC"] , invDone:isDone ,
        invId:   json["INV_NO"] , invRef:json["REF_NO"] ) ;

  }
  factory InventoryPoint.fromSql (Map<String  ,dynamic> json ){
    return  InventoryPoint(
        invDate: json[    DatabaseHelper.inv_date_column] ,
        invDesc: json[  DatabaseHelper.inv_desc_column] ,
        invDone:json[DatabaseHelper.done_column]  ,
        invId:   json[DatabaseHelper.inv_id_column] ,
        invStore: json[DatabaseHelper.inv_store_num_column],
        invRef:json[DatabaseHelper.inv_ref_num_column] ) ;

  }
  factory InventoryPoint.fromSqlReq (Map<String  ,dynamic> json ){
    return  InventoryPoint.request(
        invDate: json[ DatabaseHelper.REQ_PR_Date] ,
        invDesc: json[  DatabaseHelper.REQ_PR_DESC] ,
        invDone:json[DatabaseHelper.REQ_DONE]  ,
        invId:   json[DatabaseHelper.REQ_REQ_ID] ,
        invStore: json[DatabaseHelper.REQ_WH_CODE],
        invRef:json[DatabaseHelper.REQ_REF_NO] ,
        prType:json[DatabaseHelper.PR_TYPE] ,
        supplierId:json[DatabaseHelper.REQ_VNDR_ID] ,
        branchID: json[DatabaseHelper.BR_ID] ,
        supplierName: json[DatabaseHelper.REQ_V_Name] ,
        CST_CNT_ID:json[DatabaseHelper.CST_CNT_ID] ,



    ) ;

  }
Map<String, dynamic> DB() {
  return {
    DatabaseHelper.inv_ref_num_column: this.invRef ,
    DatabaseHelper.inv_store_num_column: this.invStore ,
    DatabaseHelper.inv_date_column: this.invDate ,
    DatabaseHelper.inv_desc_column: this.invDesc ,
    DatabaseHelper.done_column: this.invDone

  };


  }

  Map<String, dynamic> requestDB() {
  return {
    DatabaseHelper.REQ_REF_NO: this.invRef ,
    DatabaseHelper.REQ_WH_CODE: this.invStore ,
    DatabaseHelper.REQ_PR_Date: this.invDate ,
    DatabaseHelper.REQ_PR_DESC: this.invDesc ,
    DatabaseHelper.REQ_DONE: this.invDone ,
    DatabaseHelper.REQ_VNDR_ID: this.supplierId ,
    DatabaseHelper.REQ_V_Name: this.supplierName ,
    DatabaseHelper.PR_TYPE: this.prType ,
    DatabaseHelper.BR_ID: this.branchID ,
    DatabaseHelper.CST_CNT_ID: this.CST_CNT_ID


  };


  }

  Map<String, dynamic> toJson(String invID) {
    return {
      "INV_NO": invID,
      "INV_Date": this.invDate ,
      "REF_NO": this.invRef ,
      "INV_DESC": this.invDesc ,
    };

  }
  Map<String, dynamic> reqToJson() {
    return {
      "PR_TYPE": this.prType,
      "WH_CODE": this.invStore ,
      "V_Name": this.supplierName ,
      "VNDR_ID": this.supplierId ,
      "CST_CNT_ID": this.CST_CNT_ID ,
      "BR_ID": this.branchID ,
      "REF_NO": this.invRef ,
      "PR_DESC": this.invDesc ,
      "PR_Date": this.invDate ,

    };

  }
  Map<String, dynamic> toJsonInv(int invNum) {
    return {
      "INV_NO": invNum,
    };

  }


}