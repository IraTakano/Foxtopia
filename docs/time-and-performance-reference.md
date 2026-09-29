# Foxtopia: oyun saati ve performans kararı

29 Eylül 2026, v0.1.9 yerel çalışma.

## Kaynak ve davranış

- Ludeon forumundaki [Tynan Sylvester soru-cevabı](https://ludeon.com/forums/index.php?topic=109.0) duraklatma için Space tuşunu, zaman hızları için 1×, 3× ve 6× değerlerini açıklıyor. Bu, resmî geliştirici açıklaması fakat eski bir gönderi; güncel sürümün bütün ayrıntılarını tek başına doğrulamaz.
- [RimWorld Wiki zaman sayfası](https://mail.rimworldwiki.com/wiki/Day) güncel referans olarak 1× hızda saniyede 60 tick, oyun saatinde 2500 tick ve günde 60.000 tick (gerçek zamanda 16 dakika 40 saniye) veriyor. Wiki topluluk kaynağıdır, resmî Ludeon dokümanı değildir.
- Foxtopia'nın simülasyon adımı RimWorld tick'iyle bire bir aynı değil. Mevcut kayıtların ve olay aralıklarının anlamını korumak için bir oyun günü **600 Foxtopia adımı** kaldı. Kullanıcı denemesinde eski tempo yavaş bulunduğundan 1× hız saniyede **1,5 adım** oldu; bir gün yaklaşık **400 gerçek saniye** sürer. 3× yaklaşık 133 saniye, 6× yaklaşık 67 saniyedir. Hız düğmeleri 0×/1×/3×/6×. Space son seçilen hıza duraklatıp döner.
- Haritadaki hücreler arası görsel geçiş simülasyon hızına göre ölçekleniyor. Böylece hız arttığında kolonist görüntüsü eski konuma gereğinden uzun süre bağlı kalmıyor.
- Tek oyunculu Esc menüsü açılınca saat durur; kapatılınca önceki duraklama ve hız hali döner. Çok oyunculuda yerel menü diğer oyuncuların simülasyonunu durdurmaz.

## FPS ölçümü ve düzeltme

Ölçüm, bu bilgisayardaki NVIDIA GeForce RTX 2080 ile Godot 4.7.2 Compatibility/OpenGL sürücüsünde, komut dosyasının açtığı bir yerel 50×50 haritada yapıldı. Gerçek kullanıcı oturumundaki tüm aşamaların FPS garantisi olarak yorumlanmamalı. 1920×1080 için aynı görsel denemenin ortalama kare süresi statik harita katmanından önce **19,53 ms** (yaklaşık 51 FPS), sonra **8,40 ms** (yaklaşık 119 FPS) oldu; 95. yüzdelik değer **35,99 ms → 9,98 ms**. Ekran eşitlemesi ve ölçüm aralığı sonuçları etkileyebilir. Komut dosyasıyla açılan 3840×2160 pencerede ortalama **8,33 ms** ölçüldü; bu, kullanıcının gerçek 4K monitöründeki deneyimin yerini tutmaz.

Temel değişiklikler:

1. Yerel UI'da her simülasyon adımında 50×50 haritanın derin kopyası alınmıyor. Kayıt ve uzak ağ istemcileri için kopya sınırı korunuyor.
2. Statik zemin ayrı çizim katmanında tutuluyor. Kolonist hareketi artık tüm zemini yeniden çizdirmiyor; kamera, yakınlaştırma veya harita değiştiğinde zemin güncelleniyor.
3. Rutin HUD yenilemesi sınırlanıyor; doğrudan oyuncu emri sonrasında ekran gecikmeden yenileniyor.

Kafa hesabı/menü ölçümü: 60 model adımı üzerinden tek adım ve UI yenilemesi ortalaması **4,70 ms → 0,24 ms**. Bu bir mikro ölçümdür; asıl görsel deneyim için paketli oyunda kullanıcının kendi 4K ekranında tekrar bakılmalıdır.
