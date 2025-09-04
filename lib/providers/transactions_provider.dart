
// ===============================
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/supabase_service.dart';

class TransactionsProvider extends ChangeNotifier {

List<TransactionItem> items = [];
TxType filter = TxType.all;

  Future<void> bootstrap() async {
  await refresh();
}

Future<void> refresh() async {
  try {
    final res = filter == TxType.all
        ? await Supa.client
        .from('transactions')
        .select()
        .order('created_at', ascending: false)
        : await Supa.client
        .from('transactions')
        .select()
        .eq('type', filter.name)
        .order('created_at', ascending: false);

    items = (res as List)
        .map((e) => TransactionItem.fromMap(e))
        .toList();
  } catch (e, st) {
    items = [];
    debugPrint("Refresh error: $e\n$st");
  }
  notifyListeners();
}


void setFilter(TxType t) {
    filter = t;
    refresh();
    }

    Map<TxType, double> totalsByType() {
    final map = <TxType, double>{};
    for (final t in TxType.values) { map[t] = 0; }
    for (final i in items) {
    map[i.type] = (map[i.type] ?? 0) + i.amount;
    }
    return map;
    }
    }