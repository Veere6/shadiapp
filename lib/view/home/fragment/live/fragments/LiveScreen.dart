import 'package:flutter/material.dart';
import 'package:shadiapp/CommonMethod/CommonColors.dart';
import 'package:shadiapp/Models/view_live_model.dart';
import 'package:shadiapp/Services/Services.dart';
import 'package:shadiapp/view/home/fragment/live/LiveRoom.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LiveScreen extends StatefulWidget {
  @override
  State<LiveScreen> createState() => _LiveScreenState();

}

class _LiveScreenState extends State<LiveScreen> {

  TextEditingController search = TextEditingController();
  late ViewLiveModel _liveModel;
  List<Datum> list = [];
  late SharedPreferences _preferences;
  
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
  Future<void> viewLive(page) async {
    _preferences = await SharedPreferences.getInstance();
    _liveModel = await Services.ViewLiveMethod({"page": '${page}'});
    if(_liveModel.status == true){
      for(int i = 0; i < _liveModel.data!.length; i++){
       list = _liveModel.data ?? <Datum> [];
      }
    }
    setState(() {

    });
  }

  @override
  void initState() {
    viewLive(1);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
   return Scaffold(
     backgroundColor: CommonColors.themeblack,
     body: Container(
       child: Column(
         children: [
           Container(
             decoration: BoxDecoration(
               border: Border.all(color: Colors.white),
               borderRadius: BorderRadius.all(Radius.circular(30))
             ),
             margin: EdgeInsets.only(left: 20, top: 20, right: 20 , bottom: 0),
             child: TextField(
               controller: search,
               decoration: InputDecoration(
                 border: InputBorder.none,
                 hintText: 'Search',
                 hintStyle: TextStyle(
                   color: Colors.white
                 ),
                 prefixIcon: Icon(Icons.search,
                 color: Colors.white,),
               ),
             ),
           ),
           Expanded(
             child: Container(
               margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 0.0),
               child: list.isNotEmpty ? GridView.builder(
                   gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                       crossAxisCount: 2,
                       crossAxisSpacing: 2.0,
                       mainAxisSpacing: 10.0),
                   itemCount: list.length,
                   itemBuilder: (context, index){
                     Datum data = list[index];
                     return Container(
                       child: InkWell(
                         onTap: (){
                           Navigator.of(context).push(
                               MaterialPageRoute(
                                   builder: (context) => LiveRoom(images[index], '${data.channelName}', '${data.token}', true, false
                                   ))
                           );
                         },
                         child: Container(
                             margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
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
                                           image: NetworkImage(images[index]),
                                           fit: BoxFit.fill)
                                   ),
                                   child: Column(
                                       mainAxisAlignment: MainAxisAlignment.start,
                                       crossAxisAlignment: CrossAxisAlignment.start,
                                       children: [
                                         Spacer(),
                                           Padding(
                                             padding: const EdgeInsets.only(left: 10.0, right: 10.0, bottom: 5.0),
                                             child:
                                                     Container(
                                                       child: Text("Ana, 24",
                                                         style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),),
                                                     ),
                                           ),
                                       ]
                                   )
                               ),
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
                       Image.asset("assets/no_live_icon.png",),
                       SizedBox(height: 20,),
                       Text("No Live", style: TextStyle(fontSize: 16, fontFamily: 'dubai', color: CommonColors.buttonorg, fontWeight: FontWeight.bold),textAlign: TextAlign.center,),
                     ],
                   )
               ),
             ),
           ),
         ],
       ),
     ),
   );
  }

}