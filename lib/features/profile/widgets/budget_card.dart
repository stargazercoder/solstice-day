import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/color_constants.dart';

class BudgetData {
  final double salary;
  final double savingsGoal;
  final List<ExpenseItem> expenses;

  BudgetData({this.salary = 0, this.savingsGoal = 0, this.expenses = const []});

  double get totalExpenses => expenses.fold(0, (sum, e) => sum + e.amount);
  double get remaining => salary - totalExpenses;
  double get savingsProgress => savingsGoal > 0 ? (remaining / savingsGoal).clamp(0.0, 1.0) : 0;
}

class ExpenseItem {
  final String id;
  final String title;
  final double amount;
  final String category;

  ExpenseItem({required this.id, required this.title, required this.amount, this.category = 'other'});
}

final budgetProvider = StateNotifierProvider<BudgetNotifier, BudgetData>((ref) {
  return BudgetNotifier();
});

class BudgetNotifier extends StateNotifier<BudgetData> {
  BudgetNotifier() : super(BudgetData()) {
    _load();
  }

  String get _monthKey {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}';
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final salary = prefs.getDouble('budget_salary') ?? 0;
    final savingsGoal = prefs.getDouble('budget_savings_goal') ?? 0;
    final expenseData = prefs.getStringList('budget_expenses_$_monthKey') ?? [];
    final expenses = expenseData.map((e) {
      final parts = e.split('||');
      return ExpenseItem(
        id: parts[0],
        title: parts.length > 1 ? parts[1] : '',
        amount: parts.length > 2 ? double.tryParse(parts[2]) ?? 0 : 0,
        category: parts.length > 3 ? parts[3] : 'other',
      );
    }).toList();
    state = BudgetData(salary: salary, savingsGoal: savingsGoal, expenses: expenses);
  }

  Future<void> setSalary(double salary) async {
    state = BudgetData(salary: salary, savingsGoal: state.savingsGoal, expenses: state.expenses);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('budget_salary', salary);
  }

  Future<void> setSavingsGoal(double goal) async {
    state = BudgetData(salary: state.salary, savingsGoal: goal, expenses: state.expenses);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('budget_savings_goal', goal);
  }

  Future<void> addExpense(String title, double amount, String category) async {
    final expense = ExpenseItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      amount: amount,
      category: category,
    );
    final expenses = [...state.expenses, expense];
    state = BudgetData(salary: state.salary, savingsGoal: state.savingsGoal, expenses: expenses);
    await _saveExpenses();
  }

  Future<void> removeExpense(String id) async {
    final expenses = state.expenses.where((e) => e.id != id).toList();
    state = BudgetData(salary: state.salary, savingsGoal: state.savingsGoal, expenses: expenses);
    await _saveExpenses();
  }

  Future<void> _saveExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    final data = state.expenses.map((e) => '${e.id}||${e.title}||${e.amount}||${e.category}').toList();
    await prefs.setStringList('budget_expenses_$_monthKey', data);
  }
}

class BudgetCard extends ConsumerWidget {
  const BudgetCard({super.key});

