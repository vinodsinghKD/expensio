import 'package:flutter/material.dart';

class AppIcons {
  // 👇 Yeh nayi mapping add ki gayi hai: String ↔️ IconData
  static final Map<String, IconData> icons = {
    "wallet": Icons.wallet,
    "money": Icons.money,
    "account_balance": Icons.account_balance,
    "shopping_bag": Icons.shopping_bag,
    "fastfood": Icons.fastfood,
    "handshake": Icons.handshake,
    "public": Icons.public,
    "thumb_up": Icons.thumb_up,
    "face": Icons.face,
    "rocket_launch": Icons.rocket_launch,
    "eco": Icons.eco,
    "pets": Icons.pets,
    "emoji_objects": Icons.emoji_objects,
    "health_and_safety": Icons.health_and_safety,
    "monitor_heart": Icons.monitor_heart,
    "gavel": Icons.gavel,
    "diversity_3": Icons.diversity_3,
    "workspaces": Icons.workspaces,
    "cookie": Icons.cookie,
    "emoji_flags": Icons.emoji_flags,
    "hive": Icons.hive,
    "heart_broken": Icons.heart_broken,
    "medication_liquid": Icons.medication_liquid,
    "shopping_cart": Icons.shopping_cart,
    "landscape": Icons.landscape,
    "medication": Icons.medication,
    "verified": Icons.verified,
    "lock": Icons.lock,
    "celebration": Icons.celebration,
    "stars": Icons.stars,
    "developer_mode": Icons.developer_mode,
    "person": Icons.person,
    "bar_chart": Icons.bar_chart,
    "domain": Icons.domain,
    "leaderboard": Icons.leaderboard,
    "work": Icons.work,
    "credit_card": Icons.credit_card,
    "loyalty": Icons.loyalty,
    "card_membership": Icons.card_membership,
    "pallet": Icons.pallet,
    "restaurant": Icons.restaurant,
    "restaurant_menu": Icons.restaurant_menu,
    "join_full": Icons.join_full,
  };

  // 👇 Yeh iconData list ab bas values list hai
  static final List<IconData> iconsList = icons.values.toList();

  // 👇 Yeh string list agar tujhe iconName list chahiye ho UI com
  static final List<String> iconNames = icons.keys.toList();
}
