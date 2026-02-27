import 'dart:io';

import 'package:flutter/foundation.dart';

class ApiEndpoints {
  ApiEndpoints._();

  static const bool isPhysicalDevice = false;

  static const String compIpAddress = "192.168.1.1";

  // Base URL 
  // static const String baseUrl = 'http://10.0.2.2:5050/api/';
  // //static const String baseUrl = 'http://localhost:3000/api/v1';
  // // For Android Emulator use: 'http://10.0.2.2:3000/api/v1'
  // // For iOS Simulator use: 'http://localhost:5000/api/v1'
  // // For Physical Device use your computer's IP: 'http://192.168.x.x:5000/api/v1'

  static String get baseUrl{
    if(isPhysicalDevice) {
      return 'http://$compIpAddress:5050/api/';
    }
    // android
    if(kIsWeb){
      return 'http://localhost:5050/api/';
    } else if  (Platform.isAndroid){
      return 'http://10.0.2.2:5050/api/';
    }else if (Platform.isIOS){
      return 'http://localhost:5050/api/';
    } else {
      return 'http://localhost:5050/api/';
    }
  }

  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

    // ================= Auth Endpoints =================
  static const String auth = 'auth';
  static const String register = 'auth/register';
  static const String login = 'auth/login';

  // ================= Profile Endpoints =================
  static const String whoami = 'auth/whoami';
  static const String updateProfile = 'auth/update-profile';

  // ================= Provider Endpoints =================
  static const String getAllProviders = 'provider';            // GET /api/provider?page=1&size=12&categoryId=...
  static const String getProviderById = 'provider';           // GET /api/provider/:id

  // ================= Booking Endpoints =================
  static const String createBooking = 'bookings';
  static const String myBookings = 'bookings/mybooking';
  static const String providerBookings = 'bookings/provider';
  static String bookingStatus(String id) => 'bookings/$id/status';
  static String cancelBooking(String id) => 'bookings/$id/cancel';
  static String bookingById(String id) => 'bookings/$id';

  // ================= Chat Endpoints =================
static const String sendMessage = 'chat';                          // POST /api/chat
static String getMessages(String bookingId) => 'chat/$bookingId'; // GET  /api/chat/:bookingId
static String markAsRead(String bookingId) => 'chat/$bookingId/read';   // PATCH
static String unreadCount(String bookingId) => 'chat/$bookingId/unread'; // GET
}
