
// ===============================
// lib/main.dart
// ===============================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'providers/auth_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/wallet_provider.dart';
import 'providers/transactions_provider.dart';
import 'screens/login_screen.dart';
import 'screens/root_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // TODO: Replace with your Supabase URL and anon key
  await Supabase.initialize(
    url: const String.fromEnvironment('SUPABASE_URL', defaultValue: 'https://YOUR-PROJECT.supabase.co'),
    anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: 'YOUR-ANON-KEY'),
  );

  runApp(const CardtonicsApp());
}

class CardtonicsApp extends StatelessWidget {
  const CardtonicsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()..load()),
        ChangeNotifierProvider(create: (_) => AuthProvider()..bootstrap()),
        ChangeNotifierProvider(create: (_) => WalletProvider()..bootstrap()),
        ChangeNotifierProvider(create: (_) => TransactionsProvider()..bootstrap()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return MaterialApp(
            title: 'Cardtonics',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0F9AFE)),
              useMaterial3: true,
              scaffoldBackgroundColor: const Color(0xFFF7F8FB),
              appBarTheme: const AppBarTheme(centerTitle: false),
            ),
            home: const Bootstrapper(),
          );
        },
      ),
    );
  }
}

/// Decides whether to show Login or the App shell
class Bootstrapper extends StatelessWidget {
  const Bootstrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        if (auth.isBooting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return auth.isAuthenticated ? const RootShell() : const LoginScreen();
      },
    );
  }
}



// ===============================



// ===============================


// ===============================
// lib/tabs/home_tab.dart
// ===============================
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../providers/wallet_provider.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final wallet = context.watch<WalletProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Welcome, '),
            Text(
              'emmanuelutulu', // Replace with real user display name from Auth provider if desired
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_outlined))],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _BalanceCard(
              hidden: settings.hideBalance,
              amount: wallet.balance,
              onToggle: settings.toggleHideBalance,
            ),
            const SizedBox(height: 16),
            Row(
              children: const [
                Expanded(child: _ActionBlock(title: 'Buy Gift Card', icon: Icons.card_giftcard)),
                SizedBox(width: 12),
                Expanded(child: _ActionBlock(title: 'Sell Gift Card', icon: Icons.sell_outlined)),
              ],
            ),
            const SizedBox(height: 12),
            _SectionCard(
              title: 'Just Gadgets',
              subtitle: 'Authentic + Affordable',
              trailing: const Icon(Icons.headphones_outlined),
            ),
            const SizedBox(height: 12),
            Row(
              children: const [
                Expanded(child: _ActionBlock(title: 'Virtual Dollar Card', icon: Icons.credit_card)),
                SizedBox(width: 12),
                Expanded(child: _ActionBlock(title: 'Bill Payment', icon: Icons.receipt_outlined)),
              ],
            ),
            const SizedBox(height: 16),
            Text('Trending', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            CarouselSlider(
              options: CarouselOptions(height: 140, autoPlay: true, enlargeCenterPage: true),
              items: [
                _CarouselCard('Flash Sale: Apple Gift Cards'),
                _CarouselCard('10% Bonus on Wallet Top-Up'),
                _CarouselCard('New: Virtual Dollar Card v2'),
              ].map((w) => Builder(builder: (_) => w)).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  final bool hidden;
  final double amount;
  final VoidCallback onToggle;
  const _BalanceCard({required this.hidden, required this.amount, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Available Balance', style: TextStyle(color: Colors.black54)),
            const SizedBox(height: 6),
            Text(
              hidden ? '🙈🙈🙈🙈🙈' : '₦${amount.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
            ),
          ]),
          Row(children: [
            IconButton(onPressed: onToggle, icon: Icon(hidden ? Icons.visibility_off : Icons.visibility)),
          ]),
        ],
      ),
    );
  }
}

