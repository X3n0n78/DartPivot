import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image/image.dart' as img;
import '../../core/models/tool_item.dart';
import '../../core/widgets/tool_scaffold.dart';

final pngToJpgConverterTool = ToolItemImpl(
  id: 'png-to-jpg-converter',
  name: 'PNG to JPG Converter',
  description: 'Convert PNG images to JPG format.',
  icon: Icons.image,
  category: ToolCategory.graphics,
  route: '/graphics/data',
  builder: (context) => const PngToJpgConverter(),
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

class PngToJpgConverter extends StatefulWidget {
  const PngToJpgConverter({super.key});

  @override
  State<PngToJpgConverter> createState() => _PngToJpgConverterState();
}

class _PngToJpgConverterState extends State<PngToJpgConverter> {
  Uint8List? _originalBytes;
  Uint8List? _convertedBytes;
  img.Image? _decodedImage;

  bool _isProcessing = false;
  String? _error;
  int _quality = 90;

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      final bytes = await file.readAsBytes();

      setState(() => _isProcessing = true);
      try {
        final image = await compute(img.decodeImage, bytes);
        if (image != null) {
          setState(() {
            _originalBytes = bytes;
            _decodedImage = image;
            _convertedBytes = null;
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

  Future<void> _convert() async {
    if (_decodedImage == null) return;

    setState(() => _isProcessing = true);

    try {
      final convertedBytes = await compute(
        _convertIsolate,
        _ConvertRequest(_decodedImage!, _quality),
      );
      setState(() {
        _convertedBytes = convertedBytes;
        _error = null;
      });
    } catch (e) {
      setState(() => _error = 'Error converting: $e');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _save() async {
    if (_convertedBytes == null) return;
    final result = await FilePicker.platform.saveFile(
      dialogTitle: 'Save JPG Image',
      fileName: 'converted.jpg',
      type: FileType.image,
    );

    if (result != null) {
      final file = File(result);
      await file.writeAsBytes(_convertedBytes!);
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
      title: 'PNG to JPG Converter',
      description: 'Convert PNG to JPG with quality control.',
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
                      child: _convertedBytes != null
                          ? Image.memory(_convertedBytes!, fit: BoxFit.contain)
                          : const Center(
                              child: Text(
                                'Converted JPG preview',
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
                  label: const Text('Select PNG'),
                ),
                SizedBox(
                  width: 200,
                  child: Row(
                    children: [
                      const Text('Quality: '),
                      Expanded(
                        child: Slider(
                          value: _quality.toDouble(),
                          min: 10,
                          max: 100,
                          divisions: 90,
                          label: _quality.toString(),
                          onChanged: (val) {
                            setState(() => _quality = val.round());
                          },
                        ),
                      ),
                      Text('$_quality%'),
                    ],
                  ),
                ),
                FilledButton.icon(
                  onPressed: _isProcessing || _originalBytes == null
                      ? null
                      : _convert,
                  icon: const Icon(Icons.transform),
                  label: _isProcessing
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Convert to JPG'),
                ),
                if (_convertedBytes != null)
                  FilledButton.icon(
                    onPressed: _save,
                    icon: const Icon(Icons.save),
                    label: const Text('Save JPG'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ConvertRequest {
  final img.Image image;
  final int quality;
  _ConvertRequest(this.image, this.quality);
}

Uint8List _convertIsolate(_ConvertRequest req) {
  // Decode usually gives us generic image. JpegEncode supports it.
  // Note: if transparency exists, Background color should be handled, or standard black/white.
  // Jpeg doesn't support transparency.
  // For 'image' package, encoding to Jpeg handles this (usually usually black background).

  // Create a new image with white background if transparency matters?
  // Let's stick to default Jpeg encoding.

  final jpg = img.encodeJpg(req.image, quality: req.quality);
  return Uint8List.fromList(jpg);
}
