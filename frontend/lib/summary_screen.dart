import 'package:flutter/material.dart';

// --- Custom Widget for Displaying Single Email Summary ---
class EmailSummaryCard extends StatelessWidget {
  final dynamic summary;

  const EmailSummaryCard({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    List<String> bullets = List<String>.from(summary['summary'] ?? []);

    return Card(
      margin: const EdgeInsets.fromLTRB(8,10,8,16,),
      elevation: 16,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      shadowColor: Colors.black12,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Subject (Header) - Deep blue
            Text(
              summary['subject'] ?? 'No Subject',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF204ECF),
              ),
            ),
            const SizedBox(height: 4),
            // Sender (Subtitle)
            Text(
              'From: ${summary['sender'] ?? 'Unknown'}',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 8),
            // Bullet Point Summary List
            ...bullets.map((point) => Padding(
                  padding: const EdgeInsets.only(bottom: 6.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '• ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFF204ECF),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          point,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.black87,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                )).toList(),
          ],
        ),
      ),
    );
  }
}

// --- Summary Display Screen ---
class SummaryScreen extends StatelessWidget {
  final List<dynamic> summaries;

  const SummaryScreen({super.key, required this.summaries});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        titleSpacing: 0, // Move title closer to back arrow
        title: const Text(
          'Summarized Format',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Color(0xFF204ECF),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Color(0xFF204ECF)),
      ),
      body: summaries.isEmpty
          ? const Center(
              child: Text(
                "No summaries were returned.",
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
            )
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: ListView(
                children: [
                  const SizedBox(height: 8),
                  // Smaller "Summary Results"
                  const Text(
                    'Summary Results:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color.fromARGB(221, 2, 7, 89),
                    ),
                  ),
                  const SizedBox(height: 12), // Space instead of divider

                  // Results List Area
                  ...summaries.map((summary) {
                    return EmailSummaryCard(summary: summary);
                  }).toList(),
                ],
              ),
            ),
    );
  }
}
