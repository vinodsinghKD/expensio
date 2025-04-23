import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

double safeDouble(dynamic value){
  try{
    return double.parse(value);
  }catch(err){
    return 0;
  }
}Future<void> v1(Database database) async {
  debugPrint("Running first migration....");

  // 1️⃣ payments table (unchanged)
  await database.execute("""
    CREATE TABLE payments (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT NULL,
      description TEXT NULL,
      account INTEGER,
      category INTEGER,
      amount REAL,
      type TEXT,
      datetime DATETIME
    );
  """);

  // 2️⃣ categories table (added `expense` column)
  await database.execute("""
    CREATE TABLE categories (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT,
      icon INTEGER,
      color INTEGER,
      budget REAL NULL,
      expense REAL   DEFAULT 0.0,
      type TEXT
    );
  """);

  // 3️⃣ accounts table (icon as TEXT + income/expense/balance)
  await database.execute("""
    CREATE TABLE accounts (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT,
      holderName TEXT NULL,
      accountNumber TEXT NULL,
      icon TEXT,
      color INTEGER,
      isDefault INTEGER,
      income REAL   DEFAULT 0.0,
      expense REAL  DEFAULT 0.0,
      balance REAL  DEFAULT 0.0
    );
  """);
}
