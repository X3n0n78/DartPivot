import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lorem_ipsum/lorem_ipsum.dart';
import '../../core/models/tool_item.dart';
import '../../core/widgets/tool_scaffold.dart';

final loremIpsumGeneratorTool = ToolItemImpl(
  id: 'lorem-ipsum-generator',
  name: 'Lorem Ipsum',
  description: 'Generate Lorem Ipsum placeholder text.',
  icon: Icons.text_snippet,
  category: ToolCategory.generators,
  route: '/generators/lorem-ipsum',
  builder: (context) => const LoremIpsumGenerator(),
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

class LoremIpsumGenerator extends StatefulWidget {
  const LoremIpsumGenerator({super.key});

  @override
  State<LoremIpsumGenerator> createState() => _LoremIpsumGeneratorState();
}

class _LoremIpsumGeneratorState extends State<LoremIpsumGenerator> {
  final _controller = TextEditingController();
  int _count = 3;
  String _type = 'paragraphs'; // paragraphs, sentences, words

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
    String text = '';
    if (_type == 'paragraphs') {
      text = loremIpsum(paragraphs: _count, words: 0);
    } else if (_type == 'sentences') {
      // Package doesn't expose sentences count directly easily with 'loremIpsum' function often
      // actually the package is simple. 'loremIpsum(paragraphs: x, words: y)'
      // If I want sentences I might need another logic or assume paragraphs=0 means default.
      // The package 'lorem_ipsum' 0.0.3 provides `loremIpsum({int paragraphs, int words})`.
      // It doesn't support 'sentences'.
      // I'll stick to paragraphs and words.
      if (_type == 'sentences') {
        // Hack: generate words and split? Or just rename options to Paragraphs / Words?
        // Let's stick to Paragraphs and Words for now as supported by package efficiently.
        _type = 'words';
        text = loremIpsum(words: _count);
      } else {
        text = loremIpsum(words: _count);
      }
    } else {
      text = loremIpsum(words: _count);
    }

    // The package might automatically start with Lorem ipsum.
    // And it doesn't seem to have a flag to "Start with Lorem Ipsum".
    // I'll leave the checkbox but might not be able to force it easily without checking result.
    // Actually the package usually starts with it.

    _controller.text = text;
  }

  @override
  Widget build(BuildContext context) {
    return ToolScaffold(
      title: 'Lorem Ipsum Generator',
      description: 'Generate Lorem Ipsum placeholder text.',
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
                      DropdownButton<String>(
                        value: _type,
                        items: const [
                          DropdownMenuItem(
                            value: 'paragraphs',
                            child: Text('Paragraphs'),
                          ),
                          DropdownMenuItem(
                            value: 'words',
                            child: Text('Words'),
                          ),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _type = val;
                              if (_type == 'words' && _count < 5) _count = 50;
                              if (_type == 'paragraphs' && _count > 50) {
                                _count = 3;
                              }
                            });
                            _generate();
                          }
                        },
                      ),
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
                                });
                              },
                              decoration: const InputDecoration(
                                isDense: true,
                                border: OutlineInputBorder(),
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
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.copy),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: _controller.text));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Copied text to clipboard'),
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
