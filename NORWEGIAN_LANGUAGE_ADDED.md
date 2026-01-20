# Norwegian Language Support Added

## Summary
Norwegian (Norsk) language support has been successfully added to the K.S-GYM application.

## Changes Made

### 1. Translation Dictionary (lib/main.dart)
- Added complete Norwegian translation entry ('NO') with all UI strings
- Includes translations for:
  - Body parts (BRYST, RYGG, BICEPS, etc.)
  - UI actions (Legg til, Slett, Lagre, etc.)
  - Messages and notifications
  - Exercise-related terms

### 2. Language Selection UI
#### Initial Screen (Language Selection Screen)
- Added Norwegian button to the language selection screen
- Button displays "Norsk" with the same styling as Polish and English options
- Clicking the button sets language to 'NO' and navigates to the main app

#### Settings Menu Dialog
- Added Norwegian option to the language selection dialog
- Users can switch to Norwegian from the category screen menu
- Shows a checkmark when Norwegian is selected

### 3. Translation Keys Added
Added new translation key 'norwegian': 'Norsk' to:
- Polish (PL) dictionary
- English (EN) dictionary
- Norwegian (NO) dictionary

## Language Persistence
The app uses SharedPreferences to save the selected language:
```dart
await prefs.setString('language', 'NO');
```

When users select Norwegian, it will be remembered for future app sessions.

## Available Languages
The application now supports:
1. **Polish (PL)** - Polski
2. **English (EN)** - English
3. **Norwegian (NO)** - Norsk

## Testing
To test the Norwegian language:
1. Launch the app
2. Click the "Norsk" button on the language selection screen
3. All UI elements should display in Norwegian
4. Use the menu to switch between languages

## Files Modified
- `/lib/main.dart` - Added Norwegian translations and updated UI

## Notes
- All existing functionality is preserved
- The Norwegian translations cover all existing UI strings
- The implementation follows the same pattern as Polish and English translations
