import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'summary_screen.dart';

const String _apiUrl = 'http://127.0.0.1:5000/summarize';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = '';
  String? _fileName;

  // --- Animation for button ---
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // --- Pick File ---
 Future<void> _pickFile() async {
  FilePickerResult? result =
      await FilePicker.platform.pickFiles(type: FileType.any);

  if (result != null) {
    String fileContent;

    // Use `bytes` for Web, `path` for Desktop/Mobile
    if (result.files.single.bytes != null) {
      // Web or bytes available
      fileContent = utf8.decode(result.files.single.bytes!);
    } else if (result.files.single.path != null) {
      // Desktop / Mobile
      File file = File(result.files.single.path!);
      fileContent = await file.readAsString();
    } else {
      setState(() {
        _errorMessage = 'Failed to read file';
      });
      return;
    }

    setState(() {
      _controller.text = fileContent;
      _fileName = result.files.single.name;
    });
  }
}


  // --- Summarize Function ---
  Future<void> summarizeEmails() async {
    if (_controller.text.trim().isEmpty) {
      setState(() {
        _errorMessage = '⚠️ Please paste or upload some text first.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'text': _controller.text}),
      );

      if (response.statusCode == 200) {
        final summaries = jsonDecode(response.body);
        if (mounted) {
          _controller.clear();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SummaryScreen(summaries: summaries),
            ),
          );
        }
      } else {
        final errorJson = jsonDecode(response.body);
        setState(() {
          _errorMessage =
              'API Error: ${response.statusCode}. ${errorJson['error'] ?? 'Unknown issue.'}';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = '🌐 Could not connect to backend. Is Flask running?';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // --- UI ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- App Name ---
              const Text(
                "Email Summarizer",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF204ECF),
                ),
              ),

              const SizedBox(height: 40),

              // --- Stylish Square Box ---
              Expanded(
                child: Center(
                  child: Container(
                    width: 320,
                    height: 320,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF204ECF).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFF204ECF),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.summarize,
                            color: const Color(0xFF204ECF), size: 48),
                        const SizedBox(height: 12),
                        const Text(
                          "Summarize Emails by Gemini",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF204ECF),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Text Input
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            maxLines: null,
                            expands: true,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                color: Colors.black87, fontSize: 15),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText:
                                  "✍️ Paste here or upload a file below...",
                              hintStyle: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),

                        // File Upload Button
                        OutlinedButton.icon(
                          onPressed: _pickFile,
                          icon: const Icon(Icons.upload_file,
                              color: Color(0xFF204ECF)),
                          label: Text(
                            _fileName ?? "Upload File",
                            style: const TextStyle(color: Color(0xFF204ECF)),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF204ECF)),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // --- Error Message ---
              if (_errorMessage.isNotEmpty)
                Center(
                  child: Text(
                    _errorMessage,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

              const SizedBox(height: 12),

              // --- Summarize Button with Animation ---
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF204ECF),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 3,
                  ),
                  onPressed: _isLoading ? null : summarizeEmails,
                  child: _isLoading
                      ? RotationTransition(
                          turns: _animationController,
                          child: const Icon(
                            Icons.sync,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          "Summarize",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
