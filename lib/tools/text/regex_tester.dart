import 'package:flutter/material.dart';
import '../../core/models/tool_item.dart';
import '../../core/widgets/tool_scaffold.dart';

final regexTesterTool = ToolItemImpl(
  id: 'regex-tester',
  name: 'RegEx Tester',
  description: 'Test regular expressions with Dart RegExp engine.',
  icon: Icons.search,
  category: ToolCategory.text,
  route: '/text/regex',
  builder: (context) => const RegexTester(),
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

class RegexTester extends StatefulWidget {
  const RegexTester({super.key});

  @override
  State<RegexTester> createState() => _RegexTesterState();
}

class _RegexTesterState extends State<RegexTester> {
  final _regexController = TextEditingController();
  final _textController = TextEditingController();
  List<RegExpMatch> _matches = [];
  String? _error;
  bool _caseSensitive = true;
  bool _multiLine = false;

  @override
  void dispose() {
    _regexController.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _test() {
    setState(() {
      _error = null;
      _matches = [];
    });

    if (_regexController.text.isEmpty) return;

    try {
      final regex = RegExp(
        _regexController.text,
        caseSensitive: _caseSensitive,
        multiLine: _multiLine,
      );
      final matches = regex.allMatches(_textController.text).toList();
      setState(() {
        _matches = matches;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ToolScaffold(
      title: 'RegEx Tester',
      description: 'Test regular expressions using Dart\'s RegExp engine.',
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _regexController,
                  decoration: InputDecoration(
                    labelText: 'Regular Expression',
                    border: const OutlineInputBorder(),
                    errorText: _error,
                    prefixText: '/',
                    suffixText: '/',
                  ),
                  onChanged: (_) => _test(),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Checkbox(
                          value: !_caseSensitive,
                          onChanged: (v) {
                            setState(() => _caseSensitive = !(v ?? false));
                            _test();
                          },
                        ),
                        const Text('Case Insensitive (i)'),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Checkbox(
                          value: _multiLine,
                          onChanged: (v) {
                            setState(() => _multiLine = v ?? false);
                            _test();
                          },
                        ),
                        const Text('Multiline (m)'),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Test Text',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                SizedBox(
                  height: 150,
                  child: TextField(
                    controller: _textController,
                    maxLines: null,
                    expands: true,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (_) => _test(),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Matches: ${_matches.length}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey.withValues(alpha: 0.5),
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: SingleChildScrollView(
                        child: _buildHighlightedText(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightedText() {
    if (_textController.text.isEmpty) return const SizedBox();
    if (_matches.isEmpty) return Text(_textController.text);

    final spans = <InlineSpan>[];
    int currentIndex = 0;
    final text = _textController.text;

    for (var match in _matches) {
      if (match.start > currentIndex) {
        spans.add(TextSpan(text: text.substring(currentIndex, match.start)));
      }

      spans.add(
        TextSpan(
          text: text.substring(match.start, match.end),
          style: TextStyle(
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
            fontWeight: FontWeight.bold,
          ),
        ),
      );

      currentIndex = match.end;
    }

    if (currentIndex < text.length) {
      spans.add(TextSpan(text: text.substring(currentIndex)));
    }

    return RichText(
      text: TextSpan(
        style: DefaultTextStyle.of(context).style,
        children: spans,
      ),
    );
  }
}
