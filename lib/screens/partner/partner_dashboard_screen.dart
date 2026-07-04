import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/exceptions.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/api_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/hotel.dart';
import '../../models/tour_package.dart';
import '../../models/room.dart';
import '../../utils/api_exception.dart';

class PartnerDashboardScreen extends ConsumerStatefulWidget {
  const PartnerDashboardScreen({super.key});

  @override
  ConsumerState<PartnerDashboardScreen> createState() => _PartnerDashboardScreenState();
}

class _PartnerDashboardScreenState extends ConsumerState<PartnerDashboardScreen> with SingleTickerProviderStateMixin {
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
      final newToken = data['token']?.toString();
      if (newToken != null) {
        api.token = newToken;
        ref.read(authProvider.notifier).updateToken(newToken);
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
      builder: (_) => _HotelFormDialog(hotel: hotel),
    );
    if (result == null) return;
    setState(() => _isLoading = true);
    try {
      final api = ref.read(apiProvider);
      if (hotel != null) {
        await api.updatePartnerHotel(hotel.id, result);
      } else {
        await api.createPartnerHotel(result);
      }
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
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteHotel(Hotel hotel) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xóa khách sạn'),
        content: Text('Bạn chắc chắn muốn xóa "${hotel.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    setState(() => _isLoading = true);
    try {
      await ref.read(apiProvider).deletePartnerHotel(hotel.id);
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
      setState(() => _isLoading = false);
    }
  }

  // ── Tour CRUD ───────────────────────────────────────────────────────

  Future<void> _showTourForm({TourPackage? tour}) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => _TourFormDialog(tour: tour),
    );
    if (result == null) return;
    setState(() => _isLoading = true);
    try {
      final api = ref.read(apiProvider);
      if (tour != null) {
        await api.updatePartnerTour(tour.id, result);
      } else {
        await api.createPartnerTour(result);
      }
      await _loadData();
    } catch (e) {
      if (mounted) {
        final msg = e is ApiException ? e.message : 'Không thể kết nối server';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: Colors.red),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteTour(TourPackage tour) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xóa tour'),
        content: Text('Bạn chắc chắn muốn xóa "${tour.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    setState(() => _isLoading = true);
    try {
      await ref.read(apiProvider).deletePartnerTour(tour.id);
      await _loadData();
    } catch (e) {
      if (mounted) {
        final msg = e is ApiException ? e.message : 'Không thể kết nối server';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: Colors.red),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  // ── Room Management ─────────────────────────────────────────────────

  Future<void> _showRoomManager(Hotel hotel) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => _RoomManagerScreen(hotel: hotel)),
    );
    _loadData();
  }

