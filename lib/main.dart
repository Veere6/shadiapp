import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:provider/provider.dart';
import 'package:shadiapp/CommonMethod/CommonColors.dart';
import 'package:shadiapp/CommonMethod/ConnectivityProvider.dart';
import 'package:shadiapp/CommonMethod/CustomRoute.dart';
import 'package:shadiapp/Models/user_detail_model.dart';
import 'package:shadiapp/Services/Services.dart';
import 'package:shadiapp/ShadiApp.dart';
import 'package:shadiapp/view/ChooseReg/ChooseReg.dart';
import 'package:shadiapp/view/home/Home.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  Stripe.publishableKey = "pk_test_51Neuj5SC5priZjFLjU31X9irMl3HhAarUx45NTGqkV68tHfmsKypv4JVKSNDXiV0ro3xwduXuoAkI5uoKy6HNMup00GxsK1Iwv";
  runApp(const MyApp());
}
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        systemNavigationBarColor: CommonColors.themeblack,
      statusBarColor: Colors.transparent
    ));
    return ChangeNotifierProvider(
      create:(context) => ConnectivityProvider(),
        child:  MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
              primarySwatch: Colors.blue,
              fontFamily: 'opensans'
          ),
          onGenerateRoute: CustomRoute.allRoutes,
          home: const MyHomePage(),
    ));
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver{
  // final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _userStatusRef = FirebaseDatabase.instance.reference().child('users');

  String firebasetoken="";
  @override
  void initState() {
    // CheckUserConnection();
    WidgetsBinding.instance.addObserver(this);
    setUserOnlineStatus(true); // Set user as online when the app is opened

    FirebaseMessaging.instance.getToken().then((value) {
      firebasetoken = value ?? "";

    });
    Future.delayed(Duration(seconds: 3), () {
      navigateUser(context,firebasetoken);
    });
    super.initState();

  }

  @override
  void dispose() {
    // WidgetsBinding.instance.removeObserver(this);
    // setUserOnlineStatus(false); // Set user as offline when the app is closed
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused) {
      setUserOnlineStatus(false); // Set user as offline when the app is in the background
    } else if (state == AppLifecycleState.resumed) {
      setUserOnlineStatus(true); // Set user as online when the app is resumed
    }
  }

  void setUserOnlineStatus(bool online)async {
    // final User? user = _auth.currentUser;
    SharedPreferences _preferences = await SharedPreferences.getInstance();
    String userId="${_preferences?.getString(ShadiApp.userId).toString()}";
    if (userId != null) {
      final DatabaseReference statusRef = _userStatusRef.child(userId).child('status');
      statusRef.set(online ? 'online' : 'offline');
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: CommonColors.themeblack,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset("assets/logo_name.png",height: 62,width: 215,)
          ],
        ),
      ),
    );
  }
}

void updateUserPresence(String userId, bool isOnline) {
  FirebaseFirestore.instance.collection('userPresence').doc(userId).set({
    'online': isOnline,
  });
}

void navigateUser(BuildContext context,String firebasetoken) async{
  SharedPreferences _preferences = await SharedPreferences.getInstance();
  _preferences.setString(ShadiApp.fToken, firebasetoken);
  bool? status = _preferences.getBool(ShadiApp.status);
  String userId="${_preferences?.getString(ShadiApp.userId).toString()}";
  if (status == true) {
    UserDetailModel _userDetailModel = await Services.UserDetailMethod("${_preferences?.getString(ShadiApp.userId).toString()}");
    updateUserPresence(userId,true);
    int percent=0;
    if(_userDetailModel.status!=0) {
      _preferences.setBool(
          ShadiApp.isOnline, _userDetailModel.data?[0].isOnline ?? false);
      percent = _userDetailModel.data?[0].profilePercentage ?? 0;
      // percent = _userDetailModel.data?[0].profilePercentage ?? 0;
      _preferences.setString(
          ShadiApp.user_plan, _userDetailModel.data?[0].plan ?? "");
      print(percent);
      if (percent >= 70) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          'Home', (Route<dynamic> route) => false,
        );
      } else {
        Navigator.of(context).pushNamed('CountryCity');
      }
    }else{
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => ChooseReg()), (route) => false);
    }
    // Navigator.of(context).pushAndRemoveUntil(
    //     MaterialPageRoute(builder: (context) => Home()), (route) => false);
  }else{
    // Navigator.of(context).pushNamed('Home');
    // Navigator.of(context).pushNamed('FreeSub');
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => ChooseReg()), (route) => false);
  }

}
