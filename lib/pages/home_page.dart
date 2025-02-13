import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gemini_ai/bloc/chat_bloc_bloc.dart';
import 'package:gemini_ai/models/chat_message_model.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter/services.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ChatBlocBloc chatBlocBloc = ChatBlocBloc();
  TextEditingController textEditingController = TextEditingController();

  void _showUnderProcessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey.shade900,
        title: const Text('Feature Coming Soon', style: TextStyle(color: Colors.white)),
        content: const Text('Image processing feature is under development.', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }

  String capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  String formatBoldText(String text) {
    // Format headings
    text = text.replaceAllMapped(
      RegExp(r'#\s+(.*?)(?=\n|$)'),
      (match) => '\n**${match.group(1)}**\n',
    );

    // Format subheadings
    text = text.replaceAllMapped(
      RegExp(r'##\s+(.*?)(?=\n|$)'),
      (match) => '\n**${match.group(1)}**\n',
    );

    // Format bullet points
    text = text.replaceAllMapped(
      RegExp(r'•\s+(.*?)(?=\n|$)'),
      (match) => '\n  • ${match.group(1)}\n',
    );

    // Format numbered lists
    text = text.replaceAllMapped(
      RegExp(r'(\d+)\.\s+(.*?)(?=\n|$)'),
      (match) => '\n${match.group(1)}. ${match.group(2)}\n',
    );

    // Format bold text
    return text.replaceAllMapped(
      RegExp(r'\*\*(.*?)\*\*'),
      (match) => match.group(1) ?? '',
    );
  }

  Widget _buildMessage(String messageText, bool isUser) {
    final bool containsCode = messageText.contains('```');
    final List<String> parts = messageText.split('```');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: parts.map((part) {
        if (containsCode && parts.indexOf(part) % 2 == 1) {
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade800,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: SelectableText(
                    part,
                    style: const TextStyle(
                      fontFamily: 'Courier',
                      color: Colors.white,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy, color: Colors.white),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: part));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Code copied to clipboard')),
                    );
                  },
                ),
              ],
            ),
          );
        } else {
          return Text(
            part,
            style: TextStyle(
              height: 1.5,
              fontSize: 15,
              color: Colors.white,
              fontWeight: !isUser && (part.contains("**") || part.trim().startsWith('#') || part.trim().startsWith('##'))
                  ? FontWeight.bold 
                  : FontWeight.normal,
              letterSpacing: !isUser && (part.trim().startsWith('#') || part.trim().startsWith('##')) ? 0.5 : 0,
            ),
          );
        }
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<ChatBlocBloc, ChatBlocState>(
        bloc: chatBlocBloc,
        listener: (context, state) {},
        builder: (context, state) {
          switch (state.runtimeType) {
            case const (ChatSuccessState):
              List<ChatMessageModel> messages =
                  (state as ChatSuccessState).messages;

              return Container(
                width: double.maxFinite,
                height: double.maxFinite,
                decoration: const BoxDecoration(
                    image: DecorationImage(
                        opacity: 0.2,
                        image: AssetImage("assets/av.jpg"),
                        fit: BoxFit.cover)),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        border: Border(
                          bottom: BorderSide(color: Colors.grey.shade800, width: 0.5),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.smart_toy_rounded, 
                                color: Colors.blue.shade400, 
                                size: 32
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                "JARVIS AI",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 28,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            onPressed: _showUnderProcessDialog,
                            icon: const Icon(
                              Icons.image_search_rounded,
                              size: 28,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final bool isUser = messages[index].role == "user";
                          final String messageText = isUser 
                              ? capitalizeFirstLetter(messages[index].parts.first.text)
                              : formatBoldText(messages[index].parts.first.text);
                          
                          return Container(
                            margin: EdgeInsets.only(
                              bottom: 16,
                              left: 16,
                              right: 16,
                              top: index == 0 ? 8 : 0,
                            ),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: isUser
                                  ? Colors.blue.withOpacity(0.15)
                                  : Colors.white.withOpacity(0.1),
                              border: Border.all(
                                color: isUser 
                                  ? Colors.blue.withOpacity(0.3)
                                  : Colors.white.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      isUser ? Icons.person : Icons.smart_toy_rounded,
                                      size: 20,
                                      color: isUser ? Colors.amber : Colors.blue,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      isUser ? "You" : "JARVIS AI",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: isUser ? Colors.amber : Colors.blue,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                _buildMessage(messageText, isUser),
                              ],
                            )
                          );
                        }
                      )
                    ),
                    if (chatBlocBloc.generating)
                      Container(
                        height: 120,
                        width: 120,
                        padding: const EdgeInsets.all(16),
                        child: Lottie.asset(
                          'assets/ai.json',
                          fit: BoxFit.contain,
                        )
                      ),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        border: Border(
                          top: BorderSide(color: Colors.grey.shade800, width: 0.5),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: textEditingController,
                              style: const TextStyle(color: Colors.white),
                              cursorColor: Colors.blue,
                              textCapitalization: TextCapitalization.sentences,
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: BorderSide.none,
                                ),
                                fillColor: Colors.grey.shade900,
                                hintText: "Message JARVIS AI...",
                                hintStyle: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 16,
                                ),
                                filled: true,
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: const BorderSide(
                                    color: Colors.blue,
                                    width: 1.5,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Material(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(25),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(25),
                              onTap: () {
                                if (textEditingController.text.isNotEmpty) {
                                  String text = textEditingController.text;
                                  textEditingController.clear();
                                  chatBlocBloc.add(
                                    ChatGenerateNewTextMessageEvent(
                                      inputMessage: capitalizeFirstLetter(text)
                                    )
                                  );
                                }
                              },
                              child: Container(
                                height: 50,
                                width: 50,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: const Icon(
                                  Icons.send_rounded,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              );

            default:
              return const Center(
                child: CircularProgressIndicator(
                  color: Colors.blue,
                ),
              );
          }
        },
      ),
    );
  }
}
