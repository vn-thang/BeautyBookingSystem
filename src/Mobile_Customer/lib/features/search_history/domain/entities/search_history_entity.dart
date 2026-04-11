import 'package:equatable/equatable.dart';

class SearchHistoryEntity extends Equatable {
  final int id;
  final String keyword;

  const SearchHistoryEntity({
    required this.id,
    required this.keyword,
  });

  @override
  List<Object?> get props => [id, keyword];
}
