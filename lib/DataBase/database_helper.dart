import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {

  static final _databaseName = "MyDatabase.db";
  static final _databaseVersion = 1;

   static final allItemTable = 'all_items';
   static final  item_id= "item_id" ;
   static final  item_store_num= "store_num" ;
   static final  item_barcode= "barcode" ;
   static final  item_name= "item_name" ;
   static final  item_size= "item_size" ;
   static final  item_unit= "item_unit" ;
   static final  EXPIRE_DATE = "expire_date" ;
   static final  BACH_NUM = "batch_num" ;
   static final  inv_table_name= "inventory" ;
   static final  inv_id_column= "inv_id" ;
   static final  inv_date_column= "inv_date" ;
   static final  inv_store_num_column= "store_num" ;
   static final  inv_desc_column= "inv_desc" ;
   static final  inv_ref_num_column= "ref_num" ;
   static final  done_column= "done" ;
   static final String invItemsTable= "inv_items" ;
   static final String item_record_id= "record_id" ;
   static final String invItemId= "invItemId" ;
   static final String invItem_storeNum= "invItem_storeNum" ;
   static final String invItem_barcode= "invItem_barcode" ;
   static final String invItem_name= "invItem_name" ;
   static final String invItem_size= "invItem_size" ;
   static final String invItem_unit= "invItem_unit" ;
   static final String invItem_desc= "invItem_desc" ;
   static final String invItem_count= "count" ;
   static final String invStoreAvlQty= "store_avl_qty" ;
   static final String foreignInvID= "inv_id_item" ;
  static final  invItem_expireDate = "invItem_expireDate" ;
  static final  invItem_batchNum = "invItem_batchNum" ;
  static final  invItem_sellingPrice = "selling_price" ;
  static final  invItem_costPrice = "cost_price" ;
  static final  REQTable = "requests" ;
  static final  REQ_REQ_ID = "REQ_ID" ;
  static final  REQ_WH_CODE = "REQ_WH_CODE" ;
  static final  ITEM_WH_CODE = "WH_CODE" ;
  static final  REQ_V_Name = "V_Name" ;
  static final  REQ_VNDR_ID = "VNDR_ID" ;
  static final  REQ_REF_NO = "REF_NO" ;
  static final  REQ_PR_DESC = "PR_DESC" ;
  static final  REQ_PR_Date = "PR_Date" ;
  static final  REQ_DONE = "DONE" ;
  static final  REQ_ITEM_ID = "ITEM_ID" ;
  static final  REQ_UNIT = "UNIT" ;
  static final  REQ_UNIT_SIZE = "UNIT_SIZE" ;
  static final  REQ_ITM_QUANTY = "ITM_QUANTY" ;
  static final  REQ_ITM_COST = "ITM_COST" ;
  static final  REQ_ITM_DESCRPT = "ITM_DESCRPT" ;
  static final  REQ_EXP_DATE = "EXP_DATE" ;
  static final  REQ_BATCH_ID = "BATCH_ID" ;
  static final  REQ_ITEM_TB = "reqItems" ;
  static final  REQ_ITEM_NAME = "ITEM_NAME" ;
  static final  REQ_ITEM_RERDNO = "RERD_NO" ;
  static final  REQ_INV_REQ_ID = "INV_REQ_ID" ;
  static final  PR_TYPE = "PR_TYPE" ;
  static final  CST_CNT_ID = "CST_CNT_ID" ;
  static final  BR_ID = "BR_ID" ;

   static final String Edit= "edit" ;
   static final String URl= "url" ;
  // make this a singleton class
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();


  // only have a single app-wide reference to the database
  static Database _database;
  Future<Database> get database async {
    if (_database != null) return _database;
    // lazily instantiate the db the first time it is accessed
    _database = await _initDatabase();
    return _database;
  }

  // this opens the database (and creates it if it doesn't exist)
  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(path,
        version: _databaseVersion,
        onCreate: _onCreate);
  }

  // SQL code to create the database table
  Future _onCreate(Database db, int version) async {
    await db.execute(
         "CREATE TABLE $allItemTable (\n" +
                "  $item_id        varchar(200) NOT NULL , \n" +
                "  $item_name       varchar(255), \n" +
                "  $item_barcode        varchar(200), \n" +
                "  $EXPIRE_DATE     varchar(200), \n" +
                "  $BACH_NUM      varchar(200), \n" +
                "  $item_unit     varchar(200) NOT NULL, \n" +
                "  $item_size      varchar(200));");
    String create_inv ="CREATE TABLE $inv_table_name (\n" +
        "  $inv_id_column     INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, \n" +
        "  $inv_desc_column  varchar(255), \n" +
        "  $inv_date_column  varchar(200) NOT NULL, \n" +
        "  $inv_store_num_column integer(200) NOT NULL, \n" +
        "  $inv_ref_num_column   varchar(200), \n" +
        "  $done_column      integer(10) NOT NULL);" ;

    await db.execute(create_inv);
    String create_items = "CREATE TABLE $invItemsTable (\n" +
        "  $item_record_id               INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, \n" +
        "  $invItemId                 varchar(200) NOT NULL, \n" +
        "  $invItem_barcode                 varchar(200) , \n" +
        "  $invItem_name               varchar(200) NOT NULL, \n" +
        "  $invItem_size               varchar(100), \n" +
        "  $invItem_unit               varchar(200), \n" +
        "  $invItem_desc               varchar(200), \n" +
        "  $invItem_storeNum               varchar(100) NOT NULL, \n" +
        "  $invItem_count                  integer(200) DEFAULT 0 NOT NULL, \n" +
        "  $invItem_sellingPrice           varchar(200), \n" +
        "  $invItem_costPrice              varchar(255), \n" +
        "  $invItem_expireDate             varchar(200), \n" +
        "  $invItem_batchNum               varchar(200), \n" +
        "  $invStoreAvlQty             varchar(200), \n" +
        "  $foreignInvID        integer(200) NOT NULL, \n" +
        "  FOREIGN KEY($foreignInvID) REFERENCES $inv_table_name($inv_id_column));" ;
    await db.execute(create_items);
    String createPurchaseReq    =   "CREATE TABLE $REQTable (\n" +
        "  $REQ_REQ_ID        INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, \n" +
        "  $REQ_WH_CODE      integer(200) NOT NULL, \n" +
        "  $REQ_V_Name        varchar(255) NOT NULL, \n" +
        "  $REQ_VNDR_ID       varchar(200) NOT NULL, \n" +
        "  $REQ_REF_NO       varchar(200), \n" +
        "  $REQ_PR_DESC       varchar(200), \n" +
        "  $REQ_DONE          integer(10) NOT NULL,\n" +
        "  $PR_TYPE          integer(10) NOT NULL,\n" +
        "  $CST_CNT_ID          integer(10),\n" +
        "  $BR_ID          integer(10) NOT NULL,\n" +
        "  $REQ_PR_Date       varchar(200));" ;
    await db.execute(createPurchaseReq);

    String create_items_req = "CREATE TABLE $REQ_ITEM_TB (\n" +
        "  $REQ_ITEM_RERDNO           INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, \n" +
        "  $REQ_ITEM_ID               varchar(200) NOT NULL, \n" +
        "  $REQ_ITEM_NAME             varchar(200) NOT NULL, \n" +
        "  $REQ_UNIT                  varchar(200) NOT NULL, \n" +
        "  $REQ_UNIT_SIZE             varchar(200), \n" +
        "  $ITEM_WH_CODE             varchar(100) NOT NULL, \n" +
        "  $REQ_ITM_QUANTY            integer(200) DEFAULT 0 NOT NULL,\n"+
        "  $REQ_ITM_COST              varchar(200), \n" +
        "  $REQ_ITM_DESCRPT           varchar(100), \n" +
        "  $REQ_EXP_DATE              varchar(200), \n" +
        "  $REQ_BATCH_ID             varchar(200), \n" +
        "  $REQ_INV_REQ_ID            integer(200) NOT NULL, \n" +
        "  FOREIGN KEY($REQ_INV_REQ_ID) REFERENCES $REQTable($REQ_REQ_ID));" ;
    await db.execute(create_items_req);




  }

  // Helper methods

  // Inserts a row in the database where each key in the Map is a column name
  // and the value is the column value. The return value is the id of the
  // inserted row.
  Future<int> insert(Map<String, dynamic> row ,String tableName) async {
    Database db = await instance.database;
    return await db.insert(tableName, row);
  }

  // All of the rows are returned as a list of maps, where each map is
  // a key-value list of columns.
  Future<List<Map<String, dynamic>>> queryAllRows(String tableName) async {
    Database db = await instance.database;
    return await db.query(tableName);
  }

  // All of the methods (insert, query, update, delete) can also be done using
  // raw SQL commands. This method uses a raw query to give the row count.
  Future<int> queryRowCount( String tableName) async {
    Database db = await instance.database;
    return Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM $tableName'));
  }

  // We are assuming here that the id column in the map is set. The other
  // column values will be used to update the row.

  Future<int> update(Map<String, dynamic> row  ,int id ) async {
    Database db = await instance.database;
    return await db.update(invItemsTable, row, where: '$item_record_id = ?', whereArgs: [id]);
  }
  Future<int> updateInv(Map<String, dynamic> row  ,int id ) async {
    Database db = await instance.database;
    return await db.update(inv_table_name, row, where: '$inv_id_column = ?', whereArgs: [id]);
  } Future<int> updateReqData(Map<String, dynamic> row  ,int id ) async {
    Database db = await instance.database;
    return await db.update(REQTable, row, where: '$REQ_REQ_ID = ?', whereArgs: [id]);
  }
  Future<int> updateReq(Map<String, dynamic> row  ,int id ) async {
    Database db = await instance.database;
    return await db.update(REQ_ITEM_TB, row, where: '$REQ_ITEM_RERDNO = ?', whereArgs: [id]);
  }
  // Deletes the row specified by the id. The number of affected rows is
  // returned. This should be 1 as long as the row exists.
  Future<int> delete({int id ,String columnIdName  , String table}) async {
    Database db = await instance.database;
    return await db.delete(table, where: '$columnIdName = ?', whereArgs: [id]);
  } Future<int> deleteTb({ String table}) async {
    Database db = await instance.database;
    return await db.delete(table);
  }
  Future<List<Map<String, dynamic>>> getItemsById(String BarCodeID ) async {
    Database db = await instance.database;
    print('database$BarCodeID') ;
   // return await db.rawQuery('select * from all_items where item_id=? or barcode=? or  item_name like ? GROUP BY item_unit , expire_date , batch_num',
      //  [BarCodeID, BarCodeID ,"%"+BarCodeID+"%"] );
    return await   db.query("all_items" , where: '"item_id" =? or "barcode" = ? or  "item_name" like ?' ,
      whereArgs:[BarCodeID, BarCodeID ,"%"+BarCodeID+"%"] ,  );

  }
  Future<List<Map<String, dynamic>>> getItemsByBarcode(String BarCodeID ) async {
    Database db = await instance.database;
   // return await db.rawQuery('select * from all_items where item_id=? or barcode=? or  item_name like ? GROUP BY item_unit , expire_date , batch_num',
      //  [BarCodeID, BarCodeID ,"%"+BarCodeID+"%"] );
      return await db.rawQuery('select * from $allItemTable where  $item_barcode =? ' ,
          [BarCodeID] );
    //return await   db.query("all_items" , where:  '"barcode" = ?' ,whereArgs:[BarCodeID] );

  }
  Future<List<Map<String, dynamic>>> getItemsByInvId(String invId ) async {
    Database db = await instance.database;
    return await db.rawQuery('select * from $invItemsTable where $foreignInvID  = ? ' ,
        [invId] );
  }
  Future<List<Map<String, dynamic>>> getItemsByReqId(String invId ) async {
    Database db = await instance.database;
    return await db.rawQuery('select * from $REQ_ITEM_TB where $REQ_INV_REQ_ID  = ? ' ,
        [invId] );
  }
}