import 'dart:async';
import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'
    show rootBundle, HapticFeedback, Clipboard, ClipboardData;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';

import 'firebase_options.dart';
import 'plan_access.dart';
import 'client_list_screen.dart';

String globalLanguage = 'EN';
final ValueNotifier<String> globalLanguageNotifier =
    ValueNotifier<String>(globalLanguage);

void updateGlobalLanguage(String lang) {
  globalLanguage = lang;
  globalLanguageNotifier.value = lang;
}

const List<String> kSupportedLanguages = ['EN', 'PL', 'NO'];

class Translations {
  static const Map<String, Map<String, String>> translations = {
    'app_title': {'EN': 'K.S-GYM', 'PL': 'K.S-GYM', 'NO': 'K.S-GYM'},
    'login_for_online_plan': {
      'EN': 'Log in for online plan',
      'PL': 'Zaloguj sie po plan online',
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
    'save_set': {'EN': 'Save set', 'PL': 'Zapisz serie', 'NO': 'Lagre sett'},
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
      'PL': 'Biezaca kategoria',
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
    'delete_question': {'EN': 'Delete?', 'PL': 'Usunac?', 'NO': 'Slette?'},
    'delete_exercise_and_history': {
      'EN': "Delete '{name}' and all its history?",
      'PL': "Usunac '{name}' i cala historie?",
      'NO': "Slett '{name}' og all historikk?"
    },
    'delete': {'EN': 'Delete', 'PL': 'Usun', 'NO': 'Slett'},
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
      'PL': 'Automatycznie rozpocznij serie',
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
      'PL': 'Przerwa zakonczona',
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
      'NO': 'M�lt tid'
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
    'password': {'EN': 'Password', 'PL': 'Haslo', 'NO': 'Passord'},
    'change_password': {
      'EN': 'Change password',
      'PL': 'Zmien haslo',
      'NO': 'Endre passord'
    },
    'current_password': {
      'EN': 'Current password',
      'PL': 'Aktualne haslo',
      'NO': 'Nåværende passord'
    },
    'new_password': {
      'EN': 'New password',
      'PL': 'Nowe haslo',
      'NO': 'Nytt passord'
    },
    'confirm_password': {
      'EN': 'Confirm password',
      'PL': 'Potwierdz haslo',
      'NO': 'Bekreft passord'
    },
    'passwords_dont_match': {
      'EN': 'Passwords do not match',
      'PL': 'Hasla nie pasuja',
      'NO': 'Passordene samsvarer ikke'
    },
    'password_changed': {
      'EN': 'Password changed successfully',
      'PL': 'Haslo zmienione pomyslnie',
      'NO': 'Passord endret vellykket'
    },
    'password_too_short': {
      'EN': 'Password must be at least 4 characters',
      'PL': 'Haslo musi miec co najmniej 4 znaki',
      'NO': 'Passordet må være minst 4 tegn'
    },
    'logging_in': {
      'EN': 'Signing in...',
      'PL': 'Logowanie...',
      'NO': 'Logger inn...'
    },
    'login_action': {'EN': 'Sign in', 'PL': 'Zaloguj', 'NO': 'Logg inn'},
    'login_required': {
      'EN': 'Log in to see the plan',
      'PL': 'Zaloguj sie, aby zobaczyc plan',
      'NO': 'Logg inn for � se planen'
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
    'refresh': {'EN': 'Refresh', 'PL': 'Odswiez', 'NO': 'Oppdater'},
    'no_active_user': {
      'EN': 'No active user',
      'PL': 'Brak aktywnego uzytkownika',
      'NO': 'Ingen aktiv bruker'
    },
    'plan_fetch_failed': {
      'EN': 'Could not fetch plan',
      'PL': 'Nie udalo sie pobrac planu',
      'NO': 'Kunne ikke hente planen'
    },
    'plan_updated_at': {
      'EN': 'Updated: {date}',
      'PL': 'Aktualizacja: {date}',
      'NO': 'Oppdatert: {date}'
    },
    'plan_entry_core': {
      'EN': '{sets} sets � rest {rest}s',
      'PL': '{sets} serii � przerwa {rest}s',
      'NO': '{sets} sett � pause {rest}s'
    },
    'plan_entry_time': {
      'EN': ' � time {time}s',
      'PL': ' � czas {time}s',
      'NO': ' � tid {time}s'
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
      'PL': 'Nazwa cwiczenia',
      'NO': '�velsesnavn'
    },
    'kind_label': {'EN': 'Type', 'PL': 'Rodzaj', 'NO': 'Typ'},
    'select_exercise_type': {
      'EN': 'Select exercise type',
      'PL': 'Wybierz typ cwiczenia',
      'NO': 'Velg �velsestype'
    },
    'weight_based': {'EN': 'With weight', 'PL': 'Z ciezarem', 'NO': 'Med vekt'},
    'time_based': {'EN': 'For time', 'PL': 'Na czas', 'NO': 'P� tid'},
    'plan_local_desc': {
      'EN': 'Paste or write your plan. It stays on this device.',
      'PL': 'Wklej lub wpisz plan. Zostaje na tym urzadzeniu.',
      'NO': 'Lim inn eller skriv planen. Det blir p� denne enheten.'
    },
    'plan_saved_local': {
      'EN': 'Plan saved locally',
      'PL': 'Plan zapisany lokalnie',
      'NO': 'Plan lagret lokalt'
    },
    'plan_save_failed': {
      'EN': 'Could not save plan',
      'PL': 'Nie udalo sie zapisac planu',
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
  // Try with different separators - both old (�) and new (◆)
  final separators = [' ◆ ', ' � ', ' - '];
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
    'Wyciskanie sztangi na ławce poziomej ◆ Barbell Bench Press',
    'Wyciskanie sztangi na skosie dodatnim ◆ Incline Barbell Bench Press',
    'Wyciskanie sztangi na skosie ujemnym ◆ Decline Barbell Bench Press',
    'Wyciskanie sztangi wąskim chwytem ◆ Close-Grip Bench Press',
    'Wyciskanie sztangi typu Gilotyna ◆ Guillotine Press',
    'Wyciskanie z podłogi (sztanga) ◆ Barbell Floor Press',
    'Wyciskanie sztangi z łańcuchami ◆ Chain Bench Press',
    'Wyciskanie ze Slingshotem ◆ Slingshot Bench Press',
    'Wyciskanie z deską (klockiem) ◆ Board Press',
    'Wyciskanie hantli na ławce poziomej ◆ Dumbbell Bench Press',
    'Wyciskanie hantli na skosie dodatnim ◆ Incline Dumbbell Press',
    'Wyciskanie hantli na skosie ujemnym ◆ Decline Dumbbell Press',
    'Wyciskanie hantli z rotacją (korkociągowe) ◆ Twisting Dumbbell Press',
    'Wyciskanie hantli obchwytem neutralnym (młotkowym) ◆ Neutral Grip Dumbbell Press',
    'Wyciskanie hantli z podłogi ◆ Dumbbell Floor Press',
    'Wyciskanie na maszynie Smitha ◆ Smith Machine Bench Press',
    'Wyciskanie na maszynie typu Hammer (siedząc) ◆ Hammer Strength Chest Press',
    'Wyciskanie na maszynie stosowej ◆ Seated Chest Press Machine',
    'Rozpiętki z hantlami na ławce poziomej ◆ Flat Dumbbell Flys',
    'Rozpiętki z hantlami na skosie dodatnim ◆ Incline Dumbbell Flys',
    'Rozpiętki na maszynie Butterfly ◆ Pec Deck Fly / Machine Fly',
    'Krzyżowanie linek wyciągu górnego (Brama) ◆ Cable Crossover / High Cable Fly',
    'Rozpiętki z linkami wyciągu dolnego ◆ Low Cable Crossover',
    'Rozpiętki jednoręcz na wyciągu ◆ Single Arm Cable Fly',
    'Przenoszenie hantla za głowę ◆ Dumbbell Pullover',
    'Landmine Press (wyciskanie półsztangi) ◆ Landmine Press',
    'Pompki klasyczne ◆ Push-ups',
    'Pompki szerokie ◆ Wide Grip Push-ups',
    'Pompki diamentowe (wąskie) ◆ Diamond Push-ups',
    'Pompki na podwyższeniu (głowa wyżej) ◆ Incline Push-ups',
    'Pompki z nogami na podwyższeniu (głowa niżej) ◆ Decline Push-ups',
    'Pompki łucznicze ◆ Archer Push-ups',
    'Pompki plyometryczne (z klaśnięciem) ◆ Plyometric / Clap Push-ups',
    'Pompki na kółkach gimnastycznych ◆ Ring Push-ups',
    'Dipy (Pompki na poręczach, tułów pochylony) ◆ Chest Dips',
  ],
  'BACK': [
    'Podciąganie na drążku nachwytem ◆ Pull-ups',
    'Podciąganie na drążku podchwytem ◆ Chin-ups',
    'Ściąganie drążka wyciągu górnego do klatki ◆ Lat Pulldown',
    'Ściąganie drążka wyciągu górnego obchwytem wąskim ◆ Close-Grip Lat Pulldown',
    'Ściąganie drążka wyciągu górnego obchwytem neutralnym ◆ Neutral Grip Lat Pulldown',
    'Ściąganie jednoręcz na wyciągu ◆ Single Arm Lat Pulldown',
    'Ściąganie drążka za głowę ◆ Behind the Neck Pulldown',
    'Ściąganie na maszynie Hammer (góra-dół) ◆ Hammer Strength High Row / Pulldown',
    'Wiosłowanie sztangą w opadzie ◆ Bent Over Barbell Row',
    'Wiosłowanie sztangą obchwytem neutralnym ◆ Neutral Grip Barbell Row',
    'Wiosłowanie półsztangą (T-sztanga) ◆ T-Bar Row',
    'Wiosłowanie Pendlay (z martwego punktu) ◆ Pendlay Row',
    'Wiosłowanie hantlem jednoręcz ◆ One Arm Dumbbell Row',
    'Wiosłowanie na wyciągu dolnym siedząc ◆ Seated Cable Row',
    'Wiosłowanie na maszynie siedząc ◆ Seated Machine Row',
    'Wiosłowanie na ławce skośnej (przodem do oparcia) ◆ Chest Supported Row / Incline Bench Row',
    'Wiosłowanie sznurem wyciągu ◆ Cable Rope Row',
    'Martwy ciąg klasyczny ◆ Conventional Deadlift',
    'Martwy ciąg Sumo ◆ Sumo Deadlift',
    'Martwy ciąg Rumuński ◆ Romanian Deadlift (RDL)',
    'Martwy ciąg z deficytu ◆ Deficit Deadlift',
    'Martwy ciąg ze stopu (Rack Pull) ◆ Rack Pull',
    'Martwy ciąg z Trap Bar (sztanga heksagonalna) ◆ Trap Bar Deadlift',
    'Martwy ciąg na maszynie Smitha ◆ Smith Machine Deadlift',
    'Power Clean (Zarzut) ◆ Power Clean',
    'Wyprosty tułowia na ławce rzymskiej ◆ Back Extension / Hyperextension',
    'Odwrotne wyprosty (nogi w górę) ◆ Reverse Hyperextension',
    'Face Pull (przyciąganie liny do twarzy) ◆ Face Pull',
    'Szrugsy ze sztangą ◆ Barbell Shrugs',
    'Szrugsy z hantlami ◆ Dumbbell Shrugs',
    'Szrugsy na maszynie Smitha ◆ Smith Machine Shrugs',
    'Szrugsy na maszynie typu Trap Bar ◆ Trap Bar Shrugs',
    'Szrugsy na wyciągu dolnym ◆ Cable Shrugs',
    'Szrugsy jednoręcz z hantlem ◆ Single Arm Dumbbell Shrug',
    'Szrugsy z Kettlebell ◆ Kettlebell Shrugs',
  ],
  'BICEPS': [
    'Uginanie sztangi stojąc (klasyczne) ◆ Barbell Curl',
    'Uginanie sztangi EZ-bar ◆ EZ Bar Curl',
    'Uginanie sztangi EZ-bar nachwytem ◆ Reverse EZ Bar Curl',
    'Uginanie sztangi podchwytem (nachwytem) ◆ Reverse Barbell Curl',
    'Uginanie sztangi w opadzie (21s) ◆ Barbell Curl 21s',
    'Uginanie hantli stojąc ◆ Dumbbell Curl',
    'Uginanie hantli naprzemiennie ◆ Alternating Dumbbell Curl',
    'Uginanie hantli obchwytem młotkowym ◆ Hammer Curl',
    'Uginanie hantli na ławce skośnej ◆ Incline Dumbbell Curl',
    'Uginanie hantli na ławce Scotta ◆ Preacher Curl (Dumbbell)',
    'Uginanie sztangi na ławce Scotta ◆ Preacher Curl (Barbell)',
    'Uginanie skoncentrowane ◆ Concentration Curl',
    'Uginanie Zottman Curl ◆ Zottman Curl',
    'Uginanie Spider Curl ◆ Spider Curl',
    'Uginanie na wyciągu dolnym ◆ Cable Curl',
    'Podciąganie podchwytem (wąsko) ◆ Chin-ups',
  ],
  'TRICEPS': [
    'Wyciskanie sztangi wąskim chwytem ◆ Close-Grip Bench Press',
    'Pompki na poręczach (pionowo) ◆ Triceps Dips',
    'Pompki w podporze tyłem ◆ Bench Dips',
    'Wyciskanie francuskie sztangi do czoła ◆ Skullcrushers / Lying Triceps Extension',
    'Wyciskanie francuskie hantla obu rąk (siedząc) ◆ Overhead Dumbbell Triceps Extension',
    'Prostowanie ramion na wyciągu (sznur) ◆ Rope Pushdown',
    'Prostowanie ramion na wyciągu (drążek) ◆ Bar Pushdown / Triceps Pressdown',
    'Kickbacks (wyprost ramienia w tył w opadzie) ◆ Triceps Kickback',
    'JM Press ◆ JM Press',
    'Tate Press ◆ Tate Press',
  ],
  'SHOULDERS': [
    'Wyciskanie sztangi stojąc (OHP) ◆ Overhead Press / Military Press',
    'Wyciskanie sztangi siedząc ◆ Seated Barbell Press',
    'Wyciskanie hantli stojąc ◆ Standing Dumbbell Press',
    'Wyciskanie hantli siedząc ◆ Seated Dumbbell Press',
    'Wyciskanie Arnolda ◆ Arnold Press',
    'Wyciskanie jednoręcz hantla ◆ Single Arm Dumbbell Press',
    'Wznosy hantli bokiem ◆ Lateral Raise',
    'Wznosy hantli bokiem z odchyleniem ◆ Leaning Lateral Raise',
    'Wznosy talerza przodem ◆ Front Plate Raise',
    'Wznosy hantli przodem ◆ Front Dumbbell Raise',
    'Wznosy hantli przodem naprzemiennie ◆ Alternating Front Raise',
    'Wznosy sztangi przodem ◆ Barbell Front Raise',
    'Wznosy na tylną część barku w opadzie ◆ Bent Over Rear Delt Raise',
    'Wznosy na tylną część barku na ławce skośnej ◆ Incline Rear Delt Raise',
    'Rozpiętki odwrotne na maszynie Pec Deck ◆ Reverse Pec Deck',
    'Krzyżowanie linek wyciągu (odwrotne) ◆ Reverse Cable Crossover',
    'Szrugsy z hantlami ◆ Dumbbell Shrugs',
    'Szrugsy ze sztangą ◆ Barbell Shrugs',
  ],
  'ABS': [
    'Plank (Deska) ◆ Plank',
    'Plank boczny ◆ Side Plank',
    'Allahy (Ścięcia na wyciągu klęcząc) ◆ Cable Crunch',
    'Ścięcia brzucha (leżąc) ◆ Crunches',
    'Brzuszki (pełne) ◆ Sit-ups',
    'Unoszenie nóg w zwisie ◆ Hanging Leg Raise',
    'Unoszenie kolan w zwisie ◆ Hanging Knee Raise',
    'Unoszenie nóg leżąc ◆ Lying Leg Raise',
    'Rowerek (Bicycle Crunches) ◆ Bicycle Crunches',
    'Russian Twist ◆ Russian Twist',
    'Nożyce (Flutter Kicks) ◆ Flutter Kicks',
    'Mountain Climbers ◆ Mountain Climbers',
    'L-sit ◆ L-Sit',
    'Ab Wheel Rollout ◆ Ab Wheel Rollout',
    'Pallof Press ◆ Pallof Press',
  ],
  'LEGS': [
    'Przysiad ze sztangą na karku (High Bar) ◆ High Bar Squat',
    'Przysiad ze sztangą (Low Bar) ◆ Low Bar Squat',
    'Przysiad przedni ◆ Front Squat',
    'Przysiad typu Goblet ◆ Goblet Squat',
    'Wypychanie nóg (leg press) ◆ Leg Press',
    'Martwy ciąg klasyczny ◆ Conventional Deadlift',
    'Martwy ciąg Sumo ◆ Sumo Deadlift',
    'Martwy ciąg Rumuński ◆ Romanian Deadlift (RDL)',
    'Wykroki z hantlami ◆ Dumbbell Lunges',
    'Wykroki ze sztangą ◆ Barbell Lunges',
    'Wykroki bulgarskie ◆ Bulgarian Split Squat',
    'Przysiady bulgarskie na jednej nodze ◆ Single Leg Bulgarian Squat',
    'Prostowanie nóg na maszynie ◆ Leg Extension',
    'Uginanie nóg na maszynie (leżąc) ◆ Lying Leg Curl',
    'Uginanie nóg na maszynie (siedząc) ◆ Seated Leg Curl',
    'Wspięcia na palce stojąc ◆ Standing Calf Raise',
    'Wspięcia na palce siedząc ◆ Seated Calf Raise',
    'Hip Thrust (mostek biodrowy ze sztangą) ◆ Barbell Hip Thrust',
    'Glute Bridge (Mostek) ◆ Glute Bridge',
    'Step-ups (wchodzenie na podest) ◆ Step-ups',
    'Odwodzenie nogi na wyciągu ◆ Cable Leg Abduction',
    'Przywodzenie nogi na wyciągu ◆ Cable Leg Adduction',
    'Kopnięcie osła (Donkey Kick) ◆ Donkey Kick',
    'Wykopy w tył na wyciągu ◆ Cable Kickback',
    'Nordic Hamstring Curl ◆ Nordic Hamstring Curl',
  ],
  'FOREARMS': [
    'Uginanie nadgarstkow podchwytem ◆ Wrist Curl',
    'Prostowanie nadgarstkow nachwytem ◆ Reverse Wrist Curl',
    'Uginanie ramion nachwytem ◆ Reverse Curl',
    "Spacer Farmera ◆ Farmer's Carry / Farmer's Walk",
    'Zwis na drążku ◆ Dead Hang',
  ],
};

// Exercises that are performed for time; auto-tag as time-based.
// Use Polish names only (without separator)
const Set<String> kTimeBasedExercises = {
  'Plank (Deska)',
  'Plank boczny',
  'L-sit',
  'Zwis na drążku',
  'Spacer Farmera',
  'Spacer z hantlem jednoręcz',
  'Spacer z gumą (Monster Walk)',
  'Mountain Climbers',
  'Nożyce',
  'Kettlebell Swing',
  'Russian Twist',
  'Pallof Press',
  'Glute Bridge (Mostek)',
};

// Translations for seeded exercises across languages.
// Keys are Polish exercise names (without separator)
// Automatically built from kDefaultExercises
final Map<String, Map<String, String>> kExerciseTranslations =
    _buildExerciseTranslations();

Map<String, Map<String, String>> _buildExerciseTranslations() {
  final result = <String, Map<String, String>>{};

  // Process all exercises from kDefaultExercises
  kDefaultExercises.forEach((category, exercises) {
    for (final ex in exercises) {
      final trimmed = ex.trim();

      // Try different separators
      final separators = [' ◆ ', ' � '];
      for (final sep in separators) {
        if (trimmed.contains(sep)) {
          final parts = trimmed.split(sep);
          if (parts.length >= 2) {
            final polish = parts[0].trim();
            final english = parts[1].trim();

            // Add translation entry with Polish key
            result[polish] = {
              'PL': polish,
              'EN': english,
              'NO': english, // Use English for Norwegian by default
            };
          }
          break;
        }
      }
    }
  });

  return result;
}

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
  try {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
  } catch (_) {}
  await NotificationService.instance.init();
  try {
    final prefs = await SharedPreferences.getInstance();
    final savedLang = prefs.getString('app_language');
    if (savedLang != null && savedLang.isNotEmpty) {
      updateGlobalLanguage(savedLang);
    }
  } catch (_) {}
  try {
    await PlanAccessController.instance.initialize();
  } catch (_) {}
  runApp(const KsGymApp());
}

class KsGymApp extends StatelessWidget {
  const KsGymApp({super.key});

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
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: gold.withValues(alpha: 0.9)),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: gold,
            foregroundColor: const Color(0xFF0B2E5A),
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
          titleLarge: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            fontFamilyFallback: ['Roboto', 'Arial', 'sans-serif'],
          ),
          bodyLarge: TextStyle(
            fontSize: 15,
            fontFamilyFallback: ['Roboto', 'Arial', 'sans-serif'],
          ),
          bodyMedium: TextStyle(
            fontFamilyFallback: ['Roboto', 'Arial', 'sans-serif'],
          ),
        ).apply(
          fontFamilyFallback: ['Roboto', 'Arial', 'sans-serif'],
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

Future<bool> _assetExists(String path) async {
  try {
    await rootBundle.load(path);
    return true;
  } catch (_) {
    return false;
  }
}

Future<String?> _findExistingAsset(List<String> paths) async {
  for (final p in paths) {
    if (await _assetExists(p) == true) {
      return p;
    }
  }
  return null;
}

Widget buildLogo(BuildContext context, Color accentColor, {double size = 34}) {
  // Use mojelogo.svg which exists in assets/
  return FutureBuilder<String?>(
    future: _findExistingAsset([
      'mojelogo.svg',
    ]),
    builder: (ctx, snap) {
      if (snap.connectionState != ConnectionState.done) {
        return _logoPlaceholder(accentColor, size);
      }
      final path = snap.data;
      if (path == null) {
        return _logoPlaceholder(accentColor, size);
      }
      if (path.toLowerCase().endsWith('.svg')) {
        try {
          return SizedBox(
              height: size, child: SvgPicture.asset(path, fit: BoxFit.contain));
        } catch (_) {
          return _logoPlaceholder(accentColor, size);
        }
      }
      return Image.asset(path, height: size, fit: BoxFit.contain);
    },
  );
}

PreferredSizeWidget buildCustomAppBar(BuildContext context,
    {required Color accentColor}) {
  return AppBar(
    backgroundColor: Colors.transparent,
    elevation: 0,
    centerTitle: true,
    iconTheme: const IconThemeData(color: Color(0xFFFFD700)),
    title: Row(mainAxisSize: MainAxisSize.min, children: [
      buildLogo(context, accentColor, size: 42),
      const SizedBox(width: 10),
      const Text('K.S-GYM',
          style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 20,
              color: Color(0xFFFFD700),
              letterSpacing: 1.2)),
    ]),
    actions: [
      PopupMenuButton<String>(
        icon: const Icon(Icons.settings, color: Color(0xFFFFD700)),
        color: const Color(0xFF0B2E5A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFFFFD700), width: 2),
        ),
        onSelected: (value) {
          if (value == 'language') {
            _showLanguageDialog(context);
          } else if (value == 'logout') {
            _handleLogout(context);
          } else if (value == 'login') {
            _handleLogin(context);
          } else if (value == 'contact') {
            _showContactDialog(context);
          }
        },
        itemBuilder: (context) {
          final lang = globalLanguage;
          final isLoggedIn =
              PlanAccessController.instance.notifier.value.isAuthenticated;

          return [
            PopupMenuItem(
              value: 'language',
              child: Row(
                children: [
                  const Icon(Icons.language, color: Color(0xFFFFD700)),
                  const SizedBox(width: 12),
                  Text(
                    lang == 'PL'
                        ? 'Zmień język'
                        : lang == 'NO'
                            ? 'Endre språk'
                            : 'Change language',
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
            if (isLoggedIn)
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    const Icon(Icons.logout, color: Color(0xFFFFD700)),
                    const SizedBox(width: 12),
                    Text(
                      lang == 'PL'
                          ? 'Wyloguj'
                          : lang == 'NO'
                              ? 'Logg ut'
                              : 'Log out',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            if (!isLoggedIn)
              PopupMenuItem(
                value: 'login',
                child: Row(
                  children: [
                    const Icon(Icons.login, color: Color(0xFFFFD700)),
                    const SizedBox(width: 12),
                    Text(
                      lang == 'PL'
                          ? 'Zaloguj'
                          : lang == 'NO'
                              ? 'Logg inn'
                              : 'Log in',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            PopupMenuItem(
              value: 'contact',
              child: Row(
                children: [
                  const Icon(Icons.contact_mail, color: Color(0xFFFFD700)),
                  const SizedBox(width: 12),
                  Text(
                    lang == 'PL'
                        ? 'Kontakt'
                        : lang == 'NO'
                            ? 'Kontakt'
                            : 'Contact',
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ];
        },
      ),
    ],
  );
}

void _showLanguageDialog(BuildContext context) {
  final lang = globalLanguage;
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: const Color(0xFF0B2E5A),
      title: Text(
        lang == 'PL'
            ? 'Wybierz język'
            : lang == 'NO'
                ? 'Velg språk'
                : 'Select language',
        style: const TextStyle(
          color: Color(0xFFFFD700),
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildLanguageOption(context, 'PL', 'Polski', '🇵🇱'),
          _buildLanguageOption(context, 'EN', 'English', '🇬🇧'),
          _buildLanguageOption(context, 'NO', 'Norsk', '🇳🇴'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            lang == 'PL'
                ? 'Anuluj'
                : lang == 'NO'
                    ? 'Avbryt'
                    : 'Cancel',
            style: const TextStyle(color: Colors.white70),
          ),
        ),
      ],
    ),
  );
}

Widget _buildLanguageOption(
    BuildContext context, String code, String name, String flag) {
  final isSelected = globalLanguage == code;
  return Card(
    color: isSelected
        ? const Color(0xFFFFD700).withOpacity(0.2)
        : const Color(0xFF0B2E5A).withOpacity(0.8),
    margin: const EdgeInsets.only(bottom: 8),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
      side: BorderSide(
        color: isSelected ? const Color(0xFFFFD700) : Colors.transparent,
        width: 2,
      ),
    ),
    child: ListTile(
      leading: Text(flag, style: const TextStyle(fontSize: 24)),
      title: Text(
        name,
        style: TextStyle(
          color: isSelected ? const Color(0xFFFFD700) : Colors.white,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check_circle, color: Color(0xFFFFD700))
          : null,
      onTap: () {
        updateGlobalLanguage(code);
        Navigator.pop(context);
      },
    ),
  );
}

void _handleLogout(BuildContext context) async {
  final lang = globalLanguage;
  await PlanAccessController.instance.signOut();
  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          lang == 'PL'
              ? 'Wylogowano pomyślnie'
              : lang == 'NO'
                  ? 'Logget ut'
                  : 'Logged out successfully',
        ),
        backgroundColor: Colors.green,
      ),
    );
  }
}

void _handleLogin(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => const LoginScreen(themeColor: Color(0xFFFFD700)),
    ),
  );
}

void _showContactDialog(BuildContext context) {
  final lang = globalLanguage;
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: const Color(0xFF0B2E5A),
      title: Text(
        lang == 'PL'
            ? 'Kontakt'
            : lang == 'NO'
                ? 'Kontakt'
                : 'Contact',
        style: const TextStyle(
          color: Color(0xFFFFD700),
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.person, color: Color(0xFFFFD700)),
              const SizedBox(width: 12),
              Text(
                'Karol Szymek',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.email, color: Color(0xFFFFD700)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'karolszymek1402@gmail.com',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.fitness_center, color: Color(0xFFFFD700)),
              const SizedBox(width: 12),
              Text(
                'K.S-GYM',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
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
    this.backgroundImage,
    this.backgroundImageOpacity = 0.28,
  });

  @override
  Widget build(BuildContext context) {
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
        image: backgroundImage == null
            ? null
            : DecorationImage(
                image: AssetImage(backgroundImage!),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                    const Color(0xFF0B2E5A).withOpacity(backgroundImageOpacity),
                    BlendMode.darken),
              ),
      ),
      child: Stack(
        children: [
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
                  style: const TextStyle(color: Color(0xFFFFD700))),
              subtitle:
                  const Text(phone, style: TextStyle(color: Color(0xFFFFD700))),
              onTap: () async {
                await Clipboard.setData(const ClipboardData(text: phone));
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            Translations.get('copied_phone', language: lang))),
                  );
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.email, color: Color(0xFFFFD700)),
              title: Text(
                  Translations.get('contact_email_label', language: lang),
                  style: const TextStyle(color: Color(0xFFFFD700))),
              subtitle:
                  const Text(email, style: TextStyle(color: Color(0xFFFFD700))),
              onTap: () async {
                await Clipboard.setData(const ClipboardData(text: email));
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            Translations.get('copied_email', language: lang))),
                  );
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
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_language', lang);
    updateGlobalLanguage(lang);
  }

  Future<void> _continueOffline(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
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
    final prefs = await SharedPreferences.getInstance();
    final lang = prefs.getString('app_language') ?? globalLanguage;
    await prefs.setString('app_language', lang);
    updateGlobalLanguage(lang);
    if (context.mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const LoginScreen(
            themeColor: Color(0xFF0B2E5A),
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
        return Scaffold(
          body: GymBackgroundWithFitness(
            goldDumbbells: false,
            backgroundImage: 'assets/tlo.png',
            backgroundImageOpacity: 0.32,
            gradientColors: [
              const Color(0xFF0B2E5A),
              const Color(0xFF0A2652),
              const Color(0xFF0E3D8C),
            ],
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
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
                    Wrap(
                      spacing: 10,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: ['EN', 'PL', 'NO'].map((code) {
                        final bool isActive = lang == code;
                        return ChoiceChip(
                          label: Text(code,
                              style: TextStyle(
                                  color:
                                      isActive ? const Color(0xFF0B2E5A) : gold,
                                  fontWeight: FontWeight.w700)),
                          selected: isActive,
                          onSelected: (_) => _setLanguage(context, code),
                          selectedColor: gold,
                          backgroundColor:
                              const Color(0xFF0B2E5A).withValues(alpha: 0.5),
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
                    const SizedBox(height: 24),
                    OutlinedButton.icon(
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
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: gold.withValues(alpha: 0.7)),
                        minimumSize: const Size(double.infinity, 52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        foregroundColor: gold,
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
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: gold.withValues(alpha: 0.7)),
                        minimumSize: const Size(double.infinity, 52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        foregroundColor: gold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () => _showContact(context, lang),
                      icon: const Icon(Icons.contact_phone, color: gold),
                      label: Text(
                        Translations.get('contact', language: lang),
                        style: const TextStyle(
                          color: gold,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: gold.withValues(alpha: 0.7)),
                        minimumSize: const Size(double.infinity, 52),
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
        );
      },
    );
  }
}

class PlanImportScreen extends StatefulWidget {
  final Color themeColor;
  const PlanImportScreen(
      {super.key, this.themeColor = const Color(0xFF64B5F6)});

  @override
  State<PlanImportScreen> createState() => _PlanImportScreenState();
}

class _PlanImportScreenState extends State<PlanImportScreen> {
  final TextEditingController _planController = TextEditingController();
  bool _saving = false;
  String? _statusKey;
  bool _statusSuccess = false;
  List<Map<String, String>> _planHistory = [];
  int _currentPlanIndex = -1;

  static const _prefsKey = 'saved_plan_text';
  static const _historyKey = 'plan_history';

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
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getStringList(_historyKey) ?? [];

      if (historyJson.isNotEmpty) {
        _planHistory = historyJson.map((e) {
          final decoded = jsonDecode(e) as Map<String, dynamic>;
          return {
            'date': decoded['date'] as String,
            'content': decoded['content'] as String,
          };
        }).toList();

        // Load most recent plan
        if (mounted) {
          setState(() {
            _currentPlanIndex = _planHistory.length - 1;
            _planController.text = _planHistory[_currentPlanIndex]['content']!;
          });
        }
      } else {
        // Fallback to old single plan format
        final cached = prefs.getString(_prefsKey) ?? '';
        if (cached.isNotEmpty && mounted) {
          setState(() {
            _planController.text = cached;
          });
        }
      }
    } catch (_) {}
  }

  Future<void> _savePlan() async {
    setState(() {
      _saving = true;
      _statusKey = null;
    });
    try {
      final prefs = await SharedPreferences.getInstance();

      // Add to history
      final newPlan = {
        'date': DateTime.now().toString().substring(0, 19),
        'content': _planController.text.trim(),
      };

      _planHistory.add(newPlan);

      // Save history
      final historyJson = _planHistory.map((plan) => jsonEncode(plan)).toList();
      await prefs.setStringList(_historyKey, historyJson);

      // Also save to old key for compatibility
      await prefs.setString(_prefsKey, _planController.text.trim());

      if (mounted) {
        setState(() {
          _currentPlanIndex = _planHistory.length - 1;
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

  void _showPlanHistory() {
    if (_planHistory.isEmpty) return;

    final lang = globalLanguage;
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0E1528),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Text(
              lang == 'PL'
                  ? 'Historia planów'
                  : lang == 'NO'
                      ? 'Planhistorikk'
                      : 'Plan History',
              style: const TextStyle(
                color: Color(0xFFFFD700),
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _planHistory.length,
                itemBuilder: (context, index) {
                  final plan = _planHistory[index];
                  final isCurrentPlan = index == _currentPlanIndex;

                  return ListTile(
                    leading: Icon(
                      isCurrentPlan ? Icons.check_circle : Icons.history,
                      color: isCurrentPlan
                          ? const Color(0xFFFFD700)
                          : Colors.white54,
                    ),
                    title: Text(
                      plan['date']!.substring(0, 16),
                      style: TextStyle(
                        color: isCurrentPlan
                            ? const Color(0xFFFFD700)
                            : Colors.white70,
                        fontWeight:
                            isCurrentPlan ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    subtitle: Text(
                      plan['content']!.split('\n').first.substring(
                                0,
                                plan['content']!.split('\n').first.length > 30
                                    ? 30
                                    : plan['content']!.split('\n').first.length,
                              ) +
                          '...',
                      style: const TextStyle(color: Colors.white54),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () {
                      setState(() {
                        _currentPlanIndex = index;
                        _planController.text = plan['content']!;
                      });
                      Navigator.pop(ctx);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
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

  Future<void> _copyToClipboard() async {
    try {
      await Clipboard.setData(ClipboardData(text: _planController.text));
      if (mounted) {
        setState(() {
          _statusKey = 'copied_to_clipboard';
          _statusSuccess = true;
        });
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final accent = widget.themeColor;
    return ValueListenableBuilder<String>(
        valueListenable: globalLanguageNotifier,
        builder: (context, lang, _) {
          return Scaffold(
            appBar: buildCustomAppBar(context, accentColor: accent),
            body: GymBackgroundWithFitness(
              goldDumbbells: false,
              backgroundImage: 'assets/tlo.png',
              backgroundImageOpacity: 0.32,
              gradientColors: [
                const Color(0xFF0B2E5A),
                const Color(0xFF0A2652),
                const Color(0xFF0E3D8C),
              ],
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
                      style: const TextStyle(color: Color(0xFFFFD700)),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.transparent,
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
                              color: Color(0xFFFFD700), fontSize: 14),
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
                                  ? Colors.greenAccent
                                  : Colors.white70),
                        ),
                      ),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _saving ? null : _savePlan,
                            icon: const Icon(Icons.save,
                                color: Color(0xFF0B2E5A)),
                            label: Text(_saving
                                ? Translations.get('plan_saving',
                                    language: lang)
                                : Translations.get('plan_save',
                                    language: lang)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: accent,
                              foregroundColor: const Color(0xFF0B2E5A),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        IconButton(
                            onPressed: _pasteFromClipboard,
                            icon: const Icon(Icons.paste,
                                color: Color(0xFFFFD700))),
                        IconButton(
                            onPressed: _copyToClipboard,
                            icon: const Icon(Icons.copy,
                                color: Color(0xFFFFD700))),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              setState(() {
                                _planController.clear();
                                _statusKey = null;
                                _currentPlanIndex = -1;
                              });
                            },
                            icon:
                                const Icon(Icons.add, color: Color(0xFFFFD700)),
                            label: Text(
                              lang == 'PL'
                                  ? 'Dodaj nowy plan'
                                  : lang == 'NO'
                                      ? 'Legg til ny plan'
                                      : 'Add new plan',
                              style: const TextStyle(color: Color(0xFFFFD700)),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                color: Color(0xFFFFD700),
                                width: 2,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        if (_planHistory.isNotEmpty) ...[
                          const SizedBox(width: 12),
                          OutlinedButton.icon(
                            onPressed: _showPlanHistory,
                            icon: const Icon(Icons.history,
                                color: Color(0xFFFFD700)),
                            label: Text(
                              lang == 'PL'
                                  ? 'Historia'
                                  : lang == 'NO'
                                      ? 'Historikk'
                                      : 'History',
                              style: const TextStyle(color: Color(0xFFFFD700)),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                color: Color(0xFFFFD700),
                                width: 2,
                              ),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 16),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          );
        });
  }
}

class ChangePasswordDialog extends StatefulWidget {
  final Color themeColor;
  const ChangePasswordDialog(
      {super.key, this.themeColor = const Color(0xFFFFD700)});

  @override
  State<ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<ChangePasswordDialog> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    final lang = globalLanguage;
    final current = _currentPasswordController.text.trim();
    final newPass = _newPasswordController.text.trim();
    final confirm = _confirmPasswordController.text.trim();

    if (current.isEmpty || newPass.isEmpty || confirm.isEmpty) {
      setState(() {
        _error = 'All fields are required';
      });
      return;
    }

    if (newPass != confirm) {
      setState(() {
        _error = Translations.get('passwords_dont_match', language: lang);
      });
      return;
    }

    if (newPass.length < 4) {
      setState(() {
        _error = Translations.get('password_too_short', language: lang);
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await PlanAccessController.instance.changePassword(current, newPass);
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              Translations.get('password_changed', language: lang),
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: globalLanguageNotifier,
      builder: (context, lang, _) {
        final accent = widget.themeColor;
        return AlertDialog(
          backgroundColor: const Color(0xFF0B2E5A),
          title: Text(
            Translations.get('change_password', language: lang),
            style: TextStyle(color: accent, fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _currentPasswordController,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText:
                        Translations.get('current_password', language: lang),
                    labelStyle: TextStyle(color: accent.withOpacity(0.7)),
                    prefixIcon: Icon(Icons.lock_outline, color: accent),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: accent.withOpacity(0.5)),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: accent),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _newPasswordController,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: Translations.get('new_password', language: lang),
                    labelStyle: TextStyle(color: accent.withOpacity(0.7)),
                    prefixIcon: Icon(Icons.lock, color: accent),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: accent.withOpacity(0.5)),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: accent),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText:
                        Translations.get('confirm_password', language: lang),
                    labelStyle: TextStyle(color: accent.withOpacity(0.7)),
                    prefixIcon: Icon(Icons.lock_clock, color: accent),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: accent.withOpacity(0.5)),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: accent),
                    ),
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _error!,
                    style:
                        const TextStyle(color: Colors.redAccent, fontSize: 13),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: _loading ? null : () => Navigator.of(context).pop(),
              child: Text(
                Translations.get('cancel', language: lang),
                style: TextStyle(color: accent.withOpacity(0.7)),
              ),
            ),
            ElevatedButton(
              onPressed: _loading ? null : _changePassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: accent,
                foregroundColor: const Color(0xFF0B2E5A),
              ),
              child: _loading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF0B2E5A),
                      ),
                    )
                  : Text(Translations.get('save', language: lang)),
            ),
          ],
        );
      },
    );
  }
}

class LoginScreen extends StatefulWidget {
  final Color themeColor;
  const LoginScreen({super.key, this.themeColor = const Color(0xFF1E88E5)});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    PlanAccessController.instance.initialize();
    // Pre-fill trainer credentials
    _emailController.text = 'karolszymek1402@gmail.com';
    _passwordController.text = 'katarynka09';
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await PlanAccessController.instance
          .signIn(_emailController.text.trim(), _passwordController.text);
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

  Future<void> _signOut() async {
    await PlanAccessController.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final accent = widget.themeColor;
    return ValueListenableBuilder<String>(
      valueListenable: globalLanguageNotifier,
      builder: (context, lang, _) {
        return Scaffold(
          appBar: buildCustomAppBar(context, accentColor: accent),
          body: GymBackgroundWithFitness(
            goldDumbbells: false,
            accentColor: accent,
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Card(
                    color: const Color(0xFF0B2E5A).withValues(alpha: 0.6),
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
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                    Translations.get('logged_in_as',
                                        language: lang),
                                    style: const TextStyle(
                                        color: Colors.white70,
                                        fontWeight: FontWeight.w600)),
                                const SizedBox(height: 6),
                                Text(state.userEmail ?? '',
                                    style: TextStyle(
                                        color: accent,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 18)),
                                const SizedBox(height: 12),
                                Text(
                                    Translations.withParams('role_label',
                                        language: lang,
                                        params: {'role': state.role.name}),
                                    style:
                                        const TextStyle(color: Colors.white70)),
                                const SizedBox(height: 18),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.of(context)
                                        .push(MaterialPageRoute(
                                            builder: (_) => PlanOnlineScreen(
                                                  themeColor: accent,
                                                )));
                                  },
                                  icon: const Icon(Icons.cloud_download,
                                      color: Color(0xFF0B2E5A)),
                                  label: Text(Translations.get(
                                      'open_online_plan',
                                      language: lang)),
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: accent,
                                      foregroundColor: const Color(0xFF0B2E5A),
                                      minimumSize:
                                          const Size(double.infinity, 48)),
                                ),
                                const SizedBox(height: 10),
                                // Change password button (only for clients, not coaches)
                                if (state.role == PlanUserRole.client)
                                  OutlinedButton.icon(
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (_) => ChangePasswordDialog(
                                          themeColor: accent,
                                        ),
                                      );
                                    },
                                    icon: Icon(Icons.lock_reset, color: accent),
                                    label: Text(Translations.get(
                                        'change_password',
                                        language: lang)),
                                    style: OutlinedButton.styleFrom(
                                        side: BorderSide(color: accent),
                                        minimumSize:
                                            const Size(double.infinity, 46),
                                        foregroundColor: accent),
                                  ),
                                if (state.role == PlanUserRole.client)
                                  const SizedBox(height: 10),
                                OutlinedButton.icon(
                                  onPressed: _signOut,
                                  icon: const Icon(Icons.logout,
                                      color: Colors.red),
                                  label: Text(Translations.get('logout',
                                      language: lang)),
                                  style: OutlinedButton.styleFrom(
                                      side: BorderSide(
                                          color: Colors.red
                                              .withValues(alpha: 0.6)),
                                      minimumSize:
                                          const Size(double.infinity, 46),
                                      foregroundColor: Colors.red),
                                ),
                              ],
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
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                    labelText: Translations.get('email',
                                        language: lang),
                                    labelStyle: TextStyle(
                                        color: accent.withOpacity(0.7)),
                                    prefixIcon: Icon(Icons.alternate_email,
                                        size: 20, color: accent),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          color: accent.withOpacity(0.5)),
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(color: accent),
                                    )),
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: _passwordController,
                                obscureText: true,
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                    labelText: Translations.get('password',
                                        language: lang),
                                    labelStyle: TextStyle(
                                        color: accent.withOpacity(0.7)),
                                    prefixIcon: Icon(Icons.lock,
                                        size: 20, color: accent),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          color: accent.withOpacity(0.5)),
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(color: accent),
                                    )),
                              ),
                              const SizedBox(height: 14),
                              if (_error != null)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Text(
                                    _error!,
                                    style: const TextStyle(
                                        color: Colors.redAccent, fontSize: 13),
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
                                            color: Color(0xFF0B2E5A)))
                                    : const Icon(Icons.login,
                                        color: Color(0xFF0B2E5A)),
                                label: Text(_loading
                                    ? Translations.get('logging_in',
                                        language: lang)
                                    : Translations.get('login_action',
                                        language: lang)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: accent,
                                  foregroundColor: const Color(0xFF0B2E5A),
                                  minimumSize: const Size(double.infinity, 48),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                Translations.get('test_version_hint',
                                    language: lang),
                                style: const TextStyle(
                                    color: Colors.white54, fontSize: 12),
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
      {super.key, this.themeColor = const Color(0xFF1E88E5)});

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
    final accent = widget.themeColor;
    return ValueListenableBuilder<String>(
      valueListenable: globalLanguageNotifier,
      builder: (context, lang, _) {
        return Scaffold(
          appBar: buildCustomAppBar(context, accentColor: accent),
          body: GymBackgroundWithFitness(
            goldDumbbells: false,
            accentColor: accent,
            child: ValueListenableBuilder<PlanAccessState>(
              valueListenable: PlanAccessController.instance.notifier,
              builder: (context, state, _) {
                if (!state.isAuthenticated) {
                  return Center(
                    child: Text(
                        Translations.get('login_required', language: lang),
                        style: const TextStyle(color: Colors.white70)),
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
                          style: const TextStyle(color: Colors.white70),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 18),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        ClientListScreen(themeColor: accent)));
                          },
                          icon: const Icon(Icons.people,
                              color: Color(0xFF0B2E5A)),
                          label: Text(
                            lang == 'PL'
                                ? 'Lista klientów'
                                : lang == 'NO'
                                    ? 'Klientliste'
                                    : 'Client List',
                            style: const TextStyle(color: Color(0xFF0B2E5A)),
                          ),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFFD700),
                              foregroundColor: const Color(0xFF0B2E5A),
                              minimumSize: const Size(double.infinity, 50)),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => ExerciseListScreen(
                                        category: 'CHEST',
                                        themeColor: accent)));
                          },
                          icon: const Icon(Icons.folder_copy,
                              color: Color(0xFF0B2E5A)),
                          label: Text(Translations.get('exercise_database_btn',
                              language: lang)),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: accent,
                              foregroundColor: const Color(0xFF0B2E5A),
                              minimumSize: const Size(double.infinity, 50)),
                        ),
                        const SizedBox(height: 10),
                        OutlinedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const CategoryScreen()));
                            },
                            icon: Icon(Icons.apps, color: accent),
                            label: Text(Translations.get('all_categories_btn',
                                language: lang)),
                            style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                    color: accent.withValues(alpha: 0.6)),
                                minimumSize: const Size(double.infinity, 50),
                                foregroundColor: Color(0xFFFFD700))),
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
                          style: const TextStyle(color: Colors.white70)),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: _ensurePlan,
                        icon:
                            const Icon(Icons.refresh, color: Color(0xFF0B2E5A)),
                        label:
                            Text(Translations.get('refresh', language: lang)),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: accent,
                            foregroundColor: Color(0xFF0B2E5A)),
                      )
                    ],
                  ));
                }

                final plan = state.activePlan!;
                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text(plan.title,
                        style: TextStyle(
                            color: accent,
                            fontWeight: FontWeight.w800,
                            fontSize: 22)),
                    const SizedBox(height: 6),
                    Text(
                        Translations.withParams('plan_updated_at',
                            language: lang,
                            params: {
                              'date': plan.updatedAt
                                  .toLocal()
                                  .toString()
                                  .split('.')
                                  .first
                            }),
                        style: const TextStyle(
                            color: Colors.white54, fontSize: 12)),
                    const SizedBox(height: 10),
                    if (plan.notes.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                            color:
                                const Color(0xFF0B2E5A).withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: accent.withValues(alpha: 0.2))),
                        child: Text(plan.notes,
                            style: const TextStyle(color: Colors.white70)),
                      ),
                    const SizedBox(height: 12),
                    ...plan.entries.map((e) => Card(
                          color: const Color(0xFF0B2E5A).withValues(alpha: 0.6),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                  color: accent.withValues(alpha: 0.18))),
                          child: ListTile(
                            title: Text(e.exercise,
                                style: const TextStyle(
                                    color: Color(0xFFFFD700),
                                    fontWeight: FontWeight.w700)),
                            subtitle: Text(
                                '${Translations.withParams('plan_entry_core', language: lang, params: {
                                      'sets': e.sets.toString(),
                                      'rest': e.restSeconds.toString()
                                    })}${e.timeSeconds > 0 ? Translations.withParams('plan_entry_time', language: lang, params: {
                                        'time': e.timeSeconds.toString()
                                      }) : ''}',
                                style: const TextStyle(color: Colors.white70)),
                          ),
                        ))
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}

