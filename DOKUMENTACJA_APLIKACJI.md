# K.S-GYM - Dokumentacja Aplikacji
**Wersja:** 1.0  
**Data:** 23 stycznia 2026  
**Status:** Gotowa do dystrybucji (Android APK)

---

## 📱 Ogólny Opis
Aplikacja treningowa K.S-GYM to zaawansowana platforma do zarządzania treningami siłowymi, stworzona z myślą o trenerach personalnych i ich klientach. Umożliwia prowadzenie treningów offline oraz synchronizację planów treningowych przez Firebase Cloud.

---

## 🌍 Obsługiwane Języki
- **Polski** (PL) 🇵🇱
- **Angielski** (EN) 🇬🇧
- **Norweski** (NO) 🇳🇴

Język wybierany przy pierwszym uruchomieniu i zapisywany w preferencjach.

---

## 👥 Tryby Działania

### 1. **Tryb Offline (bez logowania)**
- Lokalne zarządzanie ćwiczeniami
- Zapisywanie serii i historii w SharedPreferences
- Statystyki i wykresy postępów
- Baza 100+ predefiniowanych ćwiczeń
- Możliwość dodawania własnych ćwiczeń
- Timery dla ćwiczeń czasowych (plank, zwis, itp.)

### 2. **Tryb Online - Klient**
- Logowanie emailem i hasłem (Firebase Auth)
- Pobieranie planu treningowego od trenera (Firestore)
- Synchronizacja postępów z chmurą
- Historia treningów zapisana online
- Kontakt z trenerem

### 3. **Tryb Online - Trener**
- Panel zarządzania klientami
- Tworzenie i edycja planów treningowych dla klientów
- Dodawanie ćwiczeń do planów z bazy lub własnych
- Konfiguracja serii, kg, powtórzeń dla każdego ćwiczenia
- Lista wszystkich klientów z dostępem do ich planów
- Możliwość zmiany hasła klienta

---

## 🎨 Interfejs Użytkownika

### **Ekran Startowy** (StartChoiceScreen)
- **Logo aplikacji** z efektami świetlnymi (neonowy blask)
- **Wybór języka**: 3 przyciski z flagami (EN/PL/NO)
- **Opcje logowania**:
  - "Zaloguj się po plan online" → LoginScreen
  - "Kontynuuj bez logowania" → CategoryScreen (offline)
- **Gradient tła**: Ciemnoniebieski (0xFF0B2E5A → 0xFF0E3D8C)
- **Grafiki fitness**: Dumbbells, kettlebells, siłownia

### **Ekran Kategorii Ćwiczeń** (CategoryScreen)
Kategorie mięśniowe z ikonami SVG:
1. 📋 **Plan** (osobisty plan treningowy)
2. 🏋️ **Klatka Piersiowa** (biceps icon)
3. 💪 **Barki** (shoulders icon)
4. 🔥 **Plecy** (back icon)
5. 💪 **Biceps**
6. 🦾 **Triceps**
7. 🦵 **Nogi** (legs icon)
8. 🏋️ **Przedramiona** (forearms icon)
9. 🔥 **Brzuch** (abs icon)
10. 📝 **Notatnik** (notes)

**Funkcje:**
- AppBar z logo, przyciskiem zmiany języka, dostępem do bazy ćwiczeń
- Dla online: przycisk kontaktu, wylogowanie
- Gradient tła z efektami fitness

### **Lista Ćwiczeń** (ExerciseListScreen)
- Wyświetlanie ćwiczeń z wybranej kategorii
- **Dla trybu offline**:
  - Dodawanie własnych ćwiczeń
  - Usuwanie ćwiczeń (długie przytrzymanie)
  - Wyszukiwarka ćwiczeń
- **Dla trybu online (klient)**:
  - Tylko odczyt ćwiczeń z planu trenera
  - Brak możliwości edycji
- Wyświetlanie ostatniej serii (kg × reps) pod nazwą ćwiczenia
- Ikona zegara ⏱️ dla ćwiczeń czasowych

### **Szczegóły Ćwiczenia** (ExerciseDetailScreen)
**Główne funkcje:**
1. **Dodawanie Serii**:
   - Input dla KG (waga) - obsługa klawiatury numerycznej
   - Input dla Powtórzeń - obsługa klawiatury numerycznej
   - Przycisk "Zapisz serię"
   - Automatyczny zapis do historii
   
2. **Ćwiczenia Czasowe** (Plank, L-sit, Zwis, itp.):
   - Przycisk przełączenia trybu: kg/reps ↔️ timer
   - Countdown timer z wibracjami
   - Powiadomienia po zakończeniu
   - Pauza/wznowienie/reset
   - Dzwięk zakończenia (opcjonalny)

