import 'package:flutter/material.dart';

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About App', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.lightBlue,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const CircleAvatar(
              radius: 60,
              backgroundColor: Colors.lightBlue,
              child: Icon(Icons.school, size: 70, color: Colors.white),
            ),
            const SizedBox(height: 24),
            const Text(
              'StudentHub',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.lightBlue,
              ),
            ),
            const Text(
              'Version 1.0.0',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),
            _buildInfoCard(
              title: 'Mục tiêu',
              content: 'StudentHub là giải pháp toàn diện giúp sinh viên quản lý việc học, kết nối câu lạc bộ và cập nhật tin tức trường học một cách nhanh chóng nhất.',
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              title: 'Tính năng chính',
              content: '• Quản lý thời khóa biểu\n• Đăng ký sự kiện & câu lạc bộ\n• Xem điểm & báo cáo học tập\n• Thông báo tức thì',
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              title: 'Phát triển bởi',
              content: 'Đội ngũ phát triển PRM Project.\n© 2024 StudentHub Team.',
            ),
            const SizedBox(height: 40),
            const Text(
              'Cảm ơn bạn đã sử dụng ứng dụng!',
              style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({required String title, required String content}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.lightBlue,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              content,
              style: const TextStyle(fontSize: 15, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
