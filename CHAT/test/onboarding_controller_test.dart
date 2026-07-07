import 'package:chatsito/app/app_router.dart';
import 'package:chatsito/data/in_memory_auth_repository.dart';
import 'package:chatsito/features/onboarding/onboarding_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppRouter router;
  late InMemoryAuthRepository auth;
  late OnboardingController c;

  setUp(() {
    router = AppRouter();
    auth = InMemoryAuthRepository();
    c = OnboardingController(auth, router);
  });

  test('phone entry caps at 9 digits and formats live', () {
    c.start();
    expect(router.screen, AppScreen.phone);
    for (final d in '6123456789'.split('')) {
      c.onDigit(d);
    }
    expect(c.phone, '612345678'); // 10th digit ignored
    expect(c.phoneFormatted, '612 345 678');
    expect(c.phoneComplete, true);
    c.onBackspace();
    expect(c.phone, '61234567');
    expect(c.phoneComplete, false);
  });

  test('submitPhone stores the number and advances to OTP', () async {
    c.start();
    for (final d in '600000000'.split('')) {
      c.onDigit(d);
    }
    await c.submitPhone();
    expect(router.screen, AppScreen.otp);
    expect(auth.user.phone, '600000000');
  });

  test('OTP caps at 6 digits', () {
    router.go(AppScreen.otp);
    for (final d in '1234567'.split('')) {
      c.onDigit(d);
    }
    expect(c.otp, '123456');
  });

  test('finish saves the name and lands on chats', () async {
    c.setName('  Ana Ruiz  ');
    await c.finish();
    expect(auth.user.name, '  Ana Ruiz  ');
    expect(auth.user.displayName, 'Ana Ruiz');
    expect(router.screen, AppScreen.chats);
  });
}
