import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_language.dart';

class AppTranslations {
  static const Map<String, Map<AppLanguage, String>> _translations = {
    // Common / General
    'app_name': {
      AppLanguage.english: 'Apna Batwa',
      AppLanguage.romanUrdu: 'Apna Batwa',
    },
    'app_tagline': {
      AppLanguage.english: 'Student Personal Finance',
      AppLanguage.romanUrdu: 'Student Personal Finance',
    },
    'common_cancel': {
      AppLanguage.english: 'Cancel',
      AppLanguage.romanUrdu: 'Cancel',
    },
    'common_delete': {
      AppLanguage.english: 'Delete',
      AppLanguage.romanUrdu: 'Delete',
    },
    'common_save': {
      AppLanguage.english: 'Save Entry',
      AppLanguage.romanUrdu: 'Save Entry',
    },
    'common_update': {
      AppLanguage.english: 'Update Entry',
      AppLanguage.romanUrdu: 'Update Entry',
    },
    'common_error': {
      AppLanguage.english: 'Error',
      AppLanguage.romanUrdu: 'Ghalti',
    },

    // Navigation Tabs (MainShell)
    'tab_home': {
      AppLanguage.english: 'Home',
      AppLanguage.romanUrdu: 'Home',
    },
    'tab_transactions': {
      AppLanguage.english: 'Transactions',
      AppLanguage.romanUrdu: 'Transactions',
    },
    'tab_khata': {
      AppLanguage.english: 'Khata',
      AppLanguage.romanUrdu: 'Khata',
    },
    'tab_reports': {
      AppLanguage.english: 'Reports',
      AppLanguage.romanUrdu: 'Reports',
    },
    'tab_more': {
      AppLanguage.english: 'More',
      AppLanguage.romanUrdu: 'More',
    },

    // Home Dashboard
    'dashboard_exit_title': {
      AppLanguage.english: 'Exit Apna Batwa?',
      AppLanguage.romanUrdu: 'Kya aap Apna Batwa se nikalna chahte hain?',
    },
    'dashboard_exit_message': {
      AppLanguage.english: 'Are you sure you want to close the application?',
      AppLanguage.romanUrdu: 'Kya aap waqai app band karna chahte hain?',
    },
    'dashboard_exit_button': {
      AppLanguage.english: 'Exit',
      AppLanguage.romanUrdu: 'Niklein',
    },
    'dashboard_tooltip_theme': {
      AppLanguage.english: 'Toggle Light/Dark Theme',
      AppLanguage.romanUrdu: 'Theme badlein',
    },
    'dashboard_total_balance': {
      AppLanguage.english: 'Total Balance',
      AppLanguage.romanUrdu: 'Total Balance',
    },
    'dashboard_money_in': {
      AppLanguage.english: 'Money In',
      AppLanguage.romanUrdu: 'Money In',
    },
    'dashboard_expense': {
      AppLanguage.english: 'Expense',
      AppLanguage.romanUrdu: 'Expense',
    },
    'dashboard_total_expenses': {
      AppLanguage.english: 'Total Expenses',
      AppLanguage.romanUrdu: 'Kul Kharcha',
    },
    'dashboard_you_owe': {
      AppLanguage.english: 'You Owe',
      AppLanguage.romanUrdu: 'Aap ne dene hain',
    },
    'dashboard_others_owe_you': {
      AppLanguage.english: 'Others Owe You',
      AppLanguage.romanUrdu: 'Aap ne lene hain',
    },
    'dashboard_active_savings': {
      AppLanguage.english: 'Active Savings Set Aside',
      AppLanguage.romanUrdu: 'Mehfooz ki gayi raqam',
    },
    'dashboard_recent_transactions': {
      AppLanguage.english: 'Recent Transactions',
      AppLanguage.romanUrdu: 'Haalia Transactions',
    },
    'dashboard_latest_10': {
      AppLanguage.english: 'Latest 10',
      AppLanguage.romanUrdu: 'Aakhri 10',
    },
    'dashboard_no_transactions': {
      AppLanguage.english: 'No transactions recorded yet',
      AppLanguage.romanUrdu: 'Abhi tak koi transaction record nahi hui',
    },
    'dashboard_no_transactions_sub': {
      AppLanguage.english: 'Tap "+ Money In" or "− Expense" to start tracking.',
      AppLanguage.romanUrdu: 'Record karne ke liye "+ Money In" ya "− Expense" dabayein.',
    },

    // Greetings (Home Dashboard)
    'greeting_morning': {
      AppLanguage.english: 'Good Morning!',
      AppLanguage.romanUrdu: 'Subah Bakhair!',
    },
    'greeting_afternoon': {
      AppLanguage.english: 'Good Afternoon!',
      AppLanguage.romanUrdu: 'Dopahar Bakhair!',
    },
    'greeting_evening': {
      AppLanguage.english: 'Good Evening!',
      AppLanguage.romanUrdu: 'Shaam Bakhair!',
    },
    'greeting_night': {
      AppLanguage.english: 'Good Night!',
      AppLanguage.romanUrdu: 'Shab Bakhair!',
    },

    // MoM Expense Trend Indicator
    'dashboard_trend_higher': {
      AppLanguage.english: 'higher than last month',
      AppLanguage.romanUrdu: 'pichle mahine se ziyada',
    },
    'dashboard_trend_lower': {
      AppLanguage.english: 'lower than last month',
      AppLanguage.romanUrdu: 'pichle mahine se kam',
    },
    'dashboard_trend_same': {
      AppLanguage.english: 'Same as last month',
      AppLanguage.romanUrdu: 'Pichle mahine ke barabar',
    },

    // Budget Mini-Progress
    'dashboard_top_budget': {
      AppLanguage.english: 'Highest Budget Usage',
      AppLanguage.romanUrdu: 'Sab Se Ziyada Budget Use',
    },
    'dashboard_budget_used': {
      AppLanguage.english: 'used',
      AppLanguage.romanUrdu: 'istemaal hua',
    },

    // Recurring Reminders
    'recurring_banner_title': {
      AppLanguage.english: 'Upcoming Recurring Payment',
      AppLanguage.romanUrdu: 'Aane Wali Recurring Adayegi',
    },
    'recurring_due_today': {
      AppLanguage.english: 'due today',
      AppLanguage.romanUrdu: 'aaj due hai',
    },
    'recurring_due_tomorrow': {
      AppLanguage.english: 'due tomorrow',
      AppLanguage.romanUrdu: 'kal due hai',
    },

    // Financial Tips
    'dashboard_tip_title': {
      AppLanguage.english: 'Financial Tip',
      AppLanguage.romanUrdu: 'Maliyati Mashwara',
    },
    'tip_1': {
      AppLanguage.english: 'Small savings today make a big difference tomorrow.',
      AppLanguage.romanUrdu: 'Chhoti bachat, bada farq — roz thoda bachayein.',
    },
    'tip_2': {
      AppLanguage.english: 'Before spending, ask: is it a need or a want?',
      AppLanguage.romanUrdu: 'Kharcha karne se pehle sochein: zaroorat hai ya khwahish?',
    },
    'tip_3': {
      AppLanguage.english: 'Set a monthly budget — and actually follow it.',
      AppLanguage.romanUrdu: 'Har mahine ka budget banayein, aur usay follow karein.',
    },
    'tip_4': {
      AppLanguage.english: "Building an emergency fund matters, even if it's small.",
      AppLanguage.romanUrdu: 'Emergency fund banana zaroori hai, chahe chhota hi ho.',
    },
    'tip_5': {
      AppLanguage.english: 'Before borrowing, think — can you repay it on time?',
      AppLanguage.romanUrdu: 'Udhaar lene se pehle sochein — kya wapis kar sakenge?',
    },
    'tip_6': {
      AppLanguage.english: 'Track every expense — what gets measured gets managed.',
      AppLanguage.romanUrdu: 'Apne kharche likhna aadat banayein — jo likha jata hai, wahi control hota hai.',
    },
    'tip_7': {
      AppLanguage.english: 'Save at least 10% of your pocket money.',
      AppLanguage.romanUrdu: 'Pocket money ka 10% bachat mein daalein.',
    },
    'tip_8': {
      AppLanguage.english: 'Big dreams start with small savings today.',
      AppLanguage.romanUrdu: 'Bade khwabon ke liye chhoti bachat aaj se shuru karein.',
    },
    'tip_9': {
      AppLanguage.english: 'Avoid unnecessary spending; prioritize what truly matters.',
      AppLanguage.romanUrdu: 'Fizool kharchi se bachein, zaroori cheezon ko priority dein.',
    },
    'tip_10': {
      AppLanguage.english: 'Paying with cash often gives you more control than cards.',
      AppLanguage.romanUrdu: 'Cash mein kharch karna aksar zyada control deta hai card se.',
    },
    'tip_11': {
      AppLanguage.english: 'Wait 24 hours before any big purchase — is it really needed?',
      AppLanguage.romanUrdu: 'Har khareed se pehle 24 ghante sochein — zaroori hai ya nahi?',
    },
    'tip_12': {
      AppLanguage.english: 'Splitting costs with friends is a smart habit.',
      AppLanguage.romanUrdu: 'Doston ke sath kharcha share karna acha aadat hai.',
    },
    'tip_13': {
      AppLanguage.english: 'Live within your means, not beyond them.',
      AppLanguage.romanUrdu: 'Apni income ke mutabiq lifestyle rakhein, uss se zyada nahi.',
    },
    'tip_14': {
      AppLanguage.english: 'Set savings goals — saving without a target is hard.',
      AppLanguage.romanUrdu: 'Savings goal set karein — bina target ke bachat mushkil hoti hai.',
    },
    'tip_15': {
      AppLanguage.english: 'Every rupee counts — small savings add up to big results.',
      AppLanguage.romanUrdu: 'Har Rupya ginta hai — chhoti bachat bhi ikattha ho kar badi ban jaati hai.',
    },
    'tip_16': {
      AppLanguage.english: "Plan before you spend, so you don't regret it later.",
      AppLanguage.romanUrdu: 'Kharch se pehle plan banayein, baad mein pachtana na pade.',
    },
    'tip_17': {
      AppLanguage.english: "Don't fall for discounts on things you don't actually need.",
      AppLanguage.romanUrdu: 'Discount ke chakkar mein fizool cheezein na khareedein.',
    },
    'tip_18': {
      AppLanguage.english: 'Clear your Khata (borrowed money) on time — it protects relationships too.',
      AppLanguage.romanUrdu: 'Apna Khata (udhaar) waqt par clear karein — rishtay bhi mehfooz rahenge.',
    },
    'tip_19': {
      AppLanguage.english: 'Divide your budget at the start of the month.',
      AppLanguage.romanUrdu: 'Mahine ke shuru mein hi budget divide kar lein.',
    },
    'tip_20': {
      AppLanguage.english: 'Financial freedom begins with small daily habits.',
      AppLanguage.romanUrdu: 'Financial azadi choti aadaton se shuru hoti hai.',
    },

    // Transactions Screen & Filters
    'transactions_title': {
      AppLanguage.english: 'Transactions',
      AppLanguage.romanUrdu: 'Transactions',
    },
    'transactions_export_tooltip': {
      AppLanguage.english: 'Export Transactions',
      AppLanguage.romanUrdu: 'Transactions Export Karein',
    },
    'transactions_export_pdf': {
      AppLanguage.english: 'Export as PDF',
      AppLanguage.romanUrdu: 'PDF Export Karein',
    },
    'transactions_export_csv': {
      AppLanguage.english: 'Export as CSV',
      AppLanguage.romanUrdu: 'CSV Export Karein',
    },
    'transactions_tab_all': {
      AppLanguage.english: 'All History',
      AppLanguage.romanUrdu: 'Tamam History',
    },
    'transactions_tab_income': {
      AppLanguage.english: 'Income',
      AppLanguage.romanUrdu: 'Aamdani',
    },
    'transactions_tab_expenses': {
      AppLanguage.english: 'Expenses',
      AppLanguage.romanUrdu: 'Kharchay',
    },
    'transactions_search_hint': {
      AppLanguage.english: 'Search transactions by name, note, or category...',
      AppLanguage.romanUrdu: 'Naam, note ya category se search karein...',
    },
    'transactions_clear_all': {
      AppLanguage.english: 'Clear All',
      AppLanguage.romanUrdu: 'Tamam Saaf Karein',
    },
    'transactions_add_entry': {
      AppLanguage.english: 'Add Entry',
      AppLanguage.romanUrdu: 'Add Entry',
    },
    'transactions_choose_type': {
      AppLanguage.english: 'Choose Transaction Type',
      AppLanguage.romanUrdu: 'Transaction Type Chunein',
    },
    'transactions_add_income_title': {
      AppLanguage.english: 'Add Income / Money In',
      AppLanguage.romanUrdu: 'Add Income / Money In',
    },
    'transactions_add_income_sub': {
      AppLanguage.english: 'Pocket money, salary, gifts, scholarship',
      AppLanguage.romanUrdu: 'Pocket money, salary, gifts, scholarship',
    },
    'transactions_add_expense_title': {
      AppLanguage.english: 'Add Expense',
      AppLanguage.romanUrdu: 'Add Expense',
    },
    'transactions_add_expense_sub': {
      AppLanguage.english: 'Food, transport, hostel, shopping, etc.',
      AppLanguage.romanUrdu: 'Khana, transport, hostel, shopping, wagaira',
    },
    'transactions_empty_all_title': {
      AppLanguage.english: 'No Transactions Yet 📝',
      AppLanguage.romanUrdu: 'Abhi koi transaction nahi 📝',
    },
    'transactions_empty_all_sub': {
      AppLanguage.english: 'Apna pehla income ya kharcha log karein!',
      AppLanguage.romanUrdu: 'Apna pehla income ya kharcha record karein!',
    },
    'transactions_empty_income_title': {
      AppLanguage.english: 'No Income Entries 💰',
      AppLanguage.romanUrdu: 'Income ka koi record nahi 💰',
    },
    'transactions_empty_income_sub': {
      AppLanguage.english: 'Apna pehla income add karein!',
      AppLanguage.romanUrdu: 'Apni pehli income add karein!',
    },
    'transactions_empty_expense_title': {
      AppLanguage.english: 'No Expenses Recorded 🛒',
      AppLanguage.romanUrdu: 'Koi kharcha record nahi hua 🛒',
    },
    'transactions_empty_expense_sub': {
      AppLanguage.english: 'Koi kharcha nahi hai — sub set hai!',
      AppLanguage.romanUrdu: 'Koi kharcha nahi hai — sab set hai!',
    },
    'transactions_delete_title': {
      AppLanguage.english: 'Delete Entry',
      AppLanguage.romanUrdu: 'Entry Delete Karein',
    },
    'transactions_delete_msg': {
      AppLanguage.english: 'Are you sure you want to delete this transaction entry?',
      AppLanguage.romanUrdu: 'Kya aap waqai is entry ko delete karna chahte hain?',
    },
    'filter_title': {
      AppLanguage.english: 'Filter Transactions',
      AppLanguage.romanUrdu: 'Transactions Filter Karein',
    },
    'filter_reset_all': {
      AppLanguage.english: 'Reset All',
      AppLanguage.romanUrdu: 'Reset All',
    },
    'filter_type': {
      AppLanguage.english: 'Transaction Type',
      AppLanguage.romanUrdu: 'Transaction Type',
    },
    'filter_type_all': {
      AppLanguage.english: 'All',
      AppLanguage.romanUrdu: 'All',
    },
    'filter_type_income': {
      AppLanguage.english: 'Income Only',
      AppLanguage.romanUrdu: 'Sirf Income',
    },
    'filter_type_expense': {
      AppLanguage.english: 'Expense Only',
      AppLanguage.romanUrdu: 'Sirf Expense',
    },
    'filter_categories': {
      AppLanguage.english: 'Categories',
      AppLanguage.romanUrdu: 'Categories',
    },
    'filter_date_range': {
      AppLanguage.english: 'Date Range',
      AppLanguage.romanUrdu: 'Date Range',
    },
    'filter_select_date_range': {
      AppLanguage.english: 'Select Date Range',
      AppLanguage.romanUrdu: 'Date Range Select Karein',
    },
    'filter_amount_range': {
      AppLanguage.english: 'Amount Range (Rs.)',
      AppLanguage.romanUrdu: 'Amount Range (Rs.)',
    },
    'filter_min_amount': {
      AppLanguage.english: 'Min Amount',
      AppLanguage.romanUrdu: 'Min Amount',
    },
    'filter_max_amount': {
      AppLanguage.english: 'Max Amount',
      AppLanguage.romanUrdu: 'Max Amount',
    },
    'filter_apply': {
      AppLanguage.english: 'Apply Filters',
      AppLanguage.romanUrdu: 'Filters Apply Karein',
    },

    // Khata (Borrow & Lend) Screen & Modals
    'khata_title': {
      AppLanguage.english: 'Khata (Borrow & Lend)',
      AppLanguage.romanUrdu: 'Khata (Udhaar & Lend)',
    },
    'khata_manage_people': {
      AppLanguage.english: 'Manage People',
      AppLanguage.romanUrdu: 'Logon Ka Intezam',
    },
    'khata_tab_borrowed': {
      AppLanguage.english: 'I Borrowed (I Owe)',
      AppLanguage.romanUrdu: 'Maine Liya (Dena hai)',
    },
    'khata_tab_lent': {
      AppLanguage.english: 'I Lent (Others Owe Me)',
      AppLanguage.romanUrdu: 'Maine Diya (Lena hai)',
    },
    'khata_btn_borrowed': {
      AppLanguage.english: 'Borrowed',
      AppLanguage.romanUrdu: 'Borrowed',
    },
    'khata_btn_lent': {
      AppLanguage.english: 'Lent',
      AppLanguage.romanUrdu: 'Lent',
    },
    'khata_empty_borrowed_title': {
      AppLanguage.english: 'Koi Udhaar Record Nahi 🎉',
      AppLanguage.romanUrdu: 'Udhaar ka koi record nahi 🎉',
    },
    'khata_empty_borrowed_sub': {
      AppLanguage.english: 'Apka koi udhaar record nahi hai — sab clear hai!',
      AppLanguage.romanUrdu: 'Aapka koi udhaar record nahi hai — sab clear hai!',
    },
    'khata_total_you_owe': {
      AppLanguage.english: 'Total You Owe',
      AppLanguage.romanUrdu: 'Kul Dena Hai',
    },
    'khata_empty_lent_title': {
      AppLanguage.english: 'No Lent Money Records 🤝',
      AppLanguage.romanUrdu: 'Raqam dene ka koi record nahi 🤝',
    },
    'khata_empty_lent_sub': {
      AppLanguage.english: 'Kisi ko pese diye hain? Log them here!',
      AppLanguage.romanUrdu: 'Kisi ko pese diye hain? Yahan record karein!',
    },
    'khata_total_others_owe': {
      AppLanguage.english: 'Total Others Owe You',
      AppLanguage.romanUrdu: 'Kul Lena Hai',
    },
    'khata_status_fully_paid': {
      AppLanguage.english: 'Fully Paid',
      AppLanguage.romanUrdu: 'Fully Paid',
    },
    'khata_status_partially_paid': {
      AppLanguage.english: 'Partially Paid',
      AppLanguage.romanUrdu: 'Partially Paid',
    },
    'khata_status_pending': {
      AppLanguage.english: 'Pending',
      AppLanguage.romanUrdu: 'Pending',
    },
    'khata_total': {
      AppLanguage.english: 'Total',
      AppLanguage.romanUrdu: 'Kul',
    },
    'khata_paid': {
      AppLanguage.english: 'Paid',
      AppLanguage.romanUrdu: 'Ada Shuda',
    },
    'khata_remaining': {
      AppLanguage.english: 'Remaining',
      AppLanguage.romanUrdu: 'Baqi',
    },
    'khata_add_borrowed_title': {
      AppLanguage.english: '+ Borrow Money (I Owe)',
      AppLanguage.romanUrdu: '+ Raqam Udhaar Li (Deni hai)',
    },
    'khata_edit_borrowed_title': {
      AppLanguage.english: 'Edit Borrowed Entry',
      AppLanguage.romanUrdu: 'Borrowed Entry Edit Karein',
    },
    'khata_add_lent_title': {
      AppLanguage.english: '+ Lend Money (Others Owe Me)',
      AppLanguage.romanUrdu: '+ Raqam Udhaar Di (Leni hai)',
    },
    'khata_edit_lent_title': {
      AppLanguage.english: 'Edit Lent Entry',
      AppLanguage.romanUrdu: 'Lent Entry Edit Karein',
    },
    'khata_person_label': {
      AppLanguage.english: 'Person *',
      AppLanguage.romanUrdu: 'Person *',
    },
    'khata_select_person': {
      AppLanguage.english: 'Select Person',
      AppLanguage.romanUrdu: 'Person Select Karein',
    },
    'khata_add_new_person_tooltip': {
      AppLanguage.english: 'Add New Person',
      AppLanguage.romanUrdu: 'Naya Person Add Karein',
    },
    'khata_amount_label': {
      AppLanguage.english: 'Total Amount (Rs.) *',
      AppLanguage.romanUrdu: 'Kul Raqam (Rs.) *',
    },
    'khata_date_label': {
      AppLanguage.english: 'Date *',
      AppLanguage.romanUrdu: 'Tareekh *',
    },
    'khata_note_label': {
      AppLanguage.english: 'Note / Reason (Optional)',
      AppLanguage.romanUrdu: 'Note / Wajah (Optional)',
    },
    'khata_remind_me_label': {
      AppLanguage.english: 'Remind Me On (Optional)',
      AppLanguage.romanUrdu: 'Remind Me On (Optional)',
    },
    'khata_tap_set_reminder': {
      AppLanguage.english: 'Tap to set reminder date & time',
      AppLanguage.romanUrdu: 'Reminder setting ke liye tap karein',
    },
    'khata_save_entry': {
      AppLanguage.english: 'Save Entry',
      AppLanguage.romanUrdu: 'Entry Save Karein',
    },
    'khata_update_entry': {
      AppLanguage.english: 'Update Entry',
      AppLanguage.romanUrdu: 'Entry Update Karein',
    },
    'khata_err_select_person': {
      AppLanguage.english: 'Please select or add a person.',
      AppLanguage.romanUrdu: 'Barah-e-rast person select karein ya naya add karein.',
    },
    'khata_add_person_title': {
      AppLanguage.english: 'Add New Person',
      AppLanguage.romanUrdu: 'Naya Person Add Karein',
    },
    'khata_edit_person_title': {
      AppLanguage.english: 'Edit Person',
      AppLanguage.romanUrdu: 'Person Details Edit Karein',
    },
    'khata_person_name_label': {
      AppLanguage.english: 'Person Name *',
      AppLanguage.romanUrdu: 'Naam *',
    },
    'khata_phone_label': {
      AppLanguage.english: 'Phone Number (Optional)',
      AppLanguage.romanUrdu: 'Phone Number (Optional)',
    },
    'khata_save_person': {
      AppLanguage.english: 'Save Person',
      AppLanguage.romanUrdu: 'Person Save Karein',
    },
    'khata_update_person': {
      AppLanguage.english: 'Update Person',
      AppLanguage.romanUrdu: 'Person Update Karein',
    },
    'khata_log_repayment_borrowed': {
      AppLanguage.english: 'Log Payment (Money Returned)',
      AppLanguage.romanUrdu: 'Raqam wapas ki (Log Payment)',
    },
    'khata_log_repayment_lent': {
      AppLanguage.english: 'Log Receipt (Money Received)',
      AppLanguage.romanUrdu: 'Raqam wasool hui (Log Receipt)',
    },
    'khata_current_remaining_balance': {
      AppLanguage.english: 'Current Remaining Balance:',
      AppLanguage.romanUrdu: 'Mawjooda Baqi Raqam:',
    },
    'khata_repayment_amount_label': {
      AppLanguage.english: 'Repayment Amount (Rs.) *',
      AppLanguage.romanUrdu: 'Repayment Raqam (Rs.) *',
    },
    'khata_pay_full': {
      AppLanguage.english: 'Pay Full',
      AppLanguage.romanUrdu: 'Pay Full',
    },
    'khata_save_repayment': {
      AppLanguage.english: 'Save Repayment',
      AppLanguage.romanUrdu: 'Repayment Save Karein',
    },

    // Wishlist & Shopping Screen & Modals
    'wishlist_title': {
      AppLanguage.english: 'Wishlist & Shopping',
      AppLanguage.romanUrdu: 'Wishlist aur Khareedari',
    },
    'wishlist_tab_wishlist': {
      AppLanguage.english: 'Wishlist',
      AppLanguage.romanUrdu: 'Wishlist',
    },
    'wishlist_tab_purchases': {
      AppLanguage.english: 'Purchase History',
      AppLanguage.romanUrdu: 'Khareedari History',
    },
    'wishlist_add_wish': {
      AppLanguage.english: 'Add Wish',
      AppLanguage.romanUrdu: 'Add Wish',
    },
    'wishlist_log_purchase': {
      AppLanguage.english: 'Log Purchase',
      AppLanguage.romanUrdu: 'Log Purchase',
    },
    'wishlist_search_hint': {
      AppLanguage.english: 'Search wishlist by name or category...',
      AppLanguage.romanUrdu: 'Naam ya category se wishlist search karein...',
    },
    'wishlist_total_value': {
      AppLanguage.english: 'Total Wishlist Value',
      AppLanguage.romanUrdu: 'Wishlist ki kul keemat',
    },
    'wishlist_empty_active_title': {
      AppLanguage.english: 'Your wishlist is empty',
      AppLanguage.romanUrdu: 'Aapki wishlist khali hai',
    },
    'wishlist_empty_active_sub': {
      AppLanguage.english: 'Tap "+ Add Wish" to start tracking things you want to buy.',
      AppLanguage.romanUrdu: '"+ Add Wish" par tap karke khawahishat add karein.',
    },
    'wishlist_empty_purchased_title': {
      AppLanguage.english: 'No purchased wishlist items',
      AppLanguage.romanUrdu: 'Koi khareedi gayi cheez nahi hai',
    },
    'wishlist_empty_purchased_sub': {
      AppLanguage.english: 'Items you mark as purchased will appear here.',
      AppLanguage.romanUrdu: 'Jo items aap purchased mark karenge wo yahan dikhenge.',
    },
    'wishlist_priority_high': {
      AppLanguage.english: 'HIGH PRIORITY',
      AppLanguage.romanUrdu: 'High Priority',
    },
    'wishlist_priority_medium': {
      AppLanguage.english: 'MEDIUM PRIORITY',
      AppLanguage.romanUrdu: 'Medium Priority',
    },
    'wishlist_priority_low': {
      AppLanguage.english: 'LOW PRIORITY',
      AppLanguage.romanUrdu: 'Low Priority',
    },
    'wishlist_mark_purchased_btn': {
      AppLanguage.english: 'Mark Purchased',
      AppLanguage.romanUrdu: 'Purchased Mark Karein',
    },
    'wishlist_history_search_hint': {
      AppLanguage.english: 'Search purchase history...',
      AppLanguage.romanUrdu: 'Purchase history mein search karein...',
    },
    'wishlist_total_spent': {
      AppLanguage.english: 'Total Spent on Wishlist',
      AppLanguage.romanUrdu: 'Wishlist par kul kharcha',
    },
    'wishlist_empty_history_title': {
      AppLanguage.english: 'No Purchase History',
      AppLanguage.romanUrdu: 'Koi purchase history nahi hai',
    },
    'wishlist_empty_history_sub': {
      AppLanguage.english: 'Log your item purchases to track spendings!',
      AppLanguage.romanUrdu: 'Kharcha track karne ke liye khareedari record karein!',
    },
    'wishlist_add_modal_title': {
      AppLanguage.english: '+ Add Wishlist Item',
      AppLanguage.romanUrdu: '+ Nayi Wish Add Karein',
    },
    'wishlist_edit_modal_title': {
      AppLanguage.english: 'Edit Wishlist Item',
      AppLanguage.romanUrdu: 'Wish Edit Karein',
    },
    'wishlist_item_name_label': {
      AppLanguage.english: 'Item Name *',
      AppLanguage.romanUrdu: 'Cheez Ka Naam *',
    },
    'wishlist_est_price_label': {
      AppLanguage.english: 'Estimated Price (Rs.) *',
      AppLanguage.romanUrdu: 'Andazan Keemat (Rs.) *',
    },
    'wishlist_category_label': {
      AppLanguage.english: 'Category *',
      AppLanguage.romanUrdu: 'Category *',
    },
    'wishlist_priority_label': {
      AppLanguage.english: 'Priority *',
      AppLanguage.romanUrdu: 'Priority *',
    },
    'wishlist_notes_label': {
      AppLanguage.english: 'Notes (Optional)',
      AppLanguage.romanUrdu: 'Notes (Optional)',
    },
    'wishlist_save_item': {
      AppLanguage.english: 'Save Item',
      AppLanguage.romanUrdu: 'Item Save Karein',
    },
    'wishlist_update_item': {
      AppLanguage.english: 'Update Item',
      AppLanguage.romanUrdu: 'Item Update Karein',
    },

    // Reports & Analytics Screen & Helpers
    'reports_title': {
      AppLanguage.english: 'Reports & Analytics',
      AppLanguage.romanUrdu: 'Reports & Analytics',
    },
    'reports_export_tooltip': {
      AppLanguage.english: 'Export PDF Report',
      AppLanguage.romanUrdu: 'PDF Report Export Karein',
    },
    'reports_range_this_month': {
      AppLanguage.english: 'This Month',
      AppLanguage.romanUrdu: 'Is Mahine',
    },
    'reports_range_last_3_months': {
      AppLanguage.english: 'Last 3 Months',
      AppLanguage.romanUrdu: 'Pichle 3 Mahine',
    },
    'reports_range_last_6_months': {
      AppLanguage.english: 'Last 6 Months',
      AppLanguage.romanUrdu: 'Pichle 6 Mahine',
    },
    'reports_range_this_year': {
      AppLanguage.english: 'This Year',
      AppLanguage.romanUrdu: 'Is Saal',
    },
    'reports_range_all_time': {
      AppLanguage.english: 'All Time',
      AppLanguage.romanUrdu: 'Tamam Waqt',
    },
    'reports_range_custom': {
      AppLanguage.english: 'Custom',
      AppLanguage.romanUrdu: 'Custom Date',
    },
    'reports_predictive_title': {
      AppLanguage.english: 'PREDICTIVE INSIGHT (MOVING AVG)',
      AppLanguage.romanUrdu: 'Predictive Insight (Moving Avg)',
    },
    'reports_savings_rate_title': {
      AppLanguage.english: 'Savings Rate',
      AppLanguage.romanUrdu: 'Savings Rate (Bachat)',
    },
    'reports_savings_rate_sub': {
      AppLanguage.english: 'Percentage of income saved for',
      AppLanguage.romanUrdu: 'Income ka kitna % bachat hua for',
    },
    'reports_spending_trends_title': {
      AppLanguage.english: 'Spending Trends',
      AppLanguage.romanUrdu: 'Spending Trends (Kharchay)',
    },
    'reports_spending_trends_sub': {
      AppLanguage.english: 'Monthly expense comparison & percentage change',
      AppLanguage.romanUrdu: 'Mahana kharchay ka muqabla aur change',
    },
    'reports_category_breakdown_title': {
      AppLanguage.english: 'Category Breakdown',
      AppLanguage.romanUrdu: 'Category Breakdown',
    },
    'reports_weekday_pattern_title': {
      AppLanguage.english: 'Weekday Pattern',
      AppLanguage.romanUrdu: 'Weekday Pattern',
    },
    'reports_weekday_pattern_sub': {
      AppLanguage.english: 'Expense accumulation by day of week',
      AppLanguage.romanUrdu: 'Hafte ke dinon ke mutabiq kharcha',
    },
    'reports_khata_analytics_title': {
      AppLanguage.english: 'Khata Analytics',
      AppLanguage.romanUrdu: 'Khata Analytics',
    },
    'reports_no_expense_data': {
      AppLanguage.english: 'No expense records logged for this period.',
      AppLanguage.romanUrdu: 'Is dauran koi kharcha record nahi hua.',
    },
    'reports_no_projection_data': {
      AppLanguage.english: 'Not enough data yet for a projection',
      AppLanguage.romanUrdu: 'Projection ke liye abhi data kam hai',
    },
    'reports_no_weekday_data': {
      AppLanguage.english: 'No expense data for weekday analysis.',
      AppLanguage.romanUrdu: 'Weekday analysis ke liye koi data nahi hai.',
    },
    'reports_savings_unavailable': {
      AppLanguage.english: 'Savings rate unavailable — no income recorded for this period.',
      AppLanguage.romanUrdu: 'Savings rate unavailable — is period mein income record nahi hui.',
    },

    // More Screen
    'more_title': {
      AppLanguage.english: 'More Options',
      AppLanguage.romanUrdu: 'Mazeed Options',
    },
    'more_section_financial_tools': {
      AppLanguage.english: 'FINANCIAL TOOLS',
      AppLanguage.romanUrdu: 'Financial Tools',
    },
    'more_wishlist_title': {
      AppLanguage.english: 'Wishlist & Shopping',
      AppLanguage.romanUrdu: 'Wishlist aur Khareedari',
    },
    'more_wishlist_sub': {
      AppLanguage.english: 'Track desired items & purchase history',
      AppLanguage.romanUrdu: 'Khawahishat ki list aur khareedari history',
    },
    'more_recurring_title': {
      AppLanguage.english: 'Manage Recurring',
      AppLanguage.romanUrdu: 'Bar bar hone wale kharch',
    },
    'more_recurring_sub': {
      AppLanguage.english: 'Auto-recurring income & expense rules',
      AppLanguage.romanUrdu: 'Khudkar aamdani aur kharcha rules',
    },
    'more_budget_title': {
      AppLanguage.english: 'Budget Management',
      AppLanguage.romanUrdu: 'Budget Management',
    },
    'more_budget_sub': {
      AppLanguage.english: 'Set monthly limits & track category spending',
      AppLanguage.romanUrdu: 'Mahana limit set karein aur kharcha dekhein',
    },
    'more_savings_title': {
      AppLanguage.english: 'Savings Goals',
      AppLanguage.romanUrdu: 'Bachat ke Ahadāf',
    },
    'more_savings_sub': {
      AppLanguage.english: 'Set target savings & track contributions',
      AppLanguage.romanUrdu: 'Bachat target set karein aur shamil raqam dekhein',
    },
    'more_section_appearance': {
      AppLanguage.english: 'APPEARANCE & THEME',
      AppLanguage.romanUrdu: 'Appearance & Theme',
    },
    'more_theme_mode': {
      AppLanguage.english: 'App Theme Mode',
      AppLanguage.romanUrdu: 'App Theme Mode',
    },
    'more_theme_system': {
      AppLanguage.english: 'System',
      AppLanguage.romanUrdu: 'System',
    },
    'more_theme_light': {
      AppLanguage.english: 'Light',
      AppLanguage.romanUrdu: 'Light',
    },
    'more_theme_dark': {
      AppLanguage.english: 'Dark',
      AppLanguage.romanUrdu: 'Dark',
    },
    'more_app_language': {
      AppLanguage.english: 'App Language',
      AppLanguage.romanUrdu: 'App Ki Zabaan',
    },
    'more_lang_english': {
      AppLanguage.english: 'English',
      AppLanguage.romanUrdu: 'English',
    },
    'more_lang_urdu': {
      AppLanguage.english: 'اردو',
      AppLanguage.romanUrdu: 'اردو',
    },
    'more_lang_roman_urdu': {
      AppLanguage.english: 'Roman Urdu',
      AppLanguage.romanUrdu: 'Roman Urdu',
    },
    'more_section_preferences': {
      AppLanguage.english: 'PREFERENCES & SETTINGS',
      AppLanguage.romanUrdu: 'Tarjeehat aur Settings',
    },
    'more_notifications_title': {
      AppLanguage.english: 'Notification Settings',
      AppLanguage.romanUrdu: 'Notification Settings',
    },
    'more_notifications_sub': {
      AppLanguage.english: 'Budget alerts, Khata & Savings reminders',
      AppLanguage.romanUrdu: 'Budget alerts, Khata aur Bachat reminders',
    },
    'more_security_title': {
      AppLanguage.english: 'PIN & Biometric Security',
      AppLanguage.romanUrdu: 'PIN aur Biometric Security',
    },
    'more_security_sub': {
      AppLanguage.english: 'Protect your financial data offline',
      AppLanguage.romanUrdu: 'Apna financial data offline mehfooz rakhein',
    },
    'more_backup_title': {
      AppLanguage.english: 'Data Backup & Restore',
      AppLanguage.romanUrdu: 'Data Backup aur Restore',
    },
    'more_backup_sub': {
      AppLanguage.english: 'Export & import offline JSON backup files',
      AppLanguage.romanUrdu: 'Offline JSON backup files export aur import karein',
    },
    'more_section_about': {
      AppLanguage.english: 'ABOUT & COMMUNITY',
      AppLanguage.romanUrdu: 'About & Community',
    },
    'more_share_title': {
      AppLanguage.english: 'Share App',
      AppLanguage.romanUrdu: 'App Share Karein',
    },
    'more_share_sub': {
      AppLanguage.english: 'Share Apna Batwa with friends & family',
      AppLanguage.romanUrdu: 'Doston aur family ke sath Apna Batwa share karein',
    },
    'more_share_message': {
      AppLanguage.english: 'Check out Apna Batwa — a free offline personal finance app for students to track income, expenses, and Khata!',
      AppLanguage.romanUrdu: 'Apna Batwa try karein — students ke liye aamdani, kharcha aur Khata track karne wali free offline app!',
    },
    'more_contact_title': {
      AppLanguage.english: 'Contact / Feedback',
      AppLanguage.romanUrdu: 'Rabta / Feedback',
    },
    'more_contact_sub': {
      AppLanguage.english: 'Send feedback directly to info.shahnawaz99@gmail.com',
      AppLanguage.romanUrdu: 'Barah-e-rast info.shahnawaz99@gmail.com par feedback bhejein',
    },
    'more_no_email_app': {
      AppLanguage.english: 'No email app available on this device',
      AppLanguage.romanUrdu: 'Is device par koi email app mojood nahi hai',
    },
    'more_about_title': {
      AppLanguage.english: 'About Apna Batwa',
      AppLanguage.romanUrdu: 'Apna Batwa ke baare mein',
    },
    'more_about_sub': {
      AppLanguage.english: 'App details, version info & privacy details',
      AppLanguage.romanUrdu: 'App tafseelat, version aur privacy ki jankari',
    },
    'more_version': {
      AppLanguage.english: 'Version',
      AppLanguage.romanUrdu: 'Version',
    },
    'more_developer_credit': {
      AppLanguage.english: 'Developed by SN Technologies',
      AppLanguage.romanUrdu: 'Developed by SN Technologies',
    },

    // --- PHASE 3 TRANSLATIONS ---
    // Budget Management
    'budget_title': {
      AppLanguage.english: 'Budget Management',
      AppLanguage.romanUrdu: 'Budget Management',
    },
    'budget_category_budgets': {
      AppLanguage.english: 'Category Budgets',
      AppLanguage.romanUrdu: 'Categories ke Budget',
    },
    'budget_set_button': {
      AppLanguage.english: 'Set Budget',
      AppLanguage.romanUrdu: 'Set Budget',
    },
    'budget_empty_title': {
      AppLanguage.english: 'Koi Budget Set Nahi 🎯',
      AppLanguage.romanUrdu: 'Koi Budget Set Nahi 🎯',
    },
    'budget_empty_sub': {
      AppLanguage.english: 'Tap "Set Budget" to set monthly spending limits for categories!',
      AppLanguage.romanUrdu: 'Categories ke liye mahana limit set karne ke liye "Set Budget" dabayein!',
    },
    'budget_modal_set_title': {
      AppLanguage.english: 'Set Category Budget',
      AppLanguage.romanUrdu: 'Category Budget Set Karein',
    },
    'budget_modal_edit_title': {
      AppLanguage.english: 'Edit Budget',
      AppLanguage.romanUrdu: 'Budget Edit Karein',
    },
    'budget_monthly_limit_label': {
      AppLanguage.english: 'Monthly Limit (Rs.) *',
      AppLanguage.romanUrdu: 'Mahana Limit (Rs.) *',
    },

    // Savings Goals
    'savings_title': {
      AppLanguage.english: 'Savings Goals',
      AppLanguage.romanUrdu: 'Savings Goals',
    },
    'savings_your_goals': {
      AppLanguage.english: 'Your Goals',
      AppLanguage.romanUrdu: 'Aap ke Ahadāf',
    },
    'savings_new_goal_btn': {
      AppLanguage.english: 'New Goal',
      AppLanguage.romanUrdu: 'Naya Goal',
    },
    'savings_empty_title': {
      AppLanguage.english: 'No Active Savings Goals 🐖',
      AppLanguage.romanUrdu: 'Koi Active Savings Goal Nahi 🐖',
    },
    'savings_empty_sub': {
      AppLanguage.english: 'Apna pehla savings goal banayein aur bachat shuru karein!',
      AppLanguage.romanUrdu: 'Apna pehla savings goal banayein aur bachat shuru karein!',
    },
    'savings_due_today': {
      AppLanguage.english: 'Due Today!',
      AppLanguage.romanUrdu: 'Aaj due hai!',
    },
    'savings_goal_achieved': {
      AppLanguage.english: 'Goal Achieved! 🎉',
      AppLanguage.romanUrdu: 'Goal Achieved! 🎉',
    },
    'savings_saved': {
      AppLanguage.english: 'Saved',
      AppLanguage.romanUrdu: 'Saved',
    },
    'savings_target': {
      AppLanguage.english: 'Target',
      AppLanguage.romanUrdu: 'Target',
    },
    'savings_add_money_btn': {
      AppLanguage.english: 'Add Money',
      AppLanguage.romanUrdu: 'Add Money',
    },
    'savings_detail_title': {
      AppLanguage.english: 'Savings Goal Detail',
      AppLanguage.romanUrdu: 'Savings Goal Detail',
    },
    'savings_contribution_history': {
      AppLanguage.english: 'Contribution History',
      AppLanguage.romanUrdu: 'Contribution History',
    },
    'savings_empty_contributions_title': {
      AppLanguage.english: 'No contributions logged yet',
      AppLanguage.romanUrdu: 'Abhi koi money add nahi hua',
    },
    'savings_empty_contributions_sub': {
      AppLanguage.english: 'Tap "+ Add Money" to start setting money aside for this goal.',
      AppLanguage.romanUrdu: 'Is goal ke liye raqam mehfooz karne ke liye "+ Add Money" dabayein.',
    },
    'savings_withdraw_tooltip': {
      AppLanguage.english: 'Withdraw Contribution',
      AppLanguage.romanUrdu: 'Raqam wapas nikalne',
    },
    'savings_withdraw_dialog_title': {
      AppLanguage.english: 'Withdraw Contribution',
      AppLanguage.romanUrdu: 'Withdraw Contribution',
    },
    'savings_withdraw_dialog_msg': {
      AppLanguage.english: 'Are you sure you want to withdraw money from this goal? This will return the money to your available balance.',
      AppLanguage.romanUrdu: 'Kya aap waqai is goal se raqam wapas nikalna chahte hain? Ye raqam aap ke available balance mein wapas aa jaye gi.',
    },
    'savings_withdraw_btn': {
      AppLanguage.english: 'Withdraw',
      AppLanguage.romanUrdu: 'Withdraw',
    },
    'savings_delete_dialog_title': {
      AppLanguage.english: 'Delete Savings Goal',
      AppLanguage.romanUrdu: 'Savings Goal Delete Karein',
    },
    'savings_delete_dialog_msg': {
      AppLanguage.english: 'Are you sure you want to delete this savings goal?',
      AppLanguage.romanUrdu: 'Kya aap waqai is savings goal ko delete karna chahte hain?',
    },
    'savings_modal_add_title': {
      AppLanguage.english: '+ New Savings Goal',
      AppLanguage.romanUrdu: '+ Naya Savings Goal',
    },
    'savings_modal_edit_title': {
      AppLanguage.english: 'Edit Savings Goal',
      AppLanguage.romanUrdu: 'Savings Goal Edit Karein',
    },
    'savings_goal_name_label': {
      AppLanguage.english: 'Goal Name *',
      AppLanguage.romanUrdu: 'Goal Ka Naam *',
    },
    'savings_target_amount_label': {
      AppLanguage.english: 'Target Amount (Rs.) *',
      AppLanguage.romanUrdu: 'Target Amount (Rs.) *',
    },
    'savings_target_date_label': {
      AppLanguage.english: 'Target Date (Optional)',
      AppLanguage.romanUrdu: 'Target Date (Optional)',
    },
    'savings_no_deadline': {
      AppLanguage.english: 'No target deadline set',
      AppLanguage.romanUrdu: 'Koi target deadline set nahi',
    },
    'savings_save_goal_changes': {
      AppLanguage.english: 'Save Goal Changes',
      AppLanguage.romanUrdu: 'Changes Save Karein',
    },
    'savings_create_goal': {
      AppLanguage.english: 'Create Savings Goal',
      AppLanguage.romanUrdu: 'Goal Banayein',
    },
    'savings_modal_add_money_title': {
      AppLanguage.english: '+ Add Money to Goal',
      AppLanguage.romanUrdu: '+ Goal Mein Money Add Karein',
    },
    'savings_contrib_amount_label': {
      AppLanguage.english: 'Contribution Amount (Rs.) *',
      AppLanguage.romanUrdu: 'Contribution Amount (Rs.) *',
    },
    'savings_save_contribution': {
      AppLanguage.english: 'Save Contribution',
      AppLanguage.romanUrdu: 'Contribution Save Karein',
    },

    // Recurring Transactions
    'recurring_title': {
      AppLanguage.english: 'Recurring Transactions',
      AppLanguage.romanUrdu: 'Recurring Transactions',
    },
    'recurring_empty_title': {
      AppLanguage.english: 'No Recurring Transactions 🔄',
      AppLanguage.romanUrdu: 'Koi Recurring Transaction Nahi 🔄',
    },
    'recurring_empty_sub': {
      AppLanguage.english: 'Set up auto-recurring salary, pocket money, or bill rules!',
      AppLanguage.romanUrdu: 'Auto-recurring salary, pocket money ya bill rules set karein!',
    },
    'recurring_add_rule_btn': {
      AppLanguage.english: 'Add Recurring Rule',
      AppLanguage.romanUrdu: 'Recurring Rule Add Karein',
    },
    'recurring_status_active': {
      AppLanguage.english: 'ACTIVE',
      AppLanguage.romanUrdu: 'ACTIVE',
    },
    'recurring_status_paused': {
      AppLanguage.english: 'PAUSED',
      AppLanguage.romanUrdu: 'PAUSED',
    },
    'recurring_pause_tooltip': {
      AppLanguage.english: 'Pause Rule',
      AppLanguage.romanUrdu: 'Rule Pause Karein',
    },
    'recurring_resume_tooltip': {
      AppLanguage.english: 'Resume Rule',
      AppLanguage.romanUrdu: 'Rule Resume Karein',
    },
    'recurring_delete_dialog_title': {
      AppLanguage.english: 'Delete Recurring Rule',
      AppLanguage.romanUrdu: 'Recurring Rule Delete Karein',
    },
    'recurring_delete_dialog_msg': {
      AppLanguage.english: 'Are you sure you want to delete this rule? Past generated income/expense records will remain intact.',
      AppLanguage.romanUrdu: 'Kya aap waqai is rule ko delete karna chahte hain? Pehla data mehfooz rahega.',
    },
    'recurring_modal_add_title': {
      AppLanguage.english: 'Add Recurring Rule',
      AppLanguage.romanUrdu: 'Add Recurring Rule',
    },
    'recurring_modal_edit_title': {
      AppLanguage.english: 'Edit Recurring Rule',
      AppLanguage.romanUrdu: 'Edit Recurring Rule',
    },
    'recurring_name_label': {
      AppLanguage.english: 'Name / Source',
      AppLanguage.romanUrdu: 'Naam / Source',
    },
    'recurring_amount_label': {
      AppLanguage.english: 'Amount',
      AppLanguage.romanUrdu: 'Amount',
    },
    'recurring_frequency_label': {
      AppLanguage.english: 'Frequency',
      AppLanguage.romanUrdu: 'Frequency',
    },
    'recurring_start_date_label': {
      AppLanguage.english: 'Start Date',
      AppLanguage.romanUrdu: 'Start Date',
    },
    'recurring_update_rule_btn': {
      AppLanguage.english: 'Update Rule',
      AppLanguage.romanUrdu: 'Rule Update Karein',
    },
    'recurring_save_rule_btn': {
      AppLanguage.english: 'Save Rule',
      AppLanguage.romanUrdu: 'Rule Save Karein',
    },

    // Income & Expense Modals
    'income_modal_add_title': {
      AppLanguage.english: 'Add Money In (Income)',
      AppLanguage.romanUrdu: 'Add Money In (Income)',
    },
    'income_modal_edit_title': {
      AppLanguage.english: 'Edit Income',
      AppLanguage.romanUrdu: 'Income Edit Karein',
    },
    'income_delete_title': {
      AppLanguage.english: 'Delete Income Entry',
      AppLanguage.romanUrdu: 'Income Entry Delete Karein',
    },
    'income_delete_msg': {
      AppLanguage.english: 'Are you sure you want to delete this income entry?',
      AppLanguage.romanUrdu: 'Kya aap waqai is income entry ko delete karna chahte hain?',
    },
    'income_amount_label': {
      AppLanguage.english: 'Amount (PKR)',
      AppLanguage.romanUrdu: 'Amount (PKR)',
    },
    'income_source_label': {
      AppLanguage.english: 'Income Source',
      AppLanguage.romanUrdu: 'Income Source',
    },
    'income_make_recurring': {
      AppLanguage.english: 'Make this recurring',
      AppLanguage.romanUrdu: 'Is ko recurring banayein',
    },
    'income_recurring_sub': {
      AppLanguage.english: 'Auto-generate future income entries',
      AppLanguage.romanUrdu: 'Future income entries auto-generate karein',
    },
    'income_save_btn': {
      AppLanguage.english: 'Save Income',
      AppLanguage.romanUrdu: 'Income Save Karein',
    },
    'income_update_btn': {
      AppLanguage.english: 'Update Income',
      AppLanguage.romanUrdu: 'Income Update Karein',
    },

    'expense_modal_add_title': {
      AppLanguage.english: 'Add Expense',
      AppLanguage.romanUrdu: 'Add Expense',
    },
    'expense_modal_edit_title': {
      AppLanguage.english: 'Edit Expense',
      AppLanguage.romanUrdu: 'Expense Edit Karein',
    },
    'expense_delete_title': {
      AppLanguage.english: 'Delete Expense Entry',
      AppLanguage.romanUrdu: 'Expense Entry Delete Karein',
    },
    'expense_delete_msg': {
      AppLanguage.english: 'Are you sure you want to delete this expense entry?',
      AppLanguage.romanUrdu: 'Kya aap waqai is expense entry ko delete karna chahte hain?',
    },
    'expense_amount_label': {
      AppLanguage.english: 'Amount (PKR)',
      AppLanguage.romanUrdu: 'Amount (PKR)',
    },
    'expense_category_label': {
      AppLanguage.english: 'Category',
      AppLanguage.romanUrdu: 'Category',
    },
    'expense_payment_method_label': {
      AppLanguage.english: 'Payment Method',
      AppLanguage.romanUrdu: 'Payment Method',
    },
    'expense_make_recurring': {
      AppLanguage.english: 'Make this recurring',
      AppLanguage.romanUrdu: 'Is ko recurring banayein',
    },
    'expense_recurring_sub': {
      AppLanguage.english: 'Auto-generate future expense entries',
      AppLanguage.romanUrdu: 'Future expense entries auto-generate karein',
    },
    'expense_save_btn': {
      AppLanguage.english: 'Save Expense',
      AppLanguage.romanUrdu: 'Expense Save Karein',
    },
    'expense_update_btn': {
      AppLanguage.english: 'Update Expense',
      AppLanguage.romanUrdu: 'Expense Update Karein',
    },

    // Security & PIN Lock
    'sec_title': {
      AppLanguage.english: 'Security & Lock',
      AppLanguage.romanUrdu: 'Security & Lock',
    },
    'sec_app_lock_enabled': {
      AppLanguage.english: 'App Lock Enabled',
      AppLanguage.romanUrdu: 'App Lock Enabled',
    },
    'sec_app_lock_disabled': {
      AppLanguage.english: 'App Lock Disabled',
      AppLanguage.romanUrdu: 'App Lock Disabled',
    },
    'sec_lock_enabled_sub': {
      AppLanguage.english: 'Apna Batwa requires authentication to access your data.',
      AppLanguage.romanUrdu: 'Apna Batwa data access karne ke liye authentication zaroori hai.',
    },
    'sec_lock_disabled_sub': {
      AppLanguage.english: 'Set a 4-digit PIN to prevent unauthorized access.',
      AppLanguage.romanUrdu: 'Unauthorized access rokne ke liye 4-digit PIN set karein.',
    },
    'sec_pin_header': {
      AppLanguage.english: 'PIN SECURITY',
      AppLanguage.romanUrdu: 'PIN Security',
    },
    'sec_set_pin_title': {
      AppLanguage.english: 'Set 4-Digit PIN',
      AppLanguage.romanUrdu: '4-Digit PIN Set Karein',
    },
    'sec_set_pin_sub': {
      AppLanguage.english: 'Create a new PIN code',
      AppLanguage.romanUrdu: 'Naya PIN code banayein',
    },
    'sec_change_pin': {
      AppLanguage.english: 'Change PIN',
      AppLanguage.romanUrdu: 'PIN Change Karein',
    },
    'sec_remove_pin': {
      AppLanguage.english: 'Remove PIN',
      AppLanguage.romanUrdu: 'PIN Remove Karein',
    },
    'sec_biometrics_header': {
      AppLanguage.english: 'BIOMETRICS & AUTO-LOCK',
      AppLanguage.romanUrdu: 'Biometrics & Auto-Lock',
    },
    'sec_biometric_unlock': {
      AppLanguage.english: 'Biometric Unlock',
      AppLanguage.romanUrdu: 'Biometric Unlock',
    },
    'sec_biometric_available': {
      AppLanguage.english: 'Use Fingerprint or Face ID',
      AppLanguage.romanUrdu: 'Fingerprint ya Face ID use karein',
    },
    'sec_biometric_unavailable': {
      AppLanguage.english: 'Biometrics not available on this device',
      AppLanguage.romanUrdu: 'Is device par biometrics available nahi hai',
    },
    'sec_auto_lock': {
      AppLanguage.english: 'Auto-Lock Duration',
      AppLanguage.romanUrdu: 'Auto-Lock Duration',
    },
    'sec_enter_current_pin': {
      AppLanguage.english: 'Enter Current PIN',
      AppLanguage.romanUrdu: 'Mawjooda PIN Darj Karein',
    },
    'sec_incorrect_pin': {
      AppLanguage.english: 'Incorrect PIN',
      AppLanguage.romanUrdu: 'Ghalat PIN',
    },
    'sec_confirm_btn': {
      AppLanguage.english: 'Confirm',
      AppLanguage.romanUrdu: 'Confirm',
    },
    'sec_enter_4digit': {
      AppLanguage.english: 'Enter your 4-digit PIN',
      AppLanguage.romanUrdu: 'Apna 4-digit PIN darj karein',
    },
    'sec_incorrect_pin_try_again': {
      AppLanguage.english: 'Incorrect PIN. Try again.',
      AppLanguage.romanUrdu: 'Ghalat PIN. Dobara koshish karein.',
    },
    'sec_forgot_pin': {
      AppLanguage.english: 'Forgot PIN?',
      AppLanguage.romanUrdu: 'PIN Bhool Gaye?',
    },
    'sec_reset_pin_title': {
      AppLanguage.english: 'Reset Security PIN?',
      AppLanguage.romanUrdu: 'Security PIN Reset Karein?',
    },
    'sec_reset_pin_msg': {
      AppLanguage.english: 'Apna Batwa is a 100% offline personal app. If you have forgotten your PIN, resetting it will remove the PIN lock so you can access your finances.\n\nDo you wish to remove the PIN lock?',
      AppLanguage.romanUrdu: 'Apna Batwa 100% offline app hai. Agar aap PIN bhool gaye hain to isey reset karne se PIN lock khatam ho jaye ga taakey aap apna data access kar sakein.\n\nKya aap PIN lock khatam karna chahte hain?',
    },
    'sec_reset_pin_btn': {
      AppLanguage.english: 'Reset PIN & Unlock',
      AppLanguage.romanUrdu: 'Reset PIN & Unlock',
    },
    'sec_set_new_pin': {
      AppLanguage.english: 'Set New 4-Digit PIN',
      AppLanguage.romanUrdu: 'Set New 4-Digit PIN',
    },
    'sec_confirm_new_pin': {
      AppLanguage.english: 'Confirm Your 4-Digit PIN',
      AppLanguage.romanUrdu: 'Confirm Your 4-Digit PIN',
    },
    'sec_enter_code_sub': {
      AppLanguage.english: 'Enter a 4-digit code to protect Apna Batwa',
      AppLanguage.romanUrdu: 'Apna Batwa ki hifazat ke liye 4-digit code darj karein',
    },
    'sec_reenter_code_sub': {
      AppLanguage.english: 'Re-enter the same 4-digit code to confirm',
      AppLanguage.romanUrdu: 'Tasdeeq ke liye wahi 4-digit code dobara darj karein',
    },
    'sec_pins_dont_match': {
      AppLanguage.english: 'PINs do not match. Try again.',
      AppLanguage.romanUrdu: 'PINs match nahi hue. Dobara try karein.',
    },
    'sec_pin_set_success': {
      AppLanguage.english: 'PIN has been successfully set.',
      AppLanguage.romanUrdu: 'PIN kamyabi se set ho gaya hai.',
    },

    // Notification Settings
    'notif_title': {
      AppLanguage.english: 'Notification Settings',
      AppLanguage.romanUrdu: 'Notification Settings',
    },
    'notif_offline_banner': {
      AppLanguage.english: 'All notifications run 100% offline on your device. No cloud or Firebase server required.',
      AppLanguage.romanUrdu: 'Tamam notifications aap ki device par 100% offline chalte hain. Kisi cloud server ki zaroorat nahi.',
    },
    'notif_alert_categories': {
      AppLanguage.english: 'ALERT CATEGORIES',
      AppLanguage.romanUrdu: 'ALERT CATEGORIES',
    },
    'notif_budget_warnings_title': {
      AppLanguage.english: 'Budget Limit Warnings',
      AppLanguage.romanUrdu: 'Budget Limit Warnings',
    },
    'notif_budget_warnings_sub': {
      AppLanguage.english: 'Get notified when spending reaches 90%+ or 100% of category monthly budget limit',
      AppLanguage.romanUrdu: 'Jab kharcha budget ka 90% ya 100% ho jaye to alert hasil karein',
    },
    'notif_khata_reminders_title': {
      AppLanguage.english: 'Khata Repayment Reminders',
      AppLanguage.romanUrdu: 'Khata Repayment Reminders',
    },
    'notif_khata_reminders_sub': {
      AppLanguage.english: 'Receive scheduled alerts for borrowed and lent money due dates',
      AppLanguage.romanUrdu: 'Udhar ki wapsi ki due dates par alerts hasil karein',
    },
    'notif_savings_reminders_title': {
      AppLanguage.english: 'Savings Goal Reminders',
      AppLanguage.romanUrdu: 'Savings Goal Reminders',
    },
    'notif_savings_reminders_sub': {
      AppLanguage.english: 'Get reminded 3 days before a savings target date approaches',
      AppLanguage.romanUrdu: 'Savings goal target date se 3 din pehle reminder hasil karein',
    },

    // About Screen
    'about_title': {
      AppLanguage.english: 'About Apna Batwa',
      AppLanguage.romanUrdu: 'About Apna Batwa',
    },
    'about_version': {
      AppLanguage.english: 'Version',
      AppLanguage.romanUrdu: 'Version',
    },
    'about_developed_by': {
      AppLanguage.english: 'Developed by SN Technologies',
      AppLanguage.romanUrdu: 'Developed by SN Technologies',
    },
    'about_desc_1': {
      AppLanguage.english: 'Apna Batwa is a 100% offline personal finance app designed specifically for students and individuals.',
      AppLanguage.romanUrdu: 'Apna Batwa ek 100% offline personal finance app hai jo khas tor par students aur individuals ke liye design ki gayi hai.',
    },
    'about_desc_2': {
      AppLanguage.english: 'Track daily income and expenses, manage Khata records with WhatsApp reminders, set monthly budgets, and track savings goals with complete privacy — no internet, login, or cloud servers required.',
      AppLanguage.romanUrdu: 'Daily income aur expenses track karein, WhatsApp reminders ke sath Khata manage karein, monthly budgets set karein, aur complete privacy ke sath savings goals track karein.',
    },
    'about_privacy_tagline': {
      AppLanguage.english: '100% Offline & Private • Zero Data Tracking',
      AppLanguage.romanUrdu: '100% Offline & Private • Zero Data Tracking',
    },

    // Backup & Restore
    'backup_title': {
      AppLanguage.english: 'Backup & Restore',
      AppLanguage.romanUrdu: 'Backup & Restore',
    },
    'backup_processing': {
      AppLanguage.english: 'Processing backup operation...',
      AppLanguage.romanUrdu: 'Backup process ho raha hai...',
    },
    'backup_header_title': {
      AppLanguage.english: 'Offline Data Portability',
      AppLanguage.romanUrdu: 'Offline Data Portability',
    },
    'backup_header_sub': {
      AppLanguage.english: 'Keep your financial data safe. Export backups to your device or cloud storage, and restore anytime.',
      AppLanguage.romanUrdu: 'Apna financial data mehfooz rakhein. Backup export karein aur kisi bhi waqt restore karein.',
    },
    'backup_create_title': {
      AppLanguage.english: 'Create Backup',
      AppLanguage.romanUrdu: 'Backup Banayein',
    },
    'backup_create_sub': {
      AppLanguage.english: 'Export all transactions, Khata records, budgets, and savings goals into a JSON file.',
      AppLanguage.romanUrdu: 'Tamam transactions, Khata, budgets aur savings goals ko JSON file mein export karein.',
    },
    'backup_export_btn': {
      AppLanguage.english: 'Export & Share Backup',
      AppLanguage.romanUrdu: 'Backup Export & Share Karein',
    },
    'backup_restore_title': {
      AppLanguage.english: 'Restore Backup',
      AppLanguage.romanUrdu: 'Backup Restore Karein',
    },
    'backup_restore_sub': {
      AppLanguage.english: 'Select an Apna Batwa JSON backup file to overwrite current app data with restored records.',
      AppLanguage.romanUrdu: 'Data restore karne ke liye Apna Batwa JSON backup file select karein.',
    },
    'backup_restore_btn': {
      AppLanguage.english: 'Restore from Backup File',
      AppLanguage.romanUrdu: 'Backup File Se Restore Karein',
    },
    'backup_dialog_restore_confirm_title': {
      AppLanguage.english: 'Restore Backup Data?',
      AppLanguage.romanUrdu: 'Backup Data Restore Karein?',
    },
    'backup_dialog_restore_confirm_msg': {
      AppLanguage.english: 'WARNING: Restoring a backup will erase and replace ALL current app data (income, expenses, khata, wishlist, budgets, savings goals). This cannot be undone.\n\nAre you sure you want to continue?',
      AppLanguage.romanUrdu: 'WARNING: Restore karne se tamam mawjooda data erase ho jaye ga.\n\nKya aap continue karna chahte hain?',
    },
    'backup_erase_restore_btn': {
      AppLanguage.english: 'Erase & Restore',
      AppLanguage.romanUrdu: 'Erase & Restore',
    },

    // Onboarding
    'onboarding_skip': {
      AppLanguage.english: 'Skip',
      AppLanguage.romanUrdu: 'Skip',
    },
    'onboarding_next': {
      AppLanguage.english: 'Next',
      AppLanguage.romanUrdu: 'Next',
    },
    'onboarding_get_started': {
      AppLanguage.english: 'Get Started 🚀',
      AppLanguage.romanUrdu: 'Get Started 🚀',
    },
    'onboarding_1_title': {
      AppLanguage.english: 'Track Your Money',
      AppLanguage.romanUrdu: 'Apni Raqam Ka Track Rakhein',
    },
    'onboarding_1_desc': {
      AppLanguage.english: 'Keep track of all your income, expenses, and current net balance effortlessly in one place.',
      AppLanguage.romanUrdu: 'Apni tamam aamdani, kharchay aur mawjooda balance ka ek hi jagah aasan track rakhein.',
    },
    'onboarding_2_title': {
      AppLanguage.english: 'Never Forget a Loan',
      AppLanguage.romanUrdu: 'Udhar Kabhi Na Bhoolain',
    },
    'onboarding_2_desc': {
      AppLanguage.english: 'Manage Khata records seamlessly — know exactly who owes you and who you owe with WhatsApp reminders.',
      AppLanguage.romanUrdu: 'Khata system asani se manage karein — WhatsApp reminders ke sath jaanein kis ne kitne dene hain.',
    },
    'onboarding_3_title': {
      AppLanguage.english: 'Save For Your Goals',
      AppLanguage.romanUrdu: 'Apne Ahadāf Ke Liye Bachat Karein',
    },
    'onboarding_3_desc': {
      AppLanguage.english: 'Set monthly category budgets and build custom savings goals to stay in full control of your finance.',
      AppLanguage.romanUrdu: 'Monthly category budgets set karein aur apne finances par full control ke liye savings goals banayein.',
    },
    'onboarding_4_title': {
      AppLanguage.english: '100% Offline & Private',
      AppLanguage.romanUrdu: '100% Offline & Private',
    },
    'onboarding_4_desc': {
      AppLanguage.english: 'No internet required, no login accounts, and zero cloud tracking. Your financial data stays strictly on your device.',
      AppLanguage.romanUrdu: 'Kisi internet, login ya cloud tracking ki zaroorat nahi. Aap ka data sirf aap ki device par rehta hai.',
    },

    // What's New
    'whats_new_sub': {
      AppLanguage.english: 'Apna Batwa Feature Update',
      AppLanguage.romanUrdu: 'Apna Batwa Feature Update',
    },
    'whats_new_1_title': {
      AppLanguage.english: 'Advanced Analytics & Insights',
      AppLanguage.romanUrdu: 'Advanced Analytics & Insights',
    },
    'whats_new_1_sub': {
      AppLanguage.english: 'Spending trends, category donut breakdown, day-of-week patterns, savings rate, and predictive moving-average projections.',
      AppLanguage.romanUrdu: 'Kharchon ke trends, category breakdown, weekday patterns, aur savings rate.',
    },
    'whats_new_2_title': {
      AppLanguage.english: 'WhatsApp Reminders for Khata',
      AppLanguage.romanUrdu: 'Khata ke liye WhatsApp Reminders',
    },
    'whats_new_2_sub': {
      AppLanguage.english: 'Send pre-filled payment reminders directly to your contacts via WhatsApp with one tap.',
      AppLanguage.romanUrdu: 'Single tap se apne contacts ko WhatsApp ke zariye repayment reminders bhejein.',
    },
    'whats_new_3_title': {
      AppLanguage.english: 'Dark / Light Mode Toggle',
      AppLanguage.romanUrdu: 'Dark / Light Mode Toggle',
    },
    'whats_new_3_sub': {
      AppLanguage.english: 'Switch seamlessly between Light and Dark themes anytime from the app bar or More screen.',
      AppLanguage.romanUrdu: 'App bar ya More screen se Light aur Dark themes ke darmiyan switch karein.',
    },
    'whats_new_4_title': {
      AppLanguage.english: 'UX Polish & App Improvements',
      AppLanguage.romanUrdu: 'UX Polish & App Improvements',
    },
    'whats_new_4_sub': {
      AppLanguage.english: 'Friendly empty states, app exit confirmation, currency consistency, and dynamic app info.',
      AppLanguage.romanUrdu: 'Friendly empty states, app exit confirmation, aur dynamic app info.',
    },
    'whats_new_got_it': {
      AppLanguage.english: 'Got it! 🎉',
      AppLanguage.romanUrdu: 'Samjh aa gaya! 🎉',
    },

    // Extra Khata Keys
    'khata_whatsapp_not_installed': {
      AppLanguage.english: 'WhatsApp is not installed on this device',
      AppLanguage.romanUrdu: 'Is device par WhatsApp installed nahi hai',
    },
    'khata_remaining_balance': {
      AppLanguage.english: 'Remaining Balance',
      AppLanguage.romanUrdu: 'Baqaya Raqam',
    },
    'khata_total_amount': {
      AppLanguage.english: 'Total Amount',
      AppLanguage.romanUrdu: 'Kul Raqam',
    },
    'khata_paid_so_far': {
      AppLanguage.english: 'Paid So Far',
      AppLanguage.romanUrdu: 'Ab tak ada shuda',
    },
    'khata_manage_people_title': {
      AppLanguage.english: 'Manage People',
      AppLanguage.romanUrdu: 'Manage People',
    },
    'khata_no_people_title': {
      AppLanguage.english: 'No People Added Yet',
      AppLanguage.romanUrdu: 'Abhi tak koi banda add nahi kiya gaya',
    },
    'khata_no_people_sub': {
      AppLanguage.english: 'Add people to track money borrowed or lent.',
      AppLanguage.romanUrdu: 'Udhar ki raqam track karne ke لیے logon ko add karein.',
    },
    'khata_delete_person_title': {
      AppLanguage.english: 'Delete Person',
      AppLanguage.romanUrdu: 'Person Delete Karein',
    },
    'khata_delete_person_active_debt_err': {
      AppLanguage.english: 'Cannot delete person with active debt records.',
      AppLanguage.romanUrdu: 'Active debt records wale person ko delete nahi kiya ja sakta.',
    },

    // Extra Wishlist Keys
    'purchase_modal_add_title': {
      AppLanguage.english: '+ Log Direct Purchase',
      AppLanguage.romanUrdu: '+ Direct Purchase Log Karein',
    },
    'purchase_modal_edit_title': {
      AppLanguage.english: 'Edit Purchase',
      AppLanguage.romanUrdu: 'Purchase Edit Karein',
    },
    'purchase_item_name_label': {
      AppLanguage.english: 'Item / Purchase Name *',
      AppLanguage.romanUrdu: 'Item / Purchase Ka Naam *',
    },
    'purchase_amount_paid_label': {
      AppLanguage.english: 'Amount Paid (Rs.) *',
      AppLanguage.romanUrdu: 'Amount Paid (Rs.) *',
    },
    'purchase_date_label': {
      AppLanguage.english: 'Purchase Date *',
      AppLanguage.romanUrdu: 'Purchase Date *',
    },
    'purchase_notes_label': {
      AppLanguage.english: 'Notes (Optional)',
      AppLanguage.romanUrdu: 'Notes (Optional)',
    },
    'purchase_save_changes': {
      AppLanguage.english: 'Save Changes',
      AppLanguage.romanUrdu: 'Changes Save Karein',
    },
    'purchase_log_btn': {
      AppLanguage.english: 'Log Purchase & Expense',
      AppLanguage.romanUrdu: 'Purchase & Expense Log Karein',
    },
    'wishlist_mark_purchased_title': {
      AppLanguage.english: '🎉 Mark as Purchased',
      AppLanguage.romanUrdu: '🎉 Mark as Purchased',
    },
    'wishlist_actual_price_label': {
      AppLanguage.english: 'Actual Purchase Price (Rs.) *',
      AppLanguage.romanUrdu: 'Actual Purchase Price (Rs.) *',
    },
    'wishlist_confirm_log_expense': {
      AppLanguage.english: 'Confirm & Log Expense',
      AppLanguage.romanUrdu: 'Confirm & Log Expense',
    },
    // Categories
    'cat_food': {
      AppLanguage.english: 'Food',
      AppLanguage.romanUrdu: 'Khorak',
    },
    'cat_transport': {
      AppLanguage.english: 'Transport',
      AppLanguage.romanUrdu: 'Transport',
    },
    'cat_education': {
      AppLanguage.english: 'Education',
      AppLanguage.romanUrdu: 'Taleem',
    },
    'cat_hostel/rent': {
      AppLanguage.english: 'Hostel/Rent',
      AppLanguage.romanUrdu: 'Hostel / Kiraya',
    },
    'cat_mobile/internet': {
      AppLanguage.english: 'Mobile/Internet',
      AppLanguage.romanUrdu: 'Mobile / Internet',
    },
    'cat_shopping': {
      AppLanguage.english: 'Shopping',
      AppLanguage.romanUrdu: 'Shopping',
    },
    'cat_snacks': {
      AppLanguage.english: 'Snacks',
      AppLanguage.romanUrdu: 'Snacks',
    },
    'cat_health': {
      AppLanguage.english: 'Health',
      AppLanguage.romanUrdu: 'Sehat',
    },
    'cat_entertainment': {
      AppLanguage.english: 'Entertainment',
      AppLanguage.romanUrdu: 'Tafreeh',
    },
    'cat_software/subscriptions': {
      AppLanguage.english: 'Software/Subscriptions',
      AppLanguage.romanUrdu: 'Software / Subscriptions',
    },
    'cat_other': {
      AppLanguage.english: 'Other',
      AppLanguage.romanUrdu: 'Digar',
    },
    'cat_home': {
      AppLanguage.english: 'Home',
      AppLanguage.romanUrdu: 'Ghar',
    },
    'cat_pocket_money': {
      AppLanguage.english: 'Pocket Money',
      AppLanguage.romanUrdu: 'Pocket Money',
    },
    'cat_salary': {
      AppLanguage.english: 'Salary',
      AppLanguage.romanUrdu: 'Tankhwah',
    },
    'cat_internship': {
      AppLanguage.english: 'Internship',
      AppLanguage.romanUrdu: 'Internship',
    },
    'cat_freelancing': {
      AppLanguage.english: 'Freelancing',
      AppLanguage.romanUrdu: 'Freelancing',
    },
    'cat_scholarship': {
      AppLanguage.english: 'Scholarship',
      AppLanguage.romanUrdu: 'Scholarship',
    },
    'cat_gift': {
      AppLanguage.english: 'Gift',
      AppLanguage.romanUrdu: 'Tuhfa',
    },
    'cat_general': {
      AppLanguage.english: 'General',
      AppLanguage.romanUrdu: 'General',
    },
    'cat_uncategorized': {
      AppLanguage.english: 'Uncategorized',
      AppLanguage.romanUrdu: 'Baghair Category',
    },

    // Payment Methods
    'pay_cash': {
      AppLanguage.english: 'Cash',
      AppLanguage.romanUrdu: 'Naqad (Cash)',
    },
    'pay_easypaisa': {
      AppLanguage.english: 'Easypaisa',
      AppLanguage.romanUrdu: 'Easypaisa',
    },
    'pay_jazzcash': {
      AppLanguage.english: 'JazzCash',
      AppLanguage.romanUrdu: 'JazzCash',
    },
    'pay_bank_transfer': {
      AppLanguage.english: 'Bank Transfer',
      AppLanguage.romanUrdu: 'Bank Transfer',
    },
    'pay_card': {
      AppLanguage.english: 'Card',
      AppLanguage.romanUrdu: 'Card',
    },
    'pay_wishlist': {
      AppLanguage.english: 'Wishlist',
      AppLanguage.romanUrdu: 'Wishlist',
    },
    'pay_direct_purchase': {
      AppLanguage.english: 'Direct Purchase',
      AppLanguage.romanUrdu: 'Direct Purchase',
    },
    'pay_other': {
      AppLanguage.english: 'Other',
      AppLanguage.romanUrdu: 'Digar',
    },

    // Weekday Names
    'day_mon_short': {
      AppLanguage.english: 'Mon',
      AppLanguage.romanUrdu: 'Peer',
    },
    'day_tue_short': {
      AppLanguage.english: 'Tue',
      AppLanguage.romanUrdu: 'Mangal',
    },
    'day_wed_short': {
      AppLanguage.english: 'Wed',
      AppLanguage.romanUrdu: 'Budh',
    },
    'day_thu_short': {
      AppLanguage.english: 'Thu',
      AppLanguage.romanUrdu: 'Jummarat',
    },
    'day_fri_short': {
      AppLanguage.english: 'Fri',
      AppLanguage.romanUrdu: 'Jumma',
    },
    'day_sat_short': {
      AppLanguage.english: 'Sat',
      AppLanguage.romanUrdu: 'Hafta',
    },
    'day_sun_short': {
      AppLanguage.english: 'Sun',
      AppLanguage.romanUrdu: 'Itwar',
    },
    'day_mon_full': {
      AppLanguage.english: 'Monday',
      AppLanguage.romanUrdu: 'Peer',
    },
    'day_tue_full': {
      AppLanguage.english: 'Tuesday',
      AppLanguage.romanUrdu: 'Mangal',
    },
    'day_wed_full': {
      AppLanguage.english: 'Wednesday',
      AppLanguage.romanUrdu: 'Budh',
    },
    'day_thu_full': {
      AppLanguage.english: 'Thursday',
      AppLanguage.romanUrdu: 'Jummarat',
    },
    'day_fri_full': {
      AppLanguage.english: 'Friday',
      AppLanguage.romanUrdu: 'Jumma',
    },
    'day_sat_full': {
      AppLanguage.english: 'Saturday',
      AppLanguage.romanUrdu: 'Hafta',
    },
    'day_sun_full': {
      AppLanguage.english: 'Sunday',
      AppLanguage.romanUrdu: 'Itwar',
    },

    // Month Names

    // Additional Reports / Trends Callouts
    'freq_daily': {
      AppLanguage.english: 'Daily',
      AppLanguage.romanUrdu: 'Rozana',
    },
    'freq_weekly': {
      AppLanguage.english: 'Weekly',
      AppLanguage.romanUrdu: 'Haftewar',
    },
    'freq_monthly': {
      AppLanguage.english: 'Monthly',
      AppLanguage.romanUrdu: 'Mahana',
    },
    'reports_no_prev_month_data': {
      AppLanguage.english: 'No data from previous month',
      AppLanguage.romanUrdu: 'Pichle mahine ka koi data nahi hai',
    },
    'reports_same_as_last_month': {
      AppLanguage.english: 'Same as last month',
      AppLanguage.romanUrdu: 'Pichle mahine ke barabar',
    },
    'reports_first_month_data': {
      AppLanguage.english: 'First month of expense data',
      AppLanguage.romanUrdu: 'Kharchon ke data ka pehla mahina',
    },
    'reports_khata_analytics_sub': {
      AppLanguage.english: 'Overall borrowing, lending, and contact activity',
      AppLanguage.romanUrdu: 'Udhaar, len den, aur contacts ki activity',
    },
    'reports_net_khata_pos': {
      AppLanguage.english: 'Net Position',
      AppLanguage.romanUrdu: 'Net Position',
    },
    'common_show_all': {
      AppLanguage.english: 'Show All',
      AppLanguage.romanUrdu: 'Sab Dekhein',
    },
    'app_powered_by': {
      AppLanguage.english: 'Powered by SN Technologies',
      AppLanguage.romanUrdu: 'Powered by SN Technologies',
    },

    // Month short names (for charts & analytics)
    'month_jan': {AppLanguage.english: 'Jan', AppLanguage.romanUrdu: 'Jan'},
    'month_feb': {AppLanguage.english: 'Feb', AppLanguage.romanUrdu: 'Feb'},
    'month_mar': {AppLanguage.english: 'Mar', AppLanguage.romanUrdu: 'Mar'},
    'month_apr': {AppLanguage.english: 'Apr', AppLanguage.romanUrdu: 'Apr'},
    'month_may': {AppLanguage.english: 'May', AppLanguage.romanUrdu: 'May'},
    'month_jun': {AppLanguage.english: 'Jun', AppLanguage.romanUrdu: 'Jun'},
    'month_jul': {AppLanguage.english: 'Jul', AppLanguage.romanUrdu: 'Jul'},
    'month_aug': {AppLanguage.english: 'Aug', AppLanguage.romanUrdu: 'Aug'},
    'month_sep': {AppLanguage.english: 'Sep', AppLanguage.romanUrdu: 'Sep'},
    'month_oct': {AppLanguage.english: 'Oct', AppLanguage.romanUrdu: 'Oct'},
    'month_nov': {AppLanguage.english: 'Nov', AppLanguage.romanUrdu: 'Nov'},
    'month_dec': {AppLanguage.english: 'Dec', AppLanguage.romanUrdu: 'Dec'},

    // Onboarding aliases
    'onboarding_p1_title': {AppLanguage.english: 'Welcome to Apna Batwa', AppLanguage.romanUrdu: 'Apna Batwa Mein Khush Aamdeed'},
    'onboarding_p1_desc': {AppLanguage.english: 'Your personal finance manager built specifically for students. Track income, expenses, and savings with ease.', AppLanguage.romanUrdu: 'Aapka zaati finance manager jo khaas taur par students ke liye banaya gaya hai. Aamdani, kharchay aur savings aasani se track karein.'},
    'onboarding_p2_title': {AppLanguage.english: 'Smart Khata & Udhaar', AppLanguage.romanUrdu: 'Smart Khata aur Udhaar'},
    'onboarding_p2_desc': {AppLanguage.english: 'Never forget who owes you or who you owe money to. Keep clear records of all borrowing and lending.', AppLanguage.romanUrdu: 'Kabhie mat bhoolain k kis se kitne paise lene hain ya dene hain. Udhaar aur len den ka saaf hisab rakhein.'},
    'onboarding_p3_title': {AppLanguage.english: 'Budgets & Savings Goals', AppLanguage.romanUrdu: 'Budgets aur Savings Goals'},
    'onboarding_p3_desc': {AppLanguage.english: 'Set category budgets and plan for upcoming purchases with interactive savings goals.', AppLanguage.romanUrdu: 'Category wise budget set karein aur apni khwahishat ke liye aamdani se bachat karein.'},
    'onboarding_p4_title': {AppLanguage.english: 'Private & Secure', AppLanguage.romanUrdu: 'Private aur Safe'},
    'onboarding_p4_desc': {AppLanguage.english: 'All your financial data stays safely on your device. Protect your app with biometric or PIN lock.', AppLanguage.romanUrdu: 'Aapka tamam data aapke mobile mein safe rehta hai. PIN lock ya fingerprint se app secure karein.'},

    // About screen
    'about_desc_p1': {AppLanguage.english: 'Apna Batwa is a student-focused personal finance app designed to help you track expenses, manage budgets, keep track of Khata (borrowing & lending), and save money easily.', AppLanguage.romanUrdu: 'Apna Batwa ek student-focused finance app hai jo aapke kharchon, budgets, Khata aur savings ko aasan banata hai.'},
    'about_desc_p2': {AppLanguage.english: 'Built with privacy in mind. All your financial data is stored locally on your device.', AppLanguage.romanUrdu: 'Privacy ke saath banaya gaya hai. Aapka tamam data aapke mobile mein safe rehta hai.'},
    'about_developer': {AppLanguage.english: 'Developer', AppLanguage.romanUrdu: 'Developer'},

    // Backup & Restore
    'backup_create_btn': {AppLanguage.english: 'Create Backup', AppLanguage.romanUrdu: 'Backup Banayein'},
    'backup_erase_confirm_btn': {AppLanguage.english: 'Yes, Erase All', AppLanguage.romanUrdu: 'Haan, Sab Khatam Karein'},
    'backup_restore_dialog_msg': {AppLanguage.english: 'Are you sure you want to restore data from this backup file? Existing data will be merged/updated.', AppLanguage.romanUrdu: 'Kya aap is backup file se data restore karna chahte hain?'},
    'backup_restore_dialog_title': {AppLanguage.english: 'Restore Backup', AppLanguage.romanUrdu: 'Backup Restore Karein'},
    'common_ok': {AppLanguage.english: 'OK', AppLanguage.romanUrdu: 'OK'},

    // Khata dialogs & persons
    'khata_add_person_btn': {AppLanguage.english: 'Add Person', AppLanguage.romanUrdu: 'Banda Shamil Karein'},
    'khata_delete_entry_title': {AppLanguage.english: 'Delete Record', AppLanguage.romanUrdu: 'Record Delete Karein'},
    'khata_delete_entry_msg': {AppLanguage.english: 'Are you sure you want to delete this Khata record?', AppLanguage.romanUrdu: 'Kya aap yeh Khata record delete karna chahte hain?'},
    'khata_delete_person_msg': {AppLanguage.english: 'Are you sure you want to remove this contact?', AppLanguage.romanUrdu: 'Kya aap is bande ko list se hatana chahte hain?'},
    'khata_delete_person_error': {AppLanguage.english: 'Cannot delete person with active balance records.', AppLanguage.romanUrdu: 'Active balance wale bande ko delete nahi kiya ja sakta.'},

    // Notification settings
    'notif_budget_warnings': {AppLanguage.english: 'Budget Warnings', AppLanguage.romanUrdu: 'Budget Warnings'},
    'notif_khata_reminders': {AppLanguage.english: 'Khata Reminders', AppLanguage.romanUrdu: 'Khata Reminders'},
    'notif_savings_reminders': {AppLanguage.english: 'Savings Goal Reminders', AppLanguage.romanUrdu: 'Savings Reminders'},

    // PIN lock & security
    'pin_removed_snackbar': {AppLanguage.english: 'PIN lock removed successfully', AppLanguage.romanUrdu: 'PIN lock khatam ho gaya'},
    'pin_reset_title': {AppLanguage.english: 'Forgot PIN?', AppLanguage.romanUrdu: 'PIN Bhool Gaye?'},
    'pin_reset_msg': {AppLanguage.english: 'To reset your PIN, please re-authenticate using your device biometrics or master credentials.', AppLanguage.romanUrdu: 'PIN reset karne ke liye biometrics se verify karein.'},
    'pin_reset_unlock_btn': {AppLanguage.english: 'Reset & Unlock', AppLanguage.romanUrdu: 'Reset & Unlock'},

    // Purchase modals
    'purchase_amount_label': {AppLanguage.english: 'Amount Paid', AppLanguage.romanUrdu: 'Adaya Karda Raqam'},
    'purchase_modal_log_title': {AppLanguage.english: 'Log Purchase', AppLanguage.romanUrdu: 'Kharidari Indraj'},
    'purchase_name_label': {AppLanguage.english: 'Item Name', AppLanguage.romanUrdu: 'Item Ka Naam'},

    // Security screen
    'sec_biometrics': {AppLanguage.english: 'Biometric Unlock', AppLanguage.romanUrdu: 'Fingerprint / Face Unlock'},
    'sec_create_pin_sub': {AppLanguage.english: 'Set a 4-digit security PIN', AppLanguage.romanUrdu: '4-digit security PIN set karein'},
    'sec_enter_pin_prompt': {AppLanguage.english: 'Enter your 4-digit PIN', AppLanguage.romanUrdu: 'Apna 4-digit PIN darj karein'},
    'sec_set_pin': {AppLanguage.english: 'App PIN Lock', AppLanguage.romanUrdu: 'App PIN Lock'},
    'sec_status_disabled': {AppLanguage.english: 'Disabled', AppLanguage.romanUrdu: 'Disabled'},
    'sec_status_enabled': {AppLanguage.english: 'Enabled', AppLanguage.romanUrdu: 'Enabled'},

    // Recurring & transactions
    'tab_expenses': {AppLanguage.english: 'Expenses', AppLanguage.romanUrdu: 'Kharchay'},
    'tab_income': {AppLanguage.english: 'Income', AppLanguage.romanUrdu: 'Aamdani'},
    'transactions_filter_category': {AppLanguage.english: 'Category', AppLanguage.romanUrdu: 'Category'},

    // What's new modal
    'whats_new_title': {AppLanguage.english: "What's New in", AppLanguage.romanUrdu: 'Naye Features in'},
    'whats_new_subtitle': {AppLanguage.english: 'Here are the latest updates and improvements in Apna Batwa.', AppLanguage.romanUrdu: 'Apna Batwa ki taza tareen updates aur behtari.'},

    // Wishlist modals & screen
    'wishlist_confirm_purchased_btn': {AppLanguage.english: 'Mark as Purchased', AppLanguage.romanUrdu: 'Kharid Liya Mark Karein'},
    'wishlist_modal_mark_purchased': {AppLanguage.english: 'Mark Item as Purchased', AppLanguage.romanUrdu: 'Item Kharida Hua Mark Karein'},
    'wishlist_tab_active': {AppLanguage.english: 'Wishlist', AppLanguage.romanUrdu: 'Wishlist'},
    'wishlist_tab_purchased': {AppLanguage.english: 'Purchase History', AppLanguage.romanUrdu: 'Kharidari History'},
  };

