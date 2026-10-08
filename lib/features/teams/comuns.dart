import 'package:flutter/material.dart';
import '../../core/tema.dart';
import '../../data/teams/modelos.dart';

Color corStatus(String? s) => switch (s) {
      'online' => Cores.verde,
      'reuniao' => Cores.amarelo,
      'nao_interromper' || 'nao_perturbe' => Cores.vermelho,
      'ausente' => Cores.cinzaStatus,
      _ => const Color(0xFFD0D6DE),
    };

String iniciais(String nome) {
  final p = nome.trim().split(RegExp(r'\s+')).where((e) => e.isNotEmpty).take(2).map((e) => e[0]).join();
  return p.isEmpty ? '?' : p.toUpperCase();
}

class Bolinha extends StatelessWidget {
  const Bolinha({super.key, required this.texto, this.tamanho = 38, this.status, this.escuro = false, this.quadrado = false, this.fotoUrl});
  final String texto;
  final double tamanho;
  final String? status;
  final bool escuro;
  final bool quadrado;
  final String? fotoUrl;

  @override
  Widget build(BuildContext context) {
    ImageProvider? img;
    final f = fotoUrl;
    if (f != null && f.startsWith('data:')) img = MemoryImage(UriData.parse(f).contentAsBytes());
    if (f != null && f.startsWith('http')) img = NetworkImage(f);
    final letras = Text(texto,
        style: TextStyle(fontSize: tamanho * .29, fontWeight: FontWeight.w500, color: escuro ? Cores.dourado : const Color(0xFF3D4D60)));
    return SizedBox(
      width: tamanho, height: tamanho,
      child: Stack(clipBehavior: Clip.none, children: [
        Container(
          width: tamanho, height: tamanho, clipBehavior: Clip.antiAlias, alignment: Alignment.center,
          decoration: BoxDecoration(
            color: escuro ? Cores.marinho : const Color(0xFFE6EBF1),
            borderRadius: BorderRadius.circular(quadrado ? tamanho * .3 : tamanho),
          ),
          child: img == null ? letras : Image(image: img, width: tamanho, height: tamanho, fit: BoxFit.cover, errorBuilder: (_, _, _) => letras),
        ),
        if (status != null)
          Positioned(
            right: -1, bottom: -1,
            child: Container(
              width: tamanho * .26, height: tamanho * .26,
              decoration: BoxDecoration(color: corStatus(status), shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
            ),
          ),
      ]),
    );
  }
}

Widget bolinhaPessoa(Pessoa p, {double tamanho = 38, String? status}) =>
    Bolinha(texto: iniciais(p.nome), tamanho: tamanho, status: status, fotoUrl: p.fotoUrl);

class Selo extends StatelessWidget {
  const Selo(this.n, {super.key, this.pequeno = false});
  final int n;
  final bool pequeno;
  @override
  Widget build(BuildContext context) {
    if (n <= 0) return const SizedBox.shrink();
    return Container(
      constraints: BoxConstraints(minWidth: pequeno ? 15 : 18),
      height: pequeno ? 15 : 18,
      padding: const EdgeInsets.symmetric(horizontal: 5),
      alignment: Alignment.center,
      decoration: BoxDecoration(color: Cores.dourado, borderRadius: BorderRadius.circular(10)),
      child: Text(n > 99 ? '99+' : '$n', style: TextStyle(fontSize: pequeno ? 8.5 : 10, fontWeight: FontWeight.w600, color: const Color(0xFF1A1204))),
    );
  }
}

String hora(DateTime d) => '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

String quando(DateTime? d) {
  if (d == null) return '';
  final agora = DateTime.now();
  final hoje = DateTime(agora.year, agora.month, agora.day);
  final dia = DateTime(d.year, d.month, d.day);
  final dif = hoje.difference(dia).inDays;
  if (dif == 0) return hora(d);
  if (dif == 1) return 'Ontem';
  if (dif < 7) return const ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'][d.weekday - 1];
  return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';
}

String dataCurta(DateTime d) => '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';

class Topo extends StatelessWidget {
  const Topo({super.key, required this.titulo, this.voltar = false, this.acoes = const []});
  final String titulo;
  final bool voltar;
  final List<Widget> acoes;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 6, 14, 10),
      child: Row(children: [
        if (voltar)
          IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.chevron_left_rounded, color: Cores.douradoTexto, size: 28))
        else
          const SizedBox(width: 8),
        Expanded(child: Text(titulo, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, letterSpacing: -.2))),
        ...acoes,
      ]),
    );
  }
}

