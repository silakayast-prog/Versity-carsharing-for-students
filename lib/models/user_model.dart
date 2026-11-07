class UserModel {
  final String id;
  final String adSoyad;
  final String okulEmail;
  final bool isPremium;
  final int kalanUcretsizBinis;
  final String aktifRol; // 'sofor' or 'yolcu'
  final double puan;
  final String? profilFotoUrl;
  final String? ozelIhtiyac;
  final int toplamPuan;
  final String rozetSeviyesi; // 'baslangic', 'guvenilir', 'yildiz', 'elit'
  final int aylikYolculuk;

  UserModel({
    required this.id,
    required this.adSoyad,
    required this.okulEmail,
    required this.isPremium,
    required this.kalanUcretsizBinis,
    required this.aktifRol,
    required this.puan,
    this.profilFotoUrl,
    this.ozelIhtiyac,
    this.toplamPuan = 0,
    this.rozetSeviyesi = 'baslangic',
    this.aylikYolculuk = 0,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final driverPoints = json['driver_points'] as Map<String, dynamic>?;

    return UserModel(
      id: json['id'] ?? '',
      adSoyad: json['ad_soyad'] ?? '',
      okulEmail: json['okul_email'] ?? '',
      isPremium: json['is_premium'] ?? false,
      kalanUcretsizBinis: json['kalan_ucretsiz_binis'] ?? 0,
      aktifRol: json['aktif_rol'] ?? 'yolcu',
      puan: (json['puan'] != null) ? double.parse(json['puan'].toString()) : 0.0,
      profilFotoUrl: json['profil_foto_url'],
      ozelIhtiyac: json['ozel_ihtiyac'],
      toplamPuan: driverPoints?['toplam_puan'] ?? 0,
      rozetSeviyesi: driverPoints?['rozet_seviyesi'] ?? 'baslangic',
      aylikYolculuk: driverPoints?['aylik_yolculuk'] ?? 0,
    );
  }
}
