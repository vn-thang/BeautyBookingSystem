import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_contact_info_usecase.dart';
import 'contact_support_event.dart';
import 'contact_support_state.dart';

class ContactSupportBloc
    extends Bloc<ContactSupportEvent, ContactSupportState> {
  final GetContactInfoUseCase getContactInfoUseCase;

  ContactSupportBloc(this.getContactInfoUseCase)
      : super(ContactSupportInitial()) {
    on<LoadContactInfoEvent>(_onLoadContactInfo);
  }

  Future<void> _onLoadContactInfo(
    LoadContactInfoEvent event,
    Emitter<ContactSupportState> emit,
  ) async {
    emit(ContactSupportLoading());
    try {
      final result = await getContactInfoUseCase();
      emit(ContactSupportLoaded(result));
    } catch (e) {
      emit(ContactSupportError('Không tải được thông tin hỗ trợ'));
    }
  }
}
