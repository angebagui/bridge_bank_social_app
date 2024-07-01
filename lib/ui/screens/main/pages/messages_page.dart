import 'dart:async';
import 'dart:io';

import 'package:bridgebank_social_app/app_setup.dart';
import 'package:bridgebank_social_app/data/models/conversation.dart';
import 'package:bridgebank_social_app/providers/conversations_provider.dart';
import 'package:bridgebank_social_app/rest/exception/auth/auth_exception.dart';
import 'package:bridgebank_social_app/ui/screens/main/conversation/conversation_screen.dart';
import 'package:bridgebank_social_app/ui/widgets/conversation_item_widget.dart';
import 'package:bridgebank_social_app/ui/widgets/progress_ui.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';

class MessagesPage extends StatefulWidget {

  const MessagesPage({super.key});

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {


  @override
  void initState() {
    ProgressUtils.init();
    super.initState();


    Provider
        .of<ConversationsProvider>(context, listen: false)
        .loadData(context);

  }

  @override
  Widget build(BuildContext context) {


    return Consumer<ConversationsProvider>(
      builder: (ctxt, conversationProvider, _){

        print("Consumer => ConversationsProvider");

        return conversationProvider.isLoading? ProgressUi():ListView(
            children: conversationProvider.conversations.map<Widget>((conversation)=>
                ConversationItemWidget(
                  conversation: conversation,
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context)=> ConversationScreen(
                        conversation: conversation)));
                  },

                )).toList()
        );
      },
    );
  }


}
