class Words {
  final String list; // Seviye (A1, A2 vb.)
  final String quest; // İngilizce Kelime
  final String answer; // Türkçe Karşılığı
  final String front; // İngilizce Cümle
  final String back; // Türkçe Cümle

  Words({
    required this.list,
    required this.quest,
    required this.answer,
    required this.front,
    required this.back,
  });

  // --- BU KISMI EKLEYİN: Nesneyi JSON'a çevirir (Kaydetmek için) ---
  Map<String, dynamic> toJson() => {
        'list': list,
        'quest': quest,
        'answer': answer,
        'front': front,
        'back': back,
      };

  // --- BU KISMI EKLEYİN: JSON'dan Nesne oluşturur (Yüklemek için) ---
  factory Words.fromJson(Map<String, dynamic> json) {
    return Words(
      list: json['list'] as String,
      quest: json['quest'] as String,
      answer: json['answer'] as String,
      front: json['front'] as String,
      back: json['back'] as String,
    );
  }
}
