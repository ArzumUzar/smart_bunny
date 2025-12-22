enum Level {
  a1('A1', 'Başlangıç'),
  a2('A2', 'Temel'),
  b1('B1', 'Orta Seviye'),
  b2('B2', 'Orta-İleri'),
  c1('C1', 'İleri'),
  c2('C2', 'Uzman');

  final String code;
  final String description;
  const Level(this.code, this.description);
}