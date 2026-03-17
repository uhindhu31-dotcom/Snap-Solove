import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'dart:io';

class ReportIssueScreen extends StatefulWidget {
  const ReportIssueScreen({super.key});

  @override
  State<ReportIssueScreen> createState() => _ReportIssueScreenState();
}

class _ReportIssueScreenState extends State<ReportIssueScreen> {
  final _formKey = GlobalKey<FormState>();

  // 🎤 Description Controller
  final TextEditingController descriptionController = TextEditingController();
  bool isListening = false;
  late SpeechToText speech;

  @override
  void initState() {
    super.initState();
    speech = SpeechToText();
  }

  void toggleRecording() async {
    if (!isListening) {
      bool available = await speech.initialize();

      if (available) {
        setState(() => isListening = true);

        speech.listen(
          onResult: (result) {
            setState(() {
              descriptionController.text = result.recognizedWords;
            });
          },
        );
      }
    } else {
      setState(() => isListening = false);
      speech.stop();
    }
  }

  // 📂 Category
  String selectedCategory = "Garbage";

  final List<String> categories = [
    "Garbage",
    "Road Damage",
    "Water Leakage",
    "Street Light",
  ];

  // 📷 Image + 📍 Location
  File? image;
  String locationText = "Location not captured";

  Future<void> captureImageAndLocation() async {
    final picker = ImagePicker();

    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile == null) return;

    LocationPermission permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      setState(() => locationText = "Location permission denied");
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      image = File(pickedFile.path);
      locationText = "Lat: ${position.latitude}, Lng: ${position.longitude}";
    });
  }

  @override
  void dispose() {
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Report Issue"),
        backgroundColor: const Color(0xFF1565C0),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(15),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 📷 Animated Camera UI
              AnimatedCaptureBox(image: image, onTap: captureImageAndLocation),

              const SizedBox(height: 10),

              // 📍 Location
              Text(locationText, style: const TextStyle(color: Colors.grey)),

              const SizedBox(height: 20),

              // 📂 Category
              const Text(
                "Category",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              DropdownButtonFormField<String>(
                initialValue: selectedCategory,
                items: categories
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCategory = value!;
                  });
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // 📝 Description + 🎤 Mic
              TextFormField(
                controller: descriptionController,
                maxLines: 4,
                maxLength: 200,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Enter description";
                  }
                  return null;
                },
                decoration: InputDecoration(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("Description"),
                      SizedBox(width: 5),
                      Icon(Icons.mic, size: 16, color: Colors.grey),
                    ],
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      isListening ? Icons.mic : Icons.mic_none,
                      color: isListening ? Colors.red : Colors.grey,
                    ),
                    onPressed: toggleRecording,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // 🚀 Submit
              AnimatedSubmitButton(
                onPressed: () {
                  if (_formKey.currentState!.validate() && image != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Issue Submitted")),
                    );
                  } else if (image == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Please capture an image")),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//
// 📷 Animated Capture Box
//
class AnimatedCaptureBox extends StatefulWidget {
  final File? image;
  final VoidCallback onTap;

  const AnimatedCaptureBox({
    super.key,
    required this.image,
    required this.onTap,
  });

  @override
  State<AnimatedCaptureBox> createState() => _AnimatedCaptureBoxState();
}

class _AnimatedCaptureBoxState extends State<AnimatedCaptureBox> {
  double scale = 1.0;

  void _onTapDown(_) => setState(() => scale = 0.96);
  void _onTapUp(_) => setState(() => scale = 1.0);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: () => setState(() => scale = 1.0),
      onTap: widget.onTap,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 150),
        scale: scale,
        child: Container(
          height: 220,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: widget.image == null
                ? const LinearGradient(
                    colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB)],
                  )
                : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: widget.image == null
              ? const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.camera_alt, size: 60, color: Colors.blue),
                    SizedBox(height: 10),
                    Text(
                      "Capture Issue Image",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      "Tap to open camera",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                )
              : Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.file(
                        widget.image!,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      bottom: 10,
                      right: 10,
                      child: IconButton(
                        icon: const Icon(Icons.camera_alt, color: Colors.white),
                        onPressed: widget.onTap,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

//
// 🔘 Animated Submit Button
//
class AnimatedSubmitButton extends StatefulWidget {
  final VoidCallback onPressed;

  const AnimatedSubmitButton({super.key, required this.onPressed});

  @override
  State<AnimatedSubmitButton> createState() => _AnimatedSubmitButtonState();
}

class _AnimatedSubmitButtonState extends State<AnimatedSubmitButton> {
  double scale = 1.0;

  void _onTapDown(_) => setState(() => scale = 0.95);
  void _onTapUp(_) => setState(() => scale = 1.0);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: () => setState(() => scale = 1.0),
      onTap: widget.onPressed,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 150),
        scale: scale,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.4),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: const Text(
            "Submit Issue",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
