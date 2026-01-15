import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/models/tool_item.dart';
import '../../core/widgets/tool_scaffold.dart';

final colorTools = ToolItemImpl(
  id: 'color-tools',
  name: 'Color Tools',
  description: 'Color converter and contrast checker.',
  icon: Icons.palette,
  category: ToolCategory.graphics,
  route: '/graphics/color',
  builder: (context) => const ColorTools(),
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

class ColorTools extends StatelessWidget {
  const ColorTools({super.key});

  @override
  Widget build(BuildContext context) {
    return ToolScaffold(
      title: 'Color Tools',
      description: 'Color utilities.',
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            const TabBar(
              tabs: [
                Tab(text: 'Converter'),
                Tab(text: 'Contrast'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [const ColorConverter(), const ContrastChecker()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ColorConverter extends StatefulWidget {
  const ColorConverter({super.key});

  @override
  State<ColorConverter> createState() => _ColorConverterState();
}

class _ColorConverterState extends State<ColorConverter> {
  Color _color = Colors.blue;
  final _hexController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _updateHex();
  }

  void _updateHex() {
    _hexController.text =
        '#${_color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
  }

  void _onColorChanged(Color color) {
    setState(() {
      _color = color;
      _updateHex();
    });
  }

  void _onHexChanged(String val) {
    if (val.length == 7 && val.startsWith('#')) {
      try {
        final color = Color(
          int.parse(val.substring(1), radix: 16) + 0xFF000000,
        );
        setState(() => _color = color);
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    final hsl = HSLColor.fromColor(_color);
    final hsv = HSVColor.fromColor(_color);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(height: 100, width: double.infinity, color: _color),
          const SizedBox(height: 16),
          TextField(
            controller: _hexController,
            decoration: const InputDecoration(
              labelText: 'Hex',
              border: OutlineInputBorder(),
            ),
            onChanged: _onHexChanged,
          ),
          const SizedBox(height: 16),
          _buildSlider(
            'Red',
            (_color.r * 255.0),
            255,
            (v) => _onColorChanged(_color.withRed(v.toInt())),
          ),
          _buildSlider(
            'Green',
            (_color.g * 255.0),
            255,
            (v) => _onColorChanged(_color.withGreen(v.toInt())),
          ),
          _buildSlider(
            'Blue',
            (_color.b * 255.0),
            255,
            (v) => _onColorChanged(_color.withBlue(v.toInt())),
          ),
          const Divider(),
          _buildReadOnlyRow(
            'RGB',
            '${(_color.r * 255).round()}, ${(_color.g * 255).round()}, ${(_color.b * 255).round()}',
          ),
          _buildReadOnlyRow(
            'HSL',
            '${hsl.hue.toStringAsFixed(1)}, ${(hsl.saturation * 100).toStringAsFixed(1)}%, ${(hsl.lightness * 100).toStringAsFixed(1)}%',
          ),
          _buildReadOnlyRow(
            'HSV',
            '${hsv.hue.toStringAsFixed(1)}, ${(hsv.saturation * 100).toStringAsFixed(1)}%, ${(hsv.value * 100).toStringAsFixed(1)}%',
          ),
        ],
      ),
    );
  }

  Widget _buildSlider(
    String label,
    double value,
    double max,
    ValueChanged<double> onChanged,
  ) {
    return Row(
      children: [
        SizedBox(width: 50, child: Text(label)),
        Expanded(
          child: Slider(value: value, max: max, onChanged: onChanged),
        ),
        SizedBox(width: 40, child: Text(value.toInt().toString())),
      ],
    );
  }

  Widget _buildReadOnlyRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 50,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: SelectableText(value)),
          IconButton(
            icon: const Icon(Icons.copy, size: 16),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: value));
            },
          ),
        ],
      ),
    );
  }
}

class ContrastChecker extends StatefulWidget {
  const ContrastChecker({super.key});

  @override
  State<ContrastChecker> createState() => _ContrastCheckerState();
}

class _ContrastCheckerState extends State<ContrastChecker> {
  Color _bg = Colors.white;
  Color _fg = Colors.black;

  double _getLuminance(Color color) {
    // Relative luminance
    return color.computeLuminance();
  }

  double _getContrastRatio() {
    final l1 = _getLuminance(_fg) + 0.05;
    final l2 = _getLuminance(_bg) + 0.05;
    return l1 > l2 ? l1 / l2 : l2 / l1;
  }

  String _getRating(double ratio) {
    if (ratio >= 7) return 'AAA';
    if (ratio >= 4.5) return 'AA';
    if (ratio >= 3) return 'AA Large';
    return 'Fail';
  }

  @override
  Widget build(BuildContext context) {
    final ratio = _getContrastRatio();
    final rating = _getRating(ratio);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            color: _bg,
            child: Text(
              'The quick brown fox jumps over the lazy dog.',
              style: TextStyle(color: _fg, fontSize: 18),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Contrast Ratio: ${ratio.toStringAsFixed(2)} : 1',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          Text(
            'Rating: $rating',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: rating == 'Fail' ? Colors.red : Colors.green,
            ),
          ),
          const SizedBox(height: 16),
          _buildColorPicker('Text Color', _fg, (c) => setState(() => _fg = c)),
          const SizedBox(height: 16),
          _buildColorPicker(
            'Background Color',
            _bg,
            (c) => setState(() => _bg = c),
          ),
        ],
      ),
    );
  }

  Widget _buildColorPicker(
    String label,
    Color color,
    ValueChanged<Color> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(
          children: [
            Container(width: 40, height: 40, color: color),
            const SizedBox(width: 16),
            Expanded(
              child: Slider(
                value: (color.r * 255.0),
                min: 0,
                max: 255,
                label: 'R',
                activeColor: Colors.red,
                onChanged: (v) => onChanged(color.withRed(v.toInt())),
              ),
            ),
            Expanded(
              child: Slider(
                value: (color.g * 255.0),
                min: 0,
                max: 255,
                label: 'G',
                activeColor: Colors.green,
                onChanged: (v) => onChanged(color.withGreen(v.toInt())),
              ),
            ),
            Expanded(
              child: Slider(
                value: (color.b * 255.0),
                min: 0,
                max: 255,
                label: 'B',
                activeColor: Colors.blue,
                onChanged: (v) => onChanged(color.withBlue(v.toInt())),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
