import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:sewa_hub/core/sensors/location/location_service.dart';

/// Result returned when user confirms a location
class LocationPickerResult {
  final LatLng latLng;
  final String address;

  const LocationPickerResult({required this.latLng, required this.address});
}

class LocationPickerScreen extends ConsumerStatefulWidget {
  const LocationPickerScreen({super.key});

  @override
  ConsumerState<LocationPickerScreen> createState() =>
      _LocationPickerScreenState();
}

class _LocationPickerScreenState
    extends ConsumerState<LocationPickerScreen> {
  static const _orange = Color(0xFFFF6B35);

  final MapController _mapController = MapController();

  LatLng  _selected = const LatLng(27.7172, 85.3240); // Default: Kathmandu
  String  _address  = 'Locating...';
  bool    _loading  = true;
  bool    _geocoding = false;

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _initLocation() async {
    final pos = await ref
        .read(locationServiceProvider)
        .getCurrentPosition(context);

    if (pos != null && mounted) {
      final latLng = LatLng(pos.latitude, pos.longitude);
      setState(() {
        _selected = latLng;
        _loading  = false;
      });
      _mapController.move(latLng, 16);
      await _reverseGeocode(latLng);
    } else if (mounted) {
      setState(() => _loading = false);
      await _reverseGeocode(_selected);
    }
  }

  // ── OSM Nominatim reverse geocoding (free, no key) ────────────────────────
  Future<void> _reverseGeocode(LatLng latLng) async {
    if (!mounted) return;
    setState(() => _geocoding = true);

    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse'
        '?lat=${latLng.latitude}&lon=${latLng.longitude}'
        '&format=json&addressdetails=1',
      );

      final response = await http.get(uri, headers: {
        'Accept-Language': 'en',
        'User-Agent': 'SewaHub/1.0',
      });

      if (response.statusCode == 200 && mounted) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final addr = data['address'] as Map<String, dynamic>? ?? {};

        final parts = [
          addr['road']          as String?,
          addr['suburb']        as String?,
          addr['city']          as String? ??
              addr['town']      as String? ??
              addr['village']   as String?,
          addr['state']         as String?,
        ].where((s) => s != null && s.isNotEmpty).toList();

        setState(() => _address =
            parts.isNotEmpty ? parts.join(', ') : 'Unknown location');
      }
    } catch (_) {
      if (mounted) setState(() => _address = 'Unknown location');
    } finally {
      if (mounted) setState(() => _geocoding = false);
    }
  }

  void _onMapEvent(MapEvent event) {
    if (event is MapEventMoveEnd) {
      _selected = event.camera.center;
      _reverseGeocode(_selected);
    }
  }

  void _confirm() {
    Navigator.pop(
      context,
      LocationPickerResult(latLng: _selected, address: _address),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
        title: const Text(
          'Pick Location',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: const Color(0xFFF1F5F9)),
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: _orange))
          : Stack(
              children: [
                // ── OpenStreetMap ─────────────────────────────────────
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _selected,
                    initialZoom:   16,
                    onMapEvent:    _onMapEvent,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.sewa_hub',
                    ),
                  ],
                ),

                // ── Centre pin (map moves under it) ───────────────────
                const Center(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 48),
                    child: Icon(
                      Icons.location_pin,
                      color: _orange,
                      size:  48,
                      shadows: [
                        Shadow(
                          color:      Colors.black26,
                          blurRadius: 8,
                          offset:     Offset(0, 4),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── My location button ────────────────────────────────
                Positioned(
                  right:  16,
                  bottom: 150,
                  child: FloatingActionButton.small(
                    heroTag:         'my_location',
                    backgroundColor: Colors.white,
                    elevation:       4,
                    onPressed:       _initLocation,
                    child: const Icon(Icons.my_location, color: _orange),
                  ),
                ),

                // ── Address card + confirm ────────────────────────────
                Positioned(
                  left:   0,
                  right:  0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                          top: Radius.circular(20)),
                      boxShadow: [
                        BoxShadow(
                          color:      Color(0x1A000000),
                          blurRadius: 20,
                          offset:     Offset(0, -4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize:     MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Drag handle
                        Center(
                          child: Container(
                            width:  40,
                            height: 4,
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color:        Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),

                        const Text(
                          'Selected Location',
                          style: TextStyle(
                            fontSize:   12,
                            color:      Color(0xFF6B7280),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 6),

                        Row(
                          children: [
                            const Icon(Icons.location_on,
                                color: _orange, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _geocoding
                                  ? const Row(
                                      children: [
                                        SizedBox(
                                          width: 14, height: 14,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: _orange,
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Text('Getting address...',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Color(0xFF9CA3AF),
                                            )),
                                      ],
                                    )
                                  : Text(
                                      _address,
                                      style: const TextStyle(
                                        fontSize:   14,
                                        fontWeight: FontWeight.w600,
                                        color:      Color(0xFF0F172A),
                                      ),
                                    ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        SizedBox(
                          width:  double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _geocoding ? null : _confirm,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _orange,
                              foregroundColor: Colors.white,
                              elevation:       0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                            ),
                            child: const Text(
                              'Confirm Location',
                              style: TextStyle(
                                fontSize:   15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }
}