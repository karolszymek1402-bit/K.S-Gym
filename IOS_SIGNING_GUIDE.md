# Instrukcja podpisywania aplikacji iOS "K.S-Gym"

## Wymagania
- Apple Developer Account ($99/rok) - https://developer.apple.com/
- Bundle ID: `com.ksgym.app`

## Krok 1: Utwórz App ID w Apple Developer Portal

1. Zaloguj się na https://developer.apple.com/account
2. Przejdź do **Certificates, Identifiers & Profiles**
3. Kliknij **Identifiers** → **+** (plus)
4. Wybierz **App IDs** → Continue
5. Wybierz **App** → Continue
6. Wypełnij:
   - Description: `K.S-Gym`
   - Bundle ID: `com.ksgym.app` (Explicit)
7. Zaznacz wymagane capabilities (np. Push Notifications jeśli potrzebujesz)
8. Kliknij **Continue** → **Register**

## Krok 2: Utwórz certyfikat Distribution

1. W **Certificates, Identifiers & Profiles** → **Certificates**
2. Kliknij **+** (plus)
3. Wybierz **Apple Distribution** → Continue
4. Postępuj zgodnie z instrukcją tworzenia CSR (Certificate Signing Request):
   - Na Macu: Keychain Access → Certificate Assistant → Request a Certificate...
   - Zapisz CSR na dysk
5. Prześlij CSR i pobierz certyfikat (.cer)
6. Zainstaluj certyfikat na Macu (double-click)
7. Wyeksportuj jako .p12:
   - Keychain Access → Certificates
   - Znajdź "Apple Distribution: [Your Name]"
   - Prawy klik → Export → zapisz jako .p12 z hasłem

## Krok 3: Utwórz Provisioning Profile

1. W **Certificates, Identifiers & Profiles** → **Profiles**
2. Kliknij **+** (plus)
3. Wybierz **App Store Connect** → Continue
4. Wybierz App ID: `com.ksgym.app` → Continue
5. Wybierz swój certyfikat Distribution → Continue
6. Nazwa: `K.S-Gym App Store`
7. Kliknij **Generate** → **Download**

## Krok 4: Dodaj Secrets do GitHub

Przejdź do: https://github.com/karolszymek1402-bit/silownia-app/settings/secrets/actions

Dodaj następujące secrets:

### 1. BUILD_CERTIFICATE_BASE64
```bash
# Na Macu/Linux zamień plik .p12 na base64:
base64 -i certificate.p12 | pbcopy
# lub na Windows w PowerShell:
[Convert]::ToBase64String([IO.File]::ReadAllBytes("certificate.p12")) | Set-Clipboard
```

### 2. P12_PASSWORD
Hasło które ustawiłeś podczas eksportu certyfikatu .p12

### 3. KEYCHAIN_PASSWORD
Dowolne silne hasło (np. `MyKeychain123!`)

### 4. PROVISIONING_PROFILE_BASE64
```bash
# Na Macu/Linux:
base64 -i K_S_Gym_App_Store.mobileprovision | pbcopy
# Na Windows w PowerShell:
[Convert]::ToBase64String([IO.File]::ReadAllBytes("K_S_Gym_App_Store.mobileprovision")) | Set-Clipboard
```

### 5. CODE_SIGN_IDENTITY
```
Apple Distribution: [Your Name] ([Team ID])
```
Znajdziesz to w Keychain Access przy certyfikacie

### 6. PROVISIONING_PROFILE_NAME
```
K.S-Gym App Store
```
(nazwa profilu którą nadałeś w kroku 3)

### 7. APPLE_TEAM_ID
10-znakowy Team ID, znajdziesz w:
- Apple Developer Portal → Membership → Team ID
- lub w certyfikacie w nawiasach

## Krok 5: Uruchom build

Po dodaniu wszystkich secrets:
1. Przejdź do: https://github.com/karolszymek1402-bit/silownia-app/actions
2. Wybierz "iOS Build"
3. Kliknij "Run workflow"

Build stworzy podpisany plik .ipa który możesz:
- Przesłać do App Store Connect
- Zainstalować na urządzeniach testowych przez TestFlight

## Przesłanie do App Store

1. Pobierz plik .ipa z Artifacts w GitHub Actions
2. Użyj Transporter (Mac) lub altool do przesłania do App Store Connect
3. Lub użyj fastlane do automatyzacji

---

## Alternatywa: TestFlight bez App Store

Jeśli chcesz tylko testować na iPhone bez publikacji:

1. Zamiast "App Store Connect" profilu, wybierz "Ad Hoc"
2. Dodaj UDID swoich urządzeń testowych
3. Zainstaluj .ipa przez AltStore, Sideloadly lub podobne narzędzie
