# Foxtopia arayüz referansı

Bu belge, resmî RimWorld kaynaklarından alınan **yerleşim ilkelerini** Foxtopia'nın özgün arayüzüne çevirir. Grafikler, ikonlar, yazılar ve pencere görselleri kopyalanmaz.

## İncelenen resmî kaynaklar

- [RimWorld Steam mağazası: Ludeon Studios ekran görüntüleri](https://store.steampowered.com/app/294100/RimWorld/)
- [RimWorld resmî sitesi](https://rimworldgame.com/)
- [Ludeon: Alpha 16, dünya ve birden çok harita](https://ludeon.com/blog/2016/12/rimworld-alpha-16-wanderlust-released/)
- [Ludeon: 1.3 arayüz arama alanları](https://ludeon.com/blog/2021/07/announcing-update-1-3-and-the-ideology-expansion/)
- [Ludeon: 1.5 sağlık ve araştırma pencereleri](https://ludeon.com/blog/2024/03/anomaly-expansion-and-update-1-5-announced/)
- [EdB Prepare Carefully resmî atölye sayfası ve karakter ekranı](https://steamcommunity.com/sharedfiles/filedetails/?id=735106432)
- [EdB Prepare Carefully karakter sekmesi kaynak kodu](https://github.com/edbmods/EdBPrepareCarefully/blob/master/Source/TabViewPawns.cs)

## Kullanıcının paylaştığı ekran görüntülerinden yerleşim gözlemleri

Bu iki görüntüde mod içerikleri de bulunuyor. Bu yüzden modlara ait ihtiyaçlar,
ikonlar ve sayılar temel RimWorld özelliği olarak alınmıyor. Yerleşim açısından
görülenler:

- Harita pencerenin tamamını dolduruyor; alt bilgi penceresi açılsa da kamera
  alanı kalıcı bir sütuna bölünmüyor.
- Kaynaklar solda dikey bir liste, kolonist portreleri üst orta bölgede.
- Uyarılar sağ kenarda; tarih ve hız denetimleri sağ alt bölgede.
- Ana kategori sekmeleri ekranın alt kenarında kısa bir şerit oluşturuyor.
- Seçilen kolonistin özeti sol altta açılıyor. İhtiyaçlar gibi ayrıntılar bu
  özetin üstünde bağlamsal pencere; seçili koloniste verilecek emirler hemen
  yanında küçük, tıklanabilir denetimler.

## Foxtopia düzen kararları

1. **Harita ana yüzeydir.** Oyun çözünürlüğe uyumlu tam ekran çizilir. Kaynak,
   portre, uyarı ve komut katmanları haritanın üzerinde durur; sabit başlık ve
   büyük alt panel haritayı küçültmez.
2. **Durum ekran kenarlarında bulunur.** Kaynaklar solda, portreler üst ortada,
   uyarılar sağda, tarih ve hız sağ altta, ana sekmeler alt kenardadır.
3. **Kolonist seçimi bağlamsaldır.** Haritadaki karaktere veya üst portresine
   tıklanınca sol altta kısa özet açılır. Bio, İhtiyaçlar, Sağlık ve Ekipman
   onun alt sekmeleridir. Boş alana tıklamak seçimi kapatır.
4. **Emirler seçime göre görünür.** Savaş hazırlığı, öncelikli iş ve doğrudan
   saldırı gibi eylemler, seçili karakterin yakınındaki küçük denetimlerdir.
   Müsait olmayan eşya veya hedef için eylem gösterilmez.
5. **Yeni oyun adım adım hazırlanır.** Mod → dünya ve yerleşke → kolonistler →
   oyun akışı sürer. Dünya görünümü haritaya yer açar; karakter hazırlığında
   solda ekip listesi, sağda seçili kişinin düzenleyicisi bulunur. Koloni ve
   yerleşke adları oyun içindeki uygun bir olayda belirlenir.
6. **Ayrı haritalar aynı dünya içinde yönetilir.** Rekabetçi modda oyuncular
   farklı yerleşke haritalarında başlayabilir; üst portreler yalnızca yetkili
   olunan karakterleri seçtirir.
7. **Karakter hazırlama EdB'nin bilgi sırasını izler.** Üstte Karakterler,
   İlişkiler ve Ekipman sekmeleri ile puan sınırı bulunur. Karakter sayfasında
   solda portreli ekip listesi; onun yanında ad ve hazır karakter komutları;
   altta aynı anda görülen görünüş, geçmiş/özellik/sağlık ve beceri sütunları
   bulunur. İlişkiler ve başlangıç ekipmanı ayrı, çalışan sayfalardır.

Görsel tasarım ve varlıklar Foxtopia'ya özgün olmalıdır. Referans görüntülerin
ikonları, çizimleri ve metinleri kopyalanmaz.
