import 'package:flutter/material.dart';
import '../services/ride_service.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_button.dart';

class RideDetailScreen extends StatefulWidget {
  final String driverName;
  final String rating;
  final String tripsCount;
  final String price;
  final String fromTime;
  final String fromLocation;
  final String toTime;
  final String toLocation;
  final String vehicleType;
  final String? driverDescription;
  final RideItem? rideItem;

  const RideDetailScreen({
    super.key,
    this.driverName = 'Ahmet Y.',
    this.rating = '4.8',
    this.tripsCount = '23 Sürüş',
    this.price = '250 TL',
    this.fromTime = '08:30',
    this.fromLocation = 'Antalya Güney Kampüsü',
    this.toTime = '10:45',
    this.toLocation = 'Alanya Kent Meydanı',
    this.vehicleType = 'clio',
    this.driverDescription,
    this.rideItem,
  });

  @override
  State<RideDetailScreen> createState() => _RideDetailScreenState();
}

class _RideDetailScreenState extends State<RideDetailScreen> {
  late RideItem _currentRide;
  bool _isBooked = false;

  @override
  void initState() {
    super.initState();
    _currentRide = widget.rideItem ??
        RideItem(
          id: 'temp-${widget.driverName}',
          driverName: widget.driverName,
          rating: widget.rating,
          trips: widget.tripsCount,
          badge: 'En Uygun',
          fromTime: widget.fromTime,
          fromLocation: widget.fromLocation,
          duration: '35dk',
          toTime: widget.toTime,
          toLocation: widget.toLocation,
          price: widget.price,
          availableSeatCount: 3,
          vehicleType: widget.vehicleType,
          driverDescription: widget.driverDescription,
        );
  }

