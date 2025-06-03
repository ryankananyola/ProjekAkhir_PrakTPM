import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:projekakhir_198_181/models/recipe_model.dart';
import 'package:projekakhir_198_181/models/recipe_detail_model.dart';
import 'package:projekakhir_198_181/services/recipe_service.dart';

class RecipeDetailScreen extends StatefulWidget {
  final int recipeId;

  const RecipeDetailScreen({Key? key, required this.recipeId}) : super(key: key);

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> with SingleTickerProviderStateMixin {
  late Future<RecipeServiceDetail> _recipeDetailFuture;
  late TabController _tabController;
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _recipeDetailFuture = RecipeService.fetchRecipeDetail(widget.recipeId);
    _checkIfFavorite();
  }

  Future<void> _checkIfFavorite() async {
    final box = Hive.box<Recipe>('favorites');
    final isFav = box.values.any((r) => r.id == widget.recipeId);
    setState(() {
      isFavorite = isFav;
    });
  }

  void _toggleFavorite(RecipeServiceDetail detail) {
    final box = Hive.box<Recipe>('favorites');
    final recipe = Recipe(
      id: detail.id,
      name: detail.name,
      image: detail.image,
      cuisine: detail.cuisine,
      rating: detail.rating,
    );

    if (isFavorite) {
      final existingKey = box.keys.firstWhere((key) => box.get(key)!.id == recipe.id, orElse: () => null);
      if (existingKey != null) {
        box.delete(existingKey);
      }
    } else {
      box.add(recipe);
    }

    setState(() {
      isFavorite = !isFavorite;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<RecipeServiceDetail>(
        future: _recipeDetailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('Data tidak ditemukan.'));
          }

          final recipe = snapshot.data!;
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 250,
                pinned: true,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                actions: [
                  IconButton(
                    icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border, color: Colors.redAccent),
                    onPressed: () => _toggleFavorite(recipe),
                  )
                ],
                flexibleSpace: FlexibleSpaceBar(
                  title: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    color: Colors.black.withOpacity(0.5),
                    child: Text(
                      recipe.name,
                      style: const TextStyle(fontSize: 14, color: Colors.white),
                    ),
                  ),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(recipe.image, fit: BoxFit.cover),
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.black54, Colors.transparent, Colors.black26],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    TabBar(
                      controller: _tabController,
                      labelColor: Theme.of(context).primaryColor,
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: Theme.of(context).primaryColor,
                      tabs: const [
                        Tab(text: 'Informasi'),
                        Tab(text: 'Bahan'),
                        Tab(text: 'Langkah'),
                      ],
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height - 320,
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildInfoTab(recipe),
                          _buildIngredientsTab(recipe),
                          _buildInstructionsTab(recipe),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInfoTab(RecipeServiceDetail recipe) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 3,
            shadowColor: Colors.black12,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _infoRow(Icons.access_time, 'Durasi: ${recipe.prepTimeMinutes + recipe.cookTimeMinutes} menit'),
                  const Divider(),
                  _infoRow(Icons.people, 'Porsi: ${recipe.servings} orang'),
                  const Divider(),
                  _infoRow(Icons.bolt, 'Tingkat: ${recipe.difficulty}'),
                  const Divider(),
                  _infoRow(Icons.restaurant, 'Masakan: ${recipe.cuisine}'),
                  const Divider(),
                  _infoRow(Icons.local_fire_department, 'Kalori/porsi: ${recipe.caloriesPerServing} kkal'),
                  const Divider(),
                  _infoRow(Icons.star, 'Rating: ${recipe.rating} ⭐ (${recipe.reviewCount} review)'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Tag:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: recipe.tags.map((tag) => Chip(label: Text(tag))).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientsTab(RecipeServiceDetail recipe) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView.separated(
        itemCount: recipe.ingredients.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (context, index) {
          return ListTile(
            leading: const Icon(Icons.circle, size: 10),
            title: Text(recipe.ingredients[index]),
          );
        },
      ),
    );
  }

  Widget _buildInstructionsTab(RecipeServiceDetail recipe) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView.builder(
        itemCount: recipe.instructions.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: CircleAvatar(
              radius: 16,
              backgroundColor: Theme.of(context).primaryColor,
              child: Text('${index + 1}', style: const TextStyle(color: Colors.white)),
            ),
            title: Text(recipe.instructions[index]),
          );
        },
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 22, color: Colors.blueAccent),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 16))),
      ],
    );
  }
}
