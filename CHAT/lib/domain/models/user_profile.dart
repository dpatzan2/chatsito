import '../../core/utils/formatters.dart';

/// The signed-in user. Immutable; mutate through [copyWith] in the repository.
class UserProfile {
  final String name;
  final String phone; // raw digits

  const UserProfile({this.name = '', this.phone = ''});

  bool get hasName => name.trim().isNotEmpty;
  String get displayName => hasName ? name.trim() : 'Marta García';
  String get phoneFormatted => formatPhone(phone);

  String get initials {
    if (!hasName) return 'MG';
    return name.trim().split(RegExp(r'\s+')).map((w) => w[0]).take(2).join().toUpperCase();
  }

  String get youInitials {
    if (!hasName) return 'TÚ';
    final n = name.trim();
    return (n.length >= 2 ? n.substring(0, 2) : n).toUpperCase();
  }

  String get inviteCode {
    final n = name.trim();
    final base = n.isEmpty ? 'marta' : n.toLowerCase().split(RegExp(r'\s+')).first;
    return base.replaceAll(RegExp(r'[^a-z0-9]'), '');
  }

  UserProfile copyWith({String? name, String? phone}) =>
      UserProfile(name: name ?? this.name, phone: phone ?? this.phone);
}
