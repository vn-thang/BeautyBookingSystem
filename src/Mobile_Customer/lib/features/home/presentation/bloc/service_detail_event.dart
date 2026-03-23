abstract class ServiceDetailEvent {}

class FetchServiceDetail extends ServiceDetailEvent {
  final int id;
  FetchServiceDetail(this.id);
}