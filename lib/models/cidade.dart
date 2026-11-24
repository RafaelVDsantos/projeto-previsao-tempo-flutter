class Cidade {
  final int id;
  final String name;
  final double latitude;
  final double longitude;
  final String? admin1;
  final String? country;

  const Cidade({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.admin1,
    this.country,
  });

  factory Cidade.fromJson(Map<String, dynamic> json) {
    return Cidade(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? 'Cidade sem nome',
      latitude: ((json['latitude'] as num?) ?? 0).toDouble(),
      longitude: ((json['longitude'] as num?) ?? 0).toDouble(),
      admin1: json['admin1'] as String?,
      country: json['country'] as String?,
    );
  }

  String get descricaoLocal {
    final partes = [
      if (admin1 != null && admin1!.isNotEmpty) admin1!,
      if (country != null && country!.isNotEmpty) country!,
    ];
    return partes.isEmpty ? name : '$name (${partes.join(', ')})';
  }
}