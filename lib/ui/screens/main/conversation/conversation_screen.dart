import 'package:bridgebank_social_app/app_setup.dart';
import 'package:bridgebank_social_app/configuration/constants.dart';
import 'package:bridgebank_social_app/data/models/conversation.dart';
import 'package:bridgebank_social_app/data/models/message.dart';
import 'package:bridgebank_social_app/data/models/user.dart';
import 'package:bridgebank_social_app/main.dart';
import 'package:bridgebank_social_app/providers/messages_provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ConversationScreen extends StatefulWidget {

  final Conversation conversation;
  const ConversationScreen({
    super.key,
    required this.conversation});

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();

}

class _ConversationScreenState extends State<ConversationScreen> {

  final TextEditingController _messageController = TextEditingController();

  late Conversation _conversation;

  @override
  void initState() {
    //Implement initState
    _conversation = widget.conversation;
    super.initState();

    final MessagesProvider messagesProvider = Provider
        .of<MessagesProvider>(context, listen: false);

    messagesProvider
    .addListener((){
      if(Provider.of<MessagesProvider>(context, listen: false)
          .conversation != null){
        _conversation = Provider
            .of<MessagesProvider>(context, listen: false)
            .conversation!;
      }


    });

    Provider.of<MessagesProvider>(context, listen: false)
        .setConversation(_conversation);

    Provider.of<MessagesProvider>(context, listen: false)
    .setMessages(_conversation.messages);

    Provider.of<MessagesProvider>(context, listen: false)
        .openConversation(widget.conversation.speakers);

    //Foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
          //flutterLocalNotificationsPlugin.cancel(message.messageId.hashCode);

          if(_conversation.id != null){
            Provider.of<MessagesProvider>(context, listen:false)
                .loadMessagesByConversation(_conversation.id!);
          }


      }

    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 12.w,
              height: 12.h,
              margin: EdgeInsets.only(top: 5, bottom: 5),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle
              ),
            ),

            SizedBox(width: 10,),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("${_conversation.senderName(
                  AppSetup.localStorageService.connectedUser()!.user!
                )}", style: TextStyle(
                  fontWeight: FontWeight.normal,
                  fontSize: 18
                ),),
                Text(_conversation.isConnected()?"Online":"Offline", style: TextStyle(
                    fontWeight: FontWeight.normal,
                  fontSize: 16
                ),),
                SizedBox(height: 5,),
              ],
            )

          ],
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 4.w),
            child:  GestureDetector(
              onTap: (){
                print("object");
              },
              child: Image.asset("${Constants.imagesDirectory}/menu.png",
                color: Colors.white,
                height: 2.h,
              ),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Theme.of(context).colorScheme.primary,
            height: 20,
          ),
         Expanded(
           child: SingleChildScrollView(
             reverse: true,
             child:  _buildMessagesUi(),
           ),
         ),
          _buildMessageBox(),
        ],
      ),
    );
  }
  Widget _buildMessagesUi(){
    return Consumer<MessagesProvider>(
      builder: (ctxt, messagesProvider, _){
        return Column(
            children: messagesProvider.messages.map<Widget>((message)=>
            message.senderId == AppSetup.localStorageService.connectedUser()!.user!.id?
            _buildSenderUi(message):_buildReceiverUi(message)
            ).toList()
        );
      },
    );
  }

  Widget _buildReceiverUi(Message message) {
    return Container(
      margin: EdgeInsets.only(right: 40),
      padding: const EdgeInsets.only(
          top: 8.0, right: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 50,
              height: 50,
              margin: EdgeInsets.only(left: 10),
              decoration: BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle
              ),
            ),
            SizedBox(width: 2.h,),
            Container(
              width: MediaQuery.of(context).size.width - 140,
              padding: EdgeInsets.only(
                  left: 20,
                  right: 20
              ),
              decoration: BoxDecoration(
                  color: Color(0xFFE2E2E4),
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(15),
                    bottomRight: Radius.circular(15),
                    bottomLeft: Radius.circular(15),
                  )
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: Padding(
                        padding: EdgeInsets.only(
                            top: 10,
                            bottom: 20
                        ),
                        child:Text("${message.content}")
                    ),
                  ),
                  Padding(
                    padding:  EdgeInsets.only(top: 15.0,
                        left: 10,
                        bottom: 10),
                    child: Text("${DateFormat("Hm").format(
                        message.createdAt!)}", style: TextStyle(
                        color: Color(0xFF9F9F9F)
                    ),),
                  ),
                ],
              ),
            )
          ],
      ),
    );
  }

  Widget _buildSenderUi(Message message) {
    return Container(
      padding: EdgeInsets.only(
          left: 5,
          top: 18,right: 18),
      margin: EdgeInsets.only(
        left: 100, top: 10,
        right: 10
      ),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15),
          bottomLeft: Radius.circular(15),
          bottomRight: Radius.circular(15),
        )
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          message.contentType== MessageContentType.text.name?
          Text("${message.content}", style: TextStyle(
            color: Colors.white
          ),):SizedBox(),
          message.contentType== MessageContentType.image?
          Image.network("${message.content}", height: 200,):SizedBox(),
          Padding(
            padding:  EdgeInsets.only(top: 15.0,
                left: 10,
                bottom: 10),
            child: Text("${DateFormat("Hm").format(
                message.createdAt!)}", style: TextStyle(
                color: Color(0xFF9F9F9F)
            ),),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBox() {
    return  Container(
      height: 100,
      decoration: BoxDecoration(
        //color: Colors.red,
      ),
      child: Column(
        children: [
          Divider(
            color: Colors.grey,
          ),
          TextField(
            controller: _messageController,
            decoration: InputDecoration(
              prefixIcon: IconButton(
                onPressed: (){

                },
                icon: Icon(Icons.add, size: 30,),
              ),
              border: InputBorder.none,
              hintText: "Write a message",
              suffixIcon: IconButton(
                onPressed: (){
                  _submitMessage(
                      AppSetup.localStorageService.connectedUser()!.user!,
                      _conversation);
                },
                icon: Icon(Icons.send),
              )
            ),
          )
        ],
      ),
    );
  }



  void _submitMessage(User user, Conversation conversation) {

    final String message = _messageController.text;
    if(message.isEmpty){
      return;
    }

    if(conversation.id == null){
      return;
    }

    AppSetup.backendService.sendMessage(
        content: message,
        contentType: MessageContentType.text.name,
        senderId: user.id!,
        conversationId: conversation.id!)
    .then((Message message){
      _messageController.clear();

      Provider.of<MessagesProvider>(context,listen: false)
          .addMessage(message);

      Provider.of<MessagesProvider>(context, listen: false)
          .loadMessagesByConversation(_conversation.id!);


    }).catchError((error){
      print("ConversationScreen._submitMessage() ==>>> Error $error");
    });


  }


}
