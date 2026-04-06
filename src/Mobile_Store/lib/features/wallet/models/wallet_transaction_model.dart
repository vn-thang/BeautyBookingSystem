
class WalletBalanceModel {
  final double walletBalance;
  final double minimumBalance;
  final bool isLockedByDebt;

  WalletBalanceModel({
    required this.walletBalance,
    required this.minimumBalance,
    required this.isLockedByDebt,
  });

  factory WalletBalanceModel.fromJson(Map<String, dynamic> json) {
    return WalletBalanceModel(
      walletBalance: (json['walletBalance'] ?? 0).toDouble(),
      minimumBalance: (json['minimumBalance'] ?? 0).toDouble(),
      isLockedByDebt: json['isLockedByDebt'] ?? false,
    );
  }
}

class WalletDashboardModel {
  final double currentBalance;
  final double minimumBalance;
  final bool isOpen;
  final double totalTopUpThisMonth;
  final double totalFeeThisMonth;
  
  final String? bankName;
  final String? bankAccountNumber;
  final String? bankAccountName;

  WalletDashboardModel({
    required this.currentBalance,
    required this.minimumBalance,
    required this.isOpen,
    required this.totalTopUpThisMonth,
    required this.totalFeeThisMonth,
    this.bankName,
    this.bankAccountNumber,
    this.bankAccountName,
  });

  factory WalletDashboardModel.fromJson(Map<String, dynamic> json) {
    return WalletDashboardModel(
      currentBalance: (json['currentBalance'] ?? 0).toDouble(),
      minimumBalance: (json['minimumBalance'] ?? 0).toDouble(),
      isOpen: json['isOpen'] ?? false,
      totalTopUpThisMonth: (json['totalTopUpThisMonth'] ?? 0).toDouble(),
      totalFeeThisMonth: (json['totalFeeThisMonth'] ?? 0).toDouble(),
      bankName: json['bankName'],
      bankAccountNumber: json['bankAccountNumber'],
      bankAccountName: json['bankAccountName'],
    );
  }
}

class WalletTransactionModel {
  final int id;
  final int? bookingId;
  final double amount;
  final String type; 
  final double balanceBefore;
  final double balanceAfter;
  final String description; 
  final DateTime? createdAt;
  final String status;

  final String? receiptImageUrl;
  final String? adminNote;

  WalletTransactionModel({
    required this.id,
    this.bookingId,
    required this.amount,
    required this.type,
    required this.balanceBefore,
    required this.balanceAfter,
    required this.description,
    this.createdAt,
    this.status = 'Completed',
    this.receiptImageUrl,
    this.adminNote,
  });

  factory WalletTransactionModel.fromJson(Map<String, dynamic> json) {
    return WalletTransactionModel(
      id: json['id'] ?? 0,
      bookingId: json['bookingId'],
      amount: (json['amount'] ?? 0).toDouble(),
      type: json['type']?.toString() ?? 'Unknown', 
      balanceBefore: (json['balanceBefore'] ?? 0).toDouble(),
      balanceAfter: (json['balanceAfter'] ?? 0).toDouble(),
      description: json['description'] ?? '',
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
      status: _parseStatus(json['status']),
      receiptImageUrl: json['receiptImageUrl'] as String?,
      adminNote: json['adminNote'] as String?,
    );
  }

  bool get isAddition {
    if (amount < 0) return false; 
    
    final t = type.toLowerCase();
    if (t == '1' || t == 'topup' || 
        t == '4' || t == 'refund' || 
        t == '6' || t == 'withdrawalrefund' || 
        t == '7' || t == 'receivedeposit') {
      return true; 
    }
    return false;
  }

  static String _parseStatus(dynamic statusVal) {
    if (statusVal == null) return 'Completed';

    if (statusVal is String) {
      return statusVal;
    }
    
    if (statusVal is int) {
      switch (statusVal) {
        case 0: return 'Pending';
        case 1: return 'Completed';
        case 2: return 'Failed';
        case 3: return 'Cancelled';
        default: return 'Completed';
      }
    }
    
    return 'Completed';
  }
}