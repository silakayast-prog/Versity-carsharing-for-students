# Versity — Üniversiteler Arası Araç Paylaşımı (Ride Sharing) Mobil Uygulaması

<p align="center">
  <img src="assets/images/versity_generated_banner.jpg" alt="Versity Banner" width="100%" />
</p>

Versity, üniversite öğrencilerinin ve akademisyenlerinin kampüs ve şehir merkezleri arasındaki ulaşım ihtiyaçlarını güvenli, ekonomik, çevre dostu ve sosyal bir şekilde karşılamalarını sağlayan modern bir araç paylaşım (carpooling / ride sharing) mobil uygulamasıdır.

---

## 🌟 Öne Çıkan Özellikler

- **🔒 Yalnızca Onaylı Üniversite Topluluğu:** `.edu.tr` uzantılı e-posta ve öğrenci/sürücü doğrulama sistemi.
- **🗺️ Akıllı Rota ve Canlı Konum Arama:** OpenStreetMap (Nominatim API) entegrasyonu ile Antalya/Alanya ve çevre kampüslere özel gerçek zamanlı lokasyon eşleşmesi.
- **🚘 Sürücü & Araç Profilleri:** Sürücülerin araç detayları (iç/dış galeri), sürüş kuralları (müzik, sigara yasağı, evcil hayvan vb.) ve yolculuk notları.
- **➕ Pratik İlan Oluşturma (Şoför Akışı):** Akıllı fiyat slider'ı (200 - 260 TL önerilen tavan/taban aralığı), tarih/saat seçicileri ve dinamik koltuk kapasitesi ayarı.
- **🎫 Anlık Koltuk Rezervasyonu ve Biniş QR Kodu:** Rezervasyon yapıldığında anlık koltuk düşüşü, binişte şoföre okutulacak güvenli QR kod üretimi.
- **🔥 Bulut Entegrasyonu (Firebase & REST API):** Firebase Authentication, Cloud Firestore gerçek zamanlı veritabanı ve Node.js REST API uç noktaları.
- **⚡ Yüksek Performanslı Karanlık Tema (Vanta Dark):** `#0C0C0F` vanta-black teması, 60+ FPS pürüzsüz kaydırma ve anlık dokunmatik tepki süresi.

---

## 📱 Ekran Görüntüleri ve Arayüz

Uygulama, modern koyu lacivert / vanta black tasarım dili, neon mavi (`#00B4D8`) vurguları ve mobil cihazlar için optimize edilmiş ergonomik kart mimarisi ile geliştirilmiştir:

- **Ana Ekran (Dashboard):** Canlı saat widget'ı, hızlı rota arama kartı, "Şoför müsün? İlan Oluştur" butonu ve popüler kampüs rotaları.
- **Arama Sonuçları Listesi:** Rota filtreleme, gün seçici şeridi, sürücü rozetleri (*En Uygun, En Hızlı, VIP Konfor, Lüks Sefer*) ve kalan koltuk sayaçları.
- **Seyahat Detayı & Araç Galerisi:** Zaman çizelgesi, sürücü biyografisi, araç içi/dışı 360 galeri modalı, bagaj/klima özellikleri ve rezervasyon butonu.
- **Yolculuklarım (My Rides):** Aktif, bekleyen ve geçmiş yolculuklar ile tek tıkla açılan Biniş QR Kodu modalı.
- **Profil & Şoför Rozetleri:** Puanlama, aylık yolculuk istatistikleri ve seviye rozetleri (*Başlangıç, Güvenilir, Yıldız, Elit Şoför*).

---

## 🛠️ Teknoloji Yığını (Tech Stack)

- **Framework:** [Flutter](https://flutter.dev/) (Dart 3.x)
- **State Management:** Provider
- **Bulut & Veritabanı:** Firebase Core, Firebase Auth, Cloud Firestore
- **Harita & Jeopolitik Arama:** OpenStreetMap Nominatim REST API
- **QR Kod:** `qr_flutter`
- **Tasarım:** Custom Modern Dark Architecture (`AppTheme`, Custom Buttons, Glassmorphic Containers)

---

## 📂 Proje Dizin Yapısı

```text
versity_mobile/
├── assets/
│   └── images/              # Araç modelleri, logolar ve sürücü profilleri
├── lib/
│   ├── models/              # Ride, User ve Veri modelleri
│   ├── providers/           # Kimlik doğrulama ve oturum sağlayıcıları
│   ├── screens/             # Mobil ekranlar (Home, Search, Detail, Create, Rides, Profile)
│   ├── services/            # API, Harita, Firebase ve Ride servisleri
│   ├── theme/               # Renk paletleri, tipografi ve dark tema
│   ├── widgets/             # Yeniden kullanılabilir butonlar, inputlar ve saat bileşeni
│   └── main.dart            # Uygulama başlangıç noktası
├── android/                 # Android yerel yapılandırmaları
├── ios/                     # iOS yerel yapılandırmaları
├── pubspec.yaml             # Flutter bağımlılıkları ve varlık tanımları
└── README.md
```

---

## 🚀 Kurulum ve Çalıştırma

### Gereksinimler
- Flutter SDK (>= 3.0.0)
- Android Studio / VS Code ve Flutter eklentileri
- Android SDK veya bağlı fiziksel Android/iOS cihaz

### Adımlar

1. **Depoyu klonlayın:**
   ```bash
   git clone https://github.com/silakayast-prog/Versity-carsharing-for-students.git
   cd Versity-carsharing-for-students
   ```

2. **Bağımlılıkları yükleyin:**
   ```bash
   flutter pub get
   ```

3. **Uygulamayı çalıştırın:**
   ```bash
   # Bağlı cihazları listelemek için:
   flutter devices

   # Uygulamayı başlatmak için:
   flutter run
   ```

---

## 📄 Lisans

Bu proje eğitim ve üniversite içi ulaşım inovasyonu amacıyla geliştirilmiştir. Tüm hakları saklıdır.
