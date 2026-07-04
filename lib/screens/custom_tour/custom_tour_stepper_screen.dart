import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../models/destination.dart';
import '../../models/hotel.dart';
import '../../providers/destination_provider.dart';
import '../../providers/hotel_provider.dart';
import '../../providers/trip_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_utils.dart';
import '../../utils/dialog_utils.dart';
import '../checkout/payment_method_screen.dart';

const _mockFlights = [
  {'id': 'f1', 'airline': 'Vietnam Airlines', 'price': 150.0, 'code': 'VN-234', 'logoColor': Color(0xFF0F2C59), 'time': '06:00 - 08:15'},
  {'id': 'f2', 'airline': 'Bamboo Airways', 'price': 120.0, 'code': 'QH-102', 'logoColor': Color(0xFF1E5128), 'time': '09:30 - 11:45'},
  {'id': 'f3', 'airline': 'Vietjet Air', 'price': 80.0, 'code': 'VJ-381', 'logoColor': Color(0xFFD80032), 'time': '14:15 - 16:30'},
  {'id': 'f4', 'airline': 'Vietnam Airlines', 'price': 170.0, 'code': 'VN-789', 'logoColor': Color(0xFF0F2C59), 'time': '18:00 - 20:15'},
];

class CustomTourStepperScreen extends ConsumerStatefulWidget {
  const CustomTourStepperScreen({super.key});

  @override
  ConsumerState<CustomTourStepperScreen> createState() =>
      _CustomTourStepperScreenState();
}

class _CustomTourStepperScreenState extends ConsumerState<CustomTourStepperScreen> {
  int _currentStep = 0;

