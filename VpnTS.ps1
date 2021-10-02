$lpath="$home\sstp-$($env:computername)-$(get-date -format yyyyMMdd-hhmm).txt"
nslookup myip.opendns.com resolver1.opendns.com > $lpath
tracert -h 15 -w 1 sstp.bergerbd.com >> $lpath
tracert -h 15 -w 1 vpn3.bergerbd.com >> $lpath
function Get-WuaHistory
{
  # Get a WUA Session
 $session = (New-Object -ComObject 'Microsoft.Update.Session')
 $history = $session.QueryHistory("",0,50) | ForEach-Object {
  $Product = $_.Categories | Where-Object {$_.Type -eq 'Product'} | Select-Object -First 1 -ExpandProperty Name
  $_ | Add-Member -MemberType NoteProperty -Value $_.UpdateIdentity.UpdateId -Name UpdateId
  $_ | Add-Member -MemberType NoteProperty -Value $_.UpdateIdentity.RevisionNumber -Name RevisionNumber
  $_ | Add-Member -MemberType NoteProperty -Value $Product -Name Product -PassThru
  Write-Output $_
 }
 #Remove null records and only return the fields we want
 $history | Where-Object {![String]::IsNullOrWhiteSpace($_.title)} | fl Date, Title, Product, UpdateId, RevisionNumber
}

Get-WuaHistory >> $lpath