class _ActionBlock extends StatelessWidget {
  final String title;
  final IconData icon;
  const _ActionBlock({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Center(
        child: ListTile(
          leading: CircleAvatar(backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(.1), child: Icon(icon)),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget trailing;
  const _SectionCard({required this.title, required this.subtitle, required this.trailing});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: const Icon(Icons.star_border),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(subtitle),
        trailing: trailing,
      ),
    );
  }
}

class _CarouselCard extends StatelessWidget {
  final String text;
  const _CarouselCard(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Align(
        alignment: Alignment.bottomLeft,
        child: Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
      ),
    );
  }
}

// ===============================
// lib/tabs/wallet_tab.dart
// ===============================
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

// ===============================
// lib/tabs/settings_tab.dart
// ===============================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../providers/auth_provider.dart';

class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings'), actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_outlined))]),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(children: [
            const CircleAvatar(radius: 26, child: Icon(Icons.person)),
            const SizedBox(width: 12),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(auth.username ?? 'User', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Container(width: 160, height: 6, decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(6)), child: Align(alignment: Alignment.centerLeft, child: Container(width: 90, height: 6, decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, borderRadius: BorderRadius.circular(6))))),
              const SizedBox(height: 6),
              const Text('User level: Bronze'),
            ])
          ]),
          const SizedBox(height: 16),
          _SettingsItem(icon: Icons.person_outline, title: 'Profile', onTap: () {}),
          _SettingsItem(icon: Icons.notifications_none, title: 'Notifications', onTap: () {}),
          _SettingsItem(icon: Icons.lock_outline, title: 'Security', onTap: () {}),
          _SettingsItem(icon: Icons.verified_user_outlined, title: 'Identity Verification', onTap: () {}),
          _SettingsItem(icon: Icons.chat_bubble_outline, title: 'Chat with Us', onTap: () {}),
          SwitchListTile(
            value: settings.biometricsEnabled,
            onChanged: (v) => settings.setBiometrics(v),
            secondary: const Icon(Icons.fingerprint),
            title: const Text('Sign in with biometrics'),
          ),
          const SizedBox(height: 12),
          ListTile(
            enabled: false,
            leading: const Icon(Icons.delete_outline),
            title: const Text('Delete Account'),
            subtitle: const Text('Contact support to proceed'),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () => context.read<AuthProvider>().logout(),
            child: const Text('Sign out'),
          )
        ],
      ),
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon; final String title; final VoidCallback onTap;
  const _SettingsItem({required this.icon, required this.title, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: ListTile(leading: Icon(icon), title: Text(title), trailing: const Icon(Icons.chevron_right), onTap: onTap),
    );
  }
}

// ===============================
// Supabase quick schema (save as notes)
// ===============================
/*
-- auth handled by Supabase Auth (email/password)

-- wallets
create table if not exists wallets (
  user_id uuid primary key references auth.users(id) on delete cascade,
  balance numeric default 0
);

-- helper function (RPC) to get current user's balance
create or replace function get_wallet_balance()
returns table(balance numeric)
language sql security definer set search_path = public as $$
  select coalesce(balance, 0) as balance from wallets where user_id = auth.uid();
$$;

-- bank accounts
create table if not exists bank_accounts (
  id bigint generated by default as identity primary key,
  user_id uuid references auth.users(id) on delete cascade,
  bank_name text,
  account_number text,
  account_name text,
  created_at timestamp default now()
);

-- transactions
create table if not exists transactions (
  id bigint generated by default as identity primary key,
  user_id uuid references auth.users(id) on delete cascade,
  type text check (type in ('all','billPayment','buyGiftCard','justGadgets','sellGiftCard','rewardPoints','walletTopUp','withdrawal','virtualCard')),
  amount numeric,
  note text,
  created_at timestamp default now()
);

-- RLS policies
alter table wallets enable row level security;
create policy "wallets select own" on wallets for select using (user_id = auth.uid());

alter table bank_accounts enable row level security;
create policy "bank sel" on bank_accounts for select using (user_id = auth.uid());
create policy "bank ins" on bank_accounts for insert with check (user_id = auth.uid());

alter table transactions enable row level security;
create policy "tx sel" on transactions for select using (user_id = auth.uid());
*/
