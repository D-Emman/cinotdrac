
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
