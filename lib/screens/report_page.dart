import 'package:flutter/material.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as p;
import 'disclaimer_page.dart';

class ReportCasePage extends StatefulWidget {
  const ReportCasePage({super.key});

  @override
  State<ReportCasePage> createState() => _ReportCasePageState();
}

class _ReportCasePageState extends State<ReportCasePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _incidentController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  bool _isSubmitting = false;

  final List<File> _evidenceFiles = [];
  final ImagePicker _picker = ImagePicker();
  final _audioRecorder = AudioRecorder();
  bool _isRecording = false;

  @override
  void dispose() {
    _incidentController.dispose();
    _locationController.dispose();
    _audioRecorder.dispose();
    super.dispose();
  }

  Future<void> _submitReport() async {
    final bool? didAgree = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => const DisclaimerPage()),
    );

    if (didAgree != true) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("You must agree to the disclaimer to submit.")),
        );
      }
      return; 
    }

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      // Uploading files to Firebase Storage
      List<String> evidenceUrls = [];
      final storageRef = FirebaseStorage.instance.ref();

      for (File file in _evidenceFiles) {
        final fileName =
            'evidence/${DateTime.now().millisecondsSinceEpoch}_${p.basename(file.path)}';
        final fileRef = storageRef.child(fileName);

        final uploadTask = fileRef.putFile(file);
        final snapshot = await uploadTask;
        final downloadUrl = await snapshot.ref.getDownloadURL();
        evidenceUrls.add(downloadUrl);
      }

      await FirebaseFirestore.instance.collection('reports').add({
        'incident': _incidentController.text.trim(),
        'location': _locationController.text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
        'evidenceUrls': evidenceUrls,
      });

      setState(() {
        _isSubmitting = false;
        _incidentController.clear();
        _locationController.clear();
        _evidenceFiles.clear();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Report submitted successfully 💜"),
            backgroundColor: Colors.deepPurpleAccent,
          ),
        );
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error submitting report: $e")),
        );
      }
    }
  }

  // Helper function to show permissions dialog
  Future<bool> _requestPermission(Permission permission) async {
    if (await permission.isGranted) {
      return true;
    } else {
      final result = await permission.request();
      return result == PermissionStatus.granted;
    }
  }

  // Function to pick Photo or Video
  Future<void> _pickMedia() async {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Pick Photo from Gallery'),
                onTap: () async {
                  Navigator.pop(context);
                  if (await _requestPermission(Permission.photos)) {
                    final XFile? image =
                        await _picker.pickImage(source: ImageSource.gallery);
                    if (image != null) {
                      setState(() => _evidenceFiles.add(File(image.path)));
                    }
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Take Photo with Camera'),
                onTap: () async {
                  Navigator.pop(context);
                  if (await _requestPermission(Permission.camera)) {
                    final XFile? image =
                        await _picker.pickImage(source: ImageSource.camera);
                    if (image != null) {
                      setState(() => _evidenceFiles.add(File(image.path)));
                    }
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.video_library),
                title: const Text('Pick Video from Gallery'),
                onTap: () async {
                  Navigator.pop(context);
                  if (await _requestPermission(Permission.videos)) {
                    final XFile? video =
                        await _picker.pickVideo(source: ImageSource.gallery);
                    if (video != null) {
                      setState(() => _evidenceFiles.add(File(video.path)));
                    }
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.videocam),
                title: const Text('Record Video with Camera'),
                onTap: () async {
                  Navigator.pop(context);
                  if (await _requestPermission(Permission.camera)) {
                    final XFile? video =
                        await _picker.pickVideo(source: ImageSource.camera);
                    if (video != null) {
                      setState(() => _evidenceFiles.add(File(video.path)));
                    }
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Function to record audio
  Future<void> _toggleRecording() async {
    if (!await _requestPermission(Permission.microphone)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text("Microphone permission is required to record audio.")),
        );
      }
      return;
    }

    if (_isRecording) {
      final path = await _audioRecorder.stop();
      if (path != null) {
        setState(() {
          _isRecording = false;
          _evidenceFiles.add(File(path));
        });
      }
    } else {
      final Directory appDocumentsDir =
          await getApplicationDocumentsDirectory();
      final String filePath = p.join(appDocumentsDir.path,
          'recording_${DateTime.now().millisecondsSinceEpoch}.m4a');

      await _audioRecorder.start(
          const RecordConfig(encoder: AudioEncoder.aacLc),
          path: filePath);
      setState(() => _isRecording = true);
    }
  }

  // Function to pick any file
  Future<void> _pickFile() async {
    try {
      final FilePickerResult? result =
          await FilePicker.platform.pickFiles(allowMultiple: true);

      if (result != null) {
        setState(() {
          _evidenceFiles
              .addAll(result.paths.map((path) => File(path!)).toList());
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error picking file: $e")),
        );
      }
    }
  }

  // Function to remove a file
  void _removeFile(File file) {
    setState(() {
      _evidenceFiles.remove(file);
    });
  }

  // Helper widget to build the file list
  Widget _buildFileList() {
    if (_evidenceFiles.isEmpty) {
      return const SizedBox.shrink();
    }
    return Container(
      margin: const EdgeInsets.only(top: 15),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300)),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _evidenceFiles.length,
        itemBuilder: (context, index) {
          final file = _evidenceFiles[index];
          return ListTile(
            leading: Icon(_getIconForFile(file.path)),
            title: Text(
              p.basename(file.path),
              style: const TextStyle(fontSize: 14),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.close, color: Colors.red),
              onPressed: () => _removeFile(file),
            ),
          );
        },
      ),
    );
  }

  // Helper to get file icon
  IconData _getIconForFile(String path) {
    final extension = p.extension(path).toLowerCase();
    switch (extension) {
      case '.jpg':
      case '.jpeg':
      case '.png':
        return Icons.image;
      case '.mp4':
      case '.mov':
      case '.avi':
        return Icons.video_file;
      case '.mp3':
      case '.m4a':
      case '.wav':
      case '.aac':
        return Icons.audio_file;
      case '.pdf':
        return Icons.picture_as_pdf;
      case '.doc':
      case '.docx':
        return Icons.description;
      default:
        return Icons.attach_file;
    }
  }

  // Helper widget for evidence buttons
  Widget _buildEvidenceButton(
      {required IconData icon,
      required String label,
      required VoidCallback onPressed,
      Color? color}) {
    return OutlinedButton.icon(
      icon: Icon(icon, color: color ?? const Color(0xFF7A3E9D)),
      label:
          Text(label, style: TextStyle(color: color ?? const Color(0xFF7A3E9D))),
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: color ?? const Color(0xFF7A3E9D)),
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F2FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF7A3E9D),
        title: const Text("Report a Case"),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 10),
                const Text(
                  "You’re safe here. Share what happened — no personal info is required.",
                  style: TextStyle(
                    color: Color(0xFF5B2C6F),
                    fontSize: 16,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),

                // Incident description
                TextFormField(
                  controller: _incidentController,
                  maxLines: 6,
                  decoration: InputDecoration(
                    labelText: "Describe the incident",
                    labelStyle: const TextStyle(color: Color(0xFF7A3E9D)),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF7A3E9D)),
                    ),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'Please describe the incident' : null,
                ),
                const SizedBox(height: 20),

                // Location
                TextFormField(
                  controller: _locationController,
                  decoration: InputDecoration(
                    labelText: "Where did it happen?",
                    labelStyle: const TextStyle(color: Color(0xFF7A3E9D)),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter the location' : null,
                ),
                const SizedBox(height: 30),

                // Evidence Section
                const Text(
                  "Add Evidence (Optional)",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF5B2C6F),
                  ),
                ),
                const SizedBox(height: 15),
                _buildEvidenceButton(
                  icon: Icons.photo_camera_back,
                  label: "Add Photo or Video",
                  onPressed: _pickMedia,
                ),
                const SizedBox(height: 10),
                _buildEvidenceButton(
                  icon: _isRecording ? Icons.stop : Icons.mic,
                  label: _isRecording ? "Stop Recording" : "Record Audio",
                  onPressed: _toggleRecording,
                  color: _isRecording ? Colors.red : const Color(0xFF7A3E9D),
                ),
                const SizedBox(height: 10),
                _buildEvidenceButton(
                  icon: Icons.attach_file,
                  label: "Attach Document or File",
                  onPressed: _pickFile,
                ),

                // List of selected files
                _buildFileList(),

                const SizedBox(height: 40),

                // Submit button
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitReport,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8E44AD),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: _isSubmitting
                      ? const CircularProgressIndicator(color: Colors.black)
                      : const Text(
                          "Submit Report",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
                const SizedBox(height: 20),
                
                // "Back to Home" button is removed, as it's not needed
                // in a tabbed navigation.
              ],
            ),
          ),
        ),
      ),
    );
  }
}