  static const _expenseCategories = {
    'food': '🍽️ Yemek',
    'transport': '🚌 Ulaşım',
    'bills': '💡 Faturalar',
    'shopping': '🛍️ Alışveriş',
    'health': '🏥 Sağlık',
    'entertainment': '🎬 Eğlence',
    'education': '📚 Eğitim',
    'other': '📌 Diğer',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budget = ref.watch(budgetProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Text('💰', style: TextStyle(fontSize: 20)),
                  SizedBox(width: 8),
                  Text('Bütçe', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                ],
              ),
              IconButton(
                onPressed: () => _showBudgetSettings(context, ref, budget),
                icon: const Icon(Icons.settings_outlined, size: 20),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),

          if (budget.salary <= 0)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: GestureDetector(
                onTap: () => _showBudgetSettings(context, ref, budget),
                child: Text(
                  'Maaş bilgisini ayarlamak için dokunun',
                  style: TextStyle(fontSize: 12, color: AppColors.info),
                ),
              ),
            )
          else ...[
            const SizedBox(height: 8),
            // Gelir/Gider özeti
            Row(
              children: [
                _buildMiniStat('Gelir', '₺${_formatNumber(budget.salary)}', AppColors.success),
                const SizedBox(width: 12),
                _buildMiniStat('Gider', '₺${_formatNumber(budget.totalExpenses)}', AppColors.error),
                const SizedBox(width: 12),
                _buildMiniStat('Kalan', '₺${_formatNumber(budget.remaining)}',
                    budget.remaining >= 0 ? AppColors.info : AppColors.error),
              ],
            ),
            const SizedBox(height: 12),
            // Birikim hedefi
            if (budget.savingsGoal > 0) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Birikim Hedefi', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  Text('₺${_formatNumber(budget.remaining.clamp(0, budget.savingsGoal))} / ₺${_formatNumber(budget.savingsGoal)}',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: budget.savingsProgress,
                backgroundColor: AppColors.success.withOpacity(0.1),
                valueColor: const AlwaysStoppedAnimation(AppColors.success),
                borderRadius: BorderRadius.circular(4),
                minHeight: 6,
              ),
              const SizedBox(height: 8),
            ],
            // Gider ekle butonu
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Bu ay ${budget.expenses.length} gider',
                    style: TextStyle(fontSize: 11, color: AppColors.textHint)),
                TextButton.icon(
                  onPressed: () => _showAddExpenseDialog(context, ref),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Gider Ekle', style: TextStyle(fontSize: 11)),
                  style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
            Text(label, style: TextStyle(fontSize: 9, color: color.withOpacity(0.7))),
          ],
        ),
      ),
    );
  }

  String _formatNumber(double n) {
    if (n >= 1000) {
      return '${(n / 1000).toStringAsFixed(1)}K';
    }
    return n.toStringAsFixed(0);
  }

  void _showBudgetSettings(BuildContext context, WidgetRef ref, BudgetData budget) {
    final salaryCtrl = TextEditingController(text: budget.salary > 0 ? budget.salary.toStringAsFixed(0) : '');
    final savingsCtrl = TextEditingController(text: budget.savingsGoal > 0 ? budget.savingsGoal.toStringAsFixed(0) : '');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('💰 Bütçe Ayarları'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: salaryCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Aylık Gelir (₺)', prefixIcon: Icon(Icons.payments)),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: savingsCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Birikim Hedefi (₺)', prefixIcon: Icon(Icons.savings)),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('İptal')),
          ElevatedButton(
            onPressed: () {
              final salary = double.tryParse(salaryCtrl.text) ?? 0;
              final savings = double.tryParse(savingsCtrl.text) ?? 0;
              ref.read(budgetProvider.notifier).setSalary(salary);
              ref.read(budgetProvider.notifier).setSavingsGoal(savings);
              Navigator.pop(context);
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
  }

  void _showAddExpenseDialog(BuildContext context, WidgetRef ref) {
    final titleCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    String category = 'other';

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Gider Ekle'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Açıklama', hintText: 'Market, fatura...')),
                const SizedBox(height: 8),
                TextField(controller: amountCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Tutar (₺)')),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: _expenseCategories.entries.map((e) => ChoiceChip(
                    label: Text(e.value, style: const TextStyle(fontSize: 10)),
                    selected: category == e.key,
                    onSelected: (_) => setState(() => category = e.key),
                    visualDensity: VisualDensity.compact,
                  )).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('İptal')),
            ElevatedButton(
              onPressed: () {
                final amount = double.tryParse(amountCtrl.text);
                if (titleCtrl.text.trim().isEmpty || amount == null) return;
                ref.read(budgetProvider.notifier).addExpense(titleCtrl.text.trim(), amount, category);
                Navigator.pop(context);
              },
              child: const Text('Ekle'),
            ),
          ],
        ),
      ),
    );
  }
}
