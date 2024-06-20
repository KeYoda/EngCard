import 'package:eng_card/data/gridview.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WordProvider extends ChangeNotifier {
  List<Words> initialList1 = [];
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
    notifyListeners();
  }

  WordProvider() {
    _loadLastIndex();
    loadData();
    wordsListOne.shuffle();
    initialList1.shuffle();
    initialList1.addAll(wordsListOne);
  }

  void loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    wordsListOne.clear();

    List<String>? questList = prefs.getStringList('questList');
    List<String>? answerList = prefs.getStringList('answerList');
    List<String>? backList = prefs.getStringList('backList');
    List<String>? frontList = prefs.getStringList('frontList');

    wordsListOne.clear();

    if (questList != null &&
        answerList != null &&
        backList != null &&
        frontList != null) {
      for (int i = 0; i < questList.length; i++) {
        Words word = Words(
          list: 'A1',
          answer: answerList[i],
          quest: questList[i],
          back: backList[i],
          front: frontList[i],
        );
        wordsListOne.add(word);
      }
    }
    notifyListeners();
  }

  void saveData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> questList = [];
    List<String> answerList = [];
    List<String> backList = [];
    List<String> frontList = [];

    for (Words word in wordsListOne) {
      questList.add(word.quest);
      answerList.add(word.answer);
      frontList.add(word.front);
      backList.add(word.back);
    }

    prefs.setStringList('questList', questList);
    prefs.setStringList('answerList', answerList);
    prefs.setStringList('backList', backList);
    prefs.setStringList('frontList', frontList);

    notifyListeners();
  }

  void deleteWord(int index, BuildContext context) {
    if (wordsListOne.isNotEmpty) {
      wordsListOne.removeAt(index);
      if (wordsListOne.isEmpty) {
        Navigator.pop(context); // Liste tamamen boşsa ekranı kapat
      } else {
        if (index == wordsListOne.length) {
          lastIndex--;
        } else {
          // Eğer eleman sayısı 1 ise ve onu siliyorsak `lastIndex` 0 olmalı
          if (wordsListOne.length == 1) {
            lastIndex = 0;
          } else {
            lastIndex = (index == 0) ? 0 : lastIndex - 1;
          }
        }
      }
      saveData();
      notifyListeners();
    }
  }

  void resetList() {
    wordsListOne.clear(); // Mevcut listeyi sıfırla

    // Başlangıç verilerini başlangıç listesi ile güncelle
    wordsListOne.addAll(initialList1);

    saveData();
    notifyListeners(); // Değişiklikleri bildir
  }

  List<Words> wordsListOne = [
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
        back:
            'Soğuk algınlığı kaptıktan sonra öksürmeyi bir türlü durduramadı.',
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
        front:
            'Canada is a beautiful country known for its diverse landscapes.',
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
        back:
            'Tekne gezimiz sırasında suyun üzerinden atlayan yunusları gördük',
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
        front:
            "He's all grown up now and learning to stand on his own two feet.",
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
        back:
            'Öğle yemeği için jambon, peynir ve marul ile bir sandviç yaptım.',
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
        front:
            'I felt a sharp pain in my shoulder after lifting the heavy box.',
        back:
            'Ağır kutuyu kaldırdıktan sonra omzumda keskin bir ağrı hissettim.',
        list: 'A1',
        answer: 'omuz',
        quest: 'shoulder'),
    Words(
        front:
            "There's no need to shout while everyone is screaming at the concert!",
        back:
            'Konser sırasında herkes bağırırken, senin de bağırmana gerek yok!',
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
}
