import 'package:flutter/material.dart';

import '../../../../core/utils/app_utils.dart';
import '../../application/hotel_catalog_filter.dart';

Future<HotelCatalogFilter?> showHotelFilterSheet(
  BuildContext context, {
  required HotelCatalogFilter initialFilter,
  required List<String> locations,
  required double catalogMaximumPrice,
}) {
  return showModalBottomSheet<HotelCatalogFilter>(
    context: context,
    backgroundColor: Colors.white,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => _HotelFilterSheet(
      initialFilter: initialFilter,
      locations: locations,
      catalogMaximumPrice: catalogMaximumPrice,
    ),
  );
}

class _HotelFilterSheet extends StatefulWidget {
  const _HotelFilterSheet({
    required this.initialFilter,
    required this.locations,
    required this.catalogMaximumPrice,
  });

  final HotelCatalogFilter initialFilter;
  final List<String> locations;
  final double catalogMaximumPrice;

  @override
  State<_HotelFilterSheet> createState() => _HotelFilterSheetState();
}

class _HotelFilterSheetState extends State<_HotelFilterSheet> {
  late HotelCatalogFilter _draft;

  @override
  void initState() {
    super.initState();
    _draft = widget.initialFilter;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.84,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Bộ lọc & sắp xếp',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Địa điểm',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final location in widget.locations)
                          FilterChip(
                            label: Text(location),
                            selected: _draft.location == location,
                            onSelected: (selected) {
                              setState(() {
                                _draft = selected
                                    ? _draft.copyWith(location: location)
                                    : _draft.copyWith(clearLocation: true);
                              });
                            },
                          ),
                      ],
                    ),
                    if (widget.catalogMaximumPrice > 0) ...[
                      const SizedBox(height: 20),
                      const Text(
                        'Giá tối đa',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Expanded(
                            child: Text(
                              'Không giới hạn',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            formatVND(
                              _draft.maximumPrice ?? widget.catalogMaximumPrice,
                            ),
                          ),
                        ],
                      ),
                      Slider(
                        key: const Key('hotel-price-slider'),
                        value:
                            _draft.maximumPrice ?? widget.catalogMaximumPrice,
                        max: widget.catalogMaximumPrice,
                        divisions: 20,
                        onChanged: (value) {
                          setState(() {
                            _draft = value >= widget.catalogMaximumPrice
                                ? _draft.copyWith(clearMaximumPrice: true)
                                : _draft.copyWith(maximumPrice: value);
                          });
                        },
                      ),
                    ],
                    const SizedBox(height: 20),
                    SwitchListTile(
                      key: const Key('hotel-availability'),
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Chỉ hiển thị nơi còn phòng'),
                      value: _draft.onlyWithRooms,
                      onChanged: (value) {
                        setState(
                          () => _draft = _draft.copyWith(onlyWithRooms: value),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Sắp xếp',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ChoiceChip(
                          label: const Text('Đề xuất'),
                          selected: _draft.sort == HotelCatalogSort.recommended,
                          onSelected: (_) {
                            setState(() {
                              _draft = _draft.copyWith(
                                sort: HotelCatalogSort.recommended,
                              );
                            });
                          },
                        ),
                        ChoiceChip(
                          key: const Key('hotel-sort-price-ascending'),
                          label: const Text('Giá tăng dần'),
                          selected:
                              _draft.sort == HotelCatalogSort.priceAscending,
                          onSelected: (_) {
                            setState(() {
                              _draft = _draft.copyWith(
                                sort: HotelCatalogSort.priceAscending,
                              );
                            });
                          },
                        ),
                        ChoiceChip(
                          label: const Text('Giá giảm dần'),
                          selected:
                              _draft.sort == HotelCatalogSort.priceDescending,
                          onSelected: (_) {
                            setState(() {
                              _draft = _draft.copyWith(
                                sort: HotelCatalogSort.priceDescending,
                              );
                            });
                          },
                        ),
                        ChoiceChip(
                          label: const Text('Nhiều phòng nhất'),
                          selected:
                              _draft.sort ==
                              HotelCatalogSort.roomCountDescending,
                          onSelected: (_) {
                            setState(() {
                              _draft = _draft.copyWith(
                                sort: HotelCatalogSort.roomCountDescending,
                              );
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      key: const Key('hotel-filter-reset'),
                      onPressed: () {
                        setState(() => _draft = const HotelCatalogFilter());
                      },
                      child: const Text('Đặt lại'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      key: const Key('hotel-filter-apply'),
                      onPressed: () => Navigator.pop(context, _draft),
                      child: const Text('Áp dụng'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
