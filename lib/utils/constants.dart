class AppConstants {
  // Expense Categories
  static const List<String> expenseCategories = [
    'Internet',
    'Cable',
    'Electricity',
    'Gas',
    'Shopping',
    'Groceries',
    'Fuel / gas',
    'EMI',
    'Doctor visits',
  ];

  // App Colors
  static const int primaryColor = 0xFF008080; // Teal
  static const int secondaryColor = 0xFF2196F3; // Blue
  static const int backgroundColor = 0xFFFFFFFF; // White

  // App Text
  static const String appTitle = 'Family Finance Manager';
  static const String homeTitle = 'Family Finance';
  static const String membersExpensesTitle = 'Member Expenses';

  // Error Messages
  static const String noFamilySelected = 'No family selected';
  static const String errorLoadingUserNames = 'Error loading user names';
  static const String errorLoadingExpenses = 'Error loading expenses';
  static const String noExpensesYet = 'No expenses yet';
  static const String unknownUser = 'Unknown User';

  // Date Formats
  static const String dateFormat = 'MMM dd';
  static const String fullDateFormat = 'MMM dd, yyyy';

  // Firebase Collections
  static const String usersCollection = 'users';
  static const String expensesCollection = 'expenses';
  static const String familiesCollection = 'families';

  // User Fields
  static const String nameField = 'name';
  static const String emailField = 'email';
  static const String familyIdField = 'familyId';
  static const String createdAtField = 'createdAt';

  // Expense Fields
  static const String uidField = 'uid';
  static const String categoryField = 'category';
  static const String amountField = 'amount';
  static const String timestampField = 'timestamp';
} 