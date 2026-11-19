import 'package:data_catalog/features/auth/data/repositories/auth_repository.dart';
import 'package:data_catalog/features/auth/presentation/pages/auth_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('validates sign-in fields before calling the repository', (
    tester,
  ) async {
    final repository = _FakeAuthRepository();
    await tester.pumpWidget(
      MaterialApp(
        home: AuthPage(repository: repository, onAuthenticated: () {}),
      ),
    );

    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();

    expect(find.text('Enter your username.'), findsOneWidget);
    expect(find.text('Enter your password.'), findsOneWidget);
    expect(repository.loginCalls, 0);
  });

  testWidgets('validates registration password confirmation', (tester) async {
    final repository = _FakeAuthRepository();
    await tester.pumpWidget(
      MaterialApp(
        home: AuthPage(repository: repository, onAuthenticated: () {}),
      ),
    );

    await tester.tap(find.text('New here? Create an account'));
    await tester.pumpAndSettle();
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Taylor');
    await tester.enterText(fields.at(1), 'Lee');
    await tester.enterText(fields.at(2), 'taylorlee');
    await tester.enterText(fields.at(3), 'taylor@example.com');
    await tester.enterText(fields.at(4), 'password123');
    await tester.enterText(fields.at(5), 'different123');
    await tester.ensureVisible(find.text('Create account'));
    await tester.tap(find.text('Create account'));
    await tester.pumpAndSettle();

    expect(find.text('Passwords do not match.'), findsOneWidget);
    expect(repository.registerCalls, 0);
  });
}

class _FakeAuthRepository implements AuthRepository {
  int loginCalls = 0;
  int registerCalls = 0;

  @override
  Future<void> login({
    required String username,
    required String password,
  }) async {
    loginCalls++;
  }

  @override
  Future<void> register({
    required String firstName,
    required String lastName,
    required String username,
    required String email,
    required String password,
  }) async {
    registerCalls++;
  }
}
