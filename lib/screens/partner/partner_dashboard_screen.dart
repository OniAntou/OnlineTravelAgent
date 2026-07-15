import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/exceptions.dart';
import '../../core/theme/app_theme.dart';
import '../../data/services/api_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/hotel.dart';
import '../../models/tour_package.dart';
import '../../models/user_profile.dart';
import '../../core/utils/api_exception.dart';
import '../../core/utils/dialog_utils.dart';
import '../../shared/widgets/shimmer_loading.dart';
import 'room_manager_screen.dart';
import 'widgets/hotel_form_dialog.dart';
import 'widgets/tour_form_dialog.dart';

class PartnerDashboardScreen extends ConsumerStatefulWidget {
  const PartnerDashboardScreen({super.key});

  @override
  ConsumerState<PartnerDashboardScreen> createState() =>
      _PartnerDashboardScreenState();
}

class _PartnerDashboardScreenState extends ConsumerState<PartnerDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  bool _isPartner = false;
  String? _errorMessage;

  List<Hotel> _hotels = [];
  List<TourPackage> _tours = [];
  Map<String, dynamic>? _stats;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final api = ref.read(apiProvider);
      final results = await Future.wait([
        api.getPartnerHotels(),
        api.getPartnerTours(),
        api.getPartnerStats(),
      ]);
      if (!mounted) return;
      setState(() {
        _hotels = results[0] as List<Hotel>;
        _tours = results[1] as List<TourPackage>;
        _stats = results[2] as Map<String, dynamic>;
        _isPartner = true;
      });
    } on ForbiddenException catch (_) {
      if (!mounted) return;
      setState(() {
        _isPartner = false;
        _errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isPartner = false;
        _errorMessage = getErrorMessage(e);
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _becomePartner() async {
    setState(() => _isLoading = true);
    try {
      final api = ref.read(apiProvider);
      final data = await api.becomePartner();
      if (!mounted) return;
      final newToken = data['token']?.toString();
      if (newToken != null) {
        api.token = newToken;
        ref
            .read(authProvider.notifier)
            .updateToken(
              newToken,
              user: UserProfile.fromJson(
                data['user'] as Map<String, dynamic>? ?? {},
              ),
            );
      }
      await _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đăng ký đối tác thành công!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi đăng ký đối tác: ${getErrorMessage(e)}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  // ── Hotel CRUD ──────────────────────────────────────────────────────

  Future<void> _showHotelForm({Hotel? hotel}) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => HotelFormDialog(hotel: hotel),
    );
    if (result == null || !mounted) return;
    setState(() => _isLoading = true);
    try {
      final api = ref.read(apiProvider);
      if (hotel != null) {
        await api.updatePartnerHotel(hotel.id, result);
      } else {
        await api.createPartnerHotel(result);
      }
      if (!mounted) return;
      await _loadData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi thêm/sửa khách sạn: ${getErrorMessage(e)}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteHotel(Hotel hotel) async {
    final confirm = await showConfirmDialog(
      context: context,
      title: 'Xóa khách sạn',
      content: 'Bạn chắc chắn muốn xóa "${hotel.name}"?',
      confirmText: 'Xóa',
      isDestructive: true,
    );
    if (confirm != true || !mounted) return;
    setState(() => _isLoading = true);
    try {
      await ref.read(apiProvider).deletePartnerHotel(hotel.id);
      if (!mounted) return;
      await _loadData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi xóa khách sạn: ${getErrorMessage(e)}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Tour CRUD ───────────────────────────────────────────────────────

  Future<void> _showTourForm({TourPackage? tour}) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => TourFormDialog(tour: tour),
    );
    if (result == null || !mounted) return;
    setState(() => _isLoading = true);
    try {
      final api = ref.read(apiProvider);
      if (tour != null) {
        await api.updatePartnerTour(tour.id, result);
      } else {
        await api.createPartnerTour(result);
      }
      if (!mounted) return;
      await _loadData();
    } catch (e) {
      if (mounted) {
        final msg = e is ApiException ? e.message : 'Không thể kết nối server';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: Colors.red),
        );
      }
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteTour(TourPackage tour) async {
    final confirm = await showConfirmDialog(
      context: context,
      title: 'Xóa tour',
      content: 'Bạn chắc chắn muốn xóa "${tour.name}"?',
      confirmText: 'Xóa',
      isDestructive: true,
    );
    if (confirm != true || !mounted) return;
    setState(() => _isLoading = true);
    try {
      await ref.read(apiProvider).deletePartnerTour(tour.id);
      if (!mounted) return;
      await _loadData();
    } catch (e) {
      if (mounted) {
        final msg = e is ApiException ? e.message : 'Không thể kết nối server';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: Colors.red),
        );
      }
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Room Management ─────────────────────────────────────────────────

  Future<void> _showRoomManager(Hotel hotel) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => RoomManagerScreen(hotel: hotel)),
    );
    if (!mounted) return;
    await _loadData();
  }

  // ── Build ───────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_isLoading && !_isPartner && _hotels.isEmpty) {
      return const Scaffold(
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: TimelineShimmer(),
          ),
        ),
      );
    }

    if (!_isPartner) {
      return _buildBecomePartnerView();
    }

    return _buildDashboard();
  }

  Widget _buildBecomePartnerView() {
    return Scaffold(
      appBar: AppBar(title: const Text('Trở thành Đối tác')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _errorMessage != null
                    ? Icons.error_outline
                    : Icons.handshake_rounded,
                size: 80,
                color: _errorMessage != null
                    ? Colors.red
                    : AppTheme.primaryBlue,
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage != null
                    ? 'Đã xảy ra lỗi'
                    : 'Bạn chưa phải là đối tác',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage ??
                    'Đăng ký để đăng bán khách sạn & tour của bạn trên OTA!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _errorMessage != null ? Colors.red : null,
                ),
              ),
              const SizedBox(height: 24),
              if (_errorMessage != null)
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _loadData,
                  icon: const Icon(Icons.refresh),
                  label: const Text(
                    'Thử lại',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                )
              else
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _becomePartner,
                  child: const Text(
                    'Đăng ký ngay',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboard() {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Partner Dashboard',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryBlue,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppTheme.primaryBlue,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Tổng quan'),
            Tab(icon: Icon(Icons.hotel), text: 'Khách sạn'),
            Tab(icon: Icon(Icons.tour), text: 'Tours'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildStatsTab(), _buildHotelTab(), _buildTourTab()],
      ),
    );
  }

  // ── Stats Tab ───────────────────────────────────────────────────────

  Widget _buildStatsTab() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Thống kê',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _statCard(
                Icons.hotel,
                'Khách sạn',
                '${_stats?['hotels'] ?? 0}',
                AppTheme.primaryBlue,
              ),
              const SizedBox(width: 12),
              _statCard(
                Icons.tour,
                'Tours',
                '${_stats?['tours'] ?? 0}',
                Colors.orange,
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Khách sạn gần đây',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          if (_hotels.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Chưa có khách sạn nào.'),
            )
          else
            ..._hotels.take(3).map(_buildHotelCard),
          const SizedBox(height: 24),
          const Text(
            'Tours gần đây',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          if (_tours.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Chưa có tour nào.'),
            )
          else
            ..._tours.take(3).map(_buildTourCard),
        ],
      ),
    );
  }

  Widget _statCard(IconData icon, String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 13, color: AppTheme.darkGray),
            ),
          ],
        ),
      ),
    );
  }

  // ── Hotel Tab ───────────────────────────────────────────────────────

  Widget _buildHotelTab() {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: _hotels.isEmpty
            ? const Center(
                child: Text(
                  'Chưa có khách sạn nào.\nNhấn + để thêm mới.',
                  textAlign: TextAlign.center,
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _hotels.length,
                itemBuilder: (context, index) =>
                    _buildHotelCard(_hotels[index]),
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.primaryBlue,
        onPressed: _showHotelForm,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Thêm Khách sạn',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildHotelCard(Hotel hotel) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showRoomManager(hotel),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  'https://picsum.photos/seed/${hotel.id}/100/100',
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 60,
                    height: 60,
                    color: Colors.grey[200],
                    child: const Icon(Icons.hotel, size: 30),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hotel.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${hotel.location} • ${hotel.address}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${hotel.priceFrom.toInt()} VND/đêm',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') _showHotelForm(hotel: hotel);
                  if (value == 'rooms') _showRoomManager(hotel);
                  if (value == 'delete') _deleteHotel(hotel);
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(value: 'edit', child: Text('Chỉnh sửa')),
                  const PopupMenuItem(
                    value: 'rooms',
                    child: Text('Quản lý phòng'),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text('Xóa', style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Tour Tab ────────────────────────────────────────────────────────

  Widget _buildTourTab() {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: _tours.isEmpty
            ? const Center(
                child: Text(
                  'Chưa có tour nào.\nNhấn + để thêm mới.',
                  textAlign: TextAlign.center,
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _tours.length,
                itemBuilder: (context, index) => _buildTourCard(_tours[index]),
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.primaryBlue,
        onPressed: _showTourForm,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Thêm Tour', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildTourCard(TourPackage tour) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                'https://picsum.photos/seed/${tour.id}/100/100',
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 60,
                  height: 60,
                  color: Colors.grey[200],
                  child: const Icon(Icons.tour, size: 30),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tour.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${tour.duration} • ${tour.departure}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${tour.price.toInt()} VND',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') _showTourForm(tour: tour);
                if (value == 'delete') _deleteTour(tour);
              },
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'edit', child: Text('Chỉnh sửa')),
                const PopupMenuItem(
                  value: 'delete',
                  child: Text('Xóa', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
