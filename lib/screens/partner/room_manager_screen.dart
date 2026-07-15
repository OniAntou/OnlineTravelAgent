import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../models/hotel.dart';
import '../../models/room.dart';
import '../../providers/api_provider.dart';
import '../../utils/api_exception.dart';
import '../../utils/dialog_utils.dart';
import '../../widgets/shimmer_loading.dart';
import 'widgets/room_form_dialog.dart';

class RoomManagerScreen extends ConsumerStatefulWidget {
  final Hotel hotel;
  const RoomManagerScreen({super.key, required this.hotel});

  @override
  ConsumerState<RoomManagerScreen> createState() => _RoomManagerScreenState();
}

class _RoomManagerScreenState extends ConsumerState<RoomManagerScreen> {
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
      final rooms = await ref
          .read(apiProvider)
          .getPartnerHotelRooms(widget.hotel.id);
      if (!mounted) return;
      setState(() => _rooms = rooms);
    } catch (e) {
      if (mounted) {
        final msg = e is ApiException ? e.message : 'Không thể kết nối server';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _showRoomForm({Room? room}) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => RoomFormDialog(room: room),
    );
    if (result == null || !mounted) return;
    setState(() => _isLoading = true);
    try {
      final api = ref.read(apiProvider);
      if (room != null) {
        await api.updatePartnerRoom(widget.hotel.id, room.id, result);
      } else {
        await api.createPartnerRoom(widget.hotel.id, result);
      }
      if (!mounted) return;
      await _loadRooms();
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

  Future<void> _deleteRoom(Room room) async {
    final confirm = await showConfirmDialog(
      context: context,
      title: 'Xóa phòng',
      content: 'Bạn chắc chắn muốn xóa "${room.name}"?',
      confirmText: 'Xóa',
      isDestructive: true,
    );
    if (confirm != true || !mounted) return;
    setState(() => _isLoading = true);
    try {
      await ref.read(apiProvider).deletePartnerRoom(widget.hotel.id, room.id);
      if (!mounted) return;
      await _loadRooms();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Phòng - ${widget.hotel.name}')),
      body: _isLoading
          ? const Padding(
              padding: EdgeInsets.all(16.0),
              child: ReviewCardShimmer(),
            )
          : _rooms.isEmpty
          ? const Center(
              child: Text('Chưa có phòng nào.\nNhấn + để thêm phòng.'),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _rooms.length,
              itemBuilder: (context, index) {
                final room = _rooms[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
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
                    title: Text(
                      room.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${room.capacity} khách • ${room.price.toInt()} VND/đêm',
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') _showRoomForm(room: room);
                        if (value == 'delete') _deleteRoom(room);
                      },
                      itemBuilder: (_) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Text('Chỉnh sửa'),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text(
                            'Xóa',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
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
