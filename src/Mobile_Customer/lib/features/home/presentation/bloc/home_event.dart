import 'home_bloc.dart';

abstract class HomeEvent {}

class LoadHomeEvent extends HomeEvent {
    final bool forceRefresh;
    
    LoadHomeEvent({this.forceRefresh = false});
}