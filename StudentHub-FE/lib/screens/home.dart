import 'package:bai1/widgets/custom_bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:bai1/models/news.dart';
import 'package:bai1/controllers/news_controller.dart';

final List<Map<String, dynamic>> menuItems = [
  {
    'icon': Icons.assignment,
    'label': 'Mark Report',
    'route': '/mark_report',
    'roles': ['Student'],
  },
  {
    'icon': Icons.edit_note,
    'label': 'Grade Management',
    'route': '/manage_grades',
    'roles': ['Staff'],
  },
  {
    'icon': Icons.description,
    'label': 'Reports',
    'route': '/report',
    'roles': ['Student'],
  },
  {
    'icon': Icons.assignment_turned_in,
    'label': 'Absences',
    'route': '/manage_absences',
    'roles': ['Staff'],
  },
  {
    'icon': Icons.calendar_today,
    'label': 'Schedule',
    'route': '/schedule',
    'roles': ['Student', 'Staff'],
  },
  {
    'icon': Icons.newspaper,
    'label': 'Events',
    'route': '/events',
    'roles': ['Student', 'Admin'],
  },
  {
    'icon': Icons.people,
    'label': 'Clubs',
    'route': '/clubs',
    'roles': ['Student', 'Admin'],
  },
  // {
  //   'icon': Icons.computer,
  //   'label': 'E-Learn',
  //   'route': null,
  //   'roles': ['Student'],
  // },
  // {
  //   'icon': Icons.phone,
  //   'label': 'Contact',
  //   'route': null,
  //   'roles': ['Student', 'Staff', 'Admin'],
  // },
  // {
  //   'icon': Icons.bed,
  //   'label': 'Dorm',
  //   'route': null,
  //   'roles': ['Student'],
  // },
  {
    'icon': Icons.admin_panel_settings,
    'label': 'Admin Account',
    'route': '/admin_account',
    'roles': ['Admin'],
  },
  {
    'icon': Icons.assignment_ind,
    'label': 'Class Assignment',
    'route': '/class_assignment',
    'roles': ['Admin'],
  },
  {
    'icon': Icons.edit_calendar,
    'label': 'Manage Schedule',
    'route': '/manage_schedule',
    'roles': ['Admin'],
  },
  {
    'icon': Icons.menu_book,
    'label': 'Subject Management',
    'route': '/manage_subjects',
    'roles': ['Admin'],
  },
];

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final NewsController _controller = NewsController();
  List<News> _newsItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchNews();
  }

  Future<void> _fetchNews() async {
    final news = await _controller.fetchNews();
    setState(() {
      _newsItems = news;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as dynamic;

    // Extract information with fallback for English localization
    final String fullName = args?.fullName ?? "Anonymous User";
    final String role = (args?.role ?? "Student").toString().trim();
    final String rollNumber = args?.rollNumber ?? "N/A";

    // Split comma-separated roles (e.g. "Student,Admin") into a list
    final List<String> userRoles = role
        .split(',')
        .map((r) => r.trim().toLowerCase())
        .toList();

    final filteredItems = menuItems.where((item) {
      final List<String> roles = List<String>.from(item['roles'] ?? []);
      return roles.any((r) => userRoles.contains(r.trim().toLowerCase()));
    }).toList();

    debugPrint("Home: Current Role: '$role'");
    debugPrint(
      "Home: Filtered Items: ${filteredItems.map((e) => e['label']).toList()}",
    );

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Modern Header with Gradient and Logo
            Container(
              padding: const EdgeInsets.fromLTRB(20, 50, 20, 30),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.lightBlue.shade700,
                    Colors.lightBlue.shade400,
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.lightBlue.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Logo
                      Image.asset(
                        'assets/icon/student_hub_logo.png',
                        height: 40,
                        // color: Colors.white, // Remove tint if logo has colors
                        errorBuilder: (context, error, stackTrace) => 
                          const Icon(Icons.school, color: Colors.white, size: 30),
                      ),
                      // Notification Icon
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.notifications_none, color: Colors.white),
                          onPressed: () {},
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  // User Info Section
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.white.withOpacity(0.3),
                        child: const Icon(Icons.person, color: Colors.white, size: 35),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              fullName,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text.rich(
                              TextSpan(
                                style: const TextStyle(color: Colors.white70, fontSize: 14),
                                children: [
                                  TextSpan(text: "Role: $role"),
                                  if (userRoles.contains("student")) ...[
                                    const TextSpan(text: " • ID: "),
                                    TextSpan(
                                      text: rollNumber,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 20),

              GridView.count(
                crossAxisCount: 4,
                childAspectRatio: 0.85,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: List.generate(filteredItems.length, (index) {
                  final item = filteredItems[index];

                  return GestureDetector(
                    onTap: () {
                      if (item['route'] != null) {
                        // Pass specific arguments for different screens
                        if (item['route'] == '/report') {
                          Navigator.pushNamed(
                            context,
                            item['route'],
                            arguments: args,
                          );
                        } else if (item['route'] == '/schedule') {
                          Navigator.pushNamed(
                            context,
                            item['route'],
                            arguments: args,
                          );
                        } else if (item['route'] == '/mark_report') {
                          Navigator.pushNamed(
                            context,
                            item['route'],
                            arguments: args?.studentId,
                          );
                        } else if (item['route'] == '/manage_grades') {
                          Navigator.pushNamed(
                            context,
                            '/manage_grades',
                            arguments: args,
                          );
                        } else if (item['route'] == '/events') {
                          if (userRoles.contains("admin")) {
                            Navigator.pushNamed(context, '/manage_events');
                          } else {
                            Navigator.pushNamed(context, item['route']);
                          }
                        } else if (item['route'] == '/clubs') {
                          if (userRoles.contains("admin")) {
                            Navigator.pushNamed(context, '/manage_clubs');
                          } else {
                            Navigator.pushNamed(context, item['route']);
                          }
                        } else if (item['route'] == '/manage_absences') {
                          Navigator.pushNamed(
                            context,
                            item['route'],
                            arguments: args,
                          );
                        } else {
                          Navigator.pushNamed(context, item['route']);
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Feature not implemented yet'),
                          ),
                        );
                      }
                    },
                    child: Container(
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Icon(
                              item["icon"],
                              size: 28,
                              color: Colors.lightBlue,
                            ),
                          ),
                          const SizedBox(height: 6),

                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              item["label"],
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 10),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),

              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _newsItems.length,
                      itemBuilder: (context, index) {
                        final item = _newsItems[index];

                        return Container(
                          margin: const EdgeInsets.all(8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          item.image ??
                                              'https://via.placeholder.com/1000x500',
                                          width: 1000,
                                          height: 500,
                                          fit: BoxFit.cover,
                                          errorBuilder: (ctx, err, stack) =>
                                              const Icon(Icons.image, size: 50),
                                        ),
                                      ),
                                      Text(
                                        item.title,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        softWrap: true,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        item.content ?? '',
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                        softWrap: true,
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: 0,
        args: args,
      ),
    );
  }
}
