import 'package:flutter/material.dart';
import '../services/ride_service.dart';
import '../theme/app_theme.dart';
import 'ride_detail_screen.dart';

class RideSearchListScreen extends StatefulWidget {
  final String fromLocation;
  final String toLocation;

  const RideSearchListScreen({
    super.key,
    this.fromLocation = 'Antalya Kampüs',
    this.toLocation = 'Alanya Kent Meydanı',
  });

  @override
  State<RideSearchListScreen> createState() => _RideSearchListScreenState();
}

class _RideSearchListScreenState extends State<RideSearchListScreen> {
  int _selectedDateIndex = 0;

  final List<Map<String, String>> _dateItems = const [
    {'day': 'BUGÜN', 'date': '22'},
    {'day': 'YARIN', 'date': '23'},
    {'day': 'PZT', 'date': '24'},
    {'day': 'SAL', 'date': '25'},
    {'day': 'ÇAR', 'date': '26'},
    {'day': 'PER', 'date': '27'},
  ];

  @override
  Widget build(BuildContext context) {
    final rides = RideService.getRidesForRoute(widget.fromLocation, widget.toLocation);
    final String cleanFrom = widget.fromLocation.trim().isNotEmpty ? widget.fromLocation.trim() : 'Antalya Kampüs';
    final String cleanTo = widget.toLocation.trim().isNotEmpty ? widget.toLocation.trim() : 'Alanya Kent Meydanı';

    return Scaffold(
      backgroundColor: AppTheme.vantaBlack,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.vantaTextLight, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          children: [
            const Text(
              'Arama Sonuçları',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.vantaTextLight),
            ),
            Text(
              '$cleanFrom ➔ $cleanTo',
              style: const TextStyle(fontSize: 11, color: AppTheme.vantaBlue, fontWeight: FontWeight.w600),
            ),
          ],
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
              // Date Header Title
              const Text(
                'Salı, 16 Haziran 2026',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.vantaTextLight,
                ),
              ),

              const SizedBox(height: 14),

              // Horizontal Date Selector Pills
              SizedBox(
                height: 74,
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  itemCount: _dateItems.length,
                  itemBuilder: (context, index) {
                    final item = _dateItems[index];
                    final isSelected = _selectedDateIndex == index;

                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => setState(() => _selectedDateIndex = index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 58,
                        margin: const EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                          color: isSelected ? AppTheme.vantaWhite : AppTheme.vantaSurfaceDark,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: isSelected ? AppTheme.vantaWhite : AppTheme.vantaBorder,
                          ),
                          boxShadow: isSelected
                              ? [
                                  const BoxShadow(
                                    color: Color(0x33000000),
                                    blurRadius: 10,
                                    offset: Offset(0, 4),
                                  )
                                ]
                              : null,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              item['day']!,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? AppTheme.vantaTextDark : AppTheme.vantaTextMuted,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item['date']!,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? AppTheme.vantaTextDark : AppTheme.vantaTextLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 28),

              // Results Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${rides.length} Aktif Sefer Bulundu',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.vantaTextLight,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      'Tümünü Gör',
                      style: TextStyle(
                        color: AppTheme.vantaBlue,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // Vertical List of Ride Overview Cards
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: rides.length,
                itemBuilder: (context, index) {
                  final ride = rides[index];
                  final String driverName = ride.driverName;
                  final String rating = ride.rating;
                  final String trips = ride.trips;
                  final String badgeText = ride.badge;
                  final String fromTime = ride.fromTime;
                  final String fromCity = ride.fromLocation;
                  final String duration = ride.duration;
                  final String toTime = ride.toTime;
                  final String toCity = ride.toLocation;
                  final String price = ride.price;
                  final String seats = ride.seatsText;

                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => RideDetailScreen(
                            driverName: driverName,
                            rating: rating,
                            tripsCount: trips,
                            price: price,
                            fromTime: fromTime,
                            fromLocation: fromCity,
                            toTime: toTime,
                            toLocation: toCity,
                            vehicleType: ride.vehicleType,
                            driverDescription: ride.driverDescription,
                            rideItem: ride,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppTheme.vantaSurfaceDark,
                        borderRadius: BorderRadius.circular(26),
                        border: Border.all(color: AppTheme.vantaBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Driver Row
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundColor: AppTheme.vantaBlue,
                                backgroundImage: driverName.contains('Ahmet') ? const AssetImage('assets/images/profile_ahmet.png') :
                                  (driverName.contains('Ayşe') ? const AssetImage('assets/images/profile_ayse.png') :
                                  (driverName.contains('Selin') ? const AssetImage('assets/images/profile_selin.png') : 
                                  (driverName.contains('Leyla') ? const AssetImage('assets/images/profile_leyla.jpg') : 
                                  (driverName.contains('Fatmanur') ? const AssetImage('assets/images/profile_fatmanur.jpg') : null)))),
                                child: (driverName.contains('Ahmet') || driverName.contains('Ayşe') || driverName.contains('Selin') || driverName.contains('Leyla') || driverName.contains('Fatmanur')) ? null : Text(
                                  driverName[0],
                                  style: const TextStyle(color: AppTheme.vantaTextLight, fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          driverName,
                                          style: const TextStyle(color: AppTheme.vantaTextLight, fontWeight: FontWeight.bold, fontSize: 14),
                                        ),
                                        const SizedBox(width: 6),
                                        const Icon(Icons.star_rounded, color: AppTheme.vantaBlue, size: 14),
                                        const SizedBox(width: 2),
                                        Text(rating, style: const TextStyle(color: AppTheme.vantaBlue, fontSize: 12, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '🚗 $trips',
                                      style: const TextStyle(color: AppTheme.vantaTextMuted, fontSize: 11),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppTheme.vantaCardDark,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppTheme.vantaBorder),
                                ),
                                child: Text(
                                  badgeText,
                                  style: const TextStyle(color: AppTheme.vantaTextMuted, fontSize: 11, fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 18),

                          // Route Time & Cities Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(fromTime, style: const TextStyle(color: AppTheme.vantaTextLight, fontWeight: FontWeight.bold, fontSize: 16)),
                                  const SizedBox(height: 2),
                                  Text(fromCity, style: const TextStyle(color: AppTheme.vantaTextMuted, fontSize: 12)),
                                ],
                              ),
                              Column(
                                children: [
                                  const Icon(Icons.directions_car_rounded, color: AppTheme.vantaTextMuted, size: 16),
                                  const SizedBox(height: 2),
                                  Text(duration, style: const TextStyle(color: AppTheme.vantaTextMuted, fontSize: 10)),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(toTime, style: const TextStyle(color: AppTheme.vantaTextLight, fontWeight: FontWeight.bold, fontSize: 16)),
                                  const SizedBox(height: 2),
                                  Text(toCity, style: const TextStyle(color: AppTheme.vantaTextMuted, fontSize: 12)),
                                ],
                              ),
                            ],
                          ),

                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 14.0),
                            child: Divider(color: AppTheme.vantaBorder, height: 1),
                          ),

                          // Price & Seats Available Pill
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(price, style: const TextStyle(color: AppTheme.vantaTextLight, fontWeight: FontWeight.bold, fontSize: 16)),
                                  const Text('yolcu başı', style: TextStyle(color: AppTheme.vantaTextMuted, fontSize: 10)),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: AppTheme.vantaCardDark,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: AppTheme.vantaBorder),
                                ),
                                child: Text(
                                  seats,
                                  style: const TextStyle(color: AppTheme.vantaTextLight, fontSize: 11, fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
