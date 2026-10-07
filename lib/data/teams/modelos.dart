class Pessoa {
  const Pessoa({required this.id, required this.nome, this.email, this.nivel, this.fotoUrl, this.setores = const []});
  final String id;
  final String nome;
  final String? email;
  final String? nivel;
  final String? fotoUrl;
  final List<String> setores;

  factory Pessoa.deMapa(Map m) => Pessoa(
        id: m['id'] as String,
        nome: (m['nome'] as String?) ?? '—',
        email: m['email'] as String?,
        nivel: m['nivel'] as String?,
        fotoUrl: m['foto_url'] as String?,
        setores: ((m['setores'] as List?) ?? const []).map((e) => e.toString()).toList(),
      );
}

class Setor {
  const Setor({required this.id, required this.nome});
  final String id;
  final String nome;
}

class Equipe {
  const Equipe({this.pessoas = const [], this.setores = const []});
  final List<Pessoa> pessoas;
  final List<Setor> setores;

  Pessoa pessoa(String? id) =>
      pessoas.firstWhere((p) => p.id == id, orElse: () => Pessoa(id: id ?? '', nome: 'Alguém'));
  String nomeSetor(String? id) => setores.firstWhere((s) => s.id == id, orElse: () => const Setor(id: '', nome: 'Setor')).nome;
  List<Pessoa> doSetor(String? id) => pessoas.where((p) => p.setores.contains(id)).toList();
}

class Ultima {
  const Ultima({this.autorId, this.corpo, this.tipo, this.em});
  final String? autorId;
  final String? corpo;
  final String? tipo;
  final DateTime? em;
}

class Canal {
  Canal({
    required this.id,
    required this.tipo,
    this.nome,
    this.descricao,
    this.setorId,
    this.membros = const [],
    this.silenciado = false,
    this.ultima,
    this.naoLidas = 0,
  });
  final String id;
  final String tipo;
  final String? nome;
  final String? descricao;
  final String? setorId;
  List<String> membros;
  bool silenciado;
  Ultima? ultima;
  int naoLidas;

  factory Canal.deMapa(Map m) {
    final u = m['ultima'] as Map?;
    return Canal(
      id: m['id'] as String,
      tipo: m['tipo'] as String,
      nome: m['nome'] as String?,
      descricao: m['descricao'] as String?,
      setorId: m['setor_id'] as String?,
      membros: ((m['membros'] as List?) ?? const []).map((e) => e.toString()).toList(),
      silenciado: m['silenciado'] == true,
      naoLidas: (m['nao_lidas'] as num?)?.toInt() ?? 0,
      ultima: u == null
          ? null
          : Ultima(
              autorId: u['autor_id'] as String?,
              corpo: u['corpo'] as String?,
              tipo: u['tipo'] as String?,
              em: DateTime.tryParse((u['em'] ?? '').toString())?.toLocal(),
            ),
    );
  }
}

class Anexo {
  const Anexo({required this.id, required this.tipo, this.nome, this.url, this.tamanho, this.transcricao});
  final String id;
  final String tipo;
  final String? nome;
  final String? url;
  final int? tamanho;
  final String? transcricao;

  factory Anexo.deMapa(Map m) => Anexo(
        id: m['id'] as String,
        tipo: (m['tipo'] as String?) ?? 'arquivo',
        nome: m['nome'] as String?,
        url: m['url'] as String?,
        tamanho: (m['tamanho'] as num?)?.toInt(),
        transcricao: m['transcricao'] as String?,
      );
}

class Mensagem {
  Mensagem({
    required this.id,
    required this.canalId,
    this.autorId,
    this.tipo = 'texto',
    this.corpo,
    this.meta = const {},
    this.respondeA,
    required this.criadaEm,
    this.editadaEm,
    this.anexos = const [],
    this.provisoria = false,
  });
  final String id;
  final String canalId;
  final String? autorId;
  final String tipo;
  String? corpo;
  final Map<String, dynamic> meta;
  final String? respondeA;
  final DateTime criadaEm;
  DateTime? editadaEm;
  List<Anexo> anexos;
  final bool provisoria;

