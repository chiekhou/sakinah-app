import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sakinah_app/constants/app_theme.dart';
import 'package:sakinah_app/providers/auth_provider.dart';
import 'package:sakinah_app/widgets/custom_wigdet.dart';

/// Écran de connexion
/// Design rassurant et bienveillant
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    // Réinitialiser le message d'erreur
    setState(() {
      _errorMessage = null;
    });

    // Valider le formulaire
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      final result = await authProvider.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;

      if (result['success']) {
        final user = result['user'];

        // Vérifier si c'est un professionnel qui doit uploader son diplôme
        if (user['needs_diploma_upload'] == true) {
          Navigator.of(context).pushReplacementNamed('/upload-diploma');
          return;
        }

        // Vérifier si c'est un professionnel en attente de validation
        if (user['awaiting_admin_approval'] == true) {
          Navigator.of(context).pushReplacementNamed('/awaiting-approval');
          return;
        }

        // Utilisateur normal ou professionnel validé → MoodNavigator
        Navigator.of(context).pushReplacementNamed('/mood-navigator');
      } else {
        setState(() {
          _errorMessage = result['error'];
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Une erreur est survenue. Réessaie plus tard.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),

                // Logo et titre
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: AppTheme.softShadow,
                        ),
                        child: const Icon(
                          Icons.favorite,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Bon retour ! 💚',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Connecte-toi pour continuer ton parcours',
                        style: TextStyle(
                          fontSize: 15,
                          color: AppTheme.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 48),

                // Message d'erreur
                if (_errorMessage != null) ...[
                  ErrorMessage(message: _errorMessage!),
                  const SizedBox(height: 20),
                ],

                // Email
                CustomTextField(
                  controller: _emailController,
                  labelText: 'Email',
                  hintText: 'ton-email@exemple.com',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Entre ton email';
                    }
                    if (!value.contains('@')) {
                      return 'Email invalide';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Mot de passe
                CustomTextField(
                  controller: _passwordController,
                  labelText: 'Mot de passe',
                  hintText: '••••••••',
                  prefixIcon: Icons.lock_outlined,
                  obscureText: _obscurePassword,
                  suffixIcon: _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  onSuffixIconTap: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Entre ton mot de passe';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 12),

                // Mot de passe oublié
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed('/forgot-password');
                    },
                    child: const Text('Mot de passe oublié ?'),
                  ),
                ),

                const SizedBox(height: 32),

                // Bouton de connexion
                PrimaryButton(
                  text: 'Se connecter',
                  onPressed: _isLoading ? null : _handleLogin,
                  isLoading: _isLoading,
                  icon: Icons.login,
                ),

                const SizedBox(height: 24),

                // Divider
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'OU',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),

                const SizedBox(height: 24),

                // Bouton d'inscription
                SecondaryButton(
                  text: 'Créer un compte',
                  onPressed: () {
                    Navigator.of(context).pushReplacementNamed('/register');
                  },
                  icon: Icons.person_add_outlined,
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
