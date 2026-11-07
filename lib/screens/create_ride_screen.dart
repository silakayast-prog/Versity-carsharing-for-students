import 'dart:async';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/ride_service.dart';
import '../theme/app_theme.dart';

class CreateRideScreen extends StatefulWidget {
  const CreateRideScreen({super.key});

  @override
  State<CreateRideScreen> createState() => _CreateRideScreenState();
}

class _CreateRideScreenState extends State<CreateRideScreen> {
  final TextEditingController _fromController = TextEditingController(text: 'Antalya Kampüs');
  final TextEditingController _toController = TextEditingController(text: 'Alanya Kent Meydanı');

  final FocusNode _fromFocus = FocusNode();
  final FocusNode _toFocus = FocusNode();

  Timer? _debounce;
  List<String> _suggestions = [];
  bool _isSearchingLocation = false;
  String _activeSearchField = ''; // 'from' or 'to'

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = const TimeOfDay(hour: 8, minute: 30);
  int _availableSeats = 3;
  double _pricePerSeat = 230;

  @override
  void initState() {
    super.initState();
    _fromFocus.addListener(_onFocusChange);
    _toFocus.addListener(_onFocusChange);

    _fromController.addListener(() => _onSearchChanged('from', _fromController.text));
    _toController.addListener(() => _onSearchChanged('to', _toController.text));
  }

