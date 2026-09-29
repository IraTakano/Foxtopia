extends RefCounted

## Original Foxtopia starts. Every option here is applied by the simulation;
## the setup screens must never advertise a purely cosmetic rule.

const SCENARIOS := [
	{
		"id": "landfall", "name": ["Landfall", "İlk İniş", "Lądowanie"],
		"colonist_count": 3,
		"summary": ["A balanced expedition with supplies for a small camp.", "Küçük bir kamp için dengeli erzakla gelen ekip.", "Zrównoważona wyprawa z zapasami na mały obóz."],
		"story": ["The shuttle has brought three travelers to a planet beyond the familiar routes. From the landing site you choose, they must turn a patch of open ground into a place worth calling home. There is enough in the hold to begin, but no established shelter or dependable food source waiting for them.", "Mekik, üç yolcuyu bilinen rotaların ötesindeki bir gezegene getirdi. Seçeceğiniz iniş yerinde açık bir araziyi yuva diyecekleri bir yere dönüştürmeleri gerek. Yük bölmesinde başlangıç için yeterli malzeme var; ancak hazır bir barınak ya da güvenilir yiyecek kaynağı onları beklemiyor.", "Prom przywiózł troje podróżników na planetę poza znanymi szlakami. W wybranym miejscu lądowania muszą zamienić kawałek otwartej ziemi w dom. W ładowni jest dość zapasów na początek, ale nie czeka na nich ani gotowe schronienie, ani pewne źródło pożywienia."],
		"first_days": ["Share the first jobs between building, gathering and caring for the crew. Two spears and a little medicine give you room to react while you learn the terrain. As nearby settlements come into view, decide whether to trade, keep your distance or prepare for trouble.", "İlk işleri inşa, toplama ve ekip bakımı arasında paylaştırın. İki mızrak ve az miktarda ilaç, araziyi tanırken size hareket alanı sağlar. Yakındaki yerleşkeleri keşfettikçe ticaret yapmaya, uzak durmaya veya tehlikeye hazırlanmaya karar verin.", "Podziel pierwsze zadania między budowę, zbieranie surowców i opiekę nad załogą. Dwie włócznie i trochę lekarstw dają czas na reakcję podczas poznawania terenu. Gdy poznacie pobliskie osady, zdecydujcie, czy handlować, zachować dystans, czy przygotować się na kłopoty."],
		"conditions": ["Three colonists begin together with a balanced mix of materials, food and equipment. This is the most flexible starting point for learning the colony systems.", "Üç kolonist, dengeli yapı malzemeleri, yiyecek ve ekipmanla birlikte başlar. Koloni sistemlerini öğrenmek için en esnek başlangıçtır.", "Troje kolonistów zaczyna razem ze zrównoważonym zestawem materiałów, żywności i wyposażenia. To najbardziej elastyczny początek do poznania zasad kolonii."],
		"inventory": {"wood": 12, "stone": 8, "food": 12, "medicine": 2, "silver": 25, "spear": 2, "jacket": 3},
	},
	{
		"id": "homesteaders", "name": ["Homesteaders", "Yerleşimciler", "Osadnicy"],
		"colonist_count": 2,
		"summary": ["More building supplies, fewer provisions and weapons.", "Daha çok yapı malzemesi, daha az erzak ve silah.", "Więcej materiałów budowlanych, mniej żywności i broni."],
		"story": ["This was never meant to be a brief stop. Two settlers have come with enough timber and stone to lay out a lasting home, and they have chosen to build it themselves. Their plans are ambitious; their food crates are not. The first buildings may rise quickly, but every day spent on construction is a day the pantry grows lighter.", "Bu, kısa bir mola olarak planlanmadı. İki yerleşimci kalıcı bir yuva kurmaya yetecek odun ve taşla geldi; onu kendi elleriyle inşa edecekler. Planları büyük, yiyecek sandıkları ise küçük. İlk yapılar hızla yükselebilir ama inşaatla geçen her gün erzak azalır.", "To nie miał być krótki postój. Dwoje osadników przybyło z drewnem i kamieniem wystarczającym do zbudowania trwałego domu. Ich plany są ambitne, lecz zapasy żywności skromne. Pierwsze budynki mogą stanąć szybko, ale każdy dzień budowy uszczupla spiżarnię."],
		"first_days": ["Use the generous building materials to establish a safe base, then secure a reliable way to feed the pair. With only one spear and limited medicine, a careless fight can put the whole settlement behind schedule.", "Bol yapı malzemeleriyle güvenli bir üs kurun, ardından iki kişiyi beslemenin güvenilir bir yolunu bulun. Tek mızrak ve sınırlı ilaçla dikkatsizce girilen bir çatışma bütün yerleşkenin planını bozabilir.", "Wykorzystajcie obfite materiały do wzniesienia bezpiecznej bazy, a potem zadbajcie o stałe wyżywienie pary. Jedna włócznia i niewiele lekarstw sprawiają, że nieostrożna walka może opóźnić całą osadę."],
		"conditions": ["Two colonists start with extra wood and stone, but less food, medicine and protection than the balanced expedition. Building is easier; keeping the pantry stocked needs attention.", "İki kolonist, dengeli ekibe göre daha fazla odun ve taşla; ancak daha az yiyecek, ilaç ve korunmayla başlar. İnşa etmek kolaylaşır; erzağı dolu tutmak dikkat ister.", "Dwoje kolonistów ma więcej drewna i kamienia, lecz mniej żywności, lekarstw i ochrony niż zrównoważona wyprawa. Budowa jest łatwiejsza; trzeba uważnie pilnować zapasów."],
		"inventory": {"wood": 25, "stone": 16, "food": 7, "medicine": 1, "silver": 12, "spear": 1, "jacket": 2},
	},
	{
		"id": "hard_landing", "name": ["Hard Landing", "Sert İniş", "Twarde lądowanie"],
		"colonist_count": 1,
		"summary": ["A damaged cargo hold and a demanding start.", "Hasarlı yük bölmesiyle zorlu bir başlangıç.", "Uszkodzony ładunek i wymagający początek."],
		"story": ["The descent went wrong. The cargo hold broke open before the shuttle reached the ground, leaving one survivor with only a few intact crates. There is no crew to divide the work and no medical stock to fall back on. A shelter, food and a way to stay safe must all come from the same pair of hands.", "İniş ters gitti. Mekik yere ulaşmadan yük bölmesi açıldı ve tek bir kurtulanın elinde yalnızca birkaç sağlam sandık kaldı. İşleri paylaşacak ekip ve gerektiğinde başvurulacak ilaç yok. Barınak, yiyecek ve güvenlik aynı iki elle sağlanmalı.", "Lądowanie poszło źle. Ładownia otworzyła się, zanim prom dotarł do ziemi, pozostawiając jedną osobę przy życiu i zaledwie kilka całych skrzyń. Nie ma załogi do podziału pracy ani zapasu lekarstw. Schronienie, żywność i bezpieczeństwo zależą od jednej pary rąk."],
		"first_days": ["Choose early tasks carefully: gathering resources, raising shelter and finding food all compete for one colonist's time. Your few supplies and single spear may help you through an emergency, but recovery will be difficult without medicine.", "İlk işleri dikkatle seçin: kaynak toplama, barınak kurma ve yiyecek bulma tek kolonistin zamanı için yarışır. Az sayıdaki erzak ve tek mızrak acil durumda yardımcı olabilir, fakat ilaç olmadan toparlanmak zordur.", "Starannie wybierajcie pierwsze zadania: zbieranie surowców, budowa schronienia i zdobywanie jedzenia zajmują czas jedynego kolonisty. Nieliczne zapasy i jedna włócznia mogą pomóc w nagłym wypadku, lecz bez lekarstw trudno będzie dojść do siebie."],
		"conditions": ["One colonist starts alone with sparse materials and food, one spear and one jacket. There is no starting medicine. This is the most demanding start.", "Bir kolonist az yapı malzemesi ve yiyecek, bir mızrak ve bir ceketle tek başına başlar. Başlangıç ilacı yoktur. En zorlu başlangıç budur.", "Jeden kolonista zaczyna samotnie z niewielką ilością materiałów i żywności, jedną włócznią i jedną kurtką. Nie ma lekarstw na start. To najbardziej wymagający początek."],
		"inventory": {"wood": 5, "stone": 3, "food": 6, "medicine": 0, "silver": 8, "spear": 1, "jacket": 1},
	},
]

