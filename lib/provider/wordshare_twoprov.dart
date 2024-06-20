import 'package:eng_card/data/gridview.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WordProvider2 extends ChangeNotifier {
  List<Words2> initialList2 = [];
  int lastIndex2 = 0;

  WordProvider2() {
    loadData2();
    _loadLastIndex();
    _initializeInitialList();
  }

  void _initializeInitialList() {
    initialList2 = List.from(wordsListTwo);
  }

  Future<void> _loadLastIndex() async {
    final prefs = await SharedPreferences.getInstance();
    lastIndex2 = prefs.getInt('lastIndex2') ?? 0;
    notifyListeners();
  }

  Future<void> _saveLastIndex() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('lastIndex2', lastIndex2);
  }

  void setLastIndex(int index) {
    lastIndex2 = index;
    _saveLastIndex();
    notifyListeners();
  }

  void loadData2() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    List<String>? questList2 = prefs.getStringList('questList2');
    List<String>? answerList2 = prefs.getStringList('answerList2');
    List<String>? backList2 = prefs.getStringList('backList2');
    List<String>? frontList2 = prefs.getStringList('frontList2');

    wordsListTwo.clear();

    if (questList2 != null &&
        answerList2 != null &&
        backList2 != null &&
        frontList2 != null) {
      for (int i = 0; i < questList2.length; i++) {
        Words2 word2 = Words2(
          list: 'A2',
          answer: answerList2[i],
          quest: questList2[i],
          back: backList2[i],
          front: frontList2[i],
        );
        wordsListTwo.add(word2);
      }
    } else {
      wordsListTwo = List.from(initialList2);
    }

    notifyListeners();
  }

  void saveData2() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> questList2 = [];
    List<String> answerList2 = [];
    List<String> backList2 = [];
    List<String> frontList2 = [];

    for (Words2 word2 in wordsListTwo) {
      questList2.add(word2.quest);
      answerList2.add(word2.answer);
      frontList2.add(word2.front);
      backList2.add(word2.back);
    }

    prefs.setStringList('questList2', questList2);
    prefs.setStringList('answerList2', answerList2);
    prefs.setStringList('backList2', backList2);
    prefs.setStringList('frontList2', frontList2);
    notifyListeners();
  }

  void deleteWord2(int index, BuildContext context) {
    if (wordsListTwo.isNotEmpty) {
      wordsListTwo.removeAt(index);
      if (index == wordsListTwo.length) {
        lastIndex2--;
        saveData2();
      }
      if (wordsListTwo.isEmpty) {
        Navigator.pop(context);
      } else {
        saveData2();
        notifyListeners();
      }
    }
  }

  void resetList2() {
    wordsListTwo.clear();
    wordsListTwo.addAll(initialList2);
    saveData2();
    notifyListeners();
  }

  List<Words2> wordsListTwo = [
    Words2(
        front: "What is your special ability?", // related to 'ability'
        back: "Yeteneklerin nelerdir?",
        list: "A2",
        answer: "yetenek",
        quest: "ability"),
    Words2(
        front: "Are you able to speak another language?", // related to 'able'
        back: "Başka bir dil konuşabiliyor musun?",
        list: "A2",
        answer: "hünerli",
        quest: "able"),
    Words2(
        front: "Have you ever traveled abroad?", // related to 'abroad'
        back: "Hiç yurt dışında seyahat ettin mi?",
        list: "A2",
        answer: "yurt dışında",
        quest: "abroad"),
    Words2(
        front: "Can you please accept this gift?", // related to 'accept'
        back: "Bu hediyeyi kabul edebilir misin?",
        list: "A2",
        answer: "kabul etmek",
        quest: "accept"),
    Words2(
        front: "It was an accident.", // related to 'accident'
        back: "Kazaydı.",
        list: "A2",
        answer: "rastlantı, kaza",
        quest: "accident"),
    Words2(
        front:
            "According to the news, it will rain tomorrow.", // related to 'according to'
        back: "Habere göre yarın yağmur yağacak.",
        list: "A2",
        answer: "göre",
        quest: "According to"),
    Words2(
        front: "What do you want to achieve in life?", // related to 'achieve'
        back: "Hayatta neyi başarmak istiyorsun?",
        list: "A2",
        answer: "başarmak",
        quest: "achieve"),
    Words2(
        front:
            "The play is a call to act on climate change.", // related to 'act'
        back: "Oyun, iklim değişikliği konusunda harekete geçmeye bir çağrı.",
        list: "A2",
        answer: "eylem",
        quest: "act"),
    Words2(
        front: "He is a very active person.", // related to 'active'
        back: "Çok aktif bir insan.",
        list: "A2",
        answer: "aktif",
        quest: "active"),
    Words2(
        front: "Actually, I was just leaving.", // related to 'actually'
        back: "Aslında, tam çıkıyordum.",
        list: "A2",
        answer: "aslında",
        quest: "Actually"),
    Words2(
        front: "She is an adult now.", // related to 'adult'
        back: "Artık o bir yetişkin.",
        list: "A2",
        answer: "yetişkin",
        quest: "adult"),
    Words2(
        front:
            "This company advertises its products on TV.", // related to 'advertise'
        back:
            "Bu şirket ürünlerini televizyonda реклаması yapıyor (reklam etmek).",
        list: "A2",
        answer: "reklamını yapmak",
        quest: "advertise"),
    Words2(
        front: "How can this decision affect me?", // related to 'affect'
        back: "Bu karar beni nasıl etkileyebilir?",
        list: "A2",
        answer: "etkilemek",
        quest: "affect"),
    Words2(
        front:
            "After I finish work, I will go to the gym.", // related to 'after'
        back: "İşten sonra spor salonuna gideceğim.",
        list: "A2",
        answer: "sonra",
        quest: "After"),
    Words2(
        front: "Are you against animal testing?", // related to 'against'
        back: "Hayvan deneylerine karşı mısınız?",
        list: "A2",
        answer: "aykırı",
        quest: "against"),
    Words2(
        front: "Which airline did you fly with?", // related to 'airline'
        back: "Hangi havayoluyla uçtun?",
        list: "A2",
        answer: "havayolu",
        quest: "airline"),
    Words2(
        front: "Is everything alive in the garden?", // related to 'alive'
        back: "Bahçedeki her şey canlı mı?",
        list: "A2",
        answer: "canlı",
        quest: "alive"),
    Words2(
        front: "All the students passed the exam.", // related to 'all'
        back: "Tüm öğrenciler sınavı geçti.",
        list: "A2",
        answer: "hepsi",
        quest: "All"),
    Words2(
        front: "Will you allow me to use your phone?", // related to 'allow'
        back: "Telefonunu kullanmama izin verir misin?",
        list: "A2",
        answer: "izin vermek",
        quest: "allow"),
    Words2(
        front: "I am almost finished.", // related to 'almost'
        back: "Neredeyse bitirdim.",
        list: "A2",
        answer: "neredeyse",
        quest: "almost"),
    Words2(
        front: "I prefer to be alone sometimes.", // related to 'alone'
        back: "Bazen yalnız olmayı tercih ederim.",
        list: "A2",
        answer: "yalnız",
        quest: "alone"),
    Words2(
        front: "We walked along the beach.", // related to 'along'
        back: "Plaj boyunca yürüdük.",
        list: "A2",
        answer: "boyunca",
        quest: "along"),
    Words2(
        front: "Have you eaten already?", // related to 'already'
        back: "Zaten yemek yedin mi?",
        list: "A2",
        answer: "zaten, çoktan",
        quest: "already"),
    Words2(
        front:
            "Although I was tired, I went for a run.", // related to 'although'
        back: "Yorgun olmama rağmen koşuya gittim.",
        list: "A2",
        answer: "her ne kadar",
        quest: "Although"),
    Words2(
        front: "Among my friends, I am the tallest.", // related to 'among'
        back: "Arkadaşlarım arasında en uzun boylu benim.",
        list: "A2",
        answer: "arasında",
        quest: "Among"),
    Words2(
        front:
            "The amount of rain this year is unusual.", // related to 'amount'
        back: "Bu yıl yağan yağmur miktarı alışılmadık.",
        list: "A2",
        answer: "miktar",
        quest: "amount"),
    Words2(
        front: "Have you seen any ancient ruins?", // related to 'ancient'
        back: "Herhangi antik kalıntı gördün mü?",
        list: "A2",
        answer: "antik",
        quest: "ancient"),
    Words2(
        front: "Be careful not to twist your ankle.", // related to 'ankle'
        back: "Dikkat et ayak bileğini burkma.",
        list: "A2",
        answer: "ayak bileği",
        quest: "ankle"),
    Words2(
      front: "Do you have any questions?",
      back: "Herhangi bir sorunuz var mı?",
      list: "A2",
      answer: "herhangi, her",
      quest: "any",
    ),
    Words2(
        front:
            "Is there anybody here who speaks French?", // related to 'anybody'
        back: "Burada Fransızca konuşan kimse var mı?",
        list: "A2",
        answer: "kimse",
        quest: "anybody"),
    Words2(
        front: "I don't go to the cinema anymore.", // related to 'anymore'
        back: "Artık sinemaya gitmiyorum.",
        list: "A2",
        answer: "artık",
        quest: "anymore"),
    Words2(
        front:
            "Anyway, let's move on to the next topic.", // related to 'anyway'
        back: "Her neyse, bir sonraki konuya geçelim.",
        list: "A2",
        answer: "her neyse",
        quest: "Anyway"),
    Words2(
        front:
            "Can you meet me anywhere in the city center?", // related to 'anywhere'
        back: "Şehrin merkezinde herhangi bir yerde benimle buluşabilir misin?",
        list: "A2",
        answer: "herhangi bir yer",
        quest: "anywhere"),
    Words2(
        front:
            "There are many useful apps available for learning languages.", // related to 'app'
        back: "Dil öğrenmek için birçok faydalı uygulama var.",
        list: "A2",
        answer: "uygulama",
        quest: "app"),
    Words2(
        front:
            "The magician made the rabbit appear out of thin air.", // related to 'appear'
        back: "Sihirbaz tavşanı yoktan var etti.",
        list: "A2",
        answer: "beli olmak",
        quest: "appear"),
    Words2(
        front:
            "She takes great care of her appearance.", // related to 'appearance'
        back: "Dış görünüşüne çok özen gösteriyor.",
        list: "A2",
        answer: "dış görünüş",
        quest: "appearance"),
    Words2(
        front: "How do I apply for this job?", // related to 'apply'
        back: "Bu işe nasıl başvurabilirim?",
        list: "A2",
        answer: "uygulamak",
        quest: "apply"),
    Words2(
        front:
            "This building was designed by a famous architect.", // related to 'architect'
        back: "Bu bina ünlü bir mimar tarafından tasarlandı.",
        list: "A2",
        answer: "mimar",
        quest: "architect"),
    Words2(
        front:
            "They are always argue/ing about something.", // related to 'argue' (already defined)
        back: "Her zaman bir şey hakkında tartışıyorlar.",
        list: "A2",
        answer: "tartışmak",
        quest: "argue"),
    Words2(
        front:
            "They had a strong argument about the movie.", // related to 'argument'
        back: "Film hakkında güçlü bir argümanları vardı.",
        list: "A2",
        answer: "argüman",
        quest: "argument"),
    Words2(
        front: "He joined the army after graduation.", // related to 'army'
        back: "Mezuniyetten sonra orduya katıldı.",
        list: "A2",
        answer: "ordu",
        quest: "army"),
    Words2(
        front:
            "Can you arrange a meeting for tomorrow?", // related to 'arrange'
        back: "Yarın için bir toplantı ayarlayabilir misin?",
        list: "A2",
        answer: "ayarlamak",
        quest: "arrange"),
    Words2(
        front: "He works as a doctor.", // related to 'as'
        back: "Doktor olarak çalışıyor.",
        list: "A2",
        answer: "olarak, gibi",
        quest: "as"),
    Words2(
        front:
            "The city was under attack during the war.", // related to 'attack'
        back: "Şehir savaş sırasında saldırı altındaydı.",
        list: "A2",
        answer: "saldırı",
        quest: "attack"),
    Words2(
        front: "Will you attend the conference?", // related to 'attend'
        back: "Konferansa katılacak mısın?",
        list: "A2",
        answer: "katılmak",
        quest: "attend"),
    Words2(
        front: "He needs more attention in class.", // related to 'attention'
        back: "Derste daha fazla ilgiye ihtiyacı var.",
        list: "A2",
        answer: "ilgilenme",
        quest: "attention"),
    Words2(
        front: "She is a very attractive woman.", // related to 'attractive'
        back: "Çok çekici bir kadın.",
        list: "A2",
        answer: "çekici",
        quest: "attractive"),
    Words2(
        front:
            "The play was performed for a large audience.", // related to 'audience'
        back: "Oyun, geniş bir seyirci kitlesi için sergilendi.",
        list: "A2",
        answer: "seyirci",
        quest: "audience"),
    Words2(
        front: "Who is the author of this book?", // related to 'author'
        back: "Bu kitabın yazarı kim?",
        list: "A2",
        answer: "yazar",
        quest: "author"),
    Words2(
        front:
            "Is there a(n) available table for two?", // related to 'available'
        back: "İki kişilik boşta bir masa var mı?",
        list: "A2",
        answer: "boş, mevcut",
        quest: "available"),
    Words2(
        front:
            "The average price of a house in this city is very high.", // related to 'average'
        back: "Bu şehirde bir evin ortalama fiyatı çok yüksek.",
        list: "A2",
        answer: "ortalama",
        quest: "average"),
    Words2(
        front: "We should try to avoid making mistakes.", // related to 'avoid'
        back: "Hata yapmaktan kaçınmalıyız.",
        list: "A2",
        answer: "kaçınma",
        quest: "avoid"),
    Words2(
        front: "She won an award for her bravery.", // related to 'award'
        back: "Cesaretinden dolayı bir ödül kazandı.",
        list: "A2",
        answer: "ödül",
        quest: "award"),
    Words2(
        front: "The weather was awful today.", // related to 'awful'
        back: "Hava bugün berbattı.",
        list: "A2",
        answer: "berbat",
        quest: "awful"),
    Words2(
        front: "Come back tomorrow.", // related to 'back'
        back: "Yarın geri gel.",
        list: "A2",
        answer: "arka, geri",
        quest: "back"),
    Words2(
        front:
            "He has a degree in background in computer science.", // related to 'background'
        back: "Bilgisayar bilimleri alanında bir arka planı var.",
        list: "A2",
        answer: "arka plan",
        quest: "background"),
    Words2(
        front: "He played very badly yesterday.", // related to 'badly'
        back: "Dün çok kötü oynadı.",
        list: "A2",
        answer: "kötü bir şekilde",
        quest: "badly"),
    Words2(
        front: "This decision is based on research.", // related to 'based'
        back: "Bu karar araştırmaya dayanmaktadır.",
        list: "A2",
        answer: "temeli",
        quest: "based"),
    Words2(
        front: "Do you like beans?", // related to 'bean'
        back: "Fasulye sever misin?",
        list: "A2",
        answer: "fasulye",
        quest: "bean"),
    Words2(
        front: "I saw a bear in the forest.", // related to 'bear'
        back: "Ormanda bir ayı gördüm.",
        list: "A2",
        answer: "ayı",
        quest: "bear"),
    Words2(
        front: "The boxer beat his opponent.", // related to 'beat'
        back: "Boksör rakibini yendi.",
        list: "A2",
        answer: "darbe",
        quest: "beat"),
    Words2(
        front: "Would you like some beef?", // related to 'beef'
        back: " biraz sığır eti ister misin?",
        list: "A2",
        answer: "et",
        quest: "beef"),
    Words2(
        front:
            "Before you start, let me explain the rules.", // related to 'before'
        back: "Başlamadan önce kuralları açıklayayım.",
        list: "A2",
        answer: "önce",
        quest: "Before"),
    Words2(
        front: "Please behave in class.", // related to 'behave'
        back: "Lütfen sınıfta davranışlarına dikkat et.",
        list: "A2",
        answer: "davranmak",
        quest: "behave"),
    Words2(
        front:
            "Her behaviour at school was good last year.", // related to 'behaviour'
        back: "Geçen sene okul davranışları iyiydi.",
        list: "A2",
        answer: "davranış",
        quest: "behaviour"),
    Words2(
        front: "This book belongs to me.", // related to 'belong'
        back: "Bu kitap bana ait.",
        list: "A2",
        answer: "ait olmak",
        quest: "belong"),
    Words2(
        front: "Can you tighten my belt?", // related to 'belt'
        back: "Kemerimi sıkabilir misin?",
        list: "A2",
        answer: "kemer",
        quest: "belt"),
    Words2(
        front:
            "Regular exercise has many benefits for your health.", // related to 'benefit'
        back: "Düzenli egzersizin sağlığınız için birçok faydası vardır.",
        list: "A2",
        answer: "menfaat",
        quest: "benefit"),
    Words2(
        front: "Which is the best restaurant in town?", // related to 'best'
        back: "Şehrin en iyi restoranı hangisi?",
        list: "A2",
        answer: "en iyisi",
        quest: "best"),
    Words2(
        front: "This milk is better than the other one.", // related to 'better'
        back: "Bu süt diğerinden daha iyi.",
        list: "A2",
        answer: "daha iyi",
        quest: "better"),
    Words2(
        front: "He sat between his two friends.", // related to 'between'
        back: "İki arkadaşı arasında oturdu.",
        list: "A2",
        answer: "arasında",
        quest: "between"),
    Words2(
        front:
            "The population of the world is over seven billion.", // related to 'billion'
        back: "Dünya nüfusu yedi milyardan fazla.",
        list: "A2",
        answer: "milyar",
        quest: "billion"),
    Words2(
        front: "Please throw this paper in the bin.", // related to 'bin'
        back: "Lütfen bu kağıdı çöp kutusuna at.",
        list: "A2",
        answer: "çöp kutusu",
        quest: "bin"),
    Words2(
        front: "What is your date of birth?", // related to 'birth'
        back: "Doğum tarihiniz nedir?",
        list: "A2",
        answer: "doğum",
        quest: "birth"),
    Words2(
        front:
            "Would you like a biscuit with your tea?", // related to 'biscuit'
        back: "Çayınızın yanında bisküvi ister misiniz?",
        list: "A2",
        answer: "bisküvi",
        quest: "biscuit"),
    Words2(
        front:
            "Leave the form blank if you don't have that information.", // related to 'blank'
        back: "Bu bilgi yoksa formu boş bırakın.",
        list: "A2",
        answer: "boş",
        quest: "blank"),
    Words2(
        front:
            "The doctor took a blood sample for testing.", // related to 'blood'
        back: "Doktor test için kan örneği aldı.",
        list: "A2",
        answer: "kan",
        quest: "blood"),
    Words2(
        front: "The wind is blowing hard today.", // related to 'blow'
        back: "Bugün rüzgar sert esiyor.",
        list: "A2",
        answer: "esmek",
        quest: "blow"),
    Words2(
        front:
            "There is an announcement board in the hall.", // related to 'board'
        back: "Salonda bir anons panosu var.",
        list: "A2",
        answer: "pano",
        quest: "board"),
    Words2(
        front:
            "The water is boiling - be careful not to touch it!", // related to 'boil'
        back: "Su kaynıyor - dokunmamaya dikkat edin!",
        list: "A2",
        answer: "kaynamak",
        quest: "boil"),
    Words2(
        front: "I broke my bone in an accident.", // related to 'bone'
        back: "Kazada kemiğimi kırdım.",
        list: "A2",
        answer: "kemik",
        quest: "bone"),
    Words2(
        front: "I am reading an interesting book.", // related to 'book'
        back: "İlginç bir kitap okuyorum.",
        list: "A2",
        answer: "kitap",
        quest: "book"),
    Words2(
        front: "Can I borrow your pen?", // related to 'borrow'
        back: "Kalemini ödünç alabilir miyim?",
        list: "A2",
        answer: "ödünç almak",
        quest: "borrow"),
    Words2(
        front: "I need to speak to the boss.", // related to 'boss'
        back: "Patronla konuşmam gerekiyor.",
        list: "A2",
        answer: "patron",
        quest: "boss"),
    Words2(
        front: "Sit at the bottom of the stairs.", // related to 'bottom'
        back: "Merdivenlerin dibine otur.",
        list: "A2",
        answer: "dip",
        quest: "bottom"),
    Words2(
        front: "Please give me a bowl of soup.", // related to 'bowl'
        back: " Bana bir kase çorba verir misin?",
        list: "A2",
        answer: "kase",
        quest: "bowl"),
    Words2(
        front: "The human brain is a complex organ.", // related to 'brain'
        back: "İnsan beyni karmaşık bir organdır.",
        list: "A2",
        answer: "beyin",
        quest: "brain"),
    Words2(
        front: "We crossed the river by bridge.", // related to 'bridge'
        back: "Nehri köprüden geçtik.",
        list: "A2",
        answer: "köprü",
        quest: "bridge"),
    Words2(
        front: "The sun is shining brightly today.", // related to 'bright'
        back: "Bugün güneş parlak bir şekilde parlıyor.",
        list: "A2",
        answer: "parlak",
        quest: "bright"),
    Words2(
        front: "That was a brilliant idea!", // related to 'brilliant'
        back: "Ne harika bir fikirdi!",
        list: "A2",
        answer: "nefis",
        quest: "brilliant"),
    Words2(
        front:
            "My phone is broken. I need to get it fixed.", // related to 'broken'
        back: "Telefonum bozuk. Tamir ettirmem gerekiyor.",
        list: "A2",
        answer: "arızalı",
        quest: "broken"),
    Words2(
        front: "Please brush your teeth before bed.", // related to 'brush'
        back: "Lütfen yatmadan önce dişlerinizi fırçalayın.",
        list: "A2",
        answer: "fırçalamak",
        quest: "brush"),
    Words2(
        front:
            "Be careful not to burn yourself on the stove.", // related to 'burn'
        back: "Ocağa yakmamaya dikkat edin.",
        list: "A2",
        answer: "yakmak",
        quest: "burn"),
    Words2(
        front: "He is a successful businessman.", // related to 'businessman'
        back: "Başarılı bir iş adamı.",
        list: "A2",
        answer: "iş adamı",
        quest: "businessman"),
    Words2(
        front: "Can you help me button my button?", // related to 'button'
        back: "Düğmeme bastırmama yardım edebilir misin?",
        list: "A2",
        answer: "düğme",
        quest: "button"),
    Words2(
        front: "We are going camping this weekend.", // related to 'camping'
        back: "Bu hafta sonu kamp yapmaya gidiyoruz.",
        list: "A2",
        answer: "kamp yapma",
        quest: "camping"),
    Words2(
        front: "Can I have a can of cola, please?", // related to 'can'
        back: "Bana bir kola kutusu alabilir miyim?",
        list: "A2",
        answer: "teneke",
        quest: "can"),
    Words2(
        front: "You need to take better care of your car.", // related to 'care'
        back: "Arabanızın daha iyi bakımını yapmanız gerekiyor.",
        list: "A2",
        answer: "bakım, dikkat",
        quest: "care"),
    Words2(
        front: "Be careful when crossing the street.", // related to 'careful'
        back: "Yoldan geçerken dikkatli olun.",
        list: "A2",
        answer: "dikkatli",
        quest: "careful"),
    Words2(
        front:
            "There is a beautiful carpet on the floor.", // related to 'carpet'
        back: "Yerde güzel bir halı var.",
        list: "A2",
        answer: "halı",
        quest: "carpet"),
    Words2(
        front: "I love watching funny cartoons.", // related to 'cartoon'
        back: "Komik çizgi filmleri izlemeyi seviyorum.",
        list: "A2",
        answer: "karikatür",
        quest: "cartoon"),
    Words2(
        front: "The case is still under investigation.", // related to 'case'
        back: "Dava hala soruşturma altında.",
        list: "A2",
        answer: "dava",
        quest: "case"),
    Words2(
        front:
            "Do you have enough cash to pay for the taxi?", // related to 'cash'
        back: "Taksiyi ödeyecek kadar nakit paranız var mı?",
        list: "A2",
        answer: "nakit",
        quest: "cash"),
    Words2(
        front:
            "We visited a beautiful old castle on our trip.", // related to 'castle'
        back: "Gezimizde güzel bir eski kaleyi ziyaret ettik.",
        list: "A2",
        answer: "kale",
        quest: "castle"),
    Words2(
        front:
            "The bus driver tried to catch the speeding car.", // related to 'catch'
        back: "Otobüs şoförü hız yapan arabayı yakalamaya çalıştı.",
        list: "A2",
        answer: "yakalamak",
        quest: "catch"),
    Words2(
        front: "What is the cause of the problem?", // related to 'cause'
        back: "Sorunun nedeni nedir?",
        list: "A2",
        answer: "sebep",
        quest: "cause"),
    Words2(
        front:
            "Let's celebrate your birthday this weekend!", // related to 'celebrate'
        back: "Doğum gününüzü bu hafta sonu kutlayalım!",
        list: "A2",
        answer: "kutlamak",
        quest: "celebrate"),
    Words2(
        front: "He is a famous celebrity.", // related to 'celebrity'
        back: "O ünlü birisi.",
        list: "A2",
        answer: "ünlü kişi",
        quest: "celebrity"),
    Words2(
        front:
            "Are you certain you want to quit your job?", // related to 'certain'
        back: "İşinizden ayrılmak istediğinizden emin misiniz?",
        list: "A2",
        answer: "kesin",
        quest: "certain"),
    Words2(
        front: "I will certainly help you.", // related to 'certainly'
        back: "Size kesinlikle yardım edeceğim.",
        list: "A2",
        answer: "kesinlikle",
        quest: "certainly"),
    Words2(
        front: "There is a chance it will rain today.", // related to 'chance'
        back: "Bugün yağmur yağma ihtimali var.",
        list: "A2",
        answer: "şans",
        quest: "chance"),
    Words2(
        front: "They donated money to charity.", // related to 'charity'
        back: "Hayır kurumuna para bağışladılar.",
        list: "A2",
        answer: "hayırseverlik",
        quest: "charity"),
    Words2(
        front: "Can we chat for a while?", // related to 'chat'
        back: "Bir süre sohbet edebilir miyiz?",
        list: "A2",
        answer: "sohbet",
        quest: "chat"),
    Words2(
        front:
            "Please check your homework before you hand it in.", // related to 'check'
        back: "Ödevini teslim etmeden önce lütfen kontrol et.",
        list: "A2",
        answer: "kontrol",
        quest: "check"),
    Words2(
        front:
            "He is a talented chef who cooks delicious food.", // related to 'chef'
        back: "O, lezzetli yemekler yapan yetenekli bir şef.",
        list: "A2",
        answer: "şef",
        quest: "chef"),
    Words2(
        front:
            "I am learning about chemistry in science class.", // related to 'chemistry'
        back: "Fen bilgisi dersinde kimya öğreniyorum.",
        list: "A2",
        answer: "kimyasal",
        quest: "chemistry"),
    Words2(
        front: "What is your choice - tea or coffee?", // related to 'choice'
        back: "Seçeneğiniz nedir - çay mı kahve mi?",
        list: "A2",
        answer: "tercih",
        quest: "choice"),
    Words2(
        front:
            "There is a beautiful old church in the city center.", // related to 'church'
        back: "Şehrin merkezinde güzel ve eski bir kilise var.",
        list: "A2",
        answer: "kilise",
        quest: "church"),
    Words2(
        front:
            "The water is very clear - you can see the bottom of the lake.", // related to 'clear'
        back: "Su çok temiz - gölün dibini görebilirsiniz.",
        list: "A2",
        answer: "temiz",
        quest: "clear"),
    Words2(
        front:
            "Please speak clearly so I can understand you.", // related to 'clearly'
        back: "Anlayabilmem için lütfen açıkça konuşun.",
        list: "A2",
        answer: "açıkça",
        quest: "clearly"),
    Words2(
        front: "He is a very clever boy.", // related to 'clever'
        back: "Çok zeki bir çocuk.",
        list: "A2",
        answer: "zeki",
        quest: "clever"),
    Words2(
        front:
            "The weather is affected by the climate.", // related to 'climate'
        back: "Hava iklimden etkilenir.",
        list: "A2",
        answer: "iklim",
        quest: "climate"),
    Words2(
        front: "Please close the door when you leave.", // related to 'close'
        back: "Çıkarken lütfen kapıyı kapatın.",
        list: "A2",
        answer: "kapamak",
        quest: "close"),
    Words2(
        front: "The shops are all closed on Sundays.", // related to 'closed'
        back: "Pazar günleri tüm dükkanlar kapalı.",
        list: "A2",
        answer: "kapalı",
        quest: "closed"),
    Words2(
        front:
            "She likes to wear comfortable clothing.", // related to 'clothing'
        back: "Rahat giysiler giymeyi sever.",
        list: "A2",
        answer: "giysi",
        quest: "clothing"),
    Words2(
        front: "There is a big white cloud in the sky.", // related to 'cloud'
        back: "Gökyüzünde büyük beyaz bir bulut var.",
        list: "A2",
        answer: "bulut",
        quest: "cloud"),
    Words2(
        front:
            "He is a football coach for the youth team.", // related to 'coach'
        back: "O, gençlik takımının futbol antrenörü.",
        list: "A2",
        answer: "antrenör",
        quest: "coach"),
    Words2(
        front:
            "We are spending our vacation on the coast.", // related to 'coast'
        back: "Tatilimizi sahil kenarında geçiriyoruz.",
        list: "A2",
        answer: "deniz kenarı",
        quest: "coast"),
    Words2(
        front: "Please enter your secret code.", // related to 'code'
        back: "Lütfen gizli kodunuzu girin.",
        list: "A2",
        answer: "şifre",
        quest: "code"),
    Words2(
        front:
            "We need to collect the leaves from the garden.", // related to 'collect'
        back: " bahçeden yaprakları toplamamız gerekiyor.",
        list: "A2",
        answer: "toplamak",
        quest: "collect"),
    Words2(
        front:
            "There is a beautiful ancient column in the square.", // related to 'column'
        back: "Meydanda güzel ve antik bir sütun var.",
        list: "A2",
        answer: "sütun",
        quest: "column"),
    Words2(
        front:
            "I would like to watch a comedy movie tonight.", // related to 'comedy'
        back: "Bu akşam komedi filmi izlemek isterdim.",
        list: "A2",
        answer: "komedi",
        quest: "comedy"),
    Words2(
        front:
            "I am wearing comfortable clothes for the trip.", // related to 'comfortable'
        back: "Gezi için rahat giysiler giyiyorum.",
        list: "A2",
        answer: "rahat",
        quest: "comfortable"),
    Words2(
        front:
            "Can you leave a comment on my blog post?", // related to 'comment'
        back: "Blog yazım hakkında yorum bırakabilir misin?",
        list: "A2",
        answer: "yorum",
        quest: "comment"),
    Words2(
        front:
            "I feel a sense of belonging to my local community.", // related to 'community'
        back: "Yerel topluluğuma ait olma duygusu hissediyorum.",
        list: "A2",
        answer: "topluluk",
        quest: "community"),
    Words2(
        front: "Do you want to compete in the race?", // related to 'compete'
        back: "Yarışmada yarışmak ister misin?",
        list: "A2",
        answer: "yarışmak",
        quest: "compete"),
    Words2(
        front:
            "The swimming competition is next week.", // related to 'competition'
        back: "Yüzme yarışması gelecek hafta.",
        list: "A2",
        answer: "yarışma",
        quest: "competition"),
    Words2(
        front:
            "He always complains about the weather.", // related to 'complain'
        back: "Her zaman hava şartlarından şikayet eder.",
        list: "A2",
        answer: "şikayet etmek",
        quest: "complain"),
    Words2(
        front: "I completely agree with you.", // related to 'completely'
        back: "Sana tamamen katılıyorum.",
        list: "A2",
        answer: "tamamen",
        quest: "completely"),
    Words2(
        front:
            "I can't go swimming because of the weather conditions.", // related to 'condition'
        back: "Hava koşulları nedeniyle yüzemeye gidiyorum.",
        list: "A2",
        answer: "şart",
        quest: "condition"),
    Words2(
        front:
            "There is a business conference in the city next month.", // related to 'conference'
        back: "Önümüzdeki ay şehirde bir iş konferansı var.",
        list: "A2",
        answer: "görüşme",
        quest: "conference"),
    Words2(
        front:
            "Can you connect your phone to the Wi-Fi?", // related to 'connect'
        back: "Telefonunuzu Wi-Fi'ye bağlayabilir misiniz?",
        list: "A2",
        answer: "bağlanmak",
        quest: "connect"),
    Words2(
        front:
            "My phone is not connected to the internet.", // related to 'connected'
        back: "Telefonum internete bağlı değil.",
        list: "A2",
        answer: "bağlı",
        quest: "connected"),
    Words2(
        front:
            "You need to consider all your options before making a decision.", // related to 'consider'
        back: "Karar vermeden önce tüm seçeneklerinizi dikkate almalısınız.",
        list: "A2",
        answer: "dikkate almak",
        quest: "consider"),
    Words2(
        front: "This box contains fragile items.", // related to 'contain'
        back: "Bu kutu kırılgan eşyalar içeriyor.",
        list: "A2",
        answer: "kapsamak",
        quest: "contain"),
    Words2(
        front:
            "I don't understand the context of this sentence.", // related to 'context'
        back: "Bu cümlenin bağlamını anlamıyorum.",
        list: "A2",
        answer: "bağlam",
        quest: "context"),
    Words2(
        front:
            "Asia is the largest continent in the world.", // related to 'continent'
        back: "Asya, dünyanın en büyük kıtasıdır.",
        list: "A2",
        answer: "kıta",
        quest: "continent"),
    Words2(
        front: "Please continue reading the story.", // related to 'continue'
        back: "Lütfen hikayeyi okumaya devam edin.",
        list: "A2",
        answer: "devam ettirmek",
        quest: "continue"),
    Words2(
        front:
            "You need to be in control of your emotions.", // related to 'control'
        back: "Duygularınızı kontrol altında tutmanız gerekir.",
        list: "A2",
        answer: "kontrol",
        quest: "control"),
    Words2(
        front: "Can you cook dinner tonight?", // related to 'cook'
        back: "Bu akşam yemek pişirebilir misin?",
        list: "A2",
        answer: "pişirmek",
        quest: "cook"),
    Words2(
        front: "Please turn on the cooker.", // related to 'cooker'
        back: "Lütfen ocağı aç.",
        list: "A2",
        answer: "ocak",
        quest: "cooker"),
    Words2(
        front: "Can I have a copy of your notes?", // related to 'copy'
        back: "Notlarınızın bir kopyasını alabilir miyim?",
        list: "A2",
        answer: "kopya",
        quest: "copy"),
    Words2(
        front: "There is a bookstore around the corner.", // related to 'corner'
        back: "Köşede bir kitapevi var.",
        list: "A2",
        answer: "köşe",
        quest: "corner"),
    Words2(
        front:
            "Did you answer the question correctly?", // related to 'correctly'
        back: "Soruyu doğru cevapladın mı?",
        list: "A2",
        answer: "doğru",
        quest: "correctly"),
    Words2(
        front: "Let's count how many apples there are.", // related to 'count'
        back: "Kaç tane elma olduğunu sayalım.",
        list: "A2",
        answer: "saymak",
        quest: "count"),
    Words2(
        front:
            "We saw a happy couple walking in the park.", // related to 'couple'
        back: "Parkta yürüyen mutlu bir çift gördük.",
        list: "A2",
        answer: "çift",
        quest: "couple"),
    Words2(
        front: "Can you put the cover on the box?", // related to 'cover'
        back: "Kutunun kapağını kapatabilir misin?",
        list: "A2",
        answer: "örtü, kılıf",
        quest: "cover"),
    Words2(
        front: "He is acting a bit crazy today.", // related to 'crazy'
        back: "Bugün biraz deli davranıyor.",
        list: "A2",
        answer: "deli",
        quest: "crazy"),
    Words2(
        front: "She is a very creative artist.", // related to 'creative'
        back: "O çok yaratıcı bir sanatçı.",
        list: "A2",
        answer: "yaratıcı",
        quest: "creative"),
    Words2(
        front:
            "Can I give you some credit for the bus fare?", // related to 'credit'
        back: "Otobüs bileti için sana biraz borç verebilir miyim?",
        list: "A2",
        answer: "kredi",
        quest: "credit"),
    Words2(
        front: "Stealing is a crime.", // related to 'crime'
        back: "Çalmak bir suçtur.",
        list: "A2",
        answer: "suç",
        quest: "crime"),
    Words2(
        front:
            "The police are looking for the criminal.", // related to 'criminal'
        back: "Polis suçluyu arıyor.",
        list: "A2",
        answer: "suçlu",
        quest: "criminal"),
    Words2(
        front:
            "Please walk on the other side of the street - it's too crowded here.", // related to 'cross'
        back:
            "Lütfen caddenin diğer tarafından yürüyün - burada çok kalabalık.",
        list: "A2",
        answer: "kalabalık",
        quest: "crowd"),
    Words2(
        front:
            "She started to cry when she heard the news.", // related to 'cry'
        back: "Haberi duyunca ağlamaya başladı.",
        list: "A2",
        answer: "ağlamak",
        quest: "cry"),
    Words2(
        front:
            "There are some plates in the cupboard.", // related to 'cupboard'
        back: "Dolapta bazı tabaklar var.",
        list: "A2",
        answer: "dolap",
        quest: "cupboard"),
    Words2(
        front: "She has beautiful, long curly hair.", // related to 'curly'
        back: "Uzun ve güzel kıvırcık saçları var.",
        list: "A2",
        answer: "kıvırcık",
        quest: "curly"),
    Words2(
        front: "The seasons change in a natural cycle.", // related to 'cycle'
        back: "Mevsimler doğal bir döngü içinde değişir.",
        list: "A2",
        answer: "devir",
        quest: "cycle"),
    Words2(
        front:
            "I read a daily newspaper to keep up with current events.", // related to 'daily'
        back: "Günlük bir gazete okuyarak güncel olayları takip ediyorum.",
        list: "A2",
        answer: "günlük",
        quest: "daily"),
    Words2(
        front:
            "Be careful, crossing the street alone at night can be dangerous.", // related to 'danger'
        back:
            "Dikkatli ol, gece tek başına karşıdan karşıya geçmek tehlikeli olabilir.",
        list: "A2",
        answer: "tehlikeli",
        quest: "danger"),
    Words2(
        front: "It's too dark to read without a lamp.", // related to 'dark'
        back: "Lamba olmadan okumak için çok karanlık.",
        list: "A2",
        answer: "koyu",
        quest: "dark"),
    Words2(
        front:
            "The scientist is analyzing scientific data.", // related to 'data'
        back: "Bilim insanı bilimsel verileri analiz ediyor.",
        list: "A2",
        answer: "veri",
        quest: "data"),
    Words2(
        front: "Sadly, the old dog is dead.", // related to 'dead'
        back: "Ne yazık ki, yaşlı köpek öldü.",
        list: "A2",
        answer: "ölü",
        quest: "dead"),
    Words2(
        front:
            "We made a deal to share the cost of the taxi.", // related to 'deal'
        back: "Taksi ücretini paylaşmak için bir anlaşma yaptık.",
        list: "A2",
        answer: "anlaşmak",
        quest: "deal"),
    Words2(
        front: "Dear John, How are you?", // related to 'dear'
        back: "Sevgili John, Nasılsın?",
        list: "A2",
        answer: "sevgili",
        quest: "Dear"),
    Words2(
        front:
            "Her death was a great loss to the family.", // related to 'death'
        back: "Onun ölümü aile için büyük bir kayıp oldu.",
        list: "A2",
        answer: "ölüm",
        quest: "death"),
    Words2(
        front:
            "Making a good decision can be difficult.", // related to 'decision'
        back: "Doğru bir karar vermek zor olabilir.",
        list: "A2",
        answer: "karar",
        quest: "decision"),
    Words2(
        front: "The lake is very deep.", // related to 'deep'
        back: "Göl çok derindir.",
        list: "A2",
        answer: "derin",
        quest: "deep"),
    Words2(
        front:
            "I definitely want to go to the concert.", // related to 'definitely'
        back: "Kesinlikle konsere gitmek istiyorum.",
        list: "A2",
        answer: "kesinlikle",
        quest: "definitely"),
    Words2(
        front:
            "The temperature today is 30 degrees Celsius.", // related to 'degree'
        back: "Bugün hava sıcaklığı 30 derece Celsius.",
        list: "A2",
        answer: "derece",
        quest: "degree"),
    Words2(
        front:
            "I need to see the dentist because I have a toothache.", // related to 'dentist'
        back: "Diş ağrım olduğu için dişçiye gitmem gerekiyor.",
        list: "A2",
        answer: "dişçi",
        quest: "dentist"),
    Words2(
        front:
            "She works in the marketing department.", // related to 'department'
        back: "Pazarlama bölümünde çalışıyor.",
        list: "A2",
        answer: "departman, bölüm",
        quest: "department"),
    Words2(
        front:
            "Your success will depend on your hard work.", // related to 'depend'
        back: "Başarın sıkı çalışmana bağlı olacak.",
        list: "A2",
        answer: "bağlı olmak",
        quest: "depend"),
    Words2(
        front: "The Sahara is a large desert in Africa.", // related to 'desert'
        back: "Sahra, Afrika'da bulunan geniş bir çöldür.",
        list: "A2",
        answer: "çöl",
        quest: "desert"),
    Words2(
        front: "She is a talented graphic designer.", // related to 'designer'
        back: " yetenekli bir grafik tasarımcısıdır.",
        list: "A2",
        answer: "tasarımcı",
        quest: "designer"),
    Words2(
        front:
            "The army completely destroyed the enemy's base.", // related to 'destroy'
        back: "Ordu, düşmanın üssünü tamamen yok etti.",
        list: "A2",
        answer: "imha etmek",
        quest: "destroy"),
    Words2(
        front:
            "The detective is investigating the crime scene.", // related to 'detective'
        back: "Dedektif suç mahallini araştırıyor.",
        list: "A2",
        answer: "dedektif",
        quest: "detective"),
    Words2(
        front:
            "This software is constantly being developed.", // related to 'develop'
        back: "Bu yazılım sürekli olarak geliştiriliyor.",
        list: "A2",
        answer: "geliştirmek",
        quest: "develop"),
    Words2(
        front:
            "Can you turn off your electronic devices before boarding the airplane?", // related to 'device'
        back:
            "Uçağa binmeden önce elektronik cihazlarınızı kapatabilir misiniz?",
        list: "A2",
        answer: "cihaz",
        quest: "device"),
    Words2(
        front:
            "I write my thoughts down in my diary every night.", // related to 'diary' (corrected closing quotation mark)
        back: "Her gece düşüncelerimi günlüğüme yazarım.",
        list: "A2",
        answer: "günlük",
        quest: "diary"),
    Words2(
        front:
            "They did things differently in the past.", // related to 'differently'
        back: "Geçmişte işleri farklı yaptılar.",
        list: "A2",
        answer: "farklı",
        quest: "differently"),
    Words2(
        front:
            "The teacher directed the students to the library.", // related to 'direct'
        back: "Öğretmen öğrencileri kütüphaneye yönlendirdi.",
        list: "A2",
        answer: "yöneltmek",
        quest: "direct"),
    Words2(
        front:
            "Please walk straight ahead - that's the right direction.", // related to 'direction'
        back: "Lütfen düz yürüyün - bu doğru yön.",
        list: "A2",
        answer: "yön",
        quest: "direction"),
    Words2(
        front:
            "The film is directed by a famous director.", // related to 'director'
        back: "Film ünlü bir yönetmen tarafından yönetiliyor.",
        list: "A2",
        answer: "yönetmen",
        quest: "director"),
    Words2(
        front:
            "I disagree with your opinion on this matter.", // related to 'disagree'
        back: "Bu konudaki görüşüne katılmıyorum.",
        list: "A2",
        answer: "aynı fikirde olmamak",
        quest: "disagree"),
    Words2(
        front:
            "The magician made the rabbit disappear in a puff of smoke.", // related to 'disappear'
        back: "Sihirbaz tavşanı bir duman bulutunda yok etti.",
        list: "A2",
        answer: "yok olmak",
        quest: "disappear"),
    Words2(
        front:
            "The earthquake was a terrible disaster.", // related to 'disaster'
        back: "Deprem korkunç bir felaketti.",
        list: "A2",
        answer: "felaket",
        quest: "disaster"),
    Words2(
        front:
            "The explorer discovered a new island in the Pacific Ocean.", // related to 'discover'
        back: "Kaşif Pasifik Okyanusu'nda yeni bir ada keşfetti.",
        list: "A2",
        answer: "keşfetmek",
        quest: "discover"),
    Words2(
        front:
            "The discovery of penicillin revolutionized medicine.", // related to 'discovery'
        back: "Penisilinin keşfi tıp alanında devrim yarattı.",
        list: "A2",
        answer: "keşif",
        quest: "discovery"),
    Words2(
        front:
            "We had a discussion about the best way to solve the problem.", // related to 'discussion'
        back: "Sorunu çözmenin en iyi yolu hakkında bir tartışma yaptık.",
        list: "A2",
        answer: "tartışma",
        quest: "discussion"),
    Words2(
        front:
            "The flu is a common disease that causes fever and chills.", // related to 'disease'
        back: "Grip, ateş ve titremeye neden olan yaygın bir hastalıktır.",
        list: "A2",
        answer: "hastalık",
        quest: "disease"),
    Words2(
        front:
            "The distance between Istanbul and Ankara is about 450 kilometers.", // related to 'distance'
        back:
            "İstanbul ile Ankara arasındaki mesafe yaklaşık 450 kilometredir.",
        list: "A2",
        answer: "mesafe",
        quest: "distance"),
    Words2(
        front: "My parents divorced when I was young.", // related to 'divorced'
        back: "Küçükken annem ve babam boşandı.",
        list: "A2",
        answer: "ayrılmak, boşanmak",
        quest: "divorced"),
    Words2(
        front:
            "Please give me all the necessary documents for the application.", // related to 'document'
        back: "Lütfen başvuru için gerekli tüm belgeleri bana verin.",
        list: "A2",
        answer: "belge",
        quest: "document"),
    Words2(
        front:
            "I would like a double cheeseburger, please.", // related to 'double'
        back: "Lütfen double cheeseburger rica ederim.",
        list: "A2",
        answer: "çift",
        quest: "double"),
    Words2(
        front:
            "Can I download this movie to watch later?", // related to 'download'
        back: "Bu filmi daha sonra izlemek için indirebilir miyim?",
        list: "A2",
        answer: "yüklemek",
        quest: "download"),
    Words2(
        front:
            "Is John downstairs? I can't hear him.", // related to 'downstairs'
        back: "John aşağıda mı? Onu duyamıyorum.",
        list: "A2",
        answer: "aşağı kat",
        quest: "downstairs"),
    Words2(
        front: "She showed me her beautiful drawings.", // related to 'drawing'
        back: "Bana güzel çizimlerini gösterdi.",
        list: "A2",
        answer: "çizme",
        quest: "drawing"),
    Words2(
        front: "I had a wonderful dream last night.", // related to 'dream'
        back: "Dün gece harika bir rüya gördüm.",
        list: "A2",
        answer: "rüya",
        quest: "dream"),
    Words2(
        front:
            "My father likes to drive his car to work every day.", // related to 'drive'
        back: "Babam her gün işe arabasını sürmeyi sever.",
        list: "A2",
        answer: "sürmek",
        quest: "drive"),
    Words2(
        front: "Be careful not to drop your phone!", // related to 'drop'
        back: "Telefonunuzu düşürmemeye dikkat edin!",
        list: "A2",
        answer: "düşme",
        quest: "drop"),
    Words2(
        front: "Some people take illegal drugs.", // related to 'drug'
        back: "Bazı insanlar yasadışı uyuşturucu alır.",
        list: "A2",
        answer: "ilaç",
        quest: "drug"),
    Words2(
        front:
            "It's a bit dry outside today. We might need some rain.", // related to 'dry'
        back: "Bugün dışarı biraz kuru. Yağmura ihtiyacımız olabilir.",
        list: "A2",
        answer: "kuru",
        quest: "dry"),
    Words2(
        front:
            "She works hard to earn money for her family.", // related to 'earn'
        back: "Ailesi için para kazanmak için çok çalışıyor.",
        list: "A2",
        answer: "kazanmak",
        quest: "earn"),
    Words2(
        front:
            "The earth is the third planet from the sun.", // related to 'earth'
        back: "Dünya, güneşten üçüncü gezegendir.",
        list: "A2",
        answer: "dünya",
        quest: 'earth'),
    Words2(
        front: "I can speak English easily now.", // related to 'easily'
        back: "Artık İngilizceyi kolaylıkla konuşabiliyorum.",
        list: "A2",
        answer: "rahatlıkla",
        quest: "easily"),
    Words2(
        front:
            "A good education is important for a successful career.", // related to 'education'
        back: "Başarılı bir kariyer için iyi bir eğitim önemlidir.",
        list: "A2",
        answer: "eğitim",
        quest: "education"),
    Words2(
        front:
            "What is the effect of smoking on your health?", // related to 'effect'
        back: "Sigaranın sağlığınız üzerindeki etkisi nedir?",
        list: "A2",
        answer: "etki",
        quest: "effect"),
    Words2(
        front: "You can either have coffee or tea.", // related to 'either'
        back: "Ya kahve ya da çay içebilirsiniz.",
        list: "A2",
        answer: "her iki",
        quest: "either"),
    Words2(
        front:
            "This appliance needs an electric outlet.", // related to 'electric'
        back: "Bu cihazın elektrik prizine ihtiyacı var.",
        list: "A2",
        answer: "elektrik",
        quest: "electric"),
    Words2(
        front:
            "The company is looking to employ new workers.", // related to 'employ'
        back: "Şirket yeni çalışanlar istihdam etmeyi düşünüyor.",
        list: "A2",
        answer: "işe almak",
        quest: "employ"),
    Words2(
        front:
            "He is a loyal employee who has been with the company for 10 years.", // related to 'employee'
        back: "10 yıldır şirkette çalışan sadık bir çalışan.",
        list: "A2",
        answer: "çalışan",
        quest: "employee"),
    Words2(
        front: "She is a strict but fair employer.", // related to 'employer'
        back: "O katı ama adil bir işverendir.",
        list: "A2",
        answer: "iş veren",
        quest: "employer"),
    Words2(
        front:
            "The bus is empty now that everyone has gotten off.", // related to 'empty'
        back: "Herkes indiğine göre otobüs şimdi boş.",
        list: "A2",
        answer: "boş",
        quest: "empty"),
    Words2(
        front: "I didn't like the ending of the movie.", // related to 'ending'
        back: "Filmin sonunu beğenmedim.",
        list: "A2",
        answer: "bitiş",
        quest: "ending"),
    Words2(
        front:
            "Solar energy is a clean and renewable source of energy.", // related to 'energy'
        back: "Güneş enerjisi temiz ve yenilenebilir bir enerji kaynağıdır.",
        list: "A2",
        answer: "enerji",
        quest: "energy"),
    Words2(
        front:
            "The car won't start because the engine is broken.", // related to 'engine'
        back: "Motor arızalı olduğu için araba çalışmayacak.",
        list: "A2",
        answer: "motor",
        quest: "engine"),
    Words2(
        front:
            "He is a talented engineer who designed this bridge.", // related to 'engineer'
        back: "Bu köprüyü tasarlayan yetenekli bir mühendistir.",
        list: "A2",
        answer: "mühendis",
        quest: "engineer"),
    Words2(
        front:
            "The statue is enormous. I can't believe how big it is!", // related to 'enormous'
        back: "Heykel muazzam. Ne kadar büyük olduğuna inanamıyorum!",
        list: "A2",
        answer: "kocaman",
        quest: "enormous"),
    Words2(
        front: "Please enter your name and password.", // related to 'enter'
        back: "Lütfen adınızı ve şifrenizi girin.",
        list: "A2",
        answer: "girmek",
        quest: "enter"),
    Words2(
        front:
            "We need to take care of the environment.", // related to 'environment'
        back: " çevreye bakmamız gerekiyor.",
        list: "A2",
        answer: "çevre",
        quest: "environment"),
    Words2(
        front:
            "Do you have all the necessary equipment for the camping trip?", // related to 'equipment'
        back: "Kamp gezisi için gerekli tüm ekipmana sahip misiniz?",
        list: "A2",
        answer: "ekipman",
        quest: "equipment"),
    Words2(
        front: "There seems to be an error in your code.", // related to 'error'
        back: "Kodunuzda bir hata var gibi görünüyor.",
        list: "A2",
        answer: "hata",
        quest: "error"),
    Words2(
        front:
            "I especially like to read historical novels.", // related to 'especially'
        back: "Özellikle tarihi roman okumayı severim.",
        list: "A2",
        answer: "özellikle",
        quest: "especially"),
    Words2(
        front:
            "He wrote a great essay about climate change.", // related to 'essay'
        back: "İklim değişikliği hakkında harika bir deneme yazdı.",
        list: "A2",
        answer: "girişim",
        quest: "essay"),
    Words2(
        front: "I wake up at the same time everyday", // related to 'every day'
        back: "Her gün aynı saatte uyanıyorum.",
        list: "A2",
        answer: "her gün",
        quest: "everyday"),
    Words2(
        front:
            "Music is played everywhere in the city during the festival.", // related to 'everywhere'
        back: "Festival boyunca şehirde her yerde müzik çalınıyor.",
        list: "A2",
        answer: "her yer",
        quest: "everywhere"),
    Words2(
        front:
            "Do you have any evidence to support your claim?", // related to 'evidence'
        back: "İddianızı destekleyen herhangi bir kanıtınız var mı?",
        list: "A2",
        answer: "kanıt",
        quest: "evidence"),
    Words2(
        front: "What is the exact time now?", // related to 'exact'
        back: "Şimdi tam olarak saat kaç?",
        list: "A2",
        answer: "kesin",
        quest: "exact"),
    Words2(
        front:
            "I don't know exactly what he meant by that.", // related to 'exactly'
        back: "Bununla ne demek istediğini tam olarak bilmiyorum.",
        list: "A2",
        answer: "kesinlikle",
        quest: "exactly"),
    Words2(
        front:
            "She is an excellent student who always gets good grades.", // related to 'excellent'
        back: "Her zaman iyi not alan mükemmel bir öğrencidir.",
        list: "A2",
        answer: "mükemmel",
        quest: "excellent"),
    Words2(
        front:
            "They did things differently in the past.", // related to 'differently'
        back: "Geçmişte işleri farklı yaptılar.",
        list: "A2",
        answer: "farklı",
        quest: "differently"),
    Words2(
        front:
            "The explorer discovered a new island in the Pacific Ocean.", // related to 'discover'
        back: "Kaşif Pasifik Okyanusu'nda yeni bir ada keşfetti.",
        list: "A2",
        answer: "keşfetmek",
        quest: "discover"),
    Words2(
        front:
            "The discovery of penicillin revolutionized medicine.", // related to 'discovery'
        back: "Penisilinin keşfi tıp alanında devrim yarattı.",
        list: "A2",
        answer: "keşif",
        quest: "discovery"),

    // New words
    Words2(
        front:
            "I don't expect the bus to arrive on time today.", // related to 'expect'
        back: "Otobüsün bugün zamanında gelmesini beklemiyorum.",
        list: "A2",
        answer: "beklemek",
        quest: "expect"),
    Words2(
        front:
            "Do you think life exists on other planets?", // related to 'exist'
        back: "Başka gezegenlerde yaşam var mı sence?",
        list: "A2",
        answer: "var olmak",
        quest: "exist"),
    Words2(
        front:
            "Traveling to different countries is a great way to gain new experiences.", // related to 'experience'
        back:
            "Farklı ülkelere seyahat etmek, yeni deneyimler kazanmanın harika bir yoludur.",
        list: "A2",
        answer: "deneyim",
        quest: "experience"),
    Words2(
        front:
            "Scientists are conducting an experiment to find a cure for cancer.", // related to 'experiment'
        back:
            "Bilim adamları kanser için bir tedavi bulmak amacıyla bir deney yürütüyorlar.",
        list: "A2",
        answer: "deney",
        quest: "experiment"),
    Words2(
        front:
            "He is a history expert who has written many books on the subject.", // related to 'expert'
        back: "Konu hakkında birçok kitap yazmış bir tarih uzmanıdır.",
        list: "A2",
        answer: "uzman",
        quest: "expert"),
    Words2(
        front:
            "Can you give me a more detailed explanation of the rules?", // related to 'explanation'
        back:
            "Bana kurallar hakkında daha detaylı bir açıklama yapabilir misin?",
        list: "A2",
        answer: "açıklama",
        quest: "explanation"),
    Words2(
        front:
            "She expressed her happiness by jumping up and down.", // related to 'express'
        back: "Mutluluğunu zıplayarak ifade etti.",
        list: "A2",
        answer: "ifade etmek",
        quest: "express"),
    Words2(
        front:
            "His facial expression showed that he was angry.", // related to 'expression'
        back: "Yüz ifadesi kızgın olduğunu gösteriyordu.",
        list: "A2",
        answer: "anlatım",
        quest: "expression"),
    Words2(
        front:
            "The weather is going to be extreme this weekend - very hot and sunny!", // related to 'extreme'
        back: "Bu hafta sonu hava aşırı olacak - çok sıcak ve güneşli!",
        list: "A2",
        answer: "aşırı",
        quest: "extreme"),

    Words2(
      front: 'Can you name a factor that affects plant growth?',
      back: 'Bitki büyümesini etkileyen bir faktör adlandırabilir misin?',
      list: 'A2',
      answer: 'etken',
      quest: 'factor',
    ),
    Words2(
      front: 'The factory produces cars on a large scale.',
      back: 'Fabrika arabaları büyük ölçekte üretiyor.',
      list: 'A2',
      answer: 'fabrika',
      quest: 'factory',
    ),
    Words2(
      front: "He failed the exam because he didn't study enough.",
      back: 'Yeterince çalışmadığı için sınavda başarısız oldu.',
      list: 'A2',
      answer: 'başarısızlık',
      quest: 'fail',
    ),
    Words2(
      front: 'There will be a science fair at school next week.',
      back: 'Gelecek hafta okulda bir bilim fuarı olacak.',
      list: 'A2',
      answer: 'panayır',
      quest: 'fair',
    ),
    Words2(
      front: 'The leaves start to fall in autumn.',
      back: 'Sonbaharda yapraklar dökülmeye başlar.',
      list: 'A2',
      answer: 'düşüş, güz',
      quest: 'fall',
    ),
    Words2(
      front: 'She is a big fan of the pop star.',
      back: 'O, pop yıldızının büyük bir hayranı.',
      list: 'A2',
      answer: 'hayran',
      quest: 'fan',
    ),
    Words2(
      front: 'We have a chicken farm near our house.',
      back: 'Evimizin yakınında bir tavuk çiftliği var.',
      list: 'A2',
      answer: 'çiftlik',
      quest: 'farm',
    ),
    Words2(
      front: 'She is always following the latest fashion trends.',
      back: 'En yeni moda trendlerini her zaman takip ediyor.',
      list: 'A2',
      answer: 'moda',
      quest: 'fashion',
    ),
    Words2(
      front: 'Eating too much fat can be unhealthy.',
      back: 'Çok fazla yağ yemek sağlıksız olabilir.',
      list: 'A2',
      answer: 'yağ',
      quest: 'fat',
    ),
    Words2(
      front: 'I faced my fears and went skydiving.',
      back: 'Korkularımla yüzleştim ve paraşütle atladım.',
      list: 'A2',
      answer: 'korku',
      quest: 'fear',
    ),
    Words2(
      front: 'This new phone has a great camera feature.',
      back: 'Bu yeni telefonun harika bir kamera özelliği var.',
      list: 'A2',
      answer: 'özellik',
      quest: 'feature',
    ),
    Words2(
      front: 'You need to feed the cat before you leave.',
      back: 'Gitmeden önce kediyi beslemeniz gerekiyor.',
      list: 'A2',
      answer: 'beslemek',
      quest: 'feed',
    ),
    Words2(
      front: 'There are many female CEOs in the tech industry.',
      back: 'Teknoloji sektöründe birçok kadın CEO var.',
      list: 'A2',
      answer: 'kadın',
      quest: 'female',
    ),
    Words2(
      front: 'This book is a work of fiction, not a true story.',
      back: 'Bu kitap kurgu bir eser, gerçek bir hikaye değil.',
      list: 'A2',
      answer: 'kurgu',
      quest: 'fiction',
    ),
    Words2(
      front: 'He is an expert in the field of computer science.',
      back: 'Bilgisayar bilimleri alanında uzmandır.',
      list: 'A2',
      answer: 'alan',
      quest: 'field',
    ),
    Words2(
      front: 'They got into a fight over a parking spot.',
      back: 'Park yeri yüzünden kavga ettiler.',
      list: 'A2',
      answer: 'kavga',
      quest: 'fight',
    ),

    Words2(
      front: 'He finally finished his homework after hours of studying.',
      back: 'Saatlerce çalıştıktan sonra sonunda ödevini bitirdi.',
      list: 'A2',
      answer: 'sonunda',
      quest: 'finally',
    ),
    Words2(
      front: 'Point your finger at the object you want.',
      back: 'İstediğiniz nesneyi parmağınızla işaret edin.',
      list: 'A2',
      answer: 'parmak',
      quest: 'finger',
    ),
    Words2(
      front: 'I need to finish this project by tomorrow.',
      back: 'Bu projeyi yarına kadar bitirmem gerekiyor.',
      list: 'A2',
      answer: 'bitirmek',
      quest: 'finish',
    ),
    Words2(
      front: 'He came in first place in the race.',
      back: 'Yarışta birinci oldu.',
      list: 'A2',
      answer: 'birinci, ilk',
      quest: 'first',
    ),
    Words2(
      front: 'Firstly, I would like to thank you for your time.',
      back: 'İlk olarak, zaman ayırdığınız için teşekkür ederim.',
      list: 'A2',
      answer: 'ilk önce',
      quest: 'Firstly',
    ),
    Words2(
      front: 'We saw many different fish while snorkeling.',
      back: 'Şnorkelle dalarken birçok farklı balık gördük.',
      list: 'A2',
      answer: 'balık',
      quest: 'fish',
    ),
    Words2(
      front: 'He enjoys fishing as a hobby.',
      back: 'Balık tutmayı hobi olarak seviyor.',
      list: 'A2',
      answer: 'balık tutmak',
      quest: 'fishing',
    ),
    Words2(
      front: "These jeans don't fit me anymore. I need a bigger size.",
      back:
          'Bu kot pantolonlar artık üzerime olmuyor. Daha büyük bir bedene ihtiyacım var.',
      list: 'A2',
      answer: 'uymak',
      quest: 'fit',
    ),
    Words2(
      front: 'Can you fix the broken lamp?',
      back: 'Kırık lambayı tamir edebilir misin?',
      list: 'A2',
      answer: 'düzeltmek',
      quest: 'fix',
    ),
    Words2(
      front: 'The ground is flat here, perfect for playing frisbee.',
      back: 'Burası düz bir arazi, frisbi oynamak için ideal.',
      list: 'A2',
      answer: 'düz',
      quest: 'flat',
    ),
    Words2(
      front: "She's been feeling under the weather lately. Maybe it's the flu.",
      back: 'Son zamanlarda kendini iyi hissetmiyor. Belki de griptir.',
      list: 'A2',
      answer: 'grip',
      quest: 'flu',
    ),
    Words2(
      front: 'Birds can fly long distances.',
      back: 'Kuşlar uzun mesafeler uçabilir.',
      list: 'A2',
      answer: 'uçmak',
      quest: 'fly',
    ),
    Words2(
      front: "It's important to focus on your studies if you want to succeed.",
      back:
          'Başarılı olmak istiyorsanız çalışmalarınıza odaklanmanız önemlidir.',
      list: 'A2',
      answer: 'odak',
      quest: 'focus',
    ),
    Words2(
      front: 'He is following the news closely to stay informed.',
      back: 'Bilgi sahibi olmak için haberleri yakından takip ediyor.',
      list: 'A2',
      answer:
          'talip etme (takip etme)', // "Following" translated to "takip etme"
      quest: 'following',
    ),
    Words2(
      front: 'We learned about different foreign cultures in history class.',
      back: 'Tarih dersinde farklı yabancı kültürleri öğrendik.',
      list: 'A2',
      answer: 'yabancı',
      quest: 'foreign',
    ),
    Words2(
      front: 'There are many beautiful forests in Turkey.',
      back: 'Türkiye’de birçok güzel orman var.',
      list: 'A2',
      answer: 'orman',
      quest: 'forest',
    ),
    Words2(
      front: 'Please pass me the fork.',
      back: 'Lütfen çatalı uzatır mısın?',
      list: 'A2',
      answer: 'çatal',
      quest: 'fork',
    ),
    Words2(
      front: 'You should wear formal attire for the job interview.',
      back: 'İş görüşmesi için resmi kıyafet giymelisiniz.',
      list: 'A2',
      answer: 'resmi',
      quest: 'formal',
    ),
    Words2(
      front: "Fortunately, it didn't rain today.",
      back: 'Neyse ki, bugün yağmur yağmadı.',
      list: 'A2',
      answer: 'neyse ki',
      quest: 'Fortunately',
    ),
    Words2(
      front: "Let's look forward to a brighter future.",
      back: 'Daha parlak bir gelecek için sabırsızlanalım.',
      list: 'A2',
      answer: 'ileri',
      quest: 'forward',
    ),
    Words2(
      front: 'This museum offers free admission on Sundays.',
      back: 'Bu müze, pazar günleri ücretsiz giriş imkanı sunuyor.',
      list: 'A2',
      answer: 'ücretsiz',
      quest: 'free',
    ),
    Words2(
      front: 'I like to buy fresh fruits and vegetables at the farmers market.',
      back: 'Taze meyve ve sebzeleri çiftçi pazarından almayı seviyorum.',
      list: 'A2',
      answer: 'taze',
      quest: 'fresh',
    ),
    Words2(
      front: 'Please put the leftover food in the fridge.',
      back: 'Lütfen kalan yemekleri buzdolabına koy.',
      list: 'A2',
      answer: 'buzdolabı',
      quest: 'fridge',
    ),
    Words2(
      front: 'We saw a frog jumping in the pond.',
      back: 'Göletde zıplayan bir kurbağa gördük.',
      list: 'A2',
      answer: 'kurbağa',
      quest: 'frog',
    ),
    Words2(
      front: 'They had a lot of fun playing games at the party.',
      back: 'Partilerde oyun oynayarak çok eğlendiler.',
      list: 'A2',
      answer: 'eğlence',
      quest: 'fun',
    ),
    Words2(
      front: 'We need to buy new furniture for the living room.',
      back: 'Oturma odası için yeni mobilya almamız gerekiyor.',
      list: 'A2',
      answer: 'mobilya',
      quest: 'furniture',
    ),
    Words2(
      front: 'Can you explain this concept in further detail?',
      back: 'Bu kavramı daha ayrıntılı olarak açıklayabilir misin?',
      list: 'A2',
      answer: 'daha ileri',
      quest: 'further',
    ),
    Words2(
      front: 'What do you think the future holds for us?',
      back: 'Gelecek bizim için ne barındırıyor sence?',
      list: 'A2',
      answer: 'gelecek',
      quest: 'future',
    ),
    Words2(
      front: 'There is a beautiful art gallery downtown.',
      back: 'Şehrin merkezinde güzel bir sanat galerisi var.',
      list: 'A2',
      answer: 'galeri',
      quest: 'gallery',
    ),
    Words2(
      front: 'There is a large gap between the two buildings.',
      back: 'İki bina arasında geniş bir boşluk var.',
      list: 'A2',
      answer: 'açıklık',
      quest: 'gap',
    ),
    Words2(
      front: 'My car needs gas. Can you lend me some money?',
      back: 'Arabamın benzine ihtiyacı var. Bana biraz borç verebilir misin?',
      list: 'A2',
      answer: 'benzin',
      quest: 'gas',
    ),
    Words2(
      front: 'Please wait at the gate until your flight is announced.',
      back: 'Uçuşunuz anons edilene kadar lütfen gâtede bekleyin.',
      list: 'A2',
      answer: 'geçit',
      quest: 'gate',
    ),
    Words2(
      front: 'The general spoke to the troops before the battle.',
      back: 'General savaştan önce askerlere konuştu.',
      list: 'A2',
      answer: 'genel',
      quest: 'general',
    ),
    Words2(
      front: 'She received a beautiful scarf as a gift for her birthday.',
      back: 'Doğum günü için hediye olarak güzel bir eşarp aldı.',
      list: 'A2',
      answer: 'hediye',
      quest: 'gift',
    ),
    Words2(
      front: 'My goal is to become a doctor.',
      back: 'Hedefim doktor olmaktır.',
      list: 'A2',
      answer: 'hedef',
      quest: 'goal',
    ),
    Words2(
      front: 'Many people believe in God.',
      back: 'Pek çok insan Tanrı’ya inanır.',
      list: 'A2',
      answer: 'tanrı',
      quest: 'God',
    ),
    Words2(
      front: 'The ring is made of pure gold.',
      back: 'Yüzük saf altından yapılmıştır.',
      list: 'A2',
      answer: 'altın',
      quest: 'gold',
    ),
    Words2(
      front: 'It was a good idea to bring an umbrella. It started raining!',
      back: 'Şemsiye getirmek iyi bir fikirdi. Yağmur yağmaya başladı!',
      list: 'A2',
      answer: 'güzel',
      quest: 'good',
    ),
    Words2(
      front: 'The government is responsible for making laws.',
      back: 'Hükümet, yasaları çıkarmaktan sorumludur.',
      list: 'A2',
      answer: 'hükümet',
      quest: 'government',
    ),
    Words2(
      front: 'The park has a lot of green grass.',
      back: 'Parkın çok yeşilliği var.',
      list: 'A2',
      answer: 'çim',
      quest: 'grass',
    ),
    Words2(
      front: 'He greeted his friend with a handshake.',
      back: 'Arkadaşını el sıkışarak selamladı.',
      list: 'A2',
      answer: 'selamlaşmak',
      quest: 'greet',
    ),
    Words2(
      front: 'The building is built on solid ground.',
      back: 'Bina sağlam zemine inşa edilmiştir.',
      list: 'A2',
      answer: 'zemin',
      quest: 'ground',
    ),
    Words2(
      front: 'We had some guests over for dinner last night.',
      back: 'Dün gece misafirlerimiz vardı.',
      list: 'A2',
      answer: 'misafir',
      quest: 'guest',
    ),
    Words2(
      front: 'This guidebook will help you navigate the city.',
      back: 'Bu rehberlik kitabı şehirde gezinmenize yardımcı olacaktır.',
      list: 'A2',
      answer: 'rehber',
      quest: 'guide',
    ),
    Words2(
      front: 'He is a law-abiding citizen and never carries a gun.',
      back: 'Kanunlara uyan bir vatandaştır ve asla silah taşımaz.',
      list: 'A2',
      answer: 'silah',
      quest: 'gun',
    ),
    Words2(
      front: 'That guy over there is always telling jokes.',
      back: 'Şuradaki adam sürekli şaka yapıyor.',
      list: 'A2',
      answer: 'adam',
      quest: 'guy',
    ),
    Words2(
      front: 'He has a bad habit of biting his nails.',
      back: 'Tırnaklarını ısırma gibi kötü bir alışkanlığı var.',
      list: 'A2',
      answer: 'alışkanlık',
      quest: 'habit',
    ),
    Words2(
      front: 'I ate half of the sandwich.',
      back: 'Sandviçin yarısını yedim.',
      list: 'A2',
      answer: 'yarım',
      quest: 'half',
    ),
    Words2(
      front: 'The school assembly was held in the main hall.',
      back: 'Okul töreni ana salonda gerçekleştirildi.',
      list: 'A2',
      answer: 'salon',
      quest: 'hall',
    ),
    Words2(
      front: 'They lived happily ever after.',
      back: 'Sonrasında mutlu bir şekilde yaşadılar.',
      list: 'A2',
      answer: 'mutlu bir şekilde',
      quest: 'happily',
    ),
    Words2(
      front: 'Do you have any questions?',
      back: 'Herhangi bir sorunuz var mı?',
      list: 'A2',
      answer: 'sahip olmak',
      quest: 'have',
    ),
    Words2(
      front: 'I have a headache. Do you have any aspirin?',
      back: 'Başım ağrıyor. Aspirin var mı?',
      list: 'A2',
      answer: 'baş ağrısı',
      quest: 'headache',
    ),
    Words2(
      front: 'Follow your heart and do what makes you happy.',
      back: 'Kalbinizi takip edin ve sizi mutlu eden şeyi yapın.',
      list: 'A2',
      answer: 'yürek, kalp',
      quest: 'heart',
    ),
    Words2(
      front: "It's very hot outside today. The heat is unbearable!",
      back: 'Bugün hava çok sıcak. Sıcak dayanılmaz!',
      list: 'A2',
      answer: 'sıcaklık',
      quest: 'heat',
    ),
    Words2(
      front: 'This box is too heavy for me to lift.',
      back: 'Bu kutu benim kaldırmam için çok ağır.',
      list: 'A2',
      answer: 'ağır',
      quest: 'heavy',
    ),
    Words2(
      front: 'What is the height of the Eiffel Tower?',
      back: "Eiffel Kulesi'nin yüksekliği nedir?",
      list: 'A2',
      answer: 'yükseklik',
      quest: 'height',
    ),
    Words2(
      front: 'He is always helpful and willing to lend a hand.',
      back: 'Her zaman yardımseverdir ve el uzatmaya hazırdır.',
      list: 'A2',
      answer: 'yardımsever',
      quest: 'helpful',
    ),
    Words2(
      front: 'Superman is a popular comic book hero.',
      back: 'Süpermen, popüler bir çizgi roman kahramanıdır.',
      list: 'A2',
      answer: 'kahraman',
      quest: 'hero',
    ),
    Words2(
      front:
          'Is this hers?', // "Hers" is possessive pronoun, not plural of "he"
      back: 'Bu onunki mi?', // Changed to "onunki" (possessive of "o")
      list: 'A2',
      answer: 'onunki', // Changed answer to "onunki"
      quest: 'hers',
    ),
    Words2(
      front: 'He tried to hide behind the tree.',
      back: 'Ağacın arkasına saklanmaya çalıştı.',
      list: 'A2',
      answer: 'saklamak',
      quest: 'hide',
    ),
    Words2(
      front: 'We went for a hike up the hill yesterday.',
      back: 'Dün tepeye yürüyüşe çıktık.',
      list: 'A2',
      answer: 'tepe',
      quest: 'hill',
    ),
    Words2(
      front:
          "We can't stop Tom climbing out of his cot.", // "His" is possessive pronoun
      back: "Tom'un karyolasından çıkmasını engelleyemeyiz.",
      list: 'A2',
      answer: 'onun', // Changed answer to "onun"
      quest: 'his',
    ),
    Words2(
      front: 'The baseball player hit the ball out of the park.',
      back: 'Beyzbol oyuncusu topu stadyumun dışına vurdu.',
      list: 'A2',
      answer: 'vurmak',
      quest: 'hit',
    ),
    Words2(
      front: 'Please hold this for a moment.',
      back: 'Lütfen bunu bir süre tutar mısın?',
      list: 'A2',
      answer: 'tutmak',
      quest: 'hold',
    ),
    Words2(
      front: 'There is a big hole in the ground.',
      back: 'Yerde büyük bir çukur var.',
      list: 'A2',
      answer: 'çukur',
      quest: 'hole',
    ),
    Words2(
      front: "There's no place like home.",
      back: 'Ev gibisi bir yer yoktur.',
      list: 'A2',
      answer: 'ev',
      quest: 'home',
    ),
    Words2(
      front: "Don't lose hope. Things will get better.",
      back: 'Umudu kaybetme. İşler düzelecek.',
      list: 'A2',
      answer: 'umut',
      quest: 'hope',
    ),
    Words2(
      front: 'The statue is huge! It must be very heavy.',
      back: 'Heykel kocaman! Çok ağır olmalı.',
      list: 'A2',
      answer: 'kocaman',
      quest: 'huge',
    ),
    Words2(
      front: 'All humans are equal.',
      back: 'Tüm insanlar eşittir.',
      list: 'A2',
      answer: 'insan',
      quest: 'human',
    ),
    Words2(
      front: 'My ankle hurts. I think I twisted it.',
      back: 'Bileğim ağrıyor. Sanırım burktum.',
      list: 'A2',
      answer: 'yaralamak',
      quest: 'hurt',
    ),
    Words2(
      front: 'Can you identify the suspect in this photo?',
      back: 'Bu fotoğraftaki şüpheliyi tanımlayabilir misin?',
      list: 'A2',
      answer: 'tanımlamak',
      quest: 'identify',
    ),
    Words2(
      front: "He's been feeling ill for a few days.",
      back: 'Birkaç gündür hasta hissediyor.',
      list: 'A2',
      answer: 'hasta',
      quest: 'ill',
    ),
    Words2(
      front: "I'm taking medication for my illness.",
      back: 'Hastalığım için ilaç alıyorum.',
      list: 'A2',
      answer: 'hastalık',
      quest: 'illness',
    ),
    Words2(
      front: 'The image on the screen is blurry.',
      back: 'Ekrandaki görüntü bulanık.',
      list: 'A2',
      answer: 'resim',
      quest: 'image',
    ),
    Words2(
      front: 'Come here immediately! I need your help.',
      back: 'Hemen gel! Yardımına ihtiyacım var.',
      list: 'A2',
      answer: 'hemen',
      quest: 'immediately',
    ),
    Words2(
      front: 'It is impossible to travel faster than the speed of light.',
      back: 'Işık hızından daha hızlı seyahat etmek imkansızdır.',
      list: 'A2',
      answer: 'imkansız',
      quest: 'impossible',
    ),
    Words2(
      front: 'The price of the meal included tax and gratuity.',
      back: 'Yemeğin fiyatı vergi ve bahşişi içerir.',
      list: 'A2',
      answer: 'dahil olan',
      quest: 'included',
    ),
    Words2(
      front: "The price is \$10, including tax.",
      back: 'Fiyat 10 dolar, vergi dahil.',
      list: 'A2',
      answer: 'dahil',
      quest: 'including',
    ),
    Words2(
      front: 'There has been a recent increase in the cost of living.',
      back: 'Yaşam maliyetinde son zamanlarda bir artış oldu.',
      list: 'A2',
      answer: 'artış',
      quest: 'increase',
    ),
    Words2(
      front: 'It is incredible that she can speak five languages fluently!',
      back: 'Beş dili akıcı bir şekilde konuşabilmesi inanılmaz!',
      list: 'A2',
      answer: 'inanılmaz',
      quest: 'incredible',
    ),
    Words2(
      front: 'The United States is an independent country.',
      back: 'Amerika Birleşik Devletleri bağımsız bir ülkedir.',
      list: 'A2',
      answer: 'bağımsız',
      quest: 'independent',
    ),
    Words2(
      front:
          'He is a very individual person who likes to do things his own way.',
      back: 'Kendi yöntemiyle işleri yapmayı seven çok bireysel bir insan.',
      list: 'A2',
      answer: 'bireysel',
      quest: 'individual',
    ),
    Words2(
      front: 'The car industry is one of the largest in the world.',
      back: 'Otomobil endüstrisi dünyanın en büyüklerinden biridir.',
      list: 'A2',
      answer: 'endüstri',
      quest: 'industry',
    ),
    Words2(
      front: 'We had a very informal chat about the weather.',
      back: 'Hava durumu hakkında çok gayri resmi bir sohbet yaptık.',
      list: 'A2',
      answer: 'resmi olmayan',
      quest: 'informal',
    ),
    Words2(
      front: 'He suffered a serious injury to his leg in the accident.',
      back: 'Kazada bacağından ciddi bir şekilde yaralandı.',
      list: 'A2',
      answer: 'zarar',
      quest: 'injury',
    ),
    Words2(
      front: 'There are many different insects in the garden.',
      back: 'Bahçede birçok farklı böcek var.',
      list: 'A2',
      answer: 'böcek',
      quest: 'insect',
    ),
    Words2(
      front: 'Please stay inside until the storm passes.',
      back: 'Fırtına geçene kadar lütfen içeride kalın.',
      list: 'A2',
      answer: 'içeride',
      quest: 'inside',
    ),
    Words2(
      front: 'I would like some coffee instead of tea.',
      back: 'Çay yerine kahve almak isterdim.',
      list: 'A2',
      answer: 'yerine',
      quest: 'instead',
    ),
    Words2(
      front: 'Please follow these instructions carefully.',
      back: 'Lütfen bu talimatları dikkatlice takip edin.',
      list: 'A2',
      answer: 'yönerge',
      quest: 'instruction',
    ),
    Words2(
      front: 'He is a qualified yoga instructor.',
      back: 'Kalifiye bir yoga eğitmenidir.',
      list: 'A2',
      answer: 'eğitmen',
      quest: 'instructor',
    ),
    Words2(
      front: 'The guitar is a popular musical instrument.',
      back: 'Gitar popüler bir müzik enstrümanıdır.',
      list: 'A2',
      answer: 'enstrüman',
      quest: 'instrument',
    ),
    Words2(
      front: 'He is a very intelligent student who always gets good grades.',
      back: 'Her zaman iyi notlar alan çok zeki bir öğrencidir.',
      list: 'A2',
      answer: 'zeki',
      quest: 'intelligent',
    ),
    Words2(
      front:
          'This is an international competition that is open to athletes from all over the world.',
      back:
          'Bu, dünyanın her yerinden sporculara açık uluslararası bir yarışmadır.',
      list: 'A2',
      answer: 'uluslararası',
      quest: 'international',
    ),
    Words2(
      front: 'The speaker gave a brief introduction to the topic.',
      back: 'Konuşmacı konuya kısa bir giriş yaptı.',
      list: 'A2',
      answer: 'tanıtım',
      quest: 'introduction',
    ),
    Words2(
      front: 'Thomas Edison invented the light bulb.',
      back: 'Thomas Edison ampulü icat etti.',
      list: 'A2',
      answer: 'icat etmek',
      quest: 'invent',
    ),
    Words2(
      front: 'The airplane is one of the greatest inventions of all time.',
      back: 'Uçak, tüm zamanların en büyük buluşlarından biridir.',
      list: 'A2',
      answer: 'buluş',
      quest: 'invention',
    ),
    Words2(
      front: 'I would like to thank you for the invitation to your party.',
      back: 'Partinize davetiyeniz için teşekkür ederim.',
      list: 'A2',
      answer: 'davetiye',
      quest: 'invitation',
    ),
    Words2(
      front: 'Can I invite you to join us for dinner tonight?',
      back: 'Bu akşam yemeğe bize katılmaya davet edebilir miyim?',
      list: 'A2',
      answer: 'davet etmek',
      quest: 'invite',
    ),
    Words2(
      front: 'This project will involve a lot of research and development.',
      back: 'Bu projede çok fazla araştırma ve geliştirme yer alacak.',
      list: 'A2',
      answer: 'içermek',
      quest: 'involve',
    ),
    Words2(
      front: 'The next item on the agenda is the budget proposal.',
      back: 'Gündemdeki bir sonraki madde bütçe teklifidir.',
      list: 'A2',
      answer: 'madde',
      quest: 'item',
    ),
    Words2(
      front: 'The cat can lick itself clean.',
      back: 'Kedi kendini temizleyebilir.',
      list: 'A2',
      answer: 'kendisi',
      quest: 'itself',
    ),
    Words2(
      front: 'We are stuck in a traffic jam on the highway.',
      back: 'Otobanda bir sıkışıklıkta kaldık.',
      list: 'A2',
      answer: 'sıkışıklık, reçel',
      quest: 'jam',
    ),
    Words2(
      front: 'Do you like jazz music?',
      back: 'Caz müziğini sever misin?',
      list: 'A2',
      answer: 'caz',
      quest: 'jazz',
    ),
    Words2(
      front: 'She is wearing a beautiful diamond jewellery.',
      back: 'Üzerinde güzel bir elmas mücevheratı var.',
      list: 'A2',
      answer: 'mücevherat',
      quest: 'jewellery',
    ),
    Words2(
      front: 'He told a funny joke that made everyone laugh.',
      back: 'Herkesi güldüren komik bir şaka yaptı.',
      list: 'A2',
      answer: 'şaka',
      quest: 'joke',
    ),
    Words2(
      front: 'She is a journalist who writes for a major newspaper.',
      back: 'Önde gelen bir gazetede yazan bir gazetecidir.',
      list: 'A2',
      answer: 'gazeteci',
      quest: 'journalist',
    ),
    Words2(
      front:
          'The little boy jumped on the trampoline.', // "Atlamak" already exists for "jump"
      back: 'Küçük çocuk trampolinde zıplıyordu.',
      list: 'A2',
      answer: 'zıplamak', // Changed answer to "zıplamak" to avoid duplicates
      quest: 'jump',
    ),
    Words2(
      front: 'The teacher asked the kids to be quiet.',
      back: 'Öğretmen çocuklardan sessiz olmalarını istedi.',
      list: 'A2',
      answer: 'çocuk',
      quest: 'kid',
    ),

    Words2(
      front: 'The king ruled the country for many years.',
      back: 'Kral ülkeyi uzun yıllar yönetti.',
      list: 'A2',
      answer: 'kral',
      quest: 'king',
    ),
    Words2(
      front: 'He hurt his knee while playing football.',
      back: 'Futbol oynarken dizini incitti.',
      list: 'A2',
      answer: 'diz',
      quest: 'knee',
    ),
    Words2(
      front: 'The chef used a sharp knife to cut the vegetables.',
      back: 'Şef sebzeleri kesmek için keskin bir bıçak kullandı.',
      list: 'A2',
      answer: 'bıçak',
      quest: 'knife',
    ),
    Words2(
      front: 'Did you hear someone knock on the door?',
      back: 'Kapıya birinin vurduğunu duydun mu?',
      list: 'A2',
      answer: 'kapı çalmak',
      quest: 'knock',
    ),
    Words2(
      front: 'Reading books can help you gain knowledge.',
      back: 'Kitap okumak bilgi edinmenize yardımcı olabilir.',
      list: 'A2',
      answer: 'bilgi',
      quest: 'knowledge',
    ),
    Words2(
      front: 'The scientists are conducting experiments in the lab.',
      back: 'Bilim adamları laboratuvarda deneyler yapıyor.',
      list: 'A2',
      answer: 'laboratuvar',
      quest: 'lab',
    ),
    Words2(
      front: 'The kind lady offered to help me with my groceries.',
      back:
          'Nazik hanımefendi market alışverişimde bana yardım etmeyi teklif etti.',
      list: 'A2',
      answer: 'hanımefendi',
      quest: 'lady',
    ),
    Words2(
      front: 'We went for a swim in the lake on a hot summer day.',
      back: 'Sıcak bir yaz gününde gölde yüzdük.',
      list: 'A2',
      answer: 'göl',
      quest: 'lake',
    ),
    Words2(
      front: 'I turned on the lamp because it was getting dark.',
      back: ' hava karardığı için lambayı açtım.',
      list: 'A2',
      answer: 'lamba',
      quest: 'lamp',
    ),
    Words2(
      front: 'We are planning to visit that beautiful island next summer.',
      back: 'Önümüzdeki yaz o güzel adayı ziyaret etmeyi planlıyoruz.',
      list: 'A2',
      answer: 'ada',
      quest: 'island',
    ),
    Words2(
      front: 'He was the last person to arrive at the party.',
      back: 'Partiye gelen son kişi oydu.',
      list: 'A2',
      answer: 'sonuncu',
      quest: 'last',
    ),
    Words2(
      front: 'I will see you later this evening.',
      back: 'Bu akşamın ilerleyen saatlerinde görüşürüz.',
      list: 'A2',
      answer: 'sonra',
      quest: 'later',
    ),
    Words2(
      front: 'The sound of their laughter filled the room.',
      back: 'Kahkahaları odayı doldurdu.',
      list: 'A2',
      answer: 'kahkaha',
      quest: 'laughter',
    ),
    Words2(
      front: 'Stealing is against the law.',
      back: 'Hırsızlık yasaya karşıdır.',
      list: 'A2',
      answer: 'yasa',
      quest: 'law',
    ),
    Words2(
      front: 'He hired a lawyer to represent him in court.',
      back: 'Mahkemede kendisini temsil etmesi için bir avukat tuttu.',
      list: 'A2',
      answer: 'avukat',
      quest: 'lawyer',
    ),
    Words2(
      front: 'He doesn\'t want to do any chores because he is lazy.',
      back: 'Tembel olduğu için hiçbir iş yapmak istemiyor.',
      list: 'A2',
      answer: 'tembel',
      quest: 'lazy',
    ),
    Words2(
      front: 'The teacher can guide the students in their learning.',
      back: 'Öğretmen, öğrencilere öğrenmelerinde rehberlik edebilir.',
      list: 'A2',
      answer: 'rehberlik etmek',
      quest: 'lead',
    ),
    Words2(
      front: 'Martin Luther King Jr. was a civil rights leader.',
      back: 'Martin Luther King Jr. bir insan hakları lideriydi.',
      list: 'A2',
      answer: 'lider',
      quest: 'leader',
    ),
    Words2(
      front:
          'Learning a new language can be a challenging but rewarding experience.',
      back:
          'Yeni bir dil öğrenmek zorlu ama ödüllendirici bir deneyim olabilir.',
      list: 'A2',
      answer: 'öğrenme',
      quest: 'Learning',
    ),
    Words2(
      front: 'At least you tried your best.',
      back: 'En azından elinden gelenin en iyisini yaptın.',
      list: 'A2',
      answer: 'en az',
      quest: 'least',
    ),
    Words2(
      front:
          'The professor gave a lecture on the history of the Ottoman Empire.',
      back: 'Profesör, Osmanlı İmparatorluğu tarihi hakkında ders anlattı.',
      list: 'A2',
      answer: 'ders anlatmak',
      quest: 'lecture',
    ),
    Words2(
      front: 'I would like to add some lemon juice to my fish.',
      back: 'Balığıma biraz limon suyu eklemek isterim.',
      list: 'A2',
      answer: 'limon',
      quest: 'lemon',
    ),
    Words2(
      front: 'Can you lend me some money?',
      back: 'Bana biraz para ödünç verebilir misin?',
      list: 'A2',
      answer: 'ödünç vermek',
      quest: 'lend',
    ),
    Words2(
      front: 'I have less homework today than yesterday.',
      back: 'Bugün dünden daha az ödevim var.',
      list: 'A2',
      answer: 'daha az',
      quest: 'less',
    ),
    Words2(
      front:
          'He is a beginner English learner, so his level is not very high yet.',
      back:
          'Yeni başlayan bir İngilizce öğrencisi, bu yüzden seviyesi henüz çok yüksek değil.',
      list: 'A2',
      answer: 'seviye',
      quest: 'level',
    ),
    Words2(
      front:
          'Living a healthy lifestyle can help you feel better and have more energy.',
      back:
          'Sağlıklı bir yaşam tarzı sürmek, kendinizi daha iyi hissetmenize ve daha fazla enerjiye sahip olmanıza yardımcı olabilir.',
      list: 'A2',
      answer: 'yaşam tarzı',
      quest: 'lifestyle',
    ),
    Words2(
      front: 'Can you help me lift this heavy box?',
      back: 'Bu ağır kutuyu kaldırmama yardım edebilir misin?',
      list: 'A2',
      answer: 'kaldırmak',
      quest: 'lift',
    ),
    Words2(
      front: 'Please turn off the light when you leave the room.',
      back: 'Odadan çıkarken ışığı kapatın lütfen.',
      list: 'A2',
      answer: 'ışık',
      quest: 'light',
    ),
    Words2(
      front: 'It is likely to rain tomorrow, so bring an umbrella.',
      back: 'Yarın yağmur yağma ihtimali yüksek, o yüzden şemsiye getir.',
      list: 'A2',
      answer: 'büyük ihtimalle',
      quest: 'likely',
    ),
    Words2(
      front:
          'The teacher provided a link to the article in the online classroom.',
      back: 'Öğretmen, çevrimiçi sınıftaki makaleye bir bağlantı sağladı.',
      list: 'A2',
      answer: 'bağlantı',
      quest: 'link',
    ),
    Words2(
      front: 'The speaker had a large audience of listeners.',
      back: 'Konuşmacının çok sayıda dinleyicisi vardı.',
      list: 'A2',
      answer: 'dinleyici',
      quest: 'listener',
    ),
    Words2(
      front: 'The little girl was playing with her little brother.',
      back: 'Küçük kız, küçük erkek kardeşiyle oynuyordu.',
      list: 'A2',
      answer: 'küçük',
      quest: 'little',
    ),
    Words2(
      front: 'Please lock the door before you go to bed.',
      back: 'Yatağa gitmeden önce kapıyı kilitleyin lütfen.',
      list: 'A2',
      answer: 'kilit',
      quest: 'lock',
    ),
    Words2(
      front: 'Look at this beautiful view!',
      back: 'Bu güzel manzaraya bak!',
      list: 'A2',
      answer: 'bakmak',
      quest: 'Look',
    ),
    Words2(
      front: 'The lorry driver was delivering furniture to a house.',
      back: 'Kamyon şoförü bir eve mobilya taşıyordu.',
      list: 'A2',
      answer: 'kamyon',
      quest: 'lorry',
    ),
    Words2(
      front: 'Have you seen my lost keys anywhere?',
      back: 'Kayıp anahtarlarımı herhangi bir yerde gördün mü?',
      list: 'A2',
      answer: 'kayıp',
      quest: 'lost',
    ),
    Words2(
      front: 'The music was so loud that we couldn\'t hear each other speak.',
      back:
          'Müzik o kadar yüksek sesliydi ki birbirimizi konuşurken duyamıyorduk.',
      list: 'A2',
      answer: 'yüksek ses',
      quest: 'loud',
    ),
    Words2(
      front: 'The children were playing loudly in the garden.',
      back: 'Çocuklar bahçede gürültülü bir şekilde oynuyorlardı.',
      list: 'A2',
      answer: 'gürültülü',
      quest: 'loudly',
    ),
    Words2(
      front: 'She has a lovely smile.',
      back: 'Güzel, sevimli bir gülüşü var.',
      list: 'A2',
      answer: 'güzel, sevimli',
      quest: 'lovely',
    ),
    Words2(
      front: 'The battery level is low, so I need to charge my phone.',
      back: 'Pil seviyesi düşük, bu yüzden telefonumu şarj etmem gerekiyor.',
      list: 'A2',
      answer: 'düşük',
      quest: 'low',
    ),
    Words2(
      front: 'I wish you good luck on your exam!',
      back: 'Sınavında şans diliyorum!',
      list: 'A2',
      answer: 'şans',
      quest: 'luck',
    ),
    Words2(
      front: 'He is a very lucky person; he always wins raffles.',
      back: 'Çok şanslı biri; her zaman çekilişleri kazanıyor.',
      list: 'A2',
      answer: 'şanslı',
      quest: 'lucky',
    ),
    Words2(
      front: 'I am expecting an important mail from my bank.',
      back: 'Bankamdan önemli bir posta bekliyorum.',
      list: 'A2',
      answer: 'posta',
      quest: 'mail',
    ),
    Words2(
      front: 'The company is a major player in the technology industry.',
      back: 'Şirket, teknoloji sektöründe önemli bir aktördür.',
      list: 'A2',
      answer: 'asıl, başlıca',
      quest: 'major',
    ),
    Words2(
      front: 'Most of the students in this class are male.',
      back: 'Bu sınıftaki öğrencilerin çoğu erkek.',
      list: 'A2',
      answer: 'erkek',
      quest: 'male',
    ),
    Words2(
      front: 'She is a successful businesswoman who manages her own company.',
      back: 'Kendi şirketini yöneten başarılı bir iş kadınıdır.',
      list: 'A2',
      answer: 'işletmek',
      quest: 'manage',
    ),
    Words2(
      front: 'The manager was very rude in his manner towards the customer.',
      back: 'Yönetici, müşteriye karşı tavır olarak çok kaba davrandı.',
      list: 'A2',
      answer: 'tavır, tutum',
      quest: 'manner',
    ),
    Words2(
      front: 'The teacher put a mark next to the wrong answer.',
      back: 'Öğretmen, yanlış cevap yanına bir işaret koydu.',
      list: 'A2',
      answer: 'iz, işaret',
      quest: 'mark',
    ),
    Words2(
      front: 'They are planning to get marry/ied next year.',
      back: 'Önümüzdeki sene evlenmeyi planlıyorlar.',
      list: 'A2',
      answer: 'evlenmek',
      quest: 'marry',
    ),
    Words2(
      front: 'We need more materials to finish this project.',
      back: 'Bu projeyi bitirmek için daha fazla malzemeye ihtiyacımız var.',
      list: 'A2',
      answer: 'malzeme',
      quest: 'material',
    ),
    Words2(
      front: 'I am not very good at maths, but I am good at English.',
      back: 'Matematikte pek iyi değilim, ama İngilizcede iyiyim.',
      list: 'A2',
      answer: 'matematik',
      quest: 'maths',
    ),
    Words2(
      front: 'Does it matter if I am a few minutes late?',
      back: 'Birkaç dakika geç kalırsam sorun mu var?',
      list: 'A2',
      answer: 'konu, önemli olmak',
      quest: 'matter',
    ),
    Words2(
      front: 'May is the fifth month of the year.',
      back: 'Mayıs, yılın beşinci ayıdır.',
      list: 'A2',
      answer: 'Mayıs',
      quest: 'May',
    ),
    Words2(
      front: 'Do you need to take any medicine for your cold?',
      back: 'Soğuk algınlığı için herhangi bir ilaç almanız gerekiyor mu?',
      list: 'A2',
      answer: 'ilaç',
      quest: 'medicine',
    ),
    Words2(
      front: 'He has a very good memory and can remember things easily.',
      back: 'Çok iyi bir hafızası var ve şeyleri kolayca hatırlayabiliyor.',
      list: 'A2',
      answer: 'hafıza',
      quest: 'memory',
    ),
    Words2(
      front:
          'The teacher didn\'t mention the homework assignment in class today.',
      back: 'Öğretmen bugün sınıfta ödev ödevinden bahsetmedi.',
      list: 'A2',
      answer: 'bahsetmek',
      quest: 'mention',
    ),
    Words2(
      front: 'We are standing in the middle of the street.',
      back: 'Sokağın ortasında duruyoruz.',
      list: 'A2',
      answer: 'orta kısım',
      quest: 'middle',
    ),
    Words2(
      front: 'There is a might chance that it will rain tomorrow.',
      back:
          'Yarın yağmur yağma ihtimali var.', // "büyük ihtimalle" can also be used here
      list: 'A2',
      answer: 'kuvvet',
      quest: 'might',
    ),
    Words2(
      front: 'Try to clear your mind and focus on the task at hand.',
      back: 'Zihnini temizlemeye ve elinizdeki işe odaklanmaya çalışın.',
      list: 'A2',
      answer: 'zihin',
      quest: 'mind',
    ),
    Words2(
      front: 'Coal is a fossil fuel that is mined from the ground.',
      back: 'Kömür, yerden çıkarılan fosil bir yakıttır.',
      list: 'A2',
      answer: 'maden',
      quest: 'mine',
    ),
    Words2(
      front: 'I can see my reflection in the mirror.',
      back: 'Yansımamı aynada görebiliyorum.',
      list: 'A2',
      answer: 'ayna',
      quest: 'mirror',
    ),
    Words2(
      front: 'I am missing my family while I am studying abroad.',
      back: 'Yurt dışında okurken ailemi özlüyorum.',
      list: 'A2',
      answer: 'özlemek',
      quest: 'missing',
    ),
    Words2(
      front:
          'Monkeys are intelligent animals that can be found in many parts of the world.',
      back: 'Maymunlar, dünyanın birçok yerinde bulunabilen zeki hayvanlardır.',
      list: 'A2',
      answer: 'maymun',
      quest: 'Monkey',
    ),
    Words2(
      front: 'The moon is a natural satellite of the Earth.',
      back: 'Ay, Dünya\'nın doğal uydusudur.',
      list: 'A2',
      answer: 'ay',
      quest: 'moon',
    ),
    Words2(
      front: 'He mostly speaks English, but he also knows some French.',
      back: 'Çoğunlukla İngilizce konuşuyor, ama biraz da Fransızca biliyor.',
      list: 'A2',
      answer: 'çoğunlukla',
      quest: 'mostly',
    ),
    Words2(
      front:
          'There was very little movement on the road because of the heavy traffic.',
      back: 'Yoğun trafik nedeniyle yolda çok az hareket vardı.',
      list: 'A2',
      answer: 'hareket',
      quest: 'movement',
    ),
    Words2(
      front: 'She is a talented musician who plays the piano beautifully.',
      back: 'Piyano çalan yetenekli bir müzisyendir.',
      list: 'A2',
      answer: 'müzisyen',
      quest: 'musician',
    ),
    Words2(
      front: 'I can do it myself, I don\'t need your help.',
      back: 'Kendim yapabilirim, yardımına ihtiyacım yok.',
      list: 'A2',
      answer: 'kendim',
      quest: 'myself',
    ),
    Words2(
      front: 'The street was too narrow for two cars to pass each other.',
      back: 'Sokak, iki arabanın yan yana geçmesi için çok dardı.',
      list: 'A2',
      answer: 'dar',
      quest: 'narrow',
    ),
    Words2(
      front: 'The national flag of Turkey is red and white.',
      back: "Türkiye'nin milli bayrağı kırmızı ve beyazdır.",
      list: 'A2',
      answer: 'ulusal',
      quest: 'national',
    ),
    Words2(
      front: 'We should spend more time in nature.',
      back: 'Doğada daha fazla zaman geçirmeliyiz.',
      list: 'A2',
      answer: 'doğa',
      quest: 'nature',
    ),
    Words2(
      front: 'I was nearly late for work this morning.',
      back: 'Bu sabah işe neredeyse geç kalıyordum.',
      list: 'A2',
      answer: 'neredeyse',
      quest: 'nearly',
    ),
    Words2(
      front: 'Is it necessary to bring an umbrella today?',
      back: 'Bugün şemsiye getirmek gerekli mi?',
      list: 'A2',
      answer: 'gereken',
      quest: 'necessary',
    ),
    Words2(
      front: 'She was wearing a scarf around her neck.',
      back: 'Boynuna bir eşarp takmıştı.',
      list: 'A2',
      answer: 'boyun',
      quest: 'neck',
    ),
    Words2(
      front: "I don't need a lot of money to be happy.",
      back: 'Mutlu olmak için çok fazla paraya ihtiyacım yok.',
      list: 'A2',
      answer: 'ihiyaç',
      quest: 'need',
    ),
    Words2(
      front: 'I don\'t want to go swimming, and neither does she.',
      back: 'Yüzmeye gitmek istemiyorum, o da istemiyor.',
      list: 'A2',
      answer: 'hiçbiri',
      quest: 'neither',
    ),
    Words2(
      front: 'She felt a bit nervous before giving her presentation.',
      back: 'Sunumunu yapmadan önce biraz gergin hissetti.',
      list: 'A2',
      answer: 'gergin',
      quest: 'nervous',
    ),
    Words2(
      front: "My phone can't connect to the network in this remote area.",
      back: 'Telefonum bu ıssız bölgede ağa bağlanamıyor.',
      list: 'A2',
      answer: 'ağ',
      quest: 'network',
    ),
    Words2(
      front: 'The loud noise from the traffic woke me up this morning.',
      back: 'Yüksek sesli trafik gürültüsü beni bu sabah uyandırdı.',
      list: 'A2',
      answer: 'ses',
      quest: 'noise',
    ),
    Words2(
      front: 'The construction site next door is very noisy.',
      back: 'Yandaki inşaat şantiyesi çok gürültülü.',
      list: 'A2',
      answer: 'gürültücü',
      quest: 'noisy',
    ),
    Words2(
      front: "I don't have none of my keys. I must have lost them.",
      back: 'Hiçbir anahtarım yok. Kaybetmiş olmalıyım.',
      list: 'A2',
      answer: 'hiçbiri',
      quest: 'none',
    ),
    Words2(
      front: 'Did you notice the new restaurant that opened on Main Street?',
      back: "Ana Cadde'de açılan yeni restoranı fark ettin mi?",
      list: 'A2',
      answer: 'duyuru',
      quest: 'notice',
    ),
    Words2(
      front: 'Did you notice the new restaurant that opened on Main Street?',
      back: "Ana Cadde'de açılan yeni restoranı fark ettin mi?",
      list: 'A2',
      answer: 'duyuru',
      quest: 'notice',
    ),
    Words2(
      front: 'I am reading an interesting novel by a famous author.',
      back: 'Ünlü bir yazarın yazdığı ilginç bir roman okuyorum.',
      list: 'A2',
      answer: 'roman',
      quest: 'novel',
    ),
    Words2(
      front: "I can't find my phone anywhere. It must be nowhere to be found.",
      back: 'Telefonumu hiçbir yerde bulamıyorum. Herhalde kaybolmuştur.',
      list: 'A2',
      answer: 'hiçbir yer',
      quest: 'nowhere',
    ),
    Words2(
      front: 'Are these peanuts or cashews?',
      back: 'Bunlar fıstık mı yoksa kaju mu?',
      list: 'A2',
      answer: 'fıstık',
      quest: 'peanut',
    ),
    Words2(
      front: 'The Pacific Ocean is the largest ocean in the world.',
      back: 'Pasifik Okyanusu, dünyanın en büyük okyanusudur.',
      list: 'A2',
      answer: 'okyanus',
      quest: 'ocean',
    ),
    Words2(
      front: 'The company offered me a job, but I declined.',
      back: 'Şirket bana bir iş teklif etti, ama reddettim.',
      list: 'A2',
      answer: 'teklif vermek',
      quest: 'offer',
    ),
    Words2(
      front: 'The police officer asked me for my identification.',
      back: 'Memur benden kimliğimi istedi.',
      list: 'A2',
      answer: 'memur',
      quest: 'officer',
    ),
  ];
}
