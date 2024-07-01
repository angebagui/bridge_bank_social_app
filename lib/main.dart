import 'dart:async';
import 'dart:convert';

import 'package:bridgebank_social_app/app_setup.dart';
import 'package:bridgebank_social_app/configuration/constants.dart';
import 'package:bridgebank_social_app/configuration/theme.dart';
import 'package:bridgebank_social_app/configuration/token_manager.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:firebase_core/firebase_core.dart';
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
            home: TokenManager.isExpired()?
                AppSetup.start():
            _homeScreen,
            //home: const RegisterScreen(),
          ),
        );
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
