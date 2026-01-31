import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'
    show HapticFeedback, Clipboard, ClipboardData;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'js_bridge.dart' as js_bridge;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vibration/vibration.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import 'firebase_options.dart';
import 'plan_access.dart';

String globalLanguage = 'EN';
final ValueNotifier<String> globalLanguageNotifier =
    ValueNotifier<String>(globalLanguage);

void updateGlobalLanguage(String lang) {
  globalLanguage = lang;
  globalLanguageNotifier.value = lang;
}

/// Cache dla SharedPreferences - unikamy wielokrotnego getInstance()
SharedPreferences? _cachedPrefs;

/// Pobierz SharedPreferences z cache lub zainicjalizuj
Future<SharedPreferences> getPrefs() async {
  _cachedPrefs ??= await SharedPreferences.getInstance();
  return _cachedPrefs!;
}

const List<String> kSupportedLanguages = ['EN', 'PL', 'NO'];

class Translations {
  static const Map<String, Map<String, String>> translations = {
    'app_title': {'EN': 'K.S-GYM', 'PL': 'K.S-GYM', 'NO': 'K.S-GYM'},
    'login_for_online_plan': {
      'EN': 'Log in for online plan',
      'PL': 'Zaloguj się po plan online',
      'NO': 'Logg inn for onlineplan'
    },
    'continue_without_login': {
      'EN': 'Continue without login',
      'PL': 'Kontynuuj bez logowania',
      'NO': 'Fortsett uten innlogging'
    },
    'contact': {'EN': 'Contact', 'PL': 'Kontakt', 'NO': 'Kontakt'},
    'plan': {'EN': 'Plan', 'PL': 'Plan', 'NO': 'Plan'},
    'plan_paste_hint': {
      'EN': 'Paste or write your plan here',
      'PL': 'Wklej lub wpisz plan tutaj',
      'NO': 'Lim inn eller skriv planen her'
    },
    'no_data': {
      'EN': 'No data yet',
      'PL': 'Brak danych',
      'NO': 'Ingen data ennå'
    },
    'sets_label': {
      'EN': 'Sets: {count}',
      'PL': 'Serie: {count}',
      'NO': 'Sett: {count}'
    },
    'set_label': {'EN': 'Set', 'PL': 'Seria', 'NO': 'Sett'},
    'kg_label': {'EN': 'KG', 'PL': 'KG', 'NO': 'KG'},
    'reps_label': {'EN': 'Reps', 'PL': 'Powtórzenia', 'NO': 'Reps'},
    'save_set': {'EN': 'Save set', 'PL': 'Zapisz serię', 'NO': 'Lagre sett'},
    'history': {'EN': 'History', 'PL': 'Historia', 'NO': 'Historikk'},
    'no_history': {
      'EN': 'No logs yet. Add your first set.',
      'PL': 'Brak zapisów. Dodaj pierwszą serię.',
      'NO': 'Ingen logger ennå. Legg til ditt første sett.'
    },
    'latest': {'EN': 'Latest', 'PL': 'Ostatnie', 'NO': 'Siste'},
    'no_exercises_yet': {
      'EN': 'No exercises yet. Add one to start.',
      'PL': 'Brak ćwiczeń. Dodaj, aby zacząć.',
      'NO': 'Ingen øvelser ennå. Legg til for å starte.'
    },
    'exercise_db': {
      'EN': 'Exercise library',
      'PL': 'Baza ćwiczeń',
      'NO': 'Øvelsesbibliotek'
    },
    'search_hint': {
      'EN': 'Search exercise...',
      'PL': 'Szukaj ćwiczenia...',
      'NO': 'Søk øvelse...'
    },
    'no_results': {
      'EN': 'No results',
      'PL': 'Brak wyników',
      'NO': 'Ingen treff'
    },
    'add_custom': {
      'EN': 'Add custom exercise',
      'PL': 'Dodaj własne ćwiczenie',
      'NO': 'Legg til egen øvelse'
    },
    'add': {'EN': 'Add', 'PL': 'Dodaj', 'NO': 'Legg til'},
    'add_exercise_title': {
      'EN': 'Add exercise',
      'PL': 'Dodaj ćwiczenie',
      'NO': 'Legg til øvelse'
    },
    'add_exercise_button': {
      'EN': 'Add exercise',
      'PL': 'Dodaj ćwiczenie',
      'NO': 'Legg til øvelse'
    },
    'base_exercises_title': {
      'EN': 'Base exercises in this category',
      'PL': 'Baza ćwiczeń w tej kategorii',
      'NO': 'Grunnøvelser i denne kategorien'
    },
    'stop': {'EN': 'Stop', 'PL': 'Stop', 'NO': 'Stopp'},
    'timer_pause': {'EN': 'Pause', 'PL': 'Pauza', 'NO': 'Pause'},
    'timer_resume': {'EN': 'Resume', 'PL': 'Wznów', 'NO': 'Fortsett'},
    'import_or_view_plan': {
      'EN': 'Import or view plan',
      'PL': 'Importuj lub zobacz plan',
      'NO': 'Importer eller vis plan'
    },
    'search_filter_current': {
      'EN': 'Current category',
      'PL': 'Bieżąca kategoria',
      'NO': 'Gjeldende kategori'
    },
    'search_filter_all': {'EN': 'All', 'PL': 'Wszystkie', 'NO': 'Alle'},
    'rename_exercise': {
      'EN': 'Rename Exercise',
      'PL': 'Zmień nazwę ćwiczenia',
      'NO': 'Gi nytt navn til øvelse'
    },
    'delete_exercise': {
      'EN': 'Delete Exercise',
      'PL': 'Usuń ćwiczenie',
      'NO': 'Slett øvelse'
    },
    'delete_question': {'EN': 'Delete?', 'PL': 'Usunąć?', 'NO': 'Slette?'},
    'delete_exercise_and_history': {
      'EN': "Delete '{name}' and all its history?",
      'PL': "Usunąć '{name}' i całą historię?",
      'NO': "Slett '{name}' og all historikk?"
    },
    'delete': {'EN': 'Delete', 'PL': 'Usuń', 'NO': 'Slett'},
    'cancel': {'EN': 'Cancel', 'PL': 'Anuluj', 'NO': 'Avbryt'},
    'save': {'EN': 'Save', 'PL': 'Zapisz', 'NO': 'Lagre'},
    'exercise_exists': {
      'EN': 'Exercise with that name already exists',
      'PL': 'Ćwiczenie o tej nazwie już istnieje',
      'NO': 'En øvelse med dette navnet finnes allerede'
    },
    'running': {'EN': 'Running', 'PL': 'Działa', 'NO': 'Kjører'},
    'paused': {'EN': 'Paused', 'PL': 'Wstrzymane', 'NO': 'Pauset'},
    'stopped': {'EN': 'Stopped', 'PL': 'Zatrzymane', 'NO': 'Stoppet'},
    'rest_label': {'EN': 'Rest:', 'PL': 'Przerwa:', 'NO': 'Pause:'},
    'reset': {'EN': 'Reset', 'PL': 'Reset', 'NO': 'Nullstill'},
    'rest_time': {
      'EN': 'Rest time (s)',
      'PL': 'Czas przerwy (s)',
      'NO': 'Pause tid (s)'
    },
    'auto_start': {
      'EN': 'Auto-start next set',
      'PL': 'Automatycznie rozpocznij serię',
      'NO': 'Auto-start neste sett'
    },
    'prompt_next_set': {
      'EN': 'Next set: {set}',
      'PL': 'Kolejna seria: {set}',
      'NO': 'Neste sett: {set}'
    },
    'prompt_next_set_action': {
      'EN': 'Set {set}',
      'PL': 'Seria {set}',
      'NO': 'Sett {set}'
    },
    'rest_finished_title': {
      'EN': 'Rest finished',
      'PL': 'Przerwa zakończona',
      'NO': 'Pause ferdig'
    },
    'rest_finished_body': {
      'EN': 'Time for {exercise}',
      'PL': 'Czas na {exercise}',
      'NO': 'Tid for {exercise}'
    },
    'last_entry': {
      'EN': 'Last: {value}',
      'PL': 'Ostatni: {value}',
      'NO': 'Siste: {value}'
    },
    'measured_time': {
      'EN': 'Measured time',
      'PL': 'Zmierzony czas',
      'NO': 'Målt tid'
    },
    'logged_in_as': {
      'EN': 'Signed in as',
      'PL': 'Zalogowano jako',
      'NO': 'Pålogget som'
    },
    'role_label': {
      'EN': 'Role: {role}',
      'PL': 'Rola: {role}',
      'NO': 'Rolle: {role}'
    },
    'open_online_plan': {
      'EN': 'Open online plan',
      'PL': 'Otwórz plan online',
      'NO': 'Åpne nettplan'
    },
    'logout': {'EN': 'Log out', 'PL': 'Wyloguj', 'NO': 'Logg ut'},
    'login_title': {
      'EN': 'Plan login',
      'PL': 'Logowanie do planu',
      'NO': 'Planinnlogging'
    },
    'email': {'EN': 'Email', 'PL': 'Email', 'NO': 'E-post'},
    'password': {'EN': 'Password', 'PL': 'Hasło', 'NO': 'Passord'},
    'logging_in': {
      'EN': 'Signing in...',
      'PL': 'Logowanie...',
      'NO': 'Logger inn...'
    },
    'login_action': {'EN': 'Sign in', 'PL': 'Zaloguj', 'NO': 'Logg inn'},
    'remember_me': {
      'EN': 'Remember me',
      'PL': 'Zapamiętaj mnie',
      'NO': 'Husk meg'
    },
    'login_required': {
      'EN': 'Log in to see the plan',
      'PL': 'Zaloguj się, aby zobaczyć plan',
      'NO': 'Logg inn for å se planen'
    },
    'coach_mode_title': {
      'EN': 'Coach mode: full access',
      'PL': 'Tryb trenera: pełny dostęp',
      'NO': 'Trenermodus: full tilgang'
    },
    'coach_mode_hint': {
      'EN':
          'You have access to all categories and exercise database. Open the base to browse and edit exercises.',
      'PL':
          'Masz dostęp do wszystkich kategorii i bazy ćwiczeń. Otwórz bazę, aby przeglądać i edytować ćwiczenia.',
      'NO':
          'Du har tilgang til alle kategorier og øvelsesbasen. Åpne basen for å bla og redigere øvelser.'
    },
    'exercise_database_btn': {
      'EN': 'Exercise database',
      'PL': 'Baza ćwiczeń',
      'NO': 'Øvelsesbase'
    },
    'all_categories_btn': {
      'EN': 'All categories',
      'PL': 'Wszystkie kategorie',
      'NO': 'Alle kategorier'
    },
    'no_online_plan': {
      'EN': 'No online plan',
      'PL': 'Brak planu online',
      'NO': 'Ingen nettplan'
    },
    'refresh': {'EN': 'Refresh', 'PL': 'Odśwież', 'NO': 'Oppdater'},
    'no_active_user': {
      'EN': 'No active user',
      'PL': 'Brak aktywnego użytkownika',
      'NO': 'Ingen aktiv bruker'
    },
    'plan_fetch_failed': {
      'EN': 'Could not fetch plan',
      'PL': 'Nie udało się pobrać planu',
      'NO': 'Kunne ikke hente planen'
    },
    'plan_updated_at': {
      'EN': 'Updated: {date}',
      'PL': 'Aktualizacja: {date}',
      'NO': 'Oppdatert: {date}'
    },
    'plan_entry_core': {
      'EN': '{sets} sets • rest {rest}s',
      'PL': '{sets} serii • przerwa {rest}s',
      'NO': '{sets} sett • pause {rest}s'
    },
    'plan_entry_time': {
      'EN': ' • time {time}s',
      'PL': ' • czas {time}s',
      'NO': ' • tid {time}s'
    },
    'test_version_hint': {
      'EN':
          'Test version: trainer or client account. Admin manual: karolszymek1402@gmail.com / katarynka09',
      'PL':
          'Wersja testowa: konto trenerskie lub klienta. Admin manualny: karolszymek1402@gmail.com / katarynka09',
      'NO':
          'Testversjon: trener- eller kunde-konto. Admin manuelt: karolszymek1402@gmail.com / katarynka09'
    },
    'contact_sheet_title': {'EN': 'Contact', 'PL': 'Kontakt', 'NO': 'Kontakt'},
    'contact_phone_label': {'EN': 'Phone', 'PL': 'Telefon', 'NO': 'Telefon'},
    'contact_email_label': {'EN': 'Email', 'PL': 'Email', 'NO': 'E-post'},
    'copied_phone': {
      'EN': 'Phone number copied',
      'PL': 'Skopiowano numer telefonu',
      'NO': 'Telefonnummer kopiert'
    },
    'copied_email': {
      'EN': 'Email copied',
      'PL': 'Skopiowano adres email',
      'NO': 'E-post kopiert'
    },
    'exercise_name_hint': {
      'EN': 'Exercise name',
      'PL': 'Nazwa ćwiczenia',
      'NO': 'Øvelsesnavn'
    },
    'kind_label': {'EN': 'Type', 'PL': 'Rodzaj', 'NO': 'Typ'},
    'weight_based': {'EN': 'With weight', 'PL': 'Z ciężarem', 'NO': 'Med vekt'},
    'time_based': {'EN': 'For time', 'PL': 'Na czas', 'NO': 'På tid'},
    'plan_local_desc': {
      'EN': 'Paste or write your plan. It stays on this device.',
      'PL': 'Wklej lub wpisz plan. Zostaje na tym urządzeniu.',
      'NO': 'Lim inn eller skriv planen. Det blir på denne enheten.'
    },
    'plan_saved_local': {
      'EN': 'Plan saved locally',
      'PL': 'Plan zapisany lokalnie',
      'NO': 'Plan lagret lokalt'
    },
    'plan_save_failed': {
      'EN': 'Could not save plan',
      'PL': 'Nie udało się zapisać planu',
      'NO': 'Kunne ikke lagre planen'
    },
    'plan_save': {'EN': 'Save plan', 'PL': 'Zapisz plan', 'NO': 'Lagre plan'},
    'plan_saving': {
      'EN': 'Saving...',
      'PL': 'Zapisywanie...',
      'NO': 'Lagrer...'
    },
    'copied_to_clipboard': {
      'EN': 'Copied to clipboard',
      'PL': 'Skopiowano do schowka',
      'NO': 'Kopiert til utklippstavle'
    },
    'vibration_enabled': {
      'EN': 'Vibration',
      'PL': 'Wibracje',
      'NO': 'Vibrasjon'
    },
    'sound_enabled': {'EN': 'Sound', 'PL': 'Dźwięk', 'NO': 'Lyd'},
    // Dodatkowe tłumaczenia dla trenera
    'add_client': {
      'EN': 'Add client',
      'PL': 'Dodaj klienta',
      'NO': 'Legg til klient'
    },
    'delete_client': {
      'EN': 'Delete client',
      'PL': 'Usuń klienta',
      'NO': 'Slett klient'
    },
    'delete_client_confirm': {
      'EN': 'Are you sure you want to delete this client?',
      'PL': 'Czy na pewno chcesz usunąć tego klienta?',
      'NO': 'Er du sikker på at du vil slette denne klienten?'
    },
    'no_clients': {
      'EN': 'No clients',
      'PL': 'Brak klientów',
      'NO': 'Ingen klienter'
    },
    'edit_plan': {'EN': 'Edit plan', 'PL': 'Edytuj plan', 'NO': 'Rediger plan'},
    'add_exercise': {
      'EN': 'Add exercise',
      'PL': 'Dodaj ćwiczenie',
      'NO': 'Legg til øvelse'
    },
    'delete_exercise_title': {
      'EN': 'Delete exercise',
      'PL': 'Usuń ćwiczenie',
      'NO': 'Slett øvelse'
    },
    'delete_exercise_confirm': {
      'EN': 'Are you sure you want to delete this exercise?',
      'PL': 'Czy na pewno chcesz usunąć to ćwiczenie?',
      'NO': 'Er du sikker på at du vil slette denne øvelsen?'
    },
    'edit_exercise': {
      'EN': 'Edit exercise',
      'PL': 'Edytuj ćwiczenie',
      'NO': 'Rediger øvelse'
    },
    'exercise_added': {
      'EN': 'Exercise added',
      'PL': 'Ćwiczenie dodane',
      'NO': 'Øvelse lagt til'
    },
    'error': {'EN': 'Error', 'PL': 'Błąd', 'NO': 'Feil'},
    'no_exercises_in_plan': {
      'EN': 'No exercises in plan',
      'PL': 'Brak ćwiczeń w planie',
      'NO': 'Ingen øvelser i planen'
    },
    'no_exercises': {
      'EN': 'No exercises',
      'PL': 'Brak ćwiczeń',
      'NO': 'Ingen øvelser'
    },
    'no_exercises_for_day': {
      'EN': 'No exercises for this day',
      'PL': 'Brak ćwiczeń na ten dzień',
      'NO': 'Ingen øvelser for denne dagen'
    },
    'no_plan_from_trainer': {
      'EN': 'No plan from trainer',
      'PL': 'Brak planu od trenera',
      'NO': 'Ingen plan fra trener'
    },
    'no_saved_progress': {
      'EN': 'No saved progress',
      'PL': 'Brak zapisanych postępów',
      'NO': 'Ingen lagret fremgang'
    },
    'error_loading_progress': {
      'EN': 'Error loading progress',
      'PL': 'Błąd ładowania postępów',
      'NO': 'Feil ved lasting av fremgang'
    },
    'edit_entry': {
      'EN': 'Edit entry',
      'PL': 'Edytuj wpis',
      'NO': 'Rediger oppføring'
    },
    'entry_updated': {
      'EN': 'Entry updated',
      'PL': 'Wpis zaktualizowany',
      'NO': 'Oppføring oppdatert'
    },
    'time_s': {'EN': 'TIME (s)', 'PL': 'CZAS (s)', 'NO': 'TID (s)'},
    'sets': {'EN': 'sets', 'PL': 'serii', 'NO': 'sett'},
    'rest': {'EN': 'rest', 'PL': 'przerwy', 'NO': 'pause'},
    'last': {'EN': 'Last', 'PL': 'Ostatni', 'NO': 'Siste'},
    'exercises_count': {'EN': 'exercises', 'PL': 'ćwiczeń', 'NO': 'øvelser'},
    'rest_day': {'EN': 'Rest day', 'PL': 'Dzień wolny', 'NO': 'Hviledag'},
    'rest_day_message': {
      'EN': 'Rest and recover!',
      'PL': 'Odpoczywaj i regeneruj się!',
      'NO': 'Hvil og kom deg!'
    },
    'exercises_to_do': {
      'EN': 'exercises to do',
      'PL': 'ćwiczeń do wykonania',
      'NO': 'øvelser å gjøre'
    },
    'rest_day_training': {
      'EN': 'Rest day from training',
      'PL': 'Dzień wolny od treningu',
      'NO': 'Hviledag fra trening'
    },
    'category': {'EN': 'Category', 'PL': 'Kategoria', 'NO': 'Kategori'},
    'exercise': {'EN': 'Exercise', 'PL': 'Ćwiczenie', 'NO': 'Øvelse'},
    'time_based_exercise': {
      'EN': 'Time-based exercise',
      'PL': 'Ćwiczenie na czas',
      'NO': 'Tidsbasert øvelse'
    },
    'sets_count': {
      'EN': 'Number of sets',
      'PL': 'Ilość serii',
      'NO': 'Antall sett'
    },
    'exercise_duration': {
      'EN': 'Exercise duration',
      'PL': 'Czas trwania ćwiczenia',
      'NO': 'Varighet av øvelse'
    },
    'rest_time_label': {
      'EN': 'Rest time',
      'PL': 'Czas przerwy',
      'NO': 'Pausetid'
    },
    'note_for_client': {
      'EN': 'Note for client (optional)',
      'PL': 'Notatka dla klienta (opcjonalna)',
      'NO': 'Notat til klienten (valgfritt)'
    },
    'note_hint': {
      'EN': 'e.g. Remember proper technique...',
      'PL': 'np. Pamiętaj o poprawnej technice...',
      'NO': 'f.eks. Husk riktig teknikk...'
    },
    'exercise_time_finished': {
      'EN': 'Exercise time finished!',
      'PL': 'Czas ćwiczenia minął!',
      'NO': 'Øvelsestiden er over!'
    },
  };

  static String get(String key, {String language = 'EN'}) {
    final entry = translations[key];
    if (entry == null) return key;
    return entry[language] ?? entry['EN'] ?? key;
  }

  static String withParams(String key,
      {String language = 'EN', Map<String, String> params = const {}}) {
    String base = get(key, language: language);
    params.forEach((k, v) {
      base = base.replaceAll('{$k}', v);
    });
    return base;
  }
}

String localizedExerciseName(String rawName, String language) {
  final trimmed = rawName.trim();
  final translation = kExerciseTranslations[trimmed];
  if (translation != null) {
    return translation[language] ?? translation['EN'] ?? trimmed;
  }
  final separators = [' – ', ' - '];
  for (final sep in separators) {
    if (trimmed.contains(sep)) {
      final parts = trimmed.split(sep);
      if (parts.length >= 2) {
        if (language == 'PL') return parts[0].trim();
        return parts[1].trim();
      }
    }
  }
  return trimmed;
}

const Map<String, Map<String, String>> kCategoryNames = {
  'PLAN': {'EN': 'Plan', 'PL': 'Plan', 'NO': 'Plan'},
  'CHEST': {'EN': 'Chest', 'PL': 'Klatka', 'NO': 'Bryst'},
  'BACK': {'EN': 'Back', 'PL': 'Plecy', 'NO': 'Rygg'},
  'BICEPS': {'EN': 'Biceps', 'PL': 'Biceps', 'NO': 'Biceps'},
  'TRICEPS': {'EN': 'Triceps', 'PL': 'Triceps', 'NO': 'Triceps'},
  'SHOULDERS': {'EN': 'Shoulders', 'PL': 'Barki', 'NO': 'Skuldre'},
  'ABS': {'EN': 'Abs', 'PL': 'Brzuch', 'NO': 'Mage'},
  'LEGS': {'EN': 'Legs', 'PL': 'Nogi', 'NO': 'Bein'},
  'FOREARMS': {'EN': 'Forearms', 'PL': 'Przedramiona', 'NO': 'Underarmer'},
};

String localizedCategoryName(String key, String language) {
  final normalized = key.trim().toUpperCase();
  final entry = kCategoryNames[normalized];
  if (entry == null) return key;
  return entry[language] ?? entry['EN'] ?? key;
}

// Seed exercises to restore the user-provided base if a category is empty.
const Map<String, List<String>> kDefaultExercises = {
  'CHEST': [
    // Wyciskania – Sztanga
    'Wyciskanie sztangi na ławce poziomej – Barbell Bench Press',
    'Wyciskanie sztangi na skosie dodatnim – Incline Barbell Bench Press',
    'Wyciskanie sztangi na skosie ujemnym – Decline Barbell Bench Press',
    'Wyciskanie sztangi wąskim chwytem – Close-Grip Bench Press',
    'Wyciskanie sztangi typu Gilotyna – Guillotine Press',
    'Wyciskanie z podłogi (sztanga) – Barbell Floor Press',
    'Wyciskanie ze Slingshotem – Slingshot Bench Press',
    // Wyciskania – Hantle
    'Wyciskanie hantli na ławce poziomej – Dumbbell Bench Press',
    'Wyciskanie hantli na skosie dodatnim – Incline Dumbbell Press',
    'Wyciskanie hantli na skosie ujemnym – Decline Dumbbell Press',
    'Wyciskanie hantli z rotacją (korkociągowe) – Twisting Dumbbell Press',
    'Wyciskanie hantli chwytem neutralnym (młotkowym) – Neutral Grip Dumbbell Press',
    'Wyciskanie hantli z podłogi – Dumbbell Floor Press',
    // Maszyny
    'Wyciskanie na maszynie Smitha – Smith Machine Bench Press',
    'Wyciskanie na maszynie typu Hammer (siedząc) – Hammer Strength Chest Press',
    'Wyciskanie na maszynie stosowej – Seated Chest Press Machine',
    // Rozpiętki i Izolacje
    'Rozpiętki z hantlami na ławce poziomej – Flat Dumbbell Flys',
    'Rozpiętki z hantlami na skosie dodatnim – Incline Dumbbell Flys',
    'Rozpiętki na maszynie Butterfly – Pec Deck Fly / Machine Fly',
    'Krzyżowanie linek wyciągu górnego (Brama) – Cable Crossover / High Cable Fly',
    'Rozpiętki z linkami wyciągu dolnego – Low Cable Crossover',
    'Rozpiętki jednorącz na wyciągu – Single Arm Cable Fly',
    'Landmine Press (wyciskanie półsztangi) – Landmine Press',
    // Kalistenika
    'Pompki klasyczne – Push-ups',
    'Pompki szerokie – Wide Grip Push-ups',
    'Pompki diamentowe (wąskie) – Diamond Push-ups',
    'Pompki na podwyższeniu (głowa wyżej) – Incline Push-ups',
    'Pompki z nogami na podwyższeniu (głowa niżej) – Decline Push-ups',
    'Pompki łucznicze – Archer Push-ups',
    'Pompki plyometryczne (z klaśnięciem) – Plyometric / Clap Push-ups',
    'Pompki na kółkach gimnastycznych – Ring Push-ups',
    'Dipy (Pompki na poręczach, tułów pochylony) – Chest Dips',
  ],
  'BACK': [
    // Ściągania w pionie
    'Podciąganie na drążku nachwytem – Pull-ups',
    'Podciąganie na drążku podchwytem – Chin-ups',
    'Podciąganie chwytem neutralnym – Neutral Grip Pull-ups',
    'Ściąganie drążka wyciągu górnego do klatki – Lat Pulldown',
    'Ściąganie drążka wyciągu górnego chwytem wąskim – Close-Grip Lat Pulldown',
    'Ściąganie drążka wyciągu górnego chwytem neutralnym – Neutral Grip Lat Pulldown',
    'Ściąganie jednorącz na wyciągu – Single Arm Lat Pulldown',
    'Ściąganie na maszynie Hammer (góra-dół) – Hammer Strength High Row / Pulldown',
    // Wiosłowania w poziomie
    'Wiosłowanie sztangą w opadzie – Bent Over Barbell Row',
    'Wiosłowanie sztangą chwytem neutralnym – Neutral Grip Barbell Row',
    'Wiosłowanie półsztangą (T-sztanga) – T-Bar Row',
    'T-Row – T-Row',
    'Wiosłowanie Pendlay (z martwego punktu) – Pendlay Row',
    'Wiosłowanie hantlem jednorącz – One Arm Dumbbell Row',
    'Wiosłowanie na wyciągu dolnym siedząc – Seated Cable Row',
    'Wiosłowanie na maszynie siedząc – Seated Machine Row',
    'Wiosłowanie na ławce skośnej (przodem do oparcia) – Chest Supported Row / Incline Bench Row',
    'Wiosłowanie sznurem wyciągu – Cable Rope Row',
    // Martwe Ciągi
    'Martwy ciąg klasyczny – Conventional Deadlift',
    'Martwy ciąg Sumo – Sumo Deadlift',
    'Martwy ciąg Rumuński – Romanian Deadlift (RDL)',
    'Martwy ciąg z deficytu – Deficit Deadlift',
    'Martwy ciąg ze stopu (Rack Pull) – Rack Pull',
    'Martwy ciąg z Trap Bar (sztanga heksagonalna) – Trap Bar Deadlift',
    'Martwy ciąg na maszynie Smitha – Smith Machine Deadlift',
    'Power Clean (Zarzut) – Power Clean',
    // Prostowniki i inne
    'Wyprosty tułowia na ławce rzymskiej – Back Extension / Hyperextension',
    'Odwrotne wyprosty (nogi w górę) – Reverse Hyperextension',
    'Face Pull (przyciąganie liny do twarzy) – Face Pull',
    'Przenoszenie hantla za głowę – Dumbbell Pullover',
  ],
  'LEGS': [
    // Czworogłowe
    'Przysiad ze sztangą na karku (High Bar) – High Bar Squat',
    'Przysiad ze sztangą (Low Bar) – Low Bar Squat',
    'Przysiad przedni – Front Squat',
    'Przysiad ze sztangą trzymaną skrzyżnie – Cross Grip Front Squat',
    'Przysiad typu Goblet – Goblet Squat',
    'Przysiad na maszynie Smitha – Smith Machine Squat',
    'Przysiad Hack – Hack Squat',
    'Przysiad wahadłowy (maszyna) – Pendulum Squat',
    'Przysiad Bułgarski – Bulgarian Split Squat',
    'Wypychanie ciężaru na suwnicy – Leg Press',
    'Wypychanie jednonóż na suwnicy – Single Leg Press',
    'Wyprost nóg siedząc na maszynie – Leg Extension',
    'Przysiad Sissy – Sissy Squat',
    'Wykroki – Lunges',
    'Zakroki – Reverse Lunges',
    'Wejścia na podwyższenie – Step-ups',
    // Dwugłowe i Pośladki
    'Martwy ciąg klasyczny – Conventional Deadlift',
    'Martwy ciąg na prostych nogach – Stiff Leg Deadlift',
    'Uginanie nóg leżąc – Lying Leg Curl',
    'Uginanie nóg siedząc – Seated Leg Curl',
    'Uginanie nóg stojąc (jednonóż) – Standing Leg Curl',
    'Żuraw – Nordic Hamstring Curl',
    'Hip Thrust (Wznosy bioder ze sztangą) – Hip Thrust',
    'Glute Bridge (Mostek) – Glute Bridge',
    'Glute Ham Raise – Glute Ham Raise (GHR)',
    'Kettlebell Swing – Kettlebell Swing',
    'Przyciąganie linki wyciągu między nogami – Cable Pull-Through',
    'Przywodzenie nóg na maszynie – Hip Adduction Machine',
    'Odwodzenie nóg na maszynie – Hip Abduction Machine',
    'Spacer z gumą (Monster Walk) – Monster Walk / Banded Side Steps',
    // Łydki
    'Wspięcia na palce stojąc – Standing Calf Raise',
    'Wspięcia na palce siedząc – Seated Calf Raise',
    'Wspięcia na suwnicy (ośle wspięcia) – Donkey Calf Raise / Leg Press Calf Raise',
    'Wspięcia na palce na podwyższeniu – Elevated Calf Raise',
  ],
  'SHOULDERS': [
    // Wyciskania
    'Wyciskanie żołnierskie (stojąc) – Overhead Press (OHP) / Military Press',
    'Wyciskanie sztangi siedząc – Seated Barbell Overhead Press',
    'Wyciskanie hantli siedząc – Seated Dumbbell Press',
    'Wyciskanie Arnolda – Arnold Press',
    'Landmine Press jednorącz – Single Arm Landmine Press',
    'Wyciskanie na maszynie barkowej – Shoulder Press Machine',
    // Wznosy
    'Wznosy hantli bokiem – Dumbbell Lateral Raises',
    'Wznosy bokiem na wyciągu – Cable Lateral Raises',
    'Wznosy bokiem na maszynie – Machine Lateral Raise',
    'Podciąganie sztangi wzdłuż tułowia – Barbell Upright Row',
    'Wznosy hantli przed siebie – Dumbbell Front Raises',
    'Wznosy talerza przed siebie – Plate Front Raise',
    // Tylny akton
    'Odwrotne rozpiętki w opadzie tułowia – Bent Over Dumbbell Reverse Fly',
    'Odwrotne rozpiętki na maszynie – Reverse Pec Deck',
    'Krzyżowanie linek wyciągu (odwrotne) – Reverse Cable Crossover',
    // Kaptury
    'Szrugsy z hantlami – Dumbbell Shrugs',
    'Szrugsy ze sztangą – Barbell Shrugs',
    'Odwrotne rozpiętki leżąc na ławce – Prone Dumbbell Reverse Fly',
  ],
  'BICEPS': [
    'Uginanie ramion ze sztangą stojąc – Barbell Curl',
    'Uginanie ramion ze sztangą łamaną – EZ-Bar Curl',
    'Uginanie ramion z hantlami (z supinacją) – Dumbbell Curl',
    'Uginanie ramion chwytem młotkowym – Hammer Curl',
    'Uginanie ramion na modlitewniku – Preacher Curl',
    'Uginanie skoncentrowane – Concentration Curl',
    'Uginanie Zottman Curl – Zottman Curl',
    'Spider Curl ze sztangą – Barbell Spider Curl',
    'Spider Curl z hantlami – Dumbbell Spider Curl',
    'Uginanie na wyciągu dolnym – Cable Curl',
    'Uginanie ramienia jednorącz w podporze – Single Arm Incline Curl',
    'Face Away Curl jednorącz na bramie – Single Arm Face Away Cable Curl',
    'Face Away Curl oburącz na bramie – Double Arm Face Away Cable Curl',
    'Podciąganie podchwytem (wąsko) – Chin-ups',
  ],
  'TRICEPS': [
    'Wyciskanie sztangi wąskim chwytem – Close-Grip Bench Press',
    'Pompki na poręczach (pionowo) – Triceps Dips',
    'Pompki w podporze tyłem – Bench Dips',
    'Wyciskanie francuskie sztangi do czoła – Skullcrushers / Lying Triceps Extension',
    'Wyciskanie francuskie sztanga za głowę – Overhead Barbell Triceps Extension',
    'Wyciskanie francuskie hantla oburącz (siedząc) – Overhead Dumbbell Triceps Extension',
    'Prostowanie ramion na wyciągu (sznur) – Rope Pushdown',
    'Prostowanie ramion na wyciągu (drążek) – Bar Pushdown / Triceps Pressdown',
    'JM Press – JM Press',
    'Tate Press – Tate Press',
    'Dipy na poręczach – Dips',
    'Catana Extension jednorącz – Single Arm Catana Extension',
    'Catana Extension oburącz – Double Arm Catana Extension',
  ],
  'FOREARMS': [
    'Uginanie nadgarstków podchwytem – Wrist Curl',
    'Prostowanie nadgarstków nachwytem – Reverse Wrist Curl',
    'Uginanie ramion nachwytem – Reverse Curl',
    "Spacer Farmera – Farmer's Carry / Farmer's Walk",
    'Zwis na drążku – Dead Hang',
  ],
  'ABS': [
    'Plank (Deska) – Plank',
    'Plank boczny – Side Plank',
    'Allahy (Spięcia na wyciągu klęcząc) – Cable Crunch',
    'Spięcia brzucha (leżąc) – Crunches',
    'Brzuszki (pełne) – Sit-ups',
    'Unoszenie nóg w zwisie na drążku – Hanging Leg Raise',
    'Unoszenie kolan w zwisie – Hanging Knee Raise',
    'Scyzoryki – V-ups',
    'Nożyce – Flutter Kicks',
    'L-sit – L-Sit',
    'Russian Twist – Russian Twist',
    'Mountain Climbers – Mountain Climbers',
    'Spacer z hantlem jednorącz – Suitcase Carry',
    'Kółko ab wheel – Ab Wheel Rollout',
    'Dead Bug – Dead Bug',
    'Woodchopper (Drwal) – Cable Woodchopper',
    'Pallof Press – Pallof Press',
    'Rowerek leżąc na plecach – Bicycle Crunches',
  ],
};

