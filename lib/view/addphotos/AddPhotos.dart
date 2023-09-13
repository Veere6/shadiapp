import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shadiapp/CommonMethod/CommonColors.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shadiapp/CommonMethod/Toaster.dart';
import 'package:shadiapp/Models/delete_image_model.dart';
import 'package:shadiapp/Models/upload_image_model.dart';
import 'package:shadiapp/Models/view_image_model.dart';
import 'package:shadiapp/Services/Services.dart';
import 'package:shadiapp/ShadiApp.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:collection/collection.dart';


class AddPhotos extends StatefulWidget {
  @override
  State<AddPhotos> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<AddPhotos> {

  bool ActiveConnection = false;
  String T = "";
  SharedPreferences? _preferences;
  late UploadImageModel _uploadImageModel;
  late ViewImageModel _viewImageModel;
  late DeleteImageModel _deleteImageModel;

  bool clickLoad = false;
  bool isLoad = false;
  bool deleteLoad = false;

  Future CheckUserConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        setState(() {
          ActiveConnection = true;
          T = "Turn off the data and repress again";
        });
      }
    } catch (Error) {
      // setState(() {
      ActiveConnection = false;
      T = "Turn On the data and repress again";
      // });
    }
  }

  String youarevalue="";

  List<File?> imagelist = List.filled(6, null);
  List<ImageDatum> _list = [];
  // List<File?> imagelist=[null,null,null,null,null,null];

  Future<void> uploadImage(File image) async {
    setState(() {
      clickLoad = true;
    });
    _preferences = await SharedPreferences.getInstance();
    _uploadImageModel = await Services.ImageUpload(image, "${_preferences?.getString(ShadiApp.userId).toString()}");
    if(_uploadImageModel.status == 1){
      Toaster.show(context, _uploadImageModel.message.toString());
      viewImage();
    }else{
      Toaster.show(context, _uploadImageModel.message.toString());
    }
    setState(() {
      clickLoad = false;
    });
  }

  Future<void> viewImage() async {
    isLoad = true;
    _preferences = await SharedPreferences.getInstance();
    _viewImageModel = await Services.ImageView("${_preferences?.getString(ShadiApp.userId).toString()}");
    if(_viewImageModel.status == 1) {
      for(var i = 0; i < _viewImageModel.data!.length; i++){
        _list = _viewImageModel.data ?? <ImageDatum> [];
      }
    }else{
      _list=[];
    }
    isLoad = false;
    setState(() {

    });
  }

  Future<void> deleteImage(String imageId) async {
    deleteLoad = true;
    _deleteImageModel = await Services.DeleteImage(imageId);
    if(_deleteImageModel.status == 1){
      Toaster.show(context, _deleteImageModel.message.toString());
      viewImage();
    }else{
      Toaster.show(context, _deleteImageModel.message.toString());
    }
    deleteLoad = false;
    setState(() {

    });
  }

  @override
  void initState() {
    CheckUserConnection();
    viewImage();
    super.initState();
  }

  void _pickedImage(int index) {
    showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
          content: Text("Choose image source"),
          actions: [
            TextButton(
              child: Text("Camera"),
              onPressed: () {
                _getFromCamera(index);
                Navigator.pop(context);
              }
            ),
            TextButton(
              child: Text("Gallery"),
              onPressed: () {
                _getFromGallery(index);
                Navigator.pop(context);
              }
            ),
          ]
      ),
    );
  }

  _getFromGallery(int index) async {
    PickedFile? pickedFile = await ImagePicker().getImage(
      source: ImageSource.gallery,
      maxWidth: 1800,
      maxHeight: 1800,
    );
    if (pickedFile != null) {
      setState((){
        imagelist[index] = File(pickedFile.path);
        uploadImage(File(pickedFile.path));
      });
    }
  }
  _getFromCamera(int index) async {
    PickedFile? pickedFile = await ImagePicker().getImage(
      source: ImageSource.camera,
      maxWidth: 1800,
      maxHeight: 1800,
    );
    if (pickedFile != null) {
      setState((){
        imagelist[index] = File(pickedFile.path);
        uploadImage(File(pickedFile.path));
      });

    }
  }



  @override
  Widget build(BuildContext context) {

    var size = MediaQuery.of(context).size;

    /*24 is for notification bar on Android*/
    final double itemHeight = (size.height - kToolbarHeight - 24) / 3;
    final double itemWidth = size.width / 2;

    return Scaffold(
      backgroundColor: CommonColors.themeblack,
      body: isLoad ? Center(
        child: CircularProgressIndicator(
          color: Colors.white,
          strokeWidth: 3.0,
        ),
      ):SingleChildScrollView(
        child: Center(
          child:  Column(
            mainAxisAlignment: MainAxisAlignment.start,
            // crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              new SizedBox(height: MediaQuery.of(context).padding.top+20,),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 10,vertical: 0),
                alignment: Alignment.centerLeft,
                child: InkWell(
                  onTap: (){
                    Navigator.of(context).pop();
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Image.asset(
                      'assets/back_icon.png',
                    ),
                  ),
                ),
              ),
              new SizedBox(height: 30,),
              Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Add Photos',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              new SizedBox(height: 8,),
              Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Add at least 2 photos to continue',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              new SizedBox(height: 10,),
              new Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: deleteLoad ? Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3.0,
                  ),
                ):new GridView.count(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: (itemWidth / itemHeight),
                  controller: new ScrollController(keepScrollOffset: false),
                  shrinkWrap: true,
                  scrollDirection: Axis.vertical,
                  children: List.generate(imagelist.length, (index) {
                    return Container(
                            decoration: BoxDecoration(
                              color: CommonColors.themeblack,
                              borderRadius: const BorderRadius.all(Radius.circular(5)),
                              border: /*imagelist[index] != null ?  null :*/ Border.all(color: Colors.white),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  spreadRadius: 5,
                                  blurRadius: 7,
                                  offset: Offset(0, 3), // changes position of shadow
                                ),
                              ],
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: <Widget>[

                                ClipRRect(
                                  borderRadius: BorderRadius.circular(5.0),
                                  child: _viewImageModel.status == 1 ?
                                       Container(
                                        child: index >= 0  && index < _list.length ?Image.network(
                                    "${_list![index].image}",fit: BoxFit.cover,
                                    height: itemHeight,
                                    width: itemWidth,
                                  ):Image.asset(
                                          "assets/add_photos.png",
                                          fit: BoxFit.cover,
                                          // height: itemHeight,
                                        ),
                                       )     // width: itemWidth,
                                      :imagelist[index] == null ? Image.asset(
                                    "assets/add_photos.png",
                                    fit: BoxFit.cover,
                                    // height: itemHeight,
                                    // width: itemWidth,
                                  ):Image.file(imagelist[index]!,fit: BoxFit.cover,
                                    height: itemHeight,
                                    width: itemWidth,)
                                ),
                                SizedBox.expand(
                                  child: Material(
                                    type: MaterialType.transparency,
                                    child: InkWell(onTap: () {
                                      _pickedImage(index);
                                    },splashColor: Colors.blue.withOpacity(0.2),
                                      customBorder: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                    ),
                                  ),
                                ),
                               if(imagelist[index] != null) new Positioned(
                                  right:0,
                                  top:0,
                                  child: SizedBox(
                                    height:30,
                                  width:30,
                                  child: Material(
                                    type: MaterialType.transparency,
                                    child: InkWell(onTap: () {
                                      setState((){
                                        imagelist[index]=null;
                                      });
                                    },splashColor: Colors.blue.withOpacity(0.2),
                                      customBorder: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      // child:  Container(
                                      //     decoration: BoxDecoration(
                                      //       // color: Colors.white,
                                      //       borderRadius: const BorderRadius.all(Radius.circular(15)),
                                      //     ),
                                      //     child: Icon(Icons.close,color: Colors.white,)),
                                    ),
                                  ),
                                ),),
                                SizedBox.expand(
                                  child: Material(
                                    type: MaterialType.transparency,
                                    child: InkWell(onTap: () {
                                      _pickedImage(index);
                                    },splashColor: Colors.blue.withOpacity(0.2),
                                      customBorder: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                    ),
                                  ),
                                ),
                               // if(_list[index] != null)
                                 index >= 0  && index < _list.length ?new Positioned(
                                  right:0,
                                  top:0,
                                  child: SizedBox(
                                    height:30,
                                  width:30,
                                  child: Material(
                                    type: MaterialType.transparency,
                                    child: InkWell(onTap: () {
                                      setState((){
                                        deleteImage(_list[index].id.toString());
                                        imagelist[index]=null;
                                      });
                                    },splashColor: Colors.blue.withOpacity(0.2),
                                      customBorder: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child:  Container(
                                          decoration: BoxDecoration(
                                            // color: Colors.white,
                                            borderRadius: const BorderRadius.all(Radius.circular(15)),
                                          ),
                                          child: Icon(Icons.close,color: Colors.white,)),
                                    ),
                                  ),
                                ),):Container(),

                              ],
                            ),
                          );
                  }
                    // imagelist.map((File? value) {
                  //   return Container(
                  //     // height: 100,
                  //     // margin: const EdgeInsets.symmetric(horizontal: 5,vertical: 5),
                  //     decoration: BoxDecoration(
                  //       // color: youarevalue == value ? CommonColors.buttonorg:CommonColors.themeblack ,
                  //       borderRadius: const BorderRadius.all(Radius.circular(5)),
                  //       border: value != null ?  null : Border.all(color: Colors.white),
                  //     ),
                  //     child: Stack(
                  //       alignment: Alignment.center,
                  //       children: <Widget>[
                  //         ClipRRect(
                  //           borderRadius: BorderRadius.circular(5.0),
                  //           child: Image.asset(
                  //             "assets/add_photos.png",
                  //             // height: 150.0,
                  //             // width: 100.0,
                  //           ),
                  //         ),
                  //         SizedBox.expand(
                  //           child: Material(
                  //             type: MaterialType.transparency,
                  //             child: InkWell(onTap: () {
                  //               _pickedImage()
                  //             },splashColor: Colors.blue.withOpacity(0.2),
                  //               customBorder: RoundedRectangleBorder(
                  //                 borderRadius: BorderRadius.circular(25),
                  //               ),
                  //             ),
                  //           ),
                  //         ),
                  //       ],
                  //     ),
                  //   );
                  // }).toList(),
                  ),
                  ),
              ),






              new SizedBox(height: 40,),

              Container(
                height: 50,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: CommonColors.buttonorg,
                  borderRadius:
                  const BorderRadius.all(Radius.circular(25)),
                ),
                child: Stack(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        clickLoad ? Expanded(
                            child: Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 3.0,
                              ),
                            )
                        ):
                        Expanded(
                            child: Center(
                              child: Text("Continue", style: TextStyle(
                                  color: Colors.white, fontSize: 20,fontWeight: FontWeight.w600,),),
                            )),
                      ],
                    ),
                    SizedBox.expand(
                      child: Material(
                        type: MaterialType.transparency,
                        child: InkWell(onTap: () {
                          List<File> imagelistfinal = imagelist.whereNotNull().toList();
                          if(_list.length == 0){
                          if(imagelistfinal.length<2){
                            Toaster.show(context, "Add at least 2 photos to continue");
                          }else{
                            Navigator.of(context).pushNamed('Intrests');
                          }
                          }else if(imagelistfinal.length<2){
                            Toaster.show(context, "Add at least 2 photos to continue");
                          }else{
                            Navigator.of(context).pushNamed('Intrests');
                          }
                        },splashColor: Colors.blue.withOpacity(0.2),
                          customBorder: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              new SizedBox(height: 40,),
            ],
          ),
        ),
      ),
    );
  }
}