/// ProgressChart: shows bars and under each bar the set number, reps and weight.
class ProgressChart extends StatefulWidget {
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
  State<ProgressChart> createState() => _ProgressChartState();
}

class _ProgressChartState extends State<ProgressChart> {
  int? _selectedIndex;
  Offset? _tapPosition;

  @override
  Widget build(BuildContext context) {
    if (widget.history.isEmpty) {
      return Container(
          height: 160,
          alignment: Alignment.center,
          child: Text(Translations.get('no_data', language: widget.language),
              style:
                  TextStyle(color: widget.accentColor.withValues(alpha: 0.6))));
    }

    // Check if this is a time-based exercise (uses durationSeconds)
    final isTimeBased = widget.history.any((h) => h.durationSeconds > 0);

    final values = widget.history.map((h) {
      if (isTimeBased) {
        // For time-based exercises, use durationSeconds as the value
        return h.durationSeconds.toDouble();
      } else {
        // For weight-based exercises, use weight * reps
        final w = double.tryParse(h.weight.trim()) ?? 0.0;
        final r = double.tryParse(h.reps.trim()) ?? 0.0;
        final raw = w * r;
        return raw > 0 ? raw : 0.0;
      }
    }).toList();

    final maxVal = values.fold<double>(0.0, (prev, v) => v > prev ? v : prev);

    // If all values are 0, don't show the chart
    if (maxVal == 0.0) {
      return Container(
          height: 160,
          alignment: Alignment.center,
          child: Text(Translations.get('no_data', language: widget.language),
              style:
                  TextStyle(color: widget.accentColor.withValues(alpha: 0.6))));
    }

    return Container(
      height: 220,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0B2E5A).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: const Color(0xFFFFD700).withValues(alpha: 0.3), width: 2),
      ),
      child: Column(children: [
        if (widget.title.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(widget.title,
                style: const TextStyle(
                    color: Color(0xFFFFD700), fontWeight: FontWeight.bold)),
          ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return GestureDetector(
                onTapDown: (details) {
                  final RenderBox box = context.findRenderObject() as RenderBox;
                  final localPosition =
                      box.globalToLocal(details.globalPosition);

                  final double h = constraints.maxHeight - 12;
                  final double w = constraints.maxWidth;
                  final int n = values.length;

                  // Bar chart spacing and width
                  final double spacing = 8.0;
                  final double totalSpacing = spacing * (n + 1);
                  final double barWidth = (w - totalSpacing) / n;

                  // Find which bar was tapped
                  for (int i = 0; i < n; i++) {
                    final double x = spacing + (barWidth + spacing) * i;
                    final double barHeight =
                        (values[i] / (maxVal == 0 ? 1 : maxVal)) * h;
                    final double y = h - barHeight;

                    // Check if tap is within bar bounds
                    if (localPosition.dx >= x &&
                        localPosition.dx <= x + barWidth &&
                        localPosition.dy >= y &&
                        localPosition.dy <= h) {
                      setState(() {
                        _selectedIndex = i;
                        _tapPosition = Offset(x + barWidth / 2, y);
                      });
                      break;
                    }
                  }
                },
                onTapUp: (_) {
                  Future.delayed(const Duration(seconds: 3), () {
                    if (mounted) {
                      setState(() {
                        _selectedIndex = null;
                        _tapPosition = null;
                      });
                    }
                  });
                },
                child: Stack(
                  children: [
                    CustomPaint(
                      size: Size(constraints.maxWidth, constraints.maxHeight),
                      painter: _LineChartPainter(
                          values: values,
                          accent: widget.accentColor,
                          maxVal: maxVal,
                          selectedIndex: _selectedIndex),
                    ),
                    if (_selectedIndex != null && _tapPosition != null)
                      Positioned(
                        left: _tapPosition!.dx - 60,
                        top: _tapPosition!.dy - 60,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0B2E5A),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: const Color(0xFFFFD700), width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.5),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Set ${_selectedIndex! + 1}',
                                style: const TextStyle(
                                  color: Color(0xFFFFD700),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              if (isTimeBased)
                                Text(
                                  '${widget.history[_selectedIndex!].durationSeconds}s',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                )
                              else
                                Text(
                                  '${widget.history[_selectedIndex!].weight} kg × ${widget.history[_selectedIndex!].reps}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
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
        const SizedBox(height: 6),
        Align(
            alignment: Alignment.centerRight,
            child: Text(
                Translations.withParams('sets_label',
                    language: widget.language,
                    params: {'count': widget.history.length.toString()}),
                style:
                    const TextStyle(color: Color(0xFFFFD700), fontSize: 12))),
      ]),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  final List<double> values;
  final Color accent;
  final double maxVal;
  final int? selectedIndex;

  _LineChartPainter(
      {required this.values,
      required this.accent,
      required this.maxVal,
      this.selectedIndex});

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;
    final double maxValue = maxVal == 0.0 ? 1.0 : maxVal;
    final double h = size.height - 12;
    final double w = size.width;
    final int n = values.length;

    // Calculate bar width with spacing
    final double spacing = 8.0;
    final double totalSpacing = spacing * (n + 1);
    final double barWidth = (w - totalSpacing) / n;

    // Draw grid lines for better readability
    final gridPaint = Paint()
      ..color = const Color(0xFFFFD700).withValues(alpha: 0.1)
      ..strokeWidth = 1.0;

    for (int i = 0; i <= 4; i++) {
      final double y = h * i / 4;
      canvas.drawLine(Offset(0, y), Offset(w, y), gridPaint);
    }

    // Draw baseline
    final basePaint = Paint()
      ..color = const Color(0xFFFFD700).withValues(alpha: 0.3)
      ..strokeWidth = 1.5;
    canvas.drawLine(Offset(0, h), Offset(w, h), basePaint);

    // Draw bars
    for (int i = 0; i < n; i++) {
      final double x = spacing + (barWidth + spacing) * i;
      final double barHeight = (values[i] / maxValue) * h;
      final double y = h - barHeight;

      final bool isSelected = selectedIndex == i;

      // Draw bar with gradient
      final rect = Rect.fromLTWH(x, y, barWidth, barHeight);

      final gradient = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: isSelected
            ? [
                const Color(0xFFFFD700),
                const Color(0xFFFFD700).withValues(alpha: 0.7),
              ]
            : [
                const Color(0xFFFFD700).withValues(alpha: 0.8),
                const Color(0xFFFFD700).withValues(alpha: 0.4),
              ],
      );

      final barPaint = Paint()
        ..shader = gradient.createShader(rect)
        ..style = PaintingStyle.fill;

      // Draw bar with rounded top corners
      final rrect = RRect.fromRectAndCorners(
        rect,
        topLeft: const Radius.circular(4),
        topRight: const Radius.circular(4),
      );
      canvas.drawRRect(rrect, barPaint);

      // Draw border for selected bar
      if (isSelected) {
        final borderPaint = Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0;
        canvas.drawRRect(rrect, borderPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) =>
      selectedIndex != oldDelegate.selectedIndex ||
      values != oldDelegate.values;
}

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});

  Widget _categoryBackground(String path) {
    final lower = path.toLowerCase();
    final Widget child = lower.endsWith('.svg')
        ? SvgPicture.asset(path, fit: BoxFit.cover)
        : Image.asset(path, fit: BoxFit.cover);
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: child,
    );
  }

  static const Color _navy = Color(0xFF0B2E5A);
  static const Color _gold = Color(0xFFFFD700);
  static const List<Map<String, dynamic>> categories = [
    {
      'name': 'PLAN',
      'icon': Icons.assignment,
      'color': _gold,
      'isPlan': true,
      'image': 'assets/mojelogo.svg',
    },
    {
      'name': 'CHEST',
      'icon': Icons.fitness_center,
      'color': _navy,
      'image': 'assets/klata.svg',
    },
    {
      'name': 'BACK',
      'icon': Icons.list,
      'color': _navy,
      'image': 'assets/plecy.svg',
    },
    {
      'name': 'BICEPS',
      'icon': Icons.bolt,
      'color': _navy,
      'image': 'assets/biceps.svg',
    },
    {
      'name': 'TRICEPS',
      'icon': Icons.trending_down,
      'color': _navy,
      'image': 'assets/triceps.svg',
    },
    {
      'name': 'SHOULDERS',
      'icon': Icons.architecture,
      'color': _navy,
      'image': 'assets/barki.svg',
    },
    {
      'name': 'ABS',
      'icon': Icons.grid_view,
      'color': _navy,
      'image': 'assets/brzuch.svg',
    },
    {
      'name': 'LEGS',
      'icon': Icons.directions_walk,
      'color': _navy,
      'image': 'assets/nogi.svg',
    },
    {
      'name': 'FOREARMS',
      'icon': Icons.pan_tool_alt,
      'color': _navy,
      'image': 'assets/przedramie.svg',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: globalLanguageNotifier,
      builder: (context, lang, _) {
        final theme = Theme.of(context);
        const Color cardBlue1 = Color(0xFF0B2E5A);
        const Color cardBlue2 = Color(0xFF0E3D8C);
        const Color gold = Color(0xFFFFD700);

        return Scaffold(
          appBar: buildCustomAppBar(context, accentColor: Color(0xFFFFD700)),
          body: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/tlo.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final double tileSize = (constraints.maxWidth - 24) / 3;

                  Widget buildCategoryTile(Map<String, dynamic> cat) {
                    final color = cat['color'] as Color;
                    final bool isPlan = (cat['isPlan'] as bool?) ?? false;
                    final String? imagePath = cat['image'] as String?;
                    final String name = cat['name'] as String;
                    final displayName = localizedCategoryName(name, lang);

                    void handleTap() {
                      if (isPlan) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => PlanImportScreen(
                                      themeColor: color,
                                    )));
                        return;
                      }
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ExerciseListScreen(
                                  category: name, themeColor: color)));
                    }

                    return InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: handleTap,
                      child: Container(
                        width: tileSize,
                        height: tileSize,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFFFFD700).withValues(alpha: 0.25),
                              const Color(0xFFFFD700).withValues(alpha: 0.15)
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                                color: const Color(0xFFFFD700)
                                    .withValues(alpha: 0.3),
                                blurRadius: 14,
                                offset: const Offset(0, 8))
                          ],
                          border: Border.all(
                              color: gold.withValues(alpha: 0.9), width: 2.5),
                        ),
                        child: Stack(
                          children: [
                            if (imagePath != null)
                              Positioned.fill(
                                child: _categoryBackground(imagePath),
                              ),
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  gradient: LinearGradient(
                                    colors: [
                                      const Color(0xFF0B2E5A)
                                          .withValues(alpha: 0.2),
                                      cardBlue2.withValues(alpha: 0.06)
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 16,
                              left: 0,
                              right: 0,
                              child: Text(
                                displayName,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Color(0xFFFFD700),
                                  fontWeight: FontWeight.w900,
                                  fontSize: 18,
                                  shadows: [
                                    Shadow(
                                      color: Color(0xFF0B2E5A),
                                      blurRadius: 8,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  // Separate PLAN and other categories
                  final planCategory = categories[0]; // PLAN is first
                  final otherCategories = categories.sublist(1);

                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        // First row: PLAN in center
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            buildCategoryTile(planCategory),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Remaining categories in 3-column grid
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          alignment: WrapAlignment.center,
                          children: otherCategories
                              .map((cat) => buildCategoryTile(cat))
                              .toList(),
                        ),
                      ],
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
    final prefs = await SharedPreferences.getInstance();
    List<String> list = prefs.getStringList(_prefsKey) ?? [];

    // Do not auto-seed; start empty until user adds exercises.
    Map<String, String> lastRecs = {};

    for (var ex in list) {
      final logs = prefs.getStringList('history_$ex') ?? [];
      if (logs.isNotEmpty) {
        final last =
            ExerciseLog.fromJson(jsonDecode(logs.last), defaultExercise: ex);
        if (last.durationSeconds > 0) {
          final restTime =
              last.reps.isNotEmpty ? ' | Przerwa: ${last.reps}s' : '';
          lastRecs[ex] = "${last.durationSeconds}s$restTime";
        } else {
          lastRecs[ex] = "${last.weight} kg x ${last.reps}";
        }
      }
    }
    if (mounted) {
      setState(() {
        _exercises = list;
        _recs = lastRecs;
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
            leading: const Icon(Icons.delete, color: Colors.red),
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
                      final prefs = await SharedPreferences.getInstance();
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
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();
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

    // Extract Polish name only (first part before ◆ separator)
    String cleanName = trimmed;
    if (trimmed.contains(' ◆ ')) {
      cleanName = trimmed.split(' ◆ ')[0].trim();
    } else if (trimmed.contains(' � ')) {
      cleanName = trimmed.split(' � ')[0].trim();
    }

    if (_exercises.any((e) => e.toLowerCase() == cleanName.toLowerCase())) {
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    _exercises.add(cleanName);
    await prefs.setStringList(_prefsKey, _exercises);
    await prefs.setBool('ex_type_time_$cleanName', isTimeBased);
    if (mounted) {
      _load();
    }
  }

  void _showAddExerciseSheet(Color accent, String lang) {
    final customController = TextEditingController();
    final searchController = TextEditingController();
    bool isTimeBased = false;
    String searchQuery = '';
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
            final existingLower =
                _exercises.map((e) => e.toLowerCase()).toSet();

            // Show only exercises from current category
            final currentCategory = _normalizedCategory;
            final categoryExercisesInCategory =
                kDefaultExercises[currentCategory] ?? [];

            final available = categoryExercisesInCategory
                .where((name) => !existingLower.contains(name.toLowerCase()))
                .map((ex) {
                  final localized = kExerciseTranslations[ex]?[lang] ?? ex;
                  return {
                    'original': ex,
                    'display': localized,
                  };
                })
                .where((item) =>
                    searchQuery.isEmpty ||
                    item['display']!
                        .toLowerCase()
                        .contains(searchQuery.toLowerCase()))
                .toList();

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(Translations.get('add_exercise_title', language: lang),
                    style: const TextStyle(
                        color: Color(0xFFFFD700),
                        fontWeight: FontWeight.w800,
                        fontSize: 18)),
                const SizedBox(height: 14),
                TextField(
                  controller: searchController,
                  style: const TextStyle(color: Color(0xFFFFD700)),
                  onChanged: (val) {
                    setModalState(() {
                      searchQuery = val;
                    });
                  },
                  decoration: InputDecoration(
                      hintText: Translations.get('search_hint', language: lang),
                      hintStyle: const TextStyle(color: Color(0xFFFFD700)),
                      prefixIcon:
                          const Icon(Icons.search, color: Color(0xFFFFD700)),
                      filled: true,
                      fillColor:
                          const Color(0xFFFFD700).withValues(alpha: 0.08),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: accent.withValues(alpha: 0.3)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: accent.withValues(alpha: 0.3)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: accent, width: 2),
                      )),
                ),
                const SizedBox(height: 12),
                if (available.isNotEmpty)
                  SizedBox(
                    height: 300,
                    child: RawScrollbar(
                      thumbColor: const Color(0xFFFFD700),
                      radius: const Radius.circular(8),
                      thickness: 6,
                      thumbVisibility: true,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: available.length,
                        itemBuilder: (ctx, idx) {
                          final item = available[idx];
                          final originalName = item['original']!;
                          final displayName = item['display']!;
                          final isTime =
                              kTimeBasedExercises.contains(originalName);
                          return ListTile(
                            dense: true,
                            title: Text(displayName,
                                style:
                                    const TextStyle(color: Color(0xFFFFD700))),
                            onTap: () async {
                              await _addExercise(originalName,
                                  isTimeBased: isTime);
                              if (ctx.mounted) Navigator.pop(ctx);
                            },
                          );
                        },
                      ),
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: Text(
                        Translations.get('no_results', language: lang),
                        style: const TextStyle(color: Colors.white54),
                      ),
                    ),
                  ),
                const Divider(color: Colors.white24, height: 24),
                Text(Translations.get('add_custom', language: lang),
                    style: const TextStyle(
                        color: Color(0xFFFFD700),
                        fontWeight: FontWeight.w800,
                        fontSize: 15)),
                const SizedBox(height: 8),
                TextField(
                  controller: customController,
                  style: const TextStyle(color: Color(0xFFFFD700)),
                  decoration: InputDecoration(
                      hintText: Translations.get('exercise_name_hint',
                          language: lang),
                      hintStyle: const TextStyle(color: Color(0xFFFFD700)),
                      filled: true,
                      fillColor:
                          const Color(0xFFFFD700).withValues(alpha: 0.08),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: accent.withValues(alpha: 0.3)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: accent.withValues(alpha: 0.3)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: accent, width: 2),
                      )),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: accent,
                        foregroundColor: const Color(0xFFFFD700),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12))),
                    onPressed: () async {
                      if (customController.text.trim().isEmpty) return;

                      // Pytaj o typ ćwiczenia
                      final bool? isTime = await showDialog<bool>(
                        context: ctx,
                        builder: (dialogCtx) => AlertDialog(
                          backgroundColor: const Color(0xFF0B2E5A),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          title: Text(
                            Translations.get('select_exercise_type',
                                language: lang),
                            style: const TextStyle(color: Color(0xFFFFD700)),
                          ),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF0B2E5A),
                                    foregroundColor: const Color(0xFFFFD700),
                                    side: const BorderSide(
                                        color: Color(0xFFFFD700), width: 2),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: () =>
                                      Navigator.pop(dialogCtx, false),
                                  child: Text(
                                    Translations.get('weight_based',
                                        language: lang),
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF0B2E5A),
                                    foregroundColor: const Color(0xFFFFD700),
                                    side: const BorderSide(
                                        color: Color(0xFFFFD700), width: 2),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: () =>
                                      Navigator.pop(dialogCtx, true),
                                  child: Text(
                                    Translations.get('time_based',
                                        language: lang),
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );

                      if (isTime != null) {
                        await _addExercise(customController.text,
                            isTimeBased: isTime);
                        if (ctx.mounted) Navigator.pop(ctx);
                      }
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
    final accent = widget.themeColor;
    return ValueListenableBuilder<String>(
        valueListenable: globalLanguageNotifier,
        builder: (context, lang, _) {
          return Scaffold(
            appBar: buildCustomAppBar(context, accentColor: accent),
            body: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/tlo.png'),
                  fit: BoxFit.cover,
                ),
              ),
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
                                        color: Color(0xFFFFD700)))))
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
                                        Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        ExerciseDetailScreen(
                                                            exerciseName: name,
                                                            themeColor:
                                                                accent)))
                                            .then((_) => _load());
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
                                          icon: const Icon(Icons.more_vert,
                                              color: Color(0xFFFFD700))),
                                    ),
                                  ));
                            },
                          )),
              ]),
            ),
            floatingActionButton: FloatingActionButton.extended(
                backgroundColor: const Color(0xFFFFD700),
                onPressed: () => _showAddExerciseSheet(accent, lang),
                elevation: 8,
                label: Text(
                  Translations.get('add_exercise_title', language: lang),
                  style: const TextStyle(
                    color: Color(0xFF0B2E5A),
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                icon: const Icon(
                  Icons.add,
                  color: Color(0xFF0B2E5A),
                  size: 24,
                )),
          );
        });
  }
}

