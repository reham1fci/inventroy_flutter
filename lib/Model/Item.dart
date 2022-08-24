 import 'package:inventroy_flutter/DataBase/database_helper.dart';

class Item  {
   String itemId ;
   String barCode ;
   String itemName ;
   double itemSize ;
   String unit ;
   String itemDesc ;
   String storeCode ; //WH_CODE
   String avlQty ; //AVL_QTY
   int    itemQty ;//ITM_QTY
   double sellingPrice ;//ITM_PRICE
   double costPrice ;//STK_NEW
   String batchNum ;
   String expireDate ;
   int   recordID ;

   Item({this.itemId, this.barCode, this.itemName, this.itemSize, this.unit,
       this.itemDesc, this.storeCode, this.avlQty, this.itemQty,
       this.sellingPrice, this.costPrice, this.batchNum, this.expireDate,
       this.recordID});

   factory Item.fromJson(Map<String  ,dynamic> json){
     return  Item(
         itemId: json["ITEM_ID"] ,
         barCode : json["BARCODE"]  ,
         itemName:  json["I_NAME"] ,
         itemSize:json["I_SIZE"] ,
         unit: json["UNIT"] ,
         itemDesc:json["I_DESC"]  ,
         batchNum: json["BATCH_ID"],
         expireDate: json["EXP_DATE"],
         costPrice: json["ITM_STK_NEW"]  )   ;

   }
   factory Item.fromSql(Map<String  ,dynamic> json){
      return  Item(
          itemId: json[DatabaseHelper.item_id] ,
          barCode : json[DatabaseHelper.item_barcode]  ,
          itemName:  json[DatabaseHelper.item_name] ,
          itemSize:double.parse(json[DatabaseHelper.item_size]) ,
          unit: json[DatabaseHelper.item_unit] ,
          expireDate:json[DatabaseHelper.EXPIRE_DATE]  ,
          batchNum: json[DatabaseHelper.BACH_NUM]  )   ;

   }
   factory Item.invItemFromSql(Map<String  ,dynamic> json){
     return  Item(
         itemId: json[   DatabaseHelper.invItemId] ,
         recordID: json[   DatabaseHelper.item_record_id] ,
         barCode : json[DatabaseHelper.invItem_barcode]  ,
         itemName:  json[  DatabaseHelper.invItem_name] ,
         itemSize:double.parse(json[ DatabaseHelper.invItem_size]) ,
         unit: json[ DatabaseHelper.invItem_unit] ,
         expireDate:json[ DatabaseHelper.invItem_expireDate]  ,
         batchNum: json[     DatabaseHelper.invItem_batchNum]   ,
         itemQty:    json[  DatabaseHelper.invItem_count] ,
     storeCode: json[  DatabaseHelper.invItem_storeNum] )   ;

   }

   Map<String, dynamic> allItemsDB() {
      return {
         DatabaseHelper.item_id: this.itemId,
         DatabaseHelper.item_name: this.itemName ,
         DatabaseHelper.item_unit: this.unit ,
         DatabaseHelper.item_size: this.itemSize ,
         DatabaseHelper.item_barcode: this.barCode ,
         DatabaseHelper.EXPIRE_DATE: this.expireDate ,
         DatabaseHelper.BACH_NUM: this.batchNum ,
      };

   }Map<String, dynamic> toJson(int recordNum) {
      return {
        "RCRD_NO" : recordNum.toString(),
         "INV_NO": "",
         "ITEM_ID": this.itemId ,
        "UNIT": this.unit ,
        "UNIT_SIZE": this.itemSize.toString() ,
         "WH_CODE": this.storeCode ,
         "AVL_QTY": 0.toString(),
         "ITM_QTY": this.itemQty.toString() ,
      };

   }Map<String, dynamic> reqToJson(int recordNum) {
      return {
        "RCRD_NO" : recordNum.toString(),
        "ITEM_ID": this.itemId ,
        "UNIT": this.unit ,
        "UNIT_SIZE": this.itemSize.toString() ,
         "WH_CODE": this.storeCode ,
         "ITM_QUANTY": this.itemQty.toString() ,
         "ITM_COST": this.costPrice ,
         "ITM_DESCRPT": this.itemDesc ,
         "BATCH_ID": this.batchNum ,
         "EXP_DATE": this.expireDate ,
      };

   }
   Map<String, dynamic> deleteToJson(int invId) {
     return {
       "RCRD_NO" : this.recordID,
       "INV_NO": invId.toString(),
     };

   }

