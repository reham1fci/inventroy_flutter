class Branch{

  String name   ;
   int id  ;

  Branch({this.name, this.id});
  factory Branch.fromJson(Map<String  ,dynamic> json){
    return  Branch(name: json["BR_L_NAME"] , id: json["BR_ID"])   ;
  }


  factory Branch.centerJson(Map<String  ,dynamic> json){
    return  Branch(name: json["CC_L_NAME"] , id: int.parse (json["CST_CNT_ID"]))   ;
  }

}