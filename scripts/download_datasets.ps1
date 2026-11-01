$ErrorActionPreference = "Stop"

$DataDir = Join-Path $PSScriptRoot "..\data"
New-Item -ItemType Directory -Force -Path $DataDir | Out-Null

function Download-And-Extract($Name) {
    $GzPath = Join-Path $DataDir "$Name.tsv.gz"
    $TsvPath = Join-Path $DataDir "$Name.tsv"
    $Url = "https://datasets.imdbws.com/$Name.tsv.gz"

    Write-Host "Downloading $Name..."
    Invoke-WebRequest -Uri $Url -OutFile $GzPath

    Write-Host "Extracting $Name (streamed to disk)..."
    $InputStream = [System.IO.File]::OpenRead($GzPath)
    try {
        $GzipStream = [System.IO.Compression.GzipStream]::new(
            $InputStream,
            [System.IO.Compression.CompressionMode]::Decompress
        )
        try {
            $OutputStream = [System.IO.File]::Create($TsvPath)
            try { $GzipStream.CopyTo($OutputStream) }
            finally { $OutputStream.Dispose() }
        }
        finally { $GzipStream.Dispose() }
    }
    finally { $InputStream.Dispose() }

    Remove-Item $GzPath
    Write-Host "Ready: $TsvPath"
}

Download-And-Extract "title.basics"
Download-And-Extract "title.ratings"
Write-Host "Dataset files are ready. Run the import command shown in README.md."
