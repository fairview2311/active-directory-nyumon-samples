Install-Language ja-JP -CopyToSettings
Set-SystemPreferredUILanguage ja-JP
Set-WinSystemLocale ja-JP
Set-WinHomeLocation -GeoId 122
Set-Culture ja-JP
Set-TimeZone -Id "Tokyo Standard Time"
Copy-UserInternationalSettingsToSystem -WelcomeScreen $true -NewUser $true
