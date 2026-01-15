import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/models/tool_item.dart';
import '../../core/widgets/tool_scaffold.dart';

final passwordGeneratorTool = ToolItemImpl(
  id: 'password-generator',
  name: 'Password Generator',
  description: 'Generate secure random passwords.',
  icon: Icons.password,
  category: ToolCategory.generators,
  route: '/generators/password',
  builder: (context) => const PasswordGenerator(),
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

class PasswordGenerator extends StatefulWidget {
  const PasswordGenerator({super.key});

  @override
  State<PasswordGenerator> createState() => _PasswordGeneratorState();
}

class _PasswordGeneratorState extends State<PasswordGenerator> {
  final _controller = TextEditingController();
  double _length = 16;
  bool _uppercase = true;
  bool _lowercase = true;
  bool _digits = true;
  bool _special = true;

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
    if (!_uppercase && !_lowercase && !_digits && !_special) {
      _controller.text = 'Select at least one character set';
      return;
    }

    const uppercaseChars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const lowercaseChars = 'abcdefghijklmnopqrstuvwxyz';
    const digitChars = '0123456789';
    const specialChars = '!@#\$%^&*()_+-=[]{}|;:,.<>?';

    String chars = '';
    if (_uppercase) chars += uppercaseChars;
    if (_lowercase) chars += lowercaseChars;
    if (_digits) chars += digitChars;
    if (_special) chars += specialChars;

    final rand = Random.secure();
    final length = _length.toInt();
    final buffer = StringBuffer();

    for (var i = 0; i < length; i++) {
      buffer.write(chars[rand.nextInt(chars.length)]);
    }

    _controller.text = buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    return ToolScaffold(
      title: 'Password Generator',
      description: 'Generate secure random passwords.',
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    const Text('Length: '),
                    Expanded(
                      child: Slider(
                        value: _length,
                        min: 4,
                        max: 128,
                        divisions: 124,
                        label: _length.toInt().toString(),
                        onChanged: (val) {
                          setState(() => _length = val);
                          _generate();
                        },
                      ),
                    ),
                    Text(_length.toInt().toString()),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 16,
                  children: [
                    _buildCheckbox('Uppercase', _uppercase, (v) {
                      setState(() => _uppercase = v ?? false);
                      _generate();
                    }),
                    _buildCheckbox('Lowercase', _lowercase, (v) {
                      setState(() => _lowercase = v ?? false);
                      _generate();
                    }),
                    _buildCheckbox('Digits', _digits, (v) {
                      setState(() => _digits = v ?? false);
                      _generate();
                    }),
                    _buildCheckbox('Special', _special, (v) {
                      setState(() => _special = v ?? false);
                      _generate();
                    }),
                  ],
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: _generate,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Generate'),
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
                style: const TextStyle(fontFamily: 'monospace', fontSize: 18),
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.copy),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: _controller.text));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Copied password to clipboard'),
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

  Widget _buildCheckbox(
    String label,
    bool value,
    ValueChanged<bool?> onChanged,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Checkbox(value: value, onChanged: onChanged),
        Text(label),
      ],
    );
  }
}
