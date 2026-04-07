import '../../domain/entities/search_history_entity.dart';

class SearchHistoryModel extends SearchHistoryEntity {
  const SearchHistoryModel({
    required super.id,
    required super.keyword,
  });

  factory SearchHistoryModel.fromJson(Map<String, dynamic> json) {
    return SearchHistoryModel(
      id: json['id'] as int,
      keyword: json['keyword'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'keyword': keyword,
    };
  }
}
