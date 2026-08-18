import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/transaction_model.dart';

class TransactionProvider extends ChangeNotifier {
  // =========================================================
  // STORAGE KEY
  // =========================================================

  static const String _storageKey = 'transactions';

  // =========================================================
  // TRANSACTIONS LIST
  // =========================================================

  final List<TransactionModel> _transactions = [];

  // =========================================================
  // SEARCH / FILTER VARIABLES
  // =========================================================

  String _searchQuery = '';

  String _selectedCategory = 'All';

  DateTime? _selectedMonth;

  // =========================================================
  // BASIC GETTERS
  // =========================================================

  List<TransactionModel> get transactions {
    return List.unmodifiable(_transactions);
  }

  String get searchQuery {
    return _searchQuery;
  }

  String get selectedCategory {
    return _selectedCategory;
  }

  DateTime? get selectedMonth {
    return _selectedMonth;
  }

  // =========================================================
  // FILTERED TRANSACTIONS
  // =========================================================

  List<TransactionModel> get filteredTransactions {
    return _transactions.where((transaction) {
      // SEARCH
      final matchesSearch = transaction.title
          .toLowerCase()
          .contains(
        _searchQuery.toLowerCase(),
      );

      // CATEGORY
      final matchesCategory =
          _selectedCategory == 'All' ||
              transaction.category ==
                  _selectedCategory;

      // MONTH
      final matchesMonth =
          _selectedMonth == null ||
              (
                  transaction.date.year ==
                      _selectedMonth!.year &&
                      transaction.date.month ==
                          _selectedMonth!.month
              );

      return matchesSearch &&
          matchesCategory &&
          matchesMonth;
    }).toList();
  }

  // =========================================================
  // CATEGORIES
  // =========================================================

  List<String> get categories {
    final categories = _transactions
        .map(
          (transaction) =>
      transaction.category,
    )
        .toSet()
        .toList();

    categories.sort();

    return [
      'All',
      ...categories,
    ];
  }

  // =========================================================
  // SEARCH
  // =========================================================

  void setSearchQuery(String query) {
    _searchQuery = query;

    notifyListeners();
  }

  // =========================================================
  // CATEGORY FILTER
  // =========================================================

  void setCategory(String category) {
    _selectedCategory = category;

    notifyListeners();
  }

  // =========================================================
  // MONTH FILTER
  // =========================================================

  void setSelectedMonth(
      DateTime? month,
      ) {
    _selectedMonth = month;

    notifyListeners();
  }

  // =========================================================
  // CLEAR FILTERS
  // =========================================================

  void clearFilters() {
    _searchQuery = '';

    _selectedCategory = 'All';

    _selectedMonth = null;

    notifyListeners();
  }

  // =========================================================
  // LOAD TRANSACTIONS
  // =========================================================

  Future<void> loadTransactions() async {
    final prefs =
    await SharedPreferences
        .getInstance();

    final savedData =
    prefs.getString(
      _storageKey,
    );

    // No saved data
    if (savedData == null) {
      return;
    }

    try {
      final List<dynamic> decodedData =
      jsonDecode(savedData);

      _transactions.clear();

      for (final item in decodedData) {
        _transactions.add(
          TransactionModel(
            id: item['id'],
            title: item['title'],
            amount:
            (item['amount'] as num)
                .toDouble(),
            category: item['category'],
            date: DateTime.parse(
              item['date'],
            ),
            isIncome: item['isIncome'],
          ),
        );
      }

      notifyListeners();
    } catch (e) {
      debugPrint(
        'Error loading transactions: $e',
      );
    }
  }

  // =========================================================
  // SAVE TRANSACTIONS
  // =========================================================

  Future<void> _saveTransactions() async {
    final prefs =
    await SharedPreferences
        .getInstance();

    final data =
    _transactions.map(
          (transaction) {
        return {
          'id': transaction.id,
          'title': transaction.title,
          'amount': transaction.amount,
          'category':
          transaction.category,
          'date': transaction.date
              .toIso8601String(),
          'isIncome':
          transaction.isIncome,
        };
      },
    ).toList();

    await prefs.setString(
      _storageKey,
      jsonEncode(data),
    );
  }

  // =========================================================
  // ADD TRANSACTION
  // =========================================================

  Future<void> addTransaction({
    required String title,
    required double amount,
    required String category,
    required DateTime date,
    required bool isIncome,
  }) async {
    final transaction =
    TransactionModel(
      id: DateTime.now()
          .millisecondsSinceEpoch
          .toString(),

      title: title,

      amount: amount,

      category: category,

      date: date,

      isIncome: isIncome,
    );

    _transactions.insert(
      0,
      transaction,
    );

    await _saveTransactions();

    notifyListeners();
  }

  // =========================================================
  // UPDATE TRANSACTION
  // =========================================================

  Future<void> updateTransaction({
    required String id,
    required String title,
    required double amount,
    required String category,
    required DateTime date,
    required bool isIncome,
  }) async {
    final index =
    _transactions.indexWhere(
          (transaction) =>
      transaction.id == id,
    );

    // Transaction not found
    if (index == -1) {
      return;
    }

    _transactions[index] =
        TransactionModel(
          id: id,
          title: title,
          amount: amount,
          category: category,
          date: date,
          isIncome: isIncome,
        );

    await _saveTransactions();

    notifyListeners();
  }

  // =========================================================
  // DELETE SINGLE TRANSACTION
  // =========================================================

  Future<void> deleteTransaction(
      String id,
      ) async {
    _transactions.removeWhere(
          (transaction) =>
      transaction.id == id,
    );

    await _saveTransactions();

    notifyListeners();
  }

  // =========================================================
  // DELETE ALL TRANSACTIONS
  // =========================================================

  Future<void> clearAllTransactions() async {
    _transactions.clear();

    await _saveTransactions();

    // Filters bhi reset
    _searchQuery = '';

    _selectedCategory = 'All';

    _selectedMonth = null;

    notifyListeners();
  }

  // =========================================================
  // TOTAL INCOME
  // =========================================================

  double get totalIncome {
    double total = 0;

    for (final transaction
    in _transactions) {
      if (transaction.isIncome) {
        total += transaction.amount;
      }
    }

    return total;
  }

  // =========================================================
  // TOTAL EXPENSE
  // =========================================================

  double get totalExpense {
    double total = 0;

    for (final transaction
    in _transactions) {
      if (!transaction.isIncome) {
        total += transaction.amount;
      }
    }

    return total;
  }

  // =========================================================
  // BALANCE
  // =========================================================

  double get balance {
    return totalIncome - totalExpense;
  }

  // =========================================================
  // MONTHLY INCOME
  // =========================================================

  double monthlyIncome(
      int year,
      int month,
      ) {
    double total = 0;

    for (final transaction
    in _transactions) {
      if (
      transaction.isIncome &&
          transaction.date.year == year &&
          transaction.date.month == month
      ) {
        total += transaction.amount;
      }
    }

    return total;
  }

  // =========================================================
  // MONTHLY EXPENSE
  // =========================================================

  double monthlyExpense(
      int year,
      int month,
      ) {
    double total = 0;

    for (final transaction
    in _transactions) {
      if (
      !transaction.isIncome &&
          transaction.date.year == year &&
          transaction.date.month == month
      ) {
        total += transaction.amount;
      }
    }

    return total;
  }

  // =========================================================
  // LAST 6 MONTHS
  // =========================================================

  List<DateTime> get lastSixMonths {
    final now = DateTime.now();

    return List.generate(
      6,
          (index) {
        return DateTime(
          now.year,
          now.month - (5 - index),
        );
      },
    );
  }
}