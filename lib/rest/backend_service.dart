import 'package:bridgebank_social_app/data/models/conversation.dart';
import 'package:bridgebank_social_app/data/models/message.dart';
import 'package:bridgebank_social_app/data/models/session.dart';
import 'package:bridgebank_social_app/data/models/user.dart';

abstract class BackendService{

  Future<Session> signIn({required String email, required String password});

  Future<bool> signOut({Session? session});

  Future<Session> refreshToken({Session? session});

  Future<Session> signUp({
    required String firstName,
    required String lastName,
    required String email,
    required String password});


  Future<Conversation> openConversation({
        required  List<int> speakers,
        bool isGroup = false,
        String groupName = "",
        List<int>? admins
      });

  Future<Message>  sendMessage({
    required String content,
    required String contentType, //text, audio, image
    required int senderId,
    required int conversationId
  });

  //Load Conversations by Customer ID https://api-socialapp.adjemincloud.com/api/v1/conversations/customers/1
  Future<List<Conversation>>  loadMyConversations({int? meId});

  //Load Messages by Conversation ID https://api-socialapp.adjemincloud.com/api/v1/conversations/messages/2
  Future<List<Message>>  loadMessagesByConversationID({
    required int conversationId
  });

  //Load Contacts https://api-socialapp.adjemincloud.com/api/v1/contacts/1
  Future<List<User>>  loadContacts({int? meId});

  Future<bool> storeDevice(
      {
        required String firebaseId,
        String? deviceOS,
        String? deviceOSVersion,
        String? deviceBrand,
        String? deviceBrandModel,
        double? deviceWidth,
        double? deviceHeight
        }
      );



}