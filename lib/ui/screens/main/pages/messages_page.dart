
import 'package:bridgebank_social_app/providers/conversations_provider.dart';
import 'package:bridgebank_social_app/ui/screens/main/conversation/conversation_screen.dart';
import 'package:bridgebank_social_app/ui/widgets/conversation_item_widget.dart';
import 'package:bridgebank_social_app/ui/widgets/progress_ui.dart';
import 'package:flutter/material.dart';
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

    if(mounted){
      Provider
          .of<ConversationsProvider>(
          context,
          listen: false)
          .loadData(context);
    }


  }

  @override
  Widget build(BuildContext context) {

    //Bloc ou Cubit => BlocBuilder

    //Provider => Consumer

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