  static String tr(String key, AppLanguage lang) {
    final keyMap = _translations[key];
    if (keyMap == null) return key;
    return keyMap[lang] ?? keyMap[AppLanguage.english] ?? key;
  }

  // Category & Payment Helpers
  static String translateCategory(String? categoryName, AppLanguage lang) {
    if (categoryName == null || categoryName.trim().isEmpty) {
      return tr('cat_uncategorized', lang);
    }
    final key = 'cat_${categoryName.trim().toLowerCase()}';
    if (_translations.containsKey(key)) {
      return tr(key, lang);
    }
    return categoryName;
  }

  static String translatePaymentMethod(String? paymentMethod, AppLanguage lang) {
    if (paymentMethod == null || paymentMethod.trim().isEmpty) return '';
    final key = 'pay_${paymentMethod.trim().toLowerCase().replaceAll(' ', '_')}';
    if (_translations.containsKey(key)) {
      return tr(key, lang);
    }
    return paymentMethod;
  }

  static String translateWeekdayShort(int index, AppLanguage lang) {
    const keys = [
      'day_mon_short',
      'day_tue_short',
      'day_wed_short',
      'day_thu_short',
      'day_fri_short',
      'day_sat_short',
      'day_sun_short',
    ];
    if (index >= 0 && index < keys.length) {
      return tr(keys[index], lang);
    }
    return '';
  }

