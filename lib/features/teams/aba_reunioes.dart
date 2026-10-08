import 'package:flutter/material.dart';

import '../../core/tema.dart';
import '../../data/teams/modelos.dart';
import 'chamada.dart';
import 'comuns.dart';
import 'formularios.dart';
import 'teams_store.dart';

class AbaReunioes extends StatelessWidget {
  const AbaReunioes({super.key, required this.store, required this.chamada});
  final TeamsStore store;
  final ChamadaController chamada;

  @override
  Widget build(BuildContext context) {
    final agora = DateTime.now();
    final lista = store.reunioes
        .where(
          (r) => (r.fim ?? r.inicio ?? agora).isAfter(
            agora.subtract(const Duration(hours: 2)),
          ),
        )
        .toList();
    final grupos = <String, List<Reuniao>>{};
    for (final r in lista) {
      grupos.putIfAbsent(_rotuloDia(r.inicio), () => []).add(r);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Topo(
          titulo: 'Reuniões',
          acoes: [
            BotaoRedondo(
              chave: const Key('nova-reuniao'),
              icone: Icons.add_rounded,
              aoTocar: () => abrirNovaReuniao(context, store),
            ),
          ],
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: store.carregarReunioes,
            child: ListView(
              padding: const EdgeInsets.only(bottom: 20),
              children: [
                for (final g in grupos.entries) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 8, 18, 6),
                    child: Text(
                      g.key.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 10,
                        letterSpacing: 1.4,
                        color: Color(0xFF8B97A6),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  for (final r in g.value) _cartao(context, r),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _rotuloDia(DateTime? d) {
    if (d == null) return 'Sem data';
    final h = DateTime.now();
    final dia = DateTime(d.year, d.month, d.day);
    final dif = dia.difference(DateTime(h.year, h.month, h.day)).inDays;
    if (dif == 0) return 'Hoje';
    if (dif == 1) return 'Amanhã';
    return dataCurta(d);
  }

  Widget _cartao(BuildContext context, Reuniao r) {
    final eu = store.eu;
    final conf = r.participantes[eu];
    final ids = r.participantes.keys.toList();
    final agora = DateTime.now();
    final aoVivo =
        r.inicio != null &&
        agora.isAfter(r.inicio!.subtract(const Duration(minutes: 10))) &&
        agora.isBefore(r.fim ?? r.inicio!.add(const Duration(hours: 2)));
    return Cartao(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 58,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      r.inicio == null ? '--:--' : hora(r.inicio!),
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -.3,
                      ),
                    ),
                    if (r.fim != null)
                      Text(
                        'até ${hora(r.fim!)}',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFF8B97A6),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      r.titulo,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if ((r.pauta ?? '').isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          r.pauta!,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF5C6878),
                          ),
                        ),
                      ),
                    const SizedBox(height: 6),
                    SizedBox(
                      height: 22,
                      child: Stack(
                        children: [
                          for (var i = 0; i < ids.length && i < 5; i++)
                            Positioned(
                              left: i * 16.0,
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                                child: bolinhaPessoa(
                                  store.equipe.pessoa(ids[i]),
                                  tamanho: 20,
                                ),
                              ),
                            ),
                          if (ids.length > 5)
                            Positioned(
                              left: 5 * 16.0 + 4,
                              top: 3,
                              child: Text(
                                '+${ids.length - 5}',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Cores.cinza,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          Row(
            children: [
              Expanded(
                child: r.criadoPor == eu
                    ? const Text(
                        'Você marcou',
                        style: TextStyle(
                          fontSize: 10.5,
                          color: Color(0xFF8B97A6),
                        ),
                      )
                    : conf == true
                    ? const Text(
                        '✓ Confirmado',
                        style: TextStyle(
                          fontSize: 10.5,
                          color: Cores.verde,
                          fontWeight: FontWeight.w500,
                        ),
                      )
                    : Text(
                        'Convite de ${store.equipe.pessoa(r.criadoPor).nome.split(' ').first}',
                        style: const TextStyle(
                          fontSize: 10.5,
                          color: Color(0xFF8B97A6),
                        ),
                      ),
              ),
              if (r.criadoPor != eu && conf != true)
                _botao(
                  'Confirmar',
                  false,
                  () => store.api
                      .confirmarReuniao(r.id)
                      .then((_) => store.carregarReunioes()),
                ),
              if (aoVivo && r.canalId != null) ...[
                const SizedBox(width: 6),
                _botao('Entrar', true, () {
                  final c = store.canal(r.canalId!);
                  if (c != null) chamada.ligar(c, 'video');
                }),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _botao(String t, bool escuro, VoidCallback f) => GestureDetector(
    onTap: f,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: escuro ? Cores.marinho : const Color(0xFFF1F3F6),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Text(
        t,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: escuro ? Colors.white : Cores.texto,
        ),
      ),
    ),
  );
}
