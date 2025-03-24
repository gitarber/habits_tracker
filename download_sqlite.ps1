$baseUrl = "https://github.com/tekartik/sqflite/raw/master/packages_web/sqflite_common_ffi_web/lib/src/worker"
$files = @("sqlite3.js", "worker.sql-wasm.js", "sql-wasm.wasm")
$targetDir = "web/sqlite3"

foreach ($file in $files) {
    $url = "$baseUrl/$file"
    $output = "$targetDir/$file"
    Write-Host "Downloading $file..."
    Invoke-WebRequest -Uri $url -OutFile $output
}

Write-Host "Done!" 