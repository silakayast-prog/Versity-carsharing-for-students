import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import 'ride_detail_screen.dart';
import 'ride_search_list_screen.dart';

class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  final _fromController = TextEditingController(text: 'Antalya Kampüs');
  final _toController = TextEditingController(text: 'Alanya Kent Meydanı');
  
  final _fromFocus = FocusNode();
  final _toFocus = FocusNode();
  
  Timer? _debounce;
  List<String> _suggestions = [];
  bool _isSearchingLocation = false;
  String _activeSearchField = ''; // 'from' or 'to'

  late String _selectedDate;
  late String _dateToday;
  late String _dateTomorrow;
  late String _dateDayAfter;
  
  int _passengerCount = 1;
  List<dynamic> _bestRides = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fromFocus.addListener(_onFocusChange);
    _toFocus.addListener(_onFocusChange);
    
    final today = DateTime.now();
    _dateToday = _formatDate(today, prefix: 'Bugün');
    _dateTomorrow = _formatDate(today.add(const Duration(days: 1)), prefix: 'Yarın');
    _dateDayAfter = _formatDate(today.add(const Duration(days: 2)));
    _selectedDate = _dateToday;

    _fromController.addListener(() => _onSearchChanged('from', _fromController.text));
    _toController.addListener(() => _onSearchChanged('to', _toController.text));
    _fetchBestRides();
  }

  String _formatDate(DateTime date, {String prefix = ''}) {
    const months = ['Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran', 'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'];
    const days = ['Pazartesi', 'Salı', 'Çarşamba', 'Perşembe', 'Cuma', 'Cumartesi', 'Pazar'];
    String formatted = '${date.day} ${months[date.month - 1]}';
    if (prefix.isNotEmpty) {
      return '$prefix $formatted';
    }
    return '${days[date.weekday - 1]} $formatted';
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
        if (mounted) {
          setState(() {
            if (_activeSearchField == field) {
              _suggestions = results;
            }
            _isSearchingLocation = false;
          });
        }
      } catch (_) {
        if (mounted) setState(() => _isSearchingLocation = false);
      }
    });
  }

  @override
  void dispose() {
    _fromFocus.dispose();
    _toFocus.dispose();
    _fromController.dispose();
    _toController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _fetchBestRides() async {
    setState(() => _isLoading = true);
    try {
      final res = await ApiService.get('/rides/search?lat=36.9856&lng=30.6589&radiusKm=20');
      if (mounted) {
        setState(() {
          _bestRides = res['data'] ?? [];
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _swapLocations() {
    final temp = _fromController.text;
    setState(() {
      _fromController.text = _toController.text;
      _toController.text = temp;
    });
  }

  void _showDatePickerModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.vantaSurfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Tarih Seçimi',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.vantaTextLight),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: AppTheme.vantaTextMuted),
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Column(
                  children: [
                    _buildDateOptionTile(ctx, _dateToday, isSelected: _selectedDate == _dateToday),
                    _buildDateOptionTile(ctx, _dateTomorrow, isSelected: _selectedDate == _dateTomorrow),
                    _buildDateOptionTile(ctx, _dateDayAfter, isSelected: _selectedDate == _dateDayAfter),
                  ],
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.0),
                  child: Divider(color: AppTheme.vantaBorder),
                ),

                const Row(
                  children: [
                    Icon(Icons.history_rounded, color: AppTheme.vantaBlue, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Geçmiş Yolculuk Tarihlerim',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.vantaTextLight),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildHistoryDateTile(ctx, '12 Mayıs Salı', 'Antalya ➔ Alanya (Tamamlandı)'),
                _buildHistoryDateTile(ctx, '10 Mayıs Pazar', 'Kampüs ➔ Otogar (Tamamlandı)'),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDateOptionTile(BuildContext ctx, String dateText, {bool isSelected = false}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      tileColor: isSelected ? AppTheme.vantaBlue.withValues(alpha: 0.15) : Colors.transparent,
      leading: Icon(
        Icons.calendar_today_rounded,
        size: 18,
        color: isSelected ? AppTheme.vantaBlue : AppTheme.vantaTextMuted,
      ),
      title: Text(
        dateText,
        style: TextStyle(
          color: isSelected ? AppTheme.vantaBlue : AppTheme.vantaTextLight,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          fontSize: 14,
        ),
      ),
      trailing: isSelected ? const Icon(Icons.check_circle_rounded, color: AppTheme.vantaBlue, size: 20) : null,
      onTap: () {
        setState(() => _selectedDate = dateText);
        Navigator.of(ctx).pop();
        _fetchBestRides();
      },
    );
  }

  Widget _buildHistoryDateTile(BuildContext ctx, String dateText, String routeSubtitle) {
    final bool isSelected = _selectedDate == dateText;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      tileColor: isSelected ? AppTheme.vantaBlue.withValues(alpha: 0.15) : Colors.transparent,
      leading: const Icon(Icons.history_toggle_off_rounded, size: 20, color: AppTheme.vantaTextMuted),
      title: Text(
        dateText,
        style: TextStyle(
          color: isSelected ? AppTheme.vantaBlue : AppTheme.vantaTextLight,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
      subtitle: Text(routeSubtitle, style: const TextStyle(color: AppTheme.vantaTextMuted, fontSize: 11)),
      trailing: isSelected ? const Icon(Icons.check_circle_rounded, color: AppTheme.vantaBlue, size: 20) : null,
      onTap: () {
        setState(() => _selectedDate = dateText);
        Navigator.of(ctx).pop();
        _fetchBestRides();
      },
    );
  }

  void _showPassengerModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.vantaSurfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Yolcu Sayısı Seçimi',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.vantaTextLight),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline, color: AppTheme.vantaBlue, size: 36),
                        onPressed: _passengerCount > 1
                            ? () {
                                setModalState(() => _passengerCount--);
                                setState(() {});
                              }
                            : null,
                      ),
                      const SizedBox(width: 20),
                      Text('$_passengerCount', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.vantaTextLight)),
                      const SizedBox(width: 20),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline, color: AppTheme.vantaBlue, size: 36),
                        onPressed: _passengerCount < 4
                            ? () {
                                setModalState(() => _passengerCount++);
                                setState(() {});
                              }
                            : null,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.vantaBlue,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('Tamam', style: TextStyle(color: AppTheme.vantaTextLight, fontWeight: FontWeight.w900)),
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

  void _navigateToSearchList() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RideSearchListScreen(
          fromLocation: _fromController.text,
          toLocation: _toController.text,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final String fullName = auth.user?.adSoyad ?? 'Alex';
    final String userName = fullName.split(' ').first;

    return Scaffold(
      backgroundColor: AppTheme.vantaBlack,
      appBar: AppBar(
        backgroundColor: AppTheme.vantaBlack,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 70,
        titleSpacing: 20,
        title: const Text(
          'Versity',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: AppTheme.vantaTextLight,
            letterSpacing: 0.5,
          ),
        ),
        actions: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppTheme.vantaSurfaceDark,
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.vantaBorder),
            ),
            child: const Icon(Icons.search_rounded, color: AppTheme.vantaTextLight, size: 20),
          ),
          const SizedBox(width: 10),
          Stack(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppTheme.vantaSurfaceDark,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.vantaBorder),
                ),
                child: const Icon(Icons.notifications_none_rounded, color: AppTheme.vantaTextLight, size: 20),
              ),
              Positioned(
                right: 10,
                top: 10,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppTheme.vantaBlue,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 20),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => Navigator.of(context).pushNamed('/profile'),
                      child: const CircleAvatar(
                        radius: 20,
                        backgroundColor: AppTheme.vantaBlue,
                        child: Text(
                          'A',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Günaydın, Alex!',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.vantaTextLight),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.location_on_rounded, color: AppTheme.vantaBlue, size: 12),
                            const SizedBox(width: 4),
                            const Text(
                              'Antalya Kampüs',
                              style: TextStyle(color: AppTheme.vantaTextMuted, fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                const LiveClockWidget(),
              ],
            ),

              const SizedBox(height: 24),

              // Floating High-Contrast White Search Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.vantaWhite, // Floating White Card
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x44000000),
                      blurRadius: 24,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.centerRight,
                      children: [
                        Column(
                          children: [
                            // From Input
                            Row(
                              children: [
                                const Icon(Icons.circle, color: AppTheme.vantaBlue, size: 12),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Nereden',
                                        style: TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                                      ),
                                      const SizedBox(height: 2),
                                      TextField(
                                        controller: _fromController,
                                        focusNode: _fromFocus,
                                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.vantaTextDark),
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
                              padding: EdgeInsets.symmetric(vertical: 8.0),
                              child: Divider(color: AppTheme.vantaSubtleBorder, height: 1),
                            ),
                            // To Input
                            Row(
                              children: [
                                const Icon(Icons.location_on, color: AppTheme.vantaTextDark, size: 16),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Nereye',
                                        style: TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                                      ),
                                      const SizedBox(height: 2),
                                      TextField(
                                        controller: _toController,
                                        focusNode: _toFocus,
                                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.vantaTextDark),
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
                        // Swap Circular Button ⇅
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: _swapLocations,
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: const BoxDecoration(
                              color: AppTheme.vantaTextDark,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(color: Color(0x33000000), blurRadius: 8),
                              ],
                            ),
                            child: const Icon(Icons.swap_vert_rounded, color: Colors.white, size: 20),
                          ),
                        ),
                      ],
                    ),

                    // Autocomplete Suggestions Dropdown
                    _buildSuggestionsDropdown(),

                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12.0),
                      child: Divider(color: AppTheme.vantaSubtleBorder, height: 1),
                    ),

                    // Date & Passengers Row
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: _showDatePickerModal,
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today_rounded, size: 18, color: AppTheme.vantaTextDark),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('Tarih', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                                      Text(
                                        _selectedDate,
                                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.vantaTextDark),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF64748B), size: 18),
                              ],
                            ),
                          ),
                        ),
                        Container(height: 28, width: 1, color: AppTheme.vantaSubtleBorder),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: _showPassengerModal,
                            child: Row(
                              children: [
                                const Icon(Icons.person_outline_rounded, size: 20, color: AppTheme.vantaTextDark),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('Yolcu', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                                      Text(
                                        '$_passengerCount Yolcu',
                                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.vantaTextDark),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF64748B), size: 18),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Full Width Search CTA Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _navigateToSearchList,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.vantaTextDark,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: const Text(
                          'Yolculuk Ara',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Şoförler için "İlan Oluştur" Hızlı Erişim Butonu
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).pushNamed('/create_ride'),
                  icon: const Icon(Icons.add_circle_outline_rounded, color: AppTheme.vantaTextDark, size: 20),
                  label: const Text(
                    'Şoför müsün? İlan Oluştur',
                    style: TextStyle(
                      color: AppTheme.vantaTextDark,
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                      letterSpacing: 0.3,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.vantaBlue,
                    elevation: 6,
                    shadowColor: AppTheme.vantaBlue.withOpacity(0.35),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // Best Rides Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Öne Çıkan Seferler',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.vantaTextLight,
                    ),
                  ),
                  TextButton(
                    onPressed: _navigateToSearchList,
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

              const SizedBox(height: 12),

              // Horizontal Rides Carousel List
              SizedBox(
                height: 180,
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: AppTheme.vantaBlue))
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        scrollDirection: Axis.horizontal,
                        itemCount: _bestRides.isNotEmpty ? _bestRides.length : 6,
                        itemBuilder: (context, index) {
                          final isMock = _bestRides.isEmpty;
                          final driverName = isMock
                              ? (index == 0 ? 'Ahmet Y.' : index == 1 ? 'Ayşe K.' : index == 2 ? 'Selin Kökçü' : index == 3 ? 'Mehmet D.' : index == 4 ? 'Fatmanur Şen' : 'Leyla Kaya')
                              : (_bestRides[index]['sofor']?['ad_soyad'] ?? 'Ahmet Y.');
                          final rating = isMock ? (index == 0 ? '4.8' : index == 1 ? '4.9' : index == 2 ? '4.7' : index == 3 ? '4.6' : index == 4 ? '5.0' : '4.9') : '4.8';
                          final tagText = (index == 0 || index == 2 || index == 4 || index == 5) ? 'En Uygun' : 'En Hızlı';

                          return GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => RideDetailScreen(
                                    driverName: driverName,
                                    rating: rating,
                                    price: index == 0 ? '250 TL' : '280 TL',
                                    fromTime: '08:30',
                                    fromLocation: 'Antalya',
                                    toTime: '10:45',
                                    toLocation: 'Alanya',
                                    vehicleType: index == 1 ? 'egea' : (index == 2 ? 'mini' : (index == 4 ? 'maserati' : (index == 5 ? 'audi' : 'clio'))),
                                    driverDescription: index == 5 ? 'Selam. 🖤\n\nKampüs yolunda aracıma katılabilirsiniz. Sabahları genellikle sessizliği, sade bir kahveyi ve kendi çalma listemi tercih ederim. Gereksiz sohbetlerden ziyade, huzurlu ve kaliteli bir yolculuk önceliğimdir.\n\nTek kuralım dakiklik ve kişisel alana saygı. Bekletilmeyi hiç sevmem. Vaktinde konumda olacaksanız ve sakin bir yolculuk arıyorsanız eşleşebiliriz. Görüşmek üzere. 🕶️' :
                                    index == 4 ? 'Selam! ✨\n\nSabahları kampüse Maserati ile geçiyorum ve yolda kaliteli sohbet edebileceğim bir eşlikçi fena olmaz diye düşündüm.\n\nAçıkçası yolculuk masrafı veya uygulama içi ücretler gibi detaylarla hiç ilgilenmiyorum. Kampüse vardığımızda bana sevdiğim yerden güzel bir filtre kahve ısmarlamanız yol arkadaşlığınız için fazlasıyla yeterli. ☕️\n\nYalnızca net bir kırmızı çizgim var: Arabamın içinde sigara veya elektronik sigara içilmesi kesinlikle yasaktır. Orijinal deri koltukların kokusunu ve dokusunu korumamız şart. 💅\n\nTemiz, konforlu ve keyifli bir yolculuk arıyorsanız eşleşebiliriz. Kampüste görüşmek üzere! 🤍' :
                                    index == 3 ? 'Selam. 🎧\n\nSabahları pek konuşkan biri değilim, genelde uykumu açmaya çalışıyorum. Arabada sakin bir playlist çalar, ben de sadece yola odaklanırım.\n\nYol boyu sessiz, ekstra muhabbete girmeden kendi halinde ve huzurlu bir şekilde kampüse geçmek istiyorsan eşleşebiliriz. Sadece konumda vaktinde olman yeterli. Görüşürüz. 💤' :
                                    index == 2 ? 'Sabah kahvelerimizi içtiysek kırmızı Mini\'mle kampüs yollarına düşmeye hazırız demektir! Genelde sabah erken derslere yetişiyor ve öğleden sonraları dönüyorum. Rotalarımız eşleşiyorsa yolculuğuma seve seve ortak olabilirsiniz. 🚘\n\nAraçta müzikler benden (yol moduna göre hazırladığım Spotify listelerim bayağı iyidir 🎶)' : (index == 0 ? 'Sabah derslerine genelde bu araçla geçiyorum. Arabada müzik hep açıktır (genelde rap/hip-hop), isterseniz Bluetooth\'u size de salarım.\n\nKurallarım çok basit:\n\nBeklemeyi pek sevmem, anlaştığımız saatte konumda olursanız süper olur.\n\nF1 veya arabalardan anlıyorsanız yol muhabbetle hemen biter. 🏎️\n\nGüzergah uyuyorsa Versity üzerinden eşleşelim, kampüse hızlı ve sorunsuz geçeriz. Görüşürüz. 😎' : null),
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              width: 220,
                              margin: const EdgeInsets.only(right: 14),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppTheme.vantaSurfaceDark,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(color: AppTheme.vantaBorder),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 16,
                                        backgroundColor: AppTheme.vantaBlue,
                                        backgroundImage: driverName.contains('Ahmet') ? const AssetImage('assets/images/profile_ahmet.png') :
                                          (driverName.contains('Ayşe') ? const AssetImage('assets/images/profile_ayse.png') :
                                          (driverName.contains('Selin') ? const AssetImage('assets/images/profile_selin.png') : 
                                          (driverName.contains('Leyla') ? const AssetImage('assets/images/profile_leyla.jpg') : 
                                          (driverName.contains('Fatmanur') ? const AssetImage('assets/images/profile_fatmanur.jpg') : null)))),
                                        child: (driverName.contains('Ahmet') || driverName.contains('Ayşe') || driverName.contains('Selin') || driverName.contains('Leyla') || driverName.contains('Fatmanur')) ? null : Text(
                                          driverName[0],
                                          style: const TextStyle(color: AppTheme.vantaTextLight, fontWeight: FontWeight.bold, fontSize: 13),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              driverName,
                                              style: const TextStyle(color: AppTheme.vantaTextLight, fontWeight: FontWeight.bold, fontSize: 13),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Row(
                                              children: [
                                                const Icon(Icons.star_rounded, color: AppTheme.vantaBlue, size: 12),
                                                const SizedBox(width: 2),
                                                Text(rating, style: const TextStyle(color: AppTheme.vantaBlue, fontSize: 11, fontWeight: FontWeight.bold)),
                                              ],
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
                                          tagText,
                                          style: const TextStyle(color: AppTheme.vantaTextMuted, fontSize: 10, fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                    ],
                                  ),

                                  const Spacer(),

                                  const Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('08:30', style: TextStyle(color: AppTheme.vantaTextLight, fontWeight: FontWeight.bold, fontSize: 14)),
                                          Text('Antalya', style: TextStyle(color: AppTheme.vantaTextMuted, fontSize: 10)),
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          Icon(Icons.directions_car_rounded, color: AppTheme.vantaTextMuted, size: 14),
                                          Text('2s 15dk', style: TextStyle(color: AppTheme.vantaTextMuted, fontSize: 9)),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text('10:45', style: TextStyle(color: AppTheme.vantaTextLight, fontWeight: FontWeight.bold, fontSize: 14)),
                                          Text('Alanya', style: TextStyle(color: AppTheme.vantaTextMuted, fontSize: 10)),
                                        ],
                                      ),
                                    ],
                                  ),

                                  const Spacer(),

                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(index == 0 ? '250 TL' : '280 TL', style: const TextStyle(color: AppTheme.vantaTextLight, fontWeight: FontWeight.bold, fontSize: 14)),
                                          const Text('yolcu başı', style: TextStyle(color: AppTheme.vantaTextMuted, fontSize: 9)),
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
                                          '${3 - index} koltuk kaldı',
                                          style: const TextStyle(color: AppTheme.vantaTextLight, fontSize: 10, fontWeight: FontWeight.w600),
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
              ),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestionsDropdown() {
    if (_suggestions.isEmpty && !_isSearchingLocation) return const SizedBox.shrink();

    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      child: Container(
        margin: const EdgeInsets.only(top: 12),
        constraints: const BoxConstraints(maxHeight: 200),
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
                    leading: const Icon(Icons.location_on_outlined, color: AppTheme.vantaBlue, size: 20),
                    title: Text(suggestion, style: const TextStyle(color: AppTheme.vantaTextLight, fontSize: 13, fontWeight: FontWeight.bold)),
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

class LiveClockWidget extends StatefulWidget {
  const LiveClockWidget({super.key});

  @override
  State<LiveClockWidget> createState() => _LiveClockWidgetState();
}

class _LiveClockWidgetState extends State<LiveClockWidget> {
  String _liveTime = '--:--:--';
  Timer? _clockTimer;
  Duration _timeOffset = Duration.zero;

  @override
  void initState() {
    super.initState();
    _initLiveClock();
  }

  Future<void> _initLiveClock() async {
    try {
      final response = await http.get(Uri.parse('http://worldtimeapi.org/api/timezone/Europe/Istanbul')).timeout(const Duration(seconds: 3));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final apiTime = DateTime.parse(data['datetime']);
        _timeOffset = apiTime.difference(DateTime.now());
      }
    } catch (_) {}

    _updateTime();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateTime();
    });
  }

  void _updateTime() {
    if (!mounted) return;
    final now = DateTime.now().add(_timeOffset);
    final h = now.hour.toString().padLeft(2, '0');
    final m = now.minute.toString().padLeft(2, '0');
    final s = now.second.toString().padLeft(2, '0');
    setState(() {
      _liveTime = '$h:$m:$s';
    });
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.vantaCardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.vantaBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.schedule_rounded, color: AppTheme.vantaBlue, size: 14),
          const SizedBox(width: 6),
          Text(
            _liveTime,
            style: const TextStyle(color: AppTheme.vantaTextLight, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 0.5),
          ),
        ],
      ),
    );
  }
}

