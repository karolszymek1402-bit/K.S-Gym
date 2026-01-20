@echo off
REM Export-Logos.bat - automatyczny eksport PNG + favicon z SVG (Inkscape + ImageMagick)

REM --- Ustawienia (dostosuj jeśli potrzebne) ---
SET "SVG=C:\Programowanie\silownia_app\assets\ks_gym_logo_circle.svg"
SET "OUTDIR=C:\Programowanie\silownia_app\assets"

REM --- Spróbuj znaleźć inkscape ---
where inkscape >nul 2>&1
IF %ERRORLEVEL%==0 (
  SET "INKSCAPE=inkscape"
) ELSE (
  IF EXIST "C:\Program Files\Inkscape\bin\inkscape.exe" (
    SET "INKSCAPE=C:\Program Files\Inkscape\bin\inkscape.exe"
  ) ELSE IF EXIST "C:\Program Files\Inkscape\inkscape.exe" (
    SET "INKSCAPE=C:\Program Files\Inkscape\inkscape.exe"
  ) ELSE (
    ECHO Nie znaleziono Inkscape. Podaj pelna sciezke do inkscape.exe i naciśnij ENTER:
    SET /P INKPATH=
    IF EXIST "%INKPATH%" (
      SET "INKSCAPE=%INKPATH%"
    ) ELSE (
      ECHO Brak inkscape.exe pod podana sciezka. Przerwanie.
      PAUSE
      EXIT /B 1
    )
  )
)

REM --- Eksport PNG w rozmiarach ---
ECHO Uzycie Inkscape: %INKSCAPE%
ECHO Eksportuje PNGy do: %OUTDIR%
"%INKSCAPE%" "%SVG%" -w 2048 -h 2048 --export-filename="%OUTDIR%\ks_gym_logo_2048.png"
"%INKSCAPE%" "%SVG%" -w 1024 -h 1024 --export-filename="%OUTDIR%\ks_gym_logo_1024.png"
"%INKSCAPE%" "%SVG%" -w 512  -h 512  --export-filename="%OUTDIR%\ks_gym_logo_512.png"
"%INKSCAPE%" "%SVG%" -w 256  -h 256  --export-filename="%OUTDIR%\ks_gym_logo_256.png"

REM --- PNG 64 dla favicon ---
"%INKSCAPE%" "%SVG%" -w 64 -h 64 --export-filename="%OUTDIR%\ks_gym_logo_64.png"

REM --- Spróbuj znaleźć ImageMagick (magick) i utworzyć favicon.ico ---
where magick >nul 2>&1
IF %ERRORLEVEL%==0 (
  ECHO Tworze favicon.ico za pomoca ImageMagick...
  magick convert "%OUTDIR%\ks_gym_logo_64.png" -define icon:auto-resize=64,48,32,16 "%OUTDIR%\ks_gym_favicon.ico"
  IF %ERRORLEVEL%==0 (
    ECHO Favicon utworzony: %OUTDIR%\ks_gym_favicon.ico
  ) ELSE (
    ECHO Blad przy tworzeniu favicon (ImageMagick zwrocil blad).
  )
) ELSE (
  ECHO ImageMagick (magick) nie znaleziony. Favicon nie zostanie wygenerowany.
  ECHO Mozesz samodzielnie wygenerowac ICO na stronie np. https://favicon.io lub zainstalowac ImageMagick.
)

ECHO Gotowe. Sprawdz katalog: %OUTDIR%
PAUSE