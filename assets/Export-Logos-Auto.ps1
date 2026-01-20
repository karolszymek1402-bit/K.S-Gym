# Export-Logos-Auto.ps1
# Automatyczny eksport PNG + favicon z pliku SVG (Inkscape + ImageMagick)
# Jak używać: dostosuj $inputSvg (albo zostaw - skrypt zapyta), uruchom w PowerShell:
# powershell -ExecutionPolicy Bypass -File .\Export-Logos-Auto.ps1

# ======= Ustawienia (zmień tylko jeśli chcesz stałą ścieżkę) =======
# Domyślny plik SVG (jeśli pusty, skrypt zapyta)
$inputSvg = "C:\Programowanie\silownia_app\assets\ks_gym_logo_circle.svg"

# Rozmiary PNG do wygenerowania
$sizes = @(2048,1024,512,256)

# ======= Funkcje pomocnicze =======
function Find-Executable($name, $searchPaths) {
    $cmd = Get-Command $name -ErrorAction SilentlyContinue
    if ($cmd) { return $cmd.Source }
    foreach ($p in $searchPaths) {
        try {
            $found = Get-ChildItem $p -Recurse -Filter "$name.exe" -ErrorAction SilentlyContinue | Select-Object -First 1
            if ($found) { return $found.FullName }
        } catch {}
    }
    return $null
}

# ======= Znajdź inkscape i magick (ImageMagick) automatycznie =======
$likelyPaths = @(
    "C:\Program Files\Inkscape\bin",
    "C:\Program Files\Inkscape",
    "C:\Program Files (x86)\Inkscape",
    "C:\Program Files\ImageMagick*",
    "C:\Program Files\ImageMagick-7*",
    "C:\Program Files (x86)\ImageMagick*"
)

$inkscape = Find-Executable -name "inkscape" -searchPaths $likelyPaths
$magick  = Find-Executable -name "magick"  -searchPaths $likelyPaths

# Jeśli nie ustawiono $inputSvg lub plik nie istnieje — zapytaj użytkownika
if (-not $inputSvg -or -not (Test-Path $inputSvg)) {
    $inputSvg = Read-Host "Podaj pełną ścieżkę do pliku SVG (np. C:\...\ks_gym_logo_circle.svg)"
    if (-not (Test-Path $inputSvg)) {
        Write-Error "Plik SVG nie istnieje: $inputSvg`nPrzerwanie."
        exit 1
    }
}

# Jeśli nie znaleziono inkscape, zapytaj o ścieżkę
if (-not $inkscape -or -not (Test-Path $inkscape)) {
    Write-Warning "Nie znaleziono inkscape w PATH ani w typowych lokalizacjach."
    $try = Read-Host "Podaj pełną ścieżkę do inkscape.exe (lub naciśnij Enter by kontynuować bez Inkscape)"
    if ($try) {
        if (Test-Path $try) { $inkscape = $try } else { Write-Error "Nie znaleziono pliku pod podaną ścieżką: $try"; exit 1 }
    } else {
        Write-Error "Inkscape jest wymagany do eksportu PNG. Zainstaluj inkscape lub podaj ścieżkę."
        exit 1
    }
}

# Jeśli magick nie znaleziony — oznacz jako brakujący, ale kontynuuj (wyeksportujemy PNGy; favicon pominie)
$haveMagick = $false
if ($magick -and (Test-Path $magick)) {
    $haveMagick = $true
} else {
    Write-Warning "ImageMagick (magick.exe) nie znaleziono. Favicon .ico nie zostanie utworzone automatycznie."
    $ans = Read-Host "Jeśli chcesz, podaj pełną ścieżkę do magick.exe (lub Enter by pominąć)"
    if ($ans) {
        if (Test-Path $ans) { $magick = $ans; $haveMagick = $true } else { Write-Warning "Nie znaleziono magick pod: $ans (pominieto)"; $haveMagick = $false }
    }
}

# Wyjściowy katalog = katalog pliku SVG
$outdir = Split-Path -Parent $inputSvg
Write-Host "Wejście: $inputSvg"
Write-Host "Wyjście: $outdir"
Write-Host "Inkscape: $inkscape"
if ($haveMagick) { Write-Host "ImageMagick: $magick" } else { Write-Host "ImageMagick: brak (favicon pominięty)" }

# ======= Eksport PNG dla zadanych rozmiarów =======
foreach ($s in $sizes) {
    $out = Join-Path $outdir ("ks_gym_logo_{0}.png" -f $s)
    Write-Host "Eksport: $s x $s -> $out"
    & $inkscape $inputSvg -w $s -h $s --export-filename="$out"
    if ($LASTEXITCODE -ne 0) { Write-Warning "Inkscape zwrócił kod błędu przy eksporcie $s"; }
}

# ======= Favicon (jeśli magick jest dostępny) =======
$png64 = Join-Path $outdir "ks_gym_logo_64.png"
Write-Host "Tworzenie PNG 64x64 -> $png64"
& $inkscape $inputSvg -w 64 -h 64 --export-filename="$png64"

if ($haveMagick) {
    $icoOut = Join-Path $outdir "ks_gym_favicon.ico"
    Write-Host "Tworzenie favicon.ico -> $icoOut"
    # używamy magick (nowa składnia)
    & $magick convert $png64 -define icon:auto-resize=64,48,32,16 $icoOut
    if ($LASTEXITCODE -eq 0) { Write-Host "Favicon utworzony: $icoOut" } else { Write-Warning "Błąd przy tworzeniu faviconu (ImageMagick)" }
} else {
    Write-Warning "ImageMagick nie wykryty — favicon nie utworzony. Możesz użyć online convertera lub zainstalować ImageMagick."
}

Write-Host "Gotowe. Sprawdź katalog: $outdir"