  // ── Build ───────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
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
                _errorMessage != null ? Icons.error_outline : Icons.handshake_rounded,
                size: 80,
                color: _errorMessage != null ? Colors.red : AppTheme.primaryBlue,
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage != null ? 'Đã xảy ra lỗi' : 'Bạn chưa phải là đối tác',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage ?? 'Đăng ký để đăng bán khách sạn & tour của bạn trên OTA!',
                textAlign: TextAlign.center,
                style: TextStyle(color: _errorMessage != null ? Colors.red : null),
              ),
              const SizedBox(height: 24),
              if (_errorMessage != null)
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _loadData,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Thử lại', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                )
              else
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _becomePartner,
                  child: const Text('Đăng ký ngay', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
        title: const Text('Partner Dashboard', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
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
        children: [
          _buildStatsTab(),
          _buildHotelTab(),
          _buildTourTab(),
        ],
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
          const Text('Thống kê', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            children: [
              _statCard(Icons.hotel, 'Khách sạn', '${_stats?['hotels'] ?? 0}', AppTheme.primaryBlue),
              const SizedBox(width: 12),
              _statCard(Icons.tour, 'Tours', '${_stats?['tours'] ?? 0}', Colors.orange),
            ],
          ),
          const SizedBox(height: 24),
          const Text('Khách sạn gần đây', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (_hotels.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Chưa có khách sạn nào.'),
            )
          else
            ..._hotels.take(3).map(_buildHotelCard),
          const SizedBox(height: 24),
          const Text('Tours gần đây', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
            Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
            Text(label, style: const TextStyle(fontSize: 13, color: AppTheme.darkGray)),
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
            ? const Center(child: Text('Chưa có khách sạn nào.\nNhấn + để thêm mới.', textAlign: TextAlign.center))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _hotels.length,
                itemBuilder: (context, index) => _buildHotelCard(_hotels[index]),
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.primaryBlue,
        onPressed: _showHotelForm,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Thêm Khách sạn', style: TextStyle(color: Colors.white)),
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
                    Text(hotel.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 4),
                    Text('${hotel.location} • ${hotel.address}',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text('${hotel.priceFrom.toInt()} VND/đêm',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.primaryBlue)),
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
                  const PopupMenuItem(value: 'rooms', child: Text('Quản lý phòng')),
                  const PopupMenuItem(value: 'delete', child: Text('Xóa', style: TextStyle(color: Colors.red))),
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
            ? const Center(child: Text('Chưa có tour nào.\nNhấn + để thêm mới.', textAlign: TextAlign.center))
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
                  Text(tour.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 4),
                  Text('${tour.duration} • ${tour.departure}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 4),
                  Text('${tour.price.toInt()} VND',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.primaryBlue)),
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
                const PopupMenuItem(value: 'delete', child: Text('Xóa', style: TextStyle(color: Colors.red))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Hotel Form Dialog ──────────────────────────────────────────────────

class _HotelFormDialog extends StatefulWidget {
  final Hotel? hotel;
  const _HotelFormDialog({this.hotel});

  @override
  State<_HotelFormDialog> createState() => _HotelFormDialogState();
}

class _HotelFormDialogState extends State<_HotelFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _locationCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _amenitiesCtrl;

  bool get isEditing => widget.hotel != null;

  @override
  void initState() {
    super.initState();
    final h = widget.hotel;
    _nameCtrl = TextEditingController(text: h?.name ?? '');
    _locationCtrl = TextEditingController(text: h?.location ?? '');
    _addressCtrl = TextEditingController(text: h?.address ?? '');
    _priceCtrl = TextEditingController(text: h != null ? h.priceFrom.toInt().toString() : '');
    _descCtrl = TextEditingController(text: h?.description ?? '');
    _amenitiesCtrl = TextEditingController(text: h?.amenities.join(', ') ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _locationCtrl.dispose();
    _addressCtrl.dispose();
    _priceCtrl.dispose();
    _descCtrl.dispose();
    _amenitiesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(isEditing ? 'Sửa khách sạn' : 'Thêm khách sạn mới'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _field(_nameCtrl, 'Tên khách sạn', required: true),
              _field(_locationCtrl, 'Địa điểm (VD: Hà Nội)', required: true),
              _field(_addressCtrl, 'Địa chỉ chi tiết'),
              _field(_priceCtrl, 'Giá từ (VND/đêm)', keyboard: TextInputType.number),
              _field(_descCtrl, 'Mô tả', maxLines: 3),
              _field(_amenitiesCtrl, 'Tiện nghi (phân cách bằng dấu phẩy)'),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: AppTheme.primaryBlue),
          onPressed: () {
            if (!_formKey.currentState!.validate()) return;
            final data = <String, dynamic>{
              'name': _nameCtrl.text.trim(),
              'location': _locationCtrl.text.trim(),
              'address': _addressCtrl.text.trim(),
              'priceFrom': double.tryParse(_priceCtrl.text.trim()) ?? 0,
              'description': _descCtrl.text.trim(),
              'amenities': _amenitiesCtrl.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
            };
            Navigator.pop(context, data);
          },
          child: Text(isEditing ? 'Cập nhật' : 'Thêm'),
        ),
      ],
    );
  }

  Widget _field(TextEditingController ctrl, String label,
      {bool required = false, TextInputType? keyboard, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: ctrl,
        keyboardType: keyboard,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
        validator: required ? (v) => (v == null || v.trim().isEmpty) ? 'Bắt buộc' : null : null,
      ),
    );
  }
}

// ── Tour Form Dialog ───────────────────────────────────────────────────

class _TourFormDialog extends StatefulWidget {
  final TourPackage? tour;
  const _TourFormDialog({this.tour});

  @override
  State<_TourFormDialog> createState() => _TourFormDialogState();
}

class _TourFormDialogState extends State<_TourFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _durationCtrl;
  late final TextEditingController _departureCtrl;
  late final TextEditingController _destinationsCtrl;
  late final TextEditingController _includesCtrl;

  bool get isEditing => widget.tour != null;

  @override
  void initState() {
    super.initState();
    final t = widget.tour;
    _nameCtrl = TextEditingController(text: t?.name ?? '');
    _descCtrl = TextEditingController(text: t?.description ?? '');
    _priceCtrl = TextEditingController(text: t != null ? t.price.toInt().toString() : '');
    _durationCtrl = TextEditingController(text: t?.duration ?? '');
    _departureCtrl = TextEditingController(text: t?.departure ?? '');
    _destinationsCtrl = TextEditingController(text: t?.destinations.join(', ') ?? '');
    _includesCtrl = TextEditingController(text: t?.includes.join(', ') ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _durationCtrl.dispose();
    _departureCtrl.dispose();
    _destinationsCtrl.dispose();
    _includesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(isEditing ? 'Sửa tour' : 'Thêm tour mới'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _field(_nameCtrl, 'Tên tour', required: true),
              _field(_descCtrl, 'Mô tả', maxLines: 3),
              _field(_priceCtrl, 'Giá (VND)', keyboard: TextInputType.number, required: true),
              _field(_durationCtrl, 'Thời lượng (VD: 3N2Đ)'),
              _field(_departureCtrl, 'Điểm khởi hành (VD: TP.HCM)'),
              _field(_destinationsCtrl, 'Điểm đến (phân cách bằng dấu phẩy)'),
              _field(_includesCtrl, 'Bao gồm (phân cách bằng dấu phẩy)'),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: AppTheme.primaryBlue),
          onPressed: () {
            if (!_formKey.currentState!.validate()) return;
            final data = <String, dynamic>{
              'name': _nameCtrl.text.trim(),
              'description': _descCtrl.text.trim(),
              'price': double.tryParse(_priceCtrl.text.trim()) ?? 0,
              'duration': _durationCtrl.text.trim(),
              'departure': _departureCtrl.text.trim(),
              'destinations': _destinationsCtrl.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
              'includes': _includesCtrl.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
            };
            Navigator.pop(context, data);
          },
          child: Text(isEditing ? 'Cập nhật' : 'Thêm'),
        ),
      ],
    );
  }

  Widget _field(TextEditingController ctrl, String label,
      {bool required = false, TextInputType? keyboard, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: ctrl,
        keyboardType: keyboard,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
        validator: required ? (v) => (v == null || v.trim().isEmpty) ? 'Bắt buộc' : null : null,
      ),
    );
  }
}

