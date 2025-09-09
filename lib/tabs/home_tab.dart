
// ===============================
// lib/tabs/home_tab.dart

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../providers/wallet_provider.dart';
import "../providers/auth_provider.dart";

class HomeTab extends StatelessWidget {
   HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    String? Username = "Emmanuel";
    final settings = context.watch<SettingsProvider>();
    final wallet = context.watch<WalletProvider>();
    
    Username = AuthProvider().username;
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Welcome, '),
            Text(
              "Emmanuel"
             , // Replace with real user display name from Auth provider if desired
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
