import 'firebase_service.dart';

class RideItem {
  final String id;
  final String driverName;
  final String rating;
  final String trips;
  final String badge;
  final String fromTime;
  final String fromLocation;
  final String duration;
  final String toTime;
  final String toLocation;
  final String price;
  int availableSeatCount;
  final String vehicleType;
  final String? driverDescription;

  RideItem({
    required this.id,
    required this.driverName,
    required this.rating,
    required this.trips,
    required this.badge,
    required this.fromTime,
    required this.fromLocation,
    required this.duration,
    required this.toTime,
    required this.toLocation,
    required this.price,
    required this.availableSeatCount,
    required this.vehicleType,
    this.driverDescription,
  });

  String get seatsText {
    if (availableSeatCount <= 0) return 'Doldu (Koltuk Kalmadı)';
    if (availableSeatCount == 1) return 'Son 1 koltuk kaldı';
    return '$availableSeatCount koltuk müsait';
  }
}

class BookedRide {
  final String id;
  final String driverName;
  final String route;
  final String dateStr;
  final String price;
  final DateTime bookedAt;

  BookedRide({
    required this.id,
    required this.driverName,
    required this.route,
    required this.dateStr,
    required this.price,
    required this.bookedAt,
  });
}

class RideService {
  static final List<RideItem> _userCreatedRides = [];
  static final Map<String, int> _seatCounts = {
    'driver-1': 3,
    'driver-2': 3,
    'driver-3': 2,
    'driver-4': 3,
    'driver-5': 1,
  };

  static final List<BookedRide> _myBookedRides = [];

  static List<BookedRide> get myBookedRides => List.unmodifiable(_myBookedRides);

  static void addRide(RideItem ride) {
    _userCreatedRides.insert(0, ride);
    _seatCounts[ride.id] = ride.availableSeatCount;
    FirebaseService.createRideInFirestore(ride);
  }

  static bool bookSeat(RideItem ride) {
    int current = _seatCounts[ride.id] ?? ride.availableSeatCount;
    if (current > 0) {
      _seatCounts[ride.id] = current - 1;
      ride.availableSeatCount = current - 1;
      FirebaseService.bookSeatInFirestore(ride.id);

      // Add to user's booked rides
      _myBookedRides.insert(
        0,
        BookedRide(
          id: 'booking-${DateTime.now().millisecondsSinceEpoch}',
          driverName: ride.driverName,
          route: '${ride.fromLocation} ➔ ${ride.toLocation}',
          dateStr: 'Bugün ${ride.fromTime}',
          price: ride.price,
          bookedAt: DateTime.now(),
        ),
      );
      return true;
    }
    return false;
  }

  static int getAvailableSeats(String rideId, int defaultSeats) {
    return _seatCounts[rideId] ?? defaultSeats;
  }

