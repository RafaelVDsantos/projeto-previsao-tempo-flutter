import 'package:flutter/material.dart';
import '../models/cidade.dart';
import '../models/previsao.dart';
import '../services/clima_service.dart';

class PrevisaoScreen extends StatefulWidget {
  const PrevisaoScreen({super.key});

  @override
  State<PrevisaoScreen> createState() => _PrevisaoScreenState();
}

class _PrevisaoScreenState extends State<PrevisaoScreen> {
  final _service = ClimaService();
  final _buscaController = TextEditingController(
    text: 'Sao Sebastiao do Paraiso',
  );

  bool _carregandoCidades = false;
  String? _erroCidades;
  List<Cidade> _cidades = [];
  Cidade? _cidadeSelecionada;
  Future<PrevisaoTempo>? _futurePrevisao;

  @override
  void initState() {
    super.initState();
    _pesquisarCidades();
  }

  @override
  void dispose() {
    _buscaController.dispose();
    super.dispose();
  }

  Future<void> _pesquisarCidades() async {
    final texto = _buscaController.text.trim();
    if (texto.isEmpty) {
      setState(() {
        _erroCidades = 'Digite o nome de uma cidade.';
        _cidades = [];
      });
      return;
    }

    setState(() {
      _carregandoCidades = true;
      _erroCidades = null;
    });

    try {
      final encontradas = await _service.buscarCidades(texto);
      if (!mounted) return;

      setState(() {
        _cidades = encontradas;
        if (encontradas.isNotEmpty) {
          _selecionarCidade(encontradas.first);
        } else {
          _cidadeSelecionada = null;
          _futurePrevisao = null;
          _erroCidades = 'Nenhuma cidade encontrada para "$texto".';
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _erroCidades = '$e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _carregandoCidades = false;
        });
      }
    }
  }

  void _selecionarCidade(Cidade cidade) {
    setState(() {
      _cidadeSelecionada = cidade;
      _futurePrevisao = _service.buscarPrevisao(
        latitude: cidade.latitude,
        longitude: cidade.longitude,
      );
    });
  }

  Future<void> _recarregarPrevisao() async {
    final cidade = _cidadeSelecionada;
    if (cidade == null) return;
    final novoFuture = _service.buscarPrevisao(
      latitude: cidade.latitude,
      longitude: cidade.longitude,
    );
    setState(() {
      _futurePrevisao = novoFuture;
    });
    try {
      await novoFuture;
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Previsão do Tempo'),
        actions: [
          IconButton(
            onPressed: _cidadeSelecionada == null ? null : _recarregarPrevisao,
            icon: const Icon(Icons.refresh),
            tooltip: 'Atualizar previsão',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _buscaController,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => _pesquisarCidades(),
                  decoration: const InputDecoration(
                    labelText: 'Buscar cidade',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: _carregandoCidades ? null : _pesquisarCidades,
                child: const Text('Buscar'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_carregandoCidades)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Center(child: CircularProgressIndicator()),
            ),
          if (_erroCidades != null) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(_erroCidades!),
              ),
            ),
            const SizedBox(height: 12),
          ],
          if (_cidades.length > 1) ...[
            const Text(
              'Resultados encontrados:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: _cidades.map((cidade) {
                final selecionada = _cidadeSelecionada?.id == cidade.id;
                return ChoiceChip(
                  label: Text(cidade.descricaoLocal),
                  selected: selecionada,
                  onSelected: (_) => _selecionarCidade(cidade),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],
          if (_futurePrevisao != null)
            FutureBuilder<PrevisaoTempo>(
              future: _futurePrevisao,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (snapshot.hasError) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Text(
                            'Erro: ${snapshot.error}',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          FilledButton.icon(
                            onPressed: _recarregarPrevisao,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Tentar novamente'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final previsao = snapshot.data;
                if (previsao == null) {
                  return const Center(
                    child: Text('Sem dados de previsão disponíveis.'),
                  );
                }

                final atual = previsao.atual;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_cidadeSelecionada != null)
                      Text(
                        _cidadeSelecionada!.descricaoLocal,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    const SizedBox(height: 8),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Agora: ${atual.temperatura.toStringAsFixed(1)} °C',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 8),
                            Text('Umidade: ${atual.umidadeRelativa.toStringAsFixed(0)}%'),
                            Text('Precipitação: ${atual.precipitacao} mm'),
                            Text('Chuva: ${atual.chuva} mm'),
                            Text('Vento: ${atual.velocidadeVento} km/h'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Próximos dias',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    ...previsao.diaria.map(
                      (dia) => Card(
                        child: ListTile(
                          title: Text(dia.data),
                          subtitle: Text(
                            'Máx precipitação: ${dia.probMaxPrecipitacao.toStringAsFixed(0)}%  |  Acumulado: ${dia.somaPrecipitacao} mm',
                          ),
                          trailing: Text(
                            '${dia.tempMin.toStringAsFixed(0)}° / ${dia.tempMax.toStringAsFixed(0)}°',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Próximas horas',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    ...previsao.porHora.take(12).map(
                          (hora) => ListTile(
                            dense: true,
                            title: Text(hora.horario),
                            subtitle: Text(
                              'Chuva prob.: ${hora.probabilidadePrecipitacao.toStringAsFixed(0)}%  |  Chuva: ${hora.chuva} mm',
                            ),
                            trailing: Text('${hora.temperatura.toStringAsFixed(1)} °C'),
                          ),
                        ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }
}