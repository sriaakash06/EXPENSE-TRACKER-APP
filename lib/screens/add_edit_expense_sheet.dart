import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../models/expense.dart';
import '../providers/expense_provider.dart';

class AddEditExpenseSheet extends StatefulWidget {
  final ExpenseProvider provider;
  final Expense? expense;

  const AddEditExpenseSheet({
    super.key,
    required this.provider,
    this.expense,
  });

  @override
  State<AddEditExpenseSheet> createState() => _AddEditExpenseSheetState();
}

class _AddEditExpenseSheetState extends State<AddEditExpenseSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleCtrl;
  late TextEditingController _amountCtrl;
  late TextEditingController _noteCtrl;
  late ExpenseCategory _selectedCategory;
  late DateTime _selectedDate;
  bool _isSaving = false;

  // Track if we are in category picking mode or details mode
  bool _pickingCategory = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    final e = widget.expense;
    _titleCtrl = TextEditingController(text: e?.title ?? '');
    _amountCtrl = TextEditingController(text: e != null ? e.amount.toString() : '');
    _noteCtrl = TextEditingController(text: e?.note ?? '');
    _selectedCategory = e?.category ?? ExpenseCategory.food;
    _selectedDate = e?.date ?? DateTime.now();

    // If editing, go straight to details to show current values
    if (e != null) {
      _pickingCategory = false;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: ColorScheme.light(
            primary: Theme.of(context).colorScheme.primary,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final expense = Expense(
      id: widget.expense?.id ?? const Uuid().v4(),
      title: _titleCtrl.text.trim().isEmpty ? _selectedCategory.displayName : _titleCtrl.text.trim(),
      amount: double.parse(_amountCtrl.text.trim()),
      category: _selectedCategory,
      date: _selectedDate,
      note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
    );

    if (widget.expense == null) {
      await widget.provider.addExpense(expense);
    } else {
      await widget.provider.updateExpense(expense);
    }

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    // This sheet acts like a full-screen or high modal mimicking the middle frame
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Stack(
        children: [
          // Top Gradient
          Positioned(
            top: 0, left: 0, right: 0, height: 250,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primaryContainer,
                      Theme.of(context).colorScheme.secondaryContainer,
                      Theme.of(context).scaffoldBackgroundColor,
                    ],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                // Header mimicking mockup
                Padding(
                  padding: const EdgeInsets.only(top: 20, left: 24, right: 24, bottom: 20),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (!_pickingCategory && widget.expense == null) {
                            setState(() => _pickingCategory = true);
                          } else {
                            Navigator.of(context).pop();
                          }
                        },
                        child: Container(
                          width: 44, height: 44,
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.chevron_left_rounded, color: Theme.of(context).colorScheme.onSurface),
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            _pickingCategory ? 'Select Category' : (widget.expense == null ? 'Add Expense' : 'Edit Expense'),
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 44), // balance for center alignment
                    ],
                  ),
                ),
                
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _pickingCategory ? _buildCategoryGrid() : _buildDetailsForm(),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryGrid() {
    final filteredCategories = ExpenseCategory.values.where((c) => 
      c.displayName.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();

    return Column(
      key: const ValueKey('CategoryGrid'),
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10, offset: const Offset(0, 4),
                )
              ]
            ),
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: 'Search for Categories',
                hintStyle: TextStyle(color: Theme.of(context).disabledColor),
                prefixIcon: Icon(Icons.search_rounded, color: Theme.of(context).disabledColor),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Grid View wrapped in Expanded container mimicking the card
        Expanded(
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 24,
                crossAxisSpacing: 12,
                childAspectRatio: 0.7, // Adjust to fit circle and text
              ),
              itemCount: filteredCategories.length + 1, // +1 for "Add" button
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _buildGridIcon(
                    icon: Icons.add_rounded,
                    color: Theme.of(context).disabledColor,
                    label: 'Add',
                    onTap: () {},
                  );
                }
                final cat = filteredCategories[index - 1];
                return _buildGridIcon(
                  icon: cat.icon,
                  color: cat.color,
                  label: cat.displayName,
                  onTap: () {
                    setState(() {
                      _selectedCategory = cat;
                      _pickingCategory = false; // Move to details step
                    });
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGridIcon({required IconData icon, required Color color, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))
              ]
            ),
            child: Center(
              child: Icon(icon, color: color, size: 24),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          )
        ],
      ),
    );
  }

  Widget _buildDetailsForm() {
    return Container(
      key: const ValueKey('DetailsForm'),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      padding: const EdgeInsets.all(32),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Display selected category
              Row(
                children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: _selectedCategory.color.withOpacity(0.15)),
                    child: Icon(_selectedCategory.icon, color: _selectedCategory.color),
                  ),
                  const SizedBox(width: 12),
                  Text(_selectedCategory.displayName, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                  const Spacer(),
                  TextButton(
                    onPressed: () => setState(() => _pickingCategory = true),
                    child: Text('Change', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w600)),
                  )
                ],
              ),
              const SizedBox(height: 24),

              _buildTextFieldLabel('Amount (₹)', Icons.attach_money_rounded),
              _buildTextField(
                controller: _amountCtrl,
                hint: '0.00',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Enter amount';
                  if (double.tryParse(v.trim()) == null) return 'Invalid number';
                  return null;
                },
              ),
              const SizedBox(height: 20),

              _buildTextFieldLabel('Title', Icons.title_rounded),
              _buildTextField(
                controller: _titleCtrl,
                hint: 'Optional title...',
              ),
              const SizedBox(height: 20),

              _buildTextFieldLabel('Date', Icons.calendar_today_rounded),
              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    DateFormat('d MMMM yyyy').format(_selectedDate),
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              _buildTextFieldLabel('Note', Icons.notes_rounded),
              _buildTextField(
                controller: _noteCtrl,
                hint: 'Any extra details...',
                maxLines: 2,
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.onSurface, // Dark purple button
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: _isSaving
                    ? CircularProgressIndicator(color: Theme.of(context).cardColor)
                    : Text('Save Expense', style: TextStyle(color: Theme.of(context).cardColor, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextFieldLabel(String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Text(text, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      maxLines: maxLines,
      style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Theme.of(context).disabledColor),
        filled: true,
        fillColor: Theme.of(context).scaffoldBackgroundColor,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}
