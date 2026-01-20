# 🎯 INSTRUKCJA TESTOWANIA - Dialog po 4 Seriach

## Funkcjonalność

Po zalogowaniu czwartej serii (seria #4), aplikacja automatycznie pokazuje dialog z pytaniem czy użytkownik chce zacząć nowy cykl od serii 1.

## 🧪 Kroki Testowe

### 1. **Otwórz Aplikację**
- Uruchom aplikację: `flutter run -d chrome`
- Otwórz: http://localhost:54321

### 2. **Wybierz Język**
- Wybierz "Polski" lub "English" (dialog resetowania serii będzie w wybranym języku)

### 3. **Dodaj Ćwiczenie**
- Kliknij na kategorię (np. CHEST)
- Kliknij "+" aby dodać nowe ćwiczenie
- Wpisz nazwę lub wybierz z szablonów

### 4. **Zaloguj 4 Serie**
- Dla danego ćwiczenia zaloguj dane:
  - **Seria 1**: Waga: `50`, Powtórzenia: `10`, Seria: `1` → Kliknij "Dodaj"
  - **Seria 2**: Waga: `50`, Powtórzenia: `10`, Seria: `2` → Kliknij "Dodaj"
  - **Seria 3**: Waga: `50`, Powtórzenia: `10`, Seria: `3` → Kliknij "Dodaj"
  - **Seria 4**: Waga: `50`, Powtórzenia: `10`, Seria: `4` → Kliknij "Dodaj"

### 5. **Weryfikacja Dialogu**
Po zalogowaniu czwartej serii powinien pojawić się dialog:

#### 🇵🇱 **Po Polsku:**
```
┌─────────────────────────────────┐
│   Koniec cyklu 4 serii!         │
├─────────────────────────────────┤
│ Czy chcesz zacząć nowy cykl     │
│ od serii 1?                     │
├─────────────────────────────────┤
│  [Anuluj]          [Resetuj]    │
└─────────────────────────────────┘
```

#### 🇬🇧 **Po Angielsku:**
```
┌─────────────────────────────────┐
│   Cycle Complete!               │
├─────────────────────────────────┤
│ Do you want to start a new      │
│ cycle from set 1?               │
├─────────────────────────────────┤
│  [Cancel]           [Reset]     │
└─────────────────────────────────┘
```

### 6. **Testuj Przyciski**

#### Opcja A: Kliknij "Anuluj" / "Cancel"
- Dialog zamyka się
- Licznik serii pozostaje na `4`
- Możesz wpisać serię `5` ręcznie

#### Opcja B: Kliknij "Resetuj" / "Reset"
- Dialog zamyka się
- Licznik serii automatycznie zmienia się na `1`
- Pole serii zawiera teraz `1`
- Możesz zalogować nową serię nr 1

### 7. **Testuj Oba Języki**
- Zmień język za pomocą globe icon (🌐) w AppBar
- Powtórz kroki 3-6 z innym językiem
- Dialog powinien być w nowym języku

---

## ✅ Oczekiwane Wyniki

| Krok | Oczekiwany Rezultat | Status |
|------|---------------------|--------|
| Po serii 1, 2, 3 | Brak dialogu | ✅ |
| Po serii 4 | Dialog pojawia się | ⏳ **Do testowania** |
| Kliknięcie Anuluj | Dialog zamyka, seria = 4 | ⏳ **Do testowania** |
| Kliknięcie Resetuj | Dialog zamyka, seria = 1 | ⏳ **Do testowania** |
| Po resetzie | Możliwość zalogowania serii 1 ponownie | ⏳ **Do testowania** |
| Zmiana języka | Dialog w nowym języku | ⏳ **Do testowania** |

---

## 📝 Notatki Techniczne

### Kod Logiki
- Lokalizacja: `ExerciseDetailScreen._saveLog()` (linia ~1940)
- Sprawdzanie: `if (currentSets == 4)`
- Metoda dialogu: `_showResetSetsDialog()`
- Resetowanie: `_sController.text = '1'`

### Obsługa Języków
```dart
final isPolish = globalLanguage == 'PL';
// Dialog wyświetla się w bieżącym języku
```

### Zachowanie
- Dialog pojawia się zawsze po zalogowaniu czwartej serii
- Nie wymusza resetowania (opcjonalne)
- Użytkownik może wybrać "Anuluj" aby dalej pracować z serią 4+

---

## 🔧 Debugowanie

Jeśli dialog się nie pojawia:
1. Sprawdź czy `_sController.text` = "4"
2. Sprawdź czy `mounted` jest true
3. Sprawdź DevTools Console na błędy
4. Zrestartuj aplikację (R w terminalu)

---

*Instrukcja testowania - 2026-01-01*
