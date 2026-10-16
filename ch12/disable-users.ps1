# 第12章　leavers.csv の社員のアカウントをまとめて無効にする
# 使い方: .\disable-users.ps1 -WhatIf  （まず件数と名前を確かめる）
#         .\disable-users.ps1          （本当に無効にする）
param([switch]$WhatIf)

Import-Csv -Path .\leavers.csv -Encoding UTF8 | ForEach-Object {
  $u = Get-ADUser -Identity $_.ユーザー名
  Disable-ADAccount -Identity $u -WhatIf:$WhatIf
  if (-not $WhatIf) { "無効にしました: $($u.Name)" }
}
