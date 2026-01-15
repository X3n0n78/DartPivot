import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image/image.dart' as img;
import '../../core/models/tool_item.dart';
import '../../core/widgets/tool_scaffold.dart';

final imageResizerTool = ToolItemImpl(
  id: 'image-resizer',
  name: 'Image Resizer',
  description: 'Resize images with customizeable width and height.',
  icon: Icons.photo_size_select_large,
  category: ToolCategory.graphics,
  route: '/graphics/resizer',
  builder: (context) => const ImageResizer(),
);

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

class ImageResizer extends StatefulWidget {
  const ImageResizer({super.key});

  @override
  State<ImageResizer> createState() => _ImageResizerState();
}

class _ImageResizerState extends State<ImageResizer> {
  Uint8List? _originalBytes;
  Uint8List? _resizedBytes;
  img.Image? _decodedImage;

  final _widthController = TextEditingController();
  final _heightController = TextEditingController();

  bool _maintainAspectRatio = true;
  bool _isProcessing = false;
  String? _error;

  @override
  void dispose() {
    _widthController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      final bytes = await file.readAsBytes();

      // Compute decode in isolate to avoid lag
      setState(() => _isProcessing = true);
      try {
        final image = await compute(img.decodeImage, bytes);
        if (image != null) {
          setState(() {
            _originalBytes = bytes;
            _decodedImage = image;
            _resizedBytes = null;
            _widthController.text = image.width.toString();
            _heightController.text = image.height.toString();
            _error = null;
          });
        }
      } catch (e) {
        setState(() => _error = 'Error decoding image: $e');
      } finally {
        setState(() => _isProcessing = false);
      }
    }
  }

  void _onWidthChanged(String val) {
    if (!_maintainAspectRatio || _decodedImage == null) return;
    final width = int.tryParse(val);
    if (width != null) {
      final ratio = _decodedImage!.height / _decodedImage!.width;
      final height = (width * ratio).round();
      _heightController.text = height.toString();
    }
  }

  void _onHeightChanged(String val) {
    if (!_maintainAspectRatio || _decodedImage == null) return;
    final height = int.tryParse(val);
    if (height != null) {
      final ratio = _decodedImage!.width / _decodedImage!.height;
      final width = (height * ratio).round();
      _widthController.text = width.toString();
    }
  }

  Future<void> _resize() async {
    if (_decodedImage == null) return;
    final width = int.tryParse(_widthController.text);
    final height = int.tryParse(_heightController.text);

    if (width == null || height == null) {
      setState(() => _error = 'Invalid width or height');
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final resizedBytes = await compute(
        _resizeIsolate,
        _ResizeRequest(_decodedImage!, width, height),
      );
      setState(() {
        _resizedBytes = resizedBytes;
        _error = null;
      });
    } catch (e) {
      setState(() => _error = 'Error resizing: $e');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _save() async {
    if (_resizedBytes == null) return;
    final result = await FilePicker.platform.saveFile(
      dialogTitle: 'Save Resized Image',
      fileName: 'resized.png',
      type: FileType.image,
    );

    if (result != null) {
      final file = File(result);
      await file.writeAsBytes(_resizedBytes!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image saved successfully')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ToolScaffold(
      title: 'Image Resizer',
      description: 'Resize images using standardized format.',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (_error != null)
              Container(
                padding: const EdgeInsets.all(8),
                color: Theme.of(context).colorScheme.errorContainer,
                child: Text(
                  _error!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
                ),
              ),

            Row(
              children: [
                Expanded(
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        color: Colors.grey.shade900,
                      ),
                      child: _originalBytes != null
                          ? Image.memory(_originalBytes!, fit: BoxFit.contain)
                          : const Center(
                              child: Text(
                                'No image selected',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        color: Colors.grey.shade900,
                      ),
                      child: _resizedBytes != null
                          ? Image.memory(_resizedBytes!, fit: BoxFit.contain)
                          : const Center(
                              child: Text(
                                'Resized image preview',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                FilledButton.icon(
                  onPressed: _isProcessing ? null : _pickImage,
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Select Image'),
                ),
                SizedBox(
                  width: 100,
                  child: TextField(
                    controller: _widthController,
                    decoration: const InputDecoration(
                      labelText: 'Width',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: _onWidthChanged,
                  ),
                ),
                SizedBox(
                  width: 100,
                  child: TextField(
                    controller: _heightController,
                    decoration: const InputDecoration(
                      labelText: 'Height',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: _onHeightChanged,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Checkbox(
                      value: _maintainAspectRatio,
                      onChanged: (v) =>
                          setState(() => _maintainAspectRatio = v ?? true),
                    ),
                    const Text('Keep Ratio'),
                  ],
                ),
                FilledButton.icon(
                  onPressed: _isProcessing || _originalBytes == null
                      ? null
                      : _resize,
                  icon: const Icon(Icons.transform),
                  label: _isProcessing
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Resize'),
                ),
                if (_resizedBytes != null)
                  FilledButton.icon(
                    onPressed: _save,
                    icon: const Icon(Icons.save),
                    label: const Text('Save'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Data class for Isolate
class _ResizeRequest {
  final img.Image image;
  final int width;
  final int height;
  _ResizeRequest(this.image, this.width, this.height);
}

// Function to run in Isolate
Uint8List _resizeIsolate(_ResizeRequest req) {
  final resized = img.copyResize(
    req.image,
    width: req.width,
    height: req.height,
  );
  return Uint8List.fromList(img.encodePng(resized));
}
