import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/transaction_provider.dart';

import 'add_transaction_screen.dart';
import 'edit_transaction_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      // =========================================
      // APP BAR
      // =========================================

      appBar: AppBar(
        title: const Text(
          'Expense Tracker',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        centerTitle: true,
      ),

      // =========================================
      // BODY
      // =========================================

      body: Consumer<TransactionProvider>(
        builder: (
            context,
            provider,
            child,
            ) {

          final transactions =
              provider.filteredTransactions;

          return SingleChildScrollView(
            padding:
            const EdgeInsets.all(16),

            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,

              children: [

                // =================================
                // BALANCE CARD
                // =================================

                Container(
                  width: double.infinity,

                  padding:
                  const EdgeInsets.all(24),

                  decoration: BoxDecoration(
                    color: Colors.deepPurple,

                    borderRadius:
                    BorderRadius.circular(20),
                  ),

                  child: Column(
                    children: [

                      const Text(
                        'Total Balance',

                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),

                      const SizedBox(
                        height: 8,
                      ),

                      Text(
                        'Rs. ${provider.balance.toStringAsFixed(2)}',

                        style:
                        const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(
                  height: 20,
                ),

                // =================================
                // INCOME + EXPENSE
                // =================================

                Row(
                  children: [

                    Expanded(
                      child: SummaryCard(
                        title: 'Income',

                        amount:
                        provider.totalIncome,

                        icon:
                        Icons.arrow_downward,

                        iconColor:
                        Colors.green,
                      ),
                    ),

                    const SizedBox(
                      width: 12,
                    ),

                    Expanded(
                      child: SummaryCard(
                        title: 'Expense',

                        amount:
                        provider.totalExpense,

                        icon:
                        Icons.arrow_upward,

                        iconColor:
                        Colors.red,
                      ),
                    ),
                  ],
                ),

                const SizedBox(
                  height: 25,
                ),

                // =================================
                // SEARCH
                // =================================

                TextField(
                  onChanged: (value) {

                    context
                        .read<
                        TransactionProvider>()
                        .setSearchQuery(
                      value,
                    );
                  },

                  decoration:
                  InputDecoration(
                    hintText:
                    'Search transaction...',

                    prefixIcon:
                    const Icon(
                      Icons.search,
                    ),

                    suffixIcon:
                    provider.searchQuery
                        .isNotEmpty
                        ? IconButton(
                      icon:
                      const Icon(
                        Icons.clear,
                      ),

                      onPressed: () {

                        context
                            .read<
                            TransactionProvider>()
                            .setSearchQuery(
                          '',
                        );
                      },
                    )
                        : null,

                    border:
                    OutlineInputBorder(
                      borderRadius:
                      BorderRadius.circular(
                        15,
                      ),
                    ),
                  ),
                ),

                const SizedBox(
                  height: 15,
                ),

                // =================================
                // CATEGORY FILTER
                // =================================

                const Text(
                  'Categories',

                  style: TextStyle(
                    fontSize: 18,
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),

                const SizedBox(
                  height: 10,
                ),

                SizedBox(
                  height: 45,

                  child:
                  ListView.separated(

                    scrollDirection:
                    Axis.horizontal,

                    itemCount:
                    provider.categories
                        .length,

                    separatorBuilder:
                        (_, __) =>
                    const SizedBox(
                      width: 8,
                    ),

                    itemBuilder:
                        (context, index) {

                      final category =
                      provider.categories[
                      index];

                      final isSelected =
                          provider
                              .selectedCategory ==
                              category;

                      return ChoiceChip(

                        label:
                        Text(category),

                        selected:
                        isSelected,

                        onSelected: (_) {

                          context
                              .read<
                              TransactionProvider>()
                              .setCategory(
                            category,
                          );
                        },
                      );
                    },
                  ),
                ),

                const SizedBox(
                  height: 15,
                ),

                // =================================
                // MONTH FILTER
                // =================================

                Row(
                  children: [

                    Expanded(
                      child:
                      OutlinedButton.icon(

                        onPressed:
                            () async {

                          final selected =
                          await showDatePicker(

                            context:
                            context,

                            initialDate:
                            DateTime.now(),

                            firstDate:
                            DateTime(2020),

                            lastDate:
                            DateTime(2100),

                            helpText:
                            'Select any date in the month',
                          );

                          if (selected !=
                              null &&
                              context.mounted) {

                            context
                                .read<
                                TransactionProvider>()
                                .setSelectedMonth(
                              selected,
                            );
                          }
                        },

                        icon:
                        const Icon(
                          Icons
                              .calendar_month,
                        ),

                        label: Text(

                          provider
                              .selectedMonth ==
                              null
                              ? 'Select Month'
                              : DateFormat(
                            'MMMM yyyy',
                          ).format(
                            provider
                                .selectedMonth!,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(
                      width: 10,
                    ),

                    // CLEAR BUTTON

                    if (provider.searchQuery
                        .isNotEmpty ||
                        provider
                            .selectedCategory !=
                            'All' ||
                        provider
                            .selectedMonth !=
                            null)

                      IconButton(
                        tooltip:
                        'Clear Filters',

                        onPressed: () {

                          context
                              .read<
                              TransactionProvider>()
                              .clearFilters();
                        },

                        icon:
                        const Icon(
                          Icons
                              .filter_alt_off,
                        ),
                      ),
                  ],
                ),

                const SizedBox(
                  height: 25,
                ),

                // =================================
                // TRANSACTIONS TITLE
                // =================================

                Row(
                  mainAxisAlignment:
                  MainAxisAlignment
                      .spaceBetween,

                  children: [

                    const Text(
                      'Transactions',

                      style: TextStyle(
                        fontSize: 20,
                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),

                    Text(
                      '${transactions.length}',

                      style: const TextStyle(
                        color: Colors.grey,
                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(
                  height: 12,
                ),

                // =================================
                // EMPTY STATE
                // =================================

                if (transactions.isEmpty)

                  const Center(
                    child: Padding(
                      padding:
                      EdgeInsets.all(40),

                      child: Column(
                        children: [

                          Icon(
                            Icons
                                .receipt_long,
                            size: 60,
                            color: Colors.grey,
                          ),

                          SizedBox(
                            height: 10,
                          ),

                          Text(
                            'No transactions found',

                            style:
                            TextStyle(
                              color:
                              Colors.grey,

                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )

                // =================================
                // TRANSACTION LIST
                // =================================

                else

                  ListView.builder(

                    shrinkWrap: true,

                    physics:
                    const NeverScrollableScrollPhysics(),

                    itemCount:
                    transactions.length,

                    itemBuilder:
                        (context, index) {

                      final transaction =
                      transactions[index];

                      return Card(

                        margin:
                        const EdgeInsets.only(
                          bottom: 10,
                        ),

                        child: ListTile(

                          // =================================
                          // ICON
                          // =================================

                          leading:
                          CircleAvatar(

                            backgroundColor:
                            transaction
                                .isIncome
                                ? Colors.green
                                .withValues(
                              alpha: 0.15,
                            )
                                : Colors.red
                                .withValues(
                              alpha: 0.15,
                            ),

                            child: Icon(

                              transaction
                                  .isIncome
                                  ? Icons
                                  .arrow_downward
                                  : Icons
                                  .arrow_upward,

                              color:

                              transaction
                                  .isIncome
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),

                          // =================================
                          // TITLE
                          // =================================

                          title: Text(

                            transaction.title,

                            style:
                            const TextStyle(
                              fontWeight:
                              FontWeight.bold,
                            ),
                          ),

                          // =================================
                          // CATEGORY + DATE
                          // =================================

                          subtitle: Text(

                            '${transaction.category} • '
                                '${DateFormat('dd MMM yyyy').format(transaction.date)}',
                          ),

                          // =================================
                          // AMOUNT + BUTTONS
                          // =================================

                          trailing:
                          Row(

                            mainAxisSize:
                            MainAxisSize.min,

                            children: [

                              Text(

                                '${transaction.isIncome ? '+' : '-'} '
                                    'Rs. ${transaction.amount.toStringAsFixed(2)}',

                                style:
                                TextStyle(

                                  fontWeight:
                                  FontWeight.bold,

                                  color:

                                  transaction
                                      .isIncome
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ),

                              // EDIT

                              IconButton(

                                icon:
                                const Icon(
                                  Icons
                                      .edit_outlined,
                                ),

                                onPressed: () {

                                  Navigator.push(

                                    context,

                                    MaterialPageRoute(

                                      builder: (_) =>
                                          EditTransactionScreen(
                                            transaction:
                                            transaction,
                                          ),
                                    ),
                                  );
                                },
                              ),

                              // DELETE

                              IconButton(

                                icon:
                                const Icon(
                                  Icons
                                      .delete_outline,
                                  color:
                                  Colors.red,
                                ),

                                onPressed: () {

                                  context
                                      .read<
                                      TransactionProvider>()
                                      .deleteTransaction(
                                    transaction.id,
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          );
        },
      ),

      // =========================================
      // ADD BUTTON
      // =========================================

      floatingActionButton:
      FloatingActionButton(

        onPressed: () {

          Navigator.push(

            context,

            MaterialPageRoute(
              builder: (_) =>
              const AddTransactionScreen(),
            ),
          );
        },

        child:
        const Icon(Icons.add),
      ),
    );
  }
}

// =============================================
// SUMMARY CARD
// =============================================

class SummaryCard
    extends StatelessWidget {

  final String title;

  final double amount;

  final IconData icon;

  final Color iconColor;

  const SummaryCard({
    super.key,

    required this.title,

    required this.amount,

    required this.icon,

    required this.iconColor,
  });

  @override
  Widget build(
      BuildContext context) {

    return Card(

      child: Padding(

        padding:
        const EdgeInsets.all(16),

        child: Column(

          children: [

            CircleAvatar(

              backgroundColor:
              iconColor.withValues(
                alpha: 0.15,
              ),

              child: Icon(
                icon,
                color:
                iconColor,
              ),
            ),

            const SizedBox(
              height: 8,
            ),

            Text(
              title,

              style:
              const TextStyle(
                color: Colors.grey,
              ),
            ),

            const SizedBox(
              height: 5,
            ),

            Text(

              'Rs. ${amount.toStringAsFixed(2)}',

              style:
              const TextStyle(
                fontSize: 18,
                fontWeight:
                FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}