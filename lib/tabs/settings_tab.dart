
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
