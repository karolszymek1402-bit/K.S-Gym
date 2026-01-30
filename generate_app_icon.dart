/// Ten skrypt wymaga ręcznej konwersji SVG na PNG
/// Ponieważ Dart nie obsługuje natywnie renderowania SVG do PNG,
/// użyj jednego z poniższych sposobów:
///
/// 1. Online: https://svgtopng.com/ lub https://cloudconvert.com/svg-to-png
/// 2. Inkscape: inkscape --export-type=png --export-width=1024 mojelogo.svg
/// 3. ImageMagick: magick convert -background none -size 1024x1024 mojelogo.svg app_icon.png
///
/// Po konwersji zapisz plik jako assets/app_icon.png (1024x1024 px)
///
/// Następnie uruchom:
/// flutter pub get
/// dart run flutter_launcher_icons

void main() {
  print('=== Instrukcja generowania ikony aplikacji K.S-Gym ===');
  print('');
  print('Krok 1: Przekonwertuj assets/mojelogo.svg na PNG 1024x1024');
  print('');
  print('Opcje konwersji:');
  print('  A) Online: https://svgtopng.com/');
  print('  B) Inkscape (jeśli zainstalowany):');
  print(
      '     inkscape --export-type=png --export-width=1024 assets/mojelogo.svg -o assets/app_icon.png');
  print('  C) ImageMagick (jeśli zainstalowany):');
  print(
      '     magick convert -background none -density 300 -resize 1024x1024 assets/mojelogo.svg assets/app_icon.png');
  print('');
  print('Krok 2: Zapisz wynik jako assets/app_icon.png');
  print('');
  print('Krok 3: Uruchom generowanie ikon:');
  print('  flutter pub get');
  print('  dart run flutter_launcher_icons');
  print('');
  print('To wygeneruje ikony dla iOS, Android, Web, Windows i macOS!');
}
