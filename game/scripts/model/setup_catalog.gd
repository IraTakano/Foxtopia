extends RefCounted

## Original Foxtopia starts. Every option here is applied by the simulation;
## the setup screens must never advertise a purely cosmetic rule.

const SCENARIOS := [
	{
		"id": "landfall", "name": ["Landfall", "İlk İniş", "Lądowanie"],
		"summary": ["A balanced expedition with supplies for a small camp.", "Küçük bir kamp için dengeli erzakla gelen ekip.", "Zrównoważona wyprawa z zapasami na mały obóz."],
		"story": ["Your shuttle landed far from the old routes. Build a shelter, secure food and decide who to trust.", "Mekiğiniz eski rotalardan uzakta indi. Barınak kurun, yiyecek bulun ve kime güveneceğinize karar verin.", "Wasz prom wylądował z dala od dawnych szlaków. Zbudujcie schronienie, zdobądźcie żywność i zdecydujcie, komu zaufać."],
		"inventory": {"wood": 12, "stone": 8, "food": 12, "medicine": 2, "silver": 25, "spear": 2, "jacket": 3},
	},
	{
		"id": "homesteaders", "name": ["Homesteaders", "Yerleşimciler", "Osadnicy"],
		"summary": ["More building supplies, fewer provisions and weapons.", "Daha çok yapı malzemesi, daha az erzak ve silah.", "Więcej materiałów budowlanych, mniej żywności i broni."],
		"story": ["You came to stay. The crates hold tools and timber, but your food will run out quickly.", "Kalıcı bir yuva kurmaya geldiniz. Sandıklarda alet ve kereste var, ancak yiyeceğiniz çabuk bitecek.", "Przybyliście tu na stałe. Skrzynie pełne są narzędzi i drewna, ale żywność szybko się skończy."],
		"inventory": {"wood": 25, "stone": 16, "food": 7, "medicine": 1, "silver": 12, "spear": 1, "jacket": 2},
	},
	{
		"id": "hard_landing", "name": ["Hard Landing", "Sert İniş", "Twarde lądowanie"],
		"summary": ["A damaged cargo hold and a demanding start.", "Hasarlı yük bölmesiyle zorlu bir başlangıç.", "Uszkodzony ładunek i wymagający początek."],
		"story": ["Most of the cargo scattered during descent. Salvage what you can and survive the first days.", "Yükün çoğu inişte dağıldı. Bulduklarınızı kurtarın ve ilk günleri atlatın.", "Większość ładunku rozproszyła się podczas zejścia. Ocalcie, co się da, i przetrwajcie pierwsze dni."],
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
