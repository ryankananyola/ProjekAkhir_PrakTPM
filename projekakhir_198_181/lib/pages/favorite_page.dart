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

  void _handleDelete(BuildContext context, int id, String name) async {
    await FavoriteHelper.removeFavorite(id);
    _loadFavorites();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Resep "$name" dihapus dari favorit.'),
        duration: const Duration(seconds: 2),
      ),
    );
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
                return RecipeCard(
                  recipe: recipe,
                  showRating: true,
                  onDelete: () => _handleDelete(context, recipe.id, recipe.name),
                );
              },
            ),
    );
  }
}
