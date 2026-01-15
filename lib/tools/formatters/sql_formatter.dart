import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:code_text_field/code_text_field.dart';
import 'package:highlight/languages/sql.dart';
import 'package:flutter_highlight/themes/atom-one-dark.dart';
import 'package:flutter_highlight/themes/github.dart';
import '../../core/models/tool_item.dart';
import '../../core/widgets/tool_scaffold.dart';

final sqlFormatterTool = ToolItemImpl(
  id: 'sql-formatter',
  name: 'SQL Formatter',
  description: 'Format and prettify SQL queries.',
  icon: Icons.storage,
  category: ToolCategory.formatters,
  route: '/formatters/sql',
  builder: (context) => const SqlFormatter(),
);

// Helper for ToolItemImpl
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

class SqlFormatter extends StatefulWidget {
  const SqlFormatter({super.key});

  @override
  State<SqlFormatter> createState() => _SqlFormatterState();
}

class _SqlFormatterState extends State<SqlFormatter> {
  late CodeController _controller;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = CodeController(language: sql);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _format() {
    setState(() => _error = null);
    if (_controller.text.trim().isEmpty) return;

    // Simple custom SQL formatting logic
    try {
      final formatted = _basicSqlFormat(_controller.text);
      _controller.text = formatted;
    } catch (e) {
      setState(() => _error = 'Error formatting SQL: $e');
    }
  }

  String _basicSqlFormat(String sql) {
    // Very basic formatting strategy:
    // 1. Normalize whitespace.
    // 2. Insert newlines before major keywords.
    // 3. Uppercase keywords (optional, typically preferred).

    var text = sql.replaceAll(RegExp(r'\s+'), ' ').trim();

    final keywords = [
      'SELECT',
      'FROM',
      'WHERE',
      'AND',
      'OR',
      'GROUP BY',
      'ORDER BY',
      'HAVING',
      'LIMIT',
      'JOIN',
      'LEFT JOIN',
      'RIGHT JOIN',
      'INNER JOIN',
      'OUTER JOIN',
      'UNION',
      'INSERT INTO',
      'VALUES',
      'UPDATE',
      'SET',
      'DELETE FROM',
      'CREATE TABLE',
      'DROP TABLE',
      'ALTER TABLE',
    ];

    // Case insensitive replace to Uppercase keywords first?
    // This is risky if keywords are used as identifiers.
    // Ideally we assume valid SQL.

    // Simple strategy: Split by keywords and rejoin with newlines.
    // Better: Regex replace.

    for (var kw in keywords) {
      // Look for keyword surrounded by spaces or start/end
      final pattern = RegExp('(?<=\\s|^)$kw(?=\\s|\$)', caseSensitive: false);
      text = text.replaceAllMapped(
        pattern,
        (match) => '\n${match.group(0)!.toUpperCase()}',
      );
    }

    // Add newline after comma in select list or values?
    // text = text.replaceAll(',', ',\n  ');
    // This might break function arguments e.g. COUNT(a,b).
    // For MVP, simple keyword breaking is safer.

    return text.trim();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ToolScaffold(
      title: 'SQL Formatter',
      description: 'Format and prettify SQL queries (Basic Support).',
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                FilledButton.icon(
                  onPressed: _format,
                  icon: const Icon(Icons.format_align_left),
                  label: const Text('Format'),
                ),
                const SizedBox(width: 8),
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
                        const SnackBar(content: Text('Copied to clipboard')),
                      );
                    }
                  },
                  icon: const Icon(Icons.copy),
                  tooltip: 'Copy',
                ),
                IconButton(
                  onPressed: () async {
                    final data = await Clipboard.getData(Clipboard.kTextPlain);
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
                wrap: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
