import 'dart:io';

import 'package:bridgebank_social_app/app_setup.dart';
import 'package:bridgebank_social_app/configuration/colors.dart';
import 'package:bridgebank_social_app/ui/screens/main/profile/cubit/upload_image_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  //String? photoUrl = "https://images.unsplash.com/photo-1719066373323-c3712474b2a4?q=80&w=1587&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mon compte"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),

            Center(
              child:  BlocBuilder<UploadImageCubit, UploadImageState>(
                  builder: (contxt, state){
                    if(state is NotUploadedImageState){
                      return _buildAddPhotoUi(context);
                    }

                    if(state is UploadedImageState){
                      return _buildUploadedPhotoUi(
                          context,
                          state.url
                      );
                    }

                    if(state is ProgressBarState){
                      return _buildUploadingUi();
                    }

                    if(state is UploadErrorState){
                      return Text("Error ${state.exception}");
                    }
                    return _buildAddPhotoUi(contxt);
                  }
              ),
            )

          ],
        ),
      ),
    );
  }

  Widget _buildAddPhotoUi(BuildContext contxt) {
    return Container(
        width: 140,
        height: 140,
        decoration: const BoxDecoration(
          color: Colors.black,
          shape: BoxShape.circle,
        ),
        child:  IconButton(
          onPressed: (){
            _addPicture(contxt);
          },
          icon:const Icon(Icons.add_a_photo,
            color: Colors.white,size: 60,),
        )
    );
  }

  Widget _buildUploadedPhotoUi(BuildContext contxt, String photoUrl) {

    return Container(
      width: 140,
      height: 140,
      child: Stack(
        children: [
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image:NetworkImage(
                      photoUrl
                  ),
                )
            ),
          ),

          Align(
            alignment: Alignment.topRight,
            child: IconButton(
                onPressed:(){
                  _addPicture(contxt);
                },
                icon: const Icon(
                  Icons.edit,
                  color: AppColors.secondary,
                )),
          )

        ],
      ),
    );
  }

  Widget _buildUploadingUi() {
    return Container(
      height: 140,
      width: 140,
      child: CircularProgressIndicator(),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
          border: Border.all(

          ),
          shape: BoxShape.circle
      ),
    );
  }

  void _addPicture(BuildContext contxt){

    //Take picture from Camera
    _takePicture(contxt);

    //Pick picture from gallery
    // _pickPicture();



  }

  //Take picture from Camera
  void _takePicture(BuildContext contxt) {


    final ImagePicker imagePicker = ImagePicker();
    imagePicker.pickImage(source: ImageSource.camera)
        .then((XFile? image){
      print("image ==>> ${image?.path}");
      if(image != null){
        contxt.read<UploadImageCubit>()
            .sendImageFile(File(image.path));
      }

    })
        .catchError((error){
      print("_takePicture() ==>>> Error $error");
    });
  }

  /**
   * Pick picture from gallery
   */
  void _pickPicture(BuildContext contxt) {
    final ImagePicker imagePicker = ImagePicker();
    imagePicker.pickImage(source: ImageSource.gallery)
        .then((XFile? image){
      print("image ==>> ${image?.path}");
      if(image != null){
        contxt.read<UploadImageCubit>()
            .sendImageFile(File(image.path));
      }
    })
        .catchError((error){
      print("_pickPicture() ==>>> Error $error");
    });

  }


}
