import 'package:eng_card/data/save_words.dart';
import 'package:eng_card/screens/six_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eng_card/data/favorite_list.dart';

class FavouritePage extends StatelessWidget {
  const FavouritePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whites,
      appBar: AppBar(
        backgroundColor: whites,
        title: Text(
          'Favori Kelimeler',
          style: TextStyle(color: hardgreen, fontWeight: FontWeight.bold),
        ),
        iconTheme: IconThemeData(color: whites),
        centerTitle: true,
      ),
      body: Consumer<FavoriteList>(
        builder: (context, favLists, child) {
          return Card(
            color: hardgreen,
            child: _FavouriteGrid(favorites: favLists.favorites),
          );
        },
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

  @override
  void initState() {
    super.initState();
    _currentFavorites = List.from(widget.favorites);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedList(
      key: _listKey,
      initialItemCount: _currentFavorites.length,
      itemBuilder: (context, index, animation) {
        final item = _currentFavorites[index];
        return _buildItem(context, item, index, animation);
      },
    );
  }

  Widget _buildItem(BuildContext context, SavedItem item, int index,
      Animation<double> animation) {
    return SizeTransition(
      sizeFactor: animation,
      child: Card(
        margin: const EdgeInsets.all(7),
        elevation: 4,
        shadowColor: Colors.grey,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25.0),
        ),
        color: whites,
        child: ListTile(
          title: Text(
            '     ${item.question}',
            textAlign: TextAlign.center,
            style: TextStyle(color: hardgreen, fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            '      ${item.answer}',
            style: TextStyle(color: yellow, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          leading: Text(
            item.lvClass,
            style: TextStyle(color: hardgreen, fontWeight: FontWeight.bold),
          ),
          trailing: IconButton(
            onPressed: () {
              _removeItem(context, index);
            },
            icon: Icon(
              Icons.cancel_outlined,
              color: orange,
              size: 17,
            ),
          ),
        ),
      ),
    );
  }

  void _removeItem(BuildContext context, int index) {
    final removedItem = _currentFavorites[index];

    // Remove the item from the AnimatedList first
    _listKey.currentState?.removeItem(
      index,
      (context, animation) =>
          _buildItem(context, removedItem, index, animation),
      duration: const Duration(milliseconds: 300),
    );

    // Then update the state to remove the item from the list
    setState(() {
      _currentFavorites.removeAt(index);
    });

    // Finally, update the provider
    Provider.of<FavoriteList>(context, listen: false).deleteFavorite(index);
  }
}
