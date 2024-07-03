import 'dart:async';
import 'dart:io';

import 'package:bridgebank_social_app/app_setup.dart';
import 'package:bridgebank_social_app/configuration/constants.dart';
import 'package:bridgebank_social_app/data/models/session.dart';
import 'package:bridgebank_social_app/rest/exception/auth/auth_exception.dart';
import 'package:bridgebank_social_app/ui/screens/auth/register_screen.dart';
import 'package:bridgebank_social_app/ui/widgets/custom_button.dart';
import 'package:bridgebank_social_app/ui/widgets/custom_text_field.dart';
import 'package:bridgebank_social_app/ui/widgets/progress_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:bridgebank_social_app/configuration/colors.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class LoginScreen extends StatefulWidget {

  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {


  final TextEditingController _emailController = TextEditingController(text: "angebagui@adjemin.com");
  final TextEditingController _passwordController = TextEditingController(text: "123456789");

  bool _isLoading = false;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Timer.run((){
      notificationInit();
      getToken();
    });

  }

  void getToken(){
    FirebaseMessaging messaging = FirebaseMessaging.instance;

// use the returned token to send messages to users from your custom server
    messaging.getToken()
    .then((String? token){

      print("FirebaseID =>>> $token");

    });



  }

  void notificationInit()async{

    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    print('User granted permission: ${settings.authorizationStatus}');
  }

  void _showProgress(){
    _isLoading = true;
    if(mounted){
      setState(() {

      });
    }
  }

  void _hideProgress(){
    _isLoading = false;
    if(mounted){
      setState(() {

      });
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body:_isLoading?ProgressUi():SingleChildScrollView(
        child: Column(
          children: [

            SizedBox(height: 8.h,),
            //Display Logo
            _buildLogoUi(),
            SizedBox(height: 4.h,),
            Center(
              child: Text("Connexion", style: Theme.of(context).textTheme
                  .headlineLarge,),
            ),
            Center(
              child: Text("Connectez vous maintenant !", style: Theme.of(context).textTheme
                  .titleLarge,),
            ),
            //Email
            SizedBox(height: 4.h,),
            //Email
            DefaultTextField(
              textController: _emailController,
              inputType:  TextInputType.emailAddress,
              placeholder: "Email",
              prefixIcon: Icons.email,
            ),
            SizedBox(height: 2.h,),
            //Password
            DefaultTextField(
              textController: _passwordController,
              inputType:  TextInputType.text,
              placeholder: "Mot de passe",
              prefixIcon: Icons.lock,
              obscureText: true,
            ),
            SizedBox(height: 2.h,),

            //Lien Mot de passe oublié
            InkWell(
              onTap: (){
                print("User onTap");
              },
              child: const Text("Mot de passe oublié?",
                style: TextStyle(
                    decoration: TextDecoration.underline
                ),),
            ),

            SizedBox(height: 2.h,),
            //Bouton Connexion
            CustomButton(
                title: "Se connecter",
                onTap: _submitLogin
                ),
            SizedBox(height: 2.h,),
            CustomButton(
                title: "S'inscrire",
                color: AppColors.primary,
                onTap: (){

                  final route = MaterialPageRoute(builder: (ctxt) => const RegisterScreen());
                  Navigator.pushReplacement(context, route);
                }),
            //TODO Bouton Inscription
          ],
        ),
      )
    );
  }

  Widget _buildLogoUi(){
    return Center(
      child: Image.asset("${Constants.imagesDirectory}/bank_logo.png",
      width: 60.w,
      ),
    );
  }

  void _submitLogin() {

    //Check Inputs
    if(_emailController.text.isEmpty){
      //Show Email est obligatoire
      Fluttertoast.showToast(
          msg: "Email est obligatoire",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0
      );

      return;
    }

    if(_passwordController.text.isEmpty){
      //Show Mot de passe est obligatoire
      Fluttertoast.showToast(
          msg: "Mot de passe est obligatoire",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0
      );

      return;
    }

    //Show Dialog
    _showProgress();

    final String email = _emailController.text.trim().toString();
    final String password  = _passwordController.text.trim().toString();

    AppSetup.backendService.signIn(email: email, password: password)
    .then((Session value){
      print("Session  $value");
      _hideProgress();

      AppSetup.localStorageService.storeConnectedUser(value)
      .whenComplete((){

        AppSetup.toastLongSuccess("Connexion réussie !");

        final newRoute = MaterialPageRoute(builder: (_)=> AppSetup.start());
        Navigator.pushAndRemoveUntil(context, newRoute, (_) => false);

      });


    }).catchError((error){
      _hideProgress();
      print("LoginScreen._submitLogin() =>> Error => $error");
      if(error is AuthException){

          AppSetup.toastLong(error.message);

      }else if(error is SocketException || error is ClientException){
        AppSetup.toastLong("S'il vous plâit, veuillez vérifier votre connexion internet");
      }else if(error is ArgumentError){

      }else if(error is Exception){

      }else{
        AppSetup.toastLong(error.message);
      }


    });


  }


}
