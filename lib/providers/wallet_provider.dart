// ===============================
// lib/providers/wallet_provider.dart
// ===============================
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/supabase_service.dart';

class WalletProvider extends ChangeNotifier {
  double balance = 0.0;
  List<BankAccount> recentAccounts = [];

  Future<void> bootstrap() async {
    // fetch balance and recent accounts from Supabase (or keep empty for first run)
    await fetchBalance();
    await fetchRecentAccounts();
  }

  Future<void> fetchBalance() async {
    // Example: Supabase function or table 'wallets' with column 'balance'
    try {
      final data = await Supa.client.rpc('get_wallet_balance').maybeSingle();
      balance = (data?['balance'] as num?)?.toDouble() ?? 0.0;
    } catch (_) {
      balance = 0.0;
    }
    notifyListeners();
  }

  Future<void> fetchRecentAccounts() async {
    try {
      final res = await Supa.client.from('bank_accounts').select().order('created_at', ascending: false).limit(5);
      recentAccounts = (res as List).map((e) => BankAccount.fromMap(e)).toList();
    } catch (_) {
      recentAccounts = [];
    }
    notifyListeners();
  }

  Future<void> addBankAccount(BankAccount acct) async {
    await Supa.client.from('bank_accounts').insert(acct.toMap());
    await fetchRecentAccounts();
  }
}