  // Form State
  // Support selecting multiple destinations for a custom tour
  final List<Destination> _selectedDestinations = [];
  // Selected hotels per destination (destinationId -> Hotel)
  final Map<String, Hotel?> _selectedHotelsPerDestination = {};
  // Selected flights per trip leg (index => flightId)
  final Map<int, String> _selectedFlightsPerLeg = {};
  final Map<int, double> _selectedFlightPricesPerLeg = {};
  // Per-leg option to self-book flights (true = user will handle booking for that leg)
  final Map<int, bool> _selfBookPerLeg = {};
  
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 14));
  int _guests = 2;
  // Custom tours always include a guide (fixed fee per tour)
  static const double _guideFee = 50.0;

  // Format date to string DD/MM/YYYY
  String get _formattedDate {
    final day = _selectedDate.day.toString().padLeft(2, '0');
    final month = _selectedDate.month.toString().padLeft(2, '0');
    final year = _selectedDate.year.toString();
    return '$day/$month/$year';
  }

  // Reconcile per-leg flight selections when destinations change.
  // We generate leg keys by string "from->to" so they are stable across toggles.
  void _reconcileLegSelections(List<Destination> oldSelected, List<Destination> newSelected) {
    // Build mapping from old leg key -> selected flight id/price/selfBook
    final Map<String, Map<String, dynamic>> oldLegMap = {};
    for (var i = 0; i < oldSelected.length; i++) {
      final from = i == 0 ? 'SGN' : oldSelected[i - 1].name;
      final to = oldSelected[i].name;
      // Use a stable "from->to" key when reconciling legs
      final key = '$from->$to';
      final flightId = _selectedFlightsPerLeg[i];
      final price = _selectedFlightPricesPerLeg[i];
      final selfBook = _selfBookPerLeg[i];
      if (flightId != null || price != null || selfBook != null) {
        oldLegMap[key] = {
          'flightId': flightId,
          'price': price,
          'selfBook': selfBook,
        };
      }
    }

    // Clear current maps and reassign where possible by matching leg key strings
    final newFlightsPerLeg = <int, String>{};
    final newFlightPricesPerLeg = <int, double>{};
    final newSelfBookPerLeg = <int, bool>{};

    for (var i = 0; i < newSelected.length; i++) {
      final from = i == 0 ? 'SGN' : newSelected[i - 1].name;
      final to = newSelected[i].name;
      final key = '$from->$to';
      final matched = oldLegMap[key];
      if (matched != null) {
        if (matched['flightId'] != null) newFlightsPerLeg[i] = matched['flightId'] as String;
        if (matched['price'] != null) newFlightPricesPerLeg[i] = matched['price'] as double;
        if (matched['selfBook'] != null) newSelfBookPerLeg[i] = matched['selfBook'] as bool;
      } else {
        // default to self-book if no match
        newSelfBookPerLeg[i] = true;
      }
    }

    _selectedFlightsPerLeg
      ..clear()
      ..addAll(newFlightsPerLeg);
    _selectedFlightPricesPerLeg
      ..clear()
      ..addAll(newFlightPricesPerLeg);
    _selfBookPerLeg
      ..clear()
      ..addAll(newSelfBookPerLeg);
  }

  double get _totalPrice {
    double total = 0;
    // Sum hotel prices for each selected destination (priceFrom assumed per night)
    final hotelsSum = _selectedHotelsPerDestination.values
        .where((h) => h != null)
        .map((h) => h!.priceFrom)
        .fold<double>(0.0, (p, e) => p + e);
    total += hotelsSum * _guests;
    final flightsSum = _selectedFlightPricesPerLeg.values.fold<double>(0.0, (p, e) => p + e);
    total += flightsSum * _guests;
    // Custom tours always include a guide fee (fixed, not per guest)
    total += _guideFee;
    return total;
  }

  // Active step icon maps
  final List<Map<String, dynamic>> _stepsData = [
    {'title': 'Điểm đến', 'icon': Icons.map_outlined},
    {'title': 'Chuyến bay', 'icon': Icons.flight_takeoff_outlined},
    {'title': 'Lưu trú', 'icon': Icons.hotel_outlined},
    {'title': 'Tổng kết', 'icon': Icons.assignment_turned_in_outlined},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      appBar: AppBar(
        title: const Text(
          'Tự Thiết Kế Tour',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppTheme.textBlack,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppTheme.textBlack, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildCustomStepIndicator(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              physics: const BouncingScrollPhysics(),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: child,
                ),
                child: KeyedSubtree(
                  key: ValueKey<int>(_currentStep),
                  child: _buildStepContent(),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  // Helpers for multi-destination labels
  String get _selectedDestinationsLabel {
    if (_selectedDestinations.isEmpty) return 'Chưa chọn';
    if (_selectedDestinations.length == 1) return _selectedDestinations.first.name;
    if (_selectedDestinations.length == 2) {
      return '${_selectedDestinations[0].name}, ${_selectedDestinations[1].name}';
    }
    return '${_selectedDestinations[0].name}, ${_selectedDestinations[1].name} +${_selectedDestinations.length - 2} khác';
  }

  String get _selectedDestinationsLocations {
    if (_selectedDestinations.isEmpty) return '';
    final uniq = _selectedDestinations.map((d) => d.location).toSet().toList();
    return uniq.join(', ');
  }

  String get _selectedDestinationsFirstImage {
    if (_selectedDestinations.isEmpty) return '';
    return _selectedDestinations.first.imagePath;
  }

  // --- Step Indicator ---
  Widget _buildCustomStepIndicator() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(_stepsData.length, (index) {
              final step = _stepsData[index];
              final isCompleted = _currentStep > index;
              final isActive = _currentStep == index;

              Color iconBgColor;
              Color iconColor;
              Color textColor;
              BoxBorder? border;

              if (isActive) {
                iconBgColor = AppTheme.primaryBlue;
                iconColor = Colors.white;
                textColor = AppTheme.primaryBlue;
              } else if (isCompleted) {
                iconBgColor = AppTheme.primaryBlue.withValues(alpha: 0.12);
                iconColor = AppTheme.primaryBlue;
                textColor = AppTheme.primaryBlue;
              } else {
                iconBgColor = Colors.grey.shade100;
                iconColor = Colors.grey.shade500;
                textColor = Colors.grey.shade600;
                border = Border.all(color: Colors.grey.shade300);
              }

              return Expanded(
                child: Row(
                  children: [
                    // Step item icon + label
                    GestureDetector(
                      onTap: () {
                        // Allow navigation to previous or already configured steps
                        if (index < _currentStep || 
                            (index == 1 && _selectedDestinations.isNotEmpty) ||
                            (index == 2 && _selectedDestinations.isNotEmpty) ||
                            (index == 3 && _selectedDestinations.isNotEmpty)) {
                          setState(() => _currentStep = index);
                        }
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: iconBgColor,
                              shape: BoxShape.circle,
                              border: border,
                              boxShadow: isActive
                                  ? [
                                      BoxShadow(
                                        color: AppTheme.primaryBlue.withValues(alpha: 0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      )
                                    ]
                                  : null,
                            ),
                            child: Icon(
                              step['icon'] as IconData,
                              color: iconColor,
                              size: 20,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            step['title'] as String,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Linking line
                    if (index < _stepsData.length - 1)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            height: 3,
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                              color: isCompleted
                                  ? AppTheme.primaryBlue
                                  : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // --- Step Content Switcher ---
  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildDestinationStep();
      case 1:
        return _buildFlightStep();
      case 2:
        return _buildHotelStep();
      case 3:
        return _buildReviewStep();
      default:
        return const SizedBox.shrink();
    }
  }

  // --- Step 1: Destination Selection ---
  Widget _buildDestinationStep() {
    return Consumer(
      builder: (context, ref, _) {
        final destList = ref.watch(destinationsProvider);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Chọn điểm xuất phát & khám phá',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textBlack,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Thiết kế hành trình riêng cho bạn. Hãy chọn một điểm đến lý tưởng dưới đây:',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 20),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: destList.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.82,
              ),
                itemBuilder: (context, index) {
                  final dest = destList[index];
                  final isSelected = _selectedDestinations.any((d) => d.id == dest.id);

                  return GestureDetector(
                      onTap: () {
                        // Reconcile selections when destinations are toggled so we preserve
                        // any existing per-leg flight choices that still match new legs.
                        final oldSelected = List<Destination>.from(_selectedDestinations);
                        setState(() {
                          // Toggle selection for multi-select
                          final existingIndex = _selectedDestinations.indexWhere((d) => d.id == dest.id);
                          if (existingIndex >= 0) {
                            _selectedDestinations.removeAt(existingIndex);
                          } else {
                            _selectedDestinations.add(dest);
                          }

                          // Reconcile flight selections based on leg identity (from->to)
                          _reconcileLegSelections(oldSelected, _selectedDestinations);

                          // Reconcile hotels per destination: drop entries for removed destinations
                          final keepIds = _selectedDestinations.map((d) => d.id).toSet();
                          _selectedHotelsPerDestination.removeWhere((k, v) => !keepIds.contains(k));

                          // Ensure entries exist for newly added destinations
                          for (final d in _selectedDestinations) {
                            _selectedHotelsPerDestination.putIfAbsent(d.id, () => null);
                          }
                        });
                      },
                    child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isSelected ? AppTheme.primaryBlue : Colors.white,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                        color: isSelected 
                            ? AppTheme.primaryBlue.withValues(alpha: 0.15)
                            : Colors.black.withValues(alpha: 0.04),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      )
                    ],
                  ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Image Stack
                        Expanded(
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                  child: Image.asset(
                                    dest.imagePath,
                                    fit: BoxFit.cover,
                                    cacheWidth: (MediaQuery.sizeOf(context).width / 2 * MediaQuery.devicePixelRatioOf(context)).round(),
                                    errorBuilder: (context, e, s) => Container(
                                      color: Colors.grey.shade200,
                                      child: Icon(Icons.image, color: Colors.grey.shade400, size: 40),
                                    ),
                                  ),
                                ),
                              ),
                              // Location tag overlay
                              Positioned(
                                top: 8,
                                left: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.6),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.location_on, color: Colors.white, size: 10),
                                      const SizedBox(width: 2),
                                      Text(
                                        dest.name,
                                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                        // Check indicator overlay (show when selected)
                        if (isSelected)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: AppTheme.primaryBlue,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.check, color: Colors.white, size: 14),
                            ),
                          ),
                            ],
                          ),
                        ),
                        // Details text
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                dest.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: isSelected ? AppTheme.primaryBlue : AppTheme.textBlack,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Icon(Icons.star, color: Colors.amber.shade600, size: 12),
                                  const SizedBox(width: 2),
                                  Text(
                                    dest.rating,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '(${dest.reviewsCount} reviews)',
                                    style: TextStyle(
                                      fontSize: 9,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  // --- Step 2: Flight Tickets View ---
  Widget _buildFlightStep() {
    if (_selectedDestinations.isEmpty) {
      return const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Chọn chuyến bay thích hợp',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textBlack),
          ),
          SizedBox(height: 12),
          Text('Vui lòng chọn ít nhất một điểm đến ở bước trước để lựa chọn chuyến bay.'),
        ],
      );
    }

    // Build legs: origin (SGN) -> first selected, then between selected destinations
    final legs = <Map<String, String>>[];
    for (var i = 0; i < _selectedDestinations.length; i++) {
      final from = i == 0 ? 'SGN' : _selectedDestinations[i - 1].name;
      final to = _selectedDestinations[i].name;
      legs.add({'from': from, 'to': to});
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Chọn chuyến bay thích hợp cho từng đoạn hành trình',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textBlack),
        ),
        const SizedBox(height: 8),
        Text(
          'Bạn có thể chọn chuyến bay riêng cho mỗi đoạn (ví dụ: đến Nha Trang sáng 6h, sau đó bay tiếp vào chiều). Nếu bạn muốn tự đặt một đoạn, chọn "Tôi tự đặt" cho đoạn đó.',
          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 16),

        // For each leg, show selection UI
        for (var legIndex = 0; legIndex < legs.length; legIndex++) ...[
          Builder(builder: (context) {
            final from = legs[legIndex]['from']!;
            final to = legs[legIndex]['to']!;
            final selectedId = _selectedFlightsPerLeg[legIndex] ?? '';
            final selectedPrice = _selectedFlightPricesPerLeg[legIndex] ?? 0.0;
            final selfBook = _selfBookPerLeg[legIndex] ?? true;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Đoạn ${legIndex + 1}: $from ➔ $to', style: const TextStyle(fontWeight: FontWeight.bold)),
                    if (selectedId.isNotEmpty)
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _selectedFlightsPerLeg.remove(legIndex);
                            _selectedFlightPricesPerLeg.remove(legIndex);
                            _selfBookPerLeg[legIndex] = true;
                          });
                        },
                        child: const Text('Bỏ chọn', style: TextStyle(color: Colors.grey)),
                      ),
                  ],
                ),
                const SizedBox(height: 8),

                // None / self-book option for this leg
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _selfBookPerLeg[legIndex] = true;
                      _selectedFlightsPerLeg.remove(legIndex);
                      _selectedFlightPricesPerLeg.remove(legIndex);
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: selfBook ? AppTheme.primaryBlue.withValues(alpha: 0.06) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: selfBook ? AppTheme.primaryBlue : Colors.white, width: 2),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: selfBook ? AppTheme.primaryBlue.withValues(alpha: 0.12) : Colors.grey.shade100,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(selfBook ? Icons.radio_button_checked : Icons.no_accounts, color: selfBook ? AppTheme.primaryBlue : Colors.grey.shade600, size: 18),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Tôi tự đặt vé cho đoạn này', style: TextStyle(fontWeight: FontWeight.bold, color: selfBook ? AppTheme.primaryBlue : AppTheme.textBlack)),
                              const SizedBox(height: 2),
                              Text('Tôi sẽ tự lo khâu di chuyển cho đoạn này', style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                            ],
                          ),
                        ),
                        if (selectedPrice > 0)
                          Text('${formatVND(selectedPrice)} / khách', style: const TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),

                // Flight options for this leg
                ..._mockFlights.map((flight) {
                  final logoColor = flight['logoColor'] as Color;
                  final isSelected = selectedId == flight['id'];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedFlightsPerLeg[legIndex] = flight['id'] as String;
                        _selectedFlightPricesPerLeg[legIndex] = flight['price'] as double;
                        _selfBookPerLeg[legIndex] = false;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: isSelected ? AppTheme.primaryBlue : Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: isSelected ? AppTheme.primaryBlue.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.03),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(color: logoColor.withValues(alpha: 0.1), shape: BoxShape.circle),
                            alignment: Alignment.center,
                            child: Text((flight['airline'] as String).substring(0, 1), style: TextStyle(color: logoColor, fontWeight: FontWeight.bold, fontSize: 16)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(flight['airline'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 2),
                              Text('Mã: ${flight['code']} • ${flight['time']}', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                            ]),
                          ),
                          Text('${formatVND(flight['price'] as double)} / khách', style: const TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  );
                }),

                const SizedBox(height: 8),
              ],
            );
          }),
        ],
      ],
    );
  }

  // --- Step 3: Horizontal Hotel List View ---
  Widget _buildHotelStep() {
    return Consumer(
      builder: (context, ref, _) {
        final hotels = ref.watch(hotelsProvider);

        if (_selectedDestinations.isEmpty) {
          return const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Chọn khách sạn lưu trú',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textBlack),
              ),
              SizedBox(height: 12),
              Text('Vui lòng chọn điểm đến ở bước trước để lựa chọn khách sạn cho từng nơi.'),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Chọn khách sạn lưu trú cho từng điểm',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textBlack),
            ),
            const SizedBox(height: 8),
            Text(
              'Bạn có thể chọn khách sạn khác nhau cho mỗi điểm đến. Nếu bạn muốn tự lo phòng cho một điểm, chọn "Tôi tự chuẩn bị" cho điểm đó.',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 14),

            // Per-destination hotel selector
            for (var i = 0; i < _selectedDestinations.length; i++) ...[
              Builder(builder: (context) {
                final dest = _selectedDestinations[i];
                final selected = _selectedHotelsPerDestination[dest.id];

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Lưu trú: ${dest.name}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        if (selected != null)
                          TextButton(
                            onPressed: () => setState(() => _selectedHotelsPerDestination[dest.id] = null),
                            child: const Text('Bỏ chọn', style: TextStyle(color: Colors.grey)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Self-book option for this destination
                    GestureDetector(
                      onTap: () => setState(() => _selectedHotelsPerDestination[dest.id] = null),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: (selected == null) ? AppTheme.primaryBlue.withValues(alpha: 0.06) : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: (selected == null) ? AppTheme.primaryBlue : Colors.white, width: 2),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: (selected == null) ? AppTheme.primaryBlue.withValues(alpha: 0.12) : Colors.grey.shade100,
                                shape: BoxShape.circle,
                              ),
                              child: Icon((selected == null) ? Icons.radio_button_checked : Icons.no_accounts, color: (selected == null) ? AppTheme.primaryBlue : Colors.grey.shade600, size: 18),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Tôi tự chuẩn bị phòng nghỉ cho ${dest.name}', style: TextStyle(fontWeight: FontWeight.bold, color: (selected == null) ? AppTheme.primaryBlue : AppTheme.textBlack)),
                                  const SizedBox(height: 2),
                                  Text('Không yêu cầu đặt phòng qua app cho điểm này', style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                                ],
                              ),
                            ),
                            if (selected != null)
                              Text('${formatVND(selected.priceFrom)} / đêm', style: const TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),

                    // Hotels list for this destination
                    ...hotels.map((hotel) {
                      final isSelected = selected?.id == hotel.id;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedHotelsPerDestination[dest.id] = hotel),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: isSelected ? AppTheme.primaryBlue : Colors.white, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: isSelected ? AppTheme.primaryBlue.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.03),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              )
                            ],
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.asset(hotel.imagePath, width: 68, height: 68, fit: BoxFit.cover, errorBuilder: (c, e, s) => Container(width: 68, height: 68, color: Colors.grey.shade100, child: const Icon(Icons.hotel, color: Colors.grey))),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Text(hotel.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 4),
                                  Text(hotel.location, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                                ]),
                              ),
                              Text(formatVND(hotel.priceFrom), style: const TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      );
                    }),

                    const SizedBox(height: 10),
                  ],
                );
              }),
            ],
          ],
        );
      },
    );
  }

  // --- Step 4: Summary & Deluxe Configs ---
  Widget _buildReviewStep() {
    // Compute flight selection summary for review
    final selectedFlightLegCount = _selectedFlightsPerLeg.entries
        .where((e) => e.value.isNotEmpty && (_selfBookPerLeg[e.key] != true))
        .length;
    final selectedFlightsTotalPrice = _selectedFlightPricesPerLeg.values.fold<double>(0.0, (p, e) => p + e);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Cá nhân hóa và Đặt Tour',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.textBlack,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Hoàn tất lựa chọn ngày khởi hành và số khách hàng để chốt vé.',
          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 18),

        // Custom Datepicker card
        GestureDetector(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _selectedDate,
              firstDate: DateTime.now(),
              lastDate: DateTime(2030),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: const ColorScheme.light(
                      primary: AppTheme.primaryBlue,
                      onSurface: AppTheme.textBlack,
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (picked != null) {
              setState(() => _selectedDate = picked);
            }
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.calendar_month, color: AppTheme.primaryBlue, size: 22),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Ngày khởi hành',
                        style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        _formattedDate,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textBlack),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.edit_calendar_outlined, color: AppTheme.primaryBlue, size: 20),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Deluxe Guest Counter card
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Make the left area flexible so the guest counter on the right
              // can keep a fixed/minimum width and avoid horizontal overflow
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.people_outline, color: Colors.green.shade700, size: 22),
                    ),
                    const SizedBox(width: 16),
                    // allow the text to wrap or ellipsize if space is constrained
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Số lượng khách',
                            style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 3),
                          Text(
                            'Hành khách bay & lưu trú',
                            style: TextStyle(fontSize: 12, color: AppTheme.textBlack, fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Counter should use minimal horizontal space
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.remove_circle, color: _guests > 1 ? AppTheme.primaryBlue : Colors.grey.shade300, size: 28),
                    onPressed: _guests > 1 ? () => setState(() => _guests--) : null,
                  ),
                  // keep a consistent width for 1-3 digit numbers so layout is stable
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    constraints: const BoxConstraints(minWidth: 28),
                    alignment: Alignment.center,
                    child: Text(
                      '$_guests',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textBlack),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.add_circle, color: _guests < 49 ? AppTheme.primaryBlue : Colors.grey.shade300, size: 28),
                    onPressed: _guests < 49 ? () => setState(() => _guests++) : null,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Final breakdown summary panel
        const Text(
          'Chi tiết hành trình của bạn',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textBlack),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 5),
              )
            ],
          ),
          child: Column(
            children: [
              _buildReviewRowDetail(
                title: 'Điểm đến:',
                value: _selectedDestinations.isEmpty ? 'Chưa chọn' : _selectedDestinationsLabel,
                subtitle: _selectedDestinations.isEmpty ? null : _selectedDestinationsLocations,
                icon: Icons.map_outlined,
                iconColor: AppTheme.primaryBlue,
              ),
              const Divider(height: 24, thickness: 0.5),
              _buildReviewRowDetail(
                title: 'Ngày đi:',
                value: _formattedDate,
                subtitle: 'Khởi hành lúc 08:00 AM',
                icon: Icons.calendar_month,
                iconColor: Colors.purple,
              ),
              const Divider(height: 24, thickness: 0.5),
              _buildReviewRowDetail(
                title: 'Chuyến bay:',
                value: selectedFlightLegCount == 0 ? 'Không đặt qua app' : 'Đã chọn $selectedFlightLegCount chuyến',
                subtitle: selectedFlightLegCount == 0 ? null : '${formatVND(selectedFlightsTotalPrice * _guests)} ($_guests khách)',
                icon: Icons.flight_takeoff,
                iconColor: Colors.teal,
              ),
              const Divider(height: 24, thickness: 0.5),
              _buildReviewRowDetail(
                title: 'Khách sạn:',
                value: _selectedHotelsPerDestination.values.where((h) => h != null).isEmpty ? 'Không đặt qua app' : '${_selectedHotelsPerDestination.values.where((h) => h != null).length} nơi lưu trú đã chọn',
                subtitle: _selectedHotelsPerDestination.values.where((h) => h != null).isEmpty ? null : '${formatVND(_selectedHotelsPerDestination.values.where((h) => h != null).map((h) => h!.priceFrom).fold<double>(0.0, (p, e) => p + e) * _guests)} ($_guests đêm)',
                icon: Icons.hotel_outlined,
                iconColor: Colors.orange,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  // Visual styled breakdown row widget
  Widget _buildReviewRowDetail({
    required String title,
    required String value,
    String? subtitle,
    required IconData icon,
    required Color iconColor,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor, size: 18),
        ),
        const SizedBox(width: 14),
        // Put both value and optional subtitle inside the expanded column so they
        // wrap together and don't cause horizontal overflow in the parent Row.
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(color: Colors.grey.shade500, fontSize: 11, fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.textBlack),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  // --- Persistent Bottom Action & Subtotal Bar ---
  Widget _buildBottomNavigationBar() {
    final isLastStep = _currentStep == 3;
    final isDestinationSelected = _selectedDestinations.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          )
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Subtotal calculator
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tạm tính ($_guests khách)',
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formatVND(_totalPrice),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                  ],
                ),
                Text(
                  'Bước ${_currentStep + 1} / 4',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Actions Row
            Row(
              children: [
                if (_currentStep > 0) ...[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => setState(() => _currentStep--),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        'Quay lại',
                        style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                ],
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () {
                      // Require at least one destination selected to proceed from step 0
                      if (_currentStep == 0 && _selectedDestinations.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Vui lòng chọn ít nhất một điểm đến trước khi tiếp tục'),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                        return;
                      }

                      if (_currentStep < 3) {
                        setState(() => _currentStep++);
                      } else {
                        _submitCustomTour();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedDestinations.isNotEmpty ? AppTheme.primaryBlue : Colors.grey.shade300,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      elevation: isDestinationSelected ? 3 : 0,
                      shadowColor: AppTheme.primaryBlue.withValues(alpha: 0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      isLastStep ? 'Xác nhận & Thanh toán' : 'Tiếp tục',
                      style: TextStyle(
                        color: isDestinationSelected ? Colors.white : Colors.grey.shade500,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _submitCustomTour() {
    if (!ref.read(authProvider).isLoggedIn) {
      showErrorSnackBar(context, 'Vui lòng đăng nhập để đặt!');
      Navigator.pushNamed(context, '/login');
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentMethodScreen(
          totalPrice: _totalPrice,
          onPaymentSuccess: () async {
            if (!mounted) return null;

            final selectedFlightIds = _selectedFlightsPerLeg.entries
                .where((e) => e.value.isNotEmpty && (_selfBookPerLeg[e.key] != true))
                .map((e) => e.value)
                .toList();

            final selectedHotelIds = _selectedHotelsPerDestination.values
                .where((h) => h != null)
                .map((h) => h!.id)
                .toList();

            return await ref.read(tripsProvider.notifier).createCustomTour(
                  destination: _selectedDestinations.map((d) => d.name).join(', '),
                  location: _selectedDestinations.map((d) => d.location).toSet().join(', '),
                  date: _formattedDate,
                  guests: '$_guests Người',
                  imagePath: _selectedDestinationsFirstImage,
                  flightIds: selectedFlightIds.isEmpty ? null : selectedFlightIds,
                  hotelIds: selectedHotelIds.isEmpty ? null : selectedHotelIds,
                  totalPrice: _totalPrice,
                );
          },
        ),
      ),
    );
  }
}
