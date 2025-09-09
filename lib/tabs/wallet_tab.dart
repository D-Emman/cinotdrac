// ===============================
// lib/tabs/wallet_tab.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../providers/wallet_provider.dart';
import '../models/models.dart';

class WalletTab extends StatelessWidget {
  const WalletTab({super.key});

  @override
  Widget build(BuildContext context) {
    final wallet = context.watch<WalletProvider>();
    final settings = context.watch<SettingsProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Wallet'), actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_outlined))]),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _BalanceCard(hidden: settings.hideBalance, amount: wallet.balance, onToggle: settings.toggleHideBalance),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.arrow_downward), label: const Text('Top Up'))),
              const SizedBox(width: 12),
              Expanded(child: FilledButton.icon(onPressed: () {}, icon: const Icon(Icons.arrow_upward), label: const Text('Withdraw'))),
            ]),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Recent Bank Accounts', style: TextStyle(fontWeight: FontWeight.w700)),
                TextButton(onPressed: () => _openAdd(context), child: const Text('Add Bank Account')),
              ],
            ),
            if (wallet.recentAccounts.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                child: const Row(children: [Icon(Icons.info_outline), SizedBox(width: 12), Expanded(child: Text("Hmm! We couldn't find a Bank Account"))]),
              )
            else
              Column(
                children: wallet.recentAccounts
                    .map((a) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: const Icon(Icons.account_balance),
                    title: Text(a.bankName),
                    subtitle: Text('${a.accountName} • ${a.accountNumber}'),
                  ),
                ))
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }

  void _openAdd(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _AddBankSheet(),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  final bool hidden; final double amount; final VoidCallback onToggle;
  const _BalanceCard({required this.hidden, required this.amount, required this.onToggle});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Available Balance', style: TextStyle(color: Colors.black54)),
          const SizedBox(height: 6),
          Text(hidden ? '🙈🙈🙈🙈🙈' : '₦${amount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
        ]),
        IconButton(onPressed: onToggle, icon: Icon(hidden ? Icons.visibility_off : Icons.visibility))
      ]),
    );
  }
}

class _AddBankSheet extends StatefulWidget { const _AddBankSheet({super.key});
@override State<_AddBankSheet> createState() => _AddBankSheetState(); }

class _AddBankSheetState extends State<_AddBankSheet> {
  final _bank = TextEditingController();
  final _acctNo = TextEditingController();
  final _acctName = TextEditingController();
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    final wallet = context.read<WalletProvider>();
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('Add Bank Account', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
          const SizedBox(height: 12),
          TextField(controller: _bank, decoration: const InputDecoration(labelText: 'Bank Name', border: OutlineInputBorder())),
          const SizedBox(height: 8),
          TextField(controller: _acctName, decoration: const InputDecoration(labelText: 'Account Name', border: OutlineInputBorder())),
          const SizedBox(height: 8),
          TextField(controller: _acctNo, decoration: const InputDecoration(labelText: 'Account Number', border: OutlineInputBorder())),
          const SizedBox(height: 12),
          SizedBox(width: double.infinity, child: FilledButton(
            onPressed: _saving ? null : () async {
              setState(() => _saving = true);
              await wallet.addBankAccount(BankAccount(id: DateTime.now().millisecondsSinceEpoch.toString(), bankName: _bank.text, accountNumber: _acctNo.text, accountName: _acctName.text));
              if (context.mounted) Navigator.pop(context);
            },
            child: Text(_saving ? 'Saving...' : 'Save'),
          )),
          const SizedBox(height: 20),
        ]),
      ),
    );
  }
}
