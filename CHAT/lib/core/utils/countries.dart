/// Países para el selector de prefijo telefónico del registro.
class Country {
  final String flag, name, dial, iso; // dial solo dígitos, sin '+'
  const Country(this.flag, this.name, this.dial, this.iso);
}

/// ponytail: lista curada (~40) en vez de los ~240 ISO — añadir bajo demanda.
/// Nombres endónimos para no tener que traducir la lista.
const countries = <Country>[
  Country('🇦🇷', 'Argentina', '54', 'AR'),
  Country('🇧🇿', 'Belize', '501', 'BZ'),
  Country('🇧🇴', 'Bolivia', '591', 'BO'),
  Country('🇧🇷', 'Brasil', '55', 'BR'),
  Country('🇨🇦', 'Canada', '1', 'CA'),
  Country('🇨🇱', 'Chile', '56', 'CL'),
  Country('🇨🇳', '中国', '86', 'CN'),
  Country('🇨🇴', 'Colombia', '57', 'CO'),
  Country('🇨🇷', 'Costa Rica', '506', 'CR'),
  Country('🇨🇺', 'Cuba', '53', 'CU'),
  Country('🇩🇪', 'Deutschland', '49', 'DE'),
  Country('🇪🇨', 'Ecuador', '593', 'EC'),
  Country('🇸🇻', 'El Salvador', '503', 'SV'),
  Country('🇪🇸', 'España', '34', 'ES'),
  Country('🇫🇷', 'France', '33', 'FR'),
  Country('🇬🇹', 'Guatemala', '502', 'GT'),
  Country('🇭🇳', 'Honduras', '504', 'HN'),
  Country('🇮🇳', 'भारत', '91', 'IN'),
  Country('🇮🇹', 'Italia', '39', 'IT'),
  Country('🇯🇵', '日本', '81', 'JP'),
  Country('🇰🇷', '한국', '82', 'KR'),
  Country('🇲🇦', 'Maroc', '212', 'MA'),
  Country('🇲🇽', 'México', '52', 'MX'),
  Country('🇳🇮', 'Nicaragua', '505', 'NI'),
  Country('🇳🇱', 'Nederland', '31', 'NL'),
  Country('🇵🇦', 'Panamá', '507', 'PA'),
  Country('🇵🇾', 'Paraguay', '595', 'PY'),
  Country('🇵🇪', 'Perú', '51', 'PE'),
  Country('🇵🇭', 'Philippines', '63', 'PH'),
  Country('🇵🇱', 'Polska', '48', 'PL'),
  Country('🇵🇹', 'Portugal', '351', 'PT'),
  Country('🇵🇷', 'Puerto Rico', '1', 'PR'),
  Country('🇩🇴', 'República Dominicana', '1', 'DO'),
  Country('🇷🇴', 'România', '40', 'RO'),
  Country('🇨🇭', 'Schweiz', '41', 'CH'),
  Country('🇺🇦', 'Україна', '380', 'UA'),
  Country('🇬🇧', 'United Kingdom', '44', 'GB'),
  Country('🇺🇸', 'United States', '1', 'US'),
  Country('🇺🇾', 'Uruguay', '598', 'UY'),
  Country('🇻🇪', 'Venezuela', '58', 'VE'),
];

/// País por ISO-3166 del locale del sistema; España si no está en la lista.
Country countryForIso(String? iso) {
  for (final c in countries) {
    if (c.iso == iso) return c;
  }
  return countries.firstWhere((c) => c.iso == 'ES');
}
