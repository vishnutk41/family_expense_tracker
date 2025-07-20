import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../viewmodels/expense_viewmodel.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/family_viewmodel.dart';
import '../models/expense.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';

// Import the provider from expense viewmodel
final expenseListProvider = StreamProvider.autoDispose<List<Expense>>((ref) {
  final familyId = ref.watch(familyIdProvider);
  if (familyId == null) return Stream.value([]);
  
  final expenseViewModel = ref.read(expenseViewModelProvider.notifier);
  return expenseViewModel.getExpensesByFamily(familyId);
});

class MembersExpensesScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authViewModelProvider);
    final expensesAsync = ref.watch(expenseListProvider);
    final userNamesAsync = ref.watch(familyMembersProvider);

    return authState.when(
      data: (user) {
        if (user == null) return Scaffold(body: Center(child: Text('Not authenticated')));
        
        return Scaffold(
          appBar: AppBar(
            title: Text('Member Expenses'),
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
          ),
          body: Column(
            children: [
              Expanded(
                child: expensesAsync.when(
                  data: (expenses) => userNamesAsync.when(
                    data: (userNames) {
                      final expensesByUser = <String, List<Expense>>{};
                      final userTotals = <String, double>{};
                      
                      for (final expense in expenses) {
                        final userName = userNames[expense.uid]?.name ?? AppConstants.unknownUser;
                        expensesByUser.putIfAbsent(userName, () => []).add(expense);
                        userTotals[userName] = (userTotals[userName] ?? 0) + expense.amount;
                      }

                      return ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        itemCount: userNames.length,
                        itemBuilder: (context, index) {
                          final userName = userNames.values.elementAt(index).name;
                          final userExpenses = expensesByUser[userName] ?? [];
                          final total = userTotals[userName] ?? 0;

                          return Container(
                            margin: EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.teal.withOpacity(0.1),
                                  Colors.teal.withOpacity(0.05),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.teal.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: ExpansionTile(
                              backgroundColor: Colors.transparent,
                              collapsedBackgroundColor: Colors.transparent,
                              title: Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [Colors.teal, Colors.teal.shade700],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.teal.withOpacity(0.3),
                                          blurRadius: 8,
                                          offset: Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Text(
                                      userName[0].toUpperCase(),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          userName,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: Colors.grey[800],
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Container(
                                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: Colors.teal.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                '${userExpenses.length} expenses',
                                                style: TextStyle(
                                                  color: Colors.teal,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 8),
                                            Container(
                                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: Colors.green.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                '₹${total.toStringAsFixed(2)}',
                                                style: TextStyle(
                                                  color: Colors.green,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              children: [
                                if (userExpenses.isEmpty)
                                  Padding(
                                    padding: EdgeInsets.all(20),
                                    child: Center(
                                      child: Column(
                                        children: [
                                          Icon(
                                            Icons.receipt_long,
                                            size: 48,
                                            color: Colors.grey[400],
                                          ),
                                          SizedBox(height: 8),
                                          Text(
                                            AppConstants.noExpensesYet,
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                else
                                  ListView.builder(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemCount: userExpenses.length,
                                    itemBuilder: (context, expenseIndex) {
                                      final expense = userExpenses[expenseIndex];
                                      final categoryIcon = _getCategoryIcon(expense.category);
                                      final categoryColor = _getCategoryColor(expense.category);
                                      
                                      return Container(
                                        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.7),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                            color: categoryColor.withOpacity(0.2),
                                            width: 1,
                                          ),
                                        ),
                                        child: ListTile(
                                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                          leading: Container(
                                            padding: EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: categoryColor.withOpacity(0.2),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Icon(
                                              categoryIcon,
                                              color: categoryColor,
                                              size: 20,
                                            ),
                                          ),
                                          title: Text(
                                            expense.category,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                              color: Colors.grey[800],
                                            ),
                                          ),
                                          subtitle: Text(
                                            DateFormat(AppConstants.fullDateFormat).format(expense.timestamp),
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 12,
                                            ),
                                          ),
                                          trailing: Container(
                                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: categoryColor.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              '₹${expense.amount.toStringAsFixed(2)}',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: categoryColor,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                    loading: () => Center(child: CircularProgressIndicator()),
                    error: (_, __) => Center(child: Text(AppConstants.errorLoadingUserNames)),
                  ),
                  loading: () => Center(child: CircularProgressIndicator()),
                  error: (_, __) => Center(child: Text(AppConstants.errorLoadingExpenses)),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (_, __) => Scaffold(body: Center(child: Text('Error'))),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Icons.restaurant;
      case 'transport':
        return Icons.directions_car;
      case 'shopping':
        return Icons.shopping_bag;
      case 'entertainment':
        return Icons.movie;
      case 'health':
        return Icons.local_hospital;
      case 'education':
        return Icons.school;
      case 'bills':
        return Icons.receipt;
      case 'other':
        return Icons.more_horiz;
      default:
        return Icons.category;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Colors.orange;
      case 'transport':
        return Colors.blue;
      case 'shopping':
        return Colors.purple;
      case 'entertainment':
        return Colors.pink;
      case 'health':
        return Colors.red;
      case 'education':
        return Colors.indigo;
      case 'bills':
        return Colors.green;
      case 'other':
        return Colors.grey;
      default:
        return Colors.teal;
    }
  }
} 