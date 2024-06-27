import 'dart:io';

import 'package:bridgebank_social_app/configuration/colors.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  //String? photoUrl = "https://images.unsplash.com/photo-1719066373323-c3712474b2a4?q=80&w=1587&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D";
  String? photoUrl;

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
              child: photoUrl == null?
              _buildAddPhotoUi()
                  : _buildUploadedPhotoUi(),
            )

          ],
        ),
      ),
    );
  }

  Widget _buildAddPhotoUi() {
    return Container(
        width: 140,
        height: 140,
        decoration: const BoxDecoration(
          color: Colors.black,
          shape: BoxShape.circle,
        ),
        child:  IconButton(
          onPressed: _addPicture,
          icon:const Icon(Icons.add_a_photo,
            color: Colors.white,size: 60,),
        )
    );
  }

  Widget _buildUploadedPhotoUi() {
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
                  image:FileImage(
                      File(photoUrl!)),
                )
            ),
          ),

          Align(
            alignment: Alignment.topRight,
            child: IconButton(
                onPressed:_addPicture,
                icon: const Icon(
              Icons.edit,
              color: AppColors.secondary,
            )),
          )

        ],
      ),
    );
  }

  void _addPicture(){

    //Take picture from Camera
    _takePicture();

    //Pick picture from gallery
    //_pickPicture();



  }

  //Take picture from Camera
  void _takePicture() {

    final ImagePicker imagePicker = ImagePicker();
    imagePicker.pickImage(source: ImageSource.camera)
    .then((XFile? image){
      print("image ==>> ${image?.path}");
      if(image != null){
        photoUrl = image.path;
        setState(() {

        });
      }

    })
    .catchError((error){
      print("_takePicture() ==>>> Error $error");
    });


  }

  /**
   * Pick picture from gallery
   */
  void _pickPicture() {

  }
}