   Map<String, dynamic> invItemDB(int foreignInvId) {
     return {
       DatabaseHelper.invItemId: this.itemId,
       DatabaseHelper.invItem_name: this.itemName ,
       DatabaseHelper.invItem_unit: this.unit ,
       DatabaseHelper.invItem_size: this.itemSize ,
       DatabaseHelper.invItem_barcode: this.barCode ,
       DatabaseHelper.invItem_expireDate: this.expireDate ,
       DatabaseHelper.invItem_batchNum: this.batchNum ,
       DatabaseHelper.invItem_sellingPrice: this.sellingPrice ,
       DatabaseHelper.invItem_costPrice: this.costPrice ,
       DatabaseHelper.invStoreAvlQty: this.avlQty ,
       DatabaseHelper.invItem_count: this.itemQty ,
       DatabaseHelper.invItem_desc: this.itemDesc ,
       DatabaseHelper.foreignInvID: foreignInvId ,
       DatabaseHelper.invItem_storeNum: storeCode ,

     };

   }

   Map<String, dynamic> reqItemDB(int foreignInvId) {
     return {
       DatabaseHelper.REQ_ITEM_ID: this.itemId,
       DatabaseHelper.REQ_ITEM_NAME: this.itemName ,
       DatabaseHelper.REQ_UNIT: this.unit ,
       DatabaseHelper.REQ_UNIT_SIZE: this.itemSize ,
       DatabaseHelper.REQ_EXP_DATE: this.expireDate ,
       DatabaseHelper.REQ_BATCH_ID: this.batchNum ,
       DatabaseHelper.REQ_ITM_COST: this.costPrice ,
       DatabaseHelper.REQ_ITM_QUANTY: this.itemQty ,
       DatabaseHelper.REQ_ITM_DESCRPT: this.itemDesc ,
       DatabaseHelper.REQ_INV_REQ_ID: foreignInvId ,
       DatabaseHelper.ITEM_WH_CODE: storeCode ,

     };

   }
   factory Item.reqItemFromSql(Map<String  ,dynamic> json){
     return  Item(
         itemId: json[      DatabaseHelper.REQ_ITEM_ID] ,
         recordID: json[   DatabaseHelper.REQ_ITEM_RERDNO] ,
         itemName:  json[  DatabaseHelper.REQ_ITEM_NAME] ,
         itemSize:double.parse(json[ DatabaseHelper.REQ_UNIT_SIZE]) ,
         unit: json[ DatabaseHelper.REQ_UNIT] ,
         expireDate:json[ DatabaseHelper.REQ_EXP_DATE]  ,
         batchNum: json[     DatabaseHelper.REQ_BATCH_ID]   ,
         itemQty:    json[  DatabaseHelper.REQ_ITM_QUANTY] ,
         storeCode: json[  DatabaseHelper.ITEM_WH_CODE] )   ;

   }
   factory Item.fromJson2(Map<String  ,dynamic> json){
      return  Item(
          itemId: json["ITEM_ID"] ,
          barCode : json["BARCODE"]  ,
          itemName:  json["I_NAME"] ,
          itemSize:json["I_SIZE"] ,
          unit: json["UNIT"] ,
          itemDesc:json["I_DESC"]  ,
          costPrice: json["STK_NEW"]  ,
          avlQty: json["AVL_QTY"].toString()  ,
          sellingPrice:  json["ITM_PRICE"]
          , storeCode:  json["WH_CODE"] .toString() )   ;
   } factory Item.fromJsonByInv(Map<String  ,dynamic> json){
      return  Item(
          itemId: json["ITEM_ID"] ,
          recordID: json["RCRD_NO"] ,
          unit: json["UNIT"] ,
          barCode : json["BARCODE"]  ,
          itemName:  json["I_NAME"] ,
          storeCode:  json["WH_CODE"].toString()   ,
           itemSize:json["P_SIZE"] ,
          itemDesc:json["ITM_DESCRPT"]  ,
          avlQty: json["AVL_QTY"].toString()  ,
          itemQty : json["ITM_QUANTY"].toInt());
   }

   @override
   String toString() {
     return 'Item{itemId: $itemId, barCode: $barCode, itemName: $itemName, itemSize: $itemSize, unit: $unit, itemDesc: $itemDesc, storeCode: $storeCode, avlQty: $avlQty, itemQty: $itemQty, sellingPrice: $sellingPrice, costPrice: $costPrice, batchNum: $batchNum, expireDate: $expireDate, recordID: $recordID}';
   }

}
