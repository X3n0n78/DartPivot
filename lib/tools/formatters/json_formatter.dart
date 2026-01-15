import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:code_text_field/code_text_field.dart';
import 'package:highlight/languages/json.dart';
import 'package:flutter_highlight/themes/atom-one-dark.dart';
import 'package:flutter_highlight/themes/github.dart';
import '../../core/models/tool_item.dart';
import '../../core/widgets/tool_scaffold.dart';

final jsonFormatterTool = ToolItemImpl(
  id: 'json-formatter',
  name: 'JSON Formatter',
  description: 'Format and prettify JSON data.',
  icon: Icons.format_align_left,
  category: ToolCategory.formatters,
  route: '/formatters/json',
  builder: (context) => const JsonFormatter(),
);

// Assuming ToolItemImpl is locally available or I need to import it if I moved it.
// I'll define it again to be safe/consistent with previous patterns unless I refactor.
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

class JsonFormatter extends StatefulWidget {
  const JsonFormatter({super.key});

  @override
  State<JsonFormatter> createState() => _JsonFormatterState();
}

class _JsonFormatterState extends State<JsonFormatter> {
  late CodeController _controller;
  int _indentSpaces = 2;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = CodeController(language: json);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _format() {
    setState(() => _error = null);
    try {
      if (_controller.text.trim().isEmpty) return;
      final dynamic decoded = jsonDecode(_controller.text);
      final indent = ' ' * _indentSpaces;
      final formatted = JsonEncoder.withIndent(indent).convert(decoded);
      _controller.text = formatted;
    } catch (e) {
      setState(() => _error = 'Invalid JSON: $e');
    }
  }

  void _minify() {
    setState(() => _error = null);
    try {
      if (_controller.text.trim().isEmpty) return;
      final dynamic decoded = jsonDecode(_controller.text);
      final formatted = jsonEncode(decoded);
      _controller.text = formatted;
    } catch (e) {
      setState(() => _error = 'Invalid JSON: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ToolScaffold(
      title: 'JSON Formatter',
      description: 'Format, prettify or minify JSON data.',
      actions: [
        PopupMenuButton<int>(
          icon: const Icon(Icons.space_bar),
          tooltip: 'Indentation',
          initialValue: _indentSpaces,
          onSelected: (val) {
            setState(() => _indentSpaces = val);
            _format(); // Auto-format on change
          },
          itemBuilder: (context) => [
            const PopupMenuItem(value: 2, child: Text('2 Spaces')),
            const PopupMenuItem(value: 4, child: Text('4 Spaces')),
          ],
        ),
      ],
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 8,
                    children: [
                      FilledButton.icon(
                        onPressed: _format,
                        icon: const Icon(Icons.format_align_left),
                        label: const Text('Format'),
                      ),
                      FilledButton.tonal(
                        onPressed: _minify,
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.compress),
                            SizedBox(width: 8),
                            Text('Minify'),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => _controller.clear(),
                        icon: const Icon(Icons.clear_all),
                        tooltip: 'Clear',
                      ),
                      IconButton(
                        onPressed: () async {
                          await Clipboard.setData(
                            ClipboardData(text: _controller.text),
                          );
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Copied to clipboard'),
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.copy),
                        tooltip: 'Copy',
                      ),
                      IconButton(
                        onPressed: () async {
                          final data = await Clipboard.getData(
                            Clipboard.kTextPlain,
                          );
                          if (data?.text != null) {
                            _controller.text = data!.text!;
                            _format();
                          }
                        },
                        icon: const Icon(Icons.paste),
                        tooltip: 'Paste',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_error != null)
            Container(
              color: Theme.of(context).colorScheme.errorContainer,
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              child: Text(
                _error!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
              ),
            ),
          Expanded(
            child: CodeTheme(
              data: CodeThemeData(
                styles: isDark ? atomOneDarkTheme : githubTheme,
              ),
              child: CodeField(
                controller: _controller,
                expands: true,
                wrap:
                    false, // JSON usually better without wrap, scroll horizontal
              ),
            ),
          ),
        ],
      ),
    );
  }
}
