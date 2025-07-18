import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class ReviewPage extends StatefulWidget {
  const ReviewPage({super.key});

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  double _rating = 0;
  final _controller = TextEditingController();

  final List<Map<String, dynamic>> _places = [
    {
      'name': 'Ruang Bimbel Denpasar',
      'location': LatLng(-8.6525, 115.2195),
    },
    {
      'name': 'Bimbel Brain Academy Renon',
      'location': LatLng(-8.6833, 115.2294),
    },
    {
      'name': 'English Academy Center Renon',
      'location': LatLng(-8.6880, 115.2365),
    },
  ];

  void _showReviewDialog(String placeName) {
    // ... (Fungsi ini tidak perlu diubah)
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      builder: (_) {
        return Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Review untuk $placeName',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return GestureDetector(
                      onTap: () => setState(() => _rating = index + 1.0),
                      child: Icon(
                        index < _rating ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 32,
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _controller,
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: 'Tulis ulasan singkat...',
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.all(12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Terima kasih atas ulasanmu!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    setState(() {
                      _rating = 0;
                      _controller.clear();
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Kirim Ulasan'),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final markers = _places.map((place) {
      return Marker(
        width: 80,
        height: 80,
        point: place['location'],
        child: GestureDetector(
          onTap: () => _showReviewDialog(place['name']),
          child: const Icon(Icons.location_on, size: 40, color: Colors.red),
        ),
      );
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Tempat Les'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: LatLng(-8.6705, 115.2126),
          initialZoom: 12.5,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.app',
            // tileProvider dihapus karena package caching dihapus
          ),
          MarkerLayer(markers: markers),
        ],
      ),
    );
  }
}