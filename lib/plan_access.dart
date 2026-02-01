/*
 * MIGRATION GUIDE FOR EXISTING USERS
 * 
 * After implementing the new authentication system with UserProfile and separate
 * coach/client login flows, you need to create user profiles in the 'users' collection
 * for all existing Firebase Auth accounts.
 * 
 * Run this migration once from your Firebase Console or Admin SDK:
 * 
 * For each existing Firebase Auth user:
 *   1. Get their email address
 *   2. Determine their role (coach or client)
 *      - Coaches: karolszymek1402@gmail.com and any other admin accounts
 *      - All others: client
 *   3. Create a document in the 'users' collection with:
 *      - Document ID: email with dots and @ replaced by hyphens
 *        (e.g., "test-email-com" for "test@email.com")
 *      - Fields:
 *        * email: original email address
 *        * role: "coach" or "client"
 *        * displayName: null or user's display name
 *        * createdAt: current timestamp (ISO 8601 string)
 * 
 * Example Firestore document structure:
 * 
 * users/karolszymek1402-gmail-com:
 *   email: "karolszymek1402@gmail.com"
 *   role: "coach"
 *   displayName: null
 *   createdAt: "2025-01-21T12:00:00.000Z"
 * 
 * users/client-example-com:
 *   email: "client@example.com"
 *   role: "client"
 *   displayName: null
 *   createdAt: "2025-01-21T12:00:00.000Z"
 * 
 * After migration, all users will be able to log in using the appropriate
 * login screen (CoachLoginScreen or ClientLoginScreen).
 */

import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum PlanUserRole { anonymous, client, coach }

const List<String> kCoachEmails = [
  'karolszymek1402@gmail.com',
  'karolszymek1402@gimail.com',
];

bool _isCoachEmail(String email) {
  final lower = email.trim().toLowerCase();
  return kCoachEmails.any((coach) => coach.toLowerCase() == lower);
}

String _normalizeCoachEmail(String email) {
  final trimmed = email.trim();
  final lower = trimmed.toLowerCase();

  if (lower == 'karolszymek1402@gimail.com') {
    return 'karolszymek1402@gmail.com';
  }

  return trimmed;
}

class UserProfile {
  const UserProfile({
    required this.email,
    required this.role,
    this.displayName,
    this.createdAt,
  });

  final String email;
  final PlanUserRole role;
  final String? displayName;
  final DateTime? createdAt;

  Map<String, dynamic> toMap() => {
        'email': email,
        'role': role.name,
        'displayName': displayName,
        'createdAt': createdAt?.toIso8601String(),
      };

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      email: map['email'] as String? ?? '',
      role: PlanUserRole.values.firstWhere(
        (e) => e.name == (map['role'] as String? ?? 'client'),
        orElse: () => PlanUserRole.client,
      ),
      displayName: map['displayName'] as String?,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'] as String)
          : null,
    );
  }
}

class ClientPlanEntry {
  const ClientPlanEntry({
    this.category,
    required this.exercise,
    required this.sets,
    required this.restSeconds,
    this.timeSeconds = 0,
    this.dayOfWeek = 0,
    this.note = '',
  });

  final String? category;
  final String exercise;
  final int sets;
  final int restSeconds;
  final int timeSeconds;
  final int dayOfWeek; // 0=Poniedziałek, 1=Wtorek, ..., 6=Niedziela
  final String note; // Notatka trenera dla klienta

  Map<String, dynamic> toMap() => {
        if (category != null && category!.trim().isNotEmpty)
          'category': category,
        'exercise': exercise,
        'sets': sets,
        'restSeconds': restSeconds,
        'timeSeconds': timeSeconds,
        'dayOfWeek': dayOfWeek,
        'note': note,
      };

  factory ClientPlanEntry.fromMap(Map<String, dynamic> map) {
    return ClientPlanEntry(
      category: map['category'] as String?,
      exercise: map['exercise'] as String? ?? '',
      sets: (map['sets'] as num?)?.toInt() ?? 0,
      restSeconds: (map['restSeconds'] as num?)?.toInt() ?? 0,
      timeSeconds: (map['timeSeconds'] as num?)?.toInt() ?? 0,
      dayOfWeek: (map['dayOfWeek'] as num?)?.toInt() ?? 0,
      note: (map['note'] as String?) ?? '',
    );
  }

  ClientPlanEntry copyWith({
    String? category,
    String? exercise,
    int? sets,
    int? restSeconds,
    int? timeSeconds,
    int? dayOfWeek,
    String? note,
  }) {
    return ClientPlanEntry(
      category: category ?? this.category,
      exercise: exercise ?? this.exercise,
      sets: sets ?? this.sets,
      restSeconds: restSeconds ?? this.restSeconds,
      timeSeconds: timeSeconds ?? this.timeSeconds,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      note: note ?? this.note,
    );
  }
}

class ClientPlan {
  const ClientPlan({
    required this.title,
    required this.notes,
    required this.entries,
    required this.updatedAt,
    this.restDays = const [],
  });

  final String title;
  final String notes;
  final List<ClientPlanEntry> entries;
  final DateTime updatedAt;
  final List<int> restDays; // Dni wolne: 0=Poniedziałek, ..., 6=Niedziela

  Map<String, dynamic> toMap() => {
        'title': title,
        'notes': notes,
        'updatedAt': updatedAt.toIso8601String(),
        'entries': entries.map((e) => e.toMap()).toList(growable: false),
        'restDays': restDays,
      };

  factory ClientPlan.fromMap(Map<String, dynamic> map) {
    final rawEntries = map['entries'];
    final rawRestDays = map['restDays'];
    return ClientPlan(
      title: map['title'] as String? ?? '',
      notes: map['notes'] as String? ?? '',
      updatedAt: DateTime.tryParse(map['updatedAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      entries: rawEntries is Iterable
          ? rawEntries
              .map((e) => ClientPlanEntry.fromMap(
                    Map<String, dynamic>.from(e as Map),
                  ))
              .toList(growable: false)
          : const [],
      restDays: rawRestDays is Iterable
          ? rawRestDays.map((e) => (e as num).toInt()).toList(growable: false)
          : const [],
    );
  }
}

@immutable
class PlanAccessState {
  const PlanAccessState({
    this.userEmail,
    this.role = PlanUserRole.anonymous,
    this.activePlan,
    this.planLoading = false,
  });

  final String? userEmail;
  final PlanUserRole role;
  final ClientPlan? activePlan;
  final bool planLoading;

  bool get isAuthenticated => userEmail != null && userEmail!.isNotEmpty;

  PlanAccessState copyWith({
    String? userEmail,
    PlanUserRole? role,
    ClientPlan? activePlan,
    bool? planLoading,
    bool clearPlan = false,
  }) {
    return PlanAccessState(
      userEmail: userEmail ?? this.userEmail,
      role: role ?? this.role,
      activePlan: clearPlan ? null : (activePlan ?? this.activePlan),
      planLoading: planLoading ?? this.planLoading,
    );
  }
}

class PlanAccessController {
  PlanAccessController._();
  static final PlanAccessController instance = PlanAccessController._();

  final ValueNotifier<PlanAccessState> notifier =
      ValueNotifier(const PlanAccessState());

  bool _initialized = false;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _planSubscription;
  bool _historySyncInProgress = false;
  String? _historySyncedForEmail;
  static const int _historyChunkSize = 10;

  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      FirebaseFirestore.instance.collection('users');

  CollectionReference<Map<String, dynamic>> get _legacyPlansCollection =>
      FirebaseFirestore.instance.collection('plans');

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    FirebaseAuth.instance.authStateChanges().listen(_handleAuthChanged);
    _handleAuthChanged(FirebaseAuth.instance.currentUser);
  }

  Future<void> signIn(String email, String password) async {
    final trimmedEmail = _normalizeCoachEmail(email);
    final trimmedPassword = password.trim();
    final normalizedPassword = trimmedPassword.length < 6
        ? trimmedPassword.padRight(6, '0')
        : trimmedPassword;

    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(
        email: trimmedEmail,
        password: normalizedPassword,
      )
          .timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception(
              'Przekroczono czas oczekiwania. Sprawdź połączenie z internetem.');
        },
      );
    } on FirebaseAuthException catch (e) {
      // Translate Firebase error codes to user-friendly messages
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'Nie znaleziono użytkownika z tym adresem email';
          break;
        case 'wrong-password':
        case 'invalid-credential':
          message = 'Nieprawidłowe hasło';
          break;
        case 'invalid-email':
          message = 'Nieprawidłowy format adresu email';
          break;
        case 'user-disabled':
          message = 'Konto zostało zablokowane';
          break;
        case 'too-many-requests':
          message = 'Zbyt wiele prób. Spróbuj ponownie za chwilę';
          break;
        case 'network-request-failed':
          message = 'Brak połączenia z internetem';
          break;
        default:
          message = 'Błąd logowania: ${e.code} - ${e.message}';
      }
      throw Exception(message);
    } catch (e) {
      // Catch any other exceptions
      if (e.toString().contains('timeout') ||
          e.toString().contains('Przekroczono')) {
        rethrow;
      }
      throw Exception('Błąd logowania: $e');
    }

    // Resolve role and update state directly
    final role = await _resolveRole(trimmedEmail);

    // Update state immediately after successful login
    notifier.value = notifier.value.copyWith(
      userEmail: trimmedEmail,
      role: role,
      planLoading: role != PlanUserRole.coach,
      clearPlan: role == PlanUserRole.coach,
    );

    // If client, set up plan watching
    if (role == PlanUserRole.client) {
      await _syncLocalHistoryIfNeeded(trimmedEmail);
      await _ensureClientPlan(trimmedEmail);
      _watchPlan(trimmedEmail);
    } else {
      notifier.value = notifier.value.copyWith(planLoading: false);
    }

    debugPrint(
        '🔐 signIn: Updated state - email: $trimmedEmail, role: $role, isAuthenticated: ${notifier.value.isAuthenticated}');
  }

  Future<void> signInAsCoach(String email, String password) async {
    await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email.trim(), password: password);

    // Verify coach role
    final userDoc = await _usersCollection.doc(_docIdFromEmail(email)).get();
    final userData = userDoc.data();

    if (userData == null) {
      await FirebaseAuth.instance.signOut();
      throw Exception('User profile not found');
    }

    final profile = UserProfile.fromMap(userData);
    if (profile.role != PlanUserRole.coach) {
      await FirebaseAuth.instance.signOut();
      throw Exception('Access denied: Coach account required');
    }
  }

  Future<void> signInAsClient(String email, String password) async {
    final trimmedEmail = email.trim();
    final trimmedPassword = password.trim();
    final normalizedPassword = trimmedPassword.length < 6
        ? trimmedPassword.padRight(6, '0')
        : trimmedPassword;

    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: trimmedEmail,
      password: normalizedPassword,
    );

    // Verify client role
    final userDocRef = _usersCollection.doc(_docIdFromEmail(trimmedEmail));
    final userDoc = await userDocRef.get();
    final userData = userDoc.data();

    if (userData == null) {
      final newProfile = UserProfile(
        email: trimmedEmail,
        role: PlanUserRole.client,
        createdAt: DateTime.now(),
      );
      await userDocRef.set(newProfile.toMap());
    } else {
      final profile = UserProfile.fromMap(userData);
      if (profile.role != PlanUserRole.client) {
        await FirebaseAuth.instance.signOut();
        throw Exception('Access denied: Client account required');
      }
    }

    await _ensureClientPlan(trimmedEmail);
  }

  Future<void> signOut() async {
    _planSubscription?.cancel();
    _planSubscription = null;
    _historySyncedForEmail = null;

    // Reset state immediately before Firebase signOut
    notifier.value = const PlanAccessState();

    await FirebaseAuth.instance.signOut();
    debugPrint('🔐 signOut: State reset, user logged out');
  }

  Future<void> logout() async => signOut();

  Future<void> changePassword(
      String currentPassword, String newPassword) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.email == null) {
      throw Exception('No user logged in');
    }

    // Reauthenticate user with current password
    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: currentPassword,
    );

    try {
      await user.reauthenticateWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        throw Exception('Current password is incorrect');
      }
      throw Exception('Authentication failed: ${e.message}');
    } catch (e) {
      throw Exception('Current password is incorrect');
    }

    // Update password
    try {
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw Exception('Failed to update password: ${e.message}');
    }
  }

  Future<void> createClientAccount(String email, String password,
      {String? displayName}) async {
    // Use a secondary Firebase app so the coach session stays active while creating a client.
    final secondaryApp = await Firebase.initializeApp(
      name: 'client_creator',
      options: Firebase.app().options,
    );

    final secondaryAuth = FirebaseAuth.instanceFor(app: secondaryApp);

    // Ensure password meets Firebase minimum length (6). If empty, fall back to zeros.
    final trimmedEmail = email.trim();
    final trimmedPassword = password.trim();
    final normalizedPassword =
        trimmedPassword.isEmpty ? '000000' : trimmedPassword;
    if (normalizedPassword.length < 6) {
      throw Exception('Password must be at least 6 characters');
    }

    try {
      // Create new user account without disturbing the active coach session
      await secondaryAuth.createUserWithEmailAndPassword(
        email: trimmedEmail,
        password: normalizedPassword,
      );

      // Create user profile in Firestore using MAIN instance for proper sync
      final userProfile = UserProfile(
        email: trimmedEmail,
        role: PlanUserRole.client,
        displayName:
            displayName?.trim().isNotEmpty == true ? displayName!.trim() : null,
        createdAt: DateTime.now(),
      );

      await _usersCollection
          .doc(_docIdFromEmail(trimmedEmail))
          .set(userProfile.toMap());

      // Create empty plan for the new client using MAIN instance
      final newPlan = ClientPlan(
        title: 'New Training Plan',
        notes: '',
        entries: [],
        updatedAt: DateTime.now(),
      );

      final planData = newPlan.toMap();
      planData['email'] = trimmedEmail;

      await _plansCollection.doc(_docIdFromEmail(trimmedEmail)).set(planData);
    } catch (e) {
      throw Exception('Failed to create client: ${e.toString()}');
    } finally {
      await secondaryApp.delete();
    }
  }

  Future<ClientPlan?> fetchPlanForEmail(String email) async {
    try {
      final doc = await _plansCollection.doc(_docIdFromEmail(email)).get();
      debugPrint(
          '[PlanAccess] fetchPlanForEmail: email=$email, docId=${_docIdFromEmail(email)}, exists=${doc.exists}');
      if (!doc.exists || doc.data() == null) {
        debugPrint('[PlanAccess] No plan found, loading from cache');
        return await _loadCachedPlan(email);
      }
      debugPrint('[PlanAccess] Plan data: ${doc.data()}');
      final plan = ClientPlan.fromMap(doc.data()!);
      debugPrint(
          '[PlanAccess] Parsed plan: title=${plan.title}, entries=${plan.entries.length}');
      await _cachePlan(email, plan);
      return plan;
    } catch (e) {
      debugPrint('[PlanAccess] Error loading plan: $e');
      return await _loadCachedPlan(email);
    }
  }

  Future<List<String>> fetchAllClientEmails() async {
    try {
      // Fetch all users with client role
      final snapshot =
          await _usersCollection.where('role', isEqualTo: 'client').get();

      final emails = <String>[];
      for (var doc in snapshot.docs) {
        final profile = UserProfile.fromMap(doc.data());
        emails.add(profile.email);
      }

      return emails;
    } catch (_) {
      return [];
    }
  }

  /// Fetch all client profiles (with displayName)
  Future<List<UserProfile>> fetchAllClients() async {
    try {
      final snapshot =
          await _usersCollection.where('role', isEqualTo: 'client').get();

      final clients = <UserProfile>[];
      for (var doc in snapshot.docs) {
        final profile = UserProfile.fromMap(doc.data());
        clients.add(profile);
      }

      return clients;
    } catch (_) {
      return [];
    }
  }

  /// Delete a client and all their data (profile, plan, history)
  Future<void> deleteClient(String clientEmail) async {
    final docId = _docIdFromEmail(clientEmail);

    try {
      // Delete user profile
      await _usersCollection.doc(docId).delete();

      // Delete client plan
      await _plansCollection.doc(docId).delete();

      // Delete client exercise history (subcollection)
      final historyRef = FirebaseFirestore.instance
          .collection('clientHistory')
          .doc(docId)
          .collection('exercises');
      final historyDocs = await historyRef.get();
      for (var doc in historyDocs.docs) {
        await doc.reference.delete();
      }
      await FirebaseFirestore.instance
          .collection('clientHistory')
          .doc(docId)
          .delete();

      // Clear cached plan
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('plan_$clientEmail');
    } catch (_) {
      rethrow;
    }
  }

  /// Update client display name
  Future<void> updateClientDisplayName(
      String email, String? displayName) async {
    final docId = _docIdFromEmail(email);
    try {
      await _usersCollection.doc(docId).update({
        'displayName':
            displayName?.trim().isNotEmpty == true ? displayName!.trim() : null,
      });
    } catch (_) {
      rethrow;
    }
  }

  /// Update client email (rename client)
  Future<void> updateClientEmail(String oldEmail, String newEmail) async {
    final oldDocId = _docIdFromEmail(oldEmail);
    final newDocId = _docIdFromEmail(newEmail);

    try {
      // Get old profile and create new one with updated email
      final profileDoc = await _usersCollection.doc(oldDocId).get();
      if (profileDoc.exists) {
        final data = profileDoc.data()!;
        data['email'] = newEmail.trim();
        await _usersCollection.doc(newDocId).set(data);
        await _usersCollection.doc(oldDocId).delete();
      }

      // Move plan to new doc
      final planDoc = await _plansCollection.doc(oldDocId).get();
      if (planDoc.exists) {
        final data = planDoc.data()!;
        data['email'] = newEmail.trim();
        await _plansCollection.doc(newDocId).set(data);
        await _plansCollection.doc(oldDocId).delete();
      }

      // Move history to new doc
      final oldHistoryRef =
          FirebaseFirestore.instance.collection('clientHistory').doc(oldDocId);
      final newHistoryRef =
          FirebaseFirestore.instance.collection('clientHistory').doc(newDocId);

      final historyDocs = await oldHistoryRef.collection('exercises').get();
      for (var doc in historyDocs.docs) {
        await newHistoryRef.collection('exercises').doc(doc.id).set(doc.data());
        await doc.reference.delete();
      }
      await oldHistoryRef.delete();

      // Update cached plan
      final prefs = await SharedPreferences.getInstance();
      final cachedPlan = prefs.getString('plan_$oldEmail');
      if (cachedPlan != null) {
        await prefs.setString('plan_$newEmail', cachedPlan);
        await prefs.remove('plan_$oldEmail');
      }
    } catch (_) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> fetchClientExerciseHistory(
      String clientEmail, String exerciseName) async {
    try {
      final docId = _docIdFromEmail(clientEmail);
      final exerciseId = _exerciseDocId(exerciseName);
      final doc = await FirebaseFirestore.instance
          .collection('clientHistory')
          .doc(docId)
          .collection('exercises')
          .doc(exerciseId)
          .get();
      return doc.data();
    } catch (_) {
      return null;
    }
  }

  Future<void> appendClientExerciseHistory(
    String clientEmail,
    String exerciseName,
    Map<String, dynamic> log,
  ) async {
    await _appendExerciseLogs(clientEmail, exerciseName, [log]);
  }

  Future<void> updateClientPlan(String email,
      {String? title, String? notes}) async {
    final docId = _docIdFromEmail(email);
    final doc = await _plansCollection.doc(docId).get();

    if (doc.exists) {
      final data = doc.data()!;
      if (title != null) data['title'] = title;
      if (notes != null) data['notes'] = notes;
      data['updatedAt'] = DateTime.now().toIso8601String();
      await _plansCollection.doc(docId).set(data);
    } else {
      // Create new plan if doesn't exist
      final newPlan = ClientPlan(
        title: title ?? 'New Training Plan',
        notes: notes ?? '',
        entries: [],
        updatedAt: DateTime.now(),
      );
      await savePlanForEmail(email, newPlan);
    }
  }

  Future<void> updateClientPlanEntries(
      String email, List<ClientPlanEntry> entries) async {
    final docId = _docIdFromEmail(email);
    final doc = await _plansCollection.doc(docId).get();

    if (doc.exists) {
      final data = doc.data()!;
      data['entries'] = entries.map((e) => e.toMap()).toList();
      data['updatedAt'] = DateTime.now().toIso8601String();
      await _plansCollection.doc(docId).set(data);
    } else {
      // Create new plan with entries
      final newPlan = ClientPlan(
        title: 'New Training Plan',
        notes: '',
        entries: entries,
        updatedAt: DateTime.now(),
      );
      await savePlanForEmail(email, newPlan);
    }
  }

  Future<void> updateClientPlanRestDays(
      String email, List<int> restDays) async {
    final docId = _docIdFromEmail(email);
    final doc = await _plansCollection.doc(docId).get();

    if (doc.exists) {
      final data = doc.data()!;
      data['restDays'] = restDays;
      data['updatedAt'] = DateTime.now().toIso8601String();
      await _plansCollection.doc(docId).set(data);
    } else {
      // Create new plan with restDays
      final newPlan = ClientPlan(
        title: 'New Training Plan',
        notes: '',
        entries: [],
        updatedAt: DateTime.now(),
        restDays: restDays,
      );
      await savePlanForEmail(email, newPlan);
    }
  }

  /// Resetuje cały progres (historię ćwiczeń) dla danego klienta
  Future<void> resetClientProgress(String clientEmail) async {
    final docId = _docIdFromEmail(clientEmail);

    // Pobierz wszystkie dokumenty ćwiczeń z historii klienta
    final exercisesCollection = FirebaseFirestore.instance
        .collection('clientHistory')
        .doc(docId)
        .collection('exercises');

    final snapshot = await exercisesCollection.get();

    // Usuń każdy dokument ćwiczenia
    final batch = FirebaseFirestore.instance.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  Future<void> savePlanForEmail(String email, ClientPlan plan) async {
    final planData = plan.toMap();
    planData['email'] = email.trim(); // Always include email field
    await _plansCollection.doc(_docIdFromEmail(email)).set(planData);
    await _cachePlan(email, plan);
  }

  CollectionReference<Map<String, dynamic>> get _plansCollection =>
      FirebaseFirestore.instance.collection('clientPlans');

  String _cacheKeyForEmail(String email) =>
      'cached_plan_${email.trim().toLowerCase()}';

  Future<void> _cachePlan(String email, ClientPlan plan) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cacheKeyForEmail(email), jsonEncode(plan.toMap()));
    } catch (_) {}
  }

  Future<ClientPlan?> _loadCachedPlan(String email) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_cacheKeyForEmail(email));
      if (raw == null) return null;
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return ClientPlan.fromMap(map);
    } catch (_) {
      return null;
    }
  }

  Future<PlanUserRole> _resolveRole(String? email) async {
    if (email == null || email.isEmpty) {
      return PlanUserRole.anonymous;
    }

    if (_isCoachEmail(email)) {
      return PlanUserRole.coach;
    }

    try {
      final userDocRef = _usersCollection.doc(_docIdFromEmail(email));
      final userDoc = await userDocRef.get();
      final userData = userDoc.data();

      if (userData == null) {
        final profile = UserProfile(
          email: email.trim(),
          role: PlanUserRole.client,
          createdAt: DateTime.now(),
        );
        await userDocRef.set(profile.toMap());
        return PlanUserRole.client;
      }

      final profile = UserProfile.fromMap(userData);
      return profile.role == PlanUserRole.coach
          ? PlanUserRole.coach
          : PlanUserRole.client;
    } catch (_) {
      return PlanUserRole.client;
    }
  }

  void _handleAuthChanged(User? user) async {
    _planSubscription?.cancel();
    if (user == null) {
      _historySyncedForEmail = null;
      notifier.value = const PlanAccessState();
      return;
    }
    final email = user.email ?? '';
    final role = await _resolveRole(email);
    notifier.value = notifier.value.copyWith(
      userEmail: email,
      role: role,
      planLoading: role != PlanUserRole.coach,
      clearPlan: role == PlanUserRole.coach,
    );

    if (role == PlanUserRole.client) {
      await _syncLocalHistoryIfNeeded(email);
      await _ensureClientPlan(email);
      _watchPlan(email);
    } else {
      notifier.value = notifier.value.copyWith(planLoading: false);
    }
  }

  void _watchPlan(String email) {
    notifier.value = notifier.value.copyWith(planLoading: true);
    _planSubscription = _plansCollection
        .doc(_docIdFromEmail(email))
        .snapshots()
        .listen((snapshot) {
      final data = snapshot.data();
      final plan = data == null ? null : ClientPlan.fromMap(data);
      if (plan != null) {
        _cachePlan(email, plan);
      }
      notifier.value = notifier.value.copyWith(
        activePlan: plan,
        planLoading: false,
      );
    }, onError: (_) {
      notifier.value = notifier.value.copyWith(planLoading: false);
    });
  }

  Future<void> _syncLocalHistoryIfNeeded(String email) async {
    if (_historySyncInProgress || _historySyncedForEmail == email) {
      return;
    }
    _historySyncInProgress = true;
    try {
      await _uploadLocalHistoryFromPrefs(email);
      _historySyncedForEmail = email;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('History sync failed for $email: $e');
      }
    } finally {
      _historySyncInProgress = false;
    }
  }

  Future<void> _uploadLocalHistoryFromPrefs(String email) async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    for (final key in keys) {
      if (!key.startsWith('history_')) continue;
      final exerciseName = key.substring('history_'.length);
      if (exerciseName.isEmpty) continue;
      final encodedLogs = prefs.getStringList(key);
      if (encodedLogs == null || encodedLogs.isEmpty) continue;

      final logs = <Map<String, dynamic>>[];
      for (final encoded in encodedLogs) {
        try {
          final decoded = jsonDecode(encoded);
          if (decoded is Map) {
            logs.add(Map<String, dynamic>.from(decoded));
          }
        } catch (e) {
          if (kDebugMode) {
            debugPrint('Failed to decode log for $exerciseName: $e');
          }
        }
      }

      if (logs.isEmpty) continue;
      await _appendExerciseLogs(email, exerciseName, logs);
    }
  }

  Future<void> _appendExerciseLogs(
    String clientEmail,
    String exerciseName,
    List<Map<String, dynamic>> logs,
  ) async {
    if (logs.isEmpty) return;

    final docId = _docIdFromEmail(clientEmail);
    final exerciseId = _exerciseDocId(exerciseName);
    final exerciseRef = FirebaseFirestore.instance
        .collection('clientHistory')
        .doc(docId)
        .collection('exercises')
        .doc(exerciseId);

    final sanitized =
        logs.map((log) => _sanitizeLogMap(log, exerciseName)).toList();
    final timestamp = DateTime.now().toIso8601String();

    for (var i = 0; i < sanitized.length; i += _historyChunkSize) {
      final end = (i + _historyChunkSize) > sanitized.length
          ? sanitized.length
          : i + _historyChunkSize;
      final chunk = sanitized.sublist(i, end);
      await exerciseRef.set(
        {
          'exercise': exerciseName,
          'updatedAt': timestamp,
          'logs': FieldValue.arrayUnion(chunk),
        },
        SetOptions(merge: true),
      );
    }
  }

  Map<String, dynamic> _sanitizeLogMap(
      Map<String, dynamic> source, String exerciseName) {
    final sanitized = <String, dynamic>{
      'date': source['date']?.toString() ?? '',
      'sets': source['sets']?.toString() ?? '',
      'weight': source['weight']?.toString() ?? '',
      'reps': source['reps']?.toString() ?? '',
      'durationSeconds': (source['durationSeconds'] is num)
          ? (source['durationSeconds'] as num).toInt()
          : 0,
      'exercise': source['exercise']?.toString() ?? exerciseName,
    };

    final plannedTime = source['plannedTime'];
    if (plannedTime != null && plannedTime.toString().isNotEmpty) {
      sanitized['plannedTime'] = plannedTime.toString();
    }

    return sanitized;
  }

  String _exerciseDocId(String exerciseName) {
    return exerciseName.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '-');
  }

  String _docIdFromEmail(String email) {
    return email.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '-');
  }

  Future<void> _ensureClientPlan(String email) async {
    final docId = _docIdFromEmail(email);
    final planDoc = await _plansCollection.doc(docId).get();
    if (planDoc.exists && planDoc.data() != null) {
      return;
    }

    final legacyDoc = await _legacyPlansCollection.doc(docId).get();
    if (legacyDoc.exists && legacyDoc.data() != null) {
      await _plansCollection.doc(docId).set(legacyDoc.data()!);
      return;
    }

    final newPlan = ClientPlan(
      title: 'New Training Plan',
      notes: '',
      entries: const [],
      updatedAt: DateTime.now(),
    );
    final planData = newPlan.toMap();
    planData['email'] = email.trim();
    await _plansCollection.doc(docId).set(planData);
  }
}
