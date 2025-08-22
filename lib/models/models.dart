// ===============================
class BankAccount {
  final String id;
  final String bankName;
  final String accountNumber;
  final String accountName;

  BankAccount({required this.id, required this.bankName, required this.accountNumber, required this.accountName});

  factory BankAccount.fromMap(Map<String, dynamic> m) => BankAccount(
    id: m['id'].toString(),
    bankName: m['bank_name'] ?? '',
    accountNumber: m['account_number'] ?? '',
    accountName: m['account_name'] ?? '',
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'bank_name': bankName,
    'account_number': accountNumber,
    'account_name': accountName,
  };
}

enum TxType {
  all,
  billPayment,
  buyGiftCard,
  justGadgets,
  sellGiftCard,
  rewardPoints,
  walletTopUp,
  withdrawal,
  virtualCard,
}

class TransactionItem {
  final String id;
  final TxType type;
  final double amount;
  final DateTime createdAt;
  final String note;

  TransactionItem({required this.id, required this.type, required this.amount, required this.createdAt, this.note = ''});

  factory TransactionItem.fromMap(Map<String, dynamic> m) => TransactionItem(
    id: m['id'].toString(),
    type: TxType.values.firstWhere((t) => t.name == (m['type'] ?? 'all'), orElse: () => TxType.all),
    amount: (m['amount'] as num).toDouble(),
    createdAt: DateTime.parse(m['created_at']),
    note: m['note'] ?? '',
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'type': type.name,
    'amount': amount,
    'created_at': createdAt.toIso8601String(),
    'note': note,
  };
}