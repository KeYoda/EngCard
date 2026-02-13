import 'package:eng_card/data/save_words.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:eng_card/data/favorite_list.dart';

class FavouritePage extends StatelessWidget {
  const FavouritePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Renkleri SixScreen'den veya yerel tanımlardan çekiyoruz
    // (Eğer SixScreen'de global tanımladıysanız oradan gelir, yoksa buradaki fallback çalışır)
    const Color gradientStart = Color(0xFF0F2027);
    const Color gradientEnd = Color(0xFF203A43);

    return Scaffold(
      extendBodyBehindAppBar: true, // AppBar arkasına gradient geçsin
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back_ios_new,
                color: Colors.white, size: 18),
          ),
        ),
        title: Text(
          'Favori Kelimeler',
          style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20.sp),
        ),
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [gradientStart, gradientEnd],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Consumer<FavoriteList>(
            builder: (context, favLists, child) {
              if (favLists.favorites.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.favorite_border,
                          color: Colors.white54, size: 60.sp),
                      SizedBox(height: 10.h),
                      Text(
                        "Henüz favori eklemediniz.",
                        style: GoogleFonts.poppins(
                            color: Colors.white70, fontSize: 16.sp),
                      )
                    ],
                  ),
                );
              }
              // Eski Card wrapper'ını kaldırdık, direkt listeyi veriyoruz
              return _FavouriteGrid(favorites: favLists.favorites);
            },
          ),
        ),
      ),
    );
  }
}

class _FavouriteGrid extends StatefulWidget {
  final List<SavedItem> favorites;

  const _FavouriteGrid({Key? key, required this.favorites}) : super(key: key);

  @override
  __FavouriteGridState createState() => __FavouriteGridState();
}

class __FavouriteGridState extends State<_FavouriteGrid> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  late List<SavedItem> _currentFavorites;

  // Renkler
  final Color accentColor = const Color(0xFFFF9F1C); // Turuncu
  final Color textColorMain = const Color(0xFF2EC4B6); // Turkuaz

  @override
  void initState() {
    super.initState();
    _currentFavorites = List.from(widget.favorites);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedList(
      key: _listKey,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      initialItemCount: _currentFavorites.length,
      itemBuilder: (context, index, animation) {
        // Liste dışına taşma kontrolü (Silme işlemi sırasında hata olmaması için)
        if (index >= _currentFavorites.length) return Container();

        final item = _currentFavorites[index];
        return _buildItem(context, item, index, animation);
      },
    );
  }

  Widget _buildItem(BuildContext context, SavedItem item, int index,
      Animation<double> animation) {
    return SizeTransition(
      sizeFactor: animation,
      child: Container(
        margin: EdgeInsets.only(bottom: 15.h), // Kartlar arası boşluk
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            )
          ],
        ),
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),

          // SOL TARA: Seviye Etiketi (A1, B2 vb.)
          leading: Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: textColorMain.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              item.lvClass,
              style: GoogleFonts.poppins(
                  color: textColorMain,
                  fontWeight: FontWeight.bold,
                  fontSize: 14.sp),
            ),
          ),

          // ORTA: Kelime ve Anlamı
          title: Text(
            item.question,
            style: GoogleFonts.poppins(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 16.sp),
          ),
          subtitle: Text(
            item.answer,
            style: GoogleFonts.poppins(
                color: Colors.grey,
                fontWeight: FontWeight.w500,
                fontSize: 14.sp),
          ),

          // SAĞ: Silme Butonu
          trailing: IconButton(
            onPressed: () {
              _removeItem(context, index);
            },
            icon: Icon(
              Icons.delete_outline_rounded,
              color: Colors.redAccent.withOpacity(0.8),
              size: 24.sp,
            ),
          ),
        ),
      ),
    );
  }

  void _removeItem(BuildContext context, int index) {
    if (index >= _currentFavorites.length) return;

    final removedItem = _currentFavorites[index];

    // Önce AnimatedList'ten görsel olarak sil
    _listKey.currentState?.removeItem(
      index,
      (context, animation) =>
          _buildItem(context, removedItem, index, animation),
      duration: const Duration(milliseconds: 300),
    );

    // Sonra yerel listeden sil
    setState(() {
      _currentFavorites.removeAt(index);
    });

    // En son Provider'dan sil (Veritabanı/Kalıcı hafıza)
    // Future.delayed kullanıyoruz ki animasyon bitmeden provider güncellenip ekranı rebuild etmesin
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        // Provider'daki orijinal listeden silmek için index'i değil, nesneyi bulmak daha güvenlidir
        // Ancak sizin provider yapınız index bazlıysa (ve sıra bozulmadıysa) index de olur.
        // Daha güvenli yöntem: Provider'a "deleteItem(SavedItem item)" metodu eklemektir.
        // Şimdilik mevcut yapınıza uyuyoruz:
        Provider.of<FavoriteList>(context, listen: false).deleteFavorite(index);
      }
    });
  }
}
