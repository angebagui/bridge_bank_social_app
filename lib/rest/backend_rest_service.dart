import 'dart:convert';
import 'dart:io';

import 'package:bridgebank_social_app/app_setup.dart';
import 'package:bridgebank_social_app/data/models/conversation.dart';
import 'package:bridgebank_social_app/data/models/message.dart';
import 'package:bridgebank_social_app/data/models/session.dart';
import 'package:bridgebank_social_app/data/models/user.dart';
import 'package:bridgebank_social_app/data/storage/local_storage_service.dart';
import 'package:bridgebank_social_app/rest/backend_service.dart';
import 'package:bridgebank_social_app/rest/exception/auth/auth_exception.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart';

class BackendRestService extends BackendService{

  static final String BASE_URL = "https://api-socialapp.adjemincloud.com";
  static final String API_URL = "$BASE_URL/api/v1";

  @override
  Future<Session> signIn({
    required String email,
    required String password})async {

    final Uri url = Uri.parse("$API_URL/user_auth");
    final Response response = await post(url,
        body:<String, String>{
          "email":email,
          "password":password
        }
    );

    if(response.statusCode == 200){

      final Map<String, dynamic> json = jsonDecode(response.body);

      if(json.containsKey('success') && json['success'] == true
      && json.containsKey("data") && json['data'] != null
      ){
        final Map<String, dynamic> jsonData = json['data'];
        return Session.fromJson(jsonData);
      }
      throw Exception(response.body);

    }else if(response.statusCode == 401 && response.headers['content-type']=="application/json"){
      final Map<String, dynamic> json = jsonDecode(response.body);
        final String message =
        json.containsKey("message")?json['message']:"Unauthoried";
      throw AuthException(message);
    }else{
      throw Exception(response.body);
    }


  }

  @override
  Future<Session> signUp({
    required String firstName,
    required String lastName,
    required String email,
    required String password})async {
    
    final Uri url = Uri.parse("$API_URL/user_register");

    final Response response = await post(url,
        body:<String, String>{
          "email":email,
          "password":password,
          "first_name":firstName,
          "last_name":lastName
        }
    );

    if(response.statusCode == 200 || response.statusCode == 201){

      final Map<String, dynamic> json = jsonDecode(response.body);

      if(json.containsKey('success') && json['success'] == true
          && json.containsKey("data") && json['data'] != null
      ){
        final Map<String, dynamic> jsonData = json['data'];
        return Session.fromJson(jsonData);
      }
      throw Exception(response.body);

    }else if(response.statusCode == 401 && response.headers['content-type']=="application/json"){
      final Map<String, dynamic> json = jsonDecode(response.body);
      final String message =
      json.containsKey("message")?json['message']:"Unauthoried";
      throw AuthException(message);
    }else if(response.statusCode == 400){
      final Map<String, dynamic> json = jsonDecode(response.body);
      final String message =
      json.containsKey("message")?json['message']:"Bad request";
      throw ArgumentError(message);
    }else{
      throw Exception(response.body);
    }
  }

  @override
  Future<Conversation> openConversation({
    required List<int> speakers,
    bool isGroup = false,
    String groupName = "",
    List<int>? admins}) async{
    final Uri url = Uri.parse("$API_URL/open_conversation");
    //Get Access Token
    final Session? session = AppSetup.localStorageService.connectedUser();
    //final Session session = await signIn(email: "angebagui@adjemin.com", password: "123456789");
    final String? token = session?.authorization?.token;
    print("Authorization: Bearer $token");

    final Response response = await post(url,
    body: jsonEncode({
      "speakers": speakers,
      "is_group":isGroup,
      "group_name":groupName,
      "admins":admins??[]
    }), headers: {
          "Accept":"application/json",
          "Content-Type":"application/json",
          "Authorization":"Bearer $token"
        });

    if(response.statusCode == 200){
      final Map<String, dynamic>? json = jsonDecode(response.body);

      if(json == null){
        throw Exception(response.body);
      }

      if(json.containsKey("success") && json['success'] == true && json['data'] != null){
        final Map<String, dynamic> jsonData = json['data'];
        return Conversation.fromJson(jsonData);
      }

      throw Exception(response.body);

    }else if(response.statusCode >=400 && response.statusCode <500){
      if(response.headers['content-type'] == "application/json"){
        final Map<String, dynamic> json = jsonDecode(response.body);

        if(json.containsKey("message") && json['message'] != null){
          if(json['message'].isEmpty){
            throw ArgumentError("Bad request");
          }else{
            if(response.statusCode == 401){
              throw AuthException(json['message']);
            }else{
              throw ArgumentError(json['message']);
            }
          
          }

        }
      }

      throw Exception(response.body);

    }else{
      throw Exception(response.body);
    }
  }

