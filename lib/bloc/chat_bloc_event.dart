part of 'chat_bloc_bloc.dart';

@immutable
sealed class ChatEvent {}

class ChatGenerateNewTextMessageEvent extends ChatEvent {
  final String inputMessage;
  ChatGenerateNewTextMessageEvent({
    required this.inputMessage,
  });
}