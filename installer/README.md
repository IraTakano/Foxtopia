# Windows kurulumu ve GitHub Releases güncellemeleri

Kurulum programı `FoxtopiaLauncher.exe` ve oyunun ilk sürümünü
`%LOCALAPPDATA%\KlausennGames\common\Foxtopia` içine kurar. Gerekli üst
klasörler kurulum sırasında otomatik oluşturulur. Başlat menüsü kısayolu,
isteğe bağlı masaüstü kısayolu ve kaldırıcı kurulur.

## Kurulum dosyasını oluşturma

Gerekenler: Windows, .NET 8 SDK (`.tools/dotnet/dotnet.exe` veya sistemde) ve
Inno Setup 6. `dist/game/Foxtopia.exe` ile oyunun diğer dışa aktarım dosyaları
hazır olmalıdır.

```powershell
./scripts/build-windows.ps1 -Version v0.1.1
```

Varsayılan depo `IraTakano/Foxtopia`'dır. `-Repository` ile
`https://github.com/owner/repo` biçiminde başka bir depo da verilebilir.
Çıktı: `dist/Foxtopia-Setup-v0.1.1.exe`. Yerel deneme için güncelleme
kontrolünü kapatmak gerektiğinde `-Repository ''` verilebilir.

## Güncelleme paketini hazırlama

```powershell
./scripts/create-release.ps1 -Version v0.1.1
```

Bu komut `dist/release/Foxtopia-win-x64.zip` ve
`dist/release/Foxtopia-update.json` üretir. İki dosya da **aynı** GitHub
Release'e yüklenmeli; release etiketi manifestteki sürümle aynı olmalı.
GitHub CLI ile yayımlamak için:

```powershell
./scripts/publish-release.ps1 -Version v0.1.1
```

Yayımlama komutu aynı sürümün kurulum dosyası varsa onu da Release'e ekler.
Önceden `gh auth login` ile yetkilendirme yapılmış olmalıdır.
Güncelleyici herkese açık deponun en son kararlı release'ini kullanır.

Başlatıcı her açılışta GitHub Releases'i kontrol eder. Yeni sürüm varsa arşivi
indirir, manifestteki SHA-256 özetini ve GitHub'ın asset özetini (varsa)
doğrular. Dosyalar önce ayrı bir sürüm klasörüne açılır; doğrulama ve dosya
kontrolleri tamamlanınca aktif sürüm işaretçisi değiştirilir. Kurulum programı
yeniden çalışmaz. Ağ kapalıysa veya güncelleme başarısızsa mevcut sürüm açılır.
Başlatıcı oyun kapanana kadar çalışır ve eski sürümlerin en yenisini geri dönüş
için saklar. Kaydedilmiş oyunlar kurulum klasörünün dışında tutulmalıdır.

Kısayollar `FoxtopiaLauncher.exe` dosyasını açmalıdır; `Foxtopia.exe` dosyası
doğrudan çalıştırılırsa açılış güncelleme kontrolü atlanır.

## Yerel test

```powershell
./scripts/test-updater.ps1
```

Test, yeni sürüm kurulmasını, ikinci açılışta sürümün korunmasını ve bozuk
SHA-256 nedeniyle başarısız güncellemede çalışan sürümün korunmasını sınar.
