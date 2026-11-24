import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/cidade.dart';
import '../models/previsao.dart';

class ClimaService {
  Future<List<Cidade>> buscarCidades(String nome) async {
    final termo = nome.trim();
    if (termo.isEmpty) {
      return [];
    }

    final uri = Uri.https(
      'geocoding-api.open-meteo.com',
      '/v1/search',
      {
        'name': termo,
        'count': '10',
        'language': 'pt',
        'format': 'json',
      },
    );

    final response =
        await http.get(uri).timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw Exception('Erro ${response.statusCode} ao buscar cidades.');
    }

    final decoded =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    final resultados = decoded['results'] as List<dynamic>?;

    if (resultados == null || resultados.isEmpty) {
      return [];
    }

    return resultados
        .map((item) => Cidade.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<PrevisaoTempo> buscarPrevisao({
    required double latitude,
    required double longitude,
  }) async {
    final uri = Uri.https(
      'api.open-meteo.com',
      '/v1/forecast',
      {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'current':
            'temperature_2m,relative_humidity_2m,precipitation,rain,wind_speed_10m',
        'hourly':
            'temperature_2m,precipitation_probability,precipitation,rain',
        'daily':
            'temperature_2m_max,temperature_2m_min,precipitation_sum,precipitation_probability_max',
        'timezone': 'America/Sao_Paulo',
      },
    );

    final response =
        await http.get(uri).timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw Exception('Erro ${response.statusCode} ao buscar previsão do tempo.');
    }

    final decoded =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    return PrevisaoTempo.fromJson(decoded);
  }
}