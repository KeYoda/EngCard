import 'package:eng_card/data/gridview.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WordProvider extends ChangeNotifier {
  final Map<String, List<Words>> _wordLists = {}; // Seviye bazlı tüm listeler
  final Map<String, List<Words>> _initialLists = {};
  final Map<String, int> _lastIndices = {};

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  WordProvider() {
    _initializeAll();
  }

  Future<void> _initializeAll() async {
    await initializeDummyData(); // Sadece ilk yüklemede veya boşsa çalışır
    await _initializeAllLevels();
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> _initializeAllLevels() async {
    for (var level in ['A1', 'A2', 'B1', 'B2', 'C1']) {
      await _loadLastIndex(level);
      await loadData(level);
      _initialLists[level] = List.from(_wordLists[level] ?? []);
      // İsteğe bağlı: Başlangıçta karıştırma
      // _initialLists[level]?.shuffle();
      // _wordLists[level]?.shuffle();
    }
    notifyListeners();
  }

  // --- [YENİ EKLENEN] TÜM KELİMELERİ GERİ YÜKLEME FONKSİYONU ---
  Future<void> restoreAllWords() async {
    final levels = ['A1', 'A2', 'B1', 'B2', 'C1'];

    for (var level in levels) {
      // 1. Orijinal kaynaktan (wordsListOne) o seviyenin kelimelerini çek
      List<Words> originalData =
          wordsListOne.where((w) => w.list == level).toList();

      // 2. Hafızadaki listeyi güncelle
      _wordLists[level] = List.from(originalData);

      // İsteğe bağlı: Resetlendiğinde liste karışık gelsin istiyorsan açabilirsin
      _wordLists[level]?.shuffle();

      // 3. İndeksi sıfırla
      _lastIndices[level] = 0;
      await _saveLastIndex(level);

      // 4. Telefona (SharedPreferences) taze veriyi kaydet
      await saveData(level);

      print("$level seviyesi geri yüklendi: ${originalData.length} kelime.");
    }

    notifyListeners();
  }
  // -------------------------------------------------------------

  void clearPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    print("Tüm SharedPreferences verileri temizlendi.");
  }

  Future<void> initializeDummyData() async {
    final prefs = await SharedPreferences.getInstance();
    final levels = ['A1', 'A2', 'B1', 'B2', 'C1'];

    for (var level in levels) {
      // Eğer o seviyenin verisi hiç yoksa yükle
      if (prefs.getStringList('${level}_questList') == null) {
        List<Words> dummyWords =
            wordsListOne.where((w) => w.list == level).toList();

        await prefs.setStringList(
            '${level}_questList', dummyWords.map((e) => e.quest).toList());
        await prefs.setStringList(
            '${level}_answerList', dummyWords.map((e) => e.answer).toList());
        await prefs.setStringList(
            '${level}_frontList', dummyWords.map((e) => e.front).toList());
        await prefs.setStringList(
            '${level}_backList', dummyWords.map((e) => e.back).toList());

        print("$level ilk verileri yüklendi: ${dummyWords.length} adet");
      }
    }
  }

  List<Words> getWords(String level) => _wordLists[level] ?? [];
  int getLastIndex(String level) => _lastIndices[level] ?? 0;

  Future<void> _loadLastIndex(String level) async {
    final prefs = await SharedPreferences.getInstance();
    _lastIndices[level] = prefs.getInt('${level}_lastIndex') ?? 0;
  }

  Future<void> _saveLastIndex(String level) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('${level}_lastIndex', _lastIndices[level] ?? 0);
  }

  void setLastIndex(String level, int index) {
    _lastIndices[level] = index;
    _saveLastIndex(level);
    notifyListeners();
  }

  Future<void> loadData(String level) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? questList = prefs.getStringList('${level}_questList');
    List<String>? answerList = prefs.getStringList('${level}_answerList');
    List<String>? frontList = prefs.getStringList('${level}_frontList');
    List<String>? backList = prefs.getStringList('${level}_backList');

    _wordLists[level] = [];

    if (questList != null &&
        answerList != null &&
        frontList != null &&
        backList != null) {
      for (int i = 0; i < questList.length; i++) {
        _wordLists[level]!.add(
          Words(
            list: level,
            quest: questList[i],
            answer: answerList[i],
            front: frontList[i],
            back: backList[i],
          ),
        );
      }
    }
    notifyListeners();
  }

  Future<void> saveData(String level) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<Words> list = _wordLists[level] ?? [];

    List<String> questList = list.map((w) => w.quest).toList();
    List<String> answerList = list.map((w) => w.answer).toList();
    List<String> frontList = list.map((w) => w.front).toList();
    List<String> backList = list.map((w) => w.back).toList();

    await prefs.setStringList('${level}_questList', questList);
    await prefs.setStringList('${level}_answerList', answerList);
    await prefs.setStringList('${level}_frontList', frontList);
    await prefs.setStringList('${level}_backList', backList);
  }

  void deleteWord(String level, int index, BuildContext context) {
    if (_wordLists[level] == null || _wordLists[level]!.isEmpty) return;

    _wordLists[level]!.removeAt(index);

    if (index >= (_wordLists[level]?.length ?? 0)) {
      _lastIndices[level] = (_lastIndices[level]! - 1)
          .clamp(0, (_wordLists[level]?.length ?? 1) - 1);
      _saveLastIndex(level);
    }

    if (_wordLists[level]!.isEmpty) {
      Navigator.pop(context);
    } else {
      saveData(level);
      notifyListeners();
    }
  }

  // Tekil seviye resetleme (İhtiyaç olursa diye bıraktım)
  void resetList(String level) async {
    List<Words> dummyWords =
        wordsListOne.where((w) => w.list == level).toList();

    _wordLists[level] = List.from(dummyWords);
    _initialLists[level] = List.from(dummyWords);

    _wordLists[level]?.shuffle();
    _lastIndices[level] = 0; // Indexi de sıfırla
    await _saveLastIndex(level);

    await saveData(level);
    notifyListeners();
  }
}

List<Words> wordsListOne = [
  Words(
      front: "The government decided to abolish the old law.",
      back: "Hükümet, eski yasayı yürürlükten kaldırmaya karar verdi.",
      list: 'C1',
      answer: 'yürürlükten kaldırmak',
      quest: 'abolish'),
  Words(
      front: "There was a complete absence of sound in the silent room.",
      back: "Sessiz odada tamamen yokluk,bulunmayış vardı.",
      list: 'C1',
      answer: 'yokluk,bulunmayış',
      quest: 'absence'),
  Words(
      front: "The teacher was absent from school due to illness.",
      back: "Öğretmen hastalık nedeniyle okulda mevcut değildi.",
      list: 'C1',
      answer: 'absent',
      quest: 'absent'),
  Words(
      front: "The land had an abundance of natural resources.",
      back: "Toprak, doğal kaynakların çokluğu,bolluğu vardı.",
      list: 'C1',
      answer: 'çokluk,bolluk',
      quest: 'abundance'),
  Words(
      front: "Drug abuse is a serious problem in many societies.",
      back:
          "Uyuşturucu madde kötüye kullanımı birçok toplumda ciddi bir sorundur.",
      list: 'C1',
      answer: 'kötüye kullanmak',
      quest: 'abuse'),
  Words(
      front:
          "The car accelerated quickly as it pulled away from the stop sign.",
      back: "Araba stop işaretinden uzaklaşırken hızlandı.",
      list: 'C1',
      answer: 'hızlanmak',
      quest: 'accelerate'),
  Words(
      front: "Her acceptance speech was filled with gratitude.",
      back: "Her kabul konuşması minnettarlıkla doluydu.",
      list: 'C1',
      answer: 'kabul',
      quest: 'acceptance'),
  Words(
      front: "The library is accessible to everyone in the community.",
      back: "Kütüphane, toplumdaki herkes için ulaşılabilir.",
      list: 'C1',
      answer: 'ulaşılabilir',
      quest: 'accessible'),
  Words(
      front:
          "Winning the gold medal was a great accomplishment for the athlete.",
      back: "Altın madalya kazanmak, sporcu için büyük bir başarıydı.",
      list: 'C1',
      answer: 'başarma',
      quest: 'accomplishment'),
  Words(
      front: "He acted in accordance with the company's policies.",
      back: "Şirketin politikalarına uygun hareket etti.",
      list: 'C1',
      answer: 'uygunluk',
      quest: 'accordance'),
  Words(
      front: "Accordingly, we need to change our approach.",
      back: "Bu sebepten dolayı, yaklaşımımızı değiştirmemiz gerekiyor.",
      list: 'C1',
      answer: 'bu sebepten',
      quest: 'Accordingly'),
  Words(
      front:
          "The police investigation revealed a series of accusations of corruption.",
      back: "Polis soruşturması bir dizi yolsuzluk suçlaması ortaya çıkardı.",
      list: 'C1',
      answer: 'itham,suçlama',
      quest: 'accusation'),
  Words(
      front: "The accused man pleaded not guilty in court.",
      back: "Suçlanan adam mahkemede suçsuz olduğunu iddia etti.",
      list: 'C1',
      answer: 'zanlı,suçlu',
      quest: 'accused'),
  Words(
      front:
          "The company's recent acquisition of a new startup has expanded its market reach.",
      back:
          "Şirketin yakın zamanda yeni bir girişimin satın alınması pazar erişimini genişletti.",
      list: 'C1',
      answer: 'kazanma',
      quest: 'acquisition'),
  Words(
      front: "The farmer owns a large plot of land that is hundreds of acres.",
      back: "Çiftçi, yüzlerce dönüm büyüklüğünde geniş bir araziye sahiptir.",
      list: 'C1',
      answer: 'arazi',
      quest: 'acre'),
  Words(
      front: "The activation of the security system deterred the burglar.",
      back: "Güvenlik sisteminin etkinleşmesi hırsızı caydırdı.",
      list: 'C1',
      answer: 'etkinleşme',
      quest: 'activation'),
  Words(
      front: "He was suffering from acute pain after the accident.",
      back: "Kazadan sonra şiddetli ağrı çekiyordu.",
      list: 'C1',
      answer: 'şiddetli',
      quest: 'acute'),
  Words(
      front:
          "Daily life with aniridia requires constant adaptation with the environment.",
      back:
          "Aniridia ile günlük yaşam, çevreye sürekli uyum sağlamayı gerektirir.",
      list: 'C1',
      answer: 'adaptasyon',
      quest: 'adaptation'),
  Words(
      front: "Students must adhere to the school rules.",
      back: "Öğrenciler okul kurallarına uymalıdır.",
      list: 'C1',
      answer: 'bağlı kalmak',
      quest: 'adhere'),
  Words(
      front: "The two buildings are adjacent to each other.",
      back: "İki bina birbirine komşu.",
      list: 'C1',
      answer: 'komşu',
      quest: 'adjacent'),
  Words(
      front: "The doctor made some adjustments to the medication dosage.",
      back: "Doktor, ilaç dozunda bazı ayarlama yaptı.",
      list: 'C1',
      answer: 'ayarlama',
      quest: 'adjustment'),
  Words(
      front: "The government administers a variety of social programs.",
      back: "Hükümet çeşitli sosyal programları yönetir.",
      list: 'C1',
      answer: 'yönetmek',
      quest: 'administer'),
  Words(
      front: "He works in an administrative role at the university.",
      back: "Üniversitede idari bir görevde çalışıyor.",
      list: 'C1',
      answer: 'idari',
      quest: 'administrative'),
  Words(
      front: "The school principal is the administrator in charge.",
      back: "Okul müdürü sorumlu yönetici.",
      list: 'C1',
      answer: 'yönetici',
      quest: 'administrator'),
  Words(
      front: "He finally made the admission that he had cheated on the exam.",
      back: "Nihayet sınavda kopya çektiğini itiraf etti.",
      list: 'C1',
      answer: 'itiraf',
      quest: 'admission'),
  Words(
      front: "The teenager is going through a difficult adolescent stage.",
      back: "Genç, zor bir ergenlik dönemi yaşıyor.",
      list: 'C1',
      answer: 'ergen',
      quest: 'adolescent'),
  Words(
      front: "The couple decided to pursue adoption to grow their family.",
      back:
          "Çift, ailelerini büyütmek için evlat edinme yoluna gitmeye karar verdi.",
      list: 'C1',
      answer: 'benimseme',
      quest: 'adoption'),
  Words(
      front:
          "The weather forecast predicts adverse weather conditions this weekend.",
      back:
          "Hava durumu tahmini, bu hafta sonu olumsuz hava koşulları öngörüyor.",
      list: 'C1',
      answer: 'olumsuz',
      quest: 'adverse'),
  Words(
      front: "The lawyer advocated for the rights of the refugees.",
      back: "Avukat, mültecilerin haklarını savundu.",
      list: 'C1',
      answer: 'avukat,desteklemek',
      quest: 'advocate'),
  Words(
      front: "He has a great appreciation for the aesthetic beauty of nature.",
      back: "Doğanın estetik güzelliği konusunda büyük bir takdiri var.",
      list: 'C1',
      answer: 'estetik',
      quest: 'aesthetic'),
  Words(
      front: "There was a deep affection between the mother and her child.",
      back: "Anne ile çocuğu arasında derin bir sevgi vardı.",
      list: 'C1',
      answer: 'alaka,etkileme',
      quest: 'affection'),
  Words(
      front:
          "The aftermath of the war left a trail of destruction and despair.",
      back: "Savaşın akıbeti, yıkım ve umutsuzluk izi bıraktı.",
      list: 'C1',
      answer: 'akıbet',
      quest: 'aftermath'),
  Words(
      front:
          "During such moments the child is in extreme aggression and frustration.",
      back:
          "Bu gibi anlarda çocuk aşırı saldırganlık ve hayal kırıklığı içindedir.",
      list: 'C1',
      answer: 'saldırganlık',
      quest: 'aggression'),
  Words(
      front:
          "He works in the agricultural sector, growing fruits and vegetables.",
      back: "Tarım sektöründe çalışıyor, meyve ve sebze yetiştiriyor.",
      list: 'C1',
      answer: 'tarım',
      quest: 'agricultural'),
  Words(
      front: "The king's advisor was a trusted aide who offered him counsel.",
      back: "Kralın danışmanı, ona öğüt veren güvenilir bir yardımcısıydı.",
      list: 'C1',
      answer: 'emir kulu',
      quest: 'aide'),
  Words(
      front: "The plan has some flaws, albeit minor ones.",
      back: "Planın bazı kusurları var, yine de önemsiz.",
      list: 'C1',
      answer: 'yine',
      quest: 'albeit'),
  Words(
      front: "The fire alarm went off, alerting everyone to the danger.",
      back: "Yangın alarmı çaldı ve herkesi tehlikeden haberdar etti.",
      list: 'C1',
      answer: 'alarma geçmek',
      quest: 'alert'),
  Words(
      front: "Have you ever seen a movie about aliens from outer space?",
      back: "Uzaylılar hakkında uzaydan bir film gördünüz mü?",
      list: 'C1',
      answer: 'uzaylı',
      quest: 'alien'),
  Words(
      front: "The soldiers aligned themselves in a straight line.",
      back: "Askerler kendilerini düz bir çizgi halinde sıraladılar.",
      list: 'C1',
      answer: 'sıralanmak',
      quest: 'align'),
  Words(
      front: "The alignment of the planets is a rare astronomical phenomenon.",
      back: "Gezegenlerin hizalanması nadir bir astronomi olayıdır.",
      list: 'C1',
      answer: 'sıra',
      quest: 'alignment'),
  Words(
      front:
          "They are alike in many ways, but they also have some differences.",
      back: "Birçok yönden benzeşiyorlar, ancak bazı farklılıkları da var.",
      list: 'C1',
      answer: 'benzeyen',
      quest: 'alike'),
  Words(
      front:
          "The police are investigating the allegations of corruption against the politician.",
      back: "Polis, siyasetçiye yönelik yolsuzluk suçlamalarını araştırıyor.",
      list: 'C1',
      answer: 'suçlama',
      quest: 'allegation'),
  Words(
      front: "He alleged that the company was mistreating its employees.",
      back: "Şirketin çalışanlarına kötü muamele ettiğini iddia etti.",
      list: 'C1',
      answer: 'iddia etmek',
      quest: 'allege'),
  Words(
      front: "The politician was allegedly involved in a bribery scandal.",
      back: "Siyasetçi, iddiaya göre bir rüşvet skandalına karışmıştı.",
      list: 'C1',
      answer: 'iddiaya göre',
      quest: 'allegedly'),
  Words(
      front:
          "The two countries formed a strong alliance to defend against a common enemy.",
      back:
          "İki ülke, ortak bir düşmana karşı savunmak için güçlü bir ittifak kurdu.",
      list: 'C1',
      answer: 'antlaşma',
      quest: 'alliance'),
  Words(
      front:
          "The teacher gave each student a small allowance for school supplies.",
      back: "Öğretmen, her öğrenciye okul malzemeleri için az bir izin verdi.",
      list: 'C1',
      answer: 'izin',
      quest: 'allowance'),
  Words(
      front: "Tom is my ally at the company. ",
      back: "Tom şirkette benim dostumdur.",
      list: 'C1',
      answer: 'müttefik, dost',
      quest: 'ally'),
  Words(
      front:
          "The ambassador represents her country's interests in a foreign nation.",
      back: "Büyükelçi, ülkesinin çıkarlarını yabancı bir ülkede temsil eder.",
      list: 'C1',
      answer: 'elçi',
      quest: 'ambassador'),
  Words(
      front: "The legislators are proposing amendments to the tax code.",
      back: "Yasama organı üyeleri, vergi kodunda değişiklikler öneriyor.",
      list: 'C1',
      answer: 'düzeltmek',
      quest: 'amend'),
  Words(
      front: "The amendment to the constitution failed to pass.",
      back: "Anayasaya getirilen değişiklik kabul edilmedi.",
      list: 'C1',
      answer: 'yasayı değiştirme',
      quest: 'amendment'),
  Words(
      front: "He felt lost amid the chaos of the city.",
      back: "Şehrin karmaşası içinde kendini kaybolmuş hissetti.",
      list: 'C1',
      answer: 'arasında',
      quest: 'amid'),
  Words(
      front:
          "The teacher used an analogy to explain a complex scientific concept.",
      back:
          "Öğretmen, karmaşık bir bilimsel kavramı açıklamak için mukayese kullandı.",
      list: 'C1',
      answer: 'mukayese',
      quest: 'analogy'),
  Words(
      front: "The ship dropped anchor in the calm bay.",
      back: "Gemi, sakin koyda demir attı.",
      list: 'C1',
      answer: 'demir atmak',
      quest: 'anchor'),
  Words(
      front:
          "Many cultures depict angels as winged beings with a divine purpose.",
      back:
          "Birçok kültür, melekleri ilahi bir amaçla kanatlı varlıklar olarak tasvir eder.",
      list: 'C1',
      answer: 'melek',
      quest: 'angel'),
  Words(
      front:
          "The author chose to remain anonymous and did not reveal their identity.",
      back: "Yazar anonim kalmayı tercih etti ve kimliğini açıklamadı.",
      list: 'C1',
      answer: 'anonim',
      quest: 'anonymous'),
  Words(
      front:
          "The scientist invented a new apparatus to measure the speed of light.",
      back: "Bilim insanı, ışık hızını ölçmek için yeni bir cihaz icat etti.",
      list: 'C1',
      answer: 'vasıta',
      quest: 'apparatus'),
  Words(
      front: "The delicious food was very appealing to his appetite.",
      back: "Lezzetli yemek iştahına çok çekici geliyordu.",
      list: 'C1',
      answer: 'iştah',
      quest: 'appetite'),
  Words(
      front:
          "The audience applauded thunderously after the singer's performance.",
      back: "Şarkıcının performansından sonra seyirci coşkuyla alkışladı.",
      list: 'C1',
      answer: 'alkışlamak',
      quest: 'applaud'),
  Words(
      front: "These safety regulations are not applicable to all situations.",
      back:
          "Bu güvenlik yönetmelikleri tüm durumlar için uygulanabilir değildir.",
      list: 'C1',
      answer: 'uygulanabilir',
      quest: 'applicable'),
  Words(
      front: "The board of directors appointed a new CEO to lead the company.",
      back: "Yönetim kurulu şirketi yönetecek yeni bir CEO atadı.",
      list: 'C1',
      answer: 'atamak',
      quest: 'appoint'),
  Words(
      front: "She expressed her appreciation for the thoughtful gift.",
      back: "Düşünceli hediye için takdirini ifade etti.",
      list: 'C1',
      answer: 'takdir',
      quest: 'appreciation'),
  Words(
      front: "The judge's decision seemed arbitrary and unfair.",
      back: "Hakimin kararı keyfi ve haksız görünüyordu.",
      list: 'C1',
      answer: 'keyfi',
      quest: 'arbitrary'),
  Words(
      front:
          "The building's architectural design is both impressive and functional.",
      back: "Binanın mimari tasarımı hem etkileyici hem de işlevseldir.",
      list: 'C1',
      answer: 'mimarlığa ait',
      quest: 'architectural'),
  Words(
      front:
          "Important documents are stored in the company archives for future reference.",
      back:
          "Önemli belgeler, gelecekte referans olması için şirket arşivlerinde saklanmaktadır.",
      list: 'C1',
      answer: 'arşiv',
      quest: 'archive'),
  Words(
      front: "He is arguably the greatest basketball player of all time.",
      back: "Muhakkak ki tüm zamanların en iyi basketbol oyuncusudur.",
      list: 'C1',
      answer: 'muhtemelen',
      quest: 'arguably'),
  Words(
      front: "He raised his arm to signal for a taxi.",
      back: "Taksi çağırmak için kolunu kaldırdı.",
      list: 'C1',
      answer: 'kol',
      quest: 'arm'),
  Words(
      front: "The programmer created a complex array to store the data.",
      back: "Programcı, verileri depolamak için karmaşık bir dizi oluşturdu.",
      list: 'C1',
      answer: 'sıralamak',
      quest: 'array'),
  Words(
      front: "She was unable to articulate her thoughts clearly.",
      back: "Düşüncelerini net bir şekilde ifade edemedi.",
      list: 'C1',
      answer: 'söylemek',
      quest: 'articulate'),
  Words(
      front: "The fireplace was filled with ashes after the fire died down.",
      back: "Ateş söndükten sonra şömine kül doldu.",
      list: 'C1',
      answer: 'kül',
      quest: 'ash'),
  Words(
      front: "She has a strong aspiration to become a doctor and help people.",
      back: "Doktor olmak ve insanlara yardım etmek için büyük bir hevesi var.",
      list: 'C1',
      answer: 'büyük amaç',
      quest: 'aspiration'),
  Words(
      front:
          "He aspires to travel the world and experience different cultures.",
      back:
          "Dünyayı gezmek ve farklı kültürleri deneyimlemek için hevesleniyor.",
      list: 'C1',
      answer: 'heveslenmek',
      quest: 'aspire'),
  Words(
      front:
          "The assassination of the political leader plunged the country into chaos.",
      back: "Siyasi liderin suikastı, ülkeyi kaosa sürükledi.",
      list: 'C1',
      answer: 'suikast',
      quest: 'assassination'),
  Words(
      front: "The robber assaulted the old woman and stole her purse.",
      back: "Soyguncu yaşlı kadına saldırdı ve çantasını çaldı.",
      list: 'C1',
      answer: 'saldırmak',
      quest: 'assault'),
  Words(
      front:
          "The workers assembled in the factory to discuss their working conditions.",
      back: "İşçiler çalışma koşullarını görüşmek üzere fabrikada toplandılar.",
      list: 'C1',
      answer: 'toplaşmak',
      quest: 'assemble'),
  Words(
      front:
          "There will be a school assembly tomorrow morning to announce the new schedule.",
      back: "Yeni programı duyurmak için yarın sabah okul toplantısı olacak.",
      list: 'C1',
      answer: 'toplantı',
      quest: 'assembly'),
  Words(
      front:
          "He asserted his dominance in the competition and won first place.",
      back: "Yarışmada hakimiyetini sürdürdü ve birinci oldu.",
      list: 'C1',
      answer: 'öne sürmek',
      quest: 'assert'),
  Words(
      front: "The lawyer made a strong assertion that his client was innocent.",
      back:
          "Avukat, müvekkilinin masum olduğuna dair güçlü bir iddia ortaya attı.",
      list: 'C1',
      answer: 'iddia',
      quest: 'assertion'),
  Words(
      front:
          "The therapist offered him reassurance and helped him manage his anxiety.",
      back:
          "Terapist ona güvence verdi ve kaygısıyla başa çıkmasına yardım etti.",
      list: 'C1',
      answer: 'güvence',
      quest: 'assurance'),
  Words(
      front:
          "The refugees sought asylum in a neighboring country to escape the war.",
      back:
          "Mülteciler savaşa kaçmak için komşu bir ülkede sığınma hakkı aradılar.",
      list: 'C1',
      answer: 'barınak',
      quest: 'asylum'),
  Words(
      front:
          "The war crimes committed by the soldiers were considered atrocities.",
      back: "Askerlerin işlediği savaş suçları vahşet olarak kabul edildi.",
      list: 'C1',
      answer: 'berbatlık',
      quest: 'atrocity'),
  Words(
      front:
          "Through hard work and dedication, she finally attained her goal of becoming a lawyer.",
      back:
          "Çok çalışarak ve özveriyle nihayet avukat olma hedefini gerçekleştirdi.",
      list: 'C1',
      answer: 'elde etmek',
      quest: 'attain'),
  Words(
      front: "John has hired an attorney to handle his divorce proceedings.",
      back: "John, boşanma sürecini yönetmesi için bir avukat tuttu.",
      list: 'C1',
      answer: 'avukat',
      quest: 'attorney'),
  Words(
      front: "He attributed his success to hard work and perseverance.",
      back: "Başarısını sıkı çalışmaya ve azme bağladı.",
      list: 'C1',
      answer: 'bağlamak',
      quest: 'attribute'),
  Words(
      front:
          "The company is undergoing an audit to ensure its financial records are accurate.",
      back:
          "Şirket, mali kayıtlarının doğru olduğundan emin olmak için denetimden geçiyor.",
      list: 'C1',
      answer: 'hesapları denetlemek',
      quest: 'audit'),
  Words(
      front:
          "The antique furniture store sells authentic pieces from different historical periods.",
      back:
          "Antika mobilya mağazası, farklı tarih dönemlerinden orijinal parçalar satıyor.",
      list: 'C1',
      answer: 'özgün',
      quest: 'authentic'),
  Words(
      front:
          "The manager is not authorized to make such a large purchase without approval.",
      back:
          "Müdür, onay almadan bu kadar büyük bir satın alma işlemi yapmaya yetkili değildir.",
      list: 'C1',
      answer: 'yetki vermek',
      quest: 'authorize'),
  Words(
      front: "He arrived at the meeting in a luxury auto.",
      back: "Toplantıya lüks bir otomobil ile geldi.",
      list: 'C1',
      answer: 'otomobil',
      quest: 'auto'),
  Words(
      front:
          "Scotland has a strong movement for autonomy from the United Kingdom.",
      back:
          "İskoçya, Birleşik Krallık'tan özerklik için güçlü bir harekete sahip.",
      list: 'C1',
      answer: 'özerklik',
      quest: 'autonomy'),
  Words(
      front:
          "We will check the availability of the rooms before booking our vacation.",
      back:
          "Tatilimizi rezerve etmeden önce odaların müsaitliğini kontrol edeceğiz.",
      list: 'C1',
      answer: 'geçerlilik',
      quest: 'availability'),
  Words(
      front: "He is eagerly awaiting the results of his job application.",
      back: "İş başvurusunun sonuçlarını heyecanla bekliyor.",
      list: 'C1',
      answer: 'gözlemek',
      quest: 'await'),
  Words(
      front: "The play took place against a backdrop of a bustling city.",
      back: "Oyun, hareketli bir şehrin arka planında gerçekleşti.",
      list: 'C1',
      answer: 'arka fon eklemek',
      quest: 'backdrop'),
  Words(
      front:
          "She received a lot of backing from her family and friends during her difficult time.",
      back: "Zor zamanlarında ailesi ve arkadaşlarından çok destek aldı.",
      list: 'C1',
      answer: 'yardım',
      quest: 'backing'),
  Words(
      front:
          "He always keeps a backup of his important files in case of a computer crash.",
      back:
          "Bilgisayar çökmesi durumunda önemli dosyalarının her zaman bir yedeğini tutar.",
      list: 'C1',
      answer: 'yedek',
      quest: 'backup'),
  Words(
      front:
          "The suspect was released on bail after paying a large sum of money.",
      back:
          "Şüpheli, yüklü bir miktar para ödeyerek kefaletle serbest bırakıldı.",
      list: 'C1',
      answer: 'kefalet',
      quest: 'bail'),
  Words(
      front:
          "Voters cast their ballots in the election for their preferred candidate.",
      back:
          "Seçmenler, oy pusulalarını seçtikleri aday için seçimde kullandılar.",
      list: 'C1',
      answer: 'oy vermek',
      quest: 'ballot'),
  Words(
      front:
          "The protesters held banners with slogans demanding social justice.",
      back:
          "Protestocular, sosyal adalet talep eden sloganlar bulunan pankartlar taşıdılar.",
      list: 'C1',
      answer: 'pankart',
      quest: 'banner'),
  Words(
      front: "He barely escaped the accident with just a few scratches.",
      back: "Kazadan sadece birkaç sıyrıkla zar zor kurtuldu.",
      list: 'C1',
      answer: 'çıkarmak',
      quest: 'bare'),
  Words(
      front:
          "The pirates buried their treasure in a barrel on a deserted island.",
      back: "Korsanlar hazinelerini ıssız bir adada bir varile gömdüler.",
      list: 'C1',
      answer: 'varil',
      quest: 'barrel'),
  Words(
      front: "The baseball player swung the bat and hit a home run.",
      back: "Beyzbol oyuncusu sopayı salladı ve bir sayılık home run yaptı.",
      list: 'C1',
      answer: 'yarasa',
      quest: 'bat'),
  Words(
      front:
          "The soldiers bravely fought on the battlefield despite the dangers.",
      back: "Askerler tehlikelere rağmen savaş alanında cesurca savaştılar.",
      list: 'C1',
      answer: 'savaş alanı',
      quest: 'battlefield'),
  Words(
      front: "The winner of the race will be crowned with a laurel bay wreath.",
      back:
          "Yarışın kazananı defne yapraklarından oluşan bir çelenkle taçlandırılacak.",
      list: 'C1',
      answer: 'defne',
      quest: 'bay'),
  Words(
      front:
          "The scientist studied the properties of light beams using a laser.",
      back:
          "Bilim insanı, lazer kullanarak ışık ışınlarının özelliklerini inceledi.",
      list: 'C1',
      answer: 'ışın',
      quest: 'beam'),
  Words(
      front:
          "The fairy tale depicted a fearsome beast guarding a hidden treasure.",
      back:
          "Masal, gizli bir hazineyi koruyan korkunç bir canavarı tasvir ediyordu.",
      list: 'C1',
      answer: 'hayvan',
      quest: 'beast'),
  Words(
      front: "The lawyer spoke on behalf of his client in court.",
      back: "Avukat, mahkemede müvekkili adına konuştu.",
      list: 'C1',
      answer: 'biri adına',
      quest: 'behalf'),
  Words(
      front:
          "She is her beloved grandmother, and they have a very close relationship.",
      back: "O, sevgili büyükannesi ve çok yakın bir ilişkileri var.",
      list: 'C1',
      answer: 'sevgili',
      quest: 'beloved'),
  Words(
      front: "He sat on a park bench and enjoyed the sunshine.",
      back: "Parktaki bir sıraya oturdu ve güneşin tadını çıkardı.",
      list: 'C1',
      answer: 'sıra',
      quest: 'bench'),
  Words(
      front:
          "This new software program sets the benchmark for performance in its category.",
      back:
          "Bu yeni yazılım programı, kendi kategorisinde performans için bir değerlendirme standardı oluşturuyor.",
      list: 'C1',
      answer: 'değerlendirme',
      quest: 'benchmark'),
  Words(
      front: "The lost treasure is hidden somewhere beneath the castle ruins.",
      back: "Kayıp hazine, kale kalıntılarının altında bir yerde gizlidir.",
      list: 'C1',
      answer: 'altında',
      quest: 'beneath'),
  Words(
      front:
          "The scholarship will be awarded to the most deserving beneficiary.",
      back: "Burs, en hak sahibi olan kişiye verilecektir.",
      list: 'C1',
      answer: 'hak sahibi',
      quest: 'beneficiary'),
  Words(
      front: "He felt betrayed by his closest friend who revealed his secret.",
      back:
          "En yakın arkadaşı sırrını açıklayarak ona ihanet ettiğini hissetti.",
      list: 'C1',
      answer: 'ihanet etmek',
      quest: 'betray'),
  Words(
      front:
          "Please bind together all the magazines and newspapers with some string.",
      back: "Lütfen tüm dergi ve gazeteleri bir iple birbirine bağlayın.",
      list: 'C1',
      answer: 'bağlamak',
      quest: 'bind'),
  Words(
      front:
          "The biography tells the story of the famous scientist's life and achievements.",
      back:
          "Biyografi, ünlü bilim insanının hayatını ve başarılarını anlatan bir yaşam öyküsüdür.",
      list: 'C1',
      answer: 'yaşam öyküsü',
      quest: 'biography'),
  Words(
      front:
          "The chess piece called the bishop can move diagonally across the board.",
      back:
          "Piskopos adı verilen satranç taşı, tahtada çapraz olarak hareket edebilir.",
      list: 'C1',
      answer: 'piskopos',
      quest: 'bishop'),
  Words(
      front: "The movie had a bizarre plot with strange characters and events.",
      back:
          "Filmin, garip karakterler ve olaylar içeren acayip bir konusu vardı.",
      list: 'C1',
      answer: 'garip',
      quest: 'bizarre'),
  Words(
      front: "The knife had a sharp blade that could easily cut through meat.",
      back: "Bıçağın etleri kolayca kesebilecek keskin bir ağzı vardı.",
      list: 'C1',
      answer: 'bıçak ağzı',
      quest: 'blade'),
  Words(
      front:
          "The explosion caused a loud blast that shattered windows in nearby buildings.",
      back:
          "Patlama, yakındaki binalardaki pencereleri parçalayan yüksek sesli bir gürültüye neden oldu.",
      list: 'C1',
      answer: 'büyük patlama',
      quest: 'blast'),
  Words(
      front: "The injured athlete continued to bleed after the accident.",
      back: "Yaralanan sporcu kaza sonrası kan kaybetmeye devam etti.",
      list: 'C1',
      answer: 'para sızdırmak',
      quest: 'bleed'),
  Words(
      front:
          "The artist skillfully blended different colors to create a beautiful painting.",
      back:
          "Sanatçı, güzel bir resim oluşturmak için farklı renkleri ustaca karıştırdı.",
      list: 'C1',
      answer: 'karıştırmak',
      quest: 'blend'),
  Words(
      front: "She blessed her children before they left for school.",
      back: "Çocukları okula gitmeden önce kutsadı.",
      list: 'C1',
      answer: 'kutsamak',
      quest: 'bless'),
  Words(
      front: "Good health and happiness are considered blessings in life.",
      back: "Sağlık ve mutluluk, hayattaki nimetler olarak kabul edilir.",
      list: 'C1',
      answer: 'nimet',
      quest: 'blessing'),
  Words(
      front:
          "He avoided boasting about his achievements, even though he was very proud.",
      back: "Her ne kadar çok gurur duysa da başarılarıyla övünmekten kaçındı.",
      list: 'C1',
      answer: 'övünmek',
      quest: 'boast'),
  Words(
      front:
          "He received a bonus at the end of the year for his outstanding work performance.",
      back: "Yıl sonunda olağanüstü iş performansı nedeniyle bir bonus aldı.",
      list: 'C1',
      answer: 'bonus',
      quest: 'bonus'),
  Words(
      front: "The loud boom of thunder startled everyone in the house.",
      back: "Yüksek sesli gürültü herkesi korkuttu.",
      list: 'C1',
      answer: 'patlama sesi',
      quest: 'boom'),
  Words(
      front: "The ball bounced high in the air after it was thrown.",
      back: "Top atıldıktan sonra havaya vurdu.",
      list: 'C1',
      answer: 'sektirmek',
      quest: 'bounce'),
  Words(
      front: "The Rhine is the boundary between France and Germany.",
      back: "Ren nehri Fransa ve Almanya arasındaki sınırdır..",
      list: 'C1',
      answer: 'sınır',
      quest: 'boundary'),
  Words(
      front: "The archer elegantly drew her bow and released the arrow.",
      back: "Okçu zarif bir şekilde yayını çekti ve oku bıraktı.",
      list: 'C1',
      answer: 'yay',
      quest: 'bow'),
  Words(
      front:
          "The company is taking legal action against them for breach of contract.",
      back:
          "Şirket, sözleşme ihlali nedeniyle onlara karşı yasal işlem başlatıyor.",
      list: 'C1',
      answer: 'uymama',
      quest: 'breach'),
  Words(
      front: "His car suffered a complete breakdown on the highway.",
      back: "Arabası otoyolda tamamen bozuldu.",
      list: 'C1',
      answer: 'bozulma',
      quest: 'breakdown'),
  Words(
      front:
          "The scientific breakthrough led to significant advancements in medical treatment.",
      back: "Bilimsel ilerleme, tıbbi tedavide önemli gelişmelere yol açtı.",
      list: 'C1',
      answer: 'ilerleme',
      quest: 'breakthrough'),
  Words(
      front: "I'm trying to grow a new breed of tomato.",
      back: "Yeni bir domates türü yetiştirmeye çalışıyorum.",
      list: 'C1',
      answer: 'cins',
      quest: 'breed'),
  Words(
      front:
          "He signed up for a broadband internet connection to enjoy faster download speeds.",
      back:
          "Daha hızlı indirme hızlarından yararlanmak için genişbant internet bağlantısına kaydoldu.",
      list: 'C1',
      answer: 'genişbant',
      quest: 'broadband'),
  Words(
    front: "He used a web browser to surf the internet on his computer.",
    back: "Bilgisayarında internette gezinmek için bir tarayıcı kullandı.",
    list: "C1",
    answer: "tarayıcı",
    quest: "browser",
  ),

  Words(
    front: "This was a particularly brutal and cowardly attack",
    back: "Bu özellikle vahşi ve korkakça bir saldırıydı",
    list: "C1",
    answer: "vahşi",
    quest: "brutal",
  ),

  Words(
    front: "He needs a good buddy to help him with this task.",
    back: "Bu işte ona yardım edecek iyi bir ahbap gerekiyor.",
    list: "C1",
    answer: "ahbap",
    quest: "buddy",
  ),

  Words(
    front: "The technician added a buffer to prevent data overflow.",
    back: " teknisyen, veri taşmasının önüne geçmek için tampon ekledi.",
    list: "C1",
    answer: "tampon",
    quest: "buffer",
  ),

  Words(
    front: "He bulked up for the upcoming boxing match.",
    back: "Yaklaşan boks maçı için kas yaptı.",
    list: "C1",
    answer: "büyütmek",
    quest: "bulk",
  ),

  Words(
    front: "He felt burdened by his responsibilities.",
    back: "Sorumluluklarının ağırlığı altında eziliyordu.",
    list: "C1",
    answer: "sırtına yüklemek",
    quest: "burden",
  ),

  Words(
    front: "The complex bureaucracy slowed down the process.",
    back: "Karmaşık bürokrasi süreci yavaşlattı.",
    list: "C1",
    answer: "bürokrasi",
    quest: "bureaucracy",
  ),

  Words(
    front: "The Pharaoh's burial was filled with treasures.",
    back: "Firavun'un gömme töreni hazinelerle doluydu.",
    list: "C1",
    answer: "gömme",
    quest: "burial",
  ),

  Words(
    front: "The balloon suddenly burst in mid-air.",
    back: "Balon aniden havada patladı.",
    list: "C1",
    answer: "patlamak",
    quest: "burst",
  ),

  Words(
    front: "He organized his tools in a neat cabinet.",
    back: "Aletlerini düzgün bir dolaba yerleştirdi.",
    list: "C1",
    answer: "dolap",
    quest: "cabinet",
  ),

  Words(
    front: "He made complex calculations to solve the problem.",
    back: "Sorunu çözmek için karmaşık hesaplamalar yaptı.",
    list: "C1",
    answer: "hesaplama",
    quest: "calculation",
  ),

  Words(
    front: "The artist used a canvas to paint his masterpiece.",
    back: "Sanatçı, başyapıtını boyamak için bir tuval kullandı.",
    list: "C1",
    answer: "tuval",
    quest: "canvas",
  ),

  Words(
    front: "She demonstrated her capability to lead the team.",
    back: "Takımı yönetme kabiliyetini gösterdi.",
    list: "C1",
    answer: "kabiliyet",
    quest: "capability",
  ),

  Words(
    back: "Gemi, büyük miktarda kargo taşıyordu.",
    front: "The ship was carrying a large amount of cargo.",
    list: "C1",
    answer: "kargo",
    quest: "cargo",
  ),

  Words(
    back: "Malların taşınması için lojistik şirketiyle anlaştı.",
    front: "He contracted a logistics company for the carriage of goods.",
    list: "C1",
    answer: "taşımacılık",
    quest: "carriage",
  ),

  Words(
    back: "Heykeltraş, mermeri dikkatlice oydu.",
    front: "The sculptor carefully carved the marble.",
    list: "C1",
    answer: "oymak",
    quest: "carve",
  ),

  Words(
    back: "Kazanmayı seven arkadaşıyla birlikte casinoya gitti.",
    front: "He went to the casino with his friend who loves to gamble.",
    list: "C1",
    answer: "kumarhane",
    quest: "casino",
  ),

  Words(
    back: "Bu gece acil serviste çalışan nöbetçi doktor John.",
    front: "The on-call doctor working in casualty tonight is John.",
    list: "C1",
    answer: "acil servis",
    quest: "casualty",
  ),

  Words(
    front: "He looked at the furniture store's catalogue to buy furniture.",
    back: "Mobilya almak için mobilya mağazasının kataloğuna baktı.",
    list: "C1",
    answer: "katalog",
    quest: "catalogue",
  ),

  Words(
    back: "Parti için yiyecek ve içecek temin etti.",
    front: "He catered food and drinks for the party.",
    list: "C1",
    answer: "temin etmek",
    quest: "cater",
  ),

  Words(
    back: "Çiftlikteki sığırlar sağlıklı görünüyordu.",
    front: "The cattle on the farm looked healthy.",
    list: "C1",
    answer: "sığır",
    quest: "cattle",
  ),

  Words(
    back:
        "Bir okula yakın olduğundan bu bölgede dikkatli araç kullanmalısınız.",
    front:
        "You should drive with caution in this area because it is close to a school.",
    list: "C1",
    answer: "dikkat",
    quest: "caution",
  ),

  Words(
    back: "Tedbirli bir insan olduğu için her zaman bir planı vardı.",
    front: "As a cautious person, he always had a plan.",
    list: "C1",
    answer: "tedbirli",
    quest: "cautious",
  ),

  Words(
    back: "Artık şikayetleri dinlemekten vazgeçti.",
    front: "He finally ceased listening to the complaints.",
    list: "C1",
    answer: "son vermek",
    quest: "cease",
  ),
  Words(
    front: "Visitors showed respect while walking through the cemetery.",
    back: "Ziyaretçiler, mezarlıkta dolaşırken saygı gösterdi.",
    list: "C1",
    answer: "mezarlık",
    quest: "cemetery",
  ),

  Words(
    front: "A specially designed chamber was used for the experiment.",
    back: "Deney için özel olarak tasarlanmış bir chamber kullanıldı.",
    list: "C1",
    answer: "oda",
    quest: "chamber",
  ),

  Words(
    front: "It was impossible to find anything due to the chaos in the room.",
    back: "Odadaki karmaşa nedeniyle bir şey bulmak imkansızdı.",
    list: "C1",
    answer: "karmaşa",
    quest: "chaos",
  ),

  Words(
    front:
        "If we need to characterize Roman's personality, he is a loyal and honest person.",
    back:
        "Romanın kişiliğini nitelendirmek gerekirse, o sadık ve dürüst bir insandır.",
    list: "C1",
    answer: "nitelendirmek",
    quest: "characterize",
  ),

  Words(
    front: "He was captivated by the charm of an old building.",
    back: "Eski bir binanın cazibesine kapıldı.",
    list: "C1",
    answer: "cazibe",
    quest: "charm",
  ),

  Words(
    back: "Şirket, yeni buluşu için patent vermek için başvuruda bulundu.",
    front: "The company applied for a charter to patent their new invention.",
    list: "C1",
    answer: "patent vermek",
    quest: "charter",
  ),

  Words(
    back: "Hastalığı kronikti ve tedavisi zordu.",
    front: "His illness was chronic and difficult to treat.",
    list: "C1",
    answer: "kronik",
    quest: "chronic",
  ),

  Words(
    back: "Büyük bir bilgi yığını ile karşı karşıya kaldı.",
    front: "He was faced with a huge chunk of information.",
    list: "C1",
    answer: "yığın",
    quest: "chunk",
  ),

  Words(
    back: "Haberin gazetelerde dolaşması birkaç gün sürdü.",
    front: "It took a few days for the news to circulate in the newspapers.",
    list: "C1",
    answer: "akımını sağlamak",
    quest: "circulate",
  ),

  Words(
    back: "Derginin geniş bir sürümü vardı.",
    front: "The magazine had a wide circulation.",
    list: "C1",
    answer: "sürüm",
    quest: "circulation",
  ),

  Words(
    back: "Yurttaşlık haklarını korumak önemlidir.",
    front: "It is important to protect citizenship rights.",
    list: "C1",
    answer: "yurttaşlık",
    quest: "citizenship",
  ),

  Words(
    back: "Saldırıya siviller de dahil oldu.",
    front: "The attack also involved civilians.",
    list: "C1",
    answer: "sivil",
    quest: "civilian",
  ),
  Words(
    back: "Cümlede kullanılan kelimelerin berraklığı anlamı netleştirdi.",
    front: "Clarity in the words used in the sentence made the meaning clear.",
    list: "C1",
    answer: "berraklık",
    quest: "Clarity",
  ),

  Words(
    back: "İki fikir çarpışması, çözüme ulaşmayı zorlaştırdı.",
    front: "The clash of two ideas made it difficult to reach a solution.",
    list: "C1",
    answer: "çarpışma",
    quest: "clash",
  ),

  Words(
    back: "Bilim insanları, hayvanları sınıflandırma sistemleri geliştirdiler.",
    front: "Scientists developed classification systems for animals.",
    list: "C1",
    answer: "sınıflandırma",
    quest: "classification",
  ),

  Words(
    back: "Umutsuzluğa tutunmaktan kendini alıkoyamadı.",
    front: "He couldn't stop himself from clinging to hope.",
    list: "C1",
    answer: "tutunmak",
    quest: "cling",
  ),

  Words(
    back: "Doktor, hastayı kapsamlı bir klinik muayeneye aldı.",
    front: "The doctor gave the patient a thorough clinical examination.",
    list: "C1",
    answer: "klinik",
    quest: "clinical",
  ),

  Words(
    back: "Fabrikanın kapanması kasaba sakinleri için yutulması zor bir haptı.",
    front:
        "The closure of the factory was a tough pill to swallow to the town's residents. ",
    list: "C1",
    answer: "kapanma",
    quest: "closure",
  ),

  Words(
    back: "Yıldızlar, gece gökyüzünde kümeler halinde parlıyordu.",
    front: "Stars twinkled in clusters in the night sky.",
    list: "C1",
    answer: "küme",
    quest: "cluster",
  ),

  Words(
    back:
        "Farklı partilerin bir araya gelerek oluşturduğu koalisyon hükümeti kuruldu.",
    front:
        "A coalition government formed by different parties was established.",
    list: "C1",
    answer: "birleşme",
    quest: "coalition",
  ),

  Words(
    back: "Ev, güzel bir sahil kasabasındaydı.",
    front: "The house was in a beautiful coastal town.",
    list: "C1",
    answer: "sahil",
    quest: "coastal",
  ),

  Words(
    back: "Parıltılı bir kokteyl sipariş etti.",
    front: "He ordered a fancy cocktail.",
    list: "C1",
    answer: "kokteyl",
    quest: "cocktail",
  ),

  Words(
    back: "Bilişsel yetenekleri yaşla birlikte azaldı.",
    front: "His cognitive abilities declined with age.",
    list: "C1",
    answer: "bilişsel",
    quest: "cognitive",
  ),

  Words(
    back: "Tatillerimiz tesadüfen aynı zamana denk geldi.",
    front: "Our vacations coincided by chance.",
    list: "C1",
    answer: "kesişme",
    quest: "coincide",
  ),

  Words(
    back: "Projeyi başarıyla tamamlamak için işbirliği yaptılar.",
    front: "They collaborated to successfully complete the project.",
    list: "C1",
    answer: "işbirliği yapma",
    quest: "collaborate",
  ),
  Words(
    back: "Projenin başarısı, ekiplerin mükemmel işbirliğine bağlıydı.",
    front:
        "The success of the project depended on the excellent collaboration of the teams.",
    list: "C1",
    answer: "işbirliği",
    quest: "collaboration",
  ),

  Words(
    back: "Bu başarı kolektif bir çabanın sonucudur.",
    front: "This success was the result of a collective effort. ",
    list: "C1",
    answer: "kolektif",
    quest: "collective",
  ),

  Words(
    front: "The car exploded a few moments after the collision.",
    back: "Araba çarpışmadan birkaç dakika sonra patladı. ",
    list: "C1",
    answer: "çarpışma",
    quest: "collision",
  ),

  Words(
    back: "Osmanlı İmparatorluğu, sömürgeci bir güç olarak görülüyordu.",
    front: "The Ottoman Empire was seen as a colonial power.",
    list: "C1",
    answer: "sömürge",
    quest: "colonial",
  ),

  Words(
    back: "Tanınmış köşe yazarı, güncel olaylar hakkında yorum yazdı.",
    front: "The well-known columnist wrote comments on current events.",
    list: "C1",
    answer: "köşe yazarı",
    quest: "columnist",
  ),

  Words(
    back: "Şiddetli muharebe günlerce sürdü.",
    front: "The fierce combat lasted for days.",
    list: "C1",
    answer: "muharebe",
    quest: "combat",
  ),

  Words(
    back: "Etkinlik sabah saat tam sekizde başlayacaktır.",
    front: "The event will commence at exactly eight in the morning.",
    list: "C1",
    answer: "başlatmak",
    quest: "commence",
  ),

  Words(
    back: "Gazeteci, haber üzerine bir yorum yaptı.",
    front: "The journalist made a commentary on the news.",
    list: "C1",
    answer: "yorum",
    quest: "commentary",
  ),

  Words(
    back: "Spiker, maçın heyecanını yorumcu olarak aktardı.",
    front:
        "The commentator conveyed the excitement of the match as a commentator.",
    list: "C1",
    answer: "yorumcu",
    quest: "commentator",
  ),

  Words(
    back: "Ülke, dış ticaret sayesinde ekonomisini büyüttü.",
    front: "The country grew its economy thanks to commerce.",
    list: "C1",
    answer: "ticaret",
    quest: "commerce",
  ),

  Words(
    back: "Şirket, fuara bir komiser gönderdi.",
    front: "The company sent a commissioner to the fair.",
    list: "C1",
    answer: "delege",
    quest: "commissioner",
  ),

  Words(
    back: "Kahve, dünya çapında önemli bir ticaret metaasıdır.",
    front: "Coffee is an important commodity traded worldwide.",
    list: "C1",
    answer: "alıp satılan şey",
    quest: "commodity",
  ),

  Words(
    back: "Yolculuk boyunca refakatçisi ona destek oldu.",
    front: "His companion supported him throughout the journey.",
    list: "C1",
    answer: "refakatçi",
    quest: "companion",
  ),
  Words(
    back: "Bu iki ürün birbirine kıyaslanabilir.",
    front: "These two products are comparable.",
    list: "C1",
    answer: "kıyaslanabilir",
    quest: "comparable",
  ),

  Words(
    back: "Hayvanlara karşı merhamet göstermeliyiz.",
    front: "We should show compassion towards animals.",
    list: "C1",
    answer: "merhamet",
    quest: "compassion",
  ),

  Words(
    back: "Onu gitmeye zorlamak zorunda kaldım.",
    front: "I had to compel him to go.",
    list: "C1",
    answer: "zorlamak",
    quest: "compel",
  ),

  Words(
    back: "Film, izleyicileri için zorlayıcı bir konuyu ele alıyor.",
    front: "The film tackles a compelling topic for viewers.",
    list: "C1",
    answer: "zorlu",
    quest: "compelling",
  ),

  Words(
    back: "Bu para kayıp malları telafi edecektir.",
    front: "The money will compensate the lost goods.",
    list: "C1",
    answer: "telafi etmek",
    quest: "compensate",
  ),

  Words(
    back: "Uzun çalışma saatleri için ekstra maaş gibi bir telafi hak ediyor.",
    front:
        "He deserves some compensation, like extra pay, for the long working hours.",
    list: "C1",
    answer: "telafi",
    quest: "compensation",
  ),

  Words(
    back: "Yeterliği sayesinde terfi aldı.",
    front: "He got promoted thanks to his competence.",
    list: "C1",
    answer: "yeterlik",
    quest: "competence",
  ),

  Words(
    back: "Bu konuda yetkili birine danışmalısınız.",
    front: "You should consult someone competent in this matter.",
    list: "C1",
    answer: "yetkili",
    quest: "competent",
  ),

  Words(
    back: "Verileri derleyerek bir rapor hazırladı.",
    front: "He compiled a report by compiling the data.",
    list: "C1",
    answer: "derlemek",
    quest: "compile",
  ),

  Words(
    back: "Bu iki renk birbirini tamamlıyor.",
    front: "These two colors complement each other.",
    list: "C1",
    answer: "tamamlamak",
    quest: "complement",
  ),

  Words(
    back: "Konunun karmaşıklığı nedeniyle anlamakta zorlandım.",
    front:
        "I had difficulty understanding due to the complexity of the subject.",
    list: "C1",
    answer: "karmaşıklık",
    quest: "complexity",
  ),

  Words(
    back: "Pastamız orijinal tarife tam olarak uyularak yapılmıştır.",
    front: "Our cake is made in strict compliance with the original recipe.",
    list: "C1",
    answer: "uyma,uyum",
    quest: "compliance",
  ),

  Words(
    back: "İşlemdeki bu komplikasyon çözülmedikçe ilerleyemeyiz.",
    front:
        "We cannot proceed until this complication in the process is resolved.",
    list: "C1",
    answer: "komplikasyon",
    quest: "complication",
  ),
  Words(
    back: "Kurallara boyun eğmek zorunda kaldı.",
    front: "He had to comply with the rules.",
    list: "C1",
    answer: "boyun eğmek",
    quest: "comply",
  ),

  Words(
    back: "Yarışmanın kompozisyonu şu şekildeydi: koşu, yüzme, bisiklet.",
    front:
        "The composition of the competition was as follows: running, swimming, cycling.",
    list: "C1",
    answer: "kompozisyon",
    quest: "composition",
  ),

  Words(
    back: "Tartışmada her iki taraf da bir anlaşmaya vardı.",
    front: "In the argument, both sides reached a compromise.",
    list: "C1",
    answer: "anlaşmak",
    quest: "compromise",
  ),

  Words(
    back: "Bilgisayar, karmaşık hesaplamaları saniyeler içinde yapabilir.",
    front: "The computer can perform complex computations in seconds.",
    list: "C1",
    answer: "hesaplamak",
    quest: "compute",
  ),

  Words(
    back: "Suçunu gizlemeye çalıştı.",
    front: "He tried to conceal his crime.",
    list: "C1",
    answer: "gizlemek",
    quest: "conceal",
  ),

  Words(
    back: "Rakibinin gücünü kabul etmek zorunda kaldı.",
    front: "He had to concede his opponent's strength.",
    list: "C1",
    answer: "kabullenmek",
    quest: "concede",
  ),

  Words(
    back: "Mühendis, yeni bir köprü tasarladı.",
    front: "The engineer conceived a new bridge design.",
    list: "C1",
    answer: "tasarlamak",
    quest: "conceive",
  ),

  Words(
    back: "Soyut bir düşünceyi somutlaştırmak zordur.",
    front: "It is difficult to concretize an abstract conception.",
    list: "C1",
    answer: "düşünce",
    quest: "conception",
  ),

  Words(
    back: "Tartışmada bazı tavizler vermek zorunda kaldık.",
    front: "We had to make some concessions in the discussion.",
    list: "C1",
    answer: "taviz",
    quest: "concession",
  ),

  Words(
    back: "Suçluyu müebbet hapse mahkum ettiler.",
    front: "They condemned the criminal to life imprisonment.",
    list: "C1",
    answer: "mahkum etmek",
    quest: "condemn",
  ),

  Words(
    back: "Doktorlar hastayla konferans yaptılar.",
    front: "The doctors conferred with the patient.",
    list: "C1",
    answer: "müzakere etmek",
    quest: "confer",
  ),

  Words(
    back: "Rahip itirafını dinledi.",
    front: "The priest heard his confession.",
    list: "C1",
    answer: "günah çıkarma",
    quest: "confession",
  ),

  Words(
    back: "Telefonun yeni konfigürasyonu daha kullanışlı.",
    front: "The new configuration of the phone is more user-friendly.",
    list: "C1",
    answer: "biçim",
    quest: "configuration",
  ),
  Words(
    back: "Onu bodrum katına hapsetti.",
    front: "He confined him to the basement.",
    list: "C1",
    answer: "sınırlandırmak",
    quest: "confine",
  ),

  Words(
    back: "Siparişinizin onaylanması için e-posta kontrol edin.",
    front: "Check your email for confirmation of your order.",
    list: "C1",
    answer: "onay",
    quest: "confirmation",
  ),

  Words(
    back: "Polis memuru şüpheliyi suçla yüzleştirdi.",
    front: "The police officer confronted the suspect with the accusation.",
    list: "C1",
    answer: "yüzleştirmek",
    quest: "confront",
  ),

  Words(
    back: "Görüşmedeki sert yüzleşme ortamı gerginliği artırdı.",
    front: "The tense confrontation during the meeting increased the tension.",
    list: "C1",
    answer: "yüzleşme",
    quest: "confrontation",
  ),

  Words(
    back: "Başarısını tebrik etmek için ona çiçek gönderdim.",
    front: "I sent him flowers to congratulate him on his success.",
    list: "C1",
    answer: "tebrik etmek",
    quest: "congratulate",
  ),

  Words(
    back: "Kilisenin cemaati Pazar ayinine katıldı.",
    front: "The congregation of the church attended the Sunday service.",
    list: "C1",
    answer: "topluluk",
    quest: "congregation",
  ),

  Words(
    back: "Kongresel kararın oylanması yarın yapılacak.",
    front: "The voting on the congressional decision will be held tomorrow.",
    list: "C1",
    answer: "kongresel",
    quest: "congressional",
  ),

  Words(
    back: "Romalılar, geniş toprakları fethetti.",
    front: "The Romans conquered vast territories.",
    list: "C1",
    answer: "fethetmek",
    quest: "conquer",
  ),

  Words(
    back: "Vicdanı rahat değildi.",
    front: "His conscience was not clear.",
    list: "C1",
    answer: "vicdan",
    quest: "conscience",
  ),

  Words(
    back: "Bilincinizi kaybettiniz mi?",
    front: "Did you lose consciousness?",
    list: "C1",
    answer: "bilinç",
    quest: "consciousness",
  ),

  Words(
    back: "İki gün üst üste aynı filmi izledim.",
    front: "I watched the same movie two consecutive days.",
    list: "C1",
    answer: "ardışık",
    quest: "consecutive",
  ),

  Words(
    back: "Toplantıda bir fikir birliğine varılmadı.",
    front: "No consensus was reached at the meeting.",
    list: "C1",
    answer: "fikir birliği",
    quest: "consensus",
  ),

  Words(
    back: "Bu projenin yapılması için izniniz gerekiyor.",
    front: "Your consent is required for this project to proceed.",
    list: "C1",
    answer: "razı olmak",
    quest: "consent",
  ),
  Words(
    back: "Enerjiyi korumak için ampulleri değiştirdik.",
    front: "We changed the bulbs to conserve energy.",
    list: "C1",
    answer: "korumak",
    quest: "conserve",
  ),

  Words(
    back: "Davranışlarındaki tutarlılığa hayran kaldım.",
    front: "I admired the consistency in his behavior.",
    list: "C1",
    answer: "tutarlılık",
    quest: "consistency",
  ),

  Words(
    back:
        "Kazanılan başarıyı sağlamlaştırmak için yeni stratejiler geliştirildi.",
    front: "New strategies were developed to consolidate the achieved success.",
    list: "C1",
    answer: "sağlamlaştırmak",
    quest: "consolidate",
  ),

  Words(
    back: "Milletvekili, seçim bölgesindeki halkın sorunlarını dile getirdi.",
    front: "The MP voiced the problems of the people in his constituency.",
    list: "C1",
    answer: "seçim bölgesi",
    quest: "constituency",
  ),

  Words(
    back: "Bu elementler bir atomu oluşturur.",
    front: "These elements constitute an atom.",
    list: "C1",
    answer: "oluşturmak",
    quest: "constitute",
  ),

  Words(
    back: "Ülkenin en yüksek hukuk metni anayasadır.",
    front: "The constitution is the highest legal text of the country.",
    list: "C1",
    answer: "anayasa",
    quest: "constitution",
  ),

  Words(
    back: "Bu karar anayasal mı?",
    front: "Is this decision constitutional?",
    list: "C1",
    answer: "anayasal",
    quest: "constitutional",
  ),

  Words(
    back: "Bütçe kısıtlamaları nedeniyle projeyi tamamlamakta zorlandık.",
    front:
        "We faced difficulties completing the project due to budget constraints.",
    list: "C1",
    answer: "kısıtlama",
    quest: "constraint",
  ),

  Words(
    front: "The doctor had a consultation with the patient.",
    back: "Doktor hastayla bir danışma yaptı.",
    list: "C1",
    answer: "danışma",
    quest: "consultation",
  ),

  Words(
    back: "Gelecek hakkında uzun uzun düşünüp taşındı.",
    front: "He contemplated at length about the future.",
    list: "C1",
    answer: "düşünüp taşınmak",
    quest: "contemplate",
  ),

  Words(
    back: "Davranışlarına karşı aşağılama hissettim.",
    front: "I felt contempt for his behavior.",
    list: "C1",
    answer: "aşağılama",
    quest: "contempt",
  ),

  Words(
    back: "Şampiyonluk için yarışan iki güçlü rakip vardı.",
    front: "There were two strong contenders competing for the championship.",
    list: "C1",
    answer: "rakip",
    quest: "contender",
  ),

  Words(
    back: "Bu konuda uzmanlarla uğraşmak zorunda kaldık.",
    front: "We had to contend with experts on this issue.",
    list: "C1",
    answer: "uğraşmak",
    quest: "contend",
  ),
  Words(
    back: "Web sitesinin içeriğini güncelledik.",
    front: "We updated the content of the website.",
    list: "C1",
    answer: "içerik",
    quest: "content",
  ),

  Words(
    back: "İki takım şampiyonluk için sürekli bir yarışma içindeydi.",
    front: "The two teams were in constant contention for the championship.",
    list: "C1",
    answer: "yarışma",
    quest: "contention",
  ),

  Words(
    back: "Yağmur hiç durmadan yağıyordu.",
    front: "The rain was falling continually.",
    list: "C1",
    answer: "hiç durmadan",
    quest: "continually",
  ),

  Words(
    back: "Bu inşaatın müteahhidi kim?",
    front: "Who is the contractor for this construction?",
    list: "C1",
    answer: "müteahhit",
    quest: "contractor",
  ),

  Words(
    back: "Onun sözleri davranışlarıyla bir tezat oluşturuyor.",
    front: "His words contradict his behavior.",
    list: "C1",
    answer: "tezat",
    quest: "contradict",
  ),

  Words(
    back: "Emirlere zıt hareket etmeyin.",
    front: "Do not act contrary to the orders.",
    list: "C1",
    answer: "zıt",
    quest: "contrary",
  ),

  Words(
    back: "Dergiye düzenli olarak yazı yazar.",
    front: "He is a regular contributor to the magazine.",
    list: "C1",
    answer: "yazar",
    quest: "contributor",
  ),

  Words(
    back: "Paradan elektriğe enerji dönüşümü gerçekleşti.",
    front: "The conversion of energy from money to electricity took place.",
    list: "C1",
    answer: "dönüşüm",
    quest: "conversion",
  ),

  Words(
    back: "Jüri onu suçlu buldu.",
    front: "The jury convicted him.",
    list: "C1",
    answer: "suçlu bulmak",
    quest: "convict",
  ),

  Words(
    back: "Başarıya olan inancını kaybetmedi.",
    front: "He did not lose his conviction in success.",
    list: "C1",
    answer: "inanç",
    quest: "conviction",
  ),

  Words(
    back: "Projeyi tamamlamak için işbirliği yapmak zorundayız.",
    front: "We need to cooperate to complete the project.",
    list: "C1",
    answer: "işbirliği yapmak",
    quest: "cooperate",
  ),

  Words(
    back: "Polis memuru hırsızı yakaladı.",
    front: "The cop caught the thief.",
    list: "C1",
    answer: "polis memuru",
    quest: "cop",
  ),

  Words(
    back: "Kablolar bakırdan yapılmıştır.",
    front: "The cables are made of copper.",
    list: "C1",
    answer: "bakır",
    quest: "copper",
  ),
  Words(
    back: "Yazdığınız eserin telif hakkını korumak önemlidir.",
    front: "It is important to protect the copyright of the work you wrote.",
    list: "C1",
    answer: "telif hakkı",
    quest: "copyright",
  ),

  Words(
    back: "Metindeki düzeltmeleri kırmızı kalemle işaretledim.",
    front: "I marked the corrections in the text with a red pen.",
    list: "C1",
    answer: "düzeltme",
    quest: "correction",
  ),

  Words(
    back: "Romatizma, hareketsiz alışkanlıklar ve zayıflık ile ilişkilidir.",
    front: "Arthritis is correlated with sedentary habits and weakness.",
    list: "C1",
    answer: "ilişkilendirmek",
    quest: "correlate",
  ),

  Words(
    back: "IQ seviyesi ile okul başarısı arasında pozitif bir korelasyon var.",
    front:
        "There is a positive correlation between IQ level and school success.",
    list: "C1",
    answer: "bağlılık",
    quest: "correlation",
  ),

  Words(
    back: "Bu, görüntü dosyasının ne kadar bellek kullandığına karşılık gelir.",
    front: "This corresponds to how much memory the image file uses",
    list: "C1",
    answer: "tekabül etmek",
    quest: "correspond",
  ),

  Words(
    back: "İki yazar arasındaki on yıllık yazışmalar tek bir ciltte toplandı.",
    front:
        "Ten years of correspondence between the two authors was collected into a single volume.",
    list: "C1",
    answer: "yazışma",
    quest: "correspondence",
  ),

  Words(
    back: "Savaş muhabiri, cepheden canlı yayın yaptı.",
    front: "The war correspondent broadcasted live from the front.",
    list: "C1",
    answer: "eş",
    quest: "correspondent",
  ),

  Words(
    back: "Bu gezi çok masraflı olacak.",
    front: "This trip will be very costly.",
    list: "C1",
    answer: "masraflı",
    quest: "costly",
  ),

  Words(
    back: "Meclis üyesi halkın sorunlarını dile getirdi.",
    front: "The councillor voiced the problems of the people.",
    list: "C1",
    answer: "meclis üyesi",
    quest: "councillor",
  ),

  Words(
    back: "Arkadaşım psikolojik danışmaya başladı.",
    front: "My friend started counselling.",
    list: "C1",
    answer: "danışma",
    quest: "counselling",
  ),
  Words(
    back: "Psikolojik sorunlar için bir danışmana danışabilirsiniz.",
    front: "You can consult a counsellor for psychological problems.",
    list: "C1",
    answer: "danışman",
    quest: "counsellor",
  ),

  Words(
    back: "Bankada müşteri sayacı vardı.",
    front: "There was a customer counter at the bank.",
    list: "C1",
    answer: "tezgah,sayaç",
    quest: "counter",
  ),

  Words(
    back:
        "Uluslararası görüşmelerde Türk heyetinin karşılığı İngiliz büyükelçisiydi.",
    front:
        "The British ambassador was the counterpart of the Turkish delegation in international negotiations.",
    list: "C1",
    answer: "meslektaş",
    quest: "counterpart",
  ),

  Words(
    back: "Sayısız insan yoksulluk içinde yaşıyor.",
    front: "Countless people live in poverty.",
    list: "C1",
    answer: "sayısız",
    quest: "Countless",
  ),

  Words(
    back:
        "Devlet başkanının ani ölümü siyasi bir darbe olarak değerlendirildi.",
    front: "The sudden death of the president was considered a political coup.",
    list: "C1",
    answer: "başarılı davranış",
    quest: "coup",
  ),

  Words(
    back: "Çabaları için ona teşekkür etme nezaketini gösterdi.",
    front: "He did have the courtesy to thank her for her efforts.",
    list: "C1",
    answer: "kibarlık",
    quest: "courtesy",
  ),

  Words(
    back: "Eğer değerli bir zanaatınız varsa, her zaman iş bulabilirsiniz.",
    front: "If you have a valuable craft, you can always find work.",
    list: "C1",
    answer: "zanaat",
    quest: "craft",
  ),

  Words(
    back: "Bebek yere doğru süründü.",
    front: "The baby crawled towards the ground.",
    list: "C1",
    answer: "sürünmek",
    quest: "crawl",
  ),

  Words(
    back: "Bu romanın yaratıcısı ünlü bir yazar.",
    front: "The creator of this novel is a famous writer.",
    list: "C1",
    answer: "yaratıcı",
    quest: "creator",
  ),

  Words(
    back: "Bu haber kaynağının güvenilirliği sorgulanıyor.",
    front: "The credibility of this news source is being questioned.",
    list: "C1",
    answer: "güvenilirlik",
    quest: "credibility",
  ),

  Words(
    back: "İddianız inandırıcı değil.",
    front: "Your claim is not credible.",
    list: "C1",
    answer: "inandırıcı",
    quest: "credible",
  ),

// "creep" has the same translation as "sürünmek" depending on the context.
// We can keep the existing translation here.

  Words(
    back: "Filmin yönetmeni filmi sert bir şekilde eleştirdi.",
    front: "The film's director harshly critiqued the film.",
    list: "C1",
    answer: "eleştirmek",
    quest: "critique",
  ),
  Words(
    back: "Kraliçe taç giydi.",
    front: "The queen wore a crown.",
    list: "C1",
    answer: "taç",
    quest: "crown",
  ),

  Words(
    back: "Konuşması çok kaba ve ham bir ifade içeriyordu.",
    front: "His speech contained very crude and rude language.",
    list: "C1",
    answer: "ham",
    quest: "crude",
  ),

  Words(
    back: "Kazandığı başarı hayallerini adeta ezdi.",
    front: "The success he achieved crushed his dreams.",
    list: "C1",
    answer: "ezmek",
    quest: "crush",
  ),

  Words(
    back: "Vazo kristalden yapılmıştı.",
    front: "The vase was made of crystal.",
    list: "C1",
    answer: "kristal",
    quest: "crystal",
  ),

  Words(
    back: "Bu tarikat bazı garip inançlara sahip.",
    front: "This cult has some strange beliefs.",
    list: "C1",
    answer: "tarikat",
    quest: "cult",
  ),

  Words(
    back: "Toprağı ekip biçmek için traktör kullandılar.",
    front: "They used a tractor to cultivate the land.",
    list: "C1",
    answer: "ekip biçmek",
    quest: "cultivate",
  ),

  Words(
    back: "Doğa merakımı cezbetti.",
    front: "Nature piqued my curiosity.",
    list: "C1",
    answer: "merak",
    quest: "curiosity",
  ),

  Words(
    back: "Suçlu şu anda gözaltında.",
    front: "The criminal is currently in custody.",
    list: "C1",
    answer: "gözaltı",
    quest: "custody",
  ),

  Words(
    back: "Dergi, saç kesimi modelleri hakkında bir yazı içeriyordu.",
    front: "The magazine included an article about haircutting styles.",
    list: "C1",
    answer: "kesim",
    quest: "cutting",
  ),

  Words(
    back: "Alaycı bir gülüş attı.",
    front: "He gave a cynical smile.",
    list: "C1",
    answer: "alaycı",
    quest: "cynical",
  ),

  Words(
    back: "Su baskını barajın taşmasına neden oldu.",
    front: "Flooding caused the dam to overflow",
    list: "C1",
    answer: "baraj",
    quest: "dam",
  ),

  Words(
    back: "Sigara içmek sağlığınıza zararlıdır.",
    front: "Smoking is damaging to your health.",
    list: "C1",
    answer: "zarar verici",
    quest: "damaging",
  ),

  Words(
    back: "Şafak vakti gökyüzü kırmızı ve turuncu tonlara bürünür.",
    front: "At dawn, the sky is painted in shades of red and orange.",
    list: "C1",
    answer: "şafak",
    quest: "dawn",
  ),
  Words(
    back: "Yıkılan binanın molozları temizlendi.",
    front: "The debris from the collapsed building was cleared.",
    list: "C1",
    answer: "moloz",
    quest: "debris",
  ),

  Words(
    back: "Genç şarkıcının sahneye ilk çıkışı büyük ilgi çekti.",
    front: "The young singer's debut on stage attracted great attention.",
    list: "C1",
    answer: "sahneye ilk çıkış",
    quest: "debut",
  ),

  Words(
    back: "Etkin karar verme becerileri önemlidir.",
    front: "Effective decision-making skills are important.",
    list: "C1",
    answer: "karar verme",
    quest: "decision-making",
  ),

  Words(
    back: "Kararlı bir liderdi.",
    front: "He was a decisive leader.",
    list: "C1",
    answer: "kararlı",
    quest: "decisive",
  ),

  Words(
    back: "Bağımsızlık beyannamesi imzalandı.",
    front: "The declaration of independence was signed.",
    list: "C1",
    answer: "beyanname",
    quest: "declaration",
  ),

  Words(
    back: "Hayatını bilime adayan bir bilim insanıydı.",
    front: "He was a scientist dedicated to science.",
    list: "C1",
    answer: "özel",
    quest: "dedicated",
  ),

  Words(
    back: "Kitabı en yakın arkadaşına ithaf etti.",
    front: "I really admire Joe's dedication to his work.",
    list: "C1",
    answer: "bağlılık,ithaf",
    quest: "dedication",
  ),

  Words(
    back: "Evin tapusu babamın üzerine.",
    front: "The deed to the house is in my father's name.",
    list: "C1",
    answer: "tapu",
    quest: "deed",
  ),

  Words(
    back: "Onu aptal olarak değerlendirmek doğru değil.",
    front: "It is not right to deem him a fool.",
    list: "C1",
    answer: "tutmak",
    quest: "deem",
  ),

  Words(
    back: "Borcunu ödememesi bir temerrüdtür.",
    front: "His failure to pay the debt is a default.",
    list: "C1",
    answer: "yükümlülüğünü yerine getirmemek",
    quest: "default",
  ),

  Words(
    back: "Yeni aldığım telefonun bir arızası var.",
    front: "There is a defect in the new phone I bought.",
    list: "C1",
    answer: "arıza",
    quest: "defect",
  ),

  Words(
    back: "Kendini savunan bir tavırla konuştu.",
    front: "He spoke in a defensive manner.",
    list: "C1",
    answer: "savunan",
    quest: "defensive",
  ),

  Words(
    back: "Doktor bende vitamin eksikliği olduğunu söyledi.",
    front: "The doctor said I had a vitamin deficiency",
    list: "C1",
    answer: "eksiklik",
    quest: "deficiency",
  ),
  Words(
    back: "Şirket bu yıl büyük bir açık verdi.",
    front: "The company had a big deficit this year.",
    list: "C1",
    answer: "açık(hesaplarda)",
    quest: "deficit",
  ),

  Words(
    back:
        "Asker, düşman esirlerini vurma emrine karşı geldiği için hapsedildi.",
    front:
        "The soldier was imprisoned for defying an order to shoot the enemy captives.",
    list: "C1",
    answer: "karşı gelmek",
    quest: "defy",
  ),

  Words(
    back: "Sendika toplantısına bir temsilci gönderdi.",
    front: "The union sent a delegate to the meeting.",
    list: "C1",
    answer: "temsilci",
    quest: "delegate",
  ),

  Words(
    back: "Yetkilendirme belgesini imzaladı.",
    front: "He signed the delegation document.",
    list: "C1",
    answer: "yetkilendirme",
    quest: "delegation",
  ),

  Words(
    back: "Narin bir vazoydu ve dikkatli bir şekilde ele alınması gerekiyordu.",
    front: "It was a delicate situation and needed to be handled carefully.",
    list: "C1",
    answer: "narin",
    quest: "delicate",
  ),

  Words(
    back: "Şeytan, kötülüğü temsil eder.",
    front: "The demon represents evil.",
    list: "C1",
    answer: "şeytan",
    quest: "demon",
  ),

  Words(
    back:
        "Hastalar, tedavinin tek uygun seçenek olduğunu düşünürlerse, reddini talep edebilirler.",
    front:
        "Patients can appeal denials if they feel that a treatment was the only appropriate option.",
    list: "C1",
    answer: "reddetme",
    quest: "denial",
  ),

  Words(
    back: "Hükümeti insan hakları ihlalleri nedeniyle ihbar etti.",
    front: "He denounced the government for human rights violations.",
    list: "C1",
    answer: "ihbar etmek",
    quest: "denounce",
  ),

  Words(
    back: "Orman, yoğun ağaçlarla kaplıydı.",
    front: "The forest was dense with trees.",
    list: "C1",
    answer: "yoğun",
    quest: "dense",
  ),

  Words(
    back: "Nüfus yoğunluğu kırsal kesimlere göre daha yüksektir.",
    front: "The population density is higher compared to rural areas.",
    list: "C1",
    answer: "yoğunluk",
    quest: "density",
  ),

  Words(
    back: "Başarısı babasına olan bağımlılığını azalttı.",
    front: "His success reduced his dependence on his father.",
    list: "C1",
    answer: "bağlılık",
    quest: "dependence",
  ),

  Words(
    back: "Resim, savaşın dehşetini canlı bir şekilde anlatıyordu.",
    front: "The painting depicted the horrors of war vividly.",
    list: "C1",
    answer: "anlatmak",
    quest: "depict",
  ),

  Words(
    back: "Askerleri savaşa konuşlandırdılar.",
    front: "They deployed the soldiers for the war.",
    list: "C1",
    answer: "açmak",
    quest: "deploy",
  ),
  Words(
    back: "Ordunun konuşlanması savaşı bitirmeyi amaçlıyordu.",
    front: "The deployment of the army aimed to end the war.",
    list: "C1",
    answer: "konuşlanma",
    quest: "deployment",
  ),

  Words(
    back: "Bazı ev sahipleri benzer miktarda depozito talep edebilir.",
    front: "Some landlords may require a deposit of a similar amount.",
    list: "C1",
    answer: "emanet",
    quest: "deposit",
  ),

  Words(
    back: "Yoksulluk, çocukları eğitim imkanlarından mahrum bırakıyor.",
    front: "Poverty deprives children of educational opportunities.",
    list: "C1",
    answer: "mahrum etmek",
    quest: "deprive",
  ),

  Words(
    back: "Milletvekili parlamentoda halkın temsilcisidir.",
    front: "A deputy is a representative of the people in parliament.",
    list: "C1",
    answer: "milletvekili",
    quest: "deputy",
  ),

  Words(
    back: "Kuş yavaş yavaş aşağıya indi.",
    front: "The bird slowly descended.",
    list: "C1",
    answer: "inmek",
    quest: "descend",
  ),

  Words(
    back: "Uçak kazası nedeniyle ani bir düşüş yaşandı.",
    front: "There was a sudden descent due to the plane crash.",
    list: "C1",
    answer: "düşme",
    quest: "descent",
  ),

  Words(
    back: "Yeni CEO olarak onu atadılar.",
    front: "They designated him as the new CEO.",
    list: "C1",
    answer: "atamak",
    quest: "designate",
  ),

  Words(
    back: "Barış, herkes için arzu edilen bir durumdur.",
    front: "Peace is a desirable situation for everyone.",
    list: "C1",
    answer: "arzu edilen",
    quest: "desirable",
  ),

  Words(
    back: "Bilgisayarının masaüstünde bir sürü dosya vardı.",
    front: "There were a lot of files on his computer's desktop.",
    list: "C1",
    answer: "masaüstü",
    quest: "desktop",
  ),

  Words(
    back: "Yıkıcı bir fırtınaydı.",
    front: "It was a destructive storm.",
    list: "C1",
    answer: "yıkıcı",
    quest: "destructive",
  ),

  Words(
    back: "Polis onu sorguya çekmek için alıkoydu.",
    front: "The police detained him for questioning.",
    list: "C1",
    answer: "alıkoymak",
    quest: "detain",
  ),

  Words(
    back:
        "Erken teşhis yöntemleri birçok kanserle mücadelede çok değerli hale gelmiştir.",
    front:
        "Early detection methods have become invaluable in the fight against many cancers.",
    list: "C1",
    answer: "tespit, buluş",
    quest: "detection",
  ),

  Words(
    back: "Suçlu zanlısı şu anda gözaltında ve ifadesi bekleniyor.",
    front: "The suspect is currently in detention and awaiting interrogation.",
    list: "C1",
    answer: "engellenme",
    quest: "detention",
  ),
  Words(
    front:
        "The weather started to deteriorate as soon as we got out of the car.",
    back: "Arabadan iner inmez hava kötüleşmeye başladı.",
    list: "C1",
    answer: "kötüleşmesi",
    quest: "deteriorate",
  ),

  Words(
    front: "The natural disaster devastated the city.",
    back: "Doğal afet şehri harap etti.",
    list: "C1",
    answer: "harap etmek",
    quest: "devastate",
  ),

  Words(
    front: "The devil represents evil.",
    back: "Şeytan, kötülüğü temsil eder.",
    list: "C1",
    answer: "şeytan",
    quest: "devil",
  ),

  Words(
    front: "People devised shelters in order to protect themselves.",
    back: "İnsanlar kendilerini korumak için sığınaklar tasarladılar.",
    list: "C1",
    answer: "tasarlamak,bulmak",
    quest: "devise",
  ),

  Words(
    front: "The doctor diagnosed his illness.",
    back: "Doktor hastalığını teşhis etti.",
    list: "C1",
    answer: "teşhis etmek",
    quest: "diagnose",
  ),

  Words(
    front: "Fashion trends dictate our tastes.",
    back: "Moda trendleri zevklerimizi etkiler.",
    list: "C1",
    answer: "etkilemek",
    quest: "dictate",
  ),

  Words(
    front: "The people rebelled against the oppressive dictator.",
    back: "Ülke diktatör tarafından yönetiliyordu.",
    list: "C1",
    answer: "diktatör",
    quest: "dictator",
  ),

  Words(
    front: "It is important to differentiate between fact and opinion.",
    back: "İki kavram arasındaki farkı açıkladı.",
    list: "C1",
    answer: "farklılaştırmak",
    quest: "differentiate",
  ),

  Words(
    front: "She treated everyone with respect and dignity.",
    back: "Onurunu korudu.",
    list: "C1",
    answer: "itibar",
    quest: "dignity",
  ),

  Words(
    front: "She was caught in a dilemma between her loyalty and her morals.",
    back: "Zor bir karar vermek zorundaydı.",
    list: "C1",
    answer: "açmaz",
    quest: "dilemma",
  ),

  Words(
    front:
        "Scientists are theorizing about the existence of higher dimensions.",
    back: "Heykelin üç boyutu vardır.",
    list: "C1",
    answer: "boyut",
    quest: "dimension",
  ),

  Words(
    front: "He hoped that his symptoms would diminish with medication.",
    back: "Işığın şiddeti uzaklaştıkça azaldı.",
    list: "C1",
    answer: "azalmak",
    quest: "diminish",
  ),

  Words(
    front: "The stock market took a sudden dip.",
    back: "Ekonomi ani bir düşüş yaşadı.",
    list: "C1",
    answer: "batma",
    quest: "dip",
  ),

  Words(
    front: "You can find phone numbers in the phone directory.",
    back: "Telefon numaralarını rehberden bulabilirsin.",
    list: "C1",
    answer: "rehber",
    quest: "directory",
  ),

  Words(
    front: "The earthquake caused a disastrous tsunami.",
    back: "Doğal afet felaket oldu.",
    list: "C1",
    answer: "talihsiz",
    quest: "disastrous",
  ),
  Words(
    front: "It's time to discard the old and broken toys.",
    back: "Eski ve bozuk oyuncakları atmanın zamanı geldi.",
    list: "C1",
    answer: "ayırmak",
    quest: "discard",
  ),

  Words(
    front: "The doctor discharged the patient from the hospital.",
    back: "Doktor hastayı taburcu etti.",
    list: "C1",
    answer: "taburcu etmek",
    quest: "discharge",
  ),

  Words(
    front: "The whistleblower disclosed the company's illegal activities.",
    back: "İfşa eden kişi, şirketin yasadışı faaliyetlerini açığa vurdu.",
    list: "C1",
    answer: "açığa vurmak",
    quest: "disclose",
  ),

  Words(
    front: "The meeting was a productive discourse on the current situation.",
    back: "Toplantı, güncel durum hakkında verimli bir söylemdi.",
    list: "C1",
    answer: "söylem",
    quest: "discourse",
  ),

  Words(
    front: "Use discretion when sharing personal information online.",
    back: "Kişisel bilgilerinizi çevrimiçi paylaşırken incelik gösterin.",
    list: "C1",
    answer: "incelik",
    quest: "discretion",
  ),

  Words(
    front:
        "All employees deserve to be treated with respect, without discrimination.",
    back:
        "Tüm çalışanlar ayrım yapılmadan saygı ile muamele edilmeyi hak eder.",
    list: "C1",
    answer: "ayrım",
    quest: "discrimination",
  ),

  Words(
    front: "He received a dismissal notice from his job.",
    back: "İşinden kovma bildirimi aldı.",
    list: "C1",
    answer: "kovma",
    quest: "dismissal",
  ),

  Words(
    front: "The earthquake displaced thousands of people from their homes.",
    back: "Deprem binlerce insanı yerinden etti.",
    list: "C1",
    answer: "yerinden çıkarmak",
    quest: "displace",
  ),

  Words(
    front: "There are proper procedures for the disposal of hazardous waste.",
    back: "Tehlikeli atıkların imhası için uygun prosedürler vardır.",
    list: "C1",
    answer: "imha etme",
    quest: "disposal",
  ),

  Words(
    front: "Can you dispose of this empty garbage bag?",
    back: "Bu boş çöp poşetini atabilir misin?",
    list: "C1",
    answer: "atmak",
    quest: "dispose",
  ),
  Words(
    front: "They had a dispute over who would pay the bill.",
    back: "Hesabı kimin ödeyeceği konusunda çekiştiler.",
    list: "C1",
    answer: "çekişmek",
    quest: "dispute",
  ),

  Words(
    front: "The construction project disrupted traffic flow in the city.",
    back: "İnşaat projesi şehirdeki trafik akışını aksattı.",
    list: "C1",
    answer: "aksatmak",
    quest: "disrupt",
  ),

  Words(
    front: "The power outage caused widespread disruption.",
    back: "Elektrik kesintisi yaygın bir parçalanmaya neden oldu.",
    list: "C1",
    answer: "parçalanma",
    quest: "disruption",
  ),

  Words(
    front: "Sugar dissolves easily in water.",
    back: "Şeker, suda kolayca erir.",
    list: "C1",
    answer: "eritmek",
    quest: "dissolve",
  ),

  Words(
    front: "It's important to make a distinction between fact and opinion.",
    back: "Gerçek ve fikir arasında ayrım yapmak önemlidir.",
    list: "C1",
    answer: "ayırım",
    quest: "distinction",
  ),

  Words(
    front: "She has a very distinctive laugh.",
    back: "Kendine özgü bir kahkahası var.",
    list: "C1",
    answer: "kendine özgü",
    quest: "distinctive",
  ),

  Words(
    front: "The propaganda distorted the truth about the conflict.",
    back: "Propaganda, çatışma hakkındaki gerçeği saptırdı.",
    list: "C1",
    answer: "saptırmak",
    quest: "distort",
  ),

  Words(
    front: "The financial situation caused them distress.",
    back: "Mali durum onları üzdü.",
    list: "C1",
    answer: "üzmek",
    quest: "distress",
  ),

  Words(
    front: "I found the movie disturbing and violent.",
    back: "Filmi rahatsız edici ve şiddetli buldum.",
    list: "C1",
    answer: "rahatsız etme",
    quest: "disturbing",
  ),

  Words(
    front: "We need to divert resources to the most critical areas.",
    back: "Dikkatleri en kritik alanlara çevirmek gerekiyor.",
    list: "C1",
    answer: "başka yöne çevirmek",
    quest: "divert",
  ),

  Words(
    front: "Many religions believe in a divine power.",
    back: "Pek çok din kutsal bir güce inanır.",
    list: "C1",
    answer: "kutsal",
    quest: "divine",
  ),

  Words(
    front: "The religious doctrine outlines the core beliefs of the faith.",
    back: "Dini ilke, dinin temel inançlarını ana hatlarıyla belirtir.",
    list: "C1",
    answer: "ilke",
    quest: "doctrine",
  ),

  Words(
    front: "Please provide proper documentation for your travel expenses.",
    back: "Lütfen seyahat masraflarınız için gerekli belgelemeyi sağlayın.",
    list: "C1",
    answer: "belgeleme",
    quest: "documentation",
  ),
  Words(
    front:
        "Are you still looking for some kind of job in the political domain?",
    back: "Hâlâ siyasi alanda bir iş mi arıyorsunuz?",
    list: "C1",
    answer: "bilgi alanı",
    quest: "domain",
  ),

  Words(
    front: "Hollywood exerts dominance over the film industry",
    back: "Hollywood film endüstrisi üzerinde hakimiyet sergiliyor.",
    list: "C1",
    answer: "hakimiyet",
    quest: "dominance",
  ),

  Words(
    front: "The hospital relies on the generosity of blood donors.",
    back: "Hastane, kan bağışçılarının cömertliğine güveniyor.",
    list: "C1",
    answer: "bağışçı",
    quest: "donor",
  ),

  Words(
    front: "The doctor prescribed a high dose of medication.",
    back: "Doktor yüksek dozda ilaç reçete etti.",
    list: "C1",
    answer: "doz",
    quest: "dose",
  ),

  Words(
    front: "We need to drain the pool before winter.",
    back: "Havuzun suyunu boşaltmamız gerekiyor.",
    list: "C1",
    answer: "tahliye etmek",
    quest: "drain",
  ),

  Words(
    front: "Her thoughts drifted away as she gazed at the ocean.",
    back: "Okyanusa bakarken düşünceleri uzaklaştı.",
    list: "C1",
    answer: "şaşırmak",
    quest: "drift",
  ),

  Words(
    front: "She enjoyed the thrill of driving a fast car.",
    back: "Hızlı araba kullanmanın heyecanını yaşadı.",
    list: "C1",
    answer: "sürme",
    quest: "driving",
  ),

  Words(
    front: "The tragic accident left him to drown in despair.",
    back: "Trajik kaza onu umutsuzluk içinde boğdu.",
    list: "C1",
    answer: "suda boğulmak",
    quest: "drown",
  ),

  Words(
    front: "There is a dual nature to human personality.",
    back: "İnsan kişiliğinin ikili bir yapısı vardır.",
    list: "C1",
    answer: "ikili",
    quest: "dual",
  ),

  Words(
    front: "Let me try to dub the movie into Turkish.",
    back: "Filmi Türkçe dublajlamaya çalışayım.",
    list: "C1",
    answer: "düzeltmek",
    quest: "dub",
  ),

  Words(
    front: "He lifted the heavy dumbbells with ease.",
    back: "Ağır halterleri kolaylıkla kaldırdı.",
    list: "C1",
    answer: "halter",
    quest: "dumb",
  ),

  Words(
    front: "They are a strong duo that can overcome any challenge.",
    back: "Herhangi bir zorluğun üstesinden gelebilecek güçlü bir ikilidirler.",
    list: "C1",
    answer: "eş",
    quest: "duo",
  ),

  Words(
    front:
        "The company is known for its dynamic and innovative work environment.",
    back: "Şirket, dinamik ve yenilikçi çalışma ortamı ile tanınır.",
    list: "C1",
    answer: "hareketli",
    quest: "dynamic",
  ),
  Words(
    front: "She was eager to learn and improve her skills.",
    back: "Öğrenmeye ve yeteneklerini geliştirmeye istekliydi.",
    list: "C1",
    answer: "istekli",
    quest: "eager",
  ),

  Words(
    front: "His monthly earnings were not enough to cover his expenses.",
    back: "Aylık kazancı masraflarını karşılamaya yetmiyordu.",
    list: "C1",
    answer: "kazanç",
    quest: "earnings",
  ),

  Words(
    front: "Taking a deep breath helped to ease her anxiety.",
    back: "Derin bir nefes almak endişesini rahatlatmaya yardımcı oldu.",
    list: "C1",
    answer: "rahatlatmak",
    quest: "ease",
  ),

  Words(
    front: "Her shout echoed through the empty hallway.",
    back: "Çığlığı boş koridorda yankılandı.",
    list: "C1",
    answer: "yankı",
    quest: "echo",
  ),

  Words(
    front: "We need to find ecological solutions to environmental problems.",
    back: "Çevresel sorunlara ekolojik çözümler bulmamız gerekiyor.",
    list: "C1",
    answer: "çevre",
    quest: "ecological",
  ),

  Words(
    front:
        "The experienced educator inspired his students to pursue their dreams.",
    back:
        "Tecrübeli eğitimci öğrencilerini hayallerinin peşinden gitmeye teşvik etti.",
    list: "C1",
    answer: "eğitimci",
    quest: "educator",
  ),

  Words(
    front: "The new policy will improve the effectiveness of waste management.",
    back: "Yeni politika, atık yönetiminin etkinliğini artıracaktır.",
    list: "C1",
    answer: "etkililik",
    quest: "effectiveness",
  ),

  Words(
    front: "He completed the task with efficiency and minimal effort.",
    back: "Görevi verimli bir şekilde ve minimum çabayla tamamladı.",
    list: "C1",
    answer: "liyakat",
    quest: "efficiency",
  ),

  Words(
    front: "The teacher asked her students to elaborate on their answers.",
    back: "Öğretmen öğrencilerinden cevaplarını detaylandırmayı istedi.",
    list: "C1",
    answer: "detaylandırmak",
    quest: "elaborate",
  ),

  Words(
    front:
        "The upcoming elections will be a crucial moment in the country's electoral process.",
    back: " yaklaşan seçimler, ülkenin seçim süreci için önemli bir an olacak.",
    list: "C1",
    answer: "seçimle ilgili",
    quest: "electoral",
  ),

  Words(
    front: "Education can elevate a person's social status.",
    back: "Eğitim, bir kişinin sosyal statüsünü yükseltebilir.",
    list: "C1",
    answer: "yükseltmek",
    quest: "elevate",
  ),

  Words(
    front: "Only citizens who meet the age requirement are eligible to vote.",
    back:
        "Sadece yaş şartını yerine getiren vatandaşlar oy kullanmaya hak sahibiです.",
    list: "C1",
    answer: "hak sahibi",
    quest: "eligible",
  ),

  Words(
    front:
        "They belong to an elite group of athletes who compete at the highest level.",
    back: "En üst düzeyde yarışan elit bir sporcu grubuna aitler.",
    list: "C1",
    answer: "elit",
    quest: "elite",
  ),
  Words(
    front:
        "Instead of settling down, he decided to embark on a journey to see the world.",
    back:
        "Yerleşmek yerine, dünyayı görmek için bir yolculuğa çıkmaya karar verdi.",
    list: "C1",
    answer: "çıkmak,gemiye bindirmek",
    quest: "embark",
  ),

  Words(
    front: "He felt a wave of embarrassment after tripping in public.",
    back: "Toplum içinde tökezledikten sonra bir utanç dalgası hissetti.",
    list: "C1",
    answer: "mahcubiyet",
    quest: "embarrassment",
  ),

  Words(
    front: "The US embassy in Ankara is located in Çankaya.",
    back: "ABD'nin Ankara Büyükelçiliği Çankaya'da bulunmaktadır.",
    list: "C1",
    answer: "elçilik",
    quest: "embassy",
  ),

  Words(
    front:
        "The message was embedded in the code for only authorized users to see.",
    back:
        "Mesaj, yalnızca yetkili kullanıcıların görebileceği şekilde koda gömülüydü.",
    list: "C1",
    answer: "gömmek",
    quest: "embed",
  ),

  Words(
    front: "Words embody thoughts and feelings.",
    back: "Sözcükler, düşünceleri ve duyguları somutlaştırır.",
    list: "C1",
    answer: "somutlaştırmak",
    quest: "embody",
  ),

  Words(
    front: "The emergence of new technologies is changing the world.",
    back: "Yeni teknolojilerin ortaya çıkışı dünyayı değiştiriyor.",
    list: "C1",
    answer: "belirme",
    quest: "emergence",
  ),

  Words(
    front: "Scientific research is based on empirical evidence.",
    back: "Bilimsel araştırma, deneysel kanıtlara dayanır.",
    list: "C1",
    answer: "deneysel",
    quest: "empirical",
  ),

  Words(
    front: "Education empowers individuals to reach their full potential.",
    back: "Eğitim, bireyleri tam potansiyellerine ulaşmaları için güçlendirir.",
    list: "C1",
    answer: "izin vermek",
    quest: "empower",
  ),

  Words(
    front:
        "We need to enact laws that will make it more difficult for companies to avoid paying taxes.",
    back:
        "Şirketlerin vergi ödemekten kaçınmasını daha da zorlaştıracak yasalar çıkarmamız gerekiyor.",
    list: "C1",
    answer: "yasalaştırmak",
    quest: "enact",
  ),

  Words(
    front: "The concept of human rights encompasses a wide range of freedoms.",
    back: "İnsan hakları kavramı, geniş bir özgürlük yelpazesini kapsar.",
    list: "C1",
    answer: "kuşatmak",
    quest: "encompass",
  ),

  Words(
    front: "Her positive words were a great encouragement for him.",
    back: "Onun olumlu sözleri onun için büyük bir teşvikti.",
    list: "C1",
    answer: "teşvik",
    quest: "encouragement",
  ),

  Words(
    front:
        "The teacher's encouraging words helped the students overcome their shyness.",
    back:
        "Öğretmenin cesaretlendirici sözleri öğrencilerin çekingenliklerini yenmelerine yardımcı oldu.",
    list: "C1",
    answer: "cesaretlendirici",
    quest: "encouraging",
  ),

  Words(
    front: "They are determined to succeed in their endeavours.",
    back: "Çabalarında başarılı olmaya kararlılar.",
    list: "C1",
    answer: "çabalamak",
    quest: "endeavour",
  ),
  Words(
    front: "The universe seems endless in its vastness.",
    back: "Evren enginliğiyle sonsuz görünüyor.",
    list: "C1",
    answer: "sonsuz",
    quest: "endless",
  ),

  Words(
    front: "The celebrity publicly endorsed the new brand of clothing.",
    back: "Ünlü, yeni giyim markasını alenen destekledi.",
    list: "C1",
    answer: "arkasına yazmak",
    quest: "endorse",
  ),

  Words(
    front: "You can't really get a better endorsement than that. ",
    back: "Bundan daha iyi bir onay alamazsınız.",
    list: "C1",
    answer: "onay",
    quest: "endorsement",
  ),

  Words(
    front:
        "The soldiers had to endure harsh weather conditions during the war.",
    back:
        "Askerler savaş sırasında zorlu hava koşullarına dayanmak zorunda kaldılar.",
    list: "C1",
    answer: "dayanmak",
    quest: "endure",
  ),

  Words(
    front: "The police will enforce the law to maintain public order.",
    back: "Polis, kamu düzenini sağlamak için yasayı uygulayacaktır.",
    list: "C1",
    answer: "zorla yaptırmak",
    quest: "enforce",
  ),

  Words(
    front:
        "Strict enforcement of traffic laws is necessary to reduce accidents.",
    back:
        "Kazaları azaltmak için trafik yasalarının sıkı bir şekilde uygulanması gerekiyor.",
    list: "C1",
    answer: "uygulama",
    quest: "enforcement",
  ),

  Words(
    front: "The couple's engagement was announced in the newspaper.",
    back: "Çiftin nişanı gazetede duyuruldu.",
    list: "C1",
    answer: "nişan",
    quest: "engagement",
  ),

  Words(
    front: "The teacher's engaging presentation kept the students' attention.",
    back: "Öğretmenin ilgi çekici sunumu öğrencilerin dikkatini çekti.",
    list: "C1",
    answer: "meşgul etme",
    quest: "engaging",
  ),

  Words(
    front: "He politely enquired about her well-being.",
    back: "Nezaketle onun iyiliğini sordu.",
    list: "C1",
    answer: "soru sormak",
    quest: "enquire",
  ),

  Words(
    front:
        "Traveling to different countries enriches one's cultural experience.",
    back:
        "Farklı ülkelere seyahat etmek kişinin kültürel deneyimini zenginleştirir.",
    list: "C1",
    answer: "zenginleştirmek",
    quest: "enrich",
  ),

  Words(
    front: "You can enrol in the online course at any time.",
    back: "Online kursa herhangi bir zamanda kaydolabilirsiniz.",
    list: "C1",
    answer: "kaydolmak",
    quest: "enrol",
  ),

  Words(
    front: "A heated debate ensued after the speaker's controversial remarks.",
    back:
        "Konuşmacının tartışmalı sözlerinden sonra hararetli bir tartışma başladı.",
    list: "C1",
    answer: "meydana gelmek",
    quest: "ensue",
  ),

  Words(
    front: "He started his own enterprise after leaving his corporate job.",
    back: "Kurumsal işinden ayrıldıktan sonra kendi girişimini başlattı.",
    list: "C1",
    answer: "girişim",
    quest: "enterprise",
  ),
  Words(
    front: "She is a music enthusiast who can name every song on the album.",
    back: "Albümdeki her şarkıyı sayabilen bir müzik tutkunu.",
    list: "C1",
    answer: "istekli kimse",
    quest: "enthusiast",
  ),

  Words(
    front: "The new law is entitled 'The Protection of Wildlife Act'.",
    back: "Yeni yasa 'Yaban Hayatı Koruma Kanunu' başlığını taşıyor.",
    list: "C1",
    answer: "isimlendirmek",
    quest: "entitle",
  ),

  Words(
    front:
        "The company is a legal entity with its own tax identification number.",
    back: "Şirket, kendi vergi kimlik numarası olan tüzel bir kişiliktir.",
    list: "C1",
    answer: "mevcudiyet",
    quest: "entity",
  ),

  Words(
    front: "The spread of the coronavirus has become a global epidemic.",
    back: "Koronavirüsün yayılması küresel bir salgın haline geldi.",
    list: "C1",
    answer: "salgın",
    quest: "epidemic",
  ),

  Words(
    front: "We strive for equality and justice for all.",
    back: "Herkes için eşitlik ve adalet için çabalıyoruz.",
    list: "C1",
    answer: "eşitlik",
    quest: "equality",
  ),

  Words(
    front: "Can you solve this mathematical equation for x?",
    back: "Bu matematiksel denklemi x için çözebilir misin?",
    list: "C1",
    answer: "denge",
    quest: "equation",
  ),

  Words(
    front: "The workers erected a statue in honor of the war hero.",
    back: "İşçiler savaş kahramanının onuruna bir heykel diktiler.",
    list: "C1",
    answer: "dikmek",
    quest: "erect",
  ),

  Words(
    front: "The situation escalated quickly into a violent conflict.",
    back: "Durum hızla şiddetli bir çatışmaya dönüştü.",
    list: "C1",
    answer: "kızışmak",
    quest: "escalate",
  ),

  Words(
    front: "Love is the essence of humanity.",
    back: "Sevgi, insanlığın özüdür.",
    list: "C1",
    answer: "öz",
    quest: "essence",
  ),

  Words(
    front:
        "The establishment of democracy can be traced back to ancient Greece.",
    back: "Demokrasinin kuruluşu antik Yunan'a kadar geri götürülebilir.",
    list: "C1",
    answer: "kuruluş",
    quest: "establishment",
  ),

  Words(
    front: "They believe in eternal life after death.",
    back: "Ölümdən sonra sonsuz hayata inaniyorlar.",
    list: "C1",
    answer: "sonsuz",
    quest: "eternal",
  ),

  Words(
    front: "The city was evacuated due to the approaching hurricane.",
    back: " yaklaşan kasırga nedeniyle şehir boşaltıldı.",
    list: "C1",
    answer: "götürmek",
    quest: "evacuate",
  ),

  Words(
    front: "The music evoked memories of his childhood.",
    back: "Müzik, çocukluğuna dair anıları uyandırdı.",
    list: "C1",
    answer: "anımsatmak",
    quest: "evoke",
  ),

  Words(
    front: "Don't exaggerate the problem; it's not as bad as you think.",
    back: "Problemi abartmayın; düşündüğünüz kadar kötü değil.",
    list: "C1",
    answer: "abartmak",
    quest: "exaggerate",
  ),

  Words(
    front: "She strives for excellence in everything she does.",
    back: "Yaptığı her şeyde mükemmellik için çabalar.",
    list: "C1",
    answer: "mükemmellik",
    quest: "excellence",
  ),

  Words(
    front: "He received an exceptional grade on his history exam.",
    back: "Tarih sınavında fevkalade bir not aldı.",
    list: "C1",
    answer: "fevkalade",
    quest: "exceptional",
  ),

  Words(
    front: "Eating in moderation is important to avoid excess calories.",
    back: "Aşırı kalori alımından kaçınmak için ölçülü yemek önemlidir.",
    list: "C1",
    answer: "aşırılık",
    quest: "excess",
  ),

  Words(
    front:
        "He tends to talk about himself to the exclusion of all other subjects.",
    back:
        "Diğer tüm konuları dışlayarak kendisi hakkında konuşma eğilimindedir.",
    list: "C1",
    answer: "ret",
    quest: "exclusion",
  ),

  Words(
    front: "This club is exclusive and only accepts members by invitation.",
    back: "Bu kulüp özeldir ve sadece davetiye ile üye kabul eder.",
    list: "C1",
    answer: "özel",
    quest: "exclusive",
  ),

  Words(
    front: "The new product is designed exclusively for gamers.",
    back: "Yeni ürün, özellikle oyuncular için tasarlanmıştır.",
    list: "C1",
    answer: "özellikle",
    quest: "exclusively",
  ),
  Words(
    front: "The new product is designed exclusively for gamers.",
    back: "Yeni ürün, özellikle oyuncular için tasarlanmıştır.",
    list: "C1",
    answer: "özellikle",
    quest: "exclusively",
  ),

  Words(
    front: "The execution of the plan was flawless.",
    back: "Planın icrası kusursuzdu.",
    list: "C1",
    answer: "icra,idam",
    quest: "execution",
  ),

  Words(
    front: "The leader exerted all his power to overcome the challenge.",
    back: "Lider, zorluğun üstesinden gelmek için tüm gücünü harcadı.",
    list: "C1",
    answer: "güç sarfetmek",
    quest: "exert",
  ),

  Words(
    front: "Napoleon was exiled to the island of Elba after his defeat.",
    back: "Napolyon yenilgisinden sonra Elba adasına sürüldü.",
    list: "C1",
    answer: "sürgün",
    quest: "exile",
  ),

  Words(
    front:
        "The company's high expenditure on advertising resulted in financial difficulties.",
    back:
        "Şirketin reklam için yaptığı yüksek masraflar mali sıkıntıya neden oldu.",
    list: "C1",
    answer: "masraf",
    quest: "expenditure",
  ),
  Words(
    front:
        "The scientists conducted an experimental study to test the new drug.",
    back:
        "Bilim adamları, yeni ilacı test etmek için deneysel bir çalışma yürüttüler.",
    list: "C1",
    answer: "deneysel",
    quest: "experimental",
  ),

  Words(
    front: "Your credit card will expire next month. Don't forget to renew it.",
    back: "Kredi kartınız önümüzdeki ay sona erecek. Yenilemeyi unutmayın.",
    list: "C1",
    answer: "süresi dolmak",
    quest: "expire",
  ),

  Words(
    front: "The instructions were explicit and easy to follow.",
    back: "Talimatlar açıktı ve takip edilmesi kolaydı.",
    list: "C1",
    answer: "aşikar",
    quest: "explicit",
  ),

  Words(
    front: "He explicitly stated his disagreement with the proposal.",
    back: "Öneriye açıkça karşı çıktığını ifade etti.",
    list: "C1",
    answer: "açıkça",
    quest: "explicitly",
  ),

  Words(
    front:
        "Child labor is a form of exploitation that is illegal in most countries.",
    back: "Çocuk işçilik, çoğu ülkede yasadışı olan bir sömürü biçimidir.",
    list: "C1",
    answer: "kötüye kullanma",
    quest: "exploitation",
  ),

  Words(
    front: "The news report contained explosive allegations of corruption.",
    back: "Haber raporunda patlayıcı yolsuzluk iddiaları yer alıyordu.",
    list: "C1",
    answer: "patlayıcı",
    quest: "explosive",
  ),

  Words(
    front:
        "Scientists were able to extract valuable DNA from the dinosaur fossil.",
    back: "Bilim adamları, dinozor fosilinden değerli DNA çıkarabildiler.",
    list: "C1",
    answer: "özünü çıkarmak",
    quest: "extract",
  ),

  Words(
    front: "Extremist groups often resort to violence to achieve their goals.",
    back:
        "Aşırılıkçı gruplar, hedeflerine ulaşmak için çoğu zaman şiddete başvururlar.",
    list: "C1",
    answer: "aşırılık yapmak",
    quest: "Extremist",
  ),

  Words(
    front: "The new policy will facilitate the process of applying for a visa.",
    back: "Yeni politika, vize başvuru sürecini kolaylaştıracaktır.",
    list: "C1",
    answer: "rahatlatmak",
    quest: "facilitate",
  ),

  Words(
    front: "The country is divided into various political factions.",
    back: "Ülke çeşitli siyasi hiziplere ayrılmıştır.",
    list: "C1",
    answer: "hizip",
    quest: "faction",
  ),

  Words(
    front: "She is a member of the English faculty at the university.",
    back: "Üniversitede İngiliz Dili ve Edebiyatı fakültesi üyesidir.",
    list: "C1",
    answer: "fakülte",
    quest: "faculty",
  ),

  Words(
    front: "The old photograph had faded over time.",
    back: "Eski fotoğraf zamanla solmuştu.",
    list: "C1",
    answer: "karartmak",
    quest: "fade",
  ),

  Words(
    front: "Justice demands fairness for all.",
    back: "Adalet, herkes için insaf gerektirir.",
    list: "C1",
    answer: "insaf",
    quest: "fairness",
  ),
  Words(
    front: "The accident resulted in a fatal injury.",
    back: "Kaza ölümcül bir yaralanmayla sonuçlandı.",
    list: "C1",
    answer: "ölümcül",
    quest: "fatal",
  ),

  Words(
    front: "He believes that everything happens according to fate.",
    back: "Her şeyin kadere göre gerçekleştiğine inanıyor.",
    list: "C1",
    answer: "kader",
    quest: "fate",
  ),

  Words(
    front: "The weather forecast is favourable for a picnic tomorrow.",
    back: "Yarın piknik için hava durumu olumlu.",
    list: "C1",
    answer: "olumlu",
    quest: "favourable",
  ),

  Words(
    front: "Climbing Mount Everest is a remarkable feat of human endurance.",
    back:
        "Everest Dağı'na tırmanmak, insan dayanıklılığının olağanüstü bir başarısıdır.",
    list: "C1",
    answer: "beceriklilik",
    quest: "feat",
  ),

  Words(
    front: "A diet rich in fibre can help with digestion.",
    back: "Lif açısından zengin bir diyet sindirime yardımcı olabilir.",
    list: "C1",
    answer: "lif",
    quest: "fibre",
  ),

  Words(
    front: "The lion is a fierce predator known for its hunting skills.",
    back: "Aslan, avlanma yetenekleriyle tanınan vahşi bir avcıdır.",
    list: "C1",
    answer: "vahşet",
    quest: "fierce",
  ),

  Words(
    front:
        "The award-winning film-maker is known for her thought-provoking documentaries.",
    back: "Ödüllü filmci, düşündürücü belgeselleriyle tanınır.",
    list: "C1",
    answer: "filmci",
    quest: "film-maker",
  ),

  Words(
    front:
        "Coffee filters help remove unwanted particles from the brewed coffee.",
    back:
        "Kahve filtreleri, demlenmiş kahveden istenmeyen partiküllerin temizlenmesine yardımcı olur.",
    list: "C1",
    answer: "süzmek",
    quest: "filter",
  ),

  Words(
    front: "He was fined for speeding by the traffic police.",
    back: "Trafik polisi tarafından aşırı hız yaptığı için ceza kesildi.",
    list: "C1",
    answer: "ceza kesmek",
    quest: "fine",
  ),

  Words(
    front: "The suspect was arrested for possession of a firearm.",
    back: "Şüpheli, ateşli silah bulundurma suçundan tutuklandı.",
    list: "C1",
    answer: "ateşli silah",
    quest: "firearm",
  ),

  Words(
    front: "Make sure you wear clothes that fit you well.",
    back: "Size tam oturan giysiler giydiğinizden emin olun.",
    list: "C1",
    answer: "uymak",
    quest: "fit",
  ),

  Words(
    front:
        "The football match is a weekly fixture that brings the community together.",
    back: "Futbol maçı, topluluğu bir araya getiren haftalık bir fikstürdür.",
    list: "C1",
    answer: "sabit eşya",
    quest: "fixture",
  ),

  Words(
    front:
        "The new design had a few minor flaws, but overall it was successful.",
    back:
        "Yeni tasarımın birkaç küçük kusuru vardı, ancak genel olarak başarılıydı.",
    list: "C1",
    answer: "kusur",
    quest: "flaw",
  ),
  Words(
    front: "It's clear that the methodology the researchers used is flawed.",
    back: "Araştırmacıların kullandığı metodolojinin kusurlu olduğu açıktır.",
    list: "C1",
    answer: "kusurlu, hatalı",
    quest: "flawed",
  ),

  Words(
    front: "Andrew Johnson had to flee his home to save his life.",
    back:
        "Andrew Johnson hayatını kurtarmak için evinden kaçmak zorunda kaldı.",
    list: "C1",
    answer: "kaçmak",
    quest: "flee",
  ),

  Words(
    front:
        "The naval fleet patrolled the coast to protect the country's borders.",
    back: "Donanma, ülkenin sınırlarını korumak için sahili devriye etti.",
    list: "C1",
    answer: "donanma",
    quest: "fleet",
  ),

  Words(
    front: "Scars are formed from the healing of damaged flesh.",
    back: "Yara izleri, hasarlı etin iyileşmesinden oluşur.",
    list: "C1",
    answer: "et",
    quest: "flesh",
  ),

  Words(
    front: "Yoga improves flexibility and balance.",
    back: "Yoga, esneklik ve dengeyi geliştirir.",
    list: "C1",
    answer: "esneklik",
    quest: "flexibility",
  ),

  Words(
    front:
        "The politician gave a flourishing speech filled with empty promises.",
    back: "Politikacı, boş vaatlerle dolu süslü bir konuşma yaptı.",
    list: "C1",
    answer: "süslü konuşmak",
    quest: "flourish",
  ),

  Words(
    front: "Water is a vital fluid for all living organisms.",
    back: "Su, tüm canlı organizmalar için hayati bir sıvıdır.",
    list: "C1",
    answer: "sıvı",
    quest: "fluid",
  ),

  Words(
    front: "He felt like a foreigner in his own country.",
    back: "Kendi ülkesinde kendini bir yabancı gibi hissetti.",
    list: "C1",
    answer: "yabancı",
    quest: "foreigner",
  ),

  Words(
    front:
        "Blacksmiths use fire and hammers to forge metal into different shapes.",
    back:
        "Demirciler, metali farklı şekillere dövmek için ateş ve çekiç kullanırlar.",
    list: "C1",
    answer: "demir dövmek",
    quest: "forge",
  ),

  Words(
    front:
        "The new baby formula is enriched with essential vitamins and minerals.",
    back: "Yeni mama, gerekli vitaminler ve minerallerle zenginleştirilmiştir.",
    list: "C1",
    answer: "mama",
    quest: "formula",
  ),

  Words(
    front: "Scientists are trying to formulate a cure for the disease.",
    back:
        "Bilim adamları, hastalık için bir tedavi formülü oluşturmaya çalışıyorlar.",
    list: "C1",
    answer: "formülleştirmek",
    quest: "formulate",
  ),

  Words(
    front:
        "The charity fosters hope and opportunity for underprivileged children.",
    back: "Hayır kurumu, dezavantajlı çocuklar için umut ve fırsat yaratır.",
    list: "C1",
    answer: "bakmak",
    quest: "foster",
  ),

  Words(
    front: "The fragile butterfly wings were easily damaged.",
    back: "Narin kelebek kanatları kolayca zarar gördü.",
    list: "C1",
    answer: "narin",
    quest: "fragile",
  ),

  Words(
    front: "Frankly, I don't think that plan is going to work.",
    back: "Açıkçası, bu planın işe yarayacağını sanmıyorum.",
    list: "C1",
    answer: "açıkça",
    quest: "Frankly",
  ),

  Words(
    front: "He felt frustrated after his repeated failures.",
    back:
        "Tekrarlayan başarısızlıklardan sonra kendini haksızlığa uğramış hissetti.",
    list: "C1",
    answer: "hakkı yenmiş",
    quest: 'frustrated',
  ),

  Words(
    front: "Trying to explain things to him is so frustrating!",
    back: "Ona bir şeyler anlatmaya çalışmak çok moral bozucu!",
    list: "C1",
    answer: "moral bozucu",
    quest: "frustrating",
  ),

  Words(
    front:
        "The constant traffic jams were a major source of frustration for the commuters.",
    back:
        "Sürekli trafik sıkışıklığı, yolcular için büyük bir hüsran kaynağıydı.",
    list: "C1",
    answer: "hüsran",
    quest: "frustration",
  ),

  Words(
    front: "The new furniture is both stylish and functional.",
    back: "Yeni mobilyalar hem şık hem de işlevsel.",
    list: "C1",
    answer: "pratik",
    quest: "functional",
  ),

  Words(
    front:
        "The school is organizing a fundraising event to raise money for new sports equipment.",
    back: "Okul, yeni spor malzemeleri için para toplama etkinliği düzenliyor.",
    list: "C1",
    answer: "para toplama",
    quest: "fundraising",
  ),

  Words(
    front: "Hundreds of mourners attended the funeral to pay their respects.",
    back: "Yüzlerce yas tutan, cenazeye saygılarını sunmak için katıldı.",
    list: "C1",
    answer: "cenaze",
    quest: "funeral",
  ),

  Words(
    front: "He has a gambling problem and has lost a lot of money.",
    back: "Kumar sorunu var ve çok para kaybetti.",
    list: "C1",
    answer: "kumar",
    quest: "gambling",
  ),

  Words(
    front: "There will be a gathering of friends and family this weekend.",
    back: "Bu hafta sonu bir arkadaş ve aile toplanma olacak.",
    list: "C1",
    answer: "toplanma",
    quest: "gathering",
  ),

  Words(
    front: "He turned a cold, reptilian gaze on me.",
    back: "Soğuk, sürüngen bakışlarını bana çevirdi.",
    list: "C1",
    answer: "gözünü dikmek",
    quest: "gaze",
  ),

  Words(
    front: "Shift into a higher gear to accelerate.",
    back: "Hızlanmak için daha yüksek bir vitese takın.",
    list: "C1",
    answer: "dişli",
    quest: "gear",
  ),
  Words(
    front: "This medication is a generic version of a brand-name drug.",
    back: "Bu ilaç, markalı bir ilacın jenerik versiyonudur.",
    list: "C1",
    answer: "jenerik",
    quest: "generic",
  ),

  Words(
    front:
        "The war crimes committed against the minority group were considered genocide.",
    back:
        "Azınlık grubuna karşı işlenen savaş suçları soykırım olarak değerlendirildi.",
    list: "C1",
    answer: "soykırım",
    quest: "genocide",
  ),

  Words(
    front: "He glanced at his watch to see what time it was.",
    back: "Saatin kaç olduğunu görmek için saatine şöyle bir göz attı.",
    list: "C1",
    answer: "göz atmak",
    quest: "glance",
  ),

  Words(
    front: "She caught a glimpse of the thief running down the street.",
    back: "Hırsızın sokakta koşarken anlık bir bakışını yakaladı.",
    list: "C1",
    answer: "anlık bakış",
    quest: "glimpse",
  ),

  Words(
    front: "The victory was a glorious moment in the country's history.",
    back: "Zafer, ülkenin tarihinde şanlı bir andı.",
    list: "C1",
    answer: "şanlı",
    quest: "glorious",
  ),

  Words(
    front: "The athlete achieved glory by winning the gold medal.",
    back: "Atlet, altın madalya kazanarak görkeme ulaştı.",
    list: "C1",
    answer: "görkem",
    quest: "glory",
  ),

  Words(
    front: "Good governance is essential for a stable and prosperous society.",
    back: "İyi yönetişim, istikrarlı ve müreffeh bir toplum için gereklidir.",
    list: "C1",
    answer: "kontrol",
    quest: "governance",
  ),

  Words(
    front: "She moved with grace and elegance.",
    back: "Zarafet ve incelikle hareket etti.",
    list: "C1",
    answer: "zarafet",
    quest: "grace",
  ),

  Words(
    front: "He struggled to grasp the complex concept.",
    back: "Karmaşık kavramı kavramakta zorlandı.",
    list: "C1",
    answer: "kavramak",
    quest: "grasp",
  ),

  Words(
    front:
        "The soldier's body was buried in a grave with full military honors.",
    back: "Askerin naaşı, tüm askeri törenlerle bir mezara gömüldü.",
    list: "C1",
    answer: "mezar",
    quest: "grave",
  ),

  Words(
    front: "Gravity is the force that keeps us grounded.",
    back: "Yerçekimi, bizi yerde tutan kuvvettir.",
    list: "C1",
    answer: "yerçekimi",
    quest: "Gravity",
  ),

  Words(
    front: "The city's power grid was damaged by the storm.",
    back: "Fırtına nedeniyle şehrin elektrik şebekesi zarar gördü.",
    list: "C1",
    answer: "örgü",
    quest: "grid",
  ),

  Words(
    front: "He was overcome with grief after the death of his wife.",
    back: "Karısının ölümünden sonra kederden yıkıldı.",
    list: "C1",
    answer: "keder",
    quest: "grief",
  ),
  Words(
    front: "He grinned mischievously at his friend.",
    back: "Arkadaşına yaramazca sırıttı.",
    list: "C1",
    answer: "sırıtmak",
    quest: "grin",
  ),
  Words(
    front: "The coffee beans need to be grinded before brewing.",
    back: "Kahve çekirdekleri demlenmeden önce öğütülmelidir.",
    list: "C1",
    answer: "öğütmek",
    quest: "grind",
  ),
  Words(
    front: "He struggled to grip the wet doorknob.",
    back: "Islak kapı tokmağını kavramakta zorlandı.",
    list: "C1",
    answer:
        "kavramak", // "Grip" in this context means to grasp tightly, which translates to "kavramak" in Turkish.
    quest: "grip",
  ),
  Words(
    front: "The teacher offered guidance to the struggling student.",
    back: "Öğretmen, zorlanan öğrenciye yönlendirme sundu.",
    list: "C1",
    answer: "yönlendirme",
    quest: "guidance",
  ),
  Words(
    front: "He felt a pang of guilt for his actions.",
    back: "Yaptıklarından dolayı bir suçluluk duygusu hissetti.",
    list: "C1",
    answer: "suçluluk",
    quest: "guilt",
  ),
  Words(
    front:
        "There's no point trying to clean a gut instinct.", // "Gut" in this context doesn't have a direct translation. " sezgi" (intuition) might be a better fit depending on the intended meaning.
    back:
        "Sezgileri temizlemenin bir anlamı yok.", // Adjusted the translation based on the suggested meaning.
    list: "C1",
    answer: "temizlemek",
    quest: "gut",
  ),
  Words(
    front: "The storm brought heavy hail, damaging cars and crops.",
    back: "Fırtına, arabalara ve ekinlere zarar veren dolu yağdırdı.",
    list: "C1",
    answer: "dolu yağmak",
    quest: "hail",
  ),
  Words(
    front: "She was only halfway through the project when she quit.",
    back: "Projenin ancak yarısına gelmişti ki bıraktı.",
    list: "C1",
    answer: "yarı yolda",
    quest: "halfway",
  ),
  Words(
    front: "The car came to a halt at the red light.",
    back: "Araba kırmızı ışıkta durdu.",
    list: "C1",
    answer: "durmak",
    quest: "halt",
  ),
  Words(
    front: "He grabbed a handful of nuts from the bowl.",
    back: "Kâseden bir avuç fındık aldı.",
    list: "C1",
    answer: "avuç",
    quest: "handful",
  ),
  Words(
    front: "He appreciated her skillful handling of the difficult situation.",
    back: "Zor durumun ustaca idaresini takdir etti.",
    list: "C1",
    answer: "idare",
    quest: "handling",
  ),
  Words(
    front: "The new stapler is a handy tool to have around the office.",
    back: "Yeni zımba, ofiste olması kullanışlı bir araç.",
    list: "C1",
    answer: "kullanışlı",
    quest: "handy",
  ),
  Words(
    front: "The computer consists of both software and hardware.",
    back: "Bilgisayar hem yazılımdan hem de donanımdan oluşur.",
    list: "C1",
    answer: "donanım",
    quest: "hardware",
  ),
  Words(
    front: "There is a sense of harmony between the music and the lyrics.",
    back: "Müzik ve sözler arasında bir ahenk var.",
    list: "C1",
    answer: "ahenk",
    quest: "harmony",
  ),
  Words(
    front: "The sergeant's voice was harsh and unforgiving.",
    back: "Çavuşun sesi sert ve affetmezdi.",
    list: "C1",
    answer: "haşin",
    quest: "harsh",
  ),
  Words(
    front: "The farmers are preparing for the upcoming harvest.",
    back: "Çiftçiler yaklaşan hasat için hazırlanıyor.",
    list: "C1",
    answer: "hasat",
    quest: "harvest",
  ),
  Words(
    front: "He was filled with hatred for his enemies.",
    back: "Düşmanlarına karşı nefretle doluydu.",
    list: "C1",
    answer: "nefret",
    quest: "hatred",
  ),
  Words(
    front: "The abandoned house is said to be haunted by ghosts.",
    back: "Terk edilmiş evin hayaletler tarafından perili olduğu söylenir.",
    list: "C1",
    answer:
        "perili", // "Sık sık uğramak" (frequently visit) doesn't capture the meaning of "haunt" in this context. "Perili" is a better fit.
    quest: "haunt",
  ),
  Words(
    front: "Working in a factory can be a hazardous job.",
    back: "Fabrika işçiliği tehlikeli bir iş olabilir.",
    list: "C1",
    answer:
        "risk", // "Hazard" is more about the inherent danger, while "tehlike" can also mean active threat.
    quest: "hazard",
  ),
  Words(
    front: "The speech heightened the tensions between the two countries.",
    back: "Konuşma, iki ülke arasındaki gerilimi yükseltti.",
    list: "C1",
    answer:
        "yükseltmek", // "Artan" (increasing) wouldn't capture the action of making something greater.
    quest: "heighten",
  ),
  Words(
    front: "He is proud of his rich heritage and cultural background.",
    back: "Zengin mirası ve kültürel geçmişiyle gurur duyuyor.",
    list: "C1",
    answer: "miras",
    quest: "heritage",
  ),
  Words(
    front: "The high-profile trial was covered by news outlets worldwide.",
    back:
        "Yüksek profilli dava, dünya çapında haber kuruluşları tarafından takip edildi.",
    list: "C1",
    // "İyi tanınan" (well-known) doesn't quite capture the emphasis on public importance.
    answer: "yüksek profilli",
    quest: "high-profile",
  ),
  Words(
    front: "She dropped a hint about her birthday present.",
    back: "Doğum günü hediyesi hakkında bir ipucu verdi.",
    list: "C1",
    answer: "ima etmek",
    quest: "hint",
  ),
  Words(
    front: "He longed to return to his homeland after many years abroad.",
    back: "Yıllar sonra yurt dışından vatanına dönmeyi özlemle bekliyordu.",
    list: "C1",
    answer: "vatan",
    quest: "homeland",
  ),
  Words(
    front: "He used a hook to pull the heavy box.",
    back: "Ağır kutuyu çekmek için bir kanca kullandı.",
    list: "C1",
    answer: "kanca",
    quest: "hook",
  ),
  Words(
    front: "Despite the challenges, he remained hopeful about the future.",
    back: "Tüm zorluklara rağmen, gelecek hakkında umutlu kaldı.",
    list: "C1",
    answer: "umutlu",
    quest: "hopeful",
  ),
  Words(
    front: "The sun dipped below the horizon as night fell.",
    back: "Gece bastırırken güneş ufuk çizgisinin altına battı.",
    list: "C1",
    answer: "ufuk",
    quest: "horizon",
  ),
  Words(
    front: "The deer used its horns to defend itself from the predator.",
    back: "Geyik, yırtıcıdan kendini korumak için boynuzlarını kullandı.",
    list: "C1",
    answer: "boynuz",
    quest: "horn",
  ),
  Words(
    front: "The rebels took several hostages during the bank robbery.",
    back: "İsyancılar, banka soygunu sırasında birkaç kişiyi rehin aldı.",
    list: "C1",
    answer: "rehin",
    quest: "hostage",
  ),
  Words(
    front: "The two armies faced each other in a hostile environment.",
    back: "İki ordu birbirine düşmanca bir ortamda karşı karşıya geldi.",
    list: "C1",
    answer: "düşmanca",
    quest: "hostile",
  ),
  Words(
    front: "There was a sense of hostility between the two rival companies.",
    back: "İki rakip şirket arasında düşmanlık vardı.",
    list: "C1",
    answer: "düşmanlık",
    quest: "hostility",
  ),
  Words(
    front:
        "The humanitarian organization provides aid to refugees around the world.",
    back: "Yardım kuruluşu, dünya çapındaki mültecilere yardım sağlıyor.",
    list: "C1",
    answer: "yardımsever",
    quest: "humanitarian",
  ),
  Words(
    front: "Despite their differences, they treated each other with humanity.",
    back: "Farklılıklarına rağmen birbirlerine insanlıkla davrandılar.",
    list: "C1",
    answer: "insaniyet",
    quest: "humanity",
  ),
  Words(
    front: "He was a humble man despite his great achievements.",
    back: "Büyük başarılarına rağmen mütevazı bir adamdı.",
    list: "C1",
    answer: "mütevazı",
    quest: "humble",
  ),
  Words(
    front: "You will need to show identification to enter the building.",
    back: "Binaya girmek için kimlik göstermeniz gerekecek.",
    list: "C1",
    answer: "kimlik saptama",
    quest: "identification",
  ),
  Words(
    front: "They argued over ideological differences.",
    back: "Fikri farklılıklar üzerine tartıştılar.",
    list: "C1",
    answer: "fikirsel",
    quest: "ideological",
  ),
  Words(
    front: "His ignorance of the law led him into trouble.",
    back: "Hukuku bilgisizliği onu başını derde soktu.",
    list: "C1",
    answer: "bilgisizlik",
    quest: "ignorance",
  ),
  Words(
    front:
        "The poem's vivid imagery created a strong emotional response in the reader.",
    back: "Şiirin canlı imgeleri, okuyucuda güçlü bir duygusal tepki yarattı.",
    list: "C1",
    answer: "imgelem",
    quest: "imagery",
  ),
  Words(
    front: "The castle is an immense structure with towering walls.",
    back: "Kale, yükselen duvarları olan devasa bir yapıdır.",
    list: "C1",
    answer:
        "muazzam", // "Immense" can also be translated as "devasa" depending on the context.
    quest: "immense",
  ),
  Words(
    front: "There is an imminent threat of war in the region.",
    back: "Bölgede savaş tehlikesi eli kulağındadır.",
    list: "C1",
    answer: "eli kulağında",
    quest: "imminent",
  ),
  Words(
    front:
        "The successful implementation of the new policy led to positive results.",
    back:
        "Yeni politikanın başarılı bir şekilde uygulanması olumlu sonuçlara yol açtı.",
    list: "C1",
    answer: "uygulama",
    quest: "implementation",
  ),
  Words(
    front: "The criminal was sentenced to ten years' imprisonment.",
    back: "Suçlu, on yıl hapis cezasına çarptırıldı.",
    list: "C1",
    answer: "hapse atmak",
    quest: "imprison",
  ),
  Words(
    front: "He feared the harsh conditions of imprisonment.",
    back: "Hapis hayatının zorlu koşullarından korkuyordu.",
    list: "C1",
    answer: "hapis",
    quest: "imprisonment",
  ),
  Words(
    front: "Her inability to speak the language made communication difficult.",
    back: "Dili konuşamaması iletişimi zorlaştırıyordu.",
    list: "C1",
    answer: "yetersizlik",
    quest: "inability",
  ),
  Words(
    front: "The teacher found the student's explanation inadequate.",
    back: "Öğretmen, öğrencinin açıklamasını yetersiz buldu.",
    list: "C1",
    answer: "yetersiz",
    quest: "inadequate",
  ),
  Words(
    front: "It was inappropriate to tell that joke at the funeral.",
    back: "Cenazede o şakayı anlatmak uygunsuzdu.",
    list: "C1",
    answer: "uygunsuz",
    quest: "inappropriate",
  ),
  Words(
    front: "The report documented a higher incidence of cancer in the area.",
    back: "Raporda, bölgede daha yüksek kanser vakası sayısı belgelendi.",
    list: "C1",
    answer:
        "rastlantı", // "Incidence" can also be translated as "vaka" depending on the context, but "rastlantı" captures the idea of occurrence.
    quest: "incidence",
  ),
  Words(
    front: "He was not inclined to help them with their difficult task.",
    back: "Onlara zor görevlerinde yardım etmeye meyilli değildi.",
    list: "C1",
    answer: "meyilli",
    quest: "inclined",
  ),
  Words(
    front: "The company incurred a heavy loss due to the fire.",
    back: "Şirket, yangın nedeniyle büyük bir zarar gördü.",
    list: "C1",
    answer: "uğramak",
    quest: "incur",
  ),
  Words(
    front: "The economic indicators suggest a possible recession.",
    back: "Ekonomik göstergeler olası bir durgunluğa işaret ediyor.",
    list: "C1",
    answer: "gösterge",
    quest: "indicator",
  ),
  Words(
    front: "The grand jury issued an indictment against the suspect.",
    back: "Jüri heyeti şüpheli hakkında bir iddianame hazırladı.",
    list: "C1",
    answer: "itham",
    quest: "indictment",
  ),
  Words(
    front: "The tribe lived an indigenous way of life in the rainforest.",
    back: "Kabile, yağmur ormanlarında yerli bir yaşam tarzı sürdürdü.",
    list: "C1",
    answer: "yerli",
    quest: "indigenous",
  ),
  Words(
    front:
        "The teacher tried to induce her students to learn more about science.",
    back:
        "Öğretmen, öğrencilerini bilimle daha fazla ilgilenmeye ikna etmeye çalıştı.",
    list: "C1",
    answer: "ikna etmek",
    quest: "induce",
  ),
  Words(
    front: "She likes to indulge in chocolate cake from time to time.",
    back: "Zaman zaman çikolatalı pastaya kendini şımartmayı sever.",
    list: "C1",
    answer: "şımartmak",
    quest: "indulge",
  ),
  Words(
    front:
        "There is a growing inequality in wealth distribution around the world.",
    back: "Dünya çapında servet dağılımında giderek artan bir eşitsizlik var.",
    list: "C1",
    answer: "eşitsizlik",
    quest: "inequality",
  ),
  Words(
    front:
        "Jack the Ripper is an infamous serial killer from Victorian London.",
    back:
        "Jack the Ripper, Viktorya dönemi Londra'sından kötü şöhretli bir seri katildir.",
    list: "C1",
    answer: "kötü şöhretli",
    quest: "infamous",
  ),
  Words(
    front: "A group of infants are playing in the park.",
    back: "Bir grup bebek parkta oynuyor.",
    list: "C1",
    answer: "bebek",
    quest: "infant",
  ),
  Words(
    front: "The cold weather can easily infect you with a cold or the flu.",
    back:
        "Soğuk hava sizi kolayca soğuk algınlığına veya gribe bulaştırabilir.",
    list: "C1",
    answer: "bulaştırmak",
    quest: "infect",
  ),
  Words(
    front:
        "The criminal was charged with inflicting bodily harm on the victim.",
    back: "Suçlu, kurbana ağır yaralama suçlamasıyla suçlandı.",
    list: "C1",
    answer:
        "çarptırmak", // "Inflict" can also be translated as "yapmak" (to do) depending on the context, but "çarptırmak" emphasizes the act of causing harm.
    quest: "inflict",
  ),
  Words(
    front: "He is an influential figure in the world of business.",
    back: "İş dünyasında etkili bir figürdür.",
    list: "C1",
    answer: "etkili",
    quest: "influential",
  ),
  Words(
    front: "Honesty is an inherent quality that everyone should possess.",
    back:
        "Dürüstlük, herkesin sahip olması gereken özünde olan bir özelliktir.",
    list: "C1",
    answer: "özünde olan",
    quest: "inherent",
  ),
  Words(
    front: "The new law will inhibit economic growth.",
    back: "Yeni yasa, ekonomik büyümeyi engelleyecektir.",
    list: "C1",
    answer: "engellemek",
    quest: "inhibit",
  ),
  Words(
    front: "The company has initiated a new marketing campaign.",
    back: "Şirket, yeni bir pazarlama kampanyası başlattı.",
    list: "C1",
    answer: "başlatmak",
    quest: "initiate",
  ),
  Words(
    front: "This injection will make you feel better.",
    back: "Bu iğne kendinizi daha iyi hissetmenizi sağlayacaktır.",
    list: "C1",
    answer:
        "iğne", // "Injection" is more about the act of injecting, "püskürtme" emphasizes squirting or spraying. A better translation is "enjeksiyon".
    quest: "injection",
  ),
  Words(
    front: "The war caused a great deal of injustice and suffering.",
    back: "Savaş, büyük bir adaletsizlik ve ıstıraba neden oldu.",
    list: "C1",
    answer: "adaletsizlik",
    quest: "injustice",
  ),
  Words(
    front: "The editor made some minor insertions into the text.",
    back: "Editör, metne bazı küçük ilaveler yaptı.",
    list: "C1",
    answer: "ilave",
    quest: "insertion",
  ),
  Words(
    front:
        "The police suspect that there is an insider who is leaking information.",
    back: "Polis, bilgi sızdıran bir içeriden biri olduğundan şüpheleniyor.",
    list: "C1",
    answer: "içeriden biri",
    quest: "insider",
  ),
  Words(
    front:
        "The health inspector conducted a thorough inspection of the restaurant.",
    back: "Sağlık müfettişi, restoranda kapsamlı bir denetim gerçekleştirdi.",
    list: "C1",
    answer: "denetlemek",
    quest: "inspect",
  ),
  Words(
    front: "The restaurant received a positive rating after the inspection.",
    back: "Restoran, denetimden sonra olumlu bir değerlendirme aldı.",
    list: "C1",
    answer: "denetleme",
    quest: "inspection",
  ),
  Words(
    front: "He found inspiration for his painting in the beauty of nature.",
    back: "Resminin ilhamını doğanın güzelliğinden aldı.",
    list: "C1",
    answer: "ilham",
    quest: "inspiration",
  ),
  Words(
    front: "Animals often rely on instinct for survival.",
    back: "Hayvanlar genellikle hayatta kalmak için içgüdülerine güvenir.",
    list: "C1",
    answer: "içgüdü",
    quest: "instinct",
  ),
  Words(
    front: "He worked for a large institutional bank.",
    back: "Büyük bir kuruluşa ait bankada çalıştı.",
    list: "C1",
    answer: "kuruluşa ait",
    quest: "institutional",
  ),
  Words(
    front: "The teacher instructed the students to complete the exercise.",
    back: "Öğretmen, öğrencilere alıştırmayı tamamlamaları talimatını verdi.",
    list: "C1",
    answer:
        "haber vermek", // "Instruct" can also be translated as "öğretmek" (to teach) depending on the context.
    quest: "instruct",
  ),
  // Keep the existing "yetersiz" for "insufficient"
  Words(
    front: "He screamed an insult at the referee.",
    back: "Hakeme bağırarak hakaret etti.",
    list: "C1",
    answer:
        "hakaret etmek", // "Insult" means to deliberately say something rude or hurtful. A better translation is "hakaret" or "küfretmek".
    quest: "insult",
  ),
  Words(
    front:
        "The ancient artifact remained intact despite being buried for centuries.",
    back:
        "Eski eser, yüzyıllardır gömülü kalmasına rağmen dokunulmamış olarak kaldı.",
    list: "C1",
    answer: "dokunulmamış",
    quest: "intact",
  ),
  Words(
    front: "The doctor monitored the patient's daily intake of medication.",
    back: "Doktor, hastanın günlük ilaç alım miktarını takip etti.",
    list: "C1",
    answer: "alınan miktar",
    quest: "intake",
  ),
  Words(
    front: "The new technology has been integrated into the existing system.",
    back: "Yeni teknoloji, mevcut sisteme entegre edildi.",
    list: "C1",
    answer: "bütünleşmiş",
    quest: "integrated",
  ),
  Words(
    front:
        "The successful integration of immigrants into society is a complex challenge.",
    back:
        "Göçmenlerin topluma başarılı bir şekilde entegrasyonu karmaşık bir sorundur.",
    list: "C1",
    answer: "bütünleme",
    quest: "integration",
  ),
  Words(
    front: "He is a man of integrity with strong moral principles.",
    back: "O, güçlü ahlaki değerlere sahip dürüst bir insandır.",
    list: "C1",
    answer: "tamamlık",
    quest: "integrity",
  ),
  Words(
    front: "As our economy grows stronger, the war for talent will intensify.",
    back: "Ekonomimiz güçlendikçe yetenek savaşı da şiddetlenecektir.",
    list: "C1",
    answer: "şiddetlenmek",
    quest: "intensify",
  ),
  Words(
    front:
        "The athlete trained with great intensity to prepare for the competition.",
    back: "Sporcu, yarışmaya hazırlanmak için büyük bir yoğunlukla çalıştı.",
    list: "C1",
    answer: "yoğunluk",
    quest: "intensity",
  ),
  Words(
    front:
        "He enrolled in an intensive language course to improve his English quickly.",
    back:
        "İngilizcesini hızlı bir şekilde geliştirmek için yoğun bir dil kursuna kaydoldu.",
    list: "C1",
    answer: "yoğun",
    quest: "intensive",
  ),
  Words(
    front: "What is your intent in asking me this question?",
    back: "Bana bu soruyu sorma niyetin nedir?",
    list: "C1",
    answer: "niyet",
    quest: "intent",
  ),
  Words(
    front:
        "The children enjoyed playing with the interactive whiteboard in class.",
    back: "Çocuklar, sınıftaki etkileşimli tahta ile oynamaktan zevk aldılar.",
    list: "C1",
    answer: "etkileşimli",
    quest: "interactive",
  ),
  Words(
    front: "The user interface of the new software is very user-friendly.",
    back: "Yeni yazılımın arayüzü kullanıcı dostudur.",
    list: "C1",
    answer: "arayüz",
    quest: "interface",
  ),
  Words(
    front: "Please do not interfere with my work.",
    back: "Lütfen işime müdahale etmeyin.",
    list: "C1",
    answer: "müdahale etmek",
    quest: "interfere",
  ),
  Words(
    front:
        "The radio signal was interrupted due to interference from the storm.",
    back: "Fırtınadan kaynaklanan müdahale nedeniyle radyo sinyali kesildi.",
    list: "C1",
    answer: "müdahale",
    quest: "interference",
  ),
  Words(
    front: "In the interim period, a temporary director will be appointed.",
    back: "Geçici dönemde, geçici bir müdür atanacaktır.",
    list: "C1",
    answer: "aralık",
    quest: "interim",
  ),
  Words(
    front: "The designer completely revamped the interior of the house.",
    back: "Tasarımcı, evin iç kısmını tamamen yeniledi.",
    list: "C1",
    answer: "iç,dahili",
    quest: "interior",
  ),
  Words(
    front: "He is taking an intermediate level Spanish course.",
    back: "Orta seviyede bir İspanyolca kursu alıyor.",
    list: "C1",
    answer: "orta seviye",
    quest: "intermediate",
  ),
  Words(
    front: "The police intervened to stop the fight between the two neighbors.",
    back: "Polis, iki komşu arasındaki kavgayı durdurmak için araya girdi.",
    list: "C1",
    answer: "araya girmek",
    quest: "intervene",
  ),
  Words(
    front: "The military intervention in the country was controversial.",
    back: "Ülkeye yapılan askeri müdahale tartışmalıydı.",
    list: "C1",
    answer: "araya girme",
    quest: "intervention",
  ),
  Words(
    front: "They shared an intimate conversation about their hopes and dreams.",
    back: "Umutları ve hayalleri hakkında samimi bir sohbet paylaştılar.",
    list: "C1",
    answer: "samimi",
    quest: "intimate",
  ),
  Words(
    front: "A private investigator was hired to look into the mysterious case.",
    back: "Gizemli vakayı araştırmak için özel bir dedektif tutuldu.",
    list: "C1",
    answer: "dedektif",
    quest: "investigator",
  ),
  Words(
    front:
        "The magician made the rabbit disappear in an invisible puff of smoke.",
    back: "Sihirbaz, tavşanı görünmez bir duman bulutunda yok etti.",
    list: "C1",
    answer: "görünmez",
    quest: "invisible",
  ),
  Words(
    front:
        "He invoked the spirit of his ancestors to guide him through the difficult times.",
    back:
        "Zor zamanlarda kendisine rehberlik etmeleri için atalarının ruhunu çağırdı.",
    list: "C1",
    answer: "yardım istemek",
    quest: "invoke",
  ),
  Words(
    front: "Her involvement in the project led to unexpected complications.",
    back: "Projeye katılması beklenmedik sorunlara yol açtı.",
    list: "C1",
    answer: "bulaşma",
    quest: 'involvement',
  ),
  Words(
    front: "Ironically, the fire station burned down.",
    back: "İşin garip yanı, itfaiye istasyonu yandı.",
    list: "C1",
    answer: "işin garip yanı [zf]",
    quest: "Ironically",
  ),
  Words(
    front:
        "The teacher's irrelevant comments made it difficult to focus on the lesson.",
    back: "Öğretmenin konu dışı yorumları derse odaklanmayı zorlaştırıyordu.",
    list: "C1",
    answer: "konu dışı",
    quest: "irrelevant",
  ),
  Words(
    front:
        "The prisoner was kept in solitary confinement for months, which led to his isolation.",
    back:
        "Mahkum, aylarca tek başına hapiste tutuldu, bu da izolasyonuna yol açtı.",
    list: "C1",
    answer: "izolasyon",
    quest: "isolation",
  ),
  Words(
    front: "The criminal case is under judicial review.",
    back: "Ceza davası yargı denetiminde.",
    list: "C1",
    answer: "yargılayan",
    quest: "judicial",
  ),
  Words(
    front: "The accident happened at the junction of two busy roads.",
    back: "Kaza, iki yoğun yolun birleştiği yerde meydana geldi.",
    list: "C1",
    answer: "birleşme yeri",
    quest: "junction",
  ),
  Words(
    front:
        "The crime falls outside the jurisdiction of the local police department.",
    back: "Suç, yerel polis departmanının yetki alanının dışında kalıyor.",
    list: "C1",
    answer: "yargı",
    quest: "jurisdiction",
  ),
  // "Just" can have several meanings. Here we use "sadece" for "just" meaning "fair".
  Words(
    front: "He is a just and fair leader who treats everyone equally.",
    back: "O, herkese eşit davranan adil bir liderdir.",
    list: "C1",
    answer: "sadece, adil",
    quest: "just",
  ),
  Words(
    front: "He offered a reasonable justification for his actions.",
    back: "Hareketleri için makul bir gerekçe sundu.",
    list: "C1",
    answer: "gerekçe",
    quest: "justification",
  ),
  Words(
    front: "The human body has two kidneys.",
    back: "İnsan vücudunda iki böbrek bulunur.",
    list: "C1",
    answer: "böbrek",
    quest: "kidney",
  ),
  Words(
    front: "The United Kingdom is a kingdom with a rich history.",
    back: "Birleşik Krallık, zengin bir tarihe sahip bir krallıktır.",
    list: "C1",
    answer: "krallık",
    quest: "kingdom",
  ),
  Words(
    front: "He's a young lad who just graduated from high school.",
    back: "O, liseden yeni mezun olmuş genç bir delikanlı.",
    list: "C1",
    answer: "delikanlı",
    quest: "lad",
  ),
  Words(
    front: "We need to find a new landlord as soon  our lease expires.",
    back:
        "Kira sözleşmemiz sona erer ermez yeni bir ev sahibi bulmamız gerekiyor.",
    list: "C1",
    answer: "ev sahibi",
    quest: "landlord",
  ),
  Words(
      front: "The Eiffel Tower is a famous landmark in Paris.",
      back: "Eyfel Kulesi, Paris'in ünlü bir simgesidir.",
      list: "C1",
      answer: "simge",
      quest:
          'landmark' // "Sınır işareti" means "boundary marker". A better translation for "landmark" is "simge" or "anıt".
      ),
  Words(
    front: "Tom fell off his mother's lap.",
    back: "Tom annesinin kucağından düştü.",
    list: "C1",
    answer: "kucak",
    quest: "lap",
  ),
  Words(
    front: "The company is undergoing a large-scale restructuring.",
    back: "Şirket, büyük ölçekli bir yeniden yapılanma sürecinden geçiyor.",
    list: "C1",
    answer: "büyük",
    quest: "large-scale",
  ),
  Words(
    front: "The latter option seems to be the more feasible one.",
    back: "İkinci seçenek daha uygun görünüyor.",
    list: "C1",
    answer: "ikincisi",
    quest: "latter",
  ),
  Words(
    front: "He spent the weekend relaxing in his backyard lawn.",
    back: "Hafta sonunu arka bahçesindeki çimenlikte dinlenerek geçirdi.",
    list: "C1",
    answer: "çimenlik",
    quest: "lawn",
  ),
  Words(
    front: "He is facing a lawsuit for breach of contract.",
    back: "Sözleşme ihlali nedeniyle dava ile karşı karşıya.",
    list: "C1",
    answer: "dava",
    quest: "lawsuit",
  ),
  Words(
    front: "The website has a user-friendly layout.",
    back: "Web sitesinin kullanıcı dostu bir düzeni var.",
    list: "C1",
    answer: "düzen",
    quest: "layout",
  ),
  Words(
    front: "The confidential information was leaked to the press.",
    back: "Gizli bilgiler basına sızdırıldı.",
    list: "C1",
    // "Sıçratmak" means "to splash" or "to splatter". A better translation for "leak" is "sızdırmak".
    answer: "sızdırmak",
    quest: "leak",
  ),
  Words(
    front:
        "The athlete took a great leap forward in his career after winning the championship.",
    back:
        "Sporcu, şampiyonluğu kazandıktan sonra kariyerinde büyük bir sıçrama yaptı.",
    list: "C1",
    answer: "sıçratmak",
    quest: "leap",
  ),
  Words(
    front: "He left a legacy of groundbreaking scientific discoveries.",
    back: "Çığır açan bilimsel keşifler mirası bıraktı.",
    list: "C1",
    answer: "miras",
    quest: "legacy",
  ),
  Words(
    front: "King Arthur is a legendary figure in British history.",
    back: "Kral Arthur, İngiliz tarihinde efsanevi bir figürdür.",
    list: "C1",
    answer: "efsanevi",
    quest: "legendary",
  ),
  Words(
    front: "New legislation was passed to combat climate change.",
    back: "İklim değişikliğiyle mücadele etmek için yeni kanunlar çıkarıldı.",
    list: "C1",
    answer: "kanunlar",
    quest: "legislation",
  ),
  Words(
    front:
        "The legislative branch of government is responsible for making laws.",
    back: "Hükümetin yasama organı, yasaları çıkarmaktan sorumludur.",
    list: "C1",
    answer: "yasama",
    quest: "legislative",
  ),
  Words(
    front: "The legislature is responsible for making laws.",
    back: "Yasama organı kanun yapmaktan sorumludur.",
    list: "C1",
    answer: "parlamento",
    quest: "legislature",
  ),
  Words(
    front: "He had a legitimate reason for being late.",
    back: "Geç kalmasının meşru bir sebebi vardı.",
    list: "C1",
    answer: "meşrulaştırmak",
    quest: "legitimate",
  ),
  Words(
    front: "The meeting was a lengthy one, lasting for over three hours.",
    back: "Toplantı üç saatten fazla süren uzun bir toplantıydı.",
    list: "C1",
    answer: "fazlasıyla uzun",
    quest: "lengthy",
  ),
  Words(
    front:
        "The two companies are merging to create a lesser competitor in the market.",
    back:
        "Bu iki şirket, pazarda daha az güçlü bir rakip oluşturmak için birleşiyor.",
    list: "C1",
    answer: "daha az,daha güçsüz",
    quest:
        'lesser', // "Kiralayan" means "lessor" or "landlord". A better translation for "lesser" here is "daha az" or "daha güçsüz".
  ),
  Words(
    front: "The snake venom is lethal and can cause death within minutes.",
    back: "Yılan zehiri ölümcüdür ve dakikalar içinde ölüme neden olabilir.",
    list: "C1",
    answer: "öldürücü",
    quest: "lethal",
  ),
  Words(
    front: "He is legally liable for the damages caused by the accident.",
    back: "Kazanın neden olduğu hasarlardan yasal olarak sorumludur.",
    list: "C1",
    answer: "yükümlü",
    quest: "liable",
  ),
  Words(
    front: "Liberty is one of the fundamental human rights.",
    back: "Özgürlük, temel insan haklarından biridir.",
    list: "C1",
    answer: "özgürlük",
    quest: "Liberty",
  ),
  Words(
    front: "You need a driver's license to operate a car.",
    back: "Araba kullanmak için ehliyet gereklidir.",
    list: "C1",
    answer: "ruhsat",
    quest: "license",
  ),
  Words(
    front: "He has a lifelong passion for learning.",
    back: "Hayat boyu öğrenmeye karşı bir tutkusu var.",
    list: "C1",
    answer: "hayat boyu",
    quest: "lifelong",
  ),
  Words(
    front: "The likelihood of rain this weekend is very high.",
    back: "Bu hafta sonu yağmur yağma olasılığı çok yüksek.",
    list: "C1",
    answer: "olası olma",
    quest: "likelihood",
  ),
  Words(
    front: "There is a linear relationship between exercise and weight loss.",
    back: "Egzersiz ve kilo kaybı arasında doğrusal bir ilişki vardır.",
    list: "C1",
    answer: "doğrusal,çizgisel",
    quest: "linear",
  ),
  Words(
    front:
        "The police are asking witnesses to come forward and line up to give their statements.",
    back:
        "Polis, tanıkların ifadelerini vermek üzere öne çıkıp sıraya girmelerini istiyor.",
    list: "C1",
    answer: "sıraya girmek",
    quest: 'line up',
  ),
  Words(
    front: "We lingered a while after the party to chat with some friends.",
    back: "Partiden sonra biraz oyalanıp bazı arkadaşlarla sohbet ettik.",
    list: "C1",
    answer: "oyalanmak",
    quest: "linger",
  ),
  Words(
    front: "The house is up for listing this weekend.",
    back: "Ev bu hafta sonu satışa çıkarılıyor.",
    list: "C1",
    answer: "kayıt",
    quest: "listing",
  ),
  Words(
    front:
        "The government is working on improving literacy rates in the country.",
    back:
        "Hükümet, ülkedeki okuryazarlık oranlarını iyileştirmek için çalışıyor.",
    list: "C1",
    answer: "okuryazarlık",
    quest: "literacy",
  ),
  Words(
    front: "The liver is the largest organ in the human body.",
    back: "Karaciğer, insan vücudundaki en büyük organdır.",
    list: "C1",
    answer: "karaciğer",
    quest: "liver",
  ),
  Words(
    front:
        "The environmental group is lobbying for stricter regulations on pollution.",
    back:
        "Çevre grubu, kirlilik konusunda daha sıkı düzenlemeler için lobi faaliyetleri yürütüyor.",
    list: "C1",
    answer: "lobi",
    quest: "lobby",
  ),
  Words(
    front: "The captain made a note of the ship's location in the log.",
    back: "Kaptan, geminin konumunu günlük kaydına not aldı.",
    list: "C1",
    // "Kütük" means "tree trunk" or "log" in the context of wood. A better translation for "log" here is " günlük" (daily record).
    answer: "kütük",
    quest: "log",
  ),
  Words(
    front:
        "His explanation didn't follow logic and was full of contradictions.",
    back: "Açıklaması mantığa uymuyordu ve çelişkilerle doluydu.",
    list: "C1",
    answer: "mantık",
    quest: "logic",
  ),
  Words(
    front:
        "There has been a long-standing rivalry between the two universities.",
    back: "İki üniversite arasında uzun süredir devam eden bir rekabet var.",
    list: "C1",
    answer: "epeydir devam eden",
    quest: "long-standing",
  ),
  Words(
    front: "The weaver used a loom to create a beautiful tapestry.",
    back: "Dokumacı, güzel bir halı yapmak için dokuma tezgahı kullandı.",
    list: "C1",
    answer: "dokuma tezgahı",
    quest: "loom",
  ),
  Words(
    front: "He wrote a loop in the code to repeat the process ten times.",
    back: "İşlemi on kez tekrarlamak için koda bir döngü yazdı.",
    list: "C1",
    answer: "döngü",
    quest: "loop",
  ),
  Words(
    front: "The dog showed great loyalty to its owner.",
    back: "Köpek, sahibine büyük sadakat gösterdi.",
    list: "C1",
    answer: "sadakat",
    quest: "loyalty",
  ),
  Words(
    front: "The factory is filled with loud machinery.",
    back: "Fabrika gürültülü makinelerle dolu.",
    list: "C1",
    answer: "makineler",
    quest: "machinery",
  ),
  Words(
    front:
        "The magician performed a magical trick that left the audience speechless.",
    back: "Sihirbaz, izleyiciyi şaşkına çeviren büyülü bir numara yaptı.",
    list: "C1",
    answer: "büyülü",
    quest: "magical",
  ),
  Words(
    front:
        "The magistrate is a judicial officer who presides over lower courts.",
    back: "Sulh hakimi, alt mahkemelerde başkanlık yapan bir yargı memurudur.",
    list: "C1",
    answer: "sulh hakimi",
    quest: "magistrate",
  ),
  Words(
    front: "The phone uses a magnetic field to transmit data.",
    back: "Telefon, veriyi iletmek için manyetik alan kullanır.",
    list: "C1",
    answer: "mıknatıslı",
    quest: "magnetic",
  ),
  Words(
    front:
        "The earthquake was of a significant magnitude, causing widespread damage.",
    back: "Deprem, büyük bir şiddetteydi ve yaygın hasara neden oldu.",
    list: "C1",
    answer: "büyüklük",
    quest: "magnitude",
  ),
  Words(
    front: "They are planning a vacation to the Greek mainland.",
    back: "Yunanistan anakarasına bir tatil planlıyorlar.",
    list: "C1",
    answer: "ana kara",
    quest: "mainland",
  ),
  Words(
    front: "The company is trying to mainstream electric vehicles.",
    back: "Şirket, elektrikli araçları yaygın hale getirmeye çalışıyor.",
    list: "C1",
    answer: "yaygın hale getirmek",
    quest: "mainstream",
  ),
  Words(
    front:
        "Regular car maintenance is essential for keeping your vehicle safe.",
    back:
        "Düzenli araç bakımı, aracınızın güvenliğini sağlamak için gereklidir.",
    list: "C1",
    answer: "bakım",
    quest: "maintenance",
  ),
  Words(
    front:
        "The United Nations has a mandate to maintain international peace and security.",
    back:
        "Birleşmiş Milletler'in uluslararası barış ve güvenliği sağlama yetkisi vardır.",
    list: "C1",
    answer:
        "manda altına almak", // "Manda altına almak" means "to mandate" but in a more colonial context. A better translation for "mandate" here is "yetki".
    quest: "mandate",
  ),
  Words(
    front: "Wearing a mask is mandatory on public transportation.",
    back: "Toplu taşımada maske takmak zorunludur.",
    list: "C1",
    answer: "zorunlu",
    quest: "mandatory",
  ),
  Words(
    front: "His guilt was manifest in his facial expressions.",
    back: "Suçluluğu yüz ifadelerinde açıkça belli oluyordu.",
    list: "C1",
    answer: "açıkça göstermek",
    quest: "manifest",
  ),
  Words(
    front: "The author is working on a new manuscript for a historical novel.",
    back: "Yazar, tarihi bir roman için yeni bir müsvedde üzerinde çalışıyor.",
    list: "C1",
    answer: "müsvedde",
    quest: "manuscript",
  ),
  Words(
    front: "Thousands of people participated in the march for climate justice.",
    back: "Binlerce insan iklim adaleti yürüyüşüne katıldı.",
    list: "C1",
    answer: "yürüyüş(topluca)",
    quest: "march",
  ),
  Words(
    front:
        "The marketplace is a bustling center of commerce with a variety of shops and stalls.",
    back:
        "Pazar yeri, çeşitli dükkanları ve tezgahlarıyla hareketli bir ticaret merkezidir.",
    list: "C1",
    answer: "pazar yeri",
    quest: "marketplace",
  ),
  Words(
    front: "He wore a mask to hide his identity during the robbery.",
    back: "Soygun sırasında kimliğini gizlemek için maske taktı.",
    // "Maskelemek" is not a common verb in Turkish. A better translation for "mask" here is "takmak".
    list: "C1",
    answer: "maske",
    quest: 'mask',
  ),
  Words(
    front: "The war resulted in a horrific massacre of civilians.",
    back: "Savaş, korkunç bir katliamla sonuçlandı.",
    list: "C1",
    answer: "katliam",
    quest: "massacre",
  ),
  Words(
    front: "He has become a more mature and responsible person over the years.",
    back: "Yıllar içinde daha olgun ve sorumlu bir insan oldu.",
    list: "C1",
    answer: "olgun",
    quest: "mature",
  ),
  Words(
    front: "The company is looking for ways to maximize its profits.",
    back: "Şirket, kârını en üst düzeye çıkarmanın yollarını arıyor.",
    list: "C1",
    answer: "yükseltmek",
    quest: "maximize",
  ),
  Words(
    front: "He is searching for a meaningful career path.",
    back: "Anlamlı bir kariyer yolu arıyor.",
    list: "C1",
    answer: "anlamlı",
    quest: "meaningful",
  ),
  Words(
    front:
        "I'll finish this report, and in the meantime, you can start working on the presentation.",
    back:
        "Bu raporu bitireceğim, arada sen de sunum üzerinde çalışmaya başlayabilirsin.",
    list: "C1",
    answer: "ara",
    quest: "meantime",
  ),
  Words(
    front: "The castle is a well-preserved example of medieval architecture.",
    back: "Kale, ortaçağ mimarisinin iyi korunmuş bir örneğidir.",
    list: "C1",
    answer: "ortaçağ",
    quest: "medieval",
  ),
  Words(
    front: "She practices meditation to relieve stress.",
    back: "Stresi azaltmak için meditasyon yapıyor.",
    list: "C1",
    answer: "meditasyon",
    quest: "meditation",
  ),
  Words(
    front:
        "He left a memo on his colleague's desk reminding them about the meeting.",
    back: "Meslektaşının masasında toplantıyı hatırlatan bir bildiri bıraktı.",
    list: "C1",
    answer: "bildiri",
    quest: "memo",
  ),
  Words(
    front: "She wrote a memoir about her experiences during World War II.",
    back:
        "II. Dünya Savaşı sırasında yaşadıklarını anlatan bir inceleme yazısı yazdı.",
    list: "C1",
    answer: "inceleme yazısı",
    quest: "memoir",
  ),
  Words(
    front:
        "The war memorial honors the soldiers who lost their lives in the conflict.",
    back: "Savaş anıtı, çatışmada hayatını kaybeden askerleri onurlandırıyor.",
    list: "C1",
    answer:
        "önerge", // "Öneri" means "suggestion" or "proposal". A better translation for "memorial" here is "anıt".
    quest: "memorial",
  ),
  Words(
    front:
        "He found a mentor who helped him navigate the challenges of starting his own business.",
    back:
        "Kendi işini kurmanın zorluklarında yolunu bulmasına yardımcı olan bir akıl hocası buldu.",
    list: "C1",
    answer: "akıl hocalığı yapmak",
    quest: "mentor",
  ),
  Words(
    front: "The merchant traveled the world in search of exotic spices.",
    back: "Tüccar, egzotik baharatlar aramak için dünyayı gezdi.",
    list: "C1",
    answer: "tüccar",
    quest: "merchant",
  ),
  Words(
    front: "He showed mercy to his defeated opponent.",
    back: "Mağlup olmuş rakibine merhamet gösterdi.",
    list: "C1",
    answer: "merhamet",
    quest: "mercy",
  ),
  Words(
    front: "The path led through a swampy mere.",
    back: "Yol bataklık bir alandan geçiyordu.",
    list: "C1",
    answer: "bataklık",
    quest: "mere",
  ),
  Words(
    front: "He merely suggested they postpone the meeting.",
    back: "Sadece toplantıyı ertelemelerini önerdi.",
    list: "C1",
    answer: "yalnızca",
    quest: "merely",
  ),
  Words(
    front: "Their companies are planning to merge in the New Year.",
    back: "Şirketleri yeni yılda birleşmeyi planlıyor.",
    list: "C1",
    answer: "birleşmek",
    quest: "merge",
  ),
  Words(
    front: "The merger of the two banks is expected to be finalized next year.",
    back: "İki bankanın birleşmesinin önümüzdeki yıl tamamlanması bekleniyor.",
    list: "C1",
    answer: "birleşme",
    quest: "merger",
  ),
  Words(
    front: "He was awarded a scholarship based on his academic merit.",
    back: "Akademik başarılarına göre burs kazandı.",
    list: "C1",
    answer: "erdem",
    quest: "merit",
  ),
  Words(
    front: "In the midst of the chaos, he remained calm and collected.",
    back: "Kaosun ortasında sakin ve soğukkanlı kaldı.",
    list: "C1",
    // "Orta yer" can be used for "midst" in some contexts, but "ortasında" is a more natural translation here.
    answer: "orta yer",
    quest: "midst",
  ),
  Words(
    front: "The annual bird migration is a fascinating natural phenomenon.",
    back: "Yıllık kuş göçü, büyüleyici bir doğal olaydır.",
    list: "C1",
    answer: "göç",
    quest: "migration",
  ),
  Words(
    front: "The old windmill is a picturesque landmark in the village.",
    back: "Eski değirmen, köyde pitoresk bir simgedir.",
    list: "C1",
    answer: "değirmen",
    quest: "mill",
  ),
  Words(
    front: "We need to make some minimal changes to the design.",
    back: "Tasarımda bazı asgari değişiklikler yapmamız gerekiyor.",
    list: "C1",
    answer: "asgari",
    quest: "minimal",
  ),
  Words(
    front:
        "Their goal is to minimize the environmental impact of their products.",
    back: "Amaçları, ürünlerinin çevresel etkisini en aza indirmektir.",
    list: "C1",
    answer: "küçültmek",
    quest: "minimize",
  ),
  Words(
    front: "Coal mining is a dangerous and often deadly industry.",
    back: "Kömür madenciliği tehlikeli ve çoğu zaman ölümcül bir sektördür.",
    list: "C1",
    answer: "maden kazma",
    quest: "mining",
  ),
  Words(
    front:
        "The Ministry of Education is responsible for developing the national curriculum.",
    back: "Milli Eğitim Bakanlığı, ulusal müfredatı geliştirmekten sorumludur.",
    list: "C1",
    answer: "bakanlık",
    quest: "Ministry",
  ),
  Words(
    front: "Take a five-minute break to rest your eyes.",
    back: "Gözlerinizi dinlendirmek için beş dakika ara verin.",
    list: "C1",
    answer: "dakika",
    quest: "minute",
  ),
  Words(
    front: "It would be a miracle if they win the championship.",
    back: "Şampiyonluğu kazanırlarsa mucize olurdu.",
    list: "C1",
    answer: "mucize",
    quest: "miracle",
  ),
  Words(
    front: "He lived a life of poverty and misery.",
    back: "Yoksulluk ve sefalet içinde bir hayat yaşadı.",
    list: "C1",
    answer: "sefalet",
    quest: "misery",
  ),
  Words(
    front:
        "The advertisement contained misleading information about the product.",
    back: "Reklam, ürün hakkında yanıltıcı bilgiler içeriyordu.",
    list: "C1",
    answer: "yanıltıcı",
    quest: "misleading",
  ),
  Words(
    front: "The country is developing ballistic missiles as a deterrent.",
    back: "Ülke caydırıcı olarak balistik füzeler geliştiriyor.",
    list: "C1",
    answer:
        "kurşun", // "Kurşun" means "bullet" in Turkish. A better translation for "missile" is "füze".
    quest: "missile",
  ),
  Words(
    front: "An angry mob gathered outside the parliament building.",
    back: "Öfkeli bir kalabalık parlamento binası dışında toplandı.",
    list: "C1",
    answer: "toplanmak",
    quest: "mob",
  ),
  Words(
    front: "Regular exercise is essential for maintaining good mobility.",
    back: "İyi hareketliliği korumak için düzenli egzersiz yapmak önemlidir.",
    list: "C1",
    answer: "hareketlilik",
    quest: "mobility",
  ),
  Words(
    front: "We need to take a moderate approach to solving this problem.",
    back: "Bu sorunu çözmek için ılıman bir yaklaşım benimsememiz gerekiyor.",
    list: "C1",
    answer: "ılıman",
    quest: "moderate",
  ),
  Words(
    front: "The new design is just a minor modification of the original.",
    back: "Yeni tasarım, orijinalin sadece küçük bir değişikliğidir.",
    list: "C1",
    answer: "küçük değişiklik",
    quest: "modification",
  ),
  Words(
    front: "The team is building momentum as they win more games.",
    back: "Takım daha fazla oyun kazandıkça hızlanma kazanıyor.",
    list: "C1",
    answer: "hızlanma",
    quest: "momentum",
  ),
  Words(
    front: "The monk devoted his life to prayer and meditation.",
    back: "Keşiş hayatını dua ve meditasyona adadı.",
    list: "C1",
    answer: "keşiş",
    quest: "monk",
  ),
  Words(
    front:
        "The company has a monopoly on the production of sugar in the country.",
    back: "Şirket, ülkede şeker üretiminde tekel durumundadır.",
    list: "C1",
    answer: "tekel",
    quest: "monopoly",
  ),
  Words(
    front: "He acted out of a sense of morality and justice.",
    back: "Ahlak ve adalet duygusuyla hareket etti.",
    list: "C1",
    answer: "ahlaklılık",
    quest: "morality",
  ),
  Words(
    front: "The police are investigating the motive behind the crime.",
    back: "Polis, suçun arkasındaki güdüleri araştırıyor.",
    list: "C1",
    answer: "güdü",
    quest: "motive",
  ),
  Words(
    front: "The motorist was pulled over for speeding.",
    back: "Şoför hız yaptığı için durduruldu.",
    list: "C1",
    answer: "şoför",
    quest: "motorist",
  ),
  Words(
    front: "The park is owned and maintained by the municipality.",
    back: "Park belediyeye aittir ve belediye tarafından bakımı yapılır.",
    list: "C1",
    answer: "belediyeye ait",
    quest: "municipal",
  ),
  Words(
    front: "They have a mutual respect for each other.",
    back: "Birbirlerine karşı ortak bir saygıları var.",
    list: "C1",
    answer: "ortak",
    quest: "mutual",
  ),
  Words(
    front: "The capital city, namely Ankara, is a modern metropolis.",
    back: "Başkent olan Ankara, modern bir metropolüdür.",
    list: "C1",
    answer: "olarak adlandırılan",
    quest: "namely",
  ),
  Words(
    front: "The company launched a nationwide advertising campaign.",
    back: "Şirket, ülke çapında bir reklam kampanyası başlattı.",
    list: "C1",
    answer:
        "bütün millete ait", // "Bütün millete ait" means "national" in a more literal sense. A better translation for "nationwide" is "ülke çapında".
    quest: "nationwide",
  ),
  Words(
    front: "The country has a powerful naval force.",
    back: "Ülkenin güçlü bir deniz kuvveti vardır.",
    list: "C1",
    answer: "denizcilik",
    quest: "naval",
  ),
  Words(
    front: "He neglected his responsibilities for too long.",
    back: "Sorumluluklarını çok uzun süre ihmal etti.",
    list: "C1",
    answer: "ihmal etmek",
    quest: "neglect",
  ),
  Words(
    front: "The neighbouring countries decided to sign a peace treaty.",
    back: "Komşu ülkeler bir barış antlaşması imzalamaya karar verdi.",
    list: "C1",
    answer:
        "bitişik, komşu", // "Bitişik" means "adjacent" or "attached". A better translation for "neighbouring" is "komşu".
    quest: "neighbouring",
  ),
  Words(
    front: "The bird built its nest in a tall tree.",
    back: "Kuş, yuvasını yüksek bir ağaca yaptı.",
    list: "C1",
    answer: "yuva",
    quest: "nest",
  ),
  Words(
    front: "He is caught in a net of his own making.",
    back: "Kendi kurduğu bir ağa yakalandı.",
    list: "C1",
    answer: "şebeke",
    quest: "net",
  ),
  Words(
    front: "I receive a monthly newsletter with company updates.",
    back: "Şirket güncellemelerini içeren aylık bir haber bülteni alıyorum.",
    list: "C1",
    answer: "haber bülteni",
    quest: "newsletter",
  ),
  Words(
    front: "She found a niche market for her handmade crafts.",
    back: "El yapımı el sanatları için uygun bir yer buldu.",
    list: "C1",
    answer:
        "uygun yere koymak", // "Uygun yere koymak" means "to place something in a suitable location". A better translation for "niche" is "özel alan".
    quest: "niche",
  ),
  Words(
    front: "He is a noble man with a strong sense of justice.",
    back: "Adalet duygusu güçlü, soylu bir adamdır.",
    list: "C1",
    answer: "soylu",
    quest: "noble",
  ),
  Words(
    front: "The crowd gave a silent nod of approval.",
    back: "Kalabalık sessiz bir onay işareti verdi.",
    list: "C1",
    answer:
        "seçilmek", // "Seçilmek" means "to be chosen".  A better translation for "nod" here is "baş sallamak".
    quest: "nod",
  ),
  Words(
    front: "The president nominated her to be the next secretary of state.",
    back: "Başkan, onu bir sonraki dışişleri bakanı olarak görevlendirdi.",
    list: "C1",
    answer: "görevlendirmek",
    quest: "nominate",
  ),
  Words(
    front:
        "There were several nominations for the employee of the month award.",
    back: "Ayın çalışanı ödülü için birkaç aday gösterme vardı.",
    list: "C1",
    answer: "aday gösterme",
    quest: "nomination",
  ),
  Words(
    front: "Who is the nominee for the CEO position?",
    back: "CEO pozisyonu için vekil kim?",
    list: "C1",
    answer:
        "vekil", // "Vekil" can mean "representative" in some contexts, but "aday" is a more natural translation for "nominee" here.
    quest: "nominee",
  ),
  Words(
    front: "He won the competition nonetheless.",
    back: "Bununla beraber yarışmayı kazandı.",
    list: "C1",
    answer: "bununla beraber",
    quest: "nonetheless",
  ),
  Words(
    front:
        "The organization is a non-profit that provides educational resources.",
    back:
        "Kurum, eğitim kaynakları sağlayan kar amacı gütmeyen bir kuruluştur.",
    list: "C1",
    answer: "kar etmeyen",
    quest: "non-profit",
  ),
  Words(
    front: "Stop talking nonsense and get to work!",
    back: "Saçmalık konuşmayı bırak ve işe koyul!",
    list: "C1",
    answer: "saçmalık",
    quest: "nonsense",
  ),
  Words(
    front: "The meeting will be held at noon tomorrow.",
    back: "Toplantı yarın öğle vakti yapılacak.",
    list: "C1",
    answer: "öğle vakti",
    quest: "noon",
  ),
  Words(
    front: "A notable feature of the building is its stained-glass windows.",
    back: "Binanın göze çarpan bir özelliği vitray pencereleridir.",
    list: "C1",
    answer: "göze çarpan",
    quest: "notable",
  ),
  Words(
    front: "She is notably absent from today's meeting.",
    back: "Bugünkü toplantıda açıkça yok.",
    list: "C1",
    answer:
        "açıkça", // "Açıkça" means "clearly" here. A better translation for "notably" is "özellikle" or "dikkat çekici bir şekilde".
    quest: "notably",
  ),
  Words(
    front: "We will notify you when your order is shipped.",
    back: "Siparişiniz gönderildiğinde size bildireceğiz.",
    list: "C1",
    answer: "bildirmek",
    quest: "notify",
  ),
  Words(
    front: "Al Capone was a notorious gangster during the Prohibition Era.",
    back: "Al Capone, Yasakçılık Dönemi'nde kötü şöhretli bir gangsterdi.",
    list: "C1",
    answer: "kötü şöhretli",
    quest: "notorious",
  ),
  Words(
    front: "I'm reading a fascinating novel about a dystopian future.",
    back: "Distopik bir gelecek hakkında büyüleyici bir roman okuyorum.",
    list: "C1",
    answer: "roman",
    quest: "novel",
  ),
  Words(
    front: "The baby is sleeping peacefully in the nursery.",
    back: "Bebek çocuk odasında huzur içinde uyuyor.",
    list: "C1",
    answer: "çocuk odası",
    quest: "nursery",
  ),
  Words(
    front: "He raised no objection to the proposal.",
    back: "Öneriye karşı herhangi bir karşı gelme göstermedi.",
    list: "C1",
    answer: "karşı gelme",
    quest: "objection",
  ),
  Words(
    front: "The law obliges all citizens to pay taxes.",
    back: "Yasa, tüm vatandaşları vergi ödemeye zorunlu kılar.",
    list: "C1",
    answer: "zorunda bırakmak",
    quest: "oblige",
  ),
  Words(
    front: "He is obsessed with winning the competition.",
    back: "Yarışmayı kazanmaya saplantı haline getirdi.",
    list: "C1",
    answer: "saplantı haline getirmek",
    quest: "obsess",
  ),
  Words(
    front: "Her fear of public speaking is a common obsession.",
    back: "Halka konuşma korkusu, yaygın bir takıntıdır.",
    list: "C1",
    answer: "takıntı",
    quest: "obsession",
  ),
  Words(
    front: "We have occasional meetings to discuss current projects.",
    back: "Mevcut projeleri tartışmak için ara sıra toplantılar yaparız.",
    list: "C1",
    answer: "ara sıra olan",
    quest: "occasional",
  ),
  Words(
    front: "The accident was a rare occurrence.",
    back: "Kaza ender rastlanan bir buluntu oldu.",
    list: "C1",
    answer:
        "bulunma", // "Bulunma" means "finding" or "existence" here. A better translation for "occurrence" is "olay".
    quest: "occurrence",
  ),
  Words(
    front: "The odds of winning the lottery are very low.",
    back: "Milli piyango kazanma ihtimali çok düşüktür.",
    list: "C1",
    answer: "ihtimal",
    quest: "odds",
  ),
  Words(
    front: "The factory is now fully operational after the repairs.",
    back: "Fabrika onarımların ardından artık tamamen çalıştırma durumunda.",
    list: "C1",
    answer: "çalıştırma",
    quest: "operational",
  ),
  Words(
    front: "I opted for the healthier option on the menu.",
    back: "Menüdeki daha sağlıklı seçeneği tercih ettim.",
    list: "C1",
    answer: "karar kılmak",
    quest: "opt",
  ),
  Words(
    front: "He needs glasses because of his poor optical vision.",
    back: "Zayıf görme yeteneği nedeniyle gözlüğe ihtiyacı var.",
    list: "C1",
    answer:
        "görüş", // "Görüş" means "opinion" here. A better translation for "optical" is "optik".
    quest: "optical",
  ),
  Words(
    front:
        "In recent months we have seen growing optimism and confidence about Europe's future.",
    back:
        "Son aylarda, Avrupa'nın geleceği hakkında artan bir iyimserlik ve güven gördük.",
    list: "C1",
    answer: "iyimserlik",
    quest: "optimism",
  ),
  Words(
    front: "The exam will be conducted orally this year.",
    back: "Sınav bu yıl sözlü olarak yapılacak.",
    list: "C1",
    answer: "sözlü, ağız",
    quest: "oral",
  ),
  Words(
    front: "The custom originated in ancient Greece.",
    back: "Bu adet, antik Yunanistan'da kaynaklandı.",
    list: "C1",
    answer: "kaynaklanmak",
    quest: "originate",
  ),
  Words(
    front: "The outbreak of the disease caused widespread panic.",
    back: "Hastalığın salgını yaygın paniğe neden oldu.",
    list: "C1",
    answer: "salgın",
    quest: "outbreak",
  ),
  Words(
    front: "We are planning a family outing to the park this weekend.",
    back: "Bu hafta sonu parka bir aile gezisi planlıyoruz.",
    list: "C1",
    answer: "tur",
    quest: "outing",
  ),
  Words(
    front: "This store is a brand outlet that sells discounted clothing.",
    back: "Bu mağaza indirimli kıyafet satan bir marka satış yeridir.",
    list: "C1",
    answer: "satış yeri",
    quest: "outlet",
  ),
  Words(
    front: "The economic outlook for the next year is uncertain.",
    back: "Önümüzdeki yıl için ekonomik görünüm belirsiz.",
    list: "C1",
    answer: "görünüm",
    quest: "outlook",
  ),
  Words(
    front: "His comments caused outrage among the audience.",
    back: "Yorumları seyirciler arasında öfke yarattı.",
    list: "C1",
    answer:
        "hakaret etmek", // "Hakaret etmek" means "to insult". A better translation for "outrage" is "tepkili".
    quest: "outrage",
  ),
  Words(
    front: "He felt like an outsider in his own family.",
    back: "Kendi ailesinde kendini bir dışarıdaki gibi hissetti.",
    list: "C1",
    answer: "dışarıdaki",
    quest: "outsider",
  ),
  Words(
    front: "I can't overlook his constant mistakes any longer.",
    back: "Artık sürekli yaptığı hataları görmezden gelemem.",
    list: "C1",
    answer: "hoşgörmek",
    quest: "overlook",
  ),
  Words(
    front: "He is overly cautious when it comes to taking risks.",
    back: "Risk almak söz konusu olduğunda aşırı temkinlidir.",
    list: "C1",
    answer: "fazlaca",
    quest: "overly",
  ),
  Words(
    front: "The manager oversees the daily operations of the company.",
    back: "Yönetici, şirketin günlük operasyonlarını denetler.",
    list: "C1",
    answer: "yönetmek",
    quest: "oversee",
  ),
  Words(
    front: "The recent court decision overturned the previous ruling.",
    back: "Son mahkeme kararı önceki kararı bozdu.",
    list: "C1",
    answer: "devrilmek",
    quest: "overturn",
  ),
  Words(
    front: "The workload is overwhelming, but I will try my best.",
    back: "İş yükü ezici, ama elimden geleni yapacağım.",
    list: "C1",
    answer:
        "mahcup etmek", // "Mahcup etmek" means "to embarrass". A better translation for "overwhelm" is "bunalım".
    quest: "overwhelm",
  ),
  Words(
    front:
        "The team felt overwhelmed by the overwhelming support from the fans.",
    back: "Takım, taraftarların ezici desteği karşısında bunaldı.",
    list: "C1",
    answer: "ezici",
    quest: "overwhelming",
  ),
  Words(
    front: "I need a new pad for my tablet computer.",
    back: "Tablet bilgisayarım için yeni bir ufak yastık almam gerekiyor.",
    list: "C1",
    answer:
        "ufak yastık", // "Ufak yastık" literally means "small pillow". A better translation for "pad" in this context is "kılıf".
    quest: "pad",
  ),
  Words(
    front: "The function requires several parameters to work correctly.",
    back: "Fonksiyonun doğru çalışması için birkaç parametre gerekir.",
    list: "C1",
    answer: "parametre", // This one was already correct
    quest: "parameter",
  ),

  Words(
    front: "Parental guidance is recommended for this movie.",
    back: "Bu film için ebeveyn rehberliği önerilir.",
    list: "C1",
    answer: "ebeveyne ait",
    quest: "Parental",
  ),
  Words(
    front: "The police got a partial description of the suspect.",
    back: "Polis şüphelinin kısmi bir eşkalini aldı.",
    list: "C1",
    answer: "kısmi,taraflı",
    quest: "partial",
  ),
  Words(
    front: "The building was partially destroyed in the fire.",
    back: " Bina yangında kısmen yıkıldı.",
    list: "C1",
    answer: "kısmen",
    quest: "partially",
  ),
  Words(
    front: "There were many cars passing by on the busy street.",
    back: "Yoğun caddede yanından geçen birçok araba vardı.",
    list: "C1",
    answer: "geçiş",
    quest: "passing",
  ),
  Words(
    front: "He has a passive personality and avoids confrontation.",
    back: "Pasif bir kişiliğe sahip ve yüzleşmekten kaçınıyor.",
    list: "C1",
    answer: "pasif",
    quest: "passive",
  ),
  Words(
    front: "The local pastor gave a sermon about faith and forgiveness.",
    back: "Yerel papaz, iman ve affetme dair bir vaaz verdi.",
    list: "C1",
    answer: "papaz",
    quest: "pastor",
  ),
  Words(
    front: "He tried to fix the hole in the wall with a patch.",
    back: "Duvardaki deliği bir yama ile kapatmaya çalıştı.",
    list: "C1",
    answer: "yama",
    quest: "patch",
  ),
  Words(
    front: "We walked along a scenic pathway through the forest.",
    back: "Ormanda güzel bir patika boyunca yürüdük.",
    list: "C1",
    answer:
        "yaya geçidi", // "Yaya geçidi" means "crosswalk". A better translation for "pathway" is "patika".
    quest: "pathway",
  ),
  Words(
    front: "The police patrol cars will be out all night tonight.",
    back: "Polis devriye arabaları bu gece bütün gece dışarıda olacak.",
    list: "C1",
    answer: "devriye",
    quest: "patrol",
  ),
  Words(
    front: "The mountain reached its peak at an altitude of 3,000 meters.",
    back: "Dağ, 3.000 metrelik bir yükseklikte zirveye ulaştı.",
    list: "C1",
    answer: "zirve",
    quest: "peak",
  ),
  Words(
    front: "The peasants lived a simple life on their small farm.",
    back: "Köylüler küçük çiftliklerinde sade bir hayat sürdüler.",
    list: "C1",
    answer: "köylü",
    quest: "peasant",
  ),
  Words(
    front: "He has a peculiar sense of humor that not everyone understands.",
    back: "Herkesin anlamadığı, kendine özgü bir mizah anlayışı var.",
    list: "C1",
    answer:
        "özel eşya", // "Özel eşya" means "personal belongings". A better translation for "peculiar" is "kendine özgü".
    quest: "peculiar",
  ),
  Words(
    front: "He persisted in working late despite being tired.",
    back: "Yorgun olmasına rağmen geç saatlere kadar çalışmakta ısrar etti.",
    list: "C1",
    answer:
        "ısrar etmek", // Changed from "üstelemek" to better reflect "persist"
    quest: "persist",
  ),

  Words(
    front: "She is a persistent student who always asks questions in class.",
    back: "O, sınıfta her zaman soru soran ısrarcı bir öğrencidir.",
    list: "C1",
    answer: "ısrar eden", // This one was already correct
    quest: "persistent",
  ),
  Words(
    front: "The company is hiring new personnel for the marketing department.",
    back: "Şirket, pazarlama departmanı için yeni eleman alıyor.",
    list: "C1",
    answer: "eleman",
    quest: "personnel",
  ),
  Words(
    front:
        "They submitted a petition to the government to protest the new law.",
    back: "Yeni yasayı protesto etmek için hükümete bir dilekçe sundular.",
    list: "C1",
    answer: "dilekçe",
    quest: "petition",
  ),
  Words(
    front: "Socrates was a famous ancient Greek philosopher.",
    back: "Sokrates, ünlü bir antik Yunan filozofuydu.",
    list: "C1",
    answer: "filozof",
    quest: "philosopher",
  ),
  Words(
    front:
        "The article discussed the philosophical implications of artificial intelligence.",
    back: "Makale, yapay zekanın felsefi çıkarımlarını ele aldı.",
    list: "C1",
    answer: "felsefi",
    quest: "philosophical",
  ),
  Words(
    front: "She is seeing a physician to get a checkup for her allergies.",
    back: "Alerjileri için kontrolden geçmek üzere bir hekim görüyor.",
    list: "C1",
    answer: "hekim",
    quest: "physician",
  ),
  Words(
    front:
        "Louis Braille was a pioneer in developing a writing system for the blind.",
    back: "Louis Braille, körler için yazı sistemi geliştiren bir öncüydü.",
    list: "C1",
    answer: "öncü",
    quest: "pioneer",
  ),
  Words(
    front:
        "The oil is transported from the wells to the refinery through a pipeline.",
    back: "Petrol, kuyulardan rafineriye boru hattı aracılığıyla taşınır.",
    list: "C1",
    answer: "boru hattı",
    quest: "pipeline",
  ),
  Words(
    front: "Pirates were seafaring robbers who attacked ships for treasure.",
    back: "Korsanlar, hazine için gemilere saldıran denizci soygunculardı.",
    list: "C1",
    answer: "korsan",
    quest: "Pirate",
  ),
  Words(
    front: "He fell into a deep pit and had to be rescued.",
    back: "Derin bir çukura düştü ve kurtarılması gerekti.",
    list: "C1",
    answer: "çukur",
    quest: "pit",
  ),
  Words(
    front: "The defendant entered a plea of not guilty at the trial.",
    back: "Sanık, mahkemede kendini suçsuz olduğunu savundu.",
    list: "C1",
    answer: "savunma", // This one was already correct
    quest: "plea",
  ),
  Words(
    front: "He pleaded with the judge for leniency in his sentence.",
    back: "Hakimden cezasında müsamaha göstermesini savunma yaptı.",
    list: "C1",
    answer: "savunma yapmak", // This one was already correct
    quest: "plead",
  ),
  Words(
    front: "He made a pledge to donate money to charity.",
    back: "Hayır kurumuna para bağışlama sözü verdi.",
    list: "C1",
    answer: "söz", // Changed from "rehin" to better reflect a verbal pledge
    quest: "pledge",
  ),
  Words(
    front: "You need to unplug the charger before cleaning the device.",
    back: "Cihazı temizlemeden önce fişi prizden çekmeniz gerekiyor.",
    list: "C1",
    answer: "fiş",
    quest: "plug",
  ),
  Words(
    front: "He took a daring plunge into the icy cold water.",
    back: "Cesaretli bir şekilde buz gibi soğuk suya daldı.",
    list: "C1",
    answer: "dalma",
    quest: "plunge",
  ),
  Words(
    front: "The flag was waving proudly on top of the pole.",
    back: "Bayrak, direğin tepesinde gururla dalgalanıyordu.",
    list: "C1",
    answer: "direk",
    quest: "pole",
  ),
  Words(
    front:
        "Scientists are conducting a poll to gauge public opinion on the issue.",
    back:
        "Bilim insanları, konu hakkındaki kamuoyu görüşünü ölçmek için bir anket düzenliyor.",
    list: "C1",
    answer:
        "anket yapmak", // "Kesmek" means "to cut". A better translation for "poll" is "anket yapmak".
    quest: "poll",
  ),
  Words(
    front: "There are many ducks and geese swimming in the pond.",
    back: "Gölette birçok ördek ve kaz yüzüyor.",
    list: "C1",
    answer: "gölet",
    quest: "pond",
  ),
  Words(
    front: "The crowd cheered as the fireworks popped in the night sky.",
    back: "Havai fişekler gece gökyüzünde patladıkça kalabalık tezahürat etti.",
    list: "C1",
    answer: "patlatmak",
    quest: "pop",
  ),
  Words(
    front:
        "The actor perfectly portrayed the character of a troubled teenager.",
    back:
        "Oyuncu, sorunlu bir gencin karakterini mükemmel bir şekilde canlandırdı.",
    list: "C1",
    answer: "rolünü oynamak",
    quest: "portray",
  ),
  Words(
    front: "We had to postpone the meeting due to unforeseen circumstances.",
    back:
        "Öngörülemeyen durumlar nedeniyle toplantıyı ertelemek zorunda kaldık.",
    list: "C1",
    answer: "ertelemek",
    quest: "postpone",
  ),
  Words(
    front:
        "The country is still recovering from the devastation of the post-war period.",
    back:
        "Ülke, savaş sonrası döneminden kaynaklanan yıkımdan hâlâ toparlanıyor.",
    list: "C1",
    answer: "savaş sonrası",
    quest: "post-war",
  ),
  Words(
    front:
        "She is a qualified yoga practitioner with many years of experience.",
    back:
        "Uzun yıllara dayanan deneyime sahip kalifiyeli bir yoga uygulayıcısıdır.",
    list: "C1",
    answer: "uygulayan kimse",
    quest: "practitioner",
  ),
  Words(
    front: "The pastor preached a sermon about the importance of forgiveness.",
    back: "Papaz, affetmenin önemi hakkında bir vaaz verdi.",
    list: "C1",
    answer: "vaaz vermek",
    quest: "preach",
  ),
  Words(
    front:
        "Setting a good example is an important precedent for others to follow.",
    back:
        "İyi bir örnek oluşturmak, diğerlerinin takip edebileceği önemli bir emsaldir.",
    list: "C1",
    answer: "örnek oluşturan durum",
    quest: "precedent",
  ),
  Words(
    front:
        "The production of these parts requires machines with a high level of precision.",
    back:
        "Bu parçaların üretimi için yüksek düzeyde hassasiyete sahip makineler gerekir.",
    list: "C1",
    answer: "hassasiyet", // This one was already correct
    quest: "precision",
  ),

  Words(
    front: "The lion is a predator that hunts other animals for food.",
    back:
        "Aslan, avını yemek için diğer hayvanları avlayan bir avcı hayvandır.",
    list: "C1",
    answer: "avcı hayvan",
    quest: "predator",
  ),
  Words(
    front: "He is the predecessor of the current company CEO.",
    back:
        "O, şu anki şirket CEO'sunun öncülüdür.", // Changed "öncü" to "öncül" for predecessor
    list: "C1",
    answer: "öncül",
    quest: "predecessor",
  ),
  Words(
    front: "The population in this area is predominantly rural.",
    back:
        "Bu bölgedeki nüfus çoğunlukla kırsaldır.", // Changed "çoğu" to "çoğunlukla" for predominantly
    list: "C1",
    answer: "çoğunlukla",
    quest: "predominantly",
  ),
  Words(
    front: "She is in the early stages of pregnancy.",
    back: "Gebeliğin erken aşamasındadır.",
    list: "C1",
    answer: "hamilelik",
    quest: "pregnancy",
  ),
  Words(
    front: "He faced a lot of prejudice because of his race.",
    back: "Irkı yüzünden çok fazla önyargı ile karşılaştı.",
    list: "C1",
    answer: "önyargı",
    quest: "prejudice",
  ),
  Words(
    front:
        "We need to do a preliminary investigation before finalizing the plan.",
    back: "Planı kesinleştirmeden önce bir ön inceleme yapmamız gerekiyor.",
    list: "C1",
    answer: "ön",
    quest: "preliminary",
  ),
  Words(
    front: "The Prime Minister is the premier political leader of the country.",
    back: "Başbakan, ülkenin başta gelen siyasi lideridir.",
    list: "C1",
    answer:
        "başta gelen", // "Sınıf veya önem bakımından ilk sırada" is more formal and can be used.
    quest: "premier",
  ),
  Words(
    front: "The story is based on the premise that aliens exist.",
    back: "Hikaye, uzaylıların var olma öncülüne dayanmaktadır.",
    list: "C1",
    answer: "öncül",
    quest: "premise",
  ),
  Words(
    front: "He paid a premium for the insurance policy with wider coverage.",
    back: "Daha geniş kapsamlı sigorta poliçesi için prim ödedi.",
    list: "C1",
    answer:
        "ikramiye", // "İkramiye" means "bonus". A better translation for "premium" is "prim".
    quest: "premium",
  ),
  Words(
    front: "The doctor prescribed medication to treat her allergies.",
    back: "Doktor, alerjilerini tedavi etmek için ilaç yazdı.",
    list: "C1",
    answer: "reçete yazmak",
    quest: "prescribe",
  ),
  Words(
    front:
        "He needs to get a prescription from the doctor to refill his medication.",
    back: "İlacını tekrar doldurmak için doktordan reçete alması gerekiyor.",
    list: "C1",
    answer: "reçete",
    quest: "prescription",
  ),
  Words(
    front: "Presently, I am working on a new project.",
    back: "Şu anda yeni bir proje üzerinde çalışıyorum.",
    list: "C1",
    answer: "şimdi",
    quest: "Presently",
  ),
  Words(
    front:
        "The organization is dedicated to the preservation of historical buildings.",
    back: "Kuruluş, tarihi binaların korunmasına kendini adamıştır.",
    list: "C1",
    answer: "koruma",
    quest: "preservation",
  ),
  Words(
    front: "The judge will preside over the trial and ensure fair proceedings.",
    back:
        "Hakim duruşmaya başkanlık edecek ve adil bir yargılama sürecini sağlayacaktır.",
    list: "C1",
    answer: "başkanlık yapmak",
    quest: "preside",
  ),
  Words(
    front: "He served two terms in the presidency before stepping down.",
    back: "Görevinden ayrılmadan önce iki dönem cumhurbaşkanlığı yaptı.",
    list: "C1",
    answer: "cumhurbaşkanlığı",
    quest: "presidency",
  ),
  Words(
    front:
        "The presidential election is a very important event in the country.",
    back: "Cumhurbaşkanlığı seçimi, ülke için çok önemli bir olaydır.",
    list: "C1",
    answer:
        "cumhurbaşkanlığı", // "Saygın" can be used for respected, but "cumhurbaşkanlığı" is more specific here.
    quest: "presidential",
  ),
  Words(
    front: "Winning this award is a prestigious honor for any scientist.",
    back:
        "Bu ödülü kazanmak, herhangi bir bilim insanı için prestijli bir onurdur.",
    list: "C1",
    answer: "prestijli",
    quest: "prestigious",
  ),
  Words(
    front: "Presumably, they will arrive on time for the meeting.",
    back: "Muhtemelen toplantıya zamanında gelecekler.",
    list: "C1",
    answer: "galiba, muhtemelen",
    quest: "Presumably",
  ),
  Words(
    front: "I presume you already know the answer to this question.",
    back: "Sanırım bu sorunun cevabını zaten biliyorsunuz.",
    list: "C1",
    answer: "farzetmek",
    quest: "presume",
  ),
  Words(
    front: "In the end, good always prevails over evil.",
    back: "Sonunda iyilik her zaman kötülüğe üstün gelir.",
    list: "C1",
    answer: "üstün gelmek",
    quest: "prevail",
  ),
  Words(
    front: "The prevalence of heart disease is a major public health concern.",
    back: "Kalp hastalıklarının yaygınlığı önemli bir halk sağlığı sorunudur.",
    list: "C1",
    answer: "yaygınlık",
    quest: "prevalence",
  ),
  Words(
    front:
        "Vaccination is an effective method for the prevention of infectious diseases.",
    back:
        "Aşılama, bulaşıcı hastalıkların önlenmesi için etkili bir yöntemdir.",
    list: "C1",
    answer: "önlem",
    quest: "prevention",
  ),
  Words(
    front:
        "The lion is a predator that hunts prey such as zebras and gazelles.",
    back: "Aslan, zebra ve ceylan gibi avları avlayan bir avcıdır.",
    list: "C1",
    answer: "av",
    quest: "prey",
  ),
  Words(
    front: "The principal is the head administrator of a school.",
    back: "Müdür, bir okulun baş yöneticisidir.",
    list: "C1",
    answer: "okul müdürü",
    quest: "principal",
  ),
  Words(
    front:
        "The government is considering the privatization of some state-owned companies.",
    back: "Hükümet, bazı devlet işletmelerinin özelleştirilmesini düşünüyor.",
    list: "C1",
    answer: "özelleştirme",
    quest: "privatization",
  ),
  Words(
    front: "He comes from a wealthy family and enjoys many privileges.",
    back: "Zengin bir aileden geliyor ve birçok imtiyazın tadını çıkarıyor.",
    list: "C1",
    answer: "imtiyaz", // This was already correct
    quest: "privilege",
  ),
  Words(
    front: "The space probe is collecting data from Mars.",
    back: "Uzay sondası Mars'tan veri topluyor.",
    list: "C1",
    answer: "inceleme", // This is a good translation for "probe"
    quest: "probe",
  ),
  Words(
    front: "The judge reviewed the court proceedings before making a decision.",
    back: "Hakim karar vermeden önce mahkeme tutanaklarını inceledi.",
    list: "C1",
    answer: "tutanak", // "Konferans" means "conference"
    quest: "proceedings",
  ),
  Words(
    front:
        "All proceeds from the charity event will go to help children in need.",
    back:
        "Hayır etkinliğinden elde edilen tüm gelir ihtiyacı olan çocuklara yardım etmek için gidecek.",
    list: "C1",
    answer: "gelir", // "Verim" means "yield"
    quest: "proceeds",
  ),
  Words(
    front: "The computer is still processing the data.",
    back: "Bilgisayar hala verileri işliyor.",
    list: "C1",
    answer: "işleme tabi tutma",
    quest: "processing",
  ),
  Words(
    front: "The central processor is the main chip in a computer.",
    back: "Merkezi işlemci, bir bilgisayardaki ana çiptir.",
    list: "C1",
    answer: "işlemci",
    quest: "processor",
  ),
  Words(
    front: "The leader proclaimed a new era of peace and prosperity.",
    back: "Lider, barış ve refahın yeni bir dönemini ilan etti.",
    list: "C1",
    answer: "ilan etmek", // "Duyurmak" can also work here
    quest: "proclaim",
  ),
  Words(
    front: "She is a very productive employee who always meets her deadlines.",
    back:
        "O, her zaman son teslim tarihlerine uyan çok verimli bir çalışandır.",
    list: "C1",
    answer: "verimli",
    quest: "productive",
  ),
  Words(
    front: "The company is looking for ways to improve productivity.",
    back: "Şirket, verimliliği artırmanın yollarını arıyor.",
    list: "C1",
    answer: "verimlilik",
    quest: "productivity",
  ),
  Words(
    front: "Investing in the stock market can be a profitable venture.",
    back: "Borsa yatırımı karlı bir girişim olabilir.",
    list: "C1",
    answer: "karlı",
    quest: "profitable",
  ),
  Words(
    front:
        "He made a profound impact on the field of physics with his groundbreaking research.",
    back: "Çığır açan araştırmasıyla fizik alanında derin bir etki bıraktı.",
    list: "C1",
    answer: "derin",
    quest: "profound",
  ),
  Words(
    front: "She is a prominent figure in the world of human rights activism.",
    back: "İnsan hakları aktivizmi dünyasında önemli bir figürdür.",
    list: "C1",
    answer: "önemli", // "Öne çıkan" can also be used here
    quest: "prominent",
  ),
  Words(
    front:
        "He has a very pronounced accent, which makes his speech difficult to understand.",
    back:
        "Anlaması zor olan konuşmasını sağlayan çok belirgin bir a لهجهsi (lehçe) var.",
    list: "C1",
    answer: "belirgin",
    quest: "pronounced",
  ),
  Words(
    front: "He made a proposition to buy the house for a lower price.",
    back: "Evi daha düşük bir fiyata satın almak için bir teklif sundu.",
    list: "C1",
    answer: "teklif etmek",
    quest: "proposition",
  ),
  Words(
    front: "The police will prosecute the suspect for the crime.",
    back: "Polis, şüpheliyi suçtan dolayı kovuşturmaya devam edecek.",
    list: "C1",
    answer: "kovuşturmak",
    quest: "prosecute",
  ),
  Words(
    front:
        "The defense and prosecution presented their closing arguments in court.",
    back: "Savunma ve savcılık, mahkemede kapanış konuşmalarını yaptılar.",
    list: "C1",
    answer: "savcılık",
    quest: "prosecution",
  ),
  Words(
    front: "The prosecutor is responsible for presenting evidence in court.",
    back: "Savcı, mahkemede delil sunmaktan sorumludur.",
    list: "C1",
    answer: "savcı",
    quest: "prosecutor",
  ),
  Words(
    front: "They are a prospective new client for our company.",
    back: "Onlar şirketimiz için potansiyel yeni bir müşteri.",
    list: "C1",
    answer: "potansiyel", // "İleriye yönelik" can be more formal
    quest: "prospective",
  ),
  Words(
    front:
        "The country is experiencing a period of great prosperity and economic growth.",
    back: "Ülke, büyük refah ve ekonomik büyüme dönemi yaşıyor.",
    list: "C1",
    answer: "refah",
    quest: "prosperity",
  ),
  Words(
    front: "He wore a protective helmet while riding his motorcycle.",
    back: "Motosiklet sürerken koruyucu kask taktı.",
    list: "C1",
    answer: "koruyucu",
    quest: "protective",
  ),
  Words(
    front: "Turkey is a country divided into 81 provinces.",
    back: "Türkiye, 81 ile bölünmüş bir ülkedir.",
    list: "C1",
    answer: "il", // "Vilayet" is an older term for province
    quest: "province",
  ),
  Words(
    front:
        "The contract includes provisions for termination in case of breach.",
    back: "Sözleşme, fesih durumunda fesih hükümlerini içerir.",
    list: "C1",
    answer:
        "hüküm", // "Karşılık" can mean counterpart, but "hüküm" is a more general term for provision
    quest: "provision",
  ),
  Words(
    front: "His words were intended to provoke a reaction from the crowd.",
    back: "Sözleri kalabalıktan bir tepki çekmeyi amaçlıyordu.",
    list: "C1",
    answer: "kışkırtmak",
    quest: "provoke",
  ),
  Words(
    front: "The doctor checked her pulse to assess her heart rate.",
    back: "Doktor, kalp atış hızını değerlendirmek için nabzını kontrol etti.",
    list: "C1",
    answer: "nabız",
    quest: "pulse",
  ),
  Words(
    front: "The farmer used a pump to water his crops.",
    back: "Çiftçi, mahsullerini sulamak için bir pompa kullandı.",
    list: "C1",
    answer: "pompa",
    quest: "pump",
  ),
  Words(
    front: "He threw a powerful punch that knocked out his opponent.",
    back: "Rakibini nakavt eden güçlü bir yumruk attı.",
    list: "C1",
    answer: "yumruk",
    quest: "punch",
  ),
  Words(
    front: "He embarked on a quest to find the lost treasure.",
    back: "Kayıp hazineyi bulmak için bir arayışa başladı.",
    list: "C1",
    answer: "arayış",
    quest: "quest",
  ),
  Words(
    front: "The company did not meet its sales quota this month.",
    back: "Şirket, bu ay satış kotasını karşılayamadı.",
    list: "C1",
    answer: "kota",
    quest: "quota",
  ),
  Words(
    front: "He flew into a rage when he heard the bad news.",
    back:
        "Kötü haberi duyduğunda öfkeye kapıldı.", // "Kudurmak" is a bit too strong for "rage" in this context.
    list: "C1",
    answer: "öfke", // A better translation for "rage" here
    quest: "rage",
  ),
  Words(
    front: "The police conducted a raid on the suspected hideout.",
    back: "Polis, şüpheli saklanma yerine baskın düzenledi.",
    list: "C1",
    answer: "baskın",
    quest: "raid",
  ),
  Words(
    front: "The politician asked his supporters to rally to the cause.",
    back: "Siyasetçi destekçilerinden davaya destek vermelerini istedi.",
    list: "C1",
    answer: "toplanmak",
    quest: "rally",
  ),
  Words(
    front: "The university ranking lists the top institutions in the country.",
    back: "Üniversite sıralaması, ülkedeki en iyi kurumları listeler.",
    list: "C1",
    answer: "sıralama",
    quest: "ranking",
  ),
  Words(
    front:
        "The doctor measured the ratio of oxygen to carbon dioxide in the blood.",
    back: "Doktor, kandaki oksijen-karbondi oksit oranını ölçtü.",
    list: "C1",
    answer: "oran",
    quest: "ratio",
  ),
  Words(
    front: "The sun's rays shone brightly through the window.",
    back: "Güneşin ışınları pencereden içeriye parlak bir şekilde vurdu.",
    list: "C1",
    answer: "ışın",
    quest: "ray",
  ),
  Words(
    front: "He was readily available to help anyone in need.",
    back: "İhtiyacı olan herkese kolaylıkla yardım etmeye hazırdı.",
    list: "C1",
    answer: "kolaylıkla",
    quest: "readily",
  ),
  Words(
    front: "The sudden realization of his mistake filled him with regret.",
    back: "Hatasının ani kavraması onu pişmanlıkla doldurdu.",
    list: "C1",
    answer: "kavrama",
    quest: "realization",
  ),
  Words(
    front: "The king's realm was terrorized by a dragon",
    back: " Kralın krallığı bir ejderha tarafından terörize edildi.",
    list: "C1",
    answer: "krallık",
    quest: "realm",
  ),
  Words(
    front: "All deliveries should be taken to the rear of the building.",
    back: "Tüm teslimatlar binanın arka tarafına yapılmalıdır.",
    list: "C1",
    answer: "arka",
    quest: "rear",
  ),
  Words(
    front: "They used logical reasoning to solve the puzzle.",
    back: "Bulmacayı çözmek için mantıklı muhakeme yeteneği kullandılar.",
    list: "C1",
    answer: "muhakeme", // This was already correct
    quest: "reasoning",
  ),

  Words(
    front: "Her kind words reassured him that everything would be alright.",
    back:
        "Nazik sözleri, her şeyin yoluna gireceğine dair onu güvence altına aldı.",
    list: "C1",
    answer: "güvence vermek",
    quest: "reassure",
  ),
  Words(
    front: "The colonists rebelled against the tyranny of the British crown.",
    back: "Sömürgeciler, İngiliz tacının zulmüne ayaklandı.",
    list: "C1",
    answer: "ayaklanmak",
    quest: "rebel",
  ),
  Words(
    front:
        "The country is still recovering from the devastation of the recent rebellion.",
    back:
        "Ülke hala yakın zamanda yaşanan ayaklanmanın tahribatından kurtulmaya çalışıyor.",
    list: "C1",
    answer: "ayaklanma",
    quest: "rebellion",
  ),
  Words(
    front: "The recipient of the letter was her long-lost friend.",
    back: "Mektup alıcısı, uzun zamandır kayıp olan arkadaşıydı.",
    list: "C1",
    answer: "alıcı",
    quest: "recipient",
  ),
  Words(
    front:
        "The city is undergoing a major reconstruction project after the earthquake.",
    back:
        "Şehir, depremden sonra büyük bir yeniden yapılanma projesi geçirmektedir.",
    list: "C1",
    answer: "yeniden yapılanma",
    quest: "reconstruction",
  ),
  Words(
    front:
        "There may be a need to recount the votes if the election results are very close.",
    back:
        "Seçim sonuçları çok yakın ise, oyların yeniden sayılması gerekebilir.",
    list: "C1",
    answer: "yeniden saymak",
    quest: "recount",
  ),
  Words(
    front: "He stared into the lake, lost in reflection.",
    back:
        "Göle baktı, düşüncelere dalmıştı.", // "Yansıma" can be a bit more abstract here.
    list: "C1",
    answer: "düşünce", // A better translation for "reflection" in this context
    quest: "reflection",
  ),
  Words(
    front: "Many refugees fled the war-torn country in search of safety.",
    back:
        "Birçok mülteci, güvenlik arayışı içinde savaştan zarar görmüş ülkeden kaçtı.",
    list: "C1",
    answer: "sığınak",
    quest: "refuge",
  ),
  Words(
    front: "He was met with a refusal when he asked for a raise.",
    back: "Zam istediğinde reddetme ile karşılaşıldı.",
    list: "C1",
    answer: "reddetme",
    quest: "refusal",
  ),
  Words(
    front:
        "Despite the challenges, they were determined to regain control of their lives.",
    back: "Zorluklara rağmen, hayatlarını geri kazanmaya kararlıydılar.",
    list: "C1",
    answer: "geri kazanmak",
    quest: "regain",
  ),
  Words(
    front: "Regardless of the weather, they will go on their camping trip.",
    back: "Havaya aldırmadan, kamp gezisine çıkacaklar.",
    list: "C1",
    answer: "aldırışsız",
    quest: "Regardless",
  ),
  Words(
    front: "The company is subject to a number of regulatory requirements.",
    back: "Şirket, bir dizi düzenleyici gerekliliğe tabidir.",
    list: "C1",
    answer: "düzenleyici",
    quest: 'regulatory',
  ),
  Words(
    front: "Queen Elizabeth II's reign lasted for over 70 years.",
    back: "II. Elizabeth Kraliçesi'nin saltanatı 70 yıldan fazla sürdü.",
    list: "C1",
    answer: "saltanat",
    quest: "reign",
  ),
  // Existing entries...

  Words(
    front:
        "He felt a deep sense of rejection after being passed over for the promotion.",
    back: "Terfi için geçildikten sonra derin bir reddetme duygusu hissetti.",
    list: "C1",
    answer: "reddetme",
    quest: "rejection",
  ),
  Words(
    front: "The relevance of this study to current events is undeniable.",
    back: "Bu çalışmanın güncel olaylarla ilgisi inkar edilemez.",
    list: "C1",
    answer: "ilgi",
    quest: "relevance",
  ),
  Words(
    front:
        "The company is known for its reliability and excellent customer service.",
    back: "Şirket, güvenilirliği ve mükemmel müşteri hizmeti ile tanınır.",
    list: "C1",
    answer: "güvenilirlik",
    quest: "reliability",
  ),
  Words(
    front: "He was reluctant to join the project, but eventually agreed.",
    back: "Projeye katılmaya gönülsüzdü, ancak sonunda kabul etti.",
    list: "C1",
    answer: "gönülsüz",
    quest: "reluctant",
  ),
  Words(
    front: "After eating half the pizza, there was a large remainder left.",
    back:
        "Pizzanın yarısını yedikten sonra geriye kalan büyük bir parça kaldı.",
    list: "C1",
    answer: "kalan", // "Geri kalan" is also acceptable
    quest: "remainder",
  ),
  Words(
    front: "The archaeologists discovered the remains of an ancient city.",
    back: "Arkeologlar, antik bir şehrin kalıntılarını keşfettiler.",
    list: "C1",
    answer: "kalıntılar",
    quest: "remains",
  ),
  Words(
    front: "Exercise is a good remedy for stress and anxiety.",
    back: "Egzersiz, stres ve kaygı için iyi bir çaredir.",
    list: "C1",
    answer: "çare",
    quest: "remedy",
  ),
  Words(
    front: "She set a reminder on her phone to call her mother.",
    back: "Annesini araması için telefonuna bir hatırlatma ayarladı.",
    list: "C1",
    answer: "hatırlatma",
    quest: "reminder",
  ),
  Words(
    front: "The old building is scheduled for removal next month.",
    back: "Eski bina, önümüzdeki ay kaldırılması planlanıyor.",
    list: "C1",
    answer: "sökme",
    quest: "removal",
  ),
  Words(
    front: "The artist used charcoal to render a portrait of the old man.",
    back: "Sanatçı, yaşlı adamın portresini resmetmek için kömür kullandı.",
    list: "C1",
    answer: "resmetmek",
    quest: "render",
  ),
  Words(
    front:
        "They decided to renew their wedding vows on their 25th anniversary.",
    back: "25. yıldönümlerinde evlilik yeminlerini yenilemeye karar verdiler.",
    list: "C1",
    answer: "yenilemek",
    quest: "renew",
  ),
  Words(
    front: "The city is famous for its renowned museums and art galleries.",
    back: "Şehir, ünlü müzeleri ve sanat galerileri ile ünlüdür.",
    list: "C1",
    answer: "ünlü",
    quest: "renowned",
  ),
  Words(
    front: "We are looking for a rental car for our trip.",
    back: "Gezimiz için kiralık bir araba arıyoruz.",
    list: "C1",
    answer: "kiralık",
    quest: "rental",
  ),
  Words(
    front: "Finding a replacement as good as her will not be easy.",
    back: "Onun yerine yeni birini bulmak kolay olmayacak.",
    list: "C1",
    answer: "yenisiyle değiştirme",
    quest: "replacement",
  ),
  Words(
    front: "Reportedly, the president is going to resign next week.",
    back: "Söylentilere göre, cumhurbaşkanı önümüzdeki hafta istifa edecek.",
    list: "C1",
    answer: "söylentilere göre",
    quest: "Reportedly",
  ),
  Words(
    front:
        "The painting is a beautiful representation of the Italian countryside.",
    back: "Resim, İtalyan kırsalının güzel bir temsilidir.",
    list: "C1",
    answer: "temsil",
    quest: "representation",
  ),
  Words(
    front: "Scientists are trying to reproduce the experiment.",
    back: "Bilim adamları deneyi yeniden üretmeye çalışıyorlar.",
    list: "C1",
    answer: "yeniden üretmek",
    quest: "reproduce",
  ),
  Words(
    front: "Asexual reproduction is a common method for some plants.",
    back: "Bazı bitkiler için eşeysiz çoğalma yaygın bir yöntemdir.",
    list: "C1",
    answer: "çoğalma", // "Üreme" can also be used here.
    quest: "reproduction",
  ),
  Words(
    front: "France is a republic with a democratically elected president.",
    back:
        "Fransa, demokratik olarak seçilmiş bir cumhurbaşkanı olan bir cumhuriyettir.",
    list: "C1",
    answer: "cumhuriyet",
    quest: "republic",
  ),
  Words(
    front: "The two buildings closely resemble each other in design.",
    back: "İki bina tasarım olarak birbirine çok benziyor.",
    list: "C1",
    answer: "benzemek",
    quest: "resemble",
  ),
  Words(
    front: "He has resided in France for the past 20 years.",
    back: "Son 20 yıldır Fransa'da ikamet ediyor.",
    list: "C1",
    answer: "ikamet etmek",
    quest: "reside",
  ),
  Words(
    front: "They are looking to buy a residence in a quiet neighborhood.",
    back: "Sakin bir mahallede oturmak için bir mesken satın almak istiyorlar.",
    list: "C1",
    answer: "mesken",
    quest: "residence",
  ),
  Words(
    front:
        "This area is a residential neighborhood with mostly single-family homes.",
    back:
        "Bu alan çoğunlukla müstakil evlerin bulunduğu oturmaya elverişli bir mahalleden oluşuyor.",
    list: "C1",
    answer: "oturmaya elverişli",
    quest: "residential",
  ),
  Words(
    front: "After cleaning the pan, there was a greasy residue left over.",
    back: "Tavayı temizledikten sonra yağlı bir tortu kaldı.",
    list: "C1",
    answer: "tortu",
    quest: "residue",
  ),
  Words(
    front:
        "He submitted his resignation from the company after accepting a new position.",
    back: "Yeni bir görevi kabul ettikten sonra şirketten istifa etti.",
    list: "C1",
    answer: "istifa",
    quest: "resignation",
  ),
  Words(
    front:
        "They each presented their ideas, stating their respective positions on the issue.",
    back:
        "Her biri kendi fikirlerini sundu ve konuyla ilgili kendi şahsi konumlarını belirtti.",
    list: "C1",
    answer: "şahsi",
    quest: "respective",
  ),
  Words(
    front:
        "John won first place, Mary came in second, and David came in third, respectively.",
    back: "John birinci oldu, Mary ikinci, David ise sırasıyla üçüncü oldu.",
    list: "C1",
    answer: "sırasıyla",
    quest: "respectively",
  ),
  Words(
    front:
        "He showed great restraint in not arguing back when he was insulted.",
    back:
        "Hakaret edildiğinde karşılık vermeyerek büyük bir kısıtlama gösterdi.",
    list: "C1",
    answer: "kısıtlama",
    quest: "restraint",
  ),
  Words(
    front:
        "The meeting was interrupted, but we will resume it later this afternoon.",
    back: "Toplantı yarıda kesildi, ancak öğleden sonra devam edeceğiz.",
    list: "C1",
    answer: "sürdürmek",
    quest: "resume",
  ),
  Words(
    front:
        "The enemy forces were forced to retreat after suffering heavy losses.",
    back:
        "Düşman güçleri, ağır kayıplar verdikten sonra geri çekilmek zorunda kaldı.",
    list: "C1",
    answer: "geri çekilmek",
    quest: "retreat",
  ),
  Words(
    front: "He went back to his room to retrieve his forgotten phone.",
    back: "Unutmuş olduğu telefonunu almak için odasına geri döndü.",
    list: "C1",
    answer: "geri almak",
    quest: "retrieve",
  ),
  Words(
    front: "The discovery of a new planet was a scientific revelation.",
    back: "Yeni bir gezegenin keşfi bilimsel bir vahiy niteliğindeydi.",
    list: "C1",
    answer: "vahiy",
    quest: "revelation",
  ),
  Words(
    front: "He vowed to get revenge on those who had wronged him.",
    back: "Kendisine haksızlık edenlerden intikam almak için yemin etti.",
    list: "C1",
    answer: "intikam almak",
    quest: "revenge",
  ),
  Words(
    front: "The opposite of hot is cold, and the reverse of true is false.",
    back: "Sıcağın karşıtı soğuktur, doğrunun tersi ise yanlıştır.",
    list: "C1",
    answer: "ters",
    quest: "reverse",
  ),
  Words(
    front: "There are signs of a revival in the city's cultural scene.",
    back: "Şehrin kültürel hayatında bir canlanma emareleri var.",
    list: "C1",
    answer: "canlanma",
    quest: "revival",
  ),
  Words(
    front:
        "The old painting was carefully restored to revive its former beauty.",
    back:
        "Eski resim, eski güzelliğini canlandırmak için dikkatlice restore edildi.",
    list: "C1",
    answer: "canlandırmak",
    quest: "revive",
  ),
  Words(
    front:
        "The politician's speech was full of empty rhetoric and made no real promises.",
    back:
        "Politikacının konuşması boş güzel konuşmadan ibaret olup hiçbir gerçek vaatte bulunmadı.",
    list: "C1",
    answer:
        "güzel konuşma", // "Retorik" can be used here too, but it's less common.
    quest: "rhetoric",
  ),
  Words(
    front: "The soldier aimed his rifle at the target.",
    back: "Asker tüfeğini hedefe doğrulttu.",
    list: "C1",
    answer: "tüfek",
    quest: "rifle",
  ),
  Words(
    front: "The angry protesters started a riot in the streets.",
    back: "Öfkeli göstericiler sokaklarda isyan çıkardı.",
    list: "C1",
    answer: "isyan etmek",
    quest: "riot",
  ),
  Words(
    front: "He ripped a piece of paper out of his notebook.",
    back:
        "Defterinden bir sayfa kopardı.", // "Sökmek" can be used for tearing something off, but not necessarily ripping.
    list: "C1",
    answer: "koparmak", // A better translation for "rip" in this context
    quest: "rip",
  ),
  Words(
    front:
        "The bridge is built with robust materials to withstand heavy traffic.",
    back:
        "Köprü, yoğun trafiğe dayanacak şekilde güçlü malzemelerden inşa edilmiştir.",
    list: "C1",
    answer: "güçlü",
    quest: "robust",
  ),
  Words(
    front: "The music made her want to rock out all night.",
    back: "Müzik onu bütün gece sallanmak isteğine getirdi.",
    list: "C1",
    answer: "sallanmak",
    quest: "rock",
  ),
  Words(
    front: "He used a metal rod to pry open the window.",
    back: "Pencereyi zorlamak için metal bir çubuk kullandı.",
    list: "C1",
    answer: "çubuk",
    quest: "rod",
  ),
  Words(
    front: "The Earth rotates on its axis once every 24 hours.",
    back: "Dünya kendi ekseni etrafında 24 saatte bir döner.",
    list: "C1",
    answer: "dönmek",
    quest: "rotate",
  ),
  Words(
    front:
        "The team practiced their routine for the dance competition, focusing on precise rotations.",
    back:
        "Takım, dans yarışması için rutini denedi ve hassas rotasyonlara odaklandı.",
    list: "C1",
    answer: "rotasyon",
    quest: "rotation",
  ),
  Words(
    front: "The new leaders expatriated the ruling family.",
    back: "Yeni liderler yönetici aileyi sınır dışı etti.",
    list: "C1",
    answer: "yönetim, karar",
    quest: "ruling",
  ),
  Words(
    front: "There is a rumour going around that the company is going bankrupt.",
    back: "Şirketin iflas edeceğine dair bir söylenti ortalıkta dolaşıyor.",
    list: "C1",
    answer: "söylenti",
    quest: "rumour",
  ),
  Words(
    front: "He was sacked from his job for poor performance.",
    back: "Düşük performans nedeniyle işinden kovuldu.",
    list: "C1",
    answer:
        "kovulmak", // "Çuvala koymak" is not a common expression for getting fired.
    quest: "sack",
  ),
  Words(
    front: "Many cultures consider cows to be sacred animals.",
    back: "Birçok kültür inekleri kutsal hayvanlar olarak görür.",
    list: "C1",
    answer: "kutsal",
    quest: "sacred",
  ),
  Words(
    front: "He did it for the sake of his family.",
    back: "Bunun için ailesinin hatırına yaptı.",
    list: "C1",
    answer: "hatır",
    quest: "sake",
  ),
  Words(
    front:
        "The country is facing economic sanctions due to its human rights violations.",
    back:
        "Ülke, insan hakları ihlalleri nedeniyle yaptırımlarla karşı karşıyadır.",
    list: "C1",
    answer: "yaptırım",
    quest: "sanction",
  ),
  Words(
    front: "Can you say that again?",
    back: "Bunu tekrar söyleyebilir misin?",
    list: "C1",
    answer: "söylemek",
    quest: "say",
  ),
  Words(
    front: "The toys were scattered all over the floor.",
    back: "Oyuncaklar yere dağınık bir şekilde saçılmıştı.",
    list: "C1",
    answer: "dağınık",
    quest: "scattered",
  ),
  Words(
    front: "He was sceptical of the claims made by the salesperson.",
    back: "Satış görevlisinin yaptığı iddialara şüpheyle yaklaştı.",
    list: "C1",
    answer: "kuşkucu",
    quest: "sceptical",
  ),
  Words(
    front:
        "The project falls outside the scope of my current responsibilities.",
    back: "Proje şu anki sorumluluk alanımın dışında kalıyor.",
    list: "C1",
    answer: "faaliyet alanı",
    quest: "scope",
  ),
  Words(
    front: "He carefully screwed the two pieces of wood together.",
    back: "İki tahta parçasını dikkatlice vidaladı.",
    list: "C1",
    answer: "vidalamak",
    quest: "screw",
  ),
  Words(
    front:
        "The company's financial records are under close scrutiny by the government.",
    back:
        "Şirketin mali kayıtları hükümet tarafından sıkı inceleme altındadır.",
    list: "C1",
    answer: "inceleme",
    quest: "scrutiny",
  ),
  Words(
    front: "The envelope was sealed with a red wax stamp.",
    back: "Zarf, kırmızı bir mum mührü ile mühürlenmişti.",
    list: "C1",
    answer: "mühürlemek",
    quest: "seal",
  ),
  Words(
    front:
        "He remains confident and seemingly untroubled by his recent problems.",
    back:
        "Kendinden emin ve son zamanlarda yaşadığı sorunlardan etkilenmemiş görünüyor.",
    list: "C1",
    answer: "görünürde",
    quest: "seemingly",
  ),
  Words(
    front:
        "The market can be segmented into different groups based on customer demographics.",
    back:
        "Pazar, müşteri demografik özelliklerine göre farklı segmentlere ayrılabilir.",
    list: "C1",
    answer: "bölmek",
    quest: "segment",
  ),
  Words(
    front: "The police seized the drugs that were found in the car.",
    back: "Polis, arabada bulunan uyuşturucuları ele geçirdi.",
    list: "C1",
    answer: "el koymak",
    quest: "seize",
  ),
  Words(
    front: "She seldom visits her hometown anymore.",
    back: "Artık memleketine nadiren gidiyor.",
    list: "C1",
    answer: "nadiren",
    quest: "seldom",
  ),
  Words(
    front: "The university has a selective admissions process.",
    back: "Üniversitenin seçici bir kabul süreci vardır.",
    list: "C1",
    answer: "seçici",
    quest: "selective",
  ),
  Words(
    front: "The sight of blood caused a wave of nausea and sensation.",
    back: "Kan görüntüsü bir mide bulantısı ve his dalgasına neden oldu.",
    list: "C1",
    answer: "his", // "Duyu" can also be used here.
    quest: "sensation",
  ),
  Words(
    front:
        "People with allergies often have a heightened sensitivity to dust and pollen.",
    back:
        "Alerjisi olan kişiler genellikle toz ve polene karşı yüksek hassasiyete sahiptir.",
    list: "C1",
    answer: "hassasiyet",
    quest: "sensitivity",
  ),
  Words(
    front: "The public sentiment was overwhelmingly in favor of the new law.",
    back: "Kamuoyu yeni yasadan yana ezici bir çoğunlukla duygu besliyordu.",
    list: "C1",
    answer: "düşünce",
    quest: "sentiment",
  ),
  Words(
    front: "The separation of powers is a fundamental principle of democracy.",
    back: "Yetkilerin ayrılması, demokrasinin temel ilkelerinden biridir.",
    list: "C1",
    answer: "ayırma",
    quest: "separation",
  ),
  Words(
    front: "He is a big fan of crime serial dramas.",
    back: "O, polisiye dizi filmlerinin büyük hayranıdır.",
    list: "C1",
    answer: "seri",
    quest: "serial",
  ),
  Words(
    front:
        "The peace talks aimed to find a lasting settlement between the warring parties.",
    back:
        "Barış görüşmeleri, savaşan taraflar arasında kalıcı bir yerleşim bulmayı amaçlıyordu.",
    list: "C1",
    answer: "yerleşim",
    quest: "settlement",
  ),
  Words(
    front: "We need to set up the meeting room before the clients arrive.",
    back: "Müşteriler gelmeden önce toplantı odasını hazırlamamız gerekiyor.",
    list: "C1",
    answer: "kurmak, hazırlamak",
    quest: "set up",
  ),
  Words(
    front: "He is a major shareholder in the company.",
    back: "Şirketin büyük hissedarlarından biridir.",
    list: "C1",
    answer: "hissedar",
    quest: "shareholder",
  ),
  Words(
    front: "The vase fell from the table and shattered into pieces.",
    back: "Vazo masadan düşüp paramparça oldu.",
    list: "C1",
    answer: "kırmak",
    quest: "shatter",
  ),
  Words(
    front: "He shed a tear as he said goodbye to his old friend.",
    back: "Eski dostuna veda ederken bir damla gözyaşı döktü.",
    list: "C1",
    answer: "dökmek",
    quest: "shed",
  ),
  Words(
    front: "She possessed sheer determination to succeed.",
    back: "Başarılı olmak için düpedüz bir kararlılığa sahipti.",
    list: "C1",
    answer: "düpedüz",
    quest: "sheer",
  ),
  Words(
    front: "The cost of shipping the furniture overseas was very high.",
    back: "Mobilyaların yurt dışına gönderim masrafı çok yüksekti.",
    list: "C1",
    answer: "nakliye",
    quest: "shipping",
  ),
  Words(
    front: "They are going to shoot a movie on location in Italy next summer.",
    back: "Gelecek yaz İtalya'da bir film çekimi yapacaklar.",
    list: "C1",
    answer: "film çekmek",
    quest: "shoot",
  ),
  Words(
    front: "Cotton clothes can easily shrink when machine washed and dried.",
    back:
        "Pamuklu giysiler makinede yıkanıp kurutulduğunda kolayca küçültebilir.",
    list: "C1",
    answer: "küçültmek",
    quest: "shrink",
  ),
  Words(
    front: "He shrugged his shoulders and said he didn't know.",
    back: "Omuzlarını silkti ve bilmediğini söyledi.",
    list: "C1",
    answer: "omuz silkmek",
    quest: "shrug",
  ),
  Words(
    front: "She let out a sigh of relief when she finished the exam.",
    back: "Sınayı bitirdiğinde rahatlama iç çekti.",
    list: "C1",
    answer: "iç çekme",
    quest: "sigh",
  ),
  Words(
    front:
        "The flight simulator is designed to simulate the experience of flying a real airplane.",
    back:
        "Uçuş simülatörü, gerçek bir uçak kullanma deneyimini simüle etmek için tasarlanmıştır.",
    list: "C1",
    answer: "taklidini yapmak",
    quest: "simulate",
  ),
  Words(
    front: "The fire drill was a simulation of a real fire emergency.",
    back: "Yangın tatbikatı, gerçek bir yangın acil durumu simülasyonuydu.",
    list: "C1",
    answer: "simülasyon",
    quest: "simulation",
  ),
  Words(
    front: "He translated the text into English simultaneously.",
    back: "Metni aynı anda İngilizceye çevirdi.",
    list: "C1",
    answer: "eş zamanlı",
    quest: "simultaneously",
  ),
  Words(
    front: "Lying is a sin according to many religions.",
    back: "Yalan söylemek birçok dine göre günahtır.",
    list: "C1",
    answer: "günah",
    quest: "sin",
  ),
  Words(
    front:
        "The village is situated in a beautiful valley surrounded by mountains.",
    back: "Köy, dağlarla çevrili güzel bir vadide konumlanmıştır.",
    list: "C1",
    answer: "konumlanmış",
    quest: "situated",
  ),
  Words(
    front:
        "He made a rough sketch of the building before starting to draw the final plan.",
    back: "Nihai planı çizmeye başlamadan önce binanın taslağını yaptı.",
    list: "C1",
    answer: "taslağını yapmak",
    quest: "sketch",
  ),
  Words(
    front: "We can skip this chapter as it is not relevant to the exam.",
    back: "Sınavla ilgili olmadığı için bu bölümü atlayabiliriz.",
    list: "C1",
    answer: "atlamak",
    quest: "skip",
  ),
  Words(
    front: "The critics slammed the new movie, calling it a complete disaster.",
    back:
        "Eleştirmenler, yeni filmi yerden yere vurup tam bir felaket olarak nitelendirdiler.",
    list: "C1",
    answer: "eleştirmek",
    quest: "slam",
  ),
  Words(
    front: "He received a slap on the wrist for his minor offense.",
    back: "Küçük suçundan dolayı tokat atar gibi bir ceza aldı.",
    list: "C1",
    answer: "tokat",
    quest: "slap",
  ),
  Words(
    front:
        "The company's decision to outsource jobs was met with a slash in its stock price.",
    back:
        "Şirketin işleri dışarıya verme kararı, hisse senedi fiyatında büyük bir düşüşe yol açtı.",
    list: "C1",
    answer:
        "düşüş", // "Slash" can be translated as "düşüş" here to convey the idea of a sharp decrease.
    quest: "slash",
  ),

  Words(
    front: "He inserted a new SIM card into the slot on his phone.",
    back:
        "Telefonuna SIM kartı taktı.", // "Yerleştirmek" can be used for inserting an object into a designated space.
    list: "C1",
    answer: "yerleştirmek",
    quest: "slot",
  ),
  Words(
    front: "The angry mob smashed the windows of the store.",
    back: "Öfkeli kalabalık mağazanın vitrinlerini paramparça etti.",
    list: "C1",
    answer: "paramparça etmek",
    quest: "smash",
  ),
  Words(
    front: "The twig snapped in half as he stepped on it.",
    back: "Üzerine bastığında dal parçası ikiye kırıldı.",
    list: "C1",
    answer:
        "kırılmak", // "Snap" can be translated as "kırılmak" in this context.
    quest: "snap",
  ),
  Words(
    front: "The eagle soared high above the mountains.",
    back: "Kartal, dağların çok yukarılarında süzüldü.",
    list: "C1",
    answer: "yüksekten uçmak",
    quest: "soar",
  ),
  Words(
    front: "The shoe has a rubber sole that provides good traction.",
    back: "Ayakkabının iyi tutuş sağlayan kauçuk tabanı vardır.",
    list: "C1",
    answer: "taban",
    quest: "sole",
  ),
  Words(
    front: "He came to the party solely for the purpose of networking.",
    back: "Sadece network kurmak amacıyla partiye geldi.",
    list: "C1",
    answer: "sadece",
    quest: "solely",
  ),
  Words(
    front: "He hired a solicitor to represent him in court.",
    back: "Mahkemede kendisini temsil etmesi için bir avukat tuttu.",
    list: "C1",
    answer: "avukat",
    quest: "solicitor",
  ),
  Words(
    front: "The workers showed solidarity by going on strike together.",
    back: "İşçiler birlikte greve giderek dayanışma gösterdiler.",
    list: "C1",
    answer: "dayanışma",
    quest: "solidarity",
  ),
  Words(
    front: "The sound of the music woke him up in the middle of the night.",
    back: "Müzik sesi onu gecenin ortasında uyandırdı.",
    list: "C1",
    answer: "ses",
    quest: "sound",
  ),
  Words(
    front:
        "The project spans several years and involves researchers from different countries.",
    back:
        "Proje birkaç yılı kapsıyor ve farklı ülkelerden araştırmacıları içeriyor.",
    list: "C1",
    answer:
        "kapsamak", // "Span" can be translated as "kapsamak" to convey the idea of covering a period of time or distance.
    quest: "span",
  ),
  Words(
    front: "Do you have a spare tire in case of a flat?",
    back: "Lastiğiniz patlarsa yedek lastiğiniz var mı?",
    list: "C1",
    answer: "yedek",
    quest: "spare",
  ),
  Words(
    front: "A spark from the campfire ignited the dry leaves.",
    back: "Kamp ateşinden çıkan bir kıvılcım kuru yaprakları tutuşturdu.",
    list: "C1",
    answer: "kıvılcım",
    quest: "spark",
  ),
  Words(
    front:
        "He is a specialized doctor who treats patients with heart problems.",
    back: "O, kalp hastaları tedavisinde uzmanlaşmış bir doktor.",
    list: "C1",
    answer: "uzmanlaşmış",
    quest: "specialized",
  ),
  Words(
    front:
        "The architect provided detailed specifications for the construction of the new building.",
    back: "Mimar, yeni binanın yapımı için ayrıntılı birer özellikname sundu.",
    list: "C1",
    answer: "belirti",
    quest: "specification",
  ),
  Words(
    front:
        "The scientists studied a specimen of the rare plant under a microscope.",
    back:
        "Bilimciler, nadir bitkinin bir örneğini mikroskop altında incelediler.",
    list: "C1",
    answer: "örnek",
    quest: "specimen",
  ),
  Words(
    front: "The parade is the most exciting spectacle of the festival.",
    back: "Geçit töreni festivalin en heyecan verici gösterisidir.",
    list: "C1",
    answer:
        "gösteri", // "Spectacle" can be translated as "gösteri" to convey the idea of a public event.
    quest: "spectacle",
  ),
  Words(
    front: "Can you spell the word 'believe' for me?",
    back: " 'İnanmak' kelimesini heceleyebilir misin?",
    list: "C1",
    answer: "hecelemek",
    quest: "spell",
  ),
  Words(
    front: "The Earth is a sphere, but most maps portray it as flat.",
    back: "Dünya bir küredir, ancak çoğu harita onu düz olarak gösterir.",
    list: "C1",
    answer: "küre",
    quest: "sphere",
  ),
  Words(
    front: "The patch of mud sent the car into a spin.",
    back: "Çamur parçası arabayı takla attırdı.",
    list: "C1",
    answer: "döndürmek",
    quest: "spin",
  ),
  Words(
    front: "The doctor examined his spine for any signs of injury.",
    back:
        "Doktor, omurgasını herhangi bir yaralanma belirtisi olup olmadığına baktı.",
    list: "C1",
    answer: "omurga",
    quest: "spine",
  ),
  Words(
    front:
        "The spotlight was on the actress as she delivered her opening monologue.",
    back:
        "Oyuncunun açılış monologunu sunduğu sırada spot ışığı onun üzerindeydi.",
    list: "C1",
    answer: "spot ışığı",
    quest: "spotlight",
  ),
  Words(
    front: "He has been married to his spouse for over 20 years.",
    back: "Eşiyle 20 yılı aşkın süredir evli.",
    list: "C1",
    answer: "eş",
    quest: "spouse",
  ),
  Words(
    front: "The secret agent was a double spy working for both sides.",
    back: "Gizli ajan, her iki taraf için de çalışan bir çifte casustu.",
    list: "C1",
    answer: "casus",
    quest: "spy",
  ),
  Words(
    front:
        "The police squad surrounded the building and arrested the suspects.",
    back: "Polis ekibi binayı çevirdi ve şüphelileri tutukladı.",
    list: "C1",
    answer: "ekip",
    quest: "squad",
  ),
  Words(
    front: "He tried to squeeze through the narrow gap, but he got stuck.",
    back: "Dar aralıktan sıvışmaya çalıştı ama sıkıştı.",
    list: "C1",
    answer: "sıkışmak",
    quest: "squeeze",
  ),
  Words(
    front:
        "The country's political stability is essential for economic growth.",
    back: "Ülkenin siyasi kararlılığı ekonomik büyüme için gereklidir.",
    list: "C1",
    answer: "kararlılık",
    quest: "stability",
  ),
  Words(
    front: "The medicine helped to stabilize his blood pressure.",
    back: "İlaç, kan basıncını dengeleştirmeye yardımcı oldu.",
    list: "C1",
    answer: "dengeleştirmek",
    quest: "stabilize",
  ),
  Words(
    front: "He drove a stake into the ground to secure the tent.",
    back: "Çadırı sabitlemek için yere kazık çaktı.",
    list: "C1",
    answer: "kazık",
    quest: "stake",
  ),
  Words(
    front: "The crowd was standing in silence as the national anthem played.",
    back: "Milli marş çalınırken kalabalık ayakta sessizce duruyordu.",
    list: "C1",
    answer: "ayakta durmak",
    quest: "standing",
  ),
  Words(
    front: "The contrast between the rich and the poor was stark.",
    back: "Zenginlerle fakirler arasındaki tezat çok belirgindi.",
    list: "C1",
    answer:
        "belirgin", // "Stark" can be translated as "belirgin" to convey the idea of something very noticeable.
    quest: "stark",
  ),
  Words(
    front: "The captain steered the ship away from the rocks.",
    back: "Kaptan, gemiyi kayalıklardan uzaklaştırdı.",
    list: "C1",
    answer: "yönlendirmek",
    quest: "steer",
  ),
  Words(
    front: "Knowing the stem of a word can help you understand its meaning.",
    back:
        " Bir kelimenin kökünü bilmek, anlamını anlamanıza yardımcı olabilir.",
    list: "C1",
    answer:
        "kök,çıkmak", // "Stem" can be translated as "kökenlenmek" to convey the idea of origin.
    quest: "stem",
  ),
  Words(
    front: "A loud noise was the stimulus that startled the cat.",
    back: "Yüksek ses, kediyi ürküten uyaran oldu.",
    list: "C1",
    answer: "uyarıcı",
    quest: "stimulus",
  ),
  Words(
    front: "She stirred the soup to make sure it wasn't burning.",
    back: "Yanıp yanmadığından emin olmak için çorbayı karıştırdı.",
    list: "C1",
    answer: "karıştırmak",
    quest: "stir",
  ),
  Words(
    front: "This warehouse is used for the storage of electronic equipment.",
    back: "Bu depo, elektronik eşyaların depolanması için kullanılır.",
    list: "C1",
    answer:
        "depolama", // "Storage" can be translated as "depolama" to convey the action of storing things.
    quest: "storage",
  ),
  Words(
    front:
        "He gave her straightforward instructions that were easy to understand.",
    back: "Ona anlaşılması kolay, basit talimatlar verdi.",
    list: "C1",
    answer:
        "doğrudan", // "Straightforward" can be translated as "doğrudan" to convey the idea of being clear and direct.
    quest: "straightforward",
  ),
  Words(
    front: "He strained his back while lifting the heavy box.",
    back: "Ağır kutuyu kaldırırken sırtını zorladı.",
    list: "C1",
    answer: "zorlamak",
    quest: "strain",
  ),
  Words(
    front: "She wore a long strand of pearls around her neck.",
    back: "Boynunda uzun bir inci dizisi taktı.",
    list: "C1",
    answer: "dizi",
    quest: "strand",
  ),
  Words(
    front:
        "The advertisement featured a striking image of a beautiful waterfall.",
    back: "Reklamda, güzel bir şelalenin çarpıcı bir görüntüsü vardı.",
    list: "C1",
    answer: "çarpıcı",
    quest: "striking",
  ),
  Words(
    front: "He stripped the paint off the old furniture before repainting it.",
    back: "Eski mobilyaların boyasını yeniden boyamadan önce soydu.",
    list: "C1",
    answer: "soymak",
    quest: "strip",
  ),
  Words(
    front: "She always strives to do her best in everything she does.",
    back:
        "Yaptığı her şeyde her zaman elinden gelenin en iyisini yapmaya çalışır.",
    list: "C1",
    answer: "uğraşmak",
    quest: "strive",
  ),
  Words(
    front: "The building had a strong structural foundation.",
    back: "Binanın sağlam bir yapısal temeli vardı.",
    list: "C1",
    answer: "yapısal",
    quest: "structural",
  ),
  Words(
    front: "He stumbled over his words and forgot what he was going to say.",
    back: "Sözlerinin üzerinde sendeledi ve ne söyleyeceğini unuttu.",
    list: "C1",
    answer: "sendelemek",
    quest: "stumble",
  ),
  Words(
    front: "The news of his death stunned the entire community.",
    back: "Ölüm haberi tüm toplumu şaşkına çevirdi.",
    list: "C1",
    answer: "şaşkına çevirmek",
    quest: "stun",
  ),
  Words(
    front: "The deadline for the essay submission is next Friday.",
    back: "Makalenin teslim tarihi önümüzdeki cuma günü.",
    list: "C1",
    answer: "teslim",
    quest: "submission",
  ),
  Words(
    front: "He is a subscriber to a popular online magazine.",
    back: "Popüler bir online derginin abonesidir.",
    list: "C1",
    answer: "abone",
    quest: "subscriber",
  ),
  Words(
    front: "Many people get a monthly subscription to a streaming service.",
    back: "Birçok insan, aylık olarak bir streaming hizmetine abonelik alır.",
    list: "C1",
    answer: "abonelik",
    quest: "subscription",
  ),
  Words(
    front: "It may be eligible for a government subsidy.",
    back: "Devlet sübvansiyonu için uygun olabilir.",
    list: "C1",
    answer: "sübvansiyon",
    quest: "subsidy",
  ),
  Words(
    front: "He made a substantial contribution to the project's success.",
    back: "Projenin başarısına önemli bir katkıda bulundu.",
    list: "C1",
    answer: "önemli",
    quest: "substantial",
  ),
  Words(
    front: "Her income has substantially increased since she got a new job.",
    back: "Yeni bir iş bulduğundan beri geliri önemli miktarda arttı.",
    list: "C1",
    answer: "önemli ölçüde",
    quest: "substantially",
  ),
  Words(
    front:
        "The teacher asked the students to find a substitute for the missing ingredient in the recipe.",
    back:
        "Öğretmen, öğrencilerden tarifteki eksik malzemenin yerine geçecek bir şey bulmalarını istedi.",
    list: "C1",
    answer: "yerine geçmek",
    quest: "substitute",
  ),
  Words(
    front: "The substitution of butter with olive oil made the cake healthier.",
    back:
        "Tereyağ yerine zeytinyağı kullanılması pastayı daha sağlıklı hale getirdi.",
    list: "C1",
    answer: "yerine koyma",
    quest: "substitution",
  ),
  Words(
    front:
        "The difference in quality between the two products was subtle but noticeable.",
    back: "İki ürün arasındaki kalite farkı güç algılanan ama belirgindi.",
    list: "C1",
    answer: "güç algılanan",
    quest: "subtle",
  ),
  Words(
    front: "They live in a quiet suburban neighborhood with friendly people.",
    back:
        "Sessiz ve insanların birbirini tanıdığı bir banliyö mahallesinde yaşıyorlar.",
    list: "C1",
    answer: "banliyö",
    quest: "suburban",
  ),
  Words(
    front:
        "The king's succession was peaceful, and his son took the throne without any conflict.",
    back:
        "Kralın ardıllığı barışçıl oldu ve oğlu herhangi bir çatışma yaşamadan tahta çıktı.",
    list: "C1",
    answer: "ardıllık",
    quest: "succession",
  ),
  Words(
    front: "He won three successive games of chess, proving his skills.",
    back: "Zeka yeteneğini kanıtlayarak üç ardışık satranç oyunu kazandı.",
    list: "C1",
    answer: "ardışık",
    quest: "successive",
  ),
  Words(
    front:
        "The king's successor is his eldest son, who is now the crown prince.",
    back: "Kralın varisi, şu anda veliaht prens olan en büyük oğludur.",
    list: "C1",
    answer: "varis",
    quest: "successor",
  ),
  Words(
    front:
        "He is planning to sue the company for wrongful termination of his contract.",
    back:
        "Haksız yere işten çıkarılması nedeniyle şirketi dava açmayı planlıyor.",
    list: "C1",
    answer: "dava açmak",
    quest: "sue",
  ),
  Words(
    front: "Suicide is a serious issue that needs to be addressed by society.",
    back: "İntihar, toplum tarafından ele alınması gereken ciddi bir sorundur.",
    list: "C1",
    answer: "intihar",
    quest: "Suicide",
  ),
  Words(
    front: "He rented a luxurious suite at the hotel for his honeymoon.",
    back: "Balayı için otelden lüks bir suit kiraladı.",
    list: "C1",
    answer: "suit",
    quest: "suite",
  ),
  Words(
    front: "The world leaders met at a summit to discuss global issues.",
    back:
        "Dünya liderleri, küresel sorunları tartışmak için bir zirvede bir araya geldi.",
    list: "C1",
    answer: "zirve",
    quest: "summit",
  ),
  Words(
    front: "The meal was absolutely superb! We enjoyed every bite.",
    back: "Yemek kesinlikle harikuladeydi! Her lokmasının tadını çıkardık.",
    list: "C1",
    answer: "harikulade",
    quest: "superb",
  ),
  Words(
    front: "He felt superior to his colleagues and often looked down on them.",
    back:
        "Kendisini meslektaşlarından üstün görüyordu ve onlara sık sık tepeden bakıyordu.",
    list: "C1",
    answer: "üstün",
    quest: "superior",
  ),
  Words(
    front: "The teacher provided close supervision during the students' exams.",
    back: "Öğretmen, öğrencilerin sınavları sırasında yakın gözetim sağladı.",
    list: "C1",
    answer: "gözetim",
    quest: "supervision",
  ),
  Words(
    front:
        "The supervisor is responsible for ensuring that the employees are working efficiently.",
    back:
        "Denetmen, çalışanların verimli bir şekilde çalışmasını sağlamaktan sorumludur.",
    list: "C1",
    answer: "denetmen",
    quest: "supervisor",
  ),
  Words(
    front:
        "He takes a daily vitamin supplement to ensure he is getting all the nutrients he needs.",
    back:
        "İhtiyacı olan tüm besin maddelerini aldığından emin olmak için günlük vitamin takviyesi alıyor.",
    list: "C1",
    answer: "takviye",
    quest: "supplement",
  ),
  Words(
    front:
        "She has a very supportive family who always encourages her to follow her dreams.",
    back:
        "Hayallerinin peşinden gitmesi için onu her zaman destekleyen çok destekleyici bir ailesi var.",
    list: "C1",
    answer: "destekleyici",
    quest: "supportive",
  ),
  Words(
    front:
        "The government is trying to suppress the spread of misinformation online.",
    back:
        "Hükümet, çevrimiçi yanlış bilginin yayılmasını bastırmaya çalışıyor.",
    list: "C1",
    answer: "bastırmak",
    quest: "suppress",
  ),
  Words(
    front: "The Supreme Court is the highest court in the land.",
    back: "Yargıtay, ülkenin en yüksek mahkemesidir.",
    list: "C1",
    answer: "yargıtay",
    quest: "Supreme",
  ),
  Words(
    front: "The price of oil surged after the outbreak of the war.",
    back: "Savaşın patlak vermesinden sonra petrol fiyatları fırladı.",
    list: "C1",
    answer: "fırlamak",
    quest: "surge",
  ),
  Words(
    front: "Tom put on a pair of surgical gloves.",
    back: "Tom bir çift ameliyat eldiveni giydi.",
    list: "C1",
    answer: "ameliyat",
    quest: "surgical",
  ),
  Words(
    front:
        "The company has a surplus of inventory that they are trying to sell.",
    back: "Şirket, satmaya çalıştıkları fazla stok fazlasına sahiptir.",
    list: "C1",
    answer: "fazla",
    quest: "surplus",
  ),
  Words(
    front:
        "The enemy soldiers eventually surrendered after running out of ammunition.",
    back:
        "Düşman askerleri cephaneleri bittikten sonra sonunda teslim oldular.",
    list: "C1",
    answer: "teslim olmak",
    quest: "surrender",
  ),
  Words(
    front: "The house is under constant surveillance by security cameras.",
    back: "Ev, güvenlik kameraları tarafından sürekli gözetleme altındadır.",
    list: "C1",
    answer: "gözetleme",
    quest: "surveillance",
  ),
  Words(
    front:
        "The athlete was given a two-year suspension from competition for doping.",
    back: "Sporcu, doping nedeniyle iki yıllık yarışmaya ara verildi.",
    list: "C1",
    answer: "askıya alma",
    quest: "suspension",
  ),
  Words(
    front: "There was a suspicion that he was cheating on the exam.",
    back: "Sınavda kopya çektiğine dair bir kuşku vardı.",
    list: "C1",
    answer: "kuşku",
    quest: "suspicion",
  ),
  Words(
    front: "The man looked suspicious as he lurked around the corner.",
    back: "Adam köşede pusu verirken şüpheli görünüyordu.",
    list: "C1",
    answer: "şüpheli",
    quest: "suspicious",
  ),
  Words(
    front: "He was able to sustain himself on a diet of fruits and vegetables.",
    back: "Kendini meyve ve sebze ağırlıklı bir diyetle idame ettirebildi.",
    list: "C1",
    answer: "idame ettirmek",
    quest: "sustain",
  ),
  Words(
    front: "The children were swinging on the swings in the playground.",
    back: "Çocuklar oyun parkındaki salıncakta sallanıyorlardı.",
    list: "C1",
    answer: "sallanmak",
    quest: "swing",
  ),
  Words(
    front: "The knight fought bravely with his sword against the dragon.",
    back: "Şövalye, ejderhaya karşı kılıcıyla cesurca savaştı.",
    list: "C1",
    answer: "kılıç",
    quest: "sword",
  ),
  Words(
    front:
        "The scientist's theory was a brilliant synthesis of different ideas.",
    back: "Bilimcinin teorisi, farklı fikirlerin parlak bir senteziydi.",
    list: "C1",
    answer: "sentez",
    quest: "synthesis",
  ),
  Words(
    front: "The government needs to tackle the issue of climate change.",
    back: "Hükümetin iklim değişikliği sorununu ele alması gerekiyor.",
    list: "C1",
    answer: "ele almak",
    quest: "tackle",
  ),
  Words(
    front: "Every taxpayer has a responsibility to pay their taxes.",
    back: "Her vergi verenin vergilerini ödeme sorumluluğu vardır.",
    list: "C1",
    answer: "vergi veren",
    quest: "taxpayer",
  ),
  Words(
    front: "He was tempted to cheat on the test, but he knew it was wrong.",
    back:
        "Kopya çekmek için cazip geldi, ancak bunun yanlış olduğunu biliyordu.",
    list: "C1",
    answer: "kışkırtmak",
    quest: "tempt",
  ),
  Words(
    front:
        "She is a tenant in the apartment building and pays rent to the landlord.",
    back: "Apartman dairesinde kiracıdır ve ev sahibine kira öder.",
    list: "C1",
    answer: "kiracı",
    quest: "tenant",
  ),
  Words(
    front: "The company submitted a tender for the construction project.",
    back: "Şirket, inşaat projesi için bir ihale sundu.",
    list: "C1",
    answer: "ihale",
    quest: "tender",
  ),
  Words(
    front:
        "In most universities, professors have tenure after a probationary period.",
    back:
        "Çoğu üniversitede, profesörler deneme süresinden sonra kadrolu hale gelir.",
    list: "C1",
    answer: "kadrolu olmak",
    quest: "tenure",
  ),
  Words(
    front:
        "The company was forced to terminate his contract due to budget cuts.",
    back:
        "Şirket, bütçe kesintileri nedeniyle sözleşmesini feshetmek zorunda kaldı.",
    list: "C1",
    answer: "feshetmek",
    quest: "terminate",
  ),
  Words(
    front:
        "The soldiers had to fight through difficult terrain to reach their objective.",
    back:
        "Askerler hedeflerine ulaşmak için zorlu araziden savaşarak geçmek zorunda kaldılar.",
    list: "C1",
    answer: "arazi",
    quest: "terrain",
  ),
  Words(
    front: "We had a terrific time at the party! It was a lot of fun.",
    back: "Partilde müthiş vakit geçirdik! Çok eğlenceliydi.",
    list: "C1",
    answer: "müthiş",
    quest: "terrific",
  ),
  Words(
    front:
        "The witness will testify in court about what they saw at the crime scene.",
    back: "Tanık, mahkemede olay yerinde gördükleri hakkında tanıklık edecek.",
    list: "C1",
    answer: "tanıklık etmek",
    quest: "testify",
  ),
  Words(
    front: "The police are relying on eyewitness testimony to solve the case.",
    back: "Polis, davayı çözmek için görgü tanığı ifadesine güveniyor.",
    list: "C1",
    answer: "ifade",
    quest: "testimony",
  ),
  Words(
    front: "I love the soft texture of this cashmere sweater.",
    back: "Bu kaşmir kazağın yumuşak dokusunu seviyorum.",
    list: "C1",
    answer: "doku",
    quest: "texture",
  ),
  Words(
    front:
        "Thankfully, the fire alarm went off in time and everyone was able to evacuate safely.",
    back:
        "Neyse ki, yangın alarmı zamanında devreye girdi ve herkes güvenli bir şekilde tahliye edilebildi.",
    list: "C1",
    answer: "Neyse ki",
    quest: "Thankfully",
  ),
  Words(
    front:
        "The actor gave a very theatrical performance that was full of overdramatic gestures.",
    back:
        "Oyuncu, abartılı jestlerle dolu çok teatral bir performans sergiledi.",
    list: "C1",
    answer: "abartılı",
    quest: "theatrical",
  ),
  Words(
    front:
        "His theory is based on theoretical concepts that have not been proven yet.",
    back: "Teorisi, henüz kanıtlanmamış teorik kavramlara dayanıyor.",
    list: "C1",
    answer: "teorik",
    quest: "theoretical",
  ),
  Words(
    front: "We will discuss the details of the project thereafter.",
    back: "Projenin detaylarını ondan sonra tartışacağız.",
    list: "C1",
    answer: "ondan sonra",
    quest: "thereafter",
  ),
  Words(
    front:
        "He achieved his goals by working hard and diligently. Thereby, he proved that anything is possible with hard work.",
    back:
        "Hedeflerine sıkı çalışarak ve özenle çalışarak ulaştı. Böylelikle, sıkı çalışma ile her şeyin mümkün olduğunu kanıtladı.",
    list: "C1",
    answer: "böylelikle",
    quest: "Thereby",
  ),
  Words(
    front:
        "She gave a thoughtful gift that showed she really cared about her friend.",
    back:
        "Düşünceli bir hediye verdi ve bu da arkadaşını gerçekten önemsediğini gösterdi.",
    list: "C1",
    answer: "düşünceli",
    quest: "thoughtful",
  ),
  Words(
    front: "The movie was a thought-provoking exploration of social issues.",
    back:
        "Film, sosyal sorunları düşündürücü bir şekilde ele alan bir incelemeydi.",
    list: "C1",
    answer: "düşündürücü",
    quest: "thought-provoking",
  ),
  Words(
    front: "She used a strong thread to sew the button back on her shirt.",
    back: "Gomleğindeki düğmeyi tekrar dikmek için sağlam bir iplik kullandı.",
    list: "C1",
    answer: "iplik",
    quest: "thread",
  ),
  Words(
    front:
        "We are on the threshold of a new era of technological advancements.",
    back: "Teknolojik gelişmelerin yeni bir çağının eşiğindeyiz.",
    list: "C1",
    answer: "eşik",
    quest: "threshold",
  ),
  Words(
    front:
        "She was thrilled to win the competition and finally achieve her dream.",
    back: "Yarışmayı kazanıp sonunda hayaline ulaştığı için heyecanlanmıştı.",
    list: "C1",
    answer: "heyecanlanmış",
    quest: "thrilled",
  ),
  Words(
    front: "Plants thrive in fertile soil with plenty of sunlight and water.",
    back: "Bitkiler, bereketli toprakta, bol güneş ışığı ve su ile gelişir.",
    list: "C1",
    answer: "gelişmek",
    quest: "thrive",
  ),
  Words(
    front: "He tightened his grip on the rope to prevent himself from falling.",
    back: "Düşmeyi önlemek için ipteki tutuşunu sıkılaştırdı.",
    list: "C1",
    answer: "sıkılaştırmak",
    quest: "tighten",
  ),
  Words(
    front: "The house is built from a combination of brick and timber.",
    back: "Ev, tuğla ve kereste kombinasyonundan inşa edilmiştir.",
    list: "C1",
    answer: "kereste",
    quest: "timber",
  ),
  Words(
    front: "It was a timely warning that helped us avoid a major disaster.",
    back:
        "Büyük bir felaketi önlememize yardımcı olan zamanında yapılan bir uyarıydı.",
    list: "C1",
    answer: "zamanında yapılan",
    quest: "timely",
  ),
  Words(
    front: "Smoking tobacco can lead to serious health problems.",
    back: "Tütün içmek ciddi sağlık sorunlarına yol açabilir.",
    list: "C1",
    answer: "tütün",
    quest: "tobacco",
  ),
  Words(
    front: "He showed a great deal of tolerance for her mistakes.",
    back: "Hatalarına karşı büyük bir hoşgörü gösterdi.",
    list: "C1",
    answer: "hoşgörü",
    quest: "tolerance",
  ),
  Words(
    front: "Children need to learn to tolerate frustration.",
    back: "Çocukların hayal kırıklığına tahammül etmeyi öğrenmeleri gerekir.",
    list: "C1",
    answer: "tahammül etmek",
    quest: "tolerate",
  ),
  Words(
    front: "You have to pay a toll to cross the bridge.",
    back: "Köprüyü geçmek için çan çalmak zorundasınız.",
    list: "C1",
    answer: 'Geçit ücreti',
    quest: 'toll',
  ),
  Words(
    front: "I live on the top floor of the building.",
    back: "Binanın en üst katında oturuyorum.",
    list: "C1",
    answer: "en üst",
    quest: "top",
  ),
  Words(
    front: "The prisoners were tortured by their captors.",
    back: "Tutuklular, gardiyanları tarafından işkence gördü.",
    list: "C1",
    answer: "işkence",
    quest: "torture",
  ),
  Words(
    front: "They tossed a coin to decide who would go first.",
    back: "Kimin önce gideceğine karar vermek için yazı tura attılar.",
    list: "C1",
    answer: "atmak",
    quest: "toss",
  ),
  Words(
    front: "The total cost of the repairs came to \$1000.",
    back: "Tamiratın toplam maliyeti 1000 dolara ulaştı.",
    list: "C1",
    answer: "toplam",
    quest: "total",
  ),
  Words(
    front: "Exposure to toxic chemicals can cause serious health problems.",
    back:
        "Zehirli kimyasallara maruz kalmak ciddi sağlık sorunlarına neden olabilir.",
    list: "C1",
    answer: "zehirli",
    quest: "toxic",
  ),
  Words(
    front: "The police are trying to trace the suspect's movements.",
    back: "Polis, şüphelinin hareketlerini iz sürmek çalışıyor.",
    list: "C1",
    answer: "iz sürmek",
    quest: "trace",
  ),
  Words(
    front: "Nike is a well-known trademark for athletic shoes.",
    back: "Nike, spor ayakkabıları için tanınmış bir markadır.",
    list: "C1",
    answer: "marka",
    quest: "trademark",
  ),
  Words(
    front: "The hikers followed a well-marked trail through the forest.",
    back: "Yürüyüşçüler, orman boyunca iyi işaretlenmiş bir iz takip ettiler.",
    list: "C1",
    answer: "iz",
    quest: "trail",
  ),
  Words(
    front: "I watched the trailer for the new movie and it looks really good.",
    back: "Yeni filmin fragmanını izledim ve gerçekten çok iyi görünüyor.",
    list: "C1",
    answer: "fragman",
    quest: "trailer",
  ),
  Words(
    front:
        "The bank transaction was successful and the money has been transferred.",
    back: "Banka işlemi başarılı oldu ve para transfer edildi.",
    list: "C1",
    answer: "işlem",
    quest: "transaction",
  ),
  Words(
    front:
        "The student requested a transcript of their grades from the university.",
    back: "Öğrenci, üniversiteden notlarının bir transkriptini talep etti.",
    list: "C1",
    answer: "transkript",
    quest: "transcript",
  ),
  Words(
    front:
        "The caterpillar undergoes a remarkable transformation into a butterfly.",
    back: "Tırtıl, kelebeğe dönüşen dikkat çekici bir dönüşüm geçirir.",
    list: "C1",
    answer: "dönüşüm",
    quest: "transformation",
  ),

  Words(
    front:
        "The car wouldn't start because there was a problem with the transmission.",
    back: "Araba vites sorunu nedeniyle çalışmadı.",
    list: "C1",
    answer: "vites",
    quest: "transmission",
  ),
  Words(
    front: "There is a need for more transparency in government spending.",
    back: "Devlet harcamalarında daha fazla şeffaflık olması gerekiyor.",
    list: "C1",
    answer: "şeffaflık",
    quest: "transparency",
  ),
  Words(
    front: "I can see through the transparent window.",
    back: "Saydam pencereden görebiliyorum.",
    list: "C1",
    answer: "saydam",
    quest: "transparent",
  ),
  Words(
    front: "The soldier suffered a severe trauma from the war.",
    back: "Asker, savaştan kaynaklanan ciddi bir travma yaşadı.",
    list: "C1",
    answer: "travma",
    quest: "trauma",
  ),
  Words(
    front: "The two countries signed a peace treaty to end the conflict.",
    back:
        "İki ülke, çatışmayı sona erdirmek için bir barış antlaşması imzaladı.",
    list: "C1",
    answer: "antlaşma",
    quest: "treaty",
  ),
  Words(
    front: "He made a tremendous effort to overcome the challenges he faced.",
    back:
        "Karşılaştığı zorlukların üstesinden gelmek için muazzam bir çaba gösterdi.",
    list: "C1",
    answer: "muazzam",
    quest: "tremendous",
  ),
  Words(
    front: "The case was brought before a tribunal for international crimes.",
    back: "Dava, uluslararası suçlar için bir mahkemeye getirildi.",
    list: "C1",
    answer: "mahkeme",
    quest: "tribunal",
  ),
  Words(
    front:
        "The ancient city paid tribute to the emperor in the form of gold and jewels.",
    back: "Eski şehir, haraç olarak imparatora altın ve mücevher verdi.",
    list: "C1",
    answer: "haraç",
    quest: "tribute",
  ),
  Words(
    front: "The news triggered a wave of panic buying in the supermarkets.",
    back: "Haber, süpermarketlerde bir panik satın alma dalgasını tetikledi.",
    list: "C1",
    answer: "tetiklemek",
    quest: "trigger",
  ),
  Words(
    front: "The band consists of a talented trio of musicians.",
    back: "Grup, yetenekli bir müzisyen üçlüsünden oluşuyor.",
    list: "C1",
    answer: "üçlü takım",
    quest: "trio",
  ),
  Words(
    front: "The team celebrated their triumph in the championship game.",
    back: "Takım, şampiyonluk maçındaki zaferlerini kutladı.",
    list: "C1",
    answer: "zafer",
    quest: "triumph",
  ),
  Words(
    front: "The winner of the competition received a golden trophy.",
    back: "Yarışmanın kazananı altın bir kupa aldı.",
    list: "C1",
    answer: "ganimet",
    quest: "trophy",
  ),
  Words(
    front: "He looked troubled and seemed to be deep in thought.",
    back: "Sıkıntılı görünüyordu ve derin düşüncelere dalmış gibiydi.",
    list: "C1",
    answer: "sıkıntılı",
    quest: "troubled",
  ),
  Words(
    front:
        "The cost of tuition has been rising steadily over the past few years.",
    back: "Son birkaç yılda okul ücreti maliyeti sürekli olarak artıyor.",
    list: "C1",
    answer: "okul ücreti",
    quest: "tuition",
  ),
  Words(
    front: "The bakery sells a variety of delicious turnovers.",
    back: "Fırın, çeşitli lezzetli meyveli turtalar satıyor.",
    list: "C1",
    answer: "meyveli turta",
    quest: "turnover",
  ),
  Words(
    front: "She gave the wire a little twist to tighten the connection.",
    back: "Bağlantıyı sıkmak için teli biraz büktü.",
    list: "C1",
    answer: "bükmek",
    quest: "twist",
  ),
  Words(
    front:
        "She is currently enrolled in an undergraduate program at the university.",
    back: "Şu anda üniversitede lisans programına kayıtlıdır.",
    list: "C1",
    answer: "lisans",
    quest: "undergraduate",
  ),
  Words(
    front:
        "There are many underlying factors that contribute to climate change.",
    back:
        "İklim değişikliğine katkıda bulunan birçok altta yatan faktör vardır.",
    list: "C1",
    answer: "altta yatan",
    quest: "underlying",
  ),
  Words(
    front: "His constant criticism served to undermine her confidence.",
    back: "Sürekli eleştirisi, onun güvenini baltalamaya yaradı.",
    list: "C1",
    answer: "baltalamak",
    quest: "undermine",
  ),
  Words(
    front: "He is undoubtedly the most qualified candidate for the job.",
    back: "Şüphesiz olarak işe en uygun adaydır.",
    list: "C1",
    answer: "şüphesiz olarak",
    quest: "undoubtedly",
  ),
  Words(
    front: "The countries are working together to unify their economies.",
    back: "Ülkeler, ekonomilerini birleştirmek için birlikte çalışıyorlar.",
    list: "C1",
    answer: "aynı yapmak",
    quest: "unify",
  ),
  Words(
    front: "We are facing unprecedented challenges in the 21st century.",
    back: "21. yüzyılda eşi benzeri görülmemiş zorluklarla karşı karşıyayız.",
    list: "C1",
    answer: "eşi benzeri görülmemiş",
    quest: "unprecedented",
  ),
  Words(
    front: "We are excited about the upcoming conference on climate change.",
    back:
        "İklim değişikliği hakkındaki yaklaşan konferans hakkında heyecanlıyız.",
    list: "C1",
    answer: "olmak üzere olan",
    quest: "upcoming",
  ),
  Words(
    front: "I would like to upgrade my ticket from economy to business class.",
    back: "Biletimi ekonomiden business class'a yükseltmek istiyorum.",
    list: "C1",
    answer: "geliştirmek",
    quest: "upgrade",
  ),
  Words(
    front: "It is important to uphold the values of democracy and freedom.",
    back: "Demokrasi ve özgürlük değerlerini savunmak önemlidir.",
    list: "C1",
    answer: "tutmak",
    quest: "uphold",
  ),
  Words(
    front:
        "A calculator is a useful utility for performing mathematical calculations.",
    back:
        "Hesap makinesi, matematiksel hesaplamalar yapmak için faydalı bir yardımcı yazılımdır.",
    list: "C1",
    answer: "yardımcı yazılım",
    quest: "utility",
  ),
  Words(
    front: "The company is looking for ways to better utilize its resources.",
    back: "Şirket, kaynaklarını daha iyi değerlendirmenin yollarını arıyor.",
    list: "C1",
    answer: "yararlanmak",
    quest: "utilize",
  ),
  Words(
    front: "She was utterly devastated by the news of her friend's death.",
    back: "Arkadaşının ölümü haberiyle tamamen yıkılmıştı.",
    list: "C1",
    answer: "tümüyle",
    quest: "utterly",
  ),
  Words(
    front: "His instructions were vague and left me feeling confused.",
    back: "Talimatları belirsizdi ve kafamı karıştırdı.",
    list: "C1",
    answer: "şüpheli",
    quest: "vague",
  ),
  Words(
    front: "The validity of the passport expired five years ago.",
    back: "Pasaportun geçerliliği beş yıl önce doldu.",
    list: "C1",
    answer: "geçerlilik",
    quest: "validity",
  ),
  Words(
    front: "The magician made the rabbit vanish in a puff of smoke.",
    back: "Sihirbaz, tavşanı bir duman bulutunda ortadan kaybolmasını sağladı.",
    list: "C1",
    answer: "ortadan kaybolmak",
    quest: "vanish",
  ),
  Words(
    front:
        "The weather is very variable this week, with sunshine one day and rain the next.",
    back: "Bu hafta hava çok değişken, bir gün güneşli diğer gün yağmurlu.",
    list: "C1",
    answer: "değişken",
    quest: "variable",
  ),
  Words(
    front: "We enjoyed a varied menu with dishes from all over the world.",
    back:
        "Dünyanın her yerinden yemeklerin bulunduğu çeşitli bir menünün tadını çıkardık.",
    list: "C1",
    answer: "değişik",
    quest: "varied",
  ),
  Words(
    front: "Blood travels through the veins to the heart.",
    back: "Kan, damarlar yoluyla kalbe taşınır.",
    list: 'C1',
    answer: "damar",
    quest: "vein",
  ),
  Words(
    front: "They decided to start their own business venture.",
    back: "Kendi iş girişimlerini başlatmaya karar verdiler.",
    list: "C1",
    answer: "girişim",
    quest: "venture",
  ),
  Words(
    front: "The witness gave a verbal account of what they saw.",
    back: "Tanık, gördüklerini sözlü olarak anlattı.",
    list: "C1",
    answer: "sözlü",
    quest: "verbal",
  ),
  Words(
    front: "The jury reached a verdict of guilty after a long deliberation.",
    back: "Jüri, uzun bir müzakerenin ardından suçlu kararına vardı.",
    list: "C1",
    answer: "hüküm",
    quest: "verdict",
  ),
  Words(
    front: "The scientist was able to verify the results of the experiment.",
    back: "Bilim insanı, deneyin sonuçlarını doğrulayabildi.",
    list: "C1",
    answer: "doğrulamak",
    quest: "verify",
  ),
  Words(
    front:
        "My favorite poem is the first verse of Sonnet 18 by William Shakespeare.",
    back:
        "En sevdiğim şiir, William Shakespeare'ın Sonnet 18'inin ilk dizesidir.",
    list: "C1",
    answer: "dize",
    quest: "verse",
  ),
  Words(
    front: "The football match will be played between Turkey versus France.",
    back: "Futbol maçı Türkiye - Fransa arasında oynanacak.",
    list: "C1",
    answer: "aleyhinde, karşı",
    quest: "versus",
  ),
  Words(
    front:
        "The cargo ship is a large vessel that can transport thousands of tons of goods.",
    back: "Kargo gemisi, binlerce tonluk malı taşıyabilen büyük bir gemidir.",
    list: "C1",
    answer: "gemi",
    quest: "vessel",
  ),
  Words(
    front: "He is a veteran soldier with many years of experience in combat.",
    back: "Uzun yıllar savaş tecrübesine sahip kıdemli bir askerdir.",
    list: "C1",
    answer: "kıdemli",
    quest: "veteran",
  ),
  Words(
    front: "Is this plan a viable option for solving the problem?",
    back: "Bu plan, sorunu çözmek için yaşayabilir bir seçenek mi?",
    list: "C1",
    answer: "yaşayabilir",
    quest: "viable",
  ),
  Words(
    front: "The city is known for its vibrant culture and nightlife.",
    back: "Şehir, canlı kültürü ve gece hayatı ile tanınır.",
    list: "C1",
    answer: "titreşimli",
    quest: "vibrant",
  ),
  Words(
    front: "The president admitted to his vice in judgment.",
    back: "Başkan, verdiği yanlış kararın sorumluluğunu üstlendi.",
    list: "C1",
    answer: "özür",
    quest: "vice",
  ),

  Words(
    front: "The dog attacked the mail carrier in a vicious manner.",
    back: "Köpek, postacıya vahşi bir şekilde saldırdı.",
    list: "C1",
    answer: "vahşi",
    quest: "vicious",
  ),
  Words(
    front: "The villagers live a simple life close to nature.",
    back: "Köylüler, doğayla iç içe basit bir hayat sürüyorlar.",
    list: "C1",
    answer: "köylü",
    quest: "villager",
  ),
  Words(
    front: "Smoking cigarettes violates the health code.",
    back: "Sigara içmek sağlık kurallarını çiğnemektir.",
    list: "C1",
    answer: "ihlal etmek",
    quest: "violate",
  ),
  Words(
    front: "Speeding is a violation of traffic laws.",
    back: "Hız yapmak trafik yasalarının bir ihlalidir.",
    list: "C1",
    answer: "ihlal",
    quest: "violation",
  ),
  Words(
    front: "Honesty and compassion are important virtues to possess.",
    back: "Dürüstlük ve merhamet, sahip olunması gereken önemli erdemlerdir.",
    list: "C1",
    answer: "erdem",
    quest: "virtue",
  ),
  Words(
    front: "He vowed to get revenge on his enemies.",
    back: "Düşmanlarından intikam almaya yemin etti.",
    list: "C1",
    answer: "yemin etmek",
    quest: "vow",
  ),
  Words(
    front:
        "Sharing your vulnerability/ies with someone you trust can deepen your connection.",
    back:
        "Güvendiğiniz biriyle kendi kırılganlıklarınızı paylaşmak bağlantınızı derinleştirebilir.",
    list: "C1",
    answer: "kırılganlık",
    quest: "vulnerability",
  ),
  Words(
    front:
        "She is very vulnerable to getting the flu because she hasn't been vaccinated.",
    back: "Aşı olmadığı için gribe yakalanmaya karşı çok kolay yaralanır.",
    list: "C1",
    answer: "kolayca yaralanır",
    quest: "vulnerable",
  ),
  Words(
    front: "The hospital staff were on ward duty throughout the night.",
    back: "Hastane personeli gece boyunca nöbet görevi başındaydı.",
    list: "C1",
    answer: "nöbet", // This is a better translation for "ward" in this context
    quest: "ward",
  ),
  Words(
    front: "The company has a large warehouse where they store their products.",
    back: "Şirketin ürünleri depolamak için kullandığı büyük bir deposu var.",
    list: "C1",
    answer: "depo",
    quest: "warehouse",
  ),
  Words(
    front: "A regional conflict can erupt into violent warfare.",
    back: "Bölgesel bir çatışma şiddetli bir savaşa dönüşebilir.",
    list: "C1",
    answer: "savaş",
    quest: "warfare",
  ),
  Words(
    front:
        "The product does not come with a warranty, so you cannot return it if it breaks.",
    back: "Ürün garantili değil, bu nedenle bozulursa iade edemezsiniz.",
    list: "C1",
    answer: "garanti etmek",
    quest: "warrant",
  ),
  Words(
    front: "The brave warrior fought valiantly to protect his village.",
    back: "Cesur savaşçı, köyünü korumak için kahramanca savaştı.",
    list: "C1",
    answer: "savaşçı",
    quest: "warrior",
  ),
  Words(
    front: "A lack of sleep can weaken your immune system.",
    back: "Uyku eksikliği, bağışıklık sisteminizi zayıflatabilir.",
    list: "C1",
    answer: "zayıflatmak",
    quest: "weaken",
  ),
  Words(
    front: "The artist used colorful threads to weave a beautiful tapestry.",
    back: "Sanatçı, güzel bir halı dokumak için renkli iplikler kullandı.",
    list: "C1",
    answer: "dokumak",
    quest: "weave",
  ),
  Words(
    front: "We need to remove the weeds from the flower bed.",
    back: "Yataktaki otları temizlememiz gerekiyor.",
    list: "C1",
    answer: "ot",
    quest: "weed",
  ),
  Words(
    front: "The well provided a source of fresh water for the village.",
    back: "Kuyu, köy için temiz bir su kaynağı sağladı.",
    list: "C1",
    answer: "kuyu",
    quest: "well",
  ),
  Words(
    front: "Exercise and a healthy diet are essential for well-being.",
    back: "Egzersiz ve sağlıklı beslenme, sağlıklı yaşam için gereklidir.",
    list: "C1",
    answer: "iyi oluş",
    quest: "well-being",
  ),
  Words(
    front: "We don't need to discuss his mistakes whatsoever.",
    back: "Hatalarını hiçbir şekilde tartışmamıza gerek yok.",
    list: "C1",
    answer: "hiçbir",
    quest: "whatsoever",
  ),
  Words(
    front:
        "The bridge was constructed whereby cars and trains could cross the river.",
    back:
        "Köprü, arabaların ve trenlerin nehrin üzerinden geçebileceği şekilde inşa edildi.",
    list: "C1",
    answer:
        "sayesinde", // "şöyle ki" or "böylelikle" are better translations for "whereby" in this context
    quest: "whereby",
  ),
  Words(
    front: "The trainer used a whip to motivate the horse during the race.",
    back: "Eğitmen, yarış sırasında atı motive etmek için kamçı kullandı.",
    list: "C1",
    answer: "kamçılamak",
    quest: "whip",
  ),
  Words(
    front: "He was wholly dedicated to his work and never gave up.",
    back: "Tamamen işine adanmıştı ve asla vazgeçmedi.",
    list: "C1",
    answer: "tamamen",
    quest: "wholly",
  ),
  Words(
    front:
        "The construction project will widen the road to accommodate more traffic.",
    back:
        "İnşaat projesi, daha fazla trafiğe yer açmak için yolu genişletecek.",
    list: "C1",
    answer: "genişletmek",
    quest: "widen",
  ),
  Words(
    front: "The width of the door frame is not standard.",
    back: "Kapı çerçevesinin genişliği standart değildir.",
    list: "C1",
    answer: "genişlik",
    quest: "width",
  ),
  Words(
    front: "Learning English requires a willingness to study on one's own.",
    back:
        "İngilizce öğrenmek, kişinin kendi başına çalışmaya istekli olmasını gerektirir.",
    list: "C1",
    answer: "gönüllülük",
    quest: "willingness",
  ),
  Words(
    front: "He was known for his sharp wit and clever humor.",
    back: "Keskin zekası ve esprili mizahı ile tanınıyordu.",
    list: "C1",
    answer: "ince espri",
    quest: "wit",
  ),
  Words(
    front:
        "The sudden withdrawal of troops from the warzone surprised everyone.",
    back: "Savaş bölgesinden ani asker çekilmesi herkesi şaşırttı.",
    list: "C1",
    answer: "bırakma",
    quest: "withdrawal",
  ),
  Words(
    front: "She did a daily workout to stay in shape.",
    back: "Formda kalmak için günlük olarak spor yaptı.",
    list: "C1",
    answer: "egzersiz",
    quest: "workout",
  ),
  Words(
    front: "Many people worship different gods and goddesses.",
    back: "Birçok insan farklı tanrı ve tanrıçalara tapar.",
    list: "C1",
    answer: "tapmak",
    quest: "worship",
  ),
  Words(
    front: "Is it worthwhile spending so much money on this gadget?",
    back: "Bu alete bu kadar para harcamaya değer mi?",
    list: "C1",
    answer: "değer",
    quest: "worthwhile",
  ),
  Words(
    front: "He is a worthy candidate for the scholarship.",
    back: "Bursu hak eden bir adaydır.",
    list: "C1",
    answer: "hak eden",
    quest: "worthy",
  ),
  Words(
    front: "The children were yelling and playing in the park.",
    back: "Çocuklar parkta bağırıyor ve oynuyorlardı.",
    list: "C1",
    answer: "bağırmak",
    quest: "yell",
  ),
  Words(
    front: "The army eventually yielded to the enemy's superior forces.",
    back: "Ordu sonunda düşmanın üstün güçlerine teslim oldu.",
    list: "C1",
    answer: "teslim olmak",
    quest: "yield",
  ),
  Words(
    front: "The youngsters are the future of our country.",
    back: "Gençler ülkemizin geleceğidir.",
    list: "C1",
    answer: "gençler",
    quest: "youngster",
  ),
  Words(
      front: "He decided to abandon his ship after it hit an iceberg.",
      back: "Gemisi bir buzdağına çarptıktan sonra terk etmeye karar verdi.",
      list: 'B2',
      answer: 'terk etmek',
      quest: 'abandon'),
  Words(
      front: "There is absolute silence in the library.",
      back: "Kütüphanede mutlak sessizlik var.",
      list: 'B2',
      answer: 'mutlak, tam',
      quest: 'absolute'),
  Words(
      front: "The sponge can absorb a large amount of water.",
      back: "Sünger, büyük miktarda suyu absorbe edebilir.",
      list: 'B2',
      answer: 'kavramak',
      quest: 'absorb'),
  Words(
      front: "Abstract art is often difficult to understand for beginners.",
      back: "Soyut sanat, yeni başlayanlar için genellikle anlaşılması zordur.",
      list: 'B2',
      answer: 'soyutlamak',
      quest: 'Abstract'),
  Words(
      front: "It is not acceptable to cheat on an exam.",
      back: "Bir sınavda kopya çekmek kabul edilebilir bir şey değildir.",
      list: 'B2',
      answer: 'kabul edilebilir',
      quest: 'acceptable'),
  Words(
      front: "Would you like me to accompany you to the doctor's appointment?",
      back: "Doktor randevunuza eşlik etmemi ister misiniz?",
      list: 'B2',
      answer: 'eşlik etmek',
      quest: 'accompany'),
  Words(
      front: "Don't forget to take your account number with you to the bank.",
      back: "Bankaya giderken hesap numaranızı yanınızda götürmeyi unutmayın.",
      list: 'B2',
      answer: 'hesap',
      quest: 'account'),
  Words(
      front: "Don't forget to take your account number with you to the bank.",
      back: "Bankaya giderken hesap numaranızı yanınızda götürmeyi unutmayın.",
      list: 'B2',
      answer: 'hesap',
      quest: 'account'),
  Words(
      front: "The information in this report is accurate and up-to-date.",
      back: "Bu rapordaki bilgiler doğru ve günceldir.",
      list: 'B2',
      answer: 'doğru',
      quest: 'accurate'),
  Words(
      front: "The police accused him of stealing the money.",
      back: "Polis onu parayı çalmakla suçladı.",
      list: 'B2',
      answer: 'suçlamak',
      quest: 'accuse'),
  Words(
      front: "He acknowledged his mistake and apologized.",
      back: "Hatasını kabul etti ve özür diledi.",
      list: 'B2',
      answer: 'kabullenmek',
      quest: 'acknowledge'),
  Words(
      front: "She was able to acquire new skills through her online courses.",
      back: "Çevrimiçi kursları sayesinde yeni beceriler edinebildi.",
      list: 'B2',
      answer: 'elde etmek',
      quest: 'acquire'),
  Words(
      front: "The actual reason for his departure is unknown.",
      back: "Ayrılmasının gerçek nedeni bilinmiyor.",
      list: 'B2',
      answer: 'gerçek',
      quest: 'actual'),
  Words(
      front: "We need to adapt to the changing climate.",
      back: "Değişen iklime adapte olmamız gerekiyor.",
      list: 'B2',
      answer: 'adapte etmek',
      quest: 'adapt'),
  Words(
      front: "I need some additional information before I can make a decision.",
      back: "Karar vermeden önce biraz daha fazladan bilgiye ihtiyacım var.",
      list: 'B2',
      answer: 'fazladan',
      quest: 'additional'),
  Words(
      front:
          "Please address your complaints to the customer service department.",
      back: "Şikayetlerinizi lütfen müşteri hizmetleri bölümüne bildirin.",
      list: 'B2',
      answer: 'hitap etmek, adres',
      quest: 'address'),
  Words(
      front:
          "The school administration is responsible for the day-to-day running of the school.",
      back: "Okul yönetimi, okulun günlük işleyişinden sorumludur.",
      list: 'B2',
      answer: 'yönetim',
      quest: 'administration'),
  Words(
      front:
          "Many couples choose to adopt children who are in need of a loving home.",
      back:
          "Birçok çift, sevgi dolu bir yuva ihtiyacı olan çocukları evlat edinmeyi tercih eder.",
      list: 'B2',
      answer: 'evlat edinmek, benimsemek',
      quest: 'adopt'),
  Words(
      front: "See how eagerly the lobsters and the turtles all advance!",
      back:
          "Istakozların ve kaplumbağaların ne kadar hevesle ilerlediğini görün!",
      list: 'B2',
      answer: 'ilerleme,terfi ettirmek',
      quest: 'advance'),
  Words(
      front: "It's none of your affair what I do in my free time.",
      back: "Boş zamanımda ne yaptığımın senin meselen değil.",
      list: 'B2',
      answer: 'mesele',
      quest: 'affair'),
  Words(
      front: "We can discuss this further afterwards if you like.",
      back: "İsterseniz bunu daha sonra daha ayrıntılı olarak tartışabiliriz.",
      list: 'B2',
      answer: 'sonrada',
      quest: 'afterwards'),
  Words(
      front: "I booked my flight through a travel agency.",
      back: "Uçuşumu bir seyahat acentesi aracılığıyla rezerve ettirdim.",
      list: 'B2',
      answer: 'acente',
      quest: 'agency'),
  Words(
      front: "What's on the agenda for today's meeting?",
      back: "Bugünkü toplantının gündeminde ne var?",
      list: 'B2',
      answer: 'gündem',
      quest: 'agenda'),
  Words(
      front: "The dog became aggressive when the mail carrier approached.",
      back: "Postacı yaklaştığında köpek agresifleşti.",
      list: 'B2',
      answer: 'agresif',
      quest: 'aggressive'),
  Words(
      front:
          "Many international organizations provide aid to developing countries.",
      back:
          "Birçok uluslararası kuruluş, gelişmekte olan ülkelere yardım sağlıyor.",
      list: 'B2',
      answer: 'yardım etmek',
      quest: 'aid'),
  Words(
      front:
          "The pilot was able to safely land the aircraft despite the bad weather.",
      back:
          "Pilot, kötü hava koşullarına rağmen uçağı güvenli bir şekilde yere indirmeyi başardı.",
      list: 'B2',
      answer: 'uçak',
      quest: 'aircraft'),
  Words(
      front: "I need to alter my schedule because of the unexpected meeting.",
      back: "Beklenmedik toplantı nedeniyle programımı değiştirmem gerekiyor.",
      list: 'B2',
      answer: 'değiştirmek',
      quest: 'alter'),
  Words(
      front: "The total amount of the bill is \$100.",
      back: "Faturanın toplam miktarı 100 dolar.",
      list: 'B2',
      answer: 'miktar',
      quest: 'amount'),
  Words(
      front: "Don't try to anger me. It won't help.",
      back: "Beni kızdırmaya çalışma. Yardımcı olmaz.",
      list: 'B2',
      answer: 'kızdırmak',
      quest: 'anger'),
  Words(
      front:
          "The photographer tilted the camera at a slight angle to get a better shot.",
      back:
          "Fotoğrafçı, daha iyi bir çekim yapmak için kamerayı hafif bir açıyla eğdi.",
      list: 'B2',
      answer: 'açı',
      quest: 'angle'),
  Words(
      front:
          "They celebrated their wedding anniversary with a romantic dinner.",
      back: "Düğün yıldönümlerini romantik bir akşam yemeği ile kutladılar.",
      list: 'B2',
      answer: 'yıl dönümü',
      quest: 'anniversary'),
  Words(
      front: "The company is having its annual sales conference next week.",
      back: "Şirket, önümüzdeki hafta yıllık satış konferansını düzenliyor.",
      list: 'B2',
      answer: 'senelik',
      quest: 'annual'),
  Words(
      front: "She seemed a little anxious before her job interview.",
      back: "İş görüşmesinden önce biraz endişeli görünüyordu.",
      list: 'B2',
      answer: 'endişeli',
      quest: 'anxious'),
  Words(
      front: "It is apparent that he is not interested in what I have to say.",
      back: "Benim söyleyeceklerime ilgisiz olduğu açık.",
      list: 'B2',
      answer: 'aşikar',
      quest: 'apparent'),
  Words(
      front: "Apparently, they are planning to move to a new house next year.",
      back:
          "Görünüşe göre, önümüzdeki sene yeni bir eve taşınmayı planlıyorlar.",
      list: 'B2',
      answer: 'görünüşte',
      quest: 'Apparently'),
  Words(
      front: "The judge will appeal the decision to a higher court.",
      back: "Yargıç, kararı daha yüksek bir mahkemeye taşıyacaktır.",
      list: 'B2',
      answer: 'başvurmak',
      quest: 'appeal'),
  Words(
      front: "He slowly approached the dog, making sure not to startle it.",
      back: "Köpeği ürkütmemeye dikkat ederek yavaşça yaklaştı.",
      list: 'B2',
      answer: 'yanaşmak',
      quest: 'approach'),
  Words(
      front: "It is not appropriate to wear shorts to a job interview.",
      back: "İş görüşmesine şort giymek uygunsuz değildir.",
      list: 'B2',
      answer: 'el koymak',
      quest: 'appropriate'),
  Words(
      front: "We are still waiting for the approval of our loan application.",
      back: "Kredi başvurumuzun onaylanmasını hala bekliyoruz.",
      list: 'B2',
      answer: 'onaylama',
      quest: 'approval'),
  Words(
      front: "My application was finally approved after a long wait.",
      back: "Uzun bir bekleyişin ardından başvurum nihayet onaylandı.",
      list: 'B2',
      answer: 'onaylanmak',
      quest: 'approve'),
  Words(
      front: "Many social problems arise from poverty and inequality.",
      back: "Birçok sosyal sorun yoksulluk ve eşitsizlikten kaynaklanır.",
      list: 'B2',
      answer: 'kaynaklanmak',
      quest: 'arise'),
  Words(
      front: "The police were called to the scene of an armed robbery.",
      back: "Polis, silahlı soygun olay yerine çağrıldı.",
      list: 'B2',
      answer: 'ateşli',
      quest: 'armed'),
  Words(
      front: "He is applying for a permit to carry arms for self-defense.",
      back:
          "Kendini savunmak için silah taşıma ruhsatı başvurusunda bulunuyor.",
      list: 'B2',
      answer: 'koyun, silahlar',
      quest: 'arms'),
  Words(
      front: "Artificial intelligence is rapidly changing the world around us.",
      back: "Yapay zeka, çevremizdeki dünyayı hızla değiştiriyor.",
      list: 'B2',
      answer: 'yapay',
      quest: 'Artificial'),
  Words(
      front: "He felt ashamed of his behavior and apologized to his friends.",
      back: "Davranışından dolayı mahcup oldu ve arkadaşlarından özür diledi.",
      list: 'B2',
      answer: 'mahcup',
      quest: 'ashamed'),
  Words(
      front:
          "Let's consider all the different aspects of this issue before making a decision.",
      back: "Karar vermeden önce bu konunun tüm farklı yönlerini ele alalım.",
      list: 'B2',
      answer: 'hal',
      quest: 'aspect'),
  Words(
      front:
          "The teacher assessed the students' understanding of the material.",
      back: "Öğretmen, öğrencilerin konuyu anlama düzeyini değerlendirdi.",
      list: 'B2',
      answer: 'değer biçmek',
      quest: 'assess'),
  Words(
      front:
          "We need a thorough assessment of the situation before we can proceed.",
      back:
          "Devam edebilmemiz için öncelikle durumun kapsamlı bir değerlendirmesine ihtiyacımız var.",
      list: 'B2',
      answer: 'değerlendirme',
      quest: 'assessment'),
  Words(
      front: "People often associate red with love and danger.",
      back: "İnsanlar genellikle kırmızıyı aşk ve tehlike ile ilişkilendirir.",
      list: 'B2',
      answer: 'ilişkilendirmek',
      quest: 'associate'),
  Words(
      front: "Certain colors are associated with specific emotions.",
      back: "Belirli renkler belirli duygularla ilişkilendirilir.",
      list: 'B2',
      answer: 'bağlantılı',
      quest: 'associated'),
  Words(
      front: "He is a member of a local environmental association.",
      back: "Yerel bir çevre koruma derneği üyesidir.",
      list: 'B2',
      answer: 'birlik',
      quest: 'association'),
  Words(
      front: "I can't assume that everyone knows how to use this software.",
      back: "Herkesin bu yazılımı nasıl kullanacağını bildiğini varsayamam.",
      list: 'B2',
      answer: 'üstlenmek',
      quest: 'assume'),
  Words(
      front:
          "He made several attempts to climb the mountain, but failed each time.",
      back:
          "Dağa tırmanmak için birkaç girişimde bulundu, ancak her seferinde başarısız oldu.",
      list: 'B2',
      answer: 'teşebbüs etmek',
      quest: 'attempt'),
  Words(
      front: "Please come sit at the back of the class.",
      back: "Lütfen sınıfın arkasına oturmaya gel.",
      list: 'B2',
      answer: 'sırt',
      quest: 'back'),
  Words(
      front: "Antibiotics are used to kill bacteria that cause infections.",
      back:
          "Antibiyotikler, enfeksiyona neden olan bakterileri öldürmek için kullanılır.",
      list: 'B2',
      answer: 'bakteri',
      quest: 'bacteria'),
  Words(
      front: "He leaned against the bar and ordered a drink.",
      back: "Bara yaslandı ve bir içki sipariş etti.",
      list: 'B2',
      answer: 'çubuk',
      quest: 'bar'),
  Words(
      front: "The language barrier made it difficult for them to communicate.",
      back: "Dil bariyeri iletişim kurmalarını zorlaştırdı.",
      list: 'B2',
      answer: 'bariyer',
      quest: 'barrier'),
  Words(
      front: "Basically, you just need to add these two ingredients together.",
      back: "Temelde, bu iki malzemeyi bir araya getirmeniz yeterlidir.",
      list: 'B2',
      answer: 'temelde',
      quest: 'basically'),
  Words(
      front:
          "The two armies clashed in a fierce battle for control of the territory.",
      back:
          "İki ordu, bölgenin kontrolü için şiddetli bir savaşta karşı karşıya geldi.",
      list: 'B2',
      answer: 'savaş',
      quest: 'battle'),
  Words(
      front: "I can't bear to see her suffer like this.",
      back: "Onun böyle acı çekmesine dayanamıyorum.",
      list: 'B2',
      answer: 'dayanmak',
      quest: 'bear'),
  Words(
      front: "The music was so loud that it made my heart beat faster.",
      back:
          "Müzik o kadar yüksekti ki kalbimin daha hızlı atmasına neden oldu.",
      list: 'B2',
      answer: 'vurmak',
      quest: 'beat'),
  Words(
      front: "He was begging for money on the street corner.",
      back: "Sokak köşesinde para dileniyordu.",
      list: 'B2',
      answer: 'dilenmek',
      quest: 'beg'),
  Words(
      front: "Her being there made all the difference.",
      back: "Onun orada olması her şeyi değiştirdi.",
      list: 'B2',
      answer: 'yapı',
      quest: 'being'),
  Words(
      front: "The metal rod was bent out of shape after the accident.",
      back: "Metal çubuk, kaza sonrası eğrilmişti.",
      list: 'B2',
      answer: 'bükülmüş',
      quest: 'bent'),
  Words(
      front: "I'm willing to bet that he will be late again.",
      back: "Tekrar geç kalacağına bahse varım.",
      list: 'B2',
      answer: 'iddia',
      quest: 'bet'),
  Words(
      front: "There is a whole world beyond what we can see with our eyes.",
      back:
          "Gözlerimizle göremediğimiz şeylerin ötesinde kocaman bir dünya var.",
      list: 'B2',
      answer: 'öte',
      quest: 'beyond'),
  Words(
      front: "Please pay your bill by the end of the month.",
      back: "Lütfen faturanızı ay sonuna kadar ödeyin.",
      list: 'B2',
      answer: 'fatura',
      quest: 'bill'),
  Words(
      front:
          "My boss always tries to blame other people whenever he makes a mistake.",
      back:
          "Patronum ne zaman bir hata yapsa hep başkalarını suçlamaya çalışır.",
      list: 'B2',
      answer: 'suçlamak',
      quest: 'blame'),
  Words(
      front: "The man was blind and could not see anything.",
      back: "Adam kördü ve hiçbir şey göremezdi.",
      list: 'B2',
      answer: 'kör',
      quest: 'blind'),
  Words(
      front:
          "The strong bond between the two friends helped them through difficult times.",
      back:
          "İki arkadaş arasındaki güçlü bağ, zor zamanlarda onlara yardım etti.",
      list: 'B2',
      answer: 'tutturmak',
      quest: 'bond'),
  Words(
      front: "The country has a long border with Mexico.",
      back: "Ülkenin Meksika ile uzun bir sınırı var.",
      list: 'B2',
      answer: 'kenarlık',
      quest: 'border'),
  Words(
      front: "It is important to perform a self-breast examination regularly.",
      back: "Düzenli olarak kendi kendine meme muayenesi yapmak önemlidir.",
      list: 'B2',
      answer: 'meme',
      quest: 'breast'),
  Words(
      front: "The manager gave us a brief overview of the new project.",
      back: "Yönetici bize yeni proje hakkında kısa bir brifing verdi.",
      list: 'B2',
      answer: 'kısa, talimat',
      quest: 'brief'),
  Words(
      front: "He has a broad range of knowledge on a variety of topics.",
      back: "Çok çeşitli konularda geniş bir bilgi birikimine sahiptir.",
      list: 'B2',
      answer: 'geniş',
      quest: 'broad'),
  Words(
      front: "The news will be broadcasted live at 8 pm.",
      back: "Haberler saat 8'de canlı olarak yayınlanacak.",
      list: 'B2',
      answer: 'yayın',
      quest: 'broadcast'),
  Words(
      front: "We need to create a budget for the upcoming holiday season.",
      back: " yaklaşan tatil sezonu için bir bütçe oluşturmamız gerekiyor.",
      list: 'B2',
      answer: 'bütçe',
      quest: 'budget'),
  Words(
      front: "The soldier dodged the bullet as it whizzed past his head.",
      back: "Asker, vızıldayarak başının üzerinden geçen mermiyi atlattı.",
      list: 'B2',
      answer: 'mermi',
      quest: 'bullet'),
  Words(
      front: "He bought a bunch of flowers for his wife.",
      back: "Karısına bir demet çiçek aldı.",
      list: 'B2',
      answer: 'salkım, demet',
      quest: 'bunch'),
  Words(
      front: "Be careful not to burn yourself on the hot stove.",
      back: "Sıcak sobada kendinizi yakmamaya dikkat edin.",
      list: 'B2',
      answer: 'yakmak',
      quest: 'burn'),
  Words(
      front: "The hikers got lost in the dense bushes.",
      back: "Yürüyüşçüler sık çalılarda kayboldu.",
      list: 'B2',
      answer: 'çalı',
      quest: 'bush'),
  Words(
      front: "I want to go swimming, but the water is too cold.",
      back: "Yüzmeye gitmek istiyorum, ama su çok soğuk.",
      list: 'B2',
      answer: 'ancak',
      quest: 'but'),
  Words(
      front: "Be careful not to trip over the electrical cable.",
      back: "Elektrik kablosuna takılmamaya dikkat edin.",
      list: 'B2',
      answer: 'kablo',
      quest: 'cable'),
  Words(
      front: "The scientist was able to calculate the distance to the moon.",
      back: "Bilim insanı, aya olan mesafeyi hesaplayabildi.",
      list: 'B2',
      answer: 'hesaplamak',
      quest: 'calculate'),
  Words(
      front: "I'm afraid I have to cancel our meeting today.",
      back: "Ne yazık ki bugünkü görüşmemizi iptal etmek zorundayım.",
      list: 'B2',
      answer: 'iptal etmek',
      quest: 'cancel'),
  Words(
      front:
          "Cancer is a serious disease that can affect any part of the body.",
      back:
          "Kanser, vücudun herhangi bir yerini etkileyebilen ciddi bir hastalıktır.",
      list: 'B2',
      answer: 'kanser',
      quest: 'Cancer'),
  Words(
      front: "He is a very capable student and excels in all his subjects.",
      back: "Çok yetenekli bir öğrencidir ve tüm derslerinde başarılıdır.",
      list: 'B2',
      answer: 'yetenekli',
      quest: 'capable'),
  Words(
      front:
          "The battery has a limited capacity and needs to be recharged regularly.",
      back:
          "Pilin sınırlı bir kapasitesi vardır ve düzenli olarak şarj edilmesi gerekir.",
      list: 'B2',
      answer: 'kapasite',
      quest: 'capacity'),
  Words(
      front: "The police are trying to capture the escaped convict.",
      back: "Polis, kaçan hükümlüyü yakalamaya çalışıyor.",
      list: 'B2',
      answer: 'ele geçirmek',
      quest: 'capture'),
  Words(
      front: "He cast a magic spell that made him invisible.",
      back: "Onu görünmez yapan sihirli bir büyü yaptı.",
      list: 'B2',
      answer: 'dökmek',
      quest: 'cast'),
  Words(
      front:
          "The baseball player tried to catch the ball, but it went over his head.",
      back:
          "Beyzbol oyuncusu topu yakalamaya çalıştı ama topun üzerinden geçti.",
      list: 'B2',
      answer: 'yakalamak',
      quest: 'catch'),
  Words(
      front: "Cancer cells can spread to other parts of the body.",
      back: "Kanser hücreleri vücudun diğer bölgelerine yayılabilir.",
      list: 'B2',
      answer: 'hücre',
      quest: 'cell'),
  Words(
      front: "I need a new chain for my bicycle.",
      back: "Bisikletim için yeni bir zincir gerekiyor.",
      list: 'B2',
      answer: 'zincir',
      quest: 'chain'),
  Words(
      front: "Please pull up a chair and have a seat.",
      back: "Lütfen bir sandalye çekin ve oturun.",
      list: 'B2',
      answer: 'sandalye',
      quest: 'chair'),
  Words(
      front: "The chairman of the board led the meeting.",
      back: "Yönetim kurulu başkanı toplantıya başkanlık etti.",
      list: 'B2',
      answer: 'başkan',
      quest: 'chairman'),
  Words(
      front: "He decided to challenge himself and run a marathon.",
      back: "Kendisine meydan okumaya ve maraton koşmaya karar verdi.",
      list: 'B2',
      answer: 'meydan okumak',
      quest: 'challenge'),
  Words(
      front: "The doctor used a chart to explain the patient's progress.",
      back:
          "Doktor, hastanın iyileşme sürecini açıklamak için bir çizelge kullandı.",
      list: 'B2',
      answer: 'çizelge',
      quest: 'chart'),
  Words(
      front: "Our chief concern at the moment is cutting costs",
      back: "Şu anda en büyük endişemiz maliyetleri düşürmek.",
      list: 'B2',
      answer: 'başlıca,şef',
      quest: 'chief'),
  Words(
      front:
          "We need to consider all the circumstances before making a decision.",
      back: "Karar vermeden önce tüm durumları değerlendirmemiz gerekiyor.",
      list: 'B2',
      answer: 'durum',
      quest: 'circumstance'),
  Words(
      front: "The author cited several scientific studies in his book.",
      back: "Yazar, kitabında birkaç bilimsel çalışmaya atıfta bulundu.",
      list: 'B2',
      answer: 'bahsetmek',
      quest: 'cite'),
  Words(
      front: "Every citizen has the right to vote in elections.",
      back: "Her vatandaşın seçimlerde oy kullanma hakkı vardır.",
      list: 'B2',
      answer: 'vatandaş',
      quest: 'citizen'),
  Words(
      front: "The war caused a lot of civilian casualties.",
      back: "Savaş, birçok sivil kayıpa neden oldu.",
      list: 'B2',
      answer: 'sivil',
      quest: 'civil'),
  Words(
      front: "He is a big fan of classic rock music.",
      back: "Klasik rock müziğinin büyük hayranıdır.",
      list: 'B2',
      answer: 'medeniyet',
      quest: 'classic'),
  Words(
      front: "Please close the door behind you when you leave.",
      back: "Çıkarken lütfen arkanızdaki kapıyı kapatın.",
      list: 'B2',
      answer: 'kapatmak',
      quest: 'close'),
  Words(
      front: "We need to work more closely together to achieve our goals.",
      back: "Hedeflerimize ulaşmak için daha yakın çalışmamız gerekiyor.",
      list: 'B2',
      answer: 'yakından',
      quest: 'closely'),
  Words(
      front: "The building collapsed after the earthquake.",
      back: "Bina depremden sonra yıkıldı.",
      list: 'B2',
      answer: 'yığılmak',
      quest: 'collapse'),
  Words(
      front: "The lock requires a specific combination of numbers to open.",
      back: "Kilidin açılması için belirli bir sayı kombinasyonu gerekir.",
      list: 'B2',
      answer: 'kombinasyon',
      quest: 'combination'),
  Words(
      front: "He took a long bath to relax and find comfort.",
      back: "Rahatlamak ve rahatlık bulmak için uzun bir banyo yaptı.",
      list: 'B2',
      answer: 'rahatlık, konfor',
      quest: 'comfort'),
  Words(
      front: "The officer commanded his troops to advance.",
      back: "Subay askerlerine ilerlemelerini emretti.",
      list: 'B2',
      answer: 'emretmek',
      quest: 'command'),
  Words(
      front: "The artist received a commission to paint a portrait.",
      back: "Sanatçı, bir portre resimleme komisyonu aldı.",
      list: 'B2',
      answer: 'komisyon',
      quest: 'commission'),
  Words(
      front: "A strong work ethic and commitment are essential for success.",
      back: "Başarı için güçlü bir çalışma ahlakı ve bağlılık esastır.",
      list: 'B2',
      answer: 'bağlılık',
      quest: 'commitment'),
  Words(
      front: "The committee is responsible for reviewing new legislation.",
      back: "Komite, yeni yasaları incelemekten sorumludur.",
      list: 'B2',
      answer: 'kurul',
      quest: 'committee'),
  Words(
      front: "Water is commonly found on Earth.",
      back: "Su, Dünya'da yaygın olarak bulunur.",
      list: 'B2',
      answer: 'ortak olarak',
      quest: 'commonly'),
  Words(
      front: "The human body is a complex system of organs and tissues.",
      back: "İnsan vücudu karmaşık bir organ ve doku sistemidir.",
      list: 'B2',
      answer: 'karışık',
      quest: 'complex'),
  Words(
      front:
          "The instructions for assembling the furniture were very complicated.",
      back: "Mobilya montaj talimatları çok karmaşıktı.",
      list: 'B2',
      answer: 'komplike',
      quest: 'complicated'),
  Words(
      front: "Air is a mixture of different gases and components.",
      back: "Hava, farklı gazların ve bileşenlerin bir karışımıdır.",
      list: 'B2',
      answer: 'bileşen',
      quest: 'component'),
  Words(
      front:
          "He needed to improve his concentration in order to focus on his studies.",
      back:
          "Derslerine odaklanabilmek için konsantrasyonunu geliştirmesi gerekiyordu.",
      list: 'B2',
      answer: 'yığma',
      quest: 'concentration'),
  Words(
      front:
          "The concept of gravity is difficult to understand for young children.",
      back: "Küçük çocuklar için yerçekimi kavramı anlaşılması zordur.",
      list: 'B2',
      answer: 'konsept',
      quest: 'concept'),
  Words(
      front: "I am concerned about her health.",
      back: "Onun sağlığı beni ilgilendiriyor.",
      list: 'B2',
      answer: 'ilgilendirmek',
      quest: 'concern'),
  Words(
      front: "Are you concerned about the upcoming exam?",
      back: "Yaklaşan sınav hakkında endişeleniyor musun?",
      list: 'B2',
      answer: 'ilgili',
      quest: 'concerned'),
  Words(
      front: "The teacher will conduct the experiment in front of the class.",
      back: "Öğretmen, deneyi sınıfın önünde yürütecek.",
      list: 'B2',
      answer: 'yönetmek',
      quest: 'conduct'),
  Words(
      front: "I spoke with confidence during my presentation.",
      back: "Sunumum sırasında güvenle konuştum.",
      list: 'B2',
      answer: 'güven',
      quest: 'confidence'),
  Words(
      front: "There is a conflict between the two countries.",
      back: "İki ülke arasında bir çatışma var.",
      list: 'B2',
      answer: 'çekişmek',
      quest: 'conflict'),
  Words(
      front: "The instructions for the game were very confusing.",
      back: "Oyunun talimatları çok kafa karıştırıcıydı.",
      list: 'B2',
      answer: 'şaşırtma',
      quest: 'confusing'),
  Words(
      front: "He is still conscious after the accident.",
      back: "Kazadan sonra hala bilinçli.",
      list: 'B2',
      answer: 'bilinçli',
      quest: 'conscious'),
  Words(
      front:
          "She is a conservative politician who believes in traditional values.",
      back: "Geleneksel değerlere inanan muhafazakar bir politikacıdır.",
      list: 'B2',
      answer: 'muhafazakar',
      quest: 'conservative'),
  Words(
      front:
          "We need to take your age into consideration when choosing an activity.",
      back:
          "Bir etkinlik seçerken yaşınızı göz önünde bulundurmamız gerekiyor.",
      list: 'B2',
      answer: 'düşünce',
      quest: 'consideration'),
  Words(
      front:
          "He is a consistent performer and always delivers high-quality work.",
      back:
          "Tutarlı bir performans sergiler ve her zaman yüksek kaliteli işler sunar.",
      list: 'B2',
      answer: 'istikrarlı',
      quest: 'consistent'),
  Words(
      front: "The Earth's temperature is constantly changing.",
      back: "Dünya'nın sıcaklığı sürekli değişiyor.",
      list: 'B2',
      answer: 'sabit',
      quest: 'constant'),
  Words(
      front: "He is constantly checking his phone for messages.",
      back: "Mesajları olup olmadığını sürekli telefonunu kontrol ediyor.",
      list: 'B2',
      answer: 'ikide bir',
      quest: 'constantly'),
  Words(
      front: "We need to construct a solid foundation for the building.",
      back: "Sağlam bir bina için sağlam bir temel inşa etmemiz gerekiyor.",
      list: 'B2',
      answer: 'inşa etmek',
      quest: 'construct'),
  Words(
      front:
          "The construction of the new bridge is expected to take two years.",
      back: "Yeni köprünün yapımı iki yıl sürmesi bekleniyor.",
      list: 'B2',
      answer: 'yapı',
      quest: 'construction'),
  Words(
      front: "The artist's work reflects contemporary social issues.",
      back: "Sanatçının eseri, çağdaş sosyal sorunları yansıtıyor.",
      list: 'B2',
      answer: 'modern',
      quest: 'contemporary'),
  Words(
      front: "She participated in a singing contest to showcase her talent.",
      back: "Yeteneğini sergilemek için bir şarkı yarışmasına katıldı.",
      list: 'B2',
      answer: 'yarışma',
      quest: 'contest'),
  Words(
      front: "He carefully reviewed the contract before signing it.",
      back: "Sözleşmeyi imzalamadan önce dikkatlice inceledi.",
      list: 'B2',
      answer: 'sözleşme',
      quest: 'contract'),
  Words(
      front:
          "Her research has contributed significantly to the field of medicine.",
      back: "Araştırmaları tıp alanına önemli ölçüde katkıda bulundu.",
      list: 'B2',
      answer: 'katkı yapmak',
      quest: 'contribute'),
  Words(
      front: "His positive attitude is a valuable contribution to the team.",
      back: "Pozitif tavrı, ekibe değerli bir katkıdır.",
      list: 'B2',
      answer: 'katkı',
      quest: 'contribution'),
  Words(
      front: "He was able to convert the old file format into a new one.",
      back: "Eski dosya formatını yenisine dönüştürebildi.",
      list: 'B2',
      answer: 'dönüştürmek',
      quest: 'convert'),
  Words(
      front:
          "After seeing the evidence, he was finally convinced of her innocence.",
      back: "Kanıtı gördükten sonra, sonunda onun masumiyetine ikna oldu.",
      list: 'B2',
      answer: 'inandırılan',
      quest: 'convinced'),
  Words(
      front: "The core of the building is made of steel and concrete.",
      back: "Binanın çekirdeği çelik ve betondan yapılmıştır.",
      list: 'B2',
      answer: 'çekirdek',
      quest:
          'core'), // Here, 'core' might be a better translation for 'çekirdek'
  Words(
      front: "He climbed the corporate ladder and became a successful CEO.",
      back: "Kurumsal basamaklarda yükseldi ve başarılı bir CEO oldu.",
      list: 'B2',
      answer: 'kurumsal',
      quest: 'corporate'),
  Words(
      front:
          "The city council is responsible for making decisions about local issues.",
      back:
          "Şehir meclisi, yerel sorunlarla ilgili karar vermekten sorumludur.",
      list: 'B2',
      answer: 'meclis',
      quest: 'council'),
  Words(
      front: "We live in a small county in the northern part of the country.",
      back: "Ülkenin kuzey kesiminde bulunan küçük bir ilçede yaşıyoruz.",
      list: 'B2',
      answer: 'ilçe',
      quest: 'county'),
  Words(
      front:
          "It took a lot of courage for her to stand up for what she believed in.",
      back: "İnandığı şeyleri savunmak için çok cesaret gerekiyordu.",
      list: 'B2',
      answer: 'cesurluk',
      quest: 'courage'),
  Words(
      front: "The car crashed into a tree after losing control.",
      back: "Araba kontrolden çıktıktan sonra ağaca çarptı.",
      list: 'B2',
      answer: 'çarpmak',
      quest: 'crash'),
  Words(
      front: "The artist is known for her unique and creative creations.",
      back: "Sanatçı, eşsiz ve yaratıcı kreasyonlarıyla tanınır.",
      list: 'B2',
      answer: 'kreasyon',
      quest: 'creation'),
  Words(
      front: "Mythology is full of stories about fantastical creatures.",
      back: "Mitoloji, fantastik yaratıklar hakkındaki hikayelerle doludur.",
      list: 'B2',
      answer: 'varlık',
      quest: 'creature'),
  Words(
      front: "He applied for a loan at the bank to get some credit.",
      back: "Bankadan biraz kredi almak için kredi başvurusunda bulundu.",
      list: 'B2',
      answer: 'kredi',
      quest: 'credit'),
  Words(
      front:
          "The airplane crew consisted of the pilot, copilot, and flight attendants.",
      back:
          "Uçak ekibi pilot, yardımcı pilot ve kabin memurlarından oluşuyordu.",
      list: 'B2',
      answer: 'tayfa',
      quest: 'crew'),
  Words(
      front: "The country is facing a major economic crisis.",
      back: "Ülke, büyük bir ekonomik krizle karşı karşıyadır.",
      list: 'B2',
      answer: 'bunalım',
      quest: 'crisis'),
  Words(
      front: "We have a simple criterion for assessing the models.",
      back: "Modelleri değerlendirmek için basit bir kriterimiz var.",
      list: 'B2',
      answer: 'kriter',
      quest: 'criterion'),
  Words(
      front: "The movie critic gave the film a negative review.",
      back: "Film eleştirmeni filme olumsuz bir eleştiri yaptı.",
      list: 'B2',
      answer: 'kritik',
      quest: 'critic'),
  Words(
      front: "Her constant criticism made him feel discouraged.",
      back: "Sürekli eleştirisi moralini bozdu.",
      list: 'B2',
      answer: 'eleştiri',
      quest: 'criticism'),
  Words(
      front: "It is not polite to criticize someone's appearance.",
      back: "Birinin görünüşünü eleştirmek kibarca bir davranış değildir.",
      list: 'B2',
      answer: 'eleştirmek',
      quest: 'criticize'),
  Words(
      front: "The farmer's crops were destroyed by the hail storm.",
      back: "Çiftçinin mahsulü dolu felaketiyle yok oldu.",
      list: 'B2',
      answer: 'mahsul',
      quest: 'crop'),
  Words(
      front: "Making a good first impression is crucial for a job interview.",
      back: "İyi bir ilk izlenim bırakmak, iş görüşmesi için çok önemlidir.",
      list: 'B2',
      answer: 'çok önemli',
      quest: 'crucial'),
  Words(
      front: "The baby started crying after he fell down.",
      back: "Düştükten sonra bebek ağlamaya başladı.",
      list: 'B2',
      answer: 'ağlamak',
      quest: 'cry'),
  Words(
      front:
          "There is no cure for the common cold, but symptoms usually improve within a week.",
      back:
          "Soğuk algınlığı için bir tedavi yoktur, ancak semptomlar genellikle bir hafta içinde düzelir.",
      list: 'B2',
      answer: 'iyileştirmek',
      quest: 'cure'),
  Words(
      front: "The electric current can be dangerous if not handled properly.",
      back: "Elektrik akımı doğru kullanılmazsa tehlikeli olabilir.",
      list: 'B2',
      answer: 'akım',
      quest: 'current'),
  Words(
      front: "The road takes a sharp curve to the left.",
      back: "Yol sola doğru keskin bir viraj alıyor.",
      list: 'B2',
      answer: 'bükülmek',
      quest: 'curve'),
  Words(
      front: "The building has a curved roof design.",
      back: "Binanın kavisli bir çatı tasarımı vardır.",
      list: 'B2',
      answer: 'eğimli',
      quest: 'curved'),
  Words(
      front: "He asked her out on a date for this weekend.",
      back: "Onu bu hafta sonu için randevuya davet etti.",
      list: 'B2',
      answer: 'randevuya çıkmak',
      quest: 'date'),
  Words(
      front: "There was a heated debate about the new government policy.",
      back: "Yeni hükümet politikası hakkında hararetli bir tartışma yaşandı.",
      list: 'B2',
      answer: 'debate',
      quest: 'debate'),
  Words(
      front: "He is struggling to pay off his student debt.",
      back: "Öğrenci borcunu ödemekte zorlanıyor.",
      list: 'B2',
      answer: 'borç',
      quest: 'debt'),
  Words(
      front:
          "He is a decent and kind person who is always willing to help others.",
      back:
          "Yardımsever ve her zaman başkalarına yardım etmeye istekli olan düzgün bir insandır.",
      list: 'B2',
      answer: 'edepli',
      quest: 'decent'),
  Words(
      front:
          "The president declared a state of emergency after the natural disaster.",
      back: "Devlet başkanı, doğal afetten sonra olağanüstü hal ilan etti.",
      list: 'B2',
      answer: 'beyan etmek',
      quest: 'declare'),
  Words(
      front: "She politely declined the offer because she was already busy.",
      back: "Zaten meşgul olduğu için teklifi nazikçe reddetti.",
      list: 'B2',
      answer: 'geri çevirmek', // 'zayıflamak' means 'to weaken'
      quest: 'decline'),
  Words(
      front: "The room was filled with beautiful decorations for the party.",
      back: "Oda, parti için güzel süslemelerle doluydu.",
      list: 'B2',
      answer: 'süsleme',
      quest: 'decoration'),
  Words(
      front:
          "The number of COVID-19 cases has been decrease/ing in recent weeks.",
      back: "Son haftalarda COVID-19 vakalarının sayısı azalıyor.",
      list: 'B2',
      answer: 'küçülmek',
      quest: 'decrease'),
  Words(
      front: "He was deeply affected by the news of his friend's death.",
      back: "Arkadaşının ölümü haberinden derinden etkilenmişti.",
      list: 'B2',
      answer: 'son derece',
      quest: 'deeply'),
  Words(
      front:
          "The smaller team unexpectedly defeated the favorites in the championship game.",
      back:
          "Daha küçük takım, şampiyonluk maçında favorileri beklenmedik şekilde yendi.",
      list: 'B2',
      answer: 'yenmek',
      quest: 'defeat'),
  Words(
      front: "The lawyer presented a strong defence for his client in court.",
      back: "Avukat, mahkemede müvekkili için güçlü bir savunma sundu.",
      list: 'B2',
      answer: 'savunma',
      quest: 'defence'),
  Words(
      front: "He bravely defended his country during wartime.",
      back: "Savaş sırasında ülkesini cesurca savundu.",
      list: 'B2',
      answer: 'savunmak',
      quest: 'defend'),
  Words(
      front: "The meeting was delayed due to unforeseen circumstances.",
      back: "Toplantı öngörülemeyen durumlar nedeniyle gecikmiştir.",
      list: 'B2',
      answer: 'gecikmek',
      quest: 'delay'),
  Words(
      front:
          "The accident was not a deliberate act, it was a complete accident.",
      back: "Kaza kasti bir hareket değildi, tamamen bir kazaydı.",
      list: 'B2',
      answer: 'kasti',
      quest: 'deliberate'),
  Words(
      front: "He deliberately avoided talking about the sensitive topic.",
      back: "Hassas konudan bahsetmekten kasıtlı olarak kaçındı.",
      list: 'B2',
      answer: 'kasten',
      quest: 'deliberately'),
  Words(
      front:
          "The children were filled with delight when they saw the presents.",
      back: "Hediyeleri görünce çocuklar hazla doldu.",
      list: 'B2',
      answer: 'haz',
      quest: 'delight'),
  Words(
      front: "She was delighted to hear that she got the job.",
      back: "İşi aldığını duyduğuna çok sevindi.",
      list: 'B2',
      answer: 'memnun',
      quest: 'delighted'),
  Words(
      front: "The pizza delivery arrived hot and fresh.",
      back: "Pizza teslimatı sıcak ve taze olarak geldi.",
      list: 'B2',
      answer: 'teslim',
      quest: 'delivery'),
  Words(
      front:
          "The workers demanded better working conditions from their employer.",
      back: "İşçiler işverenlerinden daha iyi çalışma koşulları talep ettiler.",
      list: 'B2',
      answer: 'talep etmek',
      quest: 'demand'),
  Words(
      front:
          "The scientist was able to demonstrate the theory through a series of experiments.",
      back: "Bilim insanı, teoriyi bir dizi deneyle kanıtlayabildi.",
      list: 'B2',
      answer: 'ispat etmek',
      quest: 'demonstrate'),
  Words(
      front: "He deny/ied all the accusations against him.",
      back: "Yöneltilen tüm suçlamaları reddetti.",
      list: 'B2',
      answer: 'yalanlamak',
      quest: 'deny'),
  Words(
      front: "She seemed depressed after losing her job.",
      back: "İşini kaybettikten sonra moralı bozuk görünüyordu.",
      list: 'B2',
      answer: 'canı sıkkın',
      quest: 'depressed'),
  Words(
      front: "The weather was gloomy and depressing all week.",
      back: "Hafta boyunca hava kasvetli ve bunaltıcıydı.",
      list: 'B2',
      answer: 'bunaltıcı',
      quest: 'depressing'),
  Words(
      front:
          "The scientist was studying the ocean's depth to learn more about marine life.",
      back:
          "Bilim insanı, deniz yaşamı hakkında daha fazla bilgi edinmek için okyanusun derinliğini araştırıyordu.",
      list: 'B2',
      answer: 'derinlik',
      quest: 'depth'),
  Words(
      front:
          "After weeks of searching, the lost hikers were finally found alive in the desert.",
      back:
          "Haftalarca süren aramadan sonra kayıp gezginler sonunda çölde sağ olarak bulundu.",
      list: 'B2',
      answer: 'terk etmek', // 'çöl' means 'desert'
      quest: 'desert'),
  Words(
      front: "He worked hard and deserves to be successful.",
      back: "Çok çalıştı ve başarılı olmayı hak ediyor.",
      list: 'B2',
      answer: 'hak etmek',
      quest: 'deserve'),
  Words(
      front: "She has a strong desire to travel the world.",
      back: "Dünyayı gezme arzusu var.",
      list: 'B2',
      answer: 'arzulamak',
      quest: 'desire'),
  Words(
      front: "The lost child was crying out of desperate-ion.",
      back: "Kayıp çocuk çaresizlikten ağlıyordu.",
      list: 'B2',
      answer: 'çaresiz',
      quest: 'desperate'),
  Words(
      front: "He paid close attention to every detail when fixing the watch.",
      back: "Saati tamir ederken her detaya dikkat etti.",
      list: 'B2',
      answer: 'detay',
      quest: 'detail'),
  Words(
      front: "The teacher provided a detailed explanation of the concept.",
      back: "Öğretmen, kavram hakkında ayrıntılı bir açıklama yaptı.",
      list: 'B2',
      answer: 'ayrıntılı',
      quest: 'detailed'),
  Words(
      front: "The smoke detector was able to detect the fire early on.",
      back: "Duman detektörü yangını erken aşamada algılayabildi.",
      list: 'B2',
      answer: 'keşfetmek',
      quest: 'detect'),
  Words(
      front: "He likes to dig in the garden.",
      back: "Bahçede kazmak hoşuna gider.",
      list: 'B2',
      answer: 'kazmak',
      quest: 'dig'),
  Words(
      front:
          "Self-discipline is an important quality for achieving your goals.",
      back: "Disiplin, hedeflerinize ulaşmak için önemli bir özelliktir.",
      list: 'B2',
      answer: 'disiplin',
      quest: 'discipline'),
  Words(
      front: "She got a discount on her purchase because it was on sale.",
      back: "İndirimde olduğu için satın aldığı üründe indirim aldı.",
      list: 'B2',
      answer: 'indirim',
      quest: 'discount'),
  Words(
      front:
          "He was caught cheating on the exam, so he received a failing grade for dishonesty.",
      back:
          "Sınavda kopya çekerken yakalandı, bu nedenle şerefsizlikten dolayı sınıfta kaldı.",
      list: 'B2',
      answer: 'şerefsiz',
      quest: 'dishonest'),
  Words(
      front: "The manager dismissed the employee for poor performance.",
      back: "Yönetici, performansı düşük olduğu için çalışanı işten çıkardı.",
      list: 'B2',
      answer: 'kovmak',
      quest: 'dismiss'),
  Words(
      front: "The artist displayed his paintings in a local gallery.",
      back: "Sanatçı, tablolarını yerel bir galeride sergiledi.",
      list: 'B2',
      answer: 'sergilemek',
      quest: 'display'),
  Words(
      front:
          "After the team won the prize, there was some disagreement over how to distribute the money.",
      back:
          "Ekip ödülü kazandıktan sonra, paranın nasıl dağıtılacağı konusunda bazı anlaşmazlıklar yaşandı.",
      list: 'B2',
      answer: 'dağıtmak',
      quest: 'distribute'),
  Words(
      front:
          "The effective distribution of resources is crucial for a successful project.",
      back:
          "Başarılı bir proje için kaynakların etkili bir şekilde dağıtılması çok önemlidir.",
      list: 'B2',
      answer: 'dağıtma',
      quest: 'distribution'),
  Words(
      front: "They live in a quiet district on the outskirts of the city.",
      back: "Şehrin dışında sakin bir semtte yaşıyorlar.",
      list: 'B2',
      answer: 'semt',
      quest: 'district'),
  Words(
      front: "The teacher divided the students into groups for the project.",
      back: "Öğretmen, öğrencileri proje için gruplara ayırdı.",
      list: 'B2',
      answer: 'bölmek', // 'dağıtmak' can also be used here
      quest: 'divide'),
  Words(
      front:
          "The marketing department is responsible for the product's division into different markets.",
      back:
          "Pazarlama departmanı, ürünün farklı pazarlara bölünmesinden sorumludur.",
      list: 'B2',
      answer: 'sınır',
      quest: 'division'),
  Words(
      front: "He has a pet cat, so it's a domestic animal.",
      back: "Evcil bir hayvan olan kedisi var.",
      list: 'B2',
      answer: 'evcil',
      quest: 'domestic'),
  Words(
      front: "The Roman Empire dominated a large part of Europe for centuries.",
      back:
          "Roma İmparatorluğu yüzyıllar boyunca Avrupa'nın büyük bir bölümüne hükmetti.",
      list: 'B2',
      answer: 'hükmetmek',
      quest: 'dominate'),
  Words(
      front: "The arrow flew downwards after it was shot from the bow.",
      back: "Ok, yaydan atıldıktan sonra aşağıya doğru uçtu.",
      list: 'B2',
      answer: 'aşağıya doğru',
      quest: 'downwards'),
  Words(
      front: "He bought a dozen eggs from the grocery store.",
      back: "Marketten bir düzine yumurta aldı.",
      list: 'B2',
      answer: 'çok sayıda', // 'düzine' means 'dozen'
      quest: 'dozen'),
  Words(
      front: "They are working on the final draft of the contract.",
      back: "Sözleşmenin son taslağı üzerinde çalışıyorlar.",
      list: 'B2',
      answer: 'tasarı',
      quest: 'draft'),
  Words(
      front: "He dragged the heavy suitcase across the floor.",
      back: "Ağır valizi yer boyunca sürükledi.",
      list: 'B2',
      answer: 'sürüklemek',
      quest: 'drag'),
  Words(
      front: "I need to edit this document before submitting it.",
      back: "Bu belgeyi göndermeden önce düzenlemem gerekiyor.",
      list: 'B2',
      answer: 'düzenlemek',
      quest: 'edit'),
  Words(
      front: "This is the latest edition of the English dictionary.",
      back: "Bu, İngilizce sözlüğün en son baskısıdır.",
      list: 'B2',
      answer: 'yayım',
      quest: 'edition'),
  Words(
      front:
          "She is a very efficient worker who always gets her tasks done quickly.",
      back:
          "Çok verimli bir çalışandır ve her zaman görevlerini hızlı bir şekilde tamamlar.",
      list: 'B2',
      answer: 'etkili',
      quest: 'efficient'),
  Words(
      front:
          "There are many programs available to help the elderly live independently.",
      back:
          "Yaşlıların bağımsız yaşam sürmelerine yardımcı olmak için birçok program mevcuttur.",
      list: 'B2',
      answer: 'yaşlı',
      quest: 'elderly'),
  Words(
      front: "The people will elect a new president next month.",
      back: "Halk önümüzdeki ay yeni bir cumhurbaşkanı seçecek.",
      list: 'B2',
      answer: 'seçmek',
      quest: 'elect'),
  Words(
      front:
          "I'm going to be elsewhere on Saturday, so I can't make it to the party.",
      back:
          "Cumartesi günü başka bir yerde olacağım, bu yüzden partiye gelemeyeceğim.",
      list: 'B2',
      answer: 'başka yerde',
      quest: 'elsewhere'),
  Words(
      front: "A new leader emerged after the old one retired.",
      back: "Eski lider emekli olduktan sonra yeni bir lider ortaya çıktı.",
      list: 'B2',
      answer: 'yücelmek',
      quest: 'emerge'),
  Words(
      front: "The movie was a very emotional story about love and loss.",
      back: "Film, aşk ve kayıp üzerine çok duygusal bir hikayeydi.",
      list: 'B2',
      answer: 'duygusal',
      quest: 'emotional'),
  Words(
      front: "He placed a strong emphasis on the importance of education.",
      back: "Eğitimin önemine büyük vurgu yaptı.",
      list: 'B2',
      answer: 'vurgu',
      quest: 'emphasis'),
  Words(
      front: "The teacher emphasized the key points of the lesson.",
      back: "Öğretmen, dersin kilit noktalarını vurguladı.",
      list: 'B2',
      answer: 'vurgulamak',
      quest: 'emphasize'),
  Words(
      front:
          "Technology has enabled us to connect with people all over the world.",
      back:
          "Teknoloji, dünyanın her yerinden insanlarla bağlantı kurmamızı sağladı.",
      list: 'B2',
      answer: 'olanak vermek',
      quest: 'enable'),
  Words(
      front: "They encountered many challenges during their journey.",
      back: "Yolculukları sırasında birçok zorlukla karşılaştılar.",
      list: 'B2',
      answer: 'rastlamak',
      quest: 'encounter'),
  Words(
      front: "The students were engaged in a lively discussion about the book.",
      back: "Öğrenciler kitap hakkında canlı bir tartışmaya girdiler.",
      list: 'B2',
      answer: 'bağlanmak',
      quest: 'engage'),
  Words(
      front:
          "The new technology has enhanced the efficiency of our production line.",
      back: "Yeni teknoloji, üretim hattımızın verimliliğini artırdı.",
      list: 'B2',
      answer: 'arttırmak',
      quest: 'enhance'),
  Words(
      front: "The police made further enquiryies about the crime.",
      back: "Polis, suç hakkında daha fazla sorgu yaptı.",
      list: 'B2',
      answer: 'sorgu',
      quest: 'enquiry'),
  Words(
      front: "We need to ensure that everyone receives the same information.",
      back: "Herkesin aynı bilgiyi aldığından emin olmamız gerekir.",
      list: 'B2',
      answer: 'sağlamak',
      quest: 'ensure'),
  Words(
      front: "The children were full of enthusiasm for the upcoming trip.",
      back: "Çocuklar yaklaşan gezi için hevesliydi.",
      list: 'B2',
      answer: 'heves',
      quest: 'enthusiasm'),
  Words(
      front: "The teacher gave an enthusiastic presentation about the topic.",
      back: "Öğretmen, konu hakkında coşkulu bir sunum yaptı.",
      list: 'B2',
      answer: 'coşkulu',
      quest: 'enthusiastic'),
  Words(
      front: "The entire team worked hard to complete the project on time.",
      back: "Tüm ekip, projeyi zamanında tamamlamak için çok çalıştı.",
      list: 'B2',
      answer: 'bütün',
      quest: 'entire'),
  Words(
      front: "The building was entirely destroyed by the fire.",
      back: "Bina yangın nedeniyle tamamen yok oldu.",
      list: 'B2',
      answer: 'tümüyle',
      quest: 'entirely'),
  Words(
      front: "All people are created equal and deserve equal rights.",
      back: "Tüm insanlar eşit yaratılmıştır ve eşit haklara sahiptir.",
      list: 'B2',
      answer: 'eşit',
      quest: 'equal'),
  Words(
      front:
          "The scientist was able to establish a link between the two phenomena.",
      back: "Bilim insanı, iki olay arasında bir bağlantı kurabildi.",
      list: 'B2',
      answer: 'kanıtlamak',
      quest: 'establish'),
  Words(
      front: "He inherited a large estate from his wealthy uncle.",
      back: "Zengin amcasından büyük bir emlak miras kaldı.",
      list: 'B2',
      answer: 'emlak',
      quest: 'estate'),
  Words(
      front: "The mechanic was able to estimate the cost of the repairs.",
      back: "Tamirci, onarım maliyetini tahmin edebildi.",
      list: 'B2',
      answer: 'tahmin etmek',
      quest: 'estimate'),
  Words(
      front: "It is important to act in an ethical manner in all situations.",
      back: "Her durumda etik davranmak önemlidir.",
      list: 'B2',
      answer: 'ahlaki',
      quest: 'ethical'),
  Words(
      front:
          "The teacher will evaluate the students' progress on the next exam.",
      back:
          "Öğretmen, öğrencilerin gelişimini bir sonraki sınavda değerlendirecek.",
      list: 'B2',
      answer: 'değerlendirmek',
      quest: 'evaluate'),
  Words(
      front: "The floor was not even, so it was difficult to walk on.",
      back: "Zemin düzgün değildi, bu nedenle yürümek zordu.",
      list: 'B2',
      answer: 'düzgün',
      quest: 'even'),
  Words(
      front: "The villain in the story represented pure evil.",
      back: "Hikayedeki kötü adam saf kötülüğü temsil ediyordu.",
      list: 'B2',
      answer: 'kötülük',
      quest: 'evil'),
  Words(
      front:
          "The doctor performed a thorough examination before making a diagnosis.",
      back: "Doktor, teşhis koymadan önce kapsamlı bir inceleme yaptı.",
      list: 'B2',
      answer: 'inceleme',
      quest: 'examination'),
  Words(
      front: "I don't need an excuse, I was simply late.",
      back: "Mazerete ihtiyacım yok, sadece geç kaldım.",
      list: 'B2',
      answer: 'mazeret',
      quest: 'excuse'),
  Words(
      front:
          "The company is looking for a new executive to lead the marketing department.",
      back:
          "Şirket, pazarlama departmanına liderlik edecek yeni bir yönetici arıyor.",
      list: 'B2',
      answer: 'yönetici',
      quest: 'executive'),
  Words(
      front: "The existence of life on other planets is still a mystery.",
      back: "Diğer gezegenlerde yaşamın varlığı hala bir gizemdir.",
      list: 'B2',
      answer: 'varlık',
      quest: 'existence'),
  Words(
      front: "We all have high expectations for the upcoming project.",
      back: "Hepimizin yaklaşan proje için yüksek beklentileri var.",
      list: 'B2',
      answer: 'beklenti',
      quest: 'expectation'),
  Words(
      front: "He traveled at the expense of the company.",
      back: "Şirketin harcamasıyla gezi yaptı.",
      list: 'B2',
      answer: 'harcama',
      quest: 'expense'),
  Words(
      front:
          "The exploration of space has been a human endeavor for centuries.",
      back: "Uzay keşfi, yüzyıllardır insanoğlunun bir çabası olmuştur.",
      list: 'B2',
      answer: 'keşif',
      quest: 'exploration'),
  Words(
      front: "Children are often exposed to too much screen time these days.",
      back: "Çocuklar günümüzde genellikle aşırı ekran süresine maruz kalıyor.",
      list: 'B2',
      answer: 'maruz bırakmak',
      quest: 'expose'),
  Words(
      front: "The company is planning to extend its operations to new markets.",
      back: "Şirket, faaliyetlerini yeni pazarlara genişletmeyi planlıyor.",
      list: 'B2',
      answer: 'genişletmek',
      quest: 'extend'),
  Words(
      front:
          "The full extent of the damage caused by the hurricane is still unknown.",
      back: "Kasırganın yol açtığı hasarın tam boyutu henüz bilinmiyor.",
      list: 'B2',
      answer: 'boyut',
      quest: 'extent'),
  Words(
      front: "He received external help to complete the difficult task.",
      back: "Zor görevi tamamlamak için dışarıdan yardım aldı.",
      list: 'B2',
      answer: 'dış',
      quest: 'external'),
  Words(
      front: "She has extraordinary abilities that no one else possesses.",
      back: "Kimsenin sahip olmadığı olağanüstü yetenekleri var.",
      list: 'B2',
      answer: 'olağanüstü',
      quest: 'extraordinary'),
  Words(
      front:
          "The weather conditions were extreme, with high winds and heavy rain.",
      back:
          "Hava koşulları aşırıydı, şiddetli rüzgar ve şiddetli yağmur vardı.",
      list: 'B2',
      answer: 'aşırı',
      quest: 'extreme'),
  Words(
      front:
          "The school has excellent facility-ies, including a library, a gym, and a swimming pool.",
      back:
          "Okulun kütüphane, spor salonu ve yüzme havuzu gibi mükemmel tesisleri vardır.",
      list: 'B2',
      answer: 'tesis',
      quest: 'facility'),
  Words(
      front: "His failure results from his carelessness.",
      back: "Başarısızlığı dikkatsizliğinden kaynaklanıyor.",
      list: 'B2',
      answer: 'başarısızlık,yapmama',
      quest: 'failure'),
  Words(
      front: "I have faith in your ability to succeed.",
      back: "Başarın yeteneğine güvenim var.",
      list: 'B2',
      answer: 'güven',
      quest: 'faith'),
  Words(
      front: "It was not my fault that the machine broke.",
      back:
          " makinenin bozulması benim hatam değildi.", // 'fayda' means 'benefit'
      list: 'B2',
      answer: 'hata',
      quest: 'fault'),
  Words(
      front: "Would you like me to do you a favour and help you with that?",
      back: "Size iyilik etmek ve size bunda yardım etmek ister misiniz?",
      list: 'B2',
      answer: 'iyilik etmek',
      quest: 'favour'),
  Words(
      front: "The bird used its feathers to build its nest.",
      back: "Kuş, yuvasını yapmak için tüylerini kullandı.",
      list: 'B2',
      answer: 'tüy',
      quest: 'feather'),
  Words(
      front: "How much is the fee for this course?",
      back: "Bu kursun ücreti ne kadar?",
      list: 'B2',
      answer: 'harç',
      quest: 'fee'),
  Words(
      front: "The cat is hungry, it needs to be feed.",
      back: " kedi aç, beslenmesi gerekiyor.",
      list: 'B2',
      answer: 'beslemek',
      quest: 'feed'),
  Words(
      front: "We appreciate your feedback on our new product.",
      back: "Yeni ürünümüz hakkındaki geri bildiriminizi appreciate ediyoruz.",
      list: 'B2',
      answer: 'geri bildirim',
      quest: 'feedback'),
  Words(
      front: "I can feel the sun on my skin.",
      back: "Güneşi tenimde hissedebiliyorum.",
      list: 'B2',
      answer: 'hissetmek',
      quest: 'feel'),
  Words(
      front: "He is a great fellow and a true friend.",
      back: "O harika bir arkadaş ve gerçek bir dost.",
      list: 'B2',
      answer: 'hemcins',
      quest: 'fellow'),
  Words(
      front: "The sales figures for this month are very promising.",
      back: "Bu ayın satış rakamları çok umut verici.",
      list: 'B2',
      answer: 'rakam, şekil', // ' şekil' can also mean 'shape' in this context
      quest: 'figure'),
  Words(
      front: "Please save the document as a new file.",
      back: "Lütfen belgeyi yeni bir dosya olarak kaydedin.",
      list: 'B2',
      answer: 'dosya',
      quest: 'file'),
  Words(
      front:
          "He borrowed from his brother to finance the loss he made on the project.",
      back: "Projede yaptığı kaybı finanse etmek için kardeşinden borç aldı.",
      list: 'B2',
      answer: 'finans',
      quest: 'finance'),
  Words(
      front:
          "We are still finding it difficult to find a solution to the problem.",
      back: "Probleme hala bir çözüm bulmakta zorlanıyoruz.",
      list: 'B2',
      answer: 'bulma',
      quest: 'finding'),
  Words(
      front: "He has a firm belief in his ability to succeed.",
      back:
          "Başaracağına dair sağlam bir inancı var.", // 'firm' can also mean ' sıkı' (tight)
      list: 'B2',
      answer: 'firma, sıkı',
      quest: 'firm'),
  Words(
      front: "The mechanic was able to fix the car engine.",
      back: "Tamirci, araba motorunu düzeltmeyi başardı.",
      list: 'B2',
      answer: 'düzeltmek',
      quest: 'fix'),
  Words(
      front: "We watched the flames of the fire burn.",
      back: "Ateşin alevlerinin yanışını izledik.",
      list: 'B2',
      answer: 'alev',
      quest: 'flame'),
  Words(
      front: "The photographer captured a flash of lightning in his photo.",
      back: "Fotoğrafçı, fotoğrafında bir şimşek flaşı yakaladı.",
      list: 'B2',
      answer: 'ışık tutmak',
      quest: 'flash'),
  Words(
      front:
          "Employers are looking for employees who are flexible and adaptable.",
      back: "İşverenler, esnek ve uyumlu çalışanlar arıyor.",
      list: 'B2',
      answer: 'esnek',
      quest: 'flexible'),
  Words(
      front:
          "I learned how to float on the surface of water in my swimming class today.",
      back: "Bugün yüzme dersimde suyun yüzeyinde nasıl yüzüleceğini öğrendim.",
      list: 'B2',
      answer: 'batmadan yüzmek',
      quest: 'float'),
  Words(
      front: "She carefully folded the piece of paper in half.",
      back: "Kâğıt parçasını dikkatlice ikiye katladı.",
      list: 'B2',
      answer: 'katlamak',
      quest: 'fold'),
  Words(
      front:
          "The art of origami involves creating complex shapes by folding paper.",
      back:
          "Origami sanatı, kağıdı katlayarak karmaşık şekiller oluşturmayı içerir.",
      list: 'B2',
      answer: 'kıvrım',
      quest: 'folding'),
  Words(
      front: "We are following the latest developments in technology closely.",
      back: "Teknolojideki son gelişmeleri yakından takip ediyoruz.",
      list: 'B2',
      answer: 'takip etme',
      quest: 'following'),
  Words(
      front: "I hope you can forgive me for my mistake.",
      back: "Umarım beni hatam için affedersin.",
      list: 'B2',
      answer: 'affetmek',
      quest: 'forgive'),
  Words(
      front: "He is a former athlete who is now a successful coach.",
      back: "O, şu anda başarılı bir antrenör olan eski bir atlet.",
      list: 'B2',
      answer: 'önceki',
      quest: 'former'),
  Words(
      front:
          "They hope that their hard work will lead to better fortune in the future.",
      back:
          "Gelecekte daha iyi bir talihinin zorlu çalışmalarının sonucunda olacağını umuyorlar.",
      list: 'B2',
      answer: 'talih',
      quest: 'fortune'),
  Words(
      front: "We need to look forward to the future and not dwell on the past.",
      back: "Geleceğe bakmalı ve geçmişte yaşamamalıyız.",
      list: 'B2',
      answer: 'ileri',
      quest: 'forward'),
  Words(
      front: "The company was founded in 1980 by two brothers.",
      back: "Şirket, 1980 yılında iki kardeş tarafından kuruldu.",
      list: 'B2',
      answer: 'kurmak',
      quest: 'found'),
  Words(
      front: "Education should be free and accessible to everyone.",
      back: "Eğitim herkes için ücretsiz ve erişilebilir olmalıdır.",
      list: 'B2',
      answer: 'bağımsız, beleş',
      quest: 'free'),
  Words(
      front: "Some people have to fight hard for their freedom.",
      back: "Bazı insanlar özgürlükleri için çok mücadele etmek zorundadır.",
      list: 'B2',
      answer: 'özgürlük',
      quest: 'freedom'),
  Words(
      front: "The frequency of the radio waves is too high for me to hear.",
      back: "Radyo dalgalarının frekansı duymam için çok yüksek.",
      list: 'B2',
      answer: 'sıklık',
      quest: 'frequency'),
  Words(
      front: "The car needs more fuel before it can continue the journey.",
      back:
          "Araba yolculuğa devam edebilmesi için daha fazla yakıta ihtiyacı var.",
      list: 'B2',
      answer: 'yakıt',
      quest: 'fuel'),
  Words(
      front: "He was fully committed to completing the task.",
      back: "Görevi tamamlamaya tamamen kararlıydı.",
      list: 'B2',
      answer: 'tamamıyla',
      quest: 'fully'),
  Words(
      front: "The function of this button is to turn on the device.",
      back: "Bu düğmenin işlevi cihazı açmaktır.",
      list: 'B2',
      answer: 'işlev',
      quest: 'function'),
  Words(
      front:
          "The government will provide funds to support the research project.",
      back:
          "Hükümet, araştırma projesini desteklemek için kaynak sağlayacaktır.",
      list: 'B2',
      answer: 'kaynak',
      quest: 'fund'),
  Words(
      front: "A strong work ethic is a fundamental principle for success.",
      back: "Güçlü bir çalışma etiği, başarı için temel bir prensiptir.",
      list: 'B2',
      answer: 'esas',
      quest: 'fundamental'),
  Words(
      front: "The company is seeking funding to expand its operations.",
      back: "Şirket, operasyonlarını genişletmek için fonlama arıyor.",
      list: 'B2',
      answer: 'fonlama',
      quest: 'funding'),
  Words(
      front: "Furthermore, the research also identified some potential risks.",
      back:
          "Üstelik, araştırma aynı zamanda bazı potansiyel riskleri de ortaya çıkardı.",
      list: 'B2',
      answer: 'üstelik',
      quest: 'Furthermore'),
  Words(
      front:
          "He has gained a lot of experience from working in different countries.",
      back: "Farklı ülkelerde çalışmaktan çok fazla tecrübe kazandı.",
      list: 'B2',
      answer: 'kazanmak',
      quest: 'gain'),
  Words(
      front:
          "The neighborhood is known for its high crime rates, with gangs operating in the area.",
      back:
          "Mahalle, bölgede faaliyet gösteren çetelere sahip olması nedeniyle yüksek suç oranlarıyla bilinir.",
      list: 'B2',
      answer: 'çete',
      quest: 'gang'),
  Words(
      front: "Solar panels generate electricity from sunlight.",
      back: "Güneş panelleri güneş ışığından elektrik üretir.",
      list: 'B2',
      answer: 'meydana getirmek',
      quest: 'generate'),
  Words(
      front: "Science fiction is my favorite genre of book.",
      back: "Bilim kurgu, en sevdiğim kitap türüdür.",
      list: 'B2',
      answer: 'tür',
      quest: 'genre'),
  Words(
      front: "The constitution is the document that governs a country.",
      back: "Anayasa, bir ülkeyi yöneten belgedir.",
      list: 'B2',
      answer: 'govern',
      quest: 'govern'),
  Words(
      front: "He grabbed the microphone and started to speak.",
      back: "Mikrofonu kaptı ve konuşmaya başladı.",
      list: 'B2',
      answer: 'kapmak',
      quest: 'grab'),
  Words(
      front: "The teacher will grade the essays next week.",
      back: "Öğretmen, denemeleri budú hafta puanlayacak.",
      list: 'B2',
      answer: 'puanlamak',
      quest: 'grade'),
  Words(
      front: "The patient's condition gradually improved over time.",
      back: "Hastanın durumu zamanla yavaş yavaş düzeldi.",
      list: 'B2',
      answer: 'yavaş yavaş',
      quest: 'gradually'),
  Words(
      front: "They built a grand castle on top of the hill.",
      back: "Tepede görkemli bir kale inşa ettiler.",
      list: 'B2',
      answer: 'büyük',
      quest: 'grand'),
  Words(
      front:
          "The government decided to grant tax breaks to businesses in order to stimulate the economy.",
      back:
          "Hükümet, ekonomiyi canlandırmak için işletmelere vergi indirimi yapmaya karar verdi.",
      list: 'B2',
      answer: 'bağışlamak',
      quest: 'grant'),
  Words(
      front: "There is no guarantee that the plan will be successful.",
      back: "Planın başarılı olacağının garantisi yoktur.",
      list: 'B2',
      answer: 'garanti',
      quest: 'guarantee'),
  Words(
      front:
          "She is a capable manager who can handle difficult situations effectively.",
      back:
          "O, zor durumları etkili bir şekilde idare edebilen yetenekli bir yönetici.",
      list: 'B2',
      answer: 'idare etmek',
      quest: 'handle'),
  Words(
      front: "Smoking can cause serious harm to your health.",
      back: "Sigara içmek sağlığınıza ciddi zarar verebilir.",
      list: 'B2',
      answer: 'zarar',
      quest: 'harm'),
  Words(
      front:
          "Fast food is often high in calories and unhealthy fats, making it harmful for your diet.",
      back:
          "Fast food genellikle kalori ve sağlıksız yağlar açısından yüksektir, bu da onu diyetiniz için zararlı hale getirir.",
      list: 'B2',
      answer: 'zararlı',
      quest: 'harmful'),
  Words(
      front: "The next court hearing in the case will be held on Monday.",
      back: "Davada bir sonraki duruşma Pazartesi günü görülecektir.",
      list: 'B2',
      answer: 'duruşma',
      quest: 'hearing'),
  Words(
      front:
          "Many religions believe in heaven as a place of eternal peace and happiness.",
      back: "Pek çok din, cenneti sonsuz huzur ve mutluluk yeri olarak görür.",
      list: 'B2',
      answer: 'cennet',
      quest: 'heaven'),
  Words(
      front: "She broke her heel while walking down the stairs.",
      back: "Merdivenden inerken topuğunu kırdı.",
      list: 'B2',
      answer: 'topuk',
      quest: 'heel'),
  Words(
      front:
          "Hell is often depicted as a place of fire and suffering in religious traditions.",
      back:
          "Cehennem, dini geleneklerde genellikle ateş ve ıstırap yeri olarak tasvir edilir.",
      list: 'B2',
      answer: 'Cehennem',
      quest: 'Hell'),
  Words(
      front: "Don't hesitate to ask for help if you need it.",
      back: "İhtiyacınız olursa yardım istemekten çekinmeyin.",
      list: 'B2',
      answer: 'duraksamak',
      quest: 'hesitate'),
  Words(
      front: "The mountain has a very high peak that is often covered in snow.",
      back: "Dağın genellikle karla kaplı çok yüksek bir zirvesi vardır.",
      list: 'B2',
      answer: 'yüksek',
      quest: 'high'),
  Words(
      front:
          "The company is looking to hire new employees with experience in marketing.",
      back: "Şirket, pazarlama alanında deneyimli yeni çalışanlar arıyor.",
      list: 'B2',
      answer: 'kiralamak',
      quest: 'hire'),
  Words(
      front: "He still holds a grudge against his former friend.",
      back: "Hala eski arkadaşına karşı kin besliyor.",
      list: 'B2',
      answer: 'sahip olmak',
      quest: 'hold'),
  Words(
      front:
          "The tree has a large, hollow trunk that can be used as a hiding place for small animals.",
      back:
          "Ağacın, küçük hayvanlar için saklanma yeri olarak kullanılabilecek büyük, içi boş bir gövdesi vardır.",
      list: 'B2',
      answer: 'çukur',
      quest: 'hollow'),
  Words(
      front: "The city of Mecca is a holy place for Muslims.",
      back: "Mekke şehri, Müslümanlar için kutsal bir yerdir.",
      list: 'B2',
      answer: 'kutsal',
      quest: 'holy'),
  Words(
      front:
          "We will hold a ceremony to honour the achievements of our employees.",
      back:
          "Çalışanlarımızın başarılarını onurlandırmak için bir tören düzenleyeceğiz.",
      list: 'B2',
      answer: 'onurlandırmak',
      quest: 'honour'),
  Words(
      front:
          "We are staying with a friend who is kindly acting as our host during our visit.",
      back:
          "Ziyaretimiz sırasında bize ev sahipliği yapan bir arkadaşımızın yanında kalıyoruz.",
      list: 'B2',
      answer: 'ev sahibi',
      quest: 'host'),
  Words(
      front: "They are looking to buy a new house with a big garden.",
      back: "Büyük bahçeli yeni bir ev satın almak istiyorlar.",
      list: 'B2',
      answer: 'ev',
      quest: 'house'),
  Words(
      front:
          "These are all household items that you will need for your new apartment.",
      back:
          "Bunlar, yeni daireniz için ihtiyacınız olacak günlük kullanılan eşyalar.",
      list: 'B2',
      answer: 'her gün kullanılan',
      quest: 'household'),
  Words(
      front:
          "The government is investing in new housing projects to provide affordable homes for everyone.",
      back:
          "Hükümet, herkese uygun fiyatlı konutlar sağlamak için yeni konut projelerine yatırım yapıyor.",
      list: 'B2',
      answer: 'konut',
      quest: 'housing'),
  Words(
      front:
          "He is known for his humorous personality and his ability to make people laugh.",
      back:
          "Mizah yeteneği ve insanları güldürme yeteneği ile tanınır.", // 'gülünç' can also mean 'funny' or 'ridiculous'
      list: 'B2',
      answer: 'gülünç',
      quest: 'humorous'),
  Words(
      front: "You don't understand British humour.",
      back: "Sen İngiliz mizahından anlamıyorsun.",
      list: 'B2',
      answer: 'mizah',
      quest: 'humour'),
  Words(
      front: "The lions are hunting for zebras on the African savanna.",
      back: "Aslanlar, Afrika savanında zebraları avlıyor.",
      list: 'B2',
      answer: 'avlanmak',
      quest: 'hunt'),
  Words(
      front: "Hunting is a controversial issue in many countries.",
      back: "Avlanma, birçok ülkede tartışmalı bir konudur.",
      list: 'B2',
      answer: 'avlama',
      quest: 'Hunting'),
  Words(
      front: "She accidentally hurt her ankle while playing basketball.",
      back: "Basketbol oynarken yanlışlıkla bileğini acıttı.",
      list: 'B2',
      answer: 'acımak, yaralamak',
      quest: 'hurt'),
  Words(
      front:
          "The book is full of illustrations that help to illustrate the story.",
      back: "Kitap, hikayeyi örneklemeye yardımcı olan resimlerle dolu.",
      list: 'B2',
      answer: 'örneklemek',
      quest: 'illustrate'),
  Words(
      front: "The latest edition of the book has beautiful illustrations.",
      back: "Kitabın son baskısı çok güzel illüstrasyonlara sahip.",
      list: 'B2',
      answer: 'illüstrasyon,örnekleme',
      quest:
          'illustration' // 'örnekleme' can also be used for illustration, but 'tasvir' might be a more fitting choice here
      ),
  Words(
      front:
          "With a little imagination, you can turn this old box into something useful.",
      back:
          "Biraz hayal gücüyle, bu eski kutuyu kullanışlı bir şeye dönüştürebilirsiniz.",
      list: 'B2',
      answer: 'hayal gücü',
      quest: 'imagination'),
  Words(
      front: "He can be a bit impatient sometimes, but he always means well.",
      back: "Bazen biraz sabırsız olabilir, ama her zaman iyiyi ister.",
      list: 'B2',
      answer: 'sabırsız',
      quest: 'impatient'),
  Words(
      front:
          "My boss said the presentation was superb, but I think he was implying some sarcasm.",
      back:
          "Patronum sunumun mükemmel olduğunu söyledi ama sanırım biraz alaycı olduğunu ima ediyordu.",
      list: 'B2',
      answer: 'kastetmek',
      quest: 'imply'),
  Words(
      front:
          "The government imposed new restrictions on travel in order to slow the spread of the virus.",
      back:
          "Hükümet, virüsün yayılmasını yavaşlatmak için seyahatlere yeni kısıtlamalar getirdi.",
      list: 'B2',
      answer: 'uygulamaya koymak',
      quest: 'impose'),
  Words(
      front: "She impressed everyone with her talent and dedication.",
      back: " yeteneği ve kararlılığıyla herkesi etkiledi.",
      list: 'B2',
      answer: 'etkilemek',
      quest: 'impress'),
  Words(
      front: "I was very impressed by the historical sites we visited in Rome.",
      back: "Roma'da ziyaret ettiğimiz tarihi yerlerden çok etkilendim.",
      list: 'B2',
      answer: 'etkilenmiş',
      quest: 'impressed'),
  Words(
      front: "The snail inched slowly across the garden path.",
      back: "Salıncak, bahçe yolunda yavaş yavaş hareket etti.",
      list: 'B2',
      answer: 'yavaş yavaş hareket etmek',
      quest: 'inch'),
  Words(
      front:
          "The police are investigating a recent incident at the local bank.",
      back: "Polis, yerel bankadaki son olayı araştırıyor.",
      list: 'B2',
      answer: 'hadise',
      quest: 'incident'),
  Words(
      front:
          "His income has increased significantly since he started his new job.",
      back: "Yeni işine başladıktan sonra geliri önemli ölçüde arttı.",
      list: 'B2',
      answer: 'gelir, kazanç',
      quest: 'income'),
  Words(
      front:
          "People are becoming increasingly concerned about the environment.",
      back: "İnsanlar çevre konusunda giderek daha fazla endişeleniyor.",
      list: 'B2',
      answer: 'gitgide',
      quest: 'increasingly'),
  Words(
      front: "The city has a large industrial zone on the outskirts.",
      back: "Şehrin kenar mahallelerinde büyük bir endüstriyel bölgesi var.",
      list: 'B2',
      answer: 'endüstriyel',
      quest: 'industrial'),
  Words(
      front:
          "Taking antibiotics for a long period of time can increase the risk of infection.",
      back: "Uzun süre antibiyotik kullanmak, enfeksiyon riskini artırabilir.",
      list: 'B2',
      answer: 'enfeksiyon',
      quest: 'infection'),
  Words(
      front:
          "It is important to inform the public about the latest developments.",
      back: "Kamuoyunu son gelişmeler hakkında bilgilendirmek önemlidir.",
      list: 'B2',
      answer: 'bilgilendirmek',
      quest: 'inform'),
  Words(
      front: "What are your initials?",
      back: "Baş harfiniz nedir?",
      list: 'B2',
      answer: 'baş harf',
      quest: 'initial'),
  Words(
      front:
          "Initially, he was hesitant about the project, but eventually he came around.",
      back: "Başlangıçta projeye karşı tereddütlüydü, ancak sonunda ikna oldu.",
      list: 'B2',
      answer: 'başlangıçta',
      quest: 'Initially'),
  Words(
      front:
          "She took the initiative to organize a fundraiser for the local animal shelter.",
      back:
          "Yerel hayvan barınağı için bir bağış etkinliği düzenlemek için girişimde bulundu.",
      list: 'B2',
      answer: 'girişim',
      quest: 'initiative'),
  Words(
      front:
          "He has a very inner strength that helps him to overcome challenges.",
      back:
          "Zorlukların üstesinden gelmesine yardımcı olan çok derinlerde bir gücü var.",
      list: 'B2',
      answer: 'içerideki',
      quest: 'inner'),
  Words(
      front:
          "The meditation helped me to gain a deeper insight into my own thoughts and feelings.",
      back:
          "Meditasyon, kendi düşüncelerim ve duygularım hakkında daha derin bir anlayış kazanmama yardımcı oldu.",
      list: 'B2',
      answer: 'anlayış',
      quest: 'insight'),
  Words(
      front:
          "He insisted on finishing the project even though everyone else was tired.",
      back: "Herkes yorgun olmasına rağmen projeyi bitirmekte ısrar etti.",
      list: 'B2',
      answer: 'ısrar etmek',
      quest: 'insist'),
  Words(
      front: "The teacher inspired his students to succeed in school.",
      back:
          "Öğretmen, öğrencilerine okulda başarılı olmaları için ilham verdi.",
      list: 'B2',
      answer: 'ilham vermek',
      quest: 'inspire'),
  Words(
      front: "We need to install a new security system in our house.",
      back: "Evimize yeni bir güvenlik sistemi kurmamız gerekiyor.",
      list: 'B2',
      answer: 'kurmak',
      quest: 'install'),
  Words(
      front:
          "For instance, getting a good night's sleep is essential for maintaining good health.",
      back:
          "Örneğin, sağlıklı kalmak için iyi bir gece uykusu almak çok önemlidir.",
      list: 'B2',
      answer: 'örnek',
      quest: 'instance'),
  Words(
      front:
          "The government is planning to institute a new tax on luxury goods.",
      back: "Hükümet, lüks mallara yeni bir vergi getirmeyi planlıyor.",
      list: 'B2',
      answer: 'kurmak',
      quest: 'institute'),
  Words(
      front:
          "The United Nations is a highly respected international institution.",
      back: "Birleşmiş Milletler, uluslararası alanda saygın bir kurumdur.",
      list: 'B2',
      answer: 'enstitü',
      quest: 'institution'),
  Words(
      front: "Do you have health insurance?",
      back: "Sağlık sigortanız var mı?",
      list: 'B2',
      answer: 'sigorta',
      quest: 'insurance'),
  Words(
      front: "The meeting was not intended to be a formal event.",
      back: "Toplantı resmi bir etkinlik olması amaçlanmamıştı.",
      list: 'B2',
      answer: 'planlanan',
      quest: 'intended'),
  Words(
      front:
          "She experienced a period of intense grief after her grandfather's death.",
      back: "Dedesinin ölümünden sonra yoğun bir keder dönemi yaşadı.",
      list: 'B2',
      answer: 'yoğun',
      quest: 'intense'),
  Words(
      front: "The company is facing some internal challenges at the moment.",
      back: "Şirket şu anda bazı dahili zorluklarla karşı karşıya.",
      list: 'B2',
      answer: 'dahili',
      quest: 'internal'),
  Words(
      front:
          "The artist's work is open to interpretation, and there is no one right answer.",
      back: "Sanatçının eseri yoruma açıktır ve tek bir doğru cevap yoktur.",
      list: 'B2',
      answer: 'yorumlamak',
      quest: 'interpret'),
  Words(
      front: "Please don't interrupt me while I am speaking.",
      back: "Konuşurken lütfen sözümü kesmeyin.",
      list: 'B2',
      answer: 'söze karışmak',
      quest: 'interrupt'),
  Words(
      front:
          "The police are conducting a thorough investigation into the crime.",
      back: "Polis, suç hakkında kapsamlı bir soruşturma yürütüyor.",
      list: 'B2',
      answer: 'soruşturma',
      quest: 'investigation'),
  Words(
      front:
          "It's important to do your research before making any investments.",
      back:
          "Herhangi bir yatırım yapmadan önce araştırmanızı yapmak önemlidir.",
      list: 'B2',
      answer: 'yatırım',
      quest: 'investment'),
  Words(
      front:
          "Climate change is a major issue that we need to address urgently.",
      back: "İklim değişikliği, acilen ele almamız gereken önemli bir konudur.",
      list: 'B2',
      answer: 'konu',
      quest: 'issue'),
  Words(
      front: "Spending time with loved ones brings me a lot of joy.",
      back: "Sevdiklerimle vakit geçirmek bana çok keyif veriyor.",
      list: 'B2',
      answer: 'keyif',
      quest: 'joy'),
  Words(
      front:
          "The judge reserved his judgement until he had heard all the evidence.",
      back: "Hakim, tüm delilleri dinleyene kadar kararını saklı tuttu.",
      list: 'B2',
      answer: 'yargı',
      quest: 'judgement'),
  Words(
      front: "She is a junior member of the team, but she is very talented.",
      back: "Takımın genç üyelerinden biridir, ancak yeteneklidir.",
      list: 'B2',
      answer: 'yaşça veya makamca küçük olan',
      quest: 'junior'),
  Words(
      front: "Justice should be served for the victims of the crime.",
      back: "Suç mağdurları için adalet sağlanmalıdır.",
      list: 'B2',
      answer: 'adalet',
      quest: 'Justice'),
  Words(
      front:
          "He can justify his actions by saying that he was only trying to help.",
      back:
          "Yalnızca yardım etmeye çalıştığını söyleyerek davranışlarını haklı çıkarabilir.",
      list: 'B2',
      answer: 'savunmak',
      quest: 'justify'),
  Words(
      front: "Manual labour can be very physically demanding.",
      back: "Fiziksel işçilik çok yorucu olabilir.",
      list: 'B2',
      answer: 'uğraşmak',
      quest: 'labour'),
  Words(
      front:
          "We enjoyed the beautiful landscape of the countryside during our road trip.",
      back:
          "Yol gezimiz sırasında kırsalın güzel manzarasının tadını çıkardık.",
      list: 'B2',
      answer: 'manzara',
      quest: 'landscape'),
  Words(
      front:
          "The success of the project was largely due to the hard work and dedication of the team.",
      back:
          "Projenin başarısı büyük ölçüde ekibin sıkı çalışması ve özverisi sayesindeydi.",
      list: 'B2',
      answer: 'büyük ölçüde',
      quest: 'largely'),
  Words(
      front: "Have you read the latest news about the election?",
      back: "Seçimle ilgili son haberleri okudunuz mu?",
      list: 'B2',
      answer: 'son',
      quest: 'latest'),
  Words(
      front: "The company is planning to launch a new product line next year.",
      back:
          "Şirket, önümüzdeki yıl yeni bir ürün serisi piyasaya sürmeyi planlıyor.",
      list: 'B2',
      answer: 'başlatmak',
      quest: 'launch'),
  Words(
      front:
          "Effective leadership is essential for the success of any organization.",
      back: "Etkin liderlik, herhangi bir kuruluşun başarısı için gereklidir.",
      list: 'B2',
      answer: 'liderlik',
      quest: 'leadership'),
  Words(
      front: "Our team is currently in first place in the league.",
      back: "Takımımız şu anda ligde birinci sırada.",
      list: 'B2',
      answer: 'lig',
      quest: 'league'),
  Words(
      front: "He leaned against the wall as he waited for his bus.",
      back: "Otobüsünü beklerken duvara yaslandı.",
      list: 'B2',
      answer: 'dayanmak',
      quest: 'lean'),
  Words(
      front: "She decided to leave her job and travel the world.",
      back: "İşini bırakıp dünyayı gezmeye karar verdi.",
      list: 'B2',
      answer: 'ayrılmak',
      quest: 'leave'),
  Words(
      front:
          "We need to improve our English to a higher level if we want to study abroad.",
      back:
          "Yurtdışında eğitim görmek istiyorsak İngilizcemizi daha üst bir seviyeye çıkarmamız gerekiyor.",
      list: 'B2',
      answer: 'seviye',
      quest: 'level'),
  Words(
      front: "Do you need a driver's licence to rent a car?",
      back: "Araba kiralamak için ehliyete mi ihtiyacınız var?",
      list: 'B2',
      answer: 'lisans',
      quest: 'licence'),
  Words(
      front: "Our resources are limited, so we need to use them wisely.",
      back:
          "Kaynaklarımız sınırlı, bu nedenle onları akıllıca kullanmamız gerekiyor.",
      list: 'B2',
      answer: 'kısıtlı',
      quest: 'limited'),
  Words(
      front: "Please wait here for a moment, I'll be back in a few lines.",
      back: "Lütfen burada bir süre bekleyin, birkaç satıra geri döneceğim.",
      list: 'B2',
      answer: 'satır',
      quest: 'line'),
  Words(
      front: "The debate in Bucharest will therefore be a very lively one",
      back: "Bu nedenle Bükreş'teki tartışma çok canlı geçecektir.",
      list: 'B2',
      answer: 'canlı',
      quest: 'lively'),
  Words(
      front: "The truck driver carefully loaded the boxes onto the trailer.",
      back: "Kamyon şoförü kutuları dikkatlice treylere yükledi.",
      list: 'B2',
      answer: 'yüklemek',
      quest: 'load'),
  Words(
      front: "He took out a loan from the bank to buy a new car.",
      back: "Yeni bir araba almak için bankadan kredi aldı.",
      list: 'B2',
      answer: 'ödünç para',
      quest: 'loan'),
  Words(
      front: "It is not logical to expect to get rich quick.",
      back: "Çabuk zengin olmayı beklemek mantıklı değil.",
      list: 'B2',
      answer: 'mantıklı',
      quest: 'logical'),
  Words(
      front: "We need to develop a long-term plan to achieve our goals.",
      back:
          "Hedeflerimize ulaşmak için uzun vadeli bir plan geliştirmemiz gerekiyor.",
      list: 'B2',
      answer: 'uzun dönem',
      quest: 'long-term'),
  Words(
      front:
          "The button on my shirt is a bit loose, can you help me sew it tighter?",
      back:
          "Gömleğimdeki düğme biraz gevşek, daha sıkı dikmeme yardım edebilir misin?",
      list: 'B2',
      answer: 'gevşek',
      quest: 'loose'),
  Words(
      front:
          "The economic crisis has led to a low standard of living for many people.",
      back: "Ekonomik kriz, birçok insanın yaşam standardını düşürdü.",
      list: 'B2',
      answer: 'düşük',
      quest: 'low'),
  Words(
      front:
          "The government is trying to lower taxes to stimulate the economy.",
      back:
          "Hükümet, ekonomiyi canlandırmak için vergileri düşürmeye çalışıyor.",
      list: 'B2',
      answer: 'düşürmek',
      quest: 'lower'),
  Words(
      front:
          "Smoking can damage your lungs and lead to serious health problems.",
      back:
          "Sigara içmek akciğerlerinize zarar verebilir ve ciddi sağlık sorunlarına yol açabilir.",
      list: 'B2',
      answer: 'akciğer',
      quest: 'lung'),
  Words(
      front:
          "It is important to maintain a healthy lifestyle in order to stay healthy.",
      back:
          "Sağlıklı kalmak için sağlıklı bir yaşam tarzı sürdürmek önemlidir.",
      list: 'B2',
      answer: 'sürdürmek',
      quest: 'maintain'),
  Words(
      front: "The majority of the population voted for the new president.",
      back: "Nüfusun çoğunluğu yeni cumhurbaşkanını seçti.",
      list: 'B2',
      answer: 'çoğunluk',
      quest: 'majority'),
  Words(
      front: "Can you help me make a decision about what to buy?",
      back: "Ne satın alacağıma karar vermemde bana yardım edebilir misin?",
      list: 'B2',
      answer: 'yapmak',
      quest: 'make'),
  Words(
      front: "We need a map to find our way around the city.",
      back: "Şehrin içinde dolaşmak için bir haritaya ihtiyacımız var.",
      list: 'B2',
      answer: 'harita',
      quest: 'map'),
  Words(
      front:
          "The protesters gathered in a mass demonstration against the government.",
      back: "Protestocular hükümete karşı kitlesel bir gösteride toplandılar.",
      list: 'B2',
      answer: 'yığmak',
      quest: 'mass'),
  Words(
      front:
          "The building was a massive structure that dominated the city skyline.",
      back: "Bina, şehrin silüetine hakim olan devasa bir yapıydı.",
      list: 'B2',
      answer: 'cüsseli',
      quest: 'massive'),
  Words(
      front: "He is a master of the guitar and can play any song you request.",
      back: "Ustasıdır gitarın, istediğiniz herhangi bir şarkıyı çalabilir.",
      list: 'B2',
      answer: 'usta, efendi',
      quest: 'master'),
  Words(
      front: "We need to find a matching pair of socks for this one.",
      back: "Bunun için uyumlu bir çorap çifti bulmamız gerekiyor.",
      list: 'B2',
      answer: 'karşılaştırma',
      quest: 'matching'),
  Words(
      front: "The bus is a convenient means of transportation in the city.",
      back: "Otobüs, şehir içinde ulaşımın elverişli bir aracıdır.",
      list: 'B2',
      answer: 'araç',
      quest: 'means'),
  Words(
      front:
          "The scientist carefully recorded his measurements in his notebook.",
      back: "Bilim insanı, ölçümlerini defterine dikkatlice kaydetti.",
      list: 'B2',
      answer: 'ölçüm',
      quest: 'measurement'),
  Words(
      front: "I like my coffee medium, not too strong and not too weak.",
      back: "Kahvemi orta seviyede, çok sert veya çok zayıf değil, severim.",
      list: 'B2',
      answer: 'orta',
      quest: 'medium'),
  Words(
      front: "The chocolate bar will melt quickly if you leave it in the sun.",
      back: "Eğer güneşte bırakırsanız çikolata çubuğu hızla eriyecektir.",
      list: 'B2',
      answer: 'eritmek',
      quest: 'melt'),
  Words(
      front: "Turkey has a strong military force.",
      back: "Türkiye'nin güçlü bir askeri gücü vardır.",
      list: 'B2',
      answer: 'askeri',
      quest: 'military'),
  Words(
      front: "Iron is an essential mineral for the human body.",
      back: "Demir, insan vücudu için gerekli bir mineraldir.",
      list: 'B2',
      answer: 'maden',
      quest: 'mineral'),
  Words(
      front: "The minimum wage is not enough to live comfortably in this city.",
      back: "Asgari ücret, bu şehirde rahat yaşamak için yeterli değil.",
      list: 'B2',
      answer: 'asgari',
      quest: 'minimum'),
  Words(
      front: "The Minister of Education announced a new reform plan.",
      back: "Milli Eğitim Bakanı yeni bir reform planı açıkladı.",
      list: 'B2',
      answer: 'bakan',
      quest: 'Minister'),
  Words(
      front: "You are not allowed to buy alcohol if you are a minor.",
      back: "Reşit değilseniz alkol satın almanıza izin verilmez.",
      list: 'B2',
      answer: 'reşit olmayan kimse',
      quest: 'minor'),
  Words(
      front: "The ethnic minority group has its own language and traditions.",
      back: "Etnik azınlık grubunun kendi dili ve gelenekleri vardır.",
      list: 'B2',
      answer: 'azınlık',
      quest: 'minority'),
  Words(
      front: "The astronauts' mission to Mars is a historic journey.",
      back: "Astronotların Mars'a yolculuğu tarihi bir görevdir.",
      list: 'B2',
      answer: 'görev',
      quest: 'mission'),
  Words(
      front:
          "Everyone makes mistakes sometimes, the important thing is to learn from them.",
      back: "Herkes bazen hata yapar, önemli olan onlardan ders çıkarmaktır.",
      list: 'B2',
      answer: 'hata',
      quest: 'mistake'),
  Words(
      front: "The movie received mixed reviews from both fans and critics.",
      back:
          "Film hem hayranlardan hem de eleştirmenlerden karışık eleştiriler aldı.",
      list: 'B2',
      answer: 'karışık',
      quest: 'mixed'),
  Words(
      front: "The software can be modify-ied to meet your specific needs.",
      back: "Yazılım, özel ihtiyaçlarınızı karşılamak için değiştirilebilir.",
      list: 'B2',
      answer: 'değişmek',
      quest: 'modify'),
  Words(
      front: "The knight mounted his horse and rode off into battle.",
      back: "Şövalye atına bindi ve savaşa doğru gitti.",
      list: 'B2',
      answer: 'binmek',
      quest: 'mount'),
  Words(
      front: "He has multiple talents, he can sing, dance, and play the piano.",
      back:
          "Çok yetenekli, şarkı söyleyebilir, dans edebilir ve piyano çalabilir.",
      list: 'B2',
      answer: 'birçok',
      quest: 'multiple'),
  Words(
      front: "Bacteria can multiply quickly in warm and humid conditions.",
      back: "Bakteriler sıcak ve nemli koşullarda hızla çoğalabilir.",
      list: 'B2',
      answer: 'çoğalmak',
      quest: 'multiply'),
  Words(
      front:
          "The ancient ruins have a mysterious aura that attracts tourists from all over the world.",
      back:
          "Eski kalıntıların, dünyanın her yerinden turistleri çeken esrarengiz bir aurası vardır.",
      list: 'B2',
      answer: 'esrarengiz',
      quest: 'mysterious'),
  Words(
      front: "The street was too narrow for two cars to pass each other.",
      back: "Sokak, iki arabanın yan yana geçmesi için çok dardı.",
      list: 'B2',
      answer: 'dar',
      quest: 'narrow'),
  Words(
      front: "The national flag is a symbol of a country's pride and unity.",
      back: "Ulusal bayrak, bir ülkenin gurur ve birliğinin sembolüdür.",
      list: 'B2',
      answer: 'ulusal',
      quest: 'national'),
  Words(
      front: "She keeps her desk neat and organized.",
      back: "Masasını düzenli ve temiz tutar.",
      list: 'B2',
      answer: 'düzenli',
      quest: 'neat'),
  Words(
      front: "The constant loud noise was getting on my nerves.",
      back: "Sürekli gelen yüksek ses sinirlerime dokunmaya başladı.",
      list: 'B2',
      answer: 'sinir',
      quest: 'nerve'),
  Words(
      front: "We lost the game, nevertheless, we played well.",
      back: "Maçı kaybettik, yine de iyi oynadık.",
      list: 'B2',
      answer: 'yine de',
      quest: 'nevertheless'),
  Words(
      front: "I woke up screaming after having a nightmare about spiders.",
      back:
          "Örümceklerle ilgili bir kabus gördükten sonra çığlık atarak uyandım.",
      list: 'B2',
      answer: 'kabus',
      quest: 'nightmare'),
  Words(
      front: "I don't have any notion of where he might be.",
      back: "Onun nerede olabileceğine dair hiçbir fikrim yok.",
      list: 'B2',
      answer: 'düşünce',
      quest: 'notion'),
  Words(
      front: "There are numerous historical landmarks to visit in this city.",
      back: "Bu şehirde ziyaret edilebilecek sayısız tarihi simge var.",
      list: 'B2',
      answer: 'sayısız',
      quest: 'numerous'),
  Words(
      front: "Children should obey their parents and teachers.",
      back: "Çocuklar anne-babalarına ve öğretmenlerine itaat etmelidir.",
      list: 'B2',
      answer: 'itaat etmek',
      quest: 'obey'),
  Words(
      front: "She has the right to object to the new regulations.",
      back: "Yeni yönetmeliklere itiraz etme hakkı var.",
      list: 'B2',
      answer: 'itiraz etmek',
      quest: 'object'),
  Words(
      front: "Our main objective is to help people in need.",
      back: "Asıl hedefimiz ihtiyaç sahibi insanlara yardım etmektir.",
      list: 'B2',
      answer: 'hedef, amaç',
      quest: 'objective'),
  Words(
      front: "You have a moral obligation to help your friend.",
      back: "Arkadaşına yardım etmek için ahlaki bir yükümlülüğün var.",
      list: 'B2',
      answer: 'yükümlülük',
      quest: 'obligation'),
  Words(
      front: "The scientist made careful observations of the plant's growth.",
      back: "Bilim insanı, bitkinin büyümesine dair dikkatli gözlemler yaptı.",
      list: 'B2',
      answer: 'gözetleme',
      quest: 'observation'),
  Words(
      front: "We need to observe the traffic before crossing the street.",
      back: "Socağı geçmeden önce trafiği gözlemlememiz gerekiyor.",
      list: 'B2',
      answer: 'gözlemlemek',
      quest: 'observe'),
  Words(
      front: "He was able to obtain a visa after a long application process.",
      back: "Uzun bir başvuru sürecinden sonra vize alabildi.",
      list: 'B2',
      answer: 'edinmek',
      quest: 'obtain'),
  Words(
      front: "We occasionally go out for dinner on weekends.",
      back: "Hafta sonları ara sıra dışarıda yemek yiyoruz.",
      list: 'B2',
      answer: 'ara sıra',
      quest: 'occasionally'),
  Words(
      front: "Her harsh words offended her deeply.",
      back: "Onun sert sözleri onu derinden rencide etti.",
      list: 'B2',
      answer: 'rencide etmek',
      quest: 'offend'),
  Words(
      front: "His offensive remark caused a heated argument.",
      back: "Saldırgan sözü hararetli bir tartışmaya neden oldu.",
      list: 'B2',
      answer: 'saldırgan',
      quest: 'offensive'),
  Words(
      front: "The government official announced a new economic plan.",
      back: "Devlet memuru yeni bir ekonomik plan açıkladı.",
      list: 'B2',
      answer: 'memur',
      quest: 'official'),
  Words(
      front: "The grand opening of the new museum will be held next week.",
      back: "Yeni müzenin görkemli açılışı önümüzdeki hafta yapılacak.",
      list: 'B2',
      answer: 'açma',
      quest: 'opening'),
  Words(
      front: "The surgeon will operate on the patient tomorrow morning.",
      back: "Cerrah hastayı yarın sabah ameliyat edecek.",
      list: 'B2',
      answer: 'ameliyat etmek',
      quest: 'operate'),
  Words(
      front: "We will be facing a strong opponent in the championship game.",
      back: "Şampiyonluk maçında güçlü bir rakip ile karşılaşacağız.",
      list: 'B2',
      answer: 'rakip',
      quest: 'opponent'),
  Words(
      front: "She strongly opposes the new law.",
      back: "Yeni yasaya şiddetle karşı çıkıyor.",
      list: 'B2',
      answer: 'karşı koymak',
      quest: 'oppose'),
  Words(
      front: "I am opposed to violence in all forms.",
      back: "Her türlü şiddete karşıyım.",
      list: 'B2',
      answer: 'karşıt',
      quest: 'opposed'),
  Words(
      front: "There is a growing opposition to the government's policies.",
      back: "Hükümetin politikalarına giderek artan bir muhalefet var.",
      list: 'B2',
      answer: 'aykırılık',
      quest: 'opposition'),
  Words(
      front: "What is the origin of this word?",
      back: "Bu kelimenin kökeni nedir?",
      list: 'B2',
      answer: 'köken',
      quest: 'origin'),
  Words(
      front:
          "He did well in school, otherwise he would not have gotten into college.",
      back: "Okulda başarılı oldu, aksi takdirde üniversiteye giremezdi.",
      list: 'B2',
      answer: 'aksi halde',
      quest: 'otherwise'),
  Words(
      front: "The outcome of the election is still uncertain.",
      back: "Seçimin sonucu hala belirsiz.",
      list: 'B2',
      answer: 'netice',
      quest: 'outcome'),
  Words(
      front:
          "The astronaut wore a special suit to protect his outer layer from the harsh space environment.",
      back:
          "Astronot, uzayın zorlu ortamından dış katmanını korumak için özel bir giysi giydi.",
      list: 'B2',
      answer: 'harici',
      quest: 'outer'),
  Words(
      front:
          "Before you start writing your essay, it's helpful to outline your main points.",
      back:
          "Denenemenizi yazmaya başlamadan önce, ana hatlarını çizmeniz faydalıdır.",
      list: 'B2',
      answer: 'taslağını çizmek',
      quest: 'outline'),
  Words(
      front: "The overall impression of the movie was positive.",
      back: "Filmin genel izlenimi olumluydu.",
      list: 'B2',
      answer: 'etraflı',
      quest: 'overall'),
  Words(
      front: "I still owe him ten dollars for the book.",
      back: "Ona kitaba dair hala on dolar borçluyum.",
      list: 'B2',
      answer: 'borçlu olmak',
      quest: 'owe'),
  Words(
      front: "He was paceing back and forth nervously before the interview.",
      back: "Mülakat öncesi gergin bir şekilde ileri geri adımlıyordu.",
      list: 'B2',
      answer: 'adımlamak',
      quest: 'pace'),
  Words(
      front: "I received a package in the mail today.",
      back: "Bugün postayla bir paket aldım.",
      list: 'B2',
      answer: 'paket',
      quest: 'package'),
  Words(
      front: "The new law was passed by a majority vote in parliament.",
      back: "Yeni yasa, parlamentoda çoğunluk oyu ile kabul edildi.",
      list: 'B2',
      answer: 'meclis',
      quest: 'parliament'),
  Words(
      front: "There were over a hundred participants in the marathon.",
      back: "Maraton yarışına yüzün üzerinde katılımcı vardı.",
      list: 'B2',
      answer: 'katılımcı',
      quest: 'participant'),
  Words(
      front:
          "The door was only partly open, so I couldn't see what was inside.",
      back: "Kapı sadece kısmen açıktı, bu yüzden içeriyi göremedim.",
      list: 'B2',
      answer: 'kısmen',
      quest: 'partly'),
  Words(
      front: "The narrow passage led to a hidden garden.",
      back: "Dar pasaj gizli bir bahçeye açılıyordu.",
      list: 'B2',
      answer: 'pasaj',
      quest: 'passage'),
  Words(
      front: "The doctor will see the next patient soon.",
      back: "Doktor kısa süre sonra bir sonraki hastayı görecek.",
      list: 'B2',
      answer: 'hasta',
      quest: 'patient'),
  Words(
      front: "Many retirees rely on their pension to make ends meet.",
      back: "Birçok emekli, geçimlerini sağlamak için emekli maaşına güvenir.",
      list: 'B2',
      answer: 'emekli maaşı',
      quest: 'pension'),
  Words(
      front: "He has a permanent job at a large company.",
      back: "Büyük bir şirkette kalıcı bir işi var.",
      list: 'B2',
      answer: 'kalıcı',
      quest: 'permanent'),
  Words(
      front: "The police did not permit us to enter the crime scene.",
      back: "Polis, olay yerine girmemize izin vermedi.",
      list: 'B2',
      answer: 'izin vermek',
      quest: 'permit'),
  Words(
      front:
          "It's important to consider all perspectives before making a decision.",
      back: "Karar vermeden önce tüm bakış açılarını değerlendirmek önemlidir.",
      list: 'B2',
      answer: 'bakış açısı',
      quest: 'perspective'),
  Words(
      front: "The project is currently in its final phase of development.",
      back: "Proje şu anda son geliştirme aşamasında.",
      list: 'B2',
      answer: 'aşama',
      quest: 'phase'),
  Words(
      front:
          "The northern lights are a natural phenomenon that can be seen in the Arctic sky.",
      back:
          "Kuzey ışıkları, Kuzey Kutbu gökyüzünde görülebilen doğal bir fenomendir.",
      list: 'B2',
      answer: 'algılanabilen şey',
      quest: 'phenomenon'),
  Words(
      front:
          "Philosophy is the study of fundamental questions about existence, knowledge, and morality.",
      back:
          "Felsefe, varoluş, bilgi ve ahlak hakkındaki temel soruların incelenmesidir.",
      list: 'B2',
      answer: 'felsefe',
      quest: 'Philosophy'),
  Words(
      front: "Please pick a number between one and ten.",
      back: "Lütfen bir ile on arasında bir sayı seçin.",
      list: 'B2',
      answer: 'seçmek',
      quest: 'pick'),
  Words(
      front: "There is a beautiful picture of the sunset hanging on the wall.",
      back: "Duvarda asılı duran güzel bir gün batımı resmi var.",
      list: 'B2',
      answer: 'resim',
      quest: 'picture'),
  Words(
      front: "There was a pile of dirty dishes in the sink.",
      back: "Lavaboda bir yığın kirli bulaşık vardı.",
      list: 'B2',
      answer: 'yığın',
      quest: 'pile'),
  Words(
      front: "The singer's voice began to pitch as she reached the high notes.",
      back: "Şarkıcının sesi, tiz notalara ulaştığında yükselmeye başladı.",
      list: 'B2',
      answer: 'yalpalamak',
      quest: 'pitch'),
  Words(
      front: "We drove across the vast plain of the Midwest.",
      back: "Orta Batı'nın geniş ovaları boyunca sürdük.",
      list: 'B2',
      answer: 'ova',
      quest: 'plain'),
  Words(
      front: "What is the plot of the movie?",
      back: "Filmin konusu nedir?",
      list: 'B2',
      answer: 'hikayenin konusu',
      quest: 'plot'),
  Words(
      front: "Two plus two equals four.",
      back: "İki artı iki dört eder.",
      list: 'B2',
      answer: 'artı',
      quest: 'plus'),
  Words(
      front: "He carefully avoided the pointed rocks on the beach.",
      back: "Plajdaki sivri kayalardan dikkatlice kaçındı.",
      list: 'B2',
      answer: 'sivri',
      quest: 'pointed'),
  Words(
      front: "She possesses a natural talent for music.",
      back: "Doğuştan müzik yeteneğine sahip.",
      list: 'B2',
      answer: 'sahip olmak',
      quest: 'possess'),
  Words(
      front: "He has the potential to become a great leader.",
      back: "Harika bir lider olma potansiyeli var.",
      list: 'B2',
      answer: 'potansiyel',
      quest: 'potential'),
  Words(
      front: "The new technology has the power to revolutionize the world.",
      back: "Yeni teknolojinin dünyayı kökten değiştirme gücü var.",
      list: 'B2',
      answer: 'güç',
      quest: 'power'),
  Words(
      front: "The teacher praised the students for their hard work.",
      back: "Öğretmen, öğrencileri sıkı çalışmaları için övdü.",
      list: 'B2',
      answer: 'methetmek',
      quest: 'praise'),
  Words(
      front: "She is three months pregnant.",
      back: "Üç aylık hamile.",
      list: 'B2',
      answer: 'hamile',
      quest: 'pregnant'),
  Words(
      front: "We need to make careful preparations for the upcoming exam.",
      back: "Yaklaşan sınav için dikkatli hazırlıklar yapmamız gerekiyor.",
      list: 'B2',
      answer: 'hazırlık',
      quest: 'preparation'),
  Words(
      front: "The strong presence of the police helped to calm the crowd.",
      back: "Polisin güçlü mevcudiyeti kalabalığı yatıştırmaya yardımcı oldu.",
      list: 'B2',
      answer: 'mevcudiyet',
      quest: 'presence'),
  Words(
      front:
          "It is important to preserve our natural environment for future generations.",
      back: "Doğal çevremizi gelecek nesiller için korumak önemlidir.",
      list: 'B2',
      answer: 'korumak',
      quest: 'preserve'),
  Words(
      front: "What is the price of this book?",
      back: "Bu kitabın fiyatı nedir?",
      list: 'B2',
      answer: 'fiyat',
      quest: 'price'),
  Words(
      front: "The suspect was the prime suspect in the robbery.",
      back: "Şüpheli, soygunda baş şüpheliydi.",
      list: 'B2',
      answer: 'kurmak',
      quest: 'prime'),
  Words(
      front: "Honesty is one of the most important principles in life.",
      back: "Dürüstlük, hayattaki en önemli ilkelerden biridir.",
      list: 'B2',
      answer: 'başlıca',
      quest: 'principle'),
  Words(
      front: "Can you please print this document for me?",
      back: "Bu belgeyi benim için yazdırabilir misin?",
      list: 'B2',
      answer: 'yazdırmak',
      quest: 'print'),
  Words(
      front: "Studying is my top priority right now.",
      back: "Şu anda en önemli önceliğim ders çalışmak.",
      list: 'B2',
      answer: 'öncelik',
      quest: 'priority'),
  Words(
      front: "Everyone deserves the right to privacy.",
      back: "Herkes gizliliğe saygı hakkına sahiptir.",
      list: 'B2',
      answer: 'gizlilik',
      quest: 'privacy'),
  Words(
      front: "The application process can take several weeks.",
      back: "Başvuru süreci birkaç hafta sürebilir.",
      list: 'B2',
      answer: 'süreç, işlem',
      quest: 'process'),
  Words(
      front: "Our factory produces a variety of household products.",
      back: " Fabrikamız çeşitli ev ürünleri üretiyor.",
      list: 'B2',
      answer: 'üretmek',
      quest: 'produce'),
  Words(
      front:
          "There has been significant progress in the fight against climate change.",
      back: "İklim değişikliği ile mücadelede önemli bir gelişme oldu.",
      list: 'B2',
      answer: 'gelişmek',
      quest: 'progress'),
  Words(
      front:
          "We are working on a new project to develop sustainable energy sources.",
      back:
          "Sürdürülebilir enerji kaynakları geliştirmek için yeni bir proje üzerinde çalışıyoruz.",
      list: 'B2',
      answer: 'proje',
      quest: 'project'),
  Words(
      front: "The police are still searching for proof of the suspect's guilt.",
      back: "Polis hala şüphelinin suçluluğuna dair kanıt arıyor.",
      list: 'B2',
      answer: 'kanıt',
      quest: 'proof'),
  Words(
      front: "He submitted a proposal for a new educational program.",
      back: "Yeni bir eğitim programı için bir önerge sundu.",
      list: 'B2',
      answer: 'öneri',
      quest: 'proposal'),
  Words(
      front: "The senator proposed a new law to reduce taxes.",
      back: "Senatör vergileri düşürmek için yeni bir yasa önerdi.",
      list: 'B2',
      answer: 'önermek',
      quest: 'propose'),
  Words(
      front: "The future looks promising, with many exciting prospects ahead.",
      back:
          "Gelecek, önümüzde birçok heyecan verici olasılık varken umut verici görünüyor.",
      list: 'B2',
      answer: 'olasılık',
      quest: 'prospect'),
  Words(
      front: "The police officer wore a bulletproof vest for protection.",
      back: "Polis memuru koruma amaçlı kurşun geçirmez yelek giydi.",
      list: 'B2',
      answer: 'koruma',
      quest: 'protection'),
  Words(
      front:
          "The recent publication of her novel has brought her critical acclaim.",
      back:
          "Romanının yakın zamanda yayınlanması ona eleştirel beğeni kazandırdı.",
      list: 'B2',
      answer: 'yayınlamak',
      quest: 'publication'),
  Words(
      front: "The teacher carefully explained the lesson to her pupils.",
      back: "Öğretmen dersi öğrencilerine dikkatlice anlattı.",
      list: 'B2',
      answer: 'öğrenci',
      quest: 'pupil'),
  Words(
      front: "She decided to purchase a new car.",
      back: "Yeni bir araba almaya karar verdi.",
      list: 'B2',
      answer: 'satın almak',
      quest: 'purchase'),
  Words(
      front: "The mountain air is pure and refreshing.",
      back: "Dağ havası saf ve tazedir.",
      list: 'B2',
      answer: 'saf',
      quest: 'pure'),
  Words(
      front: "He is determined to pursue his dream of becoming a doctor.",
      back: "Doktor olma hayalini gerçekleştirmeye kararlı.",
      list: 'B2',
      answer: 'izlemek',
      quest: 'pursue'),
  Words(
      front: "She was promoted to the rank of captain in the army.",
      back: "Orduda yüzbaşı rütbesine terfi etti.",
      list: 'B2',
      answer: 'rütbe, aşama',
      quest: 'rank'),
  Words(
      front: "The fire spread rapidly through the dry forest.",
      back: "Yangın kuru ormanda hızla yayıldı.",
      list: 'B2',
      answer: 'hızla',
      quest: 'rapid'),
  Words(
      front: "The unemployment rate is currently at a ten-year low.",
      back: "İşsizlik oranı şu anda on yıllık en düşük seviyede.",
      list: 'B2',
      answer: 'kur',
      quest: 'rate'),
  Words(
      front: "I don't like eating raw fish.",
      back: "Çiğ balık yemekten hoşlanmam.",
      list: 'B2',
      answer: 'çiğ',
      quest: 'raw'),
  Words(
      front: "We finally reached our destination after a long journey.",
      back: "Uzun bir yolculuktan sonra sonunda varış yerimize ulaştık.",
      list: 'B2',
      answer: 'ulaşmak',
      quest: 'reach'),
  Words(
      front: "It is important to set realistic goals for yourself.",
      back: "Kendiniz için gerçekçi hedefler belirlemek önemlidir.",
      list: 'B2',
      answer: 'gerçekçi',
      quest: 'realistic'),
  Words(
      front: "The teacher asked the students to answer a reasonable question.",
      back: "Öğretmen öğrencilerden mantıklı bir soru cevaplamalarını istedi.",
      list: 'B2',
      answer: 'mantıksal',
      quest: 'reasonable'),
  Words(
      front: "I can't recall where I left my keys.",
      back: " anahtarlarımı nereye bıraktığımı hatırlayamıyorum.",
      list: 'B2',
      answer: 'hatırlamak',
      quest: 'recall'),
  Words(
      front: "It took her months to recover from the accident.",
      back: "Kazadan tamamen kurtulması aylar aldı.",
      list: 'B2',
      answer: 'kurtarmak',
      quest: 'recover'),
  Words(
      front:
          "The government is implementing new policies to achieve a reduction in greenhouse gas emissions.",
      back:
          "Hükümet, sera gazı emisyonlarını azaltmak için yeni politikalar uyguluyor.",
      list: 'B2',
      answer: 'eksiltme',
      quest: 'reduction'),
  Words(
      front: "I don't regard him highly as a musician.",
      back: "Onu bir müzisyen olarak pek saymam.",
      list: 'B2',
      answer: 'saymak',
      quest: 'regard'),
  Words(
      front: "The company is expanding its operations into regional markets.",
      back: "Şirket, faaliyetlerini bölgesel pazarlara genişletiyor.",
      list: 'B2',
      answer: 'bölgesel',
      quest: 'regional'),
  Words(
      front: "You need to register for the class before the deadline.",
      back: "Derse son teslim tarihinden önce kaydolmanız gerekiyor.",
      list: 'B2',
      answer: 'kaydetmek',
      quest: 'register'),
  Words(
      front: "He expressed his regret for missing the important meeting.",
      back: "Önemli toplantıyı kaçırdığı için pişmanlığını dile getirdi.",
      list: 'B2',
      answer: 'pişmanlık',
      quest: 'regret'),
  Words(
      front: "There are strict regulations in place to ensure food safety.",
      back: "Gıda güvenliğini sağlamak için sıkı düzenlemeler var.",
      list: 'B2',
      answer: 'düzenleme',
      quest: 'regulation'),
  Words(
      front:
          "Turkey is a relatively large country compared to its European neighbors.",
      back: "Türkiye, Avrupa komşularına göre nispeten büyük bir ülkedir.",
      list: 'B2',
      answer: 'oranla',
      quest: 'relatively'),
  Words(
      front:
          "Only the information relevant to the case will be included in the report.",
      back: "Rapora sadece dava ile ilgili bilgiler dahil edilecektir.",
      list: 'B2',
      answer: 'konuyla ilgili',
      quest: 'relevant'),
  Words(
      front: "He felt a sense of relief when he finally finished the exam.",
      back: "Sınavı nihayet bitirdiğinde bir rahatlama hissetti.",
      list: 'B2',
      answer: 'rahatlama',
      quest: 'relief'),
  Words(
      front: "You can rely on me to help you with this project.",
      back: "Bu projede size yardım etmek için bana güvenebilirsiniz.",
      list: 'B2',
      answer: 'güvenmek',
      quest: 'rely'),
  Words(
      front: "The teacher made a few remarks about the students' behavior.",
      back:
          "Öğretmen, öğrencilerin davranışları hakkında birkaç açıklama yaptı.",
      list: 'B2',
      answer: 'belirtmek',
      quest: 'remark'),
  Words(
      front: "She is a representative of the student council.",
      back: "O, öğrenci konseyinin temsilcisidir.",
      list: 'B2',
      answer: 'temsil eden',
      quest: 'representative'),
  Words(
      front: "He has a good reputation for being honest and reliable.",
      back: "Dürüst ve güvenilir olmasıyla tanınan iyi bir şöhrete sahip.",
      list: 'B2',
      answer: 'ün, şöhret',
      quest: 'reputation'),
  Words(
      front: "The new law outlines the requirements for obtaining a work visa.",
      back: "Yeni yasa, çalışma vizesi almanın gerekliliklerini özetliyor.",
      list: 'B2',
      answer: 'ihtiyaç',
      quest: 'requirement'),
  Words(
      front:
          "The coast guard rescued the stranded sailors from the sinking ship.",
      back:
          "Sahil güvenlik, batmakta olan gemiden mahsur kalan denizcileri kurtardı.",
      list: 'B2',
      answer: 'kurtarmak',
      quest: 'rescue'),
  Words(
      front: "I need to reserve a table at the restaurant for tonight.",
      back: "Bu akşam için restoranda bir masa rezerve ettirmem gerekiyor.",
      list: 'B2',
      answer: 'ayırmak',
      quest: 'reserve'),
  Words(
      front: "She is a long-term resident of this city.",
      back: "O, bu şehrin uzun süreli sakinidir.",
      list: 'B2',
      answer: 'sakin',
      quest: 'resident'),
  Words(
      front: "The protesters are resisting the government's new policies.",
      back: "Protestocular, hükümetin yeni politikalarına direniyor.",
      list: 'B2',
      answer: 'direnmek',
      quest: 'resist'),
  Words(
      front: "He is determined to resolve the conflict peacefully.",
      back: "Sorunu barışçıl bir şekilde çözmeye kararlı.",
      list: 'B2',
      answer: 'kesin karar vermek',
      quest: 'resolve'),
  Words(
      front: "We spent a relaxing week at a beautiful beach resort.",
      back: "Güzel bir plaj tatilinde rahatlatıcı bir hafta geçirdik.",
      list: 'B2',
      answer: 'tatil yeri',
      quest: 'resort'),
  Words(
      front: "She was able to retain her job after the company downsized.",
      back: "Şirket küçüldükten sonra işini koruyabildi.",
      list: 'B2',
      answer: 'sürdürmek',
      quest: 'retain'),
  Words(
      front: "The investigation revealed a shocking conspiracy.",
      back: "Soruşturma şok edici bir komplo ortaya çıkardı.",
      list: 'B2',
      answer: 'meydana çıkarmak',
      quest: 'reveal'),
  Words(
      front:
          "The French Revolution was a major turning point in European history.",
      back: "Fransız Devrimi, Avrupa tarihinin önemli bir dönüm noktasıydı.",
      list: 'B2',
      answer: 'ihtilal',
      quest: 'Revolution'),
  Words(
      front: "He was given a reward for his bravery in saving the child.",
      back:
          "Çocuğu kurtarmadaki cesareti nedeniyle kendisine bir ödül verildi.",
      list: 'B2',
      answer: 'ödül',
      quest: 'reward'),
  Words(
      front: "The dancer moved to the rhythm of the music.",
      back: "Dansçı müziğin ritmine göre hareket etti.",
      list: 'B2',
      answer: 'ritim',
      quest: 'rhythm'),
  Words(
      front: "It is important to rid the world of poverty and hunger.",
      back: "Dünyayı yoksulluk ve açlıktan kurtarmak önemlidir.",
      list: 'B2',
      answer: 'temizlemek',
      quest: 'rid'),
  Words(
      front: "She is interested in learning about her family roots.",
      back: "Ailesinin köklerini öğrenmek ile ilgileniyor.",
      list: 'B2',
      answer: 'köken',
      quest: 'root'),
  Words(
      front: "The boxer completed the tenth and final round of the fight.",
      back: "Boksör, maçın onuncu ve son raundunu tamamladı.",
      list: 'B2',
      answer: 'yuvarlak',
      quest: 'round'),
  Words(
      front: "He rubbed his eyes to try and wake himself up.",
      back: "Kendini uyandırmak için gözlerini ovuşturdu.",
      list: 'B2',
      answer: 'sürtmek',
      quest: 'rub'),
  Words(
      front: "The tires are made of a durable type of rubber.",
      back: "Lastikler, dayanıklı bir kauçuktan yapılmıştır.",
      list: 'B2',
      answer: 'lastik',
      quest: 'rubber'),
  Words(
      front: "We grew up in a small rural village.",
      back: "Küçük bir kırsal köyde büyüdük.",
      list: 'B2',
      answer: 'kırsal',
      quest: 'rural'),
  Words(
      front: "Don't rush me, I need to take my time on this assignment.",
      back: "Acele etmeyin, bu ödev üzerinde zaman ayırmam gerekiyor.",
      list: 'B2',
      answer: 'acele etmek',
      quest: 'rush'),
  Words(
      front: "The scientist is analyzing a sample of the new drug.",
      back: "Bilim insanı, yeni ilacın bir örneğini analiz ediyor.",
      list: 'B2',
      answer: 'örnek',
      quest: 'sample'),
  Words(
      front: "There are many artificial satellites orbiting the Earth.",
      back: "Dünyanın etrafında dönen birçok yapay uydu var.",
      list: 'B2',
      answer: 'uydu',
      quest: 'satellite'),
  Words(
      front: "I am not satisfied with the quality of the work.",
      back: "İşin kalitesinden memnun değilim.",
      list: 'B2',
      answer: 'memnun',
      quest: 'satisfied'),
  Words(
      front: "The new policy aims to satisfy the needs of all citizens.",
      back:
          "Yeni politika, tüm vatandaşların ihtiyaçlarını karşılamayı amaçlıyor.",
      list: 'B2',
      answer: 'tatmin etmek',
      quest: 'satisfy'),
  Words(
      front:
          "The lifeguard's quick action resulted in the saving of a child's life.",
      back:
          "Cankurtaranın hızlı hareketi, bir çocuğun hayatının kurtarılmasıyla sonuçlandı.",
      list: 'B2',
      answer: 'kurtarma',
      quest: 'saving'),
  Words(
      front:
          "The map shows the scale of the destruction caused by the earthquake.",
      back: "Harita, depremin yol açtığı yıkımın ölçeğini gösteriyor.",
      list: 'B2',
      answer: 'ölçek',
      quest: 'scale'),
  Words(
      front: "Do you have a schedule for your upcoming presentations?",
      back: "Yaklaşan sunumlarınız için bir programınız var mı?",
      list: 'B2',
      answer: 'program',
      quest: 'schedule'),
  Words(
      front:
          "The criminal mastermind devised a complex scheme to rob the bank.",
      back:
          "Suç örgütü lideri, bankayı soymak için karmaşık bir plan düzenledi.",
      list: 'B2',
      answer: 'düzenlemek',
      quest: 'scheme'),
  Words(
      front:
          "The crowd started to scream when they saw their favorite band on stage.",
      back:
          "Kalabalık, favori gruplarını sahnede görünce çığlık atmaya başladı.",
      list: 'B2',
      answer: 'bağırmak',
      quest: 'scream'),
  Words(
      front: "He stared intently at the computer screen.",
      back: "Bilgisayar ekranına dikkatle baktı.",
      list: 'B2',
      answer: 'ekran',
      quest: 'screen'),
  Words(
      front: "Please take a seat and I will be with you shortly.",
      back: "Lütfen oturun, hemen yanınızda olacağım.",
      list: 'B2',
      answer: 'koltuk',
      quest: 'seat'),
  Words(
      front: "The company is a leader in the technology sector.",
      back: "Şirket, teknoloji sektöründe lider konumundadır.",
      list: 'B2',
      answer: 'sektör',
      quest: 'sector'),
  Words(
      front: "We need to take steps to secure our online accounts.",
      back:
          "Online hesaplarımızı güvence altına almak için adımlar atmamız gerekiyor.",
      list: 'B2',
      answer: 'sağlamlaştırmak',
      quest: 'secure'),
  Words(
      front: "He is seeking a new job that offers better opportunities.",
      back: "Daha iyi fırsatlar sunan yeni bir iş arıyor.",
      list: 'B2',
      answer: 'aramak',
      quest: 'seek'),
  Words(
      front: "You can select the language you prefer from the menu.",
      back: "Menüden tercih ettiğiniz dili seçebilirsiniz.",
      list: 'B2',
      answer: 'seçmek',
      quest: 'select'),
  Words(
      front: "There is a wide selection of clothes available in this store.",
      back: "Bu mağazada geniş bir seçki kıyafet bulunmaktadır.",
      list: 'B2',
      answer: 'seçme',
      quest: 'selection'),
  Words(
      front: "It's important to understand your own self-worth.",
      back: "Kendi değerinizi anlamak önemlidir.",
      list: 'B2',
      answer: 'öz',
      quest: 'self'),
  Words(
      front: "The senior manager gave a presentation to the team.",
      back: "Kıdemli yönetici ekibe bir sunum yaptı.",
      list: 'B2',
      answer: 'kıdemli',
      quest: 'senior'),
  Words(
      front: "I could sense that he was feeling nervous about the interview.",
      back: "Mülakat konusunda gergin hissettiğini hissedebiliyordum.",
      list: 'B2',
      answer: 'algılamak',
      quest: 'sense'),
  Words(
      front:
          "This is a sensitive topic, so please be mindful of your language.",
      back:
          "Bu hassas bir konu, bu yüzden lütfen kullandığınız dile dikkat edin.",
      list: 'B2',
      answer: 'hassas',
      quest: 'sensitive'),
  Words(
      front: "The judge issued a ten-year sentence for the crime.",
      back: "Hakim suç için on yıllık bir ceza verdi.",
      list: 'B2',
      answer: 'cümle',
      quest: 'sentence'),
  Words(
      front:
          "The sequence of events leading up to the accident is still being investigated.",
      back: "Kazaya yol açan olayların sırası hala araştırılıyor.",
      list: 'B2',
      answer: 'birbiri ardından gelme',
      quest: 'sequence'),
  Words(
      front:
          "We will have a brainstorming session to discuss new ideas for the project.",
      back:
          "Projeye yönelik yeni fikirleri tartışmak için bir beyin fırtınası oturumu yapacağız.",
      list: 'B2',
      answer: 'oturum',
      quest: 'session'),
  Words(
      front:
          "The refugees are hoping to settle in a safe and peaceful country.",
      back: "Mülteciler güvenli ve huzurlu bir ülkeye yerleşmeyi umuyorlar.",
      list: 'B2',
      answer: 'yerleşmek',
      quest: 'settle'),
  Words(
      front: "The winter brought a period of severe weather conditions.",
      back: "Kış, şiddetli hava koşullarının yaşandığı bir dönem getirdi.",
      list: 'B2',
      answer: 'haşin, sert',
      quest: 'severe'),
  Words(
      front: "The pond is quite shallow, so you can easily stand up in it.",
      back: "Gölet oldukça sığ, bu yüzden içinde kolayca durabilirsiniz.",
      list: 'B2',
      answer: 'sığ',
      quest: 'shallow'),
  Words(
      front: "He felt a deep sense of shame for his actions.",
      back: "Yaptıklarından dolayı derin bir utanç duydu.",
      list: 'B2',
      answer: 'utanma',
      quest: 'shame'),
  Words(
      front:
          "Exercise can help you to shape your body and improve your fitness.",
      back:
          "Egzersiz, vücudunuzu şekillendirmenize ve formunuzu geliştirmenize yardımcı olabilir.",
      list: 'B2',
      answer: 'şekil vermek',
      quest: 'shape'),
  Words(
      front: "The homeless man found shelter in a doorway for the night.",
      back: "Evsiz adam, gece boyunca bir kapının altında barınak buldu.",
      list: 'B2',
      answer: 'barınak',
      quest: 'shelter'),
  Words(
      front: "She is working the night shift at the hospital this week.",
      back: "Bu hafta hastanede gece vardiyasında çalışıyor.",
      list: 'B2',
      answer: 'vardiya',
      quest: 'shift'),
  Words(
      front: "The cargo ship is carrying a shipment of grain to Africa.",
      back: "Kargo gemisi Afrika'ya bir tahıl sevkiyatı taşıyor.",
      list: 'B2',
      answer: 'gemi',
      quest: 'ship'),
  Words(
      front: "There was a shooting in the city center yesterday.",
      back: "Dün şehir merkezinde bir silahlı çatışma yaşandı.",
      list: 'B2',
      answer: 'ateş etme',
      quest: 'shooting'),
  Words(
      front: "He missed the winning shot by a hair's breadth.",
      back: "Kazanan atışı kılına kadar kaçırdı.",
      list: 'B2',
      answer: 'atış',
      quest: 'shot'),
  Words(
      front:
          "The discovery of a new planet is a significant scientific development.",
      back: "Yeni bir gezegenin keşfi, önemli bir bilimsel gelişmedir.",
      list: 'B2',
      answer: 'dikkate değer',
      quest: 'significant'),
  Words(
      front:
          "Climate change has significantly impacted the planet's ecosystems.",
      back:
          "İklim değişikliği, gezegenin ekosistemlerini önemli ölçüde etkiledi.",
      list: 'B2',
      answer: 'önemli ölçüde',
      quest: 'significantly'),
  Words(
      front: "The room fell silent as everyone waited for the announcement.",
      back: "Herkes duyuruyu beklerken oda sessizliğe gömüldü.",
      list: 'B2',
      answer: 'sessizlik',
      quest: 'silent'),
  Words(
      front: "The dress was made of a soft and luxurious silk fabric.",
      back: "Elbise yumuşak ve lüks bir ipek kumaştan yapılmıştı.",
      list: 'B2',
      answer: 'ipek',
      quest: 'silk'),
  Words(
      front: "He offered his sincere condolences to the grieving family.",
      back: "Yas tutan aileye içten taziyelerini sundu.",
      list: 'B2',
      answer: 'içten',
      quest: 'sincere'),
  Words(
      front: "Slavery was a brutal practice that existed for centuries.",
      back: "Kölelik, yüzyıllardır var olan acımasız bir uygulamadır.",
      list: 'B2',
      answer: 'köle',
      quest: 'Slave'),
  Words(
      front: "Be careful not to slide on the wet floor.",
      back: "Islak zeminde kaymamaya dikkat edin.",
      list: 'B2',
      answer: 'kaydırma',
      quest: 'slide'),
  Words(
      front: "There has been a slight improvement in his condition.",
      back: "Durumunda hafif bir iyileşme oldu.",
      list: 'B2',
      answer: 'hafif',
      quest: 'slight'),
  Words(
      front: "She slipped on the ice and fell down.",
      back: "Buz üzerinde kaydı ve düştü.",
      list: 'B2',
      answer: 'kaymak',
      quest: 'slip'),
  Words(
      front: "The car was slowly sliding down the steep slope.",
      back: "Araba dik yamaçtan yavaşça aşağı kayıyordu.",
      list: 'B2',
      answer: 'slope',
      quest: 'slope'),
  Words(
      front: "Solar energy is a renewable and sustainable source of power.",
      back:
          "Güneş enerjisi, yenilenebilir ve sürdürülebilir bir enerji kaynağıdır.",
      list: 'B2',
      answer: 'güneş',
      quest: 'Solar'),
  Words(
      front: "I am somewhat surprised by your decision.",
      back: "Kararınıza biraz şaşırdım.",
      list: 'B2',
      answer: 'birazcık',
      quest: 'somewhat'),
  Words(
      front: "The music touched his soul and brought him peace.",
      back: "Müzik ruhuna dokundu ve ona huzur verdi.",
      list: 'B2',
      answer: 'ruh',
      quest: 'soul'),
  Words(
      front:
          "There are millions of different species of plants and animals on Earth.",
      back: "Dünyada milyonlarca farklı bitki ve hayvan türü var.",
      list: 'B2',
      answer: 'tür',
      quest: 'species'),
  Words(
      front: "The car was traveling at a high speed down the highway.",
      back: "Araba, otoyolda yüksek hızla ilerliyordu.",
      list: 'B2',
      answer: 'hız',
      quest: 'speed'),
  Words(
      front: "He is on a journey of spiritual discovery.",
      back: "Manevi bir keşif yolculuğunda.",
      list: 'B2',
      answer: 'ruhsal',
      quest: 'spiritual'),
  Words(
      front: "The cake was split into several slices for everyone to enjoy.",
      back: "Pasta, herkesin tadını çıkarması için birkaç dilime bölündü.",
      list: 'B2',
      answer: 'bölmek',
      quest: 'split'),
  Words(
      front: "I noticed a small spot of paint on my shirt.",
      back: "Gömleğimde küçük bir boya lekesi fark ettim.",
      list: 'B2',
      answer: 'leke',
      quest: 'spot'),
  Words(
      front: "The rumor quickly spread throughout the town.",
      back: "Söylenti hızla kasabaya yayıldı.",
      list: 'B2',
      answer: 'yaymak',
      quest: 'spread'),
  Words(
      front: "The economy is in a stable state at the moment.",
      back: "Ekonomi şu anda durağan bir durumda.",
      list: 'B2',
      answer: 'durağan',
      quest: 'stable'),
  Words(
      front: "The dancers are practicing on stage.",
      back: "Dansçılar sahnede pratik yapıyorlar.",
      list: 'B2',
      answer: 'sahnelemek',
      quest: 'stage'),
  Words(
      front: "Does this offer still stand?",
      back: "Bu teklif hala geçerli mi?",
      list: 'B2',
      answer: '(teklif)geçerli olmak',
      quest: 'stand'),
  Words(
      front: "He stared blankly at the wall for a long time.",
      back: "Uzun bir süre boş bir şekilde duvara baktı.",
      list: 'B2',
      answer: 'gözü dalmak',
      quest: 'stare'),
  Words(
      front: "The ship maintained a steady course throughout the night.",
      back: "Gemi gece boyunca sabit bir rotada seyretti.",
      list: 'B2',
      answer: 'sabit durum',
      quest: 'steady'),
  Words(
      front: "The building is made of reinforced steel.",
      back: "Bina, takviyeli çelikten yapılmıştır.",
      list: 'B2',
      answer: 'çelik',
      quest: 'steel'),
  Words(
      front: "The path leading up the mountain was very steep and challenging.",
      back: "Dağa çıkan yol çok dik ve zordu.",
      list: 'B2',
      answer: 'dik',
      quest: 'steep'),
  Words(
      front:
          "Take a step back and look at the situation from a different perspective.",
      back: "Geriye bir adım atın ve duruma farklı bir açıdan bakın.",
      list: 'B2',
      answer: 'adım',
      quest: 'step'),
  Words(
      front: "The candy bar was too sticky to eat.",
      back: "Şekerleme yemek için çok yapışkandı.",
      list: 'B2',
      answer: 'yapışkan',
      quest: 'sticky'),
  Words(
      front:
          "He felt a bit stiff after sitting in the same position for hours.",
      back: "Saatlerce aynı pozisyonda oturduktan sonra biraz çetin hissetti.",
      list: 'B2',
      answer: 'çetin',
      quest: 'stiff'),
  Words(
      front: "There is a clear stream running through the forest.",
      back: "Ormandan geçen berrak bir dere var.",
      list: 'B2',
      answer: 'dere',
      quest: 'stream'),
  Words(
      front: "She stretched her arms above her head to loosen up her muscles.",
      back: "Kaslarını gevşetmek için kollarını başının üstüne uzattı.",
      list: 'B2',
      answer: 'uzatmak',
      quest: 'stretch'),
  Words(
      front: "The teacher has a very strict policy on classroom behavior.",
      back:
          "Öğretmenin sınıf içi davranışları konusunda çok sıkı bir politikası var.",
      list: 'B2',
      answer: 'sıkı',
      quest: 'strict'),
  Words(
      front:
          "The workers went on strike to protest the unfair working conditions.",
      back:
          "İşçiler, adil olmayan çalışma koşullarını protesto etmek için greve gitti.",
      list: 'B2',
      answer: 'çarpmak',
      quest: 'strike'),
  Words(
      front: "The building has a strong and stable structure.",
      back: "Binanın güçlü ve sağlam bir yapısı var.",
      list: 'B2',
      answer: 'yapılandırmak',
      quest: 'structure'),
  Words(
      front: "For some people, losing weight is a significant struggle. ",
      back: "Bazı insanlar için kilo vermek önemli bir mücadeledir.",
      list: 'B2',
      answer: 'çabalamak',
      quest: 'struggle'),
  Words(
      front: "The backpack was stuffed with all her belongings for the trip.",
      back: "Sırt çantası, yolculuk için tüm eşyalarıyla doluydu.",
      list: 'B2',
      answer: 'tıkınmak, şey',
      quest: 'stuff'),
  Words(
      front: "What is the subject of your research paper?",
      back: "Araştırma makalenizin konusu nedir?",
      list: 'B2',
      answer: 'ders, özne',
      quest: 'subject'),
  Words(
      front: "He submitted his application for the job online.",
      back: "İş başvurusunu online olarak gönderdi.",
      list: 'B2',
      answer: 'sunmak, göndermek',
      quest: 'submit'),
  Words(
      front: "The sum of two and three is five.",
      back: "İki ve üçün toplamı beş",
      list: 'B2',
      answer: 'toplam',
      quest: 'sum'),
  Words(
      front: "The surgery was successful, and the patient is recovering well.",
      back: "Ameliyat başarılı geçti ve hasta iyileşiyor.",
      list: 'B2',
      answer: 'ameliyat',
      quest: 'surgery'),
  Words(
      front:
          "The enemy forces surrounded the castle, cutting off all escape routes.",
      back: "Düşman güçleri kaleyi kuşattı ve tüm kaçış yollarını kesti.",
      list: 'B2',
      answer: 'kuşatmak',
      quest: 'surround'),
  Words(
      front:
          "The hikers enjoyed the beautiful scenery of the surrounding mountains.",
      back:
          "Yürüyüşçüler, çevredeki dağların güzel manzarasının tadını çıkardı.",
      list: 'B2',
      answer: 'çevre',
      quest: 'surrounding'),
  Words(
      front:
          "The company is conducting a survey to gather feedback from customers.",
      back:
          "Şirket, müşterilerden geri bildirim toplamak için bir araştırma yürütüyor.",
      list: 'B2',
      answer: 'araştırma',
      quest: 'survey'),
  Words(
      front: "I suspect that he is not telling the whole truth.",
      back: "Sanırım bütün gerçeği söylemiyor.",
      list: 'B2',
      answer: 'şüphelenmek',
      quest: 'suspect'),

  Words(
      front: "High winds sweep across the desert.",
      back: "Şiddetli rüzgarlar çölü süpürüyor.",
      list: 'B2',
      answer: 'süpürmek',
      quest: 'sweep'),
  Words(
      front: "It's time to switch on the lights - it's getting dark.",
      back: "Işıkları açma zamanı - hava kararıyor.",
      list: 'B2',
      answer: 'değiştirmek',
      quest: 'switch'),
  Words(
      front: "My grandmother told me a bedtime tale about a brave princess.",
      back: "Büyükannem bana cesur bir prenses hakkında bir masal anlattı.",
      list: 'B2',
      answer: 'masal',
      quest: 'tale'),
  Words(
      front: "The car needs a full tank of gas before we go on a road trip.",
      back:
          "Yolculuğa çıkmadan önce arabanın deposuna dolu bir tank gazyağı lazım.",
      list: 'B2',
      answer: 'depoya koymak',
      quest: 'tank'),
  Words(
      front: "The soldier aimed his rifle at the target and fired.",
      back: "Asker tüfeğini hedefe doğrulttu ve ateş etti.",
      list: 'B2',
      answer: 'hedef',
      quest: 'target'),
  Words(
      front: "She ripped a piece of paper out of her notebook.",
      back: "Not defterinden bir sayfa kopardı.",
      list: 'B2',
      answer: 'yırtılmak',
      quest: 'tear'),
  Words(
      front:
          "This is just a temporary solution until we can find a permanent fix.",
      back: "Bu, kalıcı bir çözüm bulana kadar geçici bir çözüm.",
      list: 'B2',
      answer: 'geçici',
      quest: 'temporary'),
  Words(
      front: "The word 'democracy' is a complex term with a long history.",
      back: "Demokrasi kelimesi, uzun geçmişi olan karmaşık bir terimdir.",
      list: 'B2',
      answer: 'isimlendirmek',
      quest: 'term'),
  Words(
      front: "The bomb threat forced the evacuation of the building.",
      back: "Bomba tehdidi binanın tahliyesine zorladı.",
      list: 'B2',
      answer: 'tehdit',
      quest: 'threat'),
  Words(
      front: "He threatened to quit his job if they didn't give him a raise.",
      back: "Eğer zam yapmazlarsa işinden ayrılacağıyla tehdit etti.",
      list: 'B2',
      answer: 'tehdit etmek',
      quest: 'threaten'),
  Words(
      front:
          "Thus, we can see that education is essential for a successful life.",
      back:
          "Böylelikle, eğitimin başarılı bir yaşam için gerekli olduğunu görebiliriz.",
      list: 'B2',
      answer: 'Böylelikle',
      quest: 'Thus'),
  Words(
      front: "How many times have you seen this movie?",
      back: "Bu filmi kaç kez izledin?",
      list: 'B2',
      answer: 'kez, kere',
      quest: 'time'),
  Words(
      front:
          "The book has an interesting title that captures the reader's attention.",
      back: "Kitabın, okuyucuyu dikkatini çeken ilginç bir başlığı var.",
      list: 'B2',
      answer: 'başlık',
      quest: 'title'),
  Words(
      front: "This was a tough decision, but I had to make it.",
      back: "Bu zor bir karardı, ama vermek zorunda kaldım.",
      list: 'B2',
      answer: 'zorlu',
      quest: 'tough'),
  Words(
      front: "The police are tracking the movements of the suspect.",
      back: "Polis, şüphelinin hareketlerini izliyor.",
      list: 'B2',
      answer: 'izlemek',
      quest: 'track'),
  Words(
      front: "The caterpillar will transform into a butterfly in a few weeks.",
      back: "Tırtıl birkaç hafta içinde kelebeğe dönüşecek.",
      list: 'B2',
      answer: 'dönüşmek',
      quest: 'transform'),
  Words(
      front:
          "The transition from childhood to adulthood can be a challenging time.",
      back: "Çocukluktan yetişkinliğe geçiş zorlu bir dönem olabilir.",
      list: 'B2',
      answer: 'geçiş',
      quest: 'transition'),
  Words(
      front: "The defendant is on trial for murder.",
      back: "Sanık, cinayet davasında yargılanıyor.",
      list: 'B2',
      answer: 'yargılama',
      quest: 'trial'),
  Words(
      front: "We are planning a trip to Italy next summer.",
      back: "Önümüzdeki yaz İtalya'ya bir gezi planlıyoruz.",
      list: 'B2',
      answer: 'seyahat',
      quest: 'trip'),
  Words(
      front: "He is having trouble sleeping at night.",
      back: "Geceleri uyumakta sorun yaşıyor.",
      list: 'B2',
      answer: 'sorun',
      quest: 'trouble'),
  Words(
      front: "I truly believe that everyone deserves a second chance.",
      back: "Herkesin ikinci bir şansı hak ettiğine gerçekten inanıyorum.",
      list: 'B2',
      answer: 'tamamen',
      quest: 'truly'),
  Words(
      front: "I trust her completely with my most important secrets.",
      back: "Ona en önemli sırlarımı tamamen güveniyorum.",
      list: 'B2',
      answer: 'güvenmek',
      quest: 'trust'),
  Words(
      front: "I will try my best to finish the project on time.",
      back: "Projeyi zamanında bitirmek için elimden geleni deneyeceğim.",
      list: 'B2',
      answer: 'denemek',
      quest: 'try'),
  Words(
      front: "He was humming a catchy tune while he worked.",
      back: "Çalışırken akılda kalıcı bir melodi mırıldanıyordu.",
      list: 'B2',
      answer: 'melodi',
      quest: 'tune'),
  Words(
      front: "The rescue team dug a tunnel to reach the trapped miners.",
      back:
          "Kurtarma ekibi, mahsur kalan madencilere ulaşmak için bir tünel kazdı.",
      list: 'B2',
      answer: 'tünel',
      quest: 'tunnel'),
  Words(
      front:
          "After a six-week trial, the accused was ultimately convicted of murder. ",
      back:
          "Altı haftalık bir duruşmanın ardından sanık, sonunda cinayetten suçlu bulundu.",
      list: 'B2',
      answer: 'sonunda',
      quest: 'ultimately'),
  Words(
      front: "He was knocked unconscious after being hit in the head.",
      back: "Başına vurulduktan sonra kendinden geçti.",
      list: 'B2',
      answer: 'kendinden geçmiş',
      quest: 'unconscious'),
  Words(
      front: "The arrival of the storm was an unexpected event.",
      back: "Fırtınanın gelişi beklenmedik bir olaydı.",
      list: 'B2',
      answer: 'beklenmedik',
      quest: 'unexpected'),
  Words(
      front: "Each snowflake has a unique and beautiful design.",
      back: "Her kar tanesinin eşsiz ve güzel bir tasarımı vardır.",
      list: 'B2',
      answer: 'benzersiz',
      quest: 'unique'),
  Words(
      front:
          "Scientists are constantly trying to unravel the mysteries of the universe.",
      back:
          "Bilimciler, evrenin gizemlerini çözmeye sürekli olarak çalışıyorlar.",
      list: 'B2',
      answer: 'evren',
      quest: 'universe'),
  Words(
      front: "The explorers ventured into the unknown territory.",
      back: "Kaşifler bilinmeyene doğru yolculuk yaptılar.",
      list: 'B2',
      answer: 'bilinmeyen',
      quest: 'unknown'),
  Words(
      front: "Live on the upper floor if you prefer a quieter environment.",
      back: "Daha sakin bir ortam istiyorsanız üst katta oturun.",
      list: 'B2',
      answer: 'yukarı',
      quest: 'upper'),
  Words(
      front: "The arrow shot upwards and hit the target exactly.",
      back: "Ok yukarı doğru fırladı ve hedefe tam olarak isabet etti.",
      list: 'B2',
      answer: 'yukarıya',
      quest: 'upwards'),
  Words(
      front: "Tokyo is a large and bustling urban city.",
      back: "Tokyo, kalabalık ve hareketli bir şehirsel şehirdir.",
      list: 'B2',
      answer: 'şehirsel',
      quest: 'urban'),
  Words(
      front: "He felt a sudden urge to eat chocolate.",
      back: "Aniden çikolata yeme dürtüsü hissetti.",
      list: 'B2',
      answer: 'dürtü',
      quest: 'urge'),
  Words(
      front: "Honesty is a core value that we should all strive for.",
      back: "Dürüstlük, hepimizin uğraşması gereken temel bir değerdir.",
      list: 'B2',
      answer: 'değer',
      quest: 'value'),
  Words(
      front: "The weather can vary greatly depending on the location.",
      back: "Hava durumu, konuma göre büyük ölçüde değişebilir.",
      list: 'B2',
      answer: 'farklı olmak',
      quest: 'vary'),
  Words(
      front: "The ocean is a vast and mysterious place.",
      back: "Okyanus, engin ve gizemli bir yerdir.",
      list: 'B2',
      answer: 'vast',
      quest: 'vast'),
  Words(
      front:
          "The concert will be held at a large venue that can accommodate a large crowd.",
      back:
          "Konser, kalabalık bir kitleyi barındırabilecek geniş bir mekanda düzenlenecek.",
      list: 'B2',
      answer: 'olayın gerçekleştiği yer',
      quest: 'venue'),
  Words(
      front: "It was a very hot day, so we decided to stay indoors.",
      back: "Hava çok sıcaktı, bu yüzden içeride kalmaya karar verdik.",
      list: 'B2',
      answer: 'çok',
      quest: 'very'),
  Words(
      front: "The message was sent via email.",
      back: "Mesaj e-posta yoluyla gönderildi.",
      list: 'B2',
      answer: 'vasıtasıyla',
      quest: 'via'),
  Words(
      front: "The team celebrated their victory with a big party.",
      back: "Takım, zaferlerini büyük bir partiyle kutladı.",
      list: 'B2',
      answer: 'başarı',
      quest: 'victory'),
  Words(
      front:
          "The news report showed scenes of violence in the war-torn country.",
      back: "Haber raporu, savaşın yıktığı ülkede şiddet sahnelerini gösterdi.",
      list: 'B2',
      answer: 'şiddet',
      quest: 'violence'),
  Words(
      front:
          "They met in a virtual reality world created by computer software.",
      back:
          "Bilgisayar yazılımı tarafından oluşturulan sanal gerçeklik dünyasında buluştular.",
      list: 'B2',
      answer: 'sanal, asıl',
      quest: 'virtual'),
  Words(
      front:
          "Having a clear vision for the future is important for achieving your goals.",
      back:
          "Gelecek için net bir vizyona sahip olmak, hedeflerinize ulaşmada önemlidir.",
      list: 'B2',
      answer: 'görme',
      quest: 'vision'),
  Words(
      front: "The movie included some stunning visual effects.",
      back: "Filmde bazı çarpıcı görsel efektler vardı.",
      list: 'B2',
      answer: 'görsel',
      quest: 'visual'),
  Words(
      front: "Clean water is a vital resource that is essential for life.",
      back: "Temiz su, yaşam için gerekli olan hayati bir kaynaktır.",
      list: 'B2',
      answer: 'yaşamsal',
      quest: 'vital'),
  Words(
      front: "The employee asked for a raise in his wage.",
      back: "Çalışan, maaşına zam istedi.",
      list: 'B2',
      answer: 'maaş',
      quest: 'wage'),
  Words(
      front: "There are many different ways to solve this problem.",
      back: "Bu problemi çözmenin birçok farklı yolu var.",
      list: 'B2',
      answer: 'yol',
      quest: 'way'),
  Words(
      front: "He felt a sudden weakness after the long run.",
      back: "Uzun koşudan sonra ani bir halsizlik hissetti.",
      list: 'B2',
      answer: 'halsizlik',
      quest: 'weakness'),
  Words(
      front: "He comes from a wealthy family.",
      back: "Zengin bir aileden geliyor.",
      list: 'B2',
      answer: 'varlık',
      quest: 'wealth'),
  Words(
      front: "She is intelligent, whereas her brother is more athletic.",
      back: "Akıllı, oysa kardeşi daha atletik.",
      list: 'B2',
      answer: 'oysaki',
      quest: 'whereas'),
  Words(
      front: "You can find this information wherever you look online.",
      back:
          "Bu bilgiyi çevrimiçi olarak nereye bakarsanız bakın bulabilirsiniz.",
      list: 'B2',
      answer: 'nerede',
      quest: 'wherever'),
  Words(
      front: "They whispered secrets to each other in the dark.",
      back: "Karanlıkta birbirlerine fısıldaşarak sırlar söylediler.",
      list: 'B2',
      answer: 'fısıldamak',
      quest: 'whisper'),
  Words(
      front: "To whom did you give the gift?",
      back: "Hediyeyi kime verdin?",
      list: 'B2',
      answer: 'kime',
      quest: 'whom'),
  Words(
      front:
          "The news of the celebrity's death spread widely across social media.",
      back: "Ünlünün ölüm haberi sosyal medyada geniş çapta yayıldı.",
      list: 'B2',
      answer: 'genişçe',
      quest: 'widely'),
  Words(
      front: "The national park is home to a wide variety of wildlife.",
      back: "Milli park çok çeşitli yaban hayatına ev sahipliği yapmaktadır.",
      list: 'B2',
      answer: 'yaban hayatı',
      quest: 'wildlife'),
  Words(
      front: "Are you willing to help me with this project?",
      back: "Bu projeye bana yardım etmeye istekli misin?",
      list: 'B2',
      answer: 'gönüllü',
      quest: 'willing'),
  Words(
      front: "The strong wind blew the leaves off the trees.",
      back: "Şiddetli rüzgar, yaprakları ağaçlardan savurdu.",
      list: 'B2',
      answer: 'rüzgar',
      quest: 'wind'),
  Words(
      front: "The electrician wired the new house for electricity.",
      back: "Elektrikçi, yeni evi elektrik için kabloladı.",
      list: 'B2',
      answer: 'tel takmak',
      quest: 'wire'),
  Words(
      front: "The old man was a wise and respected leader in his community.",
      back: "Yaşlı adam, toplumunda bilge ve saygı duyulan bir liderdi.",
      list: 'B2',
      answer: 'bilge',
      quest: 'wise'),
  Words(
      front: "He witnessed the accident happen right in front of him.",
      back: "Kazanın tam önünde gerçekleştiğine şahit oldu.",
      list: 'B2',
      answer: 'şahit olmak',
      quest: 'witness'),
  Words(
      front: "The situation is bad, but it could be worse.",
      back: "Durum kötü ama daha da kötüye gidebilir.",
      list: 'B2',
      answer: 'daha kötüsü',
      quest: 'worse'),
  Words(
      front: "That was the worst experience of my life",
      back: "Hayatımın en kötü deneyimiydi.",
      list: 'B2',
      answer: 'en kötü',
      quest: 'worst' // replaced with a synonym
      ),
  Words(
      front: "This painting is worth a fortune.",
      back: "Bu tablo bir servet değerinde.",
      list: 'B2',
      answer: 'değer',
      quest: 'worth'),
  Words(
      front: "The doctor cleaned and bandaged the wound on his arm.",
      back: "Doktor kolundaki yarayı temizleyip sardı.",
      list: 'B2',
      answer: 'yaralamak',
      quest: 'wound'),
  Words(
      front: "She wrapped herself in a warm blanket to keep warm.",
      back: "Sıcak kalmak için kendisini sıcak bir battaniyeye sardı.",
      list: 'B2',
      answer: 'sarmak',
      quest: 'wrap' // replaced with a synonym
      ),
  Words(
      front: "I think you might be wrong about this.",
      back: "Sanırım bunda yanılıyor olabilirsin.",
      list: 'B2',
      answer: 'yanlış',
      quest: 'wrong'),
  Words(
      front: "The work is not finished yet, there is still more to do.",
      back: "İş henüz bitmedi, yapılacak daha çok şey var.",
      list: 'B2',
      answer: 'henüz',
      quest: 'yet'),
  Words(
      front: "The disaster zone was completely destroyed by the hurricane.",
      back: "Felaket bölgesi kasırga tarafından tamamen yok edildi.",
      list: 'B2',
      answer: 'bölge',
      quest: 'zone'),
  Words(
    front: "I can help you with that. Absolutely!",
    back: "Size bunda yardımcı olabilirim. Kesinlikle!",
    list: 'B1',
    answer: 'kesinlikle',
    quest: 'Absolutely',
  ),
  Words(
    front: "He is pursuing an academic career in history.",
    back: "Tarih alanında akademik bir kariyer peşinde.",
    list: 'B1',
    answer: 'akademik',
    quest: 'academic',
  ),
  Words(
    front: "Students need easy access to online learning materials.",
    back:
        "Öğrencilerin çevrimiçi öğrenme materyallerine kolay erişime ihtiyacı vardır.",
    list: 'B1',
    answer: 'erişim',
    quest: 'access',
  ),
  Words(
    front: "Have you booked your accommodation for the trip yet?",
    back: "Gezi için konaklamanızı henüz ayırtın mı?",
    list: 'B1',
    answer: 'konaklama',
    quest: 'accommodation',
  ),
  Words(
    front: "Please check your bank account balance before making the purchase.",
    back:
        "Satın alma işlemini yapmadan önce lütfen banka hesap bakiyenizi kontrol edin.",
    list: 'B1',
    answer: 'hesap',
    quest: 'account',
  ),
  Words(
    front: "Winning the competition was a great achievement for her.",
    back: "Yarışmayı kazanmak onun için büyük bir başarıydı.",
    list: 'B1',
    answer: 'başar',
    quest: 'achievement',
  ),
  Words(
    front:
        "He performed a kind act by helping the elderly woman cross the street.",
    back:
        "Yaşlı kadının karşıya geçmesine yardım ederek nazik bir davranışta bulundu.",
    list: 'B1',
    answer: 'eylem',
    quest: 'act',
  ),
  Words(
    front: "Have you seen the new ad for that car on TV?",
    back: "Televizyonda o arabanın yeni reklamını gördünüz mü?",
    list: 'B1',
    answer: 'reklam',
    quest: 'ad',
  ),
  Words(
    front: "In addition to his salary, he also receives a bonus every year.",
    back: "Maaşına ek olarak, her yıl bir de bonus alıyor.",
    list: 'B1',
    answer: 'ek, ilave',
    quest: 'addition',
  ),
  Words(
    front: "I really admire her talent and dedication.",
    back: "Onun yeteneğine ve özverisine gerçekten hayranlık duyuyorum.",
    list: 'B1',
    answer: 'hayranlık duymak',
    quest: 'admire',
  ),
  Words(
    front: "He finally admitted that he was wrong.",
    back: "Sonunda yanıldığını itiraf etti.",
    list: 'B1',
    answer: 'kabul etmek',
    quest: 'admit',
  ),
  Words(
    front:
        "This is an advanced course, so it requires a strong foundation in English.",
    back:
        "Bu ileri bir kurs olduğu için, İngilizcede sağlam bir temele ihtiyaç duyuyor.",
    list: 'B1',
    answer: 'ileri',
    quest: 'advanced',
  ),
  Words(
    front: "My teacher often advises me to practice speaking English more.",
    back:
        "Öğretmenim bana sık sık İngilizce konuşma pratiği yapmamı öğüt verir.",
    list: 'B1',
    answer: 'öğüt vermek',
    quest: 'advise',
  ),
  Words(
    front: "Can you afford to buy a new car right now?",
    back: "Şu anda yeni bir araba almaya paranız yeter mi?",
    list: 'B1',
    answer: 'parası yetmek',
    quest: 'afford',
  ),
  Words(
    front: "What is your age?",
    back: "Yaşınız kaç?",
    list: 'B1',
    answer: 'yaş',
    quest: 'age',
  ),
  Words(
    front: "The old man seemed aged and frail.",
    back: "Yaşlı adam yaşlı ve güçsüz görünüyordu.",
    list: 'B1',
    answer: 'yaşlı',
    quest: 'aged',
  ),
  Words(
    front: "I hired a travel agent to book my flight and hotel.",
    back: "Uçuşumu ve otetimi rezerve etmek için bir seyahat acentesi tuttum.",
    list: 'B1',
    answer: 'ajan',
    quest: 'agent',
  ),
  Words(
    front: "We finally reached an agreement on the price.",
    back: "Fiyat konusunda sonunda bir anlaşmaya vardık.",
    list: 'B1',
    answer: 'anlaşma',
    quest: 'agreement',
  ),
  Words(
    front: "What are your plans for the future? What lies ahead?",
    back: "Geleceğe yönelik planlarınız neler? Önümüzde neler var?",
    list: 'B1',
    answer: 'ilerisi',
    quest: 'ahead',
  ),
  Words(
    front: "My aim is to become a doctor.",
    back: "Amacım doktor olmaktır.",
    list: 'B1',
    answer: 'hedef ,amaç',
    quest: 'aim',
  ),
  Words(
    front: "I was amazed by the beauty of the Taj Mahal.",
    back: "Tac Mahal'in güzelliğine hayran kaldım.",
    list: 'B1',
    answer: 'şaşırmış',
    quest: 'amazed',
  ),
  Words(
    front: "He has a lot of ambition and is always striving to succeed.",
    back: "Çok hırslıdır ve her zaman başarılı olmak için çabalar.",
    list: 'B1',
    answer: 'hırs',
    quest: 'ambition',
  ),
  Words(
    front: "She is an ambitious young woman with a bright future ahead of her.",
    back: "O, parlak bir geleceği olan hırslı bir genç kadın.",
    list: 'B1',
    answer: 'hırslı',
    quest: 'ambitious',
  ),
  Words(
    front: "The teacher asked us to analyse a poem in class today.",
    back: "Öğretmen bugün sınıfta bir şiiri analiz etmemizi istedi.",
    list: 'B1',
    answer: 'incelemek',
    quest: 'analyse',
  ),
  Words(
    front:
        "The report provides a detailed analysis of the company's financial situation.",
    back: "Rapor, şirketin mali durumu hakkında ayrıntılı bir analiz sunar.",
    list: 'B1',
    answer: 'analiz',
    quest: 'analysis',
  ),
  Words(
    front:
        "The company announced that they are going to launch a new product next month.",
    back: "Şirket, önümüzdeki ay yeni bir ürün piyasaya süreceğini duyurdu.",
    list: 'B1',
    answer: 'duyurmak',
    quest: 'announce',
  ),
  Words(
    front: "Don't worry about the noise, it won't annoy the baby.",
    back: "Ses için endişelenme, bebeği rahatsız etmeyecek.",
    list: 'B1',
    answer: 'rahatsız etmek',
    quest: 'annoy',
  ),
  Words(
    front: "I'm feeling a bit annoyed because the bus is late.",
    back: "Otobüs geç geldiği için biraz sinirliyim.",
    list: 'B1',
    answer: 'sinirli',
    quest: 'annoyed',
  ),
  Words(
    front: "The constant ringing of the phone is very annoying.",
    back: "Telefonun sürekli çalması çok rahatsız edici.",
    list: 'B1',
    answer: 'rahatsız edici',
    quest: 'annoying',
  ),
  Words(
    front: "He took the table apart before moving it to his new house.",
    back: "Masayı, parçalara ayrılmış halde yeni evine taşıdı.",
    list: 'B1',
    answer: 'ayrı',
    quest: 'apart',
  ),
  Words(
    front: "I would like to apologize for being late.",
    back: "Geç kaldığım için özür dilemek istiyorum.",
    list: 'B1',
    answer: 'özür dilemek',
    quest: 'apologize',
  ),
  Words(
    front: "He submitted an application for the job.",
    back: "İşe başvuru yaptı.",
    list: 'B1',
    answer: 'uygulama, başvuru',
    quest: 'application',
  ),
  Words(
    front: "Do you have an appointment with the doctor this afternoon?",
    back: "Bu öğleden sonra doktorla randevunuz var mı?",
    list: 'B1',
    answer: 'randevu, tayin',
    quest: 'appointment',
  ),
  Words(
    front: "I really appreciate your help with this project.",
    back: "Bu projede bana verdiğiniz yardımı gerçekten takdir ediyorum.",
    list: 'B1',
    answer: 'takdir etmek',
    quest: 'appreciate',
  ),
  Words(
    front: "The meeting is scheduled for approximately 2 o'clock.",
    back: "Toplantı yaklaşık olarak saat 2'de planlanıyor.",
    list: 'B1',
    answer: 'yaklaşık olarak',
    quest: 'approximately',
  ),
  Words(
    front: "The police arrested the suspect for bank robbery.",
    back: "Polis, şüpheliyi banka soygunu suçundan tutukladı.",
    list: 'B1',
    answer: 'tutuklamak',
    quest: 'arrest',
  ),
  Words(
    front: "We are looking forward to your arrival.",
    back: "Varışınızı dört gözle bekliyoruz.",
    list: 'B1',
    answer: 'varmak',
    quest: 'arrival',
  ),
  Words(
    front: "My teacher gave me a difficult assignment for homework.",
    back: "Öğretmenim bana ödev olarak zor bir görevlendirme verdi.",
    list: 'B1',
    answer: 'görevlendirme',
    quest: 'assignment',
  ),
  Words(
    front: "Can you assist me with this task?",
    back: "Bu görevde bana yardım edebilir misin?",
    list: 'B1',
    answer: 'yardım etmek',
    quest: 'assist',
  ),
  Words(
    front: "Please attach the document to your email.",
    back: "Lütfen belgeyi e-postanıza ekleyin.",
    list: 'B1',
    answer: 'yapıştırmak, bağlamak',
    quest: 'attach',
  ),
  Words(
    front: "He has a positive attitude and is always willing to help others.",
    back:
        "Olumlu bir tavrı var ve başkalarına yardım etmeye her zaman istekli.",
    list: 'B1',
    answer: 'tutum, tavır',
    quest: 'attitude',
  ),
  Words(
    front: "The beautiful beaches attracted many tourists to the island.",
    back: "Güzel plajlar, adaya birçok turisti çekti.",
    list: 'B1',
    answer: 'cezbetmek',
    quest: 'attract',
  ),
  Words(
    front:
        "The city has a lot of attractions for tourists, such as museums and historical sites.",
    back:
        "Şehrin turistler için müzeler ve tarihi yerler gibi birçok çekiciliği var.",
    list: 'B1',
    answer: 'çekicilik',
    quest: 'attraction',
  ),
  Words(
    front:
        "The teacher has the authority to discipline students who misbehave.",
    back:
        "Öğretmen, kötü davranan öğrencileri cezalandırma yetkisine sahiptir.",
    list: 'B1',
    answer: 'yetki',
    quest: 'authority',
  ),
  Words(
    front: "The average temperature in July is 25 degrees Celsius.",
    back: "Temmuz ayındaki ortalama sıcaklık 25 santigrat derecedir.",
    list: 'B1',
    answer: 'ortalama',
    quest: 'average',
  ),
  Words(
    front: "She won an award for her outstanding work in science.",
    back: "Bilim alanındaki olağanüstü çalışmasıyla bir ödül kazandı.",
    list: 'B1',
    answer: 'ödül',
    quest: 'award',
  ),
  Words(
    front: "Are you aware of the new company policy?",
    back: "Yeni şirket politikasının farkında mısınız?",
    list: 'B1',
    answer: 'haberdar',
    quest: 'aware',
  ),
  Words(
    front: "Don't walk backwards, it's dangerous.",
    back: "Geriye doğru yürüme, tehlikeli.",
    list: 'B1',
    answer: 'geriye, arka tarafa',
    quest: 'backwards',
  ),
  Words(
    front: "I baked a cake for dessert.",
    back: "Tatlı olarak kek pişirdim.",
    list: 'B1',
    answer: 'fırında pişirmek',
    quest: 'bake',
  ),
  Words(
    front: "It is important to maintain a balance between work and life.",
    back: "İş ve yaşam arasında bir denge sağlamak önemlidir.",
    list: 'B1',
    answer: 'denge',
    quest: 'balance',
  ),
  Words(
    front: "Smoking is banned in public places.",
    back: "Halka açık yerlerde sigara içmek yasaktır.",
    list: 'B1',
    answer: 'yasak',
    quest: 'ban',
  ),
  Words(
    front: "I need to go to the bank to withdraw some money.",
    back: "Bankaya biraz para çekmek için gitmem gerekiyor.",
    list: 'B1',
    answer: 'banka',
    quest: 'bank',
  ),
  Words(
    front: "What is the base price of this product?",
    back: "Bu ürünün taban fiyatı nedir?",
    list: 'B1',
    answer: 'üs, temel',
    quest: 'base',
  ),
  Words(
    front:
        "You need to have a basic understanding of English grammar before you can start learning more advanced topics.",
    back:
        "Daha ileri konuları öğrenmeye başlamadan önce İngilizce gramerinin temel bilgisine sahip olmanız gerekir.",
    list: 'B1',
    answer: 'temel, ana',
    quest: 'basic',
  ),
  Words(
    front: "What's the basis for your theory?",
    back: "Teorinizin temeli nedir?",
    list: 'B1',
    answer: 'temel',
    quest: 'basis',
  ),
  Words(
    front: "Do you need new battery(-ies) for your remote control?",
    back: "Kumandanız için yeni pillere mi ihtiyacınız var?",
    list: 'B1',
    answer: 'akü, pil',
    quest: 'battery',
  ),
  Words(
    front:
        "The two armies fought a fierce battle for control of the territory.",
    back: "İki ordu, bölgenin kontrolü için şiddetli bir savaş verdi.",
    list: 'B1',
    answer: 'savaş',
    quest: 'battle',
  ),
  Words(
    front: "She is known for her beauty and kindness.",
    back: "Güzelliği ve nezaketiyle tanınır.",
    list: 'B1',
    answer: 'güzellik',
    quest: 'beauty',
  ),
  Words(
    front: "The bees are buzzing around the flowers.",
    back: "Arılar çiçeklerin etrafında vızıldıyor.",
    list: 'B1',
    answer: 'arı, takıntı',
    quest: 'bee',
  ),
  Words(
    front: "He stated his belief that God created us.",
    back: "Tanrı'nın bizi yarattığı inancını belirtti.",
    list: 'B1',
    answer: 'inanma',
    quest: 'belief',
  ),
  Words(
    front: "The school bell rang, signaling the end of the lesson.",
    back: "Dersin bittiğini işaret eden okul zili çaldı.",
    list: 'B1',
    answer: 'zil',
    quest: 'bell',
  ),
  Words(
    front: "Please bend your knees slightly when you squat.",
    back: "Squat yaparken lütfen dizlerinizi hafifçe bükün.",
    list: 'B1',
    answer: 'viraj, eğmek',
    quest: 'bend',
  ),
  Words(
    front: "Learning English will benefit you in many ways.",
    back: "İngilizce öğrenmek size birçok fayda sağlayacaktır.",
    list: 'B1',
    answer: 'menfaat',
    quest: 'benefit',
  ),
  Words(
    front: "I always try to do better in my studies.",
    back: "Derslerimde her zaman daha iyi olmaya çalışırım.",
    list: 'B1',
    answer: 'daha iyi',
    quest: 'better',
  ),
  Words(
    front: "The dog gave the mailman a nasty bite.",
    back: "Köpek postacıya kötü bir ısırık attı.",
    list: 'B1',
    answer: 'ısırık',
    quest: 'bite',
  ),
  Words(
    front: "He blocked my way, so I couldn't get past.",
    back: "Geçemediğim için yolumu engelledi.",
    list: 'B1',
    answer: 'blok, engellemek',
    quest: 'block',
  ),
  Words(
    front: "The board of directors met to discuss the company's future plans.",
    back:
        "Yönetim kurulu, şirketin gelecek planlarını görüşmek üzere toplandı.",
    list: 'B1',
    answer: 'kurul, heyet',
    quest: 'board',
  ),

  Words(
    front: "The country borders France to the north.",
    back: "Ülke, kuzeyde Fransa ile sınır komşusudur.",
    list: 'B1',
    answer: 'kenar',
    quest: 'border',
  ),
  Words(
    front: "Don't let these little things bother you.",
    back: "Bu küçük şeylerin sizi rahatsız etmesine izin vermeyin.",
    list: 'B1',
    answer: 'can sıkmak',
    quest: 'bother',
  ),
  Words(
    front: "The company has branches in all major cities.",
    back: "Şirketin tüm büyük şehirlerde şubeleri var.",
    list: 'B1',
    answer: 'dallanmak',
    quest: 'branch',
  ),
  Words(
    front: "What is your favorite brand of clothing?",
    back: "Favori giyim markanız hangisi?",
    list: 'B1',
    answer: 'marka',
    quest: 'brand',
  ),
  Words(
    front: "He is a brave soldier who has fought for his country. ",
    back: "Ülkesi için savaşan cesur bir askerdir.",
    list: 'B1',
    answer: 'cesur',
    quest: 'brave',
  ),
  Words(
    front: "Take a deep breath and try to calm down.",
    back: "Derin bir nefes alın ve sakinleşmeye çalışın.",
    list: 'B1',
    answer: 'nefes',
    quest: 'breath',
  ),
  Words(
    front: "The bride wore a beautiful white dress.",
    back: "Gelin, güzel beyaz bir elbise giydi.",
    list: 'B1',
    answer: 'gelin, atkı',
    quest: 'bride',
  ),
  Words(
    front: "The children blew bubbles with soap and water.",
    back: "Çocuklar sabun ve suyla kabarcıklar üflediler.",
    list: 'B1',
    answer: 'kabarcık',
    quest: 'bubble',
  ),
  Words(
    front:
        "You should also not bury batteries that contain hazardous chemicals in a garden or park.",
    back:
        "Ayrıca tehlikeli kimyasallar içeren pilleri bahçeye veya parka gömmemelisiniz.",
    list: 'B1',
    answer: 'gömmek',
    quest: 'bury',
  ),
  Words(
    front: "Despite the chaos, she remained calm.",
    back: "Kaosa rağmen sakin kaldı.",
    list: 'B1',
    answer: 'sakinlik',
    quest: 'calm',
  ),
  Words(
    front:
        "The company is running a marketing campaign to promote their new product.",
    back:
        "Şirket, yeni ürünlerini tanıtmak için bir pazarlama kampanyası yürütüyor.",
    list: 'B1',
    answer: 'kampanya',
    quest: 'campaign',
  ),
  Words(
    front: "The university campus is located in the suburbs.",
    back: "Üniversite kampüsü şehrin dışında yer almaktadır.",
    list: 'B1',
    answer: 'kampüs',
    quest: 'campus',
  ),
  Words(
    front: "There are several candidates running for president this year.",
    back: "Bu yıl başkanlık için yarışan birkaç aday var.",
    list: 'B1',
    answer: 'aday',
    quest: 'candidate',
  ),
  Words(
    front: "He wore a baseball cap to protect himself from the sun.",
    back: "Güneşten korunmak için bir beyzbol şapkası taktı.",
    list: 'B1',
    answer: 'başlık',
    quest: 'cap',
  ),
  Words(
    front: "The captain ordered the crew to set sail.",
    back: "Kaptan mürettebata yelken açmalarını emretti.",
    list: 'B1',
    answer: 'kaptan',
    quest: 'captain',
  ),
  Words(
    front: "He was so careless that he tripped and fell.",
    back: "Öylesine dikkatsizdi ki takılıp düştü.",
    list: 'B1',
    answer: 'umursamaz',
    quest: 'careless',
  ),
  Words(
    front:
        "Bacterial species are broadly divided into two categories for the purpose of science and medicine.",
    back: "Bu kelime farklı kategorilerde kullanılabilir.",
    list: 'B1',
    answer: 'kategori',
    quest: 'categories',
  ),
  Words(
    front: "The paint is peeling off the ceiling.",
    back: "Boya tavandan soyuluyor.",
    list: 'B1',
    answer: 'tavan',
    quest: 'ceiling',
  ),
  Words(
    front: "We are planning a big celebration for her birthday.",
    back: "Doğum günü için büyük bir kutlama planlıyoruz.",
    list: 'B1',
    answer: 'kutlama',
    quest: 'celebration',
  ),
  Words(
    front: "The central heating system kept the house warm.",
    back: "Merkezi ısıtma sistemi evi sıcak tuttu.",
    list: 'B1',
    answer: 'merkezi',
    quest: 'central',
  ),
  Words(
    front:
        "The city centre is a busy place with lots of shops and restaurants.",
    back:
        "Şehir merkezi, birçok mağaza ve restoranın bulunduğu hareketli bir yerdir.",
    list: 'B1',
    answer: 'merkez',
    quest: 'centre',
  ),
  Words(
    front: "The wedding ceremony was a beautiful and moving event.",
    back: "Düğün töreni güzel ve duygulu bir etkinlikti.",
    list: 'B1',
    answer: 'tören',
    quest: 'ceremony',
  ),
  Words(
    front: "He wore a gold chain around his neck.",
    back: "Boynunda altın bir zincir takıyordu.",
    list: 'B1',
    answer: 'zincir',
    quest: 'chain',
  ),
  Words(
    front: "He decided to challenge himself and run a marathon.",
    back: "Kendisine meydan okumaya ve maraton koşmaya karar verdi.",
    list: 'B1',
    answer: 'meydan okumak',
    quest: 'challenge',
  ),
  Words(
    front: "She is the reigning champion of the tennis tournament.",
    back: "O, tenis turnuvasının hüküm süren şampiyonu.",
    list: 'B1',
    answer: 'şampiyon',
    quest: 'champion',
  ),
  Words(
    front: "Can you change the channel to the news?",
    back: "Kanalı haberlere değiştirebilir misin?",
    list: 'B1',
    answer: 'kanal',
    quest: 'channel',
  ),
  Words(
    front: "This is the first chapter of the book.",
    back: "Bu, kitabın ilk bölümü.",
    list: 'B1',
    answer: 'bölüm',
    quest: 'chapter',
  ),
  Words(
    front: "The police charged him with robbery.",
    back: "Polis onu soygunculukla suçladı.",
    // Can also be "şarj etmek" depending on context (to charge a battery)
    list: 'B1',
    answer: 'suçlamak, şarj etmek',
    quest: 'charge',
  ),
  Words(
    front: "I found a cheap pair of shoes at the market.",
    back: "Pazarde ucuz bir çift ayakkabı buldum.",
    list: 'B1',
    answer: 'ucuz',
    quest: 'cheap',
  ),
  Words(
    front: "Don't cheat on your exams!",
    back: "Sınavlarda kopya çekme!",
    list: 'B1',
    answer: 'kopya çekmek',
    quest: 'cheat',
  ),
  Words(
    front: "She is always so cheerful and positive.",
    back: "Her zaman çok neşeli ve pozitiftir.",
    list: 'B1',
    answer: 'neşeli',
    quest: 'cheerful',
  ),
  Words(
    front: "Water is a chemical compound made up of hydrogen and oxygen.",
    back: "Su, hidrojen ve oksijenden oluşan kimyasal bir bileşiktir.",
    list: 'B1',
    answer: 'kimyasal',
    quest: 'chemical',
  ),
  Words(
    front: "He opened the treasure chest and found gold and jewels.",
    back: "Hazine sandığını açtı ve altınlarla mücevherler buldu.",
    list: 'B1',
    answer: 'sandık',
    quest: 'chest',
  ),
  Words(
    front: "I have fond memories of my childhood.",
    back: "Çocukluğumdan güzel anılarım var.",
    list: 'B1',
    answer: 'çocukluk',
    quest: 'childhood',
  ),
  Words(
    front: "The politician claimed that he would reduce taxes.",
    back: "Politikacı vergileri azaltacağını iddia etti.",
    list: 'B1',
    answer: 'iddia etmek',
    quest: 'claim',
  ),
  Words(
    // Clause can also be translated as "madde" depending on context (article in a legal document)
    front: "This sentence contains two independent clauses.",
    back: "Bu cümle iki bağımsız madde içerir.",
    list: 'B1',
    answer: 'fıkra',
    quest: 'clause',
  ),
  Words(
    front: "The instructions were clear and easy to follow.",
    back: "Talimatlar açıktı ve takip edilmesi kolaydı.",
    list: 'B1',
    answer: 'belirgin, açık',
    quest: 'clear',
  ),
  Words(
    front: "I heard a click when I turned on the light switch.",
    back: "Lamba anahtarını açtığımda bir tık sesi duydum.",
    list: 'B1',
    answer: 'tıkırdamak',
    quest: 'click',
  ),
  Words(
    front:
        "He is a loyal client who has been using our services for many years.",
    back: "Uzun yıllardır hizmetlerimizi kullanan sadık bir müşteridir.",
    list: 'B1',
    answer: 'müşteri',
    quest: 'client',
  ),
  Words(
    front: "They climbed the mountain to reach the summit.",
    back: "Zirveye ulaşmak için dağa tırmandılar.",
    list: 'B1',
    answer: 'tırmanmak',
    quest: 'climb',
  ),
  Words(
    front: "Please close the door when you leave.",
    back: "Ayrılırken lütfen kapıyı kapatın.",
    list: 'B1',
    answer: 'kapamak',
    quest: 'close',
  ),
  Words(
    front: "This shirt is made of a soft cotton cloth.",
    back: "Bu gömlek yumuşak bir pamuklu kumaştan yapılmıştır.",
    list: 'B1',
    answer: 'kumaş',
    quest: 'cloth',
  ),
  Words(
    front: "The detective followed the clues to solve the mystery.",
    back: "Dedektif, gizemi çözmek için ipuçlarını takip etti.",
    list: 'B1',
    answer: 'ipucu',
    quest: 'clue',
  ),
  Words(
    front:
        "He is a great soccer coach who has helped many players develop their skills.",
    back:
        "O, birçok oyuncunun yeteneklerini geliştirmesine yardımcı olan harika bir futbol antrenörüdür.",
    list: 'B1',
    answer: 'eğitmek',
    quest: 'coach',
  ),
  Words(
    front: "Coal is a fossil fuel that is used to generate electricity.",
    back: "Kömür, elektrik üretmek için kullanılan fosil bir yakıttır.",
    list: 'B1',
    answer: 'kömür',
    quest: 'Coal',
  ),
  Words(
    front: "I found a lucky coin in the street.",
    back: "Sokakta şanslı bir para buldum.",
    list: 'B1',
    answer: 'para',
    quest: 'coin',
  ),
  Words(
    front: "She has a large collection of antique stamps.",
    back: "Antik pullardan oluşan büyük bir koleksiyonu var.",
    list: 'B1',
    answer: 'toplama',
    quest: 'collection',
  ),
  Words(
    front: "He was wearing a brightly coloured shirt.",
    back: "Parlak renkli bir gömlek giymişti.",
    list: 'B1',
    answer: 'renkli',
    quest: 'coloured',
  ),
  Words(
    front: "Can you combine these two sentences into one?",
    back: "Bu iki cümleyi bir cümlede birleştirebilir misin?",
    list: 'B1',
    answer: 'birleştirmek',
    quest: 'combine',
  ),
  Words(
    front: "I would like to leave a comment on this article.",
    back: "Bu makale hakkında bir yorum bırakmak isterim.",
    list: 'B1',
    answer: 'yorum',
    quest: 'comment',
  ),
  Words(
    front: "I saw a funny commercial on TV last night.",
    back: "Dün gece televizyonda komik bir reklam gördüm.",
    list: 'B1',
    answer: 'ticari',
    quest: 'commercial',
  ),
  Words(
    front: "He committed a crime and was arrested by the police.",
    back: "Suç işledi ve polis tarafından tutuklandı.",
    list: 'B1',
    answer: 'suç işlemek',
    quest: 'commit',
  ),
  Words(
    front: "Effective communication is essential for good teamwork.",
    back: "Etkili iletişim, iyi bir takım çalışması için gereklidir.",
    list: 'B1',
    answer: 'iletişim',
    quest: 'communication',
  ),
  Words(
    front: "The essay compares and contrasts two different literary works.",
    back: "Deneme, iki farklı edebi eseri karşılaştırır ve karşılaştırır.",
    list: 'B1',
    answer: 'karşılaştırma',
    quest: 'compare',
  ),
  Words(
    front: "She is a strong competitor in the race.",
    back: "O, yarışmada güçlü bir yarışmacı.",
    list: 'B1',
    answer: 'yarışmacı',
    quest: 'competitor',
  ),
  Words(
    front: "The job market is becoming increasingly competitive.",
    back: "İş piyasası giderek daha rekabetçi hale geliyor.",
    list: 'B1',
    answer: 'rekabetçi',
    quest: 'competitive',
  ),
  Words(
    front: "I have a complaint about the slow service in the restaurant.",
    back: "Restorandaki yavaş servis hakkında bir şikayetim var.",
    list: 'B1',
    answer: 'şikayet',
    quest: 'complaint',
  ),
  Words(
    front: "The instructions were complex and difficult to understand.",
    back: "Talimatlar karmaşık ve anlaşılması zordu.",
    list: 'B1',
    answer: 'karışık',
    quest: 'complex',
  ),
  Words(
    front: "Please concentrate on your work and avoid distractions.",
    back: "Lütfen işinize konsantre olun ve dikkat dağıtıcı şeylerden kaçının.",
    list: 'B1',
    answer: 'yoğunlaşmak',
    quest: 'concentrate',
  ),
  Words(
    front:
        "The speaker concluded his presentation by summarizing the main points.",
    back: "Konuşmacı, ana noktaları özetleyerek sunumunu bitirdi.",
    list: 'B1',
    answer: 'sonuçlandırmak',
    quest: 'conclude',
  ),
  Words(
    front: "What is your conclusion about this experiment?",
    back: "Bu deney hakkındaki sonucunuz nedir?",
    list: 'B1',
    answer: 'sonuç',
    quest: 'conclusion',
  ),
  Words(
    front:
        "She is a confident public speaker who is not afraid to speak in front of a large audience.",
    back:
        "Kendinden emin, kalabalık önünde konuşmaktan korkmayan bir konuşmacıdır.",
    list: 'B1',
    answer: 'kendinden emin',
    quest: 'confident',
  ),
  Words(
    front: "Can you confirm that you received my email?",
    back: "E-postamı aldığınızı onaylayabilir misiniz?",
    list: 'B1',
    answer: 'onaylamak',
    quest: 'confirm',
  ),
  Words(
    front:
        "If you use too many technical terms, you will confuse your audience. ",
    back:
        "Çok fazla teknik terim kullanırsanız, dinleyicilerinizin kafasını karıştırırsınız. ",
    list: 'B1',
    answer: 'kafasını karıştırmak',
    quest: 'confuse',
  ),
  Words(
    front: "He looked confused and disoriented after the accident.",
    back: "Kazadan sonra şaşkın ve yönünü şaşırmış görünüyordu.",
    list: 'B1',
    answer: 'şaşkın',
    quest: 'confused',
  ),
  Words(
    front: "There is a strong connection between diet and health.",
    back: "Beslenme ve sağlık arasında güçlü bir bağlantı vardır.",
    list: 'B1',
    answer: 'bağ',
    quest: 'connection',
  ),
  Words(
    front: "Smoking can have serious consequences for your health.",
    back: "Sigara içmenin sağlığınız için ciddi sonuçları olabilir.",
    list: 'B1',
    answer: 'sonuç',
    quest: 'consequence',
  ),
  Words(
    front: "Water consists of two hydrogen atoms and one oxygen atom.",
    back: "Su, iki hidrojen atomu ve bir oksijen atomundan oluşur.",
    list: 'B1',
    answer: '-den meydana gelmek',
    quest: 'consist',
  ),
  Words(
    front: "We consume a lot of energy every day.",
    back: "Her gün çok fazla enerji tüketiyoruz.",
    list: 'B1',
    answer: 'tüketmek',
    quest: 'consume',
  ),
  Words(
    front:
        "Consumers are becoming more aware of the environmental impact of their choices.",
    back:
        "Tüketiciler, seçimlerinden kaynaklanan çevresel etki hakkında daha fazla bilinçleniyor.",
    list: 'B1',
    answer: 'tüketici',
    quest: 'Consumer',
  ),
  Words(
    front: "Please contact me if you have any questions.",
    back: "Herhangi bir sorunuz varsa lütfen benimle iletişime geçin.",
    list: 'B1',
    answer: 'ilişki kurmak',
    quest: 'contact',
  ),
  Words(
    front: "The milk is sold in plastic containers.",
    back: "Süt, plastik konteynerlerde satılmaktadır.",
    list: 'B1',
    answer: 'konteyner',
    quest: 'container',
  ),
  Words(
    front:
        "The website provides a variety of content, including articles, videos, and games.",
    back:
        "Web sitesi, makaleler, videolar ve oyunlar dahil olmak üzere çeşitli içerikler sunar.",
    list: 'B1',
    answer: 'içerik',
    quest: 'content',
  ),
  Words(
    front: "There was a continuous stream of cars on the highway.",
    back: "Otoyolda kesintisiz bir araba akışı vardı.",
    list: 'B1',
    answer: 'sürekli',
    quest: 'continuous',
  ),
  Words(
    front: "The location is very convenient for public transportation.",
    back: "Konum, toplu taşıma için çok uygundur.",
    list: 'B1',
    answer: 'müsait',
    quest: 'convenient',
  ),
  Words(
    front: "He tried to convince me to change my mind, but I wasn't persuaded.",
    back: "Beni fikrimi değiştirmeye ikna etmeye çalıştı, ama ikna olmadım.",
    list: 'B1',
    answer: 'ikna etmek',
    quest: 'convince',
  ),
  Words(
    front: " Air-conditioning cools a room very quickly.",
    back: "Klima, bir odayı çok hızlı soğutur.",
    list: 'B1',
    answer: 'soğutmak',
    quest: 'cool',
  ),
  Words(
    front: "She wore a colorful costume for the Halloween party.",
    back: "Cadılar Bayramı partisi için renkli bir kostüm giydi.",
    list: 'B1',
    answer: 'kostüm',
    quest: 'costume',
  ),
  Words(
    front: "We spent a weekend at a cozy cottage in the countryside.",
    back: "Hafta sonunu kırsal kesimde şirin bir kulübede geçirdik.",
    list: 'B1',
    answer: 'kulübe',
    quest: 'cottage',
  ),
  Words(
    front: "This shirt is made of a soft cotton cloth.",
    back: "Bu gömlek yumuşak bir pamuklu kumaştan yapılmıştır.",
    list: 'B1',
    answer: 'pamuklu',
    quest: 'cotton',
  ),
  Words(
    front: "Can you count how many apples are in the basket?",
    back: "Sepette kaç tane elma olduğunu sayabilir misin?",
    list: 'B1',
    answer: 'saymak',
    quest: 'count',
  ),
  Words(
    front: "We spent a weekend at a cozy cottage in the countryside.",
    back: "Hafta sonunu kırsal kesimde şirin bir kulübede geçirdik.",
    list: 'B1',
    answer: 'kırsal kesim',
    quest: 'countryside',
  ),
  Words(
    front: "The case will be heard in court next week.",
    back: "Dava önümüzdeki hafta mahkemede görülecek.",
    list: 'B1',
    answer: 'mahkeme',
    quest: 'court',
  ),
  Words(
    front: "She covered the table with a tablecloth.",
    back: "Masayı bir masa örtüsüyle örttü.",
    list: 'B1',
    answer: 'örtmek',
    quest: 'cover',
  ),
  Words(
    front: "The table was covered in a layer of dust.",
    back: "Masa bir toz tabakasıyla kaplıydı.",
    list: 'B1',
    answer: 'örtülü',
    quest: 'covered',
  ),
  Words(
    front: "I used a moisturizer cream before applying makeup.",
    back: "Makyaj yapmadan önce nemlendirici krem kullandım.",
    list: 'B1',
    answer: 'krema',
    quest: 'cream',
  ),
  Words(
    front: "He was criticized for his cruel treatment of animals.",
    back: "Hayvanlara karşı zalimce davranışları nedeniyle eleştirildi.",
    list: 'B1',
    answer: 'acımasız',
    quest: 'cruel',
  ),
  Words(
    front: "We learned about different cultural traditions in history class.",
    back: "Tarih dersinde farklı kültürel gelenekleri öğrendik.",
    list: 'B1',
    answer: 'kültürel',
    quest: 'cultural',
  ),
  Words(
    front: "The US dollar is the official currency of the United States.",
    back: "ABD doları, Amerika Birleşik Devletleri'nin resmi para birimidir.",
    list: 'B1',
    answer: 'para birimi',
    quest: 'currency',
  ),
  Words(
    front:
        "There is a strong current in this river, so be careful when swimming.",
    back: "Bu nehirde güçlü bir akıntı var, bu yüzden yüzerken dikkatli olun.",
    list: 'B1',
    answer: 'akım',
    quest: 'current',
  ),
  Words(
    front: "It is currently raining outside.",
    back: "Şu anda dışarıda yağmur yağıyor.",
    list: 'B1',
    answer: 'şu anda',
    quest: 'currently',
  ),
  Words(
    front: "She closed the curtains to block out the sunlight.",
    back: "Güneş ışığını engellemek için perdeleri kapattı.",
    list: 'B1',
    answer: 'perde',
    quest: 'curtain',
  ),
  Words(
    front: "It is a custom in this country to greet elders by bowing.",
    back: "Bu ülkede yaşlıları selamlamanın bir geleneği eğilmektir.",
    list: 'B1',
    answer: 'görenek',
    quest: 'custom',
  ),
  Words(
    front: "Please cut the bread into slices.",
    back: "Lütfen ekmeği dilimler halinde kesin.",
    list: 'B1',
    answer: 'kesmek',
    quest: 'cut',
  ),
  Words(
    front: "I read the daily newspaper to stay informed about current events.",
    back: "Güncel olaylardan haberdar olmak için günlük gazeteyi okurum.",
    list: 'B1',
    answer: 'günlük',
    quest: 'daily',
  ),
  Words(
    front: "The accident caused a lot of damage to the car.",
    back: "Kaza arabada büyük hasara neden oldu.",
    list: 'B1',
    answer: 'zarar vermek',
    quest: 'damage',
  ),
  Words(
    front: "How do you deal with stress?",
    back: "Stresle nasıl başa çıkıyorsun?",
    list: 'B1',
    answer: 'davranamk',
    quest: 'deal',
  ),
  Words(
    front: "Technology has changed dramatically in the past decade.",
    back: "Teknoloji, son on yılda önemli ölçüde değişti.",
    list: 'B1',
    answer: '10 yıl',
    quest: 'decade',
  ),
  Words(
    front: "She decorated the room for the party with balloons and streamers.",
    back: "Odayı parti için balonlar ve flamalar ile dekore etti.",
    list: 'B1',
    answer: 'dekore etmek',
    quest: 'decorate',
  ),
  Words(
    front: "The lake is very deep, so be careful when swimming near the edge.",
    back: "Göl çok derin, bu nedenle kenarında yüzerken dikkatli olun.",
    list: 'B1',
    answer: 'derin',
    quest: 'deep',
  ),
  Words(
    front: "Can you define the word 'democracy' for me?",
    back: "Demokrasi kelimesini benim için tanımlayabilir misin?",
    list: 'B1',
    answer: 'tanımlamak',
    quest: 'define',
  ),
  Words(
    front: "Do you have a definite answer to my question?",
    back: "Soruma kesin bir cevabınız var mı?",
    list: 'B1',
    answer: 'belirli',
    quest: 'definite',
  ),
  Words(
    front: "I created a list of important words and their definitions.",
    back: "Önemli kelimeler ve tanımlarından oluşan bir liste oluşturdum.",
    list: 'B1',
    answer: 'tanım',
    quest: 'definition',
  ),
  Words(
    front: "The pizza delivery arrived in less than 30 minutes.",
    back: "Pizza siparişiniz 30 dakikadan kısa sürede geldi.",
    list: 'B1',
    answer: 'teslim etmek',
    quest: 'deliver',
  ),
  Words(
    front: "The plane's departure was delayed due to bad weather.",
    back: "Uçağın kalkışı kötü hava koşulları nedeniyle ertelendi.",
    list: 'B1',
    answer: 'kalkış',
    quest: 'departure',
  ),
  Words(
    front: "He achieved his goals despite the difficulties.",
    back: "Zorluklara rağmen hedeflerine ulaştı.",
    list: 'B1',
    answer: 'kin',
    quest: 'despite',
  ),
  Words(
    front: "What is your final destination?",
    back: "Son varış noktanız neresi?",
    list: 'B1',
    answer: 'varış yeri',
    quest: 'destination',
  ),
  Words(
    front: "We need to determine the cause of the problem.",
    back: "Sorunun nedenini belirlememiz gerekiyor.",
    list: 'B1',
    answer: 'kararlaştırmak',
    quest: 'determine',
  ),
  Words(
    front: "She is a determined student who always strives to do her best.",
    back:
        "Elinizden gelenin en iyisini yapmaya çalışan kararlı bir öğrencidir.",
    list: 'B1',
    answer: 'azimli',
    quest: 'determined',
  ),
  Words(
    front: "Technology has undergone significant development in recent years.",
    back: "Teknoloji, son yıllarda önemli bir gelişme gösterdi.",
    list: 'B1',
    answer: 'gelişim',
    quest: 'development',
  ),
  Words(
    front: "Can you explain this concept with a diagram?",
    back: "Bu kavramı bir diyagramla açıklayabilir misiniz?",
    list: 'B1',
    answer: 'grafik',
    quest: 'diagram',
  ),
  Words(
    front: "A diamond is one of the hardest natural substances on Earth.",
    back: "Elmas, Dünya üzerindeki en sert doğal maddelerden biridir.",
    list: 'B1',
    answer: 'elmas',
    quest: 'diamond',
  ),
  Words(
    front: "I had difficulty completing the task on time.",
    back: "Görevi zamanında tamamlamakta zorlandım.",
    list: 'B1',
    answer: 'zorluk',
    quest: 'difficulty',
  ),
  Words(
    front: "Please direct me to the nearest bus stop.",
    back: "Lütfen beni en yakın otobüs durağına yönlendirin.",
    list: 'B1',
    answer: 'yöneltmek',
    quest: 'direct',
  ),
  Words(
    front: "He spoke directly to the manager to express his concerns.",
    back: "Endişelerini dile getirmek için doğrudan müdürle konuştu.",
    list: 'B1',
    answer: 'doğrudan',
    quest: 'directly',
  ),
  Words(
    front: "Wash your hands before eating to avoid germs and dirt.",
    back:
        "Mikrop ve kirden kaçınmak için yemek yemeden önce ellerinizi yıkayın.",
    list: 'B1',
    answer: 'pislik',
    quest: 'dirt',
  ),
  Words(
    front: "The lack of experience is a disadvantage for this job application.",
    back: "Deneyim eksikliği, bu iş başvurusu için bir dezavantaj.",
    list: 'B1',
    answer: 'dezavantaj',
    quest: 'disadvantage',
  ),
  Words(
    front: "I was disappointed with the quality of the food at the restaurant.",
    back: "Restorandaki yemeklerin kalitesinden hayal kırıklığına uğradım.",
    list: 'B1',
    answer: 'hayal kırıklığı',
    quest: 'disappointed',
  ),
  Words(
    front: "The movie had a disappointing ending.",
    back: "Filmin hayal kırıklığı yaratacak bir sonu vardı.",
    list: 'B1',
    answer: 'heves kırıcı',
    quest: 'disappointing',
  ),
  Words(
    front: "Is there a discount for students?",
    back: "Öğrenciler için indirim var mı?",
    list: 'B1',
    answer: 'indirim',
    quest: 'discount',
  ),
  Words(
    front: "Let's divide the cake into four slices.",
    back: "Pastayı dört dilime bölelim.",
    list: 'B1',
    answer: 'bölmek',
    quest: 'divide',
  ),
  Words(
    front: "We watched a documentary about marine life last night.",
    back: "Dün gece deniz yaşamı hakkında bir belgesel izledik.",
    list: 'B1',
    answer: 'belgesel',
    quest: 'documentary',
  ),
  Words(
    front: "Many people donate to charities to help those in need.",
    back:
        "Pek çok insan, ihtiyacı olanlara yardım etmek için hayır kurumlarına bağış yapar.",
    list: 'B1',
    answer: 'bağış',
    quest: 'donate',
  ),
  Words(
    front:
        "In the course of the 1930s steel production in Britain approximately doubled.",
    back: "1930'larda İngiltere'de çelik üretimi yaklaşık iki katına çıktı.",
    list: 'B1',
    answer: 'ikiye katlamak',
    quest: 'double',
  ),
  Words(
    front: "I have some doubts about the validity of this information.",
    back: "Bu bilginin geçerliliği hakkında bazı şüphelerim var.",
    list: 'B1',
    answer: 'şüphe',
    quest: 'doubt',
  ),
  Words(
    front: "He was dressed in a suit and tie for the job interview.",
    back: "İş görüşmesi için takım elbise ve kravat giymişti.",
    list: 'B1',
    answer: 'giyinik',
    quest: 'dressed',
  ),
  Words(
    front: "Be careful not to drop your phone!",
    back: "Telefonunuzu düşürmemeye dikkat edin!",
    list: 'B1',
    answer: 'düşmek',
    quest: 'drop',
  ),
  Words(
    front: "I can hear the sound of drums coming from the street.",
    back: "Sokaktan davul sesi duyabiliyorum.",
    list: 'B1',
    answer: 'davul',
    quest: 'drum',
  ),
  Words(
    front: "He was too drunk to drive home safely.",
    back: "Eve güvenli bir şekilde gitmek için çok sarhoştu.",
    list: 'B1',
    answer: 'sarhoş',
    quest: 'drunk',
  ),
  Words(
    front: "My rent is due on the first of the month.",
    back: "Kiram ayın birinde ödenecek.",
    list: 'B1',
    answer: 'vadesi dolmuş',
    quest: 'due',
  ),
  Words(
    front: "Please wipe the dust off the table before setting the dishes.",
    back: "Bulaşıkları masaya koymadan önce lütfen tozu silin.",
    list: 'B1',
    answer: 'toz',
    quest: 'dust',
  ),
  Words(
    front: "It is your duty to help those in need.",
    back: "İhtiyacı olanlara yardım etmek senin görevin.",
    list: 'B1',
    answer: 'görev',
    quest: 'duty',
  ),
  Words(
    front: "The recent earthquake caused a lot of damage to the buildings.",
    back:
        "Yakın zamanda meydana gelen deprem, binalarda büyük hasara neden oldu.",
    list: 'B1',
    answer: 'deprem',
    quest: 'earthquake',
  ),
  Words(
    front: "Turkish cuisine is a fusion of Eastern and Western influences.",
    back: "Türk mutfağı, Doğu ve Batı etkilerinin bir füzyonudur.",
    list: 'B1',
    answer: 'doğuya ait',
    quest: 'Eastern',
  ),
  Words(
    front:
        "The economic crisis has had a negative impact on many people's lives.",
    back: "Ekonomik kriz, birçok insanın hayatını olumsuz etkiledi.",
    list: 'B1',
    answer: 'ekonomik',
    quest: 'economic',
  ),
  Words(
    front: "The global economy is becoming increasingly interconnected.",
    back: "Küresel ekonomi giderek daha fazla birbirine bağlı hale geliyor.",
    list: 'B1',
    answer: 'ekonomi',
    quest: 'economy',
  ),
  Words(
    front: "Be careful not to stand too close to the edge of the cliff.",
    back: "Uçurumun kenarına çok yaklaşmamaya dikkat edin.",
    list: 'B1',
    answer: 'eşik, köşe',
    quest: 'edge',
  ),
  Words(
    front: "The editor carefully reviewed the article before publishing it.",
    back: "Editör makaleyi yayınlamadan önce dikkatlice gözden geçirdi.",
    list: 'B1',
    answer: 'editör',
    quest: 'editor',
  ),
  Words(
    front:
        "Kindergarten teachers generally educate children in reading and writing.",
    back:
        " Anaokulu öğretmenleri genellikle çocukları okuma ve yazma konusunda eğitir.",
    list: 'B1',
    answer: 'eğitmek',
    quest: 'educate',
  ),
  Words(
    front: "He is a highly educated man with a PhD in literature.",
    back: "Doktora derecesine sahip, yüksek eğitimli bir adamdır.",
    list: 'B1',
    answer: 'eğitimli',
    quest: 'educated',
  ),
  Words(
    front:
        "This documentary is a great educational tool for learning about history.",
    back: "Bu belgesel, tarih öğrenmek için harika bir eğitim aracıdır.",
    list: 'B1',
    answer: 'eğitici',
    quest: 'educational',
  ),
  Words(
    front: "The new cleaning product is very effective at removing stains.",
    back: "Yeni temizlik ürünü, lekeleri çıkarmada çok etkilidir.",
    list: 'B1',
    answer: 'efektif,etkili',
    quest: 'effective',
  ),
  Words(
    front: "He studied for hours to effectively prepare for the exam.",
    back: "Sınava etkili bir şekilde hazırlanmak için saatlerce çalıştı.",
    list: 'B1',
    answer: 'etkili bir şekilde',
    quest: 'effectively',
  ),
  Words(
    front: "It takes a lot of effort to learn a new language.",
    back: "Yeni bir dil öğrenmek çok çaba gerektirir.",
    list: 'B1',
    answer: 'efor, çaba',
    quest: 'effort',
  ),
  Words(
    front: "The presidential election will be held next month.",
    back: "Cumhurbaşkanlığı seçimi gelecek ay yapılacak.",
    list: 'B1',
    answer: 'seçim',
    quest: 'election',
  ),
  Words(
    front: "Water is a basic element that is essential for life.",
    back: "Su, yaşam için gerekli temel bir elementtir.",
    list: 'B1',
    answer: 'eleman',
    quest: 'element',
  ),
  Words(
    front: "I was so embarrassed when I tripped and fell in front of everyone.",
    back: "Herkesin önünde tökezleyip düştüğümde çok utandım.",
    list: 'B1',
    answer: 'utangaç',
    quest: 'embarrassed',
  ),
  Words(
    front: "It was an embarrassing situation for everyone involved.",
    back: "Herkes için utanç verici bir durumdu.",
    list: 'B1',
    answer: 'utandırıcı',
    quest: 'embarrassing',
  ),
  Words(
    front: "Call the emergency services immediately if there is a fire.",
    back: "Yangın varsa hemen acil servisi arayın.",
    list: 'B1',
    answer: 'acil vaka',
    quest: 'emergency',
  ),
  Words(
    front: "Happiness, sadness, and anger are all examples of emotions.",
    back: "Mutluluk, üzüntü ve öfke duyguların tüm örnekleridir.",
    list: 'B1',
    answer: 'duygu',
    quest: 'emotion',
  ),
  Words(
    front: "Full-time employment can provide financial security and stability.",
    back: "Tam zamanlı bir iş, mali güvenlik ve istikrar sağlayabilir.",
    list: 'B1',
    answer: 'iş verme',
    quest: 'employment',
  ),
  Words(
    front: "The trash can is empty, so you need to take it out to the curb.",
    back: "Çöp tenekesi boş, bu yüzden onu kaldırıma çıkarmanız gerekiyor.",
    list: 'B1',
    answer: 'boş',
    quest: 'empty',
  ),
  Words(
    front: "Her teacher encouraged her to pursue her dreams.",
    back: "Öğretmeni, hayallerinin peşinden gitmesi için onu cesaretlendirdi.",
    list: 'B1',
    answer: 'cesaretlendirmek',
    quest: 'encourage',
  ),
  Words(
    front: "They are the enemy of peace and freedom.",
    back: "Onlar barışın ve özgürlüğün düşmanıdırlar.",
    list: 'B1',
    answer: 'düşman',
    quest: 'enemy',
  ),
  Words(
    front: "Are you engaged to be married?",
    back: "Evlenmek için nişanlı mısın?",
    list: 'B1',
    answer: 'bağlanmış, nişanlı',
    quest: 'engaged',
  ),
  Words(
    front: "She is studying engineering at university.",
    back: "Üniversitede mühendislik okuyor.",
    list: 'B1',
    answer: 'mühendislik',
    quest: 'engineering',
  ),
  Words(
    front: "This book is both entertaining and informative.",
    back: "Bu kitap hem eğlendirici hem de bilgilendiricidir.",
    list: 'B1',
    answer: 'eğlendirmek',
    quest: 'entertain',
  ),
  Words(
    front: "We went to the cinema for some entertainment.",
    back: " biraz eğlence için sinemaya gittik.",
    list: 'B1',
    answer: 'eğlence',
    quest: 'entertainment',
  ),
  Words(
    front: "The entrance to the museum is around the corner.",
    back: "Müzenin girişi köşede.",
    list: 'B1',
    answer: 'giriş',
    quest: 'entrance',
  ),
  Words(
    front: "Please write your name and entry number on the form.",
    back: "Lütfen formun üzerine adınızı ve giriş numaranızı yazın.",
    list: 'B1',
    answer: 'giriş',
    quest: 'entry',
  ),
  Words(
    front: "There is a growing concern about environmental issues.",
    back: "Çevresel konular hakkında giderek artan bir endişe var.",
    list: 'B1',
    answer: 'çevre',
    quest: 'environmental',
  ),
  Words(
    front: "This is my favorite episode of the show so far.",
    back: "Bu, şimdiye kadar izlediğim dizinin en sevdiğim bölümü.",
    list: 'B1',
    answer: 'parça',
    quest: 'episode',
  ),
  Words(
    front: "All men are created equal.",
    back: "Tüm insanlar eşit yaratılmıştır.",
    list: 'B1',
    answer: 'eşit',
    quest: 'equal',
  ),
  Words(
    front: "The thief escaped through the back door.",
    back: "Hırsız arka kapıdan kaçtı.",
    list: 'B1',
    answer: 'kaçmak',
    quest: 'escape',
  ),
  Words(
    front: "Water is an essential element for life.",
    back: "Su, yaşam için gerekli temel bir elementtir.",
    list: 'B1',
    answer: 'esas',
    quest: 'essential',
  ),
  Words(
    front:
        "We will eventually reach our destination, even if it takes a while.",
    back: "Her ne kadar biraz zaman alsa da, sonunda hedefimize ulaşacağız.",
    list: 'B1',
    answer: 'eninde sonunda',
    quest: 'eventually',
  ),
  Words(
    front: "The doctor will examine you before making a diagnosis.",
    back: "Doktor, teşhis koymadan önce sizi muayene edecektir.",
    list: 'B1',
    answer: 'muayene etmek',
    quest: 'examine',
  ),
  Words(
    front: "Everyone is welcome to attend the party, except for children.",
    back: "Çocuklar hariç herkes partiye katılmaya davetlidir.",
    list: 'B1',
    answer: 'haricinde',
    quest: 'except',
  ),
  Words(
    front: "Let's exchange phone numbers so we can stay in touch.",
    back: "İrtibatta kalabilmek için telefon numaralarımızı değiştirelim.",
    list: 'B1',
    answer: 'takas etmek',
    quest: 'exchange',
  ),
  Words(
    front: "The news of her victory filled everyone with excitement.",
    back: "Onun zafer haberi herkesi heyecanlandırdı.",
    list: 'B1',
    answer: 'heyecan',
    quest: 'excitement',
  ),
  Words(
    front: "There is a new art exhibition at the museum this month.",
    back: "Müzede bu ay yeni bir sergi var.",
    list: 'B1',
    answer: 'sergi',
    quest: 'exhibition',
  ),
  Words(
    front: "The company is expanding into new markets.",
    back: "Şirket yeni pazarlara açılıyor.",
    list: 'B1',
    answer: 'yayılmak',
    quest: 'expand',
  ),
  Words(
    front: "The expected delivery date is next week.",
    back: "Beklenen teslimat tarihi önümüzdeki hafta.",
    list: 'B1',
    answer: 'beklenen',
    quest: 'expected',
  ),
  Words(
    front:
        "Lewis and Clark led a famous expedition to explore the American West.",
    back:
        "Lewis ve Clark, Amerikan Batı'sını keşfetmek için ünlü bir keşif gezisine liderlik etti.",
    list: 'B1',
    answer: 'acele',
    quest: 'expedition',
  ),
  Words(
    front: "He gained a lot of experience working in customer service.",
    back: "Müşteri hizmetlerinde çalışarak çok fazla deneyim kazandı.",
    list: 'B1',
    answer: 'deneyim',
    quest: 'experience',
  ),
  Words(
    front:
        "She is a highly experienced teacher with over 20 years of experience.",
    back: "20 yılı aşkın deneyime sahip, tecrübeli bir öğretmendir.",
    list: 'B1',
    answer: 'tecrübeli',
    quest: 'experienced',
  ),
  Words(
    front: "Scientists are conducting experiments to find a cure for cancer.",
    back: "Bilim adamları, kanser tedavisi bulmak için deneyler yürütüyor.",
    list: 'B1',
    answer: 'deney',
    quest: 'experiment',
  ),

  Words(
    front: "The explorers set out to explore the uncharted territory.",
    back: "Kaşifler keşfedilmemiş toprakları keşfetmek için yola çıktılar.",
    list: 'B1',
    answer: 'keşfetmek',
    quest: 'explore',
  ),
  Words(
    front: "The loud explosion caused widespread panic.",
    back: "Yüksek sesli patlama yaygın paniğe neden oldu.",
    list: 'B1',
    answer: 'patlama',
    quest: 'explosion',
  ),
  Words(
    front: "Turkey is a major exporter of textiles.",
    back: "Türkiye, tekstil ürünlerinin önemli bir ihracatçısıdır.",
    list: 'B1',
    answer: 'ihracat',
    quest: 'export',
  ),
  Words(
    front:
        "Would you like fries with your burger? - Yes, please, with extra cheese.",
    back:
        "Hamburgerinizle patates kızartması ister misiniz? - Evet, lütfen ekstra peynirli.",
    list: 'B1',
    answer: 'ekstra',
    quest: 'extra',
  ),
  Words(
    front: "He will have to face the consequences of his actions.",
    back: "Yaptıklarının sonuçlarıyla yüzleşmesi gerekecek.",
    list: 'B1',
    answer: 'yüzleşmek',
    quest: 'face',
  ),
  Words(
    front:
        "He speaks English fairly well, considering he only started learning a year ago.",
    back:
        "Bir yıl önce öğrenmeye başlamasına rağmen, İngilizceyi oldukça iyi konuşuyor.",
    list: 'B1',
    answer: 'büsbütün',
    quest: 'fairly',
  ),
  Words(
    front: "This street is familiar to me. I must have been here before.",
    back: "Bu sokak bana tanıdık geliyor. Daha önce burada olmalıyım.",
    list: 'B1',
    answer: 'tanıdık',
    quest: 'familiar',
  ),
  Words(
    front: "She wore a fancy dress to the ball.",
    back: "Baloya süslü bir elbise giydi.",
    list: 'B1',
    answer: 'süslü',
    quest: 'fancy',
  ),
  Words(
    front: "The mountains are far in the distance.",
    back: "Dağlar uzakta görünüyor.",
    list: 'B1',
    answer: 'uzak',
    quest: 'far',
  ),
  Words(
    front:
        "I found the documentary about ancient Egypt to be very fascinating.",
    back: "Eski Mısır hakkındaki belgeseli çok büyüleyici buldum.",
    list: 'B1',
    answer: 'büyüleyici',
    quest: 'fascinating',
  ),
  Words(
    front: "She always wears fashionable clothes.",
    back: "Her zaman modaya uygun giyinir.",
    list: 'B1',
    answer: 'modaya uygun',
    quest: 'fashionable',
  ),
  Words(
    front: "Please fasten your seatbelt before takeoff.",
    back: "Kalkıştan önce lütfen emniyet kemerinizi bağlayın.",
    list: 'B1',
    answer: 'bağlamak',
    quest: 'fasten',
  ),
  Words(
    front: "Can you do me a favour and take out the trash?",
    back: "Bana bir iyilik yapıp çöpü çıkarabilir misin?",
    list: 'B1',
    answer: 'iyilik',
    quest: 'favour',
  ),
  Words(
    front: "He has a terrible fear of spiders.",
    back: "Büyük bir örümcek korkusu var.",
    list: 'B1',
    answer: 'korkmak',
    quest: 'fear',
  ),
  Words(
    front: "The new phone has many interesting features.",
    back: "Yeni telefonun birçok ilginç özelliği var.",
    list: 'B1',
    answer: 'özellik',
    quest: 'feature',
  ),
  Words(
    front: "The garden is surrounded by a wooden fence.",
    back: "Bahçe ahşap bir çit ile çevrilidir.",
    list: 'B1',
    answer: 'çit',
    quest: 'fence',
  ),
  Words(
    front: "There was a lot of fighting between the two gangs.",
    back: "İki çete arasında çok kavga vardı.",
    list: 'B1',
    answer: 'kavga',
    quest: 'fighting',
  ),
  Words(
    front: "Please save your work to a file before closing the program.",
    back: "Programı kapatmadan önce lütfen çalışmanızı bir dosyaya kaydedin.",
    list: 'B1',
    answer: 'dosya',
    quest: 'file',
  ),
  Words(
    front: "He is having some financial difficulties at the moment.",
    back: "Şu anda bazı mali zorluklar yaşıyor.",
    list: 'B1',
    answer: 'finansal',
    quest: 'financial',
  ),
  Words(
    front: "Don't forget to fire the alarm before you leave the house.",
    back: "Evden çıkmadan önce alarmı kurmayı unutmayın.",
    list: 'B1',
    answer: 'kovmak, ateşlemek',
    quest: 'fire',
  ),
  Words(
    front: "I'm going to the gym to work on my fitness.",
    back: "Formumu geliştirmek için spor salonuna gidiyorum.",
    list: 'B1',
    answer: 'formda olmak',
    quest: 'fitness',
  ),
  Words(
    front: "The bus fare is a fixed price.",
    back: "Otobüs ücreti sabit bir fiyattır.",
    list: 'B1',
    answer: 'sabit',
    quest: 'fixed',
  ),
  Words(
    front: "The national flag is flying high above the building.",
    back: "Ulusal bayrak binanın yukarısında dalgalanıyor.",
    list: 'B1',
    answer: 'bayrak',
    quest: 'flag',
  ),
  Words(
    front: "The heavy rain caused flooding in the streets.",
    back: "Şiddetli yağmur, sokaklarda su baskınlarına neden oldu.",
    list: 'B1',
    answer: 'su baskını',
    quest: 'flood',
  ),
  Words(
    front: "Wheat flour is a common ingredient in baking bread.",
    back: "Buğday unu, ekmek pişirmede kullanılan yaygın bir malzemedir.",
    list: 'B1',
    answer: 'un',
    quest: 'flour',
  ),
  Words(
    front: "The river flows through the countryside.",
    back: "Nehir kırsal kesimden akıyor.",
    list: 'B1',
    answer: 'akmak',
    quest: 'flow',
  ),
  Words(
    front: "Please fold the laundry before putting it away.",
    back: "Lütfen çamaşırları kaldırmadan önce katlayın.",
    list: 'B1',
    answer: 'bükülmek',
    quest: 'fold',
  ),
  Words(
    front:
        "Folk music is a traditional form of music passed down through generations.",
    back:
        "Halk müziği, nesilden nesile aktarılan geleneksel bir müzik türüdür.",
    list: 'B1',
    answer: 'halk',
    quest: 'Folk',
  ),
  Words(
    front: "He has a large following on social media.",
    back: "Sosyal medyada çok sayıda takipçisi var.",
    list: 'B1',
    answer: 'taraftarlar',
    quest: 'following',
  ),
  Words(
    front: "He forced me to give him my money.",
    back: "Bana zorla paramı vermemi söyledi.",
    list: 'B1',
    answer: 'baskı yapmak',
    quest: 'force',
  ),
  Words(
    front: "Love is a feeling that lasts forever.",
    back: "Sevgi, sonsuza dek süren bir duygudur.",
    list: 'B1',
    answer: 'ilelebet',
    quest: 'forever',
  ),
  Words(
    front: "The picture is in a beautiful wooden frame.",
    back: "Resim güzel bir ahşap çerçeve içinde.",
    list: 'B1',
    answer: 'çerçeve',
    quest: 'frame',
  ),
  Words(
    front: "The cold weather caused the water to freeze.",
    back: "Soğuk hava suyun donmasına neden oldu. ",
    list: 'B1',
    answer: 'donmak',
    quest: 'freeze',
  ),
  Words(
    front: "She goes to the gym frequently to stay in shape.",
    back: "Formda kalmak için sık sık spor salonuna gidiyor.",
    list: 'B1',
    answer: 'sık sık',
    quest: 'frequently',
  ),
  Words(
    front: "Our friendship has lasted for many years.",
    back: "Dostluğumuz uzun yıllardır devam ediyor.",
    list: 'B1',
    answer: 'dostluk',
    quest: 'friendship',
  ),
  Words(
    front: "The loud noise frightened the child.",
    back: "Yüksek ses çocuğu korkuttu.",
    list: 'B1',
    answer: 'korkutmak',
    quest: 'frighten',
  ),
  Words(
    front: "He looked frightened after seeing the ghost.",
    back: "Hayaleti gördükten sonra ürkmüş görünüyordu.",
    list: 'B1',
    answer: 'ürkmüş',
    quest: 'frightened',
  ),
  Words(
    front: "The movie was a frightening story about a haunted house.",
    back: "Film, perili bir ev hakkındaki korkutucu bir hikayeydi.",
    list: 'B1',
    answer: 'korkutucu',
    quest: 'frightening',
  ),
  Words(
    front: "We ate frozen pizza for dinner last night.",
    back: "Dün gece akşam yemeğinde dondurulmuş pizza yedik.",
    list: 'B1',
    answer: 'donmuş',
    quest: 'frozen',
  ),
  Words(
    front: "I usually have fried eggs and coffee for breakfast.",
    back: "Kahvaltıda genellikle kızarmış yumurta ve kahve içerim.",
    list: 'B1',
    answer: 'kızarmış',
    quest: 'fried',
  ),
  Words(
    front: "The car needs more fuel before we can continue our journey.",
    back:
        "Yolculuğa devam edebilmemiz için arabanın daha fazla yakıta ihtiyacı var.",
    list: 'B1',
    answer: 'yakıt',
    quest: 'fuel',
  ),
  Words(
    front: "What is the function of this button?",
    back: "Bu düğmenin işlevi nedir?",
    list: 'B1',
    answer: 'işlev',
    quest: 'function',
  ),
  Words(
    front: "She wore a luxurious fur coat in the winter.",
    back: "Kışın lüks bir kürk manto giydi.",
    list: 'B1',
    answer: 'kürk',
    quest: 'fur',
  ),
  Words(
    front:
        "Do you want to learn more about it? - Yes, I'd like to know further details.",
    back:
        "Bunun hakkında daha fazla bilgi edinmek ister misiniz? - Evet, daha fazla ayrıntı öğrenmek isterim.",
    list: 'B1',
    answer: 'daha ileri',
    quest: 'further',
  ),
  Words(
    front: "He parked his car in the garage.",
    back: "Arabasını garaja park etti.",
    list: 'B1',
    answer: 'tamirhane',
    quest: 'garage',
  ),
  Words(
    front: "Let's gather in the living room before we leave.",
    back: "Gitmeden önce salonda toplanalım.",
    list: 'B1',
    answer: 'toplanmak',
    quest: 'gather',
  ),
  Words(
    front: "Generally speaking, most people enjoy listening to music.",
    back: "Genel olarak konuşursak, çoğu insan müzik dinlemekten zevk alır.",
    list: 'B1',
    answer: 'genelde',
    quest: 'Generally',
  ),
  Words(
    front: "This new technology is a major advancement for our generation.",
    back: "Bu yeni teknoloji, bizim jenerasyonumuz için önemli bir gelişmedir.",
    list: 'B1',
    answer: 'üretme',
    quest: 'generation',
  ),
  Words(
    front: "She is a generous person who always donates to charity.",
    back: "Her zaman hayır kurumlarına bağış yapan cömert bir insandır.",
    list: 'B1',
    answer: 'cömert',
    quest: 'generous',
  ),
  Words(
    front: "He was a gentle giant with a kind heart.",
    back: "Nazik kalpli, yumuşak dev birisiydi.",
    list: 'B1',
    answer: 'kibar',
    quest: 'gentle',
  ),
  Words(
    front: "He was a true gentleman who always treated others with respect.",
    back: "Gerçek bir beyefendiydi, başkalarına her zaman saygıyla davranırdı.",
    list: 'B1',
    answer: 'beyefendi',
    quest: 'gentleman',
  ),
  Words(
    front: "Have you ever seen a ghost?",
    back: "Hiç hayalet gördünüz mü?",
    list: 'B1',
    answer: 'hayalet, ruh',
    quest: 'ghost',
  ),
  Words(
    front: "The story was about a kind giant who helped the poor.",
    back: "Hikaye, fakirlere yardım eden nazik bir dev hakkındaydı.",
    list: 'B1',
    answer: 'dev',
    quest: 'giant',
  ),
  Words(
    front: "I'm so glad you could make it! - I'm glad to be here.",
    back: "Gelebildiğine çok sevindim! - Geldiğime sevindim.",
    list: 'B1',
    answer: 'memnun',
    quest: 'glad',
  ),
  Words(
    front: "Climate change is a global issue that affects everyone.",
    back: "İklim değişikliği herkesi etkileyen küresel bir sorundur.",
    list: 'B1',
    answer: 'küresel',
    quest: 'global',
  ),
  Words(
    front: "Don't forget to wear your gloves when it's cold outside.",
    back: "Dışarısı soğuk olduğunda eldivenlerini takmayı unutma.",
    list: 'B1',
    answer: 'eldiven',
    quest: 'glove',
  ),
  Words(
    front: "Where are you going? - I'm going to the store.",
    back: "Nereye gidiyorsun? - Marketlere gidiyorum.",
    list: 'B1',
    answer: 'gitmek',
    quest: 'go',
  ),
  Words(
    front: "These goods are imported from China.",
    back: "Bu mallar Çin'den ithal edilmektedir.",
    list: 'B1',
    answer: 'mal',
    quest: 'goods',
  ),
  Words(
    front: "He got a good grade on his history test.",
    back: "Tarih sınavından iyi puan aldı.",
    list: 'B1',
    answer: 'puanlamak',
    quest: 'grade',
  ),
  Words(
    front: "She graduated from university last year.",
    back: "Geçen yıl üniversiteden mezun oldu.",
    list: 'B1',
    answer: 'mezun olmak',
    quest: 'graduate',
  ),
  Words(
    front: "Wheat is a type of grain that is used to make bread.",
    back: "Buğday, ekmek yapmak için kullanılan bir tahıl türüdür.",
    list: 'B1',
    answer: 'tahıl',
    quest: 'grain',
  ),
  Words(
    front: "I am grateful for your help.",
    back: "Yardımın için minnettarım.",
    list: 'B1',
    answer: 'minnettar',
    quest: 'grateful',
  ),
  Words(
    front: "The economy is experiencing a period of rapid growth.",
    back: "Ekonomi hızlı bir büyüme dönemi yaşıyor.",
    list: 'B1',
    answer: 'büyüme',
    quest: 'growth',
  ),
  Words(
    front: "The security guard protects the building from intruders.",
    back: "Güvenlik görevlisi binayı izinsiz girenlere karşı korur.",
    list: 'B1',
    answer: 'korumak',
    quest: 'guard',
  ),
  Words(
    front: "He pleaded guilty to the crime.",
    back: "Suçu kabul etti.",
    list: 'B1',
    answer: 'suçlu',
    quest: 'guilty',
  ),
  Words(
    front: "Please hold this in your hand for a moment.",
    back: "Lütfen bunu bir an elinizde tutun.",
    list: 'B1',
    answer: 'el',
    quest: 'hand',
  ),
  Words(
    front: "Can you hang this picture on the wall for me?",
    back: "Bu resmi benim için duvara asabilir misin?",
    list: 'B1',
    answer: 'asmak',
    quest: 'hang',
  ),
  Words(
    front: "Money can't buy happiness.",
    back: "Para mutluluk satın alamaz.",
    list: 'B1',
    answer: 'mutluluk',
    quest: 'happiness',
  ),
  Words(
    front: "I can hardly believe it! - I know, it's incredible.",
    back: "Buna inanmakta güçlük çekiyorum! - Biliyorum, inanılmaz.",
    list: 'B1',
    answer: 'ancak, güçlükle',
    quest: 'hardly',
  ),
  Words(
    front: "I don't hate you, I'm just disappointed in your actions.",
    back:
        " senden nefret etmiyorum, sadece yaptıklarından hayal kırıklığına uğradım.",
    list: 'B1',
    answer: 'nefret etmek',
    quest: 'hate',
  ),
  Words(
    front: "He was wearing a hat on his head.",
    back: "Başında bir şapka vardı.",
    list: 'B1',
    answer: 'kafa',
    quest: 'head',
  ),
  Words(
    front: "The news headline read 'President Announces New Tax Plan'.",
    back: "Haber başlığı 'Başkan Yeni Vergi Planı Açıkladı' idi.",
    list: 'B1',
    answer: 'manşet',
    quest: 'headline',
  ),
  Words(
    front: "Turn on the heating, I'm feeling cold.",
    back: "Isıtmayı aç, üşüyorum.",
    list: 'B1',
    answer: 'ısınma',
    quest: 'heating',
  ),
  Words(
    front: "It was raining heavily, so we decided to stay indoors.",
    back: "Şiddetli yağmur yağıyordu, bu yüzden içeride kalmaya karar verdik.",
    list: 'B1',
    answer: 'aşırı derecede, ağır',
    quest: 'heavily',
  ),
  Words(
    front: "The teacher highlighted the most important points in the lesson.",
    back: "Öğretmen, dersteki en önemli noktaları vurguladı.",
    list: 'B1',
    answer: 'altını çizmek',
    quest: 'highlight',
  ),
  Words(
    front: "She is highly intelligent and qualified for the job.",
    back: "Son derece zeki ve işe nitelikli.",
    list: 'B1',
    answer: 'ziyadesiyle',
    quest: 'highly',
  ),
  Words(
    front: "We need to hire a new accountant for the company.",
    back: "Şirket için yeni bir muhasebeci tutmamız gerekiyor.",
    list: 'B1',
    answer: 'kiralamak',
    quest: 'hire',
  ),
  Words(
    front: "The Great Wall of China is a historic landmark.",
    back: "Çin Seddi tarihi bir dönüm noktasıdır.",
    list: 'B1',
    answer: 'tarihi',
    quest: 'historic',
  ),
  Words(
    front: "This book provides a historical account of World War II.",
    back: "Bu kitap, II. Dünya Savaşı hakkında tarihi bir anlatım sunar.",
    list: 'B1',
    answer: 'tarihsel',
    quest: 'historical',
  ),
  Words(
    front: "He is a kind and honest person.",
    back: "Kibar ve dürüst bir insandır.",
    list: 'B1',
    answer: 'dürüst',
    quest: 'honest',
  ),
  Words(
    front: "I had a horrible experience at the dentist yesterday.",
    back: "Dün dişçide berbat bir deneyim yaşadım.",
    list: 'B1',
    answer: 'berbat',
    quest: 'horrible',
  ),
  Words(
    front: "This movie is a horror story about a haunted house.",
    back: "Bu film, perili bir ev hakkındaki bir korku hikayesidir.",
    list: 'B1',
    answer: 'korku',
    quest: 'horror',
  ),
  Words(
    front: "He was a gracious host who made us feel welcome.",
    back: "Bizi hoş geldiniz hissettiren nazik bir ev sahibiydi.",
    list: 'B1',
    answer: 'ev sahibi',
    quest: 'host',
  ),
  Words(
    front: "People go hunting for deer and other wild animals.",
    back: "İnsanlar geyik ve diğer vahşi hayvanları avlamak için ava çıkarlar.",
    list: 'B1',
    answer: 'avlanmak',
    quest: 'hunt',
  ),
  Words(
    front: "The hurricane caused widespread damage to the coastal towns.",
    back: "Kasırga, kıyı kasabalarında büyük hasara neden oldu.",
    list: 'B1',
    answer: 'kasırga',
    quest: 'hurricane',
  ),
  Words(
    front: "Hurry up, we don't want to be late! - I'm coming, I'm coming!",
    back: "Acele et, geç kalmak istemiyoruz! - Geliyorum, geliyorum!",
    list: 'B1',
    answer: 'acele etmek',
    quest: 'Hurry',
  ),
  Words(
    front: "Everyone has a unique identity that makes them special.",
    back: "Herkesin onu özel yapan benzersiz bir kimliği vardır.",
    list: 'B1',
    answer: 'kişilik, kimlik',
    quest: 'identity',
  ),
  Words(
    front: "Please don't ignore my question. I want an answer.",
    back: "Lütfen sorumu görmezden gelmeyin. Cevap istiyorum.",
    list: 'B1',
    answer: 'görmezden gelmek',
    quest: 'ignore',
  ),
  Words(
    front: "Children often have imaginary friends.",
    back: "Çocukların genellikle hayali arkadaşları olur.",
    list: 'B1',
    answer: 'hayali',
    quest: 'imaginary',
  ),
  Words(
    front: "We need an immediate solution to this problem.",
    back: "Bu soruna acil bir çözüme ihtiyacımız var.",
    list: 'B1',
    answer: 'acil',
    quest: 'immediate',
  ),
  Words(
    front:
        "Many immigrants come to the United States in search of a better life.",
    back: "Birçok göçmen, daha iyi bir yaşam arayışı içinde ABD'ye geliyor.",
    list: 'B1',
    answer: 'göçmen',
    quest: 'immigrant',
  ),
  Words(
    front: "The discovery of penicillin had a major impact on medicine.",
    back: "Penisilinin keşfi, tıp alanında büyük bir etki yarattı.",
    list: 'B1',
    answer: 'darbe, etki',
    quest: 'impact',
  ),
  Words(
    front: "Turkey imports a lot of coffee from Brazil.",
    back: "Türkiye, Brezilya'dan çok fazla kahve ithal ediyor.",
    list: 'B1',
    answer: 'belirtmek',
    quest: 'import',
  ),
  Words(
    front: "Education is of great importance for a successful future.",
    back: "Başarılı bir gelecek için eğitim büyük önem taşımaktadır.",
    list: 'B1',
    answer: 'saygınlık',
    quest: 'importance',
  ),
  Words(
    front: "He made a good impression on his new boss.",
    back: "Yeni patronunda iyi bir etki bıraktı.",
    list: 'B1',
    answer: 'etki',
    quest: 'impression',
  ),
  Words(
    front: "She gave an impressive speech about climate change.",
    back: "İklim değişikliği hakkında etkileyici bir konuşma yaptı.",
    list: 'B1',
    answer: 'etkileyici',
    quest: 'impressive',
  ),
  Words(
    front: "There has been a significant improvement in his English skills.",
    back: "İngilizce becerilerinde önemli bir gelişme oldu.",
    list: 'B1',
    answer: 'gelişim',
    quest: 'improvement',
  ),
  Words(
    front:
        "It was incredibly hot outside today. - Indeed, I couldn't even step outside for a minute.",
    back:
        "Bugün dışarıda inanılmaz derecede sıcaktı. - Doğrusu, bir dakika bile dışarı çıkamadım.",
    list: 'B1',
    answer: 'akıl almaz derecede',
    quest: 'incredibly',
  ),
  Words(
    front: "The smoke from the fire indicates that there is a problem.",
    back: "Yangından çıkan duman, bir sorun olduğunu gösteriyor.",
    list: 'B1',
    answer: 'belirtisi olmak',
    quest: 'indicate',
  ),
  Words(
    front: "He gave me indirect instructions on how to complete the task.",
    back: "Görevi tamamlamam için bana dolaylı talimatlar verdi.",
    list: 'B1',
    answer: 'dolaylı',
    quest: 'indirect',
  ),

  Words(
    front: "It's raining outside, so we'll stay indoors today.",
    back: "Dışarıda yağmur yağıyor, bu yüzden bugün evde kalacağız.",
    list: 'B1',
    answer: 'evde',
    quest: 'indoors',
  ),
  Words(
    front: "Social media can have a negative influence on young people.",
    back: "Sosyal medya, gençler üzerinde olumsuz bir etki yaratabilir.",
    list: 'B1',
    answer: 'etkilemek',
    quest: 'influence',
  ),
  Words(
    front: "Flour, sugar, and eggs are the main ingredients in this cake.",
    back: "Un, şeker ve yumurta bu kekin temel bileşenleridir.",
    list: 'B1',
    answer: 'bileşen',
    quest: 'ingredient',
  ),
  Words(
    front: "He was injured in a car accident.",
    back: "Trafik kazasında yaralandı.",
    list: 'B1',
    answer: 'yaralamak',
    quest: 'injure',
  ),
  Words(
    front: "The police are looking for the injured person.",
    back: "Polis yaralı kişiyi arıyor.",
    list: 'B1',
    answer: 'yaralı',
    quest: 'injured',
  ),
  Words(
    front: "He was proven innocent of the crime.",
    back: "Suçsuz olduğu kanıtlandı.",
    list: 'B1',
    answer: 'masum',
    quest: 'innocent',
  ),
  Words(
    front: "She is a woman of great intelligence.",
    back: "O, yüksek zekaya sahip bir kadın.",
    list: 'B1',
    answer: 'zeka',
    quest: 'intelligence',
  ),
  Words(
    front: "I don't intend to be rude, but I have to disagree with you.",
    back:
        "Kaba olmak niyetinde değilim, ancak seninle aynı fikirde olamıyorum.",
    list: 'B1',
    answer: 'niyet etmek',
    quest: 'intend',
  ),
  Words(
    front: "What is your intention behind asking this question?",
    back: "Bu soruyu sorma maksadın nedir?",
    list: 'B1',
    answer: 'maksat',
    quest: 'intention',
  ),
  Words(
    front: "They are investing in renewable energy sources.",
    back: "Yenilenebilir enerji kaynaklarına yatırım yapıyorlar.",
    list: 'B1',
    answer: 'yatırım yapmak',
    quest: 'invest',
  ),
  Words(
    front: "In this study, we will investigate the source of the common cold.",
    back: "Bu çalışmada, soğuk algınlığının kaynağını araştıracağız.",
    list: 'B1',
    answer: 'araştırmak',
    quest: 'investigate',
  ),
  Words(
    front:
        "Are you involved in this project? - Yes, I'm one of the team members.",
    back: "Bu projeye dahil misiniz? - Evet, ekip üyelerinden biriyim.",
    list: 'B1',
    answer: 'ilgili',
    quest: 'involved',
  ),
  Words(
    front: "Iron is a common element found in many rocks and minerals.",
    back: "Demir, birçok kayaç ve mineralde bulunan yaygın bir elementtir.",
    list: 'B1',
    answer: 'demir',
    quest: 'Iron',
  ),
  Words(
    front: "Climate change is a major issue that we need to address.",
    back: "İklim değişikliği, ele almamız gereken önemli bir konudur.",
    list: 'B1',
    answer: 'konu',
    quest: 'issue',
  ),
  Words(
    front:
        "He reads scientific journals to stay up-to-date on the latest research.",
    back: "En son araştırmalardan haberdar olmak için bilimsel dergileri okur.",
    list: 'B1',
    answer: 'dergi',
    quest: 'journal',
  ),
  Words(
    front: "Don't judge a book by its cover.",
    back: "Bir kitabı kapağına göre yargılama.",
    list: 'B1',
    answer: 'yargılamak',
    quest: 'judge',
  ),
  Words(
    front: "He is very keen on learning new languages.",
    back: "Yeni diller öğrenmeye çok hevesli.",
    list: 'B1',
    answer: 'hevesli',
    quest: 'keen',
  ),
  Words(
    front: "Please give me the keys to the car.",
    back: "Lütfen bana arabanın anahtarlarını ver.",
    list: 'B1',
    answer: 'anahtar',
    quest: 'key',
  ),
  Words(
    front: "He is a fast typist and can write without looking at the keyboard.",
    back: "Hızlı bir yazıcıdır ve klavyeye bakmadan yazabilir.",
    list: 'B1',
    answer: 'klavye',
    quest: 'keyboard',
  ),
  Words(
    front: "He kicked the ball into the net.",
    back: "Topu ağlara tekmeledi.",
    list: 'B1',
    answer: 'tekmelemek',
    quest: 'kick',
  ),

  Words(
    front: "There are many different kinds of flowers in the world.",
    back: "Dünyada pek çok farklı çiçek türü vardır.",
    list: 'B1',
    answer: 'tür, çeşit',
    quest: 'kind',
  ),
  Words(
    front: "They shared a kiss goodbye.",
    back: "Hoşçakal öpücüğü paylaştılar.",
    list: 'B1',
    answer: 'öpmek',
    quest: 'kiss',
  ),
  Words(
    front: "Someone is knocking on the door. - Can you go answer it?",
    back: "Kapı çalıyor. - Açmaya gidebilir misin?",
    list: 'B1',
    answer: 'kapı çalmak',
    quest: 'knock',
  ),
  Words(
    front: "This shirt has a designer label.",
    back: "Bu gömleğin tasarımcı etiketi var.",
    list: 'B1',
    answer: 'etiket',
    quest: 'label',
  ),
  Words(
    front: "Scientists conduct experiments in a laboratory.",
    back: "Bilimciler laboratuvarda deneyler yaparlar.",
    list: 'B1',
    answer: 'laboratuvar',
    quest: 'laboratory',
  ),
  Words(
    front: "There is a lack of qualified teachers in the education system.",
    back: "Eğitim sisteminde nitelikli öğretmen eksikliği var.",
    list: 'B1',
    answer: 'yokluk',
    quest: 'lack',
  ),
  Words(
    front:
        "Are you interested in reading the latest news? - Yes, I want to stay up-to-date on current events.",
    back:
        "En son haberleri okumakla ilgileniyor musunuz? - Evet, güncel olaylardan haberdar olmak istiyorum.",
    list: 'B1',
    answer: 'son',
    quest: 'latest',
  ),
  Words(
    front: "Please lay the carpet on the floor.",
    back: "Lütfen halıyı yere ser.",
    list: 'B1',
    answer: 'sermek',
    quest: 'lay',
  ),
  Words(
    front: "The cake has a chocolate layer and a vanilla layer.",
    back: "Pastanın bir çikolata katmanı ve bir vanilya katmanı var.",
    list: 'B1',
    answer: 'katman',
    quest: 'layer',
  ),
  Words(
    front: "He can lead the team to victory.",
    back: "Takımı zafere götürebilir.",
    list: 'B1',
    answer: 'yol göstermek',
    quest: 'lead',
  ),
  Words(
    front: "She is a leading expert in the field of artificial intelligence.",
    back: "Yapay zeka alanında önde gelen bir uzmandır.",
    list: 'B1',
    answer: 'öncülük eden',
    quest: 'leading',
  ),
  Words(
    front: "She used a leaf to wrap her sandwich.",
    back: "Sandviçini sarmak için bir yaprak kullandı.",
    list: 'B1',
    answer: 'yaprak',
    quest: 'leaf',
  ),
  Words(
    front: "This jacket is made of genuine leather.",
    back: "Bu ceket hakiki deriden yapılmıştır.",
    list: 'B1',
    answer: 'deri',
    quest: 'leather',
  ),
  Words(
    front: "Is it legal to park here? - No, there is a no parking sign.",
    back: "Burada park etmek yasal mı? - Hayır, park yasak tabelası var.",
    list: 'B1',
    answer: 'yasal',
    quest: 'legal',
  ),
  Words(
    front: "He enjoys reading in his leisure time.",
    back: "Boş vaktinde okumaktan zevk alır.",
    list: 'B1',
    answer: 'boş vakit',
    quest: 'leisure',
  ),
  Words(
    front: "What is the length of this table? - It is two meters long.",
    back: "Bu masanın uzunluğu nedir? - İki metre uzunluğundadır.",
    list: 'B1',
    answer: 'uzunluk',
    quest: 'length',
  ),
  Words(
    front: "He is a beginner at this level, but he is learning quickly.",
    back: "Bu seviyede bir başlangıç, ancak hızlı öğreniyor.",
    list: 'B1',
    answer: 'seviye',
    quest: 'level',
  ),
  Words(
    front: "Don't lie to me, I know the truth.",
    back: "Bana yalan söyleme, gerçeği biliyorum.",
    list: 'B1',
    answer: 'yalan atmak',
    quest: 'lie',
  ),
  Words(
    front: "I like chocolate ice cream.",
    back: "Çikolatalı dondurma beğeniyorum.",
    list: 'B1',
    answer: 'beğenmek',
    quest: 'like',
  ),
  Words(
    front: "There is a speed limit of 50 kilometers per hour on this road.",
    back: "Bu yolda hız limiti saatte 50 kilometredir.",
    list: 'B1',
    answer: 'sınırlandırmak',
    quest: 'limit',
  ),
  Words(
    front: "Her lower lip trembled as if she was about to cry.",
    back: "Alt dudağı ağlamak üzereymiş gibi titredi.",
    list: 'B1',
    answer: 'dudak',
    quest: 'lip',
  ),
  Words(
    front: "Water is a liquid that is essential for life.",
    back: "Su, yaşam için gerekli olan bir sıvıdır.",
    list: 'B1',
    answer: 'sıvı',
    quest: 'liquid',
  ),
  Words(
    front: "He is a famous writer who has written many works of literature.",
    back: "Edebiyat alanında birçok eser yazmış ünlü bir yazardır.",
    list: 'B1',
    answer: 'edebiyat',
    quest: 'literature',
  ),
  Words(
    front: "Where do you live? - I live in Istanbul.",
    back: "Nerede yaşıyorsun? - İstanbul'da yaşıyorum.",
    list: 'B1',
    answer: 'yaşamak',
    quest: 'live',
  ),
  Words(
    front: "All living things need water to survive.",
    back: "Tüm canlıların hayatta kalmak için suya ihtiyacı vardır.",
    list: 'B1',
    answer: 'canlı',
    quest: 'living',
  ),
  Words(
    front: "We bought some local cheese from the market.",
    back: "Pazardan biraz yerel peynir aldık.",
    list: 'B1',
    answer: 'lokal, yerel',
    quest: 'local',
  ),
  Words(
    front: "Can you locate my phone? I can't seem to find it.",
    back: "Telefonumu bulabilir misin? Bulamıyorum galiba.",
    list: 'B1',
    answer: 'yerini bulmak',
    quest: 'locate',
  ),
  Words(
    front: "The missing child was located in a nearby town.",
    back: "Kayıp çocuk yakındaki bir kasabada bulundu.",
    list: 'B1',
    answer: 'tespit edilmiş',
    quest: 'located',
  ),
  Words(
    front: "What is your current location? - I'm at home right now.",
    back: "Mevcut konumunuz nedir? - Şu an evdeyim.",
    list: 'B1',
    answer: 'konum, yer',
    quest: 'location',
  ),
  Words(
    front: "He felt lonely after his friends moved away.",
    back: "Arkadaşları taşındıktan sonra kendini yalnız hissetti.",
    list: 'B1',
    answer: 'yalnız',
    quest: 'lonely',
  ),
  Words(
    front: "The company suffered a loss of profits last year.",
    back: "Şirket geçen yıl kâr kaybına uğradı.",
    list: 'B1',
    answer: 'zarar',
    quest: 'loss',
  ),
  Words(
    front: "Luxury cars are very expensive.",
    back: "Lüks arabalar çok pahalıdır.",
    list: 'B1',
    answer: 'lüks',
    quest: 'Luxury',
  ),
  Words(
    front: "He is acting mad. Maybe he didn't get enough sleep.",
    back: "Deli gibi davranıyor. Belki yeterince uyumamıştır.",
    list: 'B1',
    answer: 'deli',
    quest: 'mad',
  ),
  Words(
    front: "Do you believe in magic? - No, I am a rational person.",
    back: "Sihire inanıyor musun? - Hayır, mantıklı bir insanım.",
    list: 'B1',
    answer: 'büyü',
    quest: 'magic',
  ),
  Words(
    front: "She speaks English mainly, but she also knows some French.",
    back: "主に英語を話しますが、フランス語も少し話せます。",
    list: 'B1',
    answer: 'daha çok',
    quest: 'mainly',
  ),
  Words(
    front: "Let's go to the mall this weekend. - Great idea!",
    back: "Bu hafta sonu alışveriş merkezine gidelim. - Harika fikir!",
    list: 'B1',
    answer: 'vurmak',
    quest: 'mall',
  ),
  Words(
    front: "Good management is essential for the success of any business.",
    back: "Herhangi bir işletmenin başarısı için iyi yönetim şarttır.",
    list: 'B1',
    answer: 'işletme',
    quest: 'management',
  ),
  Words(
    front: "The farmer's market is a great place to find fresh produce.",
    back: "Çiftçi pazarı taze ürünler bulmak için harika bir yerdir.",
    list: 'B1',
    answer: 'çarşı',
    quest: 'market',
  ),
  Words(
    front:
        "He works in marketing and is responsible for promoting the company's products.",
    back:
        "Pazarlama alanında çalışıyor ve şirketin ürünlerinin tanıtımından sorumlu.",
    list: 'B1',
    answer: 'pazarlama',
    quest: 'marketing',
  ),
  Words(
    front: "Marriage is a lifelong commitment.",
    back: "Evlilik ömür boyu bir bağlılıktır.",
    list: 'B1',
    answer: 'evlenme',
    quest: 'Marriage',
  ),
  Words(
    front:
        "John was working on his report, meanwhile, Mary was checking her emails.",
    back:
        "John raporu üzerinde çalışıyordu, bu arada Mary e-postalarını kontrol ediyordu.",
    list: 'B1',
    answer: 'aynı anda',
    quest: 'meanwhile',
  ),
  Words(
    front:
        "Can you measure the temperature of the water? - Yes, it is 20 degrees Celsius.",
    back: "Suyun sıcaklığını ölçebilir misin? - Evet, 20 derece Santigrat.",
    list: 'B1',
    answer: 'ölçmek',
    quest: 'measure',
  ),
  Words(
    front: "I would like a medium coffee, please. - Coming right up!",
    back: "Orta boy bir kahve rica ederim. - Hemen geliyor!",
    list: 'B1',
    answer: 'orta',
    quest: 'medium',
  ),
  Words(
    front: "He is suffering from a mental illness.",
    back: "Akli bir hastalıktan muzdarip.",
    list: 'B1',
    answer: 'akli',
    quest: 'mental',
  ),
  Words(
    front: "Don't forget to mention it when you see him.",
    back: "Onu gördüğünüzde bahsetmeyi unutmayın.",
    list: 'B1',
    answer: 'bahsetmek',
    quest: 'mention',
  ),
  Words(
    front: "Please clean up this mess before you leave.",
    back: "Gitmeden önce bu karışıklığı temizleyin lütfen.",
    list: 'B1',
    answer: 'karışıklık',
    quest: 'mess',
  ),
  Words(
    front: "The weather is mild today, not too hot or too cold.",
    back: "Hava bugün ılıman, fazla sıcak veya fazla soğuk değil.",
    list: 'B1',
    answer: 'ılıman',
    quest: 'mild',
  ),
  Words(
    front: "Coal is mined from underground mines.",
    back: "Kömür, yeraltı madenlerinden çıkarılır.",
    list: 'B1',
    answer: 'maden, mayın',
    quest: 'mine',
  ),
  Words(
    front: "Please mix the flour and sugar in a bowl.",
    back: "Lütfen unu ve şekeri bir kasede karıştırın.",
    list: 'B1',
    answer: 'karıştırmak',
    quest: 'mix',
  ),
  Words(
    front: "This is a mixture of different spices.",
    back: "Bu, farklı baharatların bir karışımıdır.",
    list: 'B1',
    answer: 'karışım',
    quest: 'mixture',
  ),
  Words(
    front: "What is your mood today? - I'm feeling happy and optimistic.",
    back: "Bugün ruh halin nasıl? - Kendimi mutlu ve iyimser hissediyorum.",
    list: 'B1',
    answer: 'ruh hali',
    quest: 'mood',
  ),
  Words(
    front: "Can you move the table to the other side of the room? - Sure.",
    back: "Masayı odanın diğer tarafına taşıyabilir misin? - Elbette.",
    list: 'B1',
    answer: 'hareket etmek',
    quest: 'move',
  ),
  Words(
    front: "The car got stuck in the mud after the heavy rain.",
    back: "Şiddetli yağmurdan sonra araba çamura saplandı.",
    list: 'B1',
    answer: 'çamur',
    quest: 'mud',
  ),
  Words(
    front: "The murder mystery remains unsolved.",
    back: "Cinayet gizemi çözülmeden kalıyor.",
    list: 'B1',
    answer: 'öldürmek',
    quest: 'murder',
  ),
  Words(
    front: "He exercised regularly to build muscle.",
    back: "Kas yapmak için düzenli olarak egzersiz yaptı.",
    list: 'B1',
    answer: 'adale, kas',
    quest: 'muscle',
  ),
  Words(
    front: "The detective is trying to unravel the mystery.",
    back: "Dedektif, gizemi çözmeye çalışıyor.",
    list: 'B1',
    answer: 'sır',
    quest: 'mystery',
  ),
  Words(
    front: "Can you help me nail this picture to the wall? - Yes, of course.",
    back: "Bu resmi duvara çivilememe yardım edebilir misin? - Evet tabii ki.",
    list: 'B1',
    answer: 'çivilemek',
    quest: 'nail',
  ),
  Words(
    front: "This story is a well-written narrative.",
    back: "Bu hikaye iyi yazılmış bir anlatıdır.",
    list: 'B1',
    answer: 'anlatı',
    quest: 'narrative',
  ),
  Words(
    front: "Turkey is a nation with a rich history and culture.",
    back: "Türkiye, zengin bir tarihe ve kültüre sahip bir ulustur.",
    list: 'B1',
    answer: 'ulus',
    quest: 'nation',
  ),
  Words(
    front: "He is a native speaker of English.",
    back: "Doğma dili İngilizce olan biridir.",
    list: 'B1',
    answer: 'yerli',
    quest: 'native',
  ),
  Words(
    front: "Plants naturally produce oxygen.",
    back: "Bitkiler doğal olarak oksijen üretir.",
    list: 'B1',
    answer: 'doğal olarak',
    quest: 'naturally',
  ),
  Words(
    front: "Do you necessarily need to finish this today? - No, it can wait.",
    back: "Bunu bugün bitirmek zorunda mısın? - Hayır, bekleyebilir.",
    list: 'B1',
    answer: 'şart',
    quest: 'necessarily',
  ),
  Words(
    front: "I don't need your help, I can do it myself.",
    back: "Yardımına ihtiyacım yok, kendim yapabilirim.",
    list: 'B1',
    answer: 'ihtiyaç duymak',
    quest: 'need',
  ),
  Words(
    front: "The nurse gave him a needle in his arm.",
    back: "Hemşire ona koluna bir iğne yaptı.",
    list: 'B1',
    answer: 'iğnelemek',
    quest: 'needle',
  ),
  Words(
    front: "I live in a quiet neighbourhood in the suburbs.",
    back: "Varoşlarda sakin bir mahallede oturuyorum.",
    list: 'B1',
    answer: 'mahalle',
    quest: 'neighbourhood',
  ),
  Words(
    front: "I don't like chocolate, neither does my sister. ",
    back: "Ben çikolatayı sevmiyorum, ablam da sevmiyor.",
    list: 'B1',
    answer: 'hiçbir',
    quest: 'neither',
  ),
  Words(
    front: "What are your plans for next weekend? - I'm not sure yet.",
    back: "Gelecek hafta sonu için planların neler? - Henüz emin değilim.",
    list: 'B1',
    answer: 'sonraki',
    quest: 'next',
  ),
  Words(
    front: "He does not like vegetables, nor does he like fruit.",
    back: "Sebze sevmez, meyve de sevmez.",
    list: 'B1',
    answer: 'ne de',
    quest: 'nor',
  ),
  Words(
    front: "Northern England is known for its beautiful countryside.",
    back: "Kuzey İngiltere, güzel kırsalı ile tanınır.",
    list: 'B1',
    answer: 'Kuzeyli',
    quest: 'Northern',
  ),
  Words(
    front: "Please write a note to remind me to buy milk.",
    back: "Süt almamı hatırlatmak için lütfen bir not yaz.",
    list: 'B1',
    answer: 'not',
    quest: 'note',
  ),
  Words(
    front: "What time is it now? - It is 3:15 pm.",
    back: "Şimdi saat kaç? - Saat 15:15.",
    list: 'B1',
    answer: 'şimdi',
    quest: 'now',
  ),
  Words(
    front: "The world is facing a threat of nuclear war.",
    back: "Dünya nükleer savaş tehdidiyle karşı karşıyadır.",
    list: 'B1',
    answer: 'nükleer',
    quest: 'nuclear',
  ),
  Words(
    front: "It is obvious that he is lying. - I know, right?",
    back: "Yalan söylediği aşikar. - Biliyorum değil mi?",
    list: 'B1',
    answer: 'besbelli',
    quest: 'obvious',
  ),
  Words(
    front: "Obviously, you need to study harder if you want to pass the exam.",
    back: "Açıktır ki, sınavı geçmek istiyorsan daha sıkı çalışman gerekiyor.",
    list: 'B1',
    answer: 'besbelli',
    quest: 'Obviously',
  ),
  Words(
    front: "On this special occasion we have brought a gift for you",
    back: " Bu özel vesileyle sizler için bir hediye getirdim.",
    list: 'B1',
    answer: 'fırsat, vesile',
    quest: 'occasion',
  ),
  Words(
    front: "A natural disaster can occur at any time.",
    back: "Doğal afet her an meydana gelebilir.",
    list: 'B1',
    answer: 'meydana gelmek',
    quest: 'occur',
  ),
  Words(
    front: "It's a bit odd that he didn't show up for the meeting.",
    back: "Toplantıya gelmemesi biraz garip.",
    list: 'B1',
    answer: 'garip',
    quest: 'odd',
  ),
  Words(
    front: "We need your official documents to complete your application.",
    back: "Başvurunuzu tamamlamak için resmi belgelerinize ihtiyacımız var.",
    list: 'B1',
    answer: 'resmi',
    quest: 'official',
  ),
  Words(
    front: "Wearing a suit and tie is a bit old-fashioned nowadays.",
    back: "Günümüzde takım elbise ve kravat takmak biraz eski moda.",
    list: 'B1',
    answer: 'eski moda',
    quest: 'old-fashioned',
  ),
  Words(
    front: "Let's do this once and for all.",
    back: "Hadi bunu bir kereliğine halledelim.",
    list: 'B1',
    answer: 'bir kez',
    quest: 'once',
  ),
  Words(
    front:
        "The surgery was a success, and the patient is recovering well from the operation.",
    back:
        "Ameliyat başarılıydı ve hasta operasyondan sonra iyi bir şekilde iyileşiyor.",
    list: 'B1',
    answer: 'operasyon',
    quest: 'operation',
  ),
  Words(
    front: "Ants live in highly organized colonies.",
    back: "Karıncalar son derece organize koloniler halinde yaşarlar.",
    list: 'B1',
    answer: 'organize olmuş, düzenli',
    quest: 'organized',
  ),
  Words(
    front: "She is the main organizer of the charity event.",
    back: "O, yardım etkinliğinin ana düzenleyicisidir.",
    list: 'B1',
    answer: 'düzenleyici',
    quest: 'organizer',
  ),
  Words(
    front: "This painting is an original work by a famous artist.",
    back: "Bu resim, ünlü bir sanatçının orijinal eseridir.",
    list: 'B1',
    answer: 'orijinal',
    quest: 'original',
  ),
  Words(
    front: "The city was originally a small fishing village.",
    back: "Şehir aslen küçük bir balıkçı köyüydü.",
    list: 'B1',
    answer: 'aslen',
    quest: 'originally',
  ),
  Words(
    front: "You ought to apologize for your mistake.",
    back: "Hatanız için özür dilemelisiniz.",
    list: 'B1',
    answer: 'gerekli',
    quest: 'ought',
  ),
  Words(
    front: "This is ours, not theirs.",
    back: "Bu bizim, onların değil.",
    list: 'B1',
    answer: 'bizim',
    quest: 'ours',
  ),
  Words(
    front:
        "Do you enjoy spending time outdoors? - Yes, I love hiking and camping.",
    back:
        "Açık havada vakit geçirmekten hoşlanır mısın? - Evet, yürüyüş yapmayı ve kamp yapmayı severim.",
    list: 'B1',
    answer: 'açık hava',
    quest: 'outdoor',
  ),
  Words(
    front: "Please pack your bags for the trip tomorrow.",
    back: "Lütfen yarınki yolculuk için çantaları topla.",
    list: 'B1',
    answer: 'paket',
    quest: 'pack',
  ),
  Words(
    front: "I received a package in the mail today.",
    back: "Bugün postayla bir paket aldım.",
    list: 'B1',
    answer: 'paket',
    quest: 'package',
  ),
  Words(
    front: "He suffered from a painful backache.",
    back: "Ağrıtı bir sırt ağrısı çekiyordu.",
    list: 'B1',
    answer: 'ağrılı',
    quest: 'painful',
  ),
  Words(
    front: "She looked pale and unwell.",
    back: "Soluk ve rahatsız görünüyordu.",
    list: 'B1',
    answer: 'solgun',
    quest: 'pale',
  ),
  Words(
    front: "Can you fry the eggs in a pan? - Sure.",
    back: "Yumurtaları tavada kızartır mısın? - Elbette.",
    list: 'B1',
    answer: 'tava',
    quest: 'pan',
  ),
  Words(
    front:
        "Would you like to participate in the competition? - I'm not sure yet.",
    back: "Yarışmaya katılmak ister misin? - Henüz emin değilim.",
    list: 'B1',
    answer: 'katılmak',
    quest: 'participate',
  ),
  Words(
    front: "I particularly enjoyed the chocolate cake. - Me too!",
    back: "Özellikle çikolatalı pastayı beğendim. - Ben de!",
    list: 'B1',
    answer: 'özellikle',
    quest: 'particularly',
  ),
  Words(
    front: "Did you pass the exam? - Yes, I passed with flying colors.",
    back: "Sınavı geçtin mi? - Evet, başarıyla geçtim.",
    list: 'B1',
    answer: 'geçmek',
    quest: 'pass',
  ),
  Words(
    front: "She has a great passion for music.",
    back: "Müziğe karşı büyük bir tutkusu var.",
    list: 'B1',
    answer: 'hırs',
    quest: 'passion',
  ),
  Words(
    front: "We need to find a path to the top of the mountain.",
    back: "Dağın tepesine giden bir yol bulmamız gerekiyor.",
    list: 'B1',
    answer: 'yol',
    quest: 'path',
  ),
  Words(
    front: "Can you make a payment online? - Yes, of course.",
    back: "Online ödeme yapabilir misin? - Evet tabii ki.",
    list: 'B1',
    answer: 'ödeme',
    quest: 'payment',
  ),
  Words(
    front: "We live in a peaceful neighborhood.",
    back: "Huzurlu bir mahallede yaşıyoruz.",
    list: 'B1',
    answer: 'huzurlu',
    quest: 'peaceful',
  ),
  Words(
    front: "What is the percentage of students who passed the exam? - 80%",
    back: "Sınavı geçen öğrenci yüzdesi nedir? - %80",
    list: 'B1',
    answer: 'yüzde',
    quest: 'percentage',
  ),
  Words(
    front: "He did his job perfectly.",
    back: "İşini mükemmel olarak yaptı.",
    list: 'B1',
    answer: 'mükemmel olarak',
    quest: 'perfectly',
  ),
  Words(
    front: "I don't know him personally, I've only seen him on TV.",
    back: "Onu şahsen tanımıyorum, sadece televizyonda gördüm.",
    list: 'B1',
    answer: 'şahsen',
    quest: 'personally',
  ),
  Words(
    front: "The lawyer tried to persuade the jury of his client's innocence.",
    back: "Avukat, jüriyi müvekkilinin masumiyetine ikna etmeye çalıştı.",
    list: 'B1',
    answer: 'ikna etmek',
    quest: 'persuade',
  ),
  Words(
    front:
        "He is a professional photographer who specializes in wedding photography.",
    back:
        "Düğün fotoğrafçılığı konusunda uzmanlaşmış profesyonel bir fotoğrafçıdır.",
    list: 'B1',
    answer: 'fotoğrafçı',
    quest: 'photographer',
  ),
  Words(
    front: "I'm interested in learning photography.",
    back: "Fotoğrafçılığı öğrenmekle ilgileniyorum.",
    list: 'B1',
    answer: 'fotoğrafçılık',
    quest: 'photography',
  ),
  Words(
    front: "Can you help me pin this picture to the wall? - Yes, of course.",
    back: "Bu resmi duvara raptiyememe yardım edebilir misin? - Evet tabii ki.",
    list: 'B1',
    answer: 'raptiye',
    quest: 'pin',
  ),
  Words(
    front: "The water pipe burst in the kitchen.",
    back: "Mutfakta boru patladı.",
    list: 'B1',
    answer: 'boru',
    quest: 'pipe',
  ),
  Words(
    front: "Can you place the order now? - Sure.",
    back: "Siparişi şimdi verebilir misin? - Elbette.",
    list: 'B1',
    answer: 'yerleştirmek',
    quest: 'place',
  ),
  Words(
    front: "Good planning is essential for the success of any project.",
    back: "Herhangi bir projenin başarısı için iyi planlama gereklidir.",
    list: 'B1',
    answer: 'planlama',
    quest: 'planning',
  ),
  Words(
    front: "We had a very pleasant evening together.",
    back: "Birlikte çok keyifli bir akşam geçirdik.",
    list: 'B1',
    answer: 'güzel',
    quest: 'pleasant',
  ),
  Words(
    front: "He takes great pleasure in helping others.",
    back: "Başkalarına yardım etmekten büyük zevk alıyor.",
    list: 'B1',
    answer: 'zevk',
    quest: 'pleasure',
  ),
  Words(
    front: "We have plenty of time to finish this task.",
    back: "Bu görevi bitirmek için bolca vaktimiz var.",
    list: 'B1',
    answer: 'bolluk',
    quest: 'plenty',
  ),
  Words(
    front:
        "What is the plot of this story? - It's about a detective who investigates a murder.",
    back:
        "Bu hikayenin konusu nedir? - Cinayeti araştıran bir dedektif hakkındadır.",
    list: 'B1',
    answer: 'hikayenin konusu',
    quest: 'plot',
  ),
  Words(
    front: "Two plus two equals four.",
    back: "İki artı iki dört eder.",
    list: 'B1',
    answer: 'artı',
    quest: 'plus',
  ),
  Words(
    front: "She wrote a beautiful poem about love.",
    back: "Aşk hakkında güzel bir şiir yazdı.",
    list: 'B1',
    answer: 'şiir',
    quest: 'poem',
  ),
  Words(
    front: "William Shakespeare is a famous English poet.",
    back: "William Shakespeare ünlü bir İngiliz şairdir.",
    list: 'B1',
    answer: 'şair',
    quest: 'poet',
  ),
  Words(
    front: "I enjoy reading poetry.",
    back: "Şiir okumaktan zevk alıyorum.",
    list: 'B1',
    answer: 'şiir',
    quest: 'poetry',
  ),
  Words(
    front: "The main point of the discussion was education.",
    back: "Tartışmanın ana noktası eğitimdi.",
    list: 'B1',
    answer: 'puan, nokta',
    quest: 'point',
  ),
  Words(
    front: "Be careful! That plant is poisonous.",
    back: "Dikkatli ol! O bitki zehirlidir.",
    list: 'B1',
    answer: 'zehir',
    quest: 'poison',
  ),
  Words(
    front: "Be careful! That mushroom is poisonous.",
    back: "Dikkatli ol! O mantar zehirlidir.",
    list: 'B1',
    answer: 'zehirli',
    quest: 'poisonous',
  ),
  Words(
    front:
        "What is the government's policy on education? - They are increasing funding for schools.",
    back:
        "Hükümetin eğitim politikası nedir? - Okullara ayrılan bütçeyi artırıyorlar.",
    list: 'B1',
    answer: 'politika',
    quest: 'policy',
  ),
  Words(
    front: "The conversation turned to political issues.",
    back: "Konuşma siyasi konulara döndü.",
    list: 'B1',
    answer: 'politik',
    quest: 'political',
  ),
  Words(
    front: "Barack Obama is a famous American politician.",
    back: "Barack Obama ünlü bir Amerikalı siyasetçidir.",
    list: 'B1',
    answer: 'siyasetçi',
    quest: 'politician',
  ),
  Words(
    front: "I don't like to get involved in politics.",
    back: "Politiğe karışmayı sevmem.",
    list: 'B1',
    answer: 'siyaset',
    quest: 'politics',
  ),
  Words(
    front: "The ship arrived at the port of Istanbul.",
    back: "Gemi İstanbul limanına vardı.",
    list: 'B1',
    answer: 'liman',
    quest: 'port',
  ),
  Words(
    front: "Can you paint my portrait? - Yes, of course.",
    back: "Portremi çizebilir misin? - Evet tabii ki.",
    list: 'B1',
    answer: 'portre',
    quest: 'portrait',
  ),
  Words(
    front: "He will possibly be late for the meeting.",
    back: "Muhtemelen toplantıya geç kalacak.",
    list: 'B1',
    answer: 'muhtemelen',
    quest: 'possibly',
  ),
  Words(
    front: "Please put the flowers in a pot.",
    back: "Lütfen çiçekleri bir saksıya koy.",
    list: 'B1',
    answer: 'çanak',
    quest: 'pot',
  ),
  Words(
    front: "Can you pour me a glass of juice? - Sure.",
    back: "Bana bir bardak meyve suyu döker misin? - Elbette.",
    list: 'B1',
    answer: 'dökmek',
    quest: 'pour',
  ),
  Words(
    front: "Poverty is a major problem in many countries.",
    back: "Yoksulluk, birçok ülkede önemli bir sorundur.",
    list: 'B1',
    answer: 'yokluk',
    quest: 'Poverty',
  ),
  Words(
    front: "Please put some powder on your sunburn.",
    back: "Lütfen güneş yanığına biraz pudra sür.",
    list: 'B1',
    answer: 'toz',
    quest: 'powder',
  ),
  Words(
    front: "He is a powerful leader who inspires his people.",
    back: "Halkına ilham veren güçlü bir liderdir.",
    list: 'B1',
    answer: 'güçlü',
    quest: 'powerful',
  ),
  Words(
    front: "This is a very practical tool that can be used for many purposes.",
    back: "Bu, birçok amaç için kullanılabilecek çok kullanışlı bir araçtır.",
    list: 'B1',
    answer: 'kullanışlı',
    quest: 'practical',
  ),
  Words(
    front: "She prays every night before bed.",
    back: "Her gece yatmadan önce dua eder.",
    list: 'B1',
    answer: 'dua etmek',
    quest: 'pray',
  ),
  Words(
    front: "His prayers for his son's recovery were answered.",
    back: "Oğlunun iyileşmesi için yaptığı dualar kabul oldu.",
    list: 'B1',
    answer: 'dua',
    quest: 'prayer',
  ),
  Words(
    front: "The weather forecast is a prediction of future weather conditions.",
    back: "Hava tahmini, gelecekteki hava durumu tahminidir.",
    list: 'B1',
    answer: 'tahmin',
    quest: 'prediction',
  ),
  Words(
    front:
        "Are you prepared for your presentation tomorrow? - Yes, I'm all set.",
    back: "Yarınki sunumunuz için hazır mısınız? - Evet, her şey tamam.",
    list: 'B1',
    answer: 'hazır',
    quest: 'prepared',
  ),
  Words(
    front:
        "He gave a very interesting presentation about the history of cinema.",
    back: "Sinema tarihi hakkında çok ilgi çekici bir sunum yaptı.",
    list: 'B1',
    answer: 'sunum',
    quest: 'presentation',
  ),
  Words(
    front: "Please press the button to start the machine.",
    back: "Makineyi çalıştırmak için lütfen düğmeye basın.",
    list: 'B1',
    answer: 'basmak',
    quest: 'press',
  ),
  Words(
    front: "I feel under a lot of pressure at work.",
    back: "İş yerinde çok fazla baskı altında hissediyorum.",
    list: 'B1',
    answer: 'baskı',
    quest: 'pressure',
  ),
  Words(
    front: "Don't worry, I was just pretending to be angry.",
    back: "Merak etme, sadece sinirliymiş gibi yapıyordum.",
    list: 'B1',
    answer: 'yapar gibi görünmek',
    quest: 'pretend',
  ),
  Words(
    front: "We discussed the previous lesson in class today.",
    back: "Bugün derste önceki dersi tartıştık.",
    list: 'B1',
    answer: 'önceki',
    quest: 'previous',
  ),
  Words(
    front: "I had not seen him previously, so I didn't recognize him.",
    back: "Onu daha önce görmemiştim, bu yüzden onu tanımadım.",
    list: 'B1',
    answer: 'önceden',
    quest: 'previously',
  ),
  Words(
    front: "The priest gave a sermon about the importance of faith.",
    back: "Papaz, inancın önemi hakkında bir vaaz verdi.",
    list: 'B1',
    answer: 'papaz',
    quest: 'priest',
  ),
  Words(
    front: "Primary education is the first stage of compulsory education.",
    back: "İlköğretim, zorunlu eğitimin ilk aşamasıdır.",
    list: 'B1',
    answer: 'birincil',
    quest: 'Primary',
  ),
  Words(
    front:
        "Cinderella is a fairy tale about a prince who falls in love with a beautiful girl.",
    back:
        "Külkedisi, yakışıklı bir kıza aşık olan bir prens hakkındaki bir peri masalıdır.",
    list: 'B1',
    answer: 'prens',
    quest: 'prince',
  ),
  Words(
    front: "The princess lived in a grand castle.",
    back: "Prenses görkemli bir şatoda yaşıyordu.",
    list: 'B1',
    answer: 'prenses',
    quest: 'princess',
  ),
  Words(
    front: "This company specializes in high-quality printing.",
    back: "Bu şirket yüksek kaliteli baskı konusunda uzmanlaşmıştır.",
    list: 'B1',
    answer: 'baskı',
    quest: 'printing',
  ),
  Words(
    front: "The prisoners were released after serving their sentences.",
    back: "Tutuklular cezalarını çektikten sonra serbest bırakıldı.",
    list: 'B1',
    answer: 'tutuklu',
    quest: 'prisoner',
  ),
  Words(
    front: "This is a private conversation, please don't listen in.",
    back: "Bu özel bir konuşma, lütfen dinlemeyin.",
    list: 'B1',
    answer: 'özel',
    quest: 'private',
  ),
  Words(
    front: "He is a famous film producer.",
    back: "Ünlü bir film yapımcısıdır.",
    list: 'B1',
    answer: 'üretici',
    quest: 'producer',
  ),
  Words(
    front: "The factory increased its production of cars this year.",
    back: "Fabrika bu yıl otomobil üretimini artırdı.",
    list: 'B1',
    answer: 'üretim',
    quest: 'production',
  ),
  Words(
    front: "What is your profession? - I am a doctor.",
    back: "Mesleğiniz nedir? - Doktorum.",
    list: 'B1',
    answer: 'meslek',
    quest: 'profession',
  ),
  Words(
    front: "The company made a large profit last year.",
    back: "Şirket geçen yıl büyük bir kar elde etti.",
    list: 'B1',
    answer: 'kar, fayda',
    quest: 'profit',
  ),
  Words(
    front: "This toothpaste is promoted for its whitening properties.",
    back: "Bu diş macunu beyazlatma özellikleriyle tanıtılmaktadır.",
    list: 'B1',
    answer: 'desteklemek',
    quest: 'promote',
  ),
  Words(
    front: "Please dress properly for the interview.",
    back: "Lütfen mülakat için uygun şekilde giyin.",
    list: 'B1',
    answer: 'uygun',
    quest: 'proper',
  ),
  Words(
    front: "He behaved properly even though he was angry.",
    back: "Sinirli olmasına rağmen düzgün davrandı.",
    list: 'B1',
    answer: 'uygun bir şekilde',
    quest: 'properly',
  ),
  Words(
    front:
        "Do you own this property? - Yes, it's been in my family for generations.",
    back: "Bu mülke siz mi sahipsiniz? - Evet, nesillerdir ailemde.",
    list: 'B1',
    answer: 'mülkiyet',
    quest: 'property',
  ),
  Words(
    front: "People were protesting against the new law.",
    back: "İnsanlar yeni yasaya karşı protesto ediyorlardı.",
    list: 'B1',
    answer: 'karşı çıkmak',
    quest: 'protest',
  ),
  Words(
    front: "She is very proud of her children's achievements.",
    back: "Çocuklarının başarılarıyla gurur duyuyor.",
    list: 'B1',
    answer: 'gurulu',
    quest: 'proud',
  ),
  Words(
    front:
        "Can you prove that you were not there? - Yes, I have alibi witnesses.",
    back: "Orada olmadığınızı kanıtlayabilir misiniz? - Evet, tanıklarım var.",
    list: 'B1',
    answer: 'kanıtlamak',
    quest: 'prove',
  ),
  Words(
    front: "Please pull the chair closer to the table.",
    back: "Lütfen sandalyeyi masaya yaklaştırın.",
    list: 'B1',
    answer: 'çekmek',
    quest: 'pull',
  ),
  Words(
    front: "The criminal was punished for his crimes.",
    back: "Suçlu, suçları nedeniyle cezaya çarptırıldı.",
    list: 'B1',
    answer: 'cezaya çarptırmak',
    quest: 'punish',
  ),
  Words(
    front: "He received a severe punishment for his actions.",
    back: "Yaptıkları nedeniyle ağır bir ceza aldı.",
    list: 'B1',
    answer: 'ceza',
    quest: 'punishment',
  ),
  Words(
    front: "Don't push me! - I'm not pushing you.",
    back: "İtme beni! - Seni itmiyorum.",
    list: 'B1',
    answer: 'itmek',
    quest: 'push',
  ),
  Words(
    front:
        "What are the qualifications for this job? - You need a university degree and at least two years of experience.",
    back:
        "Bu iş için gerekli vasıflar nelerdir? - Üniversite diplomasına ve en az iki yıllık tecrübeye ihtiyacınız var.",
    list: 'B1',
    answer: 'vasıf',
    quest: 'qualification',
  ),
  Words(
    front: "He is a qualified teacher with many years of experience.",
    back: "Uzun yıllara dayanan deneyime sahip nitelikli bir öğretmendir.",
    list: 'B1',
    answer: 'nitelikli',
    quest: 'qualified',
  ),
  Words(
    front:
        "You need to qualify for the competition before you can participate.",
    back:
        "Yarışmaya katılmadan önce turnuvaya katılmaya hak kazanmanız gerekir.",
    list: 'B1',
    answer: 'nitelendirmek',
    quest: 'qualify',
  ),
  Words(
    front: "There is a long queue at the supermarket.",
    back: "Süpermarkette uzun bir kuyruk var.",
    list: 'B1',
    answer: 'kuyruk',
    quest: 'queue',
  ),
  Words(
    front: "He decided to quit his job and travel around the world.",
    back: "İşini bırakıp dünyayı gezmeye karar verdi.",
    list: 'B1',
    answer: 'bırakmak',
    quest: 'quit',
  ),
  Words(
    front: "Can you give me a quotation for repairing my car? - Sure.",
    back: "Arabamı tamir etmenin bir teklifini alabilir miyim? - Elbette.",
    list: 'B1',
    answer: 'alıntı',
    quest: 'quotation',
  ),
  Words(
    front: "He quoted a famous philosopher in his speech.",
    back: "Konuşmasında ünlü bir filozofu alıntı yaptı.",
    list: 'B1',
    answer: 'alıntı yapmak',
    quest: 'quote',
  ),
  Words(
    front: "Formula 1 is a popular auto racing competition.",
    back: "Formula 1, popüler bir motor yarışmasıdır.",
    list: 'B1',
    answer: 'yarışma',
    quest: 'racing',
  ),
  Words(
    front: "This product comes in a wide range of colors.",
    back: "Bu ürün geniş bir renk yelpazesine sahiptir.",
    list: 'B1',
    answer: 'silsile',
    quest: 'range',
  ),
  Words(
    front: "Pandas are rare animals that are found only in China.",
    back: "Pandalar, yalnızca Çin'de bulunan nadir hayvanlardır.",
    list: 'B1',
    answer: 'nadir',
    quest: 'rare',
  ),
  Words(
    front: "I rarely go to the cinema these days.",
    back: "Bu günlerde nadiren sinemaya gidiyorum.",
    list: 'B1',
    answer: 'nadiren',
    quest: 'rarely',
  ),
  Words(
    front:
        "What was his reaction when you told him the news? - He was very surprised.",
    back: "Haberi ona söylediğinde tepkisi ne oldu? - Çok şaşırdı.",
    list: 'B1',
    answer: 'reaksiyon',
    quest: 'reaction',
  ),
  Words(
    front: "Facing reality can be difficult sometimes.",
    back: "Gerçeklikle yüzleşmek bazen zor olabilir.",
    list: 'B1',
    answer: 'gerçeklik',
    quest: 'reality',
  ),
  Words(
    front: "Please keep the receipt for your purchase.",
    back: "Lütfen satın alma işleminizin makbuzunu saklayın.",
    list: 'B1',
    answer: 'makbuz',
    quest: 'receipt',
  ),
  Words(
    front: "I can give you a recommendation for a good restaurant.",
    back: "Size iyi bir restoran için tavsiyede bulunabilirim.",
    list: 'B1',
    answer: 'tavsiye',
    quest: 'recommendation',
  ),
  Words(
    front: "Can you provide me with some references? - Yes, of course.",
    back: "Bana bazı referanslar verebilir misiniz? - Evet tabii ki.",
    list: 'B1',
    answer: 'referans',
    quest: 'reference',
  ),
  Words(
    front: "The lake reflects the beauty of the surrounding mountains.",
    back: "Göl, çevredeki dağların güzelliğini yansıtır.",
    list: 'B1',
    answer: 'yansıtmak',
    quest: 'reflect',
  ),
  Words(
      front: "I regularly go for a walk in the park.",
      back: "Bu, düzenli olarak olan bir şeyin örneğidir.",
      list: 'B1',
      answer: 'düzenli olarak',
      quest: 'regularly'),
  Words(
      front: "We politely rejected their offer.",
      back: "Tekliflerini nazikçe reddettik.",
      list: 'B1',
      answer: 'reddetmek',
      quest: 'reject'),
  Words(
      front: "The story relates to a young boy's adventures.",
      back: "Hikaye, genç bir çocuğun maceralarıyla ilgilidir.",
      list: 'B1',
      answer: 'nakletmek',
      quest: 'relate'),
  Words(
      front: "These two events are closely related.",
      back: "Bu iki olay yakından ilişkilidir.",
      list: 'B1',
      answer: 'ilişkili',
      quest: 'related'),
  Words(
      front: "What is your relationship with your neighbor?",
      back: "Komşunuzla ilişkiniz nedir?",
      list: 'B1',
      answer: 'ilişki,bağlantı',
      quest: 'relation'),
  Words(
      front: "She is a close relative of mine.",
      back: "O benim yakın bir akrabam.",
      list: 'B1',
      answer: 'akraba',
      quest: 'relative'),
  Words(
      front: "After a long day, I felt relaxed.",
      back: "Uzun bir günün ardından rahatlamış hissettim.",
      list: 'B1',
      answer: 'rahatlamış',
      quest: 'relaxed'),
  Words(
      front: "Listening to music is a relaxing activity for me.",
      back: "Müzik dinlemek benim için rahatlatıcı bir aktivitedir.",
      list: 'B1',
      answer: 'rahatlatıcı',
      quest: 'relaxing'),
  Words(
      front: "The new movie will be released next month.",
      back: "Yeni film gelecek ay piyasaya sürülecek.",
      list: 'B1',
      answer: 'piyasaya sürmek',
      quest: 'release'),
  Words(
      front: "He is a reliable friend who I can always count on.",
      back: "Her zaman güvenebileceğim güvenilir bir arkadaştır.",
      list: 'B1',
      answer: 'güvenilir',
      quest: 'reliable'),
  Words(
      front: "Many people find comfort in their religion.",
      back: "Pek çok insan dinlerinde rahatlık bulur.",
      list: 'B1',
      answer: 'din',
      quest: 'religion'),
  Words(
      front: "They follow a religious holiday tradition.",
      back: "Dini bir bayram geleneğini takip ediyorlar.",
      list: 'B1',
      answer: 'dinsel',
      quest: 'religious'),
  Words(
      front: "Some leftovers remained in the fridge.",
      back: "Buzdolabında bazı artan yemekler kaldı.",
      list: 'B1',
      answer: 'geriye kalmak',
      quest: 'remain'),
  Words(
      front: "I need to remind you about the meeting tomorrow.",
      back: "Yarınki toplantıyı size hatırlatmam gerekiyor.",
      list: 'B1',
      answer: 'hatırlatmak',
      quest: 'remind'),
  Words(
      front: "We live in a remote village with limited internet access.",
      back: "İnternet erişimi sınırlı olan uzak bir köyde yaşıyoruz.",
      list: 'B1',
      answer: 'uzak',
      quest: 'remote'),
  Words(
      front: "We can rent a car for our trip.",
      back: "Gezimiz için araba kiralayabiliriz.",
      list: 'B1',
      answer: 'kiralamak',
      quest: 'rent'),
  Words(
      front: "I need to take my laptop in for repair.",
      back: "Laptopumu tamir için götürmem gerekiyor.",
      list: 'B1',
      answer: 'onarmak',
      quest: 'repair'),
  Words(
      front: "Please repeat your question.",
      back: "Lütfen sorunuzu tekrarlayın.",
      list: 'B1',
      answer: 'tekrarlamak',
      quest: 'repeat'),
  Words(
      front: "The teacher gave us a lot of repeated homework.",
      back: "Öğretmen bize çok fazla tekrar eden ödev verdi.",
      list: 'B1',
      answer: 'yinelenen',
      quest: 'repeated'),
  Words(
      front: "The flag represents the country.",
      back: "Bayrak, ülkeyi temsil eder.",
      list: 'B1',
      answer: 'temsil etmek',
      quest: 'represent'),
  Words(
      front: "May I request a glass of water?",
      back: "Bir bardak su rica edebilir miyim?",
      list: 'B1',
      answer: 'rica etmek',
      quest: 'request'),
  Words(
      front: "This course requires a lot of hard work.",
      back: "Bu kurs çok fazla çalışma gerektirir.",
      list: 'B1',
      answer: 'gerekmek',
      quest: 'require'),
  Words(
      front: "Do you have a reservation at this restaurant?",
      back: "Bu restoranda rezervasyonunuz var mı?",
      list: 'B1',
      answer: 'rezervasyon',
      quest: 'reservation'),
  Words(
      front: "The internet is a valuable resource for information.",
      back: "İnternet, bilgi için değerli bir kaynaktır.",
      list: 'B1',
      answer: 'kaynak',
      quest: 'resource'),
  Words(
      front: "It's important to show respect to your elders.",
      back: "Yaşlılara saygı göstermek önemlidir.",
      list: 'B1',
      answer: 'saygı göstermek',
      quest: 'respect'),
  Words(
      front: "Taking responsibility for your actions is important.",
      back: "Eylemlerinizin sorumluluğunu üstlenmek önemlidir.",
      list: 'B1',
      answer: 'sorumluluk',
      quest: 'responsibility'),
  Words(
      front: "He is a responsible person who always keeps his promises.",
      back: "Sözlerini her zaman tutan sorumlu bir insan.",
      list: 'B1',
      answer: 'sorumlu',
      quest: 'responsible'),
  Words(
      front: "What is the result of the experiment?",
      back: "Denemenin sonucu nedir?",
      list: 'B1',
      answer: 'sonuç',
      quest: 'result'),
  Words(
      front: "He is planning to retire next year.",
      back: "Gelecek sene emekli olmayı planlıyor.",
      list: 'B1',
      answer: 'emekli olmak',
      quest: 'retire'),
  Words(
      front: "She is a retired teacher.",
      back: "O emekli bir öğretmen.",
      list: 'B1',
      answer: 'emekli',
      quest: 'retired'),
  Words(
      front: "I need to revise my essay before submitting it.",
      back: "Denememi göndermeden önce gözden geçirmem gerekiyor.",
      list: 'B1',
      answer: 'gözden geçirerek düzeltmek',
      quest: 'revise'),
  Words(
      front: "The sun rises at seven in the morning.",
      back: "Güneş sabah yedide doğuyor.",
      list: 'B1',
      answer: 'doğmak',
      quest: 'rise'),
  Words(
      front: "The ball rolled down the hill.",
      back: "Top tepe aşağı yuvarlandı.",
      list: 'B1',
      answer: 'yuvarlanmak',
      quest: 'roll'),
  Words(
      front: "I need a rope to tie the boxes together.",
      back: "Kutuları birbirine bağlamak için bir ip gerekir.",
      list: 'B1',
      answer: 'halat',
      quest: 'rope'),
  Words(
      front: "The sea can be very rough during a storm.",
      back: "Deniz, fırtına sırasında çok kaba olabilir.",
      list: 'B1',
      answer: 'kaba',
      quest: 'rough'),
  Words(
      front: "Please stand in a single row.",
      back: "Lütfen tek sıra halinde bekleyin.",
      list: 'B1',
      answer: 'sıra',
      quest: 'row'), // Note: 'row1' is not a common word. Used 'row' instead.
  Words(
      front: "The royal family lives in a palace.",
      back: "Kraliyet ailesi bir sarayda yaşar.",
      list: 'B1',
      answer: 'asil',
      quest: 'royal'),
  Words(
      front: "It's important to follow the rules of the game.",
      back: " Oyunun kurallarına uymak önemlidir.",
      list: 'B1',
      answer: 'kural',
      quest: 'rule'),
  Words(
      front: "We need to prioritize safety when working with electricity.",
      back: "Elektrikle çalışırken güvenliği öncelememiz gerekiyor.",
      list: 'B1',
      answer: 'güven',
      quest: 'safety'),
  Words(
      front: "The captain decided to sail away at dawn.",
      back: "Kaptan şafak vakti denize açılmaya karar verdi.",
      list: 'B1',
      answer: 'denize açılmak',
      quest: 'sail'),
  Words(
      front: "He is a skilled sailor who has traveled the world.",
      back: "Dünyayı gezmiş deneyimli bir denizcidir.",
      list: 'B1',
      answer: 'denizci',
      quest: 'sailor'),
  Words(
      front: "Can I see a sample of the fabric?",
      back: "Kumaşın bir örneğini görebilir miyim?",
      list: 'B1',
      answer: 'örnek',
      quest: 'sample'),
  Words(
      front: "I shook the sand out of my towel.",
      back: "Havlumdaki kumu silkeledim.",
      list: 'B1',
      answer: 'kum',
      quest: 'sand'),
  Words(
      front: "Please scan your boarding pass at the gate.",
      back: "Lütfen boarding passınızı kapıdaki tarayıcıdan geçirin.",
      list: 'B1',
      answer: 'taramak',
      quest: 'scan'),
  Words(
      front: "This is a scientific breakthrough.",
      back: "Bu, bilimsel bir atılım.",
      list: 'B1',
      answer: 'bilimsel',
      quest: 'scientific'),
  Words(
      front: "The movie is based on a script written by a famous author.",
      back: "Film, ünlü bir yazarın yazdığı bir senaryoya dayanıyor.",
      list: 'B1',
      answer: 'senaryo',
      quest: 'script'),
  Words(
      front: "The museum has a collection of ancient sculptures.",
      back: "Müzede antik heykeller koleksiyonu var.",
      list: 'B1',
      answer: 'heykel',
      quest: 'sculpture'),
  Words(
      front:
          "A secondary source is information that is based on primary sources.",
      back: "İkincil kaynak, birincil kaynaklara dayanan bilgidir.",
      list: 'B1',
      answer: 'ikincil',
      quest: 'secondary'),
  Words(
      front: "The company takes security very seriously.",
      back: "Şirket, güvenliği ciddiye alır.",
      list: 'B1',
      answer: 'güvenlik',
      quest: 'security'),
  Words(
      front: "We need to plant the seeds in the spring.",
      back: "Tohumları baharda ekmemiz gerekiyor.",
      list: 'B1',
      answer: 'tohum',
      quest: 'seed'),
  Words(
      front: "It's sensible to wear a hat on a sunny day.",
      back: "Güneşli bir günde şapka takmak mantıklıdır.",
      list: 'B1',
      answer: 'mantıklı',
      quest: 'sensible'),
  Words(
      front: "We need to separate the red balls from the blue ones.",
      back: "Kırmızı topları mavi olanlardan ayırmamız gerekiyor.",
      list: 'B1',
      answer: 'ayırmak',
      quest: 'separate'),
  Words(
      front: "Are you seriously considering quitting your job?",
      back: "İşinden ayrılmayı cidden düşünüyor musun?",
      list: 'B1',
      answer: 'ciddi',
      quest: 'seriously'),
  Words(
      front: "In the past, wealthy families had servants.",
      back: "Geçmişte zengin ailelerin hizmetçileri vardı.",
      list: 'B1',
      answer: 'hizmetçi',
      quest: 'servant'),
  Words(
      front: "Please set the table for dinner.",
      back: "Lütfen akşam yemeği için masayı kurun.",
      list: 'B1',
      answer: 'kurmak',
      quest: 'set'),
  Words(
      front: "The story is set in a small village in Scotland.",
      back: "Hikaye, İskoçya'da küçük bir köyde geçiyor.",
      list: 'B1',
      answer: '-geçmek',
      quest: 'set in'),
  Words(
      front: "The table started to shake during the earthquake.",
      back: "Deprem sırasında masa sallanmaya başladı.",
      list: 'B1',
      answer: 'sallanmak',
      quest: 'shake'),
  Words(
      front: "Would you like to share a pizza with me?",
      back: "Benimle pizza paylaşmak ister misin?",
      list: 'B1',
      answer: 'paylaşmak',
      quest: 'share'),
  Words(
      front: "Be careful! That knife is very sharp.",
      back: "Dikkatli ol! O bıçak çok sivri.",
      list: 'B1',
      answer: 'sivri',
      quest: 'sharp'),
  Words(
      front: "Put the books back on the shelf.",
      back: "Kitapları rafa geri koy.",
      list: 'B1',
      answer: 'raf',
      quest: 'shelf'),
  Words(
      front: "The hermit crab lives in a shell.",
      back: "Yengeç, bir kabuk içinde yaşar.",
      list: 'B1',
      answer: 'kabuk',
      quest: 'shell'),
  Words(
      front: "I'm working the night shift this week.",
      back: "Bu hafta gece vardiyasında çalışıyorum.",
      list: 'B1',
      answer: 'değiştirmek, vardiya',
      quest: 'shift'),
  Words(
      front: "The moon shines because its surface reflects light from the sun.",
      back: "Ay, yüzeyi güneşten gelen ışığı yansıttığı için parlar.",
      list: 'B1',
      answer: 'parlamak',
      quest: 'shine'),
  Words(
      front: "I love your shiny new car!",
      back: "Parlak yeni arabanı çok sevdim!",
      list: 'B1',
      answer: 'parlak',
      quest: 'shiny'),
  Words(
      front: "They are going to shoot a movie in this location.",
      back: "Bu mekanda film çekecekler.",
      list: 'B1',
      answer: 'film çekmek',
      quest: 'shoot'),
  Words(
      front:
          "He seems a bit shy. Don't worry, he'll warm up to you eventually.",
      back: "Biraz utangaç görünüyor. Endişelenme, sonunda sana alışacak.",
      list: 'B1',
      answer: 'korkmak',
      quest: 'shy'),
  Words(
      front: "The beautiful sight of the mountains took my breath away.",
      back: "Dağların güzel görüntüsü nefesimi kesmişti.",
      list: 'B1',
      answer: 'görünüş',
      quest: 'sight'),
  Words(
      front: "The police use radio signals to communicate with each other.",
      back:
          "Polis birbirleriyle iletişim kurmak için telsiz sinyalleri kullanır.",
      list: 'B1',
      answer: 'sinyal',
      quest: 'signal'),
  Words(
      front: "The library is a quiet place where you can study in silence.",
      back: "Kütüphane, sessizce çalışabileceğiniz sessiz bir yerdir.",
      list: 'B1',
      answer: 'sessizlik',
      quest: 'silence'),
  Words(
      front: "Don't worry, that was a silly mistake. It can happen to anyone.",
      back:
          "Endişelenme, aptalca bir hataだった (dattâ) [darımaşita]. Herkesin başına gelebilir.",
      list: 'B1',
      answer: 'saçma sapan',
      quest: 'silly'),
  Words(
      front:
          "People tell me I look like Kate, but the only similarity is our hair color!",
      back:
          "İnsanlar bana Kate'e benzediğimi söylüyor ama tek benzerliğimiz saç rengimiz!",
      list: 'B1',
      answer: 'benzerlik',
      quest: 'similarity'),
  Words(
      front:
          "They are dressed similarly, so it's difficult to tell them apart.",
      back: "Benzer şekilde giyinmişler, bu yüzden onları ayırt etmek zor.",
      list: 'B1',
      answer: 'aynı şekilde',
      quest: 'similarly'),
  Words(
      front: "Simply put, water is essential for life.",
      back: "Basitçe söylemek gerekirse, su yaşam için gereklidir.",
      list: 'B1',
      answer: 'basitçe',
      quest: 'Simply'),
  Words(
      front: "I haven't seen him since he moved to a new city.",
      back: "Yeni bir şehire taşındığından beri onu görmedim.",
      list: 'B1',
      answer: 'ondan sonra',
      quest: 'since'),
  Words(
      front: "I washed the dishes in the sink.",
      back: "Bulaşıkları lavaboda yıkadım.",
      list: 'B1',
      answer: 'lavabo',
      quest: 'sink'),
  Words(
      front: "Can you slice the bread for me?",
      back: "Ekmeği benim için dilimleyebilir misin?",
      list: 'B1',
      answer: 'dilimlemek',
      quest: 'slice'),
  Words(
      front: "I feel slightly better today than yesterday.",
      back: "Bugün dün olduğundan biraz daha iyi hissediyorum.",
      list: 'B1',
      answer: 'belli belirsiz',
      quest: 'slightly'),
  Words(
      front: "Drive slowly, there are children playing in the street.",
      back: "Yavaş sür, sokakta oynayan çocuklar var.",
      list: 'B1',
      answer: 'yavaş',
      quest: 'slow'),
  Words(
      front: "He is a very smart student who always gets good grades.",
      back: "Her zaman iyi notlar alan çok zeki bir öğrencidir.",
      list: 'B1',
      answer:
          'sızlamak, akıllı', // 'sızlamak' means 'to ache' and is not related to 'smart'. Used 'zeki' for 'smart'.
      quest: 'smart'),
  Words(
      front: "I need to iron my shirt to make it smooth.",
      back: "Gömleğimi düzeltmek için ütülemem gerekiyor.",
      list: 'B1',
      answer: 'düzlemek',
      quest: 'smooth'),
  Words(
      front: "This software is very user-friendly.",
      back: "Bu yazılım çok kullanıcı dostudur.",
      list: 'B1',
      answer: 'yazılım',
      quest: 'software'),
  Words(
      front: "The plants need nutrients from the soil to grow.",
      back:
          "Bitkilerin büyümesi için topraktan alınan besinlere ihtiyacı vardır.",
      list: 'B1',
      answer: 'toprak',
      quest: 'soil'),
  Words(
      front: "The bridge is made of solid steel.",
      back: "Köprü sağlam çelikten yapılmıştır.",
      list: 'B1',
      answer: 'sağlam',
      quest: 'solid'),
  Words(
      front: "Can you sort these papers by color?",
      back: "Bu kağıtları renklerine göre sıralayabilir misin?",
      list: 'B1',
      answer: 'sıralamak',
      quest: 'sort'),
  Words(
      front: "We are going on a vacation to a southern island.",
      back: "Güneydeki bir adaya tatile gidiyoruz.",
      list: 'B1',
      answer: 'güneyli',
      quest: 'southern'),
  Words(
      front:
          "The instructions don't specifically mention what to do in this situation.",
      back:
          "Talimatlar, bu durumda ne yapılması gerektiğinden özellikle bahsetmiyor.",
      list: 'B1',
      answer: 'özellikle',
      quest: 'specifically'),
  Words(
      front: "We need to cut down on our spending this month.",
      back: "Bu ay harcamalarımızı kısmamız gerekiyor.",
      list: 'B1',
      answer: 'harcama',
      quest: 'spending'),
  Words(
      front: "Do you like spicy food?",
      back: "Acılı yemek sever misin?",
      list: 'B1',
      answer: 'baharatlı',
      quest: 'spicy'),
  Words(
      front: "He has a strong spirit and never gives up.",
      back: "Güçlü bir ruhu var ve asla vazgeçmez.",
      list: 'B1',
      answer: 'ruh',
      quest: 'spirit'),
  Words(
      front: "English is a widely spoken language.",
      back: "İngilizce, çok konuşulan bir dildir.",
      list: 'B1',
      answer: 'konuşma',
      quest: 'spoken'),
  Words(
      front: "There is a small spot of paint on your jacket.",
      back: "Ceketinde küçük bir boya lekesi var.",
      list: 'B1',
      answer: 'leke',
      quest: 'spot'),
  Words(
      front: "The news spread quickly throughout the town.",
      back: "Haber kasaba boyunca hızla yayıldı.",
      list: 'B1',
      answer: 'yaymak',
      quest: 'spread'),
  Words(
      front: "Spring is a beautiful time of year when flowers bloom.",
      back: "İlkbahar, çiçeklerin açtığı yılın güzel bir zamanıdır.",
      list: 'B1',
      answer: 'ilkbahar',
      quest: 'Spring'),
  Words(
      front: "The football match will be held at a large stadium.",
      back: "Futbol maçı büyük bir stadyumda yapılacak.",
      list: 'B1',
      answer: 'stadyum',
      quest: 'stadium'),
  Words(
      front: "The company has a large staff of qualified employees.",
      back: "Şirketin kalifiye çalışanlardan oluşan geniş bir personeli var.",
      list: 'B1',
      answer: 'personel',
      quest: 'staff'),
  Words(
      front: "The report states that the economy is improving.",
      back: "Raporda ekonomi düzeldiğinin ifade ediliyor.",
      list: 'B1',
      answer: 'ifade etmek',
      quest: 'state'),
  Words(
      front: "This statistic shows that the number of students is increasing.",
      back: "Bu istatistik, öğrenci sayısının arttığını gösteriyor.",
      list: 'B1',
      answer: 'istatistik',
      quest: 'statistic'),
  Words(
      front: "The city is famous for its beautiful statues.",
      back: "Şehir, güzel heykelleriyle ünlüdür.",
      list: 'B1',
      answer: 'heykel',
      quest: 'statue'),
  Words(
      front: "Can you stick the poster on the wall?",
      back: "Posterı duvara yapıştırabilir misin?",
      list: 'B1',
      answer: 'saplamak',
      quest: 'stick'),
  Words(
      front: "The lake was still and calm.",
      back: "Göl durgun ve sakindi.",
      list: 'B1',
      answer: 'durgun',
      quest: 'still'),
  Words(
      front: "We need to store the boxes in the garage.",
      back: "Kutuları garaja depolamak gerekiyor.",
      list: 'B1',
      answer: 'depolamak',
      quest: 'store'),
  Words(
      front: "He smiled at the stranger in a friendly way.",
      back: "Yabancıya dostça gülümsedi.",
      list: 'B1',
      answer: 'yabancı',
      quest: 'stranger'),
  Words(
      front: "He overcame the challenge with his strength and determination.",
      back: "Gücü ve kararlılığıyla zorluğun üstesinden geldi.",
      list: 'B1',
      answer: 'güç',
      quest: 'strength'),
  Words(
      front: "I strongly believe that everyone deserves a chance.",
      back: "Herkesin bir şansı hak ettiğine kesin olarak inanıyorum.",
      list: 'B1',
      answer: 'fazlasıyla',
      quest: 'strongly'),
  Words(
      front: "The artist rented a studio to work on their paintings.",
      back: "Sanatçı, resimlerini yapmak için bir stüdyo kiraladı.",
      list: 'B1',
      answer: 'stüdyo',
      quest: 'studio'),
  Words(
      front:
          "Don't stuff your backpack too full, or it will be difficult to carry.",
      back: "Sırt çantasını fazla doldurma, yoksa taşıması zor olur.",
      list: 'B1',
      answer: 'tıkınmak',
      quest: 'stuff'),
  Words(
      front: "Water is a vital substance for all living things.",
      back: "Su, tüm canlılar için hayati bir cisimdir.",
      list: 'B1',
      answer: 'cisim',
      quest: 'substance'),
  Words(
      front: "The mission was successfully completed.",
      back: "Görev başarıyla tamamlandı.",
      list: 'B1',
      answer: 'başarılı biçimde',
      quest: 'successfully'),
  Words(
      front: "There was a sudden downpour of rain, so we ran for cover.",
      back: "Ani bir sağanak yağmur yağdı, bu yüzden korunmak için koştuk.",
      list: 'B1',
      answer: 'ani',
      quest: 'sudden'),
  Words(
      front: "Many people are suffering from the effects of the war.",
      back: "Birçok insan savaşın etkilerinden acı çekiyor.",
      list: 'B1',
      answer: 'acı çekmek',
      quest: 'suffer'),
  Words(
      front: "This style of clothing doesn't really suit you.",
      back: "Bu giyim tarzı sana pek uymuyor.",
      list: 'B1',
      answer: 'uygun olmak',
      quest: 'suit'),
  Words(
      front: "What is the most suitable time for the meeting?",
      back: "Toplantı için en uygun zaman nedir?",
      list: 'B1',
      answer: 'uygun',
      quest: 'suitable'),
  Words(
      front: "Can you summarize the main points of the article?",
      back: "Yazının ana noktalarını özetleyebilir misin?",
      list: 'B1',
      answer: 'özetlemek',
      quest: 'summarize'),
  Words(
      front:
          "Here is a summary of the book for those who don't have time to read it.",
      back: "Bu, kitabı okumaya vakti olmayanlar için bir özettir.",
      list: 'B1',
      answer: 'özet',
      quest: 'summary'),
  Words(
      front:
          "The company is struggling to supply enough products to meet demand.",
      back:
          "Şirket, talebi karşılamak için yeterli ürünü tedarik etmekte zorlanıyor.",
      list: 'B1',
      answer: 'tedarik etmek',
      quest: 'supply'),
  Words(
      front: "He is a strong supporter of environmental protection.",
      back: "Doğa koruma alanında güçlü bir destekçidir.",
      list: 'B1',
      answer: 'destekçi',
      quest: 'supporter'),
  Words(
      front: "Surely you can help me with this problem.",
      back: "Elbette bu problemde bana yardım edebilirsin.",
      list: 'B1',
      answer: 'elbette',
      quest: 'Surely'),
  Words(
      front: "The surface of the lake was calm and reflective.",
      back: "Gölün yüzeyi sakin ve durgundu.",
      list: 'B1',
      answer: 'yüzey',
      quest: 'surface'),
  Words(
      front:
          "Many wild animals are struggling to survive in their natural habitat.",
      back:
          "Birçok vahşi hayvan, doğal ortamlarında hayatta kalmakta zorlanıyor.",
      list: 'B1',
      answer: 'uzun yaşamak',
      quest: 'survive'),
  Words(
      front: "Do you know how to swim? It's an important life skill.",
      back: "Yüzmeyi biliyor musun? Bu önemli bir yaşam becerisidir.",
      list: 'B1',
      answer: 'yüzmek',
      quest: 'swim'),
  Words(
      front: "Can you switch on the light, please? It's getting dark.",
      back: "Lütfen ışığı açabilir misin? Hava kararıyor.",
      list: 'B1',
      answer: 'değiştirmek',
      quest: 'switch'),
  Words(
      front: "A fever is a common symptom of the flu.",
      back: "Ateş, gripin yaygın bir belirtisidir.",
      list: 'B1',
      answer: 'belirti',
      quest: 'symptom'),
  Words(
      front: "The cat wagged its tail happily as I entered the room.",
      back: "Odaya girerken kedi kuyruğunu mutlu bir şekilde salladı.",
      list: 'B1',
      answer: 'kuyruk',
      quest: 'tail'),
  Words(
      front: "She has a natural talent for music.",
      back: "Müzik yeteneği var.",
      list: 'B1',
      answer: 'yetenek',
      quest: 'talent'),
  Words(
      front: "He is a talented young artist with a bright future.",
      back: "Parlak bir geleceği olan yetenekli bir genç sanatçı.",
      list: 'B1',
      answer: 'yetenekli',
      quest: 'talented'),
  Words(
      front: "Do you still have any old cassette tapes?",
      back: "Hala eski kaset bantların var mı?",
      list: 'B1',
      answer: 'kaset',
      quest: 'tape'),
  Words(
      front: "The government raised taxes to pay for public services.",
      back: "Hükümet, kamu hizmetlerini karşılamak için vergileri artırdı.",
      list: 'B1',
      answer: 'vergi',
      quest: 'tax'),
  Words(
      front: "Learning a new language requires a good technique.",
      back: "Yeni bir dil öğrenmek iyi bir teknik gerektirir.",
      list: 'B1',
      answer: 'teknik',
      quest: 'technique'),
  Words(
      front: "The economy tends to fluctuate over time.",
      back: "Ekonomi zaman içinde dalgalanma eğilimindedir.",
      list: 'B1',
      answer: 'eğilimi olmak',
      quest: 'tend'),
  Words(
      front: "We pitched a tent in the forest for our camping trip.",
      back: "Kamp gezimiz için ormana bir çadır kurduk.",
      list: 'B1',
      answer: 'çadır',
      quest: 'tent'),
  Words(
      front: "I can't believe that! That's incredible!",
      back: "İnanamıyorum! Bu inanılmaz!",
      list: 'B1',
      answer: 'şu',
      quest: 'that'),
  Words(
      front: "Theirs is the blue car parked over there.",
      back: "Onların, orada park halindeki mavi araba.",
      list: 'B1',
      answer: 'onların',
      quest: 'Theirs'),
  Words(
      front: "The story has a strong theme of friendship.",
      back: "Hikayenin güçlü bir dostluk teması var.",
      list: 'B1',
      answer: 'tema',
      quest: 'theme'),
  Words(
      front:
          "The theory of evolution is one of the most important scientific theories.",
      back: "Evrim teorisi, en önemli bilimsel teorilerden biridir.",
      list: 'B1',
      answer: 'teori',
      quest: 'theory'),
  Words(
      front: "He failed the exam, therefore he has to retake it.",
      back: "Sınavı geçti, bu nedenle tekrarlaması gerekiyor.",
      list: 'B1',
      answer: 'bu sebeple',
      quest: 'therefore'),
  Words(
      front: "This is a very interesting book. I recommend you read it.",
      back: "Bu çok ilginç bir kitap. Okumanızı tavsiye ederim.",
      list: 'B1',
      answer: 'bu',
      quest: 'This'),
  Words(
      front: "I like chocolate, though I try not to eat it too often.",
      back: " çikolata sevsem de, fazla sık yememeye çalışıyorum.",
      list: 'B1',
      answer: 'gerçi',
      quest: 'though'),
  Words(
      front: "I have a sore throat. It hurts to swallow.",
      back: "Boğazım ağrıyor. Yutkunmak acıtıyor.",
      list: 'B1',
      answer: 'boğaz',
      quest: 'throat'),
  Words(
      front: "The weather was beautiful throughout our entire vacation.",
      back: "Tüm tatilimiz boyunca hava güzeldi.",
      list: 'B1',
      answer: 'boyunca',
      quest: 'throughout'),
  Words(
      front: "My jeans are a bit too tight. I need to buy a bigger size.",
      back: "Kotlarım biraz fazla dar. Daha büyük bir beden almam gerekiyor.",
      list: 'B1',
      answer: 'sıkı',
      quest: 'tight'),
  Words(
      front: "She worked till she was exhausted.",
      back: "Yorgun düşene kadar çalıştı.",
      list: 'B1',
      answer: '-e kadar',
      quest: 'till'),
  Words(
      front: "Can you please throw away this empty tin can?",
      back: "Lütfen bu boş teneke kutuyu atabilir misin?",
      list: 'B1',
      answer: 'teneke',
      quest: 'tin'),
  Words(
      front: "The baby has tiny fingers and toes.",
      back: "Bebeğin minik parmakları ve ayak parmakları var.",
      list: 'B1',
      answer: 'ufacık',
      quest: 'tiny'),
  Words(
      front: "Don't forget to leave a tip for the waiter after your meal.",
      back: "Yemekten sonra garson için bahşiş bırakmayı unutmayın.",
      list: 'B1',
      answer: 'bahşiş',
      quest: 'tip'),
  Words(
      front: "Be careful not to stub your toe on the corner of the table.",
      back: "Masaya ayağınızı takmamaya dikkat edin.",
      list: 'B1',
      answer: 'ayak parmağı',
      quest: 'toe'),
  Words(
      front: "He stuck his tongue out in a playful way.",
      back: "Şakacı bir şekilde dilini çıkardı.",
      list: 'B1',
      answer: 'dil',
      quest: 'tongue'),
  Words(
      front: "The total cost of the items came to \$50.",
      back: "Ürünlerin toplam maliyeti 50 dolar tuttu.",
      list: 'B1',
      answer: 'toplam',
      quest: 'total'),
  Words(
      front: "I am totally exhausted after that long hike.",
      back: "O uzun yürüyüşten sonra tamamen bitkinim.",
      list: 'B1',
      answer: 'tamamen',
      quest: 'totally'),
  Words(
      front: "Please don't touch the wet paint.",
      back: "Lütfen ıslak boyaya dokunmayın.",
      list: 'B1',
      answer: 'dokunmak',
      quest: 'touch'),
  Words(
      front: "Would you like to join us on a walking tour of the city?",
      back: "Şehre yürüyerek bir tura katılmak ister misin?",
      list: 'B1',
      answer: 'gezi',
      quest: 'tour'),
  Words(
      front: "International trade is an important part of the global economy.",
      back: "Uluslararası ticaret, küresel ekonominin önemli bir parçasıdır.",
      list: 'B1',
      answer: 'ticaret',
      quest: 'trade'),
  Words(
      front: "Can you translate this sentence into English for me?",
      back: "Bu cümleyi benim için İngilizceye çevirebilir misin?",
      list: 'B1',
      answer: 'çevirmek',
      quest: 'translate'),
  Words(
      front: "Here is a translation of the poem into Spanish.",
      back: "İşte şiirin İspanyolca çevirisi.",
      list: 'B1',
      answer: 'çeviri',
      quest: 'translation'),
  Words(
      front: "How much does it cost to transport this box across the country?",
      back: "Bu kutuyu ülke çapında taşımanın maliyeti ne kadar?",
      list: 'B1',
      answer: 'taşımak',
      quest: 'transport'),
  Words(
      front: "He treated his guests with kindness and respect.",
      back: "Misafirlerine nezaket ve saygı ile davrandı.",
      list: 'B1',
      answer: 'davranmak',
      quest: 'treat'),
  Words(
      front: "The doctor prescribed a new treatment for my allergy.",
      back: "Doktor alerjim için yeni bir tedavi önerdi.",
      list: 'B1',
      answer: 'muamele',
      quest: 'treatment'),
  Words(
      front: "The economy is showing a trend of slow but steady growth.",
      back: "Ekonomi yavaş ama istikrarlı bir büyüme eğilimi gösteriyor.",
      list: 'B1',
      answer: 'eğilim göstermek',
      quest: 'trend'),
  Words(
      front: "Don't try to trick me. I know the truth.",
      back: "Beni kandırmaya çalışma. Gerçeği biliyorum.",
      list: 'B1',
      answer: 'kandırmak',
      quest: 'trick'),
  Words(
      front: "What is the truth behind this story?",
      back: "Bu hikayenin arkasındaki gerçek nedir?",
      list: 'B1',
      answer: 'doğru',
      quest: 'truth'),
  Words(
      front: " toothpaste comes in a tube.",
      back: "Diş macunu tüp içinde gelir.",
      list: 'B1',
      answer: 'tüp',
      quest: 'tube'),
  Words(
      front: "What type of music do you like?",
      back: "Ne tür müzikten hoşlanırsın?",
      list: 'B1',
      answer: 'tür, yazmak',
      quest: 'type'),
  Words(
      front: "He typically arrives at work early in the morning.",
      back: "Tipik olarak sabahları erken işe gelir.",
      list: 'B1',
      answer: 'sıklıkla',
      quest: 'typically'),
  Words(
      front: "I need to get a new tyre for my bike. The old one is flat.",
      back:
          "Bisikletim için yeni bir tekerlek almam gerekiyor. Eski lastiği patlak.",
      list: 'B1',
      answer: 'tekerlek',
      quest: 'tyre'),
  Words(
      front: "That sweater is really ugly. I wouldn't recommend buying it.",
      back: "O kazak gerçekten çirkin. Almanı tavsiye etmem.",
      list: 'B1',
      answer: 'çirkin',
      quest: 'ugly'),
  Words(
      front: "He was unable to finish the race due to an injury.",
      back: "Yarışmayı sakatlık nedeniyle bitiremedi.",
      list: 'B1',
      answer: 'aciz',
      quest: 'unable'),
  Words(
      front: "This chair is very uncomfortable. I can't sit here for long.",
      back: "Bu sandalye çok konforsuz. Burada uzun süre oturamam.",
      list: 'B1',
      answer: 'konforsuz',
      quest: 'uncomfortable'),
  Words(
      front: "Don't forget to pack clean underwear for your trip.",
      back: "Yolculuğunuz için temiz iç çamaşırı almayı unutmayın.",
      list: 'B1',
      answer: 'iç çamaşırı',
      quest: 'underwear'),
  Words(
      front: "The unemployment rate has been rising recently.",
      back: "İşsizlik oranı son dönemde artıyor.",
      list: 'B1',
      answer: 'işsizlik',
      quest: 'unemployment'),
  Words(
      front: "It is unfair to treat people differently based on their race.",
      back: "İnsanları ırklarına göre farklı davranmak adil değildir.",
      list: 'B1',
      answer: 'adil olmayan',
      quest: 'unfair'),
  Words(
      front: "Many workers join unions to protect their rights.",
      back: "Birçok işçi, haklarını korumak için sendikalara katılır.",
      list: 'B1',
      answer: 'sendika',
      quest: 'union'),
  Words(
      front: "You won't get into the club unless you show your ID.",
      back: "Kimliğini göstermezsen kulübe giremezsin.",
      list: 'B1',
      answer: '-mezse',
      quest: 'unless'),
  Words(
      front: "Unlike me, my brother is very good at math.",
      back: "Benim aksine, kardeşim matematikte çok iyidir.",
      list: 'B1',
      answer: 'farklı',
      quest: 'Unlike'),
  Words(
      front: "It seems unlikely that they will finish the project on time.",
      back: "Projeyi zamanında bitirmeleri pek mümkün görünmüyor.",
      list: 'B1',
      answer: 'mümkün görünmeyen',
      quest: 'unlikely'),
  Words(
      front:
          "Adding sugar to your coffee is unnecessary if you already like the taste.",
      back: "Kahvenize şeker eklemek, tadını zaten beğeniyorsanız gereksizdir.",
      list: 'B1',
      answer: 'gereksiz',
      quest: 'unnecessary'),
  Words(
      front: "He received some unpleasant news about his job.",
      back: "İşiyle ilgili hoşa gitmeyen haberler aldı.",
      list: 'B1',
      answer: 'hoşa gitmeyen',
      quest: 'unpleasant'),
  Words(
      front: "Please update your phone's software to the latest version.",
      back: "Lütfen telefonunuzun yazılımını en son sürüme güncelleyin.",
      list: 'B1',
      answer: 'update',
      quest: 'update'),
  Words(
      front: "Upon hearing the news, she started crying.",
      back: "Haberi duyunca ağlamaya başladı.",
      list: 'B1',
      answer: 'üzerine',
      quest: 'Upon'),
  Words(
      front: "Don't say anything that might upset him.",
      back: "Onu üzebilecek bir şey söyleme.",
      list: 'B1',
      answer: 'üzmek',
      quest: 'upset'),
  Words(
      front: "Do you have any used books you want to sell?",
      back: "Satmak istediğiniz kullanılmış kitaplarınız var mı?",
      list: 'B1',
      answer: 'kullanılmış',
      quest: 'used'),
  Words(
      front: "Time is a valuable resource. Don't waste it.",
      back: "Zaman değerli bir kaynaktır. Onu boşa harcamayın.",
      list: 'B1',
      answer: 'değerli',
      quest: 'valuable'),
  Words(
      front: "How much do you value your education?",
      back: "Eğitiminize ne kadar değer veriyorsunuz?",
      list: 'B1',
      answer: 'değer biçmek',
      quest: 'value'),
  Words(
      front: "There are various factors that contribute to climate change.",
      back: "İklim değişikliğine katkıda bulunan çeşitli faktörler vardır.",
      list: 'B1',
      answer: 'çeşitli',
      quest: 'various'),
  Words(
      front:
          "The crime victim received counseling to help cope with the trauma.",
      back:
          "Suç mağduru, travmayla başa çıkmasına yardımcı olmak için danışmanlık aldı.",
      list: 'B1',
      answer: 'kurban',
      quest: 'victim'),
  Words(
      front: "I would like to view the painting in a better light.",
      back: "Resmi daha iyi bir ışıkta incelemek istiyorum.",
      list: 'B1',
      answer: 'incelemek',
      quest: 'view'),
  Words(
      front: "The program has millions of viewers around the world.",
      back: "Programın dünyada milyonlarca izleyicisi var.",
      list: 'B1',
      answer: 'izleyici',
      quest: 'viewer'),
  Words(
      front:
          "The movie contains some violent scenes that may be disturbing to viewers.",
      back:
          "Film, izleyicileri rahatsız edebilecek bazı şiddetli sahneler içeriyor.",
      list: 'B1',
      answer: 'şiddetli',
      quest: 'violent'),
  Words(
      front: "Many people volunteer at local charities to help those in need.",
      back:
          "Birçok insan, ihtiyacı olanlara yardım etmek için yerel yardım kuruluşlarında gönüllü olarak çalışır.",
      list: 'B1',
      answer: 'gönüllü',
      quest: 'volunteer'),
  Words(
      front: "Don't forget to vote in the upcoming election!",
      back: "Yaklaşan seçimde oy vermeyi unutmayın!",
      list: 'B1',
      answer: 'oy vermek',
      quest: 'vote'),
  Words(
      front:
          "The weather is cold. Please wear something warm before you go outside.",
      back:
          "Hava soğuk. Dışarı çıkmadan önce lütfen sıcak tutacak bir şeyler giyin.",
      list: 'B1',
      answer: 'ısıtmak',
      quest: 'warm'),
  Words(
      front: "The police warned drivers about the icy road conditions.",
      back: "Polis, sürücüleri buzlu yol koşulları konusunda uyardı.",
      list: 'B1',
      answer: 'uyarmak',
      quest: 'warn'),
  Words(
      front: "There are warning signs on the beach about strong currents.",
      back: "Plajda güçlü akıntılarla ilgili uyarı işaretleri var.",
      list: 'B1',
      answer: 'uyarı',
      quest: 'warning'),
  Words(
      front:
          "It's a waste of time to argue with someone who is not willing to listen.",
      back: "Dinlemeye istekli olmayan biriyle tartışmak zaman kaybıdır.",
      list: 'B1',
      answer: 'boşa harcamak',
      quest: 'waste'),
  Words(
      front:
          "We need to conserve water. Don't leave the tap running when you brush your teeth.",
      back:
          "Suyu korumamız gerekiyor. Dişlerinizi fırçalarken musluğu açık bırakmayın.",
      list: 'B1',
      answer: 'su',
      quest: 'water'),
  Words(
      front: "I saw a big wave crashing on the shore.",
      back: "Sahilde dev bir dalganın vurduğunu gördüm.",
      list: 'B1',
      answer: 'dalga',
      quest: 'wave'),
  Words(
      front: "Guns are considered weapons in most countries.",
      back: "Silahlar, çoğu ülkede silah olarak kabul edilir.",
      list: 'B1',
      answer: 'silah',
      quest: 'weapon'),
  Words(
      front: "Can you help me weigh this box?",
      back: "Bu kutuyu tartmama yardım edebilir misin?",
      list: 'B1',
      answer: 'tartmak',
      quest: 'weigh'),
  Words(
      front: "Western culture has had a significant influence on the world.",
      back: "Batı kültürü, dünya üzerinde önemli bir etkiye sahip olmuştur.",
      list: 'B1',
      answer: 'Batılı',
      quest: 'Western'),
  Words(
      front: "Take whatever you need from the fridge.",
      back: "Buzdolabından ihtiyacın olan her şeyi al.",
      list: 'B1',
      answer: 'hangi',
      quest: 'whatever'),
  Words(
      front: "I can help you whenever you need it.",
      back: "Ne zaman ihtiyacınız olursa size yardım edebilirim.",
      list: 'B1',
      answer: 'herhangi bir zamanda',
      quest: 'whenever'),
  Words(
      front:
          "I don't care whether you win or lose, as long as you try your best.",
      back: "Kazansan da kaybetsen de, yeter ki elinden geleni yap, umursumam.",
      list: 'B1',
      answer: '-se de, -mese de',
      quest: 'whether'),
  Words(
      front: "While he was working on his project, I watched a movie.",
      back: "O projesi üzerinde çalışırken ben bir film izledim.",
      list: 'B1',
      answer: 'sırasında',
      quest: 'While'),
  Words(
      front: "I ate the whole cake by myself!",
      back: "Pastanın tamamını tek başıma yedim!",
      list: 'B1',
      answer: 'tam',
      quest: 'whole'),
  Words(
      front: "He has a strong will to succeed.",
      back: "Başarılı olma konusunda güçlü bir iradesi var.",
      list: 'B1',
      answer: 'irade',
      quest: 'will'),
  Words(
      front: "Our team win the competition!",
      back: "Takımımız yarışmayı kazandı!",
      list: 'B1',
      answer: 'kazanmak',
      quest: 'win'),
  Words(
      front: "The bird flapped its wings and flew away.",
      back: "Kuş kanatlarını çırptı ve uçup gitti.",
      list: 'B1',
      answer: 'kanat',
      quest: 'wing'),
  Words(
      front: "The cost of the trip is included within the price of the tour.",
      back: "Gezi ücretine yolculuk masrafı dahildir.",
      list: 'B1',
      answer: 'dahilinde',
      quest: 'within'),
  Words(
      front: "I wonder what they are talking about.",
      back: "Ne hakkında konuştuklarını merak ediyorum.",
      list: 'B1',
      answer: 'merak etmek',
      quest: 'wonder'),
  Words(
      front: "This sweater is made of wool. It's very warm.",
      back: "Bu kazak yünden yapılmış. Çok sıcak tutuyor.",
      list: 'B1',
      answer: 'yün',
      quest: 'wool'),
  Words(
      front: "The company has a worldwide reputation for its quality products.",
      back: "Şirket, kaliteli ürünleri ile dünya çapında bir üne sahiptir.",
      list: 'B1',
      answer: 'dünya çapındaki',
      quest: 'worldwide'),
  Words(
      front: "Don't worry, I'm sure everything will be alright.",
      back: "Endişelenme, eminim her şey yolunda olacak.",
      list: 'B1',
      answer: 'endişe',
      quest: 'worry'),
  Words(
      front: "The situation is bad, but it could be worse.",
      back: "Durum kötü, ama daha kötü olabilirdi.",
      list: 'B1',
      answer: 'daha kötüsü',
      quest: 'worse'),
  Words(
      front: "That was the worst movie I've ever seen!",
      back: "Bu şimdiye kadar gördüğüm en kötü filmdi!",
      list: 'B1',
      answer: 'en kötü',
      quest: 'worst'),
  Words(
      front: "Is this painting worth a lot of money?",
      back: "Bu tablo çok mu değerli?",
      list: 'B1',
      answer: 'değer',
      quest: 'worth'),
  Words(
      front:
          "Please read the written instructions carefully before you start assembling the furniture.",
      back:
          "Mobilya montajına başlamadan önce lütfen yazılı talimatları dikkatlice okuyun.",
      list: 'B1',
      answer: 'yazılı',
      quest: 'written'),
  Words(
      front: "I think you might be wrong about that.",
      back: "Sanırım bunda yanılıyor olabilirsin.",
      list: 'B1',
      answer: 'yanlış',
      quest: 'wrong'),
  Words(
      front: "We had a picnic in our front yard.",
      back: "Ön bahçemizde piknik yaptık.",
      list: 'B1',
      answer: 'bahçe',
      quest: 'yard'),
  Words(
      front: "He is a young man with a bright future.",
      back: "O parlak bir geleceği olan genç bir adam.",
      list: 'B1',
      answer: 'genç',
      quest: 'young'),
  Words(
      front: "She full of youthful energy.",
      back: "O gençlik enerjisiyle dolu.",
      list: 'B1',
      answer: 'gençlik',
      quest: 'youth'),
  Words(
      front: "What is your special ability?", // related to 'ability'
      back: "Yeteneklerin nelerdir?",
      list: 'A2',
      answer: "yetenek",
      quest: "ability"),
  Words(
      front: "Are you able to speak another language?", // related to 'able'
      back: "Başka bir dil konuşabiliyor musun?",
      list: "A2",
      answer: "hünerli",
      quest: "able"),
  Words(
      front: "Have you ever traveled abroad?", // related to 'abroad'
      back: "Hiç yurt dışında seyahat ettin mi?",
      list: "A2",
      answer: "yurt dışında",
      quest: "abroad"),
  Words(
      front: "Can you please accept this gift?", // related to 'accept'
      back: "Bu hediyeyi kabul edebilir misin?",
      list: "A2",
      answer: "kabul etmek",
      quest: "accept"),
  Words(
      front: "It was an accident.", // related to 'accident'
      back: "Kazaydı.",
      list: "A2",
      answer: "rastlantı, kaza",
      quest: "accident"),
  Words(
      front:
          "According to the news, it will rain tomorrow.", // related to 'according to'
      back: "Habere göre yarın yağmur yağacak.",
      list: "A2",
      answer: "göre",
      quest: "According to"),
  Words(
      front: "What do you want to achieve in life?", // related to 'achieve'
      back: "Hayatta neyi başarmak istiyorsun?",
      list: "A2",
      answer: "başarmak",
      quest: "achieve"),
  Words(
      front: "The play is a call to act on climate change.", // related to 'act'
      back: "Oyun, iklim değişikliği konusunda harekete geçmeye bir çağrı.",
      list: "A2",
      answer: "eylem",
      quest: "act"),
  Words(
      front: "He is a very active person.", // related to 'active'
      back: "Çok aktif bir insan.",
      list: "A2",
      answer: "aktif",
      quest: "active"),
  Words(
      front: "Actually, I was just leaving.", // related to 'actually'
      back: "Aslında, tam çıkıyordum.",
      list: "A2",
      answer: "aslında",
      quest: "Actually"),
  Words(
      front: "She is an adult now.", // related to 'adult'
      back: "Artık o bir yetişkin.",
      list: "A2",
      answer: "yetişkin",
      quest: "adult"),
  Words(
      front:
          "This company advertises its products on TV.", // related to 'advertise'
      back:
          "Bu şirket ürünlerini televizyonda реклаması yapıyor (reklam etmek).",
      list: "A2",
      answer: "reklamını yapmak",
      quest: "advertise"),
  Words(
      front: "How can this decision affect me?", // related to 'affect'
      back: "Bu karar beni nasıl etkileyebilir?",
      list: "A2",
      answer: "etkilemek",
      quest: "affect"),
  Words(
      front: "After I finish work, I will go to the gym.", // related to 'after'
      back: "İşten sonra spor salonuna gideceğim.",
      list: "A2",
      answer: "sonra",
      quest: "After"),
  Words(
      front: "Are you against animal testing?", // related to 'against'
      back: "Hayvan deneylerine karşı mısınız?",
      list: "A2",
      answer: "aykırı",
      quest: "against"),
  Words(
      front: "Which airline did you fly with?", // related to 'airline'
      back: "Hangi havayoluyla uçtun?",
      list: "A2",
      answer: "havayolu",
      quest: "airline"),
  Words(
      front: "Is everything alive in the garden?", // related to 'alive'
      back: "Bahçedeki her şey canlı mı?",
      list: "A2",
      answer: "canlı",
      quest: "alive"),
  Words(
      front: "All the students passed the exam.", // related to 'all'
      back: "Tüm öğrenciler sınavı geçti.",
      list: "A2",
      answer: "hepsi",
      quest: "All"),
  Words(
      front: "Will you allow me to use your phone?", // related to 'allow'
      back: "Telefonunu kullanmama izin verir misin?",
      list: "A2",
      answer: "izin vermek",
      quest: "allow"),
  Words(
      front: "I am almost finished.", // related to 'almost'
      back: "Neredeyse bitirdim.",
      list: "A2",
      answer: "neredeyse",
      quest: "almost"),
  Words(
      front: "I prefer to be alone sometimes.", // related to 'alone'
      back: "Bazen yalnız olmayı tercih ederim.",
      list: "A2",
      answer: "yalnız",
      quest: "alone"),
  Words(
      front: "We walked along the beach.", // related to 'along'
      back: "Plaj boyunca yürüdük.",
      list: "A2",
      answer: "boyunca",
      quest: "along"),
  Words(
      front: "Have you eaten already?", // related to 'already'
      back: "Zaten yemek yedin mi?",
      list: "A2",
      answer: "zaten, çoktan",
      quest: "already"),
  Words(
      front: "Although I was tired, I went for a run.", // related to 'although'
      back: "Yorgun olmama rağmen koşuya gittim.",
      list: "A2",
      answer: "her ne kadar",
      quest: "Although"),
  Words(
      front: "Among my friends, I am the tallest.", // related to 'among'
      back: "Arkadaşlarım arasında en uzun boylu benim.",
      list: "A2",
      answer: "arasında",
      quest: "Among"),
  Words(
      front: "The amount of rain this year is unusual.", // related to 'amount'
      back: "Bu yıl yağan yağmur miktarı alışılmadık.",
      list: "A2",
      answer: "miktar",
      quest: "amount"),
  Words(
      front: "Have you seen any ancient ruins?", // related to 'ancient'
      back: "Herhangi antik kalıntı gördün mü?",
      list: "A2",
      answer: "antik",
      quest: "ancient"),
  Words(
      front: "Be careful not to twist your ankle.", // related to 'ankle'
      back: "Dikkat et ayak bileğini burkma.",
      list: "A2",
      answer: "ayak bileği",
      quest: "ankle"),
  Words(
    front: "Do you have any questions?",
    back: "Herhangi bir sorunuz var mı?",
    list: "A2",
    answer: "herhangi, her",
    quest: "any",
  ),
  Words(
      front: "Is there anybody here who speaks French?", // related to 'anybody'
      back: "Burada Fransızca konuşan kimse var mı?",
      list: "A2",
      answer: "kimse",
      quest: "anybody"),
  Words(
      front: "I don't go to the cinema anymore.", // related to 'anymore'
      back: "Artık sinemaya gitmiyorum.",
      list: "A2",
      answer: "artık",
      quest: "anymore"),
  Words(
      front: "Anyway, let's move on to the next topic.", // related to 'anyway'
      back: "Her neyse, bir sonraki konuya geçelim.",
      list: "A2",
      answer: "her neyse",
      quest: "Anyway"),
  Words(
      front:
          "Can you meet me anywhere in the city center?", // related to 'anywhere'
      back: "Şehrin merkezinde herhangi bir yerde benimle buluşabilir misin?",
      list: "A2",
      answer: "herhangi bir yer",
      quest: "anywhere"),
  Words(
      front:
          "There are many useful apps available for learning languages.", // related to 'app'
      back: "Dil öğrenmek için birçok faydalı uygulama var.",
      list: "A2",
      answer: "uygulama",
      quest: "app"),
  Words(
      front:
          "The magician made the rabbit appear out of thin air.", // related to 'appear'
      back: "Sihirbaz tavşanı yoktan var etti.",
      list: "A2",
      answer: "beli olmak",
      quest: "appear"),
  Words(
      front:
          "She takes great care of her appearance.", // related to 'appearance'
      back: "Dış görünüşüne çok özen gösteriyor.",
      list: "A2",
      answer: "dış görünüş",
      quest: "appearance"),
  Words(
      front: "How do I apply for this job?", // related to 'apply'
      back: "Bu işe nasıl başvurabilirim?",
      list: "A2",
      answer: "uygulamak",
      quest: "apply"),
  Words(
      front:
          "This building was designed by a famous architect.", // related to 'architect'
      back: "Bu bina ünlü bir mimar tarafından tasarlandı.",
      list: "A2",
      answer: "mimar",
      quest: "architect"),
  Words(
      front:
          "They are always argue/ing about something.", // related to 'argue' (already defined)
      back: "Her zaman bir şey hakkında tartışıyorlar.",
      list: "A2",
      answer: "tartışmak",
      quest: "argue"),
  Words(
      front:
          "They had a strong argument about the movie.", // related to 'argument'
      back: "Film hakkında güçlü bir argümanları vardı.",
      list: "A2",
      answer: "argüman",
      quest: "argument"),
  Words(
      front: "He joined the army after graduation.", // related to 'army'
      back: "Mezuniyetten sonra orduya katıldı.",
      list: "A2",
      answer: "ordu",
      quest: "army"),
  Words(
      front: "Can you arrange a meeting for tomorrow?", // related to 'arrange'
      back: "Yarın için bir toplantı ayarlayabilir misin?",
      list: "A2",
      answer: "ayarlamak",
      quest: "arrange"),
  Words(
      front: "He works as a doctor.", // related to 'as'
      back: "Doktor olarak çalışıyor.",
      list: "A2",
      answer: "olarak, gibi",
      quest: "as"),
  Words(
      front: "The city was under attack during the war.", // related to 'attack'
      back: "Şehir savaş sırasında saldırı altındaydı.",
      list: "A2",
      answer: "saldırı",
      quest: "attack"),
  Words(
      front: "Will you attend the conference?", // related to 'attend'
      back: "Konferansa katılacak mısın?",
      list: "A2",
      answer: "katılmak",
      quest: "attend"),
  Words(
      front: "He needs more attention in class.", // related to 'attention'
      back: "Derste daha fazla ilgiye ihtiyacı var.",
      list: "A2",
      answer: "ilgilenme",
      quest: "attention"),
  Words(
      front: "She is a very attractive woman.", // related to 'attractive'
      back: "Çok çekici bir kadın.",
      list: "A2",
      answer: "çekici",
      quest: "attractive"),
  Words(
      front:
          "The play was performed for a large audience.", // related to 'audience'
      back: "Oyun, geniş bir seyirci kitlesi için sergilendi.",
      list: "A2",
      answer: "seyirci",
      quest: "audience"),
  Words(
      front: "Who is the author of this book?", // related to 'author'
      back: "Bu kitabın yazarı kim?",
      list: "A2",
      answer: "yazar",
      quest: "author"),
  Words(
      front: "Is there a(n) available table for two?", // related to 'available'
      back: "İki kişilik boşta bir masa var mı?",
      list: "A2",
      answer: "boş, mevcut",
      quest: "available"),
  Words(
      front:
          "The average price of a house in this city is very high.", // related to 'average'
      back: "Bu şehirde bir evin ortalama fiyatı çok yüksek.",
      list: "A2",
      answer: "ortalama",
      quest: "average"),
  Words(
      front: "We should try to avoid making mistakes.", // related to 'avoid'
      back: "Hata yapmaktan kaçınmalıyız.",
      list: "A2",
      answer: "kaçınma",
      quest: "avoid"),
  Words(
      front: "She won an award for her bravery.", // related to 'award'
      back: "Cesaretinden dolayı bir ödül kazandı.",
      list: "A2",
      answer: "ödül",
      quest: "award"),
  Words(
      front: "The weather was awful today.", // related to 'awful'
      back: "Hava bugün berbattı.",
      list: "A2",
      answer: "berbat",
      quest: "awful"),
  Words(
      front: "Come back tomorrow.", // related to 'back'
      back: "Yarın geri gel.",
      list: "A2",
      answer: "arka, geri",
      quest: "back"),
  Words(
      front:
          "He has a degree in background in computer science.", // related to 'background'
      back: "Bilgisayar bilimleri alanında bir arka planı var.",
      list: "A2",
      answer: "arka plan",
      quest: "background"),
  Words(
      front: "He played very badly yesterday.", // related to 'badly'
      back: "Dün çok kötü oynadı.",
      list: "A2",
      answer: "kötü bir şekilde",
      quest: "badly"),
  Words(
      front: "This decision is based on research.", // related to 'based'
      back: "Bu karar araştırmaya dayanmaktadır.",
      list: "A2",
      answer: "temeli",
      quest: "based"),
  Words(
      front: "Do you like beans?", // related to 'bean'
      back: "Fasulye sever misin?",
      list: "A2",
      answer: "fasulye",
      quest: "bean"),
  Words(
      front: "I saw a bear in the forest.", // related to 'bear'
      back: "Ormanda bir ayı gördüm.",
      list: "A2",
      answer: "ayı",
      quest: "bear"),
  Words(
      front: "The boxer beat his opponent.", // related to 'beat'
      back: "Boksör rakibini yendi.",
      list: "A2",
      answer: "darbe",
      quest: "beat"),
  Words(
      front: "Would you like some beef?", // related to 'beef'
      back: " biraz sığır eti ister misin?",
      list: "A2",
      answer: "et",
      quest: "beef"),
  Words(
      front:
          "Before you start, let me explain the rules.", // related to 'before'
      back: "Başlamadan önce kuralları açıklayayım.",
      list: "A2",
      answer: "önce",
      quest: "Before"),
  Words(
      front: "Please behave in class.", // related to 'behave'
      back: "Lütfen sınıfta davranışlarına dikkat et.",
      list: "A2",
      answer: "davranmak",
      quest: "behave"),
  Words(
      front:
          "Her behaviour at school was good last year.", // related to 'behaviour'
      back: "Geçen sene okul davranışları iyiydi.",
      list: "A2",
      answer: "davranış",
      quest: "behaviour"),
  Words(
      front: "This book belongs to me.", // related to 'belong'
      back: "Bu kitap bana ait.",
      list: "A2",
      answer: "ait olmak",
      quest: "belong"),
  Words(
      front: "Can you tighten my belt?", // related to 'belt'
      back: "Kemerimi sıkabilir misin?",
      list: "A2",
      answer: "kemer",
      quest: "belt"),
  Words(
      front:
          "Regular exercise has many benefits for your health.", // related to 'benefit'
      back: "Düzenli egzersizin sağlığınız için birçok faydası vardır.",
      list: "A2",
      answer: "menfaat",
      quest: "benefit"),
  Words(
      front: "Which is the best restaurant in town?", // related to 'best'
      back: "Şehrin en iyi restoranı hangisi?",
      list: "A2",
      answer: "en iyisi",
      quest: "best"),
  Words(
      front: "This milk is better than the other one.", // related to 'better'
      back: "Bu süt diğerinden daha iyi.",
      list: "A2",
      answer: "daha iyi",
      quest: "better"),
  Words(
      front: "He sat between his two friends.", // related to 'between'
      back: "İki arkadaşı arasında oturdu.",
      list: "A2",
      answer: "arasında",
      quest: "between"),
  Words(
      front:
          "The population of the world is over seven billion.", // related to 'billion'
      back: "Dünya nüfusu yedi milyardan fazla.",
      list: "A2",
      answer: "milyar",
      quest: "billion"),
  Words(
      front: "Please throw this paper in the bin.", // related to 'bin'
      back: "Lütfen bu kağıdı çöp kutusuna at.",
      list: "A2",
      answer: "çöp kutusu",
      quest: "bin"),
  Words(
      front: "What is your date of birth?", // related to 'birth'
      back: "Doğum tarihiniz nedir?",
      list: "A2",
      answer: "doğum",
      quest: "birth"),
  Words(
      front: "Would you like a biscuit with your tea?", // related to 'biscuit'
      back: "Çayınızın yanında bisküvi ister misiniz?",
      list: "A2",
      answer: "bisküvi",
      quest: "biscuit"),
  Words(
      front:
          "Leave the form blank if you don't have that information.", // related to 'blank'
      back: "Bu bilgi yoksa formu boş bırakın.",
      list: "A2",
      answer: "boş",
      quest: "blank"),
  Words(
      front:
          "The doctor took a blood sample for testing.", // related to 'blood'
      back: "Doktor test için kan örneği aldı.",
      list: "A2",
      answer: "kan",
      quest: "blood"),
  Words(
      front: "The wind is blowing hard today.", // related to 'blow'
      back: "Bugün rüzgar sert esiyor.",
      list: "A2",
      answer: "esmek",
      quest: "blow"),
  Words(
      front:
          "There is an announcement board in the hall.", // related to 'board'
      back: "Salonda bir anons panosu var.",
      list: "A2",
      answer: "pano",
      quest: "board"),
  Words(
      front:
          "The water is boiling - be careful not to touch it!", // related to 'boil'
      back: "Su kaynıyor - dokunmamaya dikkat edin!",
      list: "A2",
      answer: "kaynamak",
      quest: "boil"),
  Words(
      front: "I broke my bone in an accident.", // related to 'bone'
      back: "Kazada kemiğimi kırdım.",
      list: "A2",
      answer: "kemik",
      quest: "bone"),
  Words(
      front: "I am reading an interesting book.", // related to 'book'
      back: "İlginç bir kitap okuyorum.",
      list: "A2",
      answer: "kitap",
      quest: "book"),
  Words(
      front: "Can I borrow your pen?", // related to 'borrow'
      back: "Kalemini ödünç alabilir miyim?",
      list: "A2",
      answer: "ödünç almak",
      quest: "borrow"),
  Words(
      front: "I need to speak to the boss.", // related to 'boss'
      back: "Patronla konuşmam gerekiyor.",
      list: "A2",
      answer: "patron",
      quest: "boss"),
  Words(
      front: "Sit at the bottom of the stairs.", // related to 'bottom'
      back: "Merdivenlerin dibine otur.",
      list: "A2",
      answer: "dip",
      quest: "bottom"),
  Words(
      front: "Please give me a bowl of soup.", // related to 'bowl'
      back: " Bana bir kase çorba verir misin?",
      list: "A2",
      answer: "kase",
      quest: "bowl"),
  Words(
      front: "The human brain is a complex organ.", // related to 'brain'
      back: "İnsan beyni karmaşık bir organdır.",
      list: "A2",
      answer: "beyin",
      quest: "brain"),
  Words(
      front: "We crossed the river by bridge.", // related to 'bridge'
      back: "Nehri köprüden geçtik.",
      list: "A2",
      answer: "köprü",
      quest: "bridge"),
  Words(
      front: "The sun is shining brightly today.", // related to 'bright'
      back: "Bugün güneş parlak bir şekilde parlıyor.",
      list: "A2",
      answer: "parlak",
      quest: "bright"),
  Words(
      front: "That was a brilliant idea!", // related to 'brilliant'
      back: "Ne harika bir fikirdi!",
      list: "A2",
      answer: "nefis",
      quest: "brilliant"),
  Words(
      front:
          "My phone is broken. I need to get it fixed.", // related to 'broken'
      back: "Telefonum bozuk. Tamir ettirmem gerekiyor.",
      list: "A2",
      answer: "arızalı",
      quest: "broken"),
  Words(
      front: "Please brush your teeth before bed.", // related to 'brush'
      back: "Lütfen yatmadan önce dişlerinizi fırçalayın.",
      list: "A2",
      answer: "fırçalamak",
      quest: "brush"),
  Words(
      front:
          "Be careful not to burn yourself on the stove.", // related to 'burn'
      back: "Ocağa yakmamaya dikkat edin.",
      list: "A2",
      answer: "yakmak",
      quest: "burn"),
  Words(
      front: "He is a successful businessman.", // related to 'businessman'
      back: "Başarılı bir iş adamı.",
      list: "A2",
      answer: "iş adamı",
      quest: "businessman"),
  Words(
      front: "Can you help me button my button?", // related to 'button'
      back: "Düğmeme bastırmama yardım edebilir misin?",
      list: "A2",
      answer: "düğme",
      quest: "button"),
  Words(
      front: "We are going camping this weekend.", // related to 'camping'
      back: "Bu hafta sonu kamp yapmaya gidiyoruz.",
      list: "A2",
      answer: "kamp yapma",
      quest: "camping"),
  Words(
      front: "Can I have a can of cola, please?", // related to 'can'
      back: "Bana bir kola kutusu alabilir miyim?",
      list: "A2",
      answer: "teneke",
      quest: "can"),
  Words(
      front: "You need to take better care of your car.", // related to 'care'
      back: "Arabanızın daha iyi bakımını yapmanız gerekiyor.",
      list: "A2",
      answer: "bakım, dikkat",
      quest: "care"),
  Words(
      front: "Be careful when crossing the street.", // related to 'careful'
      back: "Yoldan geçerken dikkatli olun.",
      list: "A2",
      answer: "dikkatli",
      quest: "careful"),
  Words(
      front: "There is a beautiful carpet on the floor.", // related to 'carpet'
      back: "Yerde güzel bir halı var.",
      list: "A2",
      answer: "halı",
      quest: "carpet"),
  Words(
      front: "I love watching funny cartoons.", // related to 'cartoon'
      back: "Komik çizgi filmleri izlemeyi seviyorum.",
      list: "A2",
      answer: "karikatür",
      quest: "cartoon"),
  Words(
      front: "The case is still under investigation.", // related to 'case'
      back: "Dava hala soruşturma altında.",
      list: "A2",
      answer: "dava",
      quest: "case"),
  Words(
      front:
          "Do you have enough cash to pay for the taxi?", // related to 'cash'
      back: "Taksiyi ödeyecek kadar nakit paranız var mı?",
      list: "A2",
      answer: "nakit",
      quest: "cash"),
  Words(
      front:
          "We visited a beautiful old castle on our trip.", // related to 'castle'
      back: "Gezimizde güzel bir eski kaleyi ziyaret ettik.",
      list: "A2",
      answer: "kale",
      quest: "castle"),
  Words(
      front:
          "The bus driver tried to catch the speeding car.", // related to 'catch'
      back: "Otobüs şoförü hız yapan arabayı yakalamaya çalıştı.",
      list: "A2",
      answer: "yakalamak",
      quest: "catch"),
  Words(
      front: "What is the cause of the problem?", // related to 'cause'
      back: "Sorunun nedeni nedir?",
      list: "A2",
      answer: "sebep",
      quest: "cause"),
  Words(
      front:
          "Let's celebrate your birthday this weekend!", // related to 'celebrate'
      back: "Doğum gününüzü bu hafta sonu kutlayalım!",
      list: "A2",
      answer: "kutlamak",
      quest: "celebrate"),
  Words(
      front: "He is a famous celebrity.", // related to 'celebrity'
      back: "O ünlü birisi.",
      list: "A2",
      answer: "ünlü kişi",
      quest: "celebrity"),
  Words(
      front:
          "Are you certain you want to quit your job?", // related to 'certain'
      back: "İşinizden ayrılmak istediğinizden emin misiniz?",
      list: "A2",
      answer: "kesin",
      quest: "certain"),
  Words(
      front: "I will certainly help you.", // related to 'certainly'
      back: "Size kesinlikle yardım edeceğim.",
      list: "A2",
      answer: "kesinlikle",
      quest: "certainly"),
  Words(
      front: "There is a chance it will rain today.", // related to 'chance'
      back: "Bugün yağmur yağma ihtimali var.",
      list: "A2",
      answer: "şans",
      quest: "chance"),
  Words(
      front: "They donated money to charity.", // related to 'charity'
      back: "Hayır kurumuna para bağışladılar.",
      list: "A2",
      answer: "hayırseverlik",
      quest: "charity"),
  Words(
      front: "Can we chat for a while?", // related to 'chat'
      back: "Bir süre sohbet edebilir miyiz?",
      list: "A2",
      answer: "sohbet",
      quest: "chat"),
  Words(
      front:
          "Please check your homework before you hand it in.", // related to 'check'
      back: "Ödevini teslim etmeden önce lütfen kontrol et.",
      list: "A2",
      answer: "kontrol",
      quest: "check"),
  Words(
      front:
          "He is a talented chef who cooks delicious food.", // related to 'chef'
      back: "O, lezzetli yemekler yapan yetenekli bir şef.",
      list: "A2",
      answer: "şef",
      quest: "chef"),
  Words(
      front:
          "I am learning about chemistry in science class.", // related to 'chemistry'
      back: "Fen bilgisi dersinde kimya öğreniyorum.",
      list: "A2",
      answer: "kimyasal",
      quest: "chemistry"),
  Words(
      front: "What is your choice - tea or coffee?", // related to 'choice'
      back: "Seçeneğiniz nedir - çay mı kahve mi?",
      list: "A2",
      answer: "tercih",
      quest: "choice"),
  Words(
      front:
          "There is a beautiful old church in the city center.", // related to 'church'
      back: "Şehrin merkezinde güzel ve eski bir kilise var.",
      list: "A2",
      answer: "kilise",
      quest: "church"),
  Words(
      front:
          "The water is very clear - you can see the bottom of the lake.", // related to 'clear'
      back: "Su çok temiz - gölün dibini görebilirsiniz.",
      list: "A2",
      answer: "temiz",
      quest: "clear"),
  Words(
      front:
          "Please speak clearly so I can understand you.", // related to 'clearly'
      back: "Anlayabilmem için lütfen açıkça konuşun.",
      list: "A2",
      answer: "açıkça",
      quest: "clearly"),
  Words(
      front: "He is a very clever boy.", // related to 'clever'
      back: "Çok zeki bir çocuk.",
      list: "A2",
      answer: "zeki",
      quest: "clever"),
  Words(
      front: "The weather is affected by the climate.", // related to 'climate'
      back: "Hava iklimden etkilenir.",
      list: "A2",
      answer: "iklim",
      quest: "climate"),
  Words(
      front: "Please close the door when you leave.", // related to 'close'
      back: "Çıkarken lütfen kapıyı kapatın.",
      list: "A2",
      answer: "kapamak",
      quest: "close"),
  Words(
      front: "The shops are all closed on Sundays.", // related to 'closed'
      back: "Pazar günleri tüm dükkanlar kapalı.",
      list: "A2",
      answer: "kapalı",
      quest: "closed"),
  Words(
      front: "She likes to wear comfortable clothing.", // related to 'clothing'
      back: "Rahat giysiler giymeyi sever.",
      list: "A2",
      answer: "giysi",
      quest: "clothing"),
  Words(
      front: "There is a big white cloud in the sky.", // related to 'cloud'
      back: "Gökyüzünde büyük beyaz bir bulut var.",
      list: "A2",
      answer: "bulut",
      quest: "cloud"),
  Words(
      front: "He is a football coach for the youth team.", // related to 'coach'
      back: "O, gençlik takımının futbol antrenörü.",
      list: "A2",
      answer: "antrenör",
      quest: "coach"),
  Words(
      front: "We are spending our vacation on the coast.", // related to 'coast'
      back: "Tatilimizi sahil kenarında geçiriyoruz.",
      list: "A2",
      answer: "deniz kenarı",
      quest: "coast"),
  Words(
      front: "Please enter your secret code.", // related to 'code'
      back: "Lütfen gizli kodunuzu girin.",
      list: "A2",
      answer: "şifre",
      quest: "code"),
  Words(
      front:
          "We need to collect the leaves from the garden.", // related to 'collect'
      back: " bahçeden yaprakları toplamamız gerekiyor.",
      list: "A2",
      answer: "toplamak",
      quest: "collect"),
  Words(
      front:
          "There is a beautiful ancient column in the square.", // related to 'column'
      back: "Meydanda güzel ve antik bir sütun var.",
      list: "A2",
      answer: "sütun",
      quest: "column"),
  Words(
      front:
          "I would like to watch a comedy movie tonight.", // related to 'comedy'
      back: "Bu akşam komedi filmi izlemek isterdim.",
      list: "A2",
      answer: "komedi",
      quest: "comedy"),
  Words(
      front:
          "I am wearing comfortable clothes for the trip.", // related to 'comfortable'
      back: "Gezi için rahat giysiler giyiyorum.",
      list: "A2",
      answer: "rahat",
      quest: "comfortable"),
  Words(
      front: "Can you leave a comment on my blog post?", // related to 'comment'
      back: "Blog yazım hakkında yorum bırakabilir misin?",
      list: "A2",
      answer: "yorum",
      quest: "comment"),
  Words(
      front:
          "I feel a sense of belonging to my local community.", // related to 'community'
      back: "Yerel topluluğuma ait olma duygusu hissediyorum.",
      list: "A2",
      answer: "topluluk",
      quest: "community"),
  Words(
      front: "Do you want to compete in the race?", // related to 'compete'
      back: "Yarışmada yarışmak ister misin?",
      list: "A2",
      answer: "yarışmak",
      quest: "compete"),
  Words(
      front:
          "The swimming competition is next week.", // related to 'competition'
      back: "Yüzme yarışması gelecek hafta.",
      list: "A2",
      answer: "yarışma",
      quest: "competition"),
  Words(
      front: "He always complains about the weather.", // related to 'complain'
      back: "Her zaman hava şartlarından şikayet eder.",
      list: "A2",
      answer: "şikayet etmek",
      quest: "complain"),
  Words(
      front: "I completely agree with you.", // related to 'completely'
      back: "Sana tamamen katılıyorum.",
      list: "A2",
      answer: "tamamen",
      quest: "completely"),
  Words(
      front:
          "I can't go swimming because of the weather conditions.", // related to 'condition'
      back: "Hava koşulları nedeniyle yüzemeye gidiyorum.",
      list: "A2",
      answer: "şart",
      quest: "condition"),
  Words(
      front:
          "There is a business conference in the city next month.", // related to 'conference'
      back: "Önümüzdeki ay şehirde bir iş konferansı var.",
      list: "A2",
      answer: "görüşme",
      quest: "conference"),
  Words(
      front: "Can you connect your phone to the Wi-Fi?", // related to 'connect'
      back: "Telefonunuzu Wi-Fi'ye bağlayabilir misiniz?",
      list: "A2",
      answer: "bağlanmak",
      quest: "connect"),
  Words(
      front:
          "My phone is not connected to the internet.", // related to 'connected'
      back: "Telefonum internete bağlı değil.",
      list: "A2",
      answer: "bağlı",
      quest: "connected"),
  Words(
      front:
          "You need to consider all your options before making a decision.", // related to 'consider'
      back: "Karar vermeden önce tüm seçeneklerinizi dikkate almalısınız.",
      list: "A2",
      answer: "dikkate almak",
      quest: "consider"),
  Words(
      front: "This box contains fragile items.", // related to 'contain'
      back: "Bu kutu kırılgan eşyalar içeriyor.",
      list: "A2",
      answer: "kapsamak",
      quest: "contain"),
  Words(
      front:
          "I don't understand the context of this sentence.", // related to 'context'
      back: "Bu cümlenin bağlamını anlamıyorum.",
      list: "A2",
      answer: "bağlam",
      quest: "context"),
  Words(
      front:
          "Asia is the largest continent in the world.", // related to 'continent'
      back: "Asya, dünyanın en büyük kıtasıdır.",
      list: "A2",
      answer: "kıta",
      quest: "continent"),
  Words(
      front: "Please continue reading the story.", // related to 'continue'
      back: "Lütfen hikayeyi okumaya devam edin.",
      list: "A2",
      answer: "devam ettirmek",
      quest: "continue"),
  Words(
      front:
          "You need to be in control of your emotions.", // related to 'control'
      back: "Duygularınızı kontrol altında tutmanız gerekir.",
      list: "A2",
      answer: "kontrol",
      quest: "control"),
  Words(
      front: "Can you cook dinner tonight?", // related to 'cook'
      back: "Bu akşam yemek pişirebilir misin?",
      list: "A2",
      answer: "pişirmek",
      quest: "cook"),
  Words(
      front: "Please turn on the cooker.", // related to 'cooker'
      back: "Lütfen ocağı aç.",
      list: "A2",
      answer: "ocak",
      quest: "cooker"),
  Words(
      front: "Can I have a copy of your notes?", // related to 'copy'
      back: "Notlarınızın bir kopyasını alabilir miyim?",
      list: "A2",
      answer: "kopya",
      quest: "copy"),
  Words(
      front: "There is a bookstore around the corner.", // related to 'corner'
      back: "Köşede bir kitapevi var.",
      list: "A2",
      answer: "köşe",
      quest: "corner"),
  Words(
      front: "Did you answer the question correctly?", // related to 'correctly'
      back: "Soruyu doğru cevapladın mı?",
      list: "A2",
      answer: "doğru",
      quest: "correctly"),
  Words(
      front: "Let's count how many apples there are.", // related to 'count'
      back: "Kaç tane elma olduğunu sayalım.",
      list: "A2",
      answer: "saymak",
      quest: "count"),
  Words(
      front:
          "We saw a happy couple walking in the park.", // related to 'couple'
      back: "Parkta yürüyen mutlu bir çift gördük.",
      list: "A2",
      answer: "çift",
      quest: "couple"),
  Words(
      front: "Can you put the cover on the box?", // related to 'cover'
      back: "Kutunun kapağını kapatabilir misin?",
      list: "A2",
      answer: "örtü, kılıf",
      quest: "cover"),
  Words(
      front: "He is acting a bit crazy today.", // related to 'crazy'
      back: "Bugün biraz deli davranıyor.",
      list: "A2",
      answer: "deli",
      quest: "crazy"),
  Words(
      front: "She is a very creative artist.", // related to 'creative'
      back: "O çok yaratıcı bir sanatçı.",
      list: "A2",
      answer: "yaratıcı",
      quest: "creative"),
  Words(
      front:
          "Can I give you some credit for the bus fare?", // related to 'credit'
      back: "Otobüs bileti için sana biraz borç verebilir miyim?",
      list: "A2",
      answer: "kredi",
      quest: "credit"),
  Words(
      front: "Stealing is a crime.", // related to 'crime'
      back: "Çalmak bir suçtur.",
      list: "A2",
      answer: "suç",
      quest: "crime"),
  Words(
      front:
          "The police are looking for the criminal.", // related to 'criminal'
      back: "Polis suçluyu arıyor.",
      list: "A2",
      answer: "suçlu",
      quest: "criminal"),
  Words(
      front:
          "Please walk on the other side of the street - it's too crowded here.", // related to 'cross'
      back: "Lütfen caddenin diğer tarafından yürüyün - burada çok kalabalık.",
      list: "A2",
      answer: "kalabalık",
      quest: "crowd"),
  Words(
      front: "She started to cry when she heard the news.", // related to 'cry'
      back: "Haberi duyunca ağlamaya başladı.",
      list: "A2",
      answer: "ağlamak",
      quest: "cry"),
  Words(
      front: "There are some plates in the cupboard.", // related to 'cupboard'
      back: "Dolapta bazı tabaklar var.",
      list: "A2",
      answer: "dolap",
      quest: "cupboard"),
  Words(
      front: "She has beautiful, long curly hair.", // related to 'curly'
      back: "Uzun ve güzel kıvırcık saçları var.",
      list: "A2",
      answer: "kıvırcık",
      quest: "curly"),
  Words(
      front: "The seasons change in a natural cycle.", // related to 'cycle'
      back: "Mevsimler doğal bir döngü içinde değişir.",
      list: "A2",
      answer: "devir",
      quest: "cycle"),
  Words(
      front:
          "I read a daily newspaper to keep up with current events.", // related to 'daily'
      back: "Günlük bir gazete okuyarak güncel olayları takip ediyorum.",
      list: "A2",
      answer: "günlük",
      quest: "daily"),
  Words(
      front:
          "Be careful, crossing the street alone at night can be dangerous.", // related to 'danger'
      back:
          "Dikkatli ol, gece tek başına karşıdan karşıya geçmek tehlikeli olabilir.",
      list: "A2",
      answer: "tehlikeli",
      quest: "danger"),
  Words(
      front: "It's too dark to read without a lamp.", // related to 'dark'
      back: "Lamba olmadan okumak için çok karanlık.",
      list: "A2",
      answer: "koyu",
      quest: "dark"),
  Words(
      front: "The scientist is analyzing scientific data.", // related to 'data'
      back: "Bilim insanı bilimsel verileri analiz ediyor.",
      list: "A2",
      answer: "veri",
      quest: "data"),
  Words(
      front: "Sadly, the old dog is dead.", // related to 'dead'
      back: "Ne yazık ki, yaşlı köpek öldü.",
      list: "A2",
      answer: "ölü",
      quest: "dead"),
  Words(
      front:
          "We made a deal to share the cost of the taxi.", // related to 'deal'
      back: "Taksi ücretini paylaşmak için bir anlaşma yaptık.",
      list: "A2",
      answer: "anlaşmak",
      quest: "deal"),
  Words(
      front: "Dear John, How are you?", // related to 'dear'
      back: "Sevgili John, Nasılsın?",
      list: "A2",
      answer: "sevgili",
      quest: "Dear"),
  Words(
      front: "Her death was a great loss to the family.", // related to 'death'
      back: "Onun ölümü aile için büyük bir kayıp oldu.",
      list: "A2",
      answer: "ölüm",
      quest: "death"),
  Words(
      front:
          "Making a good decision can be difficult.", // related to 'decision'
      back: "Doğru bir karar vermek zor olabilir.",
      list: "A2",
      answer: "karar",
      quest: "decision"),
  Words(
      front: "The lake is very deep.", // related to 'deep'
      back: "Göl çok derindir.",
      list: "A2",
      answer: "derin",
      quest: "deep"),
  Words(
      front:
          "I definitely want to go to the concert.", // related to 'definitely'
      back: "Kesinlikle konsere gitmek istiyorum.",
      list: "A2",
      answer: "kesinlikle",
      quest: "definitely"),
  Words(
      front:
          "The temperature today is 30 degrees Celsius.", // related to 'degree'
      back: "Bugün hava sıcaklığı 30 derece Celsius.",
      list: "A2",
      answer: "derece",
      quest: "degree"),
  Words(
      front:
          "I need to see the dentist because I have a toothache.", // related to 'dentist'
      back: "Diş ağrım olduğu için dişçiye gitmem gerekiyor.",
      list: "A2",
      answer: "dişçi",
      quest: "dentist"),
  Words(
      front:
          "She works in the marketing department.", // related to 'department'
      back: "Pazarlama bölümünde çalışıyor.",
      list: "A2",
      answer: "departman, bölüm",
      quest: "department"),
  Words(
      front:
          "Your success will depend on your hard work.", // related to 'depend'
      back: "Başarın sıkı çalışmana bağlı olacak.",
      list: "A2",
      answer: "bağlı olmak",
      quest: "depend"),
  Words(
      front: "The Sahara is a large desert in Africa.", // related to 'desert'
      back: "Sahra, Afrika'da bulunan geniş bir çöldür.",
      list: "A2",
      answer: "çöl",
      quest: "desert"),
  Words(
      front: "She is a talented graphic designer.", // related to 'designer'
      back: " yetenekli bir grafik tasarımcısıdır.",
      list: "A2",
      answer: "tasarımcı",
      quest: "designer"),
  Words(
      front:
          "The army completely destroyed the enemy's base.", // related to 'destroy'
      back: "Ordu, düşmanın üssünü tamamen yok etti.",
      list: "A2",
      answer: "imha etmek",
      quest: "destroy"),
  Words(
      front:
          "The detective is investigating the crime scene.", // related to 'detective'
      back: "Dedektif suç mahallini araştırıyor.",
      list: "A2",
      answer: "dedektif",
      quest: "detective"),
  Words(
      front:
          "This software is constantly being developed.", // related to 'develop'
      back: "Bu yazılım sürekli olarak geliştiriliyor.",
      list: "A2",
      answer: "geliştirmek",
      quest: "develop"),
  Words(
      front:
          "Can you turn off your electronic devices before boarding the airplane?", // related to 'device'
      back: "Uçağa binmeden önce elektronik cihazlarınızı kapatabilir misiniz?",
      list: "A2",
      answer: "cihaz",
      quest: "device"),
  Words(
      front:
          "I write my thoughts down in my diary every night.", // related to 'diary' (corrected closing quotation mark)
      back: "Her gece düşüncelerimi günlüğüme yazarım.",
      list: "A2",
      answer: "günlük",
      quest: "diary"),
  Words(
      front:
          "They did things differently in the past.", // related to 'differently'
      back: "Geçmişte işleri farklı yaptılar.",
      list: "A2",
      answer: "farklı",
      quest: "differently"),
  Words(
      front:
          "The teacher directed the students to the library.", // related to 'direct'
      back: "Öğretmen öğrencileri kütüphaneye yönlendirdi.",
      list: "A2",
      answer: "yöneltmek",
      quest: "direct"),
  Words(
      front:
          "Please walk straight ahead - that's the right direction.", // related to 'direction'
      back: "Lütfen düz yürüyün - bu doğru yön.",
      list: "A2",
      answer: "yön",
      quest: "direction"),
  Words(
      front:
          "The film is directed by a famous director.", // related to 'director'
      back: "Film ünlü bir yönetmen tarafından yönetiliyor.",
      list: "A2",
      answer: "yönetmen",
      quest: "director"),
  Words(
      front:
          "I disagree with your opinion on this matter.", // related to 'disagree'
      back: "Bu konudaki görüşüne katılmıyorum.",
      list: "A2",
      answer: "aynı fikirde olmamak",
      quest: "disagree"),
  Words(
      front:
          "The magician made the rabbit disappear in a puff of smoke.", // related to 'disappear'
      back: "Sihirbaz tavşanı bir duman bulutunda yok etti.",
      list: "A2",
      answer: "yok olmak",
      quest: "disappear"),
  Words(
      front: "The earthquake was a terrible disaster.", // related to 'disaster'
      back: "Deprem korkunç bir felaketti.",
      list: "A2",
      answer: "felaket",
      quest: "disaster"),
  Words(
      front:
          "The explorer discovered a new island in the Pacific Ocean.", // related to 'discover'
      back: "Kaşif Pasifik Okyanusu'nda yeni bir ada keşfetti.",
      list: "A2",
      answer: "keşfetmek",
      quest: "discover"),
  Words(
      front:
          "The discovery of penicillin revolutionized medicine.", // related to 'discovery'
      back: "Penisilinin keşfi tıp alanında devrim yarattı.",
      list: "A2",
      answer: "keşif",
      quest: "discovery"),
  Words(
      front:
          "We had a discussion about the best way to solve the problem.", // related to 'discussion'
      back: "Sorunu çözmenin en iyi yolu hakkında bir tartışma yaptık.",
      list: "A2",
      answer: "tartışma",
      quest: "discussion"),
  Words(
      front:
          "The flu is a common disease that causes fever and chills.", // related to 'disease'
      back: "Grip, ateş ve titremeye neden olan yaygın bir hastalıktır.",
      list: "A2",
      answer: "hastalık",
      quest: "disease"),
  Words(
      front:
          "The distance between Istanbul and Ankara is about 450 kilometers.", // related to 'distance'
      back: "İstanbul ile Ankara arasındaki mesafe yaklaşık 450 kilometredir.",
      list: "A2",
      answer: "mesafe",
      quest: "distance"),
  Words(
      front: "My parents divorced when I was young.", // related to 'divorced'
      back: "Küçükken annem ve babam boşandı.",
      list: "A2",
      answer: "ayrılmak, boşanmak",
      quest: "divorced"),
  Words(
      front:
          "Please give me all the necessary documents for the application.", // related to 'document'
      back: "Lütfen başvuru için gerekli tüm belgeleri bana verin.",
      list: "A2",
      answer: "belge",
      quest: "document"),
  Words(
      front:
          "I would like a double cheeseburger, please.", // related to 'double'
      back: "Lütfen double cheeseburger rica ederim.",
      list: "A2",
      answer: "çift",
      quest: "double"),
  Words(
      front:
          "Can I download this movie to watch later?", // related to 'download'
      back: "Bu filmi daha sonra izlemek için indirebilir miyim?",
      list: "A2",
      answer: "yüklemek",
      quest: "download"),
  Words(
      front: "Is John downstairs? I can't hear him.", // related to 'downstairs'
      back: "John aşağıda mı? Onu duyamıyorum.",
      list: "A2",
      answer: "aşağı kat",
      quest: "downstairs"),
  Words(
      front: "She showed me her beautiful drawings.", // related to 'drawing'
      back: "Bana güzel çizimlerini gösterdi.",
      list: "A2",
      answer: "çizme",
      quest: "drawing"),
  Words(
      front: "I had a wonderful dream last night.", // related to 'dream'
      back: "Dün gece harika bir rüya gördüm.",
      list: "A2",
      answer: "rüya",
      quest: "dream"),
  Words(
      front:
          "My father likes to drive his car to work every day.", // related to 'drive'
      back: "Babam her gün işe arabasını sürmeyi sever.",
      list: "A2",
      answer: "sürmek",
      quest: "drive"),
  Words(
      front: "Be careful not to drop your phone!", // related to 'drop'
      back: "Telefonunuzu düşürmemeye dikkat edin!",
      list: "A2",
      answer: "düşme",
      quest: "drop"),
  Words(
      front: "Some people take illegal drugs.", // related to 'drug'
      back: "Bazı insanlar yasadışı uyuşturucu alır.",
      list: "A2",
      answer: "ilaç",
      quest: "drug"),
  Words(
      front:
          "It's a bit dry outside today. We might need some rain.", // related to 'dry'
      back: "Bugün dışarı biraz kuru. Yağmura ihtiyacımız olabilir.",
      list: "A2",
      answer: "kuru",
      quest: "dry"),
  Words(
      front:
          "She works hard to earn money for her family.", // related to 'earn'
      back: "Ailesi için para kazanmak için çok çalışıyor.",
      list: "A2",
      answer: "kazanmak",
      quest: "earn"),
  Words(
      front:
          "The earth is the third planet from the sun.", // related to 'earth'
      back: "Dünya, güneşten üçüncü gezegendir.",
      list: "A2",
      answer: "dünya",
      quest: 'earth'),
  Words(
      front: "I can speak English easily now.", // related to 'easily'
      back: "Artık İngilizceyi kolaylıkla konuşabiliyorum.",
      list: "A2",
      answer: "rahatlıkla",
      quest: "easily"),
  Words(
      front:
          "A good education is important for a successful career.", // related to 'education'
      back: "Başarılı bir kariyer için iyi bir eğitim önemlidir.",
      list: "A2",
      answer: "eğitim",
      quest: "education"),
  Words(
      front:
          "What is the effect of smoking on your health?", // related to 'effect'
      back: "Sigaranın sağlığınız üzerindeki etkisi nedir?",
      list: "A2",
      answer: "etki",
      quest: "effect"),
  Words(
      front: "You can either have coffee or tea.", // related to 'either'
      back: "Ya kahve ya da çay içebilirsiniz.",
      list: "A2",
      answer: "her iki",
      quest: "either"),
  Words(
      front:
          "This appliance needs an electric outlet.", // related to 'electric'
      back: "Bu cihazın elektrik prizine ihtiyacı var.",
      list: "A2",
      answer: "elektrik",
      quest: "electric"),
  Words(
      front:
          "The company is looking to employ new workers.", // related to 'employ'
      back: "Şirket yeni çalışanlar istihdam etmeyi düşünüyor.",
      list: "A2",
      answer: "işe almak",
      quest: "employ"),
  Words(
      front:
          "He is a loyal employee who has been with the company for 10 years.", // related to 'employee'
      back: "10 yıldır şirkette çalışan sadık bir çalışan.",
      list: "A2",
      answer: "çalışan",
      quest: "employee"),
  Words(
      front: "She is a strict but fair employer.", // related to 'employer'
      back: "O katı ama adil bir işverendir.",
      list: "A2",
      answer: "iş veren",
      quest: "employer"),
  Words(
      front:
          "The bus is empty now that everyone has gotten off.", // related to 'empty'
      back: "Herkes indiğine göre otobüs şimdi boş.",
      list: "A2",
      answer: "boş",
      quest: "empty"),
  Words(
      front: "I didn't like the ending of the movie.", // related to 'ending'
      back: "Filmin sonunu beğenmedim.",
      list: "A2",
      answer: "bitiş",
      quest: "ending"),
  Words(
      front:
          "Solar energy is a clean and renewable source of energy.", // related to 'energy'
      back: "Güneş enerjisi temiz ve yenilenebilir bir enerji kaynağıdır.",
      list: "A2",
      answer: "enerji",
      quest: "energy"),
  Words(
      front:
          "The car won't start because the engine is broken.", // related to 'engine'
      back: "Motor arızalı olduğu için araba çalışmayacak.",
      list: "A2",
      answer: "motor",
      quest: "engine"),
  Words(
      front:
          "He is a talented engineer who designed this bridge.", // related to 'engineer'
      back: "Bu köprüyü tasarlayan yetenekli bir mühendistir.",
      list: "A2",
      answer: "mühendis",
      quest: "engineer"),
  Words(
      front:
          "The statue is enormous. I can't believe how big it is!", // related to 'enormous'
      back: "Heykel muazzam. Ne kadar büyük olduğuna inanamıyorum!",
      list: "A2",
      answer: "kocaman",
      quest: "enormous"),
  Words(
      front: "Please enter your name and password.", // related to 'enter'
      back: "Lütfen adınızı ve şifrenizi girin.",
      list: "A2",
      answer: "girmek",
      quest: "enter"),
  Words(
      front:
          "We need to take care of the environment.", // related to 'environment'
      back: " çevreye bakmamız gerekiyor.",
      list: "A2",
      answer: "çevre",
      quest: "environment"),
  Words(
      front:
          "Do you have all the necessary equipment for the camping trip?", // related to 'equipment'
      back: "Kamp gezisi için gerekli tüm ekipmana sahip misiniz?",
      list: "A2",
      answer: "ekipman",
      quest: "equipment"),
  Words(
      front: "There seems to be an error in your code.", // related to 'error'
      back: "Kodunuzda bir hata var gibi görünüyor.",
      list: "A2",
      answer: "hata",
      quest: "error"),
  Words(
      front:
          "I especially like to read historical novels.", // related to 'especially'
      back: "Özellikle tarihi roman okumayı severim.",
      list: "A2",
      answer: "özellikle",
      quest: "especially"),
  Words(
      front:
          "He wrote a great essay about climate change.", // related to 'essay'
      back: "İklim değişikliği hakkında harika bir deneme yazdı.",
      list: "A2",
      answer: "girişim",
      quest: "essay"),
  Words(
      front: "I wake up at the same time everyday", // related to 'every day'
      back: "Her gün aynı saatte uyanıyorum.",
      list: "A2",
      answer: "her gün",
      quest: "everyday"),
  Words(
      front:
          "Music is played everywhere in the city during the festival.", // related to 'everywhere'
      back: "Festival boyunca şehirde her yerde müzik çalınıyor.",
      list: "A2",
      answer: "her yer",
      quest: "everywhere"),
  Words(
      front:
          "Do you have any evidence to support your claim?", // related to 'evidence'
      back: "İddianızı destekleyen herhangi bir kanıtınız var mı?",
      list: "A2",
      answer: "kanıt",
      quest: "evidence"),
  Words(
      front: "What is the exact time now?", // related to 'exact'
      back: "Şimdi tam olarak saat kaç?",
      list: "A2",
      answer: "kesin",
      quest: "exact"),
  Words(
      front:
          "I don't know exactly what he meant by that.", // related to 'exactly'
      back: "Bununla ne demek istediğini tam olarak bilmiyorum.",
      list: "A2",
      answer: "kesinlikle",
      quest: "exactly"),
  Words(
      front:
          "She is an excellent student who always gets good grades.", // related to 'excellent'
      back: "Her zaman iyi not alan mükemmel bir öğrencidir.",
      list: "A2",
      answer: "mükemmel",
      quest: "excellent"),
  Words(
      front:
          "They did things differently in the past.", // related to 'differently'
      back: "Geçmişte işleri farklı yaptılar.",
      list: "A2",
      answer: "farklı",
      quest: "differently"),
  Words(
      front:
          "The explorer discovered a new island in the Pacific Ocean.", // related to 'discover'
      back: "Kaşif Pasifik Okyanusu'nda yeni bir ada keşfetti.",
      list: "A2",
      answer: "keşfetmek",
      quest: "discover"),
  Words(
      front:
          "The discovery of penicillin revolutionized medicine.", // related to 'discovery'
      back: "Penisilinin keşfi tıp alanında devrim yarattı.",
      list: "A2",
      answer: "keşif",
      quest: "discovery"),

  // New words
  Words(
      front:
          "I don't expect the bus to arrive on time today.", // related to 'expect'
      back: "Otobüsün bugün zamanında gelmesini beklemiyorum.",
      list: "A2",
      answer: "beklemek",
      quest: "expect"),
  Words(
      front: "Do you think life exists on other planets?", // related to 'exist'
      back: "Başka gezegenlerde yaşam var mı sence?",
      list: "A2",
      answer: "var olmak",
      quest: "exist"),
  Words(
      front:
          "Traveling to different countries is a great way to gain new experiences.", // related to 'experience'
      back:
          "Farklı ülkelere seyahat etmek, yeni deneyimler kazanmanın harika bir yoludur.",
      list: "A2",
      answer: "deneyim",
      quest: "experience"),
  Words(
      front:
          "Scientists are conducting an experiment to find a cure for cancer.", // related to 'experiment'
      back:
          "Bilim adamları kanser için bir tedavi bulmak amacıyla bir deney yürütüyorlar.",
      list: "A2",
      answer: "deney",
      quest: "experiment"),
  Words(
      front:
          "He is a history expert who has written many books on the subject.", // related to 'expert'
      back: "Konu hakkında birçok kitap yazmış bir tarih uzmanıdır.",
      list: "A2",
      answer: "uzman",
      quest: "expert"),
  Words(
      front:
          "Can you give me a more detailed explanation of the rules?", // related to 'explanation'
      back: "Bana kurallar hakkında daha detaylı bir açıklama yapabilir misin?",
      list: "A2",
      answer: "açıklama",
      quest: "explanation"),
  Words(
      front:
          "She expressed her happiness by jumping up and down.", // related to 'express'
      back: "Mutluluğunu zıplayarak ifade etti.",
      list: "A2",
      answer: "ifade etmek",
      quest: "express"),
  Words(
      front:
          "His facial expression showed that he was angry.", // related to 'expression'
      back: "Yüz ifadesi kızgın olduğunu gösteriyordu.",
      list: "A2",
      answer: "anlatım",
      quest: "expression"),
  Words(
      front:
          "The weather is going to be extreme this weekend - very hot and sunny!", // related to 'extreme'
      back: "Bu hafta sonu hava aşırı olacak - çok sıcak ve güneşli!",
      list: "A2",
      answer: "aşırı",
      quest: "extreme"),

  Words(
    front: 'Can you name a factor that affects plant growth?',
    back: 'Bitki büyümesini etkileyen bir faktör adlandırabilir misin?',
    list: 'A2',
    answer: 'etken',
    quest: 'factor',
  ),
  Words(
    front: 'The factory produces cars on a large scale.',
    back: 'Fabrika arabaları büyük ölçekte üretiyor.',
    list: 'A2',
    answer: 'fabrika',
    quest: 'factory',
  ),
  Words(
    front: "He failed the exam because he didn't study enough.",
    back: 'Yeterince çalışmadığı için sınavda başarısız oldu.',
    list: 'A2',
    answer: 'başarısızlık',
    quest: 'fail',
  ),
  Words(
    front: 'There will be a science fair at school next week.',
    back: 'Gelecek hafta okulda bir bilim fuarı olacak.',
    list: 'A2',
    answer: 'panayır',
    quest: 'fair',
  ),
  Words(
    front: 'The leaves start to fall in autumn.',
    back: 'Sonbaharda yapraklar dökülmeye başlar.',
    list: 'A2',
    answer: 'düşüş, güz',
    quest: 'fall',
  ),
  Words(
    front: 'She is a big fan of the pop star.',
    back: 'O, pop yıldızının büyük bir hayranı.',
    list: 'A2',
    answer: 'hayran',
    quest: 'fan',
  ),
  Words(
    front: 'We have a chicken farm near our house.',
    back: 'Evimizin yakınında bir tavuk çiftliği var.',
    list: 'A2',
    answer: 'çiftlik',
    quest: 'farm',
  ),
  Words(
    front: 'She is always following the latest fashion trends.',
    back: 'En yeni moda trendlerini her zaman takip ediyor.',
    list: 'A2',
    answer: 'moda',
    quest: 'fashion',
  ),
  Words(
    front: 'Eating too much fat can be unhealthy.',
    back: 'Çok fazla yağ yemek sağlıksız olabilir.',
    list: 'A2',
    answer: 'yağ',
    quest: 'fat',
  ),
  Words(
    front: 'I faced my fears and went skydiving.',
    back: 'Korkularımla yüzleştim ve paraşütle atladım.',
    list: 'A2',
    answer: 'korku',
    quest: 'fear',
  ),
  Words(
    front: 'This new phone has a great camera feature.',
    back: 'Bu yeni telefonun harika bir kamera özelliği var.',
    list: 'A2',
    answer: 'özellik',
    quest: 'feature',
  ),
  Words(
    front: 'You need to feed the cat before you leave.',
    back: 'Gitmeden önce kediyi beslemeniz gerekiyor.',
    list: 'A2',
    answer: 'beslemek',
    quest: 'feed',
  ),
  Words(
    front: 'There are many female CEOs in the tech industry.',
    back: 'Teknoloji sektöründe birçok kadın CEO var.',
    list: 'A2',
    answer: 'kadın',
    quest: 'female',
  ),
  Words(
    front: 'This book is a work of fiction, not a true story.',
    back: 'Bu kitap kurgu bir eser, gerçek bir hikaye değil.',
    list: 'A2',
    answer: 'kurgu',
    quest: 'fiction',
  ),
  Words(
    front: 'He is an expert in the field of computer science.',
    back: 'Bilgisayar bilimleri alanında uzmandır.',
    list: 'A2',
    answer: 'alan',
    quest: 'field',
  ),
  Words(
    front: 'They got into a fight over a parking spot.',
    back: 'Park yeri yüzünden kavga ettiler.',
    list: 'A2',
    answer: 'kavga',
    quest: 'fight',
  ),

  Words(
    front: 'He finally finished his homework after hours of studying.',
    back: 'Saatlerce çalıştıktan sonra sonunda ödevini bitirdi.',
    list: 'A2',
    answer: 'sonunda',
    quest: 'finally',
  ),
  Words(
    front: 'Point your finger at the object you want.',
    back: 'İstediğiniz nesneyi parmağınızla işaret edin.',
    list: 'A2',
    answer: 'parmak',
    quest: 'finger',
  ),
  Words(
    front: 'I need to finish this project by tomorrow.',
    back: 'Bu projeyi yarına kadar bitirmem gerekiyor.',
    list: 'A2',
    answer: 'bitirmek',
    quest: 'finish',
  ),
  Words(
    front: 'He came in first place in the race.',
    back: 'Yarışta birinci oldu.',
    list: 'A2',
    answer: 'birinci, ilk',
    quest: 'first',
  ),
  Words(
    front: 'Firstly, I would like to thank you for your time.',
    back: 'İlk olarak, zaman ayırdığınız için teşekkür ederim.',
    list: 'A2',
    answer: 'ilk önce',
    quest: 'Firstly',
  ),
  Words(
    front: 'We saw many different fish while snorkeling.',
    back: 'Şnorkelle dalarken birçok farklı balık gördük.',
    list: 'A2',
    answer: 'balık',
    quest: 'fish',
  ),
  Words(
    front: 'He enjoys fishing as a hobby.',
    back: 'Balık tutmayı hobi olarak seviyor.',
    list: 'A2',
    answer: 'balık tutmak',
    quest: 'fishing',
  ),
  Words(
    front: "These jeans don't fit me anymore. I need a bigger size.",
    back:
        'Bu kot pantolonlar artık üzerime olmuyor. Daha büyük bir bedene ihtiyacım var.',
    list: 'A2',
    answer: 'uymak',
    quest: 'fit',
  ),
  Words(
    front: 'Can you fix the broken lamp?',
    back: 'Kırık lambayı tamir edebilir misin?',
    list: 'A2',
    answer: 'düzeltmek',
    quest: 'fix',
  ),
  Words(
    front: 'The ground is flat here, perfect for playing frisbee.',
    back: 'Burası düz bir arazi, frisbi oynamak için ideal.',
    list: 'A2',
    answer: 'düz',
    quest: 'flat',
  ),
  Words(
    front: "She's been feeling under the weather lately. Maybe it's the flu.",
    back: 'Son zamanlarda kendini iyi hissetmiyor. Belki de griptir.',
    list: 'A2',
    answer: 'grip',
    quest: 'flu',
  ),
  Words(
    front: 'Birds can fly long distances.',
    back: 'Kuşlar uzun mesafeler uçabilir.',
    list: 'A2',
    answer: 'uçmak',
    quest: 'fly',
  ),
  Words(
    front: "It's important to focus on your studies if you want to succeed.",
    back: 'Başarılı olmak istiyorsanız çalışmalarınıza odaklanmanız önemlidir.',
    list: 'A2',
    answer: 'odak',
    quest: 'focus',
  ),
  Words(
    front: 'He is following the news closely to stay informed.',
    back: 'Bilgi sahibi olmak için haberleri yakından takip ediyor.',
    list: 'A2',
    answer: 'talip etme (takip etme)', // "Following" translated to "takip etme"
    quest: 'following',
  ),
  Words(
    front: 'We learned about different foreign cultures in history class.',
    back: 'Tarih dersinde farklı yabancı kültürleri öğrendik.',
    list: 'A2',
    answer: 'yabancı',
    quest: 'foreign',
  ),
  Words(
    front: 'There are many beautiful forests in Turkey.',
    back: 'Türkiye’de birçok güzel orman var.',
    list: 'A2',
    answer: 'orman',
    quest: 'forest',
  ),
  Words(
    front: 'Please pass me the fork.',
    back: 'Lütfen çatalı uzatır mısın?',
    list: 'A2',
    answer: 'çatal',
    quest: 'fork',
  ),
  Words(
    front: 'You should wear formal attire for the job interview.',
    back: 'İş görüşmesi için resmi kıyafet giymelisiniz.',
    list: 'A2',
    answer: 'resmi',
    quest: 'formal',
  ),
  Words(
    front: "Fortunately, it didn't rain today.",
    back: 'Neyse ki, bugün yağmur yağmadı.',
    list: 'A2',
    answer: 'neyse ki',
    quest: 'Fortunately',
  ),
  Words(
    front: "Let's look forward to a brighter future.",
    back: 'Daha parlak bir gelecek için sabırsızlanalım.',
    list: 'A2',
    answer: 'ileri',
    quest: 'forward',
  ),
  Words(
    front: 'This museum offers free admission on Sundays.',
    back: 'Bu müze, pazar günleri ücretsiz giriş imkanı sunuyor.',
    list: 'A2',
    answer: 'ücretsiz',
    quest: 'free',
  ),
  Words(
    front: 'I like to buy fresh fruits and vegetables at the farmers market.',
    back: 'Taze meyve ve sebzeleri çiftçi pazarından almayı seviyorum.',
    list: 'A2',
    answer: 'taze',
    quest: 'fresh',
  ),
  Words(
    front: 'Please put the leftover food in the fridge.',
    back: 'Lütfen kalan yemekleri buzdolabına koy.',
    list: 'A2',
    answer: 'buzdolabı',
    quest: 'fridge',
  ),
  Words(
    front: 'We saw a frog jumping in the pond.',
    back: 'Göletde zıplayan bir kurbağa gördük.',
    list: 'A2',
    answer: 'kurbağa',
    quest: 'frog',
  ),
  Words(
    front: 'They had a lot of fun playing games at the party.',
    back: 'Partilerde oyun oynayarak çok eğlendiler.',
    list: 'A2',
    answer: 'eğlence',
    quest: 'fun',
  ),
  Words(
    front: 'We need to buy new furniture for the living room.',
    back: 'Oturma odası için yeni mobilya almamız gerekiyor.',
    list: 'A2',
    answer: 'mobilya',
    quest: 'furniture',
  ),
  Words(
    front: 'Can you explain this concept in further detail?',
    back: 'Bu kavramı daha ayrıntılı olarak açıklayabilir misin?',
    list: 'A2',
    answer: 'daha ileri',
    quest: 'further',
  ),
  Words(
    front: 'What do you think the future holds for us?',
    back: 'Gelecek bizim için ne barındırıyor sence?',
    list: 'A2',
    answer: 'gelecek',
    quest: 'future',
  ),
  Words(
    front: 'There is a beautiful art gallery downtown.',
    back: 'Şehrin merkezinde güzel bir sanat galerisi var.',
    list: 'A2',
    answer: 'galeri',
    quest: 'gallery',
  ),
  Words(
    front: 'There is a large gap between the two buildings.',
    back: 'İki bina arasında geniş bir boşluk var.',
    list: 'A2',
    answer: 'açıklık',
    quest: 'gap',
  ),
  Words(
    front: 'My car needs gas. Can you lend me some money?',
    back: 'Arabamın benzine ihtiyacı var. Bana biraz borç verebilir misin?',
    list: 'A2',
    answer: 'benzin',
    quest: 'gas',
  ),
  Words(
    front: 'Please wait at the gate until your flight is announced.',
    back: 'Uçuşunuz anons edilene kadar lütfen gâtede bekleyin.',
    list: 'A2',
    answer: 'geçit',
    quest: 'gate',
  ),
  Words(
    front: 'The general spoke to the troops before the battle.',
    back: 'General savaştan önce askerlere konuştu.',
    list: 'A2',
    answer: 'genel',
    quest: 'general',
  ),
  Words(
    front: 'She received a beautiful scarf as a gift for her birthday.',
    back: 'Doğum günü için hediye olarak güzel bir eşarp aldı.',
    list: 'A2',
    answer: 'hediye',
    quest: 'gift',
  ),
  Words(
    front: 'My goal is to become a doctor.',
    back: 'Hedefim doktor olmaktır.',
    list: 'A2',
    answer: 'hedef',
    quest: 'goal',
  ),
  Words(
    front: 'Many people believe in God.',
    back: 'Pek çok insan Tanrı’ya inanır.',
    list: 'A2',
    answer: 'tanrı',
    quest: 'God',
  ),
  Words(
    front: 'The ring is made of pure gold.',
    back: 'Yüzük saf altından yapılmıştır.',
    list: 'A2',
    answer: 'altın',
    quest: 'gold',
  ),
  Words(
    front: 'It was a good idea to bring an umbrella. It started raining!',
    back: 'Şemsiye getirmek iyi bir fikirdi. Yağmur yağmaya başladı!',
    list: 'A2',
    answer: 'güzel',
    quest: 'good',
  ),
  Words(
    front: 'The government is responsible for making laws.',
    back: 'Hükümet, yasaları çıkarmaktan sorumludur.',
    list: 'A2',
    answer: 'hükümet',
    quest: 'government',
  ),
  Words(
    front: 'The park has a lot of green grass.',
    back: 'Parkın çok yeşilliği var.',
    list: 'A2',
    answer: 'çim',
    quest: 'grass',
  ),
  Words(
    front: 'He greeted his friend with a handshake.',
    back: 'Arkadaşını el sıkışarak selamladı.',
    list: 'A2',
    answer: 'selamlaşmak',
    quest: 'greet',
  ),
  Words(
    front: 'The building is built on solid ground.',
    back: 'Bina sağlam zemine inşa edilmiştir.',
    list: 'A2',
    answer: 'zemin',
    quest: 'ground',
  ),
  Words(
    front: 'We had some guests over for dinner last night.',
    back: 'Dün gece misafirlerimiz vardı.',
    list: 'A2',
    answer: 'misafir',
    quest: 'guest',
  ),
  Words(
    front: 'This guidebook will help you navigate the city.',
    back: 'Bu rehberlik kitabı şehirde gezinmenize yardımcı olacaktır.',
    list: 'A2',
    answer: 'rehber',
    quest: 'guide',
  ),
  Words(
    front: 'He is a law-abiding citizen and never carries a gun.',
    back: 'Kanunlara uyan bir vatandaştır ve asla silah taşımaz.',
    list: 'A2',
    answer: 'silah',
    quest: 'gun',
  ),
  Words(
    front: 'That guy over there is always telling jokes.',
    back: 'Şuradaki adam sürekli şaka yapıyor.',
    list: 'A2',
    answer: 'adam',
    quest: 'guy',
  ),
  Words(
    front: 'He has a bad habit of biting his nails.',
    back: 'Tırnaklarını ısırma gibi kötü bir alışkanlığı var.',
    list: 'A2',
    answer: 'alışkanlık',
    quest: 'habit',
  ),
  Words(
    front: 'I ate half of the sandwich.',
    back: 'Sandviçin yarısını yedim.',
    list: 'A2',
    answer: 'yarım',
    quest: 'half',
  ),
  Words(
    front: 'The school assembly was held in the main hall.',
    back: 'Okul töreni ana salonda gerçekleştirildi.',
    list: 'A2',
    answer: 'salon',
    quest: 'hall',
  ),
  Words(
    front: 'They lived happily ever after.',
    back: 'Sonrasında mutlu bir şekilde yaşadılar.',
    list: 'A2',
    answer: 'mutlu bir şekilde',
    quest: 'happily',
  ),
  Words(
    front: 'Do you have any questions?',
    back: 'Herhangi bir sorunuz var mı?',
    list: 'A2',
    answer: 'sahip olmak',
    quest: 'have',
  ),
  Words(
    front: 'I have a headache. Do you have any aspirin?',
    back: 'Başım ağrıyor. Aspirin var mı?',
    list: 'A2',
    answer: 'baş ağrısı',
    quest: 'headache',
  ),
  Words(
    front: 'Follow your heart and do what makes you happy.',
    back: 'Kalbinizi takip edin ve sizi mutlu eden şeyi yapın.',
    list: 'A2',
    answer: 'yürek, kalp',
    quest: 'heart',
  ),
  Words(
    front: "It's very hot outside today. The heat is unbearable!",
    back: 'Bugün hava çok sıcak. Sıcak dayanılmaz!',
    list: 'A2',
    answer: 'sıcaklık',
    quest: 'heat',
  ),
  Words(
    front: 'This box is too heavy for me to lift.',
    back: 'Bu kutu benim kaldırmam için çok ağır.',
    list: 'A2',
    answer: 'ağır',
    quest: 'heavy',
  ),
  Words(
    front: 'What is the height of the Eiffel Tower?',
    back: "Eiffel Kulesi'nin yüksekliği nedir?",
    list: 'A2',
    answer: 'yükseklik',
    quest: 'height',
  ),
  Words(
    front: 'He is always helpful and willing to lend a hand.',
    back: 'Her zaman yardımseverdir ve el uzatmaya hazırdır.',
    list: 'A2',
    answer: 'yardımsever',
    quest: 'helpful',
  ),
  Words(
    front: 'Superman is a popular comic book hero.',
    back: 'Süpermen, popüler bir çizgi roman kahramanıdır.',
    list: 'A2',
    answer: 'kahraman',
    quest: 'hero',
  ),
  Words(
    front: 'Is this hers?', // "Hers" is possessive pronoun, not plural of "he"
    back: 'Bu onunki mi?', // Changed to "onunki" (possessive of "o")
    list: 'A2',
    answer: 'onunki', // Changed answer to "onunki"
    quest: 'hers',
  ),
  Words(
    front: 'He tried to hide behind the tree.',
    back: 'Ağacın arkasına saklanmaya çalıştı.',
    list: 'A2',
    answer: 'saklamak',
    quest: 'hide',
  ),
  Words(
    front: 'We went for a hike up the hill yesterday.',
    back: 'Dün tepeye yürüyüşe çıktık.',
    list: 'A2',
    answer: 'tepe',
    quest: 'hill',
  ),
  Words(
    front:
        "We can't stop Tom climbing out of his cot.", // "His" is possessive pronoun
    back: "Tom'un karyolasından çıkmasını engelleyemeyiz.",
    list: 'A2',
    answer: 'onun', // Changed answer to "onun"
    quest: 'his',
  ),
  Words(
    front: 'The baseball player hit the ball out of the park.',
    back: 'Beyzbol oyuncusu topu stadyumun dışına vurdu.',
    list: 'A2',
    answer: 'vurmak',
    quest: 'hit',
  ),
  Words(
    front: 'Please hold this for a moment.',
    back: 'Lütfen bunu bir süre tutar mısın?',
    list: 'A2',
    answer: 'tutmak',
    quest: 'hold',
  ),
  Words(
    front: 'There is a big hole in the ground.',
    back: 'Yerde büyük bir çukur var.',
    list: 'A2',
    answer: 'çukur',
    quest: 'hole',
  ),
  Words(
    front: "There's no place like home.",
    back: 'Ev gibisi bir yer yoktur.',
    list: 'A2',
    answer: 'ev',
    quest: 'home',
  ),
  Words(
    front: "Don't lose hope. Things will get better.",
    back: 'Umudu kaybetme. İşler düzelecek.',
    list: 'A2',
    answer: 'umut',
    quest: 'hope',
  ),
  Words(
    front: 'The statue is huge! It must be very heavy.',
    back: 'Heykel kocaman! Çok ağır olmalı.',
    list: 'A2',
    answer: 'kocaman',
    quest: 'huge',
  ),
  Words(
    front: 'All humans are equal.',
    back: 'Tüm insanlar eşittir.',
    list: 'A2',
    answer: 'insan',
    quest: 'human',
  ),
  Words(
    front: 'My ankle hurts. I think I twisted it.',
    back: 'Bileğim ağrıyor. Sanırım burktum.',
    list: 'A2',
    answer: 'yaralamak',
    quest: 'hurt',
  ),
  Words(
    front: 'Can you identify the suspect in this photo?',
    back: 'Bu fotoğraftaki şüpheliyi tanımlayabilir misin?',
    list: 'A2',
    answer: 'tanımlamak',
    quest: 'identify',
  ),
  Words(
    front: "He's been feeling ill for a few days.",
    back: 'Birkaç gündür hasta hissediyor.',
    list: 'A2',
    answer: 'hasta',
    quest: 'ill',
  ),
  Words(
    front: "I'm taking medication for my illness.",
    back: 'Hastalığım için ilaç alıyorum.',
    list: 'A2',
    answer: 'hastalık',
    quest: 'illness',
  ),
  Words(
    front: 'The image on the screen is blurry.',
    back: 'Ekrandaki görüntü bulanık.',
    list: 'A2',
    answer: 'resim',
    quest: 'image',
  ),
  Words(
    front: 'Come here immediately! I need your help.',
    back: 'Hemen gel! Yardımına ihtiyacım var.',
    list: 'A2',
    answer: 'hemen',
    quest: 'immediately',
  ),
  Words(
    front: 'It is impossible to travel faster than the speed of light.',
    back: 'Işık hızından daha hızlı seyahat etmek imkansızdır.',
    list: 'A2',
    answer: 'imkansız',
    quest: 'impossible',
  ),
  Words(
    front: 'The price of the meal included tax and gratuity.',
    back: 'Yemeğin fiyatı vergi ve bahşişi içerir.',
    list: 'A2',
    answer: 'dahil olan',
    quest: 'included',
  ),
  Words(
    front: "The price is \$10, including tax.",
    back: 'Fiyat 10 dolar, vergi dahil.',
    list: 'A2',
    answer: 'dahil',
    quest: 'including',
  ),
  Words(
    front: 'There has been a recent increase in the cost of living.',
    back: 'Yaşam maliyetinde son zamanlarda bir artış oldu.',
    list: 'A2',
    answer: 'artış',
    quest: 'increase',
  ),
  Words(
    front: 'It is incredible that she can speak five languages fluently!',
    back: 'Beş dili akıcı bir şekilde konuşabilmesi inanılmaz!',
    list: 'A2',
    answer: 'inanılmaz',
    quest: 'incredible',
  ),
  Words(
    front: 'The United States is an independent country.',
    back: 'Amerika Birleşik Devletleri bağımsız bir ülkedir.',
    list: 'A2',
    answer: 'bağımsız',
    quest: 'independent',
  ),
  Words(
    front: 'He is a very individual person who likes to do things his own way.',
    back: 'Kendi yöntemiyle işleri yapmayı seven çok bireysel bir insan.',
    list: 'A2',
    answer: 'bireysel',
    quest: 'individual',
  ),
  Words(
    front: 'The car industry is one of the largest in the world.',
    back: 'Otomobil endüstrisi dünyanın en büyüklerinden biridir.',
    list: 'A2',
    answer: 'endüstri',
    quest: 'industry',
  ),
  Words(
    front: 'We had a very informal chat about the weather.',
    back: 'Hava durumu hakkında çok gayri resmi bir sohbet yaptık.',
    list: 'A2',
    answer: 'resmi olmayan',
    quest: 'informal',
  ),
  Words(
    front: 'He suffered a serious injury to his leg in the accident.',
    back: 'Kazada bacağından ciddi bir şekilde yaralandı.',
    list: 'A2',
    answer: 'zarar',
    quest: 'injury',
  ),
  Words(
    front: 'There are many different insects in the garden.',
    back: 'Bahçede birçok farklı böcek var.',
    list: 'A2',
    answer: 'böcek',
    quest: 'insect',
  ),
  Words(
    front: 'Please stay inside until the storm passes.',
    back: 'Fırtına geçene kadar lütfen içeride kalın.',
    list: 'A2',
    answer: 'içeride',
    quest: 'inside',
  ),
  Words(
    front: 'I would like some coffee instead of tea.',
    back: 'Çay yerine kahve almak isterdim.',
    list: 'A2',
    answer: 'yerine',
    quest: 'instead',
  ),
  Words(
    front: 'Please follow these instructions carefully.',
    back: 'Lütfen bu talimatları dikkatlice takip edin.',
    list: 'A2',
    answer: 'yönerge',
    quest: 'instruction',
  ),
  Words(
    front: 'He is a qualified yoga instructor.',
    back: 'Kalifiye bir yoga eğitmenidir.',
    list: 'A2',
    answer: 'eğitmen',
    quest: 'instructor',
  ),
  Words(
    front: 'The guitar is a popular musical instrument.',
    back: 'Gitar popüler bir müzik enstrümanıdır.',
    list: 'A2',
    answer: 'enstrüman',
    quest: 'instrument',
  ),
  Words(
    front: 'He is a very intelligent student who always gets good grades.',
    back: 'Her zaman iyi notlar alan çok zeki bir öğrencidir.',
    list: 'A2',
    answer: 'zeki',
    quest: 'intelligent',
  ),
  Words(
    front:
        'This is an international competition that is open to athletes from all over the world.',
    back:
        'Bu, dünyanın her yerinden sporculara açık uluslararası bir yarışmadır.',
    list: 'A2',
    answer: 'uluslararası',
    quest: 'international',
  ),
  Words(
    front: 'The speaker gave a brief introduction to the topic.',
    back: 'Konuşmacı konuya kısa bir giriş yaptı.',
    list: 'A2',
    answer: 'tanıtım',
    quest: 'introduction',
  ),
  Words(
    front: 'Thomas Edison invented the light bulb.',
    back: 'Thomas Edison ampulü icat etti.',
    list: 'A2',
    answer: 'icat etmek',
    quest: 'invent',
  ),
  Words(
    front: 'The airplane is one of the greatest inventions of all time.',
    back: 'Uçak, tüm zamanların en büyük buluşlarından biridir.',
    list: 'A2',
    answer: 'buluş',
    quest: 'invention',
  ),
  Words(
    front: 'I would like to thank you for the invitation to your party.',
    back: 'Partinize davetiyeniz için teşekkür ederim.',
    list: 'A2',
    answer: 'davetiye',
    quest: 'invitation',
  ),
  Words(
    front: 'Can I invite you to join us for dinner tonight?',
    back: 'Bu akşam yemeğe bize katılmaya davet edebilir miyim?',
    list: 'A2',
    answer: 'davet etmek',
    quest: 'invite',
  ),
  Words(
    front: 'This project will involve a lot of research and development.',
    back: 'Bu projede çok fazla araştırma ve geliştirme yer alacak.',
    list: 'A2',
    answer: 'içermek',
    quest: 'involve',
  ),
  Words(
    front: 'The next item on the agenda is the budget proposal.',
    back: 'Gündemdeki bir sonraki madde bütçe teklifidir.',
    list: 'A2',
    answer: 'madde',
    quest: 'item',
  ),
  Words(
    front: 'The cat can lick itself clean.',
    back: 'Kedi kendini temizleyebilir.',
    list: 'A2',
    answer: 'kendisi',
    quest: 'itself',
  ),
  Words(
    front: 'We are stuck in a traffic jam on the highway.',
    back: 'Otobanda bir sıkışıklıkta kaldık.',
    list: 'A2',
    answer: 'sıkışıklık, reçel',
    quest: 'jam',
  ),
  Words(
    front: 'Do you like jazz music?',
    back: 'Caz müziğini sever misin?',
    list: 'A2',
    answer: 'caz',
    quest: 'jazz',
  ),
  Words(
    front: 'She is wearing a beautiful diamond jewellery.',
    back: 'Üzerinde güzel bir elmas mücevheratı var.',
    list: 'A2',
    answer: 'mücevherat',
    quest: 'jewellery',
  ),
  Words(
    front: 'He told a funny joke that made everyone laugh.',
    back: 'Herkesi güldüren komik bir şaka yaptı.',
    list: 'A2',
    answer: 'şaka',
    quest: 'joke',
  ),
  Words(
    front: 'She is a journalist who writes for a major newspaper.',
    back: 'Önde gelen bir gazetede yazan bir gazetecidir.',
    list: 'A2',
    answer: 'gazeteci',
    quest: 'journalist',
  ),
  Words(
    front:
        'The little boy jumped on the trampoline.', // "Atlamak" already exists for "jump"
    back: 'Küçük çocuk trampolinde zıplıyordu.',
    list: 'A2',
    answer: 'zıplamak', // Changed answer to "zıplamak" to avoid duplicates
    quest: 'jump',
  ),
  Words(
    front: 'The teacher asked the kids to be quiet.',
    back: 'Öğretmen çocuklardan sessiz olmalarını istedi.',
    list: 'A2',
    answer: 'çocuk',
    quest: 'kid',
  ),

  Words(
    front: 'The king ruled the country for many years.',
    back: 'Kral ülkeyi uzun yıllar yönetti.',
    list: 'A2',
    answer: 'kral',
    quest: 'king',
  ),
  Words(
    front: 'He hurt his knee while playing football.',
    back: 'Futbol oynarken dizini incitti.',
    list: 'A2',
    answer: 'diz',
    quest: 'knee',
  ),
  Words(
    front: 'The chef used a sharp knife to cut the vegetables.',
    back: 'Şef sebzeleri kesmek için keskin bir bıçak kullandı.',
    list: 'A2',
    answer: 'bıçak',
    quest: 'knife',
  ),
  Words(
    front: 'Did you hear someone knock on the door?',
    back: 'Kapıya birinin vurduğunu duydun mu?',
    list: 'A2',
    answer: 'kapı çalmak',
    quest: 'knock',
  ),
  Words(
    front: 'Reading books can help you gain knowledge.',
    back: 'Kitap okumak bilgi edinmenize yardımcı olabilir.',
    list: 'A2',
    answer: 'bilgi',
    quest: 'knowledge',
  ),
  Words(
    front: 'The scientists are conducting experiments in the lab.',
    back: 'Bilim adamları laboratuvarda deneyler yapıyor.',
    list: 'A2',
    answer: 'laboratuvar',
    quest: 'lab',
  ),
  Words(
    front: 'The kind lady offered to help me with my groceries.',
    back:
        'Nazik hanımefendi market alışverişimde bana yardım etmeyi teklif etti.',
    list: 'A2',
    answer: 'hanımefendi',
    quest: 'lady',
  ),
  Words(
    front: 'We went for a swim in the lake on a hot summer day.',
    back: 'Sıcak bir yaz gününde gölde yüzdük.',
    list: 'A2',
    answer: 'göl',
    quest: 'lake',
  ),
  Words(
    front: 'I turned on the lamp because it was getting dark.',
    back: ' hava karardığı için lambayı açtım.',
    list: 'A2',
    answer: 'lamba',
    quest: 'lamp',
  ),
  Words(
    front: 'We are planning to visit that beautiful island next summer.',
    back: 'Önümüzdeki yaz o güzel adayı ziyaret etmeyi planlıyoruz.',
    list: 'A2',
    answer: 'ada',
    quest: 'island',
  ),
  Words(
    front: 'He was the last person to arrive at the party.',
    back: 'Partiye gelen son kişi oydu.',
    list: 'A2',
    answer: 'sonuncu',
    quest: 'last',
  ),
  Words(
    front: 'I will see you later this evening.',
    back: 'Bu akşamın ilerleyen saatlerinde görüşürüz.',
    list: 'A2',
    answer: 'sonra',
    quest: 'later',
  ),
  Words(
    front: 'The sound of their laughter filled the room.',
    back: 'Kahkahaları odayı doldurdu.',
    list: 'A2',
    answer: 'kahkaha',
    quest: 'laughter',
  ),
  Words(
    front: 'Stealing is against the law.',
    back: 'Hırsızlık yasaya karşıdır.',
    list: 'A2',
    answer: 'yasa',
    quest: 'law',
  ),
  Words(
    front: 'He hired a lawyer to represent him in court.',
    back: 'Mahkemede kendisini temsil etmesi için bir avukat tuttu.',
    list: 'A2',
    answer: 'avukat',
    quest: 'lawyer',
  ),
  Words(
    front: 'He doesn\'t want to do any chores because he is lazy.',
    back: 'Tembel olduğu için hiçbir iş yapmak istemiyor.',
    list: 'A2',
    answer: 'tembel',
    quest: 'lazy',
  ),
  Words(
    front: 'The teacher can guide the students in their learning.',
    back: 'Öğretmen, öğrencilere öğrenmelerinde rehberlik edebilir.',
    list: 'A2',
    answer: 'rehberlik etmek',
    quest: 'lead',
  ),
  Words(
    front: 'Martin Luther King Jr. was a civil rights leader.',
    back: 'Martin Luther King Jr. bir insan hakları lideriydi.',
    list: 'A2',
    answer: 'lider',
    quest: 'leader',
  ),
  Words(
    front:
        'Learning a new language can be a challenging but rewarding experience.',
    back: 'Yeni bir dil öğrenmek zorlu ama ödüllendirici bir deneyim olabilir.',
    list: 'A2',
    answer: 'öğrenme',
    quest: 'Learning',
  ),
  Words(
    front: 'At least you tried your best.',
    back: 'En azından elinden gelenin en iyisini yaptın.',
    list: 'A2',
    answer: 'en az',
    quest: 'least',
  ),
  Words(
    front: 'The professor gave a lecture on the history of the Ottoman Empire.',
    back: 'Profesör, Osmanlı İmparatorluğu tarihi hakkında ders anlattı.',
    list: 'A2',
    answer: 'ders anlatmak',
    quest: 'lecture',
  ),
  Words(
    front: 'I would like to add some lemon juice to my fish.',
    back: 'Balığıma biraz limon suyu eklemek isterim.',
    list: 'A2',
    answer: 'limon',
    quest: 'lemon',
  ),
  Words(
    front: 'Can you lend me some money?',
    back: 'Bana biraz para ödünç verebilir misin?',
    list: 'A2',
    answer: 'ödünç vermek',
    quest: 'lend',
  ),
  Words(
    front: 'I have less homework today than yesterday.',
    back: 'Bugün dünden daha az ödevim var.',
    list: 'A2',
    answer: 'daha az',
    quest: 'less',
  ),
  Words(
    front:
        'He is a beginner English learner, so his level is not very high yet.',
    back:
        'Yeni başlayan bir İngilizce öğrencisi, bu yüzden seviyesi henüz çok yüksek değil.',
    list: 'A2',
    answer: 'seviye',
    quest: 'level',
  ),
  Words(
    front:
        'Living a healthy lifestyle can help you feel better and have more energy.',
    back:
        'Sağlıklı bir yaşam tarzı sürmek, kendinizi daha iyi hissetmenize ve daha fazla enerjiye sahip olmanıza yardımcı olabilir.',
    list: 'A2',
    answer: 'yaşam tarzı',
    quest: 'lifestyle',
  ),
  Words(
    front: 'Can you help me lift this heavy box?',
    back: 'Bu ağır kutuyu kaldırmama yardım edebilir misin?',
    list: 'A2',
    answer: 'kaldırmak',
    quest: 'lift',
  ),
  Words(
    front: 'Please turn off the light when you leave the room.',
    back: 'Odadan çıkarken ışığı kapatın lütfen.',
    list: 'A2',
    answer: 'ışık',
    quest: 'light',
  ),
  Words(
    front: 'It is likely to rain tomorrow, so bring an umbrella.',
    back: 'Yarın yağmur yağma ihtimali yüksek, o yüzden şemsiye getir.',
    list: 'A2',
    answer: 'büyük ihtimalle',
    quest: 'likely',
  ),
  Words(
    front:
        'The teacher provided a link to the article in the online classroom.',
    back: 'Öğretmen, çevrimiçi sınıftaki makaleye bir bağlantı sağladı.',
    list: 'A2',
    answer: 'bağlantı',
    quest: 'link',
  ),
  Words(
    front: 'The speaker had a large audience of listeners.',
    back: 'Konuşmacının çok sayıda dinleyicisi vardı.',
    list: 'A2',
    answer: 'dinleyici',
    quest: 'listener',
  ),
  Words(
    front: 'The little girl was playing with her little brother.',
    back: 'Küçük kız, küçük erkek kardeşiyle oynuyordu.',
    list: 'A2',
    answer: 'küçük',
    quest: 'little',
  ),
  Words(
    front: 'Please lock the door before you go to bed.',
    back: 'Yatağa gitmeden önce kapıyı kilitleyin lütfen.',
    list: 'A2',
    answer: 'kilit',
    quest: 'lock',
  ),
  Words(
    front: 'Look at this beautiful view!',
    back: 'Bu güzel manzaraya bak!',
    list: 'A2',
    answer: 'bakmak',
    quest: 'Look',
  ),
  Words(
    front: 'The lorry driver was delivering furniture to a house.',
    back: 'Kamyon şoförü bir eve mobilya taşıyordu.',
    list: 'A2',
    answer: 'kamyon',
    quest: 'lorry',
  ),
  Words(
    front: 'Have you seen my lost keys anywhere?',
    back: 'Kayıp anahtarlarımı herhangi bir yerde gördün mü?',
    list: 'A2',
    answer: 'kayıp',
    quest: 'lost',
  ),
  Words(
    front: 'The music was so loud that we couldn\'t hear each other speak.',
    back:
        'Müzik o kadar yüksek sesliydi ki birbirimizi konuşurken duyamıyorduk.',
    list: 'A2',
    answer: 'yüksek ses',
    quest: 'loud',
  ),
  Words(
    front: 'The children were playing loudly in the garden.',
    back: 'Çocuklar bahçede gürültülü bir şekilde oynuyorlardı.',
    list: 'A2',
    answer: 'gürültülü',
    quest: 'loudly',
  ),
  Words(
    front: 'She has a lovely smile.',
    back: 'Güzel, sevimli bir gülüşü var.',
    list: 'A2',
    answer: 'güzel, sevimli',
    quest: 'lovely',
  ),
  Words(
    front: 'The battery level is low, so I need to charge my phone.',
    back: 'Pil seviyesi düşük, bu yüzden telefonumu şarj etmem gerekiyor.',
    list: 'A2',
    answer: 'düşük',
    quest: 'low',
  ),
  Words(
    front: 'I wish you good luck on your exam!',
    back: 'Sınavında şans diliyorum!',
    list: 'A2',
    answer: 'şans',
    quest: 'luck',
  ),
  Words(
    front: 'He is a very lucky person; he always wins raffles.',
    back: 'Çok şanslı biri; her zaman çekilişleri kazanıyor.',
    list: 'A2',
    answer: 'şanslı',
    quest: 'lucky',
  ),
  Words(
    front: 'I am expecting an important mail from my bank.',
    back: 'Bankamdan önemli bir posta bekliyorum.',
    list: 'A2',
    answer: 'posta',
    quest: 'mail',
  ),
  Words(
    front: 'The company is a major player in the technology industry.',
    back: 'Şirket, teknoloji sektöründe önemli bir aktördür.',
    list: 'A2',
    answer: 'asıl, başlıca',
    quest: 'major',
  ),
  Words(
    front: 'Most of the students in this class are male.',
    back: 'Bu sınıftaki öğrencilerin çoğu erkek.',
    list: 'A2',
    answer: 'erkek',
    quest: 'male',
  ),
  Words(
    front: 'She is a successful businesswoman who manages her own company.',
    back: 'Kendi şirketini yöneten başarılı bir iş kadınıdır.',
    list: 'A2',
    answer: 'işletmek',
    quest: 'manage',
  ),
  Words(
    front: 'The manager was very rude in his manner towards the customer.',
    back: 'Yönetici, müşteriye karşı tavır olarak çok kaba davrandı.',
    list: 'A2',
    answer: 'tavır, tutum',
    quest: 'manner',
  ),
  Words(
    front: 'The teacher put a mark next to the wrong answer.',
    back: 'Öğretmen, yanlış cevap yanına bir işaret koydu.',
    list: 'A2',
    answer: 'iz, işaret',
    quest: 'mark',
  ),
  Words(
    front: 'They are planning to get marry/ied next year.',
    back: 'Önümüzdeki sene evlenmeyi planlıyorlar.',
    list: 'A2',
    answer: 'evlenmek',
    quest: 'marry',
  ),
  Words(
    front: 'We need more materials to finish this project.',
    back: 'Bu projeyi bitirmek için daha fazla malzemeye ihtiyacımız var.',
    list: 'A2',
    answer: 'malzeme',
    quest: 'material',
  ),
  Words(
    front: 'I am not very good at maths, but I am good at English.',
    back: 'Matematikte pek iyi değilim, ama İngilizcede iyiyim.',
    list: 'A2',
    answer: 'matematik',
    quest: 'maths',
  ),
  Words(
    front: 'Does it matter if I am a few minutes late?',
    back: 'Birkaç dakika geç kalırsam sorun mu var?',
    list: 'A2',
    answer: 'konu, önemli olmak',
    quest: 'matter',
  ),
  Words(
    front: 'May is the fifth month of the year.',
    back: 'Mayıs, yılın beşinci ayıdır.',
    list: 'A2',
    answer: 'Mayıs',
    quest: 'May',
  ),
  Words(
    front: 'Do you need to take any medicine for your cold?',
    back: 'Soğuk algınlığı için herhangi bir ilaç almanız gerekiyor mu?',
    list: 'A2',
    answer: 'ilaç',
    quest: 'medicine',
  ),
  Words(
    front: 'He has a very good memory and can remember things easily.',
    back: 'Çok iyi bir hafızası var ve şeyleri kolayca hatırlayabiliyor.',
    list: 'A2',
    answer: 'hafıza',
    quest: 'memory',
  ),
  Words(
    front:
        'The teacher didn\'t mention the homework assignment in class today.',
    back: 'Öğretmen bugün sınıfta ödev ödevinden bahsetmedi.',
    list: 'A2',
    answer: 'bahsetmek',
    quest: 'mention',
  ),
  Words(
    front: 'We are standing in the middle of the street.',
    back: 'Sokağın ortasında duruyoruz.',
    list: 'A2',
    answer: 'orta kısım',
    quest: 'middle',
  ),
  Words(
    front: 'There is a might chance that it will rain tomorrow.',
    back:
        'Yarın yağmur yağma ihtimali var.', // "büyük ihtimalle" can also be used here
    list: 'A2',
    answer: 'kuvvet',
    quest: 'might',
  ),
  Words(
    front: 'Try to clear your mind and focus on the task at hand.',
    back: 'Zihnini temizlemeye ve elinizdeki işe odaklanmaya çalışın.',
    list: 'A2',
    answer: 'zihin',
    quest: 'mind',
  ),
  Words(
    front: 'Coal is a fossil fuel that is mined from the ground.',
    back: 'Kömür, yerden çıkarılan fosil bir yakıttır.',
    list: 'A2',
    answer: 'maden',
    quest: 'mine',
  ),
  Words(
    front: 'I can see my reflection in the mirror.',
    back: 'Yansımamı aynada görebiliyorum.',
    list: 'A2',
    answer: 'ayna',
    quest: 'mirror',
  ),
  Words(
    front: 'I am missing my family while I am studying abroad.',
    back: 'Yurt dışında okurken ailemi özlüyorum.',
    list: 'A2',
    answer: 'özlemek',
    quest: 'missing',
  ),
  Words(
    front:
        'Monkeys are intelligent animals that can be found in many parts of the world.',
    back: 'Maymunlar, dünyanın birçok yerinde bulunabilen zeki hayvanlardır.',
    list: 'A2',
    answer: 'maymun',
    quest: 'Monkey',
  ),
  Words(
    front: 'The moon is a natural satellite of the Earth.',
    back: 'Ay, Dünya\'nın doğal uydusudur.',
    list: 'A2',
    answer: 'ay',
    quest: 'moon',
  ),
  Words(
    front: 'He mostly speaks English, but he also knows some French.',
    back: 'Çoğunlukla İngilizce konuşuyor, ama biraz da Fransızca biliyor.',
    list: 'A2',
    answer: 'çoğunlukla',
    quest: 'mostly',
  ),
  Words(
    front:
        'There was very little movement on the road because of the heavy traffic.',
    back: 'Yoğun trafik nedeniyle yolda çok az hareket vardı.',
    list: 'A2',
    answer: 'hareket',
    quest: 'movement',
  ),
  Words(
    front: 'She is a talented musician who plays the piano beautifully.',
    back: 'Piyano çalan yetenekli bir müzisyendir.',
    list: 'A2',
    answer: 'müzisyen',
    quest: 'musician',
  ),
  Words(
    front: 'I can do it myself, I don\'t need your help.',
    back: 'Kendim yapabilirim, yardımına ihtiyacım yok.',
    list: 'A2',
    answer: 'kendim',
    quest: 'myself',
  ),
  Words(
    front: 'The street was too narrow for two cars to pass each other.',
    back: 'Sokak, iki arabanın yan yana geçmesi için çok dardı.',
    list: 'A2',
    answer: 'dar',
    quest: 'narrow',
  ),
  Words(
    front: 'The national flag of Turkey is red and white.',
    back: "Türkiye'nin milli bayrağı kırmızı ve beyazdır.",
    list: 'A2',
    answer: 'ulusal',
    quest: 'national',
  ),
  Words(
    front: 'We should spend more time in nature.',
    back: 'Doğada daha fazla zaman geçirmeliyiz.',
    list: 'A2',
    answer: 'doğa',
    quest: 'nature',
  ),
  Words(
    front: 'I was nearly late for work this morning.',
    back: 'Bu sabah işe neredeyse geç kalıyordum.',
    list: 'A2',
    answer: 'neredeyse',
    quest: 'nearly',
  ),
  Words(
    front: 'Is it necessary to bring an umbrella today?',
    back: 'Bugün şemsiye getirmek gerekli mi?',
    list: 'A2',
    answer: 'gereken',
    quest: 'necessary',
  ),
  Words(
    front: 'She was wearing a scarf around her neck.',
    back: 'Boynuna bir eşarp takmıştı.',
    list: 'A2',
    answer: 'boyun',
    quest: 'neck',
  ),
  Words(
    front: "I don't need a lot of money to be happy.",
    back: 'Mutlu olmak için çok fazla paraya ihtiyacım yok.',
    list: 'A2',
    answer: 'ihiyaç',
    quest: 'need',
  ),
  Words(
    front: 'I don\'t want to go swimming, and neither does she.',
    back: 'Yüzmeye gitmek istemiyorum, o da istemiyor.',
    list: 'A2',
    answer: 'hiçbiri',
    quest: 'neither',
  ),
  Words(
    front: 'She felt a bit nervous before giving her presentation.',
    back: 'Sunumunu yapmadan önce biraz gergin hissetti.',
    list: 'A2',
    answer: 'gergin',
    quest: 'nervous',
  ),
  Words(
    front: "My phone can't connect to the network in this remote area.",
    back: 'Telefonum bu ıssız bölgede ağa bağlanamıyor.',
    list: 'A2',
    answer: 'ağ',
    quest: 'network',
  ),
  Words(
    front: 'The loud noise from the traffic woke me up this morning.',
    back: 'Yüksek sesli trafik gürültüsü beni bu sabah uyandırdı.',
    list: 'A2',
    answer: 'ses',
    quest: 'noise',
  ),
  Words(
    front: 'The construction site next door is very noisy.',
    back: 'Yandaki inşaat şantiyesi çok gürültülü.',
    list: 'A2',
    answer: 'gürültücü',
    quest: 'noisy',
  ),
  Words(
    front: "I don't have none of my keys. I must have lost them.",
    back: 'Hiçbir anahtarım yok. Kaybetmiş olmalıyım.',
    list: 'A2',
    answer: 'hiçbiri',
    quest: 'none',
  ),
  Words(
    front: 'Did you notice the new restaurant that opened on Main Street?',
    back: "Ana Cadde'de açılan yeni restoranı fark ettin mi?",
    list: 'A2',
    answer: 'duyuru',
    quest: 'notice',
  ),
  Words(
    front: 'Did you notice the new restaurant that opened on Main Street?',
    back: "Ana Cadde'de açılan yeni restoranı fark ettin mi?",
    list: 'A2',
    answer: 'duyuru',
    quest: 'notice',
  ),
  Words(
    front: 'I am reading an interesting novel by a famous author.',
    back: 'Ünlü bir yazarın yazdığı ilginç bir roman okuyorum.',
    list: 'A2',
    answer: 'roman',
    quest: 'novel',
  ),
  Words(
    front: "I can't find my phone anywhere. It must be nowhere to be found.",
    back: 'Telefonumu hiçbir yerde bulamıyorum. Herhalde kaybolmuştur.',
    list: 'A2',
    answer: 'hiçbir yer',
    quest: 'nowhere',
  ),
  Words(
    front: 'Are these peanuts or cashews?',
    back: 'Bunlar fıstık mı yoksa kaju mu?',
    list: 'A2',
    answer: 'fıstık',
    quest: 'peanut',
  ),
  Words(
    front: 'The Pacific Ocean is the largest ocean in the world.',
    back: 'Pasifik Okyanusu, dünyanın en büyük okyanusudur.',
    list: 'A2',
    answer: 'okyanus',
    quest: 'ocean',
  ),
  Words(
    front: 'The company offered me a job, but I declined.',
    back: 'Şirket bana bir iş teklif etti, ama reddettim.',
    list: 'A2',
    answer: 'teklif vermek',
    quest: 'offer',
  ),
  Words(
    front: 'The police officer asked me for my identification.',
    back: 'Memur benden kimliğimi istedi.',
    list: 'A2',
    answer: 'memur',
    quest: 'officer',
  ),
  Words(
      front: 'I need a pen to write letter.',
      back: 'Bir mektup yazmak için kaleme ihtiyacım var.',
      list: 'A1',
      answer: 'bir',
      quest: 'a'),
  Words(
      front: "I'm reading a book about history",
      back: 'Tarih hakkında bir kitap okuyorum',
      list: 'A1',
      answer: 'hakkında',
      quest: 'about'),
  Words(
      front: 'The painting is above the fireplace.',
      back: 'Tablo şöminenin üzerindedir',
      list: 'A1',
      answer: 'yukarıda',
      quest: 'above'),
  Words(
      front: "I'm afraid of the dark",
      back: 'Karanlıktan korkuyorum',
      list: 'A1',
      answer: 'korkmuş',
      quest: 'afraid'),
  Words(
      front: "We'll have lunch after the meeting.",
      back: 'Toplantıdan sonra öğle yemeği yiyeceğiz',
      list: 'A1',
      answer: 'sonra',
      quest: 'after'),
  Words(
      front: 'What is your age?',
      back: 'Kaç yaşındasın?',
      list: 'A1',
      answer: 'yaş',
      quest: 'age'),
  Words(
      front: 'She ate all the cookies',
      back: 'O, tüm kurabiyeleri yedi.',
      list: 'A1',
      answer: 'hepsi,tümü',
      quest: 'all'),
  Words(
      front: "I'll call you later to make sure everything is all right",
      back:
          'Her şeyin yolunda olduğundan emin olmak için seni daha sonra arayacağım.',
      list: 'A1',
      answer: 'elbette, yolunda, güvende',
      quest: 'all right'),
  Words(
      front: 'We took a walk along the beach.',
      back: 'Plaj boyunca yürüyüşe çıktık.',
      list: 'A1',
      answer: 'boyunca',
      quest: 'along'),
  Words(
      front: 'She always arrives on time.',
      back: 'O her zaman zamanında gelir',
      list: 'A1',
      answer: 'her zaman',
      quest: 'always'),
  Words(
      front: "I'd like to try another flavor.",
      back: 'Başka bir tat denemek isterim.',
      list: 'A1',
      answer: 'başka',
      quest: 'another'),
  Words(
      front: 'Do you have any questions?',
      back: 'Herhangi bir sorun var mı?',
      list: 'A1',
      answer: 'herhangi',
      quest: 'any'),
  Words(
      front: 'I downloaded a new app for learning languages',
      back: 'Yeni bir dil öğrenme uygulaması indirdim.',
      list: 'A1',
      answer: 'uygulama',
      quest: 'app'),
  Words(
      front: 'We walked around the city to explore.',
      back: 'Şehri keşfetmek için etrafta yürüdük.',
      list: 'A1',
      answer: 'etrafında',
      quest: 'around'),
  Words(
      front: 'She fell asleep while reading a book.',
      back: 'Kitap okurken uyuyakaldı',
      list: 'A1',
      answer: 'uyuyan',
      quest: 'asleep'),
  Words(
      front: 'She is good at playing the piano',
      back: 'Piyano çalmada iyidir.',
      list: 'A1',
      answer: 'üzere, üzerinde',
      quest: 'at'),
  Words(
      front: 'My aunt is coming to visit us next weekend.',
      back: 'Teyzem, önümüzdeki hafta sonu bizi ziyarete gelecek',
      list: 'A1',
      answer: 'teyze-hala',
      quest: 'aunt'),
  Words(
      front: 'I am usually awake by 7 AM.',
      back: "Ben genellikle saat 7'de uyanığım.",
      list: 'A1',
      answer: 'uyanmak',
      quest: 'awake'),
  Words(
      front: "He'll be back in an hour.",
      back: 'Bir saat içinde geri dönecek',
      list: 'A1',
      answer: 'arka , dönmek',
      quest: 'back'),
  Words(
      front: 'The weather is bad today',
      back: 'Bugün hava kötü.',
      list: 'A1',
      answer: 'kötü',
      quest: 'bad'),
  Words(
      front: 'He performed badly in the exam.',
      back: 'Sınavda kötü bir performans sergiledi',
      list: 'A1',
      answer: 'kötü bir şekilde',
      quest: 'badly'),
  Words(
      front: 'I know you had exams last week.',
      back: 'Geçen hafta sınavların olduğunu biliyorum.',
      list: 'A1',
      answer: 'sınav',
      quest: 'exam'),
  Words(
      front: 'The washing machine is in the basement.',
      back: 'Çamaşır makinesi bodrum katında.',
      list: 'A1',
      answer: 'bodrum',
      quest: 'basement'),
  Words(
      front: 'Bats are nocturnal creatures.',
      back: 'Yarasalar gececi yaratıklardır',
      list: 'A1',
      answer: 'yarasa',
      quest: 'Bat'),
  Words(
      front: "The new restaurant will be called 'Sunset Bistro'.",
      back: "Yeni restoran 'Günbatımı Bistro' adını alacak",
      list: 'A1',
      answer: 'çağırılmak, adı verilmek',
      quest: 'be called'),
  Words(
      front: 'The man with the long beard smiled at the children',
      back: 'Uzun sakallı adam çocuklara gülümsedi.',
      list: 'A1',
      answer: 'sakal',
      quest: 'beard'),
  Words(
      front: "I am wearing a jacket because it's cold outside",
      back: 'Arabası bozulduğu için o geç kaldı',
      list: 'A1',
      answer: 'çünkü',
      quest: 'because'),
  Words(
      front: 'Please finish your homework before dinner',
      back: 'Lütfen akşam yemeğinden önce ödevini bitir.',
      list: 'A1',
      answer: 'önce',
      quest: 'before'),
  Words(
      front: 'The temperature is below freezing.',
      back: 'Sıcaklık donma noktasının altında.',
      list: 'A1',
      answer: 'alttaki',
      quest: 'below'),
  Words(
      front: "This is the best movie I've ever seen",
      back: 'Bu, şimdiye kadar gördüğüm en iyi film',
      list: 'A1',
      answer: 'en iyi',
      quest: 'best'),
  Words(
      front: 'I hope you feel better soon',
      back: 'Umarım yakında kendini daha iyi hissedersin.',
      list: 'A1',
      answer: 'daha iyi',
      quest: 'better'),
  Words(
      front: 'She curled up on the couch with a soft blanket',
      back: 'Yumuşak bir battaniye ile kanepeye kıvrıldı.',
      list: 'A1',
      answer: 'battaniye',
      quest: 'blanket'),
  Words(
      front: 'The little girl had beautiful blonde hair',
      back: 'Küçük kızın güzel sarı saçları vardı',
      list: 'A1',
      answer: 'sarışın',
      quest: 'blonde'),
  Words(
      front: 'The movie was boring, and I fell asleep',
      back: 'Film sıkıcıydı ve ben uyudum',
      list: 'A1',
      answer: 'sıkılmak',
      quest: 'boring'),
  Words(
      front: 'They both enjoy hiking in the mountains.',
      back: 'İkisi de dağlarda yürüyüş yapmaktan keyif alıyor.',
      list: 'A1',
      answer: 'her ikisi de',
      quest: 'both'),
  Words(
      front: 'I bought a bottle of water at the store',
      back: 'Mağazadan bir şişe su satın aldım.',
      list: 'A1',
      answer: 'şişe',
      quest: 'bottle'),
  Words(
      front: 'The keys are at the bottom of the drawer.',
      back: 'Anahtarlar çekmecenin altında.',
      list: 'A1',
      answer: 'alt',
      quest: 'bottom'),
  Words(
      front: 'She ate her soup from a colorful bowl',
      back: 'Çorbasını renkli bir kaseden yedi.',
      list: 'A1',
      answer: 'kase,çanak',
      quest: 'bowl'),
  Words(
      front: 'The little boy felt brave when he climbed the tree',
      back: 'Küçük çocuk, ağaca tırmandığında cesaret buldu',
      list: 'A1',
      answer: 'cesur',
      quest: 'brave'),
  Words(
      front: "Let's take a break and have some snacks.",
      back: 'Mola verelim ve atıştırmalık bir şeyler yiyelim.',
      list: 'A1',
      answer: 'mola',
      quest: 'break'),
  Words(
      front: "Your idea is brilliant!",
      back: "Fikrin muhteşem!",
      list: "A1",
      answer: "muhteşem",
      quest: "brilliant"),
  Words(
      front: 'Can you bring me a glass of water, please?',
      back: 'Bana bir bardak su getirebilir misin, lütfen?',
      list: 'A1',
      answer: 'getirmek',
      quest: 'bring'),
  Words(
      front: 'They decided to build a new house.',
      back: 'Yeni bir ev inşa etmeye karar verdiler',
      list: 'A1',
      answer: 'inşa etmek',
      quest: 'build'),
  Words(
      front: "We'll meet at the bus station at 3 PM.",
      back: "Saat 15.00'te otogarda buluşacağız.",
      list: 'A1',
      answer: 'otobüs durağı',
      quest: 'bus station'),
  Words(
      front: "Wait for me at the bus stop, and we'll go together.",
      back: 'Beni durakta bekle, birlikte gideceğiz.',
      list: 'A1',
      answer: 'durak',
      quest: 'bus stop'),
  Words(
      front: "I can't talk right now; I'm too busy at work.",
      back: 'Şu an konuşamam, işte çok meşgulüm.',
      list: 'A1',
      answer: 'meşgul',
      quest: 'busy'),
  Words(
      front: 'They are planning to buy a new car next month',
      back: 'Onlar, gelecek ay yeni bir araba almaya plan yapıyorlar.',
      list: 'A1',
      answer: 'satın almak',
      quest: 'buy'),
  Words(
      front: 'I will finish the report by tomorrow',
      back: 'Raporu yarına kadar tamamlayacağım',
      list: 'A1',
      answer: 'ikincil mesele',
      quest: 'by'),
  Words(
      front: 'We built a cage for our pet rabbit to keep it safe',
      back:
          'Evimizdeki evcil tavşanımız için onu güvende tutmak için bir kafes yaptık.',
      list: 'A1',
      answer: 'kafes',
      quest: 'cage'),
  Words(
      front: 'Please call the doctor if you feel unwell',
      back: 'Eğer kendinizi iyi hissetmiyorsanız, lütfen doktoru arayın.',
      list: 'A1',
      answer: 'çağırmak',
      quest: 'call'),
  Words(
      front: 'The shopping center has a large car park for visitors',
      back: 'Alışveriş merkezinin ziyaretçiler için büyük bir otoparkı var.',
      list: 'A1',
      answer: 'otopark',
      quest: 'car park'),
  Words(
      front: "The doctor carefully listened to the patient's symptoms.",
      back: 'Doktor hastanın semptomlarını dikkatlice dinledi.',
      list: 'A1',
      answer: 'dikkatli',
      quest: 'careful'),
  Words(
      front: 'I always carry my phone with me.',
      back: 'Telefonumu her zaman yanımda taşırım.',
      list: 'A1',
      answer: 'taşımak',
      quest: 'carry'),
  Words(
      front: 'I tried to catch the ball, but I missed',
      back: ' Topu yakalamaya çalıştım ama kaçırdım.',
      list: 'A1',
      answer: 'yakalama',
      quest: 'catch'),
  Words(
      front: 'The city center is filled with historical buildings.',
      back: 'Şehrin merkezi tarihi binalarla doludur.',
      list: 'A1',
      answer: 'merkez',
      quest: 'center'),
  Words(
      front: 'The weather changed suddenly from sunny to rainy.',
      back: 'Hava birdenbire güneşliden yağmurluya döndü.',
      list: 'A1',
      answer: 'değişmek',
      quest: 'change'),
  Words(
      front: 'I like to put cheese on my pizza.',
      back: 'Pizzama peynir koymayı severim.',
      list: 'A1',
      answer: 'peynir',
      quest: 'cheese'),
  Words(
      front: 'Draw a circle on the paper.',
      back: 'Kağıt üzerine bir daire çiz',
      list: 'A1',
      answer: 'daire',
      quest: 'circle'),
  Words(
      front: 'We enjoyed watching the acrobats and animals at the circus.',
      back: 'Sirki izlemekten keyif aldık, cambazları ve hayvanları.',
      list: 'A1',
      answer: 'sirk',
      quest: 'circus'),
  Words(
      front: 'We visited a beautiful city on our vacation.',
      back: 'Tatilimizde güzel bir şehri ziyaret ettik.',
      list: 'A1',
      answer: 'şehir',
      quest: 'city'),
  Words(
      front: 'She is a clever student, always getting top grades.',
      back: 'O, zeki bir öğrenci, her zaman en iyi notları alıyor',
      list: 'A1',
      answer: 'akıllı',
      quest: 'clever'),
  Words(
      front: 'The cat tried to climb the tree to catch a bird.',
      back: 'Kedi, kuş yakalamak için ağaca tırmalamaya çalıştı.',
      list: 'A1',
      answer: 'tırmanmak',
      quest: 'climb'),
  Words(
      front: 'The sky was filled with fluffy white clouds.',
      back: 'Gökyüzü, kabarık beyaz bulutlarla doluydu',
      list: 'A1',
      answer: 'bulut',
      quest: 'cloud'),
  Words(
      front: "It looks like it's going to be a cloudy day.",
      back: 'Görünüşe göre, bugün bulutlu bir gün olacak.',
      list: 'A1',
      answer: 'buluttlu',
      quest: 'cloudy'),
  Words(
      front: 'The children laughed at the funny antics of the clown.',
      back: 'Çocuklar, palyaçonun komik şakalarına güldüler.',
      list: 'A1',
      answer: 'palyaço',
      quest: 'clown'),
  Words(
      front: "It's cold outside, so don't forget to wear your coat.",
      back: 'Dışarısı soğuk, bu yüzden paltonu giymeyi unutma.',
      list: 'A1',
      answer: 'mont',
      quest: 'coat'),
  Words(
      front: 'I start my day with a cup of coffee.',
      back: 'Günü bir fincan kahve ile başlıyorum.',
      list: 'A1',
      answer: 'kahve',
      quest: 'coffee'),
  Words(
      front: "Put on a jacket; it's cold outside.",
      back: 'Ceket giy, dışarısı soğuk.',
      list: 'A1',
      answer: 'soğuk',
      quest: 'cold'),
  Words(
      front: "Come on, let's go to the park together.",
      back: 'Haydi, birlikte parka gidelim.',
      list: 'A1',
      answer: 'başlamak',
      quest: 'Come on'),
  Words(
      front: 'He enjoys reading comic books in his free time.',
      back: 'Boş zamanlarında çizgi roman kitapları okumaktan keyif alır.',
      list: 'A1',
      answer: 'çizgi roman',
      quest: 'comic'),
  Words(
      front: 'She likes to cook delicious meals for her family.',
      back: 'Ailesi için lezzetli yemekler yapmaktan hoşlanır.',
      list: 'A1',
      answer: 'pişirmek',
      quest: 'cook'),
  Words(
      front: "He couldn't stop coughing after catching a cold.",
      back: 'Soğuk algınlığı kaptıktan sonra öksürmeyi bir türlü durduramadı.',
      list: 'A1',
      answer: 'öksürmek',
      quest: 'cough'),
  Words(
      front: 'She could speak three languages fluently.',
      back: 'O, üç dilde akıcı bir şekilde konuşabiliyordu.',
      list: 'A1',
      answer: '-a/ebilirdi',
      quest: 'could'),
  Words(
      front: 'Canada is a beautiful country known for its diverse landscapes.',
      back: 'Kanada, çeşitli manzaraları ile bilinen güzel bir ülkedir.',
      list: 'A1',
      answer: 'ülke',
      quest: 'country'),
  Words(
      front: 'The baby started to cry when it got hungry.',
      back: 'Bebek aç olduğunda ağlamaya başladı.',
      list: 'A1',
      answer: 'ağlamak',
      quest: 'cry'),
  Words(
      front: 'I enjoy drinking tea from my favorite cup.',
      back: 'En sevdiğim fincanımdan çay içmeyi severim.',
      list: 'A1',
      answer: 'kupa, fincan',
      quest: 'cup'),
  Words(
      front: 'She has beautiful curly hair that bounces when she walks.',
      back: 'Yürürken saçları sallanan güzel kıvırcık saçları var.',
      list: 'A1',
      answer: 'kıvırcık',
      quest: 'curly'),
  Words(
      front:
          "Wild animals can be dangerous , so it's important to keep a safe distance.",
      back:
          'Vahşi hayvanlar tehlikeli olabilir, bu yüzden güvenli bir mesafeyi korumak önemlidir.',
      list: 'A1',
      answer: 'tehlikeli',
      quest: 'dangerous'),
  Words(
      front: 'She is a proud mother of a lovely daughter.',
      back: 'O, sevimli bir kızının gurur duyan bir annesidir.',
      list: 'A1',
      answer: 'kız çocuk',
      quest: 'daughter'),
  Words(
      front: 'I have a dentist appointment next week to fix a cavity.',
      back:
          'Gelecek hafta diş çürüğümü düzeltmek için diş hekimine randevum var.',
      list: 'A1',
      answer: 'dişçi',
      quest: 'dentist'),
  Words(
      front: 'Can you explain the difference between these two options?',
      back: 'Bu iki seçenek arasındaki farkı açıklayabilir misin?',
      list: 'A1',
      answer: 'fark',
      quest: 'difference'),
  Words(
      front: 'Each person has a different taste in music.',
      back: 'Her kişinin müzikte farklı bir zevki vardır.',
      list: 'A1',
      answer: 'farklı',
      quest: 'different'),
  Words(
      front:
          'Learning a new language can be difficult, but with practice, it gets easier.',
      back:
          'Yeni bir dil öğrenmek zor olabilir, ancak pratik yapmakla daha kolay hale gelir.',
      list: 'A1',
      answer: 'önemli',
      quest: 'difficult'),
  Words(
      front: 'We saw dolphins jumping out of the water during our boat trip.',
      back: 'Tekne gezimiz sırasında suyun üzerinden atlayan yunusları gördük',
      list: 'A1',
      answer: 'yunus',
      quest: 'dolphin'),
  Words(
      front: 'She carefully climbed down the ladder.',
      back: 'Dikkatlice merdivenden indi.',
      list: 'A1',
      answer: 'aşağı',
      quest: 'down'),
  Words(
      front: "Let's go downstairs to the living room for a movie night.",
      back: 'Film gecesi için aşağı kata, oturma odasına gidelim.',
      list: 'A1',
      answer: 'alt kat',
      quest: 'downstairs'),
  Words(
      front: 'It was just a dream, but it felt so real.',
      back: 'Sadece bir rüyaydı, ama çok gerçek gibi hissettirdi.',
      list: 'A1',
      answer: 'rüya',
      quest: 'dream'),
  Words(
      front: 'We like to dress up in costumes for Halloween',
      back: 'Halloween için kostüm giyip süslenmeyi severiz.',
      list: 'A1',
      answer: 'giyinmek',
      quest: 'dress up'),
  Words(
      front: 'He knows how to drive a car.',
      back: 'Araba kullanmayı biliyor.',
      list: 'A1',
      answer: 'sürmek',
      quest: 'drive'),
  Words(
      front: 'The taxi driver took us to the airport',
      back: 'Taksi şoförü bizi havaalanına götürdü',
      list: 'A1',
      answer: 'sürücü',
      quest: 'driver'),
  Words(
      front: 'She asked me to drop off the package at the post office.',
      back: 'Bana paketi postaneye bırakmamı rica etti.',
      list: 'A1',
      answer: 'düşmek',
      quest: 'drop'),
  Words(
      front: "Let's go ask them. ",
      back: 'Gidip onlara soralım.',
      list: 'A1',
      answer: 'sormak',
      quest: 'ask'),
  Words(
      front: 'After washing, hang your clothes outside to dry.',
      back: 'Yıkadıktan sonra kıyafetlerini dışarı asarak kurut.',
      list: 'A1',
      answer: 'kuru',
      quest: 'dry'),
  Words(
      front: 'Learning English is easy with the right resources.',
      back: 'Doğru kaynaklarla İngilizce öğrenmek kolaydır.',
      list: 'A1',
      answer: 'kolay',
      quest: 'easy'),
  Words(
      front: 'The elevator stopped working, so we had to take the stairs.',
      back:
          'Asansör çalışmayı bıraktı, bu yüzden merdivenleri kullanmak zorunda kaldık.',
      list: 'A1',
      answer: 'asansör',
      quest: 'elevator'),
  Words(
      front: 'Every morning, I drink a cup of coffee.',
      back: 'Her sabah bir fincan kahve içerim.',
      list: 'A1',
      answer: 'her',
      quest: 'Every'),
  Words(
      front: 'Everyone is welcome to join the party.',
      back: 'Herkes partiye katılmaya davetlidir.',
      list: 'A1',
      answer: 'herkes',
      quest: 'Everyone'),
  Words(
      front: ' I told him everything that happened.',
      back: 'Ona olan her şeyi anlattım.',
      list: 'A1',
      answer: 'her şey',
      quest: 'everything'),
  Words(
      front: 'We have exciting plans for our summer vacation.',
      back: 'Yaz tatili için heyecan verici planlarımız var.',
      list: 'A1',
      answer: 'heyecanlı',
      quest: 'exciting'),
  Words(
      front: 'Excuse me, could you tell me what time it is?',
      back: 'Affedersiniz, saatin kaç olduğunu söyleyebilir misiniz?',
      list: 'A1',
      answer: 'affedersiniz',
      quest: 'Excuse me'),
  Words(
      front: 'The teacher graded the tests fairly.',
      back: 'Öğretmen testleri adil bir şekilde değerlendirdi.',
      list: 'A1',
      answer: 'dürüst, adil',
      quest: 'fair'),
  Words(
      front: 'I found some really cheap clothes on sale.',
      back: 'İndirimde gerçekten ucuz kıyafetler buldum.',
      list: 'A1',
      answer: 'ucuz',
      quest: 'cheap'),
  Words(
      front: 'Be careful not to fall on the ice!',
      back: 'Buzun üzerine düşmemeye dikkat edin!',
      list: 'A1',
      answer: 'düşmek,güz',
      quest: 'fall'),
  Words(
      front: 'Beyoncé is a famous singer.',
      back: 'Beyoncé ünlü bir şarkıcıdır.',
      list: 'A1',
      answer: 'ünlü',
      quest: 'famous'),
  Words(
      front: 'Farm life is very calm and peaceful.',
      back: 'Çiftlik hayatı çok sakin ve huzurlu.',
      list: 'A1',
      answer: 'çiftlik',
      quest: 'Farm'),
  Words(
      front: 'My dad is a farmer, and we grow corn on our farm.',
      back: 'Babam bir çiftçi ve çiftliğimizde mısır yetiştiriyoruz.',
      list: 'A1',
      answer: 'çiftçi',
      quest: 'farmer'),
  Words(
      front: 'Our body needs fat to store energy and protect organs.',
      back:
          'Vücudumuzun enerji depolamak ve organları korumak için yağa ihtiyacı vardır.',
      list: 'A1',
      answer: 'kilolu, yağ',
      quest: 'fat'),
  Words(
      front: 'I feed my dog twice a day.',
      back: 'Köpeğimi günde iki kez beslerim.',
      list: 'A1',
      answer: 'beslemek',
      quest: 'feed'),
  Words(
      front: 'The farmer planted corn in his fields this year.',
      back: 'Çiftçi bu yıl tarlasına mısır ekti.',
      list: 'A1',
      answer: 'tarla',
      quest: 'field'),
  Words(
      front: 'This fabric is very fine and high quality.',
      back: 'Bu kumaş çok güzel ve kaliteli.',
      list: 'A1',
      answer: 'hoş',
      quest: 'fine'),
  Words(
      front: 'She came in first place in the race.',
      back: 'Yarışmada birinci oldu',
      list: 'A1',
      answer: 'ilk',
      quest: 'first'),
  Words(
      front: 'The fish in the aquarium are swimming beautifully.',
      back: 'Akvaryumdaki balıklar çok güzel yüzüyor.',
      list: 'A1',
      answer: 'balık',
      quest: 'fish'),
  Words(
      front: 'We need to find a solution to fix this problem.',
      back: 'Bu sorunu çözebilecek bir çözüm bulmamız gerekiyor.',
      list: 'A1',
      answer: 'düzeltmek',
      quest: 'fix'),
  Words(
      front: 'The floors in the house are wooden parquet.',
      back: 'Evin zeminleri ahşap parke.',
      list: 'A1',
      answer: 'yer,zemin',
      quest: 'floor'),
  Words(
      front: 'We are going to fly to Paris for vacation',
      back: "Tatile Paris'e uçacağız.",
      list: 'A1',
      answer: 'uçmak',
      quest: 'fly'),
  Words(
      front: 'Walking in the forest is very enjoyable',
      back: 'Ormanda yürüyüş yapmak çok keyifli.',
      list: 'A1',
      answer: 'orman',
      quest: 'forest'),
  Words(
      front: 'What will you do this Friday?',
      back: 'Bu Cuma ne yapacaksın?',
      list: 'A1',
      answer: 'Cuma',
      quest: 'Friday'),
  Words(
      front: 'The child was frightened of the dark',
      back: 'Çocuk karanlıktan korkuyordu.',
      list: 'A1',
      answer: 'korkmuş',
      quest: 'frightened'),
  Words(
      front: "Let's go to the funfair and enjoy the rides together.",
      back:
          'Hadi lunaparka gidelim ve birlikte eğlenceli aktivitelerin tadını çıkaralım',
      list: 'A1',
      answer: 'lunapark',
      quest: 'funfair'),
  Words(
      front: "The architect designed the new museum in the shape of a cone.",
      back: 'Mimar yeni müzeyi bir koni şeklinde tasarladı.',
      list: 'A1',
      answer: 'tasarlamak',
      quest: 'design'),
  Words(
      front: "Can you imagine life without electricity?",
      back: 'Elektriksiz bir hayat düşünebiliyor musunuz?',
      list: 'A1',
      answer: 'hayal etmek',
      quest: 'imagine'),
  Words(
      front: "It's time to get dressed for the party.",
      back: 'Parti için giyinme zamanı geldi.',
      list: 'A1',
      answer: 'giyinmek',
      quest: 'get dressed'),
  Words(
      front: 'Please get off the bus at the next stop.',
      back: 'Lütfen bir sonraki durakta otobüsten in.',
      list: 'A1',
      answer: 'çıkmak',
      quest: 'get off'),
  Words(
      front: "There's an extra chair in the hall.",
      back: 'Koridorda fazladan bir sandalye var.',
      list: 'A1',
      answer: 'fazla',
      quest: 'extra'),
  Words(
      front: "Let's get on the train before it leaves.",
      back: "Kalkmadan önce tren'e binelim.",
      list: 'A1',
      answer: 'binmek',
      quest: 'get on'),
  Words(
      front: "Before going to bed, it's time to get undressed.",
      back: 'Yatmadan önce, soyunma zamanı.',
      list: 'A1',
      answer: 'soyunmak',
      quest: 'get undressed'),
  Words(
      front: 'I usually get up at 7:00 am.',
      back: "Genellikle sabah 7'de kalkarım.",
      list: 'A1',
      answer: 'kalkmak',
      quest: 'get up'),
  Words(
      front: 'I like to drink water from a glass.',
      back: 'Bardaktan su içmeyi seviyorum.',
      list: 'A1',
      answer: 'cam',
      quest: 'glass'),
  Words(
      front: "Let's go shopping for new clothes this weekend.",
      back: 'Bu hafta sonu yeni kıyafetler almak için alışverişe gidelim.',
      list: 'A1',
      answer: 'alışverişe gitmek',
      quest: 'go shopping'),
  Words(
      front: 'My goal is to read 10 books this year.',
      back: 'Hedefim bu yıl 10 kitap okumak.',
      list: 'A1',
      answer: 'hedef',
      quest: 'goal'),
  Words(
      front: 'My granddaughter is learning to play the piano.',
      back: 'Torunum piyano çalmayı öğreniyor.',
      list: 'A1',
      answer: 'torun',
      quest: 'granddaughter'),
  Words(
      front: 'I love spending time with my grandparents on the weekends.',
      back: 'Dedemlerle hafta sonları buluşmayı seviyorum.',
      list: 'A1',
      answer: 'büyük ebeveyn',
      quest: 'grandparent'),
  Words(
      front: 'The grass in the park is very soft and green.',
      back: 'Parktaki çimenler çok yumuşak ve yeşil.',
      list: 'A1',
      answer: 'çim',
      quest: 'grass'),
  Words(
      front: 'The plane landed on the ground.',
      back: 'Uçak yere indi.',
      list: 'A1',
      answer: 'toprak, yer',
      quest: 'ground'),
  Words(
      front: 'Children grow over time and become adults.',
      back: 'Çocuklar zamanla büyür ve yetişkin olurlar.',
      list: 'A1',
      answer: 'büyümek',
      quest: 'grow'),
  Words(
      front: 'He has just become a father.',
      back: 'Daha yeni baba oldu.',
      list: 'A1',
      answer: 'olmak,haline gelmek',
      quest: 'become'),
  Words(
      front: "He's all grown up now and learning to stand on his own two feet.",
      back: 'Artık büyüdü ve kendi ayakları üzerinde durmayı öğreniyor.',
      list: 'A1',
      answer: 'yetişkin',
      quest: 'grown up'),
  Words(
      front: 'I have many friends',
      back: 'Birçok arkadaşım var.',
      list: 'A1',
      answer: 'sahip olmak',
      quest: 'have'),
  Words(
      front: 'I have a headache, can I have a painkiller?',
      back: 'Başım ağrıyor, bir ağrı kesici alabilir miyim?',
      list: 'A1',
      answer: 'baş ağrısı',
      quest: 'headache'),
  Words(
      front: 'The phone bill was higher than he expected.',
      back: 'Telefon faturası beklediğinden yüksek geldi.',
      list: 'A1',
      answer: 'fatura',
      quest: 'bill'),
  Words(
      front: 'It is important to wear a helmet when riding a motorcycle.',
      back: 'Bisiklet kullanırken kask takmak önemlidir.',
      list: 'A1',
      answer: 'kask',
      quest: 'helmet'),
  Words(
      front: 'How can I help you?',
      back: 'Sana nasıl yardımcı olabilirim?',
      list: 'A1',
      answer: 'yardım',
      quest: 'help'),
  Words(
      front: 'She tried to hide her sadness, but I could tell she was upset.',
      back:
          'Üzüntüsünü gizlemeye çalıştı, ama üzgün olduğunu anlayabiliyordum.',
      list: 'A1',
      answer: 'saklanmak',
      quest: 'hide'),
  Words(
      front: 'We will get together with my family for Christmas holidays.',
      back: 'Noel tatili için ailemle bir araya geleceğiz.',
      list: 'A1',
      answer: 'tatil',
      quest: 'holiday'),
  Words(
      front: 'Our teacher gave us a math homework assignment.',
      back: 'Öğretmenimiz bize matematik ödevi verdi.',
      list: 'A1',
      answer: 'ev ödevi',
      quest: 'homework'),
  Words(
      front: 'The rabbit hopped through the field.',
      back: 'Tavşan tarlada zıplayarak ilerliyordu.',
      list: 'A1',
      answer: 'zıplamak',
      quest: 'hop'),
  Words(
      front: 'He was taken to the hospital for a medical check-up.',
      back: 'Sağlık kontrolü için hastaneye götürüldü.',
      list: 'A1',
      answer: 'hastane',
      quest: 'hospital'),
  Words(
      front: 'This coffee is very hot, be careful drinking it.',
      back: 'Bu kahve çok sıcak, dikkatli iç.',
      list: 'A1',
      answer: 'sıcak',
      quest: 'hot'),
  Words(
      front: 'How do you run so fast?',
      back: 'Bu kadar hızlı nasıl koşuyorsun?',
      list: 'A1',
      answer: 'Nasıl',
      quest: 'How'),
  Words(
      front: 'How much does a movie ticket cost?',
      back: 'Sinema bileti ne kadar tutuyor?',
      list: 'A1',
      answer: 'ne kadar',
      quest: 'How much'),
  Words(
      front: 'How often do you brush your teeth?',
      back: 'Dişlerini ne sıklıkla fırçalarsın?',
      list: 'A1',
      answer: 'ne sıklıkla',
      quest: 'How often'),
  Words(
      front: 'The jackpot he won was huge.',
      back: 'Kazandığı ikramiye devasa bir miktardı.',
      list: 'A1',
      answer: 'büyük, devasa',
      quest: 'huge'),
  Words(
      front: 'The population reached one hundred thousand.',
      back: 'Nüfus yüz bine ulaştı.',
      list: 'A1',
      answer: 'yüz',
      quest: 'hundred'),
  Words(
      front: 'I feel hungry after a long walk.',
      back: 'Uzun bir yürüyüşten sonra aç hissediyorum.',
      list: 'A1',
      answer: 'aç',
      quest: 'hungry'),
  Words(
      front: 'Being in the countryside makes me feel so good.',
      back: 'Kırsalda olmak bana kendimi çok iyi hissettiriyor.',
      list: 'A1',
      answer: 'hissetmek',
      quest: 'feel'),
  Words(
      front: 'I fell yesterday and hurt my knee.',
      back: 'Dün düşüp dizimi incittim.',
      list: 'A1',
      answer: 'incitmek',
      quest: 'hurt'),
  Words(
      front: 'I like to skate on the ice rink.',
      back: 'Buz pateni pistinde kaymayı seviyorum.',
      list: 'A1',
      answer: 'buz',
      quest: 'ice'),
  Words(
      front: 'We have different ideas about this.',
      back: 'Bu konuda farklı fikirlerimiz var.',
      list: 'A1',
      answer: 'fikir',
      quest: 'idea'),
  Words(
      front: 'He said he was ill.',
      back: 'Hasta olduğunu söyledi.',
      list: 'A1',
      answer: 'hasta olmak',
      quest: 'ill'),
  Words(
      front: 'You can also bring a handbag with you.',
      back: 'Yanınızda bir el çantası da getirebilirsiniz.',
      list: 'A1',
      answer: 'ayrıca',
      quest: 'also'),
  Words(
      front: 'Cats usually like to sleep inside the house.',
      back: 'Kediler genellikle evin içinde uyumayı severler.',
      list: 'A1',
      answer: 'içeri',
      quest: 'inside'),
  Words(
      front: 'I went into the water and started swimming.',
      back: 'Suya girdim ve yüzmeye başladım.',
      list: 'A1',
      answer: 'içinde',
      quest: 'into'),
  Words(
      front: 'I want to invite you to the party this weekend.',
      back: 'Seni hafta sonu yapılacak partiye davet etmek istiyorum.',
      list: 'A1',
      answer: 'davet',
      quest: 'invite'),
  Words(
      front: 'Being stranded on an island must be a terrifying experience.',
      back: 'Bir adada mahsur kalmak korkutucu bir deneyim olmalı.',
      list: 'A1',
      answer: 'ada',
      quest: 'island'),
  Words(
      front: 'The Amazon jungle is the largest rainforest in the world.',
      back: 'Amazon ormanları dünyanın en büyük yağmur ormanıdır.',
      list: 'A1',
      answer: 'orman',
      quest: 'jungle'),
  Words(
      front: 'I saw the cat kick him.',
      back: 'Kedinin onu tekmelediğini gördüm.',
      list: 'A1',
      answer: 'tekme',
      quest: 'kick'),
  Words(
      front: 'You were very kind to me, thank you.',
      back: 'Bana karşı çok nazik davrandınız, teşekkür ederim.',
      list: 'A1',
      answer: 'tür,kibar',
      quest: 'kind'),
  Words(
      front: 'The kitten was very cute.',
      back: 'Yavru kedi çok sevimliydi.',
      list: 'A1',
      answer: 'yavru kedi',
      quest: 'kitten'),
  Words(
      front: 'Lake Van is the largest lake in Turkey.',
      back: "Van Gölü Türkiye'nin en büyük gölüdür.",
      list: 'A1',
      answer: 'göl',
      quest: 'lake'),
  Words(
      front: 'This is the last book I read.',
      back: 'Bu, okuduğum en son kitap.',
      list: 'A1',
      answer: 'sonuncu',
      quest: 'last'),
  Words(
      front: "The baby's laughter made me laugh too.",
      back: 'Bebeğin kahkahası beni de güldürdü.',
      list: 'A1',
      answer: 'gülme',
      quest: 'laugh'),
  Words(
      front: "It's been a very mild autumn.",
      back: 'Çok ılıman bir sonbahar oldu.',
      list: 'A1',
      answer: 'sonbahar',
      quest: 'autumn'),
  Words(
      front: "The baby's laughter made me laugh too.",
      back: 'Bebeğin kahkahası beni de güldürdü.',
      list: 'A1',
      answer: 'bebek',
      quest: 'baby'),
  Words(
      front: 'The leaves of this tree have a very beautiful color.',
      back: 'Bu ağacın yaprakları çok güzel bir renge sahip.',
      list: 'A1',
      answer: 'yaprak',
      quest: 'leaves'),
  Words(
      front: 'I will go to the library this weekend to do some research.',
      back: 'Bu hafta sonu kütüphaneye gidip araştırma yapacağım.',
      list: 'A1',
      answer: 'kütüphane',
      quest: 'library'),
  Words(
      front: "I couldn't lift the heavy box, I need your help.",
      back: 'Ağır kutuyu kaldıramadım, yardımına ihtiyacım var.',
      list: 'A1',
      answer: 'kaldırmak',
      quest: 'lift'),
  Words(
      front: 'The lion is the largest member of the cat family.',
      back: 'Aslan, kedigiller familyasının en büyük üyesidir.',
      list: 'A1',
      answer: 'aslan',
      quest: 'lion'),
  Words(
      front: "I have a little time before my meeting.",
      back: 'Toplantımdan önce biraz zamanım var.',
      list: 'A1',
      answer: 'küçük',
      quest: 'little'),
  Words(
      front: "I'm looking for my phone, I can't find it.",
      back: 'Telefonumu arıyorum, bulamıyorum.',
      list: 'A1',
      answer: 'aramak',
      quest: 'looking for'),
  Words(
      front: 'They lose/t the ball in the last minutes of the game.',
      back: 'Maçın son dakikalarında topu kaybettiler.',
      list: 'A1',
      answer: 'kaybetmek',
      quest: 'lose'),
  Words(
      front: "He has a very loud voice, he talks like he's yelling.",
      back: 'Sesi çok yüksek, bağırıyor gibi konuşuyor.',
      list: 'A1',
      answer: 'yüksek ses',
      quest: 'loud'),
  Words(
      front: 'I used to work as a machine operator in a factory.',
      back: 'Bir fabrikada makine operatörü olarak çalışıyordum.',
      list: 'A1',
      answer: 'makine',
      quest: 'machine'),
  Words(
      front: ' I followed the map to find my way to the train station.',
      back: 'Tren istasyonuna gitmek için haritayı takip ettim.',
      list: 'A1',
      answer: 'harita',
      quest: 'map'),
  Words(
      front: "It doesn't matter what you think.",
      back: 'Düşündüğün önemli değil.',
      list: 'A1',
      answer: 'konu,önemli olmak',
      quest: 'matter'),
  Words(
      front: 'They mean to buy a new couch soon',
      back: 'Niyetleri yakında yeni bir koltuk almak',
      list: 'A1',
      answer: 'kastetmek',
      quest: 'mean'),
  Words(
      front: 'I left a message on your voicemail.',
      back: 'Sesli mesaja bir mesaj bıraktım.',
      list: 'A1',
      answer: 'mesaj',
      quest: 'message'),
  Words(
      front: 'I have a meeting with my boss on Monday.',
      back: 'Pazartesi günü patronumla bir toplantım var.',
      list: 'A1',
      answer: 'Pazartesi',
      quest: 'Monday'),
  Words(
      front: 'The moon is a beautiful celestial body that orbits the Earth.',
      back: "Ay, Dünya'nın etrafında dönen güzel bir gök cismidir.",
      list: 'A1',
      answer: 'Ay',
      quest: 'moon'),
  Words(
      front: 'I need more time to finish this project.',
      back: 'Bu projeyi bitirmek için daha fazla zamana ihtiyacım var.',
      list: 'A1',
      answer: 'daha fazla',
      quest: 'more'),
  Words(
      front:
          'I like most of the songs on this album, but my favorite is track number 5.',
      back:
          'Bu albümdeki şarkıların çoğunu seviyorum, ama favorim 5 numaralı parça.',
      list: 'A1',
      answer: 'en,çoğu',
      quest: 'most'),
  Words(
      front:
          'The climbers reached the summit of the mountain after a long and difficult journey.',
      back:
          'Dağcılar uzun ve zorlu bir yolculuğun ardından dağın zirvesine ulaştılar.',
      list: 'A1',
      answer: 'dağ',
      quest: 'mountain'),
  Words(
      front: 'He had a thick, curly moustache that covered his upper lip.',
      back: 'Üst dudağını kaplayan kalın ve kıvırcık bir bıyığı vardı.',
      list: 'A1',
      answer: 'bıyık',
      quest: 'moustache'),
  Words(
      front: 'The cat moved slowly across the room.',
      back: 'Kedi odanın içinde yavaşça hareket etti.',
      list: 'A1',
      answer: 'hareket',
      quest: 'move'),
  Words(
      front: 'I watched a movie last night with my friends.',
      back: 'Dün gece arkadaşlarımla bir film izledim.',
      list: 'A1',
      answer: 'film',
      quest: 'movie'),
  Words(
      front: 'You must be very tired after working all day.',
      back: 'Bütün gün çalıştıktan sonra çok yorgun olmalısın.',
      list: 'A1',
      answer: 'gereklilik,küf',
      quest: 'must'),
  Words(
      front: "The naughty boy pulled the girl's hair.",
      back: 'Yaramaz çocuk, kızın saçını çekti',
      list: 'A1',
      answer: 'yaramaz',
      quest: 'naughty'),
  Words(
      front: 'There is a bus stop near my house.',
      back: 'Evimin yakınında bir otobüs durağı var.',
      list: 'A1',
      answer: 'yanında',
      quest: 'near'),
  Words(
      front: 'She felt a sharp pain in her neck.',
      back: 'Boynunda keskin bir acı hissetti.',
      list: 'A1',
      answer: 'boyun',
      quest: 'neck'),
  Words(
      front: 'I need your help with this project.',
      back: 'Bu projede senin yardımına ihtiyacım var.',
      list: 'A1',
      answer: 'ihtiyaç',
      quest: 'need'),
  Words(
      front: 'I will never forget the day I met you.',
      back: 'Seni ilk gördüğüm günü asla unutmayacağım.',
      list: 'A1',
      answer: 'asla',
      quest: 'never'),
  Words(
      front: "I couldn't concentrate because of the noise",
      back: 'Gürültüden dolayı konsantre olamadım.',
      list: 'A1',
      answer: 'ses, gürültü',
      quest: 'noise'),
  Words(
      front: 'There is nothing wrong with me.',
      back: 'Benimle ilgili bir sorun yok.',
      list: 'A1',
      answer: 'hiçbir şey',
      quest: 'nothing'),
  Words(
      front: 'My mother was a nurse for many years.',
      back: 'Annem yıllarca hemşire olarak çalıştı.',
      list: 'A1',
      answer: 'hemşire',
      quest: 'nurse'),
  Words(
      front: "The meeting will start at 10 o'clock sharp.",
      back: "Toplantı tam saat 10'da başlayacak.",
      list: 'A1',
      answer: 'saat',
      quest: "o'clock"),
  Words(
      front: 'The lights are off in the empty room.',
      back: 'Boş odadaki ışıklar kapalı.',
      list: 'A1',
      answer: 'kapalı',
      quest: 'off'),
  Words(
      front: 'I often go to the park on weekends.',
      back: 'Hafta sonları sık sık parka gidiyorum.',
      list: 'A1',
      answer: 'sık sık',
      quest: 'often'),
  Words(
      front: 'The light is on.',
      back: 'Işık açık.',
      list: 'A1',
      answer: 'açık',
      quest: 'on'),
  Words(
      front: 'He only speaks English',
      back: 'O sadece İngilizce konuşur.',
      list: 'A1',
      answer: 'tek,sadece ',
      quest: 'only'),
  Words(
      front: 'She is the opposite of her sister.',
      back: 'O, kız kardeşinin tam tersi.',
      list: 'A1',
      answer: 'zıt',
      quest: 'opposite'),
  Words(
      front: "I'm going out with my friends tonight.",
      back: 'Bu akşam arkadaşlarımla dışarı çıkıyorum.',
      list: 'A1',
      answer: 'çıkış',
      quest: 'out'),
  Words(
      front: 'She is out of town this week.',
      back: 'Bu hafta şehir dışında.',
      list: 'A1',
      answer: 'dışında, bitmek',
      quest: 'out of'),
  Words(
      front: 'I like to sit outside and read.',
      back: 'Dışarıda oturup okumayı seviyorum.',
      list: 'A1',
      answer: 'dışarısı',
      quest: 'outside'),
  Words(
      front: 'I bought a new pair of shoes.',
      back: 'Yeni bir çift ayakkabı aldım.',
      list: 'A1',
      answer: 'çift',
      quest: 'pair'),
  Words(
      front: 'I made pancakes for breakfast this morning.',
      back: 'Bu sabah kahvaltıda krep yaptım.',
      list: 'A1',
      answer: 'krep',
      quest: 'pancake'),
  Words(
      front: 'My parents are coming to visit me next week.',
      back: 'Annem babam beni gelecek hafta ziyarete gelecekler.',
      list: 'A1',
      answer: 'ebeveyn',
      quest: 'parent'),
  Words(
      front: 'The parrot mimicked the sound of a car alarm.',
      back: 'Papağan araba alarmı sesini taklit etti.',
      list: 'A1',
      answer: 'papağan',
      quest: 'parrot'),
  Words(
      front: 'The pirates sailed the high seas in search of treasure.',
      back: 'Korsanlar hazine aramak için açık denizlerde yelken açtılar.',
      list: 'A1',
      answer: 'korsan',
      quest: 'pirate'),
  Words(
      front: 'I went to a beautiful place yesterday.',
      back: 'Dün güzel bir yere gittim.',
      list: 'A1',
      answer: 'yer',
      quest: 'place'),
  Words(
      front: 'The plants in the garden need to be watered every day.',
      back: 'Bahçedeki bitkilerin her gün sulanması gerekiyor.',
      list: 'A1',
      answer: 'bitki',
      quest: 'plant'),
  Words(
      front: 'I put the dirty plates in the dishwasher.',
      back: 'Kirli tabakları bulaşık makinesine koydum.',
      list: 'A1',
      answer: 'tabak',
      quest: 'plate'),
  Words(
      front:
          'The young player scored a hat-trick in his first game for the club.',
      back: 'Genç oyuncu, kulüpteki ilk maçında üç gol attı.',
      list: 'A1',
      answer: 'oyuncu',
      quest: 'player'),
  Words(
      front: 'The children were playing in the pool.',
      back: 'Çocuklar havuzda oynuyorlardı.',
      list: 'A1',
      answer: 'havuz',
      quest: 'pool'),
  Words(
      front: 'I practice playing the piano every day.',
      back: 'Her gün piyano çalmak için pratik yapıyorum.',
      list: 'A1',
      answer: 'egzersiz, pratik',
      quest: 'practice'),
  Words(
      front: 'The verb "to give" is present tense.',
      back: '"Vermek" fiili şimdiki zamandır.',
      list: 'A1',
      answer: 'şimdiki zaman',
      quest: 'present'),
  Words(
      front: 'The sunset was pretty.',
      back: 'Gün batımı çok güzeldi.',
      list: 'A1',
      answer: 'şirin, güzel',
      quest: 'pretty'),
  Words(
      front: 'She put on her coat and went outside.',
      back: 'Montunu giydi ve dışarı çıktı.',
      list: 'A1',
      answer: 'giyinmek',
      quest: 'put on'),
  Words(
      front: 'I need to finish this project quickly.',
      back: 'Bu projeyi hızlı bir şekilde bitirmem gerekiyor.',
      list: 'A1',
      answer: 'hızlı',
      quest: 'quick'),
  Words(
      front: 'The library is a quiet place where people can study.',
      back: 'Kütüphane, insanların çalışabileceği sessiz bir yerdir.',
      list: 'A1',
      answer: 'sessiz',
      quest: 'quiet'),
  Words(
      front: 'The rabbit hopped across the field.',
      back: 'Tavşan tarlada zıpladı.',
      list: 'A1',
      answer: 'tavşan',
      quest: 'rabbit'),
  Words(
      front: 'The rain started to fall as soon as we stepped outside.',
      back: 'Dışarı adım attığımızda yağmur yağmaya başladı.',
      list: 'A1',
      answer: 'yağmur',
      quest: 'rain'),
  Words(
      front: 'After the rain, a beautiful rainbow appeared in the sky.',
      back: 'Yağmurdan sonra gökyüzünde güzel bir gökkuşağı belirdi.',
      list: 'A1',
      answer: 'gökkuşağı',
      quest: 'rainbow'),
  Words(
      front: "The waves were high, so we didn't go for a ride on the boat.",
      back: 'Dalgalar yüksek olduğu için tekneye binmedik.',
      list: 'A1',
      answer: 'binmek',
      quest: 'ride'),
  Words(
      front: 'The river flows through the city.',
      back: 'Nehir şehirden akar.',
      list: 'A1',
      answer: 'nehir',
      quest: 'river'),
  Words(
      front: 'The road to success is not always easy.',
      back: 'Başarıya giden yol her zaman kolay değildir.',
      list: 'A1',
      answer: 'yol',
      quest: 'road'),
  Words(
      front: 'I saw a rock on the ground.',
      back: 'Yerde bir kaya gördüm.',
      list: 'A1',
      answer: 'taş',
      quest: 'rock'),
  Words(
      front:
          'The roof of the house was leaking, so we had to call a repairman.',
      back:
          'Evin çatısı sızıyordu, bu yüzden bir tamirci çağırmak zorunda kaldık.',
      list: 'A1',
      answer: 'çatı',
      quest: 'roof'),
  Words(
      front: 'I always brush my teeth before going to bed.',
      back: 'Yatmadan önce her zaman dişlerimi fırçalarım.',
      list: 'A1',
      answer: 'her zaman',
      quest: 'always'),
  Words(
      front: 'The meeting is on 4 April.',
      back: "Toplantı 4 Nisan'da.",
      list: 'A1',
      answer: 'Nisan',
      quest: 'April'),
  Words(
      front: 'He wound the string into a ball.',
      back: "İpi bir top haline getirdi.",
      list: 'A1',
      answer: 'top',
      quest: 'ball'),
  Words(
      front: 'My favorite band will be in town tonight.',
      back: "En sevdiğim grup bu gece şehirde olacak.",
      list: 'A1',
      answer: 'grup',
      quest: 'band'),
  Words(
      front: 'He has some air of mystery.',
      back: 'Biraz gizemli bir havası var.',
      list: 'A1',
      answer: 'hava',
      quest: 'air'),
  Words(
      front: 'The Earth is round.',
      back: 'Dünya yuvarlaktır.',
      list: 'A1',
      answer: 'yuvarlak',
      quest: 'round'),
  Words(
      front: "The child is safe in her mother's arms.",
      back: 'Çocuk annesinin kollarında güvende.',
      list: 'A1',
      answer: 'güvenli',
      quest: 'safe'),
  Words(
      front: 'The boat sailed across the harbor.',
      back: 'Tekne limanın karşısına yelken açtı.',
      list: 'A1',
      answer: 'yelken',
      quest: 'sail'),
  Words(
      front: 'I made a salad with tomatoes, cucumbers, and lettuce.',
      back: 'Domates, salatalık ve marul ile bir salata yaptım.',
      list: 'A1',
      answer: 'salata',
      quest: 'salad'),
  Words(
      front: 'I made a sandwich with ham, cheese, and lettuce for lunch.',
      back: 'Öğle yemeği için jambon, peynir ve marul ile bir sandviç yaptım.',
      list: 'A1',
      answer: 'sandviç',
      quest: 'sandwich'),
  Words(
      front: 'I like to go to the park on Saturdays.',
      back: 'Cumartesileri parka gitmeyi seviyorum.',
      list: 'A1',
      answer: 'Cumartesi',
      quest: 'Saturday'),
  Words(
      front: 'I like to add a bit of hot sauce to my tacos.',
      back: 'Tacolarıma biraz acı sos eklemeyi seviyorum.',
      list: 'A1',
      answer: 'sos',
      quest: 'sauce'),
  Words(
      front: 'She wrapped a scarf around her neck to keep warm.',
      back: 'Sıcak kalmak için boynuna bir atkı sardı.',
      list: 'A1',
      answer: 'atkı',
      quest: 'scarf'),
  Words(
      front: 'The movie received a high score from the critics.',
      back: 'Film, eleştirmenlerden yüksek puan aldı.',
      list: 'A1',
      answer: 'skor',
      quest: 'score'),
  Words(
      front: 'I reserved a seat on the plane.',
      back: 'Uçakta bir koltuk rezerve ettim.',
      list: 'A1',
      answer: 'koltuk',
      quest: 'seat'),
  Words(
      front: 'I will be there in a second.',
      back: 'Bir saniye sonra oradayım.',
      list: 'A1',
      answer: 'saniye',
      quest: 'second'),
  Words(
      front: 'I will send you the package tomorrow.',
      back: 'Paketi sana yarın göndereceğim.',
      list: 'A1',
      answer: 'yollamak,göndermek',
      quest: 'send'),
  Words(
      front: 'What shall we do tonight?',
      back: 'Bu gece ne yapalım?',
      list: 'A1',
      answer: 'kararlılık, niyet',
      quest: 'shall'),
  Words(
      front: 'The great white shark is a top predator in the ocean.',
      back: 'Beyaz köpek balığı okyanusta zirvedeki yırtıcıdır.',
      list: 'A1',
      answer: 'köpek balığı',
      quest: 'shark'),
  Words(
      front: 'The shape of the cloud is constantly changing.',
      back: 'Bulutun şekli sürekli değişiyor.',
      list: 'A1',
      answer: 'şekil',
      quest: 'shape'),
  Words(
      front: 'I want to open my own shop one day.',
      back: 'Bir gün kendi dükkanımı açmak istiyorum.',
      list: 'A1',
      answer: 'alışveriş',
      quest: 'shop'),
  Words(
      front: 'I felt a sharp pain in my shoulder after lifting the heavy box.',
      back: 'Ağır kutuyu kaldırdıktan sonra omzumda keskin bir ağrı hissettim.',
      list: 'A1',
      answer: 'omuz',
      quest: 'shoulder'),
  Words(
      front:
          "There's no need to shout while everyone is screaming at the concert!",
      back: 'Konser sırasında herkes bağırırken, senin de bağırmana gerek yok!',
      list: 'A1',
      answer: 'haykırmak',
      quest: 'shout'),
  Words(
      front: 'I take a shower every morning to wake myself up.',
      back: 'Her sabah kendimi uyandırmak için duş alırım.',
      list: 'A1',
      answer: 'duş',
      quest: 'shower'),
  Words(
      front: "I'm feeling sick, so I'm going to stay home from work today.",
      back: 'Kendimi hasta hissediyorum, bu yüzden bugün evden çalışacağım.',
      list: 'A1',
      answer: 'hasta',
      quest: 'sick'),
  Words(
      front: 'I skipped breakfast today because I was running late.',
      back: 'Bugün kahvaltıyı atladım çünkü geç kalacaktım.',
      list: 'A1',
      answer: 'atlamak',
      quest: 'skip'),
  Words(
      front: 'The sky was a brilliant blue today.',
      back: 'Bugün gökyüzü parlak bir maviydi.',
      list: 'A1',
      answer: 'gökyüzü',
      quest: 'sky'),
  Words(
      front: 'The snail is moving very slow.',
      back: 'Salyangoz çok yavaş hareket ediyor.',
      list: 'A1',
      answer: 'yavaş',
      quest: 'slow'),
  Words(
      front: 'The children built a snowman in the snow.',
      back: 'Çocuklar karda bir kardan adam yaptılar.',
      list: 'A1',
      answer: 'kar',
      quest: 'snow'),
  Words(
      front: 'Someone left a message on my door.',
      back: 'Biri kapımın önüne bir mesaj bıraktı.',
      list: 'A1',
      answer: 'birisi',
      quest: 'Someone'),
  Words(
      front: 'Would you like something to drink?',
      back: 'Bir şey içmek ister misin?',
      list: 'A1',
      answer: 'bir şey',
      quest: 'something'),
  Words(
      front: 'We sometimes go to the park on weekends.',
      back: 'Hafta sonları bazen parka gideriz.',
      list: 'A1',
      answer: 'bazı zamanlar',
      quest: 'sometimes'),
  Words(
      front: "His son is a very smart boy.",
      back: "Oğlu çok zeki bir çocuk.",
      list: "A1",
      answer: "erkek çocuk",
      quest: "son"),
  Words(
      front: "I want to have soup for dinner.",
      back: "Akşam yemeği için çorba içmek istiyorum.",
      list: "A1",
      answer: "çorba",
      quest: "soup"),
  Words(
      front: "Please draw a square on the paper.",
      back: "Lütfen kağıda bir kare çiz.",
      list: "A1",
      answer: "kare",
      quest: "square"),
  Words(
      front: "We need to use the stairs to go upstairs.",
      back: "Üst kata çıkmak için merdivenleri kullanmalıyız.",
      list: "A1",
      answer: "merdiven",
      quest: "stair"),
  Words(
      front: "Look at the stars in the night sky.",
      back: "Gece gökyüzündeki yıldızlara bak.",
      list: "A1",
      answer: "yıldız",
      quest: "star"),
  Words(
      front: "My stomach hurts. I should go to the doctor.",
      back: "Midem ağrıyor. Doktora gitmeliyim.",
      list: "A1",
      answer: "mide",
      quest: "stomach"),
  Words(
      front: "My teacher said my answer was straight and correct.",
      back: "Öğretmenim cevabımın doğru ve düzgün olduğunu söyledi.",
      list: "A1",
      answer: "düzgün,doğru",
      quest: "straight"),
  Words(
      front: "He is a very strong man.",
      back: "O çok güçlü bir adam.",
      list: "A1",
      answer: "güçlü",
      quest: "strong"),
  Words(
      front: "Tomorrow is Sunday.",
      back: "Yarın Pazar.",
      list: "A1",
      answer: "Pazar",
      quest: "Sunday"),
  Words(
      front: "It's a beautiful sunny day today.",
      back: "Bugün hava çok güzel ve güneşli.",
      list: "A1",
      answer: "güneşli",
      quest: "sunny"),
  Words(
      front: "I was surprised to see him there.",
      back: "Onu orada görmek beni şaşırttı.",
      list: "A1",
      answer: "şaşırmış",
      quest: "surprised"),
  Words(
      front: "I'm wearing a warm sweater today because it's cold.",
      back: "Hava soğuk olduğu için bugün sıcak bir kazak giyiyorum.",
      list: "A1",
      answer: "kazak",
      quest: "sweater"),
  Words(
      front: "I like to eat sweet things like chocolate.",
      back: "Çikolata gibi tatlı şeyleri yemeyi severim.",
      list: "A1",
      answer: "tatlı",
      quest: "sweet"),
  Words(
      front: "I can swim, but I'm not very good at it",
      back: "Yüzme biliyorum ama pek iyi değilim.",
      list: "A1",
      answer: "yüzmek, yüzme havuzu",
      quest: "swim"),
  Words(
      front: "Please take a seat.",
      back: "Lütfen oturun.",
      list: "A1",
      answer: "almak",
      quest: "take"),
  Words(
      front: "Can you read this text for me?",
      back: "Bu metni benim için okuyabilir misin?",
      list: "A1",
      answer: "metin",
      quest: "text"),
  Words(
      front: "Do you need a ticket for the movie?",
      back: "Film için bilete ihtiyacın var mı?",
      list: "A1",
      answer: "bilet",
      quest: "ticket"),
  Words(
      front: "We are visiting a small town in the mountains.",
      back: "Dağlarda küçük bir kasabayı ziyaret ediyoruz.",
      list: "A1",
      answer: "kasaba",
      quest: "town"),
  Words(
      front: "I'm feeling a bit tired today.",
      back: "Bugün biraz yorgunum.",
      list: "A1",
      answer: "yorulmak",
      quest: "tired"),
  Words(
      front: "This book is more interesting than the other one.",
      back: "Bu kitap diğerinden daha ilginç.",
      list: "A1",
      answer: "-den",
      quest: "than"),
  Words(
      front: "The plane is ready to take off.",
      back: "Uçak havalanmaya hazır.",
      list: "A1",
      answer: "havalanması",
      quest: "take off"),
  Words(
      front: "He is very tall for his age.",
      back: "Yaşına göre çok uzun.",
      list: "A1",
      answer: "uzun",
      quest: "tall"),
  Words(
      front: "Would you like some tea?",
      back: "Biraz çay ister misin?",
      list: "A1",
      answer: "çay",
      quest: "tea"),
  Words(
      front: "The teacher is teaching us English.",
      back: "Öğretmen bize İngilizce öğretiyor.",
      list: "A1",
      answer: "öğretmek",
      quest: "teach"),
  Words(
      front: "The temperature is rising today.",
      back: "Hava sıcaklığı bugün yükseliyor.",
      list: "A1",
      answer: "sıcaklık",
      quest: "temperature"),
  Words(
      front: "The movie was terrible.",
      back: "Film berbattı.",
      list: "A1",
      answer: "berbat",
      quest: "terrible"),
  Words(
      front: "Then I went home.",
      back: "O zaman eve gittim.",
      list: "A1",
      answer: "o zamanlar",
      quest: "Then"),
  Words(
      front: "This paper is too thin to write on.",
      back: "Bu kağıt üzerine yazmak için çok ince.",
      list: "A1",
      answer: "ince",
      quest: "thin"),
  Words(
      front: "Take a moment to think before you answer.",
      back: "Cevap vermeden önce biraz düşün.",
      list: "A1",
      answer: "düşünme",
      quest: "think"),
  Words(
      front: "He is the third person in line.",
      back: "O sırada üçüncü kişi.",
      list: "A1",
      answer: "üçüncü",
      quest: "third"),
  Words(
      front: "I'm feeling a bit thirsty. Can I have some water?",
      back: " biraz susadım. Su alabilir miyim?",
      list: "A1",
      answer: "susamak",
      quest: "thirsty"),
  Words(
      front: "Today is Thursday.",
      back: "Bugün Perşembe.",
      list: "A1",
      answer: "Perşembe",
      quest: "Thursday"),
  Words(
      front: "I have a toothache.",
      back: "Diş ağrım var.",
      list: "A1",
      answer: "diş ağrısı",
      quest: "toothache"),
  Words(
      front: "I lost a tooth when I was playing football.",
      back: "Futbol oynarken bir dişim düştü.",
      list: "A1",
      answer: "diş,",
      quest: "tooth"),
  Words(
      front: "Please put your things on the top shelf.",
      back: "Lütfen eşyalarını üst rafa koy.",
      list: "A1",
      answer: "üst,baş",
      quest: "top"),
  Words(
      front: "Can you hand me the towel?",
      back: "Havluyu bana uzatabilir misin?",
      list: "A1",
      answer: "havlu",
      quest: "towel"),
  Words(
      front: "I love to travel to new places.",
      back: "Yeni yerlere seyahat etmeyi severim.",
      list: "A1",
      answer: "yolculuk",
      quest: "travel"),
  Words(
      front: "Pirates are searching for buried treasure.",
      back: "Korsanlar gömülü hazine arıyorlar.",
      list: "A1",
      answer: "hazine",
      quest: "treasure"),
  Words(
      front: "We are planning a short trip to the mountains next weekend.",
      back: "Gelecek hafta sonu dağlara kısa bir gezi planlıyoruz.",
      list: "A1",
      answer: "gezi",
      quest: "trip"),
  Words(
      front: "Today is Tuesday.",
      back: "Bugün Salı.",
      list: "A1",
      answer: "Salı",
      quest: "Tuesday"),
  Words(
      front: "Look up at the sky.",
      back: "Gökyüzüne yukarı bak.",
      list: "A1",
      answer: "yukarı",
      quest: "up"),
  Words(
      front: "I need to go upstairs to my room.",
      back: "Odama yukarı çıkmam gerekiyor.",
      list: "A1",
      answer: "üst kat",
      quest: "upstairs"),
  Words(
      front: "We visited a small village in the countryside.",
      back: "Kırsaldaki küçük bir köyü ziyaret ettik.",
      list: "A1",
      answer: "köy",
      quest: "village"),
  Words(
      front: "Please wait a minute.",
      back: "Lütfen bir dakika bekle.",
      list: "A1",
      answer: "bekle",
      quest: "wait"),
  Words(
      front: "What time do you usually wake up?",
      back: "Genellikle ne zaman uyanırsın?",
      list: "A1",
      answer: "uyanmak",
      quest: "wake"),
  Words(
      front: "The painting is hanging on the wall.",
      back: "Resim duvarda asılı.",
      list: "A1",
      answer: "duvar",
      quest: "wall"),
  Words(
      front: "Please wash your hands before dinner.",
      back: "Lütfen yemekten önce ellerini yıka.",
      list: "A1",
      answer: "yıkamak",
      quest: "wash"),
  Words(
      front: "I need a glass of water.",
      back: "Bir bardak suya ihtiyacım var.",
      list: "A1",
      answer: "su",
      quest: "water"),
  Words(
      front: "The surfer is riding the waves in the ocean.",
      back: "Sörfçü okyanustaki dalgalarda sörf yapıyor.",
      list: "A1",
      answer: "dalga",
      quest: "wave"),
  Words(
      front: "I'm feeling a bit weak today.",
      back: "Bugün biraz halsiz ve zayıf hissediyorum.",
      list: "A1",
      answer: "halsiz,zayıf",
      quest: "weak"),
  Words(
      front: "The weather is beautiful today.",
      back: "Hava bugün güzel.",
      list: "A1",
      answer: "hava",
      quest: "weather"),
  Words(
      front: "Today is Wednesday.",
      back: "Bugün Çarşamba.",
      list: "A1",
      answer: "Çarşamba",
      quest: "Wednesday"),
  Words(
      front: "I study every day for two weeks.",
      back: "İki hafta boyunca her gün çalışıyorum.",
      list: "A1",
      answer: "hafta",
      quest: "week"),
  Words(
      front: "We are going on a trip next weekend.",
      back: "Gelecek hafta sonu bir geziye gidiyoruz.",
      list: "A1",
      answer: "haftasonu",
      quest: "weekend"),
  Words(
      front: "Well, that was an interesting movie.",
      back: "Peki, bu ilginç bir filmdi.",
      list: "A1",
      answer: "peki",
      quest: "Well"),
  Words(
      front: "Don't touch me, I'm wet.",
      back: "Bana dokunma, ıslağım.",
      list: "A1",
      answer: "ıslak",
      quest: "wet"),
  Words(
      front: "Whales are the largest whales on Earth.",
      back: "Balinalar, Dünya üzerindeki en büyük balinalardır.",
      list: "A1",
      answer: "balina",
      quest: "whale"),
  Words(
      front: "When are you coming home?",
      back: "Ne zaman eve döneceksin?",
      list: "A1",
      answer: "ne zaman?",
      quest: "When"),
  Words(
      front: "Where is the library?",
      back: "Kütüphane nerede?",
      list: "A1",
      answer: "nerede?",
      quest: "Where"),
  Words(
      front: "Which book do you want to read?",
      back: "Hangi kitabı okumak istiyorsun?",
      list: "A1",
      answer: "hangi?",
      quest: "Which"),
  Words(
      front: "Who is coming to the party tonight?",
      back: "Bu gece partiye kim geliyor?",
      list: "A1",
      answer: "kim?",
      quest: "Who"),
  Words(
      front: "Why are you late?",
      back: "Neden geciktin?",
      list: "A1",
      answer: "neden?",
      quest: "Why"),
  Words(
      front: "The strong wind is blowing the trees.",
      back: "Güçlü rüzgar ağaçları sallıyor.",
      list: "A1",
      answer: "rüzgar",
      quest: "wind"),
  Words(
      front: "It's a bit windy today.",
      back: "Bugün biraz rüzgarlı.",
      list: "A1",
      answer: "rüzgarlı",
      quest: "windy"),
  Words(
      front: "I need to work hard to achieve my goals.",
      back: "Hedeflerime ulaşmak için çok çalışmalıyım.",
      list: "A1",
      answer: "çalışmak",
      quest: "work"),
  Words(
      front:
          "We live on planet Earth. It is the only known planet to support life as we know it in the world.",
      back:
          "Dünya gezegeninde yaşıyoruz. Bildiğimiz şekliyle yaşamı destekleyen bilinen tek gezegendir.",
      list: "A1",
      answer: "dünya",
      quest: "world"),
  Words(
      front: "This situation is bad, but it could be worse.",
      back: "Bu durum kötü, ama daha da kötü olabilir.",
      list: "A1",
      answer: "daha kötüsü",
      quest: "worse"),
  Words(
      front: "That was the worst movie I've ever seen.",
      back: "Bu şimdiye kadar gördüğüm en kötü filmdi.",
      list: "A1",
      answer: "en kötü şey",
      quest: "worst"),
  Words(
      front: "What would you like to do today?",
      back: "Bugün ne yapmak isterdin?",
      list: "A1",
      answer: "-ecek/-acak",
      quest: "would"),
  Words(
      front: "I think your answer is wrong.",
      back: "Sanırım cevabın yanlış.",
      list: "A1",
      answer: "yanlış",
      quest: "wrong"),
  Words(
      front: "What did you do yesterday?",
      back: "Dün ne yaptın?",
      list: "A1",
      answer: "dün",
      quest: "yesterday"),
  Words(
      front: "The situation is not good.",
      back: "Durum iyi değil.",
      list: "A1",
      answer: "durum",
      quest: "situation"),
  Words(
      front: "Playing the piano is a difficult skill to learn.",
      back: "Piyano çalmak öğrenmesi zor bir maharettir.",
      list: "A1",
      answer: "maharet",
      quest: "skill"),
  Words(
      front: "Can you read this text for me?",
      back: "Bu metni benim için okuyabilir misin?",
      list: "A1",
      answer: "metin",
      quest: "text"),
  Words(
      front: "They are going to the movies tonight.",
      back: "Onlar bu gece sinemaya gidiyorlar.",
      list: "A1",
      answer: "onlar",
      quest: "They"),
  Words(
      front: "I need to improve my English skills.",
      back: "İngilizcemi geliştirmem gerekiyor.",
      list: "A1",
      answer: "geliştirmek",
      quest: "improve"),
  Words(
      front: "I have a job interview next week.",
      back: "Gelecek hafta bir iş görüşmem var.",
      list: "A1",
      answer: "görüşme",
      quest: "interview"),
  Words(
      front: "Are you married?",
      back: "Evli misin?",
      list: "A1",
      answer: "evli",
      quest: "married"),
  Words(
      front: "Today is March 7th.",
      back: "Bugün 7 Mart.",
      list: "A1",
      answer: "Mart",
      quest: "March"),
  Words(
      front: "My father is a doctor.",
      back: "Babam doktor.",
      list: "A1",
      answer: "baba",
      quest: "father"),
  Words(
      front: "It was cold in February.",
      back: "Şubat ayında hava soğuktu.",
      list: "A1",
      answer: "şubat",
      quest: "February"),
  Words(
      front: "I have only a few books.",
      back: "Sadece birkaç kitabım var.",
      list: "A1",
      answer: "az",
      quest: "few"),
  Words(
      front: "We have English lessons every Monday.",
      back: "Her Pazartesi İngilizce derslerimiz var.",
      list: "A1",
      answer: "ders",
      quest: "lesson"),
  Words(
      front: "No one was home when I arrived.",
      back: "Geldiğimde kimse evde yoktu.",
      list: "A1",
      answer: "hiç kimse",
      quest: "No one"),
  Words(
      front: "Please write a sentence using the word 'book'.",
      back: "Lütfen 'kitap' kelimesini kullanarak bir cümle yazın.",
      list: "A1",
      answer: "cümle",
      quest: "sentence"),
  Words(
      front: "Today is Sunday.",
      back: "Bugün Pazar.",
      list: "A1",
      answer: "pazar",
      quest: "Sunday"),
  Words(
      front: "Can you tell them the story?",
      back: "Onlara hikayeyi anlatabilir misin?",
      list: "A1",
      answer: "onlara",
      quest: "them"),
  Words(
      front: "What is the reason for your absence?",
      back: "Yokluğunuzun sebebi nedir?",
      list: "A1",
      answer: "sebep",
      quest: "reason"),
  Words(
      front: "The result of the experiment was successful.",
      back: "Deneyin sonucu başarılıydı.",
      list: "A1",
      answer: "sonuç",
      quest: "result"),
  Words(
      front: "Today is Thursday.",
      back: "Bugün Perşembe.",
      list: "A1",
      answer: "perşembe",
      quest: "Thursday"),
  Words(
      front: "It is a personal question, and I don't want to answer it.",
      back: "Bu kişisel bir soru ve cevaplamak istemiyorum.",
      list: "A1",
      answer: "kişisel",
      quest: "personal"),
  Words(
      front: "My brother is a teenager.",
      back: "Kardeşim bir genç.",
      list: "A1",
      answer: "ergen",
      quest: "teenager"),
  Words(
      front: "I gave them their books.",
      back: "Onlara kitaplarını verdim.",
      list: "A1",
      answer: "onların",
      quest: "their"),
  Words(
      front: "How much does a movie ticket cost?",
      back: "Bir film bileti ne kadar tutar?",
      list: "A1",
      answer: "bilet",
      quest: "ticket"),
  Words(
      front: "Turkey is located in the south of Asia.",
      back: "Türkiye, Asya'nın güneyinde yer alır.",
      list: "A1",
      answer: "güney",
      quest: "south"),
  Words(
      front: "The sun sets in the west.",
      back: "Güneş batıda batar.",
      list: "A1",
      answer: "batı",
      quest: "west"),
  Words(
      front: "Japan is located in the east of Asia.",
      back: "Japonya, Asya'nın doğusunda yer alır.",
      list: "A1",
      answer: "doğu",
      quest: "east"),
  Words(
      front: "How much money did you spend on vacation?",
      back: "Tatilde ne kadar para harcadınız?",
      list: "A1",
      answer: "harcamak",
      quest: "spend"),
  Words(
      front: "We are planning a vacation to Italy next summer.",
      back: "Gelecek yaz İtalya'ya tatile gitmeyi planlıyoruz.",
      list: "A1",
      answer: "tatil",
      quest: "vacation"),
  Words(
      front: "I usually wake up at 7 o'clock.",
      back: "Genellikle saat 7'de uyanırım.",
      list: "A1",
      answer: "genellikle",
      quest: "usually"),
  Words(
      front: "There are many visitors from different countries in Istanbul.",
      back: "İstanbul'da farklı ülkelerden birçok ziyaretçi var.",
      list: "A1",
      answer: "ziyaretçi",
      quest: "visitor"),
  Words(
      front: "It is a very beautiful city.",
      back: "Çok güzel bir şehir.",
      list: "A1",
      answer: "çok",
      quest: "very"),
  Words(
      front: "I enjoyed my visit to the museum.",
      back: "Müzeye yaptığım ziyareti çok beğendim.",
      list: "A1",
      answer: "ziyaret",
      quest: "visit"),
  Words(
      front: "Can I call the waiter, please?",
      back: "Garson, lütfen?",
      list: "A1",
      answer: "garson",
      quest: "waiter"),
  Words(
      front: "The wait for the bus was long.",
      back: "Otobüs bekleyişi uzundu.",
      list: "A1",
      answer: "bekleyiş",
      quest: "wait"),
  Words(
      front: "My wife is cooking dinner.",
      back: "Karım akşam yemeği pişiriyor.",
      list: "A1",
      answer: "eş",
      quest: "wife"),
  Words(
      front: "Have you written your will yet?",
      back: "Vasiyetinizi henüz yazdınız mı?",
      list: "A1",
      answer: "vasiyet",
      quest: "will"),
  Words(
      front: "Which movie do you want to watch?",
      back: "Hangi filmi izlemek istiyorsun?",
      list: "A1",
      answer: "hangi",
      quest: "Which"),
  Words(
      front: "Today is Wednesday.",
      back: "Bugün Çarşamba.",
      list: "A1",
      answer: "Çarşamba",
      quest: "Wednesday"),
  Words(
      front: "I have been studying hard all week",
      back: "Tüm hafta boyunca çok çalıştım.",
      list: "A1",
      answer: "hafta",
      quest: "week"),
  Words(
      front: "The weather is nice today.",
      back: "Hava bugün güzel.",
      list: "A1",
      answer: "hava",
      quest: "weather"),
  Words(
      front: "Learning English is useful for your future.",
      back: "İngilizce öğrenmek geleceğin için faydalıdır.",
      list: "A1",
      answer: "faydalı",
      quest: "useful"),
  Words(
      front: "Would you like some soup for lunch?",
      back: "Öğle yemeğinde çorba ister misin?",
      list: "A1",
      answer: "çorba",
      quest: "soup"),
  Words(
      front: "I want to see the Eiffel Tower in person someday.",
      back: "Bir gün Eyfel Kulesini şahsen görmek istiyorum.",
      list: "A1",
      answer: "görmek",
      quest: "see"),
  Words(
      front: "The nurse helped me when I got hurt.",
      back: "Hemşire, yaralandığımda bana yardım etti.",
      list: "A1",
      answer: "hemşire",
      quest: "nurse"),
  Words(
      front: "We are going shopping this Saturday.",
      back: "Bu Cumartesi günü alışverişe gidiyoruz.",
      list: "A1",
      answer: "Cumartesi",
      quest: "Saturday"),
  Words(
      front: "The class starts from 9 o'clock in the morning.",
      back: "Ders sabah saat 9'dan itibaren başlar.",
      list: "A1",
      answer: "itibaren",
      quest: "from"),
  Words(
      front: "Summer starts in June.",
      back: "Yaz, Haziran ayında başlar.",
      list: "A1",
      answer: "Haziran",
      quest: "June"),
  Words(
      front: "Plants grow faster in warm weather.",
      back: "Bitkiler sıcak havalarda daha hızlı büyür.",
      list: "A1",
      answer: "yetişmek",
      quest: "grow"),
  Words(
      front: "Can I have a glass of water, please?",
      back: "Lütfen bir bardak su alabilir miyim?",
      list: "A1",
      answer: "bardak, cam",
      quest: "glass"),
  Words(
      front: "I have a job interview next week.",
      back: "Gelecek hafta bir iş görüşmem var.",
      list: "A1",
      answer: "görüşme",
      quest: "interview"),
  Words(
      front: "Each student received a certificate.",
      back: "Her öğrenci bir sertifika aldı.",
      list: "A1",
      answer: "her biri",
      quest: "Each"),
  Words(
      front: "August is the hottest month of the year in many places.",
      back: "Ağustos, birçok yerde yılın en sıcak ayıdır.",
      list: "A1",
      answer: "Ağustos",
      quest: "August"),
  Words(
      front: "I would like a banana for a snack.",
      back: "Atıştırmalık olarak muz isterim.",
      list: "A1",
      answer: "muz",
      quest: "banana"),
  Words(
      front: "I am going to take a bath before bed.",
      back: "Yatmadan önce banyo yapacağım.",
      list: "A1",
      answer: "banyo",
      quest: "bath"),
  Words(
      front: "Let's discuss this issue further.",
      back: "Hadi bu konuyu daha fazla tartışalım.",
      list: "A1",
      answer: "tartışmak",
      quest: "discuss"),
  Words(
      front: "Can you please wash the dishes?",
      back: "Lütfen bulaşıkları yıkayabilir misin?",
      list: "A1",
      answer: "tabak",
      quest: "dish"),
  Words(
      front: "He looked angry when I told him the news.",
      back: "Haberi söylediğimde bana kızgın görünüyordu.",
      list: "A1",
      answer: "kızgın",
      quest: "angry"),
  Words(
      front: "Milk comes from cows.",
      back: "Süt ineklerden gelir.",
      list: "A1",
      answer: "inek",
      quest: "cow"),
  Words(
      front: "It is cold in December.",
      back: "Aralık ayında hava soğuktur.",
      list: "A1",
      answer: "Aralık",
      quest: "December"),
  Words(
      front: "I went to the shop to buy some groceries.",
      back: "Alışveriş yapmak için markete gittim.",
      list: "A1",
      answer: "mağaza",
      quest: "shop"),
  Words(
      front: "You should have been here twenty minutes ago.",
      back: "Yirmi dakika önce burada olmalıydın.",
      list: "A1",
      answer: "önce",
      quest: "ago"),
];
