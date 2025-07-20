import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';
import 'screens/members_expenses_screen.dart';
import 'screens/profile_page.dart';
import 'screens/family_screen.dart';
import 'screens/login_screen.dart';
import 'utils/constants.dart';
import 'utils/route_animations.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/expense_viewmodel.dart';
import 'viewmodels/family_viewmodel.dart';
import 'models/expense.dart';

// Providers
final expenseListProvider = StreamProvider.autoDispose<List<Expense>>((ref) {
  final familyId = ref.watch(familyIdProvider);
  if (familyId == null) return Stream.value([]);
  
  final expenseViewModel = ref.read(expenseViewModelProvider.notifier);
  return expenseViewModel.getExpensesByFamily(familyId);
});

class HomePage extends ConsumerStatefulWidget {
  @override ConsumerState<HomePage> createState()=>_HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final catC = TextEditingController(), amtC = TextEditingController();
  final List<String> categories = AppConstants.expenseCategories;
  String? selectedCategory;

  @override Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);
    final familyState = ref.watch(familyViewModelProvider);
    final familyId = ref.watch(familyIdProvider);
    final expensesAsync = ref.watch(expenseListProvider);
    final userNamesAsync = ref.watch(familyMembersProvider);
    final authViewModel = ref.read(authViewModelProvider.notifier);
    final expenseViewModel = ref.read(expenseViewModelProvider.notifier);
    final familyViewModel = ref.read(familyViewModelProvider.notifier);

    return authState.when(
      data: (user) {
        if (user == null) return LoginScreen();
        
        // Load family ID if not loaded yet
        if (familyState.isLoading) {
          familyViewModel.loadUserFamilyId(user.uid);
        }
        
        // Update family ID provider when family state changes
        familyState.whenData((familyIdFromState) {
          if (familyIdFromState != familyId) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ref.read(familyIdProvider.notifier).state = familyIdFromState;
            });
          }
        });
        
        if (familyId == null) return FamilyScreen();
        
        return Scaffold(
          appBar: AppBar(
            title: Text(AppConstants.homeTitle),
            actions: [
              StreamBuilder(
                stream: authViewModel.getUserDataStream(user.uid),
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data != null) {
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Center(
                        child: Text(
                          snapshot.data!.name,
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                      ),
                    );
                  }
                  return SizedBox.shrink();
                },
              ),
            ],
          ),
          body: Column(children:[
            Padding(
              padding: EdgeInsets.all(12),
              child: Card(
                elevation: 6,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      DropdownButtonFormField<String>(
                        value: selectedCategory,
                        decoration: InputDecoration(
                          labelText: 'Category',
                          prefixIcon: Icon(Icons.category),
                          contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                        ),
                        items: categories.map((cat) => DropdownMenuItem(
                          value: cat,
                          child: Text(cat),
                        )).toList(),
                        onChanged: (val) => setState(() => selectedCategory = val),
                      ),
                      SizedBox(height: 12),
                      TextField(
                        controller: amtC,
                        decoration: InputDecoration(
                          labelText: 'Amount',
                          prefixIcon: Icon(Icons.attach_money),
                          contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      SizedBox(height: 12),
                      SizedBox(
                        height: 48,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            foregroundColor: Colors.white,
                            elevation: 3,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          ),
                          icon: Icon(Icons.add, size: 20),
                          label: Text('Add', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                          onPressed: () async {
                            if (selectedCategory != null && amtC.text.isNotEmpty) {
                              try {
                                await expenseViewModel.addExpense(
                                  user.uid, 
                                  familyId!, 
                                  selectedCategory!, 
                                  double.tryParse(amtC.text) ?? 0
                                );
                                setState(() => selectedCategory = null);
                                amtC.clear();
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(e.toString())),
                                );
                              }
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: expensesAsync.when(
                data: (list) {
                  return userNamesAsync.when(
                    data: (userNames) => ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      itemCount: list.length,
                      itemBuilder: (context, index) {
                        final expense = list[index];
                        final userName = userNames[expense.uid]?.name ?? AppConstants.unknownUser;
                        final categoryIcon = _getCategoryIcon(expense.category);
                        final categoryColor = _getCategoryColor(expense.category);
                        
                        return Container(
                          margin: EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                categoryColor.withOpacity(0.1),
                                categoryColor.withOpacity(0.05),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: categoryColor.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: ListTile(
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            leading: Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: categoryColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                categoryIcon,
                                color: categoryColor,
                                size: 24,
                              ),
                            ),
                            title: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    expense.category,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.teal.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '₹${expense.amount.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.teal,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.person,
                                      size: 14,
                                      color: Colors.grey[600],
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      userName,
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 2),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.access_time,
                                      size: 14,
                                      color: Colors.grey[600],
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      DateFormat(AppConstants.dateFormat).format(expense.timestamp),
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    loading: () => _buildShimmerList(),
                    error: (_, __) => Center(child: Text(AppConstants.errorLoadingUserNames)),
                  );
                },
                loading: () => _buildShimmerList(),
                error: (e, st) => Center(child: Text(e.toString())),
              ),
            ),
          ]),
        );
      },
      loading: () => Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (_, __) => Scaffold(body: Center(child: Text('Error'))),
    );
  }



  Widget _buildShimmerList() {
    return ListView.builder(
      itemCount: 4,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
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