class ExerciseDetailScreen extends StatefulWidget {
  final String exerciseName;
  final Color themeColor;
  const ExerciseDetailScreen(
      {super.key, required this.exerciseName, required this.themeColor});
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
  final _restController = TextEditingController();

  bool _isTimeBased = false;
  Timer? _setTimer;
  DateTime? _setStart;

  late final AudioPlayer _audioPlayer;
  Timer? _timer;
  DateTime? _endTime;
  int _secondsRemaining = 0;
  int _totalRestSeconds = 60;
  bool _isTimerRunning = false;
  late final AnimationController _animController;

  bool _autoStart = true;
  static const String _autoStartKey = 'auto_start_timer';

  @override
  void initState() {
    super.initState();
    _audioPlayerInit();
    _animControllerInit();
    _loadHistory();
    _loadAutoStart();
  }

  void _audioPlayerInit() {
    _audioPlayer = AudioPlayer();
  }

  void _animControllerInit() {
    _animController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
  }

  @override
  void dispose() {
    _timer?.cancel();
    _setTimer?.cancel();
    try {
      _audioPlayer.dispose();
    } catch (_) {}
    _wController.dispose();
    _rController.dispose();
    _sController.dispose();
    _tController.dispose();
    _restController.dispose();
    try {
      _animController.dispose();
    } catch (_) {}
    super.dispose();
  }