  @override
  Future<Message> sendMessage({
    required String content,
    required String contentType,
    required int senderId,
    required int conversationId})async {
    final Uri url = Uri.parse("$API_URL/messages");

    //Get Access Token
    final Session? session = AppSetup.localStorageService.connectedUser();
    //final Session session = await signIn(email: "angebagui@adjemin.com", password: "123456789");
    final String? token = session?.authorization?.token;
    print("Authorization: Bearer $token");

    final Response response = await post(url,
        body: {
          "content": content,
          "content_type":contentType,
          "sender_id":"$senderId",
          "conversation_id":"$conversationId"
        }, headers: {
          HttpHeaders.acceptHeader:"application/json",
          HttpHeaders.authorizationHeader:"Bearer $token"
        });

    if(response.statusCode == 200){
      final Map<String, dynamic>? json = jsonDecode(response.body);

      if(json == null){
        throw Exception(response.body);
      }

      if(json.containsKey("success") && json['success'] == true && json['data'] != null){
        final Map<String, dynamic> jsonData = json['data'];
        return Message.fromJson(jsonData);
      }

      throw Exception(response.body);

    }else if(response.statusCode >=400 && response.statusCode <500){
      if(response.headers['content-type'] == "application/json"){
        final Map<String, dynamic> json = jsonDecode(response.body);

        if(json.containsKey("message") && json['message'] != null){
          if(json['message'].isEmpty){
            throw ArgumentError("Bad request");
          }else{
            if(response.statusCode == 401){
              throw AuthException(json['message']);
            }else{
              throw ArgumentError(json['message']);
            }

          }

        }
      }

      throw Exception(response.body);

    }else{
      throw Exception(response.body);
    }
  }

  @override
  Future<List<User>> loadContacts({int? meId}) async{
    final Uri url = Uri.parse("$API_URL/contacts/$meId");

    //Get Access Token
    final Session? session = AppSetup.localStorageService.connectedUser();
    //final Session session = await signIn(email: "angebagui@adjemin.com", password: "123456789");
    final String? token = session?.authorization?.token;
    print("loadContacts Authorization: Bearer $token");

    final Response response = await get(url, headers: {
          HttpHeaders.acceptHeader:"application/json",
          HttpHeaders.authorizationHeader:"Bearer $token"
        });

    if(response.statusCode == 200){
      final Map<String, dynamic>? json = jsonDecode(response.body);

      if(json == null){
        throw Exception(response.body);
      }

      if(json.containsKey("success") && json['success'] == true && json['data'] != null){
        final List jsonData = json['data'];
        return jsonData.map((e)=> User.fromJson(e)).toList();
      }

      throw Exception(response.body);

    }else if(response.statusCode >=400 && response.statusCode <500){
      if(response.headers['content-type'] == "application/json"){
        final Map<String, dynamic> json = jsonDecode(response.body);

        if(json.containsKey("message") && json['message'] != null){
          if(json['message'].isEmpty){
            throw ArgumentError("Bad request");
          }else{
            if(response.statusCode == 401){
              throw AuthException(json['message']);
            }else{
              throw ArgumentError(json['message']);
            }

          }

        }
      }

      throw Exception(response.body);

    }else{
      throw Exception(response.body);
    }
  }

  @override
  Future<List<Message>> loadMessagesByConversationID({required int conversationId})async {
    final Uri url = Uri.parse("$API_URL/conversations/messages/$conversationId");

    //Get Access Token
    final Session? session = AppSetup.localStorageService.connectedUser();
    //final Session session = await signIn(email: "angebagui@adjemin.com", password: "123456789");
    final String? token = session?.authorization?.token;
    //print("Authorization: Bearer $token");

    final Response response = await get(url, headers: {
      HttpHeaders.acceptHeader:"application/json",
      HttpHeaders.authorizationHeader:"Bearer $token"
    });

    if(response.statusCode == 200){
      final Map<String, dynamic>? json = jsonDecode(response.body);

      if(json == null){
        throw Exception(response.body);
      }

      if(json.containsKey("success") && json['success'] == true && json['data'] != null){
        final List<dynamic> jsonData = json['data'];
        return jsonData.map<Message>((e)=> Message.fromJson(e)).toList();
      }

      throw Exception(response.body);

    }else if(response.statusCode >=400 && response.statusCode <500){
      if(response.headers['content-type'] == "application/json"){
        final Map<String, dynamic> json = jsonDecode(response.body);

        if(json.containsKey("message") && json['message'] != null){
          if(json['message'].isEmpty){
            throw ArgumentError("Bad request");
          }else{
            if(response.statusCode == 401){
              throw AuthException(json['message']);
            }else{
              throw ArgumentError(json['message']);
            }

          }

        }
      }

      throw Exception(response.body);

    }else{
      throw Exception(response.body);
    }
  }

