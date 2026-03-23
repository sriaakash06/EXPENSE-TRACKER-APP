import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'providers/expense_provider.dart';
import 'screens/dashboard_screen.dart';
import 'screens/expenses_screen.dart';
import 'screens/add_edit_expense_sheet.dart';
import 'screens/analytics_screen.dart';
import 'screens/account_screen.dart';
import 'screens/setup_wallet_screen.dart';
final ExpenseProvider globalProvider = ExpenseProvider();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
  ));
  runApp(ExpenseTrackerApp(provider: globalProvider));
}

class ExpenseTrackerApp extends StatelessWidget {
  final ExpenseProvider provider;
  const ExpenseTrackerApp({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: provider,
      builder: (context, _) {
        return MaterialApp(
          title: 'Expense Tracker',
          debugShowCheckedModeBanner: false,
          themeMode: provider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          theme: ThemeData(
            brightness: Brightness.light,
            scaffoldBackgroundColor: const Color(0xFFF6F6F9),
            cardColor: Colors.white,
            colorScheme: const ColorScheme.light(
              onSurface: Color(0xFF1B1B2F),
              onSurfaceVariant: Color(0xFF7A7A90),
              primaryContainer: Color(0xFFE4C9FF),
              secondaryContainer: Color(0xFFF0E0FF),
              primary: Color(0xFF7C3AED),
              secondary: Color(0xFF8EE0A5),
            ),
            disabledColor: const Color(0xFFC4C4CD),
            dividerColor: const Color(0xFFF3F3F6),
            textTheme: GoogleFonts.interTextTheme(),
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF121212),
            cardColor: const Color(0xFF1E1E2E),
            colorScheme: const ColorScheme.dark(
              onSurface: Colors.white,
              onSurfaceVariant: Color(0xFFB5B5C3),
              primaryContainer: Color(0xFF2C1A4A),
              secondaryContainer: Color(0xFF1A382A),
              primary: Color(0xFF9F7AEA),
              secondary: Color(0xFF34D399),
            ),
            disabledColor: const Color(0xFF555566),
            dividerColor: const Color(0xFF2A2A3A),
            textTheme: GoogleFonts.interTextTheme(
              ThemeData.dark().textTheme,
            ),
            useMaterial3: true,
          ),
          home: HomeShell(provider: provider),
        );
      },
    );
  }
}

class HomeShell extends StatefulWidget {
  final ExpenseProvider provider;
  const HomeShell({super.key, required this.provider});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late final ExpenseProvider _provider = widget.provider;
  late AnimationController _fabController;
  late Animation<double> _fabAnimation;

  @override
  void initState() {
    super.initState();
    _provider.loadExpenses();
    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _fabAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _fabController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }

  void _openAddSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddEditExpenseSheet(provider: _provider),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _provider,
      builder: (context, _) {
        if (_provider.isLoading) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (!_provider.hasSetWallet) {
          return SetupWalletScreen(provider: _provider);
        }

        return Scaffold(
          extendBody: true,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: IndexedStack(
            index: _currentIndex,
            children: [
              DashboardScreen(provider: _provider),
              ExpensesScreen(provider: _provider), 
              AnalyticsScreen(provider: _provider),
              AccountScreen(provider: _provider),
            ],
          ),
          bottomNavigationBar: _buildNavBar(),
          floatingActionButton: _buildFAB(),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
        );
      },
    );
  }

  Widget _buildNavBar() {
    return Container(
      margin: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: BottomAppBar(
        color: Colors.transparent,
        elevation: 0,
        shape: const CircularNotchedRectangle(),
        notchMargin: 12,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _NavItem(
              icon: Icons.home_filled,
              label: 'Home',
              isSelected: _currentIndex == 0,
              onTap: () => setState(() => _currentIndex = 0),
            ),
            _NavItem(
              icon: Icons.receipt_long_rounded,
              label: 'Transaction',
              isSelected: _currentIndex == 1,
              onTap: () => setState(() => _currentIndex = 1),
            ),
            const SizedBox(width: 40), // FAB space
            _NavItem(
              icon: Icons.bar_chart_rounded,
              label: 'Analytics',
              isSelected: _currentIndex == 2,
              onTap: () => setState(() => _currentIndex = 2),
            ),
            _NavItem(
              icon: Icons.person_outline_rounded,
              label: 'Account',
              isSelected: _currentIndex == 3,
              onTap: () => setState(() => _currentIndex = 3),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAB() {
    return ScaleTransition(
      scale: _fabAnimation,
      child: FloatingActionButton(
        onPressed: () {
          _fabController.forward().then((_) => _fabController.reverse());
          _openAddSheet();
        },
        backgroundColor: const Color(0xFF1B1B2F), // Dark icon from mockup
        elevation: 8,
        shape: const CircleBorder(),
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF1B1B2F),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1B1B2F).withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF7C3AED) : const Color(0xFFB5B5C3),
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? const Color(0xFF7C3AED) : const Color(0xFFB5B5C3),
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