  factory Mensagem.deMapa(Map m) => Mensagem(
        id: m['id'] as String,
        canalId: m['canal_id'] as String,
        autorId: m['autor_id'] as String?,
        tipo: (m['tipo'] as String?) ?? 'texto',
        corpo: m['corpo'] as String?,
        meta: Map<String, dynamic>.from((m['meta'] as Map?) ?? const {}),
        respondeA: m['responde_a'] as String?,
        criadaEm: DateTime.parse(m['criada_em'] as String).toLocal(),
        editadaEm: DateTime.tryParse((m['editada_em'] ?? '').toString())?.toLocal(),
        anexos: ((m['chat_anexo'] as List?) ?? const []).map((a) => Anexo.deMapa(a as Map)).toList(),
      );
}

class Aviso {
  const Aviso({required this.id, required this.titulo, this.corpo, required this.nivel, required this.escopo, this.setorId, this.autorId, required this.criadoEm});
  final String id;
  final String titulo;
  final String? corpo;
  final String nivel;
  final String escopo;
  final String? setorId;
  final String? autorId;
  final DateTime criadoEm;

  factory Aviso.deMapa(Map m) => Aviso(
        id: m['id'] as String,
        titulo: (m['titulo'] as String?) ?? '',
        corpo: m['corpo'] as String?,
        nivel: (m['nivel'] as String?) ?? 'info',
        escopo: (m['escopo'] as String?) ?? 'central',
        setorId: m['setor_id'] as String?,
        autorId: m['autor_id'] as String?,
        criadoEm: DateTime.parse(m['criado_em'] as String).toLocal(),
      );
}

class Pedido {
  const Pedido({required this.id, required this.titulo, this.descricao, this.solicitanteId, this.responsavelId, required this.status, this.prazo, this.canalId, required this.criadoEm});
  final String id;
  final String titulo;
  final String? descricao;
  final String? solicitanteId;
  final String? responsavelId;
  final String status;
  final DateTime? prazo;
  final String? canalId;
  final DateTime criadoEm;

  String get codigo => 'P-${id.substring(0, 4).toUpperCase()}';

  factory Pedido.deMapa(Map m) => Pedido(
        id: m['id'] as String,
        titulo: (m['titulo'] as String?) ?? '',
        descricao: m['descricao'] as String?,
        solicitanteId: m['solicitante_id'] as String?,
        responsavelId: m['responsavel_id'] as String?,
        status: (m['status'] as String?) ?? 'aberto',
        prazo: DateTime.tryParse((m['prazo'] ?? '').toString()),
        canalId: m['canal_id'] as String?,
        criadoEm: DateTime.parse(m['criado_em'] as String).toLocal(),
      );
}

class Reuniao {
  const Reuniao({required this.id, required this.titulo, this.pauta, this.inicio, this.fim, this.criadoPor, this.participantes = const {}, this.canalId});
  final String id;
  final String titulo;
  final String? pauta;
  final DateTime? inicio;
  final DateTime? fim;
  final String? criadoPor;
  final String? canalId;
  final Map<String, bool?> participantes;

  factory Reuniao.deMapa(Map m) => Reuniao(
        id: m['id'] as String,
        titulo: (m['titulo'] as String?) ?? '',
        pauta: m['pauta'] as String?,
        inicio: DateTime.tryParse((m['inicio'] ?? '').toString())?.toLocal(),
        fim: DateTime.tryParse((m['fim'] ?? '').toString())?.toLocal(),
        criadoPor: m['criado_por'] as String?,
        canalId: m['canal_id'] as String?,
        participantes: {
          for (final p in ((m['chat_reuniao_participante'] as List?) ?? const []))
            (p as Map)['usuario_id'] as String: p['confirmado'] as bool?,
        },
      );
}

class Empresa {
  const Empresa({required this.id, required this.nome, this.cnpj, this.regime});
  final String id;
  final String nome;
  final String? cnpj;
  final String? regime;

  factory Empresa.deMapa(Map m) => Empresa(
        id: m['id'] as String,
        nome: ((m['nome_fantasia'] as String?)?.trim().isNotEmpty == true ? m['nome_fantasia'] : m['razao_social']) as String? ?? 'Cliente',
        cnpj: m['cnpj'] as String?,
        regime: m['regime_tributario'] as String?,
      );
}

const statusPresenca = {
  'online': 'Online',
  'reuniao': 'Em reunião',
  'ausente': 'Ausente',
  'nao_interromper': 'Não me interrompam',
  'nao_perturbe': 'Não me interrompam',
  'offline': 'Offline',
};

const statusPedido = {'aberto': 'Aberto', 'em_andamento': 'Em andamento', 'concluido': 'Concluído', 'cancelado': 'Cancelado'};

const nivelAviso = {'info': 'Informativo', 'visto': 'Exige visto', 'urgente': 'Urgente do CEO'};
