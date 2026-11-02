class PlanModel {
  final int id;
  final String name;
  final String? description;
  final double price;
  final String duration;
  final int maxUsers;
  final String status;
  final int companiesCount;

  const PlanModel({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    required this.duration,
    required this.maxUsers,
    required this.status,
    this.companiesCount = 0,
  });

  factory PlanModel.fromJson(Map<String, dynamic> json) {
    return PlanModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      price: json['price'] != null ? double.tryParse(json['price'].toString()) ?? 0.0 : 0.0,
      duration: json['duration'] as String? ?? '30 Days',
      maxUsers: json['max_users'] is int ? json['max_users'] : int.tryParse(json['max_users']?.toString() ?? '') ?? 5,
      status: json['status'] as String? ?? 'active',
      companiesCount: json['companies_count'] is int ? json['companies_count'] : int.tryParse(json['companies_count']?.toString() ?? '') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'duration': duration,
      'max_users': maxUsers,
      'status': status,
      'companies_count': companiesCount,
    };
  }

  bool get isActive => status == 'active';
}
