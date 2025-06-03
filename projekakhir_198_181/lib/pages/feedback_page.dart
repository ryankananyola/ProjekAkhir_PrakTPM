import 'package:flutter/material.dart';
import '../models/recipe_model.dart';
import '../models/feedback_model.dart';
import '../utils/feedback_helper.dart';

class FeedbackPage extends StatefulWidget {
  final Recipe recipe;
  const FeedbackPage({super.key, required this.recipe});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final TextEditingController _controller = TextEditingController();
  List<FeedbackModel> _feedbackList = [];
  int? _editingIndex;

  @override
  void initState() {
    super.initState();
    _loadFeedback();
  }

  Future<void> _loadFeedback() async {
    final feedbacks = await FeedbackHelper.getFeedbacksByRecipe(widget.recipe.id);
    setState(() {
      _feedbackList = feedbacks;
    });
  }

  Future<void> _submitFeedback() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    if (_editingIndex == null) {
      await FeedbackHelper.addFeedback(
        FeedbackModel(recipeId: widget.recipe.id, comment: text),
      );
    } else {
      final updated = FeedbackModel(recipeId: widget.recipe.id, comment: text);
      await FeedbackHelper.updateFeedback(_editingIndex!, updated);
      _editingIndex = null;
    }

    _controller.clear();
    _loadFeedback();
  }

  void _startEdit(int index) {
    setState(() {
      _editingIndex = index;
      _controller.text = _feedbackList[index].comment;
    });
  }

  Future<void> _deleteFeedback(int index) async {
    await FeedbackHelper.deleteFeedback(index);
    _loadFeedback();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Saran untuk ${widget.recipe.name}')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(children: [
              Image.network(widget.recipe.image, width: 60, height: 60, fit: BoxFit.cover),
              const SizedBox(width: 12),
              Expanded(child: Text(widget.recipe.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
            ]),
            const SizedBox(height: 20),
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: _editingIndex == null ? 'Tulis saran atau masukan...' : 'Edit saran',
                suffixIcon: IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _submitFeedback,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Daftar Saran/Masukan:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: _feedbackList.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_feedbackList[index].comment),
                    trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.orange),
                        onPressed: () => _startEdit(index),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteFeedback(index),
                      ),
                    ]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
