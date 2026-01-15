import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import '../../core/models/tool_item.dart';
import '../../core/widgets/tool_scaffold.dart';

final base64ConverterTool = ToolItemImpl(
  id: 'base64',
  name: 'Base64 Text/Image',
  description: 'Encode and decode Base64 text and images.',
  icon: Icons.code,
  category: ToolCategory.converters,
  route: '/converters/base64',
  builder: (context) => const Base64Converter(),
);

// Helper for ToolItemImpl if not exported (which it isn't yet in my thought process, correcting duplication if needed)
// Assuming I'll eventually move it to a shared file, but for now:
class ToolItemImpl implements ToolItem {
  @override
  final String id;
  @override
  final String name;
  @override
  final String description;
  @override
  final IconData icon;
  @override
  final ToolCategory category;
  @override
  final String route;
  @override
  final WidgetBuilder builder;

  ToolItemImpl({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.category,
    required this.route,
    required this.builder,
  });
}

class Base64Converter extends StatefulWidget {
  const Base64Converter({super.key});

  @override
  State<Base64Converter> createState() => _Base64ConverterState();
}

class _Base64ConverterState extends State<Base64Converter>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ToolScaffold(
      title: 'Base64 Converter',
      description: 'Encode and decode Base64 text and images.',
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Text'),
              Tab(text: 'Image'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [Base64TextTab(), Base64ImageTab()],
            ),
          ),
        ],
      ),
    );
  }
}

class Base64TextTab extends StatefulWidget {
  const Base64TextTab({super.key});

  @override
  State<Base64TextTab> createState() => _Base64TextTabState();
}

class _Base64TextTabState extends State<Base64TextTab> {
  final _sourceController = TextEditingController();
  final _encodedController = TextEditingController();

  void _encode() {
    try {
      final text = _sourceController.text;
      final bytes = utf8.encode(text);
      final encoded = base64Encode(bytes);
      _encodedController.text = encoded;
    } catch (_) {}
  }

  void _decode() {
    try {
      final text = _encodedController.text;
      final bytes = base64Decode(text);
      final decoded = utf8.decode(bytes);
      _sourceController.text = decoded;
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Text('Source', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Expanded(
                  child: TextField(
                    controller: _sourceController,
                    maxLines: null,
                    expands: true,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (_) => _encode(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              children: [
                Text(
                  'Base64 Encoded',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: TextField(
                    controller: _encodedController,
                    maxLines: null,
                    expands: true,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (_) => _decode(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Base64ImageTab extends StatefulWidget {
  const Base64ImageTab({super.key});

  @override
  State<Base64ImageTab> createState() => _Base64ImageTabState();
}

class _Base64ImageTabState extends State<Base64ImageTab> {
  final _base64Controller = TextEditingController();
  Uint8List? _imageBytes;

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      final bytes = await file.readAsBytes();
      setState(() {
        _imageBytes = bytes;
        _base64Controller.text = base64Encode(bytes);
      });
    }
  }

  void _onBase64Changed(String text) {
    try {
      final bytes = base64Decode(text);
      setState(() {
        _imageBytes = bytes;
      });
    } catch (_) {
      // Invalid base64
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Text('Image', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: _imageBytes != null
                          ? Image.memory(_imageBytes!, fit: BoxFit.contain)
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.image,
                                  size: 64,
                                  color: Colors.grey,
                                ),
                                FilledButton(
                                  onPressed: _pickImage,
                                  child: const Text('Pick Image'),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              children: [
                Text(
                  'Base64 String',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: TextField(
                    controller: _base64Controller,
                    maxLines: null,
                    expands: true,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    onChanged: _onBase64Changed,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
