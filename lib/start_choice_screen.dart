import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'main.dart';
import 'plan_access.dart';
import 'client_list_screen.dart';

class StartChoiceScreen extends StatefulWidget {
  const StartChoiceScreen({super.key});

  @override
  State<StartChoiceScreen> createState() => _StartChoiceScreenState();
}

class _StartChoiceScreenState extends State<StartChoiceScreen> {
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    // Nasłuchuj zmian stanu auth i przekieruj jeśli zalogowany
    PlanAccessController.instance.notifier.addListener(_onAuthChanged);
    // Sprawdź od razu
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAlreadyLoggedIn();
    });
  }

  @override
  void dispose() {
    PlanAccessController.instance.notifier.removeListener(_onAuthChanged);
    super.dispose();
  }

  void _onAuthChanged() {
    _checkAlreadyLoggedIn();
  }

  void _checkAlreadyLoggedIn() {
    if (_navigated || !mounted) return;

    final state = PlanAccessController.instance.notifier.value;
    if (state.isAuthenticated) {
      _navigated = true;
      if (state.role == PlanUserRole.coach) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) =>
                ClientListScreen(themeColor: const Color(0xFFFFD700)),
          ),
        );
      } else if (state.role == PlanUserRole.client) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const CategoryScreen()),
        );
      }
    }
  }

  Future<void> _setLanguage(BuildContext context, String lang) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_language', lang);
    updateGlobalLanguage(lang);
  }

  Future<void> _continueOffline(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final lang = prefs.getString('app_language') ?? 'EN';
    await prefs.setString('app_language', lang);
    updateGlobalLanguage(lang);
    if (context.mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const CategoryScreen()),
      );
    }
  }

  Future<void> _goToLogin(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final lang = prefs.getString('app_language') ?? 'EN';
    await prefs.setString('app_language', lang);
    updateGlobalLanguage(lang);
    if (context.mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const LoginScreen(
            themeColor: Color(0xFF1E88E5),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const gold = Color(0xFFFFD700);
    const seed = Color(0xFF1E88E5);
    return ValueListenableBuilder<String>(
      valueListenable: globalLanguageNotifier,
      builder: (context, lang, _) {
        return Scaffold(
          appBar: buildCustomAppBar(context, accentColor: gold),
          body: GymBackgroundWithFitness(
            backgroundImage: 'assets/tlo.png',
            backgroundImageOpacity: 0.32,
            child: Center(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: ConstrainedBox(
                      constraints:
                          BoxConstraints(minHeight: constraints.maxHeight),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 24),
                          Container(
                            width: 180,
                            height: 180,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: seed.withValues(alpha: 0.45),
                                  blurRadius: 48,
                                  spreadRadius: 10,
                                ),
                                BoxShadow(
                                  color: gold.withValues(alpha: 0.35),
                                  blurRadius: 26,
                                  spreadRadius: 4,
                                ),
                              ],
                            ),
                            child: buildLogo(context, gold, size: 135),
                          ),
                          const SizedBox(height: 32),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              {
                                'code': 'EN',
                                'label': 'English',
                                'flag': '🇬🇧'
                              },
                              {'code': 'PL', 'label': 'Polski', 'flag': '🇵🇱'},
                              {'code': 'NO', 'label': 'Norsk', 'flag': '🇳🇴'},
                            ].map((entry) {
                              final code = entry['code'] as String;
                              final label = entry['label'] as String;
                              final flag = entry['flag'] as String;
                              final bool isActive = lang == code;
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: InkWell(
                                  onTap: () => _setLanguage(context, code),
                                  borderRadius: BorderRadius.circular(14),
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: isActive
                                          ? gold.withValues(alpha: 0.85)
                                          : Colors.black
                                              .withValues(alpha: 0.35),
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: isActive
                                            ? gold.withValues(alpha: 0.9)
                                            : gold.withValues(alpha: 0.55),
                                        width: 1.2,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            CircleAvatar(
                                              radius: 16,
                                              backgroundColor: gold,
                                              child: Text(
                                                flag,
                                                style: const TextStyle(
                                                    fontSize: 18),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Text(
                                              label,
                                              style: TextStyle(
                                                color: isActive
                                                    ? Colors.black
                                                    : gold,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700,
                                                decoration: TextDecoration.none,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Icon(
                                          Icons.check_circle,
                                          color: isActive
                                              ? Colors.black
                                              : gold.withValues(alpha: 0.35),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            Translations.get('app_title', language: lang),
                            style: const TextStyle(
                              color: gold,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              decoration: TextDecoration.none,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () => _goToLogin(context),
                            icon: const Icon(Icons.login,
                                color: Color(0xFF0B2E5A)),
                            label: Text(
                              lang == 'PL'
                                  ? 'Zaloguj się'
                                  : lang == 'NO'
                                      ? 'Logg inn'
                                      : 'Log in',
                              style: const TextStyle(
                                color: Color(0xFF0B2E5A),
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                decoration: TextDecoration.none,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: gold,
                              foregroundColor: const Color(0xFF0B2E5A),
                              minimumSize: const Size(double.infinity, 52),
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            onPressed: () => _continueOffline(context),
                            icon: const Icon(Icons.arrow_forward, color: gold),
                            label: Text(
                              Translations.get('continue_without_login',
                                  language: lang),
                              style: const TextStyle(
                                color: gold,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                decoration: TextDecoration.none,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                  color: gold.withValues(alpha: 0.7)),
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              foregroundColor: gold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CoachLoginDialog extends StatefulWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final String lang;
  final VoidCallback onSuccess;

  const _CoachLoginDialog({
    required this.emailController,
    required this.passwordController,
    required this.lang,
    required this.onSuccess,
  });

  @override
  State<_CoachLoginDialog> createState() => _CoachLoginDialogState();
}

class _CoachLoginDialogState extends State<_CoachLoginDialog> {
  bool _loading = false;
  String? _error;

  Future<void> _signIn() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await PlanAccessController.instance.signInAsCoach(
        widget.emailController.text.trim(),
        widget.passwordController.text,
      );
      widget.onSuccess();
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const gold = Color(0xFFFFD700);
    final lang = widget.lang;

    return AlertDialog(
      backgroundColor: const Color(0xFF0B2E5A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        lang == 'PL'
            ? 'Logowanie trenera'
            : lang == 'NO'
                ? 'Trenerinnlogging'
                : 'Coach Login',
        style: const TextStyle(color: gold, fontWeight: FontWeight.bold),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: widget.emailController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Email',
              labelStyle: const TextStyle(color: gold),
              prefixIcon: const Icon(Icons.email, color: gold),
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: gold),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: gold, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: widget.passwordController,
            obscureText: true,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: lang == 'PL'
                  ? 'Hasło'
                  : lang == 'NO'
                      ? 'Passord'
                      : 'Password',
              labelStyle: const TextStyle(color: gold),
              prefixIcon: const Icon(Icons.lock, color: gold),
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: gold),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: gold, width: 2),
              ),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(
              _error!,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            lang == 'PL'
                ? 'Anuluj'
                : lang == 'NO'
                    ? 'Avbryt'
                    : 'Cancel',
            style: const TextStyle(color: Colors.white70),
          ),
        ),
        ElevatedButton(
          onPressed: _loading ? null : _signIn,
          style: ElevatedButton.styleFrom(
            backgroundColor: gold,
            foregroundColor: const Color(0xFF0B2E5A),
          ),
          child: _loading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(lang == 'PL'
                  ? 'Zaloguj'
                  : lang == 'NO'
                      ? 'Logg inn'
                      : 'Sign in'),
        ),
      ],
    );
  }
}
