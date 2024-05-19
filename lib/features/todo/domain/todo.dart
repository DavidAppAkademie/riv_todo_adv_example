import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
part 'todo.freezed.dart';
part 'todo.g.dart';

@freezed
abstract class Todo with _$Todo {
  const factory Todo({required String title, required String description}) =
      _Todo;
  const Todo._();
  factory Todo.fromJson(Map<String, dynamic> json) => _$TodoFromJson(json);

  factory Todo.fromDocumentSnapshot(
      DocumentSnapshot<Map<String, dynamic>> documentSnapshot) {
    final data = documentSnapshot.data()!;
    return Todo.fromJson(data);
  }
}
