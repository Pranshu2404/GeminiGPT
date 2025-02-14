part of 'chat_bloc_bloc.dart';

@immutable
sealed class ChatBlocState {}

class ChatSuccessState extends ChatBlocState {
  final List<ChatMessageModel> messages;
  ChatSuccessState({
    required this.messages,
  });
}