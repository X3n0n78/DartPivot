import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/tool_item.dart';
import '../../core/widgets/tool_scaffold.dart';

final numberBaseConverterTool = ToolItemImpl(
  id: 'number-base',
  name: 'Number Base',
  description:
      'Convert numbers between Decimal, Hexadecimal, Binary, and Octal.',
  icon: Icons.numbers,
  category: ToolCategory.converters,
  route: '/converters/number-base',
  builder: (context) => const NumberBaseConverter(),
);

// We can reuse ToolItemImpl if we export it or put it in a shared file,
// for now re-defining or assuming it is accessible.
// Ideally moving ToolItemImpl to tool_item.dart would be better.
// I will duplicate implementation here for speed/isolation as I didn't verify export.

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

class NumberBaseConverter extends ConsumerStatefulWidget {
  const NumberBaseConverter({super.key});

  @override
  ConsumerState<NumberBaseConverter> createState() =>
      _NumberBaseConverterState();
}

class _NumberBaseConverterState extends ConsumerState<NumberBaseConverter> {
  final _decController = TextEditingController();
  final _hexController = TextEditingController();
  final _binController = TextEditingController();
  final _octController = TextEditingController();

  @override
  void dispose() {
    _decController.dispose();
    _hexController.dispose();
    _binController.dispose();
    _octController.dispose();
    super.dispose();
  }

  void _updateValues(BigInt? value, {required TextEditingController source}) {
    if (value == null) {
      if (source != _decController) _decController.clear();
      if (source != _hexController) _hexController.clear();
      if (source != _binController) _binController.clear();
      if (source != _octController) _octController.clear();
      return;
    }

    if (source != _decController) _decController.text = value.toString();
    if (source != _decController) _decController.text = value.toString();
    if (source != _hexController) {
      _hexController.text = value.toRadixString(16).toUpperCase();
    }
    if (source != _binController) {
      _binController.text = value.toRadixString(2);
    }
    if (source != _octController) {
      _octController.text = value.toRadixString(8);
    }
  }

  void _onDecChanged(String text) {
    if (text.isEmpty) {
      _updateValues(null, source: _decController);
      return;
    }
    // Handle negative signs etc if needed, BigInt.tryParse handles simple ints
    try {
      final val = BigInt.parse(text);
      _updateValues(val, source: _decController);
    } catch (_) {
      // Allow user to type partial invalid numbers? No, strict validation preferred or just ignore
    }
  }

  void _onHexChanged(String text) {
    if (text.isEmpty) {
      _updateValues(null, source: _hexController);
      return;
    }
    try {
      // Remove 0x prefix if user types it
      final clean = text.replaceAll('0x', '').replaceAll(' ', '');
      final val = BigInt.parse(clean, radix: 16);
      _updateValues(val, source: _hexController);
    } catch (_) {}
  }

  void _onBinChanged(String text) {
    if (text.isEmpty) {
      _updateValues(null, source: _binController);
      return;
    }
    try {
      final clean = text.replaceAll(' ', '');
      final val = BigInt.parse(clean, radix: 2);
      _updateValues(val, source: _binController);
    } catch (_) {}
  }

  void _onOctChanged(String text) {
    if (text.isEmpty) {
      _updateValues(null, source: _octController);
      return;
    }
    try {
      final clean = text.replaceAll(' ', '');
      final val = BigInt.parse(clean, radix: 8);
      _updateValues(val, source: _octController);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return ToolScaffold(
      title: 'Number Base Converter',
      description:
          'Convert numbers between Decimal, Hexadecimal, Binary, and Octal.',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            _buildField(
              controller: _decController,
              label: 'Decimal',
              onChanged: _onDecChanged,
              allowNumbers: true,
              formatter: FilteringTextInputFormatter.allow(RegExp(r'[0-9-]')),
            ),
            const SizedBox(height: 16),
            _buildField(
              controller: _hexController,
              label: 'Hexadecimal',
              onChanged: _onHexChanged,
              formatter: FilteringTextInputFormatter.allow(
                RegExp(r'[0-9a-fA-F]'),
              ),
            ),
            const SizedBox(height: 16),
            _buildField(
              controller: _binController,
              label: 'Binary',
              onChanged: _onBinChanged,
              formatter: FilteringTextInputFormatter.allow(RegExp(r'[0-1]')),
            ),
            const SizedBox(height: 16),
            _buildField(
              controller: _octController,
              label: 'Octal',
              onChanged: _onOctChanged,
              formatter: FilteringTextInputFormatter.allow(RegExp(r'[0-7]')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required ValueChanged<String> onChanged,
    TextInputFormatter? formatter,
    bool allowNumbers = false,
  }) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      // Avoid monospace for decimal for readability? No, monospace is good for numbers
      style: const TextStyle(fontFamily: 'monospace'),
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        suffixIcon: IconButton(
          icon: const Icon(Icons.copy),
          onPressed: () {
            Clipboard.setData(ClipboardData(text: controller.text));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('$label copied to clipboard')),
            );
          },
        ),
      ),
      inputFormatters: formatter != null ? [formatter] : [],
      keyboardType: allowNumbers
          ? const TextInputType.numberWithOptions(signed: true)
          : TextInputType.text,
    );
  }
}
