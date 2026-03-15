import 'package:bai1/screens/club_details.dart';
import 'package:bai1/widgets/custom_bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:bai1/models/club.dart';
import 'package:bai1/controllers/club_controller.dart';

class ClubsScreen extends StatefulWidget {
  const ClubsScreen({super.key});

  @override
  State<ClubsScreen> createState() => _ClubsScreenState();
}

class _ClubsScreenState extends State<ClubsScreen> {
  final ClubController _controller = ClubController();
  List<Club> _clubs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchClubs();
  }

  Future<void> _fetchClubs() async {
    final clubs = await _controller.fetchClubs();
    setState(() {
      _clubs = clubs;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Student Clubs',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.orange,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // 2 cột
          childAspectRatio: 0.8, // Tỷ lệ khung hình (cao hơn rộng)
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: _clubs.length,
        itemBuilder: (context, index) {
          final club = _clubs[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ClubDetailScreen(club: {
                    'id': club.id,
                    'name': club.name,
                    'category': club.category,
                    'members': club.members,
                    'image': club.image ?? 'https://via.placeholder.com/200',
                    'description': club.description ?? '',
                    'status': club.status ?? 'Active',
                  }),
                ),
              );
            },
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo tròn
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: NetworkImage(club.image ?? 'https://via.placeholder.com/200'),
                          fit: BoxFit.cover,
                        ),
                      ),
                      margin: const EdgeInsets.all(16),
                    ),
                  ),
                  Text(
                    club.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    club.category,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: -1,
        args: ModalRoute.of(context)?.settings.arguments,
      ),
    );
  }
}
