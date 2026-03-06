import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sewa_hub/features/auth/presentation/state/auth_state.dart';
import 'package:sewa_hub/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:sewa_hub/features/profile/domain/entities/profile_entity.dart';
import 'package:sewa_hub/features/profile/presentation/pages/edit_profile_screen.dart';
import 'package:sewa_hub/features/profile/presentation/state/profile_state.dart';
import 'package:sewa_hub/features/profile/presentation/view_model/profile_view_model.dart';

// ── Mock ViewModels ──

class MockProfileViewModel extends Notifier<ProfileState>
    implements ProfileViewModel {
  final ProfileState _initialState;
  MockProfileViewModel({ProfileState initialState = const ProfileState()})
      : _initialState = initialState;

  @override
  ProfileState build() => _initialState;

  @override
  Future<void> getProfile() async {}

  @override
  Future<void> updateProfile({
    required String fullName,
    required String email,
    dynamic imageFile,
  }) async {}
}

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
  Future<void> login({required String email, required String password}) async {}

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

// ── Test Widget Builder ──

Widget createTestWidget({
  ProfileState profileState = const ProfileState(),
  AuthState authState = const AuthState(),
}) {
  return ProviderScope(
    overrides: [
      profileViewModelProvider.overrideWith(
          () => MockProfileViewModel(initialState: profileState)),
      authViewModelProvider.overrideWith(
          () => MockAuthViewModel(initialState: authState)),
    ],
    child: const MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(size: Size(800, 1200)),
        child: EditProfilePage(),
      ),
    ),
  );
}

void main() {
  group('EditProfilePage - UI Elements', () {
    // TEST 1: Tab bar is present with correct tab labels
    testWidgets('should display Edit Profile and Change Password tabs',
        (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      expect(find.text('Edit Profile'), findsOneWidget);
      expect(find.text('Change Password'), findsOneWidget);
      expect(find.byType(TabBar), findsOneWidget);
    });

    // TEST 2: Edit Profile tab shows correct fields
    testWidgets('should display Full Name and Email fields on Edit Profile tab',
        (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      expect(find.text('Full Name'), findsWidgets);
      expect(find.text('Email'), findsWidgets);
      expect(find.text('Update Profile'), findsOneWidget);
    });

    // TEST 3: Avatar/camera icon is shown when no profile picture
    testWidgets('should display person icon when no profile picture',
        (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      expect(find.byIcon(Icons.person), findsOneWidget);
      expect(find.byType(CircleAvatar), findsOneWidget);
    });

    // TEST 4: Profile data is pre-filled when ProfileState is loaded
    testWidgets('should pre-fill controllers when profile is loaded',
        (tester) async {
      const loadedState = ProfileState(
        status: ProfileStatus.loaded,
        profileEntity: ProfileEntity(
          fullName: 'John Doe',
          email: 'johndoe@gmail.com',
        ),
      );

      await tester.pumpWidget(createTestWidget(profileState: loadedState));
      await tester.pump();

      expect(find.text('John Doe'), findsWidgets);
      expect(find.text('johndoe@gmail.com'), findsWidgets);
    });

    // TEST 5: Change Password tab shows correct fields after tap
    testWidgets('should display password fields on Change Password tab',
        (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Tap the tab in the TabBar specifically
      await tester.tap(find.byType(Tab).last);
      await tester.pumpAndSettle();

      // Labels appear twice (section label + field label), so use findsWidgets
      expect(find.text('Current Password'), findsWidgets);
      expect(find.text('New Password'), findsWidgets);
      expect(find.text('Confirm Password'), findsWidgets);
      expect(find.text('Change Password'), findsWidgets);
    });

    // TEST 6: Validation errors shown on empty Change Password form submission
    testWidgets(
        'should show validation errors when Change Password submitted empty',
        (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Switch to Change Password tab via Tab widget
      await tester.tap(find.byType(Tab).last);
      await tester.pumpAndSettle();

      // Ensure the Change Password button is visible then tap
      final changePasswordButton = find.widgetWithText(
        ElevatedButton,
        'Change Password',
      ).first;
      await tester.ensureVisible(changePasswordButton);
      await tester.pumpAndSettle();
      await tester.tap(changePasswordButton);
      await tester.pump();

      expect(find.text('Current password is required'), findsOneWidget);
      expect(find.text('New password is required'), findsOneWidget);
      expect(find.text('Please confirm password'), findsOneWidget);
    });

    // TEST 7: Loading indicator shown when ProfileStatus is loading
    testWidgets('should show loading indicator when profile is loading',
        (tester) async {
      const loadingState = ProfileState(status: ProfileStatus.loading);

      await tester.pumpWidget(createTestWidget(profileState: loadingState));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}