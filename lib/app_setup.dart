import 'package:bridgebank_social_app/configuration/token_manager.dart';
import 'package:bridgebank_social_app/data/database/database_helper.dart';
import 'package:bridgebank_social_app/data/models/session.dart';
import 'package:bridgebank_social_app/data/storage/database_source.dart';
import 'package:bridgebank_social_app/data/storage/local_storage_service.dart';
import 'package:bridgebank_social_app/data/storage/shared_prefs.dart';
import 'package:bridgebank_social_app/rest/backend_rest_service.dart';
import 'package:bridgebank_social_app/rest/backend_service.dart';
import 'package:bridgebank_social_app/rest/upload/imgur/imgur_service.dart';
import 'package:bridgebank_social_app/rest/upload/upload_image_service.dart';
import 'package:bridgebank_social_app/ui/screens/auth/login_screen.dart';
import 'package:bridgebank_social_app/ui/screens/main/main_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class AppSetup{


  static late BackendService backendService;
  static late LocalStorageService localStorageService;
  static late UploadImageService uploadImageService;

  static Session? me;

  static init()async{

    backendService = BackendRestService();
    final SharedPreferences preferences = await SharedPreferences.getInstance();

    // Open Database
    //await DatabaseHelper.connection();
   // localStorageService = await DatabaseSource.getInstance();
     localStorageService = SharedPrefs(preferences);
    uploadImageService = ImgurService();

    me = localStorageService.connectedUser();

    print("AppSetup init()");
    print("AppSetup init() Session $me");


  }

  static Widget start(){

    me = localStorageService.connectedUser();

    print("AppSetup start() Session $me");

    if(me == null){
      return const LoginScreen();
    }else{
      //Check token expiration
      print("Check token expiration");
      if(TokenManager.isExpired()){
        print("Token is expired");
        localStorageService.clear()
        .whenComplete((){
          print("Cache cleared");
        });
        return const LoginScreen();
      }else{
        print("Token is not expired");
        return const MainScreen(title: "Bridge Bank Social");
      }

    }


  }

  static toastLong(String text){
    Fluttertoast.showToast(
        msg: text,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 16.0
    );
  }

  static toastLongSuccess(String text){
    Fluttertoast.showToast(
        msg: text,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0
    );
  }

  static logout({required BuildContext context, required Function() onStartLoading, required Function () onCompleteLoading}){

    onStartLoading();

    //SignOut from API
    backendService.signOut()
        .whenComplete((){

          print("SignOut from BackendService");

          //Clear our cache
          localStorageService.clear()
          .whenComplete((){

            print("Cache cleared");

            onCompleteLoading();

            //toastLongSuccess('Déconnexion réussie');

            //Navigate to LoginScreen
            final homeScreen = start();
            final newRoute = MaterialPageRoute(builder: (context)=> homeScreen);
            Navigator.pushAndRemoveUntil(context, newRoute, (_)=>false);

          });
    });
  }






}