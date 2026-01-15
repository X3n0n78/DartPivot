import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:code_text_field/code_text_field.dart';
import 'package:highlight/languages/xml.dart';
import 'package:flutter_highlight/themes/atom-one-dark.dart';
import 'package:flutter_highlight/themes/github.dart';
import 'package:xml/xml.dart';
import '../../core/models/tool_item.dart';
import '../../core/widgets/tool_scaffold.dart';

final xmlFormatterTool = ToolItemImpl(
  id: 'xml-formatter',
  name: 'XML Formatter',
  description: 'Format and prettify XML data.',
  icon: Icons.code,
  category: ToolCategory.formatters,
  route: '/formatters/xml',
  builder: (context) => const XmlFormatter(),
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

class XmlFormatter extends StatefulWidget {
  const XmlFormatter({super.key});

  @override
  State<XmlFormatter> createState() => _XmlFormatterState();
}

class _XmlFormatterState extends State<XmlFormatter> {
  late CodeController _controller;
  int _indentSpaces = 2;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = CodeController(language: xml);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _format() {
    setState(() => _error = null);
    if (_controller.text.trim().isEmpty) return;

    try {
      final document = XmlDocument.parse(_controller.text);
      final indent = ' ' * _indentSpaces;
      final formatted = document.toXmlString(pretty: true, indent: indent);
      _controller.text = formatted;
    } catch (e) {
      setState(() => _error = 'Error formatting XML: $e');
    }
  }

  void _minify() {
    setState(() => _error = null);
    if (_controller.text.trim().isEmpty) return;
    try {
      final document = XmlDocument.parse(_controller.text);
      final formatted = document.toXmlString(pretty: false);
      _controller.text = formatted;
    } catch (e) {
      setState(() => _error = 'Error formatting XML: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ToolScaffold(
      title: 'XML Formatter',
      description: 'Format, prettify or minify XML data.',
      actions: [
        PopupMenuButton<int>(
          icon: const Icon(Icons.space_bar),
          tooltip: 'Indentation',
          initialValue: _indentSpaces,
          onSelected: (val) {
            setState(() => _indentSpaces = val);
            _format();
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
                wrap: false,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
