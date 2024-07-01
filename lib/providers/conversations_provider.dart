import 'dart:io';

import 'package:bridgebank_social_app/app_setup.dart';
import 'package:bridgebank_social_app/data/models/conversation.dart';
import 'package:bridgebank_social_app/data/storage/local_storage_service.dart';
import 'package:bridgebank_social_app/rest/backend_service.dart';
import 'package:bridgebank_social_app/rest/exception/auth/auth_exception.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

class ConversationsProvider extends ChangeNotifier{

  BackendService backendService;
  LocalStorageService storageService;

  ConversationsProvider(this.backendService, this.storageService);

  bool isLoading = false;

  List<Conversation> _conversations = [];

  List<Conversation> get conversations => _conversations;
  void setConversations(List<Conversation> list){
    _conversations = list;
    notifyListeners();
  }

  void loadData(BuildContext context) {

    print("ConversationsProvider.loadData");

    //Show Loading()
    isLoading = true;
    //Load Conversations
    backendService.loadMyConversations(meId:
    storageService
        .connectedUser()
        ?.user
        ?.id
    ).then((List<Conversation> value) {
      isLoading = false;
      _conversations = value;
      print("ConversationsProvider.loadData notifyListeners()");
      notifyListeners();
    })
        .catchError((error) {
      //Hide Loading ()

      isLoading = false;
      notifyListeners();

      print("MessagesPage.loadData() Error $error");

      if (error is AuthException) {
        AppSetup.logout(context: context, onStartLoading: () {

        }, onCompleteLoading: () {

        });
      } else if (error is SocketException || error is ClientException) {
        AppSetup.toastLong(
            "S'il vous plâit, veuillez vérifier votre connexion internet");
      } else if (error is ArgumentError) {

      } else if (error is Exception) {

      } else {
        AppSetup.toastLong(error.message);
      }
    });
  }
}
