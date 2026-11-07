import 'package:flutter/material.dart';
import '../services/ride_service.dart';
import '../theme/app_theme.dart';

class MyRidesScreen extends StatelessWidget {
  const MyRidesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bookedRides = RideService.myBookedRides;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppTheme.vantaBlack,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            'Yolculuklarım',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppTheme.vantaTextLight),
          ),
          bottom: const TabBar(
            indicatorColor: AppTheme.vantaBlue,
            labelColor: AppTheme.vantaBlue,
            unselectedLabelColor: AppTheme.vantaTextMuted,
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            tabs: [
              Tab(text: 'Aktif'),
              Tab(text: 'Bekleyen'),
              Tab(text: 'Geçmiş'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildActiveRideList(context, bookedRides),
            _buildRideList(context, 'Bekleyen Talep', 'Yarın 09:00', 'Kampüs ➔ Otogar', false, 'Ahmet Y.'),
            _buildRideList(context, 'Tamamlanan Seyahat', '12 Mayıs', 'Konyaaltı ➔ Kampüs', false, 'Selin Kökçü'),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveRideList(BuildContext context, List<BookedRide> bookedRides) {
    if (bookedRides.isEmpty) {
      return ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          _buildRideTile(context, 'Aktif Yolculuk', 'Bugün 17:30', 'Antalya ➔ Alanya', true, 'Ahmet Y.'),
        ],
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      itemCount: bookedRides.length,
      itemBuilder: (context, index) {
        final b = bookedRides[index];
        return _buildRideTile(context, 'Rezerve Edildi (Aktif)', b.dateStr, b.route, true, b.driverName);
      },
    );
  }

  Widget _buildRideList(BuildContext context, String status, String dateStr, String routeStr, bool hasQr, String driverName) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      itemCount: 1,
      itemBuilder: (context, index) {
        return _buildRideTile(context, status, dateStr, routeStr, hasQr, driverName);
      },
    );
  }

  Widget _buildRideTile(BuildContext context, String status, String dateStr, String routeStr, bool hasQr, String driverName) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.vantaSurfaceDark,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.vantaBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.vantaCardDark,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.vantaBorder),
                ),
                child: Text(
                  status,
                  style: const TextStyle(color: AppTheme.vantaBlue, fontWeight: FontWeight.bold, fontSize: 11),
                ),
              ),
              Text(dateStr, style: const TextStyle(color: AppTheme.vantaTextMuted, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            routeStr,
            style: const TextStyle(color: AppTheme.vantaTextLight, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('$driverName (Sürücü)', style: const TextStyle(color: AppTheme.vantaTextMuted, fontSize: 13)),
                  if (hasQr)
                    ElevatedButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => const AlertDialog(
                            backgroundColor: AppTheme.vantaSurfaceDark,
                            title: Text('Biniş QR Kodu', style: TextStyle(color: AppTheme.vantaTextLight, fontWeight: FontWeight.bold)),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.qr_code_2_rounded, size: 140, color: AppTheme.vantaBlue),
                                SizedBox(height: 10),
                                Text('Araca binerken şoföre okutunuz.', style: TextStyle(color: AppTheme.vantaTextMuted, fontSize: 12)),
                              ],
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.vantaBlue,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: const Icon(Icons.qr_code_rounded, size: 16, color: AppTheme.vantaTextLight),
                      label: const Text('QR Göster', style: TextStyle(color: AppTheme.vantaTextLight, fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                ],
              ),
            ],
          ),
        );
  }
}