  Future<void> _loadAutoStart() async {
    final prefs = await SharedPreferences.getInstance();
    final val = prefs.getBool(_autoStartKey);
    if (mounted) {
      setState(() {
        _autoStart = val ?? true;
      });
    }
  }

  Future<void> _setAutoStart(bool v) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_autoStartKey, v);
    if (mounted) {
      setState(() {
        _autoStart = v;
      });
    }
  }

  void _startSetStopwatch() {
    _setTimer?.cancel();
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
    });
  }

  void _stopSetStopwatch() {
    _setTimer?.cancel();
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
    setState(() {
      _tController.clear();
      _setStart = null;
    });
  }

  void _startRestTimer({bool resume = false}) {
    _timer?.cancel();
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
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(SnackBar(
      content: Text(Translations.withParams('prompt_next_set',
          language: lang, params: {'set': nextSet.toString()})),
      action: SnackBarAction(
        label: Translations.withParams('prompt_next_set_action',
            language: lang, params: {'set': nextSet.toString()}),
        onPressed: () {
          setState(() {
            _sController.text = nextSet.toString();
          });
        },
      ),
    ));
  }

  Future<void> _notifyEnd() async {
    final lang = globalLanguage;
    final exName = localizedExerciseName(widget.exerciseName, lang);
    try {
      if (await Vibration.hasVibrator() == true) {
        if (await Vibration.hasCustomVibrationsSupport() == true) {
          Vibration.vibrate(pattern: [0, 300, 120, 300]);
        } else {
          await Vibration.vibrate(duration: 500);
        }
      }
    } catch (_) {}
    try {
      await _audioPlayer.play(AssetSource('sounds/alert.mp3'));
    } catch (_) {}
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
    final prefs = await SharedPreferences.getInstance();
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
            _wController.text = '30';
          }
        }
      });
    }
  }

  void _showContinueOrResetDialog(int currentSetNum, int nextSetNum) {
    if (!mounted) return;
    final lang = globalLanguage;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0E1117),
        title: Text(
          lang == 'PL'
              ? 'Seria $currentSetNum ukończona!'
              : lang == 'NO'
                  ? 'Sett $currentSetNum fullført!'
                  : 'Set $currentSetNum completed!',
          style: const TextStyle(color: Color(0xFFFFD700)),
        ),
        content: Text(
          lang == 'PL'
              ? 'Czy chcesz rozpocząć serię $nextSetNum czy wrócić do serii 1?'
              : lang == 'NO'
                  ? 'Vil du starte sett $nextSetNum eller gå tilbake til sett 1?'
                  : 'Do you want to start set $nextSetNum or go back to set 1?',
          style: const TextStyle(color: Colors.white70),
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
                  ? 'Seria 1'
                  : lang == 'NO'
                      ? 'Sett 1'
                      : 'Set 1',
              style: const TextStyle(color: Colors.white70),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _sController.text = nextSetNum.toString();
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFD700),
              foregroundColor: const Color(0xFF0B2E5A),
            ),
            child: Text(
              lang == 'PL'
                  ? 'Seria $nextSetNum'
                  : lang == 'NO'
                      ? 'Sett $nextSetNum'
                      : 'Set $nextSetNum',
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
      reps: _isTimeBased ? _restController.text : _rController.text,
      durationSeconds:
          _isTimeBased ? (int.tryParse(_tController.text) ?? 0) : 0,
      plannedTime: _isTimeBased ? _wController.text : null,
      exercise: widget.exerciseName,
    );
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList('history_${widget.exerciseName}') ?? [];
    data.add(jsonEncode(log.toJson()));
    await prefs.setStringList('history_${widget.exerciseName}', data);

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

    if (currentSetNum == 3) {
      _showContinueOrResetDialog(3, 4);
    } else if (currentSetNum == 4) {
      _showContinueOrResetDialog(4, 5);
    } else {
      // For other sets, just increment
      setState(() {
        _sController.text = (currentSetNum + 1).toString();
      });
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
    final accent = widget.themeColor;
    return ValueListenableBuilder<String>(
        valueListenable: globalLanguageNotifier,
        builder: (context, lang, _) {
          final last = _history.isNotEmpty ? _history.last : null;
          final String lastText;
          if (last == null) {
            lastText = Translations.get('no_history', language: lang);
          } else {
            final value = last.durationSeconds > 0
                ? (last.reps.isNotEmpty
                    ? "${last.durationSeconds}s | ${lang == 'PL' ? 'Przerwa' : lang == 'NO' ? 'Pause' : 'Rest'}: ${last.reps}s"
                    : "${last.durationSeconds}s")
                : "${last.weight} kg x ${last.reps}";
            lastText = Translations.withParams('last_entry',
                language: lang, params: {'value': value});
          }
          final pauseResumeLabel = _isTimerRunning
              ? Translations.get('timer_pause', language: lang)
              : Translations.get('timer_resume', language: lang);

          return Scaffold(
            appBar: buildCustomAppBar(context, accentColor: accent),
            body: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/tlo.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    Expanded(
                      child: RawScrollbar(
                        thumbColor: const Color(0xFFFFD700),
                        radius: const Radius.circular(8),
                        thickness: 6,
                        thumbVisibility: true,
                        child: ListView(
                          padding: const EdgeInsets.fromLTRB(16, 10, 16, 140),
                          children: [
                            ProgressChart(
                                history: _history,
                                accentColor: accent,
                                title: '',
                                language: lang),
                            const SizedBox(height: 10),
                            Card(
                              color: const Color(0xFF0B2E5A)
                                  .withValues(alpha: 0.5),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  side: BorderSide(
                                      color: accent.withValues(alpha: 0.2))),
                              child: Padding(
                                padding: const EdgeInsets.all(14),
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
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        IconButton(
                                          onPressed: _isTimerRunning
                                              ? null
                                              : () {
                                                  setState(() {
                                                    if (_totalRestSeconds >
                                                        10) {
                                                      _totalRestSeconds -= 10;
                                                      if (_isTimeBased) {
                                                        _wController.text =
                                                            _totalRestSeconds
                                                                .toString();
                                                      }
                                                    }
                                                  });
                                                },
                                          icon: const Icon(Icons.remove_circle,
                                              size: 40),
                                          color: const Color(0xFFFFD700),
                                          disabledColor: Colors.grey,
                                          style: IconButton.styleFrom(
                                            foregroundColor:
                                                const Color(0xFFFFD700),
                                            disabledForegroundColor:
                                                Colors.grey,
                                          ),
                                        ),
                                        const SizedBox(width: 20),
                                        Text(
                                          '${_totalRestSeconds}s',
                                          style: const TextStyle(
                                              color: Color(0xFFFFD700),
                                              fontSize: 28,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(width: 20),
                                        IconButton(
                                          onPressed: _isTimerRunning
                                              ? null
                                              : () {
                                                  setState(() {
                                                    if (_totalRestSeconds <
                                                        600) {
                                                      _totalRestSeconds += 10;
                                                      if (_isTimeBased) {
                                                        _wController.text =
                                                            _totalRestSeconds
                                                                .toString();
                                                      }
                                                    }
                                                  });
                                                },
                                          icon: const Icon(Icons.add_circle,
                                              size: 40),
                                          color: const Color(0xFFFFD700),
                                          disabledColor: Colors.grey,
                                          style: IconButton.styleFrom(
                                            foregroundColor:
                                                const Color(0xFFFFD700),
                                            disabledForegroundColor:
                                                Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
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
                                            activeThumbColor:
                                                const Color(0xFFFFD700),
                                            activeTrackColor:
                                                const Color(0xFFFFD700)
                                                    .withValues(alpha: 0.5),
                                            inactiveThumbColor:
                                                const Color(0xFFFFD700),
                                            inactiveTrackColor:
                                                const Color(0xFFFFD700)
                                                    .withValues(alpha: 0.3)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Card(
                              color: const Color(0xFF0B2E5A)
                                  .withValues(alpha: 0.5),
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
                                              style: const TextStyle(
                                                  color: Color(0xFFFFD700)),
                                              decoration: InputDecoration(
                                                  labelText: Translations.get(
                                                          'set_label',
                                                          language: lang)
                                                      .toUpperCase(),
                                                  labelStyle: const TextStyle(
                                                      color: Color(0xFFFFD700)),
                                                  enabledBorder:
                                                      const OutlineInputBorder(
                                                          borderSide: BorderSide(
                                                              color: Color(
                                                                  0xFFFFD700),
                                                              width: 2)),
                                                  focusedBorder:
                                                      const OutlineInputBorder(
                                                          borderSide: BorderSide(
                                                              color: Color(
                                                                  0xFFFFD700),
                                                              width: 2)),
                                                  border:
                                                      const OutlineInputBorder()),
                                              keyboardType:
                                                  TextInputType.number,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: TextField(
                                              controller: _wController,
                                              style: const TextStyle(
                                                  color: Color(0xFFFFD700)),
                                              decoration: InputDecoration(
                                                  labelText: lang == 'PL'
                                                      ? 'CZAS (s)'
                                                      : lang == 'NO'
                                                          ? 'TID (s)'
                                                          : 'TIME (s)',
                                                  labelStyle: const TextStyle(
                                                      color: Color(0xFFFFD700)),
                                                  hintText: lang == 'PL'
                                                      ? 'np. 30'
                                                      : lang == 'NO'
                                                          ? 'f.eks. 30'
                                                          : 'e.g. 30',
                                                  enabledBorder:
                                                      const OutlineInputBorder(
                                                          borderSide: BorderSide(
                                                              color: Color(
                                                                  0xFFFFD700),
                                                              width: 2)),
                                                  focusedBorder:
                                                      const OutlineInputBorder(
                                                          borderSide: BorderSide(
                                                              color: Color(
                                                                  0xFFFFD700),
                                                              width: 2)),
                                                  border:
                                                      const OutlineInputBorder()),
                                              keyboardType:
                                                  TextInputType.number,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: TextField(
                                              controller: _restController,
                                              style: const TextStyle(
                                                  color: Color(0xFFFFD700)),
                                              decoration: InputDecoration(
                                                  labelText: lang == 'PL'
                                                      ? 'PRZERWA (s)'
                                                      : lang == 'NO'
                                                          ? 'PAUSE (s)'
                                                          : 'REST (s)',
                                                  labelStyle: const TextStyle(
                                                      color: Color(0xFFFFD700)),
                                                  hintText: lang == 'PL'
                                                      ? 'np. 60'
                                                      : lang == 'NO'
                                                          ? 'f.eks. 60'
                                                          : 'e.g. 60',
                                                  enabledBorder:
                                                      const OutlineInputBorder(
                                                          borderSide: BorderSide(
                                                              color: Color(
                                                                  0xFFFFD700),
                                                              width: 2)),
                                                  focusedBorder:
                                                      const OutlineInputBorder(
                                                          borderSide: BorderSide(
                                                              color: Color(
                                                                  0xFFFFD700),
                                                              width: 2)),
                                                  border:
                                                      const OutlineInputBorder()),
                                              keyboardType:
                                                  TextInputType.number,
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
                                            child: OutlinedButton.icon(
                                              onPressed: _setStart == null
                                                  ? _startSetStopwatch
                                                  : null,
                                              icon: const Icon(Icons.play_arrow,
                                                  color: Color(0xFFFFD700),
                                                  size: 18),
                                              label: const Text('PLAY',
                                                  style: TextStyle(
                                                      color: Color(0xFFFFD700),
                                                      fontSize: 13)),
                                              style: OutlinedButton.styleFrom(
                                                backgroundColor:
                                                    const Color(0xFF0B2E5A),
                                                side: const BorderSide(
                                                  color: Color(0xFFFFD700),
                                                  width: 2,
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 8),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: OutlinedButton.icon(
                                              onPressed: _setStart != null
                                                  ? _stopSetStopwatch
                                                  : null,
                                              icon: const Icon(Icons.stop,
                                                  color: Color(0xFFFFD700),
                                                  size: 18),
                                              label: const Text('STOP',
                                                  style: TextStyle(
                                                      color: Color(0xFFFFD700),
                                                      fontSize: 13)),
                                              style: OutlinedButton.styleFrom(
                                                backgroundColor:
                                                    const Color(0xFF0B2E5A),
                                                side: const BorderSide(
                                                  color: Color(0xFFFFD700),
                                                  width: 2,
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 8),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: OutlinedButton.icon(
                                              onPressed: _resetSetStopwatch,
                                              icon: const Icon(Icons.refresh,
                                                  color: Color(0xFFFFD700),
                                                  size: 18),
                                              label: const Text('RESET',
                                                  style: TextStyle(
                                                      color: Color(0xFFFFD700),
                                                      fontSize: 13)),
                                              style: OutlinedButton.styleFrom(
                                                backgroundColor:
                                                    const Color(0xFF0B2E5A),
                                                side: const BorderSide(
                                                  color: Color(0xFFFFD700),
                                                  width: 2,
                                                ),
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
                                          style: const TextStyle(
                                              color: Color(0xFFFFD700),
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ] else ...[
                                      Row(
                                        children: [
                                          SizedBox(
                                            width: 82,
                                            child: TextField(
                                              controller: _sController,
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                  color: Color(0xFFFFD700)),
                                              decoration: InputDecoration(
                                                  labelText: Translations.get(
                                                          'set_label',
                                                          language: lang)
                                                      .toUpperCase(),
                                                  labelStyle: const TextStyle(
                                                      color: Color(0xFFFFD700)),
                                                  enabledBorder:
                                                      const OutlineInputBorder(
                                                          borderSide: BorderSide(
                                                              color: Color(
                                                                  0xFFFFD700),
                                                              width: 2)),
                                                  focusedBorder:
                                                      const OutlineInputBorder(
                                                          borderSide: BorderSide(
                                                              color: Color(
                                                                  0xFFFFD700),
                                                              width: 2)),
                                                  border:
                                                      const OutlineInputBorder()),
                                              keyboardType:
                                                  TextInputType.number,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: TextField(
                                              controller: _wController,
                                              style: const TextStyle(
                                                  color: Color(0xFFFFD700)),
                                              decoration: InputDecoration(
                                                  labelText: Translations.get(
                                                          'kg_label',
                                                          language: lang)
                                                      .toUpperCase(),
                                                  labelStyle: const TextStyle(
                                                      color: Color(0xFFFFD700)),
                                                  enabledBorder:
                                                      const OutlineInputBorder(
                                                          borderSide: BorderSide(
                                                              color: Color(
                                                                  0xFFFFD700),
                                                              width: 2)),
                                                  focusedBorder:
                                                      const OutlineInputBorder(
                                                          borderSide: BorderSide(
                                                              color: Color(
                                                                  0xFFFFD700),
                                                              width: 2)),
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
                                              style: const TextStyle(
                                                  color: Color(0xFFFFD700)),
                                              decoration: InputDecoration(
                                                  labelText: Translations.get(
                                                          'reps_label',
                                                          language: lang)
                                                      .toUpperCase(),
                                                  labelStyle: const TextStyle(
                                                      color: Color(0xFFFFD700)),
                                                  enabledBorder:
                                                      const OutlineInputBorder(
                                                          borderSide: BorderSide(
                                                              color: Color(
                                                                  0xFFFFD700),
                                                              width: 2)),
                                                  focusedBorder:
                                                      const OutlineInputBorder(
                                                          borderSide: BorderSide(
                                                              color: Color(
                                                                  0xFFFFD700),
                                                              width: 2)),
                                                  border:
                                                      const OutlineInputBorder()),
                                              keyboardType:
                                                  TextInputType.number,
                                            ),
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
                                            color: Color(0xFF0B2E5A)),
                                        label: Text(
                                            Translations.get('save_set',
                                                language: lang),
                                            style: const TextStyle(
                                                color: Color(0xFF0B2E5A),
                                                fontWeight: FontWeight.w800)),
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                const Color(0xFFFFD700),
                                            foregroundColor:
                                                const Color(0xFF0B2E5A),
                                            minimumSize: const Size(
                                                double.infinity, 48)),
                                      ),
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
                              ..._history.reversed.map((log) {
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
                                      leading: CircleAvatar(
                                          backgroundColor: accent,
                                          child: Text(log.sets,
                                              style: const TextStyle(
                                                  color: Color(0xFFFFD700)))),
                                      title: Text(displayText,
                                          style: const TextStyle(
                                              color: Color(0xFFFFD700),
                                              fontWeight: FontWeight.bold)),
                                      subtitle: Text(log.date,
                                          style: const TextStyle(
                                              color: Color(0xFFFFD700))),
                                    ),
                                  ),
                                );
                              }),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            bottomNavigationBar: Container(
              height: 120,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                boxShadow: [
                  BoxShadow(
                      color: const Color(0xFF0B2E5A).withValues(alpha: 0.5),
                      blurRadius: 8)
                ],
                border: const Border(top: BorderSide(color: Colors.white10)),
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
                          icon:
                              _isTimerRunning ? Icons.pause : Icons.play_arrow,
                          color: const Color(0xFFFFD700),
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
                          color: const Color(0xFFFFD700),
                          onPressed: _resetTimer,
                        ),
                        const SizedBox(width: 8),
                        _SmallIconButton(
                          tooltip: Translations.get('stop', language: lang),
                          icon: Icons.stop,
                          color: Colors.redAccent,
                          onPressed: _stopTimer,
                        ),
                        const SizedBox(width: 14),
                        Flexible(
                          child: Column(
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
                                      color: Color(0xFFFFD700),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12)),
                              const SizedBox(height: 4),
                              Text(
                                  Translations.get('rest_label',
                                      language: lang),
                                  style: const TextStyle(
                                      color: Color(0xFFFFD700), fontSize: 11)),
                              Text('${_totalRestSeconds}s',
                                  style: const TextStyle(
                                      color: Color(0xFFFFD700), fontSize: 11)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD700),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                            color:
                                const Color(0xFFFFD700).withValues(alpha: 0.6),
                            blurRadius: 24,
                            offset: const Offset(0, 8)),
                        BoxShadow(
                            color:
                                const Color(0xFF0B2E5A).withValues(alpha: 0.5),
                            blurRadius: 12,
                            offset: const Offset(0, 4))
                      ],
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                              _isTimerRunning
                                  ? Icons.pause_circle_filled
                                  : Icons.play_circle_filled,
                              color: const Color(0xFF0B2E5A),
                              size: 40),
                          const SizedBox(height: 8),
                          Text(
                            _secondsRemaining > 0
                                ? _formatTime(_secondsRemaining)
                                : _formatTime(_totalRestSeconds),
                            style: const TextStyle(
                                color: Color(0xFF0B2E5A),
                                fontWeight: FontWeight.w900,
                                fontSize: 24,
                                letterSpacing: 1.2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
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
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF0B2E5A),
            const Color(0xFF0E3D8C),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.9), width: 1.5),
        boxShadow: [
          BoxShadow(
              color: color.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 3))
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onPressed,
          child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Icon(icon, size: 22, color: color)),
        ),
      ),
    );
  }
}
