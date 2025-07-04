import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../bloc/incidents_bloc.dart';

class ReportIncidentPage extends StatefulWidget {
  const ReportIncidentPage({Key? key}) : super(key: key);

  @override
  State<ReportIncidentPage> createState() => _ReportIncidentPageState();
}

class _ReportIncidentPageState extends State<ReportIncidentPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  IncidentPriority _selectedPriority = IncidentPriority.medium;
  final List<XFile> _attachments = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          _attachments.add(image);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _removeAttachment(int index) {
    setState(() {
      _attachments.removeAt(index);
    });
  }

  void _submitReport() {
    if (_formKey.currentState!.validate()) {
      context.read<IncidentsBloc>().add(
        IncidentReportRequested(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          location: _locationController.text.trim(),
          priority: _selectedPriority,
        ),
      );

      // Show success message and go back
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Incident reported successfully'),
          backgroundColor: Colors.green,
        ),
      );
      
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Incident'),
        actions: [
          TextButton(
            onPressed: _submitReport,
            child: const Text('Submit'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title Field
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Incident Title *',
                  hintText: 'Brief description of the incident',
                  border: OutlineInputBorder(),
                ),
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter an incident title';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Priority Selection
              Text(
                'Priority Level *',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: IncidentPriority.values.map((priority) {
                  final isSelected = _selectedPriority == priority;
                  return ChoiceChip(
                    label: Text(_getPriorityLabel(priority)),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedPriority = priority;
                        });
                      }
                    },
                    selectedColor: _getPriorityColor(priority).withOpacity(0.2),
                    labelStyle: TextStyle(
                      color: isSelected ? _getPriorityColor(priority) : null,
                      fontWeight: isSelected ? FontWeight.bold : null,
                    ),
                  );
                }).toList(),
              ),
              
              const SizedBox(height: 16),
              
              // Location Field
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Location *',
                  hintText: 'Where did this incident occur?',
                  prefixIcon: Icon(Icons.location_on),
                  border: OutlineInputBorder(),
                ),
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter the incident location';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Description Field
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description *',
                  hintText: 'Provide detailed information about the incident...',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 4,
                textInputAction: TextInputAction.newline,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a description';
                  }
                  if (value.trim().length < 10) {
                    return 'Description must be at least 10 characters';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 20),
              
              // Attachments Section
              Text(
                'Attachments',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              
              // Add Photo Button
              Card(
                child: InkWell(
                  onTap: _showImageSourceDialog,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(
                          Icons.add_a_photo,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Add Photo or Video',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Attachments List
              if (_attachments.isNotEmpty) ...[
                const SizedBox(height: 12),
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _attachments.length,
                    itemBuilder: (context, index) {
                      return Container(
                        width: 100,
                        margin: const EdgeInsets.only(right: 8),
                        child: Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Theme.of(context).colorScheme.surfaceVariant,
                              ),
                              child: const Center(
                                child: Icon(Icons.image),
                              ),
                            ),
                            Positioned(
                              top: 4,
                              right: 4,
                              child: InkWell(
                                onTap: () => _removeAttachment(index),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
              
              const SizedBox(height: 32),
              
              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _submitReport,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _getPriorityColor(_selectedPriority),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text(
                    'Submit Incident Report',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Help Text
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info,
                          color: Theme.of(context).colorScheme.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Reporting Guidelines',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• Be as specific as possible in your description\n'
                      '• Include time, location, and people involved\n'
                      '• Attach photos or videos if available\n'
                      '• Report critical incidents immediately by phone',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getPriorityLabel(IncidentPriority priority) {
    switch (priority) {
      case IncidentPriority.critical:
        return 'Critical';
      case IncidentPriority.high:
        return 'High';
      case IncidentPriority.medium:
        return 'Medium';
      case IncidentPriority.low:
        return 'Low';
    }
  }

  Color _getPriorityColor(IncidentPriority priority) {
    switch (priority) {
      case IncidentPriority.critical:
        return Colors.red;
      case IncidentPriority.high:
        return Colors.orange;
      case IncidentPriority.medium:
        return Colors.blue;
      case IncidentPriority.low:
        return Colors.green;
    }
  }
}