class BotaoRedondo extends StatelessWidget {
  const BotaoRedondo({super.key, required this.icone, required this.aoTocar, this.chave});
  final IconData icone;
  final VoidCallback aoTocar;
  final Key? chave;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 6),
      child: InkResponse(
        key: chave,
        onTap: aoTocar,
        child: Container(
          width: 32, height: 32, alignment: Alignment.center,
          decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: Cores.linha)),
          child: Icon(icone, size: 16, color: Cores.texto),
        ),
      ),
    );
  }
}

class Segmentos extends StatelessWidget {
  const Segmentos({super.key, required this.opcoes, required this.valor, required this.aoMudar});
  final List<(String, String)> opcoes;
  final String valor;
  final ValueChanged<String> aoMudar;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(color: const Color(0xFFEEF1F4), borderRadius: BorderRadius.circular(10)),
      child: Row(children: [
        for (final o in opcoes)
          Expanded(
            child: GestureDetector(
              onTap: () => aoMudar(o.$1),
              child: Container(
                height: 30, alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: valor == o.$1 ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: valor == o.$1 ? const [BoxShadow(color: Color(0x1F0E1A2B), blurRadius: 3, offset: Offset(0, 1))] : null,
                ),
                child: FittedBox(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(o.$2, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: valor == o.$1 ? Cores.texto : const Color(0xFF5C6878))),
                  ),
                ),
              ),
            ),
          ),
      ]),
    );
  }
}

class Cartao extends StatelessWidget {
  const Cartao({super.key, required this.child, this.aoTocar});
  final Widget child;
  final VoidCallback? aoTocar;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: aoTocar,
      child: Container(
        margin: const EdgeInsets.fromLTRB(14, 0, 14, 8),
        padding: const EdgeInsets.fromLTRB(12, 11, 12, 11),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: Cores.linha)),
        child: child,
      ),
    );
  }
}

void avisar(BuildContext context, String texto) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto), behavior: SnackBarBehavior.floating, duration: const Duration(seconds: 2)));
}

InputDecoration campo(String dica) => InputDecoration(
      hintText: dica,
      hintStyle: const TextStyle(color: Color(0xFF9AA5B2), fontSize: 13),
      filled: true,
      fillColor: Colors.white,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE6EAEF))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Cores.dourado)),
    );

Widget rotulo(String t) => Padding(
      padding: const EdgeInsets.only(bottom: 5, top: 4),
      child: Text(t.toUpperCase(), style: const TextStyle(fontSize: 10, letterSpacing: 1, color: Color(0xFF8B97A6), fontWeight: FontWeight.w500)),
    );

Widget cabecalhoFormulario(BuildContext context, {required String titulo, required String acao, required VoidCallback? aoConfirmar}) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(4, 4, 4, 8),
    child: Row(children: [
      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar', style: TextStyle(color: Cores.douradoTexto, fontSize: 13))),
      Expanded(child: Text(titulo, textAlign: TextAlign.center, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600))),
      TextButton(onPressed: aoConfirmar, child: Text(acao, style: const TextStyle(color: Cores.douradoTexto, fontSize: 13, fontWeight: FontWeight.w600))),
    ]),
  );
}

Widget folhaFlutuante(Widget filho) => SafeArea(
      top: false,
      minimum: const EdgeInsets.only(bottom: 12),
      child: Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        clipBehavior: Clip.antiAlias,
        child: filho,
      ),
    ),
    );
