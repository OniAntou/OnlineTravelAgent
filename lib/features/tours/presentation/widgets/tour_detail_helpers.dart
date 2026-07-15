import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../domain/tour_package.dart';

class TourDetailHelpers {
  static List<LatLng> getCoordinates(TourPackage tour) {
    final Map<String, LatLng> coordsMap = {
      'đà nẵng': const LatLng(16.0544, 108.2022),
      'hội an': const LatLng(15.8801, 108.3380),
      'huế': const LatLng(16.4637, 107.5908),
      'phú quốc': const LatLng(10.2899, 103.9840),
      'đà lạt': const LatLng(11.9404, 108.4583),
      'sapa': const LatLng(22.3364, 103.8438),
      'sa pa': const LatLng(22.3364, 103.8438),
      'hạ long': const LatLng(20.9501, 107.0733),
      'vịnh hạ long': const LatLng(20.9501, 107.0733),
      'hà nội': const LatLng(21.0285, 105.8542),
      'hồ chí minh': const LatLng(10.8231, 106.6297),
      'sài gòn': const LatLng(10.8231, 106.6297),
      'nha trang': const LatLng(12.2388, 109.1967),
    };

    final List<LatLng> points = [];
    for (final dest in tour.destinations) {
      final key = dest.toLowerCase().trim();
      LatLng? match;
      coordsMap.forEach((name, coord) {
        if (key.contains(name) || name.contains(key)) {
          match = coord;
        }
      });
      if (match != null) {
        points.add(match!);
      }
    }

    if (points.isEmpty) {
      points.add(const LatLng(16.0544, 108.2022)); // Center at Da Nang
    }
    return points;
  }

  static IconData getInclusionIcon(String title) {
    final key = title.toLowerCase().trim();
    if (key.contains('khách sạn') ||
        key.contains('hotel') ||
        key.contains('phòng') ||
        key.contains('nghỉ')) {
      return Icons.hotel_rounded;
    } else if (key.contains('ăn') ||
        key.contains('food') ||
        key.contains('sáng') ||
        key.contains('trưa') ||
        key.contains('tối') ||
        key.contains('bữa')) {
      return Icons.flatware_rounded;
    } else if (key.contains('xe') ||
        key.contains('đưa đón') ||
        key.contains('bus') ||
        key.contains('di chuyển') ||
        key.contains('vận chuyển')) {
      return Icons.directions_bus_rounded;
    } else if (key.contains('vé') ||
        key.contains('ticket') ||
        key.contains('cổng') ||
        key.contains('tham quan')) {
      return Icons.local_activity_rounded;
    } else if (key.contains('hướng dẫn') || key.contains('guide')) {
      return Icons.people_rounded;
    } else if (key.contains('bảo hiểm')) {
      return Icons.security_rounded;
    } else if (key.contains('nước') || key.contains('uống')) {
      return Icons.local_drink_rounded;
    }
    return Icons.check_circle_rounded;
  }

  static List<Map<String, dynamic>> generateItinerary(TourPackage tour) {
    final destinations = tour.destinations;
    if (destinations.isEmpty) {
      return [
        {
          'day': 'Ngày 1',
          'title': 'Khởi hành & Khám phá hành trình',
          'desc':
              'Bắt đầu chuyến du lịch đầy hứa hẹn. Xe và hướng dẫn viên đón Quý khách tại điểm hẹn, khởi hành tham quan các địa danh danh tiếng và làm thủ tục nhận phòng khách sạn nghỉ ngơi.',
          'milestones': [
            {
              'time': '08:00',
              'event': 'Xe và HDV đón khách tại điểm hẹn, khởi hành.',
            },
            {'time': '12:00', 'event': 'Ăn trưa tại nhà hàng ẩm thực bản địa.'},
            {
              'time': '14:00',
              'event': 'Làm thủ tục nhận phòng khách sạn & nghỉ ngơi.',
            },
            {'time': '18:00', 'event': 'Ăn tối ấm cúng và tự do khám phá.'},
          ],
        },
      ];
    }

    final List<Map<String, dynamic>> itinerary = [];
    for (int i = 0; i < destinations.length; i++) {
      final dest = destinations[i];
      if (i == 0) {
        itinerary.add({
          'day': 'Ngày 1',
          'title': 'Chào đón & Trải nghiệm $dest',
          'desc':
              'Chào đón Quý khách tại điểm tập trung. Xe đưa Quý khách tham quan các thắng cảnh biểu tượng của $dest, tìm hiểu nét đẹp lịch sử văn hóa địa phương.',
          'milestones': [
            {
              'time': '08:30',
              'event':
                  'Đón khách tại điểm hẹn, di chuyển đến điểm tham quan đầu tiên.',
            },
            {
              'time': '10:00',
              'event': 'Khám phá danh lam thắng cảnh nổi bật tại $dest.',
            },
            {
              'time': '12:00',
              'event': 'Thưởng thức bữa trưa đặc sản vùng miền.',
            },
            {
              'time': '14:30',
              'event': 'Nhận phòng khách sạn, nghỉ ngơi tự do.',
            },
            {
              'time': '18:00',
              'event': 'Bữa tối ngon miệng và dạo chơi phố phường về đêm.',
            },
          ],
        });
      } else {
        itinerary.add({
          'day': 'Ngày ${i + 1}',
          'title': 'Hành trình di sản tại $dest',
          'desc':
              'Di chuyển khám phá mảnh đất $dest đầy quyến rũ và giàu bản sắc văn hóa.',
          'milestones': [
            {
              'time': '07:30',
              'event': 'Dùng điểm tâm sáng buffet tại khách sạn.',
            },
            {
              'time': '09:00',
              'event': 'Khởi hành hành trình khám phá chiều sâu $dest.',
            },
            {
              'time': '12:30',
              'event': 'Nghỉ ngơi và dùng cơm trưa tại nhà hàng đặc sản.',
            },
            {
              'time': '15:00',
              'event': 'Tham gia các hoạt động vui chơi giải trí địa phương.',
            },
            {
              'time': '18:30',
              'event':
                  'Dùng bữa tối hải sản thịnh soạn, tự do tham quan phố đêm.',
            },
          ],
        });
      }
    }

    itinerary.add({
      'day': 'tour_detail.day'.tr(args: [(destinations.length + 1).toString()]),
      'title': 'Mua sắm đặc sản & Kết thúc hành trình',
      'desc': 'Thư giãn nghỉ ngơi, chuẩn bị hành lý trở về.',
      'milestones': [
        {
          'time': '07:30',
          'event': 'Ăn sáng, dạo phố nhâm nhi cà phê sáng bình yên.',
        },
        {
          'time': '10:00',
          'event': 'Tự do mua sắm các món quà lưu niệm ý nghĩa.',
        },
        {'time': '11:30', 'event': 'Làm thủ tục trả phòng khách sạn.'},
        {'time': '12:30', 'event': 'Bữa trưa nhẹ nhàng ấm cúng.'},
        {
          'time': '14:30',
          'event': 'Xe tiễn đoàn ra sân bay/nhà ga, kết thúc tour tốt đẹp.',
        },
      ],
    });

    return itinerary;
  }
}
