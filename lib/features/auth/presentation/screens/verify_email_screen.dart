import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/errors/auth_exception.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/auth_providers.dart';

class VerifyEmailScreen extends ConsumerStatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  ConsumerState<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen> {
  bool _isSending = false;
  bool _isChecking = false;
  String? _message;
  bool _isError = false;

  Future<void> _resend() async {
    setState(() {
      _message = null;
      _isSending = true;
    });
    try {
      final repo = ref.read(authRepositoryProvider);
      await repo.sendEmailVerification();
      if (!mounted) return;
      setState(() {
        _message = 'Verification email sent. Check your inbox.';
        _isError = false;
        _isSending = false;
      });
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _message = e.message;
        _isError = true;
        _isSending = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _message = 'Failed to send. Try again.';
        _isError = true;
        _isSending = false;
      });
    }
  }

  Future<void> _checkVerified() async {
    setState(() {
      _message = null;
      _isChecking = true;
    });
    try {
      final repo = ref.read(authRepositoryProvider);
      final user = await repo.reloadCurrentUser();
      if (!mounted) return;
      setState(() => _isChecking = false);
      if (user != null && user.emailVerified) {
        if (mounted) context.go('/');
      } else {
        setState(() {
          _message = 'Email not verified yet. Click the link in the email and try again.';
          _isError = true;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _message = 'Failed to check. Try again.';
        _isError = true;
        _isChecking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify email'),
        backgroundColor: AppTheme.primaryDark,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              const Icon(Icons.mark_email_unread_outlined, size: 80),
              const SizedBox(height: 24),
              const Text(
                'Please verify your email',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'We sent a verification link to your email address. '
                'Click the link in the email to verify your account, then return here.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              if (_message != null) ...[
                const SizedBox(height: 16),
                Text(
                  _message!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _isError
                        ? Theme.of(context).colorScheme.error
                        : Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
              const Spacer(),
              FilledButton(
                onPressed: _isSending ? null : _resend,
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.accent,
                  foregroundColor: Colors.black87,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isSending
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Resend verification email'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: _isChecking ? null : _checkVerified,
                child: _isChecking
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text("I've verified my email"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
