import 'package:flutter/material.dart';
import 'package:shadiapp/CommonMethod/CommonColors.dart';
import 'package:shadiapp/CommonMethod/commonString.dart';
import 'package:shadiapp/Models/view_like_sent_model.dart';
import 'package:shadiapp/Services/Services.dart';
import 'package:shadiapp/ShadiApp.dart';
import 'package:shadiapp/view/home/Home.dart';
import 'package:shadiapp/view/home/fragment/ShowBottomSheet.dart';
import 'package:shadiapp/view/home/fragment/match/Match.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Likes extends StatefulWidget {
  @override
  State<Likes> createState() => _LikesState();

}

class _LikesState extends State<Likes> {

  late SharedPreferences _preferences;
  late ViewLikeSentModel _likeSentModel;
  late List<Datum> _list = [];
  bool isLoad = false;
  String plan = "";

  Future<void> viewLike() async {
    isLoad = true;
    _preferences = await SharedPreferences.getInstance();
    plan = _preferences.getString(ShadiApp.user_plan)!;
    _likeSentModel = await Services.ViewLike(_preferences.getString(ShadiApp.userId).toString());
    if(_likeSentModel.status == 1){
      for(var i = 0; i <  _likeSentModel.data!.length; i++){
        _list = _likeSentModel.data ?? <Datum> [];
      }
    }
    isLoad = false;
    if(mounted) {
      setState(() {});
    }
  }

  var images = [
    "https://w0.peakpx.com/wallpaper/564/224/HD-wallpaper-beautiful-girl-bengali-eyes-holi-indian.jpg",
    "https://w0.peakpx.com/wallpaper/396/511/HD-wallpaper-bong-angel-bengali.jpg",
    "https://w0.peakpx.com/wallpaper/798/474/HD-wallpaper-beauty-123-beautiful-ivana-saree.jpg",
    "https://w0.peakpx.com/wallpaper/366/237/HD-wallpaper-vaishnavi-beautiful-saree.jpg",
    "https://w0.peakpx.com/wallpaper/233/819/HD-wallpaper-vaishnavi-shanu-short-film-software-developer.jpg",
    "https://w0.peakpx.com/wallpaper/344/1000/HD-wallpaper-ashika-ranganath-saree-lover-model.jpg",
    "https://w0.peakpx.com/wallpaper/280/777/HD-wallpaper-anju-kurien-mallu-actress-saree-lover.jpg",
    "https://w0.peakpx.com/wallpaper/373/1013/HD-wallpaper-anju-32-actress-girl-mallu-anju-kurian.jpg",
    "https://w0.peakpx.com/wallpaper/306/75/HD-wallpaper-anju-kurian-babu-suren.jpg",
    "https://w0.peakpx.com/wallpaper/504/652/HD-wallpaper-anju-kurian-anju-kurian-mallu.jpg",
    "https://w0.peakpx.com/wallpaper/290/185/HD-wallpaper-anju-kurian-flash-graphy-lip.jpg",
    "https://w0.peakpx.com/wallpaper/320/566/HD-wallpaper-jisoo-jisoo-blackpink.jpg",
    "https://w0.peakpx.com/wallpaper/862/303/HD-wallpaper-jisoo-blackpink-blackpink-jisoo-k-pop.jpg",
    "https://w0.peakpx.com/wallpaper/509/744/HD-wallpaper-jisoo-blackpink-cute-k-pop-love-music.jpg",
  ];

  @override
  void initState() {
    viewLike();
    super.initState();
  }

  void showProfile(String image, String id){
    showBottomSheet(
      context: context,
      backgroundColor: CommonColors.themeblack,
      elevation: 10,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      builder: (context) {
        return  ShowBottomSheet(image, id);
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    /*24 is for notification bar on Android*/
    final double itemHeight = (size.width / 2)+40;
    final double itemWidth = size.width / 2;
  return Scaffold(
    backgroundColor: CommonColors.themeblack,
    body: isLoad ? Center(
      child: CircularProgressIndicator(
        color: Colors.white,
        strokeWidth: 3.0,
      ),
    ):Container(
      margin: EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: _list.isNotEmpty ? GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 15.0,
            mainAxisSpacing: 15.0,
            childAspectRatio: (itemWidth / itemHeight),
          ),
          itemCount: _list.length,
          itemBuilder: (context, index){
            Datum data = _list[index];
            // print(data.type);
            return InkWell(
              onTap: (){
                // CommonString.homesearch = "${data.id}";
                // Navigator.pushReplacement(context,
                //     MaterialPageRoute(builder: (context) => Home()));
                print("image: ${data.image.toString()}\nid:${data.userId.toString()}");
                showProfile(data.image.toString(),data.userId.toString());
              },
              child: Container(
                height: 168,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(
                      Radius.circular(15.0)),
                  color: CommonColors.bottomgrey,
                ),
                child:
                ClipRRect(
                  borderRadius: BorderRadius.circular(15.0),
                  child: Container(
                      decoration: BoxDecoration(
                          image: DecorationImage(
                              image: NetworkImage(data.image.toString()),
                              fit: BoxFit.cover)
                      ),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Spacer(),
                            Container(
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0xff66DFD7D7),
                                      Color(0xff00D9D9D9),
                                    ],
                                    begin: Alignment.center,
                                    end: Alignment.bottomRight,)
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                child: Row(
                                  children: [
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          child: Text("${data.name}, ${data.age}",
                                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600,
                                                fontSize: 14),),
                                        ),
                                        Container(
                                          child: Text("${DateTime.now().difference(data.createdAt ??  DateTime.now()).inHours} H",
                                              style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w400,)),
                                        )
                                      ],
                                    ),
                                    Spacer(),
                                     Container(
                                      height: 28,
                                      margin: const EdgeInsets.symmetric(vertical: 6),
                                      width: 28,
                                      child: data.type=="superLike" ? Image.asset("assets/white_bg_star.png",height: 28,width: 28):Container(),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ]
                      )
                  ),
                ),
              ),
            );
          }
          ):Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset("assets/no_likes_icon.png",),
              SizedBox(height: 20,),
              Text("No Likes", style: TextStyle(fontSize: 16, fontFamily: 'dubai', color: CommonColors.buttonorg, fontWeight: FontWeight.bold),textAlign: TextAlign.center,),
            ],
          )
      ),
    ),
  );
  }

}