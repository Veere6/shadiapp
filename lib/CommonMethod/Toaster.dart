import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
class Toaster{
   static show(BuildContext context,String value){
      Fluttertoast.showToast(
          msg: "${value}",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          // timeInSecForIosWeb: 1,
          // backgroundColor: Colors.red,
          // textColor: Colors.white,
          // fontSize: 16.0
      );
   }
}