  Widget _buildFeatureChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.vantaCardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.vantaBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppTheme.vantaBlue, size: 16),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(color: AppTheme.vantaTextLight, fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  void _showVehicleDetailsModal(BuildContext context) {
    final isMini = widget.vehicleType == 'mini';
    final isEgea = widget.vehicleType == 'egea';
    final isMaserati = widget.vehicleType == 'maserati';
    final isAudi = widget.vehicleType == 'audi';
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        int currentIndex = 0;
        
        final images = isAudi ? [
          'assets/images/audi_front.jpg',
          'assets/images/audi_side.jpg',
          'assets/images/audi_interior.jpg',
        ] : (isMaserati ? [
          'assets/images/maserati_front.png',
          'assets/images/maserati_side.png',
          'assets/images/maserati_interior.png',
        ] : (isMini ? [
          'assets/images/media_1786014077278.jpg',
          'assets/images/media_1786014216437.jpg',
          'assets/images/media_1786014299714.png',
        ] : (isEgea ? [
          'assets/images/egea_front.png',
          'assets/images/egea_side.png',
          'assets/images/egea_back.jpg',
        ] : [
          'assets/images/clio_front.png',
          'assets/images/clio_side1.jpg',
          'assets/images/clio_side2.jpg',
          'assets/images/clio_interior.jpg',
        ])));

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              decoration: const BoxDecoration(
                color: AppTheme.vantaSurfaceDark,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 48,
                    height: 5,
                    decoration: BoxDecoration(color: AppTheme.vantaBorder, borderRadius: BorderRadius.circular(10)),
                  ),
                  const SizedBox(height: 16),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Araç Detayları', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.vantaTextLight)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Image Carousel
                  SizedBox(
                    height: 220,
                    child: Stack(
                      children: [
                        PageView.builder(
                          itemCount: images.length,
                          onPageChanged: (index) {
                            setState(() {
                              currentIndex = index;
                            });
                          },
                          itemBuilder: (context, index) {
                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 20),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                image: DecorationImage(
                                  image: AssetImage(images[index]),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            );
                          },
                        ),
                        // Indicator
                        Positioned(
                          bottom: 12,
                          left: 0,
                          right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(images.length, (index) {
                              return Container(
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                width: currentIndex == index ? 20 : 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: currentIndex == index ? AppTheme.vantaBlue : AppTheme.vantaTextMuted.withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              );
                            }),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Vehicle Details
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (widget.driverDescription != null) ...[
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppTheme.vantaCardDark,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppTheme.vantaBlue.withValues(alpha: 0.3)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.format_quote_rounded, color: AppTheme.vantaBlue, size: 20),
                                      const SizedBox(width: 8),
                                      Text('Sürücü Notu', style: TextStyle(color: AppTheme.vantaBlue.withValues(alpha: 0.8), fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    widget.driverDescription!,
                                    style: const TextStyle(fontSize: 13, color: AppTheme.vantaTextMuted, height: 1.5),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],
                          Text(isAudi ? 'Audi RS Q3' : (isMaserati ? 'Maserati GranTurismo (4.7 V8)' : (isMini ? 'Mini Cooper (1.5)' : (isEgea ? 'Fiat Egea (1.4 Fire)' : 'Renault Clio 4 (1.5 dCi)'))), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppTheme.vantaTextLight)),
                          const SizedBox(height: 4),
                          Text(isAudi ? '2022 Model • 2 Yıllık • Siyah' : (isMaserati ? '2015 Model • 9 Yıllık • Bordo' : (isMini ? '2019 Model • 5 Yıllık • Kırmızı' : (isEgea ? '2021 Model • 3 Yıllık • Beyaz' : '2018 Model • 6 Yıllık • Beyaz'))), style: const TextStyle(fontSize: 14, color: AppTheme.vantaTextMuted)),
                          const SizedBox(height: 8),
                          if (!isEgea && !isMini && !isMaserati && !isAudi)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppTheme.vantaCardDark,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppTheme.vantaBorder),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.car_crash_rounded, color: Colors.orange, size: 16),
                                  SizedBox(width: 6),
                                  Text('Tramer (Hasar Kaydı): 4.500 TL (Sol ön çamurluk)', style: TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          if (!isEgea) const SizedBox(height: 24),
                          const Text('Araç Özellikleri', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.vantaTextLight)),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              _buildFeatureChip(Icons.ac_unit_rounded, 'Klima'),
                              _buildFeatureChip(Icons.usb_rounded, 'USB Şarj'),
                              _buildFeatureChip(Icons.bluetooth_rounded, 'Bluetooth'),
                              _buildFeatureChip(Icons.eco_rounded, 'Eco Mod'),
                            ],
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _handleBookSeat(BuildContext context) {
    final success = RideService.bookSeat(_currentRide);
    if (success) {
      setState(() {
        _isBooked = true;
      });

      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppTheme.vantaSurfaceDark,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: AppTheme.vantaBlue, size: 28),
              SizedBox(width: 10),
              Text('Rezervasyon Başarılı', style: TextStyle(color: AppTheme.vantaTextLight, fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${widget.driverName} sürücülü seyahat için 1 kişilik yeriniz ayrılmıştır. "Yolculuklarım" sekmesinden biniş QR kodunuza ulaşabilirsiniz.',
                style: const TextStyle(color: AppTheme.vantaTextMuted, fontSize: 14, height: 1.4),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.vantaCardDark,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.vantaBorder),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Güncel Koltuk Durumu:', style: TextStyle(color: AppTheme.vantaTextMuted, fontSize: 12)),
                    Text(
                      _currentRide.seatsText,
                      style: const TextStyle(color: AppTheme.vantaBlue, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.vantaBlue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Tamamdır', style: TextStyle(color: AppTheme.vantaTextLight, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.vantaBlack,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.vantaTextLight, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Sürücü ve Sefer Detayları',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.vantaTextLight),
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.vantaSurfaceDark,
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.vantaBorder),
            ),
            child: const Icon(Icons.tune_rounded, color: AppTheme.vantaTextLight, size: 18),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Driver & Vehicle Card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppTheme.vantaSurfaceDark,
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(color: AppTheme.vantaBorder),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: AppTheme.vantaBlue,
                      backgroundImage: widget.driverName.contains('Ahmet') ? const AssetImage('assets/images/profile_ahmet.png') :
                        (widget.driverName.contains('Ayşe') ? const AssetImage('assets/images/profile_ayse.png') :
                        (widget.driverName.contains('Selin') ? const AssetImage('assets/images/profile_selin.png') : 
                        (widget.driverName.contains('Leyla') ? const AssetImage('assets/images/profile_leyla.jpg') : 
                        (widget.driverName.contains('Fatmanur') ? const AssetImage('assets/images/profile_fatmanur.jpg') : null)))),
                      child: (widget.driverName.contains('Ahmet') || widget.driverName.contains('Ayşe') || widget.driverName.contains('Selin') || widget.driverName.contains('Leyla') || widget.driverName.contains('Fatmanur')) ? null : Text(
                        widget.driverName[0],
                        style: const TextStyle(color: AppTheme.vantaTextLight, fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.driverName,
                            style: const TextStyle(color: AppTheme.vantaTextLight, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.star_rounded, color: AppTheme.vantaBlue, size: 14),
                              const SizedBox(width: 3),
                              Text(widget.rating, style: const TextStyle(color: AppTheme.vantaBlue, fontSize: 12, fontWeight: FontWeight.bold)),
                              const SizedBox(width: 10),
                              const Icon(Icons.directions_car_rounded, color: AppTheme.vantaTextMuted, size: 14),
                              const SizedBox(width: 3),
                              Text(widget.tripsCount, style: const TextStyle(color: AppTheme.vantaTextMuted, fontSize: 12)),
                            ],
                          ),
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
                                Text(
                                  'Onaylı Sürücü',
                                  style: TextStyle(color: AppTheme.vantaWhite, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Vehicle Box
                    GestureDetector(
                      onTap: () => _showVehicleDetailsModal(context),
                      child: Container(
                        width: 90,
                        height: 60,
                        decoration: BoxDecoration(
                          color: AppTheme.vantaCardDark,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.vantaBorder),
                        ),
                        child: const Icon(
                          Icons.directions_car_filled_rounded,
                          color: AppTheme.vantaBlue,
                          size: 40,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Route Timeline Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.vantaSurfaceDark,
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(color: AppTheme.vantaBorder),
                ),
                child: Column(
                  children: [
                    // From Departure Row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.fromTime,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.vantaTextLight),
                        ),
                        const SizedBox(width: 14),
                        const Icon(Icons.circle, color: AppTheme.vantaBlue, size: 12),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.fromLocation,
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.vantaTextLight),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'Güney Kampüsü 18. Durak, Antalya',
                                style: TextStyle(fontSize: 12, color: AppTheme.vantaTextMuted),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const Padding(
                      padding: EdgeInsets.only(left: 70.0, top: 8.0, bottom: 8.0),
                      child: Divider(color: AppTheme.vantaBorder, height: 1),
                    ),

                    // To Arrival Row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.toTime,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.vantaTextLight),
                        ),
                        const SizedBox(width: 14),
                        const Icon(Icons.location_on_rounded, color: AppTheme.vantaBlue, size: 16),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.toLocation,
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.vantaTextLight),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'Kent Meydanı Saat Kulesi Yanı',
                                style: TextStyle(fontSize: 12, color: AppTheme.vantaTextMuted),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Amenities Row Chips
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildAmenityChip(Icons.access_time_rounded, '2s 15dk'),
                        _buildAmenityChip(Icons.alt_route_rounded, 'Direkt'),
                        _buildAmenityChip(Icons.smoke_free_rounded, 'Sigarasız'),
                        _buildAmenityChip(Icons.music_note_rounded, 'Müzikli'),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Booking & Payment Summary Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.vantaSurfaceDark,
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(color: AppTheme.vantaBorder),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Koltuk Seçiminiz',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.vantaTextLight),
                            ),
                            SizedBox(height: 2),
                            Text(
                              '1 Yolcu',
                              style: TextStyle(fontSize: 12, color: AppTheme.vantaTextMuted),
                            ),
                          ],
                        ),
                        Text(
                          widget.price,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.vantaTextLight),
                        ),
                      ],
                    ),

                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14.0),
                      child: Divider(color: AppTheme.vantaBorder, height: 1),
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Ödeme Yöntemi',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.vantaTextLight),
                            ),
                            SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.credit_card_rounded, color: AppTheme.vantaBlue, size: 16),
                                SizedBox(width: 6),
                                Text(
                                  '•••• 4242',
                                  style: TextStyle(fontSize: 13, color: AppTheme.vantaTextLight, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: () {},
                          child: const Text(
                            'Değiştir',
                            style: TextStyle(
                              color: AppTheme.vantaBlue,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Dynamic Primary CTA 'Koltuk Rezerve Et'
              CustomButton.primary(
                text: _isBooked
                    ? 'Rezerve Edildi (Kalan: ${_currentRide.availableSeatCount})'
                    : (_currentRide.availableSeatCount <= 0
                        ? 'Doldu (Koltuk Kalmadı)'
                        : 'Koltuk Rezerve Et (${_currentRide.seatsText})'),
                onPressed: (_currentRide.availableSeatCount <= 0 || _isBooked)
                    ? null
                    : () => _handleBookSeat(context),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAmenityChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.vantaCardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.vantaBorder),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppTheme.vantaTextMuted, size: 18),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: AppTheme.vantaTextLight, fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
