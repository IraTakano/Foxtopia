# Foxtopia

Foxtopia, Godot 4 ile geliştirilen küçük ölçekli, 2D bir koloni simülasyonu prototipidir. İnsan kolonistler 50×50 yerleşke haritalarında kaynak toplar, inşa eder, araştırma yapar ve olaylara tepki verir.

## Oyna

Güncel yerel Windows kurulum paketi `dist/Foxtopia-Setup-v0.1.27.exe` dosyasıdır. Kurulum hedefi `%LOCALAPPDATA%\KlausennGames\common\Foxtopia` olur. Oyun **Foxtopia** kısayolundan açıldığında başlatıcı her seferinde [GitHub Releases](https://github.com/IraTakano/Foxtopia/releases) üzerinde yayımlanmış güncellemeleri arar. Kurulum dosyası doğrudan çalıştırılarak da denenebilir. Kurulum, başlatıcı, masaüstü kısayolu ve oyun penceresi aynı özgün tilki simgesini kullanır.

Geliştirme sırasında Godot 4.7 ile `game/project.godot` açılabilir. Ana sahne `game/scenes/main.tscn` dosyasıdır.

## Mevcut prototip

- Yeni oyunda senaryo, zorluk ve dünya ayarları; senaryoya göre 1, 2 veya 3 başlangıç kolonisti.
- 50×50 yerleşke haritasında kaynak, inşa, araştırma, iş önceliği ve doğrudan kolonist emirlerinin ilk sürümleri.
- Tek oyunculu oyunun yanında ortak veya ayrı koloni kurmaya yönelik çok oyunculu prototip.
- Kolonist hazırlama, ihtiyaç, sağlık, baskın ve ticaret sistemlerinin gelişmekte olan sürümleri.

Kolonist hazırlama ekranının kurulu v0.1.27 sürümünde kullanıcının seçtiği v0.1.19 pawn gövdesi temel alınır. Beğenilen erkek orta saç korunur; diğer model, kullanıcının Issei Hyoudou ve Kirito örnekleri doğrultusunda baş çevresinde katlı ve dağınık bir biçimle yeniden çizildi. Hazırlama portresi ve oyun içi çizim birlikte güncellendi. Yeni ezik yarası için yalnızca hafif ve orta önayarları sunulur; önceki karakter kayıtlarının değerleri korunur. FT-050 kullanıcı görsel onayı olmadan kapanmaz.

Tamamlanan, yeniden düzenlenecek ve henüz yapılmamış işleri [iş ve sorun takibi](docs/issue-tracker.md) ayrı ayrı gösterir. Buradaki kapsam özeti, o listedeki açık maddelerin tamamlandığı anlamına gelmez.

Sunucu oyun durumunu yönetir. Rekabetçi modda oyuncular yalnızca kendi kolonilerinin özel harita, kişi, kaynak, araştırma ve emir verilerini alır. Ayrıntılı model sözleşmesi [game/scripts/model/API.md](game/scripts/model/API.md), Windows paketleme ve güncelleme adımları [installer/README.md](installer/README.md) içindedir.

## Arayüz

Oyun tam ekran harita üzerine kuruludur. Kolonist seçimi üst çubukta ve harita üzerinde, emirler ve çalışma panelleri alt çubuktadır. Resmî RimWorld görsellerinden ve EdB hazırlık ekranından çıkarılan yerleşim ilkeleri [docs/ui-reference.md](docs/ui-reference.md) içinde kayıtlıdır. Foxtopia'nın çizimleri ve arayüz ayrıntıları özgün üretilmiştir.

Görüntü ayarlarında monitör seçimi, dizüstü, ultrawide, 4K ve 8K boyutları ile seçilen monitörün doğal çözünürlüğü bulunur. Çerçevesiz ve pencereli mod seçilen pencere boyutunu kullanır; tam ekran monitörün doğal boyutunu kullanır. Oyun saati kararı ve performans ölçümü [zaman ve performans notunda](docs/time-and-performance-reference.md) kayıtlıdır.

## Geliştirme ve denetim

```powershell
& .tools\godot\Godot_v4.7.2-stable_win64_console.exe --headless --path game --import --quit
& .tools\godot\Godot_v4.7.2-stable_win64_console.exe --headless --path game --script res://tests/ui_smoke.gd
./scripts/test-updater.ps1
```

Windows dağıtımı için Godot dışa aktarım şablonları, .NET 8 SDK ve Inno Setup 6 gerekir. Proje içindeki `.tools` ve `dist` klasörleri yerel derleme çıktılarıdır; Git'e eklenmez.
