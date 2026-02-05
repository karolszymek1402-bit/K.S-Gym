import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'plan_access.dart';
import 'main.dart';

class ClientListScreen extends StatefulWidget {
  final Color themeColor;
  const ClientListScreen({super.key, required this.themeColor});

  @override
  State<ClientListScreen> createState() => _ClientListScreenState();
}

class _ClientListScreenState extends State<ClientListScreen> {
  List<UserProfile> _clients = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadClients();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadClients() async {
    setState(() => _loading = true);
    try {
      final clients = await PlanAccessController.instance.fetchAllClients();
      if (mounted) {
        setState(() {
          _clients = clients;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = globalLanguage;
    return Scaffold(
      appBar: buildCustomAppBar(context, accentColor: widget.themeColor),
      body: GymBackgroundWithFitness(
        goldDumbbells: true,
        backgroundImage: 'assets/tlo.png',
        backgroundImageOpacity: 0.3,
        gradientColors: const [
          Color(0xFF0B2E5A),
          Color(0xFF0A2652),
          Color(0xFF0E3D8C),
        ],
        accentColor: widget.themeColor,
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFFFFD700)))
            : _clients.isEmpty
                ? Center(
                    child: Text(
                      lang == 'PL'
                          ? 'Brak klientów'
                          : lang == 'NO'
                              ? 'Ingen klienter'
                              : 'No clients',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _clients.length,
                    itemBuilder: (context, index) {
                      final client = _clients[index];
                      final email = client.email;
                      final displayName = client.displayName;
                      final hasName =
                          displayName != null && displayName.trim().isNotEmpty;
                      return Card(
                        color: const Color(0xFF0B2E5A).withValues(alpha: 0.6),
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(
                            color: Color(0xFFFFD700),
                            width: 1.5,
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          leading: CircleAvatar(
                            backgroundColor: const Color(0xFFFFD700),
                            child: Text(
                              hasName
                                  ? displayName[0].toUpperCase()
                                  : email[0].toUpperCase(),
                              style: const TextStyle(
                                color: Color(0xFF0B2E5A),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            hasName ? displayName : email,
                            style: const TextStyle(
                              color: Color(0xFFFFD700),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: hasName
                              ? Text(
                                  email,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                )
                              : null,
                          trailing: SizedBox(
                            width: 120,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit,
                                      color: Color(0xFFFFD700), size: 22),
                                  onPressed: () => _showEditClientDialog(
                                      context, email, displayName),
                                  tooltip:
                                      Translations.get('edit', language: lang),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(
                                    minWidth: 36,
                                    minHeight: 36,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red, size: 22),
                                  onPressed: () =>
                                      _showDeleteClientDialog(context, email),
                                  tooltip: Translations.get('delete',
                                      language: lang),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(
                                    minWidth: 36,
                                    minHeight: 36,
                                  ),
                                ),
                                const Icon(
                                  Icons.arrow_forward_ios,
                                  color: Color(0xFFFFD700),
                                  size: 18,
                                ),
                              ],
                            ),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ClientDetailScreen(
                                  clientEmail: email,
                                  themeColor: widget.themeColor,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddClientDialog(context),
        backgroundColor: const Color(0xFFFFD700),
        icon: const Icon(Icons.person_add, color: Color(0xFF0B2E5A)),
        label: Text(
          Translations.get('add_client', language: lang),
          style: const TextStyle(
            color: Color(0xFF0B2E5A),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _showAddClientDialog(BuildContext context) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController(text: '000000');
    final lang = globalLanguage;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0B2E5A),
        title: Text(
          lang == 'PL'
              ? 'Dodaj nowego klienta'
              : lang == 'NO'
                  ? 'Legg til ny klient'
                  : 'Add new client',
          style: const TextStyle(
            color: Color(0xFFFFD700),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              style: const TextStyle(color: Color(0xFFFFD700)),
              decoration: InputDecoration(
                labelText: lang == 'PL'
                    ? 'Imię klienta (opcjonalnie)'
                    : lang == 'NO'
                        ? 'Kundenavn (valgfritt)'
                        : 'Client name (optional)',
                labelStyle: const TextStyle(color: Color(0xFFFFD700)),
                prefixIcon: const Icon(Icons.person, color: Color(0xFFFFD700)),
                enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFFFD700)),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFFFD700), width: 2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              style: const TextStyle(color: Color(0xFFFFD700)),
              decoration: InputDecoration(
                labelText: lang == 'PL'
                    ? 'Email klienta'
                    : lang == 'NO'
                        ? 'Klient e-post'
                        : 'Client email',
                labelStyle: const TextStyle(color: Color(0xFFFFD700)),
                prefixIcon: const Icon(Icons.email, color: Color(0xFFFFD700)),
                enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFFFD700)),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFFFD700), width: 2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              style: const TextStyle(color: Color(0xFFFFD700)),
              decoration: InputDecoration(
                labelText: lang == 'PL'
                    ? 'Hasło (min. 6 znaków, domyślnie 000000)'
                    : lang == 'NO'
                        ? 'Passord (minst 6 tegn, standard 000000)'
                        : 'Password (min 6 chars, default 000000)',
                labelStyle: const TextStyle(color: Color(0xFFFFD700)),
                prefixIcon: const Icon(Icons.lock, color: Color(0xFFFFD700)),
                enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFFFD700)),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFFFD700), width: 2),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              Translations.get('cancel', language: lang),
              style: const TextStyle(color: Colors.white70),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              final name = nameController.text.trim();
              final email = emailController.text.trim();
              final password = passwordController.text.trim();

              if (email.isEmpty) {
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(
                      lang == 'PL'
                          ? 'Wprowadź email'
                          : lang == 'NO'
                              ? 'Skriv inn e-post'
                              : 'Enter email',
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              Navigator.pop(context);

              try {
                await PlanAccessController.instance.createClientAccount(
                    email, password,
                    displayName: name.isEmpty ? null : name);
                if (!mounted) return;
                await _loadClients();
                if (!mounted) return;
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(
                      lang == 'PL'
                          ? 'Klient dodany pomyślnie'
                          : lang == 'NO'
                              ? 'Klient lagt til'
                              : 'Client added successfully',
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                if (!mounted) return;
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(
                      '${Translations.get('error', language: lang)}: ${e.toString()}',
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFD700),
              foregroundColor: const Color(0xFF0B2E5A),
            ),
            child: Text(
              Translations.get('add', language: lang),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditClientDialog(
      BuildContext context, String currentEmail, String? currentName) {
    final emailController = TextEditingController(text: currentEmail);
    final nameController = TextEditingController(text: currentName ?? '');
    final passwordController = TextEditingController();
    final lang = globalLanguage;
    bool showPassword = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF0B2E5A),
          title: Text(
            lang == 'PL'
                ? 'Edytuj klienta'
                : lang == 'NO'
                    ? 'Rediger klient'
                    : 'Edit client',
            style: const TextStyle(
              color: Color(0xFFFFD700),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: lang == 'PL'
                        ? 'Imię klienta'
                        : lang == 'NO'
                            ? 'Kundenavn'
                            : 'Client name',
                    labelStyle: const TextStyle(color: Color(0xFFFFD700)),
                    prefixIcon:
                        const Icon(Icons.person, color: Color(0xFFFFD700)),
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFFFD700)),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide:
                          BorderSide(color: Color(0xFFFFD700), width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  style: const TextStyle(color: Colors.white),
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: lang == 'PL'
                        ? 'Email klienta'
                        : lang == 'NO'
                            ? 'Klient e-post'
                            : 'Client email',
                    labelStyle: const TextStyle(color: Color(0xFFFFD700)),
                    prefixIcon:
                        const Icon(Icons.email, color: Color(0xFFFFD700)),
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFFFD700)),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide:
                          BorderSide(color: Color(0xFFFFD700), width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: passwordController,
                  style: const TextStyle(color: Colors.white),
                  obscureText: !showPassword,
                  decoration: InputDecoration(
                    labelText: lang == 'PL'
                        ? 'Nowe hasło (opcjonalne)'
                        : lang == 'NO'
                            ? 'Nytt passord (valgfritt)'
                            : 'New password (optional)',
                    labelStyle: const TextStyle(color: Color(0xFFFFD700)),
                    prefixIcon:
                        const Icon(Icons.lock, color: Color(0xFFFFD700)),
                    suffixIcon: IconButton(
                      icon: Icon(
                        showPassword ? Icons.visibility_off : Icons.visibility,
                        color: const Color(0xFFFFD700),
                      ),
                      onPressed: () {
                        setDialogState(() => showPassword = !showPassword);
                      },
                    ),
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFFFD700)),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide:
                          BorderSide(color: Color(0xFFFFD700), width: 2),
                    ),
                    helperText: lang == 'PL'
                        ? 'Min. 6 znaków'
                        : lang == 'NO'
                            ? 'Min. 6 tegn'
                            : 'Min. 6 characters',
                    helperStyle: const TextStyle(color: Colors.white54),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                Translations.get('cancel', language: lang),
                style: const TextStyle(color: Colors.white70),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                final newEmail = emailController.text.trim();
                final newName = nameController.text.trim();
                final newPassword = passwordController.text;

                if (newEmail.isEmpty) {
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(
                        lang == 'PL'
                            ? 'Wprowadź email'
                            : lang == 'NO'
                                ? 'Skriv inn e-post'
                                : 'Enter email',
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                if (newPassword.isNotEmpty && newPassword.length < 6) {
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(
                        lang == 'PL'
                            ? 'Hasło musi mieć min. 6 znaków'
                            : lang == 'NO'
                                ? 'Passordet må ha minst 6 tegn'
                                : 'Password must have at least 6 characters',
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                Navigator.pop(context);

                try {
                  // First update display name using current email
                  await PlanAccessController.instance.updateClientDisplayName(
                      currentEmail, newName.isEmpty ? null : newName);
                  debugPrint('✅ Display name updated to: $newName');

                  // Then update email if changed
                  if (newEmail != currentEmail) {
                    await PlanAccessController.instance
                        .updateClientEmail(currentEmail, newEmail);
                    debugPrint(
                        '✅ Email updated from $currentEmail to $newEmail');
                  }

                  // Update password if provided
                  if (newPassword.isNotEmpty) {
                    await PlanAccessController.instance
                        .updateClientPassword(newEmail, newPassword);
                    debugPrint('✅ Password updated for $newEmail');
                  }

                  if (!mounted) return;
                  await _loadClients();
                  if (!mounted) return;
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(
                        lang == 'PL'
                            ? 'Dane klienta zaktualizowane'
                            : lang == 'NO'
                                ? 'Kundedata oppdatert'
                                : 'Client data updated',
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  debugPrint('❌ Error updating client: $e');
                  if (!mounted) return;
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(
                        '${Translations.get('error', language: lang)}: ${e.toString()}',
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD700),
                foregroundColor: const Color(0xFF0B2E5A),
              ),
              child: Text(
                Translations.get('save', language: lang),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteClientDialog(BuildContext context, String email) {
    final lang = globalLanguage;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0B2E5A),
        title: Text(
          Translations.get('delete_client', language: lang),
          style: const TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.warning_amber_rounded,
                color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              lang == 'PL'
                  ? 'Czy na pewno chcesz usunąć klienta?'
                  : lang == 'NO'
                      ? 'Er du sikker på at du vil slette klienten?'
                      : 'Are you sure you want to delete this client?',
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              email,
              style: const TextStyle(
                color: Color(0xFFFFD700),
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              lang == 'PL'
                  ? 'Ta operacja jest nieodwracalna!\nPlan i historia ćwiczeń zostaną usunięte.'
                  : lang == 'NO'
                      ? 'Denne handlingen kan ikke angres!\nPlan og treningshistorikk vil bli slettet.'
                      : 'This action cannot be undone!\nPlan and exercise history will be deleted.',
              style: const TextStyle(color: Colors.white70, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              Translations.get('cancel', language: lang),
              style: const TextStyle(color: Colors.white70),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              Navigator.pop(context);

              try {
                await PlanAccessController.instance.deleteClient(email);
                if (!mounted) return;
                await _loadClients();
                if (!mounted) return;
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(
                      lang == 'PL'
                          ? 'Klient usunięty'
                          : lang == 'NO'
                              ? 'Klient slettet'
                              : 'Client deleted',
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                if (!mounted) return;
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(
                      '${Translations.get('error', language: lang)}: ${e.toString()}',
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(
              Translations.get('delete', language: lang),
            ),
          ),
        ],
      ),
    );
  }
}

class ClientDetailScreen extends StatefulWidget {
  final String clientEmail;
  final Color themeColor;
  const ClientDetailScreen({
    super.key,
    required this.clientEmail,
    required this.themeColor,
  });

  @override
  State<ClientDetailScreen> createState() => _ClientDetailScreenState();
}

class _ClientDetailScreenState extends State<ClientDetailScreen> {
  ClientPlan? _plan;
  bool _loading = true;
  late TextEditingController _planController;
  bool _editMode = false;

  @override
  void initState() {
    super.initState();
    _planController = TextEditingController();
    _loadClientPlan();
  }

  @override
  void dispose() {
    _planController.dispose();
    super.dispose();
  }

  Future<void> _loadClientPlan() async {
    setState(() => _loading = true);
    try {
      final plan = await PlanAccessController.instance
          .fetchPlanForEmail(widget.clientEmail);
      final prefs = await SharedPreferences.getInstance();
      final planKey = 'plan_${widget.clientEmail}';
      final localPlan = prefs.getString(planKey) ?? '';

      if (plan != null && localPlan.isNotEmpty && plan.notes.isEmpty) {
        final migratedPlan = ClientPlan(
          title: plan.title,
          notes: localPlan,
          entries: plan.entries,
          updatedAt: DateTime.now(),
        );
        await PlanAccessController.instance
            .savePlanForEmail(widget.clientEmail, migratedPlan);
        await prefs.remove(planKey);
      }

      if (mounted) {
        setState(() {
          _plan = plan;
          _planController.text = plan?.notes ?? localPlan;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _savePlan() async {
    try {
      if (_plan == null) return;

      final updatedPlan = ClientPlan(
        title: _plan!.title,
        notes: _planController.text.trim(),
        entries: _plan!.entries,
        updatedAt: DateTime.now(),
      );

      await PlanAccessController.instance
          .savePlanForEmail(widget.clientEmail, updatedPlan);

      if (mounted) {
        setState(() {
          _plan = updatedPlan;
          _editMode = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              globalLanguage == 'PL'
                  ? 'Plan zapisany'
                  : globalLanguage == 'NO'
                      ? 'Plan lagret'
                      : 'Plan saved',
            ),
            backgroundColor: Colors.green,
          ),
        );
        _loadClientPlan();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showExerciseProgress(
      BuildContext context, String exerciseName) async {
    final lang = globalLanguage;
    try {
      final data = await PlanAccessController.instance
          .fetchClientExerciseHistory(widget.clientEmail, exerciseName);
      final logsRaw = data?['logs'];
      final logs = <ExerciseLog>[];
      if (logsRaw is Iterable) {
        for (final item in logsRaw) {
          if (item is Map) {
            logs.add(ExerciseLog.fromJson(Map<String, dynamic>.from(item),
                defaultExercise: exerciseName));
          }
        }
      }

      if (!context.mounted) return;
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: const Color(0xFF0B2E5A),
          title: Text(
            localizedExerciseName(exerciseName, lang),
            style: const TextStyle(
              color: Color(0xFFFFD700),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: logs.isEmpty
                ? Text(
                    lang == 'PL'
                        ? 'Brak zapisanej historii'
                        : lang == 'NO'
                            ? 'Ingen lagret historikk'
                            : 'No saved history',
                    style: const TextStyle(color: Colors.white70),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    itemCount: logs.length,
                    separatorBuilder: (_, __) =>
                        const Divider(color: Color(0xFFFFD700), height: 12),
                    itemBuilder: (ctx, index) {
                      final entry = logs[index];
                      final isTime = entry.durationSeconds > 0;
                      final value = isTime
                          ? '${entry.durationSeconds}s'
                          : '${entry.weight} kg × ${entry.reps}';
                      final rest = entry.reps.isNotEmpty
                          ? entry.reps
                          : entry.plannedTime ?? '';
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(entry.date,
                              style: const TextStyle(
                                  color: Color(0xFFFFD700),
                                  fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          Text(
                            isTime
                                ? '${lang == 'PL' ? 'Czas' : lang == 'NO' ? 'Tid' : 'Time'}: $value'
                                : value,
                            style: const TextStyle(color: Colors.white70),
                          ),
                          if (rest.isNotEmpty)
                            Text(
                              '${lang == 'PL' ? 'Przerwa' : lang == 'NO' ? 'Pause' : 'Rest'}: $rest',
                              style: const TextStyle(color: Colors.white54),
                            ),
                          Text(
                            '${lang == 'PL' ? 'Seria' : lang == 'NO' ? 'Sett' : 'Set'}: ${entry.sets}',
                            style: const TextStyle(color: Colors.white54),
                          ),
                        ],
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                lang == 'PL'
                    ? 'Zamknij'
                    : lang == 'NO'
                        ? 'Lukk'
                        : 'Close',
                style: const TextStyle(color: Color(0xFFFFD700)),
              ),
            ),
          ],
        ),
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            lang == 'PL'
                ? 'Nie udało się pobrać historii'
                : lang == 'NO'
                    ? 'Kunne ikke hente historikk'
                    : 'Failed to load history',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _showAllProgressSummary(BuildContext context) async {
    final lang = globalLanguage;

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(
        child: CircularProgressIndicator(color: Color(0xFFFFD700)),
      ),
    );

    try {
      // Get all exercises from the plan or fetch all history
      final allProgress = <String, List<ExerciseLog>>{};

      if (_plan != null && _plan!.entries.isNotEmpty) {
        // Fetch history for each exercise in the plan
        for (final entry in _plan!.entries) {
          try {
            final data = await PlanAccessController.instance
                .fetchClientExerciseHistory(widget.clientEmail, entry.exercise);
            final logsRaw = data?['logs'];
            final logs = <ExerciseLog>[];
            if (logsRaw is Iterable) {
              for (final item in logsRaw) {
                if (item is Map) {
                  logs.add(ExerciseLog.fromJson(
                    Map<String, dynamic>.from(item),
                    defaultExercise: entry.exercise,
                  ));
                }
              }
            }
            if (logs.isNotEmpty) {
              allProgress[entry.exercise] = logs;
            }
          } catch (_) {
            // Skip if can't fetch
          }
        }
      }

      if (!context.mounted) return;
      Navigator.pop(context); // Close loading dialog

      // Show progress summary
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ClientProgressScreen(
            clientEmail: widget.clientEmail,
            progressData: allProgress,
            themeColor: widget.themeColor,
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context); // Close loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            lang == 'PL'
                ? 'Błąd ładowania postępów: ${e.toString()}'
                : lang == 'NO'
                    ? 'Feil ved lasting av fremgang: ${e.toString()}'
                    : 'Error loading progress: ${e.toString()}',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _pasteFromClipboard() async {
    try {
      final data = await Clipboard.getData('text/plain');
      if (data?.text != null && data!.text!.isNotEmpty) {
        setState(() {
          _planController.text = data.text!;
        });
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final lang = globalLanguage;
    return Scaffold(
      appBar: buildCustomAppBar(context, accentColor: widget.themeColor),
      body: GymBackgroundWithFitness(
        goldDumbbells: true,
        backgroundImage: 'assets/tlo.png',
        backgroundImageOpacity: 0.3,
        gradientColors: const [
          Color(0xFF0B2E5A),
          Color(0xFF0A2652),
          Color(0xFF0E3D8C),
        ],
        accentColor: widget.themeColor,
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFFFFD700)))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      color: const Color(0xFF0B2E5A).withValues(alpha: 0.6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(
                          color: Color(0xFFFFD700),
                          width: 2,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.person,
                                  color: Color(0xFFFFD700),
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    widget.clientEmail,
                                    style: const TextStyle(
                                      color: Color(0xFFFFD700),
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () =>
                                    _showAllProgressSummary(context),
                                icon: const Icon(Icons.insights, size: 20),
                                label: Text(
                                  lang == 'PL'
                                      ? 'Pokaż postępy'
                                      : lang == 'NO'
                                          ? 'Vis fremgang'
                                          : 'View Progress',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2ECC71),
                                  foregroundColor: Colors.white,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                            if (_plan != null) ...[
                              const SizedBox(height: 16),
                              const Divider(color: Color(0xFFFFD700)),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    lang == 'PL'
                                        ? 'Plan treningowy:'
                                        : lang == 'NO'
                                            ? 'Treningsplan:'
                                            : 'Training Plan:',
                                    style: const TextStyle(
                                      color: Color(0xFFFFD700),
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  TextButton.icon(
                                    onPressed: () {
                                      setState(() {
                                        _editMode = !_editMode;
                                        if (!_editMode) {
                                          _planController.text =
                                              _plan?.notes ?? '';
                                        }
                                      });
                                    },
                                    icon: Icon(
                                      _editMode ? Icons.close : Icons.edit,
                                      size: 18,
                                    ),
                                    label: Text(
                                      _editMode ? 'Cancel' : 'Edit',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ),
                                ],
                              ),
                              if (_editMode) ...[
                                const SizedBox(height: 12),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: const Color(0xFFFFD700)
                                          .withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: TextField(
                                    controller: _planController,
                                    keyboardType: TextInputType.multiline,
                                    maxLines: 8,
                                    style: const TextStyle(
                                        color: Color(0xFFFFD700)),
                                    decoration: InputDecoration(
                                      hintText: lang == 'PL'
                                          ? 'Wklej lub wpisz plan tutaj...'
                                          : lang == 'NO'
                                              ? 'Lim inn eller skriv plan her...'
                                              : 'Paste or write plan here...',
                                      hintStyle: const TextStyle(
                                        color: Color(0xFFFFD700),
                                        fontSize: 13,
                                      ),
                                      border: InputBorder.none,
                                      contentPadding: const EdgeInsets.all(12),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: _pasteFromClipboard,
                                        icon: const Icon(Icons.paste),
                                        label: Text(
                                          lang == 'PL'
                                              ? 'Wklej'
                                              : lang == 'NO'
                                                  ? 'Lim inn'
                                                  : 'Paste',
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              const Color(0xFFFFD700),
                                          foregroundColor:
                                              const Color(0xFF0B2E5A),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: _savePlan,
                                        icon: const Icon(Icons.save),
                                        label: Text(
                                          lang == 'PL'
                                              ? 'Zapisz'
                                              : lang == 'NO'
                                                  ? 'Lagre'
                                                  : 'Save',
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              const Color(0xFF0E3D8C),
                                          foregroundColor:
                                              const Color(0xFFFFD700),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                              if (!_editMode) ...[
                                const SizedBox(height: 8),
                                Text(
                                  _plan!.title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  (_plan!.notes.isNotEmpty
                                              ? _plan!.notes
                                              : _planController.text)
                                          .trim()
                                          .isNotEmpty
                                      ? (_plan!.notes.isNotEmpty
                                          ? _plan!.notes
                                          : _planController.text)
                                      : (lang == 'PL'
                                          ? 'Brak zapisanego planu'
                                          : lang == 'NO'
                                              ? 'Ingen lagret plan'
                                              : 'No saved plan'),
                                  style: const TextStyle(
                                    color: Color(0xFFFFD700),
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  lang == 'PL'
                                      ? 'Ostatnia aktualizacja: ${_plan!.updatedAt.toString().substring(0, 16)}'
                                      : lang == 'NO'
                                          ? 'Sist oppdatert: ${_plan!.updatedAt.toString().substring(0, 16)}'
                                          : 'Last updated: ${_plan!.updatedAt.toString().substring(0, 16)}',
                                  style: const TextStyle(
                                    color: Color(0xFFFFD700),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ],
                          ],
                        ),
                      ),
                    ),
                    if (_plan != null && _plan!.entries.isNotEmpty) ...[
                      Text(
                        lang == 'PL'
                            ? 'Ćwiczenia (${_plan!.entries.length})'
                            : lang == 'NO'
                                ? 'Øvelser (${_plan!.entries.length})'
                                : 'Exercises (${_plan!.entries.length})',
                        style: const TextStyle(
                          color: Color(0xFFFFD700),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ..._plan!.entries.map((entry) {
                        return Card(
                          color: const Color(0xFF0B2E5A).withValues(alpha: 0.5),
                          margin: const EdgeInsets.only(bottom: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(
                              color: widget.themeColor.withValues(alpha: 0.3),
                            ),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            title: Text(
                              entry.exercise,
                              style: const TextStyle(
                                color: Color(0xFFFFD700),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              entry.timeSeconds > 0
                                  ? '${entry.sets} ${lang == 'PL' ? 'serie' : lang == 'NO' ? 'sett' : 'sets'} × ${entry.timeSeconds}s | ${lang == 'PL' ? 'Przerwa' : lang == 'NO' ? 'Pause' : 'Rest'}: ${entry.restSeconds}s'
                                  : '${entry.sets} ${lang == 'PL' ? 'serie' : lang == 'NO' ? 'sett' : 'sets'} | ${lang == 'PL' ? 'Przerwa' : lang == 'NO' ? 'Pause' : 'Rest'}: ${entry.restSeconds}s',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.bar_chart,
                                  color: Color(0xFFFFD700)),
                              onPressed: () => _showExerciseProgress(
                                  context, entry.exercise),
                            ),
                          ),
                        );
                      }),
                    ],
                  ],
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddExerciseToClientPlan(context),
        backgroundColor: const Color(0xFFFFD700),
        icon: const Icon(Icons.add, color: Color(0xFF0B2E5A)),
        label: Text(
          lang == 'PL'
              ? 'Dodaj ćwiczenie'
              : lang == 'NO'
                  ? 'Legg til øvelse'
                  : 'Add exercise',
          style: const TextStyle(
            color: Color(0xFF0B2E5A),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _showAddExerciseToClientPlan(BuildContext context) {
    final lang = globalLanguage;

    // Show category selection dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0B2E5A),
        title: Text(
          lang == 'PL'
              ? 'Wybierz kategorię'
              : lang == 'NO'
                  ? 'Velg kategori'
                  : 'Select category',
          style: const TextStyle(
            color: Color(0xFFFFD700),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: kCategoryNames.keys
                .where((cat) => cat != 'PLAN')
                .map((category) {
              return Card(
                color: const Color(0xFF0B2E5A).withValues(alpha: 0.8),
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: const BorderSide(
                    color: Color(0xFFFFD700),
                    width: 1,
                  ),
                ),
                child: ListTile(
                  title: Text(
                    localizedCategoryName(category, lang),
                    style: const TextStyle(
                      color: Color(0xFFFFD700),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    color: Color(0xFFFFD700),
                    size: 16,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _showExerciseSelectionForCategory(context, category);
                  },
                ),
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              Translations.get('cancel', language: lang),
              style: const TextStyle(color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }

  void _showExerciseSelectionForCategory(
      BuildContext context, String category) async {
    final lang = globalLanguage;

    // Load exercises from default list for this category
    final exercises = kDefaultExercises[category] ?? [];

    if (exercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            lang == 'PL'
                ? 'Brak ćwiczeń w tej kategorii'
                : lang == 'NO'
                    ? 'Ingen øvelser i denne kategorien'
                    : 'No exercises in this category',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0B2E5A),
        title: Text(
          '${localizedCategoryName(category, lang)} - ${lang == 'PL' ? 'Wybierz ćwiczenie' : lang == 'NO' ? 'Velg øvelse' : 'Select exercise'}',
          style: const TextStyle(
            color: Color(0xFFFFD700),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: exercises.length,
            itemBuilder: (context, index) {
              final exerciseFull = exercises[index];
              // Exercise name is the full string including translations
              return Card(
                color: const Color(0xFF0B2E5A).withValues(alpha: 0.8),
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: const BorderSide(
                    color: Color(0xFFFFD700),
                    width: 1,
                  ),
                ),
                child: ListTile(
                  title: Text(
                    localizedExerciseName(exerciseFull, lang),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  trailing: const Icon(
                    Icons.add_circle,
                    color: Color(0xFFFFD700),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _showAddExerciseParameters(context, exerciseFull, category);
                  },
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              Translations.get('cancel', language: lang),
              style: const TextStyle(color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddExerciseParameters(
      BuildContext context, String exerciseName, String category) {
    final lang = globalLanguage;
    final setsController = TextEditingController(text: '3');
    final restController = TextEditingController(text: '90');
    final timeController = TextEditingController(text: '60');

    // Extract Polish name (first part before ◆)
    String polishName = exerciseName;
    if (exerciseName.contains(' ◆ ')) {
      polishName = exerciseName.split(' ◆ ')[0].trim();
    } else if (exerciseName.contains(' � ')) {
      polishName = exerciseName.split(' � ')[0].trim();
    }

    // Check if exercise is time-based
    bool isTimeBased = kTimeBasedExercises.contains(polishName) ||
        kTimeBasedExercises.contains(exerciseName);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF0B2E5A),
          title: Text(
            localizedExerciseName(exerciseName, lang),
            style: const TextStyle(
              color: Color(0xFFFFD700),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Toggle for time-based exercise
                Row(
                  children: [
                    Checkbox(
                      value: isTimeBased,
                      activeColor: const Color(0xFFFFD700),
                      checkColor: const Color(0xFF0B2E5A),
                      onChanged: (value) {
                        setDialogState(() {
                          isTimeBased = value ?? false;
                        });
                      },
                    ),
                    Text(
                      lang == 'PL'
                          ? 'Ćwiczenie czasowe'
                          : lang == 'NO'
                              ? 'Tidsbasert øvelse'
                              : 'Time-based exercise',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: setsController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: lang == 'PL'
                        ? 'Liczba serii'
                        : lang == 'NO'
                            ? 'Antall sett'
                            : 'Number of sets',
                    labelStyle: const TextStyle(color: Color(0xFFFFD700)),
                    prefixIcon: const Icon(Icons.fitness_center,
                        color: Color(0xFFFFD700)),
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFFFD700)),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide:
                          BorderSide(color: Color(0xFFFFD700), width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (isTimeBased)
                  TextField(
                    controller: timeController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: lang == 'PL'
                          ? 'Czas ćwiczenia (sekundy)'
                          : lang == 'NO'
                              ? 'Øvelsestid (sekunder)'
                              : 'Exercise time (seconds)',
                      labelStyle: const TextStyle(color: Color(0xFFFFD700)),
                      prefixIcon:
                          const Icon(Icons.timer, color: Color(0xFFFFD700)),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFFFD700)),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide:
                            BorderSide(color: Color(0xFFFFD700), width: 2),
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                TextField(
                  controller: restController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: lang == 'PL'
                        ? 'Czas przerwy (sekundy)'
                        : lang == 'NO'
                            ? 'Pausetid (sekunder)'
                            : 'Rest time (seconds)',
                    labelStyle: const TextStyle(color: Color(0xFFFFD700)),
                    prefixIcon:
                        const Icon(Icons.schedule, color: Color(0xFFFFD700)),
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFFFD700)),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide:
                          BorderSide(color: Color(0xFFFFD700), width: 2),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                Translations.get('cancel', language: lang),
                style: const TextStyle(color: Colors.white70),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final sets = int.tryParse(setsController.text) ?? 3;
                final rest = int.tryParse(restController.text) ?? 90;
                final time = int.tryParse(timeController.text) ?? 0;

                Navigator.pop(context);

                // Add exercise to client plan
                await _addExerciseToClientPlan(
                  exerciseName,
                  category,
                  sets,
                  rest,
                  isTimeBased ? time : 0,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD700),
                foregroundColor: const Color(0xFF0B2E5A),
              ),
              child: Text(
                Translations.get('add', language: lang),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addExerciseToClientPlan(
    String exerciseName,
    String category,
    int sets,
    int restSeconds,
    int timeSeconds,
  ) async {
    final lang = globalLanguage;

    try {
      // Extract only Polish name (first part before ◆)
      String cleanExerciseName = exerciseName;
      if (exerciseName.contains(' ◆ ')) {
        cleanExerciseName = exerciseName.split(' ◆ ')[0].trim();
      }

      // Create new entry with clean name
      final newEntry = ClientPlanEntry(
        category: category,
        exercise: cleanExerciseName,
        sets: sets,
        restSeconds: restSeconds,
        timeSeconds: timeSeconds,
      );

      // Update plan with new entry
      final updatedEntries = [...?_plan?.entries, newEntry];
      final updatedPlan = ClientPlan(
        title: _plan?.title ?? 'Training Plan',
        notes: _plan?.notes ?? '',
        entries: updatedEntries,
        updatedAt: DateTime.now(),
      );

      // Save to Firestore
      await PlanAccessController.instance.savePlanForEmail(
        widget.clientEmail,
        updatedPlan,
      );

      // Reload plan
      await _loadClientPlan();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              lang == 'PL'
                  ? 'Ćwiczenie dodane do planu'
                  : lang == 'NO'
                      ? 'Øvelse lagt til planen'
                      : 'Exercise added to plan',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${Translations.get('error', language: lang)}: ${e.toString()}',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

/// Ekran podsumowania postępów klienta
class ClientProgressScreen extends StatelessWidget {
  final String clientEmail;
  final Map<String, List<ExerciseLog>> progressData;
  final Color themeColor;

  const ClientProgressScreen({
    super.key,
    required this.clientEmail,
    required this.progressData,
    required this.themeColor,
  });

  @override
  Widget build(BuildContext context) {
    final lang = globalLanguage;
    final sortedExercises = progressData.keys.toList()
      ..sort((a, b) => a.compareTo(b));

    return Scaffold(
      appBar: buildCustomAppBar(context, accentColor: themeColor),
      body: GymBackgroundWithFitness(
        goldDumbbells: true,
        backgroundImage: 'assets/tlo.png',
        backgroundImageOpacity: 0.3,
        gradientColors: const [
          Color(0xFF0B2E5A),
          Color(0xFF0A2652),
          Color(0xFF0E3D8C),
        ],
        accentColor: themeColor,
        child: progressData.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.history,
                      color: Color(0xFFFFD700),
                      size: 64,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      lang == 'PL'
                          ? 'Brak zapisanych postępów'
                          : lang == 'NO'
                              ? 'Ingen lagret fremgang'
                              : 'No saved progress',
                      style: const TextStyle(
                        color: Color(0xFFFFD700),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      lang == 'PL'
                          ? 'Klient jeszcze nie zapisał żadnych ćwiczeń'
                          : lang == 'NO'
                              ? 'Klienten har ikke lagret noen øvelser ennå'
                              : 'Client has not saved any exercises yet',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header card
                    Card(
                      color: const Color(0xFF0B2E5A).withValues(alpha: 0.6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(
                          color: Color(0xFFFFD700),
                          width: 2,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.insights,
                                  color: Color(0xFF2ECC71),
                                  size: 28,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    lang == 'PL'
                                        ? 'Postępy klienta'
                                        : lang == 'NO'
                                            ? 'Klientens fremgang'
                                            : 'Client Progress',
                                    style: const TextStyle(
                                      color: Color(0xFFFFD700),
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              clientEmail,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                _StatCard(
                                  icon: Icons.fitness_center,
                                  value: '${sortedExercises.length}',
                                  label: lang == 'PL'
                                      ? 'Ćwiczeń'
                                      : lang == 'NO'
                                          ? 'Øvelser'
                                          : 'Exercises',
                                ),
                                const SizedBox(width: 12),
                                _StatCard(
                                  icon: Icons.repeat,
                                  value:
                                      '${progressData.values.fold<int>(0, (sum, logs) => sum + logs.length)}',
                                  label: lang == 'PL'
                                      ? 'Zapisów'
                                      : lang == 'NO'
                                          ? 'Oppføringer'
                                          : 'Entries',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      lang == 'PL'
                          ? 'Historia ćwiczeń'
                          : lang == 'NO'
                              ? 'Øvelseshistorikk'
                              : 'Exercise History',
                      style: const TextStyle(
                        color: Color(0xFFFFD700),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Exercise cards
                    ...sortedExercises.map((exerciseName) {
                      final logs = progressData[exerciseName]!;
                      final latestLog = logs.isNotEmpty ? logs.last : null;
                      final isTimeBased = latestLog?.durationSeconds != null &&
                          latestLog!.durationSeconds > 0;

                      return Card(
                        color: const Color(0xFF0B2E5A).withValues(alpha: 0.5),
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(
                            color: themeColor.withValues(alpha: 0.4),
                          ),
                        ),
                        child: ExpansionTile(
                          tilePadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          leading: CircleAvatar(
                            backgroundColor: themeColor,
                            child: Text(
                              '${logs.length}',
                              style: const TextStyle(
                                color: Color(0xFF0B2E5A),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            localizedExerciseName(exerciseName, lang),
                            style: const TextStyle(
                              color: Color(0xFFFFD700),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: latestLog != null
                              ? Text(
                                  isTimeBased
                                      ? '${lang == 'PL' ? 'Ostatni' : lang == 'NO' ? 'Siste' : 'Last'}: ${latestLog.durationSeconds}s'
                                      : '${lang == 'PL' ? 'Ostatni' : lang == 'NO' ? 'Siste' : 'Last'}: ${latestLog.weight} kg × ${latestLog.reps}',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                )
                              : null,
                          iconColor: themeColor,
                          collapsedIconColor: themeColor,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              child: Column(
                                children: logs.reversed.take(10).map((log) {
                                  final isTime = log.durationSeconds > 0;
                                  final value = isTime
                                      ? '${log.durationSeconds}s'
                                      : '${log.weight} kg × ${log.reps}';
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          log.date,
                                          style: const TextStyle(
                                            color: Colors.white54,
                                            fontSize: 12,
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              '${lang == 'PL' ? 'S' : lang == 'NO' ? 'S' : 'S'}${log.sets}',
                                              style: const TextStyle(
                                                color: Color(0xFFFFD700),
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              value,
                                              style: const TextStyle(
                                                color: Color(0xFF2ECC71),
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                            if (logs.length > 10)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Text(
                                  lang == 'PL'
                                      ? '... i ${logs.length - 10} więcej'
                                      : lang == 'NO'
                                          ? '... og ${logs.length - 10} mer'
                                          : '... and ${logs.length - 10} more',
                                  style: const TextStyle(
                                    color: Colors.white54,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF0E3D8C).withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: const Color(0xFFFFD700).withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF2ECC71), size: 24),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    color: Color(0xFFFFD700),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
