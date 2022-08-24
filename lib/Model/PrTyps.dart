class PrTypes {
  int prType  ;
  String name  ;

  PrTypes({this.prType, this.name});
  factory PrTypes.fromJson(Map<String  ,dynamic> json){
    return  PrTypes(name: json["PR_L_NAME"] , prType: json["PR_TYPE"])   ;
  }

}