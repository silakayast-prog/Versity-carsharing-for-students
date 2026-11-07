import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isDriverMode = false;

  void _showQRCodeModal(BuildContext context, String userName) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.vantaSurfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(28),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 48,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppTheme.vantaBorder,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Biniş QR Kodunuz (HMAC-SHA256)',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.vantaTextLight),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Araca binerken bu QR kodu şoföre okutunuz. 15 dakika geçerlidir.',
                  style: TextStyle(fontSize: 12, color: AppTheme.vantaTextMuted),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: QrImageView(
                    data: 'VERSITY-BOARDING-QR-$userName-2026',
                    version: QrVersions.auto,
                    size: 200.0,
                  ),
                ),
                const SizedBox(height: 24),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.timer_outlined, color: AppTheme.vantaBlue, size: 18),
                    SizedBox(width: 6),
                    Text(
                      'Kalan Geçerlilik: 14:52 dk',
                      style: TextStyle(color: AppTheme.vantaBlue, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDriverRewardsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.vantaSurfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '🏆 Şoför Ödülleri & Rozet Seviyeleri',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.vantaTextLight),
                ),
                const SizedBox(height: 14),
                _buildRewardTierItem('Elit Rozet (1000+ Puan)', '400 TL yemek kartı + Kampüs Özel Otopark + Özel Çalışma Odası', true),
                _buildRewardTierItem('Yıldız Rozet (500-999 Puan)', '250 TL yemek kartı kredisi + %10 Yemekhane indirimi', false),
                _buildRewardTierItem('Güvenilir Rozet (200-499 Puan)', '100 TL aylık yemek kartı yüklemesi', false),
                _buildRewardTierItem('Başlangıç Rozet (0-199 Puan)', 'Sürücü profili rozeti ve öncelikli ilan yayını', false),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRewardTierItem(String title, String desc, bool isCurrent) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isCurrent ? AppTheme.vantaBlue.withValues(alpha: 0.15) : AppTheme.vantaCardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isCurrent ? AppTheme.vantaBlue : AppTheme.vantaBorder),
      ),
      child: Row(
        children: [
          Icon(
            isCurrent ? Icons.military_tech_rounded : Icons.workspace_premium_rounded,
            color: isCurrent ? AppTheme.vantaBlue : AppTheme.vantaTextMuted,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: isCurrent ? AppTheme.vantaBlue : AppTheme.vantaTextLight, fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 2),
                Text(desc, style: const TextStyle(color: AppTheme.vantaTextMuted, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.user;
    final String name = user?.adSoyad ?? 'Alex Martínez';
    final String email = user?.okulEmail ?? 'alex@ogrenci.antalyabilim.edu.tr';

    return Scaffold(
      backgroundColor: AppTheme.vantaBlack,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Versity Profilim & Ayarlar',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppTheme.vantaTextLight),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          children: [
            // Profile Card Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.vantaSurfaceDark,
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: AppTheme.vantaBorder),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: AppTheme.vantaBlue,
                    child: Text(
                      name[0],
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.vantaTextLight),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.vantaTextLight)),
                        const SizedBox(height: 4),
                        Text(email, style: const TextStyle(fontSize: 12, color: AppTheme.vantaTextMuted)),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppTheme.vantaCardDark,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppTheme.vantaBorder),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.verified_rounded, color: AppTheme.vantaWhite, size: 12),
                              SizedBox(width: 4),
                              Text('Onaylı Öğrenci (4.9 ★)', style: TextStyle(color: AppTheme.vantaWhite, fontSize: 10, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Active Role Switcher Card (FR-07)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.vantaSurfaceDark,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: AppTheme.vantaBorder),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          _isDriverMode ? Icons.time_to_leave_rounded : Icons.person_pin_circle_rounded,
                          color: AppTheme.vantaBlue,
                          size: 22,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _isDriverMode ? 'Aktif Rol: Sürücü 🚗' : 'Aktif Rol: Yolcu 🎒',
                                style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.vantaTextLight, fontSize: 14),
                              ),
                              Text(
                                _isDriverMode ? 'İlan verebilir ve yolcu alabilirsiniz' : 'Yolculuk arayabilir ve koltuk ayırabilirsiniz',
                                style: const TextStyle(color: AppTheme.vantaTextMuted, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _isDriverMode,
                    activeThumbColor: AppTheme.vantaBlue,
                    onChanged: (val) {
                      setState(() => _isDriverMode = val);
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Driver Badge / Rewards Dashboard Card
            if (_isDriverMode)
              GestureDetector(
              onTap: () => _showDriverRewardsModal(context),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppTheme.vantaSurfaceDark,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppTheme.vantaBorder),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: AppTheme.vantaBlue,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.military_tech_rounded, color: AppTheme.vantaTextLight, size: 24),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Elit Şoför Rozeti (1240 Puan)', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.vantaTextLight, fontSize: 14)),
                          SizedBox(height: 2),
                          Text('Kampüs özel otopark + 400 TL yemek kredisi aktif', style: TextStyle(color: AppTheme.vantaTextMuted, fontSize: 11)),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded, color: AppTheme.vantaTextMuted),
                  ],
                ),
              ),
            ),

            if (_isDriverMode) const SizedBox(height: 16),

            // Profile Actions List
            if (!_isDriverMode)
              _buildProfileTile(
                Icons.qr_code_2_rounded,
                'Biniş QR Kodum',
                'Sürücüye okutmak için tıkla',
                onTap: () => _showQRCodeModal(context, name),
              ),
            _buildProfileTile(
              Icons.star_rounded,
              'Versity Premium (400 TL/ay)',
              '30 Ücretsiz Biniş Hakkı + Öncelikli Binme',
              badge: 'Abonelik Aktif',
            ),
            if (_isDriverMode)
              _buildProfileTile(Icons.directions_car_rounded, 'Araç Bilgilerim & Garaj', 'BMW X5 (34 BC 123) - 3 Koltuk'),
            _buildProfileTile(Icons.favorite_rounded, 'Favori Rotalarım', 'Kampüs ➔ Konyaaltı, Otogar'),
            _buildProfileTile(Icons.security_rounded, 'Güvenlik & KVKK Onayları', 'Doğrulanmış Öğrenci Hesabı'),
            _buildProfileTile(Icons.logout_rounded, 'Çıkış Yap', 'Oturumu kapat', isDanger: true, onTap: () {
              auth.logout();
              Navigator.of(context).popUntil((route) => route.isFirst);
            }),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileTile(IconData icon, String title, String subtitle, {String? badge, bool isDanger = false, VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: AppTheme.vantaSurfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppTheme.vantaBorder),
        ),
        child: ListTile(
        leading: Icon(icon, color: isDanger ? AppTheme.dangerRed : AppTheme.vantaBlue),
        title: Row(
          children: [
            Expanded(child: Text(title, style: TextStyle(color: isDanger ? AppTheme.dangerRed : AppTheme.vantaTextLight, fontWeight: FontWeight.bold, fontSize: 14))),
            if (badge != null) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.vantaBlue.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(badge, style: const TextStyle(color: AppTheme.vantaBlue, fontSize: 9, fontWeight: FontWeight.bold)),
              ),
            ],
          ],
        ),
        subtitle: Text(subtitle, style: const TextStyle(color: AppTheme.vantaTextMuted, fontSize: 11)),
        trailing: const Icon(Icons.chevron_right_rounded, color: AppTheme.vantaTextMuted),
        onTap: onTap,
      ),
    ),
  );
}
}
