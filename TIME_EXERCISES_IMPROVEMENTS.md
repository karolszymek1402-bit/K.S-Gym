# Ulepszzenia Ćwiczeń na Czas (Time-Based Exercises)

## Data: 24.01.2026

## Dokonane Zmiany

### 1. **Dodane Statystyki dla Ćwiczeń na Czas**
   - **Lokalizacja:** `ExerciseDetailScreen` - sekcja History (po liście wyników)
   - **Funkcja:** `_buildTimeBasedStats(String lang, Color accent)`
   - **Funkcjonalność:**
     - Oblicza **ŚREDNIA (AVG)** - średni czas z wszystkich pomiarów
     - Oblicza **NAJLEPIEJ (BEST)** - najdłuższy zmierzony czas
     - Oblicza **NAJGORZEJ (WORST)** - najkrótszy zmierzony czas
   - **Wyświetlanie:** Trzy karty obok siebie z wynikami w sekundach (s)
   - **Dostępne Języki:** PL, EN, NO
   - **Warunek Wyświetlania:** Tylko dla ćwiczeń na czas (`_isTimeBased == true`) i gdy historia nie jest pusta

### 2. **Ulepszone Wyświetlanie "Latest" (Ostatnie Wyniki)**
   - **Lokalizacja:** `ExerciseListScreen._load()` - metoda ładowania ostatnich wyników
   - **Zmiana:** 
     - **Przed:** `"Measured: 60s | Rest: 90s"`
     - **Teraz:** `"Planned: 30s | Measured: 60s | Rest: 90s"`
   - **Benefity:**
     - Porównanie planowanego czasu ćwiczenia z rzeczywistym pomiarem
     - Szybka ocena postępu bez otwierania szczegółów
   - **Format:** `Planned: {plannedTime}s | Measured: {durationSeconds}s | Rest: {reps}s`

### 3. **Dostosowanie Wykresu do Ćwiczeń na Czas**
   - **Lokalizacja:** `_LineChartPainter` - klasa rysująca wykres
   - **Nowy Parametr:** `isTimeBased` (flaga do sprawdzania typu ćwiczenia)
   - **Zmiana Etykiet Osi Y:**
     - **Dla ćwiczeń na czas:** Wyświetla wartości w sekundach (np. "60s", "45s")
     - **Dla ćwiczeń na wagę:** Wyświetla wartości liczbowe (np. "60", "45")
   - **Kod:**
     ```dart
     final String labelText = isTimeBased
         ? '${value.toStringAsFixed(0)}s'
         : value.toStringAsFixed(0);
     ```

### 4. **Integracja z Istniejącym Systemem**
   - Wszystkie zmiany są zgodne z istniejącym systemem
   - Nie zmieniono struktury danych (`ExerciseLog`)
   - Wariantowe wyświetlanie w zależności od typu ćwiczenia
   - Pełna obsługa wszystkich trzech języków

## Testy

### Rekomendacje Testowania:
1. ✅ **Ćwiczenie na czas:**
   - Dodaj serie ćwiczenia na czas (np. Plank)
   - Wyznacz różne czasy (np. 30s, 45s, 40s)
   - Sprawdź statystyki:
     - AVG = (30+45+40)/3 = ~38s
     - BEST = 45s (największa wartość)
     - WORST = 30s (najmniejsza wartość)
   - Sprawdź czy etykiety wykresu pokazują sekundy (30s, 45s)
   - Sprawdź czy "Latest" pokazuje: `Planned: 30s | Measured: 40s | Rest: 90s`

2. ✅ **Ćwiczenie na wagę:**
   - Upewnij się, że zwykłe ćwiczenia (np. Wyciskanie) nadal działają
   - Sprawdź czy statystyki NIE pojawiają się dla ćwiczeń na wagę
   - Sprawdź czy wykres pokazuje wartości liczbowe (bez "s")
   - Sprawdź czy "Latest" pokazuje: `60 kg x 8`

3. ✅ **Mieszane historia:**
   - Jeśli ćwiczenie ma zarówno wpisy czasowe jak i wagowe, system powinien:
     - Wyświetlać statystyki tylko dla wpisów czasowych
     - Prawidłowo wyświetlać każdy typ w historii

## Pliki Zmieniane
- [lib/main.dart](lib/main.dart)
  - Dodana funkcja `_buildTimeBasedStats()`
  - Modyfikacja `_load()` w `_ExerciseListScreenState`
  - Modyfikacja `_LineChartPainter` z nowym parametrem `isTimeBased`
  - Dodanie wyświetlania statystyk w sekcji History

## Backwards Compatibility
✅ Wszystkie zmiany są w pełni kompatybilne wstecz. Istniejące dane będą prawidłowo wyświetlane.
