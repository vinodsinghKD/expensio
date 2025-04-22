import 'package:flutter/material.dart';

class Category {
  int? id;
  String name;
  int iconCode;
  Color color;
  double? budget;
  double? expense;

  Category({
    this.id,
    required this.name,
    required this.iconCode,
    required this.color,
    this.budget,
    this.expense,
  });

  // 👇 Getter to safely use icon in UI
  IconData get icon => IconData(iconCode, fontFamily: 'MaterialIcons');

  factory Category.fromJson(Map<String, dynamic> data) => Category(
    id: data["id"],
    name: data["name"],
    iconCode: data["icon"],
    color: Color(data["color"]),
    budget: (data["budget"] ?? 0).toDouble(),
    expense: (data["expense"] ?? 0).toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "icon": iconCode,
    "color": color.value,
    "budget": budget ?? 0,
    "expense": expense ?? 0,
  };
}
