// ===============================
// lib/tabs/transactions_tab.dart
// ===============================
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transactions_provider.dart';
import '../models/models.dart';

class TransactionsTab extends StatelessWidget {
  const TransactionsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final txp = context.watch<TransactionsProvider>();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.maybePop(context)),
        title: const Text('Transactions'),
        actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_outlined))],
      ),
      body: Column(
        children: [
          // Static balance banner in whatever state (no toggle)
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [Text('Available Balance', style: TextStyle(color: Colors.black54)), Text('🙈🙈🙈🙈🙈', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800))],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                const Text('Filter by:'),
                const SizedBox(width: 12),
                DropdownButton<TxType>(
                  value: txp.filter,
                  items: TxType.values
                      .map((t) => DropdownMenuItem(value: t, child: Text(_txLabel(t))))
                      .toList(),
                  onChanged: (v) => v == null ? null : txp.setFilter(v),
                ),
                const Spacer(),
                IconButton(
                  tooltip: 'View Chart',
                  icon: const Icon(Icons.bar_chart_outlined),
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const _TxChartScreen())),
                )
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => txp.refresh(),
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: txp.items.length,
                itemBuilder: (_, i) {
                  final it = txp.items[i];
                  return Container(
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      leading: const Icon(Icons.swap_horiz),
                      title: Text(_txLabel(it.type)),
                      subtitle: Text(it.createdAt.toLocal().toString()),
                      trailing: Text('₦${it.amount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  );
                },
                separatorBuilder: (_, __) => const SizedBox(height: 8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _txLabel(TxType t) {
    switch (t) {
      case TxType.all:
        return 'All transactions';
      case TxType.billPayment:
        return 'Bill Payment';
      case TxType.buyGiftCard:
        return 'Buy Gift Card';
      case TxType.justGadgets:
        return 'Just Gadgets';
      case TxType.sellGiftCard:
        return 'Sell Gift Card';
      case TxType.rewardPoints:
        return 'Reward Points';
      case TxType.walletTopUp:
        return 'Wallet Top-Ups';
      case TxType.withdrawal:
        return 'Withdrawals';
      case TxType.virtualCard:
        return 'Virtual Card';
    }
  }
}

class _TxChartScreen extends StatelessWidget {
  const _TxChartScreen();

  @override
  Widget build(BuildContext context) {
    final totals = context.read<TransactionsProvider>().totalsByType();
    final entries = totals.entries.where((e) => e.value > 0).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Transactions Chart')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceEvenly,
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (value, _) {
                final idx = value.toInt();
                if (idx < 0 || idx >= entries.length) return const SizedBox();
                return Text(_short(entries[idx].key));
              })),
              leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            barGroups: [
              for (int i = 0; i < entries.length; i++)
                BarChartGroupData(x: i, barRods: [BarChartRodData(toY: entries[i].value)])
            ],
          ),
        ),
      ),
    );
  }

  static String _short(TxType t) {
    switch (t) {
      case TxType.billPayment:
        return 'Bills';
      case TxType.buyGiftCard:
        return 'Buy';
      case TxType.justGadgets:
        return 'Gadg';
      case TxType.sellGiftCard:
        return 'Sell';
      case TxType.rewardPoints:
        return 'Pts';
      case TxType.walletTopUp:
        return 'TopUp';
      case TxType.withdrawal:
        return 'WD';
      case TxType.virtualCard:
        return 'VCard';
      case TxType.all:
        return 'All';
    }
  }
}
