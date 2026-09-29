# Kolonist hazırlama ve çizim kararı

29 Eylül 2026. Bu not, FT-050 ve FT-139 için gönderilen EdB Prepare Carefully ekranlarıyla yapılan karşılaştırmayı kaydeder. Foxtopia çizimleri özgündür.

## İncelenen kaynaklar

- [RimWorld resmî sitesi](https://rimworldgame.com/): karakter geçmişi, ilişkiler, sağlık ve giyim, kolonist sisteminin görünen ana parçalarıdır.
- [EdB Prepare Carefully geliştirici sayfası](https://steamcommunity.com/sharedfiles/filedetails/?id=735106432): kolonist düzenleme, başlangıç ekipmanı, isteğe bağlı puan sınırı ve hazır ayar kaydetme ayrı işlevlerdir.
- [EdB Prepare Carefully kaynak yapısı](https://github.com/edbmods/EdBPrepareCarefully/blob/master/EdBPrepareCarefully.csproj): karakter listesi, ad, görünüş, yaş, giyim, ilişkiler, sağlık ve ekipman katalogları ayrı panellerdir. Bu ayrım ekranın yalnızca sütunlara benzeyip akışta ayrışmamasını engellemek için başvurudur.
- Kullanıcının gönderdiği `codex-clipboard-155c4a26-e8d5-46a2-88c2-b861924b313b.png`, `4c2520f7-e535-487c-a6bd-bf133dae4f33.png` ve `edd33294-ebd2-488b-9c75-ae6c6ba2e753.png` görüntüleri: Characters, Relationships ve Equipment yerleşiminin somut görsel başvurusu.
- [Godot 2D kenar yumuşatma belgeleri](https://docs.godotengine.org/en/stable/tutorials/2d/2d_antialiasing.html) ve [SVG yükleme API'si](https://docs.godotengine.org/en/4.5/classes/class_image.html): Compatibility çizicisinde 2D MSAA yok; doğrudan boyanan çokgenler keskin kalabiliyor. `Image.load_svg_from_string` ile eğriler yüksek çözünürlükte rasterleştirilebiliyor.

## Foxtopia'daki uygulama

- Hazırlama ekranında üst sekmeler ve dört ana sütun vardır: Colony/World listesi, yaş ve görünüş, geçmiş/özellik/sağlık, klasik beceriler. Keskin köşeli koyu panellerde dokulu zemin kullanılır; alt düğmelerin altında boşluk bırakılır. Puan anahtarı kırmızı X veya yeşil onay işaretidir; sağ üstte tüm ekip ve ortak yükün toplam harcaması görünür.
- Kolonistler bir ile üç kişi arasında eklenip çıkarılabilir. Çıkarılan kolonist World havuzuna taşınır ve geri alınabilir; kayıtlı hazırlık şablonu bu havuzu da saklar. Ad satırında ilk ad, takma ad ve soyad ayrı saklanır; takma ad haritadaki kısa etikettir. Rastgele seçim ikonları metin karakteri yerine çizilmiş zar kullanır. Biyolojik/kronolojik yaşlar, görünüş, geçmiş ve özellikler oklarla düzenlenir; saç ve ten renkleri doğrudan görünür.
- Characters sekmesindeki ana sütunda ayrı bir Apparel/Possessions/Titles/Abilities sütunu yoktur. Kişinin T-shirt, pantolon, ceket, silah ve giyim renkleri portredeki giysi ikonundan açılan pencerede düzenlenir. Şapka açılır listesindeki kep ve siperli şapka, başlangıç ekipmanına ve harita üzerindeki çizime aktarılır. Equipment sekmesi koloninin ortak yüküdür: kategori ve malzeme filtreleri, Cost sütunu, Add Equipment düğmesi ve miktar okları vardır.
- On iki klasik beceri başlığı ve alev biçimli tutku işaretleri görünür. İnşaat, madencilik, bitki, tıp, araştırma ve dövüş becerileri mevcut iş/savaş sistemlerine eşlenir.
- Aile görünümünde ebeveyn/çocuk yönlü kalın oklarla bağlanır; boş kutuların köşesindeki küçük artıdan bağ eklenir. Diğer ilişkiler yalnızca kurulmuş bağlar için portreler ve karşılıklı dolgulu rol oklarıyla görünür; yeni ilişki ayrı bir boş kutudan eklenir.
- İki beden ve kafa seçeneği biyolojik görünüme göre çizilir. Saç seçimi aynı görünümü harita, üst portre ve hazırlama ekranında kullanır.
- Pawn çizimi 256×256 özgün eğri yollardan bir kez üretilir, mipmap ile küçültülür ve filtreli çizilir. Yüz, ten, saç, T-shirt, pantolon ve ceket ayrı katmanlardır. Kıyafetsiz başlangıç mümkündür. Aynı eşya katmanı beden tiplerine oturur; kıyafet rengi başlangıç ekipmanından değiştirilir.

## Henüz açık kapsam

Bu değişiklik kullanıcının önceki FT-050 reddini kapatmaz. Görsel ve işlev karşılaştırmasında kalan farklar:

| Alan | Kalan fark |
| --- | --- |
| Colony / World listeleri | World havuzu şu anda yalnızca hazırlıkta çıkarılan kolonistleri tutar; dünyada yaşayan NPC karakterleri burada seçip koloniye alma akışı yok. |
| Characters / Skills | On iki başlık görünür; cooking, animals, crafting, artistic ve social için ayrı görev/öğrenme etkileri henüz yok. |
| Health | Sağlık durumu listesi ve başlangıç koşulları sınırlı; EdB'deki ayrıntılı vücut parçası ve implant editörü henüz yok. |
| Equipment | Gerçek oyun kataloğundaki 11 başlangıç eşyası vardır; malzeme filtresi mevcut eşya türleriyle sınırlıdır. Geniş giyim/malzeme/kalite kataloğu yok. |
| Appearance | İki şapka tipi çalışır; malzeme tabanlı giysi çeşidi ve ek şapka modelleri henüz yok. Görünüş/giysi siluetinin son sanat yönü kullanıcı incelemesini bekler. |
| Point limits | Harcanan toplam puan görünür; sınır açıldığında mevcut model kişi başına 12 puan uygular. EdB'nin tam puan ekonomisi henüz uyarlanmadı. |
| Pawn grafiği | Yeni özgün yüksek çözünürlüklü çizim yumuşaktır; beden, yüz ve kıyafet siluetinin son sanat yönü kullanıcı incelemesini bekler. |

Kullanıcının nihai görsel onayı ve bu işlevlerin kapsam kararı `issue-tracker.md` içinde açık kalır.