  static String translateWeekdayFull(int index, AppLanguage lang) {
    const keys = [
      'day_mon_full',
      'day_tue_full',
      'day_wed_full',
      'day_thu_full',
      'day_fri_full',
      'day_sat_full',
      'day_sun_full',
    ];
    if (index >= 0 && index < keys.length) {
      return tr(keys[index], lang);
    }
    return '';
  }

  static String translateWeekdayName(String dayName, AppLanguage lang) {
    final lower = dayName.toLowerCase().trim();
    if (lower.startsWith('mon')) return tr('day_mon_full', lang);
    if (lower.startsWith('tue')) return tr('day_tue_full', lang);
    if (lower.startsWith('wed')) return tr('day_wed_full', lang);
    if (lower.startsWith('thu')) return tr('day_thu_full', lang);
    if (lower.startsWith('fri')) return tr('day_fri_full', lang);
    if (lower.startsWith('sat')) return tr('day_sat_full', lang);
    if (lower.startsWith('sun')) return tr('day_sun_full', lang);
    return dayName;
  }

  static String translateMonthShort(int month, AppLanguage lang) {
    const keys = [
      'month_jan',
      'month_feb',
      'month_mar',
      'month_apr',
      'month_may',
      'month_jun',
      'month_jul',
      'month_aug',
      'month_sep',
      'month_oct',
      'month_nov',
      'month_dec',
    ];
    if (month >= 1 && month <= 12) {
      return tr(keys[month - 1], lang);
    }
    return '';
  }

