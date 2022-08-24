import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:inventroy_flutter/Model/InventoryPoint.dart';
import 'package:inventroy_flutter/Model/Item.dart';
import 'package:inventroy_flutter/Screens/productDetails.dart';
import 'package:inventroy_flutter/Tools/FuncTools.dart';
import 'package:inventroy_flutter/app_localizations.dart';
import 'package:inventroy_flutter/my_colors.dart';

class ProductListWindow extends StatefulWidget{
  List<Item>itemList;
  InventoryPoint inv  ;
  ProductListWindow(this.itemList ,this.inv , {Key key}): super(key: key);
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new ProductListState() ;
  }

}
 class  ProductListState extends  State<ProductListWindow> {
   List<Item>_itemList;
   InventoryPoint _inv  ;

   Tools tools  = new Tools()  ;
   @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _itemList  = widget.itemList  ;
    _inv  = widget.inv  ;
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return createDialog();
  }

  Dialog createDialog (){


    Dialog errorDialog = Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)), //this right here
      child: Container(
child: getView(_itemList)

      ),
    );
    //   showDialog(context: context, builder: (BuildContext context) => errorDialog);
    return errorDialog ;

  }
  Widget getView(List<Item>list){
    if(list.length>0){
      return new ListView.builder(
        itemBuilder: (context  , index ){
          return listCard( index) ;
        } ,itemCount:  list.length , ) ;

    }
    else{

      return noThingView();

    }
  }
   Widget noThingView(){
     return new Container(child:
     new Center(
       child:  new Column( children: <Widget>[
         //  Image.asset('images/nothing.png', fit: BoxFit.contain),
         Text (AppLocalizations.of(context).translate("not_found"))
       ], mainAxisAlignment: MainAxisAlignment.center,
         crossAxisAlignment: CrossAxisAlignment.center,),
     ) , height: double.infinity, ) ;
   }
   GestureDetector  listCard  ( int index) {
     Item item  = _itemList[index] ;
     // getBackgroundColor(requestItem ) ;
     return  GestureDetector(
         onTap:(){

             Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => ProductDetails(item , _inv , false)),
          );

           // String name  =  list[index].  name ;
           //  print(name )  ;
         } ,
         child : new Padding(padding: EdgeInsets.only(top: 8.0  , bottom:  8.0  , right: 16.0 , left:  16.0 )  ,
             child :   new Card(

               child:new Container(
                 // color: backgroundReq,
                 //  padding:  new EdgeInsets.all(8.0),
                 child:  new Column(

                   children: <Widget>[
                      new Center(child:
                      new Text(item.itemName)),




                       new Row(
                        // mainAxisAlignment: MainAxisAlignment.spaceBetween,

                         children: <Widget>[
                           Expanded(
                             flex: 1,
                             child: Container(
                               child:
                               new Center(child:
                               Text(AppLocalizations.of(context).translate("id"))
                                 ,),
                               width: MediaQuery.of(context).size.width * 0.33,
                               decoration: BoxDecoration(
                                 border: Border.all(width: 1 ,color: MyColors.colorPrimary),

                               ),
                             ),
                           ),
                           Expanded(
                             flex: 1,
                             child: Container(
                               child:
                               new Center(child:
                               Text(AppLocalizations.of(context).translate("unit"))
                                 ,),
                               width: MediaQuery.of(context).size.width * 0.33,
                               decoration: BoxDecoration(
                                 border: Border.all(width: 1 ,color: MyColors.colorPrimary),

                               ),
                             ),
                           ),
                           Expanded(
                             flex: 1,
                             child: Container(
                               child:
                               new Center(child:
                               Text(AppLocalizations.of(context).translate("barcode"))
                                 ,),
                               width: MediaQuery.of(context).size.width * 0.33,
                               decoration: BoxDecoration(
                                 border: Border.all(width: 1 ,color: MyColors.colorPrimary),

                               ),
                             ),
                           ),
                          // new Align(child: new Text(AppLocalizations.of(context).translate("inventory_point") +inv.invId.toString()) ,alignment: Alignment.centerLeft,),
                         //  new Align(child: new Text(inv.invDate) ,alignment: Alignment.centerRight,),

                         ],

                         mainAxisSize: MainAxisSize.max,) ,


                     new Row(
                       // mainAxisAlignment: MainAxisAlignment.spaceBetween,

                       children: <Widget>[
                         Expanded(
                           flex: 1,
                           child: Container(
                             child:
                             new Center(child:
                             Text(item.itemId)
                               ,),
                             width: MediaQuery.of(context).size.width * 0.33,

                           ),
                         ),
                         Expanded(
                           flex: 1,
                           child: Container(
                             child:
                             new Center(child:
                             Text(item.unit)
                               ,),
                             width: MediaQuery.of(context).size.width * 0.33,

                           ),
                         ),
                         Expanded(
                           flex: 1,
                           child: Container(
                             child:
                             new Center(child:
                             Text(item.barCode== null?"":item.barCode)
                               ,),
                             width: MediaQuery.of(context).size.width * 0.33,

                           ),
                         ),
                         // new Align(child: new Text(AppLocalizations.of(context).translate("inventory_point") +inv.invId.toString()) ,alignment: Alignment.centerLeft,),
                         //  new Align(child: new Text(inv.invDate) ,alignment: Alignment.centerRight,),

                       ],

                       mainAxisSize: MainAxisSize.max,) ,



                   //  new Padding(padding: EdgeInsets.all(16.0)  , child: new Text(inv.invDesc) ,) ,
                   ],),
               ) ,

               color: Theme.of(context).cardColor,
               //RoundedRectangleBorder, BeveledRectangleBorder, StadiumBorder
               shape: RoundedRectangleBorder(
                 borderRadius: BorderRadius.vertical(
                     bottom: Radius.circular(10.0),
                     top: Radius.circular(10.0)),
               ),

             ) ));
   }

 }