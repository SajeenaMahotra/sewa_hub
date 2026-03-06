import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sewa_hub/features/auth/presentation/pages/signup_page.dart';
import 'package:sewa_hub/features/auth/presentation/state/auth_state.dart';
import 'package:sewa_hub/features/auth/presentation/view_model/auth_view_model.dart';

class MockAuthViewModel extends Notifier<AuthState> implements AuthViewModel {
  final AuthState _initialState;

  MockAuthViewModel({AuthState initialState = const AuthState()})
      : _initialState = initialState;

  @override
  AuthState build() => _initialState;

  @override
  Future<void> register({
    required String fullName,
    required String email,
    required String password,
  }) async {}

  @override
  Future<void> login({
    required String email,
    required String password,
  }) async {}

  @override
  Future<void> loginWithGoogle(String idToken) async {}

  @override
  Future<void> forgotPassword({required String email}) async {}

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmNewPassword,
  }) async {}
}

Widget createTestWidget({AuthState initialState = const AuthState()}) {
  return ProviderScope(
    overrides: [
      authViewModelProvider.overrideWith(() =>
          MockAuthViewModel(initialState: initialState)),
    ],
    child: const MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(size: Size(800, 1200)),
        child: SignupScreen(),
      ),
    ),
  );
}

void main() {
  group('SignupScreen - UI Elements', () {
    testWidgets('should display title, subtitle, OR, and terms text',
        (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Create Your Account'), findsOneWidget);
      expect(
        find.text('Sign up to access reliable services anytime, anywhere.'),
        findsOneWidget,
      );
      expect(find.text('OR'), findsOneWidget);
      expect(
        find.text(
          'By signing up, you agree to our Terms and Conditions and Privacy Policy.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('should display all field labels and hint texts',
        (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Full Name'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Confirm Password'), findsOneWidget);
      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('johndoe@gmail.com'), findsOneWidget);
      expect(find.text('********'), findsNWidgets(2));
    });


    testWidgets('should display form with correct structure', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.byType(Form), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(4));
      expect(find.text('Sign Up'), findsOneWidget);
      expect(find.text('Continue with Google'), findsOneWidget);
    });

  
    testWidgets('should display login redirect link', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Already have an account? '), findsOneWidget);
      expect(find.text('Login'), findsOneWidget);
    });

 
    testWidgets('should display logo image', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.byType(Image), findsWidgets);
    });
  });
}