  void _onFocusChange() {
    if (_fromFocus.hasFocus) {
      setState(() => _activeSearchField = 'from');
      _onSearchChanged('from', _fromController.text);
    } else if (_toFocus.hasFocus) {
      setState(() => _activeSearchField = 'to');
      _onSearchChanged('to', _toController.text);
    } else {
      _debounce?.cancel();
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted && !_fromFocus.hasFocus && !_toFocus.hasFocus) {
          setState(() {
            _isSearchingLocation = false;
            _suggestions = [];
            _activeSearchField = '';
          });
        }
      });
    }
  }

  void _onSearchChanged(String field, String query) {
    if (_activeSearchField != field) return;
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    if (query.trim().isEmpty) {
      setState(() {
        _isSearchingLocation = false;
        _suggestions = [];
      });
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 300), () async {
      if (!mounted || _activeSearchField != field) return;
      setState(() => _isSearchingLocation = true);

      try {
        final results = await ApiService.searchLocations(query);
        if (mounted && _activeSearchField == field) {
          setState(() {
            _suggestions = results;
            _isSearchingLocation = false;
          });
        }
      } catch (_) {
        if (mounted) setState(() => _isSearchingLocation = false);
      }
    });
  }

  void _swapLocations() {
    setState(() {
      final temp = _fromController.text;
      _fromController.text = _toController.text;
      _toController.text = temp;
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 60)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.vantaBlue,
              onPrimary: Colors.black,
              surface: AppTheme.vantaSurfaceDark,
              onSurface: AppTheme.vantaTextLight,
            ),
            dialogBackgroundColor: AppTheme.vantaCardDark,
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.vantaBlue,
              onPrimary: Colors.black,
              surface: AppTheme.vantaSurfaceDark,
              onSurface: AppTheme.vantaTextLight,
            ),
            dialogBackgroundColor: AppTheme.vantaCardDark,
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  void _publishRide() {
    final formattedTime = '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}';
    
    RideService.addRide(
      RideItem(
        id: 'user-ride-${DateTime.now().millisecondsSinceEpoch}',
        driverName: 'Siz (Yeni İlan)',
        rating: '5.0',
        trips: 'Yeni',
        badge: 'Senin İlanın',
        fromTime: formattedTime,
        fromLocation: _fromController.text,
        duration: '30dk',
        toTime: formattedTime,
        toLocation: _toController.text,
        price: '${_pricePerSeat.toInt()} TL',
        availableSeatCount: _availableSeats,
        vehicleType: 'clio',
      ),
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.vantaSurfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: AppTheme.vantaBlue, size: 28),
            SizedBox(width: 10),
            Text(
              'İlan Yayınlandı!',
              style: TextStyle(color: AppTheme.vantaTextLight, fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${_fromController.text} ➔ ${_toController.text} güzergahlı yolculuk ilanınız başarıyla oluşturuldu.',
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
                  Text(
                    'Kapasite: $_availableSeats Koltuk',
                    style: const TextStyle(color: AppTheme.vantaTextLight, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    '${_pricePerSeat.toInt()} TL / Yolcu',
                    style: const TextStyle(color: AppTheme.vantaBlue, fontSize: 13, fontWeight: FontWeight.bold),
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

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    _fromFocus.dispose();
    _toFocus.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const months = ['Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz', 'Tem', 'Ağu', 'Eyl', 'Eki', 'Kas', 'Ara'];
    final formattedDate = '${_selectedDate.day} ${months[_selectedDate.month - 1]}';
    final formattedTime = '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}';

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
          'Yolculuk Paylaş',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.vantaTextLight),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. ROTA SEÇİM KARTI (Açık Lacivert #112240)
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFF112240), // Özel Açık Lacivert Kart
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppTheme.vantaBorder.withOpacity(0.8)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x33000000),
                      blurRadius: 16,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.centerRight,
                  children: [
                    Column(
                      children: [
                        // Nereden Input
                        Row(
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: AppTheme.vantaBlue.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: Icon(Icons.circle, color: AppTheme.vantaBlue, size: 10),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Nereden',
                                    style: TextStyle(fontSize: 11, color: AppTheme.vantaTextMuted, fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: 2),
                                  TextField(
                                    controller: _fromController,
                                    focusNode: _fromFocus,
                                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.vantaTextLight),
                                    decoration: const InputDecoration(
                                      isDense: true,
                                      contentPadding: EdgeInsets.zero,
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12.0),
                          child: Divider(color: Color(0xFF233554), height: 1),
                        ),
                        // Nereye Input
                        Row(
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: Icon(Icons.location_on_rounded, color: AppTheme.vantaWhite, size: 14),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Nereye',
                                    style: TextStyle(fontSize: 11, color: AppTheme.vantaTextMuted, fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: 2),
                                  TextField(
                                    controller: _toController,
                                    focusNode: _toFocus,
                                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.vantaTextLight),
                                    decoration: const InputDecoration(
                                      isDense: true,
                                      contentPadding: EdgeInsets.zero,
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    // Swap Button
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: _swapLocations,
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppTheme.vantaCardDark,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppTheme.vantaBorder),
                          boxShadow: const [
                            BoxShadow(color: Color(0x44000000), blurRadius: 8),
                          ],
                        ),
                        child: const Icon(Icons.swap_vert_rounded, color: AppTheme.vantaBlue, size: 18),
                      ),
                    ),
                  ],
                ),
              ),

              // Suggestions Dropdown if searching
              if (_suggestions.isNotEmpty || _isSearchingLocation) _buildSuggestionsDropdown(),

              const SizedBox(height: 20),

              // 2. TARİH, SAAT VE KAPASİTE SEÇİCİLERİ
              const Text(
                'Zaman ve Koltuk',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.vantaTextLight),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  // Tarih Seçici
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: _pickDate,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                        decoration: BoxDecoration(
                          color: AppTheme.vantaSurfaceDark,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.vantaBorder),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today_rounded, size: 16, color: AppTheme.vantaBlue),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Tarih', style: TextStyle(fontSize: 10, color: AppTheme.vantaTextMuted)),
                                  Text(
                                    formattedDate,
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.vantaTextLight),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Saat Seçici
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: _pickTime,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                        decoration: BoxDecoration(
                          color: AppTheme.vantaSurfaceDark,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.vantaBorder),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.access_time_rounded, size: 16, color: AppTheme.vantaBlue),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Saat', style: TextStyle(fontSize: 10, color: AppTheme.vantaTextMuted)),
                                  Text(
                                    formattedTime,
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.vantaTextLight),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Koltuk Sayısı (1-4)
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppTheme.vantaSurfaceDark,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.vantaBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.person_outline_rounded, size: 15, color: AppTheme.vantaBlue),
                              SizedBox(width: 4),
                              Text('Kapasite', style: TextStyle(fontSize: 10, color: AppTheme.vantaTextMuted)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () {
                                  if (_availableSeats > 1) {
                                    setState(() => _availableSeats--);
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: AppTheme.vantaCardDark,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.remove, size: 14, color: AppTheme.vantaTextLight),
                                ),
                              ),
                              Text(
                                '$_availableSeats',
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppTheme.vantaTextLight),
                              ),
                              GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () {
                                  if (_availableSeats < 4) {
                                    setState(() => _availableSeats++);
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: AppTheme.vantaBlue,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.add, size: 14, color: AppTheme.vantaTextDark),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // 3. FİYAT BELİRLEME (AKILLI SLIDER)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.vantaSurfaceDark,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppTheme.vantaBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.payments_outlined, color: AppTheme.vantaBlue, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Yolcu Başı Ücret',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.vantaTextLight),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Anlık Seçilen Fiyat Display
                    Text(
                      '${_pricePerSeat.toInt()} TL',
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.vantaBlue,
                        letterSpacing: 0.5,
                        shadows: [
                          Shadow(
                            color: Color(0x5500B4D8),
                            blurRadius: 16,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Önerilen Makul Ücret Aralığı',
                      style: TextStyle(fontSize: 11, color: AppTheme.vantaTextMuted),
                    ),
                    const SizedBox(height: 16),
                    // Akıllı Slider
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 8,
                        activeTrackColor: AppTheme.vantaBlue,
                        inactiveTrackColor: AppTheme.vantaCardDark,
                        thumbColor: AppTheme.vantaBlue,
                        overlayColor: AppTheme.vantaBlue.withOpacity(0.2),
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
                        overlayShape: const RoundSliderOverlayShape(overlayRadius: 22),
                      ),
                      child: Slider(
                        value: _pricePerSeat,
                        min: 200,
                        max: 260,
                        divisions: 12, // 5 TL adımlarla (200, 205, 210 ... 260)
                        label: '${_pricePerSeat.toInt()} TL',
                        onChanged: (val) {
                          setState(() => _pricePerSeat = val);
                        },
                      ),
                    ),
                    // Min & Max Etiketleri
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Min: 200 TL',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.vantaTextMuted),
                          ),
                          Text(
                            'Max: 260 TL',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.vantaTextMuted),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // 4. AKSİYON BUTONU (İlanı Yayınla)
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _publishRide,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.vantaBlue,
                    elevation: 8,
                    shadowColor: AppTheme.vantaBlue.withOpacity(0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.send_rounded, color: AppTheme.vantaTextDark, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'İlanı Yayınla',
                        style: TextStyle(
                          color: AppTheme.vantaTextDark,
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestionsDropdown() {
    return AnimatedSize(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      child: Container(
        margin: const EdgeInsets.only(top: 8),
        constraints: const BoxConstraints(maxHeight: 180),
        decoration: BoxDecoration(
          color: AppTheme.vantaSurfaceDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.vantaBorder),
        ),
        child: _isSearchingLocation && _suggestions.isEmpty
            ? const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(child: CircularProgressIndicator(color: AppTheme.vantaBlue)),
              )
            : ListView.separated(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: _suggestions.length,
                separatorBuilder: (_, __) => const Divider(color: AppTheme.vantaBorder, height: 1),
                itemBuilder: (context, index) {
                  final suggestion = _suggestions[index];
                  return ListTile(
                    dense: true,
                    leading: const Icon(Icons.location_on_outlined, color: AppTheme.vantaBlue, size: 18),
                    title: Text(
                      suggestion,
                      style: const TextStyle(color: AppTheme.vantaTextLight, fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    onTap: () {
                      _debounce?.cancel();
                      final field = _activeSearchField;
                      setState(() {
                        _isSearchingLocation = false;
                        _suggestions = [];
                        _activeSearchField = '';
                      });

                      if (field == 'from') {
                        _fromController.text = suggestion;
                        _fromFocus.unfocus();
                      } else if (field == 'to') {
                        _toController.text = suggestion;
                        _toFocus.unfocus();
                      }
                    },
                  );
                },
              ),
      ),
    );
  }
}
