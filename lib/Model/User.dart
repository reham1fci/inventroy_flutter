class User {
  String userId  ;
  String userName  ;
  String orgId  ;
  String userPassword  ;
   int isExpireView  ;
   int isBatchView  ;
   int isDescriptionView  ;
   bool isSellingPriceView  ;
   bool isCostPriceView  ;

  User({this.userId, this.userName, this.orgId, this.userPassword,
      this.isExpireView, this.isBatchView  , this.isDescriptionView , this.isCostPriceView , this.isSellingPriceView});

  factory User.fromJson (Map<String  ,dynamic> json , String userID , String password ,  String orgID){
      return User(userName:json['User_Name'] ,
        isBatchView:json['USE_BTCH_ITM'] ,
        isExpireView:json['USE_EXPR_ITM']  ,
        isDescriptionView:json['VW_IC_DESCPT']  ,
        orgId:orgID ,
        userPassword: password  ,
        userId:   userID,


      );
  }factory User.fromJsonShared (Map<String  ,dynamic> json ){
      return User(
          userName:json['userName'] ,
        isBatchView:json['isBatchView'] ,
        isExpireView:json['isExpireView']  ,
        orgId:json['orgId'] ,
        userPassword: json['userPassword']  ,
        userId:   json['userId'],
        isCostPriceView:  json['isCostPriceView'] ,
        isDescriptionView: json['isDescriptionView'] ,
          isSellingPriceView: json['isSellingPriceView']

      );
  }
  Map<String, dynamic> toJson( ) {
    return {
      "userId": this.userId,
      "userName": this.userName ,
      "orgId": this.orgId ,
      "isBatchView": this.isBatchView ,
      "isExpireView": this.isExpireView ,
      "userPassword": this.userPassword ,
      "isDescriptionView":this.isDescriptionView ,
      "isSellingPriceView":this.isSellingPriceView,
      "isCostPriceView":this.isCostPriceView ,
    };
  }

  User.login( this.userId, this.userPassword , this.orgId);
  Map toMap( String mobile) {
    var map = new Map<String, dynamic>();
    map["Org_id"]  = orgId ;
    map["user_id"] = userId ;
    map["password"]  = userPassword;
    map["Device_Name"]  = mobile ;
    return map;
  }

  @override
  String toString() {
    return 'User{userId: $userId, userName: $userName, orgId: $orgId, userPassword: $userPassword, isExpireView: $isExpireView, isBatchView: $isBatchView}';
  }


}