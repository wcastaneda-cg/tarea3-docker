param(
  [Parameter(Mandatory = $true)][string]$DockerHubUser,
  [string]$Version = "1.0.0",
  [string]$BitcoinVersion = "31.1"
)
$ErrorActionPreference = "Stop"
$repository = "$DockerHubUser/bitcoin-core"
$localBuild = "bitcoin-core:task2-build"
docker build --build-arg "BITCOIN_VERSION=$BitcoinVersion" -t $localBuild .
docker tag $localBuild "${repository}:$Version"
docker tag $localBuild "${repository}:latest"
docker push "${repository}:$Version"
docker push "${repository}:latest"
Write-Host "Publicadas: ${repository}:$Version y ${repository}:latest"