  static String spendingTrendCallout(AppLanguage lang, double pctChange, bool isIncreased, bool hasPrevData, bool hasCurrentData) {
    if (!hasPrevData && !hasCurrentData) {
      return tr('reports_no_prev_month_data', lang);
    }
    if (!hasPrevData && hasCurrentData) {
      return tr('reports_first_month_data', lang);
    }
    final pctStr = pctChange.abs().toStringAsFixed(1);
    if (pctChange > 0) {
      if (lang == AppLanguage.romanUrdu) {
        return 'Pichle mahine se $pctStr% ziyada';
      }
      return '$pctStr% more than last month';
    } else if (pctChange < 0) {
      if (lang == AppLanguage.romanUrdu) {
        return 'Pichle mahine se $pctStr% kam';
      }
      return '$pctStr% less than last month';
    } else {
      return tr('reports_same_as_last_month', lang);
    }
  }

  // Dynamic Sentence Translators
  static String predictiveInsightSentence(AppLanguage lang, String formattedAmount) {
    if (lang == AppLanguage.romanUrdu) {
      return 'Aapke haalia kharchay ke mutabiq, is mahine aapka kul kharcha takreeban $formattedAmount hoga.';
    }
    return "Based on your recent spending, you're on track to spend around $formattedAmount this month.";
  }

