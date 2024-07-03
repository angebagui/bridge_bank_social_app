import 'package:bridgebank_social_app/data/models/conversation.dart';
import 'package:bridgebank_social_app/data/models/message.dart';
import 'package:bridgebank_social_app/data/storage/local_storage_service.dart';
import 'package:bridgebank_social_app/rest/backend_service.dart';
import 'package:flutter/material.dart';

class MessagesProvider extends ChangeNotifier{

  final BackendService backendService;
  final LocalStorageService localStorageService;

  MessagesProvider({
    required this.backendService,
    required this.localStorageService
  });

  bool isLoadMessage = false;

  Conversation? _conversation;

  Conversation? get conversation => _conversation;
  void setConversation(Conversation conversation){
    _conversation = conversation;
    notifyListeners();
  }

  List<Message> _messages = [];

  List<Message> get messages => _messages;

  addMessage(Message message){
    messages.add(message);
    notifyListeners();
  }

  void setMessages(List<Message> list){
    _messages = list;
    notifyListeners();
  }

  void openConversation(List<int> speakers) {

    backendService.openConversation(
        speakers: speakers)
        .then((Conversation conversation){

      print("_openConversation() then =>> $conversation");
      _conversation = conversation;
      _messages = conversation.messages;
     notifyListeners();

    })
        .catchError((error){
      print("ConversationScreen._openConversation() =>>> Error $error");

    });
  }
  void loadMessagesByConversation(int conversationId) {

    print("_loadMessagesByConversation()");

    backendService.loadMessagesByConversationID(conversationId: conversationId)
        .then((List<Message> messages){
      _messages = messages;
      notifyListeners();
    }).catchError((error){
      print("ConversationScreen._loadMessagesByConversation() ==>>> Error $error");
    });

  }


}