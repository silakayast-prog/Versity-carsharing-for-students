import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.vantaBlack,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Bildirimler',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppTheme.vantaTextLight),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        itemCount: 4,
        itemBuilder: (context, index) {
          final titles = [
            'Rezervasyon Onaylandı 🎉',
            'Yeni Yolcu İsteği 🚗',
            'Yolculuk Anımsatması ⏰',
            'Puan Kazanıldı ⭐',
          ];
          final subtitles = [
            'Ahmet Y. yolculuk talebinizi kabul etti.',
            'Ahmet K. Antalya ➔ Alanya ilanınıza katıldı.',
            'Yolculuğunuz 30 dakika içinde başlıyor.',
            'Son yolculuğunuzdan +15 Üniversite Puanı kazandınız.',
          ];

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.vantaSurfaceDark,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.vantaBorder),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppTheme.vantaBlue.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.notifications_active_rounded, color: AppTheme.vantaBlue, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(titles[index], style: const TextStyle(color: AppTheme.vantaTextLight, fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 4),
                      Text(subtitles[index], style: const TextStyle(color: AppTheme.vantaTextMuted, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
