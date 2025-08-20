// App-wide constants for easy maintenance and global changes

class AppConstants {
  // Database related constants
  static const String DATABASE_NAME = 'expenser.db';
  static const int DATABASE_VERSION = 1;
  
  // Table names
  static const String TABLE_USER = 'user';
  static const String TABLE_USER_DATA = 'user_data';
  static const String TABLE_SPLIT_ON = 'split_on';
  static const String TABLE_FRIENDS_DATA = 'friends_data';
  
  // Column names
  static const String COL_MOBILE_NUMBER = 'mobile_number';
  static const String COL_FULL_NAME = 'full_name';
  static const String COL_PROFILE_PICTURE = 'profile_picture';
  static const String COL_UPI_ID = 'upi_id';
  static const String COL_USER_CREATION = 'user_creation';
  static const String COL_LAST_LOGIN = 'last_login';
  static const String COL_TO_GET = 'to_get';
  static const String COL_TO_PAY = 'to_pay';
  static const String COL_ID = 'id';
  static const String COL_TYPE = 'type';
  static const String COL_AMOUNT = 'amount';
  static const String COL_SPLIT_BY = 'split_by';
  static const String COL_SPLIT_TIME = 'split_time';
  static const String COL_STATUS = 'status';
  static const String COL_PAID_TIME = 'paid_time';
  static const String COL_USER_DATA_ID = 'user_data_id';
  static const String COL_MOBILE_NO = 'mobile_no';
  
  // Data types
  static const String TYPE_0 = 'type_0'; // Unpaid expenses
  static const String TYPE_1 = 'type_1'; // Split by me
  
  // Status values
  static const String STATUS_PAID = 'paid';
  static const String STATUS_UNPAID = 'unpaid';
  
  // Split ID prefix
  static const String SPLIT_ID_PREFIX = 'split_';
  
  // UI Constants
  static const double DEFAULT_BORDER_RADIUS = 12.0;
  static const double SMALL_BORDER_RADIUS = 8.0;
  static const double LARGE_BORDER_RADIUS = 25.0;
  static const double DEFAULT_PADDING = 16.0;
  static const double SMALL_PADDING = 8.0;
  static const double LARGE_PADDING = 24.0;
  
  // Avatar sizes
  static const double AVATAR_SMALL = 20.0;
  static const double AVATAR_MEDIUM = 25.0;
  static const double AVATAR_LARGE = 100.0;
  
  // Icon sizes
  static const double ICON_SMALL = 16.0;
  static const double ICON_MEDIUM = 20.0;
  static const double ICON_LARGE = 24.0;
  static const double ICON_XLARGE = 28.0;
  
  // Font sizes
  static const double FONT_SMALL = 12.0;
  static const double FONT_MEDIUM = 14.0;
  static const double FONT_LARGE = 16.0;
  static const double FONT_XLARGE = 18.0;
  static const double FONT_XXLARGE = 20.0;
  static const double FONT_AMOUNT = 24.0;
  static const double FONT_TITLE = 42.0;
  
  // Colors
  static const int PRIMARY_COLOR = 0xFF29B6F6;
  static const int SUCCESS_COLOR = 0xFF4CAF50;
  static const int ERROR_COLOR = 0xFFF44336;
  static const int WARNING_COLOR = 0xFFFF9800;
  static const int INFO_COLOR = 0xFF2196F3;
  
  // Animation durations
  static const int ANIMATION_FAST = 200;
  static const int ANIMATION_MEDIUM = 300;
  static const int ANIMATION_SLOW = 500;
  
  // Validation constants
  static const double AMOUNT_TOLERANCE = 0.01;
  static const int MAX_ID_GENERATION_ATTEMPTS = 10;
  static const int ID_GENERATION_DELAY = 10;
  
  // Default values
  static const String DEFAULT_USER_NAME = 'Unknown User';
  static const String DEFAULT_UPI_ID = 'Not set';
  static const String DEFAULT_MOBILE = 'N/A';
  static const String DEFAULT_EMPTY_MESSAGE = 'No data available';
  
  // Asset paths
  static const String ASSET_BILL_LOGO = 'assets/billLogo.png';
  static const String ASSET_PROFILE_PIC = 'assets/profilepic.png';
  static const String ASSET_NULL_IMAGE = 'assets/null.jpg';
  static const String ASSET_IMAGE_5 = 'assets/image 5.png';
  
