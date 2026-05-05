import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.signIn(_emailCtrl.text.trim(), _passCtrl.text);
    if (!mounted) return;
    if (ok) {
      context.go('/home');
    } else if (auth.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.error!),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              _buildLogo(),
              const SizedBox(height: 48),
              Text(
                'Tekrar hoş geldin!',
                style: Theme.of(context).textTheme.displayMedium,
              ),
              const SizedBox(height: 8),
              const Text(
                'Hesabına giriş yap ve okumaya devam et.',
                style: TextStyle(color: AppColors.onSurfaceDim, fontSize: 15),
              ),
              const SizedBox(height: 36),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(color: AppColors.onBackground),
                      decoration: const InputDecoration(
                        labelText: 'E-posta',
                        prefixIcon: Icon(
                          Icons.email_outlined,
                          color: AppColors.onSurfaceDim,
                        ),
                      ),
                      validator: (v) {
                        final value = v?.trim() ?? '';
                        if (value.isEmpty) return 'E-posta gerekli';
                        final emailRegex = RegExp(r"^[^@\s]+@[^@\s]+\.[^@\s]+");
                        if (!emailRegex.hasMatch(value)) return 'Geçerli bir e-posta gir';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passCtrl,
                      obscureText: _obscure,
                      style: const TextStyle(color: AppColors.onBackground),
                      decoration: InputDecoration(
                        labelText: 'Şifre',
                        prefixIcon: const Icon(
                          Icons.lock_outline,
                          color: AppColors.onSurfaceDim,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscure
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: AppColors.onSurfaceDim,
                          ),
                          onPressed: () =>
                              setState(() => _obscure = !_obscure),
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Şifre gerekli';
                        if (v.length < 6) return 'En az 6 karakter gir';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => _showForgotPassword(context),
                        child: const Text('Şifremi unuttum'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: auth.loading ? null : _submit,
                      child: auth.loading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Giriş Yap'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              _buildDivider(),
              const SizedBox(height: 32),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Hesabın yok mu? ',
                      style: TextStyle(color: AppColors.onSurfaceDim),
                    ),
                    TextButton(
                      onPressed: () => context.go('/register'),
                      child: const Text('Kayıt Ol'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() => Row(
    children: [
      Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(
          Icons.auto_stories_rounded,
          color: Colors.white,
          size: 22,
        ),
      ),
      const SizedBox(width: 12),
      ShaderMask(
        shaderCallback: (b) => AppColors.primaryGradient.createShader(b),
        child: const Text(
          'Chae',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: -1,
          ),
        ),
      ),
    ],
  );

  Widget _buildDivider() => Row(
    children: [
      const Expanded(child: Divider(color: AppColors.outlineVariant)),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          'veya',
          style: TextStyle(color: AppColors.onSurfaceDim.withValues(alpha: 0.6)),
        ),
      ),
      const Expanded(child: Divider(color: AppColors.outlineVariant)),
    ],
  );

  void _showForgotPassword(BuildContext context) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceContainer,
        title: const Text('Şifre Sıfırla'),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.emailAddress,
          style: const TextStyle(color: AppColors.onBackground),
          decoration: const InputDecoration(labelText: 'E-posta adresin'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await context.read<AuthProvider>().resetPassword(ctrl.text.trim());
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Sıfırlama bağlantısı gönderildi'),
                  ),
                );
              }
            },
            child: const Text('Gönder'),
          ),
        ],
      ),
    );
  }
}
