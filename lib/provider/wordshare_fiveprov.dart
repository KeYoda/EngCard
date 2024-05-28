import 'package:eng_card/data/gridview.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WordProvider5 extends ChangeNotifier {
  List<Words5> initialList5 = [];
  int lastIndex = 0;

  Future<void> _loadLastIndex() async {
    final prefs = await SharedPreferences.getInstance();
    lastIndex = prefs.getInt('lastIndex') ?? 0;
    notifyListeners(); // Notify listeners about the loaded index
  }

  Future<void> _saveLastIndex() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('lastIndex', lastIndex);
  }

  void setLastIndex(int index) {
    lastIndex = index;
    _saveLastIndex();
    notifyListeners(); // Notify listeners about the updated index
  }

  WordProvider5() {
    loadData5();
    _loadLastIndex();
    wordsListFive.shuffle();
    initialList5.shuffle();
    initialList5.addAll(wordsListFive);
  }

  void loadData5() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    List<String>? questList5 = prefs.getStringList('questList5');
    List<String>? answerList5 = prefs.getStringList('answerList5');
    List<String>? backList5 = prefs.getStringList('backList5');
    List<String>? frontList5 = prefs.getStringList('frontList5');

    wordsListFive.clear(); // Mevcut listeyi temizle

    if (questList5 != null &&
        answerList5 != null &&
        backList5 != null &&
        frontList5 != null) {
      for (int i = 0; i < questList5.length; i++) {
        Words5 word5 = Words5(
          list: 'C1',
          answer: answerList5[i],
          quest: questList5[i],
          back: backList5[i],
          front: frontList5[i],
        );
        wordsListFive.add(word5);
      }
    }

    notifyListeners();
  }

  void saveData5() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> questList5 = [];
    List<String> answerList5 = [];
    List<String> backList5 = [];
    List<String> frontList5 = [];

    for (Words5 word5 in wordsListFive) {
      questList5.add(word5.quest);
      answerList5.add(word5.answer);
      frontList5.add(word5.front);
      backList5.add(word5.back);
    }

    prefs.setStringList('questList5', questList5);
    prefs.setStringList('answerList5', answerList5);
    prefs.setStringList('backList5', backList5);
    prefs.setStringList('frontList5', frontList5);
    notifyListeners();
  }

  void deleteWord5(int index, BuildContext context) {
    if (wordsListFive.isNotEmpty) {
      wordsListFive.removeAt(index);
      if (index == wordsListFive.length) {
        // Silinen öğe son öğeyse
        lastIndex--;
      }
      if (wordsListFive.isEmpty) {
        Navigator.pop(context);
      } else {
        saveData5();
        notifyListeners();
      }
    }
  }

  void resetList5() {
    wordsListFive.clear(); // Mevcut listeyi sıfırla

    // Başlangıç verilerini başlangıç listesi ile güncelle
    wordsListFive.addAll(initialList5);

    saveData5();
    notifyListeners(); // Değişiklikleri bildir
  }

  List<Words5> wordsListFive = [
    Words5(
        front: "The government decided to abolish the old law.",
        back: "Hükümet, eski yasayı yürürlükten kaldırmaya karar verdi.",
        list: 'C1',
        answer: 'yürürlükten kaldırmak',
        quest: 'abolish'),
    Words5(
        front: "There was a complete absence of sound in the silent room.",
        back: "Sessiz odada tamamen yokluk,bulunmayış vardı.",
        list: 'C1',
        answer: 'yokluk,bulunmayış',
        quest: 'absence'),
    Words5(
        front: "The teacher was absent from school due to illness.",
        back: "Öğretmen hastalık nedeniyle okulda mevcut değildi.",
        list: 'C1',
        answer: 'absent',
        quest: 'absent'),
    Words5(
        front: "The land had an abundance of natural resources.",
        back: "Toprak, doğal kaynakların çokluğu,bolluğu vardı.",
        list: 'C1',
        answer: 'çokluk,bolluk',
        quest: 'abundance'),
    Words5(
        front: "Drug abuse is a serious problem in many societies.",
        back:
            "Uyuşturucu madde kötüye kullanımı birçok toplumda ciddi bir sorundur.",
        list: 'C1',
        answer: 'kötüye kullanmak',
        quest: 'abuse'),
    Words5(
        front:
            "The car accelerated quickly as it pulled away from the stop sign.",
        back: "Araba stop işaretinden uzaklaşırken hızlandı.",
        list: 'C1',
        answer: 'hızlanmak',
        quest: 'accelerate'),
    Words5(
        front: "Her acceptance speech was filled with gratitude.",
        back: "Her kabul konuşması minnettarlıkla doluydu.",
        list: 'C1',
        answer: 'kabul',
        quest: 'acceptance'),
    Words5(
        front: "The library is accessible to everyone in the community.",
        back: "Kütüphane, toplumdaki herkes için ulaşılabilir.",
        list: 'C1',
        answer: 'ulaşılabilir',
        quest: 'accessible'),
    Words5(
        front:
            "Winning the gold medal was a great accomplishment for the athlete.",
        back: "Altın madalya kazanmak, sporcu için büyük bir başarıydı.",
        list: 'C1',
        answer: 'başarma',
        quest: 'accomplishment'),
    Words5(
        front: "He acted in accordance with the company's policies.",
        back: "Şirketin politikalarına uygun hareket etti.",
        list: 'C1',
        answer: 'uygunluk',
        quest: 'accordance'),
    Words5(
        front: "Accordingly, we need to change our approach.",
        back: "Bu sebepten dolayı, yaklaşımımızı değiştirmemiz gerekiyor.",
        list: 'C1',
        answer: 'bu sebepten',
        quest: 'accordingly'),
    Words5(
        front:
            "The police investigation revealed a series of accusations of corruption.",
        back: "Polis soruşturması bir dizi yolsuzluk suçlaması ortaya çıkardı.",
        list: 'C1',
        answer: 'itham,suçlama',
        quest: 'accusation'),
    Words5(
        front: "The accused man pleaded not guilty in court.",
        back: "Suçlanan adam mahkemede suçsuz olduğunu iddia etti.",
        list: 'C1',
        answer: 'zanlı,suçlu',
        quest: 'accused'),
    Words5(
        front:
            "The company's recent acquisition of a new startup has expanded its market reach.",
        back:
            "Şirketin yakın zamanda yeni bir girişimin satın alınması pazar erişimini genişletti.",
        list: 'C1',
        answer: 'kazanma',
        quest: 'acquisition'),
    Words5(
        front:
            "The farmer owns a large plot of land that is hundreds of acres.",
        back: "Çiftçi, yüzlerce dönüm büyüklüğünde geniş bir araziye sahiptir.",
        list: 'C1',
        answer: 'arazi',
        quest: 'acre'),
    Words5(
        front: "The activation of the security system deterred the burglar.",
        back: "Güvenlik sisteminin etkinleşmesi hırsızı caydırdı.",
        list: 'C1',
        answer: 'etkinleşme',
        quest: 'activation'),
    Words5(
        front: "He was suffering from acute pain after the accident.",
        back: "Kazadan sonra şiddetli ağrı çekiyordu.",
        list: 'C1',
        answer: 'şiddetli',
        quest: 'acute'),
    Words5(
        front: "Many species are struggling to adapt to the changing climate.",
        back:
            "Birçok tür, değişen iklime adaptasyon sağlamak için mücadele ediyor.",
        list: 'C1',
        answer: 'adaptasyon',
        quest: 'adaptation'),
    Words5(
        front: "Students must adhere to the school rules.",
        back: "Öğrenciler okul kurallarına uymalıdır.",
        list: 'C1',
        answer: 'bağlı kalmak',
        quest: 'adhere'),
    Words5(
        front: "The two buildings are adjacent to each other.",
        back: "İki bina birbirine komşu.",
        list: 'C1',
        answer: 'komşu',
        quest: 'adjacent'),
    Words5(
        front: "The doctor made some adjustments to the medication dosage.",
        back: "Doktor, ilaç dozunda bazı ayarlama yaptı.",
        list: 'C1',
        answer: 'ayarlama',
        quest: 'adjustment'),
    Words5(
        front: "The government administers a variety of social programs.",
        back: "Hükümet çeşitli sosyal programları yönetir.",
        list: 'C1',
        answer: 'yönetmek',
        quest: 'administer'),
    Words5(
        front: "He works in an administrative role at the university.",
        back: "Üniversitede idari bir görevde çalışıyor.",
        list: 'C1',
        answer: 'idari',
        quest: 'administrative'),
    Words5(
        front: "The school principal is the administrator in charge.",
        back: "Okul müdürü sorumlu yönetici.",
        list: 'C1',
        answer: 'yönetici',
        quest: 'administrator'),
    Words5(
        front: "He finally made the admission that he had cheated on the exam.",
        back: "Nihayet sınavda kopya çektiğini itiraf etti.",
        list: 'C1',
        answer: 'itiraf',
        quest: 'admission'),
    Words5(
        front: "The teenager is going through a difficult adolescent stage.",
        back: "Genç, zor bir ergenlik dönemi yaşıyor.",
        list: 'C1',
        answer: 'ergen',
        quest: 'adolescent'),
    Words5(
        front: "The couple decided to pursue adoption to grow their family.",
        back:
            "Çift, ailelerini büyütmek için evlat edinme yoluna gitmeye karar verdi.",
        list: 'C1',
        answer: 'benimseme',
        quest: 'adoption'),
    Words5(
        front:
            "The weather forecast predicts adverse weather conditions this weekend.",
        back:
            "Hava durumu tahmini, bu hafta sonu olumsuz hava koşulları öngörüyor.",
        list: 'C1',
        answer: 'olumsuz',
        quest: 'adverse'),
    Words5(
        front: "The lawyer advocated for the rights of the refugees.",
        back: "Avukat, mültecilerin haklarını savundu.",
        list: 'C1',
        answer: 'avukat,desteklemek',
        quest: 'advocate'),
    Words5(
        front:
            "He has a great appreciation for the aesthetic beauty of nature.",
        back: "Doğanın estetik güzelliği konusunda büyük bir takdiri var.",
        list: 'C1',
        answer: 'estetik',
        quest: 'aesthetic'),
    Words5(
        front: "There was a deep affection between the mother and her child.",
        back: "Anne ile çocuğu arasında derin bir sevgi vardı.",
        list: 'C1',
        answer: 'alaka,etkileme',
        quest: 'affection'),
    Words5(
        front:
            "The aftermath of the war left a trail of destruction and despair.",
        back: "Savaşın akıbeti, yıkım ve umutsuzluk izi bıraktı.",
        list: 'C1',
        answer: 'akıbet',
        quest: 'aftermath'),
    Words5(
        front: "The child's aggressive behavior was a concern for his parents.",
        back: "Çocuğun saldırganlığı, ebeveynleri için bir endişe kaynağıydı.",
        list: 'C1',
        answer: 'saldırganlık',
        quest: 'aggression'),
    Words5(
        front:
            "He works in the agricultural sector, growing fruits and vegetables.",
        back: "Tarım sektöründe çalışıyor, meyve ve sebze yetiştiriyor.",
        list: 'C1',
        answer: 'tarım',
        quest: 'agricultural'),
    Words5(
        front: "The king's advisor was a trusted aide who offered him counsel.",
        back: "Kralın danışmanı, ona öğüt veren güvenilir bir yardımcısıydı.",
        list: 'C1',
        answer: 'emir kulu',
        quest: 'aide'),
    Words5(
        front: "The plan has some flaws, albeit minor ones.",
        back: "Planın bazı kusurları var, yine de önemsiz.",
        list: 'C1',
        answer: 'yine',
        quest: 'albeit'),
    Words5(
        front: "The fire alarm went off, alerting everyone to the danger.",
        back: "Yangın alarmı çaldı ve herkesi tehlikeden haberdar etti.",
        list: 'C1',
        answer: 'alarma geçmek',
        quest: 'alert'),
    Words5(
        front: "Have you ever seen a movie about aliens from outer space?",
        back: "Uzaylılar hakkında uzaydan bir film gördünüz mü?",
        list: 'C1',
        answer: 'uzaylı',
        quest: 'alien'),
    Words5(
        front: "The soldiers aligned themselves in a straight line.",
        back: "Askerler kendilerini düz bir çizgi halinde sıraladılar.",
        list: 'C1',
        answer: 'sıralanmak',
        quest: 'align'),
    Words5(
        front:
            "The alignment of the planets is a rare astronomical phenomenon.",
        back: "Gezegenlerin hizalanması nadir bir astronomi olayıdır.",
        list: 'C1',
        answer: 'sıra',
        quest: 'alignment'),
    Words5(
        front:
            "They are alike in many ways, but they also have some differences.",
        back: "Birçok yönden benzeşiyorlar, ancak bazı farklılıkları da var.",
        list: 'C1',
        answer: 'benzeyen',
        quest: 'alike'),
    Words5(
        front:
            "The police are investigating the allegations of corruption against the politician.",
        back: "Polis, siyasetçiye yönelik yolsuzluk suçlamalarını araştırıyor.",
        list: 'C1',
        answer: 'suçlama',
        quest: 'allegation'),
    Words5(
        front: "He alleged that the company was mistreating its employees.",
        back: "Şirketin çalışanlarına kötü muamele ettiğini iddia etti.",
        list: 'C1',
        answer: 'iddia etmek',
        quest: 'allege'),
    Words5(
        front: "The politician was allegedly involved in a bribery scandal.",
        back: "Siyasetçi, iddiaya göre bir rüşvet skandalına karışmıştı.",
        list: 'C1',
        answer: 'iddiaya göre',
        quest: 'allegedly'),
    Words5(
        front:
            "The two countries formed a strong alliance to defend against a common enemy.",
        back:
            "İki ülke, ortak bir düşmana karşı savunmak için güçlü bir ittifak kurdu.",
        list: 'C1',
        answer: 'antlaşma',
        quest: 'alliance'),
    Words5(
        front:
            "The teacher gave each student a small allowance for school supplies.",
        back:
            "Öğretmen, her öğrenciye okul malzemeleri için az bir izin verdi.",
        list: 'C1',
        answer: 'izin',
        quest: 'allowance'),
    Words5(
        front: "The United States and France are long-standing allies.",
        back:
            "Amerika Birleşik Devletleri ve Fransa uzun süredir müttefik ülkelerdir.",
        list: 'C1',
        answer: 'müttefik ülke',
        quest: 'ally'),
    Words5(
        front:
            "The ambassador represents her country's interests in a foreign nation.",
        back:
            "Büyükelçi, ülkesinin çıkarlarını yabancı bir ülkede temsil eder.",
        list: 'C1',
        answer: 'elçi',
        quest: 'ambassador'),
    Words5(
        front: "The legislators are proposing amendments to the tax code.",
        back: "Yasama organı üyeleri, vergi kodunda değişiklikler öneriyor.",
        list: 'C1',
        answer: 'düzeltmek',
        quest: 'amend'),
    Words5(
        front: "The amendment to the constitution failed to pass.",
        back: "Anayasaya getirilen değişiklik kabul edilmedi.",
        list: 'C1',
        answer: 'yasayı değiştirme',
        quest: 'amendment'),
    Words5(
        front: "He felt lost amid the chaos of the city.",
        back: "Şehrin karmaşası içinde kendini kaybolmuş hissetti.",
        list: 'C1',
        answer: 'arasında',
        quest: 'amid'),
    Words5(
        front:
            "The teacher used an analogy to explain a complex scientific concept.",
        back:
            "Öğretmen, karmaşık bir bilimsel kavramı açıklamak için mukayese kullandı.",
        list: 'C1',
        answer: 'mukayese',
        quest: 'analogy'),
    Words5(
        front: "The ship dropped anchor in the calm bay.",
        back: "Gemi, sakin koyda demir attı.",
        list: 'C1',
        answer: 'demir atmak',
        quest: 'anchor'),
    Words5(
        front:
            "Many cultures depict angels as winged beings with a divine purpose.",
        back:
            "Birçok kültür, melekleri ilahi bir amaçla kanatlı varlıklar olarak tasvir eder.",
        list: 'C1',
        answer: 'melek',
        quest: 'angel'),
    Words5(
        front:
            "The author chose to remain anonymous and did not reveal their identity.",
        back: "Yazar anonim kalmayı tercih etti ve kimliğini açıklamadı.",
        list: 'C1',
        answer: 'anonim',
        quest: 'anonymous'),
    Words5(
        front:
            "The scientist invented a new apparatus to measure the speed of light.",
        back: "Bilim insanı, ışık hızını ölçmek için yeni bir cihaz icat etti.",
        list: 'C1',
        answer: 'vasıta',
        quest: 'apparatus'),
    Words5(
        front: "The delicious food was very appealing to his appetite.",
        back: "Lezzetli yemek iştahına çok çekici geliyordu.",
        list: 'C1',
        answer: 'iştah',
        quest: 'appetite'),
    Words5(
        front:
            "The audience applauded thunderously after the singer's performance.",
        back: "Şarkıcının performansından sonra seyirci coşkuyla alkışladı.",
        list: 'C1',
        answer: 'alkışlamak',
        quest: 'applaud'),
    Words5(
        front: "These safety regulations are not applicable to all situations.",
        back:
            "Bu güvenlik yönetmelikleri tüm durumlar için uygulanabilir değildir.",
        list: 'C1',
        answer: 'uygulanabilir',
        quest: 'applicable'),
    Words5(
        front:
            "The board of directors appointed a new CEO to lead the company.",
        back: "Yönetim kurulu şirketi yönetecek yeni bir CEO atadı.",
        list: 'C1',
        answer: 'atamak',
        quest: 'appoint'),
    Words5(
        front: "She expressed her appreciation for the thoughtful gift.",
        back: "Düşünceli hediye için takdirini ifade etti.",
        list: 'C1',
        answer: 'takdir',
        quest: 'appreciation'),
    Words5(
        front: "The judge's decision seemed arbitrary and unfair.",
        back: "Hakimin kararı keyfi ve haksız görünüyordu.",
        list: 'C1',
        answer: 'keyfi',
        quest: 'arbitrary'),
    Words5(
        front:
            "The building's architectural design is both impressive and functional.",
        back: "Binanın mimari tasarımı hem etkileyici hem de işlevseldir.",
        list: 'C1',
        answer: 'mimarlığa ait',
        quest: 'architectural'),
    Words5(
        front:
            "Important documents are stored in the company archives for future reference.",
        back:
            "Önemli belgeler, gelecekte referans olması için şirket arşivlerinde saklanmaktadır.",
        list: 'C1',
        answer: 'arşiv',
        quest: 'archive'),
    Words5(
        front: "He is arguably the greatest basketball player of all time.",
        back: "Muhakkak ki tüm zamanların en iyi basketbol oyuncusudur.",
        list: 'C1',
        answer: 'muhtemelen',
        quest: 'arguably'),
    Words5(
        front: "He raised his arm to signal for a taxi.",
        back: "Taksi çağırmak için kolunu kaldırdı.",
        list: 'C1',
        answer: 'kol',
        quest: 'arm'),
    Words5(
        front: "The programmer created a complex array to store the data.",
        back: "Programcı, verileri depolamak için karmaşık bir dizi oluşturdu.",
        list: 'C1',
        answer: 'sıralamak',
        quest: 'array'),
    Words5(
        front: "She was unable to articulate her thoughts clearly.",
        back: "Düşüncelerini net bir şekilde ifade edemedi.",
        list: 'C1',
        answer: 'söylemek',
        quest: 'articulate'),
    Words5(
        front: "The fireplace was filled with ashes after the fire died down.",
        back: "Ateş söndükten sonra şömine kül doldu.",
        list: 'C1',
        answer: 'kül',
        quest: 'ash'),
    Words5(
        front:
            "She has a strong aspiration to become a doctor and help people.",
        back:
            "Doktor olmak ve insanlara yardım etmek için büyük bir hevesi var.",
        list: 'C1',
        answer: 'büyük amaç',
        quest: 'aspiration'),
    Words5(
        front:
            "He aspires to travel the world and experience different cultures.",
        back:
            "Dünyayı gezmek ve farklı kültürleri deneyimlemek için hevesleniyor.",
        list: 'C1',
        answer: 'heveslenmek',
        quest: 'aspire'),
    Words5(
        front:
            "The assassination of the political leader plunged the country into chaos.",
        back: "Siyasi liderin suikastı, ülkeyi kaosa sürükledi.",
        list: 'C1',
        answer: 'suikast',
        quest: 'assassination'),
    Words5(
        front: "The robber assaulted the old woman and stole her purse.",
        back: "Soyguncu yaşlı kadına saldırdı ve çantasını çaldı.",
        list: 'C1',
        answer: 'saldırmak',
        quest: 'assault'),
    Words5(
        front:
            "The workers assembled in the factory to discuss their working conditions.",
        back:
            "İşçiler çalışma koşullarını görüşmek üzere fabrikada toplandılar.",
        list: 'C1',
        answer: 'toplaşmak',
        quest: 'assemble'),
    Words5(
        front:
            "There will be a school assembly tomorrow morning to announce the new schedule.",
        back: "Yeni programı duyurmak için yarın sabah okul toplantısı olacak.",
        list: 'C1',
        answer: 'toplantı',
        quest: 'assembly'),
    Words5(
        front:
            "He asserted his dominance in the competition and won first place.",
        back: "Yarışmada hakimiyetini sürdürdü ve birinci oldu.",
        list: 'C1',
        answer: 'öne sürmek',
        quest: 'assert'),
    Words5(
        front:
            "The lawyer made a strong assertion that his client was innocent.",
        back:
            "Avukat, müvekkilinin masum olduğuna dair güçlü bir iddia ortaya attı.",
        list: 'C1',
        answer: 'iddia',
        quest: 'assertion'),
    Words5(
        front:
            "The therapist offered him reassurance and helped him manage his anxiety.",
        back:
            "Terapist ona güvence verdi ve kaygısıyla başa çıkmasına yardım etti.",
        list: 'C1',
        answer: 'güvence',
        quest: 'assurance'),
    Words5(
        front:
            "The refugees sought asylum in a neighboring country to escape the war.",
        back:
            "Mülteciler savaşa kaçmak için komşu bir ülkede sığınma hakkı aradılar.",
        list: 'C1',
        answer: 'barınak',
        quest: 'asylum'),
    Words5(
        front:
            "The war crimes committed by the soldiers were considered atrocities.",
        back: "Askerlerin işlediği savaş suçları vahşet olarak kabul edildi.",
        list: 'C1',
        answer: 'berbatlık',
        quest: 'atrocity'),
    Words5(
        front:
            "Through hard work and dedication, she finally attained her goal of becoming a lawyer.",
        back:
            "Çok çalışarak ve özveriyle nihayet avukat olma hedefini gerçekleştirdi.",
        list: 'C1',
        answer: 'elde etmek',
        quest: 'attain'),
    Words5(
        front: "The lawyer represented her client in court.",
        back: "Avukat, müvekkilini mahkemede temsil etti.",
        list: 'C1',
        answer: 'dava vekili',
        quest: 'attorney'),
    Words5(
        front: "He attributed his success to hard work and perseverance.",
        back: "Başarısını sıkı çalışmaya ve azme bağladı.",
        list: 'C1',
        answer: 'bağlamak',
        quest: 'attribute'),
    Words5(
        front:
            "The company is undergoing an audit to ensure its financial records are accurate.",
        back:
            "Şirket, mali kayıtlarının doğru olduğundan emin olmak için denetimden geçiyor.",
        list: 'C1',
        answer: 'hesapları denetlemek',
        quest: 'audit'),
    Words5(
        front:
            "The antique furniture store sells authentic pieces from different historical periods.",
        back:
            "Antika mobilya mağazası, farklı tarih dönemlerinden orijinal parçalar satıyor.",
        list: 'C1',
        answer: 'özgün',
        quest: 'authentic'),
    Words5(
        front:
            "The manager is not authorized to make such a large purchase without approval.",
        back:
            "Müdür, onay almadan bu kadar büyük bir satın alma işlemi yapmaya yetkili değildir.",
        list: 'C1',
        answer: 'yetki vermek',
        quest: 'authorize'),
    Words5(
        front: "He arrived at the meeting in a luxury auto.",
        back: "Toplantıya lüks bir otomobil ile geldi.",
        list: 'C1',
        answer: 'otomobil',
        quest: 'auto'),
    Words5(
        front:
            "Scotland has a strong movement for autonomy from the United Kingdom.",
        back:
            "İskoçya, Birleşik Krallık'tan özerklik için güçlü bir harekete sahip.",
        list: 'C1',
        answer: 'özerklik',
        quest: 'autonomy'),
    Words5(
        front:
            "We will check the availability of the rooms before booking our vacation.",
        back:
            "Tatilimizi rezerve etmeden önce odaların müsaitliğini kontrol edeceğiz.",
        list: 'C1',
        answer: 'geçerlilik',
        quest: 'availability'),
    Words5(
        front: "He is eagerly awaiting the results of his job application.",
        back: "İş başvurusunun sonuçlarını heyecanla bekliyor.",
        list: 'C1',
        answer: 'gözlemek',
        quest: 'await'),
    Words5(
        front: "The play took place against a backdrop of a bustling city.",
        back: "Oyun, hareketli bir şehrin arka planında gerçekleşti.",
        list: 'C1',
        answer: 'arka fon eklemek',
        quest: 'backdrop'),
    Words5(
        front:
            "She received a lot of backing from her family and friends during her difficult time.",
        back: "Zor zamanlarında ailesi ve arkadaşlarından çok destek aldı.",
        list: 'C1',
        answer: 'yardım',
        quest: 'backing'),
    Words5(
        front:
            "He always keeps a backup of his important files in case of a computer crash.",
        back:
            "Bilgisayar çökmesi durumunda önemli dosyalarının her zaman bir yedeğini tutar.",
        list: 'C1',
        answer: 'yedek',
        quest: 'backup'),
    Words5(
        front:
            "The suspect was released on bail after paying a large sum of money.",
        back:
            "Şüpheli, yüklü bir miktar para ödeyerek kefaletle serbest bırakıldı.",
        list: 'C1',
        answer: 'kefalet',
        quest: 'bail'),
    Words5(
        front:
            "Voters cast their ballots in the election for their preferred candidate.",
        back:
            "Seçmenler, oy pusulalarını seçtikleri aday için seçimde kullandılar.",
        list: 'C1',
        answer: 'oy vermek',
        quest: 'ballot'),
    Words5(
        front:
            "The protesters held banners with slogans demanding social justice.",
        back:
            "Protestocular, sosyal adalet talep eden sloganlar bulunan pankartlar taşıdılar.",
        list: 'C1',
        answer: 'pankart',
        quest: 'banner'),
    Words5(
        front: "He barely escaped the accident with just a few scratches.",
        back: "Kazadan sadece birkaç sıyrıkla zar zor kurtuldu.",
        list: 'C1',
        answer: 'çıkarmak',
        quest: 'bare'),
    Words5(
        front:
            "The pirates buried their treasure in a barrel on a deserted island.",
        back: "Korsanlar hazinelerini ıssız bir adada bir varile gömdüler.",
        list: 'C1',
        answer: 'varil',
        quest: 'barrel'),
    Words5(
        front: "The baseball player swung the bat and hit a home run.",
        back: "Beyzbol oyuncusu sopayı salladı ve bir sayılık home run yaptı.",
        list: 'C1',
        answer: 'yarasa',
        quest: 'bat'),
    Words5(
        front:
            "The soldiers bravely fought on the battlefield despite the dangers.",
        back: "Askerler tehlikelere rağmen savaş alanında cesurca savaştılar.",
        list: 'C1',
        answer: 'savaş alanı',
        quest: 'battlefield'),
    Words5(
        front:
            "The winner of the race will be crowned with a laurel bay wreath.",
        back:
            "Yarışın kazananı defne yapraklarından oluşan bir çelenkle taçlandırılacak.",
        list: 'C1',
        answer: 'defne',
        quest: 'bay'),
    Words5(
        front:
            "The scientist studied the properties of light beams using a laser.",
        back:
            "Bilim insanı, lazer kullanarak ışık ışınlarının özelliklerini inceledi.",
        list: 'C1',
        answer: 'ışın',
        quest: 'beam'),
    Words5(
        front:
            "The fairy tale depicted a fearsome beast guarding a hidden treasure.",
        back:
            "Masal, gizli bir hazineyi koruyan korkunç bir canavarı tasvir ediyordu.",
        list: 'C1',
        answer: 'hayvan',
        quest: 'beast'),
    Words5(
        front: "The lawyer spoke on behalf of his client in court.",
        back: "Avukat, mahkemede müvekkili adına konuştu.",
        list: 'C1',
        answer: 'biri adına',
        quest: 'behalf'),
    Words5(
        front:
            "She is her beloved grandmother, and they have a very close relationship.",
        back: "O, sevgili büyükannesi ve çok yakın bir ilişkileri var.",
        list: 'C1',
        answer: 'sevgili',
        quest: 'beloved'),
    Words5(
        front: "He sat on a park bench and enjoyed the sunshine.",
        back: "Parktaki bir sıraya oturdu ve güneşin tadını çıkardı.",
        list: 'C1',
        answer: 'sıra',
        quest: 'bench'),
    Words5(
        front:
            "This new software program sets the benchmark for performance in its category.",
        back:
            "Bu yeni yazılım programı, kendi kategorisinde performans için bir değerlendirme standardı oluşturuyor.",
        list: 'C1',
        answer: 'değerlendirme',
        quest: 'benchmark'),
    Words5(
        front:
            "The lost treasure is hidden somewhere beneath the castle ruins.",
        back: "Kayıp hazine, kale kalıntılarının altında bir yerde gizlidir.",
        list: 'C1',
        answer: 'altında',
        quest: 'beneath'),
    Words5(
        front:
            "The scholarship will be awarded to the most deserving beneficiary.",
        back: "Burs, en hak sahibi olan kişiye verilecektir.",
        list: 'C1',
        answer: 'hak sahibi',
        quest: 'beneficiary'),
    Words5(
        front:
            "He felt betrayed by his closest friend who revealed his secret.",
        back:
            "En yakın arkadaşı sırrını açıklayarak ona ihanet ettiğini hissetti.",
        list: 'C1',
        answer: 'ihanet etmek',
        quest: 'betray'),
    Words5(
        front: "Her wrists were bound with rope to prevent her from escaping.",
        back: "Kaçmasını önlemek için bilekleri ip ile bağlandı.",
        list: 'C1',
        answer: 'ciltlemek',
        quest: 'bind'),
    Words5(
        front:
            "The biography tells the story of the famous scientist's life and achievements.",
        back:
            "Biyografi, ünlü bilim insanının hayatını ve başarılarını anlatan bir yaşam öyküsüdür.",
        list: 'C1',
        answer: 'yaşam öyküsü',
        quest: 'biography'),
    Words5(
        front:
            "The chess piece called the bishop can move diagonally across the board.",
        back:
            "Piskopos adı verilen satranç taşı, tahtada çapraz olarak hareket edebilir.",
        list: 'C1',
        answer: 'piskopos',
        quest: 'bishop'),
    Words5(
        front:
            "The movie had a bizarre plot with strange characters and events.",
        back:
            "Filmin, garip karakterler ve olaylar içeren acayip bir konusu vardı.",
        list: 'C1',
        answer: 'garip',
        quest: 'bizarre'),
    Words5(
        front:
            "The knife had a sharp blade that could easily cut through meat.",
        back: "Bıçağın etleri kolayca kesebilecek keskin bir ağzı vardı.",
        list: 'C1',
        answer: 'bıçak ağzı',
        quest: 'blade'),
    Words5(
        front:
            "The explosion caused a loud blast that shattered windows in nearby buildings.",
        back:
            "Patlama, yakındaki binalardaki pencereleri parçalayan yüksek sesli bir gürültüye neden oldu.",
        list: 'C1',
        answer: 'büyük patlama',
        quest: 'blast'),
    Words5(
        front: "The injured athlete continued to bleed after the accident.",
        back: "Yaralanan sporcu kaza sonrası kan kaybetmeye devam etti.",
        list: 'C1',
        answer: 'para sızdırmak',
        quest: 'bleed'),
    Words5(
        front:
            "The artist skillfully blended different colors to create a beautiful painting.",
        back:
            "Sanatçı, güzel bir resim oluşturmak için farklı renkleri ustaca karıştırdı.",
        list: 'C1',
        answer: 'karıştırmak',
        quest: 'blend'),
    Words5(
        front: "She blessed her children before they left for school.",
        back: "Çocukları okula gitmeden önce kutsadı.",
        list: 'C1',
        answer: 'kutsamak',
        quest: 'bless'),
    Words5(
        front: "Good health and happiness are considered blessings in life.",
        back: "Sağlık ve mutluluk, hayattaki nimetler olarak kabul edilir.",
        list: 'C1',
        answer: 'nimet',
        quest: 'blessing'),
    Words5(
        front:
            "He avoided boasting about his achievements, even though he was very proud.",
        back:
            "Her ne kadar çok gurur duysa da başarılarıyla övünmekten kaçındı.",
        list: 'C1',
        answer: 'övünmek',
        quest: 'boast'),
    Words5(
        front:
            "He received a bonus at the end of the year for his outstanding work performance.",
        back: "Yıl sonunda olağanüstü iş performansı nedeniyle bir bonus aldı.",
        list: 'C1',
        answer: 'bonus',
        quest: 'bonus'),
    Words5(
        front: "The loud boom of thunder startled everyone in the house.",
        back: "Yüksek sesli gürültü herkesi korkuttu.",
        list: 'C1',
        answer: 'patlama sesi',
        quest: 'boom'),
    Words5(
        front: "The ball bounced high in the air after it was thrown.",
        back: "Top atıldıktan sonra havaya vurdu.",
        list: 'C1',
        answer: 'sektirmek',
        quest: 'bounce'),
    Words5(
        front:
            "The new agreement established clear boundaries between the two countries.",
        back: "Yeni anlaşma, iki ülke arasındaki net sınırlar belirledi.",
        list: 'C1',
        answer: 'sınır',
        quest: 'boundary'),
    Words5(
        front: "The archer elegantly drew her bow and released the arrow.",
        back: "Okçu zarif bir şekilde yayını çekti ve oku bıraktı.",
        list: 'C1',
        answer: 'yay',
        quest: 'bow'),
    Words5(
        front:
            "The company is taking legal action against them for breach of contract.",
        back:
            "Şirket, sözleşme ihlali nedeniyle onlara karşı yasal işlem başlatıyor.",
        list: 'C1',
        answer: 'uymama',
        quest: 'breach'),
    Words5(
        front: "His car suffered a complete breakdown on the highway.",
        back: "Arabası otoyolda tamamen bozuldu.",
        list: 'C1',
        answer: 'bozulma',
        quest: 'breakdown'),
    Words5(
        front:
            "The scientific breakthrough led to significant advancements in medical treatment.",
        back: "Bilimsel ilerleme, tıbbi tedavide önemli gelişmelere yol açtı.",
        list: 'C1',
        answer: 'ilerleme',
        quest: 'breakthrough'),
    Words5(
        front: "I'm trying to grow a new breed of tomato.",
        back: "Yeni bir domates türü yetiştirmeye çalışıyorum.",
        list: 'C1',
        answer: 'cins',
        quest: 'breed'),
    Words5(
        front:
            "He signed up for a broadband internet connection to enjoy faster download speeds.",
        back:
            "Daha hızlı indirme hızlarından yararlanmak için genişbant internet bağlantısına kaydoldu.",
        list: 'C1',
        answer: 'genişbant',
        quest: 'broadband'),
    Words5(
      front: "He used a web browser to surf the internet on his computer.",
      back: "Bilgisayarında internette gezinmek için bir tarayıcı kullandı.",
      list: "C1",
      answer: "tarayıcı",
      quest: "browser",
    ),

    Words5(
      front: "He saw a wild animal.",
      back: "Acımasız bir hayvan gördü.",
      list: "C1",
      answer: "vahşi",
      quest: "brutal",
    ),

    Words5(
      front: "He jumped into the water.",
      back: "Suya atladı.",
      list: "C1",
      answer: "sıçramak",
      quest: "buck",
    ),
    Words5(
      front: "He needs a good buddy to help him with this task.",
      back: "Bu işte ona yardım edecek iyi bir ahbap gerekiyor.",
      list: "C1",
      answer: "ahbap",
      quest: "buddy",
    ),

    Words5(
      front: "The technician added a buffer to prevent data overflow.",
      back: " teknisyen, veri taşmasının önüne geçmek için tampon ekledi.",
      list: "C1",
      answer: "tampon",
      quest: "buffer",
    ),

    Words5(
      front: "He bulked up for the upcoming boxing match.",
      back: "Yaklaşan boks maçı için kas yaptı.",
      list: "C1",
      answer: "büyütmek",
      quest: "bulk",
    ),

    Words5(
      front: "He felt burdened by his responsibilities.",
      back: "Sorumluluklarının ağırlığı altında eziliyordu.",
      list: "C1",
      answer: "sırtına yüklemek",
      quest: "burden",
    ),

    Words5(
      front: "The complex bureaucracy slowed down the process.",
      back: "Karmaşık bürokrasi süreci yavaşlattı.",
      list: "C1",
      answer: "bürokrasi",
      quest: "bureaucracy",
    ),

    Words5(
      front: "The Pharaoh's burial was filled with treasures.",
      back: "Firavun'un gömme töreni hazinelerle doluydu.",
      list: "C1",
      answer: "gömme",
      quest: "burial",
    ),

    Words5(
      front: "The balloon suddenly burst in mid-air.",
      back: "Balon aniden havada patladı.",
      list: "C1",
      answer: "patlamak",
      quest: "burst",
    ),

    Words5(
      front: "He organized his tools in a neat cabinet.",
      back: "Aletlerini düzgün bir dolaba yerleştirdi.",
      list: "C1",
      answer: "dolap",
      quest: "cabinet",
    ),

    Words5(
      front: "He made complex calculations to solve the problem.",
      back: "Sorunu çözmek için karmaşık hesaplamalar yaptı.",
      list: "C1",
      answer: "hesaplama",
      quest: "calculation",
    ),

    Words5(
      front: "The artist used a canvas to paint his masterpiece.",
      back: "Sanatçı, başyapıtını boyamak için bir tuval kullandı.",
      list: "C1",
      answer: "tuval",
      quest: "canvas",
    ),

    Words5(
      front: "She demonstrated her capability to lead the team.",
      back: "Takımı yönetme kabiliyetini gösterdi.",
      list: "C1",
      answer: "kabiliyet",
      quest: "capability",
    ),
    Words5(
      front:
          "Kapitalizm, özel mülkiyete ve serbest piyasaya dayanan ekonomik sistemdir.",
      back:
          "Capitalism is an economic system based on private ownership and free market.",
      list: "C1",
      answer: "sermayecilik",
      quest: "capitalism",
    ),

    Words5(
      front: "Sermayeci, yatırımlarıyla kâr elde etmeyi amaçlayan kişidir.",
      back:
          "A capitalist is a person who invests money with the aim of making a profit.",
      list: "C1",
      answer: "sermayeci",
      quest: "capitalist",
    ),

    Words5(
      front: "Gemi, büyük miktarda kargo taşıyordu.",
      back: "The ship was carrying a large amount of cargo.",
      list: "C1",
      answer: "kargo",
      quest: "cargo",
    ),

    Words5(
      front: "Malların taşınması için lojistik şirketiyle anlaştı.",
      back: "He contracted a logistics company for the carriage of goods.",
      list: "C1",
      answer: "taşımacılık",
      quest: "carriage",
    ),

    Words5(
      front: "Heykeltraş, mermeri dikkatlice oydu.",
      back: "The sculptor carefully carved the marble.",
      list: "C1",
      answer: "oymak",
      quest: "carve",
    ),

    Words5(
      front: "Kazanmayı seven arkadaşıyla birlikte casinoya gitti.",
      back: "He went to the casino with his friend who loves to gamble.",
      list: "C1",
      answer: "kumarhane",
      quest: "casino",
    ),

    Words5(
      front: "Kazada ölenlerin sayısı oldukça yüksekti.",
      back: "The number of casualties in the accident was very high.",
      list: "C1",
      answer: "kazazede",
      quest: "casualty",
    ),

    Words5(
      front: "He looked at the furniture store's catalogue to buy furniture.",
      back: "Mobilya almak için mobilya mağazasının kataloğuna baktı.",
      list: "C1",
      answer: "katalog",
      quest: "catalogue",
    ),

    Words5(
      front: "Parti için yiyecek ve içecek temin etti.",
      back: "He catered food and drinks for the party.",
      list: "C1",
      answer: "temin etmek",
      quest: "cater",
    ),

    Words5(
      front: "Çiftlikteki sığırlar sağlıklı görünüyordu.",
      back: "The cattle on the farm looked healthy.",
      list: "C1",
      answer: "sığır",
      quest: "cattle",
    ),

    Words5(
      front: "Geçerken yoldan geçen arabalara dikkat etti.",
      back: "He paid attention to the cars passing by on the road.",
      list: "C1",
      answer: "dikkat",
      quest: "caution",
    ),

    Words5(
      front: "Tedbirli bir insan olduğu için her zaman bir planı vardı.",
      back: "As a cautious person, he always had a plan.",
      list: "C1",
      answer: "tedbirli",
      quest: "cautious",
    ),

    Words5(
      front: "Artık şikayetleri dinlemekten vazgeçti.",
      back: "He finally ceased listening to the complaints.",
      list: "C1",
      answer: "son vermek",
      quest: "cease",
    ),
    Words5(
      front: "Visitors showed respect while walking through the cemetery.",
      back: "Ziyaretçiler, mezarlıkta dolaşırken saygı gösterdi.",
      list: "C1",
      answer: "mezarlık",
      quest: "cemetery",
    ),

    Words5(
      front: "A specially designed chamber was used for the experiment.",
      back: "Deney için özel olarak tasarlanmış bir chamber kullanıldı.",
      list: "C1",
      answer: "oda",
      quest: "chamber",
    ),

    Words5(
      front: "It was impossible to find anything due to the chaos in the room.",
      back: "Odadaki karmaşa nedeniyle bir şey bulmak imkansızdı.",
      list: "C1",
      answer: "karmaşa",
      quest: "chaos",
    ),

    Words5(
      front:
          "If we need to characterize Roman's personality, he is a loyal and honest person.",
      back:
          "Romanın kişiliğini nitelendirmek gerekirse, o sadık ve dürüst bir insandır.",
      list: "C1",
      answer: "nitelendirmek",
      quest: "characterize",
    ),

    Words5(
      front: "He was captivated by the charm of an old building.",
      back: "Eski bir binanın cazibesine kapıldı.",
      list: "C1",
      answer: "cazibe",
      quest: "charm",
    ),

    Words5(
      front: "Şirket, yeni buluşu için patent vermek için başvuruda bulundu.",
      back: "The company applied for a charter to patent their new invention.",
      list: "C1",
      answer: "patent vermek",
      quest: "charter",
    ),

    Words5(
      front: "Hastalığı kronikti ve tedavisi zordu.",
      back: "His illness was chronic and difficult to treat.",
      list: "C1",
      answer: "kronik",
      quest: "chronic",
    ),

    Words5(
      front: "Büyük bir bilgi yığını ile karşı karşıya kaldı.",
      back: "He was faced with a huge chunk of information.",
      list: "C1",
      answer: "yığın",
      quest: "chunk",
    ),

    Words5(
      front: "Haberin gazetelerde dolaşması birkaç gün sürdü.",
      back: "It took a few days for the news to circulate in the newspapers.",
      list: "C1",
      answer: "akımını sağlamak",
      quest: "circulate",
    ),

    Words5(
      front: "Derginin geniş bir sürümü vardı.",
      back: "The magazine had a wide circulation.",
      list: "C1",
      answer: "sürüm",
      quest: "circulation",
    ),

    Words5(
      front: "Yurttaşlık haklarını korumak önemlidir.",
      back: "It is important to protect citizenship rights.",
      list: "C1",
      answer: "yurttaşlık",
      quest: "citizenship",
    ),

    Words5(
      front: "Şehrin iyileştirilmesine yönelik civic projeler düzenlendi.",
      back: "Civic projects were organized for the improvement of the city.",
      list: "C1",
      answer: "şehir ile ilgili",
      quest: "civic",
    ),

    Words5(
      front: "Saldırıya siviller de dahil oldu.",
      back: "The attack also involved civilians.",
      list: "C1",
      answer: "sivil",
      quest: "civilian",
    ),
    Words5(
      back: "Cümlede kullanılan kelimelerin berraklığı anlamı netleştirdi.",
      front:
          "Clarity in the words used in the sentence made the meaning clear.",
      list: "C1",
      answer: "berraklık",
      quest: "clarity",
    ),

    Words5(
      back: "İki fikir çarpışması, çözüme ulaşmayı zorlaştırdı.",
      front: "The clash of two ideas made it difficult to reach a solution.",
      list: "C1",
      answer: "çarpışma",
      quest: "clash",
    ),

    Words5(
      back:
          "Bilim insanları, hayvanları sınıflandırma sistemleri geliştirdiler.",
      front: "Scientists developed classification systems for animals.",
      list: "C1",
      answer: "sınıflandırma",
      quest: "classification",
    ),

    Words5(
      back: "Umutsuzluğa tutunmaktan kendini alıkoyamadı.",
      front: "He couldn't stop himself from clinging to hope.",
      list: "C1",
      answer: "tutunmak",
      quest: "cling",
    ),

    Words5(
      back: "Doktor, hastayı kapsamlı bir klinik muayeneye aldı.",
      front: "The doctor gave the patient a thorough clinical examination.",
      list: "C1",
      answer: "klinik",
      quest: "clinical",
    ),

    Words5(
      back: "Okullar yaz tatili için kapanacak.",
      front: "Schools will be closed for summer vacation.",
      list: "C1",
      answer: "kapanma",
      quest: "closure",
    ),

    Words5(
      back: "Yıldızlar, gece gökyüzünde kümeler halinde parlıyordu.",
      front: "Stars twinkled in clusters in the night sky.",
      list: "C1",
      answer: "küme",
      quest: "cluster",
    ),

    Words5(
      back:
          "Farklı partilerin bir araya gelerek oluşturduğu koalisyon hükümeti kuruldu.",
      front:
          "A coalition government formed by different parties was established.",
      list: "C1",
      answer: "birleşme",
      quest: "coalition",
    ),

    Words5(
      back: "Ev, güzel bir sahil kasabasındaydı.",
      front: "The house was in a beautiful coastal town.",
      list: "C1",
      answer: "sahil",
      quest: "coastal",
    ),

    Words5(
      back: "Parıltılı bir kokteyl sipariş etti.",
      front: "He ordered a fancy cocktail.",
      list: "C1",
      answer: "kokteyl",
      quest: "cocktail",
    ),

    Words5(
      back: "Bilişsel yetenekleri yaşla birlikte azaldı.",
      front: "His cognitive abilities declined with age.",
      list: "C1",
      answer: "bilişsel",
      quest: "cognitive",
    ),

    Words5(
      back: "Tatillerimiz tesadüfen aynı zamana denk geldi.",
      front: "Our vacations coincided by chance.",
      list: "C1",
      answer: "kesişme",
      quest: "coincide",
    ),

    Words5(
      back: "Projeyi başarıyla tamamlamak için işbirliği yaptılar.",
      front: "They collaborated to successfully complete the project.",
      list: "C1",
      answer: "işbirliği yapma",
      quest: "collaborate",
    ),
    Words5(
      back: "Projenin başarısı, ekiplerin mükemmel işbirliğine bağlıydı.",
      front:
          "The success of the project depended on the excellent collaboration of the teams.",
      list: "C1",
      answer: "işbirliği",
      quest: "collaboration",
    ),

    Words5(
      back:
          "Toplu taşıma araçları genellikle sabah ve akşam saatlerinde kalabalık olur.",
      front:
          "Public transportation vehicles are usually crowded in the mornings and evenings.",
      list: "C1",
      answer: "toplu",
      quest: "collective",
    ),

    Words5(
      back: "Kazada iki araba çarpışma yaşadı.",
      front: "Two cars collided in the accident.",
      list: "C1",
      answer: "çarpışma",
      quest: "collision",
    ),

    Words5(
      back: "Osmanlı İmparatorluğu, sömürgeci bir güç olarak görülüyordu.",
      front: "The Ottoman Empire was seen as a colonial power.",
      list: "C1",
      answer: "sömürge",
      quest: "colonial",
    ),

    Words5(
      back: "Tanınmış köşe yazarı, güncel olaylar hakkında yorum yazdı.",
      front: "The well-known columnist wrote comments on current events.",
      list: "C1",
      answer: "köşe yazarı",
      quest: "columnist",
    ),

    Words5(
      back: "Şiddetli muharebe günlerce sürdü.",
      front: "The fierce combat lasted for days.",
      list: "C1",
      answer: "muharebe",
      quest: "combat",
    ),

    Words5(
      back: "Dersin sonunda derse başlamayı teklif etti.",
      front:
          "He suggested commencing the lesson at the end of the introduction.",
      list: "C1",
      answer: "başlatmak",
      quest: "commence",
    ),

    Words5(
      back: "Gazeteci, haber üzerine bir yorum yaptı.",
      front: "The journalist made a commentary on the news.",
      list: "C1",
      answer: "yorum",
      quest: "commentary",
    ),

    Words5(
      back: "Spiker, maçın heyecanını yorumcu olarak aktardı.",
      front:
          "The commentator conveyed the excitement of the match as a commentator.",
      list: "C1",
      answer: "yorumcu",
      quest: "commentator",
    ),

    Words5(
      back: "Ülke, dış ticaret sayesinde ekonomisini büyüttü.",
      front: "The country grew its economy thanks to commerce.",
      list: "C1",
      answer: "ticaret",
      quest: "commerce",
    ),

    Words5(
      back: "Şirket, fuara bir komiser gönderdi.",
      front: "The company sent a commissioner to the fair.",
      list: "C1",
      answer: "delege",
      quest: "commissioner",
    ),

    Words5(
      back: "Kahve, dünya çapında önemli bir ticaret metaasıdır.",
      front: "Coffee is an important commodity traded worldwide.",
      list: "C1",
      answer: "alıp satılan şey",
      quest: "commodity",
    ),

    Words5(
      back: "Yolculuk boyunca refakatçisi ona destek oldu.",
      front: "His companion supported him throughout the journey.",
      list: "C1",
      answer: "refakatçi",
      quest: "companion",
    ),
    Words5(
      back: "Bu iki ürün birbirine kıyaslanabilir.",
      front: "These two products are comparable.",
      list: "C1",
      answer: "kıyaslanabilir",
      quest: "comparable",
    ),

    Words5(
      back: "Hayvanlara karşı merhamet göstermeliyiz.",
      front: "We should show compassion towards animals.",
      list: "C1",
      answer: "merhamet",
      quest: "compassion",
    ),

    Words5(
      back: "Onu gitmeye zorlamak zorunda kaldım.",
      front: "I had to compel him to go.",
      list: "C1",
      answer: "zorlamak",
      quest: "compel",
    ),

    Words5(
      back: "Film, izleyicileri için zorlayıcı bir konuyu ele alıyor.",
      front: "The film tackles a compelling topic for viewers.",
      list: "C1",
      answer: "zorlu",
      quest: "compelling",
    ),

    Words5(
      back: "Kazaya uğradığı için tazminat talebinde bulundu.",
      front: "He filed a compensation claim because of the accident.",
      list: "C1",
      answer: "telafi etmek",
      quest: "compensate",
    ),

    Words5(
      back:
          "Uzun çalışma saatleri için ekstra maaş gibi bir telafi hak ediyor.",
      front:
          "He deserves some compensation, like extra pay, for the long working hours.",
      list: "C1",
      answer: "telafi",
      quest: "compensation",
    ),

    Words5(
      back: "Yeterliği sayesinde terfi aldı.",
      front: "He got promoted thanks to his competence.",
      list: "C1",
      answer: "yeterlik",
      quest: "competence",
    ),

    Words5(
      back: "Bu konuda yetkili birine danışmalısınız.",
      front: "You should consult someone competent in this matter.",
      list: "C1",
      answer: "yetkili",
      quest: "competent",
    ),

    Words5(
      back: "Verileri derleyerek bir rapor hazırladı.",
      front: "He compiled a report by compiling the data.",
      list: "C1",
      answer: "derlemek",
      quest: "compile",
    ),

    Words5(
      back: "Bu iki renk birbirini tamamlıyor.",
      front: "These two colors complement each other.",
      list: "C1",
      answer: "tamamlamak",
      quest: "complement",
    ),

    Words5(
      back: "Konunun karmaşıklığı nedeniyle anlamakta zorlandım.",
      front:
          "I had difficulty understanding due to the complexity of the subject.",
      list: "C1",
      answer: "karmaşıklık",
      quest: "complexity",
    ),

    Words5(
      back: "Kurallara riayet etmek önemlidir.",
      front: "It is important to comply with the rules.",
      list: "C1",
      answer: "riayet",
      quest: "compliance",
    ),

    Words5(
      back: "İşlemdeki bu komplikasyon çözülmedikçe ilerleyemeyiz.",
      front:
          "We cannot proceed until this complication in the process is resolved.",
      list: "C1",
      answer: "komplikasyon",
      quest: "complication",
    ),
    Words5(
      back: "Kurallara boyun eğmek zorunda kaldı.",
      front: "He had to comply with the rules.",
      list: "C1",
      answer: "boyun eğmek",
      quest: "comply",
    ),

    Words5(
      back: "Yarışmanın kompozisyonu şu şekildeydi: koşu, yüzme, bisiklet.",
      front:
          "The composition of the competition was as follows: running, swimming, cycling.",
      list: "C1",
      answer: "kompozisyon",
      quest: "composition",
    ),

    Words5(
      back: "Tartışmada her iki taraf da bir anlaşmaya vardı.",
      front: "In the argument, both sides reached a compromise.",
      list: "C1",
      answer: "anlaşmak",
      quest: "compromise",
    ),

    Words5(
      back: "Bilgisayar, karmaşık hesaplamaları saniyeler içinde yapabilir.",
      front: "The computer can perform complex computations in seconds.",
      list: "C1",
      answer: "hesaplamak",
      quest: "compute",
    ),

    Words5(
      back: "Suçunu gizlemeye çalıştı.",
      front: "He tried to conceal his crime.",
      list: "C1",
      answer: "gizlemek",
      quest: "conceal",
    ),

    Words5(
      back: "Rakibinin gücünü kabul etmek zorunda kaldı.",
      front: "He had to concede his opponent's strength.",
      list: "C1",
      answer: "kabullenmek",
      quest: "concede",
    ),

    Words5(
      back: "Mühendis, yeni bir köprü tasarladı.",
      front: "The engineer conceived a new bridge design.",
      list: "C1",
      answer: "tasarlamak",
      quest: "conceive",
    ),

    Words5(
      back: "Soyut bir düşünceyi somutlaştırmak zordur.",
      front: "It is difficult to concretize an abstract conception.",
      list: "C1",
      answer: "düşünce",
      quest: "conception",
    ),

    Words5(
      back: "Tartışmada bazı tavizler vermek zorunda kaldık.",
      front: "We had to make some concessions in the discussion.",
      list: "C1",
      answer: "taviz",
      quest: "concession",
    ),

    Words5(
      back: "Suçluyu müebbet hapse mahkum ettiler.",
      front: "They condemned the criminal to life imprisonment.",
      list: "C1",
      answer: "mahkum etmek",
      quest: "condemn",
    ),

    Words5(
      back: "Doktorlar hastayla konferans yaptılar.",
      front: "The doctors conferred with the patient.",
      list: "C1",
      answer: "müzakere etmek",
      quest: "confer",
    ),

    Words5(
      back: "Rahip, günah çıkarmak isteyenlerle görüştü.",
      front: "The priest met with those who wanted to confess.",
      list: "C1",
      answer: "günah çıkarma",
      quest: "confession",
    ),

    Words5(
      back: "Telefonun yeni konfigürasyonu daha kullanışlı.",
      front: "The new configuration of the phone is more user-friendly.",
      list: "C1",
      answer: "biçim",
      quest: "configuration",
    ),
    Words5(
      back: "Onu bodrum katına hapsetti.",
      front: "He confined him to the basement.",
      list: "C1",
      answer: "sınırlandırmak",
      quest: "confine",
    ),

    Words5(
      back: "Siparişinizin onaylanması için e-posta kontrol edin.",
      front: "Check your email for confirmation of your order.",
      list: "C1",
      answer: "onay",
      quest: "confirmation",
    ),

    Words5(
      back: "Polis memuru şüpheliyi suçla yüzleştirdi.",
      front: "The police officer confronted the suspect with the accusation.",
      list: "C1",
      answer: "yüzleştirmek",
      quest: "confront",
    ),

    Words5(
      back: "Görüşmedeki sert yüzleşme ortamı gerginliği artırdı.",
      front:
          "The tense confrontation during the meeting increased the tension.",
      list: "C1",
      answer: "yüzleşme",
      quest: "confrontation",
    ),

    Words5(
      back: "Başarısını tebrik etmek için ona çiçek gönderdim.",
      front: "I sent him flowers to congratulate him on his success.",
      list: "C1",
      answer: "tebrik etmek",
      quest: "congratulate",
    ),

    Words5(
      back: "Kilisenin cemaati Pazar ayinine katıldı.",
      front: "The congregation of the church attended the Sunday service.",
      list: "C1",
      answer: "topluluk",
      quest: "congregation",
    ),

    Words5(
      back: "Kongresel kararın oylanması yarın yapılacak.",
      front: "The voting on the congressional decision will be held tomorrow.",
      list: "C1",
      answer: "kongresel",
      quest: "congressional",
    ),

    Words5(
      back: "Romalılar, geniş toprakları fethetti.",
      front: "The Romans conquered vast territories.",
      list: "C1",
      answer: "fethetmek",
      quest: "conquer",
    ),

    Words5(
      back: "Vicdanı rahat değildi.",
      front: "His conscience was not clear.",
      list: "C1",
      answer: "vicdan",
      quest: "conscience",
    ),

    Words5(
      back: "Bilincinizi kaybettiniz mi?",
      front: "Did you lose consciousness?",
      list: "C1",
      answer: "bilinç",
      quest: "consciousness",
    ),

    Words5(
      back: "İki gün üst üste aynı filmi izledim.",
      front: "I watched the same movie two consecutive days.",
      list: "C1",
      answer: "ardışık",
      quest: "consecutive",
    ),

    Words5(
      back: "Toplantıda bir fikir birliğine varılmadı.",
      front: "No consensus was reached at the meeting.",
      list: "C1",
      answer: "fikir birliği",
      quest: "consensus",
    ),

    Words5(
      back: "Bu projenin yapılması için izniniz gerekiyor.",
      front: "Your consent is required for this project to proceed.",
      list: "C1",
      answer: "razı olmak",
      quest: "consent",
    ),
    Words5(
      back: "Enerjiyi korumak için ampulleri değiştirdik.",
      front: "We changed the bulbs to conserve energy.",
      list: "C1",
      answer: "korumak",
      quest: "conserve",
    ),

    Words5(
      back: "Davranışlarındaki tutarlılığa hayran kaldım.",
      front: "I admired the consistency in his behavior.",
      list: "C1",
      answer: "tutarlılık",
      quest: "consistency",
    ),

    Words5(
      back:
          "Kazanılan başarıyı sağlamlaştırmak için yeni stratejiler geliştirildi.",
      front:
          "New strategies were developed to consolidate the achieved success.",
      list: "C1",
      answer: "sağlamlaştırmak",
      quest: "consolidate",
    ),

    Words5(
      back: "Milletvekili, seçim bölgesindeki halkın sorunlarını dile getirdi.",
      front: "The MP voiced the problems of the people in his constituency.",
      list: "C1",
      answer: "seçim bölgesi",
      quest: "constituency",
    ),

    Words5(
      back: "Bu elementler bir atomu oluşturur.",
      front: "These elements constitute an atom.",
      list: "C1",
      answer: "oluşturmak",
      quest: "constitute",
    ),

    Words5(
      back: "Ülkenin en yüksek hukuk metni anayasadır.",
      front: "The constitution is the highest legal text of the country.",
      list: "C1",
      answer: "anayasa",
      quest: "constitution",
    ),

    Words5(
      back: "Bu karar anayasal mı?",
      front: "Is this decision constitutional?",
      list: "C1",
      answer: "anayasal",
      quest: "constitutional",
    ),

    Words5(
      back: "Bütçe kısıtlamaları nedeniyle projeyi tamamlamakta zorlandık.",
      front:
          "We faced difficulties completing the project due to budget constraints.",
      list: "C1",
      answer: "kısıtlama",
      quest: "constraint",
    ),

    Words5(
      front: "The doctor had a consultation with the patient.",
      back: "Doktor hastayla bir danışma yaptı.",
      list: "C1",
      answer: "danışma",
      quest: "consultation",
    ),

    Words5(
      back: "Gelecek hakkında uzun uzun düşünüp taşındı.",
      front: "He contemplated at length about the future.",
      list: "C1",
      answer: "düşünüp taşınmak",
      quest: "contemplate",
    ),

    Words5(
      back: "Davranışlarına karşı aşağılama hissettim.",
      front: "I felt contempt for his behavior.",
      list: "C1",
      answer: "aşağılama",
      quest: "contempt",
    ),

    Words5(
      back: "Şampiyonluk için yarışan iki güçlü rakip vardı.",
      front: "There were two strong contenders competing for the championship.",
      list: "C1",
      answer: "rakip",
      quest: "contender",
    ),

    Words5(
      back: "Bu konuda uzmanlarla uğraşmak zorunda kaldık.",
      front: "We had to contend with experts on this issue.",
      list: "C1",
      answer: "uğraşmak",
      quest: "contend",
    ),
    Words5(
      back: "Web sitesinin içeriğini güncelledik.",
      front: "We updated the content of the website.",
      list: "C1",
      answer: "içerik",
      quest: "content",
    ),

    Words5(
      back: "İki takım şampiyonluk için sürekli bir yarışma içindeydi.",
      front: "The two teams were in constant contention for the championship.",
      list: "C1",
      answer: "yarışma",
      quest: "contention",
    ),

    Words5(
      back: "Yağmur hiç durmadan yağıyordu.",
      front: "The rain was falling continually.",
      list: "C1",
      answer: "hiç durmadan",
      quest: "continually",
    ),

    Words5(
      back: "Bu inşaatın müteahhidi kim?",
      front: "Who is the contractor for this construction?",
      list: "C1",
      answer: "müteahhit",
      quest: "contractor",
    ),

    Words5(
      back: "Onun sözleri davranışlarıyla bir tezat oluşturuyor.",
      front: "His words contradict his behavior.",
      list: "C1",
      answer: "tezat",
      quest: "contradiction",
    ),

    Words5(
      back: "Emirlere zıt hareket etmeyin.",
      front: "Do not act contrary to the orders.",
      list: "C1",
      answer: "zıt",
      quest: "contrary",
    ),

    Words5(
      back: "Dergiye düzenli olarak yazı yazar.",
      front: "He is a regular contributor to the magazine.",
      list: "C1",
      answer: "yazar",
      quest: "contributor",
    ),

    Words5(
      back: "Paradan elektriğe enerji dönüşümü gerçekleşti.",
      front: "The conversion of energy from money to electricity took place.",
      list: "C1",
      answer: "dönüşüm",
      quest: "conversion",
    ),

    Words5(
      back: "Jüri onu suçlu buldu.",
      front: "The jury convicted him.",
      list: "C1",
      answer: "suçlu bulmak",
      quest: "convict",
    ),

    Words5(
      back: "Başarıya olan inancını kaybetmedi.",
      front: "He did not lose his conviction in success.",
      list: "C1",
      answer: "inanç",
      quest: "conviction",
    ),

    Words5(
      back: "Projeyi tamamlamak için işbirliği yapmak zorundayız.",
      front: "We need to cooperate to complete the project.",
      list: "C1",
      answer: "işbirliği yapmak",
      quest: "cooperate",
    ),

    Words5(
      back: "Polis memuru hırsızı yakaladı.",
      front: "The cop caught the thief.",
      list: "C1",
      answer: "polis memuru",
      quest: "cop",
    ),

    Words5(
      back: "Kablolar bakırdan yapılmıştır.",
      front: "The cables are made of copper.",
      list: "C1",
      answer: "bakır",
      quest: "copper",
    ),
    Words5(
      back: "Yazdığınız eserin telif hakkını korumak önemlidir.",
      front: "It is important to protect the copyright of the work you wrote.",
      list: "C1",
      answer: "telif hakkı",
      quest: "copyright",
    ),

    Words5(
      back: "Metindeki düzeltmeleri kırmızı kalemle işaretledim.",
      front: "I marked the corrections in the text with a red pen.",
      list: "C1",
      answer: "düzeltme",
      quest: "correction",
    ),

    Words5(
      back: "IQ seviyesi ile okul başarısı arasında bir ilişki var mı?",
      front: "Is there a correlation between IQ level and school success?",
      list: "C1",
      answer: "ilişkilendirmek",
      quest: "correlate",
    ),

    Words5(
      back:
          "IQ seviyesi ile okul başarısı arasında pozitif bir korelasyon var.",
      front:
          "There is a positive correlation between IQ level and school success.",
      list: "C1",
      answer: "bağlılık",
      quest: "correlation",
    ),

    Words5(
      back: "Sorularınıza mektupla cevap vereceğim.",
      front: "I will correspond to your questions by letter.",
      list: "C1",
      answer: "tekabül etmek",
      quest: "correspond",
    ),

    Words5(
      back: "Uzun yıllar boyunca mektuplaştık.",
      front: "We corresponded for many years.",
      list: "C1",
      answer: "yazışma",
      quest: "correspondence",
    ),

    Words5(
      back: "Savaş muhabiri, cepheden canlı yayın yaptı.",
      front: "The war correspondent broadcasted live from the front.",
      list: "C1",
      answer: "eş",
      quest: "correspondent",
    ),

    Words5(
      back: "Bu renk, kıyafetime tam olarak karşılık geliyor.",
      front: "This color corresponds perfectly to my outfit.",
      list: "C1",
      answer: "yerini tutan",
      quest: "corresponding",
    ),

    Words5(
      back: "Yolsuz politikacılar ülkeye zarar veriyor.",
      front: "Corrupt politicians are harming the country.",
      list: "C1",
      answer: "yozlaşmış",
      quest: "corrupt",
    ),

    Words5(
      back: "Yolsuzluk her ülkede önemli bir sorundur.",
      front: "Corruption is a major problem in every country.",
      list: "C1",
      answer: "yolsuzluk",
      quest: "corruption",
    ),

    Words5(
      back: "Bu gezi çok masraflı olacak.",
      front: "This trip will be very costly.",
      list: "C1",
      answer: "masraflı",
      quest: "costly",
    ),

    Words5(
      back: "Meclis üyesi halkın sorunlarını dile getirdi.",
      front: "The councillor voiced the problems of the people.",
      list: "C1",
      answer: "meclis üyesi",
      quest: "councillor",
    ),

    Words5(
      back: "Arkadaşım psikolojik danışmaya başladı.",
      front: "My friend started counselling.",
      list: "C1",
      answer: "danışma",
      quest: "counselling",
    ),
    Words5(
      back: "Psikolojik sorunlar için bir danışmana danışabilirsiniz.",
      front: "You can consult a counsellor for psychological problems.",
      list: "C1",
      answer: "danışman",
      quest: "counsellor",
    ),

    Words5(
      back: "Bankada müşteri sayacı vardı.",
      front: "There was a customer counter at the bank.",
      list: "C1",
      answer: "tezgah,sayaç",
      quest: "counter",
    ),

    Words5(
      back:
          "Uluslararası görüşmelerde Türk heyetinin karşılığı İngiliz büyükelçisiydi.",
      front:
          "The British ambassador was the counterpart of the Turkish delegation in international negotiations.",
      list: "C1",
      answer: "meslektaş",
      quest: "counterpart",
    ),

    Words5(
      back: "Sayısız insan yoksulluk içinde yaşıyor.",
      front: "Countless people live in poverty.",
      list: "C1",
      answer: "sayısız",
      quest: "countless",
    ),

    Words5(
      back:
          "Devlet başkanının ani ölümü siyasi bir darbe olarak değerlendirildi.",
      front:
          "The sudden death of the president was considered a political coup.",
      list: "C1",
      answer: "başarılı davranış",
      quest: "coup",
    ),

    Words5(
      back: "Size karşı her zaman kibar davrandı.",
      front: "He was always courteous to you.",
      list: "C1",
      answer: "kibarlık",
      quest: "courtesy",
    ),

    Words5(
      back: "El işi ürünler satan bir esnaf.",
      front: "A shopkeeper who sells handcrafted products.",
      list: "C1",
      answer: "esnaf",
      quest: "craft",
    ),

    Words5(
      back: "Bebek yere doğru süründü.",
      front: "The baby crawled towards the ground.",
      list: "C1",
      answer: "sürünmek",
      quest: "crawl",
    ),

    Words5(
      back: "Bu romanın yaratıcısı ünlü bir yazar.",
      front: "The creator of this novel is a famous writer.",
      list: "C1",
      answer: "yaratıcı",
      quest: "creator",
    ),

    Words5(
      back: "Bu haber kaynağının güvenilirliği sorgulanıyor.",
      front: "The credibility of this news source is being questioned.",
      list: "C1",
      answer: "güvenilirlik",
      quest: "credibility",
    ),

    Words5(
      back: "İddianız inandırıcı değil.",
      front: "Your claim is not credible.",
      list: "C1",
      answer: "inandırıcı",
      quest: "credible",
    ),

// "creep" has the same translation as "sürünmek" depending on the context.
// We can keep the existing translation here.

    Words5(
      back: "Filmin yönetmeni filmi sert bir şekilde eleştirdi.",
      front: "The film's director harshly critiqued the film.",
      list: "C1",
      answer: "eleştirmek",
      quest: "critique",
    ),
    Words5(
      back: "Kraliçe taç giydi.",
      front: "The queen wore a crown.",
      list: "C1",
      answer: "taç",
      quest: "crown",
    ),

    Words5(
      back: "Konuşması çok kaba ve ham bir ifade içeriyordu.",
      front: "His speech contained very crude and rude language.",
      list: "C1",
      answer: "ham",
      quest: "crude",
    ),

    Words5(
      back: "Kazandığı başarı hayallerini adeta ezdi.",
      front: "The success he achieved crushed his dreams.",
      list: "C1",
      answer: "ezmek",
      quest: "crush",
    ),

    Words5(
      back: "Vazo kristalden yapılmıştı.",
      front: "The vase was made of crystal.",
      list: "C1",
      answer: "kristal",
      quest: "crystal",
    ),

    Words5(
      back: "Bu tarikat bazı garip inançlara sahip.",
      front: "This cult has some strange beliefs.",
      list: "C1",
      answer: "tarikat",
      quest: "cult",
    ),

    Words5(
      back: "Toprağı ekip biçmek için traktör kullandılar.",
      front: "They used a tractor to cultivate the land.",
      list: "C1",
      answer: "ekip biçmek",
      quest: "cultivate",
    ),

    Words5(
      back: "Doğa merakımı cezbetti.",
      front: "Nature piqued my curiosity.",
      list: "C1",
      answer: "merak",
      quest: "curiosity",
    ),

    Words5(
      back: "Suçlu şu anda gözaltında.",
      front: "The criminal is currently in custody.",
      list: "C1",
      answer: "gözaltı",
      quest: "custody",
    ),

    Words5(
      back: "Dergi, saç kesimi modelleri hakkında bir yazı içeriyordu.",
      front: "The magazine included an article about haircutting styles.",
      list: "C1",
      answer: "kesim",
      quest: "cutting",
    ),

    Words5(
      back: "Alaycı bir gülüş attı.",
      front: "He gave a cynical smile.",
      list: "C1",
      answer: "alaycı",
      quest: "cynical",
    ),

    Words5(
      back: "Hasat mevsimi yaklaşırken çiftçiler baraklara taşındı.",
      front: "As the harvest season approached, the farmers moved to the dams.",
      list: "C1",
      answer: "barak",
      quest: "dam",
    ),

    Words5(
      back: "Sigara içmek sağlığınıza zararlıdır.",
      front: "Smoking is damaging to your health.",
      list: "C1",
      answer: "zarar verici",
      quest: "damaging",
    ),

    Words5(
      back: "Şafak vakti gökyüzü kırmızı ve turuncu tonlara bürünür.",
      front: "At dawn, the sky is painted in shades of red and orange.",
      list: "C1",
      answer: "şafak",
      quest: "dawn",
    ),
    Words5(
      back: "Yıkılan binanın molozları temizlendi.",
      front: "The debris from the collapsed building was cleared.",
      list: "C1",
      answer: "moloz",
      quest: "debris",
    ),

    Words5(
      back: "Genç şarkıcının sahneye ilk çıkışı büyük ilgi çekti.",
      front: "The young singer's debut on stage attracted great attention.",
      list: "C1",
      answer: "sahneye ilk çıkış",
      quest: "debut",
    ),

    Words5(
      back: "Etkin karar verme becerileri önemlidir.",
      front: "Effective decision-making skills are important.",
      list: "C1",
      answer: "karar verme",
      quest: "decision-making",
    ),

    Words5(
      back: "Kararlı bir liderdi.",
      front: "He was a decisive leader.",
      list: "C1",
      answer: "kararlı",
      quest: "decisive",
    ),

    Words5(
      back: "Bağımsızlık beyannamesi imzalandı.",
      front: "The declaration of independence was signed.",
      list: "C1",
      answer: "beyanname",
      quest: "declaration",
    ),

    Words5(
      back: "Hayatını bilime adayan bir bilim insanıydı.",
      front: "He was a scientist dedicated to science.",
      list: "C1",
      answer: "özel",
      quest: "dedicated",
    ),

    Words5(
      back: "Kitabı en yakın arkadaşına ithaf etti.",
      front: "He dedicated the book to his closest friend.",
      list: "C1",
      answer: "ithaf",
      quest: "dedication",
    ),

    Words5(
      back: "Evin tapusu babamın üzerine.",
      front: "The deed to the house is in my father's name.",
      list: "C1",
      answer: "tapu",
      quest: "deed",
    ),

    Words5(
      back: "Onu aptal olarak değerlendirmek doğru değil.",
      front: "It is not right to deem him a fool.",
      list: "C1",
      answer: "tutmak",
      quest: "deem",
    ),

    Words5(
      back: "Borcunu ödememesi bir temerrüdtür.",
      front: "His failure to pay the debt is a default.",
      list: "C1",
      answer: "yükümlülüğünü yerine getirmemek",
      quest: "default",
    ),

    Words5(
      back: "Yeni aldığım telefonun bir arızası var.",
      front: "There is a defect in the new phone I bought.",
      list: "C1",
      answer: "arıza",
      quest: "defect",
    ),

    Words5(
      back: "Kendini savunan bir tavırla konuştu.",
      front: "He spoke in a defensive manner.",
      list: "C1",
      answer: "savunan",
      quest: "defensive",
    ),

    Words5(
      back: "Vücuttaki vitamin eksikliği sağlığı olumsuz etkiler.",
      front: "Vitamin deficiencies in the body negatively affect health.",
      list: "C1",
      answer: "eksiklik",
      quest: "deficiency",
    ),
    Words5(
      back: "Şirket bu yıl büyük bir açık verdi.",
      front: "The company had a big deficit this year.",
      list: "C1",
      answer: "açık(hesaplarda)",
      quest: "deficit",
    ),

    Words5(
      back: "Tehditlerine boyun eğmedik ve onu göstere göstere defies ettik.",
      front: "We did not give in to his threats and defied him openly.",
      list: "C1",
      answer: "küçümsemek",
      quest: "defy",
    ),

    Words5(
      back: "Sendika toplantısına bir temsilci gönderdi.",
      front: "The union sent a delegate to the meeting.",
      list: "C1",
      answer: "temsilci",
      quest: "delegate",
    ),

    Words5(
      back: "Yetkilendirme belgesini imzaladı.",
      front: "He signed the delegation document.",
      list: "C1",
      answer: "yetkilendirme",
      quest: "delegation",
    ),

    Words5(
      back:
          "Narin bir vazoydu ve dikkatli bir şekilde ele alınması gerekiyordu.",
      front: "It was a delicate situation and needed to be handled carefully.",
      list: "C1",
      answer: "narin",
      quest: "delicate",
    ),

    Words5(
      back: "Şeytan, kötülüğü temsil eder.",
      front: "The demon represents evil.",
      list: "C1",
      answer: "şeytan",
      quest: "demon",
    ),

    Words5(
      back: "Suçlamaları reddetti.",
      front: "He denied the accusations.",
      list: "C1",
      answer: "reddetme",
      quest: "denial",
    ),

    Words5(
      back: "Hükümeti insan hakları ihlalleri nedeniyle ihbar etti.",
      front: "He denounced the government for human rights violations.",
      list: "C1",
      answer: "ihbar etmek",
      quest: "denounce",
    ),

    Words5(
      back: "Orman, yoğun ağaçlarla kaplıydı.",
      front: "The forest was dense with trees.",
      list: "C1",
      answer: "yoğun",
      quest: "dense",
    ),

    Words5(
      back: "Nüfus yoğunluğu kırsal kesimlere göre daha yüksektir.",
      front: "The population density is higher compared to rural areas.",
      list: "C1",
      answer: "yoğunluk",
      quest: "density",
    ),

    Words5(
      back: "Başarısı babasına olan bağımlılığını azalttı.",
      front: "His success reduced his dependence on his father.",
      list: "C1",
      answer: "bağlılık",
      quest: "dependence",
    ),

    Words5(
      back: "Resim, savaşın dehşetini canlı bir şekilde anlatıyordu.",
      front: "The painting depicted the horrors of war vividly.",
      list: "C1",
      answer: "anlatmak",
      quest: "depict",
    ),

    Words5(
      back: "Askerleri savaşa konuşlandırdılar.",
      front: "They deployed the soldiers for the war.",
      list: "C1",
      answer: "açmak",
      quest: "deploy",
    ),
    Words5(
      back: "Ordunun konuşlanması savaşı bitirmeyi amaçlıyordu.",
      front: "The deployment of the army aimed to end the war.",
      list: "C1",
      answer: "konuşlanma",
      quest: "deployment",
    ),

    Words5(
      back: "Bankaya para yatırdı.",
      front: "He deposited money at the bank.",
      list: "C1",
      answer: "emanet",
      quest: "deposit",
    ),

    Words5(
      back: "Yoksulluk, çocukları eğitim imkanlarından mahrum bırakıyor.",
      front: "Poverty deprives children of educational opportunities.",
      list: "C1",
      answer: "mahrum etmek",
      quest: "deprive",
    ),

    Words5(
      back: "Milletvekili parlamentoda halkın temsilcisidir.",
      front: "A deputy is a representative of the people in parliament.",
      list: "C1",
      answer: "milletvekili",
      quest: "deputy",
    ),

    Words5(
      back: "Kuş yavaş yavaş aşağıya indi.",
      front: "The bird slowly descended.",
      list: "C1",
      answer: "inmek",
      quest: "descend",
    ),

    Words5(
      back: "Uçak kazası nedeniyle ani bir düşüş yaşandı.",
      front: "There was a sudden descent due to the plane crash.",
      list: "C1",
      answer: "düşme",
      quest: "descent",
    ),

    Words5(
      back: "Yeni CEO olarak onu atadılar.",
      front: "They designated him as the new CEO.",
      list: "C1",
      answer: "atamak",
      quest: "designate",
    ),

    Words5(
      back: "Barış, herkes için arzu edilen bir durumdur.",
      front: "Peace is a desirable situation for everyone.",
      list: "C1",
      answer: "arzu edilen",
      quest: "desirable",
    ),

    Words5(
      back: "Bilgisayarının masaüstünde bir sürü dosya vardı.",
      front: "There were a lot of files on his computer's desktop.",
      list: "C1",
      answer: "masaüstü",
      quest: "desktop",
    ),

    Words5(
      back: "Yıkıcı bir fırtınaydı.",
      front: "It was a destructive storm.",
      list: "C1",
      answer: "yıkıcı",
      quest: "destructive",
    ),

    Words5(
      back: "Polis onu sorguya çekmek için alıkoydu.",
      front: "The police detained him for questioning.",
      list: "C1",
      answer: "alıkoymak",
      quest: "detain",
    ),

    Words5(
      back:
          "Hırsızın suçu, güvenlik kamerası görüntüleri sayesinde tespit edildi.",
      front:
          "The thief's crime was detected thanks to security camera footage.",
      list: "C1",
      answer: "buluş",
      quest: "detection",
    ),

    Words5(
      back: "Suçlu zanlısı şu anda gözaltında ve ifadesi bekleniyor.",
      front:
          "The suspect is currently in detention and awaiting interrogation.",
      list: "C1",
      answer: "engellenme",
      quest: "detention",
    ),
    Words5(
      front: "The health of the patient is deteriorating.",
      back: "Hastanın sağlık durumu kötüleşiyor.",
      list: "C1",
      answer: "fenalaşmak",
      quest: "deteriorate",
    ),

    Words5(
      front: "The natural disaster devastated the city.",
      back: "Doğal afet şehri harap etti.",
      list: "C1",
      answer: "harap etmek",
      quest: "devastate",
    ),

    Words5(
      front: "The devil represents evil.",
      back: "Şeytan, kötülüğü temsil eder.",
      list: "C1",
      answer: "şeytan",
      quest: "devil",
    ),

    Words5(
      front: "He invented a new method to solve the complex problem.",
      back: "Karmaşık sorunu çözmek için yeni bir yöntem icat etti.",
      list: "C1",
      answer: "icat etmek",
      quest: "devise",
    ),

    Words5(
      front: "The doctor diagnosed his illness.",
      back: "Doktor hastalığını teşhis etti.",
      list: "C1",
      answer: "teşhis etmek",
      quest: "diagnose",
    ),

    Words5(
      front: "Fashion trends dictate our tastes.",
      back: "Moda trendleri zevklerimizi etkiler.",
      list: "C1",
      answer: "etkilemek",
      quest: "dictate",
    ),

    Words5(
      front: "The people rebelled against the oppressive dictator.",
      back: "Ülke diktatör tarafından yönetiliyordu.",
      list: "C1",
      answer: "diktatör",
      quest: "dictator",
    ),

    Words5(
      front: "It is important to differentiate between fact and opinion.",
      back: "İki kavram arasındaki farkı açıkladı.",
      list: "C1",
      answer: "farklılaştırmak",
      quest: "differentiate",
    ),

    Words5(
      front: "She treated everyone with respect and dignity.",
      back: "Onurunu korudu.",
      list: "C1",
      answer: "itibar",
      quest: "dignity",
    ),

    Words5(
      front: "She was caught in a dilemma between her loyalty and her morals.",
      back: "Zor bir karar vermek zorundaydı.",
      list: "C1",
      answer: "açmaz",
      quest: "dilemma",
    ),

    Words5(
      front:
          "Scientists are theorizing about the existence of higher dimensions.",
      back: "Heykelin üç boyutu vardır.",
      list: "C1",
      answer: "boyut",
      quest: "dimension",
    ),

    Words5(
      front: "He hoped that his symptoms would diminish with medication.",
      back: "Işığın şiddeti uzaklaştıkça azaldı.",
      list: "C1",
      answer: "azalmak",
      quest: "diminish",
    ),

    Words5(
      front: "The stock market took a sudden dip.",
      back: "Ekonomi ani bir düşüş yaşadı.",
      list: "C1",
      answer: "batma",
      quest: "dip",
    ),

    Words5(
      front: "You can find phone numbers in the phone directory.",
      back: "Telefon numaralarını rehberden bulabilirsin.",
      list: "C1",
      answer: "rehber",
      quest: "directory",
    ),

    Words5(
      front: "The earthquake caused a disastrous tsunami.",
      back: "Doğal afet felaket oldu.",
      list: "C1",
      answer: "talihsiz",
      quest: "disastrous",
    ),
    Words5(
      front: "It's time to discard the old and broken toys.",
      back: "Eski ve bozuk oyuncakları atmanın zamanı geldi.",
      list: "C1",
      answer: "ayırmak",
      quest: "discard",
    ),

    Words5(
      front: "The doctor discharged the patient from the hospital.",
      back: "Doktor hastayı taburcu etti.",
      list: "C1",
      answer: "taburcu etmek",
      quest: "discharge",
    ),

    Words5(
      front: "The whistleblower disclosed the company's illegal activities.",
      back: "İfşa eden kişi, şirketin yasadışı faaliyetlerini açığa vurdu.",
      list: "C1",
      answer: "açığa vurmak",
      quest: "disclose",
    ),

    Words5(
      front: "The meeting was a productive discourse on the current situation.",
      back: "Toplantı, güncel durum hakkında verimli bir söylemdi.",
      list: "C1",
      answer: "söylem",
      quest: "discourse",
    ),

    Words5(
      front: "Use discretion when sharing personal information online.",
      back: "Kişisel bilgilerinizi çevrimiçi paylaşırken incelik gösterin.",
      list: "C1",
      answer: "incelik",
      quest: "discretion",
    ),

    Words5(
      front:
          "All employees deserve to be treated with respect, without discrimination.",
      back:
          "Tüm çalışanlar ayrım yapılmadan saygı ile muamele edilmeyi hak eder.",
      list: "C1",
      answer: "ayrım",
      quest: "discrimination",
    ),

    Words5(
      front: "He received a dismissal notice from his job.",
      back: "İşinden kovma bildirimi aldı.",
      list: "C1",
      answer: "kovma",
      quest: "dismissal",
    ),

    Words5(
      front: "The earthquake displaced thousands of people from their homes.",
      back: "Deprem binlerce insanı yerinden etti.",
      list: "C1",
      answer: "yerinden çıkarmak",
      quest: "displace",
    ),

    Words5(
      front: "There are proper procedures for the disposal of hazardous waste.",
      back: "Tehlikeli atıkların imhası için uygun prosedürler vardır.",
      list: "C1",
      answer: "imha etme",
      quest: "disposal",
    ),

    Words5(
      front: "Can you dispose of this empty garbage bag?",
      back: "Bu boş çöp poşetini atabilir misin?",
      list: "C1",
      answer: "atmak",
      quest: "dispose",
    ),
    Words5(
      front: "They had a dispute over who would pay the bill.",
      back: "Hesabı kimin ödeyeceği konusunda çekiştiler.",
      list: "C1",
      answer: "çekişmek",
      quest: "dispute",
    ),

    Words5(
      front: "The construction project disrupted traffic flow in the city.",
      back: "İnşaat projesi şehirdeki trafik akışını aksattı.",
      list: "C1",
      answer: "aksatmak",
      quest: "disrupt",
    ),

    Words5(
      front: "The power outage caused widespread disruption.",
      back: "Elektrik kesintisi yaygın bir parçalanmaya neden oldu.",
      list: "C1",
      answer: "parçalanma",
      quest: "disruption",
    ),

    Words5(
      front: "Sugar dissolves easily in water.",
      back: "Şeker, suda kolayca erir.",
      list: "C1",
      answer: "eritmek",
      quest: "dissolve",
    ),

    Words5(
      front: "It's important to make a distinction between fact and opinion.",
      back: "Gerçek ve fikir arasında ayrım yapmak önemlidir.",
      list: "C1",
      answer: "ayırım",
      quest: "distinction",
    ),

    Words5(
      front: "She has a very distinctive laugh.",
      back: "Kendine özgü bir kahkahası var.",
      list: "C1",
      answer: "kendine özgü",
      quest: "distinctive",
    ),

    Words5(
      front: "The propaganda distorted the truth about the conflict.",
      back: "Propaganda, çatışma hakkındaki gerçeği saptırdı.",
      list: "C1",
      answer: "saptırmak",
      quest: "distort",
    ),

    Words5(
      front: "The financial situation caused them distress.",
      back: "Mali durum onları üzdü.",
      list: "C1",
      answer: "üzmek",
      quest: "distress",
    ),

    Words5(
      front: "I found the movie disturbing and violent.",
      back: "Filmi rahatsız edici ve şiddetli buldum.",
      list: "C1",
      answer: "rahatsız etme",
      quest: "disturbing",
    ),

    Words5(
      front: "We need to divert resources to the most critical areas.",
      back: "Dikkatleri en kritik alanlara çevirmek gerekiyor.",
      list: "C1",
      answer: "başka yöne çevirmek",
      quest: "divert",
    ),

    Words5(
      front: "Many religions believe in a divine power.",
      back: "Pek çok din kutsal bir güce inanır.",
      list: "C1",
      answer: "kutsal",
      quest: "divine",
    ),

    Words5(
      front: "The religious doctrine outlines the core beliefs of the faith.",
      back: "Dini ilke, dinin temel inançlarını ana hatlarıyla belirtir.",
      list: "C1",
      answer: "ilke",
      quest: "doctrine",
    ),

    Words5(
      front: "Please provide proper documentation for your travel expenses.",
      back: "Lütfen seyahat masraflarınız için gerekli belgelemeyi sağlayın.",
      list: "C1",
      answer: "belgeleme",
      quest: "documentation",
    ),
    Words5(
      front: "They are experts in the field of artificial intelligence.",
      back: "Yapay zeka alanında uzmanlar.",
      list: "C1",
      answer: "bilgi alanı",
      quest: "domain",
    ),

    Words5(
      front: "The lion is the dominant predator in the savanna.",
      back: "Aslan, savanda baskın avcıdır.",
      list: "C1",
      answer: "hakimiyet",
      quest: "dominance",
    ),

    Words5(
      front: "The hospital relies on the generosity of blood donors.",
      back: "Hastane, kan bağışçılarının cömertliğine güveniyor.",
      list: "C1",
      answer: "bağışçı",
      quest: "donor",
    ),

    Words5(
      front: "The doctor prescribed a high dose of medication.",
      back: "Doktor yüksek dozda ilaç reçete etti.",
      list: "C1",
      answer: "doz",
      quest: "dose",
    ),

    Words5(
      front: "We need to drain the pool before winter.",
      back: "Havuzun suyunu boşaltmamız gerekiyor.",
      list: "C1",
      answer: "tahliye etmek",
      quest: "drain",
    ),

    Words5(
      front: "Her thoughts drifted away as she gazed at the ocean.",
      back: "Okyanusa bakarken düşünceleri uzaklaştı.",
      list: "C1",
      answer: "şaşırmak",
      quest: "drift",
    ),

    Words5(
      front: "She enjoyed the thrill of driving a fast car.",
      back: "Hızlı araba kullanmanın heyecanını yaşadı.",
      list: "C1",
      answer: "sürme",
      quest: "driving",
    ),

    Words5(
      front: "The tragic accident left him to drown in despair.",
      back: "Trajik kaza onu umutsuzluk içinde boğdu.",
      list: "C1",
      answer: "suda boğulmak",
      quest: "drown",
    ),

    Words5(
      front: "There is a dual nature to human personality.",
      back: "İnsan kişiliğinin ikili bir yapısı vardır.",
      list: "C1",
      answer: "ikili",
      quest: "dual",
    ),

    Words5(
      front: "Let me try to dub the movie into Turkish.",
      back: "Filmi Türkçe dublajlamaya çalışayım.",
      list: "C1",
      answer: "düzeltmek",
      quest: "dub",
    ),

    Words5(
      front: "He lifted the heavy dumbbells with ease.",
      back: "Ağır halterleri kolaylıkla kaldırdı.",
      list: "C1",
      answer: "halter",
      quest: "dumb",
    ),

    Words5(
      front: "They are a strong duo that can overcome any challenge.",
      back:
          "Herhangi bir zorluğun üstesinden gelebilecek güçlü bir ikilidirler.",
      list: "C1",
      answer: "eş",
      quest: "duo",
    ),

    Words5(
      front:
          "The company is known for its dynamic and innovative work environment.",
      back: "Şirket, dinamik ve yenilikçi çalışma ortamı ile tanınır.",
      list: "C1",
      answer: "hareketli",
      quest: "dynamic",
    ),
    Words5(
      front: "She was eager to learn and improve her skills.",
      back: "Öğrenmeye ve yeteneklerini geliştirmeye istekliydi.",
      list: "C1",
      answer: "istekli",
      quest: "eager",
    ),

    Words5(
      front: "His monthly earnings were not enough to cover his expenses.",
      back: "Aylık kazancı masraflarını karşılamaya yetmiyordu.",
      list: "C1",
      answer: "kazanç",
      quest: "earnings",
    ),

    Words5(
      front: "Taking a deep breath helped to ease her anxiety.",
      back: "Derin bir nefes almak endişesini rahatlatmaya yardımcı oldu.",
      list: "C1",
      answer: "rahatlatmak",
      quest: "ease",
    ),

    Words5(
      front: "Her shout echoed through the empty hallway.",
      back: "Çığlığı boş koridorda yankılandı.",
      list: "C1",
      answer: "yankı",
      quest: "echo",
    ),

    Words5(
      front: "We need to find ecological solutions to environmental problems.",
      back: "Çevresel sorunlara ekolojik çözümler bulmamız gerekiyor.",
      list: "C1",
      answer: "çevre",
      quest: "ecological",
    ),

    Words5(
      front:
          "The experienced educator inspired his students to pursue their dreams.",
      back:
          "Tecrübeli eğitimci öğrencilerini hayallerinin peşinden gitmeye teşvik etti.",
      list: "C1",
      answer: "eğitimci",
      quest: "educator",
    ),

    Words5(
      front:
          "The new policy will improve the effectiveness of waste management.",
      back: "Yeni politika, atık yönetiminin etkinliğini artıracaktır.",
      list: "C1",
      answer: "etkililik",
      quest: "effectiveness",
    ),

    Words5(
      front: "He completed the task with efficiency and minimal effort.",
      back: "Görevi verimli bir şekilde ve minimum çabayla tamamladı.",
      list: "C1",
      answer: "liyakat",
      quest: "efficiency",
    ),

    Words5(
      front: "The teacher asked her students to elaborate on their answers.",
      back: "Öğretmen öğrencilerinden cevaplarını detaylandırmayı istedi.",
      list: "C1",
      answer: "detaylandırmak",
      quest: "elaborate",
    ),

    Words5(
      front:
          "The upcoming elections will be a crucial moment in the country's electoral process.",
      back:
          " yaklaşan seçimler, ülkenin seçim süreci için önemli bir an olacak.",
      list: "C1",
      answer: "seçimle ilgili",
      quest: "electoral",
    ),

    Words5(
      front: "Education can elevate a person's social status.",
      back: "Eğitim, bir kişinin sosyal statüsünü yükseltebilir.",
      list: "C1",
      answer: "yükseltmek",
      quest: "elevate",
    ),

    Words5(
      front: "Only citizens who meet the age requirement are eligible to vote.",
      back:
          "Sadece yaş şartını yerine getiren vatandaşlar oy kullanmaya hak sahibiです.",
      list: "C1",
      answer: "hak sahibi",
      quest: "eligible",
    ),

    Words5(
      front:
          "They belong to an elite group of athletes who compete at the highest level.",
      back: "En üst düzeyde yarışan elit bir sporcu grubuna aitler.",
      list: "C1",
      answer: "elit",
      quest: "elite",
    ),
    Words5(
      front: "The passengers boarded the ship for their journey.",
      back: "Yolcular yolculukları için gemiye bindiler.",
      list: "C1",
      answer: "gemiye bindirmek",
      quest: "embark",
    ),

    Words5(
      front: "He felt a wave of embarrassment after tripping in public.",
      back: "Toplum içinde tökezledikten sonra bir utanç dalgası hissetti.",
      list: "C1",
      answer: "mahcubiyet",
      quest: "embarrassment",
    ),

    Words5(
      front: "The US embassy in Ankara is located in Çankaya.",
      back: "ABD'nin Ankara Büyükelçiliği Çankaya'da bulunmaktadır.",
      list: "C1",
      answer: "elçilik",
      quest: "embassy",
    ),

    Words5(
      front:
          "The message was embedded in the code for only authorized users to see.",
      back:
          "Mesaj, yalnızca yetkili kullanıcıların görebileceği şekilde koda gömülüydü.",
      list: "C1",
      answer: "gömmek",
      quest: "embed",
    ),

    Words5(
      front: "The spirit of freedom is embodied in the national anthem.",
      back: "Özgürlük ruhu milli marşta somutlaştırılıyor.",
      list: "C1",
      answer: "somutlaştırmak",
      quest: "embody",
    ),

    Words5(
      front: "The emergence of new technologies is changing the world.",
      back: "Yeni teknolojilerin ortaya çıkışı dünyayı değiştiriyor.",
      list: "C1",
      answer: "belirme",
      quest: "emergence",
    ),

    Words5(
      front: "Scientific research is based on empirical evidence.",
      back: "Bilimsel araştırma, deneysel kanıtlara dayanır.",
      list: "C1",
      answer: "deneysel",
      quest: "empirical",
    ),

    Words5(
      front: "Education empowers individuals to reach their full potential.",
      back:
          "Eğitim, bireyleri tam potansiyellerine ulaşmaları için güçlendirir.",
      list: "C1",
      answer: "izin vermek",
      quest: "empower",
    ),

    Words5(
      front: "The government enacted a new law to protect the environment.",
      back: "Hükümet, çevreyi korumak için yeni bir yasa çıkardı.",
      list: "C1",
      answer: "sahnelemek",
      quest: "enact",
    ),

    Words5(
      front:
          "The concept of human rights encompasses a wide range of freedoms.",
      back: "İnsan hakları kavramı, geniş bir özgürlük yelpazesini kapsar.",
      list: "C1",
      answer: "kuşatmak",
      quest: "encompass",
    ),

    Words5(
      front: "Her positive words were a great encouragement for him.",
      back: "Onun olumlu sözleri onun için büyük bir teşvikti.",
      list: "C1",
      answer: "teşvik",
      quest: "encouragement",
    ),

    Words5(
      front:
          "The teacher's encouraging words helped the students overcome their shyness.",
      back:
          "Öğretmenin cesaretlendirici sözleri öğrencilerin çekingenliklerini yenmelerine yardımcı oldu.",
      list: "C1",
      answer: "cesaretlendirici",
      quest: "encouraging",
    ),

    Words5(
      front: "They are determined to succeed in their endeavours.",
      back: "Çabalarında başarılı olmaya kararlılar.",
      list: "C1",
      answer: "çabalamak",
      quest: "endeavour",
    ),
    Words5(
      front: "The universe seems endless in its vastness.",
      back: "Evren enginliğiyle sonsuz görünüyor.",
      list: "C1",
      answer: "sonsuz",
      quest: "endless",
    ),

    Words5(
      front: "The celebrity publicly endorsed the new brand of clothing.",
      back: "Ünlü, yeni giyim markasını alenen destekledi.",
      list: "C1",
      answer: "arkasına yazmak",
      quest: "endorse",
    ),

    Words5(
      front: "You need to sign the back of the check for it to be cashed.",
      back: "Çeki bozdurmak için arkasını imzalamanız gerekiyor.",
      list: "C1",
      answer: "ciro",
      quest: "endorsement",
    ),

    Words5(
      front:
          "The soldiers had to endure harsh weather conditions during the war.",
      back:
          "Askerler savaş sırasında zorlu hava koşullarına dayanmak zorunda kaldılar.",
      list: "C1",
      answer: "dayanmak",
      quest: "endure",
    ),

    Words5(
      front: "The police will enforce the law to maintain public order.",
      back: "Polis, kamu düzenini sağlamak için yasayı uygulayacaktır.",
      list: "C1",
      answer: "zorla yaptırmak",
      quest: "enforce",
    ),

    Words5(
      front:
          "Strict enforcement of traffic laws is necessary to reduce accidents.",
      back:
          "Kazaları azaltmak için trafik yasalarının sıkı bir şekilde uygulanması gerekiyor.",
      list: "C1",
      answer: "uygulama",
      quest: "enforcement",
    ),

    Words5(
      front: "The couple's engagement was announced in the newspaper.",
      back: "Çiftin nişanı gazetede duyuruldu.",
      list: "C1",
      answer: "nişan",
      quest: "engagement",
    ),

    Words5(
      front:
          "The teacher's engaging presentation kept the students' attention.",
      back: "Öğretmenin ilgi çekici sunumu öğrencilerin dikkatini çekti.",
      list: "C1",
      answer: "meşgul etme",
      quest: "engaging",
    ),

    Words5(
      front: "He politely enquired about her well-being.",
      back: "Nezaketle onun iyiliğini sordu.",
      list: "C1",
      answer: "soru sormak",
      quest: "enquire",
    ),

    Words5(
      front:
          "Traveling to different countries enriches one's cultural experience.",
      back:
          "Farklı ülkelere seyahat etmek kişinin kültürel deneyimini zenginleştirir.",
      list: "C1",
      answer: "zenginleştirmek",
      quest: "enrich",
    ),

    Words5(
      front: "You can enrol in the online course at any time.",
      back: "Online kursa herhangi bir zamanda kaydolabilirsiniz.",
      list: "C1",
      answer: "kaydolmak",
      quest: "enrol",
    ),

    Words5(
      front:
          "A heated debate ensued after the speaker's controversial remarks.",
      back:
          "Konuşmacının tartışmalı sözlerinden sonra hararetli bir tartışma başladı.",
      list: "C1",
      answer: "meydana gelmek",
      quest: "ensue",
    ),

    Words5(
      front: "He started his own enterprise after leaving his corporate job.",
      back: "Kurumsal işinden ayrıldıktan sonra kendi girişimini başlattı.",
      list: "C1",
      answer: "girişim",
      quest: "enterprise",
    ),
    Words5(
      front: "She is a music enthusiast who can name every song on the album.",
      back: "Albümdeki her şarkıyı sayabilen bir müzik tutkunu.",
      list: "C1",
      answer: "istekli kimse",
      quest: "enthusiast",
    ),

    Words5(
      front: "The new law is entitled 'The Protection of Wildlife Act'.",
      back: "Yeni yasa 'Yaban Hayatı Koruma Kanunu' başlığını taşıyor.",
      list: "C1",
      answer: "isimlendirmek",
      quest: "entitle",
    ),

    Words5(
      front:
          "The company is a legal entity with its own tax identification number.",
      back: "Şirket, kendi vergi kimlik numarası olan tüzel bir kişiliktir.",
      list: "C1",
      answer: "mevcudiyet",
      quest: "entity",
    ),

    Words5(
      front: "The spread of the coronavirus has become a global epidemic.",
      back: "Koronavirüsün yayılması küresel bir salgın haline geldi.",
      list: "C1",
      answer: "salgın",
      quest: "epidemic",
    ),

    Words5(
      front: "We strive for equality and justice for all.",
      back: "Herkes için eşitlik ve adalet için çabalıyoruz.",
      list: "C1",
      answer: "eşitlik",
      quest: "equality",
    ),

    Words5(
      front: "Can you solve this mathematical equation for x?",
      back: "Bu matematiksel denklemi x için çözebilir misin?",
      list: "C1",
      answer: "denge",
      quest: "equation",
    ),

    Words5(
      front: "The workers erected a statue in honor of the war hero.",
      back: "İşçiler savaş kahramanının onuruna bir heykel diktiler.",
      list: "C1",
      answer: "dikmek",
      quest: "erect",
    ),

    Words5(
      front: "The situation escalated quickly into a violent conflict.",
      back: "Durum hızla şiddetli bir çatışmaya dönüştü.",
      list: "C1",
      answer: "kızışmak",
      quest: "escalate",
    ),

    Words5(
      front: "Love is the essence of humanity.",
      back: "Sevgi, insanlığın özüdür.",
      list: "C1",
      answer: "öz",
      quest: "essence",
    ),

    Words5(
      front: "The university was established in 1863.",
      back: "Üniversite 1863 yılında kuruldu.",
      list: "C1",
      answer: "kuruluş",
      quest: "establishment",
    ),

    Words5(
      front: "They believe in eternal life after death.",
      back: "Ölümdən sonra sonsuz hayata inaniyorlar.",
      list: "C1",
      answer: "sonsuz",
      quest: "eternal",
    ),

    Words5(
      front: "The city was evacuated due to the approaching hurricane.",
      back: " yaklaşan kasırga nedeniyle şehir boşaltıldı.",
      list: "C1",
      answer: "götürmek",
      quest: "evacuate",
    ),

    Words5(
      front: "The music evoked memories of his childhood.",
      back: "Müzik, çocukluğuna dair anıları uyandırdı.",
      list: "C1",
      answer: "anımsatmak",
      quest: "evoke",
    ),
    Words5(
      front: "The theory of evolution explains how species change over time.",
      back: "Evrim teorisi, türlerin zamanla nasıl değiştiğini açıklar.",
      list: "C1",
      answer: "evrimsel",
      quest: "evolutionary",
    ),

    Words5(
      front: "Don't exaggerate the problem; it's not as bad as you think.",
      back: "Problemi abartmayın; düşündüğünüz kadar kötü değil.",
      list: "C1",
      answer: "abartmak",
      quest: "exaggerate",
    ),

    Words5(
      front: "She strives for excellence in everything she does.",
      back: "Yaptığı her şeyde mükemmellik için çabalar.",
      list: "C1",
      answer: "mükemmellik",
      quest: "excellence",
    ),

    Words5(
      front: "He received an exceptional grade on his history exam.",
      back: "Tarih sınavında fevkalade bir not aldı.",
      list: "C1",
      answer: "fevkalade",
      quest: "exceptional",
    ),

    Words5(
      front: "Eating in moderation is important to avoid excess calories.",
      back: "Aşırı kalori alımından kaçınmak için ölçülü yemek önemlidir.",
      list: "C1",
      answer: "aşırılık",
      quest: "excess",
    ),

    Words5(
      front: "He was excluded from the team because of his poor sportsmanship.",
      back: "Düşük sporcu ahlakı nedeniyle takımdan çıkarıldı.",
      list: "C1",
      answer: "ret",
      quest: "exclusion",
    ),

    Words5(
      front: "This club is exclusive and only accepts members by invitation.",
      back: "Bu kulüp özeldir ve sadece davetiye ile üye kabul eder.",
      list: "C1",
      answer: "özel",
      quest: "exclusive",
    ),

    Words5(
      front: "The new product is designed exclusively for gamers.",
      back: "Yeni ürün, özellikle oyuncular için tasarlanmıştır.",
      list: "C1",
      answer: "özellikle",
      quest: "exclusively",
    ),

    Words5(
      front: "The judge ordered the execution of the criminal.",
      back: "Yargıç suçlunun infazını emretti.",
      list: "C1",
      answer: "infaz etmek",
      quest: "execute",
    ),

    Words5(
      front: "The execution of the plan was flawless.",
      back: "Planın icrası kusursuzdu.",
      list: "C1",
      answer: "icra,idam",
      quest: "execution",
    ),

    Words5(
      front: "The leader exerted all his power to overcome the challenge.",
      back: "Lider, zorluğun üstesinden gelmek için tüm gücünü harcadı.",
      list: "C1",
      answer: "güç sarfetmek",
      quest: "exert",
    ),

    Words5(
      front: "Napoleon was exiled to the island of Elba after his defeat.",
      back: "Napolyon yenilgisinden sonra Elba adasına sürüldü.",
      list: "C1",
      answer: "sürgün",
      quest: "exile",
    ),

    Words5(
      front:
          "The company's high expenditure on advertising resulted in financial difficulties.",
      back:
          "Şirketin reklam için yaptığı yüksek masraflar mali sıkıntıya neden oldu.",
      list: "C1",
      answer: "masraf",
      quest: "expenditure",
    ),
    Words5(
      front:
          "The scientists conducted an experimental study to test the new drug.",
      back:
          "Bilim adamları, yeni ilacı test etmek için deneysel bir çalışma yürüttüler.",
      list: "C1",
      answer: "deneysel",
      quest: "experimental",
    ),

    Words5(
      front:
          "Your credit card will expire next month. Don't forget to renew it.",
      back: "Kredi kartınız önümüzdeki ay sona erecek. Yenilemeyi unutmayın.",
      list: "C1",
      answer: "süresi dolmak",
      quest: "expire",
    ),

    Words5(
      front: "The instructions were explicit and easy to follow.",
      back: "Talimatlar açıktı ve takip edilmesi kolaydı.",
      list: "C1",
      answer: "aşikar",
      quest: "explicit",
    ),

    Words5(
      front: "He explicitly stated his disagreement with the proposal.",
      back: "Öneriye açıkça karşı çıktığını ifade etti.",
      list: "C1",
      answer: "açıkça",
      quest: "explicitly",
    ),

    Words5(
      front:
          "Child labor is a form of exploitation that is illegal in most countries.",
      back: "Çocuk işçilik, çoğu ülkede yasadışı olan bir sömürü biçimidir.",
      list: "C1",
      answer: "kötüye kullanma",
      quest: "exploitation",
    ),

    Words5(
      front: "The news report contained explosive allegations of corruption.",
      back: "Haber raporunda patlayıcı yolsuzluk iddiaları yer alıyordu.",
      list: "C1",
      answer: "patlayıcı",
      quest: "explosive",
    ),

    Words5(
      front:
          "Scientists were able to extract valuable DNA from the dinosaur fossil.",
      back: "Bilim adamları, dinozor fosilinden değerli DNA çıkarabildiler.",
      list: "C1",
      answer: "özünü çıkarmak",
      quest: "extract",
    ),

    Words5(
      front:
          "Extremist groups often resort to violence to achieve their goals.",
      back:
          "Aşırılıkçı gruplar, hedeflerine ulaşmak için çoğu zaman şiddete başvururlar.",
      list: "C1",
      answer: "aşırılık yapmak",
      quest: "extremist",
    ),

    Words5(
      front:
          "The new policy will facilitate the process of applying for a visa.",
      back: "Yeni politika, vize başvuru sürecini kolaylaştıracaktır.",
      list: "C1",
      answer: "rahatlatmak",
      quest: "facilitate",
    ),

    Words5(
      front: "The country is divided into various political factions.",
      back: "Ülke çeşitli siyasi hiziplere ayrılmıştır.",
      list: "C1",
      answer: "hizip",
      quest: "faction",
    ),

    Words5(
      front: "She is a member of the English faculty at the university.",
      back: "Üniversitede İngiliz Dili ve Edebiyatı fakültesi üyesidir.",
      list: "C1",
      answer: "fakülte",
      quest: "faculty",
    ),

    Words5(
      front: "The old photograph had faded over time.",
      back: "Eski fotoğraf zamanla solmuştu.",
      list: "C1",
      answer: "karartmak",
      quest: "fade",
    ),

    Words5(
      front: "Justice demands fairness for all.",
      back: "Adalet, herkes için insaf gerektirir.",
      list: "C1",
      answer: "insaf",
      quest: "fairness",
    ),
    Words5(
      front: "The accident resulted in a fatal injury.",
      back: "Kaza ölümcül bir yaralanmayla sonuçlandı.",
      list: "C1",
      answer: "ölümcül",
      quest: "fatal",
    ),

    Words5(
      front: "He believes that everything happens according to fate.",
      back: "Her şeyin kadere göre gerçekleştiğine inanıyor.",
      list: "C1",
      answer: "kader",
      quest: "fate",
    ),

    Words5(
      front: "The weather forecast is favourable for a picnic tomorrow.",
      back: "Yarın piknik için hava durumu olumlu.",
      list: "C1",
      answer: "olumlu",
      quest: "favourable",
    ),

    Words5(
      front: "Climbing Mount Everest is a remarkable feat of human endurance.",
      back:
          "Everest Dağı'na tırmanmak, insan dayanıklılığının olağanüstü bir başarısıdır.",
      list: "C1",
      answer: "beceriklilik",
      quest: "feat",
    ),

    Words5(
      front: "A diet rich in fibre can help with digestion.",
      back: "Lif açısından zengin bir diyet sindirime yardımcı olabilir.",
      list: "C1",
      answer: "lif",
      quest: "fibre",
    ),

    Words5(
      front: "The lion is a fierce predator known for its hunting skills.",
      back: "Aslan, avlanma yetenekleriyle tanınan vahşi bir avcıdır.",
      list: "C1",
      answer: "vahşet",
      quest: "fierce",
    ),

    Words5(
      front:
          "The award-winning film-maker is known for her thought-provoking documentaries.",
      back: "Ödüllü filmci, düşündürücü belgeselleriyle tanınır.",
      list: "C1",
      answer: "filmci",
      quest: "film-maker",
    ),

    Words5(
      front:
          "Coffee filters help remove unwanted particles from the brewed coffee.",
      back:
          "Kahve filtreleri, demlenmiş kahveden istenmeyen partiküllerin temizlenmesine yardımcı olur.",
      list: "C1",
      answer: "süzmek",
      quest: "filter",
    ),

    Words5(
      front: "He was fined for speeding by the traffic police.",
      back: "Trafik polisi tarafından aşırı hız yaptığı için ceza kesildi.",
      list: "C1",
      answer: "ceza kesmek",
      quest: "fine",
    ),

    Words5(
      front: "The suspect was arrested for possession of a firearm.",
      back: "Şüpheli, ateşli silah bulundurma suçundan tutuklandı.",
      list: "C1",
      answer: "ateşli silah",
      quest: "firearm",
    ),

    Words5(
      front: "Make sure you wear clothes that fit you well.",
      back: "Size tam oturan giysiler giydiğinizden emin olun.",
      list: "C1",
      answer: "uymak",
      quest: "fit",
    ),

    Words5(
      front:
          "The football match is a weekly fixture that brings the community together.",
      back: "Futbol maçı, topluluğu bir araya getiren haftalık bir fikstürdür.",
      list: "C1",
      answer: "sabit eşya",
      quest: "fixture",
    ),

    Words5(
      front:
          "The new design had a few minor flaws, but overall it was successful.",
      back:
          "Yeni tasarımın birkaç küçük kusuru vardı, ancak genel olarak başarılıydı.",
      list: "C1",
      answer: "kusur",
      quest: "flaw",
    ),
    Words5(
      front: "The cracked vase was beyond repair.",
      back: "Çatlamış vazo tamir edilemeyecek durumdaydı.",
      list: "C1",
      answer: "çatlak",
      quest: "flawed",
    ),

    Words5(
      front: "The frightened animals fled into the forest.",
      back: "Korkmuş hayvanlar kaçarak ormana sığındılar.",
      list: "C1",
      answer: "kaçmak",
      quest: "flee",
    ),

    Words5(
      front:
          "The naval fleet patrolled the coast to protect the country's borders.",
      back: "Donanma, ülkenin sınırlarını korumak için sahili devriye etti.",
      list: "C1",
      answer: "donanma",
      quest: "fleet",
    ),

    Words5(
      front: "Scars are formed from the healing of damaged flesh.",
      back: "Yara izleri, hasarlı etin iyileşmesinden oluşur.",
      list: "C1",
      answer: "et",
      quest: "flesh",
    ),

    Words5(
      front: "Yoga improves flexibility and balance.",
      back: "Yoga, esneklik ve dengeyi geliştirir.",
      list: "C1",
      answer: "esneklik",
      quest: "flexibility",
    ),

    Words5(
      front:
          "The politician gave a flourishing speech filled with empty promises.",
      back: "Politikacı, boş vaatlerle dolu süslü bir konuşma yaptı.",
      list: "C1",
      answer: "süslü konuşmak",
      quest: "flourish",
    ),

    Words5(
      front: "Water is a vital fluid for all living organisms.",
      back: "Su, tüm canlı organizmalar için hayati bir sıvıdır.",
      list: "C1",
      answer: "sıvı",
      quest: "fluid",
    ),

    Words5(
      front: "He felt like a foreigner in his own country.",
      back: "Kendi ülkesinde kendini bir yabancı gibi hissetti.",
      list: "C1",
      answer: "yabancı",
      quest: "foreigner",
    ),

    Words5(
      front:
          "Blacksmiths use fire and hammers to forge metal into different shapes.",
      back:
          "Demirciler, metali farklı şekillere dövmek için ateş ve çekiç kullanırlar.",
      list: "C1",
      answer: "demir dövmek",
      quest: "forge",
    ),

    Words5(
      front:
          "The new baby formula is enriched with essential vitamins and minerals.",
      back:
          "Yeni mama, gerekli vitaminler ve minerallerle zenginleştirilmiştir.",
      list: "C1",
      answer: "mama",
      quest: "formula",
    ),

    Words5(
      front: "Scientists are trying to formulate a cure for the disease.",
      back:
          "Bilim adamları, hastalık için bir tedavi formülü oluşturmaya çalışıyorlar.",
      list: "C1",
      answer: "formülleştirmek",
      quest: "formulate",
    ),

    Words5(
      front:
          "The charity fosters hope and opportunity for underprivileged children.",
      back: "Hayır kurumu, dezavantajlı çocuklar için umut ve fırsat yaratır.",
      list: "C1",
      answer: "bakmak",
      quest: "foster",
    ),

    Words5(
      front: "The fragile butterfly wings were easily damaged.",
      back: "Narin kelebek kanatları kolayca zarar gördü.",
      list: "C1",
      answer: "narin",
      quest: "fragile",
    ),

    Words5(
      front: "Frankly, I don't think that plan is going to work.",
      back: "Açıkçası, bu planın işe yarayacağını sanmıyorum.",
      list: "C1",
      answer: "açıkça",
      quest: "frankly",
    ),

    Words5(
      front: "He felt frustrated after his repeated failures.",
      back:
          "Tekrarlayan başarısızlıklardan sonra kendini haksızlığa uğramış hissetti.",
      list: "C1",
      answer: "hakkı yenmiş",
      quest: 'frustrated',
    ),

    Words5(
      front: "Trying to explain things to him is so frustrating!",
      back: "Ona bir şeyler anlatmaya çalışmak çok moral bozucu!",
      list: "C1",
      answer: "moral bozucu",
      quest: "frustrating",
    ),

    Words5(
      front:
          "The constant traffic jams were a major source of frustration for the commuters.",
      back:
          "Sürekli trafik sıkışıklığı, yolcular için büyük bir hüsran kaynağıydı.",
      list: "C1",
      answer: "hüsran",
      quest: "frustration",
    ),

    Words5(
      front: "The new furniture is both stylish and functional.",
      back: "Yeni mobilyalar hem şık hem de işlevsel.",
      list: "C1",
      answer: "pratik",
      quest: "functional",
    ),

    Words5(
      front:
          "The school is organizing a fundraising event to raise money for new sports equipment.",
      back:
          "Okul, yeni spor malzemeleri için para toplama etkinliği düzenliyor.",
      list: "C1",
      answer: "para toplama",
      quest: "fundraising",
    ),

    Words5(
      front: "Hundreds of mourners attended the funeral to pay their respects.",
      back: "Yüzlerce yas tutan, cenazeye saygılarını sunmak için katıldı.",
      list: "C1",
      answer: "cenaze",
      quest: "funeral",
    ),

    Words5(
      front: "He has a gambling problem and has lost a lot of money.",
      back: "Kumar sorunu var ve çok para kaybetti.",
      list: "C1",
      answer: "kumar",
      quest: "gambling",
    ),

    Words5(
      front: "There will be a gathering of friends and family this weekend.",
      back: "Bu hafta sonu bir arkadaş ve aile toplanma olacak.",
      list: "C1",
      answer: "toplanma",
      quest: "gathering",
    ),

    Words5(
      front: "She caught him gazing out the window, lost in thought.",
      back: "Onu dalgın dalgın pencereden dışarı bakarken gözüne takıldı.",
      list: "C1",
      answer: "gözünü dikmek",
      quest: "gaze",
    ),

    Words5(
      front: "Shift into a higher gear to accelerate.",
      back: "Hızlanmak için daha yüksek bir vitese takın.",
      list: "C1",
      answer: "dişli",
      quest: "gear",
    ),
    Words5(
      front: "This medication is a generic version of a brand-name drug.",
      back: "Bu ilaç, markalı bir ilacın jenerik versiyonudur.",
      list: "C1",
      answer: "jenerik",
      quest: "generic",
    ),

    Words5(
      front:
          "The war crimes committed against the minority group were considered genocide.",
      back:
          "Azınlık grubuna karşı işlenen savaş suçları soykırım olarak değerlendirildi.",
      list: "C1",
      answer: "soykırım",
      quest: "genocide",
    ),

    Words5(
      front: "He glanced at his watch to see what time it was.",
      back: "Saatin kaç olduğunu görmek için saatine şöyle bir göz attı.",
      list: "C1",
      answer: "göz atmak",
      quest: "glance",
    ),

    Words5(
      front: "She caught a glimpse of the thief running down the street.",
      back: "Hırsızın sokakta koşarken anlık bir bakışını yakaladı.",
      list: "C1",
      answer: "anlık bakış",
      quest: "glimpse",
    ),

    Words5(
      front: "The victory was a glorious moment in the country's history.",
      back: "Zafer, ülkenin tarihinde şanlı bir andı.",
      list: "C1",
      answer: "şanlı",
      quest: "glorious",
    ),

    Words5(
      front: "The athlete achieved glory by winning the gold medal.",
      back: "Atlet, altın madalya kazanarak görkeme ulaştı.",
      list: "C1",
      answer: "görkem",
      quest: "glory",
    ),

    Words5(
      front:
          "Good governance is essential for a stable and prosperous society.",
      back: "İyi yönetişim, istikrarlı ve müreffeh bir toplum için gereklidir.",
      list: "C1",
      answer: "kontrol",
      quest: "governance",
    ),

    Words5(
      front: "She moved with grace and elegance.",
      back: "Zarafet ve incelikle hareket etti.",
      list: "C1",
      answer: "zarafet",
      quest: "grace",
    ),

    Words5(
      front: "He struggled to grasp the complex concept.",
      back: "Karmaşık kavramı kavramakta zorlandı.",
      list: "C1",
      answer: "kavramak",
      quest: "grasp",
    ),

    Words5(
      front:
          "The soldier's body was buried in a grave with full military honors.",
      back: "Askerin naaşı, tüm askeri törenlerle bir mezara gömüldü.",
      list: "C1",
      answer: "mezar",
      quest: "grave",
    ),

    Words5(
      front: "Gravity is the force that keeps us grounded.",
      back: "Yerçekimi, bizi yerde tutan kuvvettir.",
      list: "C1",
      answer: "yerçekimi",
      quest: "gravity",
    ),

    Words5(
      front: "The city's power grid was damaged by the storm.",
      back: "Fırtına nedeniyle şehrin elektrik şebekesi zarar gördü.",
      list: "C1",
      answer: "örgü",
      quest: "grid",
    ),

    Words5(
      front: "He was overcome with grief after the death of his wife.",
      back: "Karısının ölümünden sonra kederden yıkıldı.",
      list: "C1",
      answer: "keder",
      quest: "grief",
    ),
    Words5(
      front: "He grinned mischievously at his friend.",
      back: "Arkadaşına yaramazca sırıttı.",
      list: "C1",
      answer: "sırıtmak",
      quest: "grin",
    ),
    Words5(
      front: "The coffee beans need to be grinded before brewing.",
      back: "Kahve çekirdekleri demlenmeden önce öğütülmelidir.",
      list: "C1",
      answer: "öğütmek",
      quest: "grind",
    ),
    Words5(
      front: "He struggled to grip the wet doorknob.",
      back: "Islak kapı tokmağını kavramakta zorlandı.",
      list: "C1",
      answer:
          "kavramak", // "Grip" in this context means to grasp tightly, which translates to "kavramak" in Turkish.
      quest: "grip",
    ),
    Words5(
      front: "The teacher offered guidance to the struggling student.",
      back: "Öğretmen, zorlanan öğrenciye yönlendirme sundu.",
      list: "C1",
      answer: "yönlendirme",
      quest: "guidance",
    ),
    Words5(
      front: "He felt a pang of guilt for his actions.",
      back: "Yaptıklarından dolayı bir suçluluk duygusu hissetti.",
      list: "C1",
      answer: "suçluluk",
      quest: "guilt",
    ),
    Words5(
      front:
          "There's no point trying to clean a gut instinct.", // "Gut" in this context doesn't have a direct translation. " sezgi" (intuition) might be a better fit depending on the intended meaning.
      back:
          "Sezgileri temizlemenin bir anlamı yok.", // Adjusted the translation based on the suggested meaning.
      list: "C1",
      answer: "temizlemek",
      quest: "gut",
    ),
    Words5(
      front: "The storm brought heavy hail, damaging cars and crops.",
      back: "Fırtına, arabalara ve ekinlere zarar veren dolu yağdırdı.",
      list: "C1",
      answer: "dolu yağmak",
      quest: "hail",
    ),
    Words5(
      front: "She was only halfway through the project when she quit.",
      back: "Projenin ancak yarısına gelmişti ki bıraktı.",
      list: "C1",
      answer: "yarı yolda",
      quest: "halfway",
    ),
    Words5(
      front: "The car came to a halt at the red light.",
      back: "Araba kırmızı ışıkta durdu.",
      list: "C1",
      answer: "durmak",
      quest: "halt",
    ),
    Words5(
      front: "He grabbed a handful of nuts from the bowl.",
      back: "Kâseden bir avuç fındık aldı.",
      list: "C1",
      answer: "avuç",
      quest: "handful",
    ),
    Words5(
      front: "He appreciated her skillful handling of the difficult situation.",
      back: "Zor durumun ustaca idaresini takdir etti.",
      list: "C1",
      answer: "idare",
      quest: "handling",
    ),
    Words5(
      front: "The new stapler is a handy tool to have around the office.",
      back: "Yeni zımba, ofiste olması kullanışlı bir araç.",
      list: "C1",
      answer: "kullanışlı",
      quest: "handy",
    ),
    Words5(
      front: "He was constantly harassed by his coworkers.",
      back: "Mesai arkadaşları tarafından sürekli tacize uğradı.",
      list: "C1",
      answer: "taciz",
      quest: "harassment",
    ),
    Words5(
      front: "The computer consists of both software and hardware.",
      back: "Bilgisayar hem yazılımdan hem de donanımdan oluşur.",
      list: "C1",
      answer: "donanım",
      quest: "hardware",
    ),
    Words5(
      front: "There is a sense of harmony between the music and the lyrics.",
      back: "Müzik ve sözler arasında bir ahenk var.",
      list: "C1",
      answer: "ahenk",
      quest: "harmony",
    ),
    Words5(
      front: "The sergeant's voice was harsh and unforgiving.",
      back: "Çavuşun sesi sert ve affetmezdi.",
      list: "C1",
      answer: "haşin",
      quest: "harsh",
    ),
    Words5(
      front: "The farmers are preparing for the upcoming harvest.",
      back: "Çiftçiler yaklaşan hasat için hazırlanıyor.",
      list: "C1",
      answer: "hasat",
      quest: "harvest",
    ),
    Words5(
      front: "He was filled with hatred for his enemies.",
      back: "Düşmanlarına karşı nefretle doluydu.",
      list: "C1",
      answer: "nefret",
      quest: "hatred",
    ),
    Words5(
      front: "The abandoned house is said to be haunted by ghosts.",
      back: "Terk edilmiş evin hayaletler tarafından perili olduğu söylenir.",
      list: "C1",
      answer:
          "perili", // "Sık sık uğramak" (frequently visit) doesn't capture the meaning of "haunt" in this context. "Perili" is a better fit.
      quest: "haunt",
    ),
    Words5(
      front: "Working in a factory can be a hazardous job.",
      back: "Fabrika işçiliği tehlikeli bir iş olabilir.",
      list: "C1",
      answer:
          "risk", // "Hazard" is more about the inherent danger, while "tehlike" can also mean active threat.
      quest: "hazard",
    ),
    Words5(
      front: "The speech heightened the tensions between the two countries.",
      back: "Konuşma, iki ülke arasındaki gerilimi yükseltti.",
      list: "C1",
      answer:
          "yükseltmek", // "Artan" (increasing) wouldn't capture the action of making something greater.
      quest: "heighten",
    ),
    Words5(
      front: "He is proud of his rich heritage and cultural background.",
      back: "Zengin mirası ve kültürel geçmişiyle gurur duyuyor.",
      list: "C1",
      answer: "miras",
      quest: "heritage",
    ),
    Words5(
      front: "The high-profile trial was covered by news outlets worldwide.",
      back:
          "Yüksek profilli dava, dünya çapında haber kuruluşları tarafından takip edildi.",
      list: "C1",
      // "İyi tanınan" (well-known) doesn't quite capture the emphasis on public importance.
      answer: "yüksek profilli",
      quest: "high-profile",
    ),
    Words5(
      front: "She dropped a hint about her birthday present.",
      back: "Doğum günü hediyesi hakkında bir ipucu verdi.",
      list: "C1",
      answer: "ima etmek",
      quest: "hint",
    ),
    Words5(
      front: "He longed to return to his homeland after many years abroad.",
      back: "Yıllar sonra yurt dışından vatanına dönmeyi özlemle bekliyordu.",
      list: "C1",
      answer: "vatan",
      quest: "homeland",
    ),
    Words5(
      front: "He used a hook to pull the heavy box.",
      back: "Ağır kutuyu çekmek için bir kanca kullandı.",
      list: "C1",
      answer: "kanca",
      quest: "hook",
    ),
    Words5(
      front: "Despite the challenges, he remained hopeful about the future.",
      back: "Tüm zorluklara rağmen, gelecek hakkında umutlu kaldı.",
      list: "C1",
      answer: "umutlu",
      quest: "hopeful",
    ),
    Words5(
      front: "The sun dipped below the horizon as night fell.",
      back: "Gece bastırırken güneş ufuk çizgisinin altına battı.",
      list: "C1",
      answer: "ufuk",
      quest: "horizon",
    ),
    Words5(
      front: "The deer used its horns to defend itself from the predator.",
      back: "Geyik, yırtıcıdan kendini korumak için boynuzlarını kullandı.",
      list: "C1",
      answer: "boynuz",
      quest: "horn",
    ),
    Words5(
      front: "The rebels took several hostages during the bank robbery.",
      back: "İsyancılar, banka soygunu sırasında birkaç kişiyi rehin aldı.",
      list: "C1",
      answer: "rehin",
      quest: "hostage",
    ),
    Words5(
      front: "The two armies faced each other in a hostile environment.",
      back: "İki ordu birbirine düşmanca bir ortamda karşı karşıya geldi.",
      list: "C1",
      answer: "düşmanca",
      quest: "hostile",
    ),
    Words5(
      front: "There was a sense of hostility between the two rival companies.",
      back: "İki rakip şirket arasında düşmanlık vardı.",
      list: "C1",
      answer: "düşmanlık",
      quest: "hostility",
    ),
    Words5(
      front:
          "The humanitarian organization provides aid to refugees around the world.",
      back: "Yardım kuruluşu, dünya çapındaki mültecilere yardım sağlıyor.",
      list: "C1",
      answer: "yardımsever",
      quest: "humanitarian",
    ),
    Words5(
      front:
          "Despite their differences, they treated each other with humanity.",
      back: "Farklılıklarına rağmen birbirlerine insanlıkla davrandılar.",
      list: "C1",
      answer: "insaniyet",
      quest: "humanity",
    ),
    Words5(
      front: "He was a humble man despite his great achievements.",
      back: "Büyük başarılarına rağmen mütevazı bir adamdı.",
      list: "C1",
      answer: "mütevazı",
      quest: "humble",
    ),
    Words5(
      front: "You will need to show identification to enter the building.",
      back: "Binaya girmek için kimlik göstermeniz gerekecek.",
      list: "C1",
      answer: "kimlik saptama",
      quest: "identification",
    ),
    Words5(
      front: "They argued over ideological differences.",
      back: "Fikri farklılıklar üzerine tartıştılar.",
      list: "C1",
      answer: "fikirsel",
      quest: "ideological",
    ),
    Words5(
      front: "He didn't know the answer because of his sheer idiocy.",
      back: "Saf salaklığı yüzünden cevabı bilmiyordu.",
      list: "C1",
      answer:
          "salak", // "Idiot" can also be translated as "aptal" depending on the context.
      quest: "idiot",
    ),
    Words5(
      front: "His ignorance of the law led him into trouble.",
      back: "Hukuku bilgisizliği onu başını derde soktu.",
      list: "C1",
      answer: "bilgisizlik",
      quest: "ignorance",
    ),
    Words5(
      front:
          "The poem's vivid imagery created a strong emotional response in the reader.",
      back:
          "Şiirin canlı imgeleri, okuyucuda güçlü bir duygusal tepki yarattı.",
      list: "C1",
      answer: "imgelem",
      quest: "imagery",
    ),
    Words5(
      front: "The castle is an immense structure with towering walls.",
      back: "Kale, yükselen duvarları olan devasa bir yapıdır.",
      list: "C1",
      answer:
          "muazzam", // "Immense" can also be translated as "devasa" depending on the context.
      quest: "immense",
    ),
    Words5(
      front: "There is an imminent threat of war in the region.",
      back: "Bölgede savaş tehlikesi eli kulağındadır.",
      list: "C1",
      answer: "eli kulağında",
      quest: "imminent",
    ),
    Words5(
      front:
          "The successful implementation of the new policy led to positive results.",
      back:
          "Yeni politikanın başarılı bir şekilde uygulanması olumlu sonuçlara yol açtı.",
      list: "C1",
      answer: "uygulama",
      quest: "implementation",
    ),
    Words5(
      front: "The criminal was sentenced to ten years' imprisonment.",
      back: "Suçlu, on yıl hapis cezasına çarptırıldı.",
      list: "C1",
      answer: "hapse atmak",
      quest: "imprison",
    ),
    Words5(
      front: "He feared the harsh conditions of imprisonment.",
      back: "Hapis hayatının zorlu koşullarından korkuyordu.",
      list: "C1",
      answer: "hapis",
      quest: "imprisonment",
    ),
    Words5(
      front:
          "Her inability to speak the language made communication difficult.",
      back: "Dili konuşamaması iletişimi zorlaştırıyordu.",
      list: "C1",
      answer: "yetersizlik",
      quest: "inability",
    ),
    Words5(
      front: "The teacher found the student's explanation inadequate.",
      back: "Öğretmen, öğrencinin açıklamasını yetersiz buldu.",
      list: "C1",
      answer: "yetersiz",
      quest: "inadequate",
    ),
    Words5(
      front: "It was inappropriate to tell that joke at the funeral.",
      back: "Cenazede o şakayı anlatmak uygunsuzdu.",
      list: "C1",
      answer: "uygunsuz",
      quest: "inappropriate",
    ),
    Words5(
      front: "The report documented a higher incidence of cancer in the area.",
      back: "Raporda, bölgede daha yüksek kanser vakası sayısı belgelendi.",
      list: "C1",
      answer:
          "rastlantı", // "Incidence" can also be translated as "vaka" depending on the context, but "rastlantı" captures the idea of occurrence.
      quest: "incidence",
    ),
    Words5(
      front: "He was not inclined to help them with their difficult task.",
      back: "Onlara zor görevlerinde yardım etmeye meyilli değildi.",
      list: "C1",
      answer: "meyilli",
      quest: "inclined",
    ),
    Words5(
      front: "The company incurred a heavy loss due to the fire.",
      back: "Şirket, yangın nedeniyle büyük bir zarar gördü.",
      list: "C1",
      answer: "uğramak",
      quest: "incur",
    ),
    Words5(
      front: "The economic indicators suggest a possible recession.",
      back: "Ekonomik göstergeler olası bir durgunluğa işaret ediyor.",
      list: "C1",
      answer: "gösterge",
      quest: "indicator",
    ),
    Words5(
      front: "The grand jury issued an indictment against the suspect.",
      back: "Jüri heyeti şüpheli hakkında bir iddianame hazırladı.",
      list: "C1",
      answer: "itham",
      quest: "indictment",
    ),
    Words5(
      front: "The tribe lived an indigenous way of life in the rainforest.",
      back: "Kabile, yağmur ormanlarında yerli bir yaşam tarzı sürdürdü.",
      list: "C1",
      answer: "yerli",
      quest: "indigenous",
    ),
    Words5(
      front:
          "The teacher tried to induce her students to learn more about science.",
      back:
          "Öğretmen, öğrencilerini bilimle daha fazla ilgilenmeye ikna etmeye çalıştı.",
      list: "C1",
      answer: "ikna etmek",
      quest: "induce",
    ),
    Words5(
      front: "She likes to indulge in chocolate cake from time to time.",
      back: "Zaman zaman çikolatalı pastaya kendini şımartmayı sever.",
      list: "C1",
      answer: "şımartmak",
      quest: "indulge",
    ),
    Words5(
      front:
          "There is a growing inequality in wealth distribution around the world.",
      back:
          "Dünya çapında servet dağılımında giderek artan bir eşitsizlik var.",
      list: "C1",
      answer: "eşitsizlik",
      quest: "inequality",
    ),
    Words5(
      front:
          "Jack the Ripper is an infamous serial killer from Victorian London.",
      back:
          "Jack the Ripper, Viktorya dönemi Londra'sından kötü şöhretli bir seri katildir.",
      list: "C1",
      answer: "kötü şöhretli",
      quest: "infamous",
    ),
    Words5(
      front: "The baby cried incessantly throughout the night.",
      back: "Bebek gece boyunca durmadan ağladı.",
      list: "C1",
      answer: "bebek",
      quest: "infant",
    ),
    Words5(
      front: "The cold weather can easily infect you with a cold or the flu.",
      back:
          "Soğuk hava sizi kolayca soğuk algınlığına veya gribe bulaştırabilir.",
      list: "C1",
      answer: "bulaştırmak",
      quest: "infect",
    ),
    Words5(
      front:
          "The criminal was charged with inflicting bodily harm on the victim.",
      back: "Suçlu, kurbana ağır yaralama suçlamasıyla suçlandı.",
      list: "C1",
      answer:
          "çarptırmak", // "Inflict" can also be translated as "yapmak" (to do) depending on the context, but "çarptırmak" emphasizes the act of causing harm.
      quest: "inflict",
    ),
    Words5(
      front: "He is an influential figure in the world of business.",
      back: "İş dünyasında etkili bir figürdür.",
      list: "C1",
      answer: "etkili",
      quest: "influential",
    ),
    Words5(
      front: "Honesty is an inherent quality that everyone should possess.",
      back:
          "Dürüstlük, herkesin sahip olması gereken özünde olan bir özelliktir.",
      list: "C1",
      answer: "özünde olan",
      quest: "inherent",
    ),
    Words5(
      front: "The new law will inhibit economic growth.",
      back: "Yeni yasa, ekonomik büyümeyi engelleyecektir.",
      list: "C1",
      answer: "engellemek",
      quest: "inhibit",
    ),
    Words5(
      front: "The company has initiated a new marketing campaign.",
      back: "Şirket, yeni bir pazarlama kampanyası başlattı.",
      list: "C1",
      answer: "başlatmak",
      quest: "initiate",
    ),
    Words5(
      front: "The doctor injected the medicine into the patient's arm.",
      back: "Doktor, hastaya ilacı kolundan enjekte etti.",
      list: "C1",
      answer:
          "püskürtme", // "Injection" is more about the act of injecting, "püskürtme" emphasizes squirting or spraying. A better translation is "enjeksiyon".
      quest: "injection",
    ),
    Words5(
      front: "The war caused a great deal of injustice and suffering.",
      back: "Savaş, büyük bir adaletsizlik ve ıstıraba neden oldu.",
      list: "C1",
      answer: "adaletsizlik",
      quest: "injustice",
    ),
    Words5(
      front: "The editor made some minor insertions into the text.",
      back: "Editör, metne bazı küçük ilaveler yaptı.",
      list: "C1",
      answer: "ilave",
      quest: "insertion",
    ),
    Words5(
      front:
          "The police suspect that there is an insider who is leaking information.",
      back: "Polis, bilgi sızdıran bir içeriden biri olduğundan şüpheleniyor.",
      list: "C1",
      answer: "içeriden biri",
      quest: "insider",
    ),
    Words5(
      front:
          "The health inspector conducted a thorough inspection of the restaurant.",
      back: "Sağlık müfettişi, restoranda kapsamlı bir denetim gerçekleştirdi.",
      list: "C1",
      answer: "denetlemek",
      quest: "inspect",
    ),
    Words5(
      front: "The restaurant received a positive rating after the inspection.",
      back: "Restoran, denetimden sonra olumlu bir değerlendirme aldı.",
      list: "C1",
      answer: "denetleme",
      quest: "inspection",
    ),
    Words5(
      front: "He found inspiration for his painting in the beauty of nature.",
      back: "Resminin ilhamını doğanın güzelliğinden aldı.",
      list: "C1",
      answer: "ilham",
      quest: "inspiration",
    ),
    Words5(
      front: "Animals often rely on instinct for survival.",
      back: "Hayvanlar genellikle hayatta kalmak için içgüdülerine güvenir.",
      list: "C1",
      answer: "içgüdü",
      quest: "instinct",
    ),
    Words5(
      front: "He worked for a large institutional bank.",
      back: "Büyük bir kuruluşa ait bankada çalıştı.",
      list: "C1",
      answer: "kuruluşa ait",
      quest: "institutional",
    ),
    Words5(
      front: "The teacher instructed the students to complete the exercise.",
      back: "Öğretmen, öğrencilere alıştırmayı tamamlamaları talimatını verdi.",
      list: "C1",
      answer:
          "haber vermek", // "Instruct" can also be translated as "öğretmek" (to teach) depending on the context.
      quest: "instruct",
    ),
    // Keep the existing "yetersiz" for "insufficient"
    Words5(
      front:
          "Her explanation was insufficient and did not answer the question.",
      back: "Açıklaması yetersizdi ve soruyu cevaplamıyordu.",
      list: "C1",
      answer:
          "hakaret etmek", // "Insult" means to deliberately say something rude or hurtful. A better translation is "hakaret" or "küfretmek".
      quest: "insult",
    ),
    Words5(
      front:
          "The ancient artifact remained intact despite being buried for centuries.",
      back:
          "Eski eser, yüzyıllardır gömülü kalmasına rağmen dokunulmamış olarak kaldı.",
      list: "C1",
      answer: "dokunulmamış",
      quest: "intact",
    ),
    Words5(
      front: "The doctor monitored the patient's daily intake of medication.",
      back: "Doktor, hastanın günlük ilaç alım miktarını takip etti.",
      list: "C1",
      answer: "alınan miktar",
      quest: "intake",
    ),
    Words5(
      front: "The new technology has been integrated into the existing system.",
      back: "Yeni teknoloji, mevcut sisteme entegre edildi.",
      list: "C1",
      answer: "bütünleşmiş",
      quest: "integrated",
    ),
    Words5(
      front:
          "The successful integration of immigrants into society is a complex challenge.",
      back:
          "Göçmenlerin topluma başarılı bir şekilde entegrasyonu karmaşık bir sorundur.",
      list: "C1",
      answer: "bütünleme",
      quest: "integration",
    ),
    Words5(
      front: "He is a man of integrity with strong moral principles.",
      back: "O, güçlü ahlaki değerlere sahip dürüst bir insandır.",
      list: "C1",
      answer: "tamamlık",
      quest: "integrity",
    ),
    Words5(
      front:
          "The conflict intensified as both sides increased their military presence.",
      back: "Her iki taraf da askeri varlığını artırdıkça çatışma yoğunlaştı.",
      list: "C1",
      answer: "yoğunlaştırmak",
      quest: "intensify",
    ),
    Words5(
      front:
          "The athlete trained with great intensity to prepare for the competition.",
      back: "Sporcu, yarışmaya hazırlanmak için büyük bir yoğunlukla çalıştı.",
      list: "C1",
      answer: "yoğunluk",
      quest: "intensity",
    ),
    Words5(
      front:
          "He enrolled in an intensive language course to improve his English quickly.",
      back:
          "İngilizcesini hızlı bir şekilde geliştirmek için yoğun bir dil kursuna kaydoldu.",
      list: "C1",
      answer: "yoğun",
      quest: "intensive",
    ),
    Words5(
      front: "What is your intent in asking me this question?",
      back: "Bana bu soruyu sorma niyetin nedir?",
      list: "C1",
      answer: "niyet",
      quest: "intent",
    ),
    Words5(
      front:
          "The children enjoyed playing with the interactive whiteboard in class.",
      back:
          "Çocuklar, sınıftaki etkileşimli tahta ile oynamaktan zevk aldılar.",
      list: "C1",
      answer: "etkileşimli",
      quest: "interactive",
    ),
    Words5(
      front: "The user interface of the new software is very user-friendly.",
      back: "Yeni yazılımın arayüzü kullanıcı dostudur.",
      list: "C1",
      answer: "arayüz",
      quest: "interface",
    ),
    Words5(
      front: "Please do not interfere with my work.",
      back: "Lütfen işime müdahale etmeyin.",
      list: "C1",
      answer: "müdahale etmek",
      quest: "interfere",
    ),
    Words5(
      front:
          "The radio signal was interrupted due to interference from the storm.",
      back: "Fırtınadan kaynaklanan müdahale nedeniyle radyo sinyali kesildi.",
      list: "C1",
      answer: "müdahale",
      quest: "interference",
    ),
    Words5(
      front: "In the interim period, a temporary director will be appointed.",
      back: "Geçici dönemde, geçici bir müdür atanacaktır.",
      list: "C1",
      answer: "aralık",
      quest: "interim",
    ),
    Words5(
      front: "The designer completely revamped the interior of the house.",
      back: "Tasarımcı, evin iç kısmını tamamen yeniledi.",
      list: "C1",
      answer: "iç,dahili",
      quest: "interior",
    ),
    Words5(
      front: "He is taking an intermediate level Spanish course.",
      back: "Orta seviyede bir İspanyolca kursu alıyor.",
      list: "C1",
      answer: "orta seviye",
      quest: "intermediate",
    ),
    Words5(
      front:
          "The police intervened to stop the fight between the two neighbors.",
      back: "Polis, iki komşu arasındaki kavgayı durdurmak için araya girdi.",
      list: "C1",
      answer: "araya girmek",
      quest: "intervene",
    ),
    Words5(
      front: "The military intervention in the country was controversial.",
      back: "Ülkeye yapılan askeri müdahale tartışmalıydı.",
      list: "C1",
      answer: "araya girme",
      quest: "intervention",
    ),
    Words5(
      front:
          "They shared an intimate conversation about their hopes and dreams.",
      back: "Umutları ve hayalleri hakkında samimi bir sohbet paylaştılar.",
      list: "C1",
      answer: "samimi",
      quest: "intimate",
    ),
    Words5(
      front:
          "A private investigator was hired to look into the mysterious case.",
      back: "Gizemli vakayı araştırmak için özel bir dedektif tutuldu.",
      list: "C1",
      answer: "dedektif",
      quest: "investigator",
    ),
    Words5(
      front:
          "The magician made the rabbit disappear in an invisible puff of smoke.",
      back: "Sihirbaz, tavşanı görünmez bir duman bulutunda yok etti.",
      list: "C1",
      answer: "görünmez",
      quest: "invisible",
    ),
    Words5(
      front:
          "He invoked the spirit of his ancestors to guide him through the difficult times.",
      back:
          "Zor zamanlarda kendisine rehberlik etmeleri için atalarının ruhunu çağırdı.",
      list: "C1",
      answer: "yardım istemek",
      quest: "invoke",
    ),
    Words5(
      front: "Her involvement in the project led to unexpected complications.",
      back: "Projeye katılması beklenmedik sorunlara yol açtı.",
      list: "C1",
      answer: "bulaşma",
      quest: 'involvement',
    ),
    Words5(
      front: "Ironically, the fire station burned down.",
      back: "İşin garip yanı, itfaiye istasyonu yandı.",
      list: "C1",
      answer: "işin garip yanı [zf]",
      quest: "ironically",
    ),
    Words5(
      front:
          "The teacher's irrelevant comments made it difficult to focus on the lesson.",
      back: "Öğretmenin konu dışı yorumları derse odaklanmayı zorlaştırıyordu.",
      list: "C1",
      answer: "konu dışı",
      quest: "irrelevant",
    ),
    Words5(
      front:
          "The prisoner was kept in solitary confinement for months, which led to his isolation.",
      back:
          "Mahkum, aylarca tek başına hapiste tutuldu, bu da izolasyonuna yol açtı.",
      list: "C1",
      answer: "izolasyon",
      quest: "isolation",
    ),
    Words5(
      front: "The criminal case is under judicial review.",
      back: "Ceza davası yargı denetiminde.",
      list: "C1",
      answer: "yargılayan",
      quest: "judicial",
    ),
    Words5(
      front: "The accident happened at the junction of two busy roads.",
      back: "Kaza, iki yoğun yolun birleştiği yerde meydana geldi.",
      list: "C1",
      answer: "birleşme yeri",
      quest: "junction",
    ),
    Words5(
      front:
          "The crime falls outside the jurisdiction of the local police department.",
      back: "Suç, yerel polis departmanının yetki alanının dışında kalıyor.",
      list: "C1",
      answer: "yargı",
      quest: "jurisdiction",
    ),
    // "Just" can have several meanings. Here we use "sadece" for "just" meaning "fair".
    Words5(
      front: "He is a just and fair leader who treats everyone equally.",
      back: "O, herkese eşit davranan adil bir liderdir.",
      list: "C1",
      answer: "sadece, adil",
      quest: "just",
    ),
    Words5(
      front: "He offered a reasonable justification for his actions.",
      back: "Hareketleri için makul bir gerekçe sundu.",
      list: "C1",
      answer: "gerekçe",
      quest: "justification",
    ),
    Words5(
      front: "The human body has two kidneys.",
      back: "İnsan vücudunda iki böbrek bulunur.",
      list: "C1",
      answer: "böbrek",
      quest: "kidney",
    ),
    Words5(
      front: "The United Kingdom is a kingdom with a rich history.",
      back: "Birleşik Krallık, zengin bir tarihe sahip bir krallıktır.",
      list: "C1",
      answer: "krallık",
      quest: "kingdom",
    ),
    Words5(
      front: "He's a young lad who just graduated from high school.",
      back: "O, liseden yeni mezun olmuş genç bir delikanlı.",
      list: "C1",
      answer: "delikanlı",
      quest: "lad",
    ),
    Words5(
      front: "We need to find a new landlord as soon  our lease expires.",
      back:
          "Kira sözleşmemiz sona erer ermez yeni bir ev sahibi bulmamız gerekiyor.",
      list: "C1",
      answer: "ev sahibi",
      quest: "landlord",
    ),
    Words5(
        front: "The Eiffel Tower is a famous landmark in Paris.",
        back: "Eyfel Kulesi, Paris'in ünlü bir simgesidir.",
        list: "C1",
        answer: "simge",
        quest:
            'landmark' // "Sınır işareti" means "boundary marker". A better translation for "landmark" is "simge" or "anıt".
        ),
    Words5(
      front: "He placed the laptop on his lap and started working.",
      back: "Dizüstü bilgisayarı kucağına koydu ve çalışmaya başladı.",
      list: "C1",
      answer: "kucak",
      quest: "lap",
    ),
    Words5(
      front: "The company is undergoing a large-scale restructuring.",
      back: "Şirket, büyük ölçekli bir yeniden yapılanma sürecinden geçiyor.",
      list: "C1",
      answer: "büyük",
      quest: "large-scale",
    ),
    Words5(
      front: "The latter option seems to be the more feasible one.",
      back: "İkinci seçenek daha uygun görünüyor.",
      list: "C1",
      answer: "ikincisi",
      quest: "latter",
    ),
    Words5(
      front: "He spent the weekend relaxing in his backyard lawn.",
      back: "Hafta sonunu arka bahçesindeki çimenlikte dinlenerek geçirdi.",
      list: "C1",
      answer: "çimenlik",
      quest: "lawn",
    ),
    Words5(
      front: "He is facing a lawsuit for breach of contract.",
      back: "Sözleşme ihlali nedeniyle dava ile karşı karşıya.",
      list: "C1",
      answer: "dava",
      quest: "lawsuit",
    ),
    Words5(
      front: "The website has a user-friendly layout.",
      back: "Web sitesinin kullanıcı dostu bir düzeni var.",
      list: "C1",
      answer: "düzen",
      quest: "layout",
    ),
    Words5(
      front: "The confidential information was leaked to the press.",
      back: "Gizli bilgiler basına sızdırıldı.",
      list: "C1",
      // "Sıçratmak" means "to splash" or "to splatter". A better translation for "leak" is "sızdırmak".
      answer: "sızdırmak",
      quest: "leak",
    ),
    Words5(
      front:
          "The athlete took a great leap forward in his career after winning the championship.",
      back:
          "Sporcu, şampiyonluğu kazandıktan sonra kariyerinde büyük bir sıçrama yaptı.",
      list: "C1",
      answer: "sıçratmak",
      quest: "leap",
    ),
    Words5(
      front: "He left a legacy of groundbreaking scientific discoveries.",
      back: "Çığır açan bilimsel keşifler mirası bıraktı.",
      list: "C1",
      answer: "miras",
      quest: "legacy",
    ),
    Words5(
      front: "King Arthur is a legendary figure in British history.",
      back: "Kral Arthur, İngiliz tarihinde efsanevi bir figürdür.",
      list: "C1",
      answer: "efsanevi",
      quest: "legendary",
    ),
    Words5(
      front: "New legislation was passed to combat climate change.",
      back: "İklim değişikliğiyle mücadele etmek için yeni kanunlar çıkarıldı.",
      list: "C1",
      answer: "kanunlar",
      quest: "legislation",
    ),
    Words5(
      front:
          "The legislative branch of government is responsible for making laws.",
      back: "Hükümetin yasama organı, yasaları çıkarmaktan sorumludur.",
      list: "C1",
      answer: "yasama",
      quest: "legislative",
    ),
    Words5(
      front: "The legislature is responsible for making laws.",
      back: "Yasama organı kanun yapmaktan sorumludur.",
      list: "C1",
      answer: "parlamento",
      quest: "legislature",
    ),
    Words5(
      front: "He had a legitimate reason for being late.",
      back: "Geç kalmasının meşru bir sebebi vardı.",
      list: "C1",
      answer: "meşrulaştırmak",
      quest: "legitimate",
    ),
    Words5(
      front: "The meeting was a lengthy one, lasting for over three hours.",
      back: "Toplantı üç saatten fazla süren uzun bir toplantıydı.",
      list: "C1",
      answer: "fazlasıyla uzun",
      quest: "lengthy",
    ),
    Words5(
      front:
          "The two companies are merging to create a lesser competitor in the market.",
      back:
          "Bu iki şirket, pazarda daha az güçlü bir rakip oluşturmak için birleşiyor.",
      list: "C1",
      answer: "daha az,daha güçsüz",
      quest:
          'lesser', // "Kiralayan" means "lessor" or "landlord". A better translation for "lesser" here is "daha az" or "daha güçsüz".
    ),
    Words5(
      front: "The snake venom is lethal and can cause death within minutes.",
      back: "Yılan zehiri ölümcüdür ve dakikalar içinde ölüme neden olabilir.",
      list: "C1",
      answer: "öldürücü",
      quest: "lethal",
    ),
    Words5(
      front: "He is legally liable for the damages caused by the accident.",
      back: "Kazanın neden olduğu hasarlardan yasal olarak sorumludur.",
      list: "C1",
      answer: "yükümlü",
      quest: "liable",
    ),
    Words5(
      front: "Liberty is one of the fundamental human rights.",
      back: "Özgürlük, temel insan haklarından biridir.",
      list: "C1",
      answer: "özgürlük",
      quest: "liberty",
    ),
    Words5(
      front: "You need a driver's license to operate a car.",
      back: "Araba kullanmak için ehliyet gereklidir.",
      list: "C1",
      answer: "ruhsat",
      quest: "license",
    ),
    Words5(
      front: "He has a lifelong passion for learning.",
      back: "Hayat boyu öğrenmeye karşı bir tutkusu var.",
      list: "C1",
      answer: "hayat boyu",
      quest: "lifelong",
    ),
    Words5(
      front: "The likelihood of rain this weekend is very high.",
      back: "Bu hafta sonu yağmur yağma olasılığı çok yüksek.",
      list: "C1",
      answer: "olası olma",
      quest: "likelihood",
    ),
    Words5(
      front: "He broke his leg in a car accident.",
      back: "Trafik kazasında bacağını kırdı.",
      list: "C1",
      answer: "bacak",
      quest: "limb",
    ),
    Words5(
      front: "There is a linear relationship between exercise and weight loss.",
      back: "Egzersiz ve kilo kaybı arasında doğrusal bir ilişki vardır.",
      list: "C1",
      answer: "doğrusal,çizgisel",
      quest: "linear",
    ),
    Words5(
      front:
          "The police are asking witnesses to come forward and line up to give their statements.",
      back:
          "Polis, tanıkların ifadelerini vermek üzere öne çıkıp sıraya girmelerini istiyor.",
      list: "C1",
      answer: "sıraya girmek",
      quest: 'line up',
    ),
    Words5(
      front: "We lingered a while after the party to chat with some friends.",
      back: "Partiden sonra biraz oyalanıp bazı arkadaşlarla sohbet ettik.",
      list: "C1",
      answer: "oyalanmak",
      quest: "linger",
    ),
    Words5(
      front: "The house is up for listing this weekend.",
      back: "Ev bu hafta sonu satışa çıkarılıyor.",
      list: "C1",
      answer: "kayıt",
      quest: "listing",
    ),
    Words5(
      front:
          "The government is working on improving literacy rates in the country.",
      back:
          "Hükümet, ülkedeki okuryazarlık oranlarını iyileştirmek için çalışıyor.",
      list: "C1",
      answer: "okuryazarlık",
      quest: "literacy",
    ),
    Words5(
      front: "The liver is the largest organ in the human body.",
      back: "Karaciğer, insan vücudundaki en büyük organdır.",
      list: "C1",
      answer: "karaciğer",
      quest: "liver",
    ),
    Words5(
      front:
          "The environmental group is lobbying for stricter regulations on pollution.",
      back:
          "Çevre grubu, kirlilik konusunda daha sıkı düzenlemeler için lobi faaliyetleri yürütüyor.",
      list: "C1",
      answer: "lobi",
      quest: "lobby",
    ),
    Words5(
      front: "The captain made a note of the ship's location in the log.",
      back: "Kaptan, geminin konumunu günlük kaydına not aldı.",
      list: "C1",
      // "Kütük" means "tree trunk" or "log" in the context of wood. A better translation for "log" here is " günlük" (daily record).
      answer: "kütük",
      quest: "log",
    ),
    Words5(
      front:
          "His explanation didn't follow logic and was full of contradictions.",
      back: "Açıklaması mantığa uymuyordu ve çelişkilerle doluydu.",
      list: "C1",
      answer: "mantık",
      quest: "logic",
    ),
    Words5(
      front:
          "There has been a long-standing rivalry between the two universities.",
      back: "İki üniversite arasında uzun süredir devam eden bir rekabet var.",
      list: "C1",
      answer: "epeydir devam eden",
      quest: "long-standing",
    ),
    Words5(
      front: "The weaver used a loom to create a beautiful tapestry.",
      back: "Dokumacı, güzel bir halı yapmak için dokuma tezgahı kullandı.",
      list: "C1",
      answer: "dokuma tezgahı",
      quest: "loom",
    ),
    Words5(
      front: "He wrote a loop in the code to repeat the process ten times.",
      back: "İşlemi on kez tekrarlamak için koda bir döngü yazdı.",
      list: "C1",
      answer: "döngü",
      quest: "loop",
    ),
    Words5(
      front: "The dog showed great loyalty to its owner.",
      back: "Köpek, sahibine büyük sadakat gösterdi.",
      list: "C1",
      answer: "sadakat",
      quest: "loyalty",
    ),
    Words5(
      front: "The factory is filled with loud machinery.",
      back: "Fabrika gürültülü makinelerle dolu.",
      list: "C1",
      answer: "makineler",
      quest: "machinery",
    ),
    Words5(
      front:
          "The magician performed a magical trick that left the audience speechless.",
      back: "Sihirbaz, izleyiciyi şaşkına çeviren büyülü bir numara yaptı.",
      list: "C1",
      answer: "büyülü",
      quest: "magical",
    ),
    Words5(
      front:
          "The magistrate is a judicial officer who presides over lower courts.",
      back:
          "Sulh hakimi, alt mahkemelerde başkanlık yapan bir yargı memurudur.",
      list: "C1",
      answer: "sulh hakimi",
      quest: "magistrate",
    ),
    Words5(
      front: "The phone uses a magnetic field to transmit data.",
      back: "Telefon, veriyi iletmek için manyetik alan kullanır.",
      list: "C1",
      answer: "mıknatıslı",
      quest: "magnetic",
    ),
    Words5(
      front:
          "The earthquake was of a significant magnitude, causing widespread damage.",
      back: "Deprem, büyük bir şiddetteydi ve yaygın hasara neden oldu.",
      list: "C1",
      answer: "büyüklük",
      quest: "magnitude",
    ),
    Words5(
      front: "They are planning a vacation to the Greek mainland.",
      back: "Yunanistan anakarasına bir tatil planlıyorlar.",
      list: "C1",
      answer: "ana kara",
      quest: "mainland",
    ),
    Words5(
      front: "The company is trying to mainstream electric vehicles.",
      back: "Şirket, elektrikli araçları yaygın hale getirmeye çalışıyor.",
      list: "C1",
      answer: "yaygın hale getirmek",
      quest: "mainstream",
    ),
    Words5(
      front:
          "Regular car maintenance is essential for keeping your vehicle safe.",
      back:
          "Düzenli araç bakımı, aracınızın güvenliğini sağlamak için gereklidir.",
      list: "C1",
      answer: "bakım",
      quest: "maintenance",
    ),
    Words5(
      front:
          "The United Nations has a mandate to maintain international peace and security.",
      back:
          "Birleşmiş Milletler'in uluslararası barış ve güvenliği sağlama yetkisi vardır.",
      list: "C1",
      answer:
          "manda altına almak", // "Manda altına almak" means "to mandate" but in a more colonial context. A better translation for "mandate" here is "yetki".
      quest: "mandate",
    ),
    Words5(
      front: "Wearing a mask is mandatory on public transportation.",
      back: "Toplu taşımada maske takmak zorunludur.",
      list: "C1",
      answer: "zorunlu",
      quest: "mandatory",
    ),
    Words5(
      front: "His guilt was manifest in his facial expressions.",
      back: "Suçluluğu yüz ifadelerinde açıkça belli oluyordu.",
      list: "C1",
      answer: "açıkça göstermek",
      quest: "manifest",
    ),
    Words5(
      front:
          "The author is working on a new manuscript for a historical novel.",
      back:
          "Yazar, tarihi bir roman için yeni bir müsvedde üzerinde çalışıyor.",
      list: "C1",
      answer: "müsvedde",
      quest: "manuscript",
    ),
    Words5(
      front:
          "Thousands of people participated in the march for climate justice.",
      back: "Binlerce insan iklim adaleti yürüyüşüne katıldı.",
      list: "C1",
      answer: "yürüyüş(topluca)",
      quest: "march",
    ),
    Words5(
      front:
          "The marketplace is a bustling center of commerce with a variety of shops and stalls.",
      back:
          "Pazar yeri, çeşitli dükkanları ve tezgahlarıyla hareketli bir ticaret merkezidir.",
      list: "C1",
      answer: "pazar yeri",
      quest: "marketplace",
    ),
    Words5(
      front: "He wore a mask to hide his identity during the robbery.",
      back: "Soygun sırasında kimliğini gizlemek için maske taktı.",
      // "Maskelemek" is not a common verb in Turkish. A better translation for "mask" here is "takmak".
      list: "C1",
      answer: "maske",
      quest: 'mask',
    ),
    Words5(
      front: "The war resulted in a horrific massacre of civilians.",
      back: "Savaş, korkunç bir katliamla sonuçlandı.",
      list: "C1",
      answer: "katliam",
      quest: "massacre",
    ),
    Words5(
      front:
          "He has become a more mature and responsible person over the years.",
      back: "Yıllar içinde daha olgun ve sorumlu bir insan oldu.",
      list: "C1",
      answer: "olgun",
      quest: "mature",
    ),
    Words5(
      front: "The company is looking for ways to maximize its profits.",
      back: "Şirket, kârını en üst düzeye çıkarmanın yollarını arıyor.",
      list: "C1",
      answer: "yükseltmek",
      quest: "maximize",
    ),
    Words5(
      front: "He is searching for a meaningful career path.",
      back: "Anlamlı bir kariyer yolu arıyor.",
      list: "C1",
      answer: "anlamlı",
      quest: "meaningful",
    ),
    Words5(
      front:
          "I'll finish this report, and in the meantime, you can start working on the presentation.",
      back:
          "Bu raporu bitireceğim, arada sen de sunum üzerinde çalışmaya başlayabilirsin.",
      list: "C1",
      answer: "ara",
      quest: "meantime",
    ),
    Words5(
      front: "The castle is a well-preserved example of medieval architecture.",
      back: "Kale, ortaçağ mimarisinin iyi korunmuş bir örneğidir.",
      list: "C1",
      answer: "ortaçağ",
      quest: "medieval",
    ),
    Words5(
      front: "She practices meditation to relieve stress.",
      back: "Stresi azaltmak için meditasyon yapıyor.",
      list: "C1",
      answer: "meditasyon",
      quest: "meditation",
    ),
    Words5(
      front:
          "He left a memo on his colleague's desk reminding them about the meeting.",
      back:
          "Meslektaşının masasında toplantıyı hatırlatan bir bildiri bıraktı.",
      list: "C1",
      answer: "bildiri",
      quest: "memo",
    ),
    Words5(
      front: "She wrote a memoir about her experiences during World War II.",
      back:
          "II. Dünya Savaşı sırasında yaşadıklarını anlatan bir inceleme yazısı yazdı.",
      list: "C1",
      answer: "inceleme yazısı",
      quest: "memoir",
    ),
    Words5(
      front:
          "The war memorial honors the soldiers who lost their lives in the conflict.",
      back:
          "Savaş anıtı, çatışmada hayatını kaybeden askerleri onurlandırıyor.",
      list: "C1",
      answer:
          "önerge", // "Öneri" means "suggestion" or "proposal". A better translation for "memorial" here is "anıt".
      quest: "memorial",
    ),
    Words5(
      front:
          "He found a mentor who helped him navigate the challenges of starting his own business.",
      back:
          "Kendi işini kurmanın zorluklarında yolunu bulmasına yardımcı olan bir akıl hocası buldu.",
      list: "C1",
      answer: "akıl hocalığı yapmak",
      quest: "mentor",
    ),
    Words5(
      front: "The merchant traveled the world in search of exotic spices.",
      back: "Tüccar, egzotik baharatlar aramak için dünyayı gezdi.",
      list: "C1",
      answer: "tüccar",
      quest: "merchant",
    ),
    Words5(
      front: "He showed mercy to his defeated opponent.",
      back: "Mağlup olmuş rakibine merhamet gösterdi.",
      list: "C1",
      answer: "merhamet",
      quest: "mercy",
    ),
    Words5(
      front: "The path led through a swampy mere.",
      back: "Yol bataklık bir alandan geçiyordu.",
      list: "C1",
      answer: "bataklık",
      quest: "mere",
    ),
    Words5(
      front: "He merely suggested they postpone the meeting.",
      back: "Sadece toplantıyı ertelemelerini önerdi.",
      list: "C1",
      answer: "yalnızca",
      quest: "merely",
    ),
    Words5(
      front: "The two companies are merging to create a larger corporation.",
      back: "Bu iki şirket daha büyük bir şirket oluşturmak için birleşiyor.",
      list: "C1",
      answer: "birleşmek",
      quest: "merge",
    ),
    Words5(
      front:
          "The merger of the two banks is expected to be finalized next year.",
      back:
          "İki bankanın birleşmesinin önümüzdeki yıl tamamlanması bekleniyor.",
      list: "C1",
      answer: "birleşme",
      quest: "merger",
    ),
    Words5(
      front: "He was awarded a scholarship based on his academic merit.",
      back: "Akademik başarılarına göre burs kazandı.",
      list: "C1",
      answer: "erdem",
      quest: "merit",
    ),
    Words5(
      front: "In the midst of the chaos, he remained calm and collected.",
      back: "Kaosun ortasında sakin ve soğukkanlı kaldı.",
      list: "C1",
      // "Orta yer" can be used for "midst" in some contexts, but "ortasında" is a more natural translation here.
      answer: "orta yer",
      quest: "midst",
    ),
    Words5(
      front: "The annual bird migration is a fascinating natural phenomenon.",
      back: "Yıllık kuş göçü, büyüleyici bir doğal olaydır.",
      list: "C1",
      answer: "göç",
      quest: "migration",
    ),
    Words5(
      front: "The old windmill is a picturesque landmark in the village.",
      back: "Eski değirmen, köyde pitoresk bir simgedir.",
      list: "C1",
      answer: "değirmen",
      quest: "mill",
    ),
    Words5(
      front: "We need to make some minimal changes to the design.",
      back: "Tasarımda bazı asgari değişiklikler yapmamız gerekiyor.",
      list: "C1",
      answer: "asgari",
      quest: "minimal",
    ),
    Words5(
      front:
          "Their goal is to minimize the environmental impact of their products.",
      back: "Amaçları, ürünlerinin çevresel etkisini en aza indirmektir.",
      list: "C1",
      answer: "küçültmek",
      quest: "minimize",
    ),
    Words5(
      front: "Coal mining is a dangerous and often deadly industry.",
      back: "Kömür madenciliği tehlikeli ve çoğu zaman ölümcül bir sektördür.",
      list: "C1",
      answer: "maden kazma",
      quest: "mining",
    ),
    Words5(
      front:
          "The Ministry of Education is responsible for developing the national curriculum.",
      back:
          "Milli Eğitim Bakanlığı, ulusal müfredatı geliştirmekten sorumludur.",
      list: "C1",
      answer: "bakanlık",
      quest: "ministry",
    ),
    Words5(
      front: "Take a five-minute break to rest your eyes.",
      back: "Gözlerinizi dinlendirmek için beş dakika ara verin.",
      list: "C1",
      answer: "dakika",
      quest: "minute",
    ),
    Words5(
      front: "It would be a miracle if they win the championship.",
      back: "Şampiyonluğu kazanırlarsa mucize olurdu.",
      list: "C1",
      answer: "mucize",
      quest: "miracle",
    ),
    Words5(
      front: "He lived a life of poverty and misery.",
      back: "Yoksulluk ve sefalet içinde bir hayat yaşadı.",
      list: "C1",
      answer: "sefalet",
      quest: "misery",
    ),
    Words5(
      front:
          "The advertisement contained misleading information about the product.",
      back: "Reklam, ürün hakkında yanıltıcı bilgiler içeriyordu.",
      list: "C1",
      answer: "yanıltıcı",
      quest: "misleading",
    ),
    Words5(
      front: "The country is developing ballistic missiles as a deterrent.",
      back: "Ülke caydırıcı olarak balistik füzeler geliştiriyor.",
      list: "C1",
      answer:
          "kurşun", // "Kurşun" means "bullet" in Turkish. A better translation for "missile" is "füze".
      quest: "missile",
    ),
    Words5(
      front: "An angry mob gathered outside the parliament building.",
      back: "Öfkeli bir kalabalık parlamento binası dışında toplandı.",
      list: "C1",
      answer: "toplanmak",
      quest: "mob",
    ),
    Words5(
      front: "Regular exercise is essential for maintaining good mobility.",
      back: "İyi hareketliliği korumak için düzenli egzersiz yapmak önemlidir.",
      list: "C1",
      answer: "hareketlilik",
      quest: "mobility",
    ),
    Words5(
      front: "We need to take a moderate approach to solving this problem.",
      back: "Bu sorunu çözmek için ılıman bir yaklaşım benimsememiz gerekiyor.",
      list: "C1",
      answer: "ılıman",
      quest: "moderate",
    ),
    Words5(
      front: "The new design is just a minor modification of the original.",
      back: "Yeni tasarım, orijinalin sadece küçük bir değişikliğidir.",
      list: "C1",
      answer: "küçük değişiklik",
      quest: "modification",
    ),
    Words5(
      front: "The team is building momentum as they win more games.",
      back: "Takım daha fazla oyun kazandıkça hızlanma kazanıyor.",
      list: "C1",
      answer: "hızlanma",
      quest: "momentum",
    ),
    Words5(
      front: "The monk devoted his life to prayer and meditation.",
      back: "Keşiş hayatını dua ve meditasyona adadı.",
      list: "C1",
      answer: "keşiş",
      quest: "monk",
    ),
    Words5(
      front:
          "The company has a monopoly on the production of sugar in the country.",
      back: "Şirket, ülkede şeker üretiminde tekel durumundadır.",
      list: "C1",
      answer: "tekel",
      quest: "monopoly",
    ),
    Words5(
      front: "He acted out of a sense of morality and justice.",
      back: "Ahlak ve adalet duygusuyla hareket etti.",
      list: "C1",
      answer: "ahlaklılık",
      quest: "morality",
    ),
    Words5(
      front: "The police are investigating the motive behind the crime.",
      back: "Polis, suçun arkasındaki güdüleri araştırıyor.",
      list: "C1",
      answer: "güdü",
      quest: "motive",
    ),
    Words5(
      front: "The motorist was pulled over for speeding.",
      back: "Şoför hız yaptığı için durduruldu.",
      list: "C1",
      answer: "şoför",
      quest: "motorist",
    ),
    Words5(
      front: "The park is owned and maintained by the municipality.",
      back: "Park belediyeye aittir ve belediye tarafından bakımı yapılır.",
      list: "C1",
      answer: "belediyeye ait",
      quest: "municipal",
    ),
    Words5(
      front: "They have a mutual respect for each other.",
      back: "Birbirlerine karşı ortak bir saygıları var.",
      list: "C1",
      answer: "ortak",
      quest: "mutual",
    ),
    Words5(
      front: "The capital city, namely Ankara, is a modern metropolis.",
      back: "Başkent olan Ankara, modern bir metropolüdür.",
      list: "C1",
      answer: "olarak adlandırılan",
      quest: "namely",
    ),
    Words5(
      front: "The company launched a nationwide advertising campaign.",
      back: "Şirket, ülke çapında bir reklam kampanyası başlattı.",
      list: "C1",
      answer:
          "bütün millete ait", // "Bütün millete ait" means "national" in a more literal sense. A better translation for "nationwide" is "ülke çapında".
      quest: "nationwide",
    ),
    Words5(
      front: "The country has a powerful naval force.",
      back: "Ülkenin güçlü bir deniz kuvveti vardır.",
      list: "C1",
      answer: "denizcilik",
      quest: "naval",
    ),
    Words5(
      front: "He neglected his responsibilities for too long.",
      back: "Sorumluluklarını çok uzun süre ihmal etti.",
      list: "C1",
      answer: "ihmal etmek",
      quest: "neglect",
    ),
    Words5(
      front: "We live in a quiet neighborhood with friendly neighbors.",
      back: "Sessiz bir mahallede, cana yakın komşularla yaşıyoruz.",
      list: "C1",
      answer:
          "bitişik", // "Bitişik" means "adjacent" or "attached". A better translation for "neighbouring" is "komşu".
      quest: "neighbouring",
    ),
    Words5(
      front: "The bird built its nest in a tall tree.",
      back: "Kuş, yuvasını yüksek bir ağaca yaptı.",
      list: "C1",
      answer: "yuva",
      quest: "nest",
    ),
    Words5(
      front: "He is caught in a net of his own making.",
      back: "Kendi kurduğu bir ağa yakalandı.",
      list: "C1",
      answer: "şebeke",
      quest: "net",
    ),
    Words5(
      front: "I receive a monthly newsletter with company updates.",
      back: "Şirket güncellemelerini içeren aylık bir haber bülteni alıyorum.",
      list: "C1",
      answer: "haber bülteni",
      quest: "newsletter",
    ),
    Words5(
      front: "She found a niche market for her handmade crafts.",
      back: "El yapımı el sanatları için uygun bir yer buldu.",
      list: "C1",
      answer:
          "uygun yere koymak", // "Uygun yere koymak" means "to place something in a suitable location". A better translation for "niche" is "özel alan".
      quest: "niche",
    ),
    Words5(
      front: "He is a noble man with a strong sense of justice.",
      back: "Adalet duygusu güçlü, soylu bir adamdır.",
      list: "C1",
      answer: "soylu",
      quest: "noble",
    ),
    Words5(
      front: "The crowd gave a silent nod of approval.",
      back: "Kalabalık sessiz bir onay işareti verdi.",
      list: "C1",
      answer:
          "seçilmek", // "Seçilmek" means "to be chosen".  A better translation for "nod" here is "baş sallamak".
      quest: "nod",
    ),
    Words5(
      front: "The president nominated her to be the next secretary of state.",
      back: "Başkan, onu bir sonraki dışişleri bakanı olarak görevlendirdi.",
      list: "C1",
      answer: "görevlendirmek",
      quest: "nominate",
    ),
    Words5(
      front:
          "There were several nominations for the employee of the month award.",
      back: "Ayın çalışanı ödülü için birkaç aday gösterme vardı.",
      list: "C1",
      answer: "aday gösterme",
      quest: "nomination",
    ),
    Words5(
      front: "Who is the nominee for the CEO position?",
      back: "CEO pozisyonu için vekil kim?",
      list: "C1",
      answer:
          "vekil", // "Vekil" can mean "representative" in some contexts, but "aday" is a more natural translation for "nominee" here.
      quest: "nominee",
    ),
    Words5(
      front: "He won the competition nonetheless.",
      back: "Bununla beraber yarışmayı kazandı.",
      list: "C1",
      answer: "bununla beraber",
      quest: "nonetheless",
    ),
    Words5(
      front:
          "The organization is a non-profit that provides educational resources.",
      back:
          "Kurum, eğitim kaynakları sağlayan kar amacı gütmeyen bir kuruluştur.",
      list: "C1",
      answer: "kar etmeyen",
      quest: "non-profit",
    ),
    Words5(
      front: "Stop talking nonsense and get to work!",
      back: "Saçmalık konuşmayı bırak ve işe koyul!",
      list: "C1",
      answer: "saçmalık",
      quest: "nonsense",
    ),
    Words5(
      front: "The meeting will be held at noon tomorrow.",
      back: "Toplantı yarın öğle vakti yapılacak.",
      list: "C1",
      answer: "öğle vakti",
      quest: "noon",
    ),
    Words5(
      front: "A notable feature of the building is its stained-glass windows.",
      back: "Binanın göze çarpan bir özelliği vitray pencereleridir.",
      list: "C1",
      answer: "göze çarpan",
      quest: "notable",
    ),
    Words5(
      front: "She is notably absent from today's meeting.",
      back: "Bugünkü toplantıda açıkça yok.",
      list: "C1",
      answer:
          "açıkça", // "Açıkça" means "clearly" here. A better translation for "notably" is "özellikle" or "dikkat çekici bir şekilde".
      quest: "notably",
    ),
    Words5(
      front: "We will notify you when your order is shipped.",
      back: "Siparişiniz gönderildiğinde size bildireceğiz.",
      list: "C1",
      answer: "bildirmek",
      quest: "notify",
    ),
    Words5(
      front: "Al Capone was a notorious gangster during the Prohibition Era.",
      back: "Al Capone, Yasakçılık Dönemi'nde kötü şöhretli bir gangsterdi.",
      list: "C1",
      answer: "kötü şöhretli",
      quest: "notorious",
    ),
    Words5(
      front: "I'm reading a fascinating novel about a dystopian future.",
      back: "Distopik bir gelecek hakkında büyüleyici bir roman okuyorum.",
      list: "C1",
      answer: "roman",
      quest: "novel",
    ),
    Words5(
      front: "The baby is sleeping peacefully in the nursery.",
      back: "Bebek çocuk odasında huzur içinde uyuyor.",
      list: "C1",
      answer: "çocuk odası",
      quest: "nursery",
    ),
    Words5(
      front: "He raised no objection to the proposal.",
      back: "Öneriye karşı herhangi bir karşı gelme göstermedi.",
      list: "C1",
      answer: "karşı gelme",
      quest: "objection",
    ),
    Words5(
      front: "The law obliges all citizens to pay taxes.",
      back: "Yasa, tüm vatandaşları vergi ödemeye zorunlu kılar.",
      list: "C1",
      answer: "zorunda bırakmak",
      quest: "oblige",
    ),
    Words5(
      front: "He is obsessed with winning the competition.",
      back: "Yarışmayı kazanmaya saplantı haline getirdi.",
      list: "C1",
      answer: "saplantı haline getirmek",
      quest: "obsess",
    ),
    Words5(
      front: "Her fear of public speaking is a common obsession.",
      back: "Halka konuşma korkusu, yaygın bir takıntıdır.",
      list: "C1",
      answer: "takıntı",
      quest: "obsession",
    ),
    Words5(
      front: "We have occasional meetings to discuss current projects.",
      back: "Mevcut projeleri tartışmak için ara sıra toplantılar yaparız.",
      list: "C1",
      answer: "ara sıra olan",
      quest: "occasional",
    ),
    Words5(
      front: "The accident was a rare occurrence.",
      back: "Kaza ender rastlanan bir buluntu oldu.",
      list: "C1",
      answer:
          "bulunma", // "Bulunma" means "finding" or "existence" here. A better translation for "occurrence" is "olay".
      quest: "occurrence",
    ),
    Words5(
      front: "The odds of winning the lottery are very low.",
      back: "Milli piyango kazanma ihtimali çok düşüktür.",
      list: "C1",
      answer: "ihtimal",
      quest: "odds",
    ),
    Words5(
      front: "The factory is now fully operational after the repairs.",
      back: "Fabrika onarımların ardından artık tamamen çalıştırma durumunda.",
      list: "C1",
      answer: "çalıştırma",
      quest: "operational",
    ),
    Words5(
      front: "I opted for the healthier option on the menu.",
      back: "Menüdeki daha sağlıklı seçeneği tercih ettim.",
      list: "C1",
      answer: "karar kılmak",
      quest: "opt",
    ),
    Words5(
      front: "He needs glasses because of his poor optical vision.",
      back: "Zayıf görme yeteneği nedeniyle gözlüğe ihtiyacı var.",
      list: "C1",
      answer:
          "görüş", // "Görüş" means "opinion" here. A better translation for "optical" is "optik".
      quest: "optical",
    ),
    Words5(
      front:
          "Despite the challenges, she remained optimistic about the future.",
      back: "Zorluklara rağmen, gelecek hakkında iyimserlik sürdürdü.",
      list: "C1",
      answer: "iyimserlik",
      quest: "optimism",
    ),
    Words5(
      front: "The exam will be conducted orally this year.",
      back: "Sınav bu yıl sözlü olarak yapılacak.",
      list: "C1",
      answer: "sözlü, ağız",
      quest: "oral",
    ),
    Words5(
      front: "The custom originated in ancient Greece.",
      back: "Bu adet, antik Yunanistan'da kaynaklandı.",
      list: "C1",
      answer: "kaynaklanmak",
      quest: "originate",
    ),
    Words5(
      front: "The outbreak of the disease caused widespread panic.",
      back: "Hastalığın salgını yaygın paniğe neden oldu.",
      list: "C1",
      answer: "salgın",
      quest: "outbreak",
    ),
    Words5(
      front: "We are planning a family outing to the park this weekend.",
      back: "Bu hafta sonu parka bir aile gezisi planlıyoruz.",
      list: "C1",
      answer: "tur",
      quest: "outing",
    ),
    Words5(
      front: "This store is a brand outlet that sells discounted clothing.",
      back: "Bu mağaza indirimli kıyafet satan bir marka satış yeridir.",
      list: "C1",
      answer: "satış yeri",
      quest: "outlet",
    ),
    Words5(
      front: "The economic outlook for the next year is uncertain.",
      back: "Önümüzdeki yıl için ekonomik görünüm belirsiz.",
      list: "C1",
      answer: "görünüm",
      quest: "outlook",
    ),
    Words5(
      front: "His comments caused outrage among the audience.",
      back: "Yorumları seyirciler arasında öfke yarattı.",
      list: "C1",
      answer:
          "hakaret etmek", // "Hakaret etmek" means "to insult". A better translation for "outrage" is "tepkili".
      quest: "outrage",
    ),
    Words5(
      front: "He felt like an outsider in his own family.",
      back: "Kendi ailesinde kendini bir dışarıdaki gibi hissetti.",
      list: "C1",
      answer: "dışarıdaki",
      quest: "outsider",
    ),
    Words5(
      front: "I can't overlook his constant mistakes any longer.",
      back: "Artık sürekli yaptığı hataları görmezden gelemem.",
      list: "C1",
      answer: "hoşgörmek",
      quest: "overlook",
    ),
    Words5(
      front: "He is overly cautious when it comes to taking risks.",
      back: "Risk almak söz konusu olduğunda aşırı temkinlidir.",
      list: "C1",
      answer: "fazlaca",
      quest: "overly",
    ),
    Words5(
      front: "The manager oversees the daily operations of the company.",
      back: "Yönetici, şirketin günlük operasyonlarını denetler.",
      list: "C1",
      answer: "yönetmek",
      quest: "oversee",
    ),
    Words5(
      front: "The recent court decision overturned the previous ruling.",
      back: "Son mahkeme kararı önceki kararı bozdu.",
      list: "C1",
      answer: "devrilmek",
      quest: "overturn",
    ),
    Words5(
      front: "The workload is overwhelming, but I will try my best.",
      back: "İş yükü ezici, ama elimden geleni yapacağım.",
      list: "C1",
      answer:
          "mahcup etmek", // "Mahcup etmek" means "to embarrass". A better translation for "overwhelm" is "bunalım".
      quest: "overwhelm",
    ),
    Words5(
      front:
          "The team felt overwhelmed by the overwhelming support from the fans.",
      back: "Takım, taraftarların ezici desteği karşısında bunaldı.",
      list: "C1",
      answer: "ezici",
      quest: "overwhelming",
    ),
    Words5(
      front: "I need a new pad for my tablet computer.",
      back: "Tablet bilgisayarım için yeni bir ufak yastık almam gerekiyor.",
      list: "C1",
      answer:
          "ufak yastık", // "Ufak yastık" literally means "small pillow". A better translation for "pad" in this context is "kılıf".
      quest: "pad",
    ),
    Words5(
      front: "The function requires several parameters to work correctly.",
      back: "Fonksiyonun doğru çalışması için birkaç parametre gerekir.",
      list: "C1",
      answer: "parametre", // This one was already correct
      quest: "parameter",
    ),

    Words5(
      front: "Parental guidance is recommended for this movie.",
      back: "Bu film için ebeveyn rehberliği önerilir.",
      list: "C1",
      answer: "ebeveyne ait",
      quest: "parental",
    ),
    Words5(
      front: "The judge tried to remain impartial during the trial.",
      back: "Hakim dava sırasında tarafsız kalmaya çalıştı.",
      list: "C1",
      answer:
          "taraflı", // "Taraflı" means "biased". A better translation for "partial" is "tarafsız olmayan".
      quest: "partial",
    ),
    Words5(
      front: "The building was partially destroyed in the fire.",
      back: " Bina yangında kısmen yıkıldı.",
      list: "C1",
      answer: "kısmen",
      quest: "partially",
    ),
    Words5(
      front: "There were many cars passing by on the busy street.",
      back: "Yoğun caddede yanından geçen birçok araba vardı.",
      list: "C1",
      answer: "geçiş",
      quest: "passing",
    ),
    Words5(
      front: "He has a passive personality and avoids confrontation.",
      back: "Pasif bir kişiliğe sahip ve yüzleşmekten kaçınıyor.",
      list: "C1",
      answer: "pasif",
      quest: "passive",
    ),
    Words5(
      front: "The local pastor gave a sermon about faith and forgiveness.",
      back: "Yerel papaz, iman ve affetme dair bir vaaz verdi.",
      list: "C1",
      answer: "papaz",
      quest: "pastor",
    ),
    Words5(
      front: "He tried to fix the hole in the wall with a patch.",
      back: "Duvardaki deliği bir yama ile kapatmaya çalıştı.",
      list: "C1",
      answer: "yama",
      quest: "patch",
    ),
    Words5(
      front: "We walked along a scenic pathway through the forest.",
      back: "Ormanda güzel bir patika boyunca yürüdük.",
      list: "C1",
      answer:
          "yaya geçidi", // "Yaya geçidi" means "crosswalk". A better translation for "pathway" is "patika".
      quest: "pathway",
    ),
    Words5(
      front: "The police patrol cars will be out all night tonight.",
      back: "Polis devriye arabaları bu gece bütün gece dışarıda olacak.",
      list: "C1",
      answer: "devriye",
      quest: "patrol",
    ),
    Words5(
      front: "The mountain reached its peak at an altitude of 3,000 meters.",
      back: "Dağ, 3.000 metrelik bir yükseklikte zirveye ulaştı.",
      list: "C1",
      answer: "zirve",
      quest: "peak",
    ),
    Words5(
      front: "The peasants lived a simple life on their small farm.",
      back: "Köylüler küçük çiftliklerinde sade bir hayat sürdüler.",
      list: "C1",
      answer: "köylü",
      quest: "peasant",
    ),
    Words5(
      front: "He has a peculiar sense of humor that not everyone understands.",
      back: "Herkesin anlamadığı, kendine özgü bir mizah anlayışı var.",
      list: "C1",
      answer:
          "özel eşya", // "Özel eşya" means "personal belongings". A better translation for "peculiar" is "kendine özgü".
      quest: "peculiar",
    ),
    Words5(
      front: "He persisted in working late despite being tired.",
      back: "Yorgun olmasına rağmen geç saatlere kadar çalışmakta ısrar etti.",
      list: "C1",
      answer:
          "ısrar etmek", // Changed from "üstelemek" to better reflect "persist"
      quest: "persist",
    ),

    Words5(
      front: "She is a persistent student who always asks questions in class.",
      back: "O, sınıfta her zaman soru soran ısrarcı bir öğrencidir.",
      list: "C1",
      answer: "ısrar eden", // This one was already correct
      quest: "persistent",
    ),
    Words5(
      front:
          "The company is hiring new personnel for the marketing department.",
      back: "Şirket, pazarlama departmanı için yeni eleman alıyor.",
      list: "C1",
      answer: "eleman",
      quest: "personnel",
    ),
    Words5(
      front:
          "They submitted a petition to the government to protest the new law.",
      back: "Yeni yasayı protesto etmek için hükümete bir dilekçe sundular.",
      list: "C1",
      answer: "dilekçe",
      quest: "petition",
    ),
    Words5(
      front: "Socrates was a famous ancient Greek philosopher.",
      back: "Sokrates, ünlü bir antik Yunan filozofuydu.",
      list: "C1",
      answer: "filozof",
      quest: "philosopher",
    ),
    Words5(
      front:
          "The article discussed the philosophical implications of artificial intelligence.",
      back: "Makale, yapay zekanın felsefi çıkarımlarını ele aldı.",
      list: "C1",
      answer: "felsefi",
      quest: "philosophical",
    ),
    Words5(
      front: "She is seeing a physician to get a checkup for her allergies.",
      back: "Alerjileri için kontrolden geçmek üzere bir hekim görüyor.",
      list: "C1",
      answer: "hekim",
      quest: "physician",
    ),
    Words5(
      front:
          "Louis Braille was a pioneer in developing a writing system for the blind.",
      back: "Louis Braille, körler için yazı sistemi geliştiren bir öncüydü.",
      list: "C1",
      answer: "öncü",
      quest: "pioneer",
    ),
    Words5(
      front:
          "The oil is transported from the wells to the refinery through a pipeline.",
      back: "Petrol, kuyulardan rafineriye boru hattı aracılığıyla taşınır.",
      list: "C1",
      answer: "boru hattı",
      quest: "pipeline",
    ),
    Words5(
      front: "Pirates were seafaring robbers who attacked ships for treasure.",
      back: "Korsanlar, hazine için gemilere saldıran denizci soygunculardı.",
      list: "C1",
      answer: "korsan",
      quest: "pirate",
    ),
    Words5(
      front: "He fell into a deep pit and had to be rescued.",
      back: "Derin bir çukura düştü ve kurtarılması gerekti.",
      list: "C1",
      answer: "çukur",
      quest: "pit",
    ),
    Words5(
      front: "The defendant entered a plea of not guilty at the trial.",
      back: "Sanık, mahkemede kendini suçsuz olduğunu savundu.",
      list: "C1",
      answer: "savunma", // This one was already correct
      quest: "plea",
    ),
    Words5(
      front: "He pleaded with the judge for leniency in his sentence.",
      back: "Hakimden cezasında müsamaha göstermesini savunma yaptı.",
      list: "C1",
      answer: "savunma yapmak", // This one was already correct
      quest: "plead",
    ),
    Words5(
      front: "He made a pledge to donate money to charity.",
      back: "Hayır kurumuna para bağışlama sözü verdi.",
      list: "C1",
      answer: "söz", // Changed from "rehin" to better reflect a verbal pledge
      quest: "pledge",
    ),
    Words5(
      front: "You need to unplug the charger before cleaning the device.",
      back: "Cihazı temizlemeden önce fişi prizden çekmeniz gerekiyor.",
      list: "C1",
      answer: "fiş",
      quest: "plug",
    ),
    Words5(
      front: "He took a daring plunge into the icy cold water.",
      back: "Cesaretli bir şekilde buz gibi soğuk suya daldı.",
      list: "C1",
      answer: "dalma",
      quest: "plunge",
    ),
    Words5(
      front: "The flag was waving proudly on top of the pole.",
      back: "Bayrak, direğin tepesinde gururla dalgalanıyordu.",
      list: "C1",
      answer: "direk",
      quest: "pole",
    ),
    Words5(
      front:
          "Scientists are conducting a poll to gauge public opinion on the issue.",
      back:
          "Bilim insanları, konu hakkındaki kamuoyu görüşünü ölçmek için bir anket düzenliyor.",
      list: "C1",
      answer:
          "anket yapmak", // "Kesmek" means "to cut". A better translation for "poll" is "anket yapmak".
      quest: "poll",
    ),
    Words5(
      front: "There are many ducks and geese swimming in the pond.",
      back: "Gölette birçok ördek ve kaz yüzüyor.",
      list: "C1",
      answer: "gölet",
      quest: "pond",
    ),
    Words5(
      front: "The crowd cheered as the fireworks popped in the night sky.",
      back:
          "Havai fişekler gece gökyüzünde patladıkça kalabalık tezahürat etti.",
      list: "C1",
      answer: "patlatmak",
      quest: "pop",
    ),
    Words5(
      front:
          "The actor perfectly portrayed the character of a troubled teenager.",
      back:
          "Oyuncu, sorunlu bir gencin karakterini mükemmel bir şekilde canlandırdı.",
      list: "C1",
      answer: "rolünü oynamak",
      quest: "portray",
    ),
    Words5(
      front: "We had to postpone the meeting due to unforeseen circumstances.",
      back:
          "Öngörülemeyen durumlar nedeniyle toplantıyı ertelemek zorunda kaldık.",
      list: "C1",
      answer: "ertelemek",
      quest: "postpone",
    ),
    Words5(
      front:
          "The country is still recovering from the devastation of the post-war period.",
      back:
          "Ülke, savaş sonrası döneminden kaynaklanan yıkımdan hâlâ toparlanıyor.",
      list: "C1",
      answer: "savaş sonrası",
      quest: "post-war",
    ),
    Words5(
      front:
          "She is a qualified yoga practitioner with many years of experience.",
      back:
          "Uzun yıllara dayanan deneyime sahip kalifiyeli bir yoga uygulayıcısıdır.",
      list: "C1",
      answer: "uygulayan kimse",
      quest: "practitioner",
    ),
    Words5(
      front:
          "The pastor preached a sermon about the importance of forgiveness.",
      back: "Papaz, affetmenin önemi hakkında bir vaaz verdi.",
      list: "C1",
      answer: "vaaz vermek",
      quest: "preach",
    ),
    Words5(
      front:
          "Setting a good example is an important precedent for others to follow.",
      back:
          "İyi bir örnek oluşturmak, diğerlerinin takip edebileceği önemli bir emsaldir.",
      list: "C1",
      answer: "örnek oluşturan durum",
      quest: "precedent",
    ),
    Words5(
      front: "The function requires several parameters to work correctly.",
      back: "Fonksiyonun doğru çalışması için birkaç parametre gerekir.",
      list: "C1",
      answer: "parametre", // This one was already correct
      quest: "precision",
    ),

    Words5(
      front: "The lion is a predator that hunts other animals for food.",
      back:
          "Aslan, avını yemek için diğer hayvanları avlayan bir avcı hayvandır.",
      list: "C1",
      answer: "avcı hayvan",
      quest: "predator",
    ),
    Words5(
      front: "He is the predecessor of the current company CEO.",
      back:
          "O, şu anki şirket CEO'sunun öncülüdür.", // Changed "öncü" to "öncül" for predecessor
      list: "C1",
      answer: "öncül",
      quest: "predecessor",
    ),
    Words5(
      front: "The population in this area is predominantly rural.",
      back:
          "Bu bölgedeki nüfus çoğunlukla kırsaldır.", // Changed "çoğu" to "çoğunlukla" for predominantly
      list: "C1",
      answer: "çoğunlukla",
      quest: "predominantly",
    ),
    Words5(
      front: "She is in the early stages of pregnancy.",
      back: "Gebeliğin erken aşamasındadır.",
      list: "C1",
      answer: "hamilelik",
      quest: "pregnancy",
    ),
    Words5(
      front: "He faced a lot of prejudice because of his race.",
      back: "Irkı yüzünden çok fazla önyargı ile karşılaştı.",
      list: "C1",
      answer: "önyargı",
      quest: "prejudice",
    ),
    Words5(
      front:
          "We need to do a preliminary investigation before finalizing the plan.",
      back: "Planı kesinleştirmeden önce bir ön inceleme yapmamız gerekiyor.",
      list: "C1",
      answer: "ön",
      quest: "preliminary",
    ),
    Words5(
      front:
          "The Prime Minister is the premier political leader of the country.",
      back: "Başbakan, ülkenin başta gelen siyasi lideridir.",
      list: "C1",
      answer:
          "başta gelen", // "Sınıf veya önem bakımından ilk sırada" is more formal and can be used.
      quest: "premier",
    ),
    Words5(
      front: "The story is based on the premise that aliens exist.",
      back: "Hikaye, uzaylıların var olma öncülüne dayanmaktadır.",
      list: "C1",
      answer: "öncül",
      quest: "premise",
    ),
    Words5(
      front: "He paid a premium for the insurance policy with wider coverage.",
      back: "Daha geniş kapsamlı sigorta poliçesi için prim ödedi.",
      list: "C1",
      answer:
          "ikramiye", // "İkramiye" means "bonus". A better translation for "premium" is "prim".
      quest: "premium",
    ),
    Words5(
      front: "The doctor prescribed medication to treat her allergies.",
      back: "Doktor, alerjilerini tedavi etmek için ilaç yazdı.",
      list: "C1",
      answer: "reçete yazmak",
      quest: "prescribe",
    ),
    Words5(
      front:
          "He needs to get a prescription from the doctor to refill his medication.",
      back: "İlacını tekrar doldurmak için doktordan reçete alması gerekiyor.",
      list: "C1",
      answer: "reçete",
      quest: "prescription",
    ),
    Words5(
      front: "Presently, I am working on a new project.",
      back: "Şu anda yeni bir proje üzerinde çalışıyorum.",
      list: "C1",
      answer: "şimdi",
      quest: "presently",
    ),
    Words5(
      front:
          "The organization is dedicated to the preservation of historical buildings.",
      back: "Kuruluş, tarihi binaların korunmasına kendini adamıştır.",
      list: "C1",
      answer: "koruma",
      quest: "preservation",
    ),
    Words5(
      front:
          "The judge will preside over the trial and ensure fair proceedings.",
      back:
          "Hakim duruşmaya başkanlık edecek ve adil bir yargılama sürecini sağlayacaktır.",
      list: "C1",
      answer: "başkanlık yapmak",
      quest: "preside",
    ),
    Words5(
      front: "He served two terms in the presidency before stepping down.",
      back: "Görevinden ayrılmadan önce iki dönem cumhurbaşkanlığı yaptı.",
      list: "C1",
      answer: "cumhurbaşkanlığı",
      quest: "presidency",
    ),
    Words5(
      front:
          "The presidential election is a very important event in the country.",
      back: "Cumhurbaşkanlığı seçimi, ülke için çok önemli bir olaydır.",
      list: "C1",
      answer:
          "cumhurbaşkanlığı", // "Saygın" can be used for respected, but "cumhurbaşkanlığı" is more specific here.
      quest: "presidential",
    ),
    Words5(
      front: "Winning this award is a prestigious honor for any scientist.",
      back:
          "Bu ödülü kazanmak, herhangi bir bilim insanı için prestijli bir onurdur.",
      list: "C1",
      answer: "prestijli",
      quest: "prestigious",
    ),
    Words5(
      front: "Presumably, they will arrive on time for the meeting.",
      back: "Muhtemelen toplantıya zamanında gelecekler.",
      list: "C1",
      answer: "galiba",
      quest: "presumably",
    ),
    Words5(
      front: "I presume you already know the answer to this question.",
      back: "Sanırım bu sorunun cevabını zaten biliyorsunuz.",
      list: "C1",
      answer: "farzetmek",
      quest: "presume",
    ),
    Words5(
      front: "In the end, good always prevails over evil.",
      back: "Sonunda iyilik her zaman kötülüğe üstün gelir.",
      list: "C1",
      answer: "üstün gelmek",
      quest: "prevail",
    ),
    Words5(
      front:
          "The prevalence of heart disease is a major public health concern.",
      back:
          "Kalp hastalıklarının yaygınlığı önemli bir halk sağlığı sorunudur.",
      list: "C1",
      answer: "yaygınlık",
      quest: "prevalence",
    ),
    Words5(
      front:
          "Vaccination is an effective method for the prevention of infectious diseases.",
      back:
          "Aşılama, bulaşıcı hastalıkların önlenmesi için etkili bir yöntemdir.",
      list: "C1",
      answer: "önlem",
      quest: "prevention",
    ),
    Words5(
      front:
          "The lion is a predator that hunts prey such as zebras and gazelles.",
      back: "Aslan, zebra ve ceylan gibi avları avlayan bir avcıdır.",
      list: "C1",
      answer: "av",
      quest: "prey",
    ),
    Words5(
      front: "The principal is the head administrator of a school.",
      back: "Müdür, bir okulun baş yöneticisidir.",
      list: "C1",
      answer: "okul müdürü",
      quest: "principal",
    ),
    Words5(
      front:
          "The government is considering the privatization of some state-owned companies.",
      back: "Hükümet, bazı devlet işletmelerinin özelleştirilmesini düşünüyor.",
      list: "C1",
      answer: "özelleştirme",
      quest: "privatization",
    ),
    Words5(
      front: "He comes from a wealthy family and enjoys many privileges.",
      back: "Zengin bir aileden geliyor ve birçok imtiyazın tadını çıkarıyor.",
      list: "C1",
      answer: "imtiyaz", // This was already correct
      quest: "privilege",
    ),
    Words5(
      front: "The space probe is collecting data from Mars.",
      back: "Uzay sondası Mars'tan veri topluyor.",
      list: "C1",
      answer: "inceleme", // This is a good translation for "probe"
      quest: "probe",
    ),
    Words5(
      front:
          "The judge reviewed the court proceedings before making a decision.",
      back: "Hakim karar vermeden önce mahkeme tutanaklarını inceledi.",
      list: "C1",
      answer: "tutanak", // "Konferans" means "conference"
      quest: "proceedings",
    ),
    Words5(
      front:
          "All proceeds from the charity event will go to help children in need.",
      back:
          "Hayır etkinliğinden elde edilen tüm gelir ihtiyacı olan çocuklara yardım etmek için gidecek.",
      list: "C1",
      answer: "gelir", // "Verim" means "yield"
      quest: "proceeds",
    ),
    Words5(
      front: "The computer is still processing the data.",
      back: "Bilgisayar hala verileri işliyor.",
      list: "C1",
      answer: "işleme tabi tutma",
      quest: "processing",
    ),
    Words5(
      front: "The central processor is the main chip in a computer.",
      back: "Merkezi işlemci, bir bilgisayardaki ana çiptir.",
      list: "C1",
      answer: "işlemci",
      quest: "processor",
    ),
    Words5(
      front: "The leader proclaimed a new era of peace and prosperity.",
      back: "Lider, barış ve refahın yeni bir dönemini ilan etti.",
      list: "C1",
      answer: "ilan etmek", // "Duyurmak" can also work here
      quest: "proclaim",
    ),
    Words5(
      front:
          "She is a very productive employee who always meets her deadlines.",
      back:
          "O, her zaman son teslim tarihlerine uyan çok verimli bir çalışandır.",
      list: "C1",
      answer: "verimli",
      quest: "productive",
    ),
    Words5(
      front: "The company is looking for ways to improve productivity.",
      back: "Şirket, verimliliği artırmanın yollarını arıyor.",
      list: "C1",
      answer: "verimlilik",
      quest: "productivity",
    ),
    Words5(
      front: "Investing in the stock market can be a profitable venture.",
      back: "Borsa yatırımı karlı bir girişim olabilir.",
      list: "C1",
      answer: "karlı",
      quest: "profitable",
    ),
    Words5(
      front:
          "He made a profound impact on the field of physics with his groundbreaking research.",
      back: "Çığır açan araştırmasıyla fizik alanında derin bir etki bıraktı.",
      list: "C1",
      answer: "derin",
      quest: "profound",
    ),
    Words5(
      front: "She is a prominent figure in the world of human rights activism.",
      back: "İnsan hakları aktivizmi dünyasında önemli bir figürdür.",
      list: "C1",
      answer: "önemli", // "Öne çıkan" can also be used here
      quest: "prominent",
    ),
    Words5(
      front:
          "He has a very pronounced accent, which makes his speech difficult to understand.",
      back:
          "Anlaması zor olan konuşmasını sağlayan çok belirgin bir a لهجهsi (lehçe) var.",
      list: "C1",
      answer: "belirgin",
      quest: "pronounced",
    ),
    Words5(
      front: "He made a proposition to buy the house for a lower price.",
      back: "Evi daha düşük bir fiyata satın almak için bir teklif sundu.",
      list: "C1",
      answer: "teklif etmek",
      quest: "proposition",
    ),
    Words5(
      front: "The police will prosecute the suspect for the crime.",
      back: "Polis, şüpheliyi suçtan dolayı kovuşturmaya devam edecek.",
      list: "C1",
      answer: "kovuşturmak",
      quest: "prosecute",
    ),
    Words5(
      front:
          "The defense and prosecution presented their closing arguments in court.",
      back: "Savunma ve savcılık, mahkemede kapanış konuşmalarını yaptılar.",
      list: "C1",
      answer: "savcılık",
      quest: "prosecution",
    ),
    Words5(
      front: "The prosecutor is responsible for presenting evidence in court.",
      back: "Savcı, mahkemede delil sunmaktan sorumludur.",
      list: "C1",
      answer: "savcı",
      quest: "prosecutor",
    ),
    Words5(
      front: "They are a prospective new client for our company.",
      back: "Onlar şirketimiz için potansiyel yeni bir müşteri.",
      list: "C1",
      answer: "potansiyel", // "İleriye yönelik" can be more formal
      quest: "prospective",
    ),
    Words5(
      front:
          "The country is experiencing a period of great prosperity and economic growth.",
      back: "Ülke, büyük refah ve ekonomik büyüme dönemi yaşıyor.",
      list: "C1",
      answer: "refah",
      quest: "prosperity",
    ),
    Words5(
      front: "He wore a protective helmet while riding his motorcycle.",
      back: "Motosiklet sürerken koruyucu kask taktı.",
      list: "C1",
      answer: "koruyucu",
      quest: "protective",
    ),
    Words5(
      front: "Turkey is a country divided into 81 provinces.",
      back: "Türkiye, 81 ile bölünmüş bir ülkedir.",
      list: "C1",
      answer: "il", // "Vilayet" is an older term for province
      quest: "province",
    ),
    Words5(
      front:
          "The contract includes provisions for termination in case of breach.",
      back: "Sözleşme, fesih durumunda fesih hükümlerini içerir.",
      list: "C1",
      answer:
          "hüküm", // "Karşılık" can mean counterpart, but "hüküm" is a more general term for provision
      quest: "provision",
    ),
    Words5(
      front: "His words were intended to provoke a reaction from the crowd.",
      back: "Sözleri kalabalıktan bir tepki çekmeyi amaçlıyordu.",
      list: "C1",
      answer: "kışkırtmak",
      quest: "provoke",
    ),
    Words5(
      front: "The doctor checked her pulse to assess her heart rate.",
      back:
          "Doktor, kalp atış hızını değerlendirmek için nabzını kontrol etti.",
      list: "C1",
      answer: "nabız",
      quest: "pulse",
    ),
    Words5(
      front: "The farmer used a pump to water his crops.",
      back: "Çiftçi, mahsullerini sulamak için bir pompa kullandı.",
      list: "C1",
      answer: "pompa",
      quest: "pump",
    ),
    Words5(
      front: "He threw a powerful punch that knocked out his opponent.",
      back: "Rakibini nakavt eden güçlü bir yumruk attı.",
      list: "C1",
      answer: "yumruk",
      quest: "punch",
    ),
    Words5(
      front: "He embarked on a quest to find the lost treasure.",
      back: "Kayıp hazineyi bulmak için bir arayışa başladı.",
      list: "C1",
      answer: "arayış",
      quest: "quest",
    ),
    Words5(
      front: "The company did not meet its sales quota this month.",
      back: "Şirket, bu ay satış kotasını karşılayamadı.",
      list: "C1",
      answer: "kota",
      quest: "quota",
    ),
    Words5(
      front: "He flew into a rage when he heard the bad news.",
      back:
          "Kötü haberi duyduğunda öfkeye kapıldı.", // "Kudurmak" is a bit too strong for "rage" in this context.
      list: "C1",
      answer: "öfke", // A better translation for "rage" here
      quest: "rage",
    ),
    Words5(
      front: "The police conducted a raid on the suspected hideout.",
      back: "Polis, şüpheli saklanma yerine baskın düzenledi.",
      list: "C1",
      answer: "baskın",
      quest: "raid",
    ),
    Words5(
      front:
          "Thousands of people rallied in the streets to protest the government's policies.",
      back:
          "Hükümetin politikalarını protesto etmek için binlerce insan sokaklara toplandı.",
      list: "C1",
      answer: "toplanmak",
      quest: "rally",
    ),
    Words5(
      front:
          "The university ranking lists the top institutions in the country.",
      back: "Üniversite sıralaması, ülkedeki en iyi kurumları listeler.",
      list: "C1",
      answer: "sıralama",
      quest: "ranking",
    ),
    Words5(
      front:
          "The doctor measured the ratio of oxygen to carbon dioxide in the blood.",
      back: "Doktor, kandaki oksijen-karbondi oksit oranını ölçtü.",
      list: "C1",
      answer: "oran",
      quest: "ratio",
    ),
    Words5(
      front: "The sun's rays shone brightly through the window.",
      back: "Güneşin ışınları pencereden içeriye parlak bir şekilde vurdu.",
      list: "C1",
      answer: "ışın",
      quest: "ray",
    ),
    Words5(
      front: "He was readily available to help anyone in need.",
      back: "İhtiyacı olan herkese kolaylıkla yardım etmeye hazırdı.",
      list: "C1",
      answer: "kolaylıkla",
      quest: "readily",
    ),
    Words5(
      front: "The sudden realization of his mistake filled him with regret.",
      back: "Hatasının ani kavraması onu pişmanlıkla doldurdu.",
      list: "C1",
      answer: "kavrama",
      quest: "realization",
    ),
    Words5(
      front: "The kingdom is ruled by a wise and just king.",
      back: "Krallık, adil ve bilge bir kral tarafından yönetiliyor.",
      list: "C1",
      answer: "krallık",
      quest: "realm",
    ),
    Words5(
      front: "Please sit at the back of the bus.",
      back: "Lütfen otobüsün arkasına oturun.",
      list: "C1",
      answer: "arka",
      quest: "rear",
    ),
    Words5(
      front: "They used logical reasoning to solve the puzzle.",
      back: "Bulmacayı çözmek için mantıklı muhakeme yeteneği kullandılar.",
      list: "C1",
      answer: "muhakeme", // This was already correct
      quest: "reasoning",
    ),

    Words5(
      front: "Her kind words reassured him that everything would be alright.",
      back:
          "Nazik sözleri, her şeyin yoluna gireceğine dair onu güvence altına aldı.",
      list: "C1",
      answer: "güvence vermek",
      quest: "reassure",
    ),
    Words5(
      front: "The colonists rebelled against the tyranny of the British crown.",
      back: "Sömürgeciler, İngiliz tacının zulmüne ayaklandı.",
      list: "C1",
      answer: "ayaklanmak",
      quest: "rebel",
    ),
    Words5(
      front:
          "The country is still recovering from the devastation of the recent rebellion.",
      back:
          "Ülke hala yakın zamanda yaşanan ayaklanmanın tahribatından kurtulmaya çalışıyor.",
      list: "C1",
      answer: "ayaklanma",
      quest: "rebellion",
    ),
    Words5(
      front: "The recipient of the letter was her long-lost friend.",
      back: "Mektup alıcısı, uzun zamandır kayıp olan arkadaşıydı.",
      list: "C1",
      answer: "alıcı",
      quest: "recipient",
    ),
    Words5(
      front:
          "The city is undergoing a major reconstruction project after the earthquake.",
      back:
          "Şehir, depremden sonra büyük bir yeniden yapılanma projesi geçirmektedir.",
      list: "C1",
      answer: "yeniden yapılanma",
      quest: "reconstruction",
    ),
    Words5(
      front:
          "There may be a need to recount the votes if the election results are very close.",
      back:
          "Seçim sonuçları çok yakın ise, oyların yeniden sayılması gerekebilir.",
      list: "C1",
      answer: "yeniden saymak",
      quest: "recount",
    ),
    Words5(
      front: "He stared into the lake, lost in reflection.",
      back:
          "Göle baktı, düşüncelere dalmıştı.", // "Yansıma" can be a bit more abstract here.
      list: "C1",
      answer:
          "düşünce", // A better translation for "reflection" in this context
      quest: "reflection",
    ),
    Words5(
      front: "Many refugees fled the war-torn country in search of safety.",
      back:
          "Birçok mülteci, güvenlik arayışı içinde savaştan zarar görmüş ülkeden kaçtı.",
      list: "C1",
      answer: "sığınak",
      quest: "refuge",
    ),
    Words5(
      front: "He was met with a refusal when he asked for a raise.",
      back: "Zam istediğinde reddetme ile karşılaşıldı.",
      list: "C1",
      answer: "reddetme",
      quest: "refusal",
    ),
    Words5(
      front:
          "Despite the challenges, they were determined to regain control of their lives.",
      back: "Zorluklara rağmen, hayatlarını geri kazanmaya kararlıydılar.",
      list: "C1",
      answer: "geri kazanmak",
      quest: "regain",
    ),
    Words5(
      front: "Regardless of the weather, they will go on their camping trip.",
      back: "Havaya aldırmadan, kamp gezisine çıkacaklar.",
      list: "C1",
      answer: "aldırışsız",
      quest: "regardless",
    ),
    Words5(
      front: "The company is subject to a number of regulatory requirements.",
      back: "Şirket, bir dizi düzenleyici gerekliliğe tabidir.",
      list: "C1",
      answer: "düzenleyici",
      quest: 'regulatory',
    ),
    Words5(
      front: "Queen Elizabeth II's reign lasted for over 70 years.",
      back: "II. Elizabeth Kraliçesi'nin saltanatı 70 yıldan fazla sürdü.",
      list: "C1",
      answer: "saltanat",
      quest: "reign",
    ),
    // Existing entries...

    Words5(
      front:
          "He felt a deep sense of rejection after being passed over for the promotion.",
      back: "Terfi için geçildikten sonra derin bir reddetme duygusu hissetti.",
      list: "C1",
      answer: "reddetme",
      quest: "rejection",
    ),
    Words5(
      front: "The relevance of this study to current events is undeniable.",
      back: "Bu çalışmanın güncel olaylarla ilgisi inkar edilemez.",
      list: "C1",
      answer: "ilgi",
      quest: "relevance",
    ),
    Words5(
      front:
          "The company is known for its reliability and excellent customer service.",
      back: "Şirket, güvenilirliği ve mükemmel müşteri hizmeti ile tanınır.",
      list: "C1",
      answer: "güvenilirlik",
      quest: "reliability",
    ),
    Words5(
      front: "He was reluctant to join the project, but eventually agreed.",
      back: "Projeye katılmaya gönülsüzdü, ancak sonunda kabul etti.",
      list: "C1",
      answer: "gönülsüz",
      quest: "reluctant",
    ),
    Words5(
      front: "After eating half the pizza, there was a large remainder left.",
      back:
          "Pizzanın yarısını yedikten sonra geriye kalan büyük bir parça kaldı.",
      list: "C1",
      answer: "kalan", // "Geri kalan" is also acceptable
      quest: "remainder",
    ),
    Words5(
      front: "The archaeologists discovered the remains of an ancient city.",
      back: "Arkeologlar, antik bir şehrin kalıntılarını keşfettiler.",
      list: "C1",
      answer: "kalıntılar",
      quest: "remains",
    ),
    Words5(
      front: "Exercise is a good remedy for stress and anxiety.",
      back: "Egzersiz, stres ve kaygı için iyi bir çaredir.",
      list: "C1",
      answer: "çare",
      quest: "remedy",
    ),
    Words5(
      front: "She set a reminder on her phone to call her mother.",
      back: "Annesini araması için telefonuna bir hatırlatma ayarladı.",
      list: "C1",
      answer: "hatırlatma",
      quest: "reminder",
    ),
    Words5(
      front: "The old building is scheduled for removal next month.",
      back: "Eski bina, önümüzdeki ay kaldırılması planlanıyor.",
      list: "C1",
      answer: "sökme",
      quest: "removal",
    ),
    Words5(
      front: "The artist used charcoal to render a portrait of the old man.",
      back: "Sanatçı, yaşlı adamın portresini resmetmek için kömür kullandı.",
      list: "C1",
      answer: "resmetmek",
      quest: "render",
    ),
    Words5(
      front:
          "They decided to renew their wedding vows on their 25th anniversary.",
      back:
          "25. yıldönümlerinde evlilik yeminlerini yenilemeye karar verdiler.",
      list: "C1",
      answer: "yenilemek",
      quest: "renew",
    ),
    Words5(
      front: "The city is famous for its renowned museums and art galleries.",
      back: "Şehir, ünlü müzeleri ve sanat galerileri ile ünlüdür.",
      list: "C1",
      answer: "ünlü",
      quest: "renowned",
    ),
    Words5(
      front: "We are looking for a rental car for our trip.",
      back: "Gezimiz için kiralık bir araba arıyoruz.",
      list: "C1",
      answer: "kiralık",
      quest: "rental",
    ),
    Words5(
      front: "The faulty product was replaced with a new one under warranty.",
      back: "Hatalı ürün, garanti kapsamında yenisiyle değiştirildi.",
      list: "C1",
      answer: "yenisiyle değiştirme",
      quest: "replacement",
    ),
    Words5(
      front: "Reportedly, the president is going to resign next week.",
      back: "Söylentilere göre, cumhurbaşkanı önümüzdeki hafta istifa edecek.",
      list: "C1",
      answer: "söylentilere göre",
      quest: "reportedly",
    ),
    Words5(
      front:
          "The painting is a beautiful representation of the Italian countryside.",
      back: "Resim, İtalyan kırsalının güzel bir temsilidir.",
      list: "C1",
      answer: "temsil",
      quest: "representation",
    ),
    Words5(
      front: "Scientists are trying to reproduce the experiment.",
      back: "Bilim adamları deneyi yeniden üretmeye çalışıyorlar.",
      list: "C1",
      answer: "yeniden üretmek",
      quest: "reproduce",
    ),
    Words5(
      front: "Asexual reproduction is a common method for some plants.",
      back: "Bazı bitkiler için eşeysiz çoğalma yaygın bir yöntemdir.",
      list: "C1",
      answer: "çoğalma", // "Üreme" can also be used here.
      quest: "reproduction",
    ),
    Words5(
      front: "France is a republic with a democratically elected president.",
      back:
          "Fransa, demokratik olarak seçilmiş bir cumhurbaşkanı olan bir cumhuriyettir.",
      list: "C1",
      answer: "cumhuriyet",
      quest: "republic",
    ),
    Words5(
      front: "The two buildings closely resemble each other in design.",
      back: "İki bina tasarım olarak birbirine çok benziyor.",
      list: "C1",
      answer: "benzemek",
      quest: "resemble",
    ),
    Words5(
      front: "He has resided in France for the past 20 years.",
      back: "Son 20 yıldır Fransa'da ikamet ediyor.",
      list: "C1",
      answer: "ikamet etmek",
      quest: "reside",
    ),
    Words5(
      front: "They are looking to buy a residence in a quiet neighborhood.",
      back:
          "Sakin bir mahallede oturmak için bir mesken satın almak istiyorlar.",
      list: "C1",
      answer: "mesken",
      quest: "residence",
    ),
    Words5(
      front:
          "This area is a residential neighborhood with mostly single-family homes.",
      back:
          "Bu alan çoğunlukla müstakil evlerin bulunduğu oturmaya elverişli bir mahalleden oluşuyor.",
      list: "C1",
      answer: "oturmaya elverişli",
      quest: "residential",
    ),
    Words5(
      front: "After cleaning the pan, there was a greasy residue left over.",
      back: "Tavayı temizledikten sonra yağlı bir tortu kaldı.",
      list: "C1",
      answer: "tortu",
      quest: "residue",
    ),
    Words5(
      front:
          "He submitted his resignation from the company after accepting a new position.",
      back: "Yeni bir görevi kabul ettikten sonra şirketten istifa etti.",
      list: "C1",
      answer: "istifa",
      quest: "resignation",
    ),
    Words5(
      front:
          "They each presented their ideas, stating their respective positions on the issue.",
      back:
          "Her biri kendi fikirlerini sundu ve konuyla ilgili kendi şahsi konumlarını belirtti.",
      list: "C1",
      answer: "şahsi",
      quest: "respective",
    ),
    Words5(
      front:
          "John won first place, Mary came in second, and David came in third, respectively.",
      back: "John birinci oldu, Mary ikinci, David ise sırasıyla üçüncü oldu.",
      list: "C1",
      answer: "sırasıyla",
      quest: "respectively",
    ),
    Words5(
      front:
          "He showed great restraint in not arguing back when he was insulted.",
      back:
          "Hakaret edildiğinde karşılık vermeyerek büyük bir kısıtlama gösterdi.",
      list: "C1",
      answer: "kısıtlama",
      quest: "restraint",
    ),
    Words5(
      front:
          "The meeting was interrupted, but we will resume it later this afternoon.",
      back: "Toplantı yarıda kesildi, ancak öğleden sonra devam edeceğiz.",
      list: "C1",
      answer: "sürdürmek",
      quest: "resume",
    ),
    Words5(
      front:
          "The enemy forces were forced to retreat after suffering heavy losses.",
      back:
          "Düşman güçleri, ağır kayıplar verdikten sonra geri çekilmek zorunda kaldı.",
      list: "C1",
      answer: "geri çekilmek",
      quest: "retreat",
    ),
    Words5(
      front: "He went back to his room to retrieve his forgotten phone.",
      back: "Unutmuş olduğu telefonunu almak için odasına geri döndü.",
      list: "C1",
      answer: "geri almak",
      quest: "retrieve",
    ),
    Words5(
      front: "The discovery of a new planet was a scientific revelation.",
      back: "Yeni bir gezegenin keşfi bilimsel bir vahiy niteliğindeydi.",
      list: "C1",
      answer: "vahiy",
      quest: "revelation",
    ),
    Words5(
      front: "He vowed to get revenge on those who had wronged him.",
      back: "Kendisine haksızlık edenlerden intikam almak için yemin etti.",
      list: "C1",
      answer: "intikam almak",
      quest: "revenge",
    ),
    Words5(
      front: "The opposite of hot is cold, and the reverse of true is false.",
      back: "Sıcağın karşıtı soğuktur, doğrunun tersi ise yanlıştır.",
      list: "C1",
      answer: "ters",
      quest: "reverse",
    ),
    Words5(
      front: "There are signs of a revival in the city's cultural scene.",
      back: "Şehrin kültürel hayatında bir canlanma emareleri var.",
      list: "C1",
      answer: "canlanma",
      quest: "revival",
    ),
    Words5(
      front:
          "The old painting was carefully restored to revive its former beauty.",
      back:
          "Eski resim, eski güzelliğini canlandırmak için dikkatlice restore edildi.",
      list: "C1",
      answer: "canlandırmak",
      quest: "revive",
    ),
    Words5(
      front:
          "The politician's speech was full of empty rhetoric and made no real promises.",
      back:
          "Politikacının konuşması boş güzel konuşmadan ibaret olup hiçbir gerçek vaatte bulunmadı.",
      list: "C1",
      answer:
          "güzel konuşma", // "Retorik" can be used here too, but it's less common.
      quest: "rhetoric",
    ),
    Words5(
      front: "The soldier aimed his rifle at the target.",
      back: "Asker tüfeğini hedefe doğrulttu.",
      list: "C1",
      answer: "tüfek",
      quest: "rifle",
    ),
    Words5(
      front: "The angry protesters started a riot in the streets.",
      back: "Öfkeli göstericiler sokaklarda isyan çıkardı.",
      list: "C1",
      answer: "isyan etmek",
      quest: "riot",
    ),
    Words5(
      front: "He ripped a piece of paper out of his notebook.",
      back:
          "Defterinden bir sayfa kopardı.", // "Sökmek" can be used for tearing something off, but not necessarily ripping.
      list: "C1",
      answer: "koparmak", // A better translation for "rip" in this context
      quest: "rip",
    ),
    Words5(
      front:
          "The bridge is built with robust materials to withstand heavy traffic.",
      back:
          "Köprü, yoğun trafiğe dayanacak şekilde güçlü malzemelerden inşa edilmiştir.",
      list: "C1",
      answer: "güçlü",
      quest: "robust",
    ),
    Words5(
      front: "The music made her want to rock out all night.",
      back: "Müzik onu bütün gece sallanmak isteğine getirdi.",
      list: "C1",
      answer: "sallanmak",
      quest: "rock",
    ),
    Words5(
      front: "He used a metal rod to pry open the window.",
      back: "Pencereyi zorlamak için metal bir çubuk kullandı.",
      list: "C1",
      answer: "çubuk",
      quest: "rod",
    ),
    Words5(
      front: "The Earth rotates on its axis once every 24 hours.",
      back: "Dünya kendi ekseni etrafında 24 saatte bir döner.",
      list: "C1",
      answer: "dönmek",
      quest: "rotate",
    ),
    Words5(
      front:
          "The team practiced their routine for the dance competition, focusing on precise rotations.",
      back:
          "Takım, dans yarışması için rutini denedi ve hassas rotasyonlara odaklandı.",
      list: "C1",
      answer: "rotasyon",
      quest: "rotation",
    ),
    Words5(
      front: "The judge drew a blue line with a ruler to mark the boundary.",
      back: "Hakim, sınırı işaretlemek için cetvelle mavi bir çizgi çekti.",
      list: "C1",
      answer: "cetvelle çizmek",
      quest: "ruling",
    ),
    Words5(
      front:
          "There is a rumour going around that the company is going bankrupt.",
      back: "Şirketin iflas edeceğine dair bir söylenti ortalıkta dolaşıyor.",
      list: "C1",
      answer: "söylenti",
      quest: "rumour",
    ),
    Words5(
      front: "He was sacked from his job for poor performance.",
      back: "Düşük performans nedeniyle işinden kovuldu.",
      list: "C1",
      answer:
          "kovulmak", // "Çuvala koymak" is not a common expression for getting fired.
      quest: "sack",
    ),
    Words5(
      front: "Many cultures consider cows to be sacred animals.",
      back: "Birçok kültür inekleri kutsal hayvanlar olarak görür.",
      list: "C1",
      answer: "kutsal",
      quest: "sacred",
    ),
    Words5(
      front: "He did it for the sake of his family.",
      back: "Bunun için ailesinin hatırına yaptı.",
      list: "C1",
      answer: "hatır",
      quest: "sake",
    ),
    Words5(
      front:
          "The country is facing economic sanctions due to its human rights violations.",
      back:
          "Ülke, insan hakları ihlalleri nedeniyle yaptırımlarla karşı karşıyadır.",
      list: "C1",
      answer: "yaptırım",
      quest: "sanction",
    ),
    Words5(
      front: "Can you say that again?",
      back: "Bunu tekrar söyleyebilir misin?",
      list: "C1",
      answer: "söylemek",
      quest: "say",
    ),
    Words5(
      front: "The toys were scattered all over the floor.",
      back: "Oyuncaklar yere dağınık bir şekilde saçılmıştı.",
      list: "C1",
      answer: "dağınık",
      quest: "scattered",
    ),
    Words5(
      front: "He was skeptical of the claims made by the salesperson.",
      back: "Satış görevlisinin yaptığı iddialara şüpheyle yaklaştı.",
      list: "C1",
      answer: "kuşkucu",
      quest: "sceptical",
    ),
    Words5(
      front:
          "The project falls outside the scope of my current responsibilities.",
      back: "Proje şu anki sorumluluk alanımın dışında kalıyor.",
      list: "C1",
      answer: "faaliyet alanı",
      quest: "scope",
    ),
    Words5(
      front: "He carefully screwed the two pieces of wood together.",
      back: "İki tahta parçasını dikkatlice vidaladı.",
      list: "C1",
      answer: "vidalamak",
      quest: "screw",
    ),
    Words5(
      front:
          "The company's financial records are under close scrutiny by the government.",
      back:
          "Şirketin mali kayıtları hükümet tarafından sıkı inceleme altındadır.",
      list: "C1",
      answer: "inceleme",
      quest: "scrutiny",
    ),
    Words5(
      front: "The envelope was sealed with a red wax stamp.",
      back: "Zarf, kırmızı bir mum mührü ile mühürlenmişti.",
      list: "C1",
      answer: "mühürlemek",
      quest: "seal",
    ),
    Words5(
      front:
          "The situation seemed calm on the surface, but tensions were high beneath it.",
      back: "Görünürde durum sakince görünse de, altında gerginlik yüksekti.",
      list: "C1",
      answer: "görünürde",
      quest: "seemingly",
    ),
    Words5(
      front:
          "The market can be segmented into different groups based on customer demographics.",
      back:
          "Pazar, müşteri demografik özelliklerine göre farklı segmentlere ayrılabilir.",
      list: "C1",
      answer: "bölmek",
      quest: "segment",
    ),
    Words5(
      front: "The police seized the drugs that were found in the car.",
      back: "Polis, arabada bulunan uyuşturucuları ele geçirdi.",
      list: "C1",
      answer: "el koymak",
      quest: "seize",
    ),
    Words5(
      front: "She seldom visits her hometown anymore.",
      back: "Artık memleketine nadiren gidiyor.",
      list: "C1",
      answer: "nadiren",
      quest: "seldom",
    ),
    Words5(
      front: "The university has a selective admissions process.",
      back: "Üniversitenin seçici bir kabul süreci vardır.",
      list: "C1",
      answer: "seçici",
      quest: "selective",
    ),
    Words5(
      front: "The sight of blood caused a wave of nausea and sensation.",
      back: "Kan görüntüsü bir mide bulantısı ve his dalgasına neden oldu.",
      list: "C1",
      answer: "his", // "Duyu" can also be used here.
      quest: "sensation",
    ),
    Words5(
      front:
          "People with allergies often have a heightened sensitivity to dust and pollen.",
      back:
          "Alerjisi olan kişiler genellikle toz ve polene karşı yüksek hassasiyete sahiptir.",
      list: "C1",
      answer: "hassasiyet",
      quest: "sensitivity",
    ),
    Words5(
      front: "The public sentiment was overwhelmingly in favor of the new law.",
      back: "Kamuoyu yeni yasadan yana ezici bir çoğunlukla duygu besliyordu.",
      list: "C1",
      answer: "düşünce",
      quest: "sentiment",
    ),
    Words5(
      front:
          "The separation of powers is a fundamental principle of democracy.",
      back: "Yetkilerin ayrılması, demokrasinin temel ilkelerinden biridir.",
      list: "C1",
      answer: "ayırma",
      quest: "separation",
    ),
    Words5(
      front: "He is a big fan of crime serial dramas.",
      back: "O, polisiye dizi filmlerinin büyük hayranıdır.",
      list: "C1",
      answer: "seri",
      quest: "serial",
    ),
    Words5(
      front:
          "The peace talks aimed to find a lasting settlement between the warring parties.",
      back:
          "Barış görüşmeleri, savaşan taraflar arasında kalıcı bir yerleşim bulmayı amaçlıyordu.",
      list: "C1",
      answer: "yerleşim",
      quest: "settlement",
    ),
    Words5(
      front: "How long does it take to set up the new printer?",
      back: "Yeni yazıcıyı kurmak ne kadar sürer?",
      list: "C1",
      answer:
          "kurmak", // "Set-up" can be translated as "kurmak" or "hazırlamak" depending on the context.
      quest: "set-up",
    ),
    Words5(
      front: "He is a major shareholder in the company.",
      back: "Şirketin büyük hissedarlarından biridir.",
      list: "C1",
      answer: "hissedar",
      quest: "shareholder",
    ),
    Words5(
      front: "The vase fell from the table and shattered into pieces.",
      back: "Vazo masadan düşüp paramparça oldu.",
      list: "C1",
      answer: "kırmak",
      quest: "shatter",
    ),
    Words5(
      front: "He shed a tear as he said goodbye to his old friend.",
      back: "Eski dostuna veda ederken bir damla gözyaşı döktü.",
      list: "C1",
      answer: "dökmek",
      quest: "shed",
    ),
    Words5(
      front: "She possessed sheer determination to succeed.",
      back: "Başarılı olmak için düpedüz bir kararlılığa sahipti.",
      list: "C1",
      answer: "düpedüz",
      quest: "sheer",
    ),
    Words5(
      front: "The cost of shipping the furniture overseas was very high.",
      back: "Mobilyaların yurt dışına gönderim masrafı çok yüksekti.",
      list: "C1",
      answer: "nakliye",
      quest: "shipping",
    ),
    Words5(
      front:
          "They are going to shoot a movie on location in Italy next summer.",
      back: "Gelecek yaz İtalya'da bir film çekimi yapacaklar.",
      list: "C1",
      answer: "film çekmek",
      quest: "shoot",
    ),
    Words5(
      front: "The sweater shrunk in the wash, so I can't wear it anymore.",
      back: "Kazak yıkandığında küçüldü, bu yüzden artık giyemiyorum.",
      list: "C1",
      answer: "küçültmek",
      quest: "shrink",
    ),
    Words5(
      front: "He shrugged his shoulders and said he didn't know.",
      back: "Omuzlarını silkti ve bilmediğini söyledi.",
      list: "C1",
      answer: "omuz silkmek",
      quest: "shrug",
    ),
    Words5(
      front: "She let out a sigh of relief when she finished the exam.",
      back: "Sınayı bitirdiğinde rahatlama iç çekti.",
      list: "C1",
      answer: "iç çekme",
      quest: "sigh",
    ),
    Words5(
      front:
          "The flight simulator is designed to simulate the experience of flying a real airplane.",
      back:
          "Uçuş simülatörü, gerçek bir uçak kullanma deneyimini simüle etmek için tasarlanmıştır.",
      list: "C1",
      answer: "taklidini yapmak",
      quest: "simulate",
    ),
    Words5(
      front: "The fire drill was a simulation of a real fire emergency.",
      back: "Yangın tatbikatı, gerçek bir yangın acil durumu simülasyonuydu.",
      list: "C1",
      answer: "simülasyon",
      quest: "simulation",
    ),
    Words5(
      front: "He translated the text into English simultaneously.",
      back: "Metni aynı anda İngilizceye çevirdi.",
      list: "C1",
      answer: "eş zamanlı",
      quest: "simultaneously",
    ),
    Words5(
      front: "Lying is a sin according to many religions.",
      back: "Yalan söylemek birçok dine göre günahtır.",
      list: "C1",
      answer: "günah",
      quest: "sin",
    ),
    Words5(
      front:
          "The village is situated in a beautiful valley surrounded by mountains.",
      back: "Köy, dağlarla çevrili güzel bir vadide konumlanmıştır.",
      list: "C1",
      answer: "konumlanmış",
      quest: "situated",
    ),
    Words5(
      front:
          "He made a rough sketch of the building before starting to draw the final plan.",
      back: "Nihai planı çizmeye başlamadan önce binanın taslağını yaptı.",
      list: "C1",
      answer: "taslağını yapmak",
      quest: "sketch",
    ),
    Words5(
      front: "We can skip this chapter as it is not relevant to the exam.",
      back: "Sınavla ilgili olmadığı için bu bölümü atlayabiliriz.",
      list: "C1",
      answer: "atlamak",
      quest: "skip",
    ),
    Words5(
      front:
          "The critics slammed the new movie, calling it a complete disaster.",
      back:
          "Eleştirmenler, yeni filmi yerden yere vurup tam bir felaket olarak nitelendirdiler.",
      list: "C1",
      answer: "eleştirmek",
      quest: "slam",
    ),
    Words5(
      front: "He received a slap on the wrist for his minor offense.",
      back: "Küçük suçundan dolayı tokat atar gibi bir ceza aldı.",
      list: "C1",
      answer: "tokat",
      quest: "slap",
    ),
    Words5(
      front:
          "The company's decision to outsource jobs was met with a slash in its stock price.",
      back:
          "Şirketin işleri dışarıya verme kararı, hisse senedi fiyatında büyük bir düşüşe yol açtı.",
      list: "C1",
      answer:
          "düşüş", // "Slash" can be translated as "düşüş" here to convey the idea of a sharp decrease.
      quest: "slash",
    ),
    Words5(
      front: "Slavery was finally abolished in the 19th century.",
      back: "Kölelik nihayet 19. yüzyılda kaldırıldı.",
      list: "C1",
      answer: "kölelik",
      quest: "slavery",
    ),
    Words5(
      front: "He inserted a new SIM card into the slot on his phone.",
      back:
          "Telefonuna SIM kartı taktı.", // "Yerleştirmek" can be used for inserting an object into a designated space.
      list: "C1",
      answer: "yerleştirmek",
      quest: "slot",
    ),
    Words5(
      front: "The angry mob smashed the windows of the store.",
      back: "Öfkeli kalabalık mağazanın vitrinlerini paramparça etti.",
      list: "C1",
      answer: "paramparça etmek",
      quest: "smash",
    ),
    Words5(
      front: "The twig snapped in half as he stepped on it.",
      back: "Üzerine bastığında dal parçası ikiye kırıldı.",
      list: "C1",
      answer:
          "kırılmak", // "Snap" can be translated as "kırılmak" in this context.
      quest: "snap",
    ),
    Words5(
      front: "The eagle soared high above the mountains.",
      back: "Kartal, dağların çok yukarılarında süzüldü.",
      list: "C1",
      answer: "yüksekten uçmak",
      quest: "soar",
    ),
    Words5(
      front: "The shoe has a rubber sole that provides good traction.",
      back: "Ayakkabının iyi tutuş sağlayan kauçuk tabanı vardır.",
      list: "C1",
      answer: "taban",
      quest: "sole",
    ),
    Words5(
      front: "He came to the party solely for the purpose of networking.",
      back: "Sadece network kurmak amacıyla partiye geldi.",
      list: "C1",
      answer: "sadece",
      quest: "solely",
    ),
    Words5(
      front: "He hired a solicitor to represent him in court.",
      back: "Mahkemede kendisini temsil etmesi için bir avukat tuttu.",
      list: "C1",
      answer: "avukat",
      quest: "solicitor",
    ),
    Words5(
      front: "The workers showed solidarity by going on strike together.",
      back: "İşçiler birlikte greve giderek dayanışma gösterdiler.",
      list: "C1",
      answer: "dayanışma",
      quest: "solidarity",
    ),
    Words5(
      front: "The sound of the music woke him up in the middle of the night.",
      back: "Müzik sesi onu gecenin ortasında uyandırdı.",
      list: "C1",
      answer: "ses",
      quest: "sound",
    ),
    Words5(
      front:
          "The project spans several years and involves researchers from different countries.",
      back:
          "Proje birkaç yılı kapsıyor ve farklı ülkelerden araştırmacıları içeriyor.",
      list: "C1",
      answer:
          "kapsamak", // "Span" can be translated as "kapsamak" to convey the idea of covering a period of time or distance.
      quest: "span",
    ),
    Words5(
      front: "Do you have a spare tire in case of a flat?",
      back: "Lastiğiniz patlarsa yedek lastiğiniz var mı?",
      list: "C1",
      answer: "yedek",
      quest: "spare",
    ),
    Words5(
      front: "A spark from the campfire ignited the dry leaves.",
      back: "Kamp ateşinden çıkan bir kıvılcım kuru yaprakları tutuşturdu.",
      list: "C1",
      answer: "kıvılcım",
      quest: "spark",
    ),
    Words5(
      front:
          "He is a specialized doctor who treats patients with heart problems.",
      back: "O, kalp hastaları tedavisinde uzmanlaşmış bir doktor.",
      list: "C1",
      answer: "uzmanlaşmış",
      quest: "specialized",
    ),
    Words5(
      front:
          "The architect provided detailed specifications for the construction of the new building.",
      back:
          "Mimar, yeni binanın yapımı için ayrıntılı birer özellikname sundu.",
      list: "C1",
      answer: "belirti",
      quest: "specification",
    ),
    Words5(
      front:
          "The scientists studied a specimen of the rare plant under a microscope.",
      back:
          "Bilimciler, nadir bitkinin bir örneğini mikroskop altında incelediler.",
      list: "C1",
      answer: "örnek",
      quest: "specimen",
    ),
    Words5(
      front: "The fireworks display was a spectacular sight to behold.",
      back: "Havai fişek gösterisi görsel bir şölendi.",
      list: "C1",
      answer:
          "gösteri", // "Spectacle" can be translated as "gösteri" to convey the idea of a public event.
      quest: "spectacle",
    ),
    Words5(
      front: "Can you spell the word 'believe' for me?",
      back: " 'İnanmak' kelimesini heceleyebilir misin?",
      list: "C1",
      answer: "hecelemek",
      quest: "spell",
    ),
    Words5(
      front: "The Earth is a sphere, but most maps portray it as flat.",
      back: "Dünya bir küredir, ancak çoğu harita onu düz olarak gösterir.",
      list: "C1",
      answer: "küre",
      quest: "sphere",
    ),
    Words5(
      front:
          "He spun the wheel on the game show and waited to see where it would land.",
      back: " Oyun programında çarkı çevirdi ve nerede duracağını bekledi.",
      list: "C1",
      answer: "döndürmek",
      quest: "spin",
    ),
    Words5(
      front: "The doctor examined his spine for any signs of injury.",
      back:
          "Doktor, omurgasını herhangi bir yaralanma belirtisi olup olmadığına baktı.",
      list: "C1",
      answer: "omurga",
      quest: "spine",
    ),
    Words5(
      front:
          "The spotlight was on the actress as she delivered her opening monologue.",
      back:
          "Oyuncunun açılış monologunu sunduğu sırada spot ışığı onun üzerindeydi.",
      list: "C1",
      answer: "spot ışığı",
      quest: "spotlight",
    ),
    Words5(
      front: "He has been married to his spouse for over 20 years.",
      back: "Eşiyle 20 yılı aşkın süredir evli.",
      list: "C1",
      answer: "eş",
      quest: "spouse",
    ),
    Words5(
      front: "The secret agent was a double spy working for both sides.",
      back: "Gizli ajan, her iki taraf için de çalışan bir çifte casustu.",
      list: "C1",
      answer: "casus",
      quest: "spy",
    ),
    Words5(
      front:
          "The police squad surrounded the building and arrested the suspects.",
      back: "Polis ekibi binayı çevirdi ve şüphelileri tutukladı.",
      list: "C1",
      answer: "ekip",
      quest: "squad",
    ),
    Words5(
      front: "He tried to squeeze through the narrow gap, but he got stuck.",
      back: "Dar aralıktan sıvışmaya çalıştı ama sıkıştı.",
      list: "C1",
      answer: "sıkışmak",
      quest: "squeeze",
    ),
    Words5(
      front:
          "The country's political stability is essential for economic growth.",
      back: "Ülkenin siyasi kararlılığı ekonomik büyüme için gereklidir.",
      list: "C1",
      answer: "kararlılık",
      quest: "stability",
    ),
    Words5(
      front: "The medicine helped to stabilize his blood pressure.",
      back: "İlaç, kan basıncını dengeleştirmeye yardımcı oldu.",
      list: "C1",
      answer: "dengeleştirmek",
      quest: "stabilize",
    ),
    Words5(
      front: "He drove a stake into the ground to secure the tent.",
      back: "Çadırı sabitlemek için yere kazık çaktı.",
      list: "C1",
      answer: "kazık",
      quest: "stake",
    ),
    Words5(
      front: "The crowd was standing in silence as the national anthem played.",
      back: "Milli marş çalınırken kalabalık ayakta sessizce duruyordu.",
      list: "C1",
      answer: "ayakta durmak",
      quest: "standing",
    ),
    Words5(
      front: "The contrast between the rich and the poor was stark.",
      back: "Zenginlerle fakirler arasındaki tezat çok belirgindi.",
      list: "C1",
      answer:
          "belirgin", // "Stark" can be translated as "belirgin" to convey the idea of something very noticeable.
      quest: "stark",
    ),
    Words5(
      front: "The captain steered the ship away from the rocks.",
      back: "Kaptan, gemiyi kayalıklardan uzaklaştırdı.",
      list: "C1",
      answer: "yönlendirmek",
      quest: "steer",
    ),
    Words5(
      front: "Knowing the stem of a word can help you understand its meaning.",
      back:
          " Bir kelimenin kökünü bilmek, anlamını anlamanıza yardımcı olabilir.",
      list: "C1",
      answer:
          "kök,çıkmak", // "Stem" can be translated as "kökenlenmek" to convey the idea of origin.
      quest: "stem",
    ),
    Words5(
      front: "A loud noise was the stimulus that startled the cat.",
      back: "Yüksek ses, kediyi ürküten uyaran oldu.",
      list: "C1",
      answer: "uyarıcı",
      quest: "stimulus",
    ),
    Words5(
      front: "She stirred the soup to make sure it wasn't burning.",
      back: "Yanıp yanmadığından emin olmak için çorbayı karıştırdı.",
      list: "C1",
      answer: "karıştırmak",
      quest: "stir",
    ),
    Words5(
      front: "This warehouse is used for the storage of electronic equipment.",
      back: "Bu depo, elektronik eşyaların depolanması için kullanılır.",
      list: "C1",
      answer:
          "depolama", // "Storage" can be translated as "depolama" to convey the action of storing things.
      quest: "storage",
    ),
    Words5(
      front:
          "He gave her straightforward instructions that were easy to understand.",
      back: "Ona anlaşılması kolay, basit talimatlar verdi.",
      list: "C1",
      answer:
          "doğrudan", // "Straightforward" can be translated as "doğrudan" to convey the idea of being clear and direct.
      quest: "straightforward",
    ),
    Words5(
      front: "He strained his back while lifting the heavy box.",
      back: "Ağır kutuyu kaldırırken sırtını zorladı.",
      list: "C1",
      answer: "zorlamak",
      quest: "strain",
    ),
    Words5(
      front: "She wore a long strand of pearls around her neck.",
      back: "Boynunda uzun bir inci dizisi taktı.",
      list: "C1",
      answer: "dizi",
      quest: "strand",
    ),
    Words5(
      front:
          "The advertisement featured a striking image of a beautiful waterfall.",
      back: "Reklamda, güzel bir şelalenin çarpıcı bir görüntüsü vardı.",
      list: "C1",
      answer: "çarpıcı",
      quest: "striking",
    ),
    Words5(
      front:
          "He stripped the paint off the old furniture before repainting it.",
      back: "Eski mobilyaların boyasını yeniden boyamadan önce soydu.",
      list: "C1",
      answer: "soymak",
      quest: "strip",
    ),
    Words5(
      front: "She always strives to do her best in everything she does.",
      back:
          "Yaptığı her şeyde her zaman elinden gelenin en iyisini yapmaya çalışır.",
      list: "C1",
      answer: "uğraşmak",
      quest: "strive",
    ),
    Words5(
      front: "The building had a strong structural foundation.",
      back: "Binanın sağlam bir yapısal temeli vardı.",
      list: "C1",
      answer: "yapısal",
      quest: "structural",
    ),
    Words5(
      front: "He stumbled over his words and forgot what he was going to say.",
      back: "Sözlerinin üzerinde sendeledi ve ne söyleyeceğini unuttu.",
      list: "C1",
      answer: "sendelemek",
      quest: "stumble",
    ),
    Words5(
      front: "The news of his death stunned the entire community.",
      back: "Ölüm haberi tüm toplumu şaşkına çevirdi.",
      list: "C1",
      answer: "şaşkına çevirmek",
      quest: "stun",
    ),
    Words5(
      front: "The deadline for the essay submission is next Friday.",
      back: "Makalenin teslim tarihi önümüzdeki cuma günü.",
      list: "C1",
      answer: "teslim",
      quest: "submission",
    ),
    Words5(
      front: "He is a subscriber to a popular online magazine.",
      back: "Popüler bir online derginin abonesidir.",
      list: "C1",
      answer: "abone",
      quest: "subscriber",
    ),
    Words5(
      front: "Many people get a monthly subscription to a streaming service.",
      back: "Birçok insan, aylık olarak bir streaming hizmetine abonelik alır.",
      list: "C1",
      answer: "abonelik",
      quest: "subscription",
    ),
    Words5(
      front:
          "The government provides subsidies to farmers to help them with their crops.",
      back:
          "Hükümet, çiftçilere mahsullerine yardımcı olmak için sübvansiyon sağlar.",
      list: "C1",
      answer: "sübvansiyon",
      quest: "subsidy",
    ),
    Words5(
      front: "He made a substantial contribution to the project's success.",
      back: "Projenin başarısına önemli bir katkıda bulundu.",
      list: "C1",
      answer: "önemli",
      quest: "substantial",
    ),
    Words5(
      front: "Her income has substantially increased since she got a new job.",
      back: "Yeni bir iş bulduğundan beri geliri önemli miktarda arttı.",
      list: "C1",
      answer: "önemli ölçüde",
      quest: "substantially",
    ),
    Words5(
      front:
          "The teacher asked the students to find a substitute for the missing ingredient in the recipe.",
      back:
          "Öğretmen, öğrencilerden tarifteki eksik malzemenin yerine geçecek bir şey bulmalarını istedi.",
      list: "C1",
      answer: "yerine geçmek",
      quest: "substitute",
    ),
    Words5(
      front:
          "The substitution of butter with olive oil made the cake healthier.",
      back:
          "Tereyağ yerine zeytinyağı kullanılması pastayı daha sağlıklı hale getirdi.",
      list: "C1",
      answer: "yerine koyma",
      quest: "substitution",
    ),
    Words5(
      front:
          "The difference in quality between the two products was subtle but noticeable.",
      back: "İki ürün arasındaki kalite farkı güç algılanan ama belirgindi.",
      list: "C1",
      answer: "güç algılanan",
      quest: "subtle",
    ),
    Words5(
      front: "They live in a quiet suburban neighborhood with friendly people.",
      back:
          "Sessiz ve insanların birbirini tanıdığı bir banliyö mahallesinde yaşıyorlar.",
      list: "C1",
      answer: "banliyö",
      quest: "suburban",
    ),
    Words5(
      front:
          "The king's succession was peaceful, and his son took the throne without any conflict.",
      back:
          "Kralın ardıllığı barışçıl oldu ve oğlu herhangi bir çatışma yaşamadan tahta çıktı.",
      list: "C1",
      answer: "ardıllık",
      quest: "succession",
    ),
    Words5(
      front: "He won three successive games of chess, proving his skills.",
      back: "Zeka yeteneğini kanıtlayarak üç ardışık satranç oyunu kazandı.",
      list: "C1",
      answer: "ardışık",
      quest: "successive",
    ),
    Words5(
      front:
          "The king's successor is his eldest son, who is now the crown prince.",
      back: "Kralın varisi, şu anda veliaht prens olan en büyük oğludur.",
      list: "C1",
      answer: "varis",
      quest: "successor",
    ),
    Words5(
      front:
          "He is planning to sue the company for wrongful termination of his contract.",
      back:
          "Haksız yere işten çıkarılması nedeniyle şirketi dava açmayı planlıyor.",
      list: "C1",
      answer: "dava açmak",
      quest: "sue",
    ),
    Words5(
      front:
          "Suicide is a serious issue that needs to be addressed by society.",
      back:
          "İntihar, toplum tarafından ele alınması gereken ciddi bir sorundur.",
      list: "C1",
      answer: "intihar",
      quest: "Suicide",
    ),
    Words5(
      front: "He rented a luxurious suite at the hotel for his honeymoon.",
      back: "Balayı için otelden lüks bir suit kiraladı.",
      list: "C1",
      answer: "suit",
      quest: "suite",
    ),
    Words5(
      front: "The world leaders met at a summit to discuss global issues.",
      back:
          "Dünya liderleri, küresel sorunları tartışmak için bir zirvede bir araya geldi.",
      list: "C1",
      answer: "zirve",
      quest: "summit",
    ),
    Words5(
      front: "The meal was absolutely superb! We enjoyed every bite.",
      back: "Yemek kesinlikle harikuladeydi! Her lokmasının tadını çıkardık.",
      list: "C1",
      answer: "harikulade",
      quest: "superb",
    ),
    Words5(
      front:
          "He felt superior to his colleagues and often looked down on them.",
      back:
          "Kendisini meslektaşlarından üstün görüyordu ve onlara sık sık tepeden bakıyordu.",
      list: "C1",
      answer: "üstün",
      quest: "superior",
    ),
    Words5(
      front:
          "The teacher provided close supervision during the students' exams.",
      back: "Öğretmen, öğrencilerin sınavları sırasında yakın gözetim sağladı.",
      list: "C1",
      answer: "gözetim",
      quest: "supervision",
    ),
    Words5(
      front:
          "The supervisor is responsible for ensuring that the employees are working efficiently.",
      back:
          "Denetmen, çalışanların verimli bir şekilde çalışmasını sağlamaktan sorumludur.",
      list: "C1",
      answer: "denetmen",
      quest: "supervisor",
    ),
    Words5(
      front:
          "He takes a daily vitamin supplement to ensure he is getting all the nutrients he needs.",
      back:
          "İhtiyacı olan tüm besin maddelerini aldığından emin olmak için günlük vitamin takviyesi alıyor.",
      list: "C1",
      answer: "takviye",
      quest: "supplement",
    ),
    Words5(
      front:
          "She has a very supportive family who always encourages her to follow her dreams.",
      back:
          "Hayallerinin peşinden gitmesi için onu her zaman destekleyen çok destekleyici bir ailesi var.",
      list: "C1",
      answer: "destekleyici",
      quest: "supportive",
    ),
    Words5(
      front:
          "The government is trying to suppress the spread of misinformation online.",
      back:
          "Hükümet, çevrimiçi yanlış bilginin yayılmasını bastırmaya çalışıyor.",
      list: "C1",
      answer: "bastırmak",
      quest: "suppress",
    ),
    Words5(
      front: "The Supreme Court is the highest court in the land.",
      back: "Yargıtay, ülkenin en yüksek mahkemesidir.",
      list: "C1",
      answer: "yargıtay",
      quest: "Supreme",
    ),
    Words5(
      front: "The price of oil surged after the outbreak of the war.",
      back: "Savaşın patlak vermesinden sonra petrol fiyatları fırladı.",
      list: "C1",
      answer: "fırlamak",
      quest: "surge",
    ),
    Words5(
      front: "He needed surgery to remove his appendix.",
      back: "Apanditini almak için ameliyata ihtiyacı vardı.",
      list: "C1",
      answer: "ameliyat",
      quest: "surgical",
    ),
    Words5(
      front:
          "The company has a surplus of inventory that they are trying to sell.",
      back: "Şirket, satmaya çalıştıkları fazla stok fazlasına sahiptir.",
      list: "C1",
      answer: "fazla",
      quest: "surplus",
    ),
    Words5(
      front:
          "The enemy soldiers eventually surrendered after running out of ammunition.",
      back:
          "Düşman askerleri cephaneleri bittikten sonra sonunda teslim oldular.",
      list: "C1",
      answer: "teslim olmak",
      quest: "surrender",
    ),
    Words5(
      front: "The house is under constant surveillance by security cameras.",
      back: "Ev, güvenlik kameraları tarafından sürekli gözetleme altındadır.",
      list: "C1",
      answer: "gözetleme",
      quest: "surveillance",
    ),
    Words5(
      front:
          "The athlete was given a two-year suspension from competition for doping.",
      back: "Sporcu, doping nedeniyle iki yıllık yarışmaya ara verildi.",
      list: "C1",
      answer: "askıya alma",
      quest: "suspension",
    ),
    Words5(
      front: "There was a suspicion that he was cheating on the exam.",
      back: "Sınavda kopya çektiğine dair bir kuşku vardı.",
      list: "C1",
      answer: "kuşku",
      quest: "suspicion",
    ),
    Words5(
      front: "The man looked suspicious as he lurked around the corner.",
      back: "Adam köşede pusu verirken şüpheli görünüyordu.",
      list: "C1",
      answer: "şüpheli",
      quest: "suspicious",
    ),
    Words5(
      front:
          "He was able to sustain himself on a diet of fruits and vegetables.",
      back: "Kendini meyve ve sebze ağırlıklı bir diyetle idame ettirebildi.",
      list: "C1",
      answer: "idame ettirmek",
      quest: "sustain",
    ),
    Words5(
      front: "The children were swinging on the swings in the playground.",
      back: "Çocuklar oyun parkındaki salıncakta sallanıyorlardı.",
      list: "C1",
      answer: "sallanmak",
      quest: "swing",
    ),
    Words5(
      front: "The knight fought bravely with his sword against the dragon.",
      back: "Şövalye, ejderhaya karşı kılıcıyla cesurca savaştı.",
      list: "C1",
      answer: "kılıç",
      quest: "sword",
    ),
    Words5(
      front:
          "The scientist's theory was a brilliant synthesis of different ideas.",
      back: "Bilimcinin teorisi, farklı fikirlerin parlak bir senteziydi.",
      list: "C1",
      answer: "sentez",
      quest: "synthesis",
    ),
    Words5(
      front: "The government needs to tackle the issue of climate change.",
      back: "Hükümetin iklim değişikliği sorununu ele alması gerekiyor.",
      list: "C1",
      answer: "ele almak",
      quest: "tackle",
    ),
    Words5(
      front: "Every taxpayer has a responsibility to pay their taxes.",
      back: "Her vergi verenin vergilerini ödeme sorumluluğu vardır.",
      list: "C1",
      answer: "vergi veren",
      quest: "taxpayer",
    ),
    Words5(
      front: "He was tempted to cheat on the test, but he knew it was wrong.",
      back:
          "Kopya çekmek için cazip geldi, ancak bunun yanlış olduğunu biliyordu.",
      list: "C1",
      answer: "kışkırtmak",
      quest: "tempt",
    ),
    Words5(
      front:
          "She is a tenant in the apartment building and pays rent to the landlord.",
      back: "Apartman dairesinde kiracıdır ve ev sahibine kira öder.",
      list: "C1",
      answer: "kiracı",
      quest: "tenant",
    ),
    Words5(
      front: "The company submitted a tender for the construction project.",
      back: "Şirket, inşaat projesi için bir ihale sundu.",
      list: "C1",
      answer: "ihale",
      quest: "tender",
    ),
    Words5(
      front:
          "In most universities, professors have tenure after a probationary period.",
      back:
          "Çoğu üniversitede, profesörler deneme süresinden sonra kadrolu hale gelir.",
      list: "C1",
      answer: "kadrolu olmak",
      quest: "tenure",
    ),
    Words5(
      front:
          "The company was forced to terminate his contract due to budget cuts.",
      back:
          "Şirket, bütçe kesintileri nedeniyle sözleşmesini feshetmek zorunda kaldı.",
      list: "C1",
      answer: "feshetmek",
      quest: "terminate",
    ),
    Words5(
      front:
          "The soldiers had to fight through difficult terrain to reach their objective.",
      back:
          "Askerler hedeflerine ulaşmak için zorlu araziden savaşarak geçmek zorunda kaldılar.",
      list: "C1",
      answer: "arazi",
      quest: "terrain",
    ),
    Words5(
      front: "We had a terrific time at the party! It was a lot of fun.",
      back: "Partilde müthiş vakit geçirdik! Çok eğlenceliydi.",
      list: "C1",
      answer: "müthiş",
      quest: "terrific",
    ),
    Words5(
      front:
          "The witness will testify in court about what they saw at the crime scene.",
      back:
          "Tanık, mahkemede olay yerinde gördükleri hakkında tanıklık edecek.",
      list: "C1",
      answer: "tanıklık etmek",
      quest: "testify",
    ),
    Words5(
      front:
          "The police are relying on eyewitness testimony to solve the case.",
      back: "Polis, davayı çözmek için görgü tanığı ifadesine güveniyor.",
      list: "C1",
      answer: "ifade",
      quest: "testimony",
    ),
    Words5(
      front: "I love the soft texture of this cashmere sweater.",
      back: "Bu kaşmir kazağın yumuşak dokusunu seviyorum.",
      list: "C1",
      answer: "doku",
      quest: "texture",
    ),
    Words5(
      front:
          "Thankfully, the fire alarm went off in time and everyone was able to evacuate safely.",
      back:
          "Neyse ki, yangın alarmı zamanında devreye girdi ve herkes güvenli bir şekilde tahliye edilebildi.",
      list: "C1",
      answer: "Neyse ki",
      quest: "thankfully",
    ),
    Words5(
      front:
          "The actor gave a very theatrical performance that was full of overdramatic gestures.",
      back:
          "Oyuncu, abartılı jestlerle dolu çok teatral bir performans sergiledi.",
      list: "C1",
      answer: "abartılı",
      quest: "theatrical",
    ),
    Words5(
      front:
          "His theory is based on theoretical concepts that have not been proven yet.",
      back: "Teorisi, henüz kanıtlanmamış teorik kavramlara dayanıyor.",
      list: "C1",
      answer: "teorik",
      quest: "theoretical",
    ),
    Words5(
      front: "We will discuss the details of the project thereafter.",
      back: "Projenin detaylarını ondan sonra tartışacağız.",
      list: "C1",
      answer: "ondan sonra",
      quest: "thereafter",
    ),
    Words5(
      front:
          "He achieved his goals by working hard and diligently. Thereby, he proved that anything is possible with hard work.",
      back:
          "Hedeflerine sıkı çalışarak ve özenle çalışarak ulaştı. Böylelikle, sıkı çalışma ile her şeyin mümkün olduğunu kanıtladı.",
      list: "C1",
      answer: "böylelikle",
      quest: "thereby",
    ),
    Words5(
      front:
          "She gave a thoughtful gift that showed she really cared about her friend.",
      back:
          "Düşünceli bir hediye verdi ve bu da arkadaşını gerçekten önemsediğini gösterdi.",
      list: "C1",
      answer: "düşünceli",
      quest: "thoughtful",
    ),
    Words5(
      front: "The movie was a thought-provoking exploration of social issues.",
      back:
          "Film, sosyal sorunları düşündürücü bir şekilde ele alan bir incelemeydi.",
      list: "C1",
      answer: "düşündürücü",
      quest: "thought-provoking",
    ),
    Words5(
      front: "She used a strong thread to sew the button back on her shirt.",
      back:
          "Gomleğindeki düğmeyi tekrar dikmek için sağlam bir iplik kullandı.",
      list: "C1",
      answer: "iplik",
      quest: "thread",
    ),
    Words5(
      front:
          "We are on the threshold of a new era of technological advancements.",
      back: "Teknolojik gelişmelerin yeni bir çağının eşiğindeyiz.",
      list: "C1",
      answer: "eşik",
      quest: "threshold",
    ),
    Words5(
      front:
          "She was thrilled to win the competition and finally achieve her dream.",
      back: "Yarışmayı kazanıp sonunda hayaline ulaştığı için heyecanlanmıştı.",
      list: "C1",
      answer: "heyecanlanmış",
      quest: "thrilled",
    ),
    Words5(
      front: "Plants thrive in fertile soil with plenty of sunlight and water.",
      back: "Bitkiler, bereketli toprakta, bol güneş ışığı ve su ile gelişir.",
      list: "C1",
      answer: "gelişmek",
      quest: "thrive",
    ),
    Words5(
      front:
          "He tightened his grip on the rope to prevent himself from falling.",
      back: "Düşmeyi önlemek için ipteki tutuşunu sıkılaştırdı.",
      list: "C1",
      answer: "sıkılaştırmak",
      quest: "tighten",
    ),
    Words5(
      front: "The house is built from a combination of brick and timber.",
      back: "Ev, tuğla ve kereste kombinasyonundan inşa edilmiştir.",
      list: "C1",
      answer: "kereste",
      quest: "timber",
    ),
    Words5(
      front: "It was a timely warning that helped us avoid a major disaster.",
      back:
          "Büyük bir felaketi önlememize yardımcı olan zamanında yapılan bir uyarıydı.",
      list: "C1",
      answer: "zamanında yapılan",
      quest: "timely",
    ),
    Words5(
      front: "Smoking tobacco can lead to serious health problems.",
      back: "Tütün içmek ciddi sağlık sorunlarına yol açabilir.",
      list: "C1",
      answer: "tütün",
      quest: "tobacco",
    ),
    Words5(
      front: "He showed a great deal of tolerance for her mistakes.",
      back: "Hatalarına karşı büyük bir hoşgörü gösterdi.",
      list: "C1",
      answer: "hoşgörü",
      quest: "tolerance",
    ),
    Words5(
      front: "Children need to learn to tolerate frustration.",
      back: "Çocukların hayal kırıklığına tahammül etmeyi öğrenmeleri gerekir.",
      list: "C1",
      answer: "tahammül etmek",
      quest: "tolerate",
    ),
    Words5(
      front: "You have to pay a toll to cross the bridge.",
      back: "Köprüyü geçmek için çan çalmak zorundasınız.",
      list: "C1",
      answer: 'Geçit ücreti',
      quest: 'toll',
    ),
    Words5(
      front: "The mountain peak was shrouded in mist.",
      back: "Dağın tepesi sisle örtülüydü.",
      list: "C1",
      answer: "tepe",
      quest: "top",
    ),
    Words5(
      front: "The prisoners were tortured by their captors.",
      back: "Tutuklular, gardiyanları tarafından işkence gördü.",
      list: "C1",
      answer: "işkence",
      quest: "torture",
    ),
    Words5(
      front: "They tossed a coin to decide who would go first.",
      back: "Kimin önce gideceğine karar vermek için yazı tura attılar.",
      list: "C1",
      answer: "atmak",
      quest: "toss",
    ),
    Words5(
      front: "The total cost of the repairs came to \$1000.",
      back: "Tamiratın toplam maliyeti 1000 dolara ulaştı.",
      list: "C1",
      answer: "toplam",
      quest: "total",
    ),
    Words5(
      front: "Exposure to toxic chemicals can cause serious health problems.",
      back:
          "Zehirli kimyasallara maruz kalmak ciddi sağlık sorunlarına neden olabilir.",
      list: "C1",
      answer: "zehirli",
      quest: "toxic",
    ),
    Words5(
      front: "The police are trying to trace the suspect's movements.",
      back: "Polis, şüphelinin hareketlerini iz sürmek çalışıyor.",
      list: "C1",
      answer: "iz sürmek",
      quest: "trace",
    ),
    Words5(
      front: "Nike is a well-known trademark for athletic shoes.",
      back: "Nike, spor ayakkabıları için tanınmış bir markadır.",
      list: "C1",
      answer: "marka",
      quest: "trademark",
    ),
    Words5(
      front: "The hikers followed a well-marked trail through the forest.",
      back:
          "Yürüyüşçüler, orman boyunca iyi işaretlenmiş bir iz takip ettiler.",
      list: "C1",
      answer: "iz",
      quest: "trail",
    ),
    Words5(
      front:
          "I watched the trailer for the new movie and it looks really good.",
      back: "Yeni filmin fragmanını izledim ve gerçekten çok iyi görünüyor.",
      list: "C1",
      answer: "fragman",
      quest: "trailer",
    ),
    Words5(
      front:
          "The bank transaction was successful and the money has been transferred.",
      back: "Banka işlemi başarılı oldu ve para transfer edildi.",
      list: "C1",
      answer: "işlem",
      quest: "transaction",
    ),
    Words5(
      front:
          "The student requested a transcript of their grades from the university.",
      back: "Öğrenci, üniversiteden notlarının bir transkriptini talep etti.",
      list: "C1",
      answer: "transkript",
      quest: "transcript",
    ),
    Words5(
      front:
          "The caterpillar undergoes a remarkable transformation into a butterfly.",
      back: "Tırtıl, kelebeğe dönüşen dikkat çekici bir dönüşüm geçirir.",
      list: "C1",
      answer: "dönüşüm",
      quest: "transformation",
    ),
    Words5(
      front: "The cargo ship is transporting goods through the Panama Canal.",
      back: "Kargo gemisi, Panama Kanalı'ndan transit geçiyor.",
      list: "C1",
      answer: "transit, geçiş",
      quest: "transit",
    ),
    Words5(
      front:
          "The car wouldn't start because there was a problem with the transmission.",
      back: "Araba vites sorunu nedeniyle çalışmadı.",
      list: "C1",
      answer: "vites",
      quest: "transmission",
    ),
    Words5(
      front: "There is a need for more transparency in government spending.",
      back: "Devlet harcamalarında daha fazla şeffaflık olması gerekiyor.",
      list: "C1",
      answer: "şeffaflık",
      quest: "transparency",
    ),
    Words5(
      front: "I can see through the transparent window.",
      back: "Saydam pencereden görebiliyorum.",
      list: "C1",
      answer: "saydam",
      quest: "transparent",
    ),
    Words5(
      front: "The soldier suffered a severe trauma from the war.",
      back: "Asker, savaştan kaynaklanan ciddi bir travma yaşadı.",
      list: "C1",
      answer: "travma",
      quest: "trauma",
    ),
    Words5(
      front: "The two countries signed a peace treaty to end the conflict.",
      back:
          "İki ülke, çatışmayı sona erdirmek için bir barış antlaşması imzaladı.",
      list: "C1",
      answer: "antlaşma",
      quest: "treaty",
    ),
    Words5(
      front: "He made a tremendous effort to overcome the challenges he faced.",
      back:
          "Karşılaştığı zorlukların üstesinden gelmek için muazzam bir çaba gösterdi.",
      list: "C1",
      answer: "muazzam",
      quest: "tremendous",
    ),
    Words5(
      front: "The case was brought before a tribunal for international crimes.",
      back: "Dava, uluslararası suçlar için bir mahkemeye getirildi.",
      list: "C1",
      answer: "mahkeme",
      quest: "tribunal",
    ),
    Words5(
      front:
          "The ancient city paid tribute to the emperor in the form of gold and jewels.",
      back: "Eski şehir, haraç olarak imparatora altın ve mücevher verdi.",
      list: "C1",
      answer: "haraç",
      quest: "tribute",
    ),
    Words5(
      front: "The news triggered a wave of panic buying in the supermarkets.",
      back: "Haber, süpermarketlerde bir panik satın alma dalgasını tetikledi.",
      list: "C1",
      answer: "tetiklemek",
      quest: "trigger",
    ),
    Words5(
      front: "The band consists of a talented trio of musicians.",
      back: "Grup, yetenekli bir müzisyen üçlüsünden oluşuyor.",
      list: "C1",
      answer: "üçlü takım",
      quest: "trio",
    ),
    Words5(
      front: "The team celebrated their triumph in the championship game.",
      back: "Takım, şampiyonluk maçındaki zaferlerini kutladı.",
      list: "C1",
      answer: "zafer",
      quest: "triumph",
    ),
    Words5(
      front: "The winner of the competition received a golden trophy.",
      back: "Yarışmanın kazananı altın bir kupa aldı.",
      list: "C1",
      answer: "ganimet",
      quest: "trophy",
    ),
    Words5(
      front: "He looked troubled and seemed to be deep in thought.",
      back: "Sıkıntılı görünüyordu ve derin düşüncelere dalmış gibiydi.",
      list: "C1",
      answer: "sıkıntılı",
      quest: "troubled",
    ),
    Words5(
      front:
          "The cost of tuition has been rising steadily over the past few years.",
      back: "Son birkaç yılda okul ücreti maliyeti sürekli olarak artıyor.",
      list: "C1",
      answer: "okul ücreti",
      quest: "tuition",
    ),
    Words5(
      front: "The bakery sells a variety of delicious turnovers.",
      back: "Fırın, çeşitli lezzetli meyveli turtalar satıyor.",
      list: "C1",
      answer: "meyveli turta",
      quest: "turnover",
    ),
    Words5(
      front: "She gave the wire a little twist to tighten the connection.",
      back: "Bağlantıyı sıkmak için teli biraz büktü.",
      list: "C1",
      answer: "bükmek",
      quest: "twist",
    ),
    Words5(
      front:
          "She is currently enrolled in an undergraduate program at the university.",
      back: "Şu anda üniversitede lisans programına kayıtlıdır.",
      list: "C1",
      answer: "lisans",
      quest: "undergraduate",
    ),
    Words5(
      front:
          "There are many underlying factors that contribute to climate change.",
      back:
          "İklim değişikliğine katkıda bulunan birçok altta yatan faktör vardır.",
      list: "C1",
      answer: "altta yatan",
      quest: "underlying",
    ),
    Words5(
      front: "His constant criticism served to undermine her confidence.",
      back: "Sürekli eleştirisi, onun güvenini baltalamaya yaradı.",
      list: "C1",
      answer: "baltalamak",
      quest: "undermine",
    ),
    Words5(
      front: "He is undoubtedly the most qualified candidate for the job.",
      back: "Şüphesiz olarak işe en uygun adaydır.",
      list: "C1",
      answer: "şüphesiz olarak",
      quest: "undoubtedly",
    ),
    Words5(
      front: "The countries are working together to unify their economies.",
      back: "Ülkeler, ekonomilerini birleştirmek için birlikte çalışıyorlar.",
      list: "C1",
      answer: "aynı yapmak",
      quest: "unify",
    ),
    Words5(
      front: "We are facing unprecedented challenges in the 21st century.",
      back: "21. yüzyılda eşi benzeri görülmemiş zorluklarla karşı karşıyayız.",
      list: "C1",
      answer: "eşi benzeri görülmemiş",
      quest: "unprecedented",
    ),
    Words5(
      front: "We are excited about the upcoming conference on climate change.",
      back:
          "İklim değişikliği hakkındaki yaklaşan konferans hakkında heyecanlıyız.",
      list: "C1",
      answer: "olmak üzere olan",
      quest: "upcoming",
    ),
    Words5(
      front:
          "The company is constantly upgrading its software to improve functionality.",
      back:
          "Şirket, işlevselliği artırmak için yazılımını sürekli olarak geliştiriyor.",
      list: "C1",
      answer: "geliştirmek",
      quest: "upgrade",
    ),
    Words5(
      front: "It is important to uphold the values of democracy and freedom.",
      back: "Demokrasi ve özgürlük değerlerini savunmak önemlidir.",
      list: "C1",
      answer: "tutmak",
      quest: "uphold",
    ),
    Words5(
      front:
          "A calculator is a useful utility for performing mathematical calculations.",
      back:
          "Hesap makinesi, matematiksel hesaplamalar yapmak için faydalı bir yardımcı yazılımdır.",
      list: "C1",
      answer: "yardımcı yazılım",
      quest: "utility",
    ),
    Words5(
      front: "The company is looking for ways to better utilize its resources.",
      back: "Şirket, kaynaklarını daha iyi değerlendirmenin yollarını arıyor.",
      list: "C1",
      answer: "yararlanmak",
      quest: "utilize",
    ),
    Words5(
      front: "She was utterly devastated by the news of her friend's death.",
      back: "Arkadaşının ölümü haberiyle tamamen yıkılmıştı.",
      list: "C1",
      answer: "tümüyle",
      quest: "utterly",
    ),
    Words5(
      front: "His instructions were vague and left me feeling confused.",
      back: "Talimatları belirsizdi ve kafamı karıştırdı.",
      list: "C1",
      answer: "şüpheli",
      quest: "vague",
    ),
    Words5(
      front: "The validity of the passport expired five years ago.",
      back: "Pasaportun geçerliliği beş yıl önce doldu.",
      list: "C1",
      answer: "geçerlilik",
      quest: "validity",
    ),
    Words5(
      front: "The magician made the rabbit vanish in a puff of smoke.",
      back:
          "Sihirbaz, tavşanı bir duman bulutunda ortadan kaybolmasını sağladı.",
      list: "C1",
      answer: "ortadan kaybolmak",
      quest: "vanish",
    ),
    Words5(
      front:
          "The weather is very variable this week, with sunshine one day and rain the next.",
      back: "Bu hafta hava çok değişken, bir gün güneşli diğer gün yağmurlu.",
      list: "C1",
      answer: "değişken",
      quest: "variable",
    ),
    Words5(
      front: "We enjoyed a varied menu with dishes from all over the world.",
      back:
          "Dünyanın her yerinden yemeklerin bulunduğu çeşitli bir menünün tadını çıkardık.",
      list: "C1",
      answer: "değişik",
      quest: "varied",
    ),
    Words5(
      front: "Blood travels through the veins to the heart.",
      back: "Kan, damarlar yoluyla kalbe taşınır.",
      list: 'C1',
      answer: "damar",
      quest: "vein",
    ),
    Words5(
      front: "They decided to start their own business venture.",
      back: "Kendi iş girişimlerini başlatmaya karar verdiler.",
      list: "C1",
      answer: "girişim",
      quest: "venture",
    ),
    Words5(
      front: "The witness gave a verbal account of what they saw.",
      back: "Tanık, gördüklerini sözlü olarak anlattı.",
      list: "C1",
      answer: "sözlü",
      quest: "verbal",
    ),
    Words5(
      front: "The jury reached a verdict of guilty after a long deliberation.",
      back: "Jüri, uzun bir müzakerenin ardından suçlu kararına vardı.",
      list: "C1",
      answer: "hüküm",
      quest: "verdict",
    ),
    Words5(
      front: "The scientist was able to verify the results of the experiment.",
      back: "Bilim insanı, deneyin sonuçlarını doğrulayabildi.",
      list: "C1",
      answer: "doğrulamak",
      quest: "verify",
    ),
    Words5(
      front:
          "My favorite poem is the first verse of Sonnet 18 by William Shakespeare.",
      back:
          "En sevdiğim şiir, William Shakespeare'ın Sonnet 18'inin ilk dizesidir.",
      list: "C1",
      answer: "dize",
      quest: "verse",
    ),
    Words5(
      front: "The football match will be played between Turkey versus France.",
      back: "Futbol maçı Türkiye - Fransa arasında oynanacak.",
      list: "C1",
      answer: "aleyhinde, karşı",
      quest: "versus",
    ),
    Words5(
      front:
          "The cargo ship is a large vessel that can transport thousands of tons of goods.",
      back: "Kargo gemisi, binlerce tonluk malı taşıyabilen büyük bir gemidir.",
      list: "C1",
      answer: "gemi",
      quest: "vessel",
    ),
    Words5(
      front: "He is a veteran soldier with many years of experience in combat.",
      back: "Uzun yıllar savaş tecrübesine sahip kıdemli bir askerdir.",
      list: "C1",
      answer: "kıdemli",
      quest: "veteran",
    ),
    Words5(
      front: "Is this plan a viable option for solving the problem?",
      back: "Bu plan, sorunu çözmek için yaşayabilir bir seçenek mi?",
      list: "C1",
      answer: "yaşayabilir",
      quest: "viable",
    ),
    Words5(
      front: "The city is known for its vibrant culture and nightlife.",
      back: "Şehir, canlı kültürü ve gece hayatı ile tanınır.",
      list: "C1",
      answer: "titreşimli",
      quest: "vibrant",
    ),
    Words5(
      front: "The president admitted to his vice in judgment.",
      back: "Başkan, verdiği yanlış kararın sorumluluğunu üstlendi.",
      list: "C1",
      answer: "özür",
      quest: "vice",
    ),

    Words5(
      front: "The dog attacked the mail carrier in a vicious manner.",
      back: "Köpek, postacıya vahşi bir şekilde saldırdı.",
      list: "C1",
      answer: "vahşi",
      quest: "vicious",
    ),
    Words5(
      front: "The villagers live a simple life close to nature.",
      back: "Köylüler, doğayla iç içe basit bir hayat sürüyorlar.",
      list: "C1",
      answer: "köylü",
      quest: "villager",
    ),
    Words5(
      front: "Smoking cigarettes violates the health code.",
      back: "Sigara içmek sağlık kurallarını çiğnemektir.",
      list: "C1",
      answer: "ihlal etmek",
      quest: "violate",
    ),
    Words5(
      front: "Speeding is a violation of traffic laws.",
      back: "Hız yapmak trafik yasalarının bir ihlalidir.",
      list: "C1",
      answer: "ihlal",
      quest: "violation",
    ),
    Words5(
      front: "Honesty and compassion are important virtues to possess.",
      back: "Dürüstlük ve merhamet, sahip olunması gereken önemli erdemlerdir.",
      list: "C1",
      answer: "erdem",
      quest: "virtue",
    ),
    Words5(
      front: "He vowed to get revenge on his enemies.",
      back: "Düşmanlarından intikam almaya yemin etti.",
      list: "C1",
      answer: "yemin etmek",
      quest: "vow",
    ),
    Words5(
      front:
          "The computer system has several vulnerabilities that hackers could exploit.",
      back:
          "Bilgisayar sisteminin, hackerların faydalanabileceği birkaç güvenlik açığı var.",
      list: "C1",
      answer: "yaralanabilirlik",
      quest: "vulnerability",
    ),
    Words5(
      front:
          "She is very vulnerable to getting the flu because she hasn't been vaccinated.",
      back: "Aşı olmadığı için gribe yakalanmaya karşı çok kolay yaralanır.",
      list: "C1",
      answer: "kolayca yaralanır",
      quest: "vulnerable",
    ),
    Words5(
      front: "The hospital staff were on ward duty throughout the night.",
      back: "Hastane personeli gece boyunca nöbet görevi başındaydı.",
      list: "C1",
      answer:
          "nöbet", // This is a better translation for "ward" in this context
      quest: "ward",
    ),
    Words5(
      front:
          "The company has a large warehouse where they store their products.",
      back: "Şirketin ürünleri depolamak için kullandığı büyük bir deposu var.",
      list: "C1",
      answer: "depo",
      quest: "warehouse",
    ),
    Words5(
      front: "The world has seen many devastating wars throughout history.",
      back: "Dünya tarih boyunca birçok yıkıcı savaşa sahne olmuştur.",
      list: "C1",
      answer: "savaş",
      quest: "warfare",
    ),
    Words5(
      front:
          "The product does not come with a warranty, so you cannot return it if it breaks.",
      back: "Ürün garantili değil, bu nedenle bozulursa iade edemezsiniz.",
      list: "C1",
      answer: "garanti etmek",
      quest: "warrant",
    ),
    Words5(
      front: "The brave warrior fought valiantly to protect his village.",
      back: "Cesur savaşçı, köyünü korumak için kahramanca savaştı.",
      list: "C1",
      answer: "savaşçı",
      quest: "warrior",
    ),
    Words5(
      front: "A lack of sleep can weaken your immune system.",
      back: "Uyku eksikliği, bağışıklık sisteminizi zayıflatabilir.",
      list: "C1",
      answer: "zayıflatmak",
      quest: "weaken",
    ),
    Words5(
      front: "The artist used colorful threads to weave a beautiful tapestry.",
      back: "Sanatçı, güzel bir halı dokumak için renkli iplikler kullandı.",
      list: "C1",
      answer: "dokumak",
      quest: "weave",
    ),
    Words5(
      front: "We need to remove the weeds from the flower bed.",
      back: "Yataktaki otları temizlememiz gerekiyor.",
      list: "C1",
      answer: "ot",
      quest: "weed",
    ),
    Words5(
      front: "The well provided a source of fresh water for the village.",
      back: "Kuyu, köy için temiz bir su kaynağı sağladı.",
      list: "C1",
      answer: "kuyu",
      quest: "well",
    ),
    Words5(
      front: "Exercise and a healthy diet are essential for well-being.",
      back: "Egzersiz ve sağlıklı beslenme, sağlıklı yaşam için gereklidir.",
      list: "C1",
      answer: "iyi oluş",
      quest: "well-being",
    ),
    Words5(
      front: "We don't need to discuss his mistakes whatsoever.",
      back: "Hatalarını hiçbir şekilde tartışmamıza gerek yok.",
      list: "C1",
      answer: "hiçbir",
      quest: "whatsoever",
    ),
    Words5(
      front:
          "The bridge was constructed whereby cars and trains could cross the river.",
      back:
          "Köprü, arabaların ve trenlerin nehrin üzerinden geçebileceği şekilde inşa edildi.",
      list: "C1",
      answer:
          "sayesinde", // "şöyle ki" or "böylelikle" are better translations for "whereby" in this context
      quest: "whereby",
    ),
    Words5(
      front: "The trainer used a whip to motivate the horse during the race.",
      back: "Eğitmen, yarış sırasında atı motive etmek için kamçı kullandı.",
      list: "C1",
      answer: "kamçılamak",
      quest: "whip",
    ),
    Words5(
      front: "He was wholly dedicated to his work and never gave up.",
      back: "Tamamen işine adanmıştı ve asla vazgeçmedi.",
      list: "C1",
      answer: "tamamen",
      quest: "wholly",
    ),
    Words5(
      front:
          "The construction project will widen the road to accommodate more traffic.",
      back:
          "İnşaat projesi, daha fazla trafiğe yer açmak için yolu genişletecek.",
      list: "C1",
      answer: "genişletmek",
      quest: "widen",
    ),
    Words5(
      front: "The width of the door frame is not standard.",
      back: "Kapı çerçevesinin genişliği standart değildir.",
      list: "C1",
      answer: "genişlik",
      quest: "width",
    ),
    Words5(
      front: "Many people volunteered their time to help clean up the park.",
      back:
          "Parkın temizlenmesine yardım etmek için birçok kişi gönüllü olarak zaman ayırdı.",
      list: "C1",
      answer: "gönüllülük",
      quest: "willingness",
    ),
    Words5(
      front: "He was known for his sharp wit and clever humor.",
      back: "Keskin zekası ve esprili mizahı ile tanınıyordu.",
      list: "C1",
      answer: "ince espri",
      quest: "wit",
    ),
    Words5(
      front:
          "The sudden withdrawal of troops from the warzone surprised everyone.",
      back: "Savaş bölgesinden ani asker çekilmesi herkesi şaşırttı.",
      list: "C1",
      answer: "bırakma",
      quest: "withdrawal",
    ),
    Words5(
      front: "She did a daily workout to stay in shape.",
      back: "Formda kalmak için günlük olarak spor yaptı.",
      list: "C1",
      answer: "egzersiz",
      quest: "workout",
    ),
    Words5(
      front: "Many people worship different gods and goddesses.",
      back: "Birçok insan farklı tanrı ve tanrıçalara tapar.",
      list: "C1",
      answer: "tapmak",
      quest: "worship",
    ),
    Words5(
      front: "Is it worthwhile spending so much money on this gadget?",
      back: "Bu alete bu kadar para harcamaya değer mi?",
      list: "C1",
      answer: "değer",
      quest: "worthwhile",
    ),
    Words5(
      front: "He is a worthy candidate for the scholarship.",
      back: "Bursu hak eden bir adaydır.",
      list: "C1",
      answer: "hak eden",
      quest: "worthy",
    ),
    Words5(
      front: "The children were yelling and playing in the park.",
      back: "Çocuklar parkta bağırıyor ve oynuyorlardı.",
      list: "C1",
      answer: "bağırmak",
      quest: "yell",
    ),
    Words5(
      front: "The army eventually yielded to the enemy's superior forces.",
      back: "Ordu sonunda düşmanın üstün güçlerine teslim oldu.",
      list: "C1",
      answer: "teslim olmak",
      quest: "yield",
    ),
    Words5(
      front: "The youngsters are the future of our country.",
      back: "Gençler ülkemizin geleceğidir.",
      list: "C1",
      answer: "gençler",
      quest: "youngster",
    ),
  ];
}
