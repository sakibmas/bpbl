$path = "$home"
$lpath = "$path\VpnTS-$($env:computername)-$(get-date -format yyyyMMdd-hhmm).txt"
$zpath = "$path\VpnTS-$($env:computername)-$(get-date -format yyyyMMdd-hhmm).zip"
$ldir = "C:\Program Files\OpenVPN\log"
If(Test-path $zpath) {Remove-item $zpath}
If(Test-path $lpath) {Remove-item $lpath}

nslookup myip.opendns.com resolver1.opendns.com > $lpath
tracert -h 15 -w 1 vpn.bergerbd.com >> $lpath
tracert -h 15 -w 1 vpn3.bergerbd.com >> $lpath
function Get-WuaHistory
{
 $session = (New-Object -ComObject 'Microsoft.Update.Session')
 $history = $session.QueryHistory("",0,10) | ForEach-Object {
  $Product = $_.Categories | Where-Object {$_.Type -eq 'Product'} | Select-Object -First 1 -ExpandProperty Name
  $_ | Add-Member -MemberType NoteProperty -Value $_.UpdateIdentity.UpdateId -Name UpdateId
  $_ | Add-Member -MemberType NoteProperty -Value $_.UpdateIdentity.RevisionNumber -Name RevisionNumber
  $_ | Add-Member -MemberType NoteProperty -Value $Product -Name Product -PassThru
  Write-Output $_
 }
 $history | Where-Object {![String]::IsNullOrWhiteSpace($_.title)} | select Date, Title, Product, UpdateId, RevisionNumber
}

Get-WuaHistory >> $lpath

if (test-path -Path $ldir){
 Compress-Archive -Path $ldir -DestinationPath $zpath
}

$ldir2 = "$ENV:USERPROFILE\OpenVPN\log"

if (test-path -Path $ldir2){
 Compress-Archive -Path $ldir2 -DestinationPath $zpath  -Update
}

Compress-Archive -Path $lpath -DestinationPath $zpath -Update
If(Test-path $lpath) {Remove-item $lpath}
