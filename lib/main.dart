import 'dart:async';
import 'dart:convert';

import 'package:bridgebank_social_app/app_setup.dart';
import 'package:bridgebank_social_app/configuration/constants.dart';
import 'package:bridgebank_social_app/configuration/theme.dart';
import 'package:bridgebank_social_app/configuration/token_manager.dart';
import 'package:bridgebank_social_app/providers/conversations_provider.dart';
import 'package:bridgebank_social_app/ui/screens/main/profile/cubit/upload_image_cubit.dart';
import 'package:bridgebank_social_app/ui/screens/main/profile/profile_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';


_onDidReceiveLocalNotification(int id, String? title, String? body, String? payload){
  print("_onDidReceiveLocalNotification =>>>>>>");
  print("_onDidReceiveLocalNotification =>>>>>> id =>> $id");
  print("_onDidReceiveLocalNotification =>>>>>> title =>> $title");
  print("_onDidReceiveLocalNotification =>>>>>> body =>> $body");
  print("_onDidReceiveLocalNotification =>>>>>> payload =>> $payload");
}

_onDidReceiveNotificationResponse(NotificationResponse notificationResponse){
  print("_onDidReceiveNotificationResponse =>>>>>> $notificationResponse");
}

_onDidReceiveBackgroundNotificationResponse(NotificationResponse notificationResponse){
  print("_onDidReceiveBackgroundNotificationResponse =>>>>>> $notificationResponse");

}

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

initLocalNotification()async{
  InitializationSettings initializationSettings = const InitializationSettings(
      android: AndroidInitializationSettings('ic_launcher'),
      iOS: DarwinInitializationSettings(
          onDidReceiveLocalNotification: _onDidReceiveLocalNotification
      )
  );
  await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse:_onDidReceiveNotificationResponse,
      onDidReceiveBackgroundNotificationResponse: _onDidReceiveBackgroundNotificationResponse
  );
}

showNotification(RemoteMessage message){
  flutterLocalNotificationsPlugin.show(
      message.messageId.hashCode,
      message.notification!.title,
      message.notification!.body,
      NotificationDetails(
          android: AndroidNotificationDetails(
              "channelId",
              'channelName'
          ),
          iOS: DarwinNotificationDetails()
      ),
      payload: jsonEncode(message.data)
  );
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  print("Handling a background message: ${message.messageId}");

  if(message.notification != null){
    //showNotification(message);
  }
}

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await initLocalNotification();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await AppSetup.init();
  final Widget firstScreen = AppSetup.start();

  runApp(MyApp(homeScreen: firstScreen,));
}

class MyApp extends StatefulWidget  {

  final Widget homeScreen;
  const MyApp({super.key, required this.homeScreen});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver{

  // This widget is the root of your application.
  late Widget _homeScreen;

  Timer? _timer;

  notificationInit()async{

    await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();
  }

  @override
  void initState() {
    //Init properties
    _homeScreen = widget.homeScreen;
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    //Foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');

        showNotification(message);

      }

    });

    Timer.run((){
      notificationInit();
    });

    _startTimer();

  }

  void _startTimer(){
    print("_startTimer");

    _timer = Timer.periodic(const Duration(
        seconds: Constants.TIMER_DELAY
    ), (timer){
      print("Timer.periodic => ${DateTime.now()}");
      if(TokenManager.isExpired()){
        AppSetup.localStorageService.clear()
            .whenComplete((){
          setState(() {

          });
        });

      }else{
        //Automatic refresh
        TokenManager.refresh();
      }

    });

    if(mounted){
      setState(() {

      });
    }
  }


  _stopTimer(){
    print("_stopTimeer");
    if(_timer != null){
      _timer!.cancel();
      _timer = null;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    //Implement didChangeAppLifecycleState

    if(state == AppLifecycleState.paused){
      print("AppLifecycleState.paused");
      _stopTimer();

    }

    if(state == AppLifecycleState.resumed){

      _startTimer();

      print("AppLifecycleState.resumed");
      //Check token expiration
      if(TokenManager.isExpired()){
        AppSetup.localStorageService.clear()
            .whenComplete((){
          if(mounted){
            setState(() {

            });
          }
        });

      }

    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  void dispose() {
    //Implement dispose
    _stopTimer();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();

  }
  @override
  Widget build(BuildContext context) {
    return FlutterSizer(
      builder: (contxt, orientation, screenType){
        return Listener(
          onPointerDown: (event){
            print("$event");
            if(TokenManager.isExpired()){
              if(mounted){
                setState(() {
                });
              }
            }else{
              TokenManager.refresh();
            }

          },
          child: MaterialApp(
              title: 'Flutter Demo',
              theme: AppTheme.light(),
              //home: MainScreen(title: "BB Social",)

            home: MultiProvider(
              providers: [
                ChangeNotifierProvider(create: (_)=>
                    ConversationsProvider(
                    AppSetup.backendService,
                    AppSetup.localStorageService
                ))
              ],
              child: TokenManager.isExpired()?
              AppSetup.start():
              _homeScreen,
            ),
/*              home: MultiBlocProvider(
                providers: [
                  BlocProvider(
                      create: (_)=> UploadImageCubit(uploadImageService:
                      AppSetup.uploadImageService),
                  )
                ],
                child: TokenManager.isExpired()?
                AppSetup.start():
                _homeScreen,
              ),*/
            //home: const RegisterScreen(),
          ),
        );
      },
    );
  }
}