class TranscriptRow {
  final String kod;
  final String isim;
  final String status;
  final String dil;
  final int t, u, uk, akts, puan;
  final String not;
  final String aciklama;

  TranscriptRow({required this.kod, required this.isim, required this.status, required this.dil, required this.t, required this.u, required this.uk, required this.akts, required this.puan, required this.not, required this.aciklama});


  @override
  String toString() {
    return 'TranscriptRow(kod: $kod, isim: $isim, status: $status, dil: $dil, t: $t, u: $u, uk: $uk, akts: $akts, puan: $puan, not: $not, aciklama: $aciklama)';
  }
}
