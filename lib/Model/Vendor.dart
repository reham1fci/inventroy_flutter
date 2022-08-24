class Vendor {
  String name ;
  String id  ;

  Vendor({this.name, this.id});
  factory Vendor.fromJson(Map<String  ,dynamic> json){
    return  Vendor(name: json["V_L_NAME"] , id: json["VNDR_ID"])   ;
  }

  @override
  String toString() {
    return 'Vendor{name: $name, id: $id}';
  }


}