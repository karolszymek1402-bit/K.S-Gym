# run_save_svgs.ps1 - zapisze 4 SVG do folderu assets (nie wymaga admin)
New-Item -Path .\assets -ItemType Directory -Force | Out-Null

@"
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512" width="512" height="512">
  <rect width="100%" height="100%" fill="none"/>
  <g transform="translate(50,50)" fill="#000">
    <path d="M40 20 L40 220 L68 220 L68 140 L120 220 L156 220 L88 120 L156 20 L120 20 L68 100 L68 20 Z" />
  </g>
  <g fill="#000" transform="translate(0,260)">
    <rect x="24" y="36" width="464" height="16" rx="8"/>
    <rect x="0" y="16" width="24" height="56" rx="6"/>
    <rect x="488" y="16" width="24" height="56" rx="6"/>
  </g>
  <g transform="translate(300,60)" fill="#000">
    <text x="0" y="180" font-family="Roboto, Arial, sans-serif" font-weight="700" font-size="46">K.S‑GYM</text>
  </g>
</svg>
"@ | Out-File -FilePath .\assets\ks_gym_monogram_barbell.svg -Encoding utf8

@"
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512" width="512" height="512">
  <rect width="100%" height="100%" fill="none"/>
  <g transform="translate(56,56)">
    <rect x="0" y="0" width="400" height="400" rx="48" fill="none" stroke="#000" stroke-width="6"/>
    <rect x="36" y="188" width="328" height="36" rx="18" fill="#000"/>
    <text x="200" y="140" text-anchor="middle" fill="#fff" font-family="Roboto, Arial, sans-serif" font-weight="800" font-size="120">KS</text>
    <text x="200" y="340" text-anchor="middle" fill="#000" font-family="Roboto, Arial, sans-serif" font-weight="700" font-size="22">K.S‑GYM</text>
  </g>
</svg>
"@ | Out-File -FilePath .\assets\ks_gym_negative_space.svg -Encoding utf8

@"
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512" width="512" height="512">
  <rect width="100%" height="100%" fill="none"/>
  <g transform="translate(0,0)">
    <path d="M130 260 C60 180, 60 120, 130 80" fill="none" stroke="#000" stroke-width="10" stroke-linecap="round"/>
    <path d="M382 260 C452 180, 452 120, 382 80" fill="none" stroke="#000" stroke-width="10" stroke-linecap="round"/>
    <circle cx="256" cy="180" r="88" fill="none" stroke="#000" stroke-width="8"/>
    <g transform="translate(150,175)">
      <rect x="0" y="-6" width="212" height="12" rx="6" fill="#000"/>
      <rect x="-24" y="-18" width="24" height="48" rx="6" fill="#000"/>
      <rect x="212" y="-18" width="24" height="48" rx="6" fill="#000"/>
    </g>
    <text x="256" y="210" text-anchor="middle" fill="#000" font-family="Georgia, serif" font-weight="700" font-size="72">KS</text>
    <text x="256" y="320" text-anchor="middle" fill="#000" font-family="Roboto, Arial, sans-serif" font-weight="700" font-size="24">K.S‑GYM</text>
  </g>
</svg>
"@ | Out-File -FilePath .\assets\ks_gym_crest_laurel.svg -Encoding utf8

@"
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 800 200" width="800" height="200">
  <rect width="100%" height="100%" fill="none"/>
  <g transform="translate(0,40)">
    <g transform="translate(20,20)" fill="#000">
      <rect x="0" y="52" width="140" height="12" rx="6"/>
      <rect x="-20" y="34" width="20" height="40" rx="4"/>
      <rect x="140" y="34" width="20" height="40" rx="4"/>
      <rect x="-36" y="44" width="36" height="28" rx="6"/>
      <rect x="164" y="44" width="36" height="28" rx="6"/>
    </g>
    <text x="220" y="90" fill="#000" font-family="Montserrat, Roboto, Arial" font-weight="800" font-size="64">K.S‑GYM</text>
    <text x="220" y="130" fill="#000" font-family="Montserrat, Roboto, Arial" font-weight="400" font-size="18">Strength • Progress • Repeat</text>
  </g>
</svg>
"@ | Out-File -FilePath .\assets\ks_gym_wordmark_bar.svg -Encoding utf8

Write-Output "Zapisano SVG w folderze assets. Otwieram folder..."
Start-Process -FilePath (Resolve-Path .\assets)