# Foxtopia

Foxtopia, Godot 4 ile geliştirilen küçük ölçekli, 2D bir koloni simülasyonu prototipidir. İnsan kolonistler 50×50 yerleşke haritalarında kaynak toplar, inşa eder, araştırma yapar ve olaylara tepki verir.

## Oyna

Windows kurulum paketi `dist/Foxtopia-Setup-v0.1.4.exe` olarak üretilir. Kurulum hedefi `%LOCALAPPDATA%\KlausennGames\common\Foxtopia` olur. Oyun **Foxtopia** kısayolundan açıldığında başlatıcı her seferinde GitHub Releases üzerinde güncelleme arar; yayımlanmış yeni sürümü aynı kurulum içinde indirip doğrular. Kurulum, başlatıcı, masaüstü kısayolu ve oyun penceresi aynı özgün tilki simgesini kullanır.

Geliştirme sırasında Godot 4.7 ile `game/project.godot` açılabilir. Ana sahne `game/scenes/main.tscn` dosyasıdır.

## İlk sürüm kapsamı

- Senaryo, anlatıcı, zorluk ve dünya ayarları; seed ile döndürülebilen gezegen, ayrıntılı yerleşke bilgisi ve oynanacak 50×50 haritadan üretilen önizleme.
- Tek oyunculu, ortak koloni ve ayrı kolonilerle çok oyunculu oturum hazırlığı.
- Koloni başına 1–3 kolonist; EdB Prepare Carefully'den esinlenen ayrı karakter, ilişki ve ekipman hazırlama ekranları. Yaş, geçmiş, görünüş, özellik, sağlık ve beceriler düzenlenebilir; isteğe bağlı puan sınırı ile ekip/karakter hazır ayarları vardır.
- İhtiyaçlar, sağlık, iş öncelikleri 0–9, emir öncelikleri 1–9, günlük çalışma/uyku planı ve seçili koloniste doğrudan komutlar.
- Odun, taş, yiyecek; inşa, araştırma, düşman baskınları ve dost ticaret kervanları.
- Aynı sunucudaki koloniler arası ticaret; ayrı yerleşke haritalarında oynama.

Sunucu oyun durumunu yönetir. Rekabetçi modda oyuncular yalnızca kendi kolonilerinin özel harita, kişi, kaynak, araştırma ve emir verilerini alır. Ayrıntılı model sözleşmesi [game/scripts/model/API.md](game/scripts/model/API.md), Windows paketleme ve güncelleme adımları [installer/README.md](installer/README.md) içindedir.

## Arayüz

Oyun tam ekran harita üzerine kuruludur. Kolonist seçimi üst çubukta ve harita üzerinde, emirler ve çalışma panelleri alt çubuktadır. Resmî RimWorld görsellerinden ve EdB hazırlık ekranından çıkarılan yerleşim ilkeleri [docs/ui-reference.md](docs/ui-reference.md) içinde kayıtlıdır. Foxtopia'nın çizimleri ve arayüz ayrıntıları özgün üretilmiştir.

Görüntü ayarlarında dizüstü, ultrawide, 4K ve 8K boyutları ile etkin monitörün doğal çözünürlüğü bulunur. Çerçevesiz ve pencereli mod seçilen pencere boyutunu kullanır; tam ekran monitörün doğal boyutunu kullanır.

## Geliştirme ve denetim

```powershell
& .tools\godot\Godot_v4.7.2-stable_win64_console.exe --headless --path game --import --quit
& .tools\godot\Godot_v4.7.2-stable_win64_console.exe --headless --path game --script res://tests/ui_smoke.gd
./scripts/test-updater.ps1
```

Windows dağıtımı için Godot dışa aktarım şablonları, .NET 8 SDK ve Inno Setup 6 gerekir. Proje içindeki `.tools` ve `dist` klasörleri yerel derleme çıktılarıdır; Git'e eklenmez.
