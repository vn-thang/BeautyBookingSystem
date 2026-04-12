import '../../domain/entities/contact_info.dart';

abstract class ContactSupportState {}

class ContactSupportInitial extends ContactSupportState {}

class ContactSupportLoading extends ContactSupportState {}

class ContactSupportLoaded extends ContactSupportState {
  final ContactInfo contactInfo;

  ContactSupportLoaded(this.contactInfo);
}

class ContactSupportError extends ContactSupportState {
  final String message;

  ContactSupportError(this.message);
}
