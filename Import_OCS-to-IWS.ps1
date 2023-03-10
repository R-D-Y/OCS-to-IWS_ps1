# Settings
$iwsUrl = "http://URL_IWS/iws/api"
$csvFilePath = "C:\data.csv" ## chemin ou sera le csv extrait de ocs
$username = "username"
$password = "password"

# Read CSV File
$csvContent = [System.IO.File]::ReadAllText($csvFilePath)

# Filter column
$csvLines = $csvContent -split "`n"
$headerLine = $csvLines[0]
$csvFields = $headerLine -split ","
$selectedFields = @("Account info : TAG1", "TAG2", "TAG3") ##il s'agit là d'un exemple
$selectedFieldIndexes = @()
foreach ($field in $selectedFields) {
    $selectedFieldIndexes += $csvFields.IndexOf($field)
}
$selectedCsvLines = @()
foreach ($line in $csvLines) {
    $lineFields = $line -split ","
    $selectedLineFields = @()
    foreach ($index in $selectedFieldIndexes) {
        $selectedLineFields += $lineFields[$index]
    } 
    $selectedCsvLines += $selectedLineFields -join ","
}

# CSV to XML
$xmlContent = "<Data>"
foreach ($line in $selectedCsvLines) {
    $xmlContent += "<Item>"
    $lineFields = $line -split ","
    foreach ($field in $lineFields) {
        $xmlContent += "<$field>$field</$field>"
    }
    $xmlContent += "</Item>"
}
$xmlContent += "</Data>"

# Request HTTP & Import XML data
$request = [System.Net.WebRequest]::Create($iwsUrl)
$request.Method = "POST"
$request.ContentType = "text/xml"
$request.Credentials = New-Object System.Net.NetworkCredential($username, $password)

# Write XML Data in the HTTP request
$requestStream = $request.GetRequestStream()
[System.IO.StreamWriter] $sw = New-Object System.IO.StreamWriter($requestStream)
$sw.Write($xmlContent)
$sw.Close()

# Send HTTP request to obtain response
$response = $request.GetResponse()

# grab HTTP Response in a text model
$responseStream = $response.GetResponseStream()
[System.IO.StreamReader] $sr = New-Object System.IO.StreamReader($responseStream)
$responseContent = $sr.ReadToEnd()
$sr.Close()

# Treatment of the response
$responseCode = $response.StatusCode
if ($responseCode -eq "200") {
    # La requête a réussi, vous pouvez traiter le contenu de la réponse ici
    Write-Output "Import effectué avec succès"
} else {
    # La requête a échoué, vous pouvez traiter les erreurs ici
    Write-Output "Erreur lors de l'import : $responseContent"
}
