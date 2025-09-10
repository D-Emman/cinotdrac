// lib/screens/login_screen.dart
import 'package:cardtonics/screens/signup_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/settings_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}


class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final settings = context.watch<SettingsProvider>();

    final lockedMode = auth.username != null && !auth.isAuthenticated; // session exists but requires password

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              Text('Welcome${auth.username != null ? ', ${auth.username}' : ''}', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text(lockedMode ? 'Enter your password to continue' : 'Sign in to continue'),
              const SizedBox(height: 15),
              if (!lockedMode) ...[
                TextField(controller: _emailCtrl, decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder())),
                const SizedBox(height: 12),
              ],

              TextField(

                controller: _passwordCtrl,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(onPressed: () {}, child: const Text('Forgot Password?')),
                  TextButton(onPressed: () => context.read<AuthProvider>().logout(), child: const Text('Log out')),
                ],
              ),
              const SizedBox(height: 10),
              if (settings.biometricsEnabled)
                Center(
                  child: IconButton(
                    icon: const Icon(Icons.fingerprint, size: 48),
                    onPressed: () async {
                      await context.read<AuthProvider>().tryBiometric();
                    },
                  ),
                ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _loading
                      ? null
                      : () async {
                    setState(() => _loading = true);
                    try {
                      if (lockedMode) {
                        await context.read<AuthProvider>().reauthenticateLocked(password: _passwordCtrl.text);
                      } else {
                        await context.read<AuthProvider>().loginWithPassword(email: _emailCtrl.text, password: _passwordCtrl.text);
                      }
                    } catch (e) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Login failed: $e')));
                    } finally {
                      if (mounted) setState(() => _loading = false);
                    }
                  },
                  child: Text(_loading ? 'Signing in...' : 'Sign In'),
                ),
              ),
              const SizedBox(height: 12),

              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SignUpScreen()),
                  );
                },
                child: const Text("New here? Create an account"),
              ),
              const SizedBox(height: 12),

            ],
          ),
        ),
      ),
    );
  }
}
