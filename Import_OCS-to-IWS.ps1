# Définir les paramètres
$iwsUrl = "http://URL_IWS/iws/api"
$csvFilePath = "C:\data.csv" ## chemin ou sera le csv extrait de ocs
$username = "username"
$password = "password"

# Lire le contenu du fichier CSV d'ocs
$csvContent = [System.IO.File]::ReadAllText($csvFilePath)

# Filtrer les colonnes du CSV avec ce que nous souhaitons garder
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

# Formater la data de CSV vers XML
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

# Créer une requête HTTP pour l'import des données XML
$request = [System.Net.WebRequest]::Create($iwsUrl)
$request.Method = "POST"
$request.ContentType = "text/xml"
$request.Credentials = New-Object System.Net.NetworkCredential($username, $password)

# Écrire le contenu du fichier XML dans la requête HTTP
$requestStream = $request.GetRequestStream()
[System.IO.StreamWriter] $sw = New-Object System.IO.StreamWriter($requestStream)
$sw.Write($xmlContent)
$sw.Close()

# Envoyer la requête HTTP et obtenir la réponse
$response = $request.GetResponse()

# Récupérer le contenu de la réponse HTTP sous forme de texte
$responseStream = $response.GetResponseStream()
[System.IO.StreamReader] $sr = New-Object System.IO.StreamReader($responseStream)
$responseContent = $sr.ReadToEnd()
$sr.Close()

#Traitement de la réponse
$responseCode = $response.StatusCode
if ($responseCode -eq "200") {
    # La requête a réussi, vous pouvez traiter le contenu de la réponse ici
    Write-Output "Import effectué avec succès"
} else {
    # La requête a échoué, vous pouvez traiter les erreurs ici
    Write-Output "Erreur lors de l'import : $responseContent"
}
