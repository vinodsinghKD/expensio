import 'package:flutter/material.dart';

class Account {
  int? id;
  String name;
  String holderName;
  String accountNumber;
  String iconName; // Icon name as string
  Color color;
  bool? isDefault;
  double? balance;
  double? income;
  double? expense;

  Account({
    this.id,
    required this.name,
    required this.holderName,
    required this.accountNumber,
    required this.iconName,
    required this.color,
    this.isDefault,
    this.income,
    this.expense,
    this.balance,
  });

  factory Account.fromJson(Map<String, dynamic> data) => Account(
    id: data["id"],
    name: data["name"] ?? "",
    holderName: data["holderName"] ?? "",
    accountNumber: data["accountNumber"] ?? "",
    iconName: data["icon"] ?? "wallet", // fallback to 'wallet'
    color: Color(data["color"] ?? Colors.grey.value),
    isDefault: data["isDefault"] == 1 ? true : false,
    income: (data["income"] ?? 0).toDouble(),
    expense: (data["expense"] ?? 0).toDouble(),
    balance: (data["balance"] ?? 0).toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "holderName": holderName,
    "accountNumber": accountNumber,
    "icon": iconName,
    "color": color.value,
    "isDefault": (isDefault ?? false) ? 1 : 0,
    "income": income ?? 0,
    "expense": expense ?? 0,
    "balance": balance ?? 0,
  };

  /// Converts iconName to IconData for UI display
  IconData get icon => _getIconDataFromName(iconName);

  static IconData _getIconDataFromName(String name) {
    switch (name) {
      case 'wallet':
        return Icons.account_balance_wallet;
      case 'bank':
        return Icons.account_balance;
      case 'savings':
        return Icons.savings;
      case 'card':
        return Icons.credit_card;
      case 'cash':
        return Icons.money;
      default:
        return Icons.account_balance_wallet;
    }
  }
}
