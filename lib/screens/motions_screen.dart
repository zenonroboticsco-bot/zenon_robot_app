import 'package:flutter/material.dart';
import '../services/api_service.dart';

class MotionsScreen extends StatefulWidget {
  const MotionsScreen({super.key});

  @override
  State<MotionsScreen> createState() => _MotionsScreenState();
}

class _MotionsScreenState extends State<MotionsScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'All';
  bool _robotStarted = false;

  final Map<String, List<Map<String, dynamic>>> _motions = {
    'Basic': [
      {'name': 'stand', 'icon': Icons.accessibility, 'color': Colors.blue},
      {'name': 'crouch', 'icon': Icons.airline_seat_recline_normal, 'color': Colors.blue},
      {'name': 'tall_stand', 'icon': Icons.height, 'color': Colors.blue},
    ],
    'Gestures': [
      {'name': 'wave', 'icon': Icons.waving_hand, 'color': Colors.orange},
      {'name': 'bow', 'icon': Icons.emoji_people, 'color': Colors.orange},
      {'name': 'deep_bow', 'icon': Icons.emoji_people, 'color': Colors.orange},
      {'name': 'nod_yes', 'icon': Icons.check_circle, 'color': Colors.green},
      {'name': 'shake_no', 'icon': Icons.cancel, 'color': Colors.red},
    ],
    'Movement': [
      {'name': 'move_forward', 'icon': Icons.arrow_upward, 'color': Colors.blue},
      {'name': 'move_backward', 'icon': Icons.arrow_downward, 'color': Colors.blue},
      {'name': 'turn_left', 'icon': Icons.arrow_back, 'color': Colors.blue},
      {'name': 'turn_right', 'icon': Icons.arrow_forward, 'color': Colors.blue},
      {'name': 'spin', 'icon': Icons.refresh, 'color': Colors.purple},
      {'name': 'wheels_stop', 'icon': Icons.stop, 'color': Colors.red},
    ],
    'Complex': [
      {'name': 'dance', 'icon': Icons.music_note, 'color': Colors.pink},
      {'name': 'crawl', 'icon': Icons.pets, 'color': Colors.brown},
      {'name': 'celebration', 'icon': Icons.celebration, 'color': Colors.amber},
      {'name': 'patrol', 'icon': Icons.security, 'color': Colors.blue},
      {'name': 'look_around', 'icon': Icons.threed_rotation, 'color': Colors.cyan},
    ],
  };

  List<Map<String, dynamic>> get _filteredMotions {
    List<Map<String, dynamic>> all = [];
    if (_selectedCategory == 'All') {
      _motions.forEach((_, m) => all.addAll(m));
    } else {
      all = _motions[_selectedCategory] ?? [];
    }
    if (_searchQuery.isNotEmpty) {
      all = all.where((m) => m['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }
    return all;
  }

  Future<void> _ensureRobotStarted() async {
    if (_robotStarted) return;
    
    final result = await ApiService.startRobot();
    if (result['success'] == true) {
      setState(() => _robotStarted = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF1a1a2e), const Color(0xFF16213e).withOpacity(0.8)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(16),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search motions...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchQuery.isNotEmpty ? IconButton(icon: const Icon(Icons.clear), onPressed: () => setState(() => _searchQuery = '')) : null,
                    ),
                    onChanged: (v) => setState(() => _searchQuery = v),
                  ),
                ),
                SizedBox(
                  height: 50,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      _buildCategoryChip('All'),
                      ..._motions.keys.map(_buildCategoryChip),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 1.2, crossAxisSpacing: 12, mainAxisSpacing: 12),
              itemCount: _filteredMotions.length,
              itemBuilder: (context, i) => _buildMotionCard(_filteredMotions[i]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String cat) {
    final sel = _selectedCategory == cat;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(label: Text(cat), selected: sel, onSelected: (_) => setState(() => _selectedCategory = cat), selectedColor: const Color(0xFF667EEA), checkmarkColor: Colors.white),
    );
  }

  Widget _buildMotionCard(Map<String, dynamic> m) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: () => _runMotion(m['name']),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: (m['color'] as Color).withOpacity(0.2), shape: BoxShape.circle),
                child: Icon(m['icon'], size: 32, color: m['color']),
              ),
              const SizedBox(height: 12),
              Text(m['name'].replaceAll('_', ' ').toUpperCase(), textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _runMotion(String name) async {
    // Auto-start robot if needed
    //await _ensureRobotStarted();
    
    showDialog(context: context, barrierDismissible: false, builder: (c) => AlertDialog(content: Column(mainAxisSize: MainAxisSize.min, children: [const CircularProgressIndicator(), const SizedBox(height: 16), Text('Running $name...')])));
    
    final result = await ApiService.runMotion(name);
    
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['success'] == true ? '✓ $name completed' : '✗ $name failed'), backgroundColor: result['success'] == true ? Colors.green : Colors.red, duration: const Duration(seconds: 2)),
      );
    }
  }
}
