import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../../../core/theme/app_theme.dart';

class TravelStoriesSection extends StatelessWidget {
  const TravelStoriesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final stories = [
      {
        'name': 'Hồng Nhung',
        'avatar': 'https://randomuser.me/api/portraits/women/44.jpg',
        'location': 'Sa Pa, VN',
        'comment':
            'Bản Cát Cát thật yên bình, mây mù phủ kín thung lũng mộng mơ vào sáng sớm!',
        'rating': '5.0',
        'image': 'assets/images/sapa_image.png',
      },
      {
        'name': 'Quốc Anh',
        'avatar': 'https://randomuser.me/api/portraits/men/32.jpg',
        'location': 'Vịnh Hạ Long, VN',
        'comment':
            'Chèo thuyền kayak vượt qua Hang Luồn hoang sơ là một trải nghiệm không thể quên!',
        'rating': '4.9',
        'image': 'assets/images/halong_image.png',
      },
      {
        'name': 'Minh Huy',
        'avatar': 'https://randomuser.me/api/portraits/men/46.jpg',
        'location': 'Đà Nẵng, VN',
        'comment':
            'Hoàng hôn trên Cầu Vàng rất hùng vĩ, mây núi hòa quyện say đắm lòng người.',
        'rating': '4.8',
        'image': 'assets/images/danang_image.png',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Cảm hứng du lịch',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 190,
          child: AnimationLimiter(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              itemCount: stories.length,
              separatorBuilder: (_, _) => const SizedBox(width: 16),
              itemBuilder: (context, index) {
                final story = stories[index];
                return AnimationConfiguration.staggeredList(
                  position: index,
                  duration: const Duration(milliseconds: 400),
                  child: SlideAnimation(
                    horizontalOffset: 50.0,
                    child: FadeInAnimation(
                      child: Container(
                        width: 280,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                          border: Border.all(
                            color: Colors.grey.withValues(alpha: 0.08),
                          ),
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.asset(
                                story['image']!,
                                width: 90,
                                height: 166,
                                fit: BoxFit.cover,
                                cacheWidth:
                                    (90 *
                                            MediaQuery.devicePixelRatioOf(
                                              context,
                                            ))
                                        .round(),
                                filterQuality: FilterQuality.low,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                      width: 90,
                                      color: Colors.grey[200],
                                      child: const Icon(
                                        Icons.image,
                                        color: Colors.grey,
                                      ),
                                    ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      ClipOval(
                                        child: Image.network(
                                          story['avatar']!,
                                          width: 24,
                                          height: 24,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) =>
                                              Container(
                                            width: 24,
                                            height: 24,
                                            color: Colors.grey[300],
                                            child: const Icon(Icons.person,
                                                size: 16, color: Colors.grey),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          story['name']!,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.location_on,
                                        size: 10,
                                        color: AppTheme.primaryBlue,
                                      ),
                                      const SizedBox(width: 2),
                                      Text(
                                        story['location']!,
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Expanded(
                                    child: Text(
                                      story['comment']!,
                                      style: TextStyle(
                                        color: Colors.grey[800],
                                        fontSize: 11,
                                        height: 1.4,
                                      ),
                                      maxLines: 4,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.star,
                                        size: 12,
                                        color: Colors.amber,
                                      ),
                                      const SizedBox(width: 2),
                                      Text(
                                        story['rating']!,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 11,
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
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