  @override
  Future<List<Conversation>> loadMyConversations({int? meId})async {

    //Get Access Token
    final Session? session = AppSetup.localStorageService.connectedUser();
    //final Session session = await signIn(email: "angebagui@adjemin.com", password: "123456789");
    final Uri url = Uri.parse("$API_URL/conversations/customers/${meId??session?.user?.id}");

    final String? token = session?.authorization?.token;
    //print("Authorization: Bearer $token");

    final Response response = await get(url, headers: {
      HttpHeaders.acceptHeader:"application/json",
      HttpHeaders.authorizationHeader:"Bearer $token"
    });

    if(response.statusCode == 200){
      final Map<String, dynamic>? json = jsonDecode(response.body);

      if(json == null){
        throw Exception(response.body);
      }

      if(json.containsKey("success") && json['success'] == true && json['data'] != null){
        final List<dynamic> jsonData = json['data'];
        return jsonData.map<Conversation>((e)=> Conversation.fromJson(e)).toList();
      }

      throw Exception(response.body);

    }else if(response.statusCode >=400 && response.statusCode <500){
      if(response.headers['content-type'] == "application/json"){
        final Map<String, dynamic> json = jsonDecode(response.body);

        if(json.containsKey("message") && json['message'] != null){
          if(json['message'].isEmpty){
            throw ArgumentError("Bad request");
          }else{
            if(response.statusCode == 401){
              throw AuthException(json['message']);
            }else{
              throw ArgumentError(json['message']);
            }

          }

        }
      }

      throw Exception(response.body);

    }else{
      throw Exception(response.body);
    }
  }


  @override
  Future<Session> refreshToken({Session? session}) async {
    final Uri url = Uri.parse("$API_URL/refresh_token");

    // Get Access Token
    final Session? _session = session ?? AppSetup.localStorageService.connectedUser();
    final String? token = _session?.authorization?.token;

    final Response response = await post(
      url,
      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic>? json = jsonDecode(response.body);

      if (json == null) {
        throw Exception('Failed to parse response body');
      }

      if (json.containsKey("data") && json['data'] != null) {
        final Map<String, dynamic> data = json['data'];
        return Session.fromJson(data);
      }

      throw Exception('Unexpected response format: ${response.body}');

    } else if (response.statusCode >= 400 && response.statusCode < 500) {
      if (response.headers['content-type']?.contains('application/json') == true) {
        final Map<String, dynamic> json = jsonDecode(response.body);

        if (json.containsKey("message") && json['message'] != null) {
          if (json['message'].isEmpty) {
            throw ArgumentError("Bad request");
          } else {
            if (response.statusCode == 401) {
              throw AuthException(json['message']);
            } else {
              throw ArgumentError(json['message']);
            }
          }
        }
      }
      throw Exception('Client error: ${response.body}');
    } else {
      throw Exception('Server error: ${response.body}');
    }
  }

  @override
  Future<bool> signOut({Session? session}) async {
    final Uri url = Uri.parse("$API_URL/user_logout");

    // Get Access Token
    final Session? _session = session ?? AppSetup.localStorageService.connectedUser();
    final String? token = _session?.authorization?.token;

    final Response response = await post(
      url,
      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic>? json = jsonDecode(response.body);

      if (json == null) {
        throw Exception('Failed to parse response body');
      }

      if (json.containsKey("success") && json['success'] == true) {

        return true;
      }

      throw Exception('Unexpected response format: ${response.body}');

    } else if (response.statusCode >= 400 && response.statusCode < 500) {
      if (response.headers['content-type']?.contains('application/json') == true) {
        final Map<String, dynamic> json = jsonDecode(response.body);

        if (json.containsKey("message") && json['message'] != null) {
          if (json['message'].isEmpty) {
            throw ArgumentError("Bad request");
          } else {
            if (response.statusCode == 401) {
              throw AuthException(json['message']);
            } else {
              throw ArgumentError(json['message']);
            }
          }
        }
      }
      throw Exception('Client error: ${response.body}');
    } else {
      throw Exception('Server error: ${response.body}');
    }
  }

  @override
  Future<bool> storeDevice({
    required String firebaseId,
    String? deviceOS,
    String? deviceOSVersion,
    String? deviceBrand,
    String? deviceBrandModel,
    double? deviceWidth,
    double?deviceHeight}) {
    // TODO: implement storeDevice
    throw UnimplementedError();

  }


}