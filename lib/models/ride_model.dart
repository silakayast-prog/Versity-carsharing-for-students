class RideModel {
  final String id;
  final String soforId;
  final String soforAd;
  final String rozetSeviyesi;
  final String aracMarkaModel;
  final String plaka;
  final String baslangicMetni;
  final String varisMetni;
  final DateTime kalkisZamani;
  final int mevcutKapasite;
  final double puanCarpani;
  final String durum;

  RideModel({
    required this.id,
    required this.soforId,
    required this.soforAd,
    required this.rozetSeviyesi,
    required this.aracMarkaModel,
    required this.plaka,
    required this.baslangicMetni,
    required this.varisMetni,
    required this.kalkisZamani,
    required this.mevcutKapasite,
    required this.puanCarpani,
    required this.durum,
  });

  factory RideModel.fromJson(Map<String, dynamic> json) {
    final sofor = json['sofor'] as Map<String, dynamic>?;
    final driverPoints = sofor?['driver_points'] as Map<String, dynamic>?;
    final vehicle = json['vehicle'] as Map<String, dynamic>?;

    return RideModel(
      id: json['id'] ?? '',
      soforId: json['sofor_id'] ?? '',
      soforAd: sofor?['ad_soyad'] ?? 'Şoför',
      rozetSeviyesi: driverPoints?['rozet_seviyesi'] ?? 'baslangic',
      aracMarkaModel: vehicle?['marka_model'] ?? 'Araç',
      plaka: vehicle?['plaka'] ?? '',
      baslangicMetni: json['baslangic_metni'] ?? '',
      varisMetni: json['varis_metni'] ?? '',
      kalkisZamani: DateTime.tryParse(json['kalkis_zamani'] ?? '') ?? DateTime.now(),
      mevcutKapasite: json['mevcut_kapasite'] ?? 0,
      puanCarpani: (json['puan_carpani'] != null) ? double.parse(json['puan_carpani'].toString()) : 1.0,
      durum: json['durum'] ?? 'bekliyor',
    );
  }
}
