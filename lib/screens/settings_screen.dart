import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/theme_provider.dart';
import '../providers/transaction_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider =
    context.watch<ThemeProvider>();

    final transactionProvider =
    context.watch<TransactionProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          // =====================================
          // APPEARANCE
          // =====================================

          const Text(
            'Appearance',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          Card(
            child: SwitchListTile(
              secondary: Icon(
                themeProvider.isDarkMode
                    ? Icons.dark_mode
                    : Icons.light_mode,
              ),

              title: const Text(
                'Dark Mode',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),

              subtitle: Text(
                themeProvider.isDarkMode
                    ? 'Dark theme is ON'
                    : 'Light theme is ON',
              ),

              value: themeProvider.isDarkMode,

              onChanged: (_) {
                context
                    .read<ThemeProvider>()
                    .toggleTheme();
              },
            ),
          ),

          const SizedBox(height: 25),

          // =====================================
          // DATA
          // =====================================

          const Text(
            'Data',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          Card(
            child: ListTile(
              leading: const Icon(
                Icons.delete_forever,
                color: Colors.red,
              ),

              title: const Text(
                'Clear All Transactions',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),

              subtitle: Text(
                '${transactionProvider.transactions.length} transactions saved',
              ),

              trailing: const Icon(
                Icons.arrow_forward_ios,
                size: 16,
              ),

              onTap: () {
                _showDeleteDialog(
                  context,
                );
              },
            ),
          ),

          const SizedBox(height: 25),

          // =====================================
          // ABOUT
          // =====================================

          const Text(
            'About',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          Card(
            child: ListTile(
              leading: const Icon(
                Icons.info_outline,
              ),

              title: const Text(
                'About Expense Tracker',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),

              subtitle: const Text(
                'Version 1.0.0',
              ),

              trailing: const Icon(
                Icons.arrow_forward_ios,
                size: 16,
              ),

              onTap: () {
                _showAboutDialog(
                  context,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // =========================================
  // DELETE DIALOG
  // =========================================

  void _showDeleteDialog(
      BuildContext context,
      ) {
    showDialog(
      context: context,

      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Delete All Transactions?',
          ),

          content: const Text(
            'All your saved transactions '
                'will be permanently deleted. '
                'This action cannot be undone.',
          ),

          actions: [

            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                );
              },

              child: const Text(
                'Cancel',
              ),
            ),

            ElevatedButton(
              onPressed: () async {

                await context
                    .read<
                    TransactionProvider>()
                    .clearAllTransactions();

                if (dialogContext.mounted) {
                  Navigator.pop(
                    dialogContext,
                  );

                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'All transactions deleted',
                      ),
                    ),
                  );
                }
              },

              child: const Text(
                'Delete All',
              ),
            ),
          ],
        );
      },
    );
  }

  // =========================================
  // ABOUT DIALOG
  // =========================================

  void _showAboutDialog(
      BuildContext context,
      ) {
    showAboutDialog(
      context: context,

      applicationName:
      'Expense Tracker',

      applicationVersion:
      '1.0.0',

      applicationIcon: const Icon(
        Icons.account_balance_wallet,
        size: 40,
      ),

      children: const [
        Text(
          'A simple expense management '
              'application built with Flutter.',
        ),

        SizedBox(height: 15),

        Text(
          'Features include income tracking, '
              'expense tracking, search, filters, '
              'statistics, charts and dark mode.',
        ),
      ],
    );
  }
}