# 第12章　employees.csv の社員をまとめて登録し、部署のグループに入れる
# 使い方: .\add-users.ps1 -WhatIf    （登録せずに、何をするかだけ表示する。先に必ずこちら）
#         .\add-users.ps1            （本当に登録する）
# DC01 の「管理者: Windows PowerShell」の窓で、C:\work に移ってから動かす
param([switch]$WhatIf)

if (-not $WhatIf) {
  # 初期パスワードを2回聞き、違っていたら止める
  $pw  = Read-Host -AsSecureString "初期パスワード"
  $pw2 = Read-Host -AsSecureString "初期パスワード（もう一度）"
  $a = [Runtime.InteropServices.Marshal]::PtrToStringBSTR([Runtime.InteropServices.Marshal]::SecureStringToBSTR($pw))
  $b = [Runtime.InteropServices.Marshal]::PtrToStringBSTR([Runtime.InteropServices.Marshal]::SecureStringToBSTR($pw2))
  if ($a -ne $b) { "2回のパスワードが違います。もう一度動かしてください。"; return }
}

$ok = 0; $ng = 0
foreach ($r in Import-Csv -Path .\employees.csv -Encoding UTF8) {
  $name = "$($r.姓) $($r.名)"
  try {
    # 部署の書き間違いがあれば、ここで止まる
    $group = Get-ADGroup -Identity "G-$($r.部署)" -ErrorAction Stop
    if ($WhatIf) {
      "登録します: $name（$($r.ユーザー名)、$($group.Name)）"
    } else {
      New-ADUser -Name $name -Surname $r.姓 -GivenName $r.名 -DisplayName $name `
        -SamAccountName $r.ユーザー名 -UserPrincipalName "$($r.ユーザー名)@corp.example.com" `
        -Path "OU=社員,DC=corp,DC=example,DC=com" -AccountPassword $pw `
        -ChangePasswordAtLogon $true -Enabled $true -ErrorAction Stop
      Add-ADGroupMember -Identity $group -Members $r.ユーザー名 -ErrorAction Stop
      "登録しました: $name（$($group.Name)）"
    }
    $ok++
  }
  catch [Microsoft.ActiveDirectory.Management.ADPasswordComplexityException] {
    # パスワードが決まりに合わないと、無効のアカウントだけが残るので消して止める
    Get-ADUser -LDAPFilter "(sAMAccountName=$($r.ユーザー名))" | Remove-ADUser -Confirm:$false
    "止めました: 初期パスワードがドメインの決まり（14文字以上など）に合いません。長くしてやり直してください。"
    return
  }
  catch {
    "失敗しました: $name … $($_.Exception.Message)"
    $ng++
  }
}
if ($WhatIf) { "--- 登録できる人 $ok 人、失敗 $ng 人" } else { "--- 登録した人 $ok 人、失敗 $ng 人" }