  // Error messages
  static const String ERROR_LOADING_DATA = 'Error loading data';
  static const String ERROR_SAVING_DATA = 'Error saving data';
  static const String ERROR_USER_NOT_LOGGED_IN = 'User not logged in';
  static const String ERROR_INVALID_AMOUNT = 'Invalid amount';
  static const String ERROR_NO_FRIENDS_SELECTED = 'Please select at least one friend';
  static const String ERROR_AMOUNT_MISMATCH = 'Total amount must equal the original amount';
  
  // Success messages
  static const String SUCCESS_SPLIT_SAVED = 'Split saved successfully!';
  static const String SUCCESS_LINK_COPIED = 'Link copied to clipboard!';
  static const String SUCCESS_FRIEND_REQUEST_SENT = 'Friend request sent';
  
  // Button texts
  static const String BUTTON_NEXT = 'Next';
  static const String BUTTON_SPLIT_EXPENSE = 'Split an expense';
  static const String BUTTON_COPY_LINK = 'Copy Link';
  static const String BUTTON_SHARE = 'Share';
  static const String BUTTON_ADD = 'Add';
  static const String BUTTON_CLEAR_ALL = 'Clear All';
  static const String BUTTON_LOGOUT = 'Logout';
  static const String BUTTON_REFRESH = 'Refresh';
  
  // Tab texts
  static const String TAB_SPLIT_EVENLY = 'Split Evenly';
  static const String TAB_SPLIT_BY_AMOUNTS = 'Split by Amounts';
  static const String TAB_SPLIT_BY_SHARES = 'Split by Shares';
  
  // Label texts
  static const String LABEL_OWED_TO_ME = 'Owed to Me';
  static const String LABEL_OWED_BY_ME = 'Owed by Me';
  static const String LABEL_FRIENDS_SELECTED = 'friends selected';
  static const String LABEL_PULL_TO_REFRESH = 'Pull up to refresh';
  static const String LABEL_NO_SPLIT_EXPENSES = 'No split expenses';
  static const String LABEL_CREATE_FIRST_SPLIT = 'Create your first split expense to get started';
  static const String LABEL_NO_FRIENDS_FOUND = 'No friends found';
  static const String LABEL_ADD_FRIENDS_TO_SPLIT = 'Add friends to split expenses with them';
  static const String LABEL_LOADING_PROFILE = 'Loading Profile...';
  static const String LABEL_WAIT_LOADING_PROFILE = 'Please wait while we load your profile information.';
  
  // Currency
  static const String CURRENCY_SYMBOL = '₹';
  static const String CURRENCY_FORMAT = '₹ {amount}';
  
  // Time formats
  static const String TIME_FORMAT_12HOUR = 'h:mm a';
  static const String DATE_FORMAT_DDMMYY = 'dd/MM/yy';
  static const String TIMESTAMP_FORMAT = 'h:mm a dd/MM/yy';
  
  // Share link
  static const String SHARE_BASE_URL = 'https://expenser.app/invite/';
  static const String SHARE_TEXT_TEMPLATE = 'Check out this awesome expense sharing app! Join me using this link: {link}';
  
  // Notification texts
  static const String NOTIFICATION_CONTACTS_PERMISSION = 'Contacts permission is required to add friends';
  static const String NOTIFICATION_NO_CONTACTS = 'No contacts found';
  static const String NOTIFICATION_COPY_FAILED = 'Failed to copy link';
  
  // Dialog texts
  static const String DIALOG_CONFIRM_LOGOUT_TITLE = 'Confirm Logout';
  static const String DIALOG_CONFIRM_LOGOUT_CONTENT = 'Are you sure you want to logout?';
  static const String DIALOG_INVITE_FRIENDS_TITLE = 'Invite Friends';
  static const String DIALOG_ADD_FRIENDS_TITLE = 'Add friends from your contacts';
  
  // Search hints
  static const String SEARCH_CONTACTS_HINT = 'Search in contacts';
  
  // Profile texts
  static const String PROFILE_TITLE = 'Profile';
  static const String PROFILE_INVITE_FRIENDS = 'Invite friends to use the app';
  static const String PROFILE_ADD_FRIENDS = 'Add your friends';
  
  // Expenses texts
  static const String EXPENSES_TITLE = 'Expenses';
  static const String EXPENSES_OWED_TO_ME = 'Owed to Me';
  static const String EXPENSES_OWED_BY_ME = 'Owed by Me';
  
  // Split texts
  static const String SPLIT_REQUEST = 'Split request';
  static const String SPLIT_PAID_COUNT = '{paidCount} of {totalCount} paid';
  static const String SPLIT_REMAINING_AMOUNT = '₹ {amount} left';
  static const String SPLIT_AMOUNT_TITLE = 'Split Amount';
} 