  static List<RideItem> getRidesForRoute(String from, String to) {
    final String cleanFrom = from.trim().isNotEmpty ? from.trim() : 'Antalya Kampüs';
    final String cleanTo = to.trim().isNotEmpty ? to.trim() : 'Alanya Kent Meydanı';

    final List<RideItem> results = [];

    for (var r in _userCreatedRides) {
      r.availableSeatCount = _seatCounts[r.id] ?? r.availableSeatCount;
      results.add(r);
    }

    final defaultDrivers = [
      RideItem(
        id: 'driver-1',
        driverName: 'Ahmet Y.',
        rating: '4.8',
        trips: '23 Sürüş',
        badge: 'En Uygun',
        fromTime: '08:30',
        fromLocation: cleanFrom,
        duration: '35dk',
        toTime: '09:05',
        toLocation: cleanTo,
        price: '250 TL',
        availableSeatCount: _seatCounts['driver-1'] ?? 3,
        vehicleType: 'clio',
        driverDescription: 'Sabah derslerine genelde bu araçla geçiyorum. Arabada müzik hep açıktır (genelde rap/hip-hop), isterseniz Bluetooth\'u size de salarım.\n\nKurallarım çok basit:\n\nBeklemeyi pek sevmem, anlaştığımız saatte konumda olursanız süper olur.\n\nF1 veya arabalardan anlıyorsanız yol muhabbetle hemen biter. 🏎️\n\nGüzergah uyuyorsa Versity üzerinden eşleşelim, kampüse hızlı ve sorunsuz geçeriz. Görüşürüz. 😎',
      ),
      RideItem(
        id: 'driver-2',
        driverName: 'Ayşe K.',
        rating: '4.9',
        trips: '45 Sürüş',
        badge: 'En Hızlı',
        fromTime: '09:15',
        fromLocation: cleanFrom,
        duration: '40dk',
        toTime: '09:55',
        toLocation: cleanTo,
        price: '220 TL',
        availableSeatCount: _seatCounts['driver-2'] ?? 3,
        vehicleType: 'egea',
      ),
      RideItem(
        id: 'driver-3',
        driverName: 'Selin Kökçü',
        rating: '4.7',
        trips: '18 Sürüş',
        badge: 'En Popüler',
        fromTime: '10:30',
        fromLocation: cleanFrom,
        duration: '30dk',
        toTime: '11:00',
        toLocation: cleanTo,
        price: '280 TL',
        availableSeatCount: _seatCounts['driver-3'] ?? 2,
        vehicleType: 'mini',
        driverDescription: 'Sabah kahvelerimizi içtiysek kırmızı Mini\'mle kampüs yollarına düşmeye hazırız demektir! Genelde sabah erken derslere yetişiyor ve öğleden sonraları dönüyorum. Rotalarımız eşleşiyorsa yolculuğuma seve seve ortak olabilirsiniz. 🚘\n\nAraçta müzikler benden (yol moduna göre hazırladığım Spotify listelerim bayağı iyidir 🎶)',
      ),
      RideItem(
        id: 'driver-4',
        driverName: 'Leyla Kaya',
        rating: '4.9',
        trips: '32 Sürüş',
        badge: 'VIP Konfor',
        fromTime: '12:00',
        fromLocation: cleanFrom,
        duration: '25dk',
        toTime: '12:25',
        toLocation: cleanTo,
        price: '290 TL',
        availableSeatCount: _seatCounts['driver-4'] ?? 3,
        vehicleType: 'audi',
        driverDescription: 'Selam. 🖤\n\nKampüs yolunda aracıma katılabilirsiniz. Sabahları genellikle sessizliği, sade bir kahveyi ve kendi çalma listemi tercih ederim. Gereksiz sohbetlerden ziyade, huzurlu ve kaliteli bir yolculuk önceliğimdir.\n\nTek kuralım dakiklik ve kişisel alana saygı. Bekletilmeyi hiç sevmem. Vaktinde konumda olacaksanız ve sakin bir yolculuk arıyorsanız eşleşebiliriz. Görüşmek üzere. 🕶️',
      ),
      RideItem(
        id: 'driver-5',
        driverName: 'Fatmanur Şen',
        rating: '5.0',
        trips: '50 Sürüş',
        badge: 'Lüks Sefer',
        fromTime: '14:00',
        fromLocation: cleanFrom,
        duration: '25dk',
        toTime: '14:25',
        toLocation: cleanTo,
        price: '260 TL',
        availableSeatCount: _seatCounts['driver-5'] ?? 1,
        vehicleType: 'maserati',
        driverDescription: 'Selam! ✨\n\nSabahları kampüse Maserati ile geçiyorum ve yolda kaliteli sohbet edebileceğim bir eşlikçi fena olmaz diye düşündüm.\n\nAçıkçası yolculuk masrafı veya uygulama içi ücretler gibi detaylarla hiç ilgilenmiyorum. Kampüse vardığımızda bana sevdiğim yerden güzel bir filtre kahve ısmarlamanız yol arkadaşlığınız için fazlasıyla yeterli. ☕️\n\nYalnızca net bir kırmızı çizgim var: Arabamın içinde sigara veya elektronik sigara içilmesi kesinlikle yasaktır. Orijinal deri koltukların kokusunu ve dokusunu korumamız şart. 💅\n\nTemiz, konforlu ve keyifli bir yolculuk arıyorsanız eşleşebiliriz. Kampüste görüşmek üzere! 🤍',
      ),
    ];

    results.addAll(defaultDrivers);
    return results;
  }
}