3. **Historia Treningowa**:
   - Lista wszystkich zapisanych serii
   - Format: "Data - KG × Reps" lub "Data - 1:23"
   - Filtrowanie po dacie
   - Statystyki: całkowita objętość (kg × reps)
   - Wykresy postępów (wykres słupkowy)
   - Kopiowanie historii do schowka
   - Usuwanie pojedynczych serii (przesunięcie)
   - Reset wszystkich serii (opcja w menu)

4. **Przyciski Szybkiego Dostępu**:
   - Kopiowanie ostatniej serii
   - Zwiększanie/zmniejszanie kg o 2.5
   - Przełączanie trybu ćwiczenia (reps/time)

### **Baza Ćwiczeń** (ExerciseDatabaseScreen)
- **Wyszukiwarka**: Filtrowanie po nazwie
- **Kategorie**: Grupowanie ćwiczeń jak w głównym menu
- **100+ predefiniowanych ćwiczeń** z tłumaczeniami PL/EN/NO
- Dodawanie do własnej listy jednym kliknięciem
- **Własne ćwiczenia**: Możliwość tworzenia custom exercises

### **Panel Trenera** (ClientListScreen)
- **Lista wszystkich klientów** (pobierane z Firestore)
- Kliknięcie w klienta → ekran szczegółów klienta
- **Tworzenie nowego klienta**:
  - Email
  - Hasło (auto-generowane lub własne)
- **Zarządzanie planem klienta**:
  - Dodawanie ćwiczeń z bazy
  - Konfiguracja: ile serii, kg, reps
  - Usuwanie ćwiczeń z planu
  - Zmiana hasła klienta
- Wylogowanie

### **Import Planu** (PlanImportScreen)
- **Tryb trener**: Przycisk "Login as Trainer" → ClientListScreen
- **Tryb klient**: 
  - Pole email + hasło
  - Logowanie → PlanOnlineScreen
  - Podgląd planu od trenera
  - Wykonywanie treningów z synchronizacją

---

## 🗄️ Struktura Danych

### **SharedPreferences (Offline)**
Klucze:
- `app_language` - wybrany język (EN/PL/NO)
- `exercises_{category}` - lista ćwiczeń w kategorii
- `ex_type_time_{exerciseName}` - czy ćwiczenie jest czasowe (bool)
- `history_{category}_{exercise}` - JSON array historii serii
- `plan_exercises` - lista ćwiczeń w osobistym planie

### **Firestore (Online)**
Kolekcja: `clientPlans`

Struktura dokumentu:
```json
{
  "email": "klient@example.com",
  "password": "hashedPassword",
  "plan": [
    {
      "category": "Klatka",
      "exercises": [
        {
          "name": "Wyciskanie sztangi",
          "sets": 4,
          "kg": 80,
          "reps": 10,
          "isTime": false
        }
      ]
    }
  ]
}
```

---

## 🏋️ Baza Ćwiczeń

### **Predefiniowane Kategorie i Przykłady**:
1. **Klatka**: Wyciskanie sztangi, Rozpiętki, Pompki, itp.
2. **Barki**: Wyciskanie sztangielki, Arnoldy, Unoszenie bokiem
3. **Plecy**: Podciąganie, Wiosłowanie, Martwy ciąg
4. **Biceps**: Uginanie sztangi, Młotki, Koncentryczne
5. **Triceps**: Wyciskanie wąskim chwytem, Francuskie, Pompki diamentowe
6. **Nogi**: Przysiad, Wypychanie, Wypady
7. **Przedramiona**: Uginanie nadgarstków, Chwyt
8. **Brzuch**: Brzuszki, Plank, Nożyce

### **Ćwiczenia Czasowe** (13 exercises):
- Plank (Deska)
- Plank boczny
- L-sit
- Zwis na drążku
- Spacer Farmera
- Wall Sit
- Hollow Hold
- Dead Hang
- Active Hang
- Support Hold
- Ring Hold
- Flag Hold
- Handstand Hold

**Wszystkie z tłumaczeniami PL ◆ EN**

---

## 🔔 Funkcje Techniczne

### **Powiadomienia**
- Lokalskie powiadomienia (flutter_local_notifications)
- Powiadomienie po zakończeniu timera
- Android notification channel: "ks_gym_channel"

### **Audio**
- Dzwięk zakończenia timera (assets/sounds/bell.mp3 - opcjonalny)
- Biblioteka: audioplayers

### **Wibracje**
- Feedback haptyczny przy zapisywaniu serii
- Pulsacje podczas ostatnich sekund timera
- Biblioteka: vibration

### **Wykresy**
- Wykresy słupkowe postępów (CustomPaint)
- Wyświetlanie objętości treningu (kg × reps)
- Ostatnie 10 sesji z danego ćwiczenia