const STORYTELLERS := [
	{"id": "steady", "name": ["Mira — Steady", "Mira — Dengeli", "Mira — Spokojna"],
		"summary": ["Threats rise at a measured pace, with pauses to rebuild.", "Tehditler ölçülü artar; toparlanmak için zaman kalır.", "Zagrożenia rosną stopniowo, z przerwami na odbudowę."],
		"raid_factor": 1.0, "caravan_factor": 1.0, "variance": 0.0},
	{"id": "gentle", "name": ["Elian — Patient", "Elian — Sabırlı", "Elian — Cierpliwy"],
		"summary": ["Longer peaceful stretches and more visiting traders.", "Daha uzun sakin dönemler ve daha çok tüccar ziyareti.", "Dłuższe okresy spokoju i częstsze wizyty handlarzy."],
		"raid_factor": 1.55, "caravan_factor": 0.75, "variance": 0.0},
	{"id": "erratic", "name": ["Rook — Unpredictable", "Rook — Öngörülemez", "Rook — Nieprzewidywalny"],
		"summary": ["Events arrive at uneven intervals. Prepare for surprises.", "Olaylar düzensiz aralıklarla gelir. Sürprizlere hazırlanın.", "Zdarzenia pojawiają się nieregularnie. Przygotujcie się na niespodzianki."],
		"raid_factor": 1.0, "caravan_factor": 1.0, "variance": 0.45},
]

const DIFFICULTIES := [
	{"id": "peaceful", "name": ["Peaceful", "Barışçıl", "Spokojny"],
		"summary": ["No hostile raids. Learn and build freely.", "Düşman baskını yok. Rahatça öğrenin ve inşa edin.", "Bez wrogich najazdów. Uczcie się i budujcie swobodnie."], "raid_scale": 0.0},
	{"id": "builder", "name": ["Builder", "Kurucu", "Budowniczy"],
		"summary": ["Occasional small threats.", "Arada küçük tehditler.", "Sporadyczne niewielkie zagrożenia."], "raid_scale": 0.65},
	{"id": "frontier", "name": ["Frontier", "Sınır Bölgesi", "Pogranicze"],
		"summary": ["The intended balance of building and danger.", "İnşa ve tehlike arasında dengeli deneyim.", "Zrównoważona rozgrywka między budową a zagrożeniem."], "raid_scale": 1.0},
	{"id": "harsh", "name": ["Harsh", "Çetin", "Surowy"],
		"summary": ["More frequent and stronger raids.", "Daha sık ve güçlü baskınlar.", "Częstsze i silniejsze najazdy."], "raid_scale": 1.55},
]


static func find_by_id(entries: Array, id: String) -> Dictionary:
	for entry in entries:
		if str(entry.get("id", "")) == id:
			return entry
	return entries[0] if not entries.is_empty() else {}


static func localized(values: Array, language: String) -> String:
	var index := 1 if language == "tr" else 2 if language == "pl" else 0
	return str(values[index]) if index < values.size() else str(values[0])
