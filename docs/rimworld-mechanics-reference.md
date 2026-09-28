# Foxtopia: RimWorld mekanik başvuru notları

Bu not, kullanıcının paylaştığı [RimWorld Wiki](https://rimworldwiki.com/wiki/Main_Page),
Ludeon'un resmî geliştirme yazıları ve ilgili mod yapımcılarının açıklamalarından
Foxtopia için uygulanabilir davranışları çıkarır. **Şimdi / Sonraki / İleri**
etiketleri uygulama durumu değil, geliştirme sırasıdır. Kaynak oyun, arayüz
işleyişi için referanstır; görseller, ikonlar, metinler ve kod Foxtopia için
özgün üretilmelidir.

## Kaynak oyunun akışı ve Foxtopia kararı

| Konu | Doğrulanan RimWorld davranışı | Foxtopia kararı ve kapsam |
| --- | --- | --- |
| Yeni oyun | Senaryo ve dünya ayarlarından sonra üretilen dünyada iniş karosu seçilir; seçilen karonun biyom ve arazi bilgisi gösterilir. Başlangıç karakterleri daha sonra gözden geçirilir. [Dünya üretimi](https://rimworldwiki.com/wiki/World_generation), [Senaryo sistemi](https://rimworldwiki.com/wiki/Scenario_system) | **Şimdi:** ana menü → mod ve 1/2/3 insan → seed/dünya önizlemesi → karadan herhangi uygun karo → karakter hazırlığı → oyun. Ayrı “Hazır mısın?” adımı yok. 1/2/3 seçenekleri Foxtopia senaryosu. |
| Dünya | Seed coğrafyayı tekrar üretir. Önce kara kütleleri, sonra nehirler, yollar ve yerleşimler oluşur; komşu biyomlar/coğrafya ilişkili görünür. Tek tile seçimi ile yerleşim kurulabilir. [Dünya üretimi](https://rimworldwiki.com/wiki/World_generation), [Ludeon Alpha 17](https://ludeon.com/blog/2017/05/alpha-17-on-the-road-released/) | **Şimdi:** seed ile tekrarlanabilir, bitişik kara/deniz ve biyom bölgeleri; her uygun kara karosu seçilebilir. **Sonraki:** nehir, yol, iklim ve yerleşim yakınlığının oynanışa etkisi. |
| Birden çok yerleşim | Küresel dünya, aynı anda birden fazla yerel harita ve haritaya göre gruplu üst karakter şeridi destekler. [Ludeon Alpha 16](https://ludeon.com/blog/2016/12/rimworld-alpha-16-wanderlust-released/) | **Şimdi:** rekabetçi oyuncular farklı yerel haritalarda başlayabilir; sunucu her koloni/karakter için yetkiyi denetler. Co-op aynı koloniyi ortak yönetir. Bu iki oyun modu Foxtopia'ya özgüdür. |
| Faksiyon/yerleşke adı | Faksiyon adı ile yerleşim adı ayrı kavramlardır. [Ludeon Alpha 16](https://ludeon.com/blog/2016/12/rimworld-alpha-16-wanderlust-released/) | **Şimdi:** başlangıç menüsünde kalıcı ad sormak yerine geçici ad kullan. **Sonraki:** oyun içinde iki kolonistin sosyal karşılaşmasından doğan, tek seferlik adlandırma olayı; tek kolonistli başlangıçta ikinci kolonist gelince tetiklenebilir. Olayın bu kesin koşulu Foxtopia tasarımıdır. |
| Kolonist hazırlığı | Temel oyunda kolonistler tek tek rastgele yeniden oluşturulabilir; beceri, arka plan, kısıt ve 1–3 özellik görülür. Her niteliği serbest düzenleme temel oyunun özelliği değildir. [Kolonist](https://rimworldwiki.com/wiki/Colonist), [Özellikler](https://rimworldwiki.com/wiki/Traits) | **Şimdi:** 1/2/3 insan; görünüş, cinsiyet, sağlık, beceri, birden fazla özellik; seçili kişi ve ekip özeti aynı veriden beslenir. Puan bütçesi açık/kapalı olabilir, olumlu ve olumsuz seçimler bütçeyi etkiler. |
| Ayrıntılı başlangıç editörü | Karakter/ekipman ve isteğe bağlı puan sınırı [EdB Prepare Carefully modunun](https://steamcommunity.com/sharedfiles/filedetails/?id=735106432) sunduğu özelliktir. | **Şimdi:** modun fikrini Foxtopia kurallarına uyarlayan özgün bir editör; ad ve görünüş varyantlarında ileri/geri tuşları. **Sonraki:** başlangıç ekipmanı ve kayıtlı hazırlık şablonları. |

## Yerel haritada temel oynanış

| Konu | Doğrulanan RimWorld davranışı | Foxtopia kararı ve kapsam |
| --- | --- | --- |
| Ana HUD | Harita ana yüzeydir. Üstte karakter şeridi, sol altta seçim bilgi alanı, alt kenarda Architect/Work/Research/World gibi sekmeler; hız/tarih ve uyarılar ekran kenarındadır. Esc oyun menüsünü açar. [Arayüz](https://rimworldwiki.com/wiki/User_interface), [Kontroller](https://rimworldwiki.com/wiki/Controls) | **Şimdi:** harita tüm pencereyi doldurur; üst başlık ve kalıcı büyük paneller kaldırılır. Kaydet/Yükle/Ayarlar/Çıkış Esc menüsündedir. Seçim boş karo tıklanınca kapanır. |
| Seçim ve emir | Karakter veya üst portresinden seçim; seçili karakterle hedefe sağ tık, o anda yapılabilen işler için bağlama duyarlı menü; elle verilen iş mevcut işi kesebilir. Draft bir karakteri konuma veya saldırıya yönlendirir. [Emirler](https://rimworldwiki.com/wiki/Orders), [Draft](https://rimworldwiki.com/wiki/Drafting) | **Şimdi:** ulaşılabilir, sahip olunan ve karakterin yapabildiği eylemleri göster; olmayan mızrağı kuşan önerme. Draft/undraft tek bağlamsal düğme; hedefe git/iş yap/saldır; seçili karakterin eylem düğmeleri sol altta. **Sonraki:** Shift ile emir kuyruğu ve çoklu seçim. |
| İş önceliği | Temel oyun manuel Work tabında **1–4** kullanır; boş kutu işi kapatır. Önce düşük sayı, eşitlikte soldaki iş türü çalışır. [Work](https://rimworldwiki.com/wiki/Work) | **Şimdi:** kullanıcının istediği Foxtopia ölçeği **1–9**, ayrıca **0 = kapalı**. Bu sayı bir karakterin iş türünü seçme önceliğidir. Yetenek/kısıt kontrolü korunur. |
| Harita emir sırası | RimWorld'de Architect/Orders hedefleri işaretler; kolonist Work ve Schedule ayarlarına göre yapar. Acil hedef için seçili kolonistle sağ tık “Prioritize” verilir. [Emirler](https://rimworldwiki.com/wiki/Orders), [Prioritize](https://rimworldwiki.com/wiki/Prioritize) | **Şimdi:** Foxtopia'ya özgü ikinci **1–9** sayı, aynı türdeki iki duvar gibi *belirlenmiş işlerin kendi sırasıdır*. İş türü önceliğinden ayrı saklanır; Orders alt menüsündeki seçimin sonraki işaretlemelere uygulanması ve harita üstünde rozetle gösterilmesi gerekir. |
| Kaynak/taşıma | Kesilen veya çıkarılan kaynak fiziksel yerde bulunur; taşıyıcı yalnızca uygun boş alanı olan ve öğeyi kabul eden stockpile'a götürür. Bölgenin kabul ettiği öğeler seçilerek ayarlanır. [Bölgeler](https://rimworldwiki.com/wiki/Zone/Area), [Haul](https://rimworldwiki.com/wiki/Haul_things) | **Şimdi:** odun/taş/yemek/gümüş haritada istif olarak görünür; stockpile bölgesi ve basit öğe filtresi; taşıma koloni envanterine ışınlama değildir. **Sonraki:** depo önceliği ve çok hücreli çizim. |
| İş ve hareket geri bildirimi | Harita hücrelerine verilen işler karakterlerce yürünerek yapılır; araştırma gibi işlerin süre ve ilerlemesi vardır. [Emirler](https://rimworldwiki.com/wiki/Orders), [Araştırma](https://rimworldwiki.com/wiki/Research) | **Şimdi:** hücreler arası görsel yürüyüş yumuşatılır, iş yapan karakterin yakınında ilerleme çubuğu; boşta kısa ve güvenli dolaşma. Görsel ara kareler simülasyonun sunucu otoritesini değiştirmez. |
| İhtiyaçlar ve ruh hâli | Needs panelinde ölçerler ile Mood ve pozitif/negatif düşünceler bulunur; düşünceler ruh hâli hedefini değiştirir. [İhtiyaçlar](https://rimworldwiki.com/wiki/Need), [Mood](https://rimworldwiki.com/wiki/Mood) | **Şimdi:** seçili karakterde Needs sekmesi; açlık/dinlenme/ruh hâli, okunabilir olumlu/olumsuz etkiler. **Sonraki:** rahatlık, eğlence, ortam ve kırılma eşikleri. |
| Sağlık, Bio, Gear, Social | Yaralar seçilen karakterin Health sekmesinde; karakterin beceri/özellikleri, ekipmanı ve ilişkileri kendi bilgi sekmelerindedir. [Sağlık](https://rimworldwiki.com/wiki/Health), [Kolonist](https://rimworldwiki.com/wiki/Colonist), [Social](https://rimworldwiki.com/wiki/Social) | **Şimdi:** seçili karakterde Health/Needs/Bio/Gear; aynı tür yaraları sayıyla özetle, şiddeti anlaşılır kategoriyle ver. **Sonraki:** vücut bölgesi, tedavi ve Social ilişkileri; komşu karakterlerde kısa sosyal diyalog/ilişki etkisi. |
| Araştırma | Proje Research ekranında seçilir, fakat ilerleme için araştırmacı ve araştırma masası gerekir; ön koşullar teknoloji ağacı oluşturur. [Araştırma](https://rimworldwiki.com/wiki/Research), [Basit masa](https://rimworldwiki.com/wiki/Simple_research_bench) | **Şimdi:** masa inşa edilmeden araştırma ilerlemez; masaya ihtiyaç uyarısı ve Research girişinde açıklama; kurulduğunda proje seçimi/ilerleme. Sekmeyi tamamen kilitlemek kullanıcının istediği Foxtopia arayüz kararıdır, temel RimWorld davranışı olarak gösterilmemeli. **Sonraki:** bağımlılık ağacı. |
| Ticaret | Ziyaretçi kervanın liderinde ticaret işareti bulunur; seçilen kolonistle sağ tıklayıp Trade denince karakter lidere yürür, görüşünce alışveriş açılır. Satın alınan mallar haritaya düşer. [Ticaret](https://rimworldwiki.com/wiki/Trade) | **Şimdi:** dost NPC kervanı harita kenarından gelir; seçili kolonist liderle etkileşime yürür, ticaret penceresi bu temasla açılır; mal fiziksel konuma teslim edilir. Koloniler arası teklif ayrı çok oyunculu mekanik olarak korunur. **Sonraki:** mal türüne göre tüccar stoku/fiyat ve oyuncu kervanıyla dış yerleşime yolculuk. |
| Baskın | Baskın bildirimi saldırının türünü açıklar. Temel oyunda **hemen saldıran** ve harita kenarında **hazırlanan** saldırganlar ayrı stratejilerdir; hazırlananlara oyuncu erken saldırabilir. [Raider](https://rimworldwiki.com/wiki/Raider) | **Şimdi:** kullanıcının tercih ettiği ilk Foxtopia baskınında uyarı → harita kenarından geliş → kısa hazırlık → hücum; oyuncu erken saldırırsa bekleme biter. Her baskının hazırlanması temel RimWorld kuralı değildir. **Sonraki:** birden çok taktik ve servet/güç ölçekleme. |

## Ekran görüntülerinde mod/DLC ayrımı

- Görseldeki **Bladder, Hygiene, water pump, well** öğeleri temel oyunun ihtiyaçları
  değildir; [Dubs Bad Hygiene](https://github.com/Dubwise56/Dubs-Bad-Hygiene)
  modunun sistemidir. Foxtopia ilk sürümü için sağlık/Need panelinin yerleşimi
  örnek alınır, bu ihtiyaçlar kapsam dışı kalır.
- **Genes/xenotypes** [Biotech DLC](https://rimworldwiki.com/wiki/Biotech) içeriğidir.
  Başlangıç insanlarının görünüş ve özellik düzenlemesi bununla karıştırılmamalı.
- Oyun içindeki **styling station** [Ideology DLC](https://rimworldwiki.com/wiki/Styling_station)
  öğesidir. **Sonraki:** Foxtopia'nın kendi berber/ayna mobilyası; karakterin
  yürüyüp etkileşmesiyle görünüş ekranının açılması. İlk karakter hazırlığından
  farklı bir eylemdir.
- **9 basamaklı Work ve işaretleme önceliği, oda koduyla çok oyunculu giriş,
  co-op ve ayrı haritalı rekabet** Foxtopia istekleridir; temel RimWorld özelliği
  olarak tanıtılmamalıdır.

## Öncelik ve kabul listesi

1. **Şimdi:** yeni oyun akışı, seed ve seçilebilir kara; tam yüzey harita HUD;
   karakter seçimi/bağlamsal emir; 1–9 Work ile ayrı 1–9 iş emri; fiziksel
   kaynak/stockpile; karakter alt sekmeleri; araştırma masası kapısı; temasla
   ticaret; aşamalı baskın. Her adım tek oyuncu ve ağdaki yetki kuralıyla çalışmalı.
2. **Sonraki:** sosyal ilişki ve adlandırma olayı, görünüş mobilyası, içerikli
   kervan ekonomisi, derin sağlık/Needs, yollar/nehirler, gelişmiş başlangıç
   şablonları ve çoklu yerleşim dolaşımı.
3. **İleri:** büyük teknoloji ağacı, diplomasi, karavan yolculuğu ve dünya
   olayları, ayrıntılı tıbbi sistem, modüler biyom/iklim ve genişletilmiş
   hikâye olayları. Bunlar temel döngü oturmadan ilk sürüme yığılmamalı.