### **SVG Graphics**
- Ikony kategorii (flutter_svg)
- Logo aplikacji
- Dumbbells, kettlebells dekoracje

---

## 🔐 Bezpieczeństwo
- Firebase Authentication dla klientów i trenerów
- Hasła zarządzane przez Firebase (nie plain text)
- Trener może zmieniać hasła klientów przez PlanAccessController
- Firestore security rules (należy skonfigurować)

---

## 📦 Zależności

### **Główne pakiety:**
```yaml
dependencies:
  flutter:
    sdk: flutter
  firebase_core: ^3.11.0
  cloud_firestore: ^5.11.0
  firebase_auth: ^5.4.1
  shared_preferences: ^2.3.4
  flutter_local_notifications: ^18.0.1
  audioplayers: ^6.2.0
  vibration: ^2.0.0
  flutter_svg: ^2.0.16
```

### **Dev Dependencies:**
```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0
```

---

## 🛠️ Konfiguracja Build

### **Android**
- Min SDK: flutter.minSdkVersion
- Target SDK: flutter.targetSdkVersion
- Namespace: com.example.silownia_app
- Java 17 + Core Library Desugaring 2.1.4
- Gradle: Kotlin DSL (build.gradle.kts)

### **iOS**
- Deployment Target: 12.0+
- CocoaPods dependencies
- Build configuration w Runner.xcodeproj

### **Web**
- HTML renderer support
- Firebase web initialization

---

## 📊 Stan Projektu

### ✅ **Ukończone Funkcje**:
1. ✅ Wielojęzyczność (PL/EN/NO)
2. ✅ System kategorii i ćwiczeń
3. ✅ Dodawanie/usuwanie ćwiczeń
4. ✅ Zapisywanie serii z kg i reps
5. ✅ Historia treningowa z filtrowaniem
6. ✅ Wykresy postępów
7. ✅ Ćwiczenia czasowe z timerem
8. ✅ Powiadomienia i wibracje
9. ✅ Tryb offline (SharedPreferences)
10. ✅ Tryb online z Firebase
11. ✅ Panel trenera z zarządzaniem klientami
12. ✅ Import i synchronizacja planów
13. ✅ Baza 100+ ćwiczeń z tłumaczeniami
14. ✅ Gradient UI z grafikami fitness
15. ✅ Reset serii i kopiowanie historii
16. ✅ Android APK build (release)
17. ✅ GitHub Actions workflow (iOS/Android CI/CD)

### 🔄 **Możliwe Rozszerzenia**:
- 🔄 Dodanie zdjęć/filmów instruktażowych do ćwiczeń
- 🔄 Eksport historii do PDF/CSV
- 🔄 Statystyki trenera (postępy wszystkich klientów)
- 🔄 Dark mode toggle
- 🔄 Customizacja motywu kolorów
- 🔄 Integracja z Google Fit / Apple Health
- 🔄 Kalendarz treningowy
- 🔄 Social sharing (udostępnianie postępów)
- 🔄 Makra żywieniowe (opcjonalne)

---

## 🚀 Dystrybucja

### **Android**
- **APK Location**: `build/app/outputs/flutter-apk/app-release.apk`
- **Rozmiar**: ~108 MB
- **Status**: Gotowy do instalacji
- **Wymagania**: Android 5.0+ (API 21+)

### **iOS**
- Wymaga Mac z Xcode
- Alternatywnie: GitHub Actions macOS runner
- Apple Developer Account ($99/rok) dla App Store

### **Web**
- Build gotowy: `flutter build web`
- Hosting: Firebase Hosting / Netlify / Vercel

---

## 📝 Podsumowanie Techniczne

**Architektura:**
- Single-file architecture (main.dart ~5082 linii)
- Separate files: client_list_screen.dart (923 linii), plan_access.dart (383 linii)
- State management: StatefulWidget + setState
- Persistence: SharedPreferences (offline) + Firestore (online)

**Design Patterns:**
- Singleton: NotificationService, PlanAccessController
- Factory pattern: Theme builders, translation lookups
- Observer: ValueNotifier dla języka (globalLanguageNotifier)

**UI Framework:**
- Material Design 3
- Custom gradients i shadows
- SVG icons z flutter_svg
- Custom paint dla wykresów

**Backend:**
- Firebase Auth (email/password)
- Cloud Firestore (NoSQL database)
- Firestore indexes dla zapytań

---

## 📄 Licencja i Autorstwo
**Autor**: K.S-GYM Team  
**Copyright**: © 2026  
**Wersja aplikacji**: 1.0.0  

---

**Ostatnia aktualizacja dokumentacji**: 23 stycznia 2026, 07:42
**APK build status**: ✅ Sukces (Exit Code 0)
