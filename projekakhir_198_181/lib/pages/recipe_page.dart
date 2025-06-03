import 'package:flutter/material.dart';
import '../services/recipe_service.dart';
import '../models/recipe_model.dart';
import '../widgets/recipe_card.dart';

class RecipePage extends StatefulWidget {
  const RecipePage({super.key});

  @override
  State<RecipePage> createState() => _RecipePageState();
}

class _RecipePageState extends State<RecipePage> {
  late Future<List<Recipe>> _recipeFuture;
  List<Recipe> _allRecipes = [];
  List<Recipe> _filteredRecipes = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _recipeFuture = RecipeService.fetchRecipes();
    _recipeFuture.then((data) {
      setState(() {
        _allRecipes = data;
        _filteredRecipes = data;
      });
    });
  }

  void _filterRecipes(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
      _filteredRecipes = _allRecipes.where((recipe) {
        return recipe.name.toLowerCase().contains(_searchQuery) ||
               recipe.cuisine.toLowerCase().contains(_searchQuery);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: const Text(
          'Resep',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            tooltip: 'Favorit',
            onPressed: () {
              Navigator.pushNamed(context, '/favorites');
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Recipe>>(
        future: _recipeFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Tidak ada resep ditemukan.'));
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Cari resep atau cuisine...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: _filterRecipes,
                ),
              ),
              Expanded(
                child: _filteredRecipes.isEmpty
                    ? const Center(child: Text('Tidak ada hasil ditemukan.'))
                    : ListView.builder(
                        itemCount: _filteredRecipes.length,
                        itemBuilder: (context, index) {
                          return RecipeCard(
                            recipe: _filteredRecipes[index],
                            showRating: true,
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
