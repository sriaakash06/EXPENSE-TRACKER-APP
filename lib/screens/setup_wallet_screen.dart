import 'package:flutter/material.dart';
import '../providers/expense_provider.dart';

class SetupWalletScreen extends StatefulWidget {
  final ExpenseProvider provider;
  const SetupWalletScreen({super.key, required this.provider});

  @override
  State<SetupWalletScreen> createState() => _SetupWalletScreenState();
}

class _SetupWalletScreenState extends State<SetupWalletScreen> {
  final TextEditingController _amountCtrl = TextEditingController();

  void _save() {
    final amount = double.tryParse(_amountCtrl.text.trim());
    if (amount != null && amount >= 0) {
      widget.provider.setInitialWalletBalance(amount);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.account_balance_wallet_rounded, size: 64, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 24),
              Text(
                'Welcome to Tracker!',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
              ),
              const SizedBox(height: 8),
              Text(
                'Please enter your initial wallet balance to get started.',
                style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _amountCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Initial Balance (₹)',
                  prefixIcon: const Icon(Icons.currency_rupee_rounded),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.onSurface,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text('Continue', style: TextStyle(fontSize: 18, color: Theme.of(context).cardColor)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
