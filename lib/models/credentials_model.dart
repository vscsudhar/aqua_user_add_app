class CredentialsModel {
  final String companyName;
  final String companyId;
  final int adminUserId;
  final String adminEmail;
  final String temporaryPassword;
  final String assignedPlan;
  final int maxUsers;
  final String accountStatus;

  const CredentialsModel({
    required this.companyName,
    required this.companyId,
    required this.adminUserId,
    required this.adminEmail,
    required this.temporaryPassword,
    required this.assignedPlan,
    required this.maxUsers,
    required this.accountStatus,
  });

  factory CredentialsModel.fromJson(Map<String, dynamic> json) {
    return CredentialsModel(
      companyName: json['company_name'] as String? ?? '',
      companyId: json['company_id'] as String? ?? '',
      adminUserId: json['admin_user_id'] is int
          ? json['admin_user_id']
          : int.tryParse(json['admin_user_id']?.toString() ?? '') ?? 0,
      adminEmail: json['admin_email'] as String? ?? '',
      temporaryPassword: json['temporary_password'] as String? ?? '',
      assignedPlan: json['assigned_plan'] as String? ?? '',
      maxUsers: json['max_users'] is int
          ? json['max_users']
          : int.tryParse(json['max_users']?.toString() ?? '') ?? 5,
      accountStatus: json['account_status'] as String? ?? 'active',
    );
  }

  String toFormattedString() {
    return '''
========================================
   MARINA AQUA - COMPANY CREDENTIALS
========================================
Company Name : $companyName
Company ID   : $companyId
Admin User ID: $adminUserId
Admin Email  : $adminEmail
Password     : $temporaryPassword
Assigned Plan: $assignedPlan (Max $maxUsers Users)
Status       : $accountStatus
========================================
Use these credentials to sign in to the Marina Aqua business application.
''';
  }
}
