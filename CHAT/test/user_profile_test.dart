import 'package:chatsito/domain/models/user_profile.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('falls back to demo identity when no name is set', () {
    const u = UserProfile();
    expect(u.initials, 'MG');
    expect(u.displayName, 'Marta García');
    expect(u.youInitials, 'TÚ');
    expect(u.inviteCode, 'marta');
  });

  test('derives initials, you-initials and invite code from the name', () {
    const u = UserProfile(name: 'Laura Méndez');
    expect(u.initials, 'LM');
    expect(u.youInitials, 'LA');
    expect(u.inviteCode, 'laura');
  });

  test('formats the raw phone in groups of three', () {
    const u = UserProfile(phone: '612345678');
    expect(u.phoneFormatted, '612 345 678');
  });

  test('copyWith conserva y cambia avatarUrl', () {
    const u = UserProfile(id: '1', name: 'Ana', phone: '502', avatarUrl: '/a.png');
    expect(u.copyWith(name: 'B').avatarUrl, '/a.png');
    expect(u.copyWith(avatarUrl: '/b.png').avatarUrl, '/b.png');
  });
}
