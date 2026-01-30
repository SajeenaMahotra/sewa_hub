import 'dart:async';
import 'dart:ui';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sewa_hub/core/error/failures.dart';
import 'package:sewa_hub/features/auth/domain/usecases/login_usecase.dart';
import 'package:sewa_hub/features/auth/domain/usecases/register_usecase.dart';
import 'package:sewa_hub/features/auth/presentation/pages/signup_page.dart';

// Mock classes
class MockLoginUsecase extends Mock implements LoginUsecase {}
class MockRegisterUsecase extends Mock implements RegisterUsecase {}

void main() {
  late MockLoginUsecase mockLoginUsecase;
  late MockRegisterUsecase mockRegisterUsecase;

  setUpAll(() {
    registerFallbackValue(
      const LoginUsecaseParam(
        email: 'fallback@email.com',
        password: 'fallback',
      ),
    );
    registerFallbackValue(
      const RegisterUsecaseParam(
        fullName: 'fallback',
        email: 'fallback@email.com',
        password: 'fallback',
      ),
    );
  });

  setUp(() {
    mockLoginUsecase = MockLoginUsecase();
    mockRegisterUsecase = MockRegisterUsecase();
  });

  Widget createTestWidget() {
    return ProviderScope(
      overrides: [
        loginUsecaseProvider.overrideWithValue(mockLoginUsecase),
        registerUsecaseProvider.overrideWithValue(mockRegisterUsecase),
      ],
      child: MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(
            size: Size(800, 1200),
          ),
          child: const SignupScreen(),
        ),
      ),
    );
  }

  group('SignupScreen UI Elements', () {
    testWidgets('should display welcome text', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Create Your Account'), findsOneWidget);
      expect(
        find.text('Sign up to access reliable services anytime, anywhere.'),
        findsOneWidget,
      );
    });

    testWidgets('should display all field labels', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Full Name'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Confirm Password'), findsOneWidget);
    });

    testWidgets('should display sign up button', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Sign Up'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('should display four text form fields', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.byType(TextFormField), findsNWidgets(4));
    });

    testWidgets('should display login link text', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Already have an account? '), findsOneWidget);
      expect(find.text('Login'), findsOneWidget);
    });

    testWidgets('should display OR text', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Or continue with'), findsOneWidget);
    });

    testWidgets('should display terms and conditions text', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(
        find.text(
          'By signing up, you agree to our Terms and Conditions and Privacy Policy.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('should display hint texts', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('johndoe@gmail.com'), findsOneWidget);
      expect(find.text('********'), findsNWidgets(2)); // Password fields
    });

    testWidgets('should display logo image', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.byType(Image), findsWidgets);
    });

    testWidgets('should display form', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.byType(Form), findsOneWidget);
    });
  });
}