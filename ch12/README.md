# 第12章の練習用ファイル

| ファイル | 中身 |
|---|---|
| employees.csv | まとめて登録する社員22人（架空の名前）。最後の1行は、わざと部署を「総務」と書き間違えてある |
| add-users.ps1 | employees.csv を読んで、社員の OU に登録し、部署のグループ（G-営業部など）に入れる |
| leavers.csv | まとめて無効にする2人のユーザー名 |
| commands.txt | 第12章で打つコマンドの一覧。ブラウザーで開いてコピーし、DC01 の PowerShell に貼り付ける |
| disable-users.ps1 | leavers.csv の人のアカウントを無効にする。必ず先に -WhatIf を付けて実行する |

DC01 の C:\work に置き、［管理者として実行］で開いた Windows PowerShell で `cd C:\work` してから実行します。
スクリプト（.ps1）は「UTF-8（BOM 付き）」で保存してあります。BOM が無いと、Windows PowerShell 5.1 は日本語を読み違えて動きません。
