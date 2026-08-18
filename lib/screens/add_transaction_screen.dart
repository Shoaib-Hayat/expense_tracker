import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/transaction_provider.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() =>
      _AddTransactionScreenState();
}

class _AddTransactionScreenState
    extends State<AddTransactionScreen> {

  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();

  final _amountController = TextEditingController();

  bool _isIncome = false;

  String _selectedCategory = 'Food';

  DateTime _selectedDate = DateTime.now();

  final List<String> _categories = [
    'Food',
    'Shopping',
    'Transport',
    'Bills',
    'Education',
    'Health',
    'Entertainment',
    'Other',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  // =========================
  // DATE PICKER
  // =========================

  Future<void> _selectDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  // =========================
  // SAVE TRANSACTION
  // =========================

  void _saveTransaction() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final title = _titleController.text.trim();

    final amount = double.parse(
      _amountController.text.trim(),
    );

    context.read<TransactionProvider>().addTransaction(
      title: title,
      amount: amount,
      category: _selectedCategory,
      date: _selectedDate,
      isIncome: _isIncome,
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add Transaction',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: Form(
        key: _formKey,

        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),

          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,

            children: [

              // =========================
              // TRANSACTION TYPE
              // =========================

              const Text(
                'Transaction Type',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              Row(
                children: [

                  Expanded(
                    child: ChoiceChip(
                      label:
                      const Text('Expense'),
                      selected: !_isIncome,
                      onSelected: (_) {
                        setState(() {
                          _isIncome = false;
                        });
                      },
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: ChoiceChip(
                      label:
                      const Text('Income'),
                      selected: _isIncome,
                      onSelected: (_) {
                        setState(() {
                          _isIncome = true;
                        });
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              // =========================
              // TITLE
              // =========================

              TextFormField(
                controller: _titleController,

                decoration:
                const InputDecoration(
                  labelText: 'Title',
                  hintText: 'e.g. Grocery',
                  prefixIcon:
                  Icon(Icons.title),
                  border:
                  OutlineInputBorder(),
                ),

                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return 'Please enter title';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              // =========================
              // AMOUNT
              // =========================

              TextFormField(
                controller:
                _amountController,

                keyboardType:
                const TextInputType
                    .numberWithOptions(
                  decimal: true,
                ),

                decoration:
                const InputDecoration(
                  labelText: 'Amount',
                  hintText: 'e.g. 500',
                  prefixIcon: Icon(
                    Icons.currency_exchange,
                  ),
                  border:
                  OutlineInputBorder(),
                ),

                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return 'Please enter amount';
                  }

                  final amount =
                  double.tryParse(
                    value.trim(),
                  );

                  if (amount == null ||
                      amount <= 0) {
                    return 'Enter a valid amount';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              // =========================
              // CATEGORY
              // =========================

              DropdownButtonFormField<String>(
                initialValue:
                _selectedCategory,

                decoration:
                const InputDecoration(
                  labelText: 'Category',
                  prefixIcon:
                  Icon(Icons.category),
                  border:
                  OutlineInputBorder(),
                ),

                items:
                _categories.map(
                      (category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  },
                ).toList(),

                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedCategory =
                          value;
                    });
                  }
                },
              ),

              const SizedBox(height: 16),

              // =========================
              // DATE
              // =========================

              InkWell(
                onTap: _selectDate,

                borderRadius:
                BorderRadius.circular(12),

                child: InputDecorator(
                  decoration:
                  const InputDecoration(
                    labelText: 'Date',
                    prefixIcon: Icon(
                      Icons.calendar_month,
                    ),
                    border:
                    OutlineInputBorder(),
                  ),

                  child: Text(
                    '${_selectedDate.day}/'
                        '${_selectedDate.month}/'
                        '${_selectedDate.year}',
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // =========================
              // SAVE BUTTON
              // =========================

              SizedBox(
                width: double.infinity,
                height: 55,

                child: ElevatedButton.icon(
                  onPressed:
                  _saveTransaction,

                  icon: const Icon(
                    Icons.save,
                  ),

                  label: const Text(
                    'Save Transaction',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}