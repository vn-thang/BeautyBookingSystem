class BankModel {
  final int id;
  final String name; 
  final String code; 
  final String bin;  
  final String shortName; 
  final String logo; 

  BankModel({
    required this.id,
    required this.name,
    required this.code,
    required this.bin,
    required this.shortName,
    required this.logo,
  });

  factory BankModel.fromJson(Map<String, dynamic> json) {
    return BankModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      bin: json['bin'] ?? '',
      shortName: json['shortName'] ?? '',
      logo: json['logo'] ?? '',
    );
  }
}