// ── Room Manager Screen ────────────────────────────────────────────────

class _RoomManagerScreen extends ConsumerStatefulWidget {
  final Hotel hotel;
  const _RoomManagerScreen({required this.hotel});

  @override
  ConsumerState<_RoomManagerScreen> createState() => _RoomManagerScreenState();
}

class _RoomManagerScreenState extends ConsumerState<_RoomManagerScreen> {
  List<Room> _rooms = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRooms();
  }

  Future<void> _loadRooms() async {
    setState(() => _isLoading = true);
    try {
      final rooms = await ref.read(apiProvider).getPartnerHotelRooms(widget.hotel.id);
      setState(() => _rooms = rooms);
    } catch (e) {
      if (mounted) {
        final msg = e is ApiException ? e.message : 'Không thể kết nối server';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _showRoomForm({Room? room}) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => _RoomFormDialog(room: room),
    );
    if (result == null) return;
    setState(() => _isLoading = true);
    try {
      final api = ref.read(apiProvider);
      if (room != null) {
        await api.updatePartnerRoom(widget.hotel.id, room.id, result);
      } else {
        await api.createPartnerRoom(widget.hotel.id, result);
      }
      await _loadRooms();
    } catch (e) {
      if (mounted) {
        final msg = e is ApiException ? e.message : 'Không thể kết nối server';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: Colors.red),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteRoom(Room room) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xóa phòng'),
        content: Text('Bạn chắc chắn muốn xóa "${room.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    setState(() => _isLoading = true);
    try {
      await ref.read(apiProvider).deletePartnerRoom(widget.hotel.id, room.id);
      await _loadRooms();
    } catch (e) {
      if (mounted) {
        final msg = e is ApiException ? e.message : 'Không thể kết nối server';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: Colors.red),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Phòng - ${widget.hotel.name}'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _rooms.isEmpty
              ? const Center(child: Text('Chưa có phòng nào.\nNhấn + để thêm phòng.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _rooms.length,
                  itemBuilder: (context, index) {
                    final room = _rooms[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.bed, color: AppTheme.primaryBlue),
                        ),
                        title: Text(room.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('${room.capacity} khách • ${room.price.toInt()} VND/đêm'),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'edit') _showRoomForm(room: room);
                            if (value == 'delete') _deleteRoom(room);
                          },
                          itemBuilder: (_) => [
                            const PopupMenuItem(value: 'edit', child: Text('Chỉnh sửa')),
                            const PopupMenuItem(value: 'delete', child: Text('Xóa', style: TextStyle(color: Colors.red))),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primaryBlue,
        onPressed: _showRoomForm,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

// ── Room Form Dialog ──────────────────────────────────────────────────

class _RoomFormDialog extends StatefulWidget {
  final Room? room;
  const _RoomFormDialog({this.room});

  @override
  State<_RoomFormDialog> createState() => _RoomFormDialogState();
}

class _RoomFormDialogState extends State<_RoomFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _capacityCtrl;

  bool get isEditing => widget.room != null;

  @override
  void initState() {
    super.initState();
    final r = widget.room;
    _nameCtrl = TextEditingController(text: r?.name ?? '');
    _descCtrl = TextEditingController(text: r?.description ?? '');
    _priceCtrl = TextEditingController(text: r != null ? r.price.toInt().toString() : '');
    _capacityCtrl = TextEditingController(text: r != null ? r.capacity.toString() : '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _capacityCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(isEditing ? 'Sửa phòng' : 'Thêm phòng mới'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _field(_nameCtrl, 'Tên phòng', required: true),
              _field(_descCtrl, 'Mô tả'),
              _field(_priceCtrl, 'Giá (VND/đêm)', keyboard: TextInputType.number, required: true),
              _field(_capacityCtrl, 'Số khách tối đa', keyboard: TextInputType.number),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: AppTheme.primaryBlue),
          onPressed: () {
            if (!_formKey.currentState!.validate()) return;
            Navigator.pop(context, {
              'name': _nameCtrl.text.trim(),
              'description': _descCtrl.text.trim(),
              'price': double.tryParse(_priceCtrl.text.trim()) ?? 0,
              'capacity': int.tryParse(_capacityCtrl.text.trim()) ?? 1,
            });
          },
          child: Text(isEditing ? 'Cập nhật' : 'Thêm'),
        ),
      ],
    );
  }

  Widget _field(TextEditingController ctrl, String label,
      {bool required = false, TextInputType? keyboard, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: ctrl,
        keyboardType: keyboard,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
        validator: required ? (v) => (v == null || v.trim().isEmpty) ? 'Bắt buộc' : null : null,
      ),
    );
  }
}
