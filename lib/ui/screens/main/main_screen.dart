import 'dart:async';
import 'dart:ui';

import 'package:bridgebank_social_app/app_setup.dart';
import 'package:bridgebank_social_app/configuration/colors.dart';
import 'package:bridgebank_social_app/ui/screens/main/contacts/contacts_screen.dart';
import 'package:bridgebank_social_app/ui/screens/main/pages/groups_page.dart';
import 'package:bridgebank_social_app/ui/screens/main/pages/messages_page.dart';
import 'package:bridgebank_social_app/ui/screens/main/profile/cubit/upload_image_cubit.dart';
import 'package:bridgebank_social_app/ui/screens/main/profile/profile_screen.dart';
import 'package:bridgebank_social_app/ui/widgets/dialogs.dart';
import 'package:bridgebank_social_app/ui/widgets/progress_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MainScreen extends StatefulWidget {
  final String title;
  const MainScreen({super.key, required this.title});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {


  bool _isLoading = false;


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

    return _isLoading?
    const Scaffold(
      body: ProgressUi(),
    ):DefaultTabController(
        length: 2,
        child: Scaffold(
            appBar: AppBar(
              title: Text(widget.title),
              actions: [

                IconButton(onPressed: (){

                  Navigator.push(context, MaterialPageRoute(
                      builder: (_)=>
                      BlocProvider(
                          create: (_)=>UploadImageCubit(uploadImageService:
                          AppSetup.uploadImageService),
                        child: const ProfileScreen(),
                      ),
                  ));
            /*      Navigator.push(context, MaterialPageRoute(
                      builder: (_)=>
                   BlocProvider.value(
                     value: context.read<UploadImageCubit>(),
                     child: const ProfileScreen(),
                   )
                  ));*/

                }, icon: const Icon(Icons.person)),

                IconButton(
                    onPressed: (){

                      //Show Disclaimer and Take confirmation

                     Dialogs.showConfirmDialog(
                         context: context,
                         message: "Êtes-vous sûr de vouloir vous déconnecter?",
                         onCancel: (){
                           print("onCancel()");

                         },
                         onConfirm: (){
                           print("onConfirm()");
                           AppSetup.logout(context:context, onStartLoading:_showProgress, onCompleteLoading:_hideProgress);

                         });

                      },
                    icon: const Icon(Icons.logout, color: Colors.white,)
                )

              ],
              bottom: const TabBar(
                labelColor: Colors.white,
                tabs: [
                  Tab(
                    text: "Message",
                  ),
                  Tab(
                    text: "Group",
                  )
                ],
              ),
            ),
            floatingActionButton: FloatingActionButton(
              backgroundColor: Colors.transparent,
              onPressed: (){

                Navigator.push(context, MaterialPageRoute(
                    builder: (context)=> const ContactsScreen(),

                ));
              },
              child: Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.secondary,

                ),
                child: const Icon(Icons.add, color: Colors.white,),
              ),
            ),
            body: const TabBarView(
              children: [
                MessagesPage(),
                GroupsPage(),
              ],
            )
        )
    );
  }


}
