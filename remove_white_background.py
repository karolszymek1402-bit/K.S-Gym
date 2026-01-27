from PIL import Image
import os

# Lista plików PNG do przetworzenia
png_files = [
    "assets/Gemini_Generated_Image_jwqvh7jwqvh7jwqv.png",
    "assets/Gemini_Generated_Image_vmhppkvmhppkvmhp.png",
    "assets/Gemini_Generated_Image_vmhppkvmhppkvmhp (1).png",
    "assets/Gemini_Generated_Image_vmhppkvmhppkvmhp (2).png",
    "assets/Gemini_Generated_Image_vmhppkvmhppkvmhp (3).png",
    "assets/Gemini_Generated_Image_vmhppkvmhppkvmhp (4).png",
    "assets/Gemini_Generated_Image_eammu5eammu5eamm.png",
    "assets/Gemini_Generated_Image_42ss4j42ss4j42ss.png",
    "assets/Gemini_Generated_Image_3yn3k93yn3k93yn3.png",
]

def remove_white_background(image_path, threshold=180):
    """Usuwa białe i szare tło z obrazka PNG"""
    print(f"Przetwarzam: {image_path}")
    
    # Otwórz obrazek
    img = Image.open(image_path).convert("RGBA")
    
    # Pobierz dane pikseli jako array
    pixels = img.load()
    width, height = img.size
    
    for y in range(height):
        for x in range(width):
            r, g, b, a = pixels[x, y]
            
            # Usuń białe piksele
            if r > 245 and g > 245 and b > 245:
                pixels[x, y] = (0, 0, 0, 0)
            # Usuń jasne szare (szachownica jasna)
            elif r > 220 and g > 220 and b > 220 and abs(r - g) < 20 and abs(g - b) < 20:
                pixels[x, y] = (0, 0, 0, 0)
            # Usuń ciemne szare (szachownica ciemna) - TO JEST KLUCZ
            elif r > threshold and g > threshold and b > threshold:
                if abs(r - g) < 40 and abs(g - b) < 40 and abs(r - b) < 40:
                    # To jest szarość, usuń
                    pixels[x, y] = (0, 0, 0, 0)
    
    # Zapisz z nadpisaniem
    img.save(image_path, "PNG")
    print(f"✓ Zapisano: {image_path}")

# Przetwórz wszystkie pliki
for png_file in png_files:
    if os.path.exists(png_file):
        remove_white_background(png_file, threshold=240)
    else:
        print(f"⚠ Plik nie istnieje: {png_file}")

print("\n✅ Gotowe! Wszystkie białe tła zostały usunięte.")
