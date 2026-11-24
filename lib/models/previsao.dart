class DadosAtuais {
  final double temperatura;
  final double umidadeRelativa;
  final double precipitacao;
  final double chuva;
  final double velocidadeVento;

  const DadosAtuais({
    required this.temperatura,
    required this.umidadeRelativa,
    required this.precipitacao,
    required this.chuva,
    required this.velocidadeVento,
  });

  factory DadosAtuais.fromJson(Map<String, dynamic> json) {
    return DadosAtuais(
      temperatura: ((json['temperature_2m'] as num?) ?? 0).toDouble(),
      umidadeRelativa: ((json['relative_humidity_2m'] as num?) ?? 0).toDouble(),
      precipitacao: ((json['precipitation'] as num?) ?? 0).toDouble(),
      chuva: ((json['rain'] as num?) ?? 0).toDouble(),
      velocidadeVento: ((json['wind_speed_10m'] as num?) ?? 0).toDouble(),
    );
  }
}

class PrevisaoHora {
  final String horario;
  final double temperatura;
  final double probabilidadePrecipitacao;
  final double precipitacao;
  final double chuva;

  const PrevisaoHora({
    required this.horario,
    required this.temperatura,
    required this.probabilidadePrecipitacao,
    required this.precipitacao,
    required this.chuva,
  });
}

class PrevisaoDia {
  final String data;
  final double tempMax;
  final double tempMin;
  final double somaPrecipitacao;
  final double probMaxPrecipitacao;

  const PrevisaoDia({
    required this.data,
    required this.tempMax,
    required this.tempMin,
    required this.somaPrecipitacao,
    required this.probMaxPrecipitacao,
  });
}

class PrevisaoTempo {
  final DadosAtuais atual;
  final List<PrevisaoHora> porHora;
  final List<PrevisaoDia> diaria;

  const PrevisaoTempo({
    required this.atual,
    required this.porHora,
    required this.diaria,
  });

  factory PrevisaoTempo.fromJson(Map<String, dynamic> json) {
    final currentMap = (json['current'] as Map<String, dynamic>?) ?? {};
    final hourlyMap = (json['hourly'] as Map<String, dynamic>?) ?? {};
    final dailyMap = (json['daily'] as Map<String, dynamic>?) ?? {};

    final horas = (hourlyMap['time'] as List<dynamic>?) ?? [];
    final tempsHora = (hourlyMap['temperature_2m'] as List<dynamic>?) ?? [];
    final probsHora =
        (hourlyMap['precipitation_probability'] as List<dynamic>?) ?? [];
    final precipsHora = (hourlyMap['precipitation'] as List<dynamic>?) ?? [];
    final chuvasHora = (hourlyMap['rain'] as List<dynamic>?) ?? [];

    final totalHoras = [
      horas.length,
      tempsHora.length,
      probsHora.length,
      precipsHora.length,
      chuvasHora.length,
    ].reduce((a, b) => a < b ? a : b);

    final listaHora = List.generate(totalHoras, (i) {
      return PrevisaoHora(
        horario: horas[i]?.toString() ?? '',
        temperatura: ((tempsHora[i] as num?) ?? 0).toDouble(),
        probabilidadePrecipitacao: ((probsHora[i] as num?) ?? 0).toDouble(),
        precipitacao: ((precipsHora[i] as num?) ?? 0).toDouble(),
        chuva: ((chuvasHora[i] as num?) ?? 0).toDouble(),
      );
    });

    final datas = (dailyMap['time'] as List<dynamic>?) ?? [];
    final maxTemps = (dailyMap['temperature_2m_max'] as List<dynamic>?) ?? [];
    final minTemps = (dailyMap['temperature_2m_min'] as List<dynamic>?) ?? [];
    final somasPrecip = (dailyMap['precipitation_sum'] as List<dynamic>?) ?? [];
    final probsMax =
        (dailyMap['precipitation_probability_max'] as List<dynamic>?) ?? [];

    final totalDias = [
      datas.length,
      maxTemps.length,
      minTemps.length,
      somasPrecip.length,
      probsMax.length,
    ].reduce((a, b) => a < b ? a : b);

    final listaDia = List.generate(totalDias, (i) {
      return PrevisaoDia(
        data: datas[i]?.toString() ?? '',
        tempMax: ((maxTemps[i] as num?) ?? 0).toDouble(),
        tempMin: ((minTemps[i] as num?) ?? 0).toDouble(),
        somaPrecipitacao: ((somasPrecip[i] as num?) ?? 0).toDouble(),
        probMaxPrecipitacao: ((probsMax[i] as num?) ?? 0).toDouble(),
      );
    });

    return PrevisaoTempo(
      atual: DadosAtuais.fromJson(currentMap),
      porHora: listaHora,
      diaria: listaDia,
    );
  }
}