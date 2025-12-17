
class ApiConstants {
  // 10.0.2.2 is for Emulator. For Physical Device, use your LAN IP.
  static const String baseUrl = 'http://192.168.88.46:8000/api';
  
  // Endpoints
  static const String login = '/login';
  static const String register = '/register';
  static const String tutors = '/tutors';
  static const String questions = '/questions';
  static const String bookings = '/bookings';
  static const String transactions = '/transactions';
  static const String classes = '/classes';
  static const String groups = '/groups';
}
