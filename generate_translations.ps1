# Script to generate kExerciseTranslations with Polish keys
# Reads kDefaultExercises and creates a new map

$mainDartPath = "lib/main.dart"
$content = Get-Content $mainDartPath -Raw

# Extract all exercise strings with the diamond separator
$exercisePattern = "'([^']+?)\s*◆\s*([^']+?)'"
$exercises = [regex]::Matches($content, $exercisePattern)

Write-Output "Found $($exercises.Count) exercises"

$translationEntries = @()
$seen = @{}

foreach ($match in $exercises) {
    $polish = $match.Groups[1].Value.Trim()
    $english = $match.Groups[2].Value.Trim()
    
    # Skip duplicates
    if ($seen.ContainsKey($polish)) {
        continue
    }
    $seen[$polish] = $true
    
    # Create translation entry
    $entry = @"
  '$polish': {
    'PL': '$polish',
    'EN': '$english',
    'NO': '$english',
  },
"@
    $translationEntries += $entry
}

# Join all entries
$allEntries = $translationEntries -join "`n"

# Output the complete map
$output = @"
// Translations for seeded exercises across languages.
// Keys are Polish exercise names (without separator)
const Map<String, Map<String, String>> kExerciseTranslations = {
$allEntries
};
"@

Write-Output "Generated kExerciseTranslations with $($translationEntries.Count) unique exercises"
$output | Out-File -FilePath "lib/generated_translations.dart" -Encoding UTF8
Write-Output "Saved to lib/generated_translations.dart"
