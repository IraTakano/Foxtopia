# Kolonist hazırlama ve çizim kararı

29 Eylül 2026. Bu not, FT-050 ve FT-139 için gönderilen EdB Prepare Carefully ekranlarıyla yapılan karşılaştırmayı kaydeder. Foxtopia çizimleri özgündür.

## İncelenen kaynaklar

- [RimWorld resmî sitesi](https://rimworldgame.com/): karakter geçmişi, ilişkiler, sağlık ve giyim, kolonist sisteminin görünen ana parçalarıdır.
- [EdB Prepare Carefully geliştirici sayfası](https://steamcommunity.com/sharedfiles/filedetails/?id=735106432): kolonist düzenleme, başlangıç ekipmanı, isteğe bağlı puan sınırı ve hazır ayar kaydetme ayrı işlevlerdir.
- [EdB Prepare Carefully kaynak yapısı](https://github.com/edbmods/EdBPrepareCarefully/blob/master/EdBPrepareCarefully.csproj): karakter listesi, ad, görünüş, yaş, giyim, ilişkiler, sağlık ve ekipman katalogları ayrı panellerdir. Bu ayrım ekranın yalnızca sütunlara benzeyip akışta ayrışmamasını engellemek için başvurudur.
- Kullanıcının gönderdiği `codex-clipboard-155c4a26-e8d5-46a2-88c2-b861924b313b.png`, `4c2520f7-e535-487c-a6bd-bf133dae4f33.png` ve `edd33294-ebd2-488b-9c75-ae6c6ba2e753.png` görüntüleri: Characters, Relationships ve Equipment yerleşiminin somut görsel başvurusu.
- [Godot 2D kenar yumuşatma belgeleri](https://docs.godotengine.org/en/stable/tutorials/2d/2d_antialiasing.html) ve [SVG yükleme API'si](https://docs.godotengine.org/en/4.5/classes/class_image.html): Compatibility çizicisinde 2D MSAA yok; doğrudan boyanan çokgenler keskin kalabiliyor. `Image.load_svg_from_string` ile eğriler yüksek çözünürlükte rasterleştirilebiliyor.

## Foxtopia'daki uygulama

- Hazırlama ekranı, tek bir koyu editör penceresinde üst sekmeler, solda ekip listesi ve karakter sekmesinde görünüş, giyim/eşya, geçmiş/özellik/sağlık, beceri sütunları kullanır. Ekipman ve ilişkiler ayrı sekmelerdir.
- Ad satırında ilk ad, takma ad ve soyad ayrı saklanır; takma ad haritadaki kısa etikettir. Biyolojik ve kronolojik yaş, favori renk ve beceri tutkusu da hazırlamadan oyun modeline aktarılır.
- Kişinin giydiği T-shirt, pantolon ve ceket ile renkleri Characters/Apparel alanından düzenlenir. Equipment sekmesi yalnızca koloninin ortak başlangıç yükünü seçer; kategori, arama, miktar ve tümünü kaldırma sunar.
- İlişki görünümü gerçekten tanımlanan ebeveyn/çocuk/kardeş bağlarını çizgilerle gösterir. Boş bağlantı alanları da aynı ilişkileri düzenler.
- İki beden ve kafa seçeneği biyolojik görünüme göre çizilir. Saç seçimi aynı görünümü harita, üst portre ve hazırlama ekranında kullanır.
- Pawn çizimi 256×256 özgün eğri yollardan bir kez üretilir, mipmap ile küçültülür ve filtreli çizilir. Yüz, ten, saç, T-shirt, pantolon ve ceket ayrı katmanlardır. Kıyafetsiz başlangıç mümkündür. Aynı eşya katmanı beden tiplerine oturur; kıyafet rengi başlangıç ekipmanından değiştirilir.

## Henüz açık kapsam

Bu değişiklik kullanıcının önceki FT-050 reddini kapatmaz. Görsel ve işlev karşılaştırmasında kalan farklar:

| Alan | Kalan fark |
| --- | --- |
| Colony / World listeleri | Senaryo 1–3 kolonisti sabitler; EdB'deki ek dünya karakterlerini yaratma/taşıma ve rosterdaki Add akışı henüz yok. |
| Characters / Skills | Foxtopia'nın 8 becerisi gösterilir; EdB'deki geniş beceri listesi ve tutkuya bağlı öğrenme sistemi henüz yok. |
| Titles / Abilities / Health | Başlıkları görünürdür; unvan ve özel yetenek mekanikleri yok, sağlık durumları sınırlı. |
| Equipment | Gerçek oyun kataloğundaki 9 başlangıç eşyası vardır; geniş giyim/malzeme/kalite kataloğu yok. |
| Pawn grafiği | Yeni özgün yüksek çözünürlüklü çizim yumuşaktır; beden, yüz ve kıyafet siluetinin son sanat yönü kullanıcı incelemesini bekler. |

Kullanıcının nihai görsel onayı ve bu işlevlerin kapsam kararı `issue-tracker.md` içinde açık kalır.
