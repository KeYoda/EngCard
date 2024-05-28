import 'package:eng_card/data/gridview.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WordProvider4 extends ChangeNotifier {
  List<Words4> initialList4 = [];
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

  WordProvider4() {
    loadData4();
    _loadLastIndex();
    wordsListFour.shuffle();
    initialList4.shuffle();
    initialList4.addAll(wordsListFour);
  }

  void loadData4() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    List<String>? questList4 = prefs.getStringList('questList4');
    List<String>? answerList4 = prefs.getStringList('answerList4');
    List<String>? backList4 = prefs.getStringList('backList4');
    List<String>? frontList4 = prefs.getStringList('frontList4');

    wordsListFour.clear(); // Mevcut listeyi temizle

    if (questList4 != null &&
        answerList4 != null &&
        backList4 != null &&
        frontList4 != null) {
      for (int i = 0; i < questList4.length; i++) {
        Words4 word4 = Words4(
          list: 'B2',
          answer: answerList4[i],
          quest: questList4[i],
          back: backList4[i],
          front: frontList4[i],
        );
        wordsListFour.add(word4);
      }
    }

    notifyListeners();
  }

  void saveData4() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> questList4 = [];
    List<String> answerList4 = [];
    List<String> backList4 = [];
    List<String> frontList4 = [];

    for (Words4 word4 in wordsListFour) {
      questList4.add(word4.quest);
      answerList4.add(word4.answer);
      frontList4.add(word4.front);
      backList4.add(word4.back);
    }

    prefs.setStringList('questList4', questList4);
    prefs.setStringList('answerList4', answerList4);
    prefs.setStringList('backList4', backList4);
    prefs.setStringList('frontList4', frontList4);
    notifyListeners();
  }

  void deleteWord4(int index, BuildContext context) {
    if (wordsListFour.isNotEmpty) {
      wordsListFour.removeAt(index);
      if (index == wordsListFour.length) {
        // Silinen öğe son öğeyse
        lastIndex--;
      }
      if (wordsListFour.isEmpty) {
        Navigator.pop(context);
      } else {
        saveData4();
        notifyListeners();
      }
    }
  }

  void resetList4() {
    wordsListFour.clear(); // Mevcut listeyi sıfırla

    // Başlangıç verilerini başlangıç listesi ile güncelle
    wordsListFour.addAll(initialList4);

    saveData4();
    notifyListeners(); // Değişiklikleri bildir
  }

  List<Words4> wordsListFour = [
    Words4(
        front: "He decided to abandon his ship after it hit an iceberg.",
        back: "Gemisi bir buzdağına çarptıktan sonra terk etmeye karar verdi.",
        list: 'B2',
        answer: 'terk etmek',
        quest: 'abandon'),
    Words4(
        front: "There is absolute silence in the library.",
        back: "Kütüphanede mutlak sessizlik var.",
        list: 'B2',
        answer: 'mutlak, tam',
        quest: 'absolute'),
    Words4(
        front: "The sponge can absorb a large amount of water.",
        back: "Sünger, büyük miktarda suyu absorbe edebilir.",
        list: 'B2',
        answer: 'kavramak',
        quest: 'absorb'),
    Words4(
        front: "Abstract art is often difficult to understand for beginners.",
        back:
            "Soyut sanat, yeni başlayanlar için genellikle anlaşılması zordur.",
        list: 'B2',
        answer: 'soyutlamak',
        quest: 'abstract'),
    Words4(
        front: "It is not acceptable to cheat on an exam.",
        back: "Bir sınavda kopya çekmek kabul edilebilir bir şey değildir.",
        list: 'B2',
        answer: 'kabul edilebilir',
        quest: 'acceptable'),
    Words4(
        front:
            "Would you like me to accompany you to the doctor's appointment?",
        back: "Doktor randevunuza eşlik etmemi ister misiniz?",
        list: 'B2',
        answer: 'eşlik etmek',
        quest: 'accompany'),
    Words4(
        front: "Don't forget to take your account number with you to the bank.",
        back:
            "Bankaya giderken hesap numaranızı yanınızda götürmeyi unutmayın.",
        list: 'B2',
        answer: 'hesap',
        quest: 'account'),
    Words4(
        front: "The information in this report is accurate and up-to-date.",
        back: "Bu rapordaki bilgiler doğru ve günceldir.",
        list: 'B2',
        answer: 'doğru',
        quest: 'accurate'),
    Words4(
        front: "The police accused him of stealing the money.",
        back: "Polis onu parayı çalmakla suçladı.",
        list: 'B2',
        answer: 'suçlamak',
        quest: 'accuse'),
    Words4(
        front: "He acknowledged his mistake and apologized.",
        back: "Hatasını kabul etti ve özür diledi.",
        list: 'B2',
        answer: 'kabullenmek',
        quest: 'acknowledge'),
    Words4(
        front: "She was able to acquire new skills through her online courses.",
        back: "Çevrimiçi kursları sayesinde yeni beceriler edinebildi.",
        list: 'B2',
        answer: 'elde etmek',
        quest: 'acquire'),
    Words4(
        front: "The actual reason for his departure is unknown.",
        back: "Ayrılmasının gerçek nedeni bilinmiyor.",
        list: 'B2',
        answer: 'gerçek',
        quest: 'actual'),
    Words4(
        front: "We need to adapt to the changing climate.",
        back: "Değişen iklime adapte olmamız gerekiyor.",
        list: 'B2',
        answer: 'adapte etmek',
        quest: 'adapt'),
    Words4(
        front:
            "I need some additional information before I can make a decision.",
        back: "Karar vermeden önce biraz daha fazladan bilgiye ihtiyacım var.",
        list: 'B2',
        answer: 'fazladan',
        quest: 'additional'),
    Words4(
        front:
            "Please address your complaints to the customer service department.",
        back: "Şikayetlerinizi lütfen müşteri hizmetleri bölümüne bildirin.",
        list: 'B2',
        answer: 'hitap etmek, adres',
        quest: 'address'),
    Words4(
        front:
            "The school administration is responsible for the day-to-day running of the school.",
        back: "Okul yönetimi, okulun günlük işleyişinden sorumludur.",
        list: 'B2',
        answer: 'yönetim',
        quest: 'administration'),
    Words4(
        front:
            "Many couples choose to adopt children who are in need of a loving home.",
        back:
            "Birçok çift, sevgi dolu bir yuva ihtiyacı olan çocukları evlat edinmeyi tercih eder.",
        list: 'B2',
        answer: 'evlat edinmek, benimsemek',
        quest: 'adopt'),
    Words4(
        front:
            "He was promoted to a management position after several years of hard work.",
        back:
            "Yıllarca süren sıkı çalışmanın ardından yönetim pozisyonuna terfi etti.",
        list: 'B2',
        answer: 'terfi ettirmek',
        quest: 'advance'),
    Words4(
        front: "It's none of your affair what I do in my free time.",
        back: "Boş zamanımda ne yaptığımın senin meselen değil.",
        list: 'B2',
        answer: 'mesele',
        quest: 'affair'),
    Words4(
        front: "We can discuss this further afterwards if you like.",
        back:
            "İsterseniz bunu daha sonra daha ayrıntılı olarak tartışabiliriz.",
        list: 'B2',
        answer: 'sonrada',
        quest: 'afterwards'),
    Words4(
        front: "I booked my flight through a travel agency.",
        back: "Uçuşumu bir seyahat acentesi aracılığıyla rezerve ettirdim.",
        list: 'B2',
        answer: 'acente',
        quest: 'agency'),
    Words4(
        front: "What's on the agenda for today's meeting?",
        back: "Bugünkü toplantının gündeminde ne var?",
        list: 'B2',
        answer: 'gündem',
        quest: 'agenda'),
    Words4(
        front: "The dog became aggressive when the mail carrier approached.",
        back: "Postacı yaklaştığında köpek agresifleşti.",
        list: 'B2',
        answer: 'agresif',
        quest: 'aggressive'),
    Words4(
        front:
            "Many international organizations provide aid to developing countries.",
        back:
            "Birçok uluslararası kuruluş, gelişmekte olan ülkelere yardım sağlıyor.",
        list: 'B2',
        answer: 'yardım etmek',
        quest: 'aid'),
    Words4(
        front:
            "The pilot was able to safely land the aircraft despite the bad weather.",
        back:
            "Pilot, kötü hava koşullarına rağmen uçağı güvenli bir şekilde yere indirmeyi başardı.",
        list: 'B2',
        answer: 'uçak',
        quest: 'aircraft'),
    Words4(
        front: "I need to alter my schedule because of the unexpected meeting.",
        back:
            "Beklenmedik toplantı nedeniyle programımı değiştirmem gerekiyor.",
        list: 'B2',
        answer: 'değiştirmek',
        quest: 'alter'),
    Words4(
        front: "The total amount of the bill is \$100.",
        back: "Faturanın toplam miktarı 100 dolar.",
        list: 'B2',
        answer: 'miktar',
        quest: 'amount'),
    Words4(
        front: "Don't try to anger me. It won't help.",
        back: "Beni kızdırmaya çalışma. Yardımcı olmaz.",
        list: 'B2',
        answer: 'kızdırmak',
        quest: 'anger'),
    Words4(
        front:
            "The photographer tilted the camera at a slight angle to get a better shot.",
        back:
            "Fotoğrafçı, daha iyi bir çekim yapmak için kamerayı hafif bir açıyla eğdi.",
        list: 'B2',
        answer: 'açı',
        quest: 'angle'),
    Words4(
        front:
            "They celebrated their wedding anniversary with a romantic dinner.",
        back: "Düğün yıldönümlerini romantik bir akşam yemeği ile kutladılar.",
        list: 'B2',
        answer: 'yıl dönümü',
        quest: 'anniversary'),
    Words4(
        front: "The company is having its annual sales conference next week.",
        back: "Şirket, önümüzdeki hafta yıllık satış konferansını düzenliyor.",
        list: 'B2',
        answer: 'senelik',
        quest: 'annual'),
    Words4(
        front: "She seemed a little anxious before her job interview.",
        back: "İş görüşmesinden önce biraz endişeli görünüyordu.",
        list: 'B2',
        answer: 'endişeli',
        quest: 'anxious'),
    Words4(
        front:
            "It is apparent that he is not interested in what I have to say.",
        back: "Benim söyleyeceklerime ilgisiz olduğu açık.",
        list: 'B2',
        answer: 'aşikar',
        quest: 'apparent'),
    Words4(
        front:
            "Apparently, they are planning to move to a new house next year.",
        back:
            "Görünüşe göre, önümüzdeki sene yeni bir eve taşınmayı planlıyorlar.",
        list: 'B2',
        answer: 'görünüşte',
        quest: 'Apparently'),
    Words4(
        front: "The judge will appeal the decision to a higher court.",
        back: "Yargıç, kararı daha yüksek bir mahkemeye taşıyacaktır.",
        list: 'B2',
        answer: 'başvurmak',
        quest: 'appeal'),
    Words4(
        front: "He slowly approached the dog, making sure not to startle it.",
        back: "Köpeği ürkütmemeye dikkat ederek yavaşça yaklaştı.",
        list: 'B2',
        answer: 'yanaşmak',
        quest: 'approach'),
    Words4(
        front: "It is not appropriate to wear shorts to a job interview.",
        back: "İş görüşmesine şort giymek uygunsuz değildir.",
        list: 'B2',
        answer: 'el koymak',
        quest: 'appropriate'),
    Words4(
        front: "We are still waiting for the approval of our loan application.",
        back: "Kredi başvurumuzun onaylanmasını hala bekliyoruz.",
        list: 'B2',
        answer: 'onaylama',
        quest: 'approval'),
    Words4(
        front: "My application was finally approved after a long wait.",
        back: "Uzun bir bekleyişin ardından başvurum nihayet onaylandı.",
        list: 'B2',
        answer: 'onaylanmak',
        quest: 'approve'),
    Words4(
        front: "Many social problems arise from poverty and inequality.",
        back: "Birçok sosyal sorun yoksulluk ve eşitsizlikten kaynaklanır.",
        list: 'B2',
        answer: 'kaynaklanmak',
        quest: 'arise'),
    Words4(
        front: "The police were called to the scene of an armed robbery.",
        back: "Polis, silahlı soygun olay yerine çağrıldı.",
        list: 'B2',
        answer: 'ateşli',
        quest: 'armed'),
    Words4(
        front: "He is applying for a permit to carry arms for self-defense.",
        back:
            "Kendini savunmak için silah taşıma ruhsatı başvurusunda bulunuyor.",
        list: 'B2',
        answer: 'koyun, silahlar',
        quest: 'arms'),
    Words4(
        front:
            "Artificial intelligence is rapidly changing the world around us.",
        back: "Yapay zeka, çevremizdeki dünyayı hızla değiştiriyor.",
        list: 'B2',
        answer: 'yapay',
        quest: 'Artificial'),
    Words4(
        front: "He felt ashamed of his behavior and apologized to his friends.",
        back:
            "Davranışından dolayı mahcup oldu ve arkadaşlarından özür diledi.",
        list: 'B2',
        answer: 'mahcup',
        quest: 'ashamed'),
    Words4(
        front:
            "Let's consider all the different aspects of this issue before making a decision.",
        back: "Karar vermeden önce bu konunun tüm farklı yönlerini ele alalım.",
        list: 'B2',
        answer: 'hal',
        quest: 'aspect'),
    Words4(
        front:
            "The teacher assessed the students' understanding of the material.",
        back: "Öğretmen, öğrencilerin konuyu anlama düzeyini değerlendirdi.",
        list: 'B2',
        answer: 'değer biçmek',
        quest: 'assess'),
    Words4(
        front:
            "We need a thorough assessment of the situation before we can proceed.",
        back:
            "Devam edebilmemiz için öncelikle durumun kapsamlı bir değerlendirmesine ihtiyacımız var.",
        list: 'B2',
        answer: 'değerlendirme',
        quest: 'assessment'),
    Words4(
        front: "People often associate red with love and danger.",
        back:
            "İnsanlar genellikle kırmızıyı aşk ve tehlike ile ilişkilendirir.",
        list: 'B2',
        answer: 'ilişkilendirmek',
        quest: 'associate'),
    Words4(
        front: "Certain colors are associated with specific emotions.",
        back: "Belirli renkler belirli duygularla ilişkilendirilir.",
        list: 'B2',
        answer: 'bağlantılı',
        quest: 'associated'),
    Words4(
        front: "He is a member of a local environmental association.",
        back: "Yerel bir çevre koruma derneği üyesidir.",
        list: 'B2',
        answer: 'birlik',
        quest: 'association'),
    Words4(
        front: "I can't assume that everyone knows how to use this software.",
        back: "Herkesin bu yazılımı nasıl kullanacağını bildiğini varsayamam.",
        list: 'B2',
        answer: 'üstlenmek',
        quest: 'assume'),
    Words4(
        front:
            "He made several attempts to climb the mountain, but failed each time.",
        back:
            "Dağa tırmanmak için birkaç girişimde bulundu, ancak her seferinde başarısız oldu.",
        list: 'B2',
        answer: 'teşebbüs etmek',
        quest: 'attempt'),
    Words4(
        front: "Please come sit at the back of the class.",
        back: "Lütfen sınıfın arkasına oturmaya gel.",
        list: 'B2',
        answer: 'sırt',
        quest: 'back'),
    Words4(
        front: "Antibiotics are used to kill bacteria that cause infections.",
        back:
            "Antibiyotikler, enfeksiyona neden olan bakterileri öldürmek için kullanılır.",
        list: 'B2',
        answer: 'bakteri',
        quest: 'bacteria'),
    Words4(
        front: "He leaned against the bar and ordered a drink.",
        back: "Bara yaslandı ve bir içki sipariş etti.",
        list: 'B2',
        answer: 'çubuk',
        quest: 'bar'),
    Words4(
        front:
            "The language barrier made it difficult for them to communicate.",
        back: "Dil bariyeri iletişim kurmalarını zorlaştırdı.",
        list: 'B2',
        answer: 'bariyer',
        quest: 'barrier'),
    Words4(
        front:
            "Basically, you just need to add these two ingredients together.",
        back: "Temelde, bu iki malzemeyi bir araya getirmeniz yeterlidir.",
        list: 'B2',
        answer: 'temelde',
        quest: 'basically'),
    Words4(
        front:
            "The two armies clashed in a fierce battle for control of the territory.",
        back:
            "İki ordu, bölgenin kontrolü için şiddetli bir savaşta karşı karşıya geldi.",
        list: 'B2',
        answer: 'savaş',
        quest: 'battle'),
    Words4(
        front: "I can't bear to see her suffer like this.",
        back: "Onun böyle acı çekmesine dayanamıyorum.",
        list: 'B2',
        answer: 'dayanmak',
        quest: 'bear'),
    Words4(
        front: "The music was so loud that it made my heart beat faster.",
        back:
            "Müzik o kadar yüksekti ki kalbimin daha hızlı atmasına neden oldu.",
        list: 'B2',
        answer: 'vurmak',
        quest: 'beat'),
    Words4(
        front: "He was begging for money on the street corner.",
        back: "Sokak köşesinde para dileniyordu.",
        list: 'B2',
        answer: 'dilenmek',
        quest: 'beg'),
    Words4(
        front: "Her being there made all the difference.",
        back: "Onun orada olması her şeyi değiştirdi.",
        list: 'B2',
        answer: 'yapı',
        quest: 'being'),
    Words4(
        front: "The metal rod was bent out of shape after the accident.",
        back: "Metal çubuk, kaza sonrası eğrilmişti.",
        list: 'B2',
        answer: 'bükülmüş',
        quest: 'bent'),
    Words4(
        front: "I'm willing to bet that he will be late again.",
        back: "Tekrar geç kalacağına bahse varım.",
        list: 'B2',
        answer: 'iddia',
        quest: 'bet'),
    Words4(
        front: "There is a whole world beyond what we can see with our eyes.",
        back:
            "Gözlerimizle göremediğimiz şeylerin ötesinde kocaman bir dünya var.",
        list: 'B2',
        answer: 'öte',
        quest: 'beyond'),
    Words4(
        front: "Please pay your bill by the end of the month.",
        back: "Lütfen faturanızı ay sonuna kadar ödeyin.",
        list: 'B2',
        answer: 'fatura',
        quest: 'bill'),
    Words4(
        front:
            "The police are blaming him for the robbery, but he claims he is innocent.",
        back:
            "Polis onu soygunla suçluyor, ancak o masum olduğunu iddia ediyor.",
        list: 'B2',
        answer: 'suçlamak',
        quest: 'blame'),
    Words4(
        front: "The man was blind and could not see anything.",
        back: "Adam kördü ve hiçbir şey göremezdi.",
        list: 'B2',
        answer: 'kör',
        quest: 'blind'),
    Words4(
        front:
            "The strong bond between the two friends helped them through difficult times.",
        back:
            "İki arkadaş arasındaki güçlü bağ, zor zamanlarda onlara yardım etti.",
        list: 'B2',
        answer: 'tutturmak',
        quest: 'bond'),
    Words4(
        front: "The country has a long border with Mexico.",
        back: "Ülkenin Meksika ile uzun bir sınırı var.",
        list: 'B2',
        answer: 'kenarlık',
        quest: 'border'),
    Words4(
        front:
            "It is important to perform a self-breast examination regularly.",
        back: "Düzenli olarak kendi kendine meme muayenesi yapmak önemlidir.",
        list: 'B2',
        answer: 'meme',
        quest: 'breast'),
    Words4(
        front: "The manager gave us a brief overview of the new project.",
        back: "Yönetici bize yeni proje hakkında kısa bir brifing verdi.",
        list: 'B2',
        answer: 'kısa, talimat',
        quest: 'brief'),
    Words4(
        front: "He has a broad range of knowledge on a variety of topics.",
        back: "Çok çeşitli konularda geniş bir bilgi birikimine sahiptir.",
        list: 'B2',
        answer: 'geniş',
        quest: 'broad'),
    Words4(
        front: "The news will be broadcasted live at 8 pm.",
        back: "Haberler saat 8'de canlı olarak yayınlanacak.",
        list: 'B2',
        answer: 'yayın',
        quest: 'broadcast'),
    Words4(
        front: "We need to create a budget for the upcoming holiday season.",
        back: " yaklaşan tatil sezonu için bir bütçe oluşturmamız gerekiyor.",
        list: 'B2',
        answer: 'bütçe',
        quest: 'budget'),
    Words4(
        front: "The soldier dodged the bullet as it whizzed past his head.",
        back: "Asker, vızıldayarak başının üzerinden geçen mermiyi atlattı.",
        list: 'B2',
        answer: 'mermi',
        quest: 'bullet'),
    Words4(
        front: "He bought a bunch of flowers for his wife.",
        back: "Karısına bir demet çiçek aldı.",
        list: 'B2',
        answer: 'salkım, demet',
        quest: 'bunch'),
    Words4(
        front: "Be careful not to burn yourself on the hot stove.",
        back: "Sıcak sobada kendinizi yakmamaya dikkat edin.",
        list: 'B2',
        answer: 'yakmak',
        quest: 'burn'),
    Words4(
        front: "The hikers got lost in the dense bushes.",
        back: "Yürüyüşçüler sık çalılarda kayboldu.",
        list: 'B2',
        answer: 'çalı',
        quest: 'bush'),
    Words4(
        front: "I want to go swimming, but the water is too cold.",
        back: "Yüzmeye gitmek istiyorum, ama su çok soğuk.",
        list: 'B2',
        answer: 'ancak',
        quest: 'but'),
    Words4(
        front: "Be careful not to trip over the electrical cable.",
        back: "Elektrik kablosuna takılmamaya dikkat edin.",
        list: 'B2',
        answer: 'kablo',
        quest: 'cable'),
    Words4(
        front: "The scientist was able to calculate the distance to the moon.",
        back: "Bilim insanı, aya olan mesafeyi hesaplayabildi.",
        list: 'B2',
        answer: 'hesaplamak',
        quest: 'calculate'),
    Words4(
        front: "I'm afraid I have to cancel our meeting today.",
        back: "Ne yazık ki bugünkü görüşmemizi iptal etmek zorundayım.",
        list: 'B2',
        answer: 'iptal etmek',
        quest: 'cancel'),
    Words4(
        front:
            "Cancer is a serious disease that can affect any part of the body.",
        back:
            "Kanser, vücudun herhangi bir yerini etkileyebilen ciddi bir hastalıktır.",
        list: 'B2',
        answer: 'kanser',
        quest: 'Cancer'),
    Words4(
        front: "He is a very capable student and excels in all his subjects.",
        back: "Çok yetenekli bir öğrencidir ve tüm derslerinde başarılıdır.",
        list: 'B2',
        answer: 'yetenekli',
        quest: 'capable'),
    Words4(
        front:
            "The battery has a limited capacity and needs to be recharged regularly.",
        back:
            "Pilin sınırlı bir kapasitesi vardır ve düzenli olarak şarj edilmesi gerekir.",
        list: 'B2',
        answer: 'kapasite',
        quest: 'capacity'),
    Words4(
        front: "The police are trying to capture the escaped convict.",
        back: "Polis, kaçan hükümlüyü yakalamaya çalışıyor.",
        list: 'B2',
        answer: 'ele geçirmek',
        quest: 'capture'),
    Words4(
        front: "He cast a magic spell that made him invisible.",
        back: "Onu görünmez yapan sihirli bir büyü yaptı.",
        list: 'B2',
        answer: 'dökmek',
        quest: 'cast'),
    Words4(
        front:
            "The baseball player tried to catch the ball, but it went over his head.",
        back:
            "Beyzbol oyuncusu topu yakalamaya çalıştı ama topun üzerinden geçti.",
        list: 'B2',
        answer: 'yakalamak',
        quest: 'catch'),
    Words4(
        front: "Cancer cells can spread to other parts of the body.",
        back: "Kanser hücreleri vücudun diğer bölgelerine yayılabilir.",
        list: 'B2',
        answer: 'hücre',
        quest: 'cell'),
    Words4(
        front: "I need a new chain for my bicycle.",
        back: "Bisikletim için yeni bir zincir gerekiyor.",
        list: 'B2',
        answer: 'zincir',
        quest: 'chain'),
    Words4(
        front: "Please pull up a chair and have a seat.",
        back: "Lütfen bir sandalye çekin ve oturun.",
        list: 'B2',
        answer: 'sandalye',
        quest: 'chair'),
    Words4(
        front: "The chairman of the board led the meeting.",
        back: "Yönetim kurulu başkanı toplantıya başkanlık etti.",
        list: 'B2',
        answer: 'başkan',
        quest: 'chairman'),
    Words4(
        front: "He decided to challenge himself and run a marathon.",
        back: "Kendisine meydan okumaya ve maraton koşmaya karar verdi.",
        list: 'B2',
        answer: 'meydan okumak',
        quest: 'challenge'),
    Words4(
        front: "The doctor used a chart to explain the patient's progress.",
        back:
            "Doktor, hastanın iyileşme sürecini açıklamak için bir çizelge kullandı.",
        list: 'B2',
        answer: 'çizelge',
        quest: 'chart'),
    Words4(
        front: "The head chef is responsible for overseeing the kitchen staff.",
        back: "Şef, mutfak personelini denetlemekten sorumludur.",
        list: 'B2',
        answer: 'şef',
        quest: 'chief'),
    Words4(
        front:
            "We need to consider all the circumstances before making a decision.",
        back: "Karar vermeden önce tüm durumları değerlendirmemiz gerekiyor.",
        list: 'B2',
        answer: 'durum',
        quest: 'circumstance'),
    Words4(
        front: "The author cited several scientific studies in his book.",
        back: "Yazar, kitabında birkaç bilimsel çalışmaya atıfta bulundu.",
        list: 'B2',
        answer: 'bahsetmek',
        quest: 'cite'),
    Words4(
        front: "Every citizen has the right to vote in elections.",
        back: "Her vatandaşın seçimlerde oy kullanma hakkı vardır.",
        list: 'B2',
        answer: 'vatandaş',
        quest: 'citizen'),
    Words4(
        front: "The war caused a lot of civilian casualties.",
        back: "Savaş, birçok sivil kayıpa neden oldu.",
        list: 'B2',
        answer: 'sivil',
        quest: 'civil'),
    Words4(
        front: "He is a big fan of classic rock music.",
        back: "Klasik rock müziğinin büyük hayranıdır.",
        list: 'B2',
        answer: 'medeniyet',
        quest: 'classic'),
    Words4(
        front: "Please close the door behind you when you leave.",
        back: "Çıkarken lütfen arkanızdaki kapıyı kapatın.",
        list: 'B2',
        answer: 'kapatmak',
        quest: 'close'),
    Words4(
        front: "We need to work more closely together to achieve our goals.",
        back: "Hedeflerimize ulaşmak için daha yakın çalışmamız gerekiyor.",
        list: 'B2',
        answer: 'yakından',
        quest: 'closely'),
    Words4(
        front: "The building collapsed after the earthquake.",
        back: "Bina depremden sonra yıkıldı.",
        list: 'B2',
        answer: 'yığılmak',
        quest: 'collapse'),
    Words4(
        front: "The lock requires a specific combination of numbers to open.",
        back: "Kilidin açılması için belirli bir sayı kombinasyonu gerekir.",
        list: 'B2',
        answer: 'kombinasyon',
        quest: 'combination'),
    Words4(
        front: "He took a long bath to relax and find comfort.",
        back: "Rahatlamak ve rahatlık bulmak için uzun bir banyo yaptı.",
        list: 'B2',
        answer: 'rahatlık, konfor',
        quest: 'comfort'),
    Words4(
        front: "The officer commanded his troops to advance.",
        back: "Subay askerlerine ilerlemelerini emretti.",
        list: 'B2',
        answer: 'emretmek',
        quest: 'command'),
    Words4(
        front: "The artist received a commission to paint a portrait.",
        back: "Sanatçı, bir portre resimleme komisyonu aldı.",
        list: 'B2',
        answer: 'komisyon',
        quest: 'commission'),
    Words4(
        front: "A strong work ethic and commitment are essential for success.",
        back: "Başarı için güçlü bir çalışma ahlakı ve bağlılık esastır.",
        list: 'B2',
        answer: 'bağlılık',
        quest: 'commitment'),
    Words4(
        front: "The committee is responsible for reviewing new legislation.",
        back: "Komite, yeni yasaları incelemekten sorumludur.",
        list: 'B2',
        answer: 'kurul',
        quest: 'committee'),
    Words4(
        front: "Water is commonly found on Earth.",
        back: "Su, Dünya'da yaygın olarak bulunur.",
        list: 'B2',
        answer: 'ortak olarak',
        quest: 'commonly'),
    Words4(
        front: "The human body is a complex system of organs and tissues.",
        back: "İnsan vücudu karmaşık bir organ ve doku sistemidir.",
        list: 'B2',
        answer: 'karışık',
        quest: 'complex'),
    Words4(
        front:
            "The instructions for assembling the furniture were very complicated.",
        back: "Mobilya montaj talimatları çok karmaşıktı.",
        list: 'B2',
        answer: 'komplike',
        quest: 'complicated'),
    Words4(
        front: "Air is a mixture of different gases and components.",
        back: "Hava, farklı gazların ve bileşenlerin bir karışımıdır.",
        list: 'B2',
        answer: 'bileşen',
        quest: 'component'),
    Words4(
        front:
            "He needed to improve his concentration in order to focus on his studies.",
        back:
            "Derslerine odaklanabilmek için konsantrasyonunu geliştirmesi gerekiyordu.",
        list: 'B2',
        answer: 'yığma',
        quest: 'concentration'),
    Words4(
        front:
            "The concept of gravity is difficult to understand for young children.",
        back: "Küçük çocuklar için yerçekimi kavramı anlaşılması zordur.",
        list: 'B2',
        answer: 'konsept',
        quest: 'concept'),
    Words4(
        front: "I am concerned about her health.",
        back: "Onun sağlığı beni ilgilendiriyor.",
        list: 'B2',
        answer: 'ilgilendirmek',
        quest: 'concern'),
    Words4(
        front: "Are you concerned about the upcoming exam?",
        back: "Yaklaşan sınav hakkında endişeleniyor musun?",
        list: 'B2',
        answer: 'ilgili',
        quest: 'concerned'),
    Words4(
        front: "The teacher will conduct the experiment in front of the class.",
        back: "Öğretmen, deneyi sınıfın önünde yürütecek.",
        list: 'B2',
        answer: 'yönetmek',
        quest: 'conduct'),
    Words4(
        front: "I spoke with confidence during my presentation.",
        back: "Sunumum sırasında güvenle konuştum.",
        list: 'B2',
        answer: 'güven',
        quest: 'confidence'),
    Words4(
        front: "There is a conflict between the two countries.",
        back: "İki ülke arasında bir çatışma var.",
        list: 'B2',
        answer: 'çekişmek',
        quest: 'conflict'),
    Words4(
        front: "The instructions for the game were very confusing.",
        back: "Oyunun talimatları çok kafa karıştırıcıydı.",
        list: 'B2',
        answer: 'şaşırtma',
        quest: 'confusing'),
    Words4(
        front: "He is still conscious after the accident.",
        back: "Kazadan sonra hala bilinçli.",
        list: 'B2',
        answer: 'bilinçli',
        quest: 'conscious'),
    Words4(
        front:
            "She is a conservative politician who believes in traditional values.",
        back: "Geleneksel değerlere inanan muhafazakar bir politikacıdır.",
        list: 'B2',
        answer: 'muhafazakar',
        quest: 'conservative'),
    Words4(
        front:
            "We need to take your age into consideration when choosing an activity.",
        back:
            "Bir etkinlik seçerken yaşınızı göz önünde bulundurmamız gerekiyor.",
        list: 'B2',
        answer: 'düşünce',
        quest: 'consideration'),
    Words4(
        front:
            "He is a consistent performer and always delivers high-quality work.",
        back:
            "Tutarlı bir performans sergiler ve her zaman yüksek kaliteli işler sunar.",
        list: 'B2',
        answer: 'istikrarlı',
        quest: 'consistent'),
    Words4(
        front: "The Earth's temperature is constantly changing.",
        back: "Dünya'nın sıcaklığı sürekli değişiyor.",
        list: 'B2',
        answer: 'sabit',
        quest: 'constant'),
    Words4(
        front: "He is constantly checking his phone for messages.",
        back: "Mesajları olup olmadığını sürekli telefonunu kontrol ediyor.",
        list: 'B2',
        answer: 'ikide bir',
        quest: 'constantly'),
    Words4(
        front: "We need to construct a solid foundation for the building.",
        back: "Sağlam bir bina için sağlam bir temel inşa etmemiz gerekiyor.",
        list: 'B2',
        answer: 'inşa etmek',
        quest: 'construct'),
    Words4(
        front:
            "The construction of the new bridge is expected to take two years.",
        back: "Yeni köprünün yapımı iki yıl sürmesi bekleniyor.",
        list: 'B2',
        answer: 'yapı',
        quest: 'construction'),
    Words4(
        front: "The artist's work reflects contemporary social issues.",
        back: "Sanatçının eseri, çağdaş sosyal sorunları yansıtıyor.",
        list: 'B2',
        answer: 'modern',
        quest: 'contemporary'),
    Words4(
        front: "She participated in a singing contest to showcase her talent.",
        back: "Yeteneğini sergilemek için bir şarkı yarışmasına katıldı.",
        list: 'B2',
        answer: 'yarışma',
        quest: 'contest'),
    Words4(
        front: "He carefully reviewed the contract before signing it.",
        back: "Sözleşmeyi imzalamadan önce dikkatlice inceledi.",
        list: 'B2',
        answer: 'sözleşme',
        quest: 'contract'),
    Words4(
        front:
            "Her research has contributed significantly to the field of medicine.",
        back: "Araştırmaları tıp alanına önemli ölçüde katkıda bulundu.",
        list: 'B2',
        answer: 'katkı yapmak',
        quest: 'contribute'),
    Words4(
        front: "His positive attitude is a valuable contribution to the team.",
        back: "Pozitif tavrı, ekibe değerli bir katkıdır.",
        list: 'B2',
        answer: 'katkı',
        quest: 'contribution'),
    Words4(
        front: "He was able to convert the old file format into a new one.",
        back: "Eski dosya formatını yenisine dönüştürebildi.",
        list: 'B2',
        answer: 'dönüştürmek',
        quest: 'convert'),
    Words4(
        front:
            "After seeing the evidence, he was finally convinced of her innocence.",
        back: "Kanıtı gördükten sonra, sonunda onun masumiyetine ikna oldu.",
        list: 'B2',
        answer: 'inandırılan',
        quest: 'convinced'),
    Words4(
        front: "The core of the building is made of steel and concrete.",
        back: "Binanın çekirdeği çelik ve betondan yapılmıştır.",
        list: 'B2',
        answer: 'çekirdek',
        quest:
            'core'), // Here, 'core' might be a better translation for 'çekirdek'
    Words4(
        front: "He climbed the corporate ladder and became a successful CEO.",
        back: "Kurumsal basamaklarda yükseldi ve başarılı bir CEO oldu.",
        list: 'B2',
        answer: 'kurumsal',
        quest: 'corporate'),
    Words4(
        front:
            "The city council is responsible for making decisions about local issues.",
        back:
            "Şehir meclisi, yerel sorunlarla ilgili karar vermekten sorumludur.",
        list: 'B2',
        answer: 'meclis',
        quest: 'council'),
    Words4(
        front: "We live in a small county in the northern part of the country.",
        back: "Ülkenin kuzey kesiminde bulunan küçük bir ilçede yaşıyoruz.",
        list: 'B2',
        answer: 'ilçe',
        quest: 'county'),
    Words4(
        front:
            "It took a lot of courage for her to stand up for what she believed in.",
        back: "İnandığı şeyleri savunmak için çok cesaret gerekiyordu.",
        list: 'B2',
        answer: 'cesurluk',
        quest: 'courage'),
    Words4(
        front: "The car crashed into a tree after losing control.",
        back: "Araba kontrolden çıktıktan sonra ağaca çarptı.",
        list: 'B2',
        answer: 'çarpmak',
        quest: 'crash'),
    Words4(
        front: "The artist is known for her unique and creative creations.",
        back: "Sanatçı, eşsiz ve yaratıcı kreasyonlarıyla tanınır.",
        list: 'B2',
        answer: 'kreasyon',
        quest: 'creation'),
    Words4(
        front: "Mythology is full of stories about fantastical creatures.",
        back: "Mitoloji, fantastik yaratıklar hakkındaki hikayelerle doludur.",
        list: 'B2',
        answer: 'varlık',
        quest: 'creature'),
    Words4(
        front: "He applied for a loan at the bank to get some credit.",
        back: "Bankadan biraz kredi almak için kredi başvurusunda bulundu.",
        list: 'B2',
        answer: 'kredi',
        quest: 'credit'),
    Words4(
        front:
            "The airplane crew consisted of the pilot, copilot, and flight attendants.",
        back:
            "Uçak ekibi pilot, yardımcı pilot ve kabin memurlarından oluşuyordu.",
        list: 'B2',
        answer: 'tayfa',
        quest: 'crew'),
    Words4(
        front: "The country is facing a major economic crisis.",
        back: "Ülke, büyük bir ekonomik krizle karşı karşıyadır.",
        list: 'B2',
        answer: 'bunalım',
        quest: 'crisis'),
    Words4(
        front:
            "We need to establish clear criteria for evaluating job applications.",
        back:
            "İş başvurularını değerlendirmek için net kriterler belirlememiz gerekiyor.",
        list: 'B2',
        answer: 'kriter',
        quest: 'criterion'),
    Words4(
        front: "The movie critic gave the film a negative review.",
        back: "Film eleştirmeni filme olumsuz bir eleştiri yaptı.",
        list: 'B2',
        answer: 'kritik',
        quest: 'critic'),
    Words4(
        front: "Her constant criticism made him feel discouraged.",
        back: "Sürekli eleştirisi moralini bozdu.",
        list: 'B2',
        answer: 'eleştiri',
        quest: 'criticism'),
    Words4(
        front: "It is not polite to criticize someone's appearance.",
        back: "Birinin görünüşünü eleştirmek kibarca bir davranış değildir.",
        list: 'B2',
        answer: 'eleştirmek',
        quest: 'criticize'),
    Words4(
        front: "The farmer's crops were destroyed by the hail storm.",
        back: "Çiftçinin mahsulü dolu felaketiyle yok oldu.",
        list: 'B2',
        answer: 'mahsul',
        quest: 'crop'),
    Words4(
        front: "Making a good first impression is crucial for a job interview.",
        back: "İyi bir ilk izlenim bırakmak, iş görüşmesi için çok önemlidir.",
        list: 'B2',
        answer: 'çok önemli',
        quest: 'crucial'),
    Words4(
        front: "The baby started crying after he fell down.",
        back: "Düştükten sonra bebek ağlamaya başladı.",
        list: 'B2',
        answer: 'ağlamak',
        quest: 'cry'),
    Words4(
        front:
            "There is no cure for the common cold, but symptoms usually improve within a week.",
        back:
            "Soğuk algınlığı için bir tedavi yoktur, ancak semptomlar genellikle bir hafta içinde düzelir.",
        list: 'B2',
        answer: 'iyileştirmek',
        quest: 'cure'),
    Words4(
        front: "The electric current can be dangerous if not handled properly.",
        back: "Elektrik akımı doğru kullanılmazsa tehlikeli olabilir.",
        list: 'B2',
        answer: 'akım',
        quest: 'current'),
    Words4(
        front: "The road takes a sharp curve to the left.",
        back: "Yol sola doğru keskin bir viraj alıyor.",
        list: 'B2',
        answer: 'bükülmek',
        quest: 'curve'),
    Words4(
        front: "The building has a curved roof design.",
        back: "Binanın kavisli bir çatı tasarımı vardır.",
        list: 'B2',
        answer: 'eğimli',
        quest: 'curved'),
    Words4(
        front: "He asked her out on a date for this weekend.",
        back: "Onu bu hafta sonu için randevuya davet etti.",
        list: 'B2',
        answer: 'randevuya çıkmak',
        quest: 'date'),
    Words4(
        front: "There was a heated debate about the new government policy.",
        back:
            "Yeni hükümet politikası hakkında hararetli bir tartışma yaşandı.",
        list: 'B2',
        answer: 'debate',
        quest: 'debate'),
    Words4(
        front: "He is struggling to pay off his student debt.",
        back: "Öğrenci borcunu ödemekte zorlanıyor.",
        list: 'B2',
        answer: 'borç',
        quest: 'debt'),
    Words4(
        front:
            "He is a decent and kind person who is always willing to help others.",
        back:
            "Yardımsever ve her zaman başkalarına yardım etmeye istekli olan düzgün bir insandır.",
        list: 'B2',
        answer: 'edepli',
        quest: 'decent'),
    Words4(
        front:
            "The president declared a state of emergency after the natural disaster.",
        back: "Devlet başkanı, doğal afetten sonra olağanüstü hal ilan etti.",
        list: 'B2',
        answer: 'beyan etmek',
        quest: 'declare'),
    Words4(
        front: "She politely declined the offer because she was already busy.",
        back: "Zaten meşgul olduğu için teklifi nazikçe reddetti.",
        list: 'B2',
        answer: 'geri çevirmek', // 'zayıflamak' means 'to weaken'
        quest: 'decline'),
    Words4(
        front: "The room was filled with beautiful decorations for the party.",
        back: "Oda, parti için güzel süslemelerle doluydu.",
        list: 'B2',
        answer: 'süsleme',
        quest: 'decoration'),
    Words4(
        front:
            "The number of COVID-19 cases has been decrease/ing in recent weeks.",
        back: "Son haftalarda COVID-19 vakalarının sayısı azalıyor.",
        list: 'B2',
        answer: 'küçülmek',
        quest: 'decrease'),
    Words4(
        front: "He was deeply affected by the news of his friend's death.",
        back: "Arkadaşının ölümü haberinden derinden etkilenmişti.",
        list: 'B2',
        answer: 'son derece',
        quest: 'deeply'),
    Words4(
        front:
            "The smaller team unexpectedly defeated the favorites in the championship game.",
        back:
            "Daha küçük takım, şampiyonluk maçında favorileri beklenmedik şekilde yendi.",
        list: 'B2',
        answer: 'yenmek',
        quest: 'defeat'),
    Words4(
        front: "The lawyer presented a strong defence for his client in court.",
        back: "Avukat, mahkemede müvekkili için güçlü bir savunma sundu.",
        list: 'B2',
        answer: 'savunma',
        quest: 'defence'),
    Words4(
        front: "He bravely defended his country during wartime.",
        back: "Savaş sırasında ülkesini cesurca savundu.",
        list: 'B2',
        answer: 'savunmak',
        quest: 'defend'),
    Words4(
        front: "The meeting was delayed due to unforeseen circumstances.",
        back: "Toplantı öngörülemeyen durumlar nedeniyle gecikmiştir.",
        list: 'B2',
        answer: 'gecikmek',
        quest: 'delay'),
    Words4(
        front:
            "The accident was not a deliberate act, it was a complete accident.",
        back: "Kaza kasti bir hareket değildi, tamamen bir kazaydı.",
        list: 'B2',
        answer: 'kasti',
        quest: 'deliberate'),
    Words4(
        front: "He deliberately avoided talking about the sensitive topic.",
        back: "Hassas konudan bahsetmekten kasıtlı olarak kaçındı.",
        list: 'B2',
        answer: 'kasten',
        quest: 'deliberately'),
    Words4(
        front:
            "The children were filled with delight when they saw the presents.",
        back: "Hediyeleri görünce çocuklar hazla doldu.",
        list: 'B2',
        answer: 'haz',
        quest: 'delight'),
    Words4(
        front: "She was delighted to hear that she got the job.",
        back: "İşi aldığını duyduğuna çok sevindi.",
        list: 'B2',
        answer: 'memnun',
        quest: 'delighted'),
    Words4(
        front: "The pizza delivery arrived hot and fresh.",
        back: "Pizza teslimatı sıcak ve taze olarak geldi.",
        list: 'B2',
        answer: 'teslim',
        quest: 'delivery'),
    Words4(
        front:
            "The workers demanded better working conditions from their employer.",
        back:
            "İşçiler işverenlerinden daha iyi çalışma koşulları talep ettiler.",
        list: 'B2',
        answer: 'talep etmek',
        quest: 'demand'),
    Words4(
        front:
            "The scientist was able to demonstrate the theory through a series of experiments.",
        back: "Bilim insanı, teoriyi bir dizi deneyle kanıtlayabildi.",
        list: 'B2',
        answer: 'ispat etmek',
        quest: 'demonstrate'),
    Words4(
        front: "He denied all the accusations against him.",
        back: "Yöneltilen tüm suçlamaları reddetti.",
        list: 'B2',
        answer: 'yalanlamak',
        quest: 'deny'),
    Words4(
        front: "She seemed depressed after losing her job.",
        back: "İşini kaybettikten sonra moralı bozuk görünüyordu.",
        list: 'B2',
        answer: 'canı sıkkın',
        quest: 'depressed'),
    Words4(
        front: "The weather was gloomy and depressing all week.",
        back: "Hafta boyunca hava kasvetli ve bunaltıcıydı.",
        list: 'B2',
        answer: 'bunaltıcı',
        quest: 'depressing'),
    Words4(
        front:
            "The scientist was studying the ocean's depth to learn more about marine life.",
        back:
            "Bilim insanı, deniz yaşamı hakkında daha fazla bilgi edinmek için okyanusun derinliğini araştırıyordu.",
        list: 'B2',
        answer: 'derinlik',
        quest: 'depth'),
    Words4(
        front:
            "After weeks of searching, the lost hikers were finally found alive in the desert.",
        back:
            "Haftalarca süren aramadan sonra kayıp gezginler sonunda çölde sağ olarak bulundu.",
        list: 'B2',
        answer: 'terk etmek', // 'çöl' means 'desert'
        quest: 'desert'),
    Words4(
        front: "He worked hard and deserves to be successful.",
        back: "Çok çalıştı ve başarılı olmayı hak ediyor.",
        list: 'B2',
        answer: 'hak etmek',
        quest: 'deserve'),
    Words4(
        front: "She has a strong desire to travel the world.",
        back: "Dünyayı gezme arzusu var.",
        list: 'B2',
        answer: 'arzulamak',
        quest: 'desire'),
    Words4(
        front: "The lost child was crying out of desperate-ion.",
        back: "Kayıp çocuk çaresizlikten ağlıyordu.",
        list: 'B2',
        answer: 'çaresiz',
        quest: 'desperate'),
    Words4(
        front: "He paid close attention to every detail when fixing the watch.",
        back: "Saati tamir ederken her detaya dikkat etti.",
        list: 'B2',
        answer: 'detay',
        quest: 'detail'),
    Words4(
        front: "The teacher provided a detailed explanation of the concept.",
        back: "Öğretmen, kavram hakkında ayrıntılı bir açıklama yaptı.",
        list: 'B2',
        answer: 'ayrıntılı',
        quest: 'detailed'),
    Words4(
        front: "The smoke detector was able to detect the fire early on.",
        back: "Duman detektörü yangını erken aşamada algılayabildi.",
        list: 'B2',
        answer: 'keşfetmek',
        quest: 'detect'),
    Words4(
        front:
            "The archaeologists are digging for ancient artifacts in the ruins.",
        back: "Arkeologlar kalıntılarda tarihi eserleri kazıyor.",
        list: 'B2',
        answer: 'kazmak',
        quest: 'dig'),
    Words4(
        front:
            "Self-discipline is an important quality for achieving your goals.",
        back: "Disiplin, hedeflerinize ulaşmak için önemli bir özelliktir.",
        list: 'B2',
        answer: 'disiplin',
        quest: 'discipline'),
    Words4(
        front: "She got a discount on her purchase because it was on sale.",
        back: "İndirimde olduğu için satın aldığı üründe indirim aldı.",
        list: 'B2',
        answer: 'indirim',
        quest: 'discount'),
    Words4(
        front:
            "He was caught cheating on the exam, so he received a failing grade for dishonesty.",
        back:
            "Sınavda kopya çekerken yakalandı, bu nedenle şerefsizlikten dolayı sınıfta kaldı.",
        list: 'B2',
        answer: 'şerefsiz',
        quest: 'dishonest'),
    Words4(
        front: "The manager dismissed the employee for poor performance.",
        back: "Yönetici, performansı düşük olduğu için çalışanı işten çıkardı.",
        list: 'B2',
        answer: 'kovmak',
        quest: 'dismiss'),
    Words4(
        front: "The artist displayed his paintings in a local gallery.",
        back: "Sanatçı, tablolarını yerel bir galeride sergiledi.",
        list: 'B2',
        answer: 'sergilemek',
        quest: 'display'),
    Words4(
        front:
            "The company is responsible for distributing flyers in the neighborhood.",
        back: "Şirket, mahallede broşür dağıtmaktan sorumludur.",
        list: 'B2',
        answer: 'dağıtmak',
        quest: 'distribute'),
    Words4(
        front:
            "The effective distribution of resources is crucial for a successful project.",
        back:
            "Başarılı bir proje için kaynakların etkili bir şekilde dağıtılması çok önemlidir.",
        list: 'B2',
        answer: 'dağıtma',
        quest: 'distribution'),
    Words4(
        front: "They live in a quiet district on the outskirts of the city.",
        back: "Şehrin dışında sakin bir semtte yaşıyorlar.",
        list: 'B2',
        answer: 'semt',
        quest: 'district'),
    Words4(
        front: "The teacher divided the students into groups for the project.",
        back: "Öğretmen, öğrencileri proje için gruplara ayırdı.",
        list: 'B2',
        answer: 'bölmek', // 'dağıtmak' can also be used here
        quest: 'divide'),
    Words4(
        front:
            "The marketing department is responsible for the product's division into different markets.",
        back:
            "Pazarlama departmanı, ürünün farklı pazarlara bölünmesinden sorumludur.",
        list: 'B2',
        answer: 'sınır',
        quest: 'division'),
    Words4(
        front: "He has a pet cat, so it's a domestic animal.",
        back: "Evcil bir hayvan olan kedisi var.",
        list: 'B2',
        answer: 'evcil',
        quest: 'domestic'),
    Words4(
        front:
            "The Roman Empire dominated a large part of Europe for centuries.",
        back:
            "Roma İmparatorluğu yüzyıllar boyunca Avrupa'nın büyük bir bölümüne hükmetti.",
        list: 'B2',
        answer: 'hükmetmek',
        quest: 'dominate'),
    Words4(
        front: "The arrow flew downwards after it was shot from the bow.",
        back: "Ok, yaydan atıldıktan sonra aşağıya doğru uçtu.",
        list: 'B2',
        answer: 'aşağıya doğru',
        quest: 'downwards'),
    Words4(
        front: "He bought a dozen eggs from the grocery store.",
        back: "Marketten bir düzine yumurta aldı.",
        list: 'B2',
        answer: 'çok sayıda', // 'düzine' means 'dozen'
        quest: 'dozen'),
    Words4(
        front: "They are working on the final draft of the contract.",
        back: "Sözleşmenin son taslağı üzerinde çalışıyorlar.",
        list: 'B2',
        answer: 'tasarı',
        quest: 'draft'),
    Words4(
        front: "He dragged the heavy suitcase across the floor.",
        back: "Ağır valizi yer boyunca sürükledi.",
        list: 'B2',
        answer: 'sürüklemek',
        quest: 'drag'),
    Words4(
        front: "I need to edit this document before submitting it.",
        back: "Bu belgeyi göndermeden önce düzenlemem gerekiyor.",
        list: 'B2',
        answer: 'düzenlemek',
        quest: 'edit'),
    Words4(
        front: "This is the latest edition of the English dictionary.",
        back: "Bu, İngilizce sözlüğün en son baskısıdır.",
        list: 'B2',
        answer: 'yayım',
        quest: 'edition'),
    Words4(
        front:
            "She is a very efficient worker who always gets her tasks done quickly.",
        back:
            "Çok verimli bir çalışandır ve her zaman görevlerini hızlı bir şekilde tamamlar.",
        list: 'B2',
        answer: 'etkili',
        quest: 'efficient'),
    Words4(
        front:
            "There are many programs available to help the elderly live independently.",
        back:
            "Yaşlıların bağımsız yaşam sürmelerine yardımcı olmak için birçok program mevcuttur.",
        list: 'B2',
        answer: 'yaşlı',
        quest: 'elderly'),
    Words4(
        front: "The people will elect a new president next month.",
        back: "Halk önümüzdeki ay yeni bir cumhurbaşkanı seçecek.",
        list: 'B2',
        answer: 'seçmek',
        quest: 'elect'),
    Words4(
        front:
            "I'm going to be elsewhere on Saturday, so I can't make it to the party.",
        back:
            "Cumartesi günü başka bir yerde olacağım, bu yüzden partiye gelemeyeceğim.",
        list: 'B2',
        answer: 'başka yerde',
        quest: 'elsewhere'),
    Words4(
        front: "A new leader emerged after the old one retired.",
        back: "Eski lider emekli olduktan sonra yeni bir lider ortaya çıktı.",
        list: 'B2',
        answer: 'yücelmek',
        quest: 'emerge'),
    Words4(
        front: "The movie was a very emotional story about love and loss.",
        back: "Film, aşk ve kayıp üzerine çok duygusal bir hikayeydi.",
        list: 'B2',
        answer: 'duygusal',
        quest: 'emotional'),
    Words4(
        front: "He placed a strong emphasis on the importance of education.",
        back: "Eğitimin önemine büyük vurgu yaptı.",
        list: 'B2',
        answer: 'vurgu',
        quest: 'emphasis'),
    Words4(
        front: "The teacher emphasized the key points of the lesson.",
        back: "Öğretmen, dersin kilit noktalarını vurguladı.",
        list: 'B2',
        answer: 'vurgulamak',
        quest: 'emphasize'),
    Words4(
        front:
            "Technology has enabled us to connect with people all over the world.",
        back:
            "Teknoloji, dünyanın her yerinden insanlarla bağlantı kurmamızı sağladı.",
        list: 'B2',
        answer: 'olanak vermek',
        quest: 'enable'),
    Words4(
        front: "They encountered many challenges during their journey.",
        back: "Yolculukları sırasında birçok zorlukla karşılaştılar.",
        list: 'B2',
        answer: 'rastlamak',
        quest: 'encounter'),
    Words4(
        front:
            "The students were engaged in a lively discussion about the book.",
        back: "Öğrenciler kitap hakkında canlı bir tartışmaya girdiler.",
        list: 'B2',
        answer: 'bağlanmak',
        quest: 'engage'),
    Words4(
        front:
            "The new technology has enhanced the efficiency of our production line.",
        back: "Yeni teknoloji, üretim hattımızın verimliliğini artırdı.",
        list: 'B2',
        answer: 'arttırmak',
        quest: 'enhance'),
    Words4(
        front: "The police made further enquiries about the crime.",
        back: "Polis, suç hakkında daha fazla sorgu yaptı.",
        list: 'B2',
        answer: 'sorgu',
        quest: 'enquiry'),
    Words4(
        front: "We need to ensure that everyone receives the same information.",
        back: "Herkesin aynı bilgiyi aldığından emin olmamız gerekir.",
        list: 'B2',
        answer: 'sağlamak',
        quest: 'ensure'),
    Words4(
        front: "The children were full of enthusiasm for the upcoming trip.",
        back: "Çocuklar yaklaşan gezi için hevesliydi.",
        list: 'B2',
        answer: 'heves',
        quest: 'enthusiasm'),
    Words4(
        front: "The teacher gave an enthusiastic presentation about the topic.",
        back: "Öğretmen, konu hakkında coşkulu bir sunum yaptı.",
        list: 'B2',
        answer: 'coşkulu',
        quest: 'enthusiastic'),
    Words4(
        front: "The entire team worked hard to complete the project on time.",
        back: "Tüm ekip, projeyi zamanında tamamlamak için çok çalıştı.",
        list: 'B2',
        answer: 'bütün',
        quest: 'entire'),
    Words4(
        front: "The building was entirely destroyed by the fire.",
        back: "Bina yangın nedeniyle tamamen yok oldu.",
        list: 'B2',
        answer: 'tümüyle',
        quest: 'entirely'),
    Words4(
        front: "All people are created equal and deserve equal rights.",
        back: "Tüm insanlar eşit yaratılmıştır ve eşit haklara sahiptir.",
        list: 'B2',
        answer: 'eşit',
        quest: 'equal'),
    Words4(
        front:
            "The scientist was able to establish a link between the two phenomena.",
        back: "Bilim insanı, iki olay arasında bir bağlantı kurabildi.",
        list: 'B2',
        answer: 'kanıtlamak',
        quest: 'establish'),
    Words4(
        front: "He inherited a large estate from his wealthy uncle.",
        back: "Zengin amcasından büyük bir emlak miras kaldı.",
        list: 'B2',
        answer: 'emlak',
        quest: 'estate'),
    Words4(
        front: "The mechanic was able to estimate the cost of the repairs.",
        back: "Tamirci, onarım maliyetini tahmin edebildi.",
        list: 'B2',
        answer: 'tahmin etmek',
        quest: 'estimate'),
    Words4(
        front: "It is important to act in an ethical manner in all situations.",
        back: "Her durumda etik davranmak önemlidir.",
        list: 'B2',
        answer: 'ahlaki',
        quest: 'ethical'),
    Words4(
        front:
            "The teacher will evaluate the students' progress on the next exam.",
        back:
            "Öğretmen, öğrencilerin gelişimini bir sonraki sınavda değerlendirecek.",
        list: 'B2',
        answer: 'değerlendirmek',
        quest: 'evaluate'),
    Words4(
        front: "The floor was not even, so it was difficult to walk on.",
        back: "Zemin düzgün değildi, bu nedenle yürümek zordu.",
        list: 'B2',
        answer: 'düzgün',
        quest: 'even'),
    Words4(
        front: "The villain in the story represented pure evil.",
        back: "Hikayedeki kötü adam saf kötülüğü temsil ediyordu.",
        list: 'B2',
        answer: 'kötülük',
        quest: 'evil'),
    Words4(
        front:
            "The doctor performed a thorough examination before making a diagnosis.",
        back: "Doktor, teşhis koymadan önce kapsamlı bir inceleme yaptı.",
        list: 'B2',
        answer: 'inceleme',
        quest: 'examination'),
    Words4(
        front: "I don't need an excuse, I was simply late.",
        back: "Mazerete ihtiyacım yok, sadece geç kaldım.",
        list: 'B2',
        answer: 'mazeret',
        quest: 'excuse'),
    Words4(
        front:
            "The company is looking for a new executive to lead the marketing department.",
        back:
            "Şirket, pazarlama departmanına liderlik edecek yeni bir yönetici arıyor.",
        list: 'B2',
        answer: 'yönetici',
        quest: 'executive'),
    Words4(
        front: "The existence of life on other planets is still a mystery.",
        back: "Diğer gezegenlerde yaşamın varlığı hala bir gizemdir.",
        list: 'B2',
        answer: 'varlık',
        quest: 'existence'),
    Words4(
        front: "We all have high expectations for the upcoming project.",
        back: "Hepimizin yaklaşan proje için yüksek beklentileri var.",
        list: 'B2',
        answer: 'beklenti',
        quest: 'expectation'),
    Words4(
        front:
            "Traveling to other countries can be a very expense-ive experience.",
        back: "Diğer ülkelere seyahat etmek çok masraflı bir deneyim olabilir.",
        list: 'B2',
        answer: 'harcama',
        quest: 'expense'),
    Words4(
        front:
            "The exploration of space has been a human endeavor for centuries.",
        back: "Uzay keşfi, yüzyıllardır insanoğlunun bir çabası olmuştur.",
        list: 'B2',
        answer: 'keşif',
        quest: 'exploration'),
    Words4(
        front: "Children are often exposed to too much screen time these days.",
        back:
            "Çocuklar günümüzde genellikle aşırı ekran süresine maruz kalıyor.",
        list: 'B2',
        answer: 'maruz bırakmak',
        quest: 'expose'),
    Words4(
        front:
            "The company is planning to extend its operations to new markets.",
        back: "Şirket, faaliyetlerini yeni pazarlara genişletmeyi planlıyor.",
        list: 'B2',
        answer: 'genişletmek',
        quest: 'extend'),
    Words4(
        front:
            "The full extent of the damage caused by the hurricane is still unknown.",
        back: "Kasırganın yol açtığı hasarın tam boyutu henüz bilinmiyor.",
        list: 'B2',
        answer: 'boyut',
        quest: 'extent'),
    Words4(
        front: "He received external help to complete the difficult task.",
        back: "Zor görevi tamamlamak için dışarıdan yardım aldı.",
        list: 'B2',
        answer: 'dış',
        quest: 'external'),
    Words4(
        front: "She has extraordinary abilities that no one else possesses.",
        back: "Kimsenin sahip olmadığı olağanüstü yetenekleri var.",
        list: 'B2',
        answer: 'olağanüstü',
        quest: 'extraordinary'),
    Words4(
        front:
            "The weather conditions were extreme, with high winds and heavy rain.",
        back:
            "Hava koşulları aşırıydı, şiddetli rüzgar ve şiddetli yağmur vardı.",
        list: 'B2',
        answer: 'aşırı',
        quest: 'extreme'),
    Words4(
        front:
            "The school has excellent facility-ies, including a library, a gym, and a swimming pool.",
        back:
            "Okulun kütüphane, spor salonu ve yüzme havuzu gibi mükemmel tesisleri vardır.",
        list: 'B2',
        answer: 'tesis',
        quest: 'facility'),
    Words4(
        front: "The project failed to meet its objectives.",
        back:
            "Proje hedeflerine ulaşamadı (yapmama = negation of yapmak - to do)",
        list: 'B2',
        answer: 'yapmama',
        quest: 'failure'),
    Words4(
        front: "I have faith in your ability to succeed.",
        back: "Başarın yeteneğine güvenim var.",
        list: 'B2',
        answer: 'güven',
        quest: 'faith'),
    Words4(
        front: "It was not my fault that the machine broke.",
        back:
            " makinenin bozulması benim hatam değildi.", // 'fayda' means 'benefit'
        list: 'B2',
        answer: 'hata',
        quest: 'fault'),
    Words4(
        front: "Would you like me to do you a favour and help you with that?",
        back: "Size iyilik etmek ve size bunda yardım etmek ister misiniz?",
        list: 'B2',
        answer: 'iyilik etmek',
        quest: 'favour'),
    Words4(
        front: "The bird used its feathers to build its nest.",
        back: "Kuş, yuvasını yapmak için tüylerini kullandı.",
        list: 'B2',
        answer: 'tüy',
        quest: 'feather'),
    Words4(
        front: "How much is the fee for this course?",
        back: "Bu kursun ücreti ne kadar?",
        list: 'B2',
        answer: 'harç',
        quest: 'fee'),
    Words4(
        front: "The cat is hungry, it needs to be feed.",
        back: " kedi aç, beslenmesi gerekiyor.",
        list: 'B2',
        answer: 'beslemek',
        quest: 'feed'),
    Words4(
        front: "We appreciate your feedback on our new product.",
        back:
            "Yeni ürünümüz hakkındaki geri bildiriminizi appreciate ediyoruz.",
        list: 'B2',
        answer: 'geri bildirim',
        quest: 'feedback'),
    Words4(
        front: "I can feel the sun on my skin.",
        back: "Güneşi tenimde hissedebiliyorum.",
        list: 'B2',
        answer: 'hissetmek',
        quest: 'feel'),
    Words4(
        front: "He is a great fellow and a true friend.",
        back: "O harika bir arkadaş ve gerçek bir dost.",
        list: 'B2',
        answer: 'hemcins',
        quest: 'fellow'),
    Words4(
        front: "The sales figures for this month are very promising.",
        back: "Bu ayın satış rakamları çok umut verici.",
        list: 'B2',
        answer:
            'rakam, şekil', // ' şekil' can also mean 'shape' in this context
        quest: 'figure'),
    Words4(
        front: "Please save the document as a new file.",
        back: "Lütfen belgeyi yeni bir dosya olarak kaydedin.",
        list: 'B2',
        answer: 'dosya',
        quest: 'file'),
    Words4(
        front:
            "She is a finance-ial advisor who can help you manage your money.",
        back:
            "O, paranızı yönetmenize yardımcı olabilecek bir finans danışmanıdır.",
        list: 'B2',
        answer: 'finans',
        quest: 'finance'),
    Words4(
        front:
            "We are still finding it difficult to find a solution to the problem.",
        back: "Probleme hala bir çözüm bulmakta zorlanıyoruz.",
        list: 'B2',
        answer: 'bulma',
        quest: 'finding'),
    Words4(
        front: "He has a firm belief in his ability to succeed.",
        back:
            "Başaracağına dair sağlam bir inancı var.", // 'firm' can also mean ' sıkı' (tight)
        list: 'B2',
        answer: 'firma, sıkı',
        quest: 'firm'),
    Words4(
        front: "The mechanic was able to fix the car engine.",
        back: "Tamirci, araba motorunu düzeltmeyi başardı.",
        list: 'B2',
        answer: 'düzeltmek',
        quest: 'fix'),
    Words4(
        front:
            "The firefighter bravely rushed into the burning building to save the people trapped inside.",
        back:
            "İtfaiyeci, içeride mahsur kalan insanları kurtarmak için alevlerin içine cesurca koştu.",
        list: 'B2',
        answer: 'alev',
        quest: 'flame'),
    Words4(
        front: "The photographer captured a flash of lightning in his photo.",
        back: "Fotoğrafçı, fotoğrafında bir şimşek flaşı yakaladı.",
        list: 'B2',
        answer: 'ışık tutmak',
        quest: 'flash'),
    Words4(
        front:
            "Employers are looking for employees who are flexible and adaptable.",
        back: "İşverenler, esnek ve uyumlu çalışanlar arıyor.",
        list: 'B2',
        answer: 'esnek',
        quest: 'flexible'),
    Words4(
        front: "The child was happily floating in the pool.",
        back: "Çocuk havuzda mutlu bir şekilde yüzüyordu.",
        list: 'B2',
        answer: 'batmadan yüzmek',
        quest: 'float'),
    Words4(
        front: "She carefully folded the piece of paper in half.",
        back: "Kâğıt parçasını dikkatlice ikiye katladı.",
        list: 'B2',
        answer: 'katlamak',
        quest: 'fold'),
    Words4(
        front:
            "The art of origami involves creating complex shapes by folding paper.",
        back:
            "Origami sanatı, kağıdı katlayarak karmaşık şekiller oluşturmayı içerir.",
        list: 'B2',
        answer: 'kıvrım',
        quest: 'folding'),
    Words4(
        front:
            "We are following the latest developments in technology closely.",
        back: "Teknolojideki son gelişmeleri yakından takip ediyoruz.",
        list: 'B2',
        answer: 'takip etme',
        quest: 'following'),
    Words4(
        front: "I hope you can forgive me for my mistake.",
        back: "Umarım beni hatam için affedersin.",
        list: 'B2',
        answer: 'affetmek',
        quest: 'forgive'),
    Words4(
        front: "He is a former athlete who is now a successful coach.",
        back: "O, şu anda başarılı bir antrenör olan eski bir atlet.",
        list: 'B2',
        answer: 'önceki',
        quest: 'former'),
    Words4(
        front:
            "They hope that their hard work will lead to better fortune in the future.",
        back:
            "Gelecekte daha iyi bir talihinin zorlu çalışmalarının sonucunda olacağını umuyorlar.",
        list: 'B2',
        answer: 'talih',
        quest: 'fortune'),
    Words4(
        front:
            "We need to look forward to the future and not dwell on the past.",
        back: "Geleceğe bakmalı ve geçmişte yaşamamalıyız.",
        list: 'B2',
        answer: 'ileri',
        quest: 'forward'),
    Words4(
        front: "The company was founded in 1980 by two brothers.",
        back: "Şirket, 1980 yılında iki kardeş tarafından kuruldu.",
        list: 'B2',
        answer: 'kurmak',
        quest: 'found'),
    Words4(
        front: "Education should be free and accessible to everyone.",
        back: "Eğitim herkes için ücretsiz ve erişilebilir olmalıdır.",
        list: 'B2',
        answer: 'bağımsız, beleş',
        quest: 'free'),
    Words4(
        front: "Freedom of speech is a fundamental human right.",
        back: "Konuşma özgürlüğü temel bir insan hakkıdır.",
        list: 'B2',
        answer: 'özgürlük',
        quest: 'freedom'),
    Words4(
        front: "The frequency of the radio waves is too high for me to hear.",
        back: "Radyo dalgalarının frekansı duymam için çok yüksek.",
        list: 'B2',
        answer: 'sıklık',
        quest: 'frequency'),
    Words4(
        front: "The car needs more fuel before it can continue the journey.",
        back:
            "Araba yolculuğa devam edebilmesi için daha fazla yakıta ihtiyacı var.",
        list: 'B2',
        answer: 'yakıt',
        quest: 'fuel'),
    Words4(
        front: "He was fully committed to completing the task.",
        back: "Görevi tamamlamaya tamamen kararlıydı.",
        list: 'B2',
        answer: 'tamamıyla',
        quest: 'fully'),
    Words4(
        front: "The function of this button is to turn on the device.",
        back: "Bu düğmenin işlevi cihazı açmaktır.",
        list: 'B2',
        answer: 'işlev',
        quest: 'function'),
    Words4(
        front:
            "The government will provide funds to support the research project.",
        back:
            "Hükümet, araştırma projesini desteklemek için kaynak sağlayacaktır.",
        list: 'B2',
        answer: 'kaynak',
        quest: 'fund'),
    Words4(
        front: "A strong work ethic is a fundamental principle for success.",
        back: "Güçlü bir çalışma etiği, başarı için temel bir prensiptir.",
        list: 'B2',
        answer: 'esas',
        quest: 'fundamental'),
    Words4(
        front: "The company is seeking funding to expand its operations.",
        back: "Şirket, operasyonlarını genişletmek için fonlama arıyor.",
        list: 'B2',
        answer: 'fonlama',
        quest: 'funding'),
    Words4(
        front:
            "Furthermore, the research also identified some potential risks.",
        back:
            "Üstelik, araştırma aynı zamanda bazı potansiyel riskleri de ortaya çıkardı.",
        list: 'B2',
        answer: 'üstelik',
        quest: 'Furthermore'),
    Words4(
        front:
            "He has gained a lot of experience from working in different countries.",
        back: "Farklı ülkelerde çalışmaktan çok fazla tecrübe kazandı.",
        list: 'B2',
        answer: 'kazanmak',
        quest: 'gain'),
    Words4(
        front:
            "The neighborhood is known for its high crime rates, with gangs operating in the area.",
        back:
            "Mahalle, bölgede faaliyet gösteren çetelere sahip olması nedeniyle yüksek suç oranlarıyla bilinir.",
        list: 'B2',
        answer: 'çete',
        quest: 'gang'),
    Words4(
        front: "Solar panels generate electricity from sunlight.",
        back: "Güneş panelleri güneş ışığından elektrik üretir.",
        list: 'B2',
        answer: 'meydana getirmek',
        quest: 'generate'),
    Words4(
        front: "Science fiction is my favorite genre of book.",
        back: "Bilim kurgu, en sevdiğim kitap türüdür.",
        list: 'B2',
        answer: 'tür',
        quest: 'genre'),
    Words4(
        front: "The constitution is the document that governs a country.",
        back: "Anayasa, bir ülkeyi yöneten belgedir.",
        list: 'B2',
        answer: 'govern',
        quest: 'govern'),
    Words4(
        front: "He grabbed the microphone and started to speak.",
        back: "Mikrofonu kaptı ve konuşmaya başladı.",
        list: 'B2',
        answer: 'kapmak',
        quest: 'grab'),
    Words4(
        front: "The teacher will grade the essays next week.",
        back: "Öğretmen, denemeleri budú hafta puanlayacak.",
        list: 'B2',
        answer: 'puanlamak',
        quest: 'grade'),
    Words4(
        front: "The patient's condition gradually improved over time.",
        back: "Hastanın durumu zamanla yavaş yavaş düzeldi.",
        list: 'B2',
        answer: 'yavaş yavaş',
        quest: 'gradually'),
    Words4(
        front: "They built a grand castle on top of the hill.",
        back: "Tepede görkemli bir kale inşa ettiler.",
        list: 'B2',
        answer: 'büyük',
        quest: 'grand'),
    Words4(
        front:
            "The government decided to grant tax breaks to businesses in order to stimulate the economy.",
        back:
            "Hükümet, ekonomiyi canlandırmak için işletmelere vergi indirimi yapmaya karar verdi.",
        list: 'B2',
        answer: 'bağışlamak',
        quest: 'grant'),
    Words4(
        front: "There is no guarantee that the plan will be successful.",
        back: "Planın başarılı olacağının garantisi yoktur.",
        list: 'B2',
        answer: 'garanti',
        quest: 'guarantee'),
    Words4(
        front:
            "She is a capable manager who can handle difficult situations effectively.",
        back:
            "O, zor durumları etkili bir şekilde idare edebilen yetenekli bir yönetici.",
        list: 'B2',
        answer: 'idare etmek',
        quest: 'handle'),
    Words4(
        front: "Smoking can cause serious harm to your health.",
        back: "Sigara içmek sağlığınıza ciddi zarar verebilir.",
        list: 'B2',
        answer: 'zarar',
        quest: 'harm'),
    Words4(
        front:
            "Fast food is often high in calories and unhealthy fats, making it harmful for your diet.",
        back:
            "Fast food genellikle kalori ve sağlıksız yağlar açısından yüksektir, bu da onu diyetiniz için zararlı hale getirir.",
        list: 'B2',
        answer: 'zararlı',
        quest: 'harmful'),
    Words4(
        front: "The next court hearing in the case will be held on Monday.",
        back: "Davada bir sonraki duruşma Pazartesi günü görülecektir.",
        list: 'B2',
        answer: 'duruşma',
        quest: 'hearing'),
    Words4(
        front:
            "Many religions believe in heaven as a place of eternal peace and happiness.",
        back:
            "Pek çok din, cenneti sonsuz huzur ve mutluluk yeri olarak görür.",
        list: 'B2',
        answer: 'cennet',
        quest: 'heaven'),
    Words4(
        front: "She broke her heel while walking down the stairs.",
        back: "Merdivenden inerken topuğunu kırdı.",
        list: 'B2',
        answer: 'topuk',
        quest: 'heel'),
    Words4(
        front:
            "Hell is often depicted as a place of fire and suffering in religious traditions.",
        back:
            "Cehennem, dini geleneklerde genellikle ateş ve ıstırap yeri olarak tasvir edilir.",
        list: 'B2',
        answer: 'Cehennem',
        quest: 'Hell'),
    Words4(
        front: "Don't hesitate to ask for help if you need it.",
        back: "İhtiyacınız olursa yardım istemekten çekinmeyin.",
        list: 'B2',
        answer: 'duraksamak',
        quest: 'hesitate'),
    Words4(
        front:
            "The mountain has a very high peak that is often covered in snow.",
        back: "Dağın genellikle karla kaplı çok yüksek bir zirvesi vardır.",
        list: 'B2',
        answer: 'yüksek',
        quest: 'high'),
    Words4(
        front:
            "The company is looking to hire new employees with experience in marketing.",
        back: "Şirket, pazarlama alanında deneyimli yeni çalışanlar arıyor.",
        list: 'B2',
        answer: 'kiralamak',
        quest: 'hire'),
    Words4(
        front: "He still holds a grudge against his former friend.",
        back: "Hala eski arkadaşına karşı kin besliyor.",
        list: 'B2',
        answer: 'sahip olmak',
        quest: 'hold'),
    Words4(
        front:
            "The tree has a large, hollow trunk that can be used as a hiding place for small animals.",
        back:
            "Ağacın, küçük hayvanlar için saklanma yeri olarak kullanılabilecek büyük, içi boş bir gövdesi vardır.",
        list: 'B2',
        answer: 'çukur',
        quest: 'hollow'),
    Words4(
        front: "The city of Mecca is a holy place for Muslims.",
        back: "Mekke şehri, Müslümanlar için kutsal bir yerdir.",
        list: 'B2',
        answer: 'kutsal',
        quest: 'holy'),
    Words4(
        front:
            "We will hold a ceremony to honour the achievements of our employees.",
        back:
            "Çalışanlarımızın başarılarını onurlandırmak için bir tören düzenleyeceğiz.",
        list: 'B2',
        answer: 'onurlandırmak',
        quest: 'honour'),
    Words4(
        front:
            "We are staying with a friend who is kindly acting as our host during our visit.",
        back:
            "Ziyaretimiz sırasında bize ev sahipliği yapan bir arkadaşımızın yanında kalıyoruz.",
        list: 'B2',
        answer: 'ev sahibi',
        quest: 'host'),
    Words4(
        front: "They are looking to buy a new house with a big garden.",
        back: "Büyük bahçeli yeni bir ev satın almak istiyorlar.",
        list: 'B2',
        answer: 'ev',
        quest: 'house'),
    Words4(
        front:
            "These are all household items that you will need for your new apartment.",
        back:
            "Bunlar, yeni daireniz için ihtiyacınız olacak günlük kullanılan eşyalar.",
        list: 'B2',
        answer: 'her gün kullanılan',
        quest: 'household'),
    Words4(
        front:
            "The government is investing in new housing projects to provide affordable homes for everyone.",
        back:
            "Hükümet, herkese uygun fiyatlı konutlar sağlamak için yeni konut projelerine yatırım yapıyor.",
        list: 'B2',
        answer: 'konut',
        quest: 'housing'),
    Words4(
        front:
            "He is known for his humorous personality and his ability to make people laugh.",
        back:
            "Mizah yeteneği ve insanları güldürme yeteneği ile tanınır.", // 'gülünç' can also mean 'funny' or 'ridiculous'
        list: 'B2',
        answer: 'gülünç',
        quest: 'humorous'),
    Words4(
        front: "The movie was full of slapstick humor.",
        back: "Film, slapstick mizahla doluydu.",
        list: 'B2',
        answer: 'mizah',
        quest: 'humour'),
    Words4(
        front: "The lions are hunting for zebras on the African savanna.",
        back: "Aslanlar, Afrika savanında zebraları avlıyor.",
        list: 'B2',
        answer: 'avlanmak',
        quest: 'hunt'),
    Words4(
        front: "Hunting is a controversial issue in many countries.",
        back: "Avlanma, birçok ülkede tartışmalı bir konudur.",
        list: 'B2',
        answer: 'avlama',
        quest: 'Hunting'),
    Words4(
        front: "She accidentally hurt her ankle while playing basketball.",
        back: "Basketbol oynarken yanlışlıkla bileğini acıttı.",
        list: 'B2',
        answer: 'acımak, yaralamak',
        quest: 'hurt'),
    Words4(
        front:
            "The book is full of illustrations that help to illustrate the story.",
        back: "Kitap, hikayeyi örneklemeye yardımcı olan resimlerle dolu.",
        list: 'B2',
        answer: 'örneklemek',
        quest: 'illustrate'),
    Words4(
        front:
            "The children used their imagination to create a magical world in their backyard.",
        back:
            "Çocuklar, arka bahçelerinde büyülü bir dünya yaratmak için hayal güçlerini kullandılar.",
        list: 'B2',
        answer: 'örnekleme',
        quest:
            'illustration' // 'örnekleme' can also be used for illustration, but 'tasvir' might be a more fitting choice here
        ),
    Words4(
        front:
            "With a little imagination, you can turn this old box into something useful.",
        back:
            "Biraz hayal gücüyle, bu eski kutuyu kullanışlı bir şeye dönüştürebilirsiniz.",
        list: 'B2',
        answer: 'hayal gücü',
        quest: 'imagination'),
    Words4(
        front: "He can be a bit impatient sometimes, but he always means well.",
        back: "Bazen biraz sabırsız olabilir, ama her zaman iyiyi ister.",
        list: 'B2',
        answer: 'sabırsız',
        quest: 'impatient'),
    Words4(
        front: "Her comment implied that she was not happy with the situation.",
        back: "Her yorumu, durumdan memnun olmadığını ima ediyordu.",
        list: 'B2',
        answer: 'kastetmek',
        quest: 'imply'),
    Words4(
        front:
            "The government imposed new restrictions on travel in order to slow the spread of the virus.",
        back:
            "Hükümet, virüsün yayılmasını yavaşlatmak için seyahatlere yeni kısıtlamalar getirdi.",
        list: 'B2',
        answer: 'uygulamaya koymak',
        quest: 'impose'),
    Words4(
        front: "She impressed everyone with her talent and dedication.",
        back: " yeteneği ve kararlılığıyla herkesi etkiledi.",
        list: 'B2',
        answer: 'etkilemek',
        quest: 'impress'),
    Words4(
        front:
            "I was very impressed by the historical sites we visited in Rome.",
        back: "Roma'da ziyaret ettiğimiz tarihi yerlerden çok etkilendim.",
        list: 'B2',
        answer: 'etkilenmiş',
        quest: 'impressed'),
    Words4(
        front: "The snail inched slowly across the garden path.",
        back: "Salıncak, bahçe yolunda yavaş yavaş hareket etti.",
        list: 'B2',
        answer: 'yavaş yavaş hareket etmek',
        quest: 'inch'),
    Words4(
        front:
            "The police are investigating a recent incident at the local bank.",
        back: "Polis, yerel bankadaki son olayı araştırıyor.",
        list: 'B2',
        answer: 'hadise',
        quest: 'incident'),
    Words4(
        front:
            "His income has increased significantly since he started his new job.",
        back: "Yeni işine başladıktan sonra geliri önemli ölçüde arttı.",
        list: 'B2',
        answer: 'gelir, kazanç',
        quest: 'income'),
    Words4(
        front:
            "People are becoming increasingly concerned about the environment.",
        back: "İnsanlar çevre konusunda giderek daha fazla endişeleniyor.",
        list: 'B2',
        answer: 'gitgide',
        quest: 'increasingly'),
    Words4(
        front: "The city has a large industrial zone on the outskirts.",
        back: "Şehrin kenar mahallelerinde büyük bir endüstriyel bölgesi var.",
        list: 'B2',
        answer: 'endüstriyel',
        quest: 'industrial'),
    Words4(
        front:
            "Taking antibiotics for a long period of time can increase the risk of infection.",
        back:
            "Uzun süre antibiyotik kullanmak, enfeksiyon riskini artırabilir.",
        list: 'B2',
        answer: 'enfeksiyon',
        quest: 'infection'),
    Words4(
        front:
            "It is important to inform the public about the latest developments.",
        back: "Kamuoyunu son gelişmeler hakkında bilgilendirmek önemlidir.",
        list: 'B2',
        answer: 'bilgilendirmek',
        quest: 'inform'),
    Words4(
        front: "What are your initials?",
        back: "Baş harfiniz nedir?",
        list: 'B2',
        answer: 'baş harf',
        quest: 'initial'),
    Words4(
        front:
            "Initially, he was hesitant about the project, but eventually he came around.",
        back:
            "Başlangıçta projeye karşı tereddütlüydü, ancak sonunda ikna oldu.",
        list: 'B2',
        answer: 'başlangıçta',
        quest: 'initially'),
    Words4(
        front:
            "She took the initiative to organize a fundraiser for the local animal shelter.",
        back:
            "Yerel hayvan barınağı için bir bağış etkinliği düzenlemek için girişimde bulundu.",
        list: 'B2',
        answer: 'girişim',
        quest: 'initiative'),
    Words4(
        front:
            "He has a very inner strength that helps him to overcome challenges.",
        back:
            "Zorlukların üstesinden gelmesine yardımcı olan çok derinlerde bir gücü var.",
        list: 'B2',
        answer: 'içerideki',
        quest: 'inner'),
    Words4(
        front:
            "The meditation helped me to gain a deeper insight into my own thoughts and feelings.",
        back:
            "Meditasyon, kendi düşüncelerim ve duygularım hakkında daha derin bir anlayış kazanmama yardımcı oldu.",
        list: 'B2',
        answer: 'anlayış',
        quest: 'insight'),
    Words4(
        front:
            "He insisted on finishing the project even though everyone else was tired.",
        back: "Herkes yorgun olmasına rağmen projeyi bitirmekte ısrar etti.",
        list: 'B2',
        answer: 'ısrar etmek',
        quest: 'insist'),
    Words4(
        front: "Her inspirational speech motivated the team to work harder.",
        back: "İlham verici konuşması, takımı daha çok çalışmaya motive etti.",
        list: 'B2',
        answer: 'ilham vermek',
        quest: 'inspire'),
    Words4(
        front: "We need to install a new security system in our house.",
        back: "Evimize yeni bir güvenlik sistemi kurmamız gerekiyor.",
        list: 'B2',
        answer: 'kurmak',
        quest: 'install'),
    Words4(
        front:
            "For instance, getting a good night's sleep is essential for maintaining good health.",
        back:
            "Örneğin, sağlıklı kalmak için iyi bir gece uykusu almak çok önemlidir.",
        list: 'B2',
        answer: 'örnek',
        quest: 'instance'),
    Words4(
        front:
            "The government is planning to institute a new tax on luxury goods.",
        back: "Hükümet, lüks mallara yeni bir vergi getirmeyi planlıyor.",
        list: 'B2',
        answer: 'kurmak',
        quest: 'institute'),
    Words4(
        front:
            "The United Nations is a highly respected international institution.",
        back: "Birleşmiş Milletler, uluslararası alanda saygın bir kurumdur.",
        list: 'B2',
        answer: 'enstitü',
        quest: 'institution'),
    Words4(
        front: "Do you have health insurance?",
        back: "Sağlık sigortanız var mı?",
        list: 'B2',
        answer: 'sigorta',
        quest: 'insurance'),
    Words4(
        front: "The meeting was not intended to be a formal event.",
        back: "Toplantı resmi bir etkinlik olması amaçlanmamıştı.",
        list: 'B2',
        answer: 'planlanan',
        quest: 'intended'),
    Words4(
        front:
            "She experienced a period of intense grief after her grandfather's death.",
        back: "Dedesinin ölümünden sonra yoğun bir keder dönemi yaşadı.",
        list: 'B2',
        answer: 'yoğun',
        quest: 'intense'),
    Words4(
        front: "The company is facing some internal challenges at the moment.",
        back: "Şirket şu anda bazı dahili zorluklarla karşı karşıya.",
        list: 'B2',
        answer: 'dahili',
        quest: 'internal'),
    Words4(
        front:
            "The artist's work is open to interpretation, and there is no one right answer.",
        back: "Sanatçının eseri yoruma açıktır ve tek bir doğru cevap yoktur.",
        list: 'B2',
        answer: 'yorumlamak',
        quest: 'interpret'),
    Words4(
        front: "Please don't interrupt me while I am speaking.",
        back: "Konuşurken lütfen sözümü kesmeyin.",
        list: 'B2',
        answer: 'söze karışmak',
        quest: 'interrupt'),
    Words4(
        front:
            "The police are conducting a thorough investigation into the crime.",
        back: "Polis, suç hakkında kapsamlı bir soruşturma yürütüyor.",
        list: 'B2',
        answer: 'soruşturma',
        quest: 'investigation'),
    Words4(
        front:
            "It's important to do your research before making any investments.",
        back:
            "Herhangi bir yatırım yapmadan önce araştırmanızı yapmak önemlidir.",
        list: 'B2',
        answer: 'yatırım',
        quest: 'investment'),
    Words4(
        front:
            "Climate change is a major issue that we need to address urgently.",
        back:
            "İklim değişikliği, acilen ele almamız gereken önemli bir konudur.",
        list: 'B2',
        answer: 'konu',
        quest: 'issue'),
    Words4(
        front: "Spending time with loved ones brings me a lot of joy.",
        back: "Sevdiklerimle vakit geçirmek bana çok keyif veriyor.",
        list: 'B2',
        answer: 'keyif',
        quest: 'joy'),
    Words4(
        front:
            "The judge reserved his judgement until he had heard all the evidence.",
        back: "Hakim, tüm delilleri dinleyene kadar kararını saklı tuttu.",
        list: 'B2',
        answer: 'yargı',
        quest: 'judgement'),
    Words4(
        front: "She is a junior member of the team, but she is very talented.",
        back: "Takımın genç üyelerinden biridir, ancak yeteneklidir.",
        list: 'B2',
        answer: 'yaşça veya makamca küçük olan',
        quest: 'junior'),
    Words4(
        front: "Justice should be served for the victims of the crime.",
        back: "Suç mağdurları için adalet sağlanmalıdır.",
        list: 'B2',
        answer: 'adalet',
        quest: 'justice'),
    Words4(
        front:
            "He can justify his actions by saying that he was only trying to help.",
        back:
            "Yalnızca yardım etmeye çalıştığını söyleyerek davranışlarını haklı çıkarabilir.",
        list: 'B2',
        answer: 'savunmak',
        quest: 'justify'),
    Words4(
        front: "Manual labour can be very physically demanding.",
        back: "Fiziksel işçilik çok yorucu olabilir.",
        list: 'B2',
        answer: 'uğraşmak',
        quest: 'labour'),
    Words4(
        front:
            "We enjoyed the beautiful landscape of the countryside during our road trip.",
        back:
            "Yol gezimiz sırasında kırsalın güzel manzarasının tadını çıkardık.",
        list: 'B2',
        answer: 'manzara',
        quest: 'landscape'),
    Words4(
        front:
            "The success of the project was largely due to the hard work and dedication of the team.",
        back:
            "Projenin başarısı büyük ölçüde ekibin sıkı çalışması ve özverisi sayesindeydi.",
        list: 'B2',
        answer: 'büyük ölçüde',
        quest: 'largely'),
    Words4(
        front: "Have you read the latest news about the election?",
        back: "Seçimle ilgili son haberleri okudunuz mu?",
        list: 'B2',
        answer: 'son',
        quest: 'latest'),
    Words4(
        front:
            "The company is planning to launch a new product line next year.",
        back:
            "Şirket, önümüzdeki yıl yeni bir ürün serisi piyasaya sürmeyi planlıyor.",
        list: 'B2',
        answer: 'başlatmak',
        quest: 'launch'),
    Words4(
        front:
            "Effective leadership is essential for the success of any organization.",
        back:
            "Etkin liderlik, herhangi bir kuruluşun başarısı için gereklidir.",
        list: 'B2',
        answer: 'liderlik',
        quest: 'leadership'),
    Words4(
        front: "Our team is currently in first place in the league.",
        back: "Takımımız şu anda ligde birinci sırada.",
        list: 'B2',
        answer: 'lig',
        quest: 'league'),
    Words4(
        front: "He leaned against the wall as he waited for his bus.",
        back: "Otobüsünü beklerken duvara yaslandı.",
        list: 'B2',
        answer: 'dayanmak',
        quest: 'lean'),
    Words4(
        front: "She decided to leave her job and travel the world.",
        back: "İşini bırakıp dünyayı gezmeye karar verdi.",
        list: 'B2',
        answer: 'ayrılmak',
        quest: 'leave'),
    Words4(
        front:
            "We need to improve our English to a higher level if we want to study abroad.",
        back:
            "Yurtdışında eğitim görmek istiyorsak İngilizcemizi daha üst bir seviyeye çıkarmamız gerekiyor.",
        list: 'B2',
        answer: 'seviye',
        quest: 'level'),
    Words4(
        front: "Do you need a driver's licence to rent a car?",
        back: "Araba kiralamak için ehliyete mi ihtiyacınız var?",
        list: 'B2',
        answer: 'lisans',
        quest: 'licence'),
    Words4(
        front: "Our resources are limited, so we need to use them wisely.",
        back:
            "Kaynaklarımız sınırlı, bu nedenle onları akıllıca kullanmamız gerekiyor.",
        list: 'B2',
        answer: 'kısıtlı',
        quest: 'limited'),
    Words4(
        front: "Please wait here for a moment, I'll be back in a few lines.",
        back: "Lütfen burada bir süre bekleyin, birkaç satıra geri döneceğim.",
        list: 'B2',
        answer: 'satır',
        quest: 'line'),
    Words4(
        front:
            "The city comes alive at night with all the bars and restaurants open.",
        back: "Şehir, tüm barlar ve restoranlar açıksa geceleri canlanır.",
        list: 'B2',
        answer: 'canlı',
        quest: 'lively'),
    Words4(
        front: "The truck driver carefully loaded the boxes onto the trailer.",
        back: "Kamyon şoförü kutuları dikkatlice treylere yükledi.",
        list: 'B2',
        answer: 'yüklemek',
        quest: 'load'),
    Words4(
        front: "He took out a loan from the bank to buy a new car.",
        back: "Yeni bir araba almak için bankadan kredi aldı.",
        list: 'B2',
        answer: 'ödünç para',
        quest: 'loan'),
    Words4(
        front: "It is not logical to expect to get rich quick.",
        back: "Çabuk zengin olmayı beklemek mantıklı değil.",
        list: 'B2',
        answer: 'mantıklı',
        quest: 'logical'),
    Words4(
        front: "We need to develop a long-term plan to achieve our goals.",
        back:
            "Hedeflerimize ulaşmak için uzun vadeli bir plan geliştirmemiz gerekiyor.",
        list: 'B2',
        answer: 'uzun dönem',
        quest: 'long-term'),
    Words4(
        front:
            "The button on my shirt is a bit loose, can you help me sew it tighter?",
        back:
            "Gömleğimdeki düğme biraz gevşek, daha sıkı dikmeme yardım edebilir misin?",
        list: 'B2',
        answer: 'gevşek',
        quest: 'loose'),
    Words4(
        front:
            "The economic crisis has led to a low standard of living for many people.",
        back: "Ekonomik kriz, birçok insanın yaşam standardını düşürdü.",
        list: 'B2',
        answer: 'düşük',
        quest: 'low'),
    Words4(
        front:
            "The government is trying to lower taxes to stimulate the economy.",
        back:
            "Hükümet, ekonomiyi canlandırmak için vergileri düşürmeye çalışıyor.",
        list: 'B2',
        answer: 'düşürmek',
        quest: 'lower'),
    Words4(
        front:
            "Smoking can damage your lungs and lead to serious health problems.",
        back:
            "Sigara içmek akciğerlerinize zarar verebilir ve ciddi sağlık sorunlarına yol açabilir.",
        list: 'B2',
        answer: 'akciğer',
        quest: 'lung'),
    Words4(
        front:
            "It is important to maintain a healthy lifestyle in order to stay healthy.",
        back:
            "Sağlıklı kalmak için sağlıklı bir yaşam tarzı sürdürmek önemlidir.",
        list: 'B2',
        answer: 'sürdürmek',
        quest: 'maintain'),
    Words4(
        front: "The majority of the population voted for the new president.",
        back: "Nüfusun çoğunluğu yeni cumhurbaşkanını seçti.",
        list: 'B2',
        answer: 'çoğunluk',
        quest: 'majority'),
    Words4(
        front: "Can you help me make a decision about what to buy?",
        back: "Ne satın alacağıma karar vermemde bana yardım edebilir misin?",
        list: 'B2',
        answer: 'yapmak',
        quest: 'make'),
    Words4(
        front: "We need a map to find our way around the city.",
        back: "Şehrin içinde dolaşmak için bir haritaya ihtiyacımız var.",
        list: 'B2',
        answer: 'harita',
        quest: 'map'),
    Words4(
        front:
            "The protesters gathered in a mass demonstration against the government.",
        back:
            "Protestocular hükümete karşı kitlesel bir gösteride toplandılar.",
        list: 'B2',
        answer: 'yığmak',
        quest: 'mass'),
    Words4(
        front:
            "The building was a massive structure that dominated the city skyline.",
        back: "Bina, şehrin silüetine hakim olan devasa bir yapıydı.",
        list: 'B2',
        answer: 'cüsseli',
        quest: 'massive'),
    Words4(
        front:
            "He is a master of the guitar and can play any song you request.",
        back: "Ustasıdır gitarın, istediğiniz herhangi bir şarkıyı çalabilir.",
        list: 'B2',
        answer: 'usta, efendi',
        quest: 'master'),
    Words4(
        front: "We need to find a matching pair of socks for this one.",
        back: "Bunun için uyumlu bir çorap çifti bulmamız gerekiyor.",
        list: 'B2',
        answer: 'karşılaştırma',
        quest: 'matching'),
    Words4(
        front: "The bus is a convenient means of transportation in the city.",
        back: "Otobüs, şehir içinde ulaşımın elverişli bir aracıdır.",
        list: 'B2',
        answer: 'araç',
        quest: 'means'),
    Words4(
        front:
            "The scientist carefully recorded his measurements in his notebook.",
        back: "Bilim insanı, ölçümlerini defterine dikkatlice kaydetti.",
        list: 'B2',
        answer: 'ölçüm',
        quest: 'measurement'),
    Words4(
        front: "I like my coffee medium, not too strong and not too weak.",
        back: "Kahvemi orta seviyede, çok sert veya çok zayıf değil, severim.",
        list: 'B2',
        answer: 'orta',
        quest: 'medium'),
    Words4(
        front:
            "The chocolate bar will melt quickly if you leave it in the sun.",
        back: "Eğer güneşte bırakırsanız çikolata çubuğu hızla eriyecektir.",
        list: 'B2',
        answer: 'eritmek',
        quest: 'melt'),
    Words4(
        front: "Turkey has a strong military force.",
        back: "Türkiye'nin güçlü bir askeri gücü vardır.",
        list: 'B2',
        answer: 'askeri',
        quest: 'military'),
    Words4(
        front: "Iron is an essential mineral for the human body.",
        back: "Demir, insan vücudu için gerekli bir mineraldir.",
        list: 'B2',
        answer: 'maden',
        quest: 'mineral'),
    Words4(
        front:
            "The minimum wage is not enough to live comfortably in this city.",
        back: "Asgari ücret, bu şehirde rahat yaşamak için yeterli değil.",
        list: 'B2',
        answer: 'asgari',
        quest: 'minimum'),
    Words4(
        front: "The Minister of Education announced a new reform plan.",
        back: "Milli Eğitim Bakanı yeni bir reform planı açıkladı.",
        list: 'B2',
        answer: 'bakan',
        quest: 'minister'),
    Words4(
        front: "You are not allowed to buy alcohol if you are a minor.",
        back: "Reşit değilseniz alkol satın almanıza izin verilmez.",
        list: 'B2',
        answer: 'reşit olmayan kimse',
        quest: 'minor'),
    Words4(
        front: "The ethnic minority group has its own language and traditions.",
        back: "Etnik azınlık grubunun kendi dili ve gelenekleri vardır.",
        list: 'B2',
        answer: 'azınlık',
        quest: 'minority'),
    Words4(
        front: "The astronauts' mission to Mars is a historic journey.",
        back: "Astronotların Mars'a yolculuğu tarihi bir görevdir.",
        list: 'B2',
        answer: 'görev',
        quest: 'mission'),
    Words4(
        front:
            "Everyone makes mistakes sometimes, the important thing is to learn from them.",
        back: "Herkes bazen hata yapar, önemli olan onlardan ders çıkarmaktır.",
        list: 'B2',
        answer: 'hata',
        quest: 'mistake'),
    Words4(
        front: "I felt a mix of emotions when I received the news.",
        back: "Haberi aldığımda karışık duygular yaşadım.",
        list: 'B2',
        answer: 'karışık',
        quest: 'mixed'),
    Words4(
        front: "The software can be modify-ied to meet your specific needs.",
        back: "Yazılım, özel ihtiyaçlarınızı karşılamak için değiştirilebilir.",
        list: 'B2',
        answer: 'değişmek',
        quest: 'modify'),
    Words4(
        front: "The knight mounted his horse and rode off into battle.",
        back: "Şövalye atına bindi ve savaşa doğru gitti.",
        list: 'B2',
        answer: 'binmek',
        quest: 'mount'),
    Words4(
        front:
            "He has multiple talents, he can sing, dance, and play the piano.",
        back:
            "Çok yetenekli, şarkı söyleyebilir, dans edebilir ve piyano çalabilir.",
        list: 'B2',
        answer: 'birçok',
        quest: 'multiple'),
    Words4(
        front: "Bacteria can multiply quickly in warm and humid conditions.",
        back: "Bakteriler sıcak ve nemli koşullarda hızla çoğalabilir.",
        list: 'B2',
        answer: 'çoğalmak',
        quest: 'multiply'),
    Words4(
        front:
            "The ancient ruins have a mysterious aura that attracts tourists from all over the world.",
        back:
            "Eski kalıntıların, dünyanın her yerinden turistleri çeken esrarengiz bir aurası vardır.",
        list: 'B2',
        answer: 'esrarengiz',
        quest: 'mysterious'),
    Words4(
        front: "The street was too narrow for two cars to pass each other.",
        back: "Sokak, iki arabanın yan yana geçmesi için çok dardı.",
        list: 'B2',
        answer: 'dar',
        quest: 'narrow'),
    Words4(
        front: "The national flag is a symbol of a country's pride and unity.",
        back: "Ulusal bayrak, bir ülkenin gurur ve birliğinin sembolüdür.",
        list: 'B2',
        answer: 'ulusal',
        quest: 'national'),
    Words4(
        front: "She keeps her desk neat and organized.",
        back: "Masasını düzenli ve temiz tutar.",
        list: 'B2',
        answer: 'düzenli',
        quest: 'neat'),
    Words4(
        front: "The constant loud noise was getting on my nerves.",
        back: "Sürekli gelen yüksek ses sinirlerime dokunmaya başladı.",
        list: 'B2',
        answer: 'sinir',
        quest: 'nerve'),
    Words4(
        front: "We lost the game, nevertheless, we played well.",
        back: "Maçı kaybettik, yine de iyi oynadık.",
        list: 'B2',
        answer: 'yine de',
        quest: 'nevertheless'),
    Words4(
        front: "I woke up screaming after having a nightmare about spiders.",
        back:
            "Örümceklerle ilgili bir kabus gördükten sonra çığlık atarak uyandım.",
        list: 'B2',
        answer: 'kabus',
        quest: 'nightmare'),
    Words4(
        front: "I don't have any notion of where he might be.",
        back: "Onun nerede olabileceğine dair hiçbir fikrim yok.",
        list: 'B2',
        answer: 'düşünce',
        quest: 'notion'),
    Words4(
        front: "There are numerous historical landmarks to visit in this city.",
        back: "Bu şehirde ziyaret edilebilecek sayısız tarihi simge var.",
        list: 'B2',
        answer: 'sayısız',
        quest: 'numerous'),
    Words4(
        front: "Children should obey their parents and teachers.",
        back: "Çocuklar anne-babalarına ve öğretmenlerine itaat etmelidir.",
        list: 'B2',
        answer: 'itaat etmek',
        quest: 'obey'),
    Words4(
        front: "She has the right to object to the new regulations.",
        back: "Yeni yönetmeliklere itiraz etme hakkı var.",
        list: 'B2',
        answer: 'itiraz etmek',
        quest: 'object'),
    Words4(
        front: "Our main objective is to help people in need.",
        back: "Asıl hedefimiz ihtiyaç sahibi insanlara yardım etmektir.",
        list: 'B2',
        answer: 'hedef, amaç',
        quest: 'objective'),
    Words4(
        front: "You have a moral obligation to help your friend.",
        back: "Arkadaşına yardım etmek için ahlaki bir yükümlülüğün var.",
        list: 'B2',
        answer: 'yükümlülük',
        quest: 'obligation'),
    Words4(
        front: "The scientist made careful observations of the plant's growth.",
        back:
            "Bilim insanı, bitkinin büyümesine dair dikkatli gözlemler yaptı.",
        list: 'B2',
        answer: 'gözetleme',
        quest: 'observation'),
    Words4(
        front: "We need to observe the traffic before crossing the street.",
        back: "Socağı geçmeden önce trafiği gözlemlememiz gerekiyor.",
        list: 'B2',
        answer: 'gözlemlemek',
        quest: 'observe'),
    Words4(
        front: "He was able to obtain a visa after a long application process.",
        back: "Uzun bir başvuru sürecinden sonra vize alabildi.",
        list: 'B2',
        answer: 'edinmek',
        quest: 'obtain'),
    Words4(
        front: "We occasionally go out for dinner on weekends.",
        back: "Hafta sonları ara sıra dışarıda yemek yiyoruz.",
        list: 'B2',
        answer: 'ara sıra',
        quest: 'occasionally'),
    Words4(
        front: "Her harsh words offended her deeply.",
        back: "Onun sert sözleri onu derinden rencide etti.",
        list: 'B2',
        answer: 'rencide etmek',
        quest: 'offend'),
    Words4(
        front: "His offensive remark caused a heated argument.",
        back: "Saldırgan sözü hararetli bir tartışmaya neden oldu.",
        list: 'B2',
        answer: 'saldırgan',
        quest: 'offensive'),
    Words4(
        front: "The government official announced a new economic plan.",
        back: "Devlet memuru yeni bir ekonomik plan açıkladı.",
        list: 'B2',
        answer: 'memur',
        quest: 'official'),
    Words4(
        front: "The grand opening of the new museum will be held next week.",
        back: "Yeni müzenin görkemli açılışı önümüzdeki hafta yapılacak.",
        list: 'B2',
        answer: 'açma',
        quest: 'opening'),
    Words4(
        front: "The surgeon will operate on the patient tomorrow morning.",
        back: "Cerrah hastayı yarın sabah ameliyat edecek.",
        list: 'B2',
        answer: 'ameliyat etmek',
        quest: 'operate'),
    Words4(
        front: "We will be facing a strong opponent in the championship game.",
        back: "Şampiyonluk maçında güçlü bir rakip ile karşılaşacağız.",
        list: 'B2',
        answer: 'rakip',
        quest: 'opponent'),
    Words4(
        front: "She strongly opposes the new law.",
        back: "Yeni yasaya şiddetle karşı çıkıyor.",
        list: 'B2',
        answer: 'karşı koymak',
        quest: 'oppose'),
    Words4(
        front: "I am opposed to violence in all forms.",
        back: "Her türlü şiddete karşıyım.",
        list: 'B2',
        answer: 'karşıt',
        quest: 'opposed'),
    Words4(
        front: "There is a growing opposition to the government's policies.",
        back: "Hükümetin politikalarına giderek artan bir muhalefet var.",
        list: 'B2',
        answer: 'aykırılık',
        quest: 'opposition'),
    Words4(
        front: "What is the origin of this word?",
        back: "Bu kelimenin kökeni nedir?",
        list: 'B2',
        answer: 'köken',
        quest: 'origin'),
    Words4(
        front:
            "He did well in school, otherwise he would not have gotten into college.",
        back: "Okulda başarılı oldu, aksi takdirde üniversiteye giremezdi.",
        list: 'B2',
        answer: 'aksi halde',
        quest: 'otherwise'),
    Words4(
        front: "The outcome of the election is still uncertain.",
        back: "Seçimin sonucu hala belirsiz.",
        list: 'B2',
        answer: 'netice',
        quest: 'outcome'),
    Words4(
        front:
            "The astronaut wore a special suit to protect his outer layer from the harsh space environment.",
        back:
            "Astronot, uzayın zorlu ortamından dış katmanını korumak için özel bir giysi giydi.",
        list: 'B2',
        answer: 'harici',
        quest: 'outer'),
    Words4(
        front:
            "Before you start writing your essay, it's helpful to outline your main points.",
        back:
            "Denenemenizi yazmaya başlamadan önce, ana hatlarını çizmeniz faydalıdır.",
        list: 'B2',
        answer: 'taslağını çizmek',
        quest: 'outline'),
    Words4(
        front: "The overall impression of the movie was positive.",
        back: "Filmin genel izlenimi olumluydu.",
        list: 'B2',
        answer: 'etraflı',
        quest: 'overall'),
    Words4(
        front: "I still owe him ten dollars for the book.",
        back: "Ona kitaba dair hala on dolar borçluyum.",
        list: 'B2',
        answer: 'borçlu olmak',
        quest: 'owe'),
    Words4(
        front: "He was pace-ing back and forth nervously before the interview.",
        back: "Mülakat öncesi gergin bir şekilde ileri geri adımlıyordu.",
        list: 'B2',
        answer: 'adımlamak',
        quest: 'pace'),
    Words4(
        front: "I received a package in the mail today.",
        back: "Bugün postayla bir paket aldım.",
        list: 'B2',
        answer: 'paket',
        quest: 'package'),
    Words4(
        front: "The new law was passed by a majority vote in parliament.",
        back: "Yeni yasa, parlamentoda çoğunluk oyu ile kabul edildi.",
        list: 'B2',
        answer: 'meclis',
        quest: 'parliament'),
    Words4(
        front: "There were over a hundred participants in the marathon.",
        back: "Maraton yarışına yüzün üzerinde katılımcı vardı.",
        list: 'B2',
        answer: 'katılımcı',
        quest: 'participant'),
    Words4(
        front:
            "The door was only partly open, so I couldn't see what was inside.",
        back: "Kapı sadece kısmen açıktı, bu yüzden içeriyi göremedim.",
        list: 'B2',
        answer: 'kısmen',
        quest: 'partly'),
    Words4(
        front: "The narrow passage led to a hidden garden.",
        back: "Dar pasaj gizli bir bahçeye açılıyordu.",
        list: 'B2',
        answer: 'pasaj',
        quest: 'passage'),
    Words4(
        front: "The doctor will see the next patient soon.",
        back: "Doktor kısa süre sonra bir sonraki hastayı görecek.",
        list: 'B2',
        answer: 'hasta',
        quest: 'patient'),
    Words4(
        front: "Many retirees rely on their pension to make ends meet.",
        back:
            "Birçok emekli, geçimlerini sağlamak için emekli maaşına güvenir.",
        list: 'B2',
        answer: 'emekli maaşı',
        quest: 'pension'),
    Words4(
        front: "He has a permanent job at a large company.",
        back: "Büyük bir şirkette kalıcı bir işi var.",
        list: 'B2',
        answer: 'kalıcı',
        quest: 'permanent'),
    Words4(
        front: "The police did not permit us to enter the crime scene.",
        back: "Polis, olay yerine girmemize izin vermedi.",
        list: 'B2',
        answer: 'izin vermek',
        quest: 'permit'),
    Words4(
        front:
            "It's important to consider all perspectives before making a decision.",
        back:
            "Karar vermeden önce tüm bakış açılarını değerlendirmek önemlidir.",
        list: 'B2',
        answer: 'bakış açısı',
        quest: 'perspective'),
    Words4(
        front: "The project is currently in its final phase of development.",
        back: "Proje şu anda son geliştirme aşamasında.",
        list: 'B2',
        answer: 'aşama',
        quest: 'phase'),
    Words4(
        front:
            "The northern lights are a natural phenomenon that can be seen in the Arctic sky.",
        back:
            "Kuzey ışıkları, Kuzey Kutbu gökyüzünde görülebilen doğal bir fenomendir.",
        list: 'B2',
        answer: 'algılanabilen şey',
        quest: 'phenomenon'),
    Words4(
        front:
            "Philosophy is the study of fundamental questions about existence, knowledge, and morality.",
        back:
            "Felsefe, varoluş, bilgi ve ahlak hakkındaki temel soruların incelenmesidir.",
        list: 'B2',
        answer: 'felsefe',
        quest: 'Philosophy'),
    Words4(
        front: "Please pick a number between one and ten.",
        back: "Lütfen bir ile on arasında bir sayı seçin.",
        list: 'B2',
        answer: 'seçmek',
        quest: 'pick'),
    Words4(
        front:
            "There is a beautiful picture of the sunset hanging on the wall.",
        back: "Duvarda asılı duran güzel bir gün batımı resmi var.",
        list: 'B2',
        answer: 'resim',
        quest: 'picture'),
    Words4(
        front: "There was a pile of dirty dishes in the sink.",
        back: "Lavaboda bir yığın kirli bulaşık vardı.",
        list: 'B2',
        answer: 'yığın',
        quest: 'pile'),
    Words4(
        front:
            "The singer's voice began to pitch as she reached the high notes.",
        back: "Şarkıcının sesi, tiz notalara ulaştığında yükselmeye başladı.",
        list: 'B2',
        answer: 'yalpalamak',
        quest: 'pitch'),
    Words4(
        front: "We drove across the vast plains of the Midwest.",
        back: "Orta Batı'nın geniş ovaları boyunca sürdük.",
        list: 'B2',
        answer: 'ova',
        quest: 'plain'),
    Words4(
        front: "What is the plot of the movie?",
        back: "Filmin konusu nedir?",
        list: 'B2',
        answer: 'hikayenin konusu',
        quest: 'plot'),
    Words4(
        front: "Two plus two equals four.",
        back: "İki artı iki dört eder.",
        list: 'B2',
        answer: 'artı',
        quest: 'plus'),
    Words4(
        front: "He carefully avoided the pointed rocks on the beach.",
        back: "Plajdaki sivri kayalardan dikkatlice kaçındı.",
        list: 'B2',
        answer: 'sivri',
        quest: 'pointed'),
    Words4(
        front: "She possesses a natural talent for music.",
        back: "Doğuştan müzik yeteneğine sahip.",
        list: 'B2',
        answer: 'sahip olmak',
        quest: 'possess'),
    Words4(
        front: "He has the potential to become a great leader.",
        back: "Harika bir lider olma potansiyeli var.",
        list: 'B2',
        answer: 'potansiyel',
        quest: 'potential'),
    Words4(
        front: "The new technology has the power to revolutionize the world.",
        back: "Yeni teknolojinin dünyayı kökten değiştirme gücü var.",
        list: 'B2',
        answer: 'güç',
        quest: 'power'),
    Words4(
        front: "The teacher praised the students for their hard work.",
        back: "Öğretmen, öğrencileri sıkı çalışmaları için övdü.",
        list: 'B2',
        answer: 'methetmek',
        quest: 'praise'),
    Words4(
        front: "She is three months pregnant.",
        back: "Üç aylık hamile.",
        list: 'B2',
        answer: 'hamile',
        quest: 'pregnant'),
    Words4(
        front: "We need to make careful preparations for the upcoming exam.",
        back: "Yaklaşan sınav için dikkatli hazırlıklar yapmamız gerekiyor.",
        list: 'B2',
        answer: 'hazırlık',
        quest: 'preparation'),
    Words4(
        front: "The strong presence of the police helped to calm the crowd.",
        back:
            "Polisin güçlü mevcudiyeti kalabalığı yatıştırmaya yardımcı oldu.",
        list: 'B2',
        answer: 'mevcudiyet',
        quest: 'presence'),
    Words4(
        front:
            "It is important to preserve our natural environment for future generations.",
        back: "Doğal çevremizi gelecek nesiller için korumak önemlidir.",
        list: 'B2',
        answer: 'korumak',
        quest: 'preserve'),
    Words4(
        front: "What is the price of this book?",
        back: "Bu kitabın fiyatı nedir?",
        list: 'B2',
        answer: 'fiyat',
        quest: 'price'),
    Words4(
        front: "The suspect was the prime suspect in the robbery.",
        back: "Şüpheli, soygunda baş şüpheliydi.",
        list: 'B2',
        answer: 'kurmak',
        quest: 'prime'),
    Words4(
        front: "Honesty is one of the most important principles in life.",
        back: "Dürüstlük, hayattaki en önemli ilkelerden biridir.",
        list: 'B2',
        answer: 'başlıca',
        quest: 'principle'),
    Words4(
        front: "Can you please print this document for me?",
        back: "Bu belgeyi benim için yazdırabilir misin?",
        list: 'B2',
        answer: 'yazdırmak',
        quest: 'print'),
    Words4(
        front: "Studying is my top priority right now.",
        back: "Şu anda en önemli önceliğim ders çalışmak.",
        list: 'B2',
        answer: 'öncelik',
        quest: 'priority'),
    Words4(
        front: "Everyone deserves the right to privacy.",
        back: "Herkes gizliliğe saygı hakkına sahiptir.",
        list: 'B2',
        answer: 'gizlilik',
        quest: 'privacy'),
    Words4(
        front: "The application process can take several weeks.",
        back: "Başvuru süreci birkaç hafta sürebilir.",
        list: 'B2',
        answer: 'süreç, işlem',
        quest: 'process'),
    Words4(
        front: "Our factory produces a variety of household products.",
        back: " Fabrikamız çeşitli ev ürünleri üretiyor.",
        list: 'B2',
        answer: 'üretmek',
        quest: 'produce'),
    Words4(
        front:
            "There has been significant progress in the fight against climate change.",
        back: "İklim değişikliği ile mücadelede önemli bir gelişme oldu.",
        list: 'B2',
        answer: 'gelişmek',
        quest: 'progress'),
    Words4(
        front:
            "We are working on a new project to develop sustainable energy sources.",
        back:
            "Sürdürülebilir enerji kaynakları geliştirmek için yeni bir proje üzerinde çalışıyoruz.",
        list: 'B2',
        answer: 'proje',
        quest: 'project'),
    Words4(
        front:
            "The police are still searching for proof of the suspect's guilt.",
        back: "Polis hala şüphelinin suçluluğuna dair kanıt arıyor.",
        list: 'B2',
        answer: 'kanıt',
        quest: 'proof'),
    Words4(
        front: "He submitted a proposal for a new educational program.",
        back: "Yeni bir eğitim programı için bir önerge sundu.",
        list: 'B2',
        answer: 'öneri',
        quest: 'proposal'),
    Words4(
        front: "The senator proposed a new law to reduce taxes.",
        back: "Senatör vergileri düşürmek için yeni bir yasa önerdi.",
        list: 'B2',
        answer: 'önermek',
        quest: 'propose'),
    Words4(
        front:
            "The future looks promising, with many exciting prospects ahead.",
        back:
            "Gelecek, önümüzde birçok heyecan verici olasılık varken umut verici görünüyor.",
        list: 'B2',
        answer: 'olasılık',
        quest: 'prospect'),
    Words4(
        front: "The police officer wore a bulletproof vest for protection.",
        back: "Polis memuru koruma amaçlı kurşun geçirmez yelek giydi.",
        list: 'B2',
        answer: 'koruma',
        quest: 'protection'),
    Words4(
        front:
            "The recent publication of her novel has brought her critical acclaim.",
        back:
            "Romanının yakın zamanda yayınlanması ona eleştirel beğeni kazandırdı.",
        list: 'B2',
        answer: 'yayınlamak',
        quest: 'publication'),
    Words4(
        front: "The teacher carefully explained the lesson to her pupils.",
        back: "Öğretmen dersi öğrencilerine dikkatlice anlattı.",
        list: 'B2',
        answer: 'öğrenci',
        quest: 'pupil'),
    Words4(
        front: "She decided to purchase a new car.",
        back: "Yeni bir araba almaya karar verdi.",
        list: 'B2',
        answer: 'satın almak',
        quest: 'purchase'),
    Words4(
        front: "The mountain air is pure and refreshing.",
        back: "Dağ havası saf ve tazedir.",
        list: 'B2',
        answer: 'saf',
        quest: 'pure'),
    Words4(
        front: "He is determined to pursue his dream of becoming a doctor.",
        back: "Doktor olma hayalini gerçekleştirmeye kararlı.",
        list: 'B2',
        answer: 'izlemek',
        quest: 'pursue'),
    Words4(
        front: "She was promoted to the rank of captain in the army.",
        back: "Orduda yüzbaşı rütbesine terfi etti.",
        list: 'B2',
        answer: 'rütbe, aşama',
        quest: 'rank'),
    Words4(
        front: "The fire spread rapidly through the dry forest.",
        back: "Yangın kuru ormanda hızla yayıldı.",
        list: 'B2',
        answer: 'hızla',
        quest: 'rapid'),
    Words4(
        front: "The unemployment rate is currently at a ten-year low.",
        back: "İşsizlik oranı şu anda on yıllık en düşük seviyede.",
        list: 'B2',
        answer: 'kur',
        quest: 'rate'),
    Words4(
        front: "I don't like eating raw fish.",
        back: "Çiğ balık yemekten hoşlanmam.",
        list: 'B2',
        answer: 'çiğ',
        quest: 'raw'),
    Words4(
        front: "We finally reached our destination after a long journey.",
        back: "Uzun bir yolculuktan sonra sonunda varış yerimize ulaştık.",
        list: 'B2',
        answer: 'ulaşmak',
        quest: 'reach'),
    Words4(
        front: "It is important to set realistic goals for yourself.",
        back: "Kendiniz için gerçekçi hedefler belirlemek önemlidir.",
        list: 'B2',
        answer: 'gerçekçi',
        quest: 'realistic'),
    Words4(
        front:
            "The teacher asked the students to answer a reasonable question.",
        back:
            "Öğretmen öğrencilerden mantıklı bir soru cevaplamalarını istedi.",
        list: 'B2',
        answer: 'mantıksal',
        quest: 'reasonable'),
    Words4(
        front: "I can't recall where I left my keys.",
        back: " anahtarlarımı nereye bıraktığımı hatırlayamıyorum.",
        list: 'B2',
        answer: 'hatırlamak',
        quest: 'recall'),
    Words4(
        front: "It took her months to recover from the accident.",
        back: "Kazadan tamamen kurtulması aylar aldı.",
        list: 'B2',
        answer: 'kurtarmak',
        quest: 'recover'),
    Words4(
        front:
            "The government is implementing new policies to achieve a reduction in greenhouse gas emissions.",
        back:
            "Hükümet, sera gazı emisyonlarını azaltmak için yeni politikalar uyguluyor.",
        list: 'B2',
        answer: 'eksiltme',
        quest: 'reduction'),
    Words4(
        front: "I don't regard him highly as a musician.",
        back: "Onu bir müzisyen olarak pek saymam.",
        list: 'B2',
        answer: 'saymak',
        quest: 'regard'),
    Words4(
        front: "The company is expanding its operations into regional markets.",
        back: "Şirket, faaliyetlerini bölgesel pazarlara genişletiyor.",
        list: 'B2',
        answer: 'bölgesel',
        quest: 'regional'),
    Words4(
        front: "You need to register for the class before the deadline.",
        back: "Derse son teslim tarihinden önce kaydolmanız gerekiyor.",
        list: 'B2',
        answer: 'kaydetmek',
        quest: 'register'),
    Words4(
        front: "He expressed his regret for missing the important meeting.",
        back: "Önemli toplantıyı kaçırdığı için pişmanlığını dile getirdi.",
        list: 'B2',
        answer: 'pişmanlık',
        quest: 'regret'),
    Words4(
        front: "There are strict regulations in place to ensure food safety.",
        back: "Gıda güvenliğini sağlamak için sıkı düzenlemeler var.",
        list: 'B2',
        answer: 'düzenleme',
        quest: 'regulation'),
    Words4(
        front:
            "Turkey is a relatively large country compared to its European neighbors.",
        back: "Türkiye, Avrupa komşularına göre nispeten büyük bir ülkedir.",
        list: 'B2',
        answer: 'oranla',
        quest: 'relatively'),
    Words4(
        front:
            "Only the information relevant to the case will be included in the report.",
        back: "Rapora sadece dava ile ilgili bilgiler dahil edilecektir.",
        list: 'B2',
        answer: 'konuyla ilgili',
        quest: 'relevant'),
    Words4(
        front: "He felt a sense of relief when he finally finished the exam.",
        back: "Sınavı nihayet bitirdiğinde bir rahatlama hissetti.",
        list: 'B2',
        answer: 'rahatlama',
        quest: 'relief'),
    Words4(
        front: "You can rely on me to help you with this project.",
        back: "Bu projede size yardım etmek için bana güvenebilirsiniz.",
        list: 'B2',
        answer: 'güvenmek',
        quest: 'rely'),
    Words4(
        front: "The teacher made a few remarks about the students' behavior.",
        back:
            "Öğretmen, öğrencilerin davranışları hakkında birkaç açıklama yaptı.",
        list: 'B2',
        answer: 'belirtmek',
        quest: 'remark'),
    Words4(
        front: "She is a representative of the student council.",
        back: "O, öğrenci konseyinin temsilcisidir.",
        list: 'B2',
        answer: 'temsil eden',
        quest: 'representative'),
    Words4(
        front: "He has a good reputation for being honest and reliable.",
        back: "Dürüst ve güvenilir olmasıyla tanınan iyi bir şöhrete sahip.",
        list: 'B2',
        answer: 'ün, şöhret',
        quest: 'reputation'),
    Words4(
        front:
            "The new law outlines the requirements for obtaining a work visa.",
        back: "Yeni yasa, çalışma vizesi almanın gerekliliklerini özetliyor.",
        list: 'B2',
        answer: 'ihtiyaç',
        quest: 'requirement'),
    Words4(
        front:
            "The coast guard rescued the stranded sailors from the sinking ship.",
        back:
            "Sahil güvenlik, batmakta olan gemiden mahsur kalan denizcileri kurtardı.",
        list: 'B2',
        answer: 'kurtarmak',
        quest: 'rescue'),
    Words4(
        front: "I need to reserve a table at the restaurant for tonight.",
        back: "Bu akşam için restoranda bir masa rezerve ettirmem gerekiyor.",
        list: 'B2',
        answer: 'ayırmak',
        quest: 'reserve'),
    Words4(
        front: "She is a long-term resident of this city.",
        back: "O, bu şehrin uzun süreli sakinidir.",
        list: 'B2',
        answer: 'sakin',
        quest: 'resident'),
    Words4(
        front: "The protesters are resisting the government's new policies.",
        back: "Protestocular, hükümetin yeni politikalarına direniyor.",
        list: 'B2',
        answer: 'direnmek',
        quest: 'resist'),
    Words4(
        front: "He is determined to resolve the conflict peacefully.",
        back: "Sorunu barışçıl bir şekilde çözmeye kararlı.",
        list: 'B2',
        answer: 'kesin karar vermek',
        quest: 'resolve'),
    Words4(
        front: "We spent a relaxing week at a beautiful beach resort.",
        back: "Güzel bir plaj tatilinde rahatlatıcı bir hafta geçirdik.",
        list: 'B2',
        answer: 'tatil yeri',
        quest: 'resort'),
    Words4(
        front: "She was able to retain her job after the company downsized.",
        back: "Şirket küçüldükten sonra işini koruyabildi.",
        list: 'B2',
        answer: 'sürdürmek',
        quest: 'retain'),
    Words4(
        front: "The investigation revealed a shocking conspiracy.",
        back: "Soruşturma şok edici bir komplo ortaya çıkardı.",
        list: 'B2',
        answer: 'meydana çıkarmak',
        quest: 'reveal'),
    Words4(
        front:
            "The French Revolution was a major turning point in European history.",
        back: "Fransız Devrimi, Avrupa tarihinin önemli bir dönüm noktasıydı.",
        list: 'B2',
        answer: 'ihtilal',
        quest: 'revolution'),
    Words4(
        front: "He was given a reward for his bravery in saving the child.",
        back:
            "Çocuğu kurtarmadaki cesareti nedeniyle kendisine bir ödül verildi.",
        list: 'B2',
        answer: 'ödül',
        quest: 'reward'),
    Words4(
        front: "The dancer moved to the rhythm of the music.",
        back: "Dansçı müziğin ritmine göre hareket etti.",
        list: 'B2',
        answer: 'ritim',
        quest: 'rhythm'),
    Words4(
        front: "It is important to rid the world of poverty and hunger.",
        back: "Dünyayı yoksulluk ve açlıktan kurtarmak önemlidir.",
        list: 'B2',
        answer: 'temizlemek',
        quest: 'rid'),
    Words4(
        front: "She is interested in learning about her family roots.",
        back: "Ailesinin köklerini öğrenmek ile ilgileniyor.",
        list: 'B2',
        answer: 'köken',
        quest: 'root'),
    Words4(
        front: "The boxer completed the tenth and final round of the fight.",
        back: "Boksör, maçın onuncu ve son raundunu tamamladı.",
        list: 'B2',
        answer: 'yuvarlak',
        quest: 'round'),
    Words4(
        front: "He rubbed his eyes to try and wake himself up.",
        back: "Kendini uyandırmak için gözlerini ovuşturdu.",
        list: 'B2',
        answer: 'sürtmek',
        quest: 'rub'),
    Words4(
        front: "The tires are made of a durable type of rubber.",
        back: "Lastikler, dayanıklı bir kauçuktan yapılmıştır.",
        list: 'B2',
        answer: 'lastik',
        quest: 'rubber'),
    Words4(
        front: "We grew up in a small rural village.",
        back: "Küçük bir kırsal köyde büyüdük.",
        list: 'B2',
        answer: 'kırsal',
        quest: 'rural'),
    Words4(
        front: "Don't rush me, I need to take my time on this assignment.",
        back: "Acele etmeyin, bu ödev üzerinde zaman ayırmam gerekiyor.",
        list: 'B2',
        answer: 'acele etmek',
        quest: 'rush'),
    Words4(
        front: "The scientist is analyzing a sample of the new drug.",
        back: "Bilim insanı, yeni ilacın bir örneğini analiz ediyor.",
        list: 'B2',
        answer: 'örnek',
        quest: 'sample'),
    Words4(
        front: "There are many artificial satellites orbiting the Earth.",
        back: "Dünyanın etrafında dönen birçok yapay uydu var.",
        list: 'B2',
        answer: 'uydu',
        quest: 'satellite'),
    Words4(
        front: "I am not satisfied with the quality of the work.",
        back: "İşin kalitesinden memnun değilim.",
        list: 'B2',
        answer: 'memnun',
        quest: 'satisfied'),
    Words4(
        front: "The new policy aims to satisfy the needs of all citizens.",
        back:
            "Yeni politika, tüm vatandaşların ihtiyaçlarını karşılamayı amaçlıyor.",
        list: 'B2',
        answer: 'tatmin etmek',
        quest: 'satisfy'),
    Words4(
        front:
            "The lifeguard's quick action resulted in the saving of a child's life.",
        back:
            "Cankurtaranın hızlı hareketi, bir çocuğun hayatının kurtarılmasıyla sonuçlandı.",
        list: 'B2',
        answer: 'kurtarma',
        quest: 'saving'),
    Words4(
        front:
            "The map shows the scale of the destruction caused by the earthquake.",
        back: "Harita, depremin yol açtığı yıkımın ölçeğini gösteriyor.",
        list: 'B2',
        answer: 'ölçek',
        quest: 'scale'),
    Words4(
        front: "Do you have a schedule for your upcoming presentations?",
        back: "Yaklaşan sunumlarınız için bir programınız var mı?",
        list: 'B2',
        answer: 'program',
        quest: 'schedule'),
    Words4(
        front:
            "The criminal mastermind devised a complex scheme to rob the bank.",
        back:
            "Suç örgütü lideri, bankayı soymak için karmaşık bir plan düzenledi.",
        list: 'B2',
        answer: 'düzenlemek',
        quest: 'scheme'),
    Words4(
        front:
            "The crowd started to scream when they saw their favorite band on stage.",
        back:
            "Kalabalık, favori gruplarını sahnede görünce çığlık atmaya başladı.",
        list: 'B2',
        answer: 'bağırmak',
        quest: 'scream'),
    Words4(
        front: "He stared intently at the computer screen.",
        back: "Bilgisayar ekranına dikkatle baktı.",
        list: 'B2',
        answer: 'ekran',
        quest: 'screen'),
    Words4(
        front: "Please take a seat and I will be with you shortly.",
        back: "Lütfen oturun, hemen yanınızda olacağım.",
        list: 'B2',
        answer: 'koltuk',
        quest: 'seat'),
    Words4(
        front: "The company is a leader in the technology sector.",
        back: "Şirket, teknoloji sektöründe lider konumundadır.",
        list: 'B2',
        answer: 'sektör',
        quest: 'sector'),
    Words4(
        front: "We need to take steps to secure our online accounts.",
        back:
            "Online hesaplarımızı güvence altına almak için adımlar atmamız gerekiyor.",
        list: 'B2',
        answer: 'sağlamlaştırmak',
        quest: 'secure'),
    Words4(
        front: "He is seeking a new job that offers better opportunities.",
        back: "Daha iyi fırsatlar sunan yeni bir iş arıyor.",
        list: 'B2',
        answer: 'aramak',
        quest: 'seek'),
    Words4(
        front: "You can select the language you prefer from the menu.",
        back: "Menüden tercih ettiğiniz dili seçebilirsiniz.",
        list: 'B2',
        answer: 'seçmek',
        quest: 'select'),
    Words4(
        front: "There is a wide selection of clothes available in this store.",
        back: "Bu mağazada geniş bir seçki kıyafet bulunmaktadır.",
        list: 'B2',
        answer: 'seçme',
        quest: 'selection'),
    Words4(
        front: "It's important to understand your own self-worth.",
        back: "Kendi değerinizi anlamak önemlidir.",
        list: 'B2',
        answer: 'öz',
        quest: 'self'),
    Words4(
        front: "The senior manager gave a presentation to the team.",
        back: "Kıdemli yönetici ekibe bir sunum yaptı.",
        list: 'B2',
        answer: 'kıdemli',
        quest: 'senior'),
    Words4(
        front: "I could sense that he was feeling nervous about the interview.",
        back: "Mülakat konusunda gergin hissettiğini hissedebiliyordum.",
        list: 'B2',
        answer: 'algılamak',
        quest: 'sense'),
    Words4(
        front:
            "This is a sensitive topic, so please be mindful of your language.",
        back:
            "Bu hassas bir konu, bu yüzden lütfen kullandığınız dile dikkat edin.",
        list: 'B2',
        answer: 'hassas',
        quest: 'sensitive'),
    Words4(
        front: "The judge issued a ten-year sentence for the crime.",
        back: "Hakim suç için on yıllık bir ceza verdi.",
        list: 'B2',
        answer: 'cümle',
        quest: 'sentence'),
    Words4(
        front:
            "The sequence of events leading up to the accident is still being investigated.",
        back: "Kazaya yol açan olayların sırası hala araştırılıyor.",
        list: 'B2',
        answer: 'birbiri ardından gelme',
        quest: 'sequence'),
    Words4(
        front:
            "We will have a brainstorming session to discuss new ideas for the project.",
        back:
            "Projeye yönelik yeni fikirleri tartışmak için bir beyin fırtınası oturumu yapacağız.",
        list: 'B2',
        answer: 'oturum',
        quest: 'session'),
    Words4(
        front:
            "The refugees are hoping to settle in a safe and peaceful country.",
        back: "Mülteciler güvenli ve huzurlu bir ülkeye yerleşmeyi umuyorlar.",
        list: 'B2',
        answer: 'yerleşmek',
        quest: 'settle'),
    Words4(
        front: "The winter brought a period of severe weather conditions.",
        back: "Kış, şiddetli hava koşullarının yaşandığı bir dönem getirdi.",
        list: 'B2',
        answer: 'haşin, sert',
        quest: 'severe'),
    Words4(
        front: "The pond is quite shallow, so you can easily stand up in it.",
        back: "Gölet oldukça sığ, bu yüzden içinde kolayca durabilirsiniz.",
        list: 'B2',
        answer: 'sığ',
        quest: 'shallow'),
    Words4(
        front: "He felt a deep sense of shame for his actions.",
        back: "Yaptıklarından dolayı derin bir utanç duydu.",
        list: 'B2',
        answer: 'utanma',
        quest: 'shame'),
    Words4(
        front:
            "Exercise can help you to shape your body and improve your fitness.",
        back:
            "Egzersiz, vücudunuzu şekillendirmenize ve formunuzu geliştirmenize yardımcı olabilir.",
        list: 'B2',
        answer: 'şekil vermek',
        quest: 'shape'),
    Words4(
        front: "The homeless man found shelter in a doorway for the night.",
        back: "Evsiz adam, gece boyunca bir kapının altında barınak buldu.",
        list: 'B2',
        answer: 'barınak',
        quest: 'shelter'),
    Words4(
        front: "She is working the night shift at the hospital this week.",
        back: "Bu hafta hastanede gece vardiyasında çalışıyor.",
        list: 'B2',
        answer: 'vardiya',
        quest: 'shift'),
    Words4(
        front: "The cargo ship is carrying a shipment of grain to Africa.",
        back: "Kargo gemisi Afrika'ya bir tahıl sevkiyatı taşıyor.",
        list: 'B2',
        answer: 'gemi',
        quest: 'ship'),
    Words4(
        front: "There was a shooting in the city center yesterday.",
        back: "Dün şehir merkezinde bir silahlı çatışma yaşandı.",
        list: 'B2',
        answer: 'ateş etme',
        quest: 'shooting'),
    Words4(
        front: "He missed the winning shot by a hair's breadth.",
        back: "Kazanan atışı kılına kadar kaçırdı.",
        list: 'B2',
        answer: 'atış',
        quest: 'shot'),
    Words4(
        front:
            "The discovery of a new planet is a significant scientific development.",
        back: "Yeni bir gezegenin keşfi, önemli bir bilimsel gelişmedir.",
        list: 'B2',
        answer: 'dikkate değer',
        quest: 'significant'),
    Words4(
        front:
            "Climate change has significantly impacted the planet's ecosystems.",
        back:
            "İklim değişikliği, gezegenin ekosistemlerini önemli ölçüde etkiledi.",
        list: 'B2',
        answer: 'önemli ölçüde',
        quest: 'significantly'),
    Words4(
        front: "The room fell silent as everyone waited for the announcement.",
        back: "Herkes duyuruyu beklerken oda sessizliğe gömüldü.",
        list: 'B2',
        answer: 'sessizlik',
        quest: 'silent'),
    Words4(
        front: "The dress was made of a soft and luxurious silk fabric.",
        back: "Elbise yumuşak ve lüks bir ipek kumaştan yapılmıştı.",
        list: 'B2',
        answer: 'ipek',
        quest: 'silk'),
    Words4(
        front: "He offered his sincere condolences to the grieving family.",
        back: "Yas tutan aileye içten taziyelerini sundu.",
        list: 'B2',
        answer: 'içten',
        quest: 'sincere'),
    Words4(
        front: "Slavery was a brutal practice that existed for centuries.",
        back: "Kölelik, yüzyıllardır var olan acımasız bir uygulamadır.",
        list: 'B2',
        answer: 'köle',
        quest: 'Slave'),
    Words4(
        front: "Be careful not to slide on the wet floor.",
        back: "Islak zeminde kaymamaya dikkat edin.",
        list: 'B2',
        answer: 'kaydırma',
        quest: 'slide'),
    Words4(
        front: "There has been a slight improvement in his condition.",
        back: "Durumunda hafif bir iyileşme oldu.",
        list: 'B2',
        answer: 'hafif',
        quest: 'slight'),
    Words4(
        front: "She slipped on the ice and fell down.",
        back: "Buz üzerinde kaydı ve düştü.",
        list: 'B2',
        answer: 'kaymak',
        quest: 'slip'),
    Words4(
        front: "The car was slowly sliding down the steep slope.",
        back: "Araba dik yamaçtan yavaşça aşağı kayıyordu.",
        list: 'B2',
        answer: 'slope',
        quest: 'slope'),
    Words4(
        front: "Solar energy is a renewable and sustainable source of power.",
        back:
            "Güneş enerjisi, yenilenebilir ve sürdürülebilir bir enerji kaynağıdır.",
        list: 'B2',
        answer: 'güneş',
        quest: 'solar'),
    Words4(
        front: "I am somewhat surprised by your decision.",
        back: "Kararınıza biraz şaşırdım.",
        list: 'B2',
        answer: 'birazcık',
        quest: 'somewhat'),
    Words4(
        front: "The music touched his soul and brought him peace.",
        back: "Müzik ruhuna dokundu ve ona huzur verdi.",
        list: 'B2',
        answer: 'ruh',
        quest: 'soul'),
    Words4(
        front:
            "There are millions of different species of plants and animals on Earth.",
        back: "Dünyada milyonlarca farklı bitki ve hayvan türü var.",
        list: 'B2',
        answer: 'tür',
        quest: 'species'),
    Words4(
        front: "The car was traveling at a high speed down the highway.",
        back: "Araba, otoyolda yüksek hızla ilerliyordu.",
        list: 'B2',
        answer: 'hız',
        quest: 'speed'),
    Words4(
        front: "He is on a journey of spiritual discovery.",
        back: "Manevi bir keşif yolculuğunda.",
        list: 'B2',
        answer: 'ruhsal',
        quest: 'spiritual'),
    Words4(
        front: "The cake was split into several slices for everyone to enjoy.",
        back: "Pasta, herkesin tadını çıkarması için birkaç dilime bölündü.",
        list: 'B2',
        answer: 'bölmek',
        quest: 'split'),
    Words4(
        front: "I noticed a small spot of paint on my shirt.",
        back: "Gömleğimde küçük bir boya lekesi fark ettim.",
        list: 'B2',
        answer: 'leke',
        quest: 'spot'),
    Words4(
        front: "The rumor quickly spread throughout the town.",
        back: "Söylenti hızla kasabaya yayıldı.",
        list: 'B2',
        answer: 'yaymak',
        quest: 'spread'),
    Words4(
        front: "The economy is in a stable state at the moment.",
        back: "Ekonomi şu anda durağan bir durumda.",
        list: 'B2',
        answer: 'durağan',
        quest: 'stable'),
    Words4(
        front:
            "The band will be staging their new show at the theater next week.",
        back: "Grup, önümüzdeki hafta tiyatroda yeni şovlarını sahneleyecek.",
        list: 'B2',
        answer: 'sahnelemek',
        quest: 'stage'),
    Words4(
        front: "Does this offer still stand?",
        back: "Bu teklif hala geçerli mi?",
        list: 'B2',
        answer: '(teklif)geçerli olmak',
        quest: 'stand'),
    Words4(
        front: "He stared blankly at the wall for a long time.",
        back: "Uzun bir süre boş bir şekilde duvara baktı.",
        list: 'B2',
        answer: 'gözü dalmak',
        quest: 'stare'),
    Words4(
        front: "The ship maintained a steady course throughout the night.",
        back: "Gemi gece boyunca sabit bir rotada seyretti.",
        list: 'B2',
        answer: 'sabit durum',
        quest: 'steady'),
    Words4(
        front: "The building is made of reinforced steel.",
        back: "Bina, takviyeli çelikten yapılmıştır.",
        list: 'B2',
        answer: 'çelik',
        quest: 'steel'),
    Words4(
        front:
            "The path leading up the mountain was very steep and challenging.",
        back: "Dağa çıkan yol çok dik ve zordu.",
        list: 'B2',
        answer: 'dik',
        quest: 'steep'),
    Words4(
        front:
            "Take a step back and look at the situation from a different perspective.",
        back: "Geriye bir adım atın ve duruma farklı bir açıdan bakın.",
        list: 'B2',
        answer: 'adım',
        quest: 'step'),
    Words4(
        front: "The candy bar was too sticky to eat.",
        back: "Şekerleme yemek için çok yapışkandı.",
        list: 'B2',
        answer: 'yapışkan',
        quest: 'sticky'),
    Words4(
        front:
            "He felt a bit stiff after sitting in the same position for hours.",
        back:
            "Saatlerce aynı pozisyonda oturduktan sonra biraz çetin hissetti.",
        list: 'B2',
        answer: 'çetin',
        quest: 'stiff'),
    Words4(
        front: "There is a clear stream running through the forest.",
        back: "Ormandan geçen berrak bir dere var.",
        list: 'B2',
        answer: 'dere',
        quest: 'stream'),
    Words4(
        front:
            "She stretched her arms above her head to loosen up her muscles.",
        back: "Kaslarını gevşetmek için kollarını başının üstüne uzattı.",
        list: 'B2',
        answer: 'uzatmak',
        quest: 'stretch'),
    Words4(
        front: "The teacher has a very strict policy on classroom behavior.",
        back:
            "Öğretmenin sınıf içi davranışları konusunda çok sıkı bir politikası var.",
        list: 'B2',
        answer: 'sıkı',
        quest: 'strict'),
    Words4(
        front:
            "The workers went on strike to protest the unfair working conditions.",
        back:
            "İşçiler, adil olmayan çalışma koşullarını protesto etmek için greve gitti.",
        list: 'B2',
        answer: 'çarpmak',
        quest: 'strike'),
    Words4(
        front: "The building has a strong and stable structure.",
        back: "Binanın güçlü ve sağlam bir yapısı var.",
        list: 'B2',
        answer: 'yapılandırmak',
        quest: 'structure'),
    Words4(
        front:
            "He is struggling to find a job in the current economic climate.",
        back: "Mevcut ekonomik ortamda iş bulmakta zorlanıyor.",
        list: 'B2',
        answer: 'çabalamak',
        quest: 'struggle'),
    Words4(
        front: "The backpack was stuffed with all her belongings for the trip.",
        back: "Sırt çantası, yolculuk için tüm eşyalarıyla doluydu.",
        list: 'B2',
        answer: 'tıkınmak, şey',
        quest: 'stuff'),
    Words4(
        front: "What is the subject of your research paper?",
        back: "Araştırma makalenizin konusu nedir?",
        list: 'B2',
        answer: 'ders, özne',
        quest: 'subject'),
    Words4(
        front: "He submitted his application for the job online.",
        back: "İş başvurusunu online olarak gönderdi.",
        list: 'B2',
        answer: 'sunmak',
        quest: 'submit'),
    Words4(
        front: "The total cost of the repairs came to \$1,000.",
        back: "Tamiratların toplam maliyeti 1.000 dolara ulaştı.",
        list: 'B2',
        answer: 'toplam',
        quest: 'sum'),
    Words4(
        front:
            "The surgery was successful, and the patient is recovering well.",
        back: "Ameliyat başarılı geçti ve hasta iyileşiyor.",
        list: 'B2',
        answer: 'ameliyat',
        quest: 'surgery'),
    Words4(
        front:
            "The enemy forces surrounded the castle, cutting off all escape routes.",
        back: "Düşman güçleri kaleyi kuşattı ve tüm kaçış yollarını kesti.",
        list: 'B2',
        answer: 'kuşatmak',
        quest: 'surround'),
    Words4(
        front:
            "The hikers enjoyed the beautiful scenery of the surrounding mountains.",
        back:
            "Yürüyüşçüler, çevredeki dağların güzel manzarasının tadını çıkardı.",
        list: 'B2',
        answer: 'çevre',
        quest: 'surrounding'),
    Words4(
        front:
            "The company is conducting a survey to gather feedback from customers.",
        back:
            "Şirket, müşterilerden geri bildirim toplamak için bir araştırma yürütüyor.",
        list: 'B2',
        answer: 'araştırma',
        quest: 'survey'),
    Words4(
        front: "I suspect that he is not telling the whole truth.",
        back: "Sanırım bütün gerçeği söylemiyor.",
        list: 'B2',
        answer: 'şüphelenmek',
        quest: 'suspect'),
    Words4(
        front: "He swore under his breath when he dropped his phone.",
        back: "Telefonunu düşürdüğünde nefretle söylendi.",
        list: 'B2',
        answer: 'sövmek',
        quest: 'swear'),
    Words4(
        front: "She swept the floor to remove the dirt and dust.",
        back: "Kiri ve tozu temizlemek için yeri süpürdü.",
        list: 'B2',
        answer: 'süpürmek',
        quest: 'sweep'),
    Words4(
        front: "It's time to switch on the lights - it's getting dark.",
        back: "Işıkları açma zamanı - hava kararıyor.",
        list: 'B2',
        answer: 'değiştirmek',
        quest: 'switch'),
    Words4(
        front: "My grandmother told me a bedtime tale about a brave princess.",
        back: "Büyükannem bana cesur bir prenses hakkında bir masal anlattı.",
        list: 'B2',
        answer: 'masal',
        quest: 'tale'),
    Words4(
        front: "The car needs a full tank of gas before we go on a road trip.",
        back:
            "Yolculuğa çıkmadan önce arabanın deposuna dolu bir tank gazyağı lazım.",
        list: 'B2',
        answer: 'depoya koymak',
        quest: 'tank'),
    Words4(
        front: "The soldier aimed his rifle at the target and fired.",
        back: "Asker tüfeğini hedefe doğrulttu ve ateş etti.",
        list: 'B2',
        answer: 'hedef',
        quest: 'target'),
    Words4(
        front: "She ripped a piece of paper out of her notebook.",
        back: "Not defterinden bir sayfa kopardı.",
        list: 'B2',
        answer: 'yırtılmak',
        quest: 'tear'),
    Words4(
        front:
            "This is just a temporary solution until we can find a permanent fix.",
        back: "Bu, kalıcı bir çözüm bulana kadar geçici bir çözüm.",
        list: 'B2',
        answer: 'geçici',
        quest: 'temporary'),
    Words4(
        front: "The word 'democracy' is a complex term with a long history.",
        back: "Demokrasi kelimesi, uzun geçmişi olan karmaşık bir terimdir.",
        list: 'B2',
        answer: 'isimlendirmek',
        quest: 'term'),
    Words4(
        front: "The bomb threat forced the evacuation of the building.",
        back: "Bomba tehdidi binanın tahliyesine zorladı.",
        list: 'B2',
        answer: 'tehdit',
        quest: 'threat'),
    Words4(
        front: "He threatened to quit his job if they didn't give him a raise.",
        back: "Eğer zam yapmazlarsa işinden ayrılacağıyla tehdit etti.",
        list: 'B2',
        answer: 'tehdit etmek',
        quest: 'threaten'),
    Words4(
        front:
            "Thus, we can see that education is essential for a successful life.",
        back:
            "Böylelikle, eğitimin başarılı bir yaşam için gerekli olduğunu görebiliriz.",
        list: 'B2',
        answer: 'Böylelikle',
        quest: 'Thus'),
    Words4(
        front: "How many times have you seen this movie?",
        back: "Bu filmi kaç kez izledin?",
        list: 'B2',
        answer: 'kez, kere',
        quest: 'time'),
    Words4(
        front:
            "The book has an interesting title that captures the reader's attention.",
        back: "Kitabın, okuyucuyu dikkatini çeken ilginç bir başlığı var.",
        list: 'B2',
        answer: 'başlık',
        quest: 'title'),
    Words4(
        front: "This was a tough decision, but I had to make it.",
        back: "Bu zor bir karardı, ama vermek zorunda kaldım.",
        list: 'B2',
        answer: 'zorlu',
        quest: 'tough'),
    Words4(
        front: "The police are tracking the movements of the suspect.",
        back: "Polis, şüphelinin hareketlerini izliyor.",
        list: 'B2',
        answer: 'izlemek',
        quest: 'track'),
    Words4(
        front:
            "The caterpillar will transform into a butterfly in a few weeks.",
        back: "Tırtıl birkaç hafta içinde kelebeğe dönüşecek.",
        list: 'B2',
        answer: 'dönüşmek',
        quest: 'transform'),
    Words4(
        front:
            "The transition from childhood to adulthood can be a challenging time.",
        back: "Çocukluktan yetişkinliğe geçiş zorlu bir dönem olabilir.",
        list: 'B2',
        answer: 'geçiş',
        quest: 'transition'),
    Words4(
        front: "The defendant is on trial for murder.",
        back: "Sanık, cinayet davasında yargılanıyor.",
        list: 'B2',
        answer: 'yargılama',
        quest: 'trial'),
    Words4(
        front: "We are planning a trip to Italy next summer.",
        back: "Önümüzdeki yaz İtalya'ya bir gezi planlıyoruz.",
        list: 'B2',
        answer: 'seyahat',
        quest: 'trip'),
    Words4(
        front: "He is having trouble sleeping at night.",
        back: "Geceleri uyumakta sorun yaşıyor.",
        list: 'B2',
        answer: 'sorun',
        quest: 'trouble'),
    Words4(
        front: "I truly believe that everyone deserves a second chance.",
        back: "Herkesin ikinci bir şansı hak ettiğine gerçekten inanıyorum.",
        list: 'B2',
        answer: 'tamamen',
        quest: 'truly'),
    Words4(
        front: "I trust her completely with my most important secrets.",
        back: "Ona en önemli sırlarımı tamamen güveniyorum.",
        list: 'B2',
        answer: 'güvenmek',
        quest: 'trust'),
    Words4(
        front: "I will try my best to finish the project on time.",
        back: "Projeyi zamanında bitirmek için elimden geleni deneyeceğim.",
        list: 'B2',
        answer: 'denemek',
        quest: 'try'),
    Words4(
        front: "He was humming a catchy tune while he worked.",
        back: "Çalışırken akılda kalıcı bir melodi mırıldanıyordu.",
        list: 'B2',
        answer: 'melodi',
        quest: 'tune'),
    Words4(
        front: "The rescue team dug a tunnel to reach the trapped miners.",
        back:
            "Kurtarma ekibi, mahsur kalan madencilere ulaşmak için bir tünel kazdı.",
        list: 'B2',
        answer: 'tünel',
        quest: 'tunnel'),
    Words4(
        front:
            "Ultimately, the goal is to create a better future for everyone.",
        back:
            "Sonuç olarak, amaç herkes için daha iyi bir gelecek yaratmaktır.",
        list: 'B2',
        answer: 'sonunda',
        quest: 'ultimately'),
    Words4(
        front: "He was knocked unconscious after being hit in the head.",
        back: "Başına vurulduktan sonra kendinden geçti.",
        list: 'B2',
        answer: 'kendinden geçmiş',
        quest: 'unconscious'),
    Words4(
        front: "The arrival of the storm was an unexpected event.",
        back: "Fırtınanın gelişi beklenmedik bir olaydı.",
        list: 'B2',
        answer: 'beklenmedik',
        quest: 'unexpected'),
    Words4(
        front: "Each snowflake has a unique and beautiful design.",
        back: "Her kar tanesinin eşsiz ve güzel bir tasarımı vardır.",
        list: 'B2',
        answer: 'benzersiz',
        quest: 'unique'),
    Words4(
        front:
            "Scientists are constantly trying to unravel the mysteries of the universe.",
        back:
            "Bilimciler, evrenin gizemlerini çözmeye sürekli olarak çalışıyorlar.",
        list: 'B2',
        answer: 'evren',
        quest: 'universe'),
    Words4(
        front: "The explorers ventured into the unknown territory.",
        back: "Kaşifler bilinmeyene doğru yolculuk yaptılar.",
        list: 'B2',
        answer: 'bilinmeyen',
        quest: 'unknown'),
    Words4(
        front: "Live on the upper floor if you prefer a quieter environment.",
        back: "Daha sakin bir ortam istiyorsanız üst katta oturun.",
        list: 'B2',
        answer: 'yukarı',
        quest: 'upper'),
    Words4(
        front: "The arrow shot upwards and hit the target exactly.",
        back: "Ok yukarı doğru fırladı ve hedefe tam olarak isabet etti.",
        list: 'B2',
        answer: 'yukarıya',
        quest: 'upwards'),
    Words4(
        front: "Tokyo is a large and bustling urban city.",
        back: "Tokyo, kalabalık ve hareketli bir şehirsel şehirdir.",
        list: 'B2',
        answer: 'şehirsel',
        quest: 'urban'),
    Words4(
        front: "He felt a sudden urge to eat chocolate.",
        back: "Aniden çikolata yeme dürtüsü hissetti.",
        list: 'B2',
        answer: 'dürtü',
        quest: 'urge'),
    Words4(
        front: "Honesty is a core value that we should all strive for.",
        back: "Dürüstlük, hepimizin uğraşması gereken temel bir değerdir.",
        list: 'B2',
        answer: 'değer',
        quest: 'value'),
    Words4(
        front: "The weather can vary greatly depending on the location.",
        back: "Hava durumu, konuma göre büyük ölçüde değişebilir.",
        list: 'B2',
        answer: 'farklı olmak',
        quest: 'vary'),
    Words4(
        front: "The ocean is a vast and mysterious place.",
        back: "Okyanus, engin ve gizemli bir yerdir.",
        list: 'B2',
        answer: 'vast',
        quest: 'vast'),
    Words4(
        front:
            "The concert will be held at a large venue that can accommodate a large crowd.",
        back:
            "Konser, kalabalık bir kitleyi barındırabilecek geniş bir mekanda düzenlenecek.",
        list: 'B2',
        answer: 'olayın gerçekleştiği yer',
        quest: 'venue'),
    Words4(
        front: "It was a very hot day, so we decided to stay indoors.",
        back: "Hava çok sıcaktı, bu yüzden içeride kalmaya karar verdik.",
        list: 'B2',
        answer: 'çok',
        quest: 'very'),
    Words4(
        front: "The message was sent via email.",
        back: "Mesaj e-posta yoluyla gönderildi.",
        list: 'B2',
        answer: 'vasıtasıyla',
        quest: 'via'),
    Words4(
        front: "The team celebrated their victory with a big party.",
        back: "Takım, zaferlerini büyük bir partiyle kutladı.",
        list: 'B2',
        answer: 'başarı',
        quest: 'victory'),
    Words4(
        front:
            "The news report showed scenes of violence in the war-torn country.",
        back:
            "Haber raporu, savaşın yıktığı ülkede şiddet sahnelerini gösterdi.",
        list: 'B2',
        answer: 'şiddet',
        quest: 'violence'),
    Words4(
        front:
            "They met in a virtual reality world created by computer software.",
        back:
            "Bilgisayar yazılımı tarafından oluşturulan sanal gerçeklik dünyasında buluştular.",
        list: 'B2',
        answer: 'sanal, asıl',
        quest: 'virtual'),
    Words4(
        front:
            "Having a clear vision for the future is important for achieving your goals.",
        back:
            "Gelecek için net bir vizyona sahip olmak, hedeflerinize ulaşmada önemlidir.",
        list: 'B2',
        answer: 'görme',
        quest: 'vision'),
    Words4(
        front: "The movie included some stunning visual effects.",
        back: "Filmde bazı çarpıcı görsel efektler vardı.",
        list: 'B2',
        answer: 'görsel',
        quest: 'visual'),
    Words4(
        front: "Clean water is a vital resource that is essential for life.",
        back: "Temiz su, yaşam için gerekli olan hayati bir kaynaktır.",
        list: 'B2',
        answer: 'yaşamsal',
        quest: 'vital'),
    Words4(
        front: "The employee asked for a raise in his wage.",
        back: "Çalışan, maaşına zam istedi.",
        list: 'B2',
        answer: 'maaş',
        quest: 'wage'),
    Words4(
        front: "There are many different ways to solve this problem.",
        back: "Bu problemi çözmenin birçok farklı yolu var.",
        list: 'B2',
        answer: 'yol',
        quest: 'way'),
    Words4(
        front: "He felt a sudden weakness after the long run.",
        back: "Uzun koşudan sonra ani bir halsizlik hissetti.",
        list: 'B2',
        answer: 'halsizlik',
        quest: 'weakness'),
    Words4(
        front: "He comes from a wealthy family.",
        back: "Zengin bir aileden geliyor.",
        list: 'B2',
        answer: 'varlık',
        quest: 'wealth'),
    Words4(
        front: "She is intelligent, whereas her brother is more athletic.",
        back: "Akıllı, oysa kardeşi daha atletik.",
        list: 'B2',
        answer: 'oysaki',
        quest: 'whereas'),
    Words4(
        front: "You can find this information wherever you look online.",
        back:
            "Bu bilgiyi çevrimiçi olarak nereye bakarsanız bakın bulabilirsiniz.",
        list: 'B2',
        answer: 'nerede',
        quest: 'wherever'),
    Words4(
        front: "They whispered secrets to each other in the dark.",
        back: "Karanlıkta birbirlerine fısıldaşarak sırlar söylediler.",
        list: 'B2',
        answer: 'fısıldamak',
        quest: 'whisper'),
    Words4(
        front: "To whom did you give the gift?",
        back: "Hediyeyi kime verdin?",
        list: 'B2',
        answer: 'kime',
        quest: 'whom'),
    Words4(
        front:
            "The news of the celebrity's death spread widely across social media.",
        back: "Ünlünün ölüm haberi sosyal medyada geniş çapta yayıldı.",
        list: 'B2',
        answer: 'genişçe',
        quest: 'widely'),
    Words4(
        front:
            "We saw many amazing animals on our safari trip, including lions, elephants, and zebras.",
        back:
            "Safari gezimizde aslanlar, filler ve zebralar da dahil olmak üzere birçok harika vahşi hayvan gördük.",
        list: 'B2',
        answer: 'yaban hayatı',
        quest: 'wildlife'),
    Words4(
        front: "Are you willing to help me with this project?",
        back: "Bu projeye bana yardım etmeye istekli misin?",
        list: 'B2',
        answer: 'gönüllü',
        quest: 'willing'),
    Words4(
        front: "The strong wind blew the leaves off the trees.",
        back: "Şiddetli rüzgar, yaprakları ağaçlardan savurdu.",
        list: 'B2',
        answer: 'rüzgar',
        quest: 'wind'),
    Words4(
        front: "The electrician wired the new house for electricity.",
        back: "Elektrikçi, yeni evi elektrik için kabloladı.",
        list: 'B2',
        answer: 'tel takmak',
        quest: 'wire'),
    Words4(
        front: "The old man was a wise and respected leader in his community.",
        back: "Yaşlı adam, toplumunda bilge ve saygı duyulan bir liderdi.",
        list: 'B2',
        answer: 'bilge',
        quest: 'wise'),
    Words4(
        front: "He witnessed the accident happen right in front of him.",
        back: "Kazanın tam önünde gerçekleştiğine şahit oldu.",
        list: 'B2',
        answer: 'şahit olmak',
        quest: 'witness'),
    Words4(
        front: "The situation is bad, but it could be worse.",
        back: "Durum kötü ama daha da kötüye gidebilir.",
        list: 'B2',
        answer: 'daha kötüsü',
        quest: 'worse'),
    Words4(
        front: "That was the worst experience of my life",
        back: "Hayatımın en kötü deneyimiydi.",
        list: 'B2',
        answer: 'en kötü',
        quest: 'worst' // replaced with a synonym
        ),
    Words4(
        front: "This painting is worth a fortune.",
        back: "Bu tablo bir servet değerinde.",
        list: 'B2',
        answer: 'değer',
        quest: 'worth'),
    Words4(
        front: "The doctor cleaned and bandaged the wound on his arm.",
        back: "Doktor kolundaki yarayı temizleyip sardı.",
        list: 'B2',
        answer: 'yaralamak',
        quest: 'wound'),
    Words4(
        front: "She wrapped herself in a warm blanket to keep warm.",
        back: "Sıcak kalmak için kendisini sıcak bir battaniyeye sardı.",
        list: 'B2',
        answer: 'sarmak',
        quest: 'wrap' // replaced with a synonym
        ),
    Words4(
        front: "I think you might be wrong about this.",
        back: "Sanırım bunda yanılıyor olabilirsin.",
        list: 'B2',
        answer: 'yanlış',
        quest: 'wrong'),
    Words4(
        front: "The work is not finished yet, there is still more to do.",
        back: "İş henüz bitmedi, yapılacak daha çok şey var.",
        list: 'B2',
        answer: 'henüz',
        quest: 'yet'),
    Words4(
        front: "The disaster zone was completely destroyed by the hurricane.",
        back: "Felaket bölgesi kasırga tarafından tamamen yok edildi.",
        list: 'B2',
        answer: 'bölge',
        quest: 'zone'),
  ];
}
