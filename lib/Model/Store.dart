class Store  {
  int storeID ;
  String avlQty ;
  String costPrice;
  String storeName ;

  Store({this.storeID, this.storeName});


  Store.con2(this.storeID, this.avlQty, this.costPrice);
  factory Store.fromJson(Map<String  ,dynamic> json){
    return  Store(storeID: json["WH_CODE"] , storeName: json["W_NAME"])   ;
  }

}