  static String highestCategorySentence(AppLanguage lang, String category, String percentage, String amount) {
    final localizedCat = translateCategory(category, lang);
    if (lang == AppLanguage.romanUrdu) {
      return 'Is dauran aapka sab se ziyada kharcha $localizedCat category mein $percentage% ($amount) hua hai.';
    }
    return 'Your highest spending category for this period is $localizedCat at $percentage% ($amount).';
  }

  static String weekdayPatternSentence(AppLanguage lang, String dayName, String amount) {
    final localizedDay = translateWeekdayName(dayName, lang);
    if (lang == AppLanguage.romanUrdu) {
      return 'Aapka sab se ziyada kharcha $localizedDay ko hota hai ($amount total).';
    }
    return 'You tend to spend most on ${dayName}s ($amount total).';
  }

  static String savingsRateSentence(AppLanguage lang, double rate) {
    final absRate = rate.abs().toStringAsFixed(0);
    if (rate >= 0) {
      if (lang == AppLanguage.romanUrdu) {
        return 'Aap ne is period ke dauran apni aamdani ka $absRate% bachaya hai.';
      }
      return 'You saved $absRate% of your income this period.';
    } else {
      if (lang == AppLanguage.romanUrdu) {
        return 'Is period mein aap ke kharchay aamdani se $absRate% ziyada thay.';
      }
      return 'Your expenses exceeded income by $absRate% this period.';
    }
  }
}

final translationsProvider = Provider<String Function(String)>((ref) {
  final lang = ref.watch(appLanguageProvider);
  return (String key) => AppTranslations.tr(key, lang);
});
