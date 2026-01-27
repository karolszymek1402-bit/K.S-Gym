from PIL import Image
import os

# Lista plików PNG do naprawienia (bez logo i tlo)
png_files = [
    "assets/barki.png",
    "assets/biceps.png",
    "assets/brzuch.png",
    "assets/klata.png",
    "assets/nogi.png",
    "assets/notes.png",
    "assets/plecy.png",
    "assets/przedramie.png",
    "assets/triceps.png",
]

def fix_transparency(image_path):
    """Usuwa TYLKO czyste białe tło, zachowując wszystkie kolory"""
    print(f"Naprawiam: {image_path}")
    
    # Otwórz obrazek
    img = Image.open(image_path).convert("RGBA")
    
    # Pobierz dane pikseli
    pixels = img.load()
    width, height = img.size
    
    for y in range(height):
        for x in range(width):
            r, g, b, a = pixels[x, y]
            
            # Usuń TYLKO czysto białe piksele (bardzo wąski zakres)
            if r >= 250 and g >= 250 and b >= 250:
                pixels[x, y] = (0, 0, 0, 0)
    
    # Zapisz
    img.save(image_path, "PNG")
    print(f"✓ Naprawiono: {image_path}")

# Przetwórz wszystkie pliki
for png_file in png_files:
    if os.path.exists(png_file):
        fix_transparency(png_file)
    else:
        print(f"⚠ Plik nie istnieje: {png_file}")

print("\n✅ Gotowe! Obrazki naprawione - zachowane oryginalne kolory.")
