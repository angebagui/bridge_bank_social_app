import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bridgebank_social_app/rest/upload/upload_image_service.dart';

sealed class UploadImageState{}

//When we don't have photoUrl
class NotUploadedImageState extends UploadImageState{}

//When we have progressbar
class ProgressBarState extends UploadImageState{}

//When we have our link
class UploadedImageState extends UploadImageState{
  final String url;
  UploadedImageState(this.url);
}

class UploadErrorState extends UploadImageState{
  final Exception exception;
  UploadErrorState(this.exception);
}

class UploadImageCubit extends Cubit<UploadImageState>{

  final UploadImageService uploadImageService;

  UploadImageCubit({
    required this.uploadImageService
  }):super(NotUploadedImageState());


  /**
   * Send File to Upload Service
   */
  sendImageFile(File file) {

    emit(ProgressBarState());

    print("Upload image");
    uploadImageService.uploadImage(file).then((String url) {
      print("Response =>> $url");

      emit(UploadedImageState(url));

    }).catchError((error) {

      print("uploadImage() error => $error");

      emit(UploadErrorState(error));

    });
  }


}