// Exercises that are performed for time; auto-tag as time-based.
const Set<String> kTimeBasedExercises = {
  'Plank (Deska) – Plank',
  'Plank boczny – Side Plank',
  'L-sit – L-Sit',
  'Zwis na drążku – Dead Hang',
  "Spacer Farmera – Farmer's Carry / Farmer's Walk",
  'Spacer z hantlem jednorącz – Suitcase Carry',
  'Spacer z gumą (Monster Walk) – Monster Walk / Banded Side Steps',
  'Mountain Climbers – Mountain Climbers',
  'Nożyce – Flutter Kicks',
  'Kettlebell Swing – Kettlebell Swing',
  'Russian Twist – Russian Twist',
  'Pallof Press – Pallof Press',
  'Glute Bridge (Mostek) – Glute Bridge',
  'Dead Bug – Dead Bug',
};

// Translations for seeded exercises across languages.
const Map<String, Map<String, String>> kExerciseTranslations = {
  // CHEST
  'Wyciskanie sztangi na ławce poziomej – Barbell Bench Press': {
    'PL': 'Wyciskanie sztangi na ławce poziomej',
    'EN': 'Barbell Bench Press',
    'NO': 'Barbell Bench Press',
  },
  'Wyciskanie sztangi na skosie dodatnim – Incline Barbell Bench Press': {
    'PL': 'Wyciskanie sztangi na skosie dodatnim',
    'EN': 'Incline Barbell Bench Press',
    'NO': 'Incline Barbell Bench Press',
  },
  'Wyciskanie sztangi na skosie ujemnym – Decline Barbell Bench Press': {
    'PL': 'Wyciskanie sztangi na skosie ujemnym',
    'EN': 'Decline Barbell Bench Press',
    'NO': 'Decline Barbell Bench Press',
  },
  'Wyciskanie sztangi typu Gilotyna – Guillotine Press': {
    'PL': 'Wyciskanie sztangi typu Gilotyna',
    'EN': 'Guillotine Press',
    'NO': 'Guillotine Press',
  },
  'Wyciskanie z podłogi (sztanga) – Barbell Floor Press': {
    'PL': 'Wyciskanie z podłogi (sztanga)',
    'EN': 'Barbell Floor Press',
    'NO': 'Barbell Floor Press',
  },
  'Wyciskanie ze Slingshotem – Slingshot Bench Press': {
    'PL': 'Wyciskanie ze Slingshotem',
    'EN': 'Slingshot Bench Press',
    'NO': 'Slingshot Bench Press',
  },
  'Wyciskanie hantli na ławce poziomej – Dumbbell Bench Press': {
    'PL': 'Wyciskanie hantli na ławce poziomej',
    'EN': 'Dumbbell Bench Press',
    'NO': 'Dumbbell Bench Press',
  },
  'Wyciskanie hantli na skosie dodatnim – Incline Dumbbell Press': {
    'PL': 'Wyciskanie hantli na skosie dodatnim',
    'EN': 'Incline Dumbbell Press',
    'NO': 'Incline Dumbbell Press',
  },
  'Wyciskanie hantli na skosie ujemnym – Decline Dumbbell Press': {
    'PL': 'Wyciskanie hantli na skosie ujemnym',
    'EN': 'Decline Dumbbell Press',
    'NO': 'Decline Dumbbell Press',
  },
  'Wyciskanie hantli z rotacją (korkociągowe) – Twisting Dumbbell Press': {
    'PL': 'Wyciskanie hantli z rotacją (korkociągowe)',
    'EN': 'Twisting Dumbbell Press',
    'NO': 'Twisting Dumbbell Press',
  },
  'Wyciskanie hantli chwytem neutralnym (młotkowym) – Neutral Grip Dumbbell Press':
      {
    'PL': 'Wyciskanie hantli chwytem neutralnym (młotkowym)',
    'EN': 'Neutral Grip Dumbbell Press',
    'NO': 'Neutral Grip Dumbbell Press',
  },
  'Wyciskanie hantli z podłogi – Dumbbell Floor Press': {
    'PL': 'Wyciskanie hantli z podłogi',
    'EN': 'Dumbbell Floor Press',
    'NO': 'Dumbbell Floor Press',
  },
  'Wyciskanie na maszynie Smitha – Smith Machine Bench Press': {
    'PL': 'Wyciskanie na maszynie Smitha',
    'EN': 'Smith Machine Bench Press',
    'NO': 'Smith Machine Bench Press',
  },
  'Wyciskanie na maszynie typu Hammer (siedząc) – Hammer Strength Chest Press':
      {
    'PL': 'Wyciskanie na maszynie typu Hammer (siedząc)',
    'EN': 'Hammer Strength Chest Press',
    'NO': 'Hammer Strength Chest Press',
  },
  'Wyciskanie na maszynie stosowej – Seated Chest Press Machine': {
    'PL': 'Wyciskanie na maszynie stosowej',
    'EN': 'Seated Chest Press Machine',
    'NO': 'Seated Chest Press Machine',
  },
  'Rozpiętki z hantlami na ławce poziomej – Flat Dumbbell Flys': {
    'PL': 'Rozpiętki z hantlami na ławce poziomej',
    'EN': 'Flat Dumbbell Flys',
    'NO': 'Flat Dumbbell Flys',
  },
  'Rozpiętki z hantlami na skosie dodatnim – Incline Dumbbell Flys': {
    'PL': 'Rozpiętki z hantlami na skosie dodatnim',
    'EN': 'Incline Dumbbell Flys',
    'NO': 'Incline Dumbbell Flys',
  },
  'Rozpiętki na maszynie Butterfly – Pec Deck Fly / Machine Fly': {
    'PL': 'Rozpiętki na maszynie Butterfly',
    'EN': 'Pec Deck Fly / Machine Fly',
    'NO': 'Pec Deck Fly / Machine Fly',
  },
  'Krzyżowanie linek wyciągu górnego (Brama) – Cable Crossover / High Cable Fly':
      {
    'PL': 'Krzyżowanie linek wyciągu górnego (Brama)',
    'EN': 'Cable Crossover / High Cable Fly',
    'NO': 'Cable Crossover / High Cable Fly',
  },
  'Rozpiętki z linkami wyciągu dolnego – Low Cable Crossover': {
    'PL': 'Rozpiętki z linkami wyciągu dolnego',
    'EN': 'Low Cable Crossover',
    'NO': 'Low Cable Crossover',
  },
  'Rozpiętki jednorącz na wyciągu – Single Arm Cable Fly': {
    'PL': 'Rozpiętki jednorącz na wyciągu',
    'EN': 'Single Arm Cable Fly',
    'NO': 'Single Arm Cable Fly',
  },
  'Landmine Press (wyciskanie półsztangi) – Landmine Press': {
    'PL': 'Landmine Press (wyciskanie półsztangi)',
    'EN': 'Landmine Press',
    'NO': 'Landmine Press',
  },
  'Pompki klasyczne – Push-ups': {
    'PL': 'Pompki klasyczne',
    'EN': 'Push-ups',
    'NO': 'Push-ups',
  },
  'Pompki szerokie – Wide Grip Push-ups': {
    'PL': 'Pompki szerokie',
    'EN': 'Wide Grip Push-ups',
    'NO': 'Wide Grip Push-ups',
  },
  'Pompki diamentowe (wąskie) – Diamond Push-ups': {
    'PL': 'Pompki diamentowe (wąskie)',
    'EN': 'Diamond Push-ups',
    'NO': 'Diamond Push-ups',
  },
  'Pompki na podwyższeniu (głowa wyżej) – Incline Push-ups': {
    'PL': 'Pompki na podwyższeniu (głowa wyżej)',
    'EN': 'Incline Push-ups',
    'NO': 'Incline Push-ups',
  },
  'Pompki z nogami na podwyższeniu (głowa niżej) – Decline Push-ups': {
    'PL': 'Pompki z nogami na podwyższeniu (głowa niżej)',
    'EN': 'Decline Push-ups',
    'NO': 'Decline Push-ups',
  },
  'Pompki łucznicze – Archer Push-ups': {
    'PL': 'Pompki łucznicze',
    'EN': 'Archer Push-ups',
    'NO': 'Archer Push-ups',
  },
  'Pompki plyometryczne (z klaśnięciem) – Plyometric / Clap Push-ups': {
    'PL': 'Pompki plyometryczne (z klaśnięciem)',
    'EN': 'Plyometric / Clap Push-ups',
    'NO': 'Plyometric / Clap Push-ups',
  },
  'Pompki na kółkach gimnastycznych – Ring Push-ups': {
    'PL': 'Pompki na kółkach gimnastycznych',
    'EN': 'Ring Push-ups',
    'NO': 'Ring Push-ups',
  },
  'Dipy (Pompki na poręczach, tułów pochylony) – Chest Dips': {
    'PL': 'Dipy (Pompki na poręczach, tułów pochylony)',
    'EN': 'Chest Dips',
    'NO': 'Chest Dips',
  },

  // BACK
  'Podciąganie na drążku nachwytem – Pull-ups': {
    'PL': 'Podciąganie na drążku nachwytem',
    'EN': 'Pull-ups',
    'NO': 'Pull-ups',
  },
  'Podciąganie na drążku podchwytem – Chin-ups': {
    'PL': 'Podciąganie na drążku podchwytem',
    'EN': 'Chin-ups',
    'NO': 'Chin-ups',
  },
  'Podciąganie chwytem neutralnym – Neutral Grip Pull-ups': {
    'PL': 'Podciąganie chwytem neutralnym',
    'EN': 'Neutral Grip Pull-ups',
    'NO': 'Neutral Grip Pull-ups',
  },
  'Ściąganie drążka wyciągu górnego do klatki – Lat Pulldown': {
    'PL': 'Ściąganie drążka wyciągu górnego do klatki',
    'EN': 'Lat Pulldown',
    'NO': 'Lat Pulldown',
  },
  'Ściąganie drążka wyciągu górnego chwytem wąskim – Close-Grip Lat Pulldown': {
    'PL': 'Ściąganie drążka wyciągu górnego chwytem wąskim',
    'EN': 'Close-Grip Lat Pulldown',
    'NO': 'Close-Grip Lat Pulldown',
  },
  'Ściąganie drążka wyciągu górnego chwytem neutralnym – Neutral Grip Lat Pulldown':
      {
    'PL': 'Ściąganie drążka wyciągu górnego chwytem neutralnym',
    'EN': 'Neutral Grip Lat Pulldown',
    'NO': 'Neutral Grip Lat Pulldown',
  },
  'Ściąganie jednorącz na wyciągu – Single Arm Lat Pulldown': {
    'PL': 'Ściąganie jednorącz na wyciągu',
    'EN': 'Single Arm Lat Pulldown',
    'NO': 'Single Arm Lat Pulldown',
  },
  'Ściąganie na maszynie Hammer (góra-dół) – Hammer Strength High Row / Pulldown':
      {
    'PL': 'Ściąganie na maszynie Hammer (góra-dół)',
    'EN': 'Hammer Strength High Row / Pulldown',
    'NO': 'Hammer Strength High Row / Pulldown',
  },
  'Wiosłowanie sztangą w opadzie – Bent Over Barbell Row': {
    'PL': 'Wiosłowanie sztangą w opadzie',
    'EN': 'Bent Over Barbell Row',
    'NO': 'Bent Over Barbell Row',
  },
  'Wiosłowanie sztangą chwytem neutralnym – Neutral Grip Barbell Row': {
    'PL': 'Wiosłowanie sztangą chwytem neutralnym',
    'EN': 'Neutral Grip Barbell Row',
    'NO': 'Neutral Grip Barbell Row',
  },
  'Wiosłowanie półsztangą (T-sztanga) – T-Bar Row': {
    'PL': 'Wiosłowanie półsztangą (T-sztanga)',
    'EN': 'T-Bar Row',
    'NO': 'T-Bar Row',
  },
  'Wiosłowanie Pendlay (z martwego punktu) – Pendlay Row': {
    'PL': 'Wiosłowanie Pendlay (z martwego punktu)',
    'EN': 'Pendlay Row',
    'NO': 'Pendlay Row',
  },
  'Wiosłowanie hantlem jednorącz – One Arm Dumbbell Row': {
    'PL': 'Wiosłowanie hantlem jednorącz',
    'EN': 'One Arm Dumbbell Row',
    'NO': 'One Arm Dumbbell Row',
  },
  'Wiosłowanie na wyciągu dolnym siedząc – Seated Cable Row': {
    'PL': 'Wiosłowanie na wyciągu dolnym siedząc',
    'EN': 'Seated Cable Row',
    'NO': 'Seated Cable Row',
  },
  'Wiosłowanie na maszynie siedząc – Seated Machine Row': {
    'PL': 'Wiosłowanie na maszynie siedząc',
    'EN': 'Seated Machine Row',
    'NO': 'Seated Machine Row',
  },
  'Wiosłowanie na ławce skośnej (przodem do oparcia) – Chest Supported Row / Incline Bench Row':
      {
    'PL': 'Wiosłowanie na ławce skośnej (przodem do oparcia)',
    'EN': 'Chest Supported Row / Incline Bench Row',
    'NO': 'Chest Supported Row / Incline Bench Row',
  },
  'Wiosłowanie sznurem wyciągu – Cable Rope Row': {
    'PL': 'Wiosłowanie sznurem wyciągu',
    'EN': 'Cable Rope Row',
    'NO': 'Cable Rope Row',
  },
  'Martwy ciąg klasyczny – Conventional Deadlift': {
    'PL': 'Martwy ciąg klasyczny',
    'EN': 'Conventional Deadlift',
    'NO': 'Conventional Deadlift',
  },
  'Martwy ciąg Sumo – Sumo Deadlift': {
    'PL': 'Martwy ciąg Sumo',
    'EN': 'Sumo Deadlift',
    'NO': 'Sumo Deadlift',
  },
  'Martwy ciąg Rumuński – Romanian Deadlift (RDL)': {
    'PL': 'Martwy ciąg Rumuński',
    'EN': 'Romanian Deadlift (RDL)',
    'NO': 'Romanian Deadlift (RDL)',
  },
  'Martwy ciąg z deficytu – Deficit Deadlift': {
    'PL': 'Martwy ciąg z deficytu',
    'EN': 'Deficit Deadlift',
    'NO': 'Deficit Deadlift',
  },
  'Martwy ciąg ze stopu (Rack Pull) – Rack Pull': {
    'PL': 'Martwy ciąg ze stopu (Rack Pull)',
    'EN': 'Rack Pull',
    'NO': 'Rack Pull',
  },
  'Martwy ciąg z Trap Bar (sztanga heksagonalna) – Trap Bar Deadlift': {
    'PL': 'Martwy ciąg z Trap Bar (sztanga heksagonalna)',
    'EN': 'Trap Bar Deadlift',
    'NO': 'Trap Bar Deadlift',
  },
  'Martwy ciąg na maszynie Smitha – Smith Machine Deadlift': {
    'PL': 'Martwy ciąg na maszynie Smitha',
    'EN': 'Smith Machine Deadlift',
    'NO': 'Smith Machine Deadlift',
  },
  'Power Clean (Zarzut) – Power Clean': {
    'PL': 'Power Clean (Zarzut)',
    'EN': 'Power Clean',
    'NO': 'Power Clean',
  },
  'Wyprosty tułowia na ławce rzymskiej – Back Extension / Hyperextension': {
    'PL': 'Wyprosty tułowia na ławce rzymskiej',
    'EN': 'Back Extension / Hyperextension',
    'NO': 'Back Extension / Hyperextension',
  },
  'Odwrotne wyprosty (nogi w górę) – Reverse Hyperextension': {
    'PL': 'Odwrotne wyprosty (nogi w górę)',
    'EN': 'Reverse Hyperextension',
    'NO': 'Reverse Hyperextension',
  },
  'Face Pull (przyciąganie liny do twarzy) – Face Pull': {
    'PL': 'Face Pull (przyciąganie liny do twarzy)',
    'EN': 'Face Pull',
    'NO': 'Face Pull',
  },
  'Przenoszenie hantla za głowę – Dumbbell Pullover': {
    'PL': 'Przenoszenie hantla za głowę',
    'EN': 'Dumbbell Pullover',
    'NO': 'Dumbbell Pullover',
  },

  // LEGS
  'Przysiad ze sztangą na karku (High Bar) – High Bar Squat': {
    'PL': 'Przysiad ze sztangą na karku (High Bar)',
    'EN': 'High Bar Squat',
    'NO': 'High Bar Squat',
  },
  'Przysiad ze sztangą (Low Bar) – Low Bar Squat': {
    'PL': 'Przysiad ze sztangą (Low Bar)',
    'EN': 'Low Bar Squat',
    'NO': 'Low Bar Squat',
  },
  'Przysiad przedni – Front Squat': {
    'PL': 'Przysiad przedni',
    'EN': 'Front Squat',
    'NO': 'Front Squat',
  },
  'Przysiad ze sztangą trzymaną skrzyżnie (stary styl) – Cross Grip Front Squat':
      {
    'PL': 'Przysiad ze sztangą trzymaną skrzyżnie (stary styl)',
    'EN': 'Cross Grip Front Squat',
    'NO': 'Cross Grip Front Squat',
  },
  'Przysiad typu Goblet – Goblet Squat': {
    'PL': 'Przysiad typu Goblet',
    'EN': 'Goblet Squat',
    'NO': 'Goblet Squat',
  },
  'Przysiad na maszynie Smitha – Smith Machine Squat': {
    'PL': 'Przysiad na maszynie Smitha',
    'EN': 'Smith Machine Squat',
    'NO': 'Smith Machine Squat',
  },
  'Przysiad Hack – Hack Squat': {
    'PL': 'Przysiad Hack',
    'EN': 'Hack Squat',
    'NO': 'Hack Squat',
  },
  'Przysiad wahadłowy (maszyna) – Pendulum Squat': {
    'PL': 'Przysiad wahadłowy (maszyna)',
    'EN': 'Pendulum Squat',
    'NO': 'Pendulum Squat',
  },
  'Przysiad Bułgarski – Bulgarian Split Squat': {
    'PL': 'Przysiad Bułgarski',
    'EN': 'Bulgarian Split Squat',
    'NO': 'Bulgarian Split Squat',
  },
  'Wypychanie ciężaru na suwnicy – Leg Press': {
    'PL': 'Wypychanie ciężaru na suwnicy',
    'EN': 'Leg Press',
    'NO': 'Leg Press',
  },
  'Wypychanie jednonóż na suwnicy – Single Leg Press': {
    'PL': 'Wypychanie jednonóż na suwnicy',
    'EN': 'Single Leg Press',
    'NO': 'Single Leg Press',
  },
  'Wyprost nóg siedząc na maszynie – Leg Extension': {
    'PL': 'Wyprost nóg siedząc na maszynie',
    'EN': 'Leg Extension',
    'NO': 'Leg Extension',
  },
  'Przysiad Sissy – Sissy Squat': {
    'PL': 'Przysiad Sissy',
    'EN': 'Sissy Squat',
    'NO': 'Sissy Squat',
  },
  'Wykroki – Lunges': {
    'PL': 'Wykroki',
    'EN': 'Lunges',
    'NO': 'Lunges',
  },
  'Zakroki – Reverse Lunges': {
    'PL': 'Zakroki',
    'EN': 'Reverse Lunges',
    'NO': 'Reverse Lunges',
  },
  'Wejścia na podwyższenie – Step-ups': {
    'PL': 'Wejścia na podwyższenie',
    'EN': 'Step-ups',
    'NO': 'Step-ups',
  },
  'Martwy ciąg na prostych nogach – Stiff Leg Deadlift': {
    'PL': 'Martwy ciąg na prostych nogach',
    'EN': 'Stiff Leg Deadlift',
    'NO': 'Stiff Leg Deadlift',
  },
  'Uginanie nóg leżąc – Lying Leg Curl': {
    'PL': 'Uginanie nóg leżąc',
    'EN': 'Lying Leg Curl',
    'NO': 'Lying Leg Curl',
  },
  'Uginanie nóg siedząc – Seated Leg Curl': {
    'PL': 'Uginanie nóg siedząc',
    'EN': 'Seated Leg Curl',
    'NO': 'Seated Leg Curl',
  },
  'Uginanie nóg stojąc (jednonóż) – Standing Leg Curl': {
    'PL': 'Uginanie nóg stojąc (jednonóż)',
    'EN': 'Standing Leg Curl',
    'NO': 'Standing Leg Curl',
  },
  'Żuraw – Nordic Hamstring Curl': {
    'PL': 'Żuraw',
    'EN': 'Nordic Hamstring Curl',
    'NO': 'Nordic Hamstring Curl',
  },
  'Hip Thrust (Wznosy bioder ze sztangą) – Hip Thrust': {
    'PL': 'Hip Thrust (Wznosy bioder ze sztangą)',
    'EN': 'Hip Thrust',
    'NO': 'Hip Thrust',
  },
  'Glute Bridge (Mostek) – Glute Bridge': {
    'PL': 'Glute Bridge (Mostek)',
    'EN': 'Glute Bridge',
    'NO': 'Glute Bridge',
  },
  'Glute Ham Raise – Glute Ham Raise (GHR)': {
    'PL': 'Glute Ham Raise',
    'EN': 'Glute Ham Raise (GHR)',
    'NO': 'Glute Ham Raise (GHR)',
  },
  'Kettlebell Swing – Kettlebell Swing': {
    'PL': 'Kettlebell Swing',
    'EN': 'Kettlebell Swing',
    'NO': 'Kettlebell Swing',
  },
  'Przyciąganie linki wyciągu między nogami – Cable Pull-Through': {
    'PL': 'Przyciąganie linki wyciągu między nogami',
    'EN': 'Cable Pull-Through',
    'NO': 'Cable Pull-Through',
  },
  'Przywodzenie nóg na maszynie – Hip Adduction Machine': {
    'PL': 'Przywodzenie nóg na maszynie',
    'EN': 'Hip Adduction Machine',
    'NO': 'Hip Adduction Machine',
  },
  'Odwodzenie nóg na maszynie – Hip Abduction Machine': {
    'PL': 'Odwodzenie nóg na maszynie',
    'EN': 'Hip Abduction Machine',
    'NO': 'Hip Abduction Machine',
  },
  'Spacer z gumą (Monster Walk) – Monster Walk / Banded Side Steps': {
    'PL': 'Spacer z gumą (Monster Walk)',
    'EN': 'Monster Walk / Banded Side Steps',
    'NO': 'Monster Walk / Banded Side Steps',
  },
  'Wspięcia na palce stojąc – Standing Calf Raise': {
    'PL': 'Wspięcia na palce stojąc',
    'EN': 'Standing Calf Raise',
    'NO': 'Standing Calf Raise',
  },
  'Wspięcia na palce siedząc – Seated Calf Raise': {
    'PL': 'Wspięcia na palce siedząc',
    'EN': 'Seated Calf Raise',
    'NO': 'Seated Calf Raise',
  },
  'Wspięcia na suwnicy (ośle wspięcia) – Donkey Calf Raise / Leg Press Calf Raise':
      {
    'PL': 'Wspięcia na suwnicy (ośle wspięcia)',
    'EN': 'Donkey Calf Raise / Leg Press Calf Raise',
    'NO': 'Donkey Calf Raise / Leg Press Calf Raise',
  },
  'Wspięcia na palce na podwyższeniu – Elevated Calf Raise': {
    'PL': 'Wspięcia na palce na podwyższeniu',
    'EN': 'Elevated Calf Raise',
    'NO': 'Elevated Calf Raise',
  },

  // SHOULDERS
  'Wyciskanie żołnierskie (stojąc) – Overhead Press (OHP) / Military Press': {
    'PL': 'Wyciskanie żołnierskie (stojąc)',
    'EN': 'Overhead Press (OHP) / Military Press',
    'NO': 'Overhead Press (OHP) / Military Press',
  },
  'Wyciskanie sztangi siedząc – Seated Barbell Overhead Press': {
    'PL': 'Wyciskanie sztangi siedząc',
    'EN': 'Seated Barbell Overhead Press',
    'NO': 'Seated Barbell Overhead Press',
  },
  'Wyciskanie hantli siedząc – Seated Dumbbell Press': {
    'PL': 'Wyciskanie hantli siedząc',
    'EN': 'Seated Dumbbell Press',
    'NO': 'Seated Dumbbell Press',
  },
  'Wyciskanie Arnolda – Arnold Press': {
    'PL': 'Wyciskanie Arnolda',
    'EN': 'Arnold Press',
    'NO': 'Arnold Press',
  },
  'Landmine Press jednorącz – Single Arm Landmine Press': {
    'PL': 'Landmine Press jednorącz',
    'EN': 'Single Arm Landmine Press',
    'NO': 'Single Arm Landmine Press',
  },
  'Wyciskanie na maszynie barkowej – Shoulder Press Machine': {
    'PL': 'Wyciskanie na maszynie barkowej',
    'EN': 'Shoulder Press Machine',
    'NO': 'Shoulder Press Machine',
  },
  'Wznosy hantli bokiem – Dumbbell Lateral Raises': {
    'PL': 'Wznosy hantli bokiem',
    'EN': 'Dumbbell Lateral Raises',
    'NO': 'Dumbbell Lateral Raises',
  },
  'Wznosy bokiem na wyciągu – Cable Lateral Raises': {
    'PL': 'Wznosy bokiem na wyciągu',
    'EN': 'Cable Lateral Raises',
    'NO': 'Cable Lateral Raises',
  },
  'Wznosy bokiem na maszynie – Machine Lateral Raise': {
    'PL': 'Wznosy bokiem na maszynie',
    'EN': 'Machine Lateral Raise',
    'NO': 'Machine Lateral Raise',
  },
  'Podciąganie sztangi wzdłuż tułowia – Barbell Upright Row': {
    'PL': 'Podciąganie sztangi wzdłuż tułowia',
    'EN': 'Barbell Upright Row',
    'NO': 'Barbell Upright Row',
  },
  'Wznosy hantli przed siebie – Dumbbell Front Raises': {
    'PL': 'Wznosy hantli przed siebie',
    'EN': 'Dumbbell Front Raises',
    'NO': 'Dumbbell Front Raises',
  },
  'Wznosy talerza przed siebie – Plate Front Raise': {
    'PL': 'Wznosy talerza przed siebie',
    'EN': 'Plate Front Raise',
    'NO': 'Plate Front Raise',
  },
  'Odwrotne rozpiętki w opadzie tułowia – Bent Over Dumbbell Reverse Fly': {
    'PL': 'Odwrotne rozpiętki w opadzie tułowia',
    'EN': 'Bent Over Dumbbell Reverse Fly',
    'NO': 'Bent Over Dumbbell Reverse Fly',
  },
  'Odwrotne rozpiętki na maszynie – Reverse Pec Deck': {
    'PL': 'Odwrotne rozpiętki na maszynie',
    'EN': 'Reverse Pec Deck',
    'NO': 'Reverse Pec Deck',
  },
  'Krzyżowanie linek wyciągu (odwrotne) – Reverse Cable Crossover': {
    'PL': 'Krzyżowanie linek wyciągu (odwrotne)',
    'EN': 'Reverse Cable Crossover',
    'NO': 'Reverse Cable Crossover',
  },
  'Szrugsy z hantlami – Dumbbell Shrugs': {
    'PL': 'Szrugsy z hantlami',
    'EN': 'Dumbbell Shrugs',
    'NO': 'Dumbbell Shrugs',
  },
  'Szrugsy ze sztangą – Barbell Shrugs': {
    'PL': 'Szrugsy ze sztangą',
    'EN': 'Barbell Shrugs',
    'NO': 'Barbell Shrugs',
  },
  'Odwrotne rozpiętki leżąc na ławce – Prone Dumbbell Reverse Fly': {
    'PL': 'Odwrotne rozpiętki leżąc na ławce',
    'EN': 'Prone Dumbbell Reverse Fly',
    'NO': 'Prone Dumbbell Reverse Fly',
  },
  'Szrugsy na maszynie Smitha – Smith Machine Shrugs': {
    'PL': 'Szrugsy na maszynie Smitha',
    'EN': 'Smith Machine Shrugs',
    'NO': 'Smith Machine Shrugs',
  },
  'Szrugsy na maszynie typu Trap Bar – Trap Bar Shrugs': {
    'PL': 'Szrugsy na maszynie typu Trap Bar',
    'EN': 'Trap Bar Shrugs',
    'NO': 'Trap Bar Shrugs',
  },
  'Szrugsy na wyciągu dolnym – Cable Shrugs': {
    'PL': 'Szrugsy na wyciągu dolnym',
    'EN': 'Cable Shrugs',
    'NO': 'Cable Shrugs',
  },
  'Szrugsy jednorącz z hantlem – Single Arm Dumbbell Shrug': {
    'PL': 'Szrugsy jednorącz z hantlem',
    'EN': 'Single Arm Dumbbell Shrug',
    'NO': 'Single Arm Dumbbell Shrug',
  },
  'Szrugsy z Kettlebell – Kettlebell Shrugs': {
    'PL': 'Szrugsy z Kettlebell',
    'EN': 'Kettlebell Shrugs',
    'NO': 'Kettlebell Shrugs',
  },

  // ABS
  'Plank (Deska) – Plank': {
    'PL': 'Plank (Deska)',
    'EN': 'Plank',
    'NO': 'Plank',
  },
  'Plank boczny – Side Plank': {
    'PL': 'Plank boczny',
    'EN': 'Side Plank',
    'NO': 'Side Plank',
  },
  'Allahy (Spięcia na wyciągu klęcząc) – Cable Crunch': {
    'PL': 'Allahy (Spięcia na wyciągu klęcząc)',
    'EN': 'Cable Crunch',
    'NO': 'Cable Crunch',
  },
  'Spięcia brzucha (leżąc) – Crunches': {
    'PL': 'Spięcia brzucha (leżąc)',
    'EN': 'Crunches',
    'NO': 'Crunches',
  },
  'Brzuszki (pełne) – Sit-ups': {
    'PL': 'Brzuszki (pełne)',
    'EN': 'Sit-ups',
    'NO': 'Sit-ups',
  },
  'Unoszenie nóg w zwisie na drążku – Hanging Leg Raise': {
    'PL': 'Unoszenie nóg w zwisie na drążku',
    'EN': 'Hanging Leg Raise',
    'NO': 'Hanging Leg Raise',
  },
  'Unoszenie kolan w zwisie – Hanging Knee Raise': {
    'PL': 'Unoszenie kolan w zwisie',
    'EN': 'Hanging Knee Raise',
    'NO': 'Hanging Knee Raise',
  },
  'Scyzoryki – V-ups': {
    'PL': 'Scyzoryki',
    'EN': 'V-ups',
    'NO': 'V-ups',
  },
  'Nożyce – Flutter Kicks': {
    'PL': 'Nożyce',
    'EN': 'Flutter Kicks',
    'NO': 'Flutter Kicks',
  },
  'L-sit – L-Sit': {
    'PL': 'L-sit',
    'EN': 'L-Sit',
    'NO': 'L-Sit',
  },
  'Russian Twist – Russian Twist': {
    'PL': 'Russian Twist',
    'EN': 'Russian Twist',
    'NO': 'Russian Twist',
  },
  'Mountain Climbers – Mountain Climbers': {
    'PL': 'Mountain Climbers',
    'EN': 'Mountain Climbers',
    'NO': 'Mountain Climbers',
  },
  'Spacer z hantlem jednorącz – Suitcase Carry': {
    'PL': 'Spacer z hantlem jednorącz',
    'EN': 'Suitcase Carry',
    'NO': 'Suitcase Carry',
  },
  'Kółko ab wheel – Ab Wheel Rollout': {
    'PL': 'Kółko ab wheel',
    'EN': 'Ab Wheel Rollout',
    'NO': 'Ab Wheel Rollout',
  },
  'Dead Bug – Dead Bug': {
    'PL': 'Dead Bug',
    'EN': 'Dead Bug',
    'NO': 'Dead Bug',
  },
  'Woodchopper (Drwal) – Cable Woodchopper': {
    'PL': 'Woodchopper (Drwal)',
    'EN': 'Cable Woodchopper',
    'NO': 'Cable Woodchopper',
  },
  'Pallof Press – Pallof Press': {
    'PL': 'Pallof Press',
    'EN': 'Pallof Press',
    'NO': 'Pallof Press',
  },
  'Rowerek leżąc na plecach – Bicycle Crunches': {
    'PL': 'Rowerek leżąc na plecach',
    'EN': 'Bicycle Crunches',
    'NO': 'Bicycle Crunches',
  },

  // BICEPS
  'Uginanie ramion ze sztangą stojąc – Barbell Curl': {
    'PL': 'Uginanie ramion ze sztangą stojąc',
    'EN': 'Barbell Curl',
    'NO': 'Barbell Curl',
  },
  'Uginanie ramion ze sztangą łamaną – EZ-Bar Curl': {
    'PL': 'Uginanie ramion ze sztangą łamaną',
    'EN': 'EZ-Bar Curl',
    'NO': 'EZ-Bar Curl',
  },
  'Uginanie ramion z hantlami (z supinacją) – Dumbbell Curl': {
    'PL': 'Uginanie ramion z hantlami (z supinacją)',
    'EN': 'Dumbbell Curl',
    'NO': 'Dumbbell Curl',
  },
  'Uginanie ramion chwytem młotkowym – Hammer Curl': {
    'PL': 'Uginanie ramion chwytem młotkowym',
    'EN': 'Hammer Curl',
    'NO': 'Hammer Curl',
  },
  'Uginanie ramion na modlitewniku – Preacher Curl': {
    'PL': 'Uginanie ramion na modlitewniku',
    'EN': 'Preacher Curl',
    'NO': 'Preacher Curl',
  },
  'Uginanie skoncentrowane – Concentration Curl': {
    'PL': 'Uginanie skoncentrowane',
    'EN': 'Concentration Curl',
    'NO': 'Concentration Curl',
  },
  'Uginanie Zottman Curl – Zottman Curl': {
    'PL': 'Uginanie Zottman Curl',
    'EN': 'Zottman Curl',
    'NO': 'Zottman Curl',
  },
  'Spider Curl ze sztangą – Barbell Spider Curl': {
    'PL': 'Spider Curl ze sztangą',
    'EN': 'Barbell Spider Curl',
    'NO': 'Barbell Spider Curl',
  },
  'Spider Curl z hantlami – Dumbbell Spider Curl': {
    'PL': 'Spider Curl z hantlami',
    'EN': 'Dumbbell Spider Curl',
    'NO': 'Dumbbell Spider Curl',
  },
  'Uginanie na wyciągu dolnym – Cable Curl': {
    'PL': 'Uginanie na wyciągu dolnym',
    'EN': 'Cable Curl',
    'NO': 'Cable Curl',
  },
  'Uginanie ramienia jednorącz w podporze – Single Arm Incline Curl': {
    'PL': 'Uginanie ramienia jednorącz w podporze',
    'EN': 'Single Arm Incline Curl',
    'NO': 'Single Arm Incline Curl',
  },
  'Face Away Curl jednorącz na bramie – Single Arm Face Away Cable Curl': {
    'PL': 'Face Away Curl jednorącz na bramie',
    'EN': 'Single Arm Face Away Cable Curl',
    'NO': 'Single Arm Face Away Cable Curl',
  },
  'Face Away Curl oburącz na bramie – Double Arm Face Away Cable Curl': {
    'PL': 'Face Away Curl oburącz na bramie',
    'EN': 'Double Arm Face Away Cable Curl',
    'NO': 'Double Arm Face Away Cable Curl',
  },
  'Podciąganie podchwytem (wąsko) – Chin-ups': {
    'PL': 'Podciąganie podchwytem (wąsko)',
    'EN': 'Chin-ups',
    'NO': 'Chin-ups',
  },

  // TRICEPS
  'Wyciskanie sztangi wąskim chwytem – Close-Grip Bench Press': {
    'PL': 'Wyciskanie sztangi wąskim chwytem',
    'EN': 'Close-Grip Bench Press',
    'NO': 'Close-Grip Bench Press',
  },
  'Pompki na poręczach (pionowo) – Triceps Dips': {
    'PL': 'Pompki na poręczach (pionowo)',
    'EN': 'Triceps Dips',
    'NO': 'Triceps Dips',
  },
  'Pompki w podporze tyłem – Bench Dips': {
    'PL': 'Pompki w podporze tyłem',
    'EN': 'Bench Dips',
    'NO': 'Bench Dips',
  },
  'Wyciskanie francuskie sztangi do czoła – Skullcrushers / Lying Triceps Extension':
      {
    'PL': 'Wyciskanie francuskie sztangi do czoła',
    'EN': 'Skullcrushers / Lying Triceps Extension',
    'NO': 'Skullcrushers / Lying Triceps Extension',
  },
  'Wyciskanie francuskie hantla oburącz (siedząc) – Overhead Dumbbell Triceps Extension':
      {
    'PL': 'Wyciskanie francuskie hantla oburącz (siedząc)',
    'EN': 'Overhead Dumbbell Triceps Extension',
    'NO': 'Overhead Dumbbell Triceps Extension',
  },
  'Prostowanie ramion na wyciągu (sznur) – Rope Pushdown': {
    'PL': 'Prostowanie ramion na wyciągu (sznur)',
    'EN': 'Rope Pushdown',
    'NO': 'Rope Pushdown',
  },
  'Prostowanie ramion na wyciągu (drążek) – Bar Pushdown / Triceps Pressdown': {
    'PL': 'Prostowanie ramion na wyciągu (drążek)',
    'EN': 'Bar Pushdown / Triceps Pressdown',
    'NO': 'Bar Pushdown / Triceps Pressdown',
  },
  'JM Press – JM Press': {
    'PL': 'JM Press',
    'EN': 'JM Press',
    'NO': 'JM Press',
  },
  'Tate Press – Tate Press': {
    'PL': 'Tate Press',
    'EN': 'Tate Press',
    'NO': 'Tate Press',
  },
  'Dipy na poręczach – Dips': {
    'PL': 'Dipy na poręczach',
    'EN': 'Dips',
    'NO': 'Dips',
  },
  'Catana Extension jednorącz – Single Arm Catana Extension': {
    'PL': 'Catana Extension jednorącz',
    'EN': 'Single Arm Catana Extension',
    'NO': 'Single Arm Catana Extension',
  },
  'Catana Extension oburącz – Double Arm Catana Extension': {
    'PL': 'Catana Extension oburącz',
    'EN': 'Double Arm Catana Extension',
    'NO': 'Double Arm Catana Extension',
  },

  // FOREARMS
  'Uginanie nadgarstków podchwytem – Wrist Curl': {
    'PL': 'Uginanie nadgarstków podchwytem',
    'EN': 'Wrist Curl',
    'NO': 'Wrist Curl',
  },
  'Prostowanie nadgarstków nachwytem – Reverse Wrist Curl': {
    'PL': 'Prostowanie nadgarstków nachwytem',
    'EN': 'Reverse Wrist Curl',
    'NO': 'Reverse Wrist Curl',
  },
  'Uginanie ramion nachwytem – Reverse Curl': {
    'PL': 'Uginanie ramion nachwytem',
    'EN': 'Reverse Curl',
    'NO': 'Reverse Curl',
  },
  "Spacer Farmera – Farmer's Carry / Farmer's Walk": {
    'PL': 'Spacer Farmera',
    'EN': "Farmer's Carry / Farmer's Walk",
    'NO': "Farmer's Carry / Farmer's Walk",
  },
  'Zwis na drążku – Dead Hang': {
    'PL': 'Zwis na drążku',
    'EN': 'Dead Hang',
    'NO': 'Dead Hang',
  },
};

final Map<String, Map<String, String>> kExerciseNamesByLanguage =
    _buildExerciseNamesByLanguage();

final Map<String, Map<String, List<String>>> kDefaultExercisesByLanguage =
    _buildDefaultExercisesByLanguage();

Map<String, Map<String, String>> _buildExerciseNamesByLanguage() {
  final result = <String, Map<String, String>>{};
  for (final lang in kSupportedLanguages) {
    final langMap = <String, String>{};
    kExerciseTranslations.forEach((key, translations) {
      langMap[key] = translations[lang] ?? translations['EN'] ?? key;
    });
    result[lang] = langMap;
  }
  return result;
}

Map<String, Map<String, List<String>>> _buildDefaultExercisesByLanguage() {
  final result = <String, Map<String, List<String>>>{};
  for (final lang in kSupportedLanguages) {
    final langMap = <String, List<String>>{};
    kDefaultExercises.forEach((category, seeds) {
      langMap[category] = seeds
          .map((name) =>
              kExerciseNamesByLanguage[lang]?[name] ??
              localizedExerciseName(name, lang))
          .toList();
    });
    result[lang] = langMap;
  }
  return result;
}

extension ColorWithValues on Color {
  Color withValues({double alpha = 1.0}) {
    final int a = (alpha.clamp(0.0, 1.0) * 255).round();
    return withAlpha(a);
  }
}

/// Notification helper (singleton)
class NotificationService {
  NotificationService._internal();
  static final NotificationService instance = NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    const initSettings =
        InitializationSettings(android: androidInit, iOS: iosInit);
    await _plugin.initialize(initSettings);
    const channel = AndroidNotificationChannel(
      'ks_gym_channel',
      'K.S-Gym notifications',
      description: 'Notifications for timer completions',
      importance: Importance.defaultImportance,
    );
    try {
      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    } catch (_) {}
  }

  Future<void> showNotification(
      {required String title, required String body}) async {
    const androidDetails = AndroidNotificationDetails(
      'ks_gym_channel',
      'K.S-Gym notifications',
      channelDescription: 'Notifications for timer completions',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );
    const details = NotificationDetails(
        android: androidDetails, iOS: DarwinNotificationDetails());
    await _plugin.show(0, title, body, details);
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Równoległa inicjalizacja dla szybszego startu
  await Future.wait([
    _initFirebase(),
    NotificationService.instance.init(),
    _initLanguageFromPrefs(),
    _initPlanAccess(),
  ]);

  runApp(const KsGymApp());
}

Future<void> _initFirebase() async {
  try {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
  } catch (_) {}
}

Future<void> _initLanguageFromPrefs() async {
  try {
    final prefs = await getPrefs();
    final savedLang = prefs.getString('app_language');
    if (savedLang != null && savedLang.isNotEmpty) {
      updateGlobalLanguage(savedLang);
    }
  } catch (_) {}
}

Future<void> _initPlanAccess() async {
  try {
    await PlanAccessController.instance.initialize();
  } catch (_) {}
}

class KsGymApp extends StatefulWidget {
  const KsGymApp({super.key});

  @override
  State<KsGymApp> createState() => _KsGymAppState();
}

class _KsGymAppState extends State<KsGymApp> {
  @override
  void initState() {
    super.initState();
    _precacheAssets();
  }

  /// Precache SVG assets dla szybszego renderowania
  Future<void> _precacheAssets() async {
    // Skip SVG precaching on web - some SVGs have unsupported elements
    if (kIsWeb) return;

    final svgAssets = [
      'assets/mojelogo.svg',
      'assets/klata.svg',
      'assets/plecy.svg',
      'assets/nogi.svg',
      'assets/barki.svg',
      'assets/biceps.svg',
      'assets/triceps.svg',
      'assets/brzuch.svg',
      'assets/przedramie.svg',
      'assets/plan.svg',
      'assets/notatnik.svg',
    ];

    for (final asset in svgAssets) {
      try {
        final loader = SvgAssetLoader(asset);
        await svg.cache.putIfAbsent(
          loader.cacheKey(null),
          () => loader.loadBytes(null),
        );
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF1E88E5); // primary blue
    const gold = Color(0xFFFFD700);
    return MaterialApp(
      title: 'K.S-GYM',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.dark(
          primary: seed,
          secondary: gold,
          surface: const Color(0xFF0D1324),
          background: const Color(0xFF0A0F1D),
        ),
        scaffoldBackgroundColor: const Color(0xFF0A0F1D),
        appBarTheme:
            const AppBarTheme(backgroundColor: Color(0xFF0B1224), elevation: 0),
        cardColor: const Color(0xFF111A2E),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF0E1528),
          labelStyle: const TextStyle(color: gold, fontWeight: FontWeight.w700),
          hintStyle: TextStyle(color: gold.withValues(alpha: 0.7)),
          prefixIconColor: gold,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: gold.withValues(alpha: 0.4))),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: gold.withValues(alpha: 0.5))),
          focusedBorder: OutlineInputBorder(
            borderSide:
                BorderSide(color: gold.withValues(alpha: 0.95), width: 1.6),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: gold,
            foregroundColor: Colors.black,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            elevation: 2,
          ),
        ),
        sliderTheme: SliderThemeData(
          activeTrackColor: seed,
          inactiveTrackColor: gold.withValues(alpha: 0.35),
          thumbColor: gold,
          overlayColor: gold.withValues(alpha: 0.12),
        ),
        textTheme: const TextTheme(
          titleLarge: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
          bodyLarge: TextStyle(fontSize: 15),
        ),
      ),
      home: const StartChoiceScreen(),
    );
  }
}

/// Logo helpers
Widget _logoPlaceholder(Color accentColor, double size) {
  return SizedBox(width: size, height: size);
}

Widget buildLogo(BuildContext context, Color accentColor, {double size = 34}) {
  // Używamy PNG - SVG z embedded image nie działa na web
  return SizedBox(
    height: size,
    width: size,
    child: Image.asset(
      'assets/app_icon.png',
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) =>
          _logoPlaceholder(accentColor, size),
    ),
  );
}

PreferredSizeWidget buildCustomAppBar(BuildContext context,
    {required Color accentColor, VoidCallback? onLogout}) {
  final state = PlanAccessController.instance.notifier.value;
  final isLoggedIn = state.isAuthenticated;

  return AppBar(
    backgroundColor: Colors.transparent,
    elevation: 0,
    centerTitle: true,
    leading: Navigator.canPop(context)
        ? IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFFFFD700)),
            onPressed: () => Navigator.of(context).pop(),
          )
        : null,
    title: Row(mainAxisSize: MainAxisSize.min, children: [
      buildLogo(context, accentColor),
      const SizedBox(width: 10),
      Text('K.S-GYM',
          style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 20,
              color: const Color(0xFFFFD700),
              letterSpacing: 1.2)),
    ]),
    actions: [
      if (isLoggedIn)
        IconButton(
          tooltip: globalLanguage == 'PL'
              ? 'Wyloguj'
              : globalLanguage == 'NO'
                  ? 'Logg ut'
                  : 'Logout',
          icon: const Icon(Icons.logout),
          color: const Color(0xFFFFD700),
          onPressed: () async {
            final lang = globalLanguage;
            final confirm = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                backgroundColor: Colors.black.withValues(alpha: 0.9),
                title: Text(
                  lang == 'PL'
                      ? 'Wyloguj'
                      : lang == 'NO'
                          ? 'Logg ut'
                          : 'Logout',
                  style: const TextStyle(color: Color(0xFFFFD700)),
                ),
                content: Text(
                  lang == 'PL'
                      ? 'Czy na pewno chcesz się wylogować?'
                      : lang == 'NO'
                          ? 'Er du sikker på at du vil logge ut?'
                          : 'Are you sure you want to log out?',
                  style: const TextStyle(color: Colors.white70),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
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
                    onPressed: () => Navigator.pop(ctx, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD700),
                      foregroundColor: Colors.black,
                    ),
                    child: Text(
                      lang == 'PL'
                          ? 'Wyloguj'
                          : lang == 'NO'
                              ? 'Logg ut'
                              : 'Logout',
                    ),
                  ),
                ],
              ),
            );

            if (confirm == true) {
              // Wyczyść zapamiętane dane logowania
              final prefs = await getPrefs();
              await prefs.setBool('remember_me', false);
              await prefs.remove('saved_email');
              await prefs.remove('saved_password');

              // Wyloguj z Firebase
              await PlanAccessController.instance.signOut();

              // Przekieruj do ekranu startowego
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const StartChoiceScreen()),
                  (route) => false,
                );
              }
            }
          },
        ),
      IconButton(
        tooltip: 'Ustawienia',
        icon: const Icon(Icons.settings),
        color: const Color(0xFFFFD700),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const SettingsScreen(),
            ),
          );
        },
      ),
    ],
  );
}

class ExerciseLog {
  final String date;
  final String sets;
  final String weight;
  final String reps;
  final int durationSeconds;
  final String? plannedTime;
  final String exercise;

  ExerciseLog({
    required this.date,
    required this.sets,
    required this.weight,
    required this.reps,
    this.durationSeconds = 0,
    this.plannedTime,
    required this.exercise,
  });

  Map<String, dynamic> toJson() => {
        'date': date,
        'sets': sets,
        'weight': weight,
        'reps': reps,
        'durationSeconds': durationSeconds,
        'plannedTime': plannedTime,
        'exercise': exercise,
      };

  factory ExerciseLog.fromJson(Map<String, dynamic> json,
      {String defaultExercise = ''}) {
    return ExerciseLog(
      date: json['date'] ?? '',
      sets: json['sets'] ?? '',
      weight: json['weight'] ?? '',
      reps: json['reps'] ?? '',
      durationSeconds: (json['durationSeconds'] as num?)?.toInt() ?? 0,
      plannedTime: json['plannedTime'] as String?,
      exercise: json['exercise'] ?? defaultExercise,
    );
  }
}

class GymBackgroundWithFitness extends StatelessWidget {
  final Widget child;
  final Color accentColor;
  final bool showScatteredLogos;
  final bool goldDumbbells;
  final List<Color>? gradientColors;
  final String? backgroundImage;
  final double backgroundImageOpacity;

  const GymBackgroundWithFitness({
    super.key,
    required this.child,
    this.accentColor = const Color(0xFF1E88E5),
    this.showScatteredLogos = true,
    this.goldDumbbells = false,
    this.gradientColors,
    this.backgroundImage = 'assets/moje_tlo.png',
    this.backgroundImageOpacity = 0.32,
  });

  @override
  Widget build(BuildContext context) {
    final bool isSvgBackground =
        backgroundImage?.toLowerCase().endsWith('.svg') ?? false;
    final List<Color> colors = gradientColors ??
        [
          const Color(0xFF0C1C33),
          const Color(0xFF0B1830),
          accentColor.withValues(alpha: 0.18),
        ];
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        image: (backgroundImage == null || isSvgBackground)
            ? null
            : DecorationImage(
                image: AssetImage(backgroundImage!),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(backgroundImageOpacity),
                    BlendMode.darken),
              ),
      ),
      child: Stack(
        children: [
          if (backgroundImage != null && isSvgBackground)
            Positioned.fill(
              child: ColorFiltered(
                colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(backgroundImageOpacity),
                    BlendMode.darken),
                child: SvgPicture.asset(backgroundImage!, fit: BoxFit.cover),
              ),
            ),
          if (goldDumbbells)
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _DumbbellPatternPainter(),
                ),
              ),
            ),
          child,
        ],
      ),
    );
  }
}

class _DumbbellPatternPainter extends CustomPainter {
  final Color gold = const Color(0xFFFFD700);

  @override
  void paint(Canvas canvas, Size size) {
    // Fewer, larger dumbbells for a calmer background
    const double spacing = 230;
    const double baseSize = 44;

    for (double y = -spacing; y < size.height + spacing; y += spacing) {
      for (double x = -spacing; x < size.width + spacing; x += spacing) {
        final offset = Offset(x + 40, y + 40);
        final double angle = ((x + y) ~/ spacing) % 2 == 0 ? 0.28 : -0.18;
        _drawDumbbell(canvas, offset, baseSize, angle);
      }
    }
  }

  void _drawDumbbell(Canvas canvas, Offset center, double size, double angle) {
    final double barLen = size;
    final double barHeight = size * 0.18;
    final double plateSize = size * 0.36;

    final stroke = Paint()
      ..color = gold.withOpacity(0.14)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    final fill = Paint()
      ..color = gold.withOpacity(0.05)
      ..style = PaintingStyle.fill;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);

    final barRect =
        Rect.fromCenter(center: Offset.zero, width: barLen, height: barHeight);
    final rBar = RRect.fromRectAndRadius(barRect, const Radius.circular(6));
    canvas.drawRRect(rBar, fill);
    canvas.drawRRect(rBar, stroke);

    final lp = Rect.fromCenter(
        center: Offset(-barLen / 2 - plateSize * 0.32, 0),
        width: plateSize,
        height: plateSize);
    final rp = Rect.fromCenter(
        center: Offset(barLen / 2 + plateSize * 0.32, 0),
        width: plateSize,
        height: plateSize);

    final rPlateL = RRect.fromRectAndRadius(lp, const Radius.circular(7));
    final rPlateR = RRect.fromRectAndRadius(rp, const Radius.circular(7));
    canvas.drawRRect(rPlateL, fill);
    canvas.drawRRect(rPlateR, fill);
    canvas.drawRRect(rPlateL, stroke);
    canvas.drawRRect(rPlateR, stroke);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class StartChoiceScreen extends StatelessWidget {
  const StartChoiceScreen({super.key});

  void _showContact(BuildContext context, String lang) {
    const phone = '92545267';
    const email = 'karolszymek1402@gmail.com';

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0E1528),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(18))),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Text(Translations.get('contact_sheet_title', language: lang),
                style: const TextStyle(
                    color: Color(0xFFFFD700),
                    fontWeight: FontWeight.w800,
                    fontSize: 16)),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.call, color: Color(0xFFFFD700)),
              title: Text(
                  Translations.get('contact_phone_label', language: lang),
                  style: const TextStyle(
                      color: Color(0xFFFFD700), fontWeight: FontWeight.w700)),
              subtitle:
                  const Text(phone, style: TextStyle(color: Color(0xFFFFD700))),
              onTap: () async {
                final Uri phoneUri = Uri(scheme: 'tel', path: phone);
                if (await canLaunchUrl(phoneUri)) {
                  await launchUrl(phoneUri);
                } else {
                  await Clipboard.setData(const ClipboardData(text: phone));
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(Translations.get('copied_phone',
                              language: lang))),
                    );
                  }
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.email, color: Color(0xFFFFD700)),
              title: Text(
                  Translations.get('contact_email_label', language: lang),
                  style: const TextStyle(
                      color: Color(0xFFFFD700), fontWeight: FontWeight.w700)),
              subtitle:
                  const Text(email, style: TextStyle(color: Color(0xFFFFD700))),
              onTap: () async {
                final Uri emailUri = Uri(scheme: 'mailto', path: email);
                if (await canLaunchUrl(emailUri)) {
                  await launchUrl(emailUri);
                } else {
                  await Clipboard.setData(const ClipboardData(text: email));
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(Translations.get('copied_email',
                              language: lang))),
                    );
                  }
                }
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Future<void> _setLanguage(BuildContext context, String lang) async {
    final prefs = await getPrefs();
    await prefs.setString('app_language', lang);
    updateGlobalLanguage(lang);
  }

  Future<void> _continueOffline(BuildContext context) async {
    final prefs = await getPrefs();
    final lang = prefs.getString('app_language') ?? globalLanguage;
    await prefs.setString('app_language', lang);
    updateGlobalLanguage(lang);
    if (context.mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const CategoryScreen()),
      );
    }
  }

  Future<void> _goToOnlinePlan(BuildContext context) async {
    final prefs = await getPrefs();
    final lang = prefs.getString('app_language') ?? globalLanguage;
    await prefs.setString('app_language', lang);
    updateGlobalLanguage(lang);
    if (context.mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const LoginScreen(
            themeColor: Color(0xFFFFD700),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const gold = Color(0xFFFFD700);
    const seed = Color(0xFF0B2E5A);
    return ValueListenableBuilder<String>(
      valueListenable: globalLanguageNotifier,
      builder: (context, lang, _) {
        final screenWidth = MediaQuery.of(context).size.width;
        final isSmallScreen = screenWidth < 400;
        final logoSize = isSmallScreen ? 140.0 : 180.0;
        final logoInnerSize = isSmallScreen ? 105.0 : 135.0;
        final horizontalPadding = isSmallScreen ? 20.0 : 32.0;

        return Scaffold(
          body: GymBackgroundWithFitness(
            goldDumbbells: false,
            backgroundImage: 'assets/moje_tlo.png',
            backgroundImageOpacity: 0.32,
            gradientColors: [
              const Color(0xFF0B2E5A),
              const Color(0xFF0A2652),
              const Color(0xFF0E3D8C),
            ],
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: isSmallScreen ? 16 : 24),
                      Container(
                        width: logoSize,
                        height: logoSize,
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
                        child: buildLogo(context, gold, size: logoInnerSize),
                      ),
                      SizedBox(height: isSmallScreen ? 20 : 32),
                      Wrap(
                        spacing: 10,
                        runSpacing: 8,
                        alignment: WrapAlignment.center,
                        children: ['EN', 'PL', 'NO'].map((code) {
                          final bool isActive = lang == code;
                          return ChoiceChip(
                            label: Text(code,
                                style: TextStyle(
                                    color: isActive ? Colors.black : gold,
                                    fontWeight: FontWeight.w700)),
                            selected: isActive,
                            onSelected: (_) => _setLanguage(context, code),
                            selectedColor: gold,
                            backgroundColor:
                                Colors.black.withValues(alpha: 0.35),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                    color: gold.withValues(alpha: 0.6))),
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
                      // Wyświetl imię użytkownika lub "Trener"
                      ValueListenableBuilder<PlanAccessState>(
                        valueListenable: PlanAccessController.instance.notifier,
                        builder: (context, state, _) {
                          if (!state.isAuthenticated) {
                            return const SizedBox.shrink();
                          }
                          String displayName;
                          if (state.role == PlanUserRole.coach) {
                            displayName = lang == 'PL'
                                ? 'Trener'
                                : lang == 'NO'
                                    ? 'Trener'
                                    : 'Coach';
                          } else {
                            // Pobierz imię z emaila (część przed @)
                            final email =
                                FirebaseAuth.instance.currentUser?.email ?? '';
                            final namePart = email.split('@').first;
                            // Zamień pierwszą literę na wielką
                            displayName = namePart.isNotEmpty
                                ? namePart[0].toUpperCase() +
                                    namePart.substring(1)
                                : email;
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              displayName,
                              style: TextStyle(
                                color: gold.withValues(alpha: 0.85),
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.none,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () => _goToOnlinePlan(context),
                        icon: const Icon(Icons.login, color: gold),
                        label: Text(
                          Translations.get('login_for_online_plan',
                              language: lang),
                          style: const TextStyle(
                            color: gold,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            decoration: TextDecoration.none,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color(0xFF1E90FF).withValues(alpha: 0.35),
                          foregroundColor: gold,
                          minimumSize: const Size(double.infinity, 52),
                          elevation: 0,
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
                          side: BorderSide(color: gold.withValues(alpha: 0.7)),
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          foregroundColor: gold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      OutlinedButton.icon(
                        onPressed: () => _showContact(context, lang),
                        icon: const Icon(Icons.contact_phone, color: gold),
                        label: Text(
                          Translations.get('contact', language: lang),
                          style: const TextStyle(
                            color: gold,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            decoration: TextDecoration.none,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: gold.withValues(alpha: 0.7)),
                          minimumSize: const Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          foregroundColor: gold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class PlanImportScreen extends StatefulWidget {
  final Color themeColor;
  const PlanImportScreen(
      {super.key, this.themeColor = const Color(0xFFFFD700)});

  @override
  State<PlanImportScreen> createState() => _PlanImportScreenState();
}

class _PlanImportScreenState extends State<PlanImportScreen> {
  final TextEditingController _planController = TextEditingController();
  bool _saving = false;
  String? _statusKey;
  bool _statusSuccess = false;

  static const _prefsKey = 'saved_plan_text';

  @override
  void initState() {
    super.initState();
    _loadPlan();
  }

  @override
  void dispose() {
    _planController.dispose();
    super.dispose();
  }

  Future<void> _loadPlan() async {
    try {
      final prefs = await getPrefs();
      final cached = prefs.getString(_prefsKey) ?? '';
      if (cached.isNotEmpty) {
        _planController.text = cached;
      }
    } catch (_) {}
  }

  Future<void> _savePlan() async {
    setState(() {
      _saving = true;
      _statusKey = null;
    });
    try {
      final prefs = await getPrefs();
      await prefs.setString(_prefsKey, _planController.text.trim());
      if (mounted) {
        setState(() {
          _statusKey = 'plan_saved_local';
          _statusSuccess = true;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _statusKey = 'plan_save_failed';
          _statusSuccess = false;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFFFFD700);
    return ValueListenableBuilder<String>(
        valueListenable: globalLanguageNotifier,
        builder: (context, lang, _) {
          return Scaffold(
            appBar: buildCustomAppBar(context, accentColor: accent),
            body: GymBackgroundWithFitness(
              accentColor: accent,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(Translations.get('plan', language: lang),
                        style: TextStyle(
                            color: accent,
                            fontSize: 22,
                            fontWeight: FontWeight.w800)),
                    const SizedBox(height: 8),
                    Text(
                      Translations.get('plan_local_desc', language: lang),
                      style: TextStyle(
                          color: Color(0xB3FFD700).withValues(alpha: 0.8)),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(14),
                        border:
                            Border.all(color: accent.withValues(alpha: 0.2)),
                      ),
                      child: TextField(
                        controller: _planController,
                        keyboardType: TextInputType.multiline,
                        maxLines: 14,
                        style: const TextStyle(color: Color(0xFFFFD700)),
                        decoration: InputDecoration(
                          hintText: Translations.get('plan_paste_hint',
                              language: lang),
                          hintStyle: const TextStyle(
                              color: Color(0x8AFFD700), fontSize: 14),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (_statusKey != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          Translations.get(_statusKey!, language: lang),
                          style: TextStyle(
                              color: _statusSuccess
                                  ? const Color(0xFF2ECC71)
                                  : Color(0xB3FFD700)),
                        ),
                      ),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _saving ? null : _savePlan,
                            icon: const Icon(Icons.save, color: Colors.black),
                            label: Text(_saving
                                ? Translations.get('plan_saving',
                                    language: lang)
                                : Translations.get('plan_save',
                                    language: lang)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: accent,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }
}

class LoginScreen extends StatefulWidget {
  final Color themeColor;
  const LoginScreen({super.key, this.themeColor = const Color(0xFFFFD700)});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  String? _error;
  bool _rememberMe = false;
  static const String _rememberMeKey = 'remember_me';
  static const String _savedEmailKey = 'saved_email';
  static const String _savedPasswordKey = 'saved_password';

  @override
  void initState() {
    super.initState();
    PlanAccessController.instance.initialize();
    _checkRememberedLogin();
  }

  Future<void> _checkRememberedLogin() async {
    final prefs = await getPrefs();
    final rememberMe = prefs.getBool(_rememberMeKey) ?? false;
    if (rememberMe) {
      final email = prefs.getString(_savedEmailKey);
      final password = prefs.getString(_savedPasswordKey);
      if (email != null &&
          password != null &&
          email.isNotEmpty &&
          password.isNotEmpty) {
        if (mounted) {
          setState(() {
            _emailController.text = email;
            _passwordController.text = password;
            _rememberMe = true;
          });
          // Auto-login
          _signIn();
        }
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    debugPrint('🔐 _signIn called with email: ${_emailController.text.trim()}');
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      debugPrint('🔐 Calling PlanAccessController.signIn...');
      await PlanAccessController.instance
          .signIn(_emailController.text.trim(), _passwordController.text);
      debugPrint('🔐 signIn completed successfully');

      // Zapisz dane logowania jeśli "Zapamiętaj mnie" jest włączone
      final prefs = await getPrefs();
      if (_rememberMe) {
        await prefs.setBool(_rememberMeKey, true);
        await prefs.setString(_savedEmailKey, _emailController.text.trim());
        await prefs.setString(_savedPasswordKey, _passwordController.text);
      } else {
        await prefs.setBool(_rememberMeKey, false);
        await prefs.remove(_savedEmailKey);
        await prefs.remove(_savedPasswordKey);
      }

      // Po zalogowaniu, sprawdź rolę użytkownika
      if (mounted) {
        // Poczekaj chwilę na aktualizację stanu przez Firebase listener
        await Future.delayed(const Duration(milliseconds: 500));

        final state = PlanAccessController.instance.notifier.value;
        debugPrint(
            '🔐 State after login: isAuthenticated=${state.isAuthenticated}, role=${state.role}, email=${state.userEmail}');

        if (state.isAuthenticated) {
          debugPrint('🔐 User authenticated, redirecting...');
          if (state.role == PlanUserRole.client) {
            // Klient - przekieruj do CategoryScreen
            debugPrint('🔐 Redirecting to CategoryScreen (client)');
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const CategoryScreen()),
            );
          } else if (state.role == PlanUserRole.coach) {
            // Trener - przekieruj do CoachDashboardScreen
            debugPrint('🔐 Redirecting to CoachDashboardScreen (coach)');
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const CoachDashboardScreen()),
            );
          } else {
            debugPrint(
                '🔐 Unknown role: ${state.role}, redirecting to CategoryScreen');
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const CategoryScreen()),
            );
          }
        } else {
          debugPrint('🔐 User not authenticated after signIn!');
          setState(() {
            _error = 'Logowanie nie powiodło się - spróbuj ponownie';
          });
        }
      }
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
    const accent = Color(0xFFFFD700);
    return ValueListenableBuilder<String>(
      valueListenable: globalLanguageNotifier,
      builder: (context, lang, _) {
        return Scaffold(
          appBar: buildCustomAppBar(context, accentColor: accent),
          body: GymBackgroundWithFitness(
            accentColor: accent,
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Card(
                    color: Colors.black.withValues(alpha: 0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: accent.withValues(alpha: 0.3)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 22),
                      child: ValueListenableBuilder<PlanAccessState>(
                        valueListenable: PlanAccessController.instance.notifier,
                        builder: (context, state, _) {
                          if (state.isAuthenticated) {
                            // Automatyczne przekierowanie dla zalogowanych użytkowników
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (state.role == PlanUserRole.coach) {
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          const CoachDashboardScreen()),
                                );
                              } else if (state.role == PlanUserRole.client) {
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                      builder: (_) => const CategoryScreen()),
                                );
                              }
                            });
                            return const Center(
                              child: CircularProgressIndicator(
                                  color: Color(0xFFFFD700)),
                            );
                          }

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                  Translations.get('login_title',
                                      language: lang),
                                  style: TextStyle(
                                      color: accent,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 20)),
                              const SizedBox(height: 16),
                              TextField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(
                                    labelText: Translations.get('email',
                                        language: lang),
                                    prefixIcon: const Icon(
                                        Icons.alternate_email,
                                        size: 20,
                                        color: Color(0xFFFFD700))),
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: _passwordController,
                                obscureText: true,
                                decoration: InputDecoration(
                                    labelText: Translations.get('password',
                                        language: lang),
                                    prefixIcon: const Icon(Icons.lock,
                                        size: 20, color: Color(0xFFFFD700))),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: Checkbox(
                                      value: _rememberMe,
                                      onChanged: (value) {
                                        setState(() {
                                          _rememberMe = value ?? false;
                                        });
                                      },
                                      activeColor: accent,
                                      checkColor: Colors.black,
                                      side: BorderSide(
                                          color: accent.withValues(alpha: 0.7)),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _rememberMe = !_rememberMe;
                                      });
                                    },
                                    child: Text(
                                      Translations.get('remember_me',
                                          language: lang),
                                      style: TextStyle(
                                        color: accent.withValues(alpha: 0.9),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              if (_error != null)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Text(
                                    _error!,
                                    style: const TextStyle(
                                        color: Color(0xFFFF5252), fontSize: 13),
                                  ),
                                ),
                              ElevatedButton.icon(
                                onPressed: _loading ? null : _signIn,
                                icon: _loading
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.black))
                                    : const Icon(Icons.login,
                                        color: Colors.black),
                                label: Text(_loading
                                    ? Translations.get('logging_in',
                                        language: lang)
                                    : Translations.get('login_action',
                                        language: lang)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: accent,
                                  foregroundColor: Colors.black,
                                  minimumSize: const Size(double.infinity, 48),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                Translations.get('test_version_hint',
                                    language: lang),
                                style: const TextStyle(
                                    color: Color(0x8AFFD700), fontSize: 12),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class PlanOnlineScreen extends StatefulWidget {
  final Color themeColor;
  const PlanOnlineScreen(
      {super.key, this.themeColor = const Color(0xFFFFD700)});

  @override
  State<PlanOnlineScreen> createState() => _PlanOnlineScreenState();
}

class _PlanOnlineScreenState extends State<PlanOnlineScreen> {
  bool _fetching = false;
  String? _statusKey;

  @override
  void initState() {
    super.initState();
    _ensurePlan();
  }

  Future<void> _ensurePlan() async {
    final state = PlanAccessController.instance.notifier.value;
    final email = state.userEmail;
    if (email == null || email.isEmpty) {
      setState(() {
        _statusKey = 'no_active_user';
      });
      return;
    }
    if (state.activePlan != null) return;
    setState(() {
      _fetching = true;
      _statusKey = null;
    });
    try {
      final plan = await PlanAccessController.instance.fetchPlanForEmail(email);
      if (mounted && plan == null) {
        setState(() {
          _statusKey = 'no_online_plan';
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _statusKey = 'plan_fetch_failed';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _fetching = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFFFFD700);
    return ValueListenableBuilder<String>(
      valueListenable: globalLanguageNotifier,
      builder: (context, lang, _) {
        return Scaffold(
          appBar: buildCustomAppBar(context, accentColor: accent),
          body: GymBackgroundWithFitness(
            accentColor: accent,
            child: ValueListenableBuilder<PlanAccessState>(
              valueListenable: PlanAccessController.instance.notifier,
              builder: (context, state, _) {
                if (!state.isAuthenticated) {
                  return Center(
                    child: Text(
                        Translations.get('login_required', language: lang),
                        style: TextStyle(color: Color(0xB3FFD700))),
                  );
                }
                if (state.role == PlanUserRole.coach) {
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                            Translations.get('coach_mode_title',
                                language: lang),
                            style: TextStyle(
                                color: accent,
                                fontWeight: FontWeight.w800,
                                fontSize: 20)),
                        const SizedBox(height: 12),
                        Text(
                          Translations.get('coach_mode_hint', language: lang),
                          style: TextStyle(color: Color(0xB3FFD700)),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }
                if (_fetching || state.planLoading) {
                  return const Center(
                      child:
                          CircularProgressIndicator(color: Color(0xFFFFD700)));
                }
                if (state.activePlan == null) {
                  final statusText = _statusKey == null
                      ? Translations.get('no_online_plan', language: lang)
                      : Translations.get(_statusKey!, language: lang);
                  return Center(
                      child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(statusText,
                          style: TextStyle(color: Color(0xB3FFD700))),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: _ensurePlan,
                        icon: const Icon(Icons.refresh, color: Colors.black),
                        label:
                            Text(Translations.get('refresh', language: lang)),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: accent,
                            foregroundColor: Colors.black),
                      )
                    ],
                  ));
                }

                final plan = state.activePlan!;

                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Nagłówek planu
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            accent.withValues(alpha: 0.2),
                            accent.withValues(alpha: 0.05),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border:
                            Border.all(color: accent.withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: accent,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.fitness_center,
                                    color: Colors.black, size: 24),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(plan.title,
                                        style: const TextStyle(
                                            color: accent,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 20)),
                                    const SizedBox(height: 4),
                                    Text(
                                        Translations.withParams(
                                            'plan_updated_at',
                                            language: lang,
                                            params: {
                                              'date': plan.updatedAt
                                                  .toLocal()
                                                  .toString()
                                                  .split('.')
                                                  .first
                                            }),
                                        style: TextStyle(
                                            color:
                                                accent.withValues(alpha: 0.7),
                                            fontSize: 11)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          if (plan.notes.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(8)),
                              child: Text(plan.notes,
                                  style: TextStyle(
                                      color: accent.withValues(alpha: 0.85),
                                      fontSize: 13)),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Lista ćwiczeń
                    if (plan.entries.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            children: [
                              Icon(Icons.fitness_center,
                                  color: accent.withValues(alpha: 0.3),
                                  size: 48),
                              const SizedBox(height: 12),
                              Text(
                                lang == 'PL'
                                    ? 'Brak ćwiczeń w planie'
                                    : lang == 'NO'
                                        ? 'Ingen øvelser i planen'
                                        : 'No exercises in plan',
                                style: TextStyle(
                                    color: accent.withValues(alpha: 0.6)),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ...plan.entries.asMap().entries.map((entry) {
                        final idx = entry.key;
                        final exercise = entry.value;
                        final isTimeBased = exercise.timeSeconds > 0;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                accent.withValues(alpha: 0.1),
                                Colors.black.withValues(alpha: 0.35),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: accent.withValues(alpha: 0.2)),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 6),
                            leading: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    accent,
                                    accent.withValues(alpha: 0.7)
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: accent.withValues(alpha: 0.3),
                                    blurRadius: 6,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  '${idx + 1}',
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                            title: Text(
                              localizedExerciseName(
                                  exercise.exercise, globalLanguage),
                              style: const TextStyle(
                                color: accent,
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Wrap(
                                spacing: 8,
                                runSpacing: 4,
                                children: [
                                  _buildInfoChip(
                                      Icons.repeat,
                                      '${exercise.sets} ${lang == 'PL' ? 'serii' : 'sets'}',
                                      accent),
                                  _buildInfoChip(
                                      Icons.timer_outlined,
                                      '${exercise.restSeconds}s ${lang == 'PL' ? 'przerwy' : 'rest'}',
                                      accent),
                                  if (isTimeBased)
                                    _buildInfoChip(
                                        Icons.hourglass_bottom,
                                        '${exercise.timeSeconds}s',
                                        const Color(0xFFFFD700)),
                                ],
                              ),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ExerciseDetailScreen(
                                    exerciseName: exercise.exercise,
                                    themeColor: accent,
                                    recommendedSets: exercise.sets,
                                    recommendedRestSeconds:
                                        exercise.restSeconds,
                                    recommendedTimeSeconds:
                                        exercise.timeSeconds > 0
                                            ? exercise.timeSeconds
                                            : null,
                                  ),
                                ),
                              );
                            },
                            trailing: const Icon(Icons.chevron_right,
                                color: accent, size: 22),
                          ),
                        );
                      }),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color.withValues(alpha: 0.9)),
          const SizedBox(width: 4),
          Text(text,
              style: TextStyle(
                  color: color.withValues(alpha: 0.95),
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class CoachDashboardScreen extends StatelessWidget {
  final Color themeColor;
  const CoachDashboardScreen(
      {super.key, this.themeColor = const Color(0xFFFFD700)});

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFFFFD700);
    return ValueListenableBuilder<String>(
      valueListenable: globalLanguageNotifier,
      builder: (context, lang, _) {
        return Scaffold(
          appBar: buildCustomAppBar(context, accentColor: accent),
          body: GymBackgroundWithFitness(
            backgroundImage: 'assets/moje_tlo.png',
            backgroundImageOpacity: 0.32,
            accentColor: accent,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.fitness_center, size: 80, color: accent),
                    const SizedBox(height: 20),
                    Text(
                      lang == 'PL'
                          ? 'Panel Trenera'
                          : lang == 'NO'
                              ? 'Trener Panel'
                              : 'Coach Dashboard',
                      style: TextStyle(
                        color: accent,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ValueListenableBuilder<PlanAccessState>(
                      valueListenable: PlanAccessController.instance.notifier,
                      builder: (context, state, _) {
                        return Text(
                          state.userEmail ?? '',
                          style: const TextStyle(
                              color: Color(0xB3FFD700), fontSize: 14),
                        );
                      },
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const ClientsScreen()),
                          );
                        },
                        icon: const Icon(Icons.people,
                            color: Colors.black, size: 28),
                        label: Text(
                          lang == 'PL'
                              ? 'Lista klientów'
                              : lang == 'NO'
                                  ? 'Klientliste'
                                  : 'Client List',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w700),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accent,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    const ClientsScreen(openAddDialog: true)),
                          );
                        },
                        icon: const Icon(Icons.person_add,
                            color: Colors.black, size: 28),
                        label: Text(
                          Translations.get('add_client', language: lang),
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w700),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accent,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    OutlinedButton.icon(
                      onPressed: () async {
                        // Wyczyść dane "Zapamiętaj mnie" przy wylogowaniu
                        final prefs = await getPrefs();
                        await prefs.setBool('remember_me', false);
                        await prefs.remove('saved_email');
                        await prefs.remove('saved_password');

                        await PlanAccessController.instance.signOut();
                        if (context.mounted) {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (_) => const StartChoiceScreen()),
                            (route) => false,
                          );
                        }
                      },
                      icon: const Icon(Icons.logout,
                          color: Color(0xFFFF5252), size: 20),
                      label: Text(
                        lang == 'PL'
                            ? 'Wyloguj'
                            : lang == 'NO'
                                ? 'Logg ut'
                                : 'Logout',
                        style: const TextStyle(color: Color(0xFFFF5252)),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                            color:
                                const Color(0xFFFF5252).withValues(alpha: 0.5)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 10),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class ClientsScreen extends StatefulWidget {
  final Color themeColor;
  final bool openAddDialog;
  const ClientsScreen(
      {super.key,
      this.themeColor = const Color(0xFFFFD700),
      this.openAddDialog = false});

  @override
  State<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  List<String> _clientEmails = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadClients().then((_) {
      if (widget.openAddDialog && mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _addClientDialog();
        });
      }
    });
  }

  Future<void> _loadClients() async {
    setState(() => _loading = true);
    try {
      final emails = await PlanAccessController.instance.fetchAllClientEmails();
      if (mounted) {
        setState(() {
          _clientEmails = emails;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _addClientDialog() async {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final passwordCtrl = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Colors.black.withValues(alpha: 0.8),
          title: Text(Translations.get('add_client', language: globalLanguage),
              style: const TextStyle(color: Color(0xFFFFD700))),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                style: const TextStyle(color: Color(0xFFFFD700)),
                decoration: InputDecoration(
                    labelText: globalLanguage == 'PL'
                        ? 'Imię i nazwisko'
                        : globalLanguage == 'NO'
                            ? 'Navn'
                            : 'Full name',
                    prefixIcon: const Icon(Icons.person)),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: emailCtrl,
                style: const TextStyle(color: Color(0xFFFFD700)),
                decoration: InputDecoration(
                    labelText:
                        Translations.get('email', language: globalLanguage),
                    prefixIcon: const Icon(Icons.email)),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: passwordCtrl,
                obscureText: true,
                style: const TextStyle(color: Color(0xFFFFD700)),
                decoration: InputDecoration(
                    labelText: globalLanguage == 'PL'
                        ? 'Hasło (min. 6 znaków)'
                        : globalLanguage == 'NO'
                            ? 'Passord (min. 6 tegn)'
                            : 'Password (min. 6 chars)',
                    prefixIcon: const Icon(Icons.lock)),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child:
                    Text(Translations.get('cancel', language: globalLanguage))),
            ElevatedButton(
                onPressed: () {
                  if (emailCtrl.text.trim().isNotEmpty &&
                      passwordCtrl.text.trim().length >= 6) {
                    Navigator.pop(ctx, true);
                  }
                },
                child:
                    Text(Translations.get('save', language: globalLanguage))),
          ],
        );
      },
    );
    if (result == true) {
      try {
        await PlanAccessController.instance.createClientAccount(
          emailCtrl.text.trim(),
          passwordCtrl.text.trim(),
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Klient dodany pomyślnie')),
          );
          _loadClients();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    '${Translations.get('error', language: globalLanguage)}: ${e.toString()}')),
          );
        }
      }
    }
  }

  Future<void> _deleteClient(String email) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.black.withValues(alpha: 0.9),
        title: Text(Translations.get('delete_client', language: globalLanguage),
            style: const TextStyle(color: Color(0xFFFFD700))),
        content: Text(
          globalLanguage == 'PL'
              ? 'Czy na pewno chcesz usunąć klienta $email?\n\nTa operacja usunie również wszystkie dane klienta (plan, historię ćwiczeń).'
              : globalLanguage == 'NO'
                  ? 'Er du sikker på at du vil slette klienten $email?\n\nDenne operasjonen sletter også alle klientens data (plan, treningshistorikk).'
                  : 'Are you sure you want to delete client $email?\n\nThis will also delete all client data (plan, exercise history).',
          style: const TextStyle(color: Color(0xB3FFD700)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(Translations.get('cancel', language: globalLanguage)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF5252)),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(Translations.get('delete', language: globalLanguage)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await PlanAccessController.instance.deleteClient(email);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Klient usunięty')),
          );
          _loadClients();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    '${Translations.get('error', language: globalLanguage)}: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = widget.themeColor;
    return Scaffold(
      appBar: buildCustomAppBar(context, accentColor: accent),
      body: GymBackgroundWithFitness(
        backgroundImage: 'assets/moje_tlo.png',
        backgroundImageOpacity: 0.32,
        accentColor: accent,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  globalLanguage == 'PL'
                      ? 'Lista klientów'
                      : globalLanguage == 'NO'
                          ? 'Kundeliste'
                          : 'Client list',
                  style: TextStyle(
                      color: accent,
                      fontWeight: FontWeight.w800,
                      fontSize: 22)),
              const SizedBox(height: 14),
              Expanded(
                child: _loading
                    ? const Center(
                        child:
                            CircularProgressIndicator(color: Color(0xFFFFD700)),
                      )
                    : _clientEmails.isEmpty
                        ? Center(
                            child: Text(
                                Translations.get('no_clients',
                                    language: globalLanguage),
                                style:
                                    const TextStyle(color: Color(0xB3FFD700))),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadClients,
                            child: ListView.separated(
                              itemCount: _clientEmails.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 10),
                              itemBuilder: (context, index) {
                                final email = _clientEmails[index];
                                return Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.35),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: accent.withValues(alpha: 0.4)),
                                  ),
                                  child: ListTile(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => ClientDetailScreen(
                                            clientEmail: email,
                                          ),
                                        ),
                                      ).then((_) => _loadClients());
                                    },
                                    leading: CircleAvatar(
                                      backgroundColor: accent,
                                      child: const Icon(Icons.person,
                                          color: Colors.black),
                                    ),
                                    title: Text(email,
                                        style: const TextStyle(
                                            color: Color(0xFFFFD700),
                                            fontWeight: FontWeight.w700)),
                                    subtitle: const Text('Klient',
                                        style: TextStyle(
                                            color: Color(0xFF2ECC71))),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.delete,
                                              color: Color(0xFFFF5252),
                                              size: 22),
                                          onPressed: () => _deleteClient(email),
                                        ),
                                        const Icon(Icons.chevron_right,
                                            color: Color(0xFFFFD700)),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
              ),
            ],
          ),
        ),
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
    this.themeColor = const Color(0xFFFFD700),
  });

  @override
  State<ClientDetailScreen> createState() => _ClientDetailScreenState();
}

class _ClientDetailScreenState extends State<ClientDetailScreen> {
  ClientPlan? _plan;
  bool _loading = true;
  final ScrollController _scrollController = ScrollController();

  // Nazwy dni tygodnia
  static const List<String> _dayNamesPL = [
    'Poniedziałek',
    'Wtorek',
    'Środa',
    'Czwartek',
    'Piątek',
    'Sobota',
    'Niedziela'
  ];
  static const List<String> _dayNamesEN = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];
  static const List<String> _dayNamesNO = [
    'Mandag',
    'Tirsdag',
    'Onsdag',
    'Torsdag',
    'Fredag',
    'Lørdag',
    'Søndag'
  ];

  List<String> get _dayNames {
    switch (globalLanguage) {
      case 'NO':
        return _dayNamesNO;
      case 'EN':
        return _dayNamesEN;
      default:
        return _dayNamesPL;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadPlan();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadPlan() async {
    setState(() => _loading = true);
    try {
      final plan = await PlanAccessController.instance
          .fetchPlanForEmail(widget.clientEmail);
      if (mounted) {
        setState(() {
          _plan = plan;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  // Odświeża plan bez pokazywania loadera - zachowuje pozycję scrollowania
  Future<void> _refreshPlan() async {
    try {
      final plan = await PlanAccessController.instance
          .fetchPlanForEmail(widget.clientEmail);
      if (mounted) {
        setState(() {
          _plan = plan;
        });
      }
    } catch (_) {}
  }

  // Sprawdź czy dzień jest dniem wolnym
  bool _isRestDay(int dayIndex) {
    return _plan?.restDays.contains(dayIndex) ?? false;
  }

  // Pobierz ćwiczenia dla danego dnia
  List<ClientPlanEntry> _getExercisesForDay(int dayIndex) {
    if (_plan == null) return [];
    return _plan!.entries.where((e) => e.dayOfWeek == dayIndex).toList();
  }

  // Przełącz dzień wolny
  Future<void> _toggleRestDay(int dayIndex) async {
    final currentRestDays = List<int>.from(_plan?.restDays ?? []);
    if (currentRestDays.contains(dayIndex)) {
      currentRestDays.remove(dayIndex);
    } else {
      currentRestDays.add(dayIndex);
      // Usuń ćwiczenia z tego dnia gdy oznaczamy jako wolny
      final entriesWithoutDay =
          (_plan?.entries ?? []).where((e) => e.dayOfWeek != dayIndex).toList();
      await PlanAccessController.instance.updateClientPlanEntries(
        widget.clientEmail,
        entriesWithoutDay,
      );
    }
    await PlanAccessController.instance.updateClientPlanRestDays(
      widget.clientEmail,
      currentRestDays,
    );
    _refreshPlan();
  }

  // Przenieś wszystkie ćwiczenia z jednego dnia na inny
  Future<void> _moveDayExercises(int fromDayIndex) async {
    final lang = globalLanguage;
    final fromDayName = _dayNames[fromDayIndex];

    // Pobierz listę dni do wyboru (bez aktualnego dnia)
    final availableDays =
        List.generate(7, (i) => i).where((i) => i != fromDayIndex).toList();

    int? selectedDay;

    final result = await showDialog<int>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: Colors.black.withValues(alpha: 0.95),
            title: Text(
              lang == 'PL'
                  ? 'Przenieś trening'
                  : lang == 'NO'
                      ? 'Flytt trening'
                      : 'Move workout',
              style: const TextStyle(color: Color(0xFFFFD700)),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lang == 'PL'
                      ? 'Przenieś ćwiczenia z dnia:'
                      : lang == 'NO'
                          ? 'Flytt øvelser fra:'
                          : 'Move exercises from:',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
                ),
                const SizedBox(height: 4),
                Text(
                  fromDayName,
                  style: const TextStyle(
                    color: Color(0xFFFFD700),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  lang == 'PL'
                      ? 'Wybierz dzień docelowy:'
                      : lang == 'NO'
                          ? 'Velg måldag:'
                          : 'Select target day:',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
                ),
                const SizedBox(height: 8),
                ...availableDays.map((dayIndex) {
                  final dayName = _dayNames[dayIndex];
                  final isRestDay = _isRestDay(dayIndex);
                  final exerciseCount = _getExercisesForDay(dayIndex).length;
                  final isSelected = selectedDay == dayIndex;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: InkWell(
                      onTap: () {
                        setDialogState(() {
                          selectedDay = dayIndex;
                        });
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFFFFD700).withValues(alpha: 0.2)
                              : Colors.black.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFFFFD700)
                                : Colors.white.withValues(alpha: 0.2),
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isRestDay ? Icons.hotel : Icons.fitness_center,
                              color: isRestDay
                                  ? const Color(0xFF4CAF50)
                                  : const Color(0xFFFFD700),
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    dayName,
                                    style: TextStyle(
                                      color: isSelected
                                          ? const Color(0xFFFFD700)
                                          : Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    isRestDay
                                        ? (lang == 'PL'
                                            ? 'Dzień wolny'
                                            : lang == 'NO'
                                                ? 'Hviledag'
                                                : 'Rest day')
                                        : (exerciseCount > 0
                                            ? '$exerciseCount ${lang == 'PL' ? 'ćwiczeń' : lang == 'NO' ? 'øvelser' : 'exercises'}'
                                            : (lang == 'PL'
                                                ? 'Brak ćwiczeń'
                                                : lang == 'NO'
                                                    ? 'Ingen øvelser'
                                                    : 'No exercises')),
                                    style: TextStyle(
                                      color:
                                          Colors.white.withValues(alpha: 0.5),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              const Icon(Icons.check_circle,
                                  color: Color(0xFFFFD700), size: 20),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
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
                onPressed: selectedDay != null
                    ? () => Navigator.pop(ctx, selectedDay)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD700),
                  foregroundColor: Colors.black,
                  disabledBackgroundColor: Colors.grey.withValues(alpha: 0.3),
                ),
                child: Text(
                  lang == 'PL'
                      ? 'Przenieś'
                      : lang == 'NO'
                          ? 'Flytt'
                          : 'Move',
                ),
              ),
            ],
          );
        },
      ),
    );

    if (result != null) {
      try {
        // Pobierz aktualne wpisy
        final entries = List<ClientPlanEntry>.from(_plan?.entries ?? []);

        // Przenieś ćwiczenia z fromDayIndex na result (nowy dzień)
        final updatedEntries = entries.map((e) {
          if (e.dayOfWeek == fromDayIndex) {
            return e.copyWith(dayOfWeek: result);
          }
          return e;
        }).toList();

        // Usuń fromDayIndex z dni wolnych jeśli był (bo przenosimy ćwiczenia)
        final currentRestDays = List<int>.from(_plan?.restDays ?? []);
        if (currentRestDays.contains(result)) {
          currentRestDays.remove(result);
          await PlanAccessController.instance.updateClientPlanRestDays(
            widget.clientEmail,
            currentRestDays,
          );
        }

        await PlanAccessController.instance.updateClientPlanEntries(
          widget.clientEmail,
          updatedEntries,
        );

        await _refreshPlan();

        if (mounted) {
          final toDayName = _dayNames[result];
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                lang == 'PL'
                    ? 'Przeniesiono trening z $fromDayName na $toDayName'
                    : lang == 'NO'
                        ? 'Trening flyttet fra $fromDayName til $toDayName'
                        : 'Moved workout from $fromDayName to $toDayName',
              ),
              backgroundColor: const Color(0xFF4CAF50),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${lang == 'PL' ? 'Błąd' : 'Error'}: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _editPlan() async {
    final titleCtrl =
        TextEditingController(text: _plan?.title ?? 'New Training Plan');
    final notesCtrl = TextEditingController(text: _plan?.notes ?? '');

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.black.withValues(alpha: 0.9),
        title: Text(Translations.get('edit_plan', language: globalLanguage),
            style: const TextStyle(color: Color(0xFFFFD700))),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                style: const TextStyle(color: Color(0xFFFFD700)),
                decoration: InputDecoration(
                  labelText: globalLanguage == 'PL'
                      ? 'Tytuł planu'
                      : globalLanguage == 'NO'
                          ? 'Plantittel'
                          : 'Plan title',
                  labelStyle: const TextStyle(color: Color(0xB3FFD700)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: notesCtrl,
                style: const TextStyle(color: Color(0xFFFFD700)),
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: globalLanguage == 'PL'
                      ? 'Notatki'
                      : globalLanguage == 'NO'
                          ? 'Notater'
                          : 'Notes',
                  labelStyle: const TextStyle(color: Color(0xB3FFD700)),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(Translations.get('cancel', language: globalLanguage)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(Translations.get('save', language: globalLanguage)),
          ),
        ],
      ),
    );

    if (result == true) {
      try {
        await PlanAccessController.instance.updateClientPlan(
          widget.clientEmail,
          title: titleCtrl.text.trim(),
          notes: notesCtrl.text.trim(),
        );
        _refreshPlan();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Plan zaktualizowany')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    '${Translations.get('error', language: globalLanguage)}: $e')),
          );
        }
      }
    }
  }

  Future<void> _addExerciseForDay(int dayIndex) async {
    final setsCtrl = TextEditingController(text: '3');
    final restCtrl = TextEditingController(text: '90');
    final timeCtrl = TextEditingController(text: '30');
    final noteCtrl = TextEditingController();
    final searchCtrl = TextEditingController();
    bool isTimeBased = false;
    String searchQuery = '';

    // Pobierz kategorie z kCategoryNames (bez 'PLAN')
    final categories =
        kCategoryNames.keys.where((key) => key != 'PLAN').toList();
    String selectedCategory = categories.first;

    // Pobierz ćwiczenia z wybranej kategorii
    List<String> exercisesForCategory =
        kDefaultExercises[selectedCategory] ?? [];
    String? selectedExercise =
        exercisesForCategory.isNotEmpty ? exercisesForCategory.first : null;

    // Mapa ćwiczenie -> kategoria dla wyświetlania kategorii przy wyszukiwaniu
    final Map<String, String> exerciseToCategoryMap = {};
    for (final cat in categories) {
      for (final ex in kDefaultExercises[cat] ?? []) {
        exerciseToCategoryMap[ex] = cat;
      }
    }

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          // Filtruj ćwiczenia na podstawie wyszukiwania
          List<String> filteredExercises;
          if (searchQuery.isNotEmpty) {
            // Szukaj we wszystkich kategoriach - używaj Set aby uniknąć duplikatów
            final allExercisesSet = <String>{};
            for (final cat in categories) {
              allExercisesSet.addAll(kDefaultExercises[cat] ?? []);
            }
            filteredExercises = allExercisesSet
                .where((ex) =>
                    ex.toLowerCase().contains(searchQuery.toLowerCase()))
                .toSet() // Dodatkowe zabezpieczenie przed duplikatami
                .toList();
          } else {
            // Aktualizuj listę ćwiczeń gdy zmieni się kategoria
            exercisesForCategory = kDefaultExercises[selectedCategory] ?? [];
            // Usuń duplikaty z kategorii
            filteredExercises = exercisesForCategory.toSet().toList();
          }

          // Upewnij się że selectedExercise jest w liście
          if (filteredExercises.isEmpty) {
            selectedExercise = null;
          } else if (selectedExercise == null ||
              !filteredExercises.contains(selectedExercise)) {
            selectedExercise = filteredExercises.first;
          }
          // Automatycznie ustaw czy ćwiczenie jest na czas
          if (selectedExercise != null) {
            isTimeBased = kTimeBasedExercises.contains(selectedExercise);
          }

          return AlertDialog(
            backgroundColor: Colors.black.withValues(alpha: 0.9),
            title: Text(
                Translations.get('add_exercise', language: globalLanguage),
                style: const TextStyle(color: Color(0xFFFFD700))),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Pole wyszukiwania
                  TextField(
                    controller: searchCtrl,
                    style: const TextStyle(color: Color(0xFFFFD700)),
                    decoration: InputDecoration(
                      hintText: Translations.get('search_hint',
                          language: globalLanguage),
                      hintStyle: TextStyle(
                          color:
                              const Color(0xFFFFD700).withValues(alpha: 0.5)),
                      prefixIcon:
                          const Icon(Icons.search, color: Color(0xFFFFD700)),
                      suffixIcon: searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear,
                                  color: Color(0xFFFFD700)),
                              onPressed: () {
                                searchCtrl.clear();
                                setDialogState(() {
                                  searchQuery = '';
                                });
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                            color:
                                const Color(0xFFFFD700).withValues(alpha: 0.5)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFFFD700)),
                      ),
                    ),
                    onChanged: (val) {
                      setDialogState(() {
                        searchQuery = val;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  // Kategoria - dropdown (ukryty gdy wyszukiwanie aktywne)
                  if (searchQuery.isEmpty)
                    DropdownButtonFormField<String>(
                      value: selectedCategory,
                      dropdownColor: const Color(0xFF1A1A2E),
                      style: const TextStyle(color: Color(0xFF2ECC71)),
                      decoration: InputDecoration(
                        labelText: Translations.get('category',
                            language: globalLanguage),
                        labelStyle: const TextStyle(color: Color(0xFF2ECC71)),
                        border: const OutlineInputBorder(),
                      ),
                      items: categories
                          .map((cat) => DropdownMenuItem(
                                value: cat,
                                child: Text(
                                    localizedCategoryName(cat, globalLanguage),
                                    style: const TextStyle(
                                        color: Color(0xFF2ECC71))),
                              ))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() {
                            selectedCategory = val;
                            exercisesForCategory = kDefaultExercises[val] ?? [];
                            selectedExercise = exercisesForCategory.isNotEmpty
                                ? exercisesForCategory.first
                                : null;
                            if (selectedExercise != null) {
                              isTimeBased = kTimeBasedExercises
                                  .contains(selectedExercise);
                            }
                          });
                        }
                      },
                    ),
                  if (searchQuery.isEmpty) const SizedBox(height: 12),
                  // Ćwiczenie - dropdown z bazą
                  if (filteredExercises.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        Translations.get('no_results',
                            language: globalLanguage),
                        style: TextStyle(
                            color:
                                const Color(0xFFFFD700).withValues(alpha: 0.6)),
                      ),
                    )
                  else
                    DropdownButtonFormField<String>(
                      value: selectedExercise,
                      dropdownColor: const Color(0xFF1A1A2E),
                      isExpanded: true,
                      menuMaxHeight: 300,
                      style: const TextStyle(
                          color: Color(0xFF2ECC71), fontSize: 13),
                      decoration: InputDecoration(
                        labelText:
                            '${Translations.get('exercise', language: globalLanguage)} (${filteredExercises.length})',
                        labelStyle: TextStyle(color: Color(0xFF2ECC71)),
                        border: OutlineInputBorder(),
                      ),
                      items: filteredExercises.map((ex) {
                        // Pobierz kategorię dla ćwiczenia
                        final category = exerciseToCategoryMap[ex] ?? '';
                        final categoryLabel = searchQuery.isNotEmpty &&
                                category.isNotEmpty
                            ? ' [${localizedCategoryName(category, globalLanguage)}]'
                            : '';
                        final exerciseName =
                            localizedExerciseName(ex, globalLanguage);
                        return DropdownMenuItem(
                          value: ex,
                          child: Text(
                            '$exerciseName$categoryLabel',
                            style: const TextStyle(color: Color(0xFF2ECC71)),
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() {
                            selectedExercise = val;
                            isTimeBased = kTimeBasedExercises.contains(val);
                          });
                        }
                      },
                    ),
                  const SizedBox(height: 12),
                  // Info czy ćwiczenie na czas
                  if (isTimeBased)
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD700).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.timer,
                              color: Color(0xFFFFD700), size: 18),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              Translations.get('time_based_exercise',
                                  language: globalLanguage),
                              style: TextStyle(
                                  color: Color(0xFFFFD700), fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (isTimeBased) const SizedBox(height: 12),
                  // Serie - zawsze widoczne
                  TextField(
                    controller: setsCtrl,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Color(0xFF2ECC71)),
                    decoration: InputDecoration(
                      labelText: Translations.get('sets_count',
                          language: globalLanguage),
                      labelStyle: TextStyle(color: Color(0xFF2ECC71)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Czas trwania - tylko dla ćwiczeń na czas (co 30s)
                  if (isTimeBased)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            Translations.get('exercise_duration',
                                language: globalLanguage),
                            style: TextStyle(
                                color: Color(0xFF2ECC71), fontSize: 12)),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              onPressed: () {
                                int val = int.tryParse(timeCtrl.text) ?? 30;
                                if (val >= 30) {
                                  val -= 30;
                                  timeCtrl.text = val.toString();
                                  setDialogState(() {});
                                }
                              },
                              icon: const Icon(Icons.remove_circle,
                                  color: Color(0xFFFF5252), size: 32),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                border:
                                    Border.all(color: const Color(0xFFFFD700)),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${timeCtrl.text}s',
                                style: const TextStyle(
                                    color: Color(0xFFFFD700),
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                int val = int.tryParse(timeCtrl.text) ?? 0;
                                val += 30;
                                timeCtrl.text = val.toString();
                                setDialogState(() {});
                              },
                              icon: const Icon(Icons.add_circle,
                                  color: Color(0xFF2ECC71), size: 32),
                            ),
                          ],
                        ),
                      ],
                    ),
                  if (isTimeBased) const SizedBox(height: 12),
                  // Przerwa - zawsze widoczna (co 30s)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          Translations.get('rest_time_label',
                              language: globalLanguage),
                          style: TextStyle(
                              color: Color(0xFF2ECC71), fontSize: 12)),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: () {
                              int val = int.tryParse(restCtrl.text) ?? 30;
                              if (val >= 30) {
                                val -= 30;
                                restCtrl.text = val.toString();
                                setDialogState(() {});
                              }
                            },
                            icon: const Icon(Icons.remove_circle,
                                color: Color(0xFFFF5252), size: 32),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              border:
                                  Border.all(color: const Color(0xFFFFD700)),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${restCtrl.text}s',
                              style: const TextStyle(
                                  color: Color(0xFFFFD700),
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              int val = int.tryParse(restCtrl.text) ?? 0;
                              val += 30;
                              restCtrl.text = val.toString();
                              setDialogState(() {});
                            },
                            icon: const Icon(Icons.add_circle,
                                color: Color(0xFF2ECC71), size: 32),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Notatka dla klienta
                  TextField(
                    controller: noteCtrl,
                    maxLines: 3,
                    style: const TextStyle(color: Color(0xFFFFD700)),
                    decoration: InputDecoration(
                      labelText: Translations.get('note_for_client',
                          language: globalLanguage),
                      labelStyle: TextStyle(
                          color:
                              const Color(0xFFFFD700).withValues(alpha: 0.7)),
                      hintText: Translations.get('note_hint',
                          language: globalLanguage),
                      hintStyle: TextStyle(
                          color:
                              const Color(0xFFFFD700).withValues(alpha: 0.4)),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                            color:
                                const Color(0xFFFFD700).withValues(alpha: 0.3)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFFFD700)),
                      ),
                      prefixIcon: Icon(Icons.note_add,
                          color:
                              const Color(0xFFFFD700).withValues(alpha: 0.7)),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child:
                    Text(Translations.get('cancel', language: globalLanguage)),
              ),
              ElevatedButton(
                onPressed: () {
                  if (selectedExercise != null) {
                    Navigator.pop(ctx, true);
                  }
                },
                child: Text(Translations.get('add', language: globalLanguage)),
              ),
            ],
          );
        },
      ),
    );

    if (result == true && selectedExercise != null) {
      try {
        final newEntry = ClientPlanEntry(
          exercise: selectedExercise!,
          category: selectedCategory,
          sets: int.tryParse(setsCtrl.text) ?? 3,
          restSeconds: int.tryParse(restCtrl.text) ?? 90,
          timeSeconds: isTimeBased ? (int.tryParse(timeCtrl.text) ?? 30) : 0,
          dayOfWeek: dayIndex,
          note: noteCtrl.text.trim(),
        );

        final currentEntries = _plan?.entries ?? [];
        await PlanAccessController.instance.updateClientPlanEntries(
          widget.clientEmail,
          [...currentEntries, newEntry],
        );
        _refreshPlan();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(Translations.get('exercise_added',
                    language: globalLanguage))),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    '${Translations.get('error', language: globalLanguage)}: $e')),
          );
        }
      }
    }
  }

  Future<void> _moveExercise(int fromIndex, int toIndex) async {
    if (toIndex < 0 || toIndex >= (_plan?.entries.length ?? 0)) return;
    try {
      final entries = List<ClientPlanEntry>.from(_plan?.entries ?? []);
      final item = entries.removeAt(fromIndex);
      entries.insert(toIndex, item);
      await PlanAccessController.instance.updateClientPlanEntries(
        widget.clientEmail,
        entries,
      );
      _refreshPlan();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  '${Translations.get('error', language: globalLanguage)}: $e')),
        );
      }
    }
  }

  Future<void> _deleteExercise(int index) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.black.withValues(alpha: 0.9),
        title: const Text('Usuń ćwiczenie',
            style: TextStyle(color: Color(0xFFFFD700))),
        content: const Text('Czy na pewno chcesz usunąć to ćwiczenie?',
            style: TextStyle(color: Color(0xB3FFD700))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(Translations.get('cancel', language: globalLanguage)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF5252)),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(Translations.get('delete', language: globalLanguage)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final entries = List<ClientPlanEntry>.from(_plan?.entries ?? []);
        entries.removeAt(index);
        await PlanAccessController.instance.updateClientPlanEntries(
          widget.clientEmail,
          entries,
        );
        _refreshPlan();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    '${Translations.get('error', language: globalLanguage)}: $e')),
          );
        }
      }
    }
  }

  Future<void> _editExercise(int index) async {
    final entry = _plan!.entries[index];
    final setsCtrl = TextEditingController(text: entry.sets.toString());
    final restCtrl = TextEditingController(text: entry.restSeconds.toString());
    final timeCtrl = TextEditingController(text: entry.timeSeconds.toString());
    bool isTimeBased = entry.timeSeconds > 0;

    // Pobierz kategorie z kCategoryNames (bez 'PLAN')
    final categories =
        kCategoryNames.keys.where((key) => key != 'PLAN').toList();
    String selectedCategory = (entry.category != null &&
            categories.contains(entry.category!.toUpperCase()))
        ? entry.category!.toUpperCase()
        : categories.first;

    // Pobierz ćwiczenia z wybranej kategorii
    List<String> exercisesForCategory =
        kDefaultExercises[selectedCategory] ?? [];
    // Znajdź aktualne ćwiczenie lub użyj pierwszego z listy
    String? selectedExercise = exercisesForCategory.contains(entry.exercise)
        ? entry.exercise
        : (exercisesForCategory.isNotEmpty ? exercisesForCategory.first : null);

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          // Aktualizuj listę ćwiczeń gdy zmieni się kategoria
          exercisesForCategory = kDefaultExercises[selectedCategory] ?? [];
          if (selectedExercise == null ||
              !exercisesForCategory.contains(selectedExercise)) {
            selectedExercise = exercisesForCategory.isNotEmpty
                ? exercisesForCategory.first
                : null;
          }
          // Automatycznie ustaw czy ćwiczenie jest na czas
          if (selectedExercise != null) {
            isTimeBased = kTimeBasedExercises.contains(selectedExercise);
          }

          return AlertDialog(
            backgroundColor: Colors.black.withValues(alpha: 0.9),
            title: Text(
                Translations.get('edit_exercise', language: globalLanguage),
                style: TextStyle(color: Color(0xFFFFD700))),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Kategoria - dropdown
                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    dropdownColor: const Color(0xFF1A1A2E),
                    style: const TextStyle(color: Color(0xFF2ECC71)),
                    decoration: InputDecoration(
                      labelText: Translations.get('category',
                          language: globalLanguage),
                      labelStyle: const TextStyle(color: Color(0xFF2ECC71)),
                      border: const OutlineInputBorder(),
                    ),
                    items: categories
                        .map((cat) => DropdownMenuItem(
                              value: cat,
                              child: Text(
                                  localizedCategoryName(cat, globalLanguage),
                                  style: const TextStyle(
                                      color: Color(0xFF2ECC71))),
                            ))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setDialogState(() {
                          selectedCategory = val;
                          exercisesForCategory = kDefaultExercises[val] ?? [];
                          selectedExercise = exercisesForCategory.isNotEmpty
                              ? exercisesForCategory.first
                              : null;
                          if (selectedExercise != null) {
                            isTimeBased =
                                kTimeBasedExercises.contains(selectedExercise);
                          }
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  // Ćwiczenie - dropdown z bazą
                  DropdownButtonFormField<String>(
                    value: selectedExercise,
                    dropdownColor: const Color(0xFF1A1A2E),
                    isExpanded: true,
                    style:
                        const TextStyle(color: Color(0xFF2ECC71), fontSize: 13),
                    decoration: InputDecoration(
                      labelText: Translations.get('exercise',
                          language: globalLanguage),
                      labelStyle: TextStyle(color: Color(0xFF2ECC71)),
                      border: OutlineInputBorder(),
                    ),
                    items: exercisesForCategory
                        .map((ex) => DropdownMenuItem(
                              value: ex,
                              child: Text(
                                localizedExerciseName(ex, globalLanguage),
                                style:
                                    const TextStyle(color: Color(0xFF2ECC71)),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setDialogState(() {
                          selectedExercise = val;
                          isTimeBased = kTimeBasedExercises.contains(val);
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  // Info czy ćwiczenie na czas
                  if (isTimeBased)
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD700).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.timer,
                              color: Color(0xFFFFD700), size: 18),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              Translations.get('time_based_exercise',
                                  language: globalLanguage),
                              style: TextStyle(
                                  color: Color(0xFFFFD700), fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (isTimeBased) const SizedBox(height: 12),
                  // Serie - zawsze widoczne
                  TextField(
                    controller: setsCtrl,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Color(0xFF2ECC71)),
                    decoration: InputDecoration(
                      labelText: Translations.get('sets_count',
                          language: globalLanguage),
                      labelStyle: TextStyle(color: Color(0xFF2ECC71)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Czas trwania - tylko dla ćwiczeń na czas (co 30s)
                  if (isTimeBased)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            Translations.get('exercise_duration',
                                language: globalLanguage),
                            style: TextStyle(
                                color: Color(0xFF2ECC71), fontSize: 12)),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              onPressed: () {
                                int val = int.tryParse(timeCtrl.text) ?? 30;
                                if (val >= 30) {
                                  val -= 30;
                                  timeCtrl.text = val.toString();
                                  setDialogState(() {});
                                }
                              },
                              icon: const Icon(Icons.remove_circle,
                                  color: Color(0xFFFF5252), size: 32),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                border:
                                    Border.all(color: const Color(0xFFFFD700)),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${timeCtrl.text}s',
                                style: const TextStyle(
                                    color: Color(0xFFFFD700),
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                int val = int.tryParse(timeCtrl.text) ?? 0;
                                val += 30;
                                timeCtrl.text = val.toString();
                                setDialogState(() {});
                              },
                              icon: const Icon(Icons.add_circle,
                                  color: Color(0xFF2ECC71), size: 32),
                            ),
                          ],
                        ),
                      ],
                    ),
                  if (isTimeBased) const SizedBox(height: 12),
                  // Przerwa - zawsze widoczna (co 30s)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          Translations.get('rest_time_label',
                              language: globalLanguage),
                          style: TextStyle(
                              color: Color(0xFF2ECC71), fontSize: 12)),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: () {
                              int val = int.tryParse(restCtrl.text) ?? 30;
                              if (val >= 30) {
                                val -= 30;
                                restCtrl.text = val.toString();
                                setDialogState(() {});
                              }
                            },
                            icon: const Icon(Icons.remove_circle,
                                color: Color(0xFFFF5252), size: 32),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              border:
                                  Border.all(color: const Color(0xFFFFD700)),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${restCtrl.text}s',
                              style: const TextStyle(
                                  color: Color(0xFFFFD700),
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              int val = int.tryParse(restCtrl.text) ?? 0;
                              val += 30;
                              restCtrl.text = val.toString();
                              setDialogState(() {});
                            },
                            icon: const Icon(Icons.add_circle,
                                color: Color(0xFF2ECC71), size: 32),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child:
                    Text(Translations.get('cancel', language: globalLanguage)),
              ),
              ElevatedButton(
                onPressed: () {
                  if (selectedExercise != null) {
                    Navigator.pop(ctx, true);
                  }
                },
                child: Text(Translations.get('save', language: globalLanguage)),
              ),
            ],
          );
        },
      ),
    );

    if (result == true && selectedExercise != null) {
      try {
        final updatedEntry = ClientPlanEntry(
          exercise: selectedExercise!,
          category: selectedCategory,
          sets: int.tryParse(setsCtrl.text) ?? 3,
          restSeconds: int.tryParse(restCtrl.text) ?? 90,
          timeSeconds: isTimeBased ? (int.tryParse(timeCtrl.text) ?? 30) : 0,
          dayOfWeek: entry.dayOfWeek, // Zachowaj dzień tygodnia
        );

        final entries = List<ClientPlanEntry>.from(_plan?.entries ?? []);
        entries[index] = updatedEntry;
        await PlanAccessController.instance.updateClientPlanEntries(
          widget.clientEmail,
          entries,
        );
        _refreshPlan();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(Translations.get('exercise_updated',
                    language: globalLanguage))),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    '${Translations.get('error', language: globalLanguage)}: $e')),
          );
        }
      }
    }
  }

  Future<void> _showClientProgress(BuildContext context) async {
    final lang = globalLanguage;
    final navigator = Navigator.of(context);

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(
        child: CircularProgressIndicator(color: Color(0xFFFFD700)),
      ),
    );

    try {
      final allProgress = <String, List<ExerciseLog>>{};

      if (_plan != null && _plan!.entries.isNotEmpty) {
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
          } catch (_) {}
        }
      }

      if (!mounted) return;
      navigator.pop();

      // Show progress dialog
      if (!context.mounted) return;
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: const Color(0xFF0E1117),
          title: Row(
            children: [
              const Icon(Icons.insights, color: Color(0xFF2ECC71)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  lang == 'PL'
                      ? 'Postępy klienta'
                      : lang == 'NO'
                          ? 'Klientens fremgang'
                          : 'Client Progress',
                  style: const TextStyle(
                      color: Color(0xFFFFD700), fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: allProgress.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.history,
                            color: Color(0xFFFFD700), size: 48),
                        const SizedBox(height: 12),
                        Text(
                          lang == 'PL'
                              ? 'Brak zapisanych postępów'
                              : lang == 'NO'
                                  ? 'Ingen lagret fremgang'
                                  : 'No saved progress',
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: allProgress.keys.length,
                    itemBuilder: (ctx, index) {
                      final exerciseName = allProgress.keys.elementAt(index);
                      final logs = allProgress[exerciseName]!;
                      final latestLog = logs.isNotEmpty ? logs.last : null;
                      final isTime = latestLog?.durationSeconds != null &&
                          latestLog!.durationSeconds > 0;

                      return ExpansionTile(
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFFFFD700),
                          radius: 16,
                          child: Text('${logs.length}',
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12)),
                        ),
                        title: Text(
                          localizedExerciseName(exerciseName, lang),
                          style: const TextStyle(
                              color: Color(0xFFFFD700),
                              fontWeight: FontWeight.w600),
                        ),
                        subtitle: latestLog != null
                            ? Text(
                                isTime
                                    ? '${lang == 'PL' ? 'Ostatni' : 'Last'}: ${latestLog.durationSeconds}s'
                                    : '${lang == 'PL' ? 'Ostatni' : 'Last'}: ${latestLog.weight} kg × ${latestLog.reps}',
                                style: const TextStyle(
                                    color: Colors.white54, fontSize: 12),
                              )
                            : null,
                        iconColor: const Color(0xFFFFD700),
                        collapsedIconColor: const Color(0xFFFFD700),
                        children: logs.reversed.take(5).map((log) {
                          final isTimeBased = log.durationSeconds > 0;
                          final value = isTimeBased
                              ? '${log.durationSeconds}s'
                              : '${log.weight} kg × ${log.reps}';
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(log.date,
                                    style: const TextStyle(
                                        color: Colors.white54, fontSize: 11)),
                                Text(value,
                                    style: const TextStyle(
                                        color: Color(0xFF2ECC71),
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
          ),
          actions: [
            // Przycisk resetu progresu
            if (allProgress.isNotEmpty)
              TextButton(
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: ctx,
                    builder: (c) => AlertDialog(
                      backgroundColor: const Color(0xFF0E1117),
                      title: Text(
                        lang == 'PL'
                            ? 'Resetuj progres?'
                            : lang == 'NO'
                                ? 'Tilbakestill fremgang?'
                                : 'Reset progress?',
                        style: const TextStyle(color: Color(0xFFFF5252)),
                      ),
                      content: Text(
                        lang == 'PL'
                            ? 'Czy na pewno chcesz usunąć całą historię ćwiczeń tego klienta? Tej operacji nie można cofnąć.'
                            : lang == 'NO'
                                ? 'Er du sikker på at du vil slette all treningshistorikk for denne klienten? Denne handlingen kan ikke angres.'
                                : 'Are you sure you want to delete all exercise history for this client? This action cannot be undone.',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(c, false),
                          child: Text(
                            lang == 'PL'
                                ? 'Anuluj'
                                : lang == 'NO'
                                    ? 'Avbryt'
                                    : 'Cancel',
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(c, true),
                          child: Text(
                            lang == 'PL'
                                ? 'Usuń'
                                : lang == 'NO'
                                    ? 'Slett'
                                    : 'Delete',
                            style: const TextStyle(color: Color(0xFFFF5252)),
                          ),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    try {
                      await PlanAccessController.instance
                          .resetClientProgress(widget.clientEmail);
                      if (ctx.mounted) {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(lang == 'PL'
                                ? 'Progres został zresetowany'
                                : lang == 'NO'
                                    ? 'Fremgang ble tilbakestilt'
                                    : 'Progress has been reset'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    } catch (e) {
                      if (ctx.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                Text('${lang == 'PL' ? 'Błąd' : 'Error'}: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  }
                },
                child: Text(
                  lang == 'PL'
                      ? 'Resetuj'
                      : lang == 'NO'
                          ? 'Tilbakestill'
                          : 'Reset',
                  style: const TextStyle(color: Color(0xFFFF5252)),
                ),
              ),
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
    } catch (e) {
      if (!mounted) return;
      navigator.pop();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(lang == 'PL'
              ? 'Błąd ładowania postępów'
              : 'Error loading progress'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: globalLanguageNotifier,
      builder: (context, lang, _) {
        const accent = Color(0xFFFFD700);
        const restDayColor = Color(0xFF4CAF50);

        return Scaffold(
          appBar: buildCustomAppBar(context, accentColor: accent),
          body: GymBackgroundWithFitness(
            backgroundImage: 'assets/moje_tlo.png',
            backgroundImageOpacity: 0.32,
            accentColor: accent,
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: accent))
                : ListView(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    children: [
                      // Header z emailem klienta
                      Card(
                        color: Colors.black.withValues(alpha: 0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side:
                              BorderSide(color: accent.withValues(alpha: 0.4)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: accent,
                                    radius: 28,
                                    child: const Icon(Icons.person,
                                        color: Colors.black, size: 32),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(widget.clientEmail,
                                            style: const TextStyle(
                                                color: Color(0xFFFFD700),
                                                fontWeight: FontWeight.w700,
                                                fontSize: 16)),
                                        Text(
                                            lang == 'PL'
                                                ? 'Klient'
                                                : lang == 'NO'
                                                    ? 'Klient'
                                                    : 'Client',
                                            style: const TextStyle(
                                                color: Color(0xFF2ECC71))),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: () => _showClientProgress(context),
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
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Plan treningowy - nagłówek
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                              _plan?.title ??
                                  (lang == 'PL'
                                      ? 'Plan treningowy'
                                      : 'Training Plan'),
                              style: const TextStyle(
                                  color: accent,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 20)),
                          IconButton(
                            icon: const Icon(Icons.edit, color: accent),
                            onPressed: _editPlan,
                          ),
                        ],
                      ),
                      if (_plan != null && _plan!.notes.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(_plan!.notes,
                              style: TextStyle(
                                  color: accent.withValues(alpha: 0.9))),
                        ),
                      const SizedBox(height: 8),

                      // Dni tygodnia z ćwiczeniami
                      ...List.generate(7, (dayIndex) {
                        final isRestDay = _isRestDay(dayIndex);
                        final exercisesForDay = _getExercisesForDay(dayIndex);
                        final dayName = _dayNames[dayIndex];

                        return Card(
                          color: isRestDay
                              ? restDayColor.withValues(alpha: 0.15)
                              : Colors.black.withValues(alpha: 0.45),
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: isRestDay
                                  ? restDayColor.withValues(alpha: 0.5)
                                  : accent.withValues(alpha: 0.3),
                              width: 1.5,
                            ),
                          ),
                          child: Theme(
                            data: Theme.of(context)
                                .copyWith(dividerColor: Colors.transparent),
                            child: ExpansionTile(
                              initiallyExpanded: exercisesForDay.isNotEmpty,
                              leading: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: isRestDay ? restDayColor : accent,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  isRestDay
                                      ? Icons.hotel
                                      : Icons.fitness_center,
                                  color: Colors.black,
                                  size: 22,
                                ),
                              ),
                              title: Text(
                                dayName,
                                style: TextStyle(
                                  color: isRestDay ? restDayColor : accent,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: Text(
                                isRestDay
                                    ? (lang == 'PL'
                                        ? 'Dzień wolny'
                                        : lang == 'NO'
                                            ? 'Hviledag'
                                            : 'Rest day')
                                    : (exercisesForDay.isEmpty
                                        ? (lang == 'PL'
                                            ? 'Brak ćwiczeń'
                                            : lang == 'NO'
                                                ? 'Ingen øvelser'
                                                : 'No exercises')
                                        : '${exercisesForDay.length} ${lang == 'PL' ? 'ćwiczeń' : lang == 'NO' ? 'øvelser' : 'exercises'}'),
                                style: TextStyle(
                                  color: isRestDay
                                      ? restDayColor.withValues(alpha: 0.7)
                                      : accent.withValues(alpha: 0.7),
                                  fontSize: 12,
                                ),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Przycisk przenieś trening na inny dzień
                                  if (!isRestDay && exercisesForDay.isNotEmpty)
                                    IconButton(
                                      icon: const Icon(Icons.swap_horiz,
                                          color: Color(0xFF2196F3), size: 22),
                                      tooltip: lang == 'PL'
                                          ? 'Przenieś na inny dzień'
                                          : lang == 'NO'
                                              ? 'Flytt til annen dag'
                                              : 'Move to another day',
                                      onPressed: () =>
                                          _moveDayExercises(dayIndex),
                                    ),
                                  // Przycisk oznacz jako dzień wolny
                                  IconButton(
                                    icon: Icon(
                                      isRestDay
                                          ? Icons.fitness_center
                                          : Icons.hotel,
                                      color: isRestDay ? accent : restDayColor,
                                      size: 20,
                                    ),
                                    tooltip: isRestDay
                                        ? (lang == 'PL'
                                            ? 'Dzień treningowy'
                                            : 'Training day')
                                        : (lang == 'PL'
                                            ? 'Dzień wolny'
                                            : 'Rest day'),
                                    onPressed: () => _toggleRestDay(dayIndex),
                                  ),
                                  // Przycisk dodaj ćwiczenie
                                  if (!isRestDay)
                                    IconButton(
                                      icon: const Icon(Icons.add_circle,
                                          color: accent, size: 24),
                                      tooltip: lang == 'PL'
                                          ? 'Dodaj ćwiczenie'
                                          : 'Add exercise',
                                      onPressed: () =>
                                          _addExerciseForDay(dayIndex),
                                    ),
                                ],
                              ),
                              iconColor: accent,
                              collapsedIconColor: accent.withValues(alpha: 0.5),
                              children: [
                                if (!isRestDay && exercisesForDay.isEmpty)
                                  Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      children: [
                                        Icon(Icons.add_circle_outline,
                                            color:
                                                accent.withValues(alpha: 0.4),
                                            size: 32),
                                        const SizedBox(height: 8),
                                        Text(
                                          lang == 'PL'
                                              ? 'Kliknij + aby dodać ćwiczenie'
                                              : 'Click + to add exercise',
                                          style: TextStyle(
                                              color: accent.withValues(
                                                  alpha: 0.5)),
                                        ),
                                      ],
                                    ),
                                  ),
                                ...exercisesForDay.map((exercise) {
                                  final entryIndex =
                                      _plan!.entries.indexOf(exercise);
                                  return Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 4),
                                    decoration: BoxDecoration(
                                      color:
                                          Colors.black.withValues(alpha: 0.3),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                          color:
                                              accent.withValues(alpha: 0.15)),
                                    ),
                                    child: ListTile(
                                      dense: true,
                                      onTap: () => _editExercise(entryIndex),
                                      leading: Container(
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          color: accent.withValues(alpha: 0.2),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: const Icon(Icons.fitness_center,
                                            color: accent, size: 18),
                                      ),
                                      title: Text(
                                        localizedExerciseName(
                                            exercise.exercise, lang),
                                        style: const TextStyle(
                                            color: accent,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      subtitle: Text(
                                        '${exercise.sets} ${lang == 'PL' ? 'serii' : 'sets'} • ${exercise.restSeconds}s ${lang == 'PL' ? 'przerwy' : 'rest'}${exercise.timeSeconds > 0 ? ' • ${exercise.timeSeconds}s' : ''}',
                                        style: TextStyle(
                                            color:
                                                accent.withValues(alpha: 0.6),
                                            fontSize: 11),
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          // Strzałka w górę
                                          IconButton(
                                            icon: Icon(Icons.arrow_upward,
                                                color: entryIndex > 0
                                                    ? accent.withValues(
                                                        alpha: 0.7)
                                                    : accent.withValues(
                                                        alpha: 0.2),
                                                size: 18),
                                            onPressed: entryIndex > 0
                                                ? () => _moveExercise(
                                                    entryIndex, entryIndex - 1)
                                                : null,
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(
                                                minWidth: 28, minHeight: 28),
                                          ),
                                          // Strzałka w dół
                                          IconButton(
                                            icon: Icon(Icons.arrow_downward,
                                                color: entryIndex <
                                                        (_plan?.entries
                                                                    .length ??
                                                                0) -
                                                            1
                                                    ? accent.withValues(
                                                        alpha: 0.7)
                                                    : accent.withValues(
                                                        alpha: 0.2),
                                                size: 18),
                                            onPressed: entryIndex <
                                                    (_plan?.entries.length ??
                                                            0) -
                                                        1
                                                ? () => _moveExercise(
                                                    entryIndex, entryIndex + 1)
                                                : null,
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(
                                                minWidth: 28, minHeight: 28),
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.edit,
                                                color: accent.withValues(
                                                    alpha: 0.7),
                                                size: 18),
                                            onPressed: () =>
                                                _editExercise(entryIndex),
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(
                                                minWidth: 28, minHeight: 28),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete,
                                                color: Color(0xFFFF5252),
                                                size: 18),
                                            onPressed: () =>
                                                _deleteExercise(entryIndex),
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(
                                                minWidth: 28, minHeight: 28),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                                if (exercisesForDay.isNotEmpty)
                                  const SizedBox(height: 8),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
          ),
        );
      },
    );
  }
}

/// ProgressChart: shows bars and under each bar the set number, reps and weight.
class ProgressChart extends StatelessWidget {
  final List<ExerciseLog> history;
  final Color accentColor;
  final String title;
  final String language;

  const ProgressChart(
      {super.key,
      required this.history,
      required this.accentColor,
      this.title = "",
      this.language = 'EN'});

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) {
      return Container(
          height: 160,
          alignment: Alignment.center,
          child: Text(Translations.get('no_data', language: language),
              style: TextStyle(color: accentColor.withValues(alpha: 0.6))));
    }

    return Container(
      height: 220,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accentColor.withValues(alpha: 0.08)),
      ),
      child: Column(children: [
        if (title.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(title,
                style: TextStyle(
                    color: accentColor.withValues(alpha: 0.9),
                    fontWeight: FontWeight.bold)),
          ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final int n = history.length;
              final double availableWidth = constraints.maxWidth;
              final double barWidth =
                  n == 1 ? 50.0 : (availableWidth / n) * 0.7;
              final double spacing = n == 1 ? 0 : (availableWidth / n) * 0.3;

              // Oblicz wartości dla proporcjonalnych wysokości
              final bool isTimeBased =
                  history.any((log) => log.durationSeconds > 0);

              List<double> values = [];
              for (final log in history) {
                if (isTimeBased) {
                  values.add(log.durationSeconds.toDouble());
                } else {
                  final w = double.tryParse(log.weight) ?? 0;
                  final r = double.tryParse(log.reps) ?? 0;
                  values.add(w * r);
                }
              }

              final double maxVal = values.isNotEmpty
                  ? values.reduce((a, b) => a > b ? a : b)
                  : 1;
              final double minVal = values.isNotEmpty
                  ? values.reduce((a, b) => a < b ? a : b)
                  : 0;
              final double range = maxVal - minVal;

              // Dostępna wysokość dla słupków
              final double maxBarHeight = 80.0;
              final double minBarHeight = 20.0;

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(history.length, (i) {
                    final log = history[i];
                    final isTimeBasedEntry = log.durationSeconds > 0;

                    // Etykieta: dla ćwiczeń czasowych - czas, dla wagowych - ciężar
                    final String label1 = isTimeBasedEntry
                        ? '${log.durationSeconds}s'
                        : '${log.weight}kg';
                    final String label2 = '${log.reps}x';

                    // Oblicz proporcjonalną wysokość słupka
                    double barHeight;
                    if (range < 0.01) {
                      // Wszystkie wartości równe - użyj maksymalnej wysokości
                      barHeight = maxBarHeight;
                    } else {
                      // Normalizuj wartość do zakresu [minBarHeight, maxBarHeight]
                      final normalizedValue = (values[i] - minVal) / range;
                      barHeight = minBarHeight +
                          normalizedValue * (maxBarHeight - minBarHeight);
                    }

                    return Padding(
                      padding: EdgeInsets.only(
                        left: i == 0 ? spacing / 2 : spacing / 2,
                        right:
                            i == history.length - 1 ? spacing / 2 : spacing / 2,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // Słupek o proporcjonalnej wysokości
                          Container(
                            width: barWidth,
                            height: barHeight,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  accentColor,
                                  accentColor.withOpacity(0.6)
                                ],
                              ),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(4),
                                topRight: Radius.circular(4),
                              ),
                              border: Border.all(
                                color: accentColor.withOpacity(0.8),
                                width: 1.5,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                log.sets,
                                style: const TextStyle(
                                  color: Color(0xFFFFD700),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          // Etykieta z danymi
                          Text(
                            label2,
                            style: TextStyle(
                              color: accentColor,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            label1,
                            style: TextStyle(
                              color: accentColor.withOpacity(0.8),
                              fontSize: 9,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 6),
        Align(
            alignment: Alignment.centerRight,
            child: Text(
                Translations.withParams('sets_label',
                    language: language,
                    params: {'count': history.length.toString()}),
                style: TextStyle(
                    color: accentColor.withValues(alpha: 0.7), fontSize: 12))),
      ]),
    );
  }
}

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  static const Color _gold = Color(0xFFFFD700);
  static const List<Map<String, dynamic>> categories = [
    {'name': 'PLAN', 'isPlan': true},
    {'name': 'CHEST'},
    {'name': 'BACK'},
    {'name': 'BICEPS'},
    {'name': 'TRICEPS'},
    {'name': 'SHOULDERS'},
    {'name': 'ABS'},
    {'name': 'LEGS'},
    {'name': 'FOREARMS'},
  ];

  // Nazwy dni tygodnia
  static const List<String> _dayNamesPL = [
    'Poniedziałek',
    'Wtorek',
    'Środa',
    'Czwartek',
    'Piątek',
    'Sobota',
    'Niedziela'
  ];
  static const List<String> _dayNamesEN = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];
  static const List<String> _dayNamesNO = [
    'Mandag',
    'Tirsdag',
    'Onsdag',
    'Torsdag',
    'Fredag',
    'Lørdag',
    'Søndag'
  ];

  List<String> _getDayNames(String lang) {
    switch (lang) {
      case 'NO':
        return _dayNamesNO;
      case 'EN':
        return _dayNamesEN;
      default:
        return _dayNamesPL;
    }
  }

  ClientPlan? _clientPlan;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadClientPlan();
  }

  Future<void> _loadClientPlan() async {
    final state = PlanAccessController.instance.notifier.value;
    if (state.isAuthenticated && state.role == PlanUserRole.client) {
      final email = state.userEmail;
      if (email != null) {
        try {
          final plan =
              await PlanAccessController.instance.fetchPlanForEmail(email);
          if (mounted) {
            setState(() {
              _clientPlan = plan;
              _loading = false;
            });
          }
        } catch (e) {
          if (mounted) {
            setState(() => _loading = false);
          }
        }
      } else {
        if (mounted) setState(() => _loading = false);
      }
    } else {
      if (mounted) setState(() => _loading = false);
    }
  }

  // Pobierz ćwiczenia dla danego dnia
  List<ClientPlanEntry> _getExercisesForDay(int dayIndex) {
    if (_clientPlan == null) return [];
    return _clientPlan!.entries.where((e) => e.dayOfWeek == dayIndex).toList();
  }

  // Sprawdź czy dzień jest dniem wolnym
  bool _isRestDay(int dayIndex) {
    return _clientPlan?.restDays.contains(dayIndex) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: globalLanguageNotifier,
      builder: (context, lang, _) {
        const Color gold = Color(0xFFFFD700);

        final state = PlanAccessController.instance.notifier.value;
        final isClient =
            state.isAuthenticated && state.role == PlanUserRole.client;

        return Scaffold(
          appBar: buildCustomAppBar(context, accentColor: gold),
          body: GymBackgroundWithFitness(
            goldDumbbells: false,
            backgroundImage: 'assets/moje_tlo.png',
            backgroundImageOpacity: 0.32,
            gradientColors: [
              const Color(0xFF0B2E5A),
              const Color(0xFF0A2652),
              const Color(0xFF0E3D8C),
            ],
            child: SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  children: [
                    Expanded(
                      child: isClient
                          ? _buildClientDaysView(lang, gold)
                          : _buildDefaultCategoriesView(lang, gold),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Widok dla klienta - dni tygodnia
  Widget _buildClientDaysView(String lang, Color gold) {
    if (_loading) {
      return const Center(
          child: CircularProgressIndicator(color: Color(0xFFFFD700)));
    }

    if (_clientPlan == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.fitness_center,
                color: gold.withValues(alpha: 0.3), size: 48),
            const SizedBox(height: 12),
            Text(
              lang == 'PL'
                  ? 'Brak planu od trenera'
                  : lang == 'NO'
                      ? 'Ingen plan fra trener'
                      : 'No plan from trainer',
              style: TextStyle(color: gold.withValues(alpha: 0.6)),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                setState(() => _loading = true);
                _loadClientPlan();
              },
              icon: const Icon(Icons.refresh, color: Colors.black),
              label: Text(lang == 'PL'
                  ? 'Odśwież'
                  : lang == 'NO'
                      ? 'Oppdater'
                      : 'Refresh'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: gold, foregroundColor: Colors.black),
            ),
          ],
        ),
      );
    }

    final dayNames = _getDayNames(lang);

    // 8 elementów: 1 kafelek PLAN + 7 dni tygodnia
    return ListView.separated(
      itemCount: 8,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        // Pierwszy element - kafelek PLAN
        if (index == 0) {
          final planLabel = lang == 'PL'
              ? 'Plan'
              : lang == 'NO'
                  ? 'Plan'
                  : 'Plan';
          final planSubtitle = lang == 'PL'
              ? 'Twój plan treningowy'
              : lang == 'NO'
                  ? 'Din treningsplan'
                  : 'Your training plan';

          return Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PlanOnlineScreen(themeColor: gold),
                  ),
                );
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: Colors.transparent,
                  border: Border.all(
                    color: gold,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: gold.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.calendar_month,
                          color: gold,
                          size: 24,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            planLabel,
                            style: TextStyle(
                              color: gold,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            planSubtitle,
                            style: TextStyle(
                              color: gold.withValues(alpha: 0.6),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right, color: gold),
                  ],
                ),
              ),
            ),
          );
        }

        // Pozostałe elementy - dni tygodnia (index - 1 bo pierwszy to PLAN)
        final dayIndex = index - 1;
        final dayName = dayNames[dayIndex];
        final exercises = _getExercisesForDay(dayIndex);
        final isRest = _isRestDay(dayIndex);
        final exerciseCount = exercises.length;

        String subtitle;
        if (isRest) {
          subtitle = lang == 'PL'
              ? 'Dzień wolny'
              : lang == 'NO'
                  ? 'Hviledag'
                  : 'Rest day';
        } else if (exerciseCount == 0) {
          subtitle = lang == 'PL'
              ? 'Brak ćwiczeń'
              : lang == 'NO'
                  ? 'Ingen øvelser'
                  : 'No exercises';
        } else {
          subtitle = lang == 'PL'
              ? '$exerciseCount ćwiczeń'
              : lang == 'NO'
                  ? '$exerciseCount øvelser'
                  : '$exerciseCount exercises';
        }

        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ClientDayExercisesScreen(
                    dayIndex: dayIndex,
                    dayName: dayName,
                    exercises: exercises,
                    isRestDay: isRest,
                    themeColor: gold,
                  ),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: isRest
                    ? Colors.green.withValues(alpha: 0.1)
                    : Colors.transparent,
                border: Border.all(
                  color: isRest ? Colors.green : gold,
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isRest
                          ? Colors.green.withValues(alpha: 0.2)
                          : gold.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Icon(
                        isRest ? Icons.hotel : Icons.fitness_center,
                        color: isRest ? Colors.green : gold,
                        size: 22,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dayName,
                          style: TextStyle(
                            color: isRest ? Colors.green : gold,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: TextStyle(
                            color: (isRest ? Colors.green : gold)
                                .withValues(alpha: 0.6),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right,
                      color: isRest ? Colors.green : gold),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Widok domyślny - kategorie (dla niezalogowanych lub trenera)
  Widget _buildDefaultCategoriesView(String lang, Color gold) {
    return ListView.separated(
      itemCount: categories.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final cat = categories[index];
        final bool isPlan = (cat['isPlan'] as bool?) ?? false;
        final String name = cat['name'] as String;
        final displayName = localizedCategoryName(name, lang);

        void handleTap() {
          if (isPlan) {
            final state = PlanAccessController.instance.notifier.value;
            if (state.isAuthenticated && state.role == PlanUserRole.client) {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => PlanOnlineScreen(themeColor: gold)),
              );
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => PlanImportScreen(themeColor: gold)),
              );
            }
            return;
          }
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  ExerciseListScreen(category: name, themeColor: gold),
            ),
          );
        }

        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: handleTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: Colors.transparent,
                border: Border.all(color: gold, width: 1.5),
              ),
              child: Center(
                child: Text(
                  displayName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: _gold,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// Ekran ćwiczeń dla danego dnia (dla klienta)
class ClientDayExercisesScreen extends StatelessWidget {
  final int dayIndex;
  final String dayName;
  final List<ClientPlanEntry> exercises;
  final bool isRestDay;
  final Color themeColor;

  const ClientDayExercisesScreen({
    super.key,
    required this.dayIndex,
    required this.dayName,
    required this.exercises,
    required this.isRestDay,
    this.themeColor = const Color(0xFFFFD700),
  });

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFFFFD700);
    return ValueListenableBuilder<String>(
      valueListenable: globalLanguageNotifier,
      builder: (context, lang, _) {
        return Scaffold(
          appBar: buildCustomAppBar(context, accentColor: accent),
          body: GymBackgroundWithFitness(
            backgroundImage: 'assets/moje_tlo.png',
            backgroundImageOpacity: 0.32,
            accentColor: accent,
            child: SafeArea(
              child: Column(
                children: [
                  // Nagłówek dnia
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          (isRestDay ? Colors.green : accent)
                              .withValues(alpha: 0.2),
                          (isRestDay ? Colors.green : accent)
                              .withValues(alpha: 0.05),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: (isRestDay ? Colors.green : accent)
                              .withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isRestDay ? Colors.green : accent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            isRestDay ? Icons.hotel : Icons.fitness_center,
                            color: Colors.black,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                dayName,
                                style: TextStyle(
                                  color: isRestDay ? Colors.green : accent,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 22,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                isRestDay
                                    ? (lang == 'PL'
                                        ? 'Dzień wolny od treningu'
                                        : lang == 'NO'
                                            ? 'Hviledag'
                                            : 'Rest day')
                                    : (lang == 'PL'
                                        ? '${exercises.length} ćwiczeń do wykonania'
                                        : lang == 'NO'
                                            ? '${exercises.length} øvelser å gjøre'
                                            : '${exercises.length} exercises to do'),
                                style: TextStyle(
                                  color: (isRestDay ? Colors.green : accent)
                                      .withValues(alpha: 0.7),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Lista ćwiczeń lub komunikat o dniu wolnym
                  Expanded(
                    child: isRestDay
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.self_improvement,
                                    color: Colors.green.withValues(alpha: 0.5),
                                    size: 64),
                                const SizedBox(height: 16),
                                Text(
                                  lang == 'PL'
                                      ? 'Odpoczywaj i regeneruj się!'
                                      : lang == 'NO'
                                          ? 'Hvil og kom deg!'
                                          : 'Rest and recover!',
                                  style: TextStyle(
                                      color:
                                          Colors.green.withValues(alpha: 0.8),
                                      fontSize: 18),
                                ),
                              ],
                            ),
                          )
                        : exercises.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.fitness_center,
                                        color: accent.withValues(alpha: 0.3),
                                        size: 48),
                                    const SizedBox(height: 12),
                                    Text(
                                      lang == 'PL'
                                          ? 'Brak ćwiczeń na ten dzień'
                                          : lang == 'NO'
                                              ? 'Ingen øvelser for denne dagen'
                                              : 'No exercises for this day',
                                      style: TextStyle(
                                          color: accent.withValues(alpha: 0.6)),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                itemCount: exercises.length,
                                itemBuilder: (context, index) {
                                  final exercise = exercises[index];
                                  final isTimeBased = exercise.timeSeconds > 0;

                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 10),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          accent.withValues(alpha: 0.1),
                                          Colors.black.withValues(alpha: 0.35),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                          color: accent.withValues(alpha: 0.2)),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        ListTile(
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 14, vertical: 6),
                                          leading: Container(
                                            width: 40,
                                            height: 40,
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  accent,
                                                  accent.withValues(alpha: 0.7)
                                                ],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: accent.withValues(
                                                      alpha: 0.3),
                                                  blurRadius: 6,
                                                  spreadRadius: 1,
                                                ),
                                              ],
                                            ),
                                            child: Center(
                                              child: Text(
                                                '${index + 1}',
                                                style: const TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ),
                                          ),
                                          title: Text(
                                            localizedExerciseName(
                                                exercise.exercise, lang),
                                            style: const TextStyle(
                                              color: accent,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 15,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          subtitle: Padding(
                                            padding:
                                                const EdgeInsets.only(top: 6),
                                            child: Wrap(
                                              spacing: 8,
                                              runSpacing: 4,
                                              children: [
                                                _buildInfoChip(
                                                  Icons.repeat,
                                                  '${exercise.sets} ${lang == 'PL' ? 'serii' : 'sets'}',
                                                  accent,
                                                ),
                                                _buildInfoChip(
                                                  Icons.timer_outlined,
                                                  '${exercise.restSeconds}s ${lang == 'PL' ? 'przerwy' : 'rest'}',
                                                  accent,
                                                ),
                                                if (isTimeBased)
                                                  _buildInfoChip(
                                                    Icons.hourglass_bottom,
                                                    '${exercise.timeSeconds}s',
                                                    const Color(0xFFFFD700),
                                                  ),
                                              ],
                                            ),
                                          ),
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    ExerciseDetailScreen(
                                                  exerciseName:
                                                      exercise.exercise,
                                                  themeColor: accent,
                                                  recommendedSets:
                                                      exercise.sets,
                                                  recommendedRestSeconds:
                                                      exercise.restSeconds,
                                                  recommendedTimeSeconds:
                                                      exercise.timeSeconds > 0
                                                          ? exercise.timeSeconds
                                                          : null,
                                                ),
                                              ),
                                            );
                                          },
                                          trailing: const Icon(
                                              Icons.chevron_right,
                                              color: accent,
                                              size: 22),
                                        ),
                                        // Notatka od trenera
                                        if (exercise.note.isNotEmpty)
                                          Container(
                                            width: double.infinity,
                                            padding: const EdgeInsets.fromLTRB(
                                                14, 0, 14, 12),
                                            child: Container(
                                              padding: const EdgeInsets.all(10),
                                              decoration: BoxDecoration(
                                                color: Colors.blue
                                                    .withValues(alpha: 0.15),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                border: Border.all(
                                                    color: Colors.blue
                                                        .withValues(
                                                            alpha: 0.3)),
                                              ),
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Icon(Icons.note,
                                                      color: Colors.blue
                                                          .withValues(
                                                              alpha: 0.8),
                                                      size: 16),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    child: Text(
                                                      exercise.note,
                                                      style: TextStyle(
                                                        color: Colors.blue
                                                            .withValues(
                                                                alpha: 0.9),
                                                        fontSize: 13,
                                                        fontStyle:
                                                            FontStyle.italic,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color.withValues(alpha: 0.9)),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color.withValues(alpha: 0.95),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class ExerciseListScreen extends StatefulWidget {
  final String category;
  final Color themeColor;

  const ExerciseListScreen(
      {super.key, required this.category, required this.themeColor});

  @override
  State<ExerciseListScreen> createState() => _ExerciseListScreenState();
}

class _ExerciseListScreenState extends State<ExerciseListScreen> {
  List<String> _exercises = [];
  Map<String, String> _recs = {};
  Map<String, int> _trainerRecommendedSets =
      {}; // Mapa zaleceń trenera: ćwiczenie -> liczba serii
  Map<String, int> _trainerRecommendedRestSeconds =
      {}; // Mapa zaleceń trenera: ćwiczenie -> czas przerwy
  Map<String, int> _trainerRecommendedTimeSeconds =
      {}; // Mapa zaleceń trenera: ćwiczenie -> czas ćwiczenia
  static const Map<String, String> _categoryAliases = {
    'KLATA': 'CHEST',
    'CHEST': 'CHEST',
    'PLECY': 'BACK',
    'BACK': 'BACK',
    'NOGI': 'LEGS',
    'LEGS': 'LEGS',
    'BARKI': 'SHOULDERS',
    'SHOULDERS': 'SHOULDERS',
    'BICEPS': 'BICEPS',
    'TRICEPS': 'TRICEPS',
    'BRZUCH': 'ABS',
    'ABS': 'ABS',
    'PRZEDRAMIE': 'FOREARMS',
    'FOREARMS': 'FOREARMS',
  };

  String get _normalizedCategory {
    final raw = widget.category.trim().toUpperCase();
    return _categoryAliases[raw] ?? raw;
  }

  String get _prefsKey => 'ex_$_normalizedCategory';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await getPrefs();

    // Pokaż ćwiczenia zapisane lokalnie dla tej kategorii
    List<String> list = prefs.getStringList(_prefsKey) ?? [];
    Map<String, int> trainerSetsMap = {}; // Zalecone serie od trenera
    Map<String, int> trainerRestSecondsMap =
        {}; // Zalecony czas przerwy od trenera
    Map<String, int> trainerTimeSecondsMap =
        {}; // Zalecony czas ćwiczenia od trenera

    // Dla zalogowanego klienta - dodaj ćwiczenia z jego planu
    final state = PlanAccessController.instance.notifier.value;
    debugPrint(
        '[ExerciseListScreen] State: isAuthenticated=${state.isAuthenticated}, role=${state.role}, normalizedCategory=$_normalizedCategory');
    if (state.isAuthenticated && state.role == PlanUserRole.client) {
      try {
        final email = FirebaseAuth.instance.currentUser?.email;
        debugPrint('[ExerciseListScreen] Client email: $email');
        if (email != null) {
          final plan =
              await PlanAccessController.instance.fetchPlanForEmail(email);
          debugPrint(
              '[ExerciseListScreen] Plan loaded: ${plan != null}, entries: ${plan?.entries.length ?? 0}');
          if (plan != null) {
            for (final entry in plan.entries) {
              final entryCategory = (entry.category ?? '').toUpperCase();
              debugPrint(
                  '[ExerciseListScreen] Entry: exercise=${entry.exercise}, category=$entryCategory, comparing with $_normalizedCategory');
              if (entryCategory == _normalizedCategory) {
                // Zawsze ustaw typ ćwiczenia z planu (czasowe jeśli timeSeconds > 0)
                final isTimeBased = entry.timeSeconds > 0;
                await prefs.setBool(
                    'ex_type_time_${entry.exercise}', isTimeBased);

                // Zapisz zalecone serie od trenera
                if (entry.sets > 0) {
                  trainerSetsMap[entry.exercise] = entry.sets;
                }

                // Zapisz zalecony czas przerwy od trenera
                if (entry.restSeconds > 0) {
                  trainerRestSecondsMap[entry.exercise] = entry.restSeconds;
                }

                // Zapisz zalecony czas ćwiczenia od trenera
                if (entry.timeSeconds > 0) {
                  trainerTimeSecondsMap[entry.exercise] = entry.timeSeconds;
                }

                if (!list.contains(entry.exercise)) {
                  list.add(entry.exercise);
                  debugPrint(
                      '[ExerciseListScreen] Added exercise: ${entry.exercise}');
                }
              }
            }
            // Zapisz zaktualizowaną listę lokalnie
            await prefs.setStringList(_prefsKey, list);
          }
        }
      } catch (e) {
        // Ignoruj błędy pobierania planu
        debugPrint('[ExerciseListScreen] Error loading plan: $e');
      }
    }
    debugPrint('[ExerciseListScreen] Final list: $list');

    // Do not auto-seed; start empty until user adds exercises.
    Map<String, String> lastRecs = {};

    for (var ex in list) {
      final logs = prefs.getStringList('history_$ex') ?? [];
      if (logs.isNotEmpty) {
        final last =
            ExerciseLog.fromJson(jsonDecode(logs.last), defaultExercise: ex);
        if (last.durationSeconds > 0) {
          lastRecs[ex] = "${last.durationSeconds}s";
        } else {
          lastRecs[ex] = "${last.weight} kg x ${last.reps}";
        }
      }
    }
    if (mounted) {
      setState(() {
        _exercises = list;
        _recs = lastRecs;
        _trainerRecommendedSets = trainerSetsMap;
        _trainerRecommendedRestSeconds = trainerRestSecondsMap;
        _trainerRecommendedTimeSeconds = trainerTimeSecondsMap;
      });
    }
  }

  void _showEditDeleteMenu(String currentName) {
    final lang = globalLanguage;
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF10131A),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Column(mainAxisSize: MainAxisSize.min, children: [
        const SizedBox(height: 10),
        ListTile(
            leading: const Icon(Icons.edit, color: Colors.blue),
            title: Text(Translations.get('rename_exercise', language: lang)),
            onTap: () {
              Navigator.pop(ctx);
              _renameExercise(currentName);
            }),
        ListTile(
            leading: const Icon(Icons.delete, color: Color(0xFFFF5252)),
            title: Text(Translations.get('delete_exercise', language: lang)),
            onTap: () {
              Navigator.pop(ctx);
              _confirmDelete(currentName);
            }),
        const SizedBox(height: 10),
      ]),
    );
  }

  void _renameExercise(String oldName) {
    final lang = globalLanguage;
    final controller = TextEditingController(text: oldName);
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              backgroundColor: const Color(0xFF0E1117),
              title: Text(Translations.get('rename_exercise', language: lang)),
              content: TextField(controller: controller, autofocus: true),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                    },
                    child: Text(Translations.get('cancel', language: lang))),
                ElevatedButton(
                    onPressed: () async {
                      String newName = controller.text.trim();
                      if (newName.isEmpty) {
                        return;
                      }
                      if (newName == oldName) {
                        if (ctx.mounted) {
                          Navigator.pop(ctx);
                        }
                        return;
                      }
                      if (_exercises.contains(newName)) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(Translations.get('exercise_exists',
                                  language: lang))));
                        }
                        return;
                      }
                      final prefs = await getPrefs();
                      int index = _exercises.indexOf(oldName);
                      if (index != -1) {
                        _exercises[index] = newName;
                        await prefs.setStringList(_prefsKey, _exercises);

                        final oldTypeKey = 'ex_type_time_$oldName';
                        final newTypeKey = 'ex_type_time_$newName';
                        final bool? isTimeBased = prefs.getBool(oldTypeKey);
                        if (isTimeBased != null) {
                          await prefs.setBool(newTypeKey, isTimeBased);
                          await prefs.remove(oldTypeKey);
                        }

                        final historyOld =
                            prefs.getStringList('history_$oldName') ?? [];
                        final List<String> historyNew = [];
                        for (var raw in historyOld) {
                          try {
                            final Map<String, dynamic> map = jsonDecode(raw);
                            map['exercise'] = newName;
                            historyNew.add(jsonEncode(map));
                          } catch (e) {
                            historyNew.add(raw);
                          }
                        }
                        if (historyNew.isNotEmpty) {
                          await prefs.setStringList(
                              'history_$newName', historyNew);
                        } else {
                          await prefs.remove('history_$newName');
                        }
                        await prefs.remove('history_$oldName');
                      }
                      if (ctx.mounted) {
                        Navigator.pop(ctx);
                        _load();
                      }
                    },
                    child: Text(Translations.get('save', language: lang))),
              ],
            ));
  }

  void _confirmDelete(String name) {
    final lang = globalLanguage;
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              backgroundColor: const Color(0xFF0E1117),
              title: Text(Translations.get('delete_question', language: lang)),
              content: Text(Translations.withParams(
                  'delete_exercise_and_history',
                  language: lang,
                  params: {'name': name})),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                    },
                    child: Text(Translations.get('cancel', language: lang))),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF5252)),
                    onPressed: () async {
                      final prefs = await getPrefs();
                      _exercises.remove(name);
                      await prefs.setStringList(_prefsKey, _exercises);
                      await prefs.remove('history_$name');
                      await prefs.remove('ex_type_time_$name');
                      if (ctx.mounted) {
                        Navigator.pop(ctx);
                        _load();
                      }
                    },
                    child: Text(Translations.get('delete', language: lang),
                        style: const TextStyle(color: Color(0xFFFFD700)))),
              ],
            ));
  }

  Future<void> _addExercise(String name, {bool isTimeBased = false}) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    if (_exercises.any((e) => e.toLowerCase() == trimmed.toLowerCase())) {
      return;
    }
    final prefs = await getPrefs();
    _exercises.add(trimmed);
    await prefs.setStringList(_prefsKey, _exercises);
    await prefs.setBool('ex_type_time_$trimmed', isTimeBased);
    if (mounted) {
      _load();
    }
  }

  void _showAddExerciseSheet(Color accent, String lang) {
    final customController = TextEditingController();
    final existingLower = _exercises.map((e) => e.toLowerCase()).toSet();
    final baseList = kDefaultExercises[_normalizedCategory] ?? const [];
    final localizedBaseList = kDefaultExercisesByLanguage[lang]
            ?[_normalizedCategory] ??
        baseList.map((name) => localizedExerciseName(name, lang)).toList();
    bool isTimeBased = false;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF10131A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 12,
              bottom: 16 + MediaQuery.of(ctx).viewInsets.bottom),
          child: StatefulBuilder(builder: (ctx, setModalState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 14),
                    decoration: BoxDecoration(
                        color: Color(0x3DFFD700),
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                Text(Translations.get('add_exercise_title', language: lang),
                    style: const TextStyle(
                        color: Color(0xFFFFD700),
                        fontWeight: FontWeight.w800,
                        fontSize: 18)),
                const SizedBox(height: 14),
                if (baseList.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          Translations.get('base_exercises_title',
                              language: lang),
                          style: const TextStyle(
                              color: Color(0xFFFFD700),
                              fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 220,
                        child: ListView.builder(
                          itemCount: baseList.length,
                          itemBuilder: (ctx, i) {
                            final name = baseList[i];
                            final displayName = localizedBaseList[i];
                            final already =
                                existingLower.contains(name.toLowerCase());
                            return Card(
                              color: const Color(0xFF0E1117),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  side: BorderSide(
                                      color: accent.withValues(alpha: 0.18))),
                              child: ListTile(
                                dense: true,
                                title: Text(displayName,
                                    style: const TextStyle(
                                        color: Color(0xFFFFD700),
                                        fontWeight: FontWeight.w600)),
                                trailing: already
                                    ? Icon(Icons.check,
                                        color: accent.withValues(alpha: 0.7))
                                    : Icon(Icons.add_circle, color: accent),
                                onTap: already
                                    ? null
                                    : () async {
                                        final isTime =
                                            kTimeBasedExercises.contains(name);
                                        await _addExercise(name,
                                            isTimeBased: isTime);
                                        if (ctx.mounted) Navigator.pop(ctx);
                                      },
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],
                  ),
                const SizedBox(height: 12),
                TextField(
                  controller: customController,
                  decoration: InputDecoration(
                      hintText: Translations.get('exercise_name_hint',
                          language: lang),
                      border: const OutlineInputBorder()),
                ),
                const SizedBox(height: 14),
                Text(Translations.get('kind_label', language: lang),
                    style: const TextStyle(
                        color: Color(0xFFFFD700), fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        label: Text(
                            Translations.get('weight_based', language: lang)),
                        selected: !isTimeBased,
                        onSelected: (_) {
                          setModalState(() {
                            isTimeBased = false;
                          });
                        },
                        selectedColor: accent,
                        labelStyle: TextStyle(
                            color: !isTimeBased
                                ? Colors.black
                                : Color(0xFFFFD700)),
                        backgroundColor:
                            Color(0xFFFFD700).withValues(alpha: 0.08),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ChoiceChip(
                        label: Text(
                            Translations.get('time_based', language: lang)),
                        selected: isTimeBased,
                        onSelected: (_) {
                          setModalState(() {
                            isTimeBased = true;
                          });
                        },
                        selectedColor: accent,
                        labelStyle: TextStyle(
                            color:
                                isTimeBased ? Colors.black : Color(0xFFFFD700)),
                        backgroundColor:
                            Color(0xFFFFD700).withValues(alpha: 0.08),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: accent,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12))),
                    onPressed: () async {
                      await _addExercise(customController.text,
                          isTimeBased: isTimeBased);
                      if (ctx.mounted) Navigator.pop(ctx);
                    },
                    child: Text(Translations.get('add', language: lang)),
                  ),
                ),
              ],
            );
          }),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFFFFD700);
    return ValueListenableBuilder<String>(
        valueListenable: globalLanguageNotifier,
        builder: (context, lang, _) {
          return Scaffold(
            appBar: buildCustomAppBar(context, accentColor: accent),
            body: GymBackgroundWithFitness(
              goldDumbbells: false,
              backgroundImage: 'assets/moje_tlo.png',
              backgroundImageOpacity: 0.32,
              accentColor: accent,
              child: Column(children: [
                Expanded(
                    child: _exercises.isEmpty
                        ? Center(
                            child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24.0),
                                child: Text(
                                    Translations.get('no_exercises_yet',
                                        language: lang),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        color: Color(0xB3FFD700)))))
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _exercises.length,
                            itemBuilder: (ctx, i) {
                              final name = _exercises[i];
                              final displayName =
                                  localizedExerciseName(name, lang);
                              final rec = _recs[name] ??
                                  Translations.get('no_data', language: lang);
                              return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  child: Card(
                                    color: Theme.of(context).cardColor,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    child: ListTile(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 12),
                                      onTap: () {
                                        final recSets =
                                            _trainerRecommendedSets[name];
                                        final recRestSeconds =
                                            _trainerRecommendedRestSeconds[
                                                name];
                                        final recTimeSeconds =
                                            _trainerRecommendedTimeSeconds[
                                                name];
                                        debugPrint(
                                            '[ExerciseListScreen] Opening exercise: $name, recommendedSets: $recSets, recommendedRestSeconds: $recRestSeconds, recommendedTimeSeconds: $recTimeSeconds');
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    ExerciseDetailScreen(
                                                        exerciseName: name,
                                                        themeColor: accent,
                                                        recommendedSets:
                                                            recSets,
                                                        recommendedRestSeconds:
                                                            recRestSeconds,
                                                        recommendedTimeSeconds:
                                                            recTimeSeconds))).then(
                                            (_) => _load());
                                      },
                                      onLongPress: () {
                                        _showEditDeleteMenu(name);
                                      },
                                      leading: CircleAvatar(
                                          radius: 22,
                                          backgroundColor: accent,
                                          child: Text(
                                              displayName.isNotEmpty
                                                  ? displayName[0].toUpperCase()
                                                  : '?',
                                              style: const TextStyle(
                                                  color: Color(0xFFFFD700),
                                                  fontWeight:
                                                      FontWeight.bold))),
                                      title: Text(displayName,
                                          style: const TextStyle(
                                              color: Color(0xFFFFD700),
                                              fontWeight: FontWeight.bold)),
                                      subtitle: Text(
                                          "${Translations.get('latest', language: lang)}: $rec",
                                          style: const TextStyle(
                                              color: Color(0xFFFFD700))),
                                      trailing: IconButton(
                                          onPressed: () {
                                            _showEditDeleteMenu(name);
                                          },
                                          icon: const Icon(Icons.more_vert)),
                                    ),
                                  ));
                            },
                          )),
              ]),
            ),
            floatingActionButton: FloatingActionButton(
                backgroundColor: accent,
                onPressed: () => _showAddExerciseSheet(accent, lang),
                child: const Icon(Icons.add, color: Colors.black)),
          );
        });
  }
}

class ExerciseDetailScreen extends StatefulWidget {
  final String exerciseName;
  final Color themeColor;
  final int? recommendedSets; // Zalecone serie od trenera (dla klienta)
  final int?
      recommendedRestSeconds; // Zalecony czas przerwy od trenera (dla klienta)
  final int?
      recommendedTimeSeconds; // Zalecony czas ćwiczenia od trenera (dla klienta)
  const ExerciseDetailScreen(
      {super.key,
      required this.exerciseName,
      required this.themeColor,
      this.recommendedSets,
      this.recommendedRestSeconds,
      this.recommendedTimeSeconds});
  @override
  State<ExerciseDetailScreen> createState() => _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends State<ExerciseDetailScreen>
    with TickerProviderStateMixin {
  final List<ExerciseLog> _history = [];
  final _wController = TextEditingController();
  final _rController = TextEditingController();
  final _sController = TextEditingController();
  final _tController = TextEditingController();

  bool _isTimeBased = false;
  Timer? _setTimer;
  DateTime? _setStart;

  Timer? _timer;
  DateTime? _endTime;
  int _secondsRemaining = 0;
  int _totalRestSeconds = 60;
  bool _isTimerRunning = false;
  late final AnimationController _animController;

  bool _autoStart = true;
  static const String _autoStartKey = 'auto_start_timer';

  bool _vibrationEnabled = true;
  static const String _vibrationEnabledKey = 'vibration_enabled';
  Timer? _vibrationTimer; // Timer do ciągłych wibracji

  @override
  void initState() {
    super.initState();
    _animControllerInit();
    _loadHistory();
    _loadAutoStart();
    _loadVibrationEnabled();

    // Ustaw czas przerwy zalecony przez trenera (jeśli dostępny)
    if (widget.recommendedRestSeconds != null &&
        widget.recommendedRestSeconds! > 0) {
      _totalRestSeconds = widget.recommendedRestSeconds!;
      _secondsRemaining = _totalRestSeconds;
    }
    // Czas ćwiczenia od trenera jest ustawiany w _loadHistory()
  }

  void _animControllerInit() {
    _animController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
  }

  @override
  void dispose() {
    _timer?.cancel();
    _setTimer?.cancel();
    _vibrationTimer?.cancel();
    try {
      if (kIsWeb) {
        js_bridge.evalJs('if(navigator.vibrate){navigator.vibrate(0);}');
      } else {
        Vibration.cancel();
      }
    } catch (_) {}
    _wController.dispose();
    _rController.dispose();
    _sController.dispose();
    _tController.dispose();
    try {
      _animController.dispose();
    } catch (_) {}
    super.dispose();
  }

  Future<void> _loadAutoStart() async {
    final prefs = await getPrefs();
    final val = prefs.getBool(_autoStartKey);
    if (mounted) {
      setState(() {
        _autoStart = val ?? true;
      });
    }
  }

  Future<void> _setAutoStart(bool v) async {
    final prefs = await getPrefs();
    await prefs.setBool(_autoStartKey, v);
    if (mounted) {
      setState(() {
        _autoStart = v;
      });
    }
  }

  Future<void> _loadVibrationEnabled() async {
    final prefs = await getPrefs();
    final val = prefs.getBool(_vibrationEnabledKey);
    if (mounted) {
      setState(() {
        _vibrationEnabled = val ?? true;
      });
    }
  }

  void _stopVibration() {
    _vibrationTimer?.cancel();
    _vibrationTimer = null;
    try {
      if (kIsWeb) {
        js_bridge.evalJs('if(navigator.vibrate){navigator.vibrate(0);}');
      } else {
        Vibration.cancel();
      }
    } catch (_) {}
  }

  void _startContinuousVibration() {
    if (!_vibrationEnabled) {
      debugPrint('🔔 Vibration disabled by user setting');
      return;
    }
    debugPrint('🔔 Starting continuous vibration, kIsWeb=$kIsWeb');
    _vibrationTimer?.cancel();
    // Wibruj co 1.5 sekundy aż do zatrzymania
    _vibrationTimer =
        Timer.periodic(const Duration(milliseconds: 1500), (_) async {
      if (!mounted) {
        _stopVibration();
        return;
      }
      try {
        if (kIsWeb) {
          // Web Vibration API - check if supported and call
          debugPrint('🔔 Attempting web vibration...');
          js_bridge.evalJs('''
            (function() {
              if (navigator.vibrate) {
                var result = navigator.vibrate([300, 150, 300, 150, 300]);
                console.log('Vibration API called, result:', result);
              } else {
                console.log('Vibration API not supported');
              }
            })();
          ''');
        } else if (!kIsWeb && Platform.isIOS) {
          // iOS - użyj HapticFeedback (wielokrotnie dla silniejszego efektu)
          await HapticFeedback.heavyImpact();
          await Future.delayed(const Duration(milliseconds: 150));
          await HapticFeedback.heavyImpact();
          await Future.delayed(const Duration(milliseconds: 150));
          await HapticFeedback.heavyImpact();
        } else {
          // Android i inne platformy
          if (await Vibration.hasVibrator() == true) {
            if (await Vibration.hasCustomVibrationsSupport() == true) {
              Vibration.vibrate(pattern: [0, 300, 150, 300, 150, 300]);
            } else {
              await Vibration.vibrate(duration: 500);
            }
          }
        }
      } catch (_) {}
    });
    // Pierwsza wibracja natychmiast
    _vibrateOnce();
  }

  Future<void> _vibrateOnce() async {
    if (!_vibrationEnabled) return;
    try {
      if (kIsWeb) {
        // Web Vibration API
        js_bridge.evalJs(
            'if(navigator.vibrate){navigator.vibrate([300,150,300,150,300]);}');
      } else if (!kIsWeb && Platform.isIOS) {
        // iOS - użyj HapticFeedback (wielokrotnie dla silniejszego efektu)
        await HapticFeedback.heavyImpact();
        await Future.delayed(const Duration(milliseconds: 150));
        await HapticFeedback.heavyImpact();
        await Future.delayed(const Duration(milliseconds: 150));
        await HapticFeedback.heavyImpact();
      } else {
        // Android i inne platformy
        if (await Vibration.hasVibrator() == true) {
          if (await Vibration.hasCustomVibrationsSupport() == true) {
            Vibration.vibrate(pattern: [0, 300, 150, 300, 150, 300]);
          } else {
            await Vibration.vibrate(duration: 500);
          }
        }
      }
    } catch (_) {}
  }

  bool _exerciseTimeNotified =
      false; // Czy już powiadomiono o zakończeniu czasu ćwiczenia

  void _startSetStopwatch() {
    _setTimer?.cancel();
    _exerciseTimeNotified = false; // Reset flagi przy starcie
    setState(() {
      _setStart = DateTime.now();
      _tController.text = '0';
    });
    _setTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || _setStart == null) return;
      final secs = DateTime.now().difference(_setStart!).inSeconds;
      setState(() {
        _tController.text = secs.toString();
      });

      // Sprawdź czy osiągnięto planowany czas ćwiczenia
      if (!_exerciseTimeNotified) {
        final plannedTime = int.tryParse(_wController.text) ?? 0;
        if (plannedTime > 0 && secs >= plannedTime) {
          _exerciseTimeNotified = true;
          _notifyExerciseTimeEnd();
        }
      }
    });
  }

  void _stopSetStopwatch() {
    _setTimer?.cancel();
    _stopVibration(); // Zatrzymaj wibracje
    if (_setStart != null) {
      final secs = DateTime.now().difference(_setStart!).inSeconds;
      setState(() {
        _tController.text = secs.toString();
        _setStart = null;
      });
    }
  }

  void _resetSetStopwatch() {
    _setTimer?.cancel();
    _stopVibration(); // Zatrzymaj wibracje
    _exerciseTimeNotified = false;
    setState(() {
      _tController.clear();
      _setStart = null;
    });
  }

  Future<void> _notifyExerciseTimeEnd() async {
    final lang = globalLanguage;

    // Uruchom ciągłe wibracje (będą trwać do wciśnięcia STOP)
    _startContinuousVibration();
    try {
      HapticFeedback.heavyImpact();
    } catch (_) {}
    try {
      await NotificationService.instance.showNotification(
          title: lang == 'PL'
              ? 'Czas ćwiczenia minął!'
              : lang == 'NO'
                  ? 'Øvelsestiden er over!'
                  : 'Exercise time finished!',
          body: localizedExerciseName(widget.exerciseName, lang));
    } catch (_) {}
  }

  void _startRestTimer({bool resume = false}) {
    _timer?.cancel();
    // Włącz wakelock żeby ekran nie gasł podczas przerwy
    try {
      WakelockPlus.enable();
    } catch (_) {}
    setState(() {
      if (!resume || _secondsRemaining == 0) {
        _secondsRemaining = _totalRestSeconds;
      }
      _isTimerRunning = true;
      _endTime = DateTime.now().add(Duration(seconds: _secondsRemaining));
      try {
        _animController.forward(from: 0);
      } catch (_) {}
    });

    _timer = Timer.periodic(const Duration(milliseconds: 200), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      final now = DateTime.now();
      final remainingMs = _endTime!.difference(now).inMilliseconds;
      final sec = remainingMs <= 0 ? 0 : (remainingMs / 1000).ceil();
      if (sec != _secondsRemaining) {
        setState(() {
          _secondsRemaining = sec;
        });
      }
      if (remainingMs <= 0) {
        t.cancel();
        setState(() {
          _isTimerRunning = false;
          _secondsRemaining = 0;
          _endTime = null;
        });
        _notifyEnd();
      }
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() {
      _isTimerRunning = false;
      _endTime = null;
      try {
        _animController.stop();
      } catch (_) {}
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _stopVibration(); // Zatrzymaj ciągłe wibracje
    // Wyłącz wakelock
    try {
      WakelockPlus.disable();
    } catch (_) {}
    setState(() {
      _isTimerRunning = false;
      _secondsRemaining = 0;
      _endTime = null;
      try {
        _animController.reset();
      } catch (_) {}
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    // Włącz wakelock podczas resetu
    try {
      WakelockPlus.enable();
    } catch (_) {}
    setState(() {
      _secondsRemaining = _totalRestSeconds;
      _isTimerRunning = true;
      _endTime = DateTime.now().add(Duration(seconds: _secondsRemaining));
      try {
        _animController.forward(from: 0);
      } catch (_) {}
    });
    _timer = Timer.periodic(const Duration(milliseconds: 200), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      final now = DateTime.now();
      final remainingMs = _endTime!.difference(now).inMilliseconds;
      final sec = remainingMs <= 0 ? 0 : (remainingMs / 1000).ceil();
      if (sec != _secondsRemaining) {
        setState(() {
          _secondsRemaining = sec;
        });
      }
      if (remainingMs <= 0) {
        t.cancel();
        setState(() {
          _isTimerRunning = false;
          _secondsRemaining = 0;
          _endTime = null;
        });
        _notifyEnd();
      }
    });
  }

  void _promptNextSet(int nextSet) {
    if (!mounted) return;
    final lang = globalLanguage;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0E1117),
        title: Text(
          lang == 'PL'
              ? 'Seria ${nextSet - 1} zakończona!'
              : lang == 'NO'
                  ? 'Sett ${nextSet - 1} fullført!'
                  : 'Set ${nextSet - 1} complete!',
          style: const TextStyle(color: Color(0xFFFFD700)),
        ),
        content: Text(
          lang == 'PL'
              ? 'Co chcesz zrobić?'
              : lang == 'NO'
                  ? 'Hva vil du gjøre?'
                  : 'What do you want to do?',
          style: TextStyle(color: Color(0xB3FFD700)),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _sController.text = '1';
              });
            },
            child: Text(
              lang == 'PL'
                  ? 'Wróć do serii 1'
                  : lang == 'NO'
                      ? 'Tilbake til sett 1'
                      : 'Back to set 1',
              style: const TextStyle(color: Color(0xFFFF5252)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _sController.text = nextSet.toString();
              });
            },
            child: Text(
              lang == 'PL'
                  ? 'Rozpocznij serię $nextSet'
                  : lang == 'NO'
                      ? 'Start sett $nextSet'
                      : 'Start set $nextSet',
              style: const TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  /// Dialog informujący klienta, że trener zalecił określoną liczbę serii
  void _showTrainerRecommendationDialog(int recommendedSets, int nextSet) {
    if (!mounted) return;
    final lang = globalLanguage;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0E1117),
        title: Text(
          lang == 'PL'
              ? 'Zalecenie trenera wykonane!'
              : lang == 'NO'
                  ? 'Trenerens anbefaling fullført!'
                  : 'Trainer recommendation complete!',
          style: const TextStyle(color: Color(0xFF2ECC71)),
        ),
        content: Text(
          lang == 'PL'
              ? 'Twój trener zalecił $recommendedSets serie dla tego ćwiczenia.\n\nUkończyłeś zaleconą liczbę serii!\n\nCzy chcesz kontynuować następną serię czy wrócić do serii 1?'
              : lang == 'NO'
                  ? 'Treneren din anbefalte $recommendedSets sett for denne øvelsen.\n\nDu har fullført det anbefalte antall sett!\n\nVil du fortsette med neste sett eller gå tilbake til sett 1?'
                  : 'Your trainer recommended $recommendedSets sets for this exercise.\n\nYou have completed the recommended number of sets!\n\nDo you want to continue with the next set or go back to set 1?',
          style: TextStyle(color: Color(0xB3FFD700), height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _sController.text = '1';
              });
            },
            child: Text(
              lang == 'PL'
                  ? 'Wróć do serii 1'
                  : lang == 'NO'
                      ? 'Tilbake til sett 1'
                      : 'Back to set 1',
              style: const TextStyle(color: Color(0xFFFF5252)),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2ECC71),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _sController.text = nextSet.toString();
              });
            },
            child: Text(
              lang == 'PL'
                  ? 'Kontynuuj serię $nextSet'
                  : lang == 'NO'
                      ? 'Fortsett med sett $nextSet'
                      : 'Continue set $nextSet',
              style: const TextStyle(color: Color(0xFFFFD700)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _notifyEnd() async {
    final lang = globalLanguage;
    final exName = localizedExerciseName(widget.exerciseName, lang);

    debugPrint('🔔 _notifyEnd called, starting vibration and sound');

    // Odtwórz dźwięk alarmu na web (jako fallback dla urządzeń bez wibracji)
    if (kIsWeb) {
      try {
        js_bridge.evalJs('''
          (function() {
            try {
              var audio = new Audio('assets/sounds/alert.mp3');
              audio.volume = 1.0;
              audio.play().then(function() {
                console.log('Alert sound played');
              }).catch(function(e) {
                console.log('Audio play failed:', e);
              });
            } catch(e) {
              console.log('Audio error:', e);
            }
          })();
        ''');
        debugPrint('🔔 Web audio play triggered');
      } catch (e) {
        debugPrint('🔔 Web audio error: $e');
      }
    }

    // Uruchom ciągłe wibracje (będą trwać do wciśnięcia STOP)
    _startContinuousVibration();
    try {
      HapticFeedback.heavyImpact();
    } catch (_) {}
    try {
      await NotificationService.instance.showNotification(
          title: Translations.get('rest_finished_title', language: lang),
          body: Translations.withParams('rest_finished_body',
              language: lang, params: {'exercise': exName}));
    } catch (_) {}
  }

  Future<void> _loadHistory() async {
    final prefs = await getPrefs();
    final data = prefs.getStringList('history_${widget.exerciseName}') ?? [];
    final bool isTime =
        prefs.getBool('ex_type_time_${widget.exerciseName}') ?? false;
    if (mounted) {
      setState(() {
        _history.clear();
        _history.addAll(data.map((e) => ExerciseLog.fromJson(jsonDecode(e),
            defaultExercise: widget.exerciseName)));
        _isTimeBased = isTime;
        _tController.clear();
        if (_history.isNotEmpty) {
          if (_isTimeBased) {
            final lastPlannedTime =
                _history.last.plannedTime ?? _history.last.weight;
            _wController.text =
                lastPlannedTime.isEmpty ? '30' : lastPlannedTime;
          } else {
            _wController.text = _history.last.weight;
          }
          int lastNum = int.tryParse(_history.last.sets) ?? _history.length;
          _sController.text = (lastNum + 1).toString();
        } else {
          _sController.text = "1";
          if (_isTimeBased) {
            // Użyj zalecanego czasu od trenera jeśli dostępny
            if (widget.recommendedTimeSeconds != null &&
                widget.recommendedTimeSeconds! > 0) {
              _wController.text = widget.recommendedTimeSeconds.toString();
            } else {
              _wController.text = '30';
            }
          }
        }

        // Ustaw zalecany czas ćwiczenia od trenera dla ćwiczeń czasowych (jeśli dostępny)
        if (_isTimeBased &&
            widget.recommendedTimeSeconds != null &&
            widget.recommendedTimeSeconds! > 0) {
          _wController.text = widget.recommendedTimeSeconds.toString();
        }
      });
    }
  }

  Future<void> _editHistoryEntry(int index) async {
    final lang = globalLanguage;
    final log = _history[index];
    final setsCtrl = TextEditingController(text: log.sets);
    final weightCtrl = TextEditingController(text: log.weight);
    final repsCtrl = TextEditingController(text: log.reps);
    final durationCtrl = TextEditingController(
        text: log.durationSeconds > 0 ? log.durationSeconds.toString() : '');

    final isTimeBasedEntry = log.durationSeconds > 0;

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0E1117),
        title: Text(
          lang == 'PL'
              ? 'Edytuj wpis'
              : lang == 'NO'
                  ? 'Rediger oppføring'
                  : 'Edit entry',
          style: const TextStyle(color: Color(0xFFFFD700)),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: setsCtrl,
              decoration: InputDecoration(
                labelText:
                    Translations.get('set_label', language: lang).toUpperCase(),
                border: const OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Color(0xFFFFD700)),
            ),
            const SizedBox(height: 12),
            if (isTimeBasedEntry) ...[
              TextField(
                controller: durationCtrl,
                decoration: InputDecoration(
                  labelText: lang == 'PL' ? 'CZAS (s)' : 'TIME (s)',
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Color(0xFFFFD700)),
              ),
            ] else ...[
              TextField(
                controller: weightCtrl,
                decoration: InputDecoration(
                  labelText: Translations.get('kg_label', language: lang)
                      .toUpperCase(),
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Color(0xFFFFD700)),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: repsCtrl,
                decoration: InputDecoration(
                  labelText: Translations.get('reps_label', language: lang)
                      .toUpperCase(),
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Color(0xFFFFD700)),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(Translations.get('cancel', language: lang)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD700)),
            child: Text(
              Translations.get('save', language: lang),
              style: const TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
    );

    if (result == true) {
      final updatedLog = ExerciseLog(
        date: log.date,
        sets: setsCtrl.text.trim(),
        weight: isTimeBasedEntry ? log.weight : weightCtrl.text.trim(),
        reps: isTimeBasedEntry ? log.reps : repsCtrl.text.trim(),
        durationSeconds: isTimeBasedEntry
            ? (int.tryParse(durationCtrl.text) ?? log.durationSeconds)
            : log.durationSeconds,
        plannedTime: log.plannedTime,
        exercise: log.exercise,
      );

      final prefs = await getPrefs();
      final data = prefs.getStringList('history_${widget.exerciseName}') ?? [];
      if (index < data.length) {
        data[index] = jsonEncode(updatedLog.toJson());
        await prefs.setStringList('history_${widget.exerciseName}', data);
        _loadHistory();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    lang == 'PL' ? 'Wpis zaktualizowany' : 'Entry updated')),
          );
        }
      }
    }
  }

  void _showResetSetsDialog() {
    if (!mounted) return;
    final lang = globalLanguage;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0E1117),
        title: Text(
          lang == 'PL'
              ? 'Seria 4 zakończona!'
              : lang == 'NO'
                  ? 'Sett 4 fullført!'
                  : 'Set 4 complete!',
          style: const TextStyle(color: Color(0xFFFFD700)),
        ),
        content: Text(
          lang == 'PL'
              ? 'Co chcesz zrobić?'
              : lang == 'NO'
                  ? 'Hva vil du gjøre?'
                  : 'What do you want to do?',
          style: TextStyle(color: Color(0xB3FFD700)),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _sController.text = '1';
              });
            },
            child: Text(
              lang == 'PL'
                  ? 'Wróć do serii 1'
                  : lang == 'NO'
                      ? 'Tilbake til sett 1'
                      : 'Back to set 1',
              style: const TextStyle(color: Color(0xFFFF5252)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _sController.text = '5';
              });
            },
            child: Text(
              lang == 'PL'
                  ? 'Rozpocznij serię 5'
                  : lang == 'NO'
                      ? 'Start sett 5'
                      : 'Start set 5',
              style: const TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveLog() async {
    if (_sController.text.isEmpty) return;
    final currentSetNum = int.tryParse(_sController.text) ?? 0;
    if (_isTimeBased) {
      if (_tController.text.isEmpty) return;
    } else {
      if (_wController.text.isEmpty || _rController.text.isEmpty) return;
    }
    final log = ExerciseLog(
      date: DateTime.now().toString().substring(5, 16),
      sets: _sController.text,
      weight: _isTimeBased ? '' : _wController.text,
      reps: _isTimeBased ? '' : _rController.text,
      durationSeconds:
          _isTimeBased ? (int.tryParse(_tController.text) ?? 0) : 0,
      plannedTime: _isTimeBased ? _wController.text : null,
      exercise: widget.exerciseName,
    );
    final prefs = await getPrefs();
    final data = prefs.getStringList('history_${widget.exerciseName}') ?? [];
    data.add(jsonEncode(log.toJson()));
    await prefs.setStringList('history_${widget.exerciseName}', data);

    // Zapisz do Firebase jeśli użytkownik jest klientem
    final state = PlanAccessController.instance.notifier.value;
    debugPrint(
        '[ExerciseDetailScreen] Current user role: ${state.role}, email: ${state.userEmail}');
    if (state.role == PlanUserRole.client && state.userEmail != null) {
      try {
        debugPrint(
            '[ExerciseDetailScreen] Attempting to save log to Firebase...');
        await PlanAccessController.instance.appendClientExerciseHistory(
          state.userEmail!,
          widget.exerciseName,
          log.toJson(),
        );
        debugPrint(
            '[ExerciseDetailScreen] Log saved to Firebase for client: ${state.userEmail}');
      } catch (e) {
        debugPrint('[ExerciseDetailScreen] Error saving log to Firebase: $e');
      }
    } else {
      debugPrint(
          '[ExerciseDetailScreen] Not saving to Firebase - role: ${state.role}, email: ${state.userEmail}');
    }

    try {
      if (await Vibration.hasVibrator() == true) {
        await Vibration.vibrate(duration: 40);
      }
    } catch (_) {}

    if (_isTimeBased) {
      _resetSetStopwatch();
    } else {
      _rController.clear();
      _wController.clear();
    }
    _loadHistory();

    // Sprawdź zalecenia trenera dla klienta
    final trainerRec = widget.recommendedSets;
    debugPrint(
        '[ExerciseDetailScreen] _saveLog: currentSetNum=$currentSetNum, trainerRec=$trainerRec, exercise=${widget.exerciseName}');
    if (trainerRec != null && trainerRec > 0 && currentSetNum == trainerRec) {
      // Klient ukończył zaleconą przez trenera liczbę serii
      debugPrint(
          '[ExerciseDetailScreen] Showing trainer recommendation dialog!');
      _showTrainerRecommendationDialog(trainerRec, currentSetNum + 1);
    } else if (currentSetNum == 3) {
      _promptNextSet(4);
    } else if (currentSetNum == 4) {
      _showResetSetsDialog();
    }

    if (_autoStart) {
      _startRestTimer(resume: false);
    } else {
      setState(() {
        _secondsRemaining = _totalRestSeconds;
      });
    }
  }

  String _formatTime(int seconds) {
    final int mins = seconds ~/ 60;
    final int secs = seconds % 60;
    return "$mins:${secs.toString().padLeft(2, '0')}";
  }

  double _progressValue() {
    if (_totalRestSeconds == 0) return 0.0;
    final int used =
        (_totalRestSeconds - _secondsRemaining).clamp(0, _totalRestSeconds);
    final double p = (used / _totalRestSeconds).clamp(0.0, 1.0);
    return p;
  }

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFFFFD700);
    return ValueListenableBuilder<String>(
        valueListenable: globalLanguageNotifier,
        builder: (context, lang, _) {
          final last = _history.isNotEmpty ? _history.last : null;
          final String lastText;
          if (last == null) {
            lastText = Translations.get('no_history', language: lang);
          } else {
            final value = last.durationSeconds > 0
                ? "${last.durationSeconds}s"
                : "${last.weight} kg x ${last.reps}";
            lastText = Translations.withParams('last_entry',
                language: lang, params: {'value': value});
          }
          final pauseResumeLabel = _isTimerRunning
              ? Translations.get('timer_pause', language: lang)
              : Translations.get('timer_resume', language: lang);

          return Scaffold(
            appBar: buildCustomAppBar(context, accentColor: accent),
            body: LayoutBuilder(builder: (context, constraints) {
              final isSmallScreen = constraints.maxWidth < 400;
              final paddingH = isSmallScreen ? 10.0 : 16.0;
              final cardPadding = isSmallScreen ? 10.0 : 14.0;

              return GymBackgroundWithFitness(
                backgroundImage: 'assets/moje_tlo.png',
                backgroundImageOpacity: 0.32,
                child: SafeArea(
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView(
                          padding:
                              EdgeInsets.fromLTRB(paddingH, 10, paddingH, 140),
                          children: [
                            ProgressChart(
                                history: _history,
                                accentColor: accent,
                                title: '',
                                language: lang),
                            const SizedBox(height: 10),
                            Card(
                              color: Colors.black.withValues(alpha: 0.4),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  side: BorderSide(
                                      color: accent.withValues(alpha: 0.25))),
                              child: Padding(
                                padding: EdgeInsets.all(cardPadding),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: accent,
                                      radius: isSmallScreen ? 22 : 26,
                                      child: const Icon(Icons.fitness_center,
                                          color: Colors.black),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 4),
                                          Text(
                                            lastText,
                                            style: const TextStyle(
                                                color: Color(0xFFFFD700)),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Card(
                              color: Colors.black.withValues(alpha: 0.4),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  side: BorderSide(
                                      color: accent.withValues(alpha: 0.22))),
                              child: Padding(
                                padding: const EdgeInsets.all(14),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (_isTimeBased) ...[
                                      Row(
                                        children: [
                                          SizedBox(
                                            width: 82,
                                            child: TextField(
                                              controller: _sController,
                                              textAlign: TextAlign.center,
                                              decoration: InputDecoration(
                                                  labelText: Translations.get(
                                                          'set_label',
                                                          language: lang)
                                                      .toUpperCase(),
                                                  border:
                                                      const OutlineInputBorder()),
                                              keyboardType:
                                                  TextInputType.number,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Text('CZAS ĆWICZENIA',
                                                    style: TextStyle(
                                                        color:
                                                            Color(0xFFFFD700),
                                                        fontSize: 11,
                                                        fontWeight:
                                                            FontWeight.w600)),
                                                const SizedBox(height: 6),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    IconButton(
                                                      onPressed: () {
                                                        int val = int.tryParse(
                                                                _wController
                                                                    .text) ??
                                                            30;
                                                        if (val >= 30) {
                                                          val -= 30;
                                                          _wController.text =
                                                              val.toString();
                                                          setState(() {});
                                                        }
                                                      },
                                                      icon: const Icon(
                                                          Icons.remove_circle,
                                                          color:
                                                              Color(0xFFFF5252),
                                                          size: 32),
                                                    ),
                                                    Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 16,
                                                          vertical: 8),
                                                      decoration: BoxDecoration(
                                                        border: Border.all(
                                                            color: const Color(
                                                                0xFFFFD700)),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                      ),
                                                      child: Text(
                                                        '${_wController.text.isEmpty ? "30" : _wController.text}s',
                                                        style: const TextStyle(
                                                            color: Color(
                                                                0xFFFFD700),
                                                            fontSize: 20,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    ),
                                                    IconButton(
                                                      onPressed: () {
                                                        int val = int.tryParse(
                                                                _wController
                                                                    .text) ??
                                                            0;
                                                        val += 30;
                                                        _wController.text =
                                                            val.toString();
                                                        setState(() {});
                                                      },
                                                      icon: const Icon(
                                                          Icons.add_circle,
                                                          color:
                                                              Color(0xFF2ECC71),
                                                          size: 32),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Expanded(
                                            child: ElevatedButton.icon(
                                              onPressed: _setStart == null
                                                  ? _startSetStopwatch
                                                  : null,
                                              icon: const Icon(Icons.play_arrow,
                                                  color: Colors.black,
                                                  size: 18),
                                              label: const Text('START',
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 13)),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    const Color(0xFF2ECC71),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 8),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: ElevatedButton.icon(
                                              onPressed: _setStart != null
                                                  ? _stopSetStopwatch
                                                  : null,
                                              icon: const Icon(Icons.stop,
                                                  color: Colors.black,
                                                  size: 18),
                                              label: const Text('STOP',
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 13)),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    const Color(0xFFFF5252),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 8),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: ElevatedButton.icon(
                                              onPressed: _resetSetStopwatch,
                                              icon: const Icon(Icons.refresh,
                                                  color: Colors.black,
                                                  size: 18),
                                              label: const Text('RESET',
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 13)),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.orange,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 8),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Center(
                                        child: Text(
                                          'Zmierzony czas: ${_tController.text.isEmpty ? "0" : _tController.text}s',
                                          style: TextStyle(
                                              color: accent,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ] else ...[
                                      Row(
                                        children: [
                                          Expanded(
                                            child: TextField(
                                              controller: _sController,
                                              textAlign: TextAlign.center,
                                              decoration: InputDecoration(
                                                  labelText: Translations.get(
                                                          'set_label',
                                                          language: lang)
                                                      .toUpperCase(),
                                                  border:
                                                      const OutlineInputBorder()),
                                              keyboardType:
                                                  TextInputType.number,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: TextField(
                                              controller: _rController,
                                              decoration: InputDecoration(
                                                  labelText: Translations.get(
                                                          'reps_label',
                                                          language: lang)
                                                      .toUpperCase(),
                                                  border:
                                                      const OutlineInputBorder()),
                                              keyboardType:
                                                  TextInputType.number,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      // Waga (KG) z przyciskami +/- i suwakiem
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            Translations.get('kg_label',
                                                    language: lang)
                                                .toUpperCase(),
                                            style: TextStyle(
                                              color:
                                                  accent.withValues(alpha: 0.8),
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              // Minus 1 kg
                                              IconButton(
                                                onPressed: () {
                                                  double val = double.tryParse(
                                                          _wController.text) ??
                                                      0;
                                                  if (val >= 1) {
                                                    val -= 1;
                                                    _wController.text =
                                                        val.toStringAsFixed(
                                                            val.truncateToDouble() ==
                                                                    val
                                                                ? 0
                                                                : 1);
                                                    setState(() {});
                                                  }
                                                },
                                                icon: const Icon(
                                                    Icons.remove_circle,
                                                    color: Color(0xFFFF5252),
                                                    size: 36),
                                              ),
                                              const SizedBox(width: 8),
                                              // Pole tekstowe z wagą
                                              SizedBox(
                                                width: 80,
                                                child: TextField(
                                                  controller: _wController,
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                    color: Color(0xFFFFD700),
                                                    fontSize: 24,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  decoration: InputDecoration(
                                                    suffixText: 'kg',
                                                    suffixStyle: TextStyle(
                                                      color: accent.withValues(
                                                          alpha: 0.7),
                                                      fontSize: 14,
                                                    ),
                                                    border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                      borderSide: BorderSide(
                                                          color: accent),
                                                    ),
                                                    enabledBorder:
                                                        OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                      borderSide: BorderSide(
                                                          color:
                                                              accent.withValues(
                                                                  alpha: 0.5)),
                                                    ),
                                                    focusedBorder:
                                                        OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                      borderSide: BorderSide(
                                                          color: accent,
                                                          width: 2),
                                                    ),
                                                    contentPadding:
                                                        const EdgeInsets
                                                            .symmetric(
                                                            horizontal: 8,
                                                            vertical: 12),
                                                  ),
                                                  keyboardType:
                                                      const TextInputType
                                                          .numberWithOptions(
                                                          decimal: true),
                                                  onChanged: (_) =>
                                                      setState(() {}),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              // Plus 1 kg
                                              IconButton(
                                                onPressed: () {
                                                  double val = double.tryParse(
                                                          _wController.text) ??
                                                      0;
                                                  val += 1;
                                                  _wController.text =
                                                      val.toStringAsFixed(
                                                          val.truncateToDouble() ==
                                                                  val
                                                              ? 0
                                                              : 1);
                                                  setState(() {});
                                                },
                                                icon: const Icon(
                                                    Icons.add_circle,
                                                    color: Color(0xFF2ECC71),
                                                    size: 36),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          // Suwak wagi (0-200 kg)
                                          SliderTheme(
                                            data: SliderTheme.of(context)
                                                .copyWith(
                                              activeTrackColor: accent,
                                              inactiveTrackColor:
                                                  accent.withValues(alpha: 0.3),
                                              thumbColor: accent,
                                              overlayColor:
                                                  accent.withValues(alpha: 0.2),
                                              trackHeight: 6,
                                              thumbShape:
                                                  const RoundSliderThumbShape(
                                                      enabledThumbRadius: 10),
                                            ),
                                            child: Slider(
                                              value: (double.tryParse(
                                                          _wController.text) ??
                                                      0)
                                                  .clamp(0, 200),
                                              min: 0,
                                              max: 200,
                                              divisions: 200, // co 1 kg
                                              onChanged: (val) {
                                                _wController.text =
                                                    val.toInt().toString();
                                                setState(() {});
                                              },
                                            ),
                                          ),
                                          // Etykiety suwaka
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text('0 kg',
                                                  style: TextStyle(
                                                      color: accent.withValues(
                                                          alpha: 0.5),
                                                      fontSize: 10)),
                                              Text('100 kg',
                                                  style: TextStyle(
                                                      color: accent.withValues(
                                                          alpha: 0.5),
                                                      fontSize: 10)),
                                              Text('200 kg',
                                                  style: TextStyle(
                                                      color: accent.withValues(
                                                          alpha: 0.5),
                                                      fontSize: 10)),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                    const SizedBox(height: 12),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton.icon(
                                        onPressed: _saveLog,
                                        icon: const Icon(Icons.check,
                                            color: Colors.black),
                                        label: Text(
                                            Translations.get('save_set',
                                                language: lang),
                                            style: const TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.w800)),
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: accent,
                                            minimumSize: const Size(
                                                double.infinity, 48)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Card(
                              color: Colors.black.withValues(alpha: 0.35),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  side: BorderSide(
                                      color: accent.withValues(alpha: 0.2))),
                              child: Padding(
                                padding: EdgeInsets.all(cardPadding),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                            Translations.get('rest_time',
                                                language: lang),
                                            style: TextStyle(
                                                color: accent,
                                                fontWeight: FontWeight.w700)),
                                        Text(
                                            '${_totalRestSeconds ~/ 60}:${(_totalRestSeconds % 60).toString().padLeft(2, '0')}',
                                            style: const TextStyle(
                                                color: Color(0xFFFFD700),
                                                fontWeight: FontWeight.w700,
                                                fontSize: 18)),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    SliderTheme(
                                      data: SliderTheme.of(context).copyWith(
                                          thumbColor: accent,
                                          activeTrackColor: accent),
                                      child: Slider(
                                          value: _totalRestSeconds.toDouble(),
                                          min: 10,
                                          max: 600,
                                          divisions: 59,
                                          onChanged: _isTimerRunning
                                              ? null
                                              : (val) {
                                                  setState(() {
                                                    _totalRestSeconds =
                                                        val.toInt();
                                                  });
                                                }),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        IconButton(
                                          onPressed: _isTimerRunning
                                              ? null
                                              : () {
                                                  setState(() {
                                                    _totalRestSeconds =
                                                        (_totalRestSeconds - 30)
                                                            .clamp(30, 600);
                                                  });
                                                },
                                          icon: Icon(Icons.remove_circle,
                                              color: _isTimerRunning
                                                  ? Colors.grey
                                                  : const Color(0xFFFF5252),
                                              size: 36),
                                        ),
                                        const SizedBox(width: 16),
                                        IconButton(
                                          onPressed: _isTimerRunning
                                              ? null
                                              : () {
                                                  setState(() {
                                                    _totalRestSeconds =
                                                        (_totalRestSeconds + 30)
                                                            .clamp(30, 600);
                                                  });
                                                },
                                          icon: Icon(Icons.add_circle,
                                              color: _isTimerRunning
                                                  ? Colors.grey
                                                  : const Color(0xFF2ECC71),
                                              size: 36),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                            Translations.get('auto_start',
                                                language: lang),
                                            style: const TextStyle(
                                                color: Color(0xFFFFD700))),
                                        Switch(
                                            value: _autoStart,
                                            onChanged: (v) => _setAutoStart(v),
                                            activeThumbColor: accent),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(Translations.get('history', language: lang),
                                style: TextStyle(
                                    color: accent,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 16)),
                            const SizedBox(height: 6),
                            if (_history.isEmpty)
                              Text(
                                  Translations.get('no_history',
                                      language: lang),
                                  style: const TextStyle(
                                      color: Color(0xFFFFD700))),
                            if (_history.isNotEmpty)
                              ..._history
                                  .asMap()
                                  .entries
                                  .map((entry) {
                                    final index = entry.key;
                                    final log = entry.value;
                                    final String displayText;
                                    if (log.durationSeconds > 0) {
                                      final planned = log.plannedTime ?? '';
                                      if (planned.isNotEmpty) {
                                        displayText =
                                            'Planned: ${planned}s | Measured: ${log.durationSeconds}s';
                                      } else {
                                        displayText = '${log.durationSeconds}s';
                                      }
                                    } else {
                                      displayText =
                                          '${log.weight} kg x ${log.reps}';
                                    }

                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 10),
                                      child: Card(
                                        color: Theme.of(context).cardColor,
                                        child: ListTile(
                                          onTap: () => _editHistoryEntry(index),
                                          leading: CircleAvatar(
                                              backgroundColor: accent,
                                              child: Text(log.sets,
                                                  style: const TextStyle(
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 16))),
                                          title: Text(
                                              '${lang == 'PL' ? 'Seria' : lang == 'NO' ? 'Sett' : 'Set'} ${log.sets}: $displayText',
                                              style: const TextStyle(
                                                  color: Color(0xFF2ECC71),
                                                  fontWeight: FontWeight.bold)),
                                          subtitle: Text(log.date,
                                              style: const TextStyle(
                                                  color: Color(0xFFFFD700))),
                                          trailing: Icon(Icons.edit,
                                              color: Color(0xFFFF5252),
                                              size: 20),
                                        ),
                                      ),
                                    );
                                  })
                                  .toList()
                                  .reversed,
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            bottomNavigationBar: LayoutBuilder(builder: (context, constraints) {
              final isSmallScreen = MediaQuery.of(context).size.width < 400;
              final barHeight = isSmallScreen ? 100.0 : 120.0;
              final timerSize = isSmallScreen ? 80.0 : 100.0;
              final timerInnerSize = isSmallScreen ? 68.0 : 84.0;

              return Container(
                height: barHeight,
                padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 8 : 14,
                    vertical: isSmallScreen ? 8 : 12),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.35),
                        blurRadius: 8)
                  ],
                  border: Border(top: BorderSide(color: Color(0x1AFFD700))),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          _SmallIconButton(
                            tooltip: pauseResumeLabel,
                            icon: _isTimerRunning
                                ? Icons.pause
                                : Icons.play_arrow,
                            color: accent,
                            onPressed: () {
                              if (_isTimerRunning) {
                                _pauseTimer();
                              } else {
                                if (_secondsRemaining > 0) {
                                  _startRestTimer(resume: true);
                                } else {
                                  _startRestTimer(resume: false);
                                }
                              }
                            },
                          ),
                          const SizedBox(width: 8),
                          _SmallIconButton(
                            tooltip: Translations.get('reset', language: lang),
                            icon: Icons.refresh,
                            color: accent,
                            onPressed: _resetTimer,
                          ),
                          const SizedBox(width: 8),
                          _SmallIconButton(
                            tooltip: Translations.get('stop', language: lang),
                            icon: Icons.stop,
                            color: const Color(0xFFFF5252),
                            onPressed: _stopTimer,
                          ),
                          const SizedBox(width: 14),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  _isTimerRunning
                                      ? Translations.get('running',
                                          language: lang)
                                      : (_secondsRemaining > 0
                                          ? Translations.get('paused',
                                              language: lang)
                                          : Translations.get('stopped',
                                              language: lang)),
                                  style: const TextStyle(
                                      color: Color(0xB3FFD700),
                                      fontWeight: FontWeight.w600)),
                              const SizedBox(height: 4),
                              Text(
                                  Translations.get('rest_label',
                                      language: lang),
                                  style: const TextStyle(
                                      color: Color(0x8AFFD700), fontSize: 12)),
                              Text('${_totalRestSeconds}s',
                                  style: const TextStyle(
                                      color: Color(0x8AFFD700), fontSize: 12)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: timerSize,
                      height: timerSize,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: accent, width: 2),
                        boxShadow: [
                          BoxShadow(
                              color: accent.withValues(alpha: 0.25),
                              blurRadius: 16,
                              offset: const Offset(0, 6))
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: timerInnerSize,
                              height: timerInnerSize,
                              child: CircularProgressIndicator(
                                  value: _progressValue(),
                                  strokeWidth: isSmallScreen ? 6 : 8,
                                  color: accent,
                                  backgroundColor: Color(0x3DFFD700)),
                            ),
                            Text(
                              _secondsRemaining > 0
                                  ? _formatTime(_secondsRemaining)
                                  : _formatTime(_totalRestSeconds),
                              style: TextStyle(
                                  color: _isTimerRunning
                                      ? accent
                                      : Color(0xFFFFD700),
                                  fontWeight: FontWeight.bold,
                                  fontSize: isSmallScreen ? 18 : 22,
                                  shadows: [
                                    Shadow(
                                      color:
                                          Colors.black.withValues(alpha: 0.8),
                                      blurRadius: 4,
                                    ),
                                  ]),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          );
        });
  }
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _vibrationEnabled = true;
  static const String _vibrationEnabledKey = 'vibration_enabled';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await getPrefs();
    if (mounted) {
      setState(() {
        _vibrationEnabled = prefs.getBool(_vibrationEnabledKey) ?? true;
      });
    }
  }

  Future<void> _setVibrationEnabled(bool v) async {
    final prefs = await getPrefs();
    await prefs.setBool(_vibrationEnabledKey, v);
    if (mounted) {
      setState(() {
        _vibrationEnabled = v;
      });
    }
  }

  Future<void> _setLanguage(String lang) async {
    final prefs = await getPrefs();
    await prefs.setString('app_language', lang);
    updateGlobalLanguage(lang);
  }

  void _showLanguageSheet(BuildContext context, String currentLang) {
    const gold = Color(0xFFFFD700);
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0E1528),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(18))),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: kSupportedLanguages.map((code) {
              final bool active = code == currentLang;
              return ListTile(
                leading: Icon(Icons.language, color: gold),
                title: Text(code,
                    style: TextStyle(
                        color: gold,
                        fontWeight:
                            active ? FontWeight.w800 : FontWeight.w600)),
                trailing: active
                    ? const Icon(Icons.check, color: gold)
                    : const SizedBox.shrink(),
                onTap: () {
                  Navigator.pop(ctx);
                  _setLanguage(code);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const gold = Color(0xFFFFD700);
    return ValueListenableBuilder<String>(
      valueListenable: globalLanguageNotifier,
      builder: (context, lang, _) {
        return ValueListenableBuilder<PlanAccessState>(
          valueListenable: PlanAccessController.instance.notifier,
          builder: (context, state, __) {
            final bool loggedIn = state.isAuthenticated;
            final String userEmail = state.userEmail ?? '';
            return Scaffold(
              appBar: buildCustomAppBar(context, accentColor: gold),
              body: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Card(
                    color: Colors.black.withValues(alpha: 0.35),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: BorderSide(color: gold.withValues(alpha: 0.4))),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text('Ustawienia',
                              style: TextStyle(
                                  color: gold,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 20)),
                          const SizedBox(height: 12),
                          ListTile(
                            leading: const Icon(Icons.language, color: gold),
                            title: const Text('Język aplikacji',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: gold)),
                            subtitle: Text(lang,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: gold.withValues(alpha: 0.7))),
                            onTap: () => _showLanguageSheet(context, lang),
                          ),
                          Divider(color: Color(0x1FFFD700)),
                          ListTile(
                            leading: Icon(
                              loggedIn ? Icons.logout : Icons.login,
                              color: gold,
                            ),
                            title: Text(
                              loggedIn ? 'Wyloguj' : 'Zaloguj',
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: gold),
                            ),
                            subtitle: Text(
                              loggedIn
                                  ? (userEmail.isNotEmpty
                                      ? userEmail
                                      : 'Zalogowano')
                                  : 'Nie jesteś zalogowany',
                              textAlign: TextAlign.center,
                              style:
                                  TextStyle(color: gold.withValues(alpha: 0.7)),
                            ),
                            onTap: () async {
                              if (loggedIn) {
                                // Wyczyść dane "Zapamiętaj mnie" przy wylogowaniu
                                final prefs =
                                    await SharedPreferences.getInstance();
                                await prefs.setBool('remember_me', false);
                                await prefs.remove('saved_email');
                                await prefs.remove('saved_password');

                                await PlanAccessController.instance.signOut();
                                if (context.mounted) {
                                  Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(
                                        builder: (_) =>
                                            const StartChoiceScreen()),
                                    (route) => false,
                                  );
                                }
                              } else {
                                if (context.mounted) {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) => const LoginScreen()));
                                }
                              }
                            },
                          ),
                          Divider(color: Color(0x1FFFD700)),
                          ListTile(
                            enabled: loggedIn,
                            leading: const Icon(Icons.lock, color: gold),
                            title: const Text('Zmień hasło',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: gold)),
                            subtitle: Text(
                              loggedIn
                                  ? 'Aktualne konto: ${userEmail.isNotEmpty ? userEmail : 'zalogowany użytkownik'}'
                                  : 'Zaloguj się, aby zmienić hasło',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: loggedIn
                                      ? gold.withValues(alpha: 0.7)
                                      : gold.withValues(alpha: 0.4)),
                            ),
                            onTap: loggedIn
                                ? () {
                                    showDialog(
                                      context: context,
                                      builder: (_) =>
                                          const ChangePasswordDialog(),
                                    );
                                  }
                                : null,
                          ),
                          Divider(color: Color(0x1FFFD700)),
                          SwitchListTile(
                            secondary: const Icon(Icons.vibration, color: gold),
                            title: Text(
                                Translations.get('vibration_enabled',
                                    language: lang),
                                style: const TextStyle(color: gold)),
                            value: _vibrationEnabled,
                            onChanged: (v) => _setVibrationEnabled(v),
                            activeColor: gold,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _SmallIconButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final Color color;
  final String tooltip;
  const _SmallIconButton(
      {required this.onPressed,
      required this.icon,
      required this.color,
      required this.tooltip});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.6),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: color.withValues(alpha: 0.9))),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onPressed,
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Icon(icon, size: 18, color: color)),
      ),
    );
  }
}

class ChangePasswordDialog extends StatefulWidget {
  const ChangePasswordDialog({super.key});

  @override
  State<ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<ChangePasswordDialog> {
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    final current = _currentController.text.trim();
    final newPass = _newController.text.trim();
    final confirm = _confirmController.text.trim();

    if (newPass.length < 6) {
      setState(() => _error = 'Hasło musi mieć min. 6 znaków');
      return;
    }
    if (newPass != confirm) {
      setState(() => _error = 'Hasła nie są takie same');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await PlanAccessController.instance.changePassword(current, newPass);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Hasło zostało zmienione')),
        );
      }
    } catch (e) {
      setState(() => _error = e.toString());
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
    return AlertDialog(
      backgroundColor: Colors.black.withValues(alpha: 0.9),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Zmień hasło',
          style:
              TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.w800)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _currentController,
            obscureText: true,
            style: const TextStyle(color: Color(0xFFFFD700)),
            decoration: const InputDecoration(
                labelText: 'Obecne hasło',
                prefixIcon: Icon(Icons.lock_outline)),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _newController,
            obscureText: true,
            style: const TextStyle(color: Color(0xFFFFD700)),
            decoration: const InputDecoration(
                labelText: 'Nowe hasło', prefixIcon: Icon(Icons.password)),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _confirmController,
            obscureText: true,
            style: const TextStyle(color: Color(0xFFFFD700)),
            decoration: const InputDecoration(
                labelText: 'Powtórz nowe hasło',
                prefixIcon: Icon(Icons.password)),
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(_error!,
                style: const TextStyle(color: Color(0xFFFF5252), fontSize: 12)),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _loading ? null : () => Navigator.pop(context),
          child: Text(Translations.get('cancel', language: globalLanguage)),
        ),
        ElevatedButton(
          onPressed: _loading ? null : _changePassword,
          child: _loading
              ? const SizedBox(
                  width: 16, height: 16, child: CircularProgressIndicator())
              : Text(Translations.get('save', language: globalLanguage)),
        ),
      ],
    );
  }
}
