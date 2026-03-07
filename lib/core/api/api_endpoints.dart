import 'dart:io';

import 'package:flutter/foundation.dart';

class ApiEndpoints {
  ApiEndpoints._();

  static const bool isPhysicalDevice = true;

  static const String compIpAddress = "192.168.1.76";

  static String get baseUrl {
    if (isPhysicalDevice) return 'http://$compIpAddress:5050/api/';
    if (kIsWeb) return 'http://localhost:5050/api/';
    if (Platform.isAndroid) return 'http://10.0.2.2:5050/api/';
    if (Platform.isIOS) return 'http://localhost:5050/api/';
    return 'http://localhost:5050/api/';
  }

  static String get mediaBaseUrl {
    if (isPhysicalDevice) return 'http://$compIpAddress:5050';
    if (kIsWeb) return 'http://localhost:5050';
    if (Platform.isAndroid) return 'http://10.0.2.2:5050';
    if (Platform.isIOS) return 'http://localhost:5050';
    return 'http://localhost:5050';
  }

  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // ================= Auth Endpoints =================
  static const String auth = 'auth';
  static const String register = 'auth/register';
  static const String login = 'auth/login';
  static const String googleAuth = '/auth/google';
  static const String sendResetPasswordEmail = '/auth/send-reset-password-email';
  static const String resetPassword = '/auth/reset-password';
  static const String changePassword = '/auth/change-password';
  static const String googleTokenLogin = 'auth/google/token';

  // ================= Profile Endpoints =================
  static const String whoami = 'auth/whoami';
  static const String updateProfile = 'auth/update-profile';

  // ================= Provider Endpoints =================
  static const String getAllProviders = 'provider';
  static const String getProviderById = 'provider';

  // ================= Booking Endpoints =================
  static const String createBooking = 'bookings';
  static const String myBookings = 'bookings/mybooking';
  static const String providerBookings = 'bookings/provider';
  static String bookingStatus(String id) => 'bookings/$id/status';
  static String cancelBooking(String id) => 'bookings/$id/cancel';
  static String bookingById(String id) => 'bookings/$id';
  static String rateProvider(String id) => 'provider/rate/$id';

  // ================= Chat Endpoints =================
  static const String sendMessage = 'chat';
  static String getMessages(String bookingId) => 'chat/$bookingId';
  static String markAsRead(String bookingId) => 'chat/$bookingId/read';
  static String unreadCount(String bookingId) => 'chat/$bookingId/unread';
}