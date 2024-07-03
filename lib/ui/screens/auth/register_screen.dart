import 'dart:io';

import 'package:bridgebank_social_app/app_setup.dart';
import 'package:bridgebank_social_app/configuration/constants.dart';
import 'package:bridgebank_social_app/data/models/session.dart';
import 'package:bridgebank_social_app/rest/exception/auth/auth_exception.dart';
import 'package:bridgebank_social_app/ui/screens/auth/login_screen.dart';
import 'package:bridgebank_social_app/ui/widgets/custom_button.dart';
import 'package:bridgebank_social_app/ui/widgets/custom_text_field.dart';
import 'package:bridgebank_social_app/ui/widgets/progress_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:bridgebank_social_app/configuration/colors.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';

class RegisterScreen extends StatefulWidget {

  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {


  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();

  bool _isLoading = false;
  bool _isTermsAccepted = false;

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      body:_isLoading?
      const ProgressUi()
          : SingleChildScrollView(
        child: Column(
          children: [

            SizedBox(height: 8.h,),
            //Display Logo
            _buildLogoUi(),
            SizedBox(height: 4.h,),
            Center(
              child: Text("Inscription", style: Theme.of(context).textTheme
                  .headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),),
            ),
            Container(
              padding: const EdgeInsets.only(left: Constants.defaultPadding,right: Constants.defaultPadding),
              child: Text("Rejoignez nous maintenant ! Ouvrez un compte pour accéder à la communauté.",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme
                  .titleMedium,),
            ),
            //FirstName
            SizedBox(height: 4.h,),
            //Email
            DefaultTextField(
              textController: _firstNameController,
              inputType:  TextInputType.name,
              placeholder: "Prénoms",
              prefixIcon: Icons.person,
            ),
            SizedBox(height: 1.h,),
            //LastName
            DefaultTextField(
              textController: _lastNameController,
              inputType:  TextInputType.name,
              placeholder: "Nom",
              prefixIcon: Icons.person,
            ),
            //Email
            SizedBox(height: 1.h,),
            //Email
            DefaultTextField(
              textController: _emailController,
              inputType:  TextInputType.emailAddress,
              placeholder: "Email",
              prefixIcon: Icons.email,
            ),
            SizedBox(height: 1.h,),
            //Password
            DefaultTextField(
              textController: _passwordController,
              inputType:  TextInputType.text,
              placeholder: "Mot de passe",
              prefixIcon: Icons.lock,
              obscureText: true,
            ),
            SizedBox(height: 4.h,),
            Row(
              children: [
                Checkbox(value: _isTermsAccepted,
                    onChanged: (value){
                      _isTermsAccepted  = value!;
                 setState(() {

                 });
                }),
                Expanded(
                  child: GestureDetector(
                    onTap: (){
                      _isTermsAccepted  = !_isTermsAccepted;
                      setState(() {

                      });
                    },
                    child: const Text("J'accepte les conditions d'utilisations en cochant cette case. "
                        "Cette action est obligatoire pour votre inscription.",
                    ),
                  ),
                )
              ],
            ),
            SizedBox(height: 4.h,),
            //Bouton Connexion
            CustomButton(
                title: "S'inscrire",
                onTap: _submitRegister
            ),
            SizedBox(height: 2.h,),
            CustomButton(
                title: "Se connecter",
                color: AppColors.primary,
                onTap: (){
                  final route = MaterialPageRoute(builder: (ctxt) => const LoginScreen());
                  Navigator.pushReplacement(context, route);
                }),
            //TODO Bouton Inscription
          ],
        ),
      ),
    );
  }

  Widget _buildLogoUi(){
    return Center(
      child: Image.asset("${Constants.imagesDirectory}/bank_logo.png",
        width: 60.w,
      ),
    );
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

  void _submitRegister() {

    //Check Inputs

    if(_firstNameController.text.isEmpty){
      //Show Email est obligatoire
      Fluttertoast.showToast(
          msg: "Prénom est obligatoire",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0
      );

      return;
    }

    if(_lastNameController.text.isEmpty){
      //Show Email est obligatoire
      Fluttertoast.showToast(
          msg: "Nom de famille est obligatoire",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0
      );

      return;
    }
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

    if(!_isTermsAccepted){
      //Show Email est obligatoire
      Fluttertoast.showToast(
          msg: "Vous devez absolument accepter les conditions d'utilisations.",
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

    final String firstName = _firstNameController.text.trim().toString();
    final String lastName = _lastNameController.text.trim().toString();
    final String email = _emailController.text.trim().toString();
    final String password  = _passwordController.text.trim().toString();

    AppSetup.backendService.signUp(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password)
        .then((Session value){
      print("Session  $value");
      _hideProgress();

      AppSetup.localStorageService.storeConnectedUser(value)
          .whenComplete((){

        AppSetup.toastLongSuccess("Inscription réussie !");

        final newRoute = MaterialPageRoute(builder: (_)=> AppSetup.start());
        Navigator.pushAndRemoveUntil(context, newRoute, (_) => false);

      });


    }).catchError((error){
      _hideProgress();
      print("LoginScreen._submitRegister() =>> Error => $error");
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
