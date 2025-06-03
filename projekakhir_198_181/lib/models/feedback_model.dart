import 'package:hive/hive.dart';

part 'feedback_model.g.dart';

@HiveType(typeId: 1)
class FeedbackModel extends HiveObject {
  @HiveField(0)
  final int recipeId;

  @HiveField(1)
  String comment;

  FeedbackModel({required this.recipeId, required this.comment});
}
