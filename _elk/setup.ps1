$ErrorActionPreference = "Stop"
$here = Split-Path $PSCommandPath -Parent

try {
	Invoke-RestMethod -Method DELETE -Uri http://localhost:9200/thedivision
}
catch {
}

Invoke-RestMethod -Method PUT -Uri http://localhost:9200/thedivision
Invoke-RestMethod -Method PUT -Uri http://localhost:9200/thedivision/item/_mapping -Body (gc -raw $here\item.json)
Invoke-RestMethod -Method PUT -Uri http://localhost:9200/thedivision/build_info/_mapping -Body (gc -raw $here\build_info.json)

$items = ConvertFrom-Json (gc -raw "$here\..\my-gear-list-with-mods.json")
foreach ($item in $items)
{
	$itemAsJson = $item | ConvertTo-Json -Compress
	Invoke-Restmethod -Method POST -Uri http://localhost:9200/thedivision/item -Body $itemAsJson
}