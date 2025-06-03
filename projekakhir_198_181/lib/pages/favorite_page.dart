import 'package:flutter/material.dart';
import '../models/recipe_model.dart';
import '../utils/favorite_helper.dart';
import '../widgets/recipe_card.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  List<Recipe> _favorites = [];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  void _loadFavorites() {
    setState(() {
      _favorites = FavoriteHelper.getAllFavorites();
    });
  }

  void _removeFavorite(int id) async {
    await FavoriteHelper.removeFavorite(id);
    _loadFavorites();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resep Favorit'),
        centerTitle: true,
      ),
      body: _favorites.isEmpty
          ? const Center(
              child: Text('Belum ada resep favorit.'),
            )
          : ListView.builder(
              itemCount: _favorites.length,
              itemBuilder: (context, index) {
                final recipe = _favorites[index];
                return Dismissible(
                  key: Key(recipe.id.toString()),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    color: Colors.red,
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (_) => _removeFavorite(recipe.id),
                  child: RecipeCard(recipe: recipe, showRating: true),
                );
              },
            ),
    );
  }
}
