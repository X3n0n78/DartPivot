import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import '../../core/models/tool_item.dart';
import '../../core/widgets/tool_scaffold.dart';

final uuidGeneratorTool = ToolItemImpl(
  id: 'uuid-generator',
  name: 'UUID Generator',
  description: 'Generate unique identifiers (UUIDs).',
  icon: Icons.fingerprint,
  category: ToolCategory.generators,
  route: '/generators/uuid',
  builder: (context) => const UuidGenerator(),
);

// Assuming ToolItemImpl is available/duplicated for speed.
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

class UuidGenerator extends StatefulWidget {
  const UuidGenerator({super.key});

  @override
  State<UuidGenerator> createState() => _UuidGeneratorState();
}

class _UuidGeneratorState extends State<UuidGenerator> {
  final _uuid = const Uuid();
  final _controller = TextEditingController();
  int _count = 1;
  bool _hyphens = true;
  bool _uppercase = false;

  @override
  void initState() {
    super.initState();
    _generate();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _generate() {
    final buffer = StringBuffer();
    for (var i = 0; i < _count; i++) {
      var uuid = _uuid.v4();
      if (!_hyphens) {
        uuid = uuid.replaceAll('-', '');
      }
      if (_uppercase) {
        uuid = uuid.toUpperCase();
      }
      buffer.writeln(uuid);
    }
    _controller.text = buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    return ToolScaffold(
      title: 'UUID Generator',
      description: 'Generate UUID v4 identifiers.',
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Count: '),
                          SizedBox(
                            width: 80,
                            child: TextField(
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              onChanged: (val) {
                                setState(() {
                                  _count = int.tryParse(val) ?? 1;
                                  if (_count < 1) _count = 1;
                                  if (_count > 1000) _count = 1000; // Limit
                                });
                              },
                              decoration: const InputDecoration(
                                isDense: true,
                                border: OutlineInputBorder(),
                                hintText: '1',
                              ),
                              controller:
                                  TextEditingController(text: _count.toString())
                                    ..selection = TextSelection.collapsed(
                                      offset: _count.toString().length,
                                    ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Checkbox(
                            value: _hyphens,
                            onChanged: (v) =>
                                setState(() => _hyphens = v ?? true),
                          ),
                          const Text('Hyphens'),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Checkbox(
                            value: _uppercase,
                            onChanged: (v) =>
                                setState(() => _uppercase = v ?? false),
                          ),
                          const Text('Uppercase'),
                        ],
                      ),
                      FilledButton.icon(
                        onPressed: _generate,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Generate'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _controller,
                readOnly: true,
                maxLines: null,
                expands: true,
                style: const TextStyle(fontFamily: 'monospace'),
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.copy),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: _controller.text));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Copied UUIDs to clipboard'),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
