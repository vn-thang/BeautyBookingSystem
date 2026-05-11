import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_customer/core/location/location_service.dart';
import 'package:mobile_customer/features/chat/data/datasources/chat_remote_data_source.dart';
import 'package:mobile_customer/features/chat/data/models/send_chat_request_model.dart';

import 'chat_event.dart';
import 'chat_state.dart';
import '../../domain/entities/chat_message.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRemoteDataSource remoteDataSource;
  final LocationService locationService;

  ChatBloc(
    this.remoteDataSource,
    this.locationService,
  ) : super(ChatState.initial()) {
    on<ChatStarted>(_onStarted);
    on<ChatSendPressed>(_onSendPressed);
  }

  Future<void> _onStarted(
    ChatStarted event,
    Emitter<ChatState> emit,
  ) async {
    emit(state.copyWith(
      isLoading: true,
      sessionKey: event.sessionKey,
      error: null,
    ));

    try {
      final location = await locationService.getCurrentLocation();
      final lat = location?.latitude;
      final lon = location?.longitude;

      if (event.sessionKey != null && event.sessionKey!.isNotEmpty) {
        final history = await remoteDataSource.getHistory(event.sessionKey!);
        emit(state.copyWith(
          messages: history,
          lat: lat,
          lon: lon,
          isLoading: false,
        ));
      } else {
        emit(state.copyWith(
          messages: [],
          lat: lat,
          lon: lon,
          isLoading: false,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
       error: _mapError(e),
      ));
    }
  }

  Future<void> _onSendPressed(
    ChatSendPressed event,
    Emitter<ChatState> emit,
  ) async {
    final text = event.message.trim();
    if (text.isEmpty) return;
    if (state.isSending) return;

    final userMessage = ChatMessage(
      role: ChatRole.user,
      content: text,
      createdAt: DateTime.now(),
    );

    emit(state.copyWith(
      messages: [...state.messages, userMessage],
      isSending: true,
      error: null,
    ));

    try {
      double? lat = state.lat;
      double? lon = state.lon;

      if (lat == null || lon == null) {
        final location = await locationService.getCurrentLocation();
        lat = location?.latitude;
        lon = location?.longitude;
      }

      final response = await remoteDataSource.sendMessage(
        SendChatRequestModel(
          sessionKey: state.sessionKey,
          message: text,
          userLat: lat,
          userLng: lon,
        ),
      );

      final assistantMessage = ChatMessage(
        role: ChatRole.assistant,
        content: response.reply,
        createdAt: DateTime.now(),
      );

      emit(state.copyWith(
        sessionKey: response.sessionKey,
        messages: [...state.messages, assistantMessage],
        isSending: false,
        lat: lat,
        lon: lon,
      ));
    } catch (e) {
      emit(state.copyWith(
        isSending: false,
       error: _mapError(e),
      ));
    }
  }
}
String _mapError(Object e) {
  final error = e.toString().toLowerCase();

  if (error.contains('503') || error.contains('unavailable')) {
    return 'Hệ thống AI đang bận, vui lòng thử lại sau.';
  }

  if (error.contains('429') || error.contains('quota')) {
    return 'Hệ thống đang quá tải, bạn thử lại sau ít phút nhé.';
  }

  if (error.contains('500')) {
    return 'Hệ thống đang gặp sự cố, vui lòng thử lại sau.';
  }

  if (error.contains('timeout')) {
    return 'Kết nối chậm, vui lòng thử lại.';
  }

  return 'Đã có lỗi xảy ra, vui lòng thử lại sau.';
}
