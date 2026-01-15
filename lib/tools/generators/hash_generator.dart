import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:crypto/crypto.dart';
import '../../core/models/tool_item.dart';
import '../../core/widgets/tool_scaffold.dart';

final hashGeneratorTool = ToolItemImpl(
  id: 'hash-generator',
  name: 'Hash Generator',
  description: 'Calculate MD5, SHA1, SHA256 and other hashes from text.',
  icon: Icons.tag,
  category: ToolCategory.generators,
  route: '/generators/hash',
  builder: (context) => const HashGenerator(),
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

class HashGenerator extends StatefulWidget {
  const HashGenerator({super.key});

  @override
  State<HashGenerator> createState() => _HashGeneratorState();
}

class _HashGeneratorState extends State<HashGenerator> {
  final _inputController = TextEditingController();
  bool _uppercase = false;
  String _input = '';

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  String _calculateHash(Hash algorithm, String text) {
    if (text.isEmpty) return '';
    final bytes = utf8.encode(text);
    final digest = algorithm.convert(bytes);
    final hex = digest.toString();
    return _uppercase ? hex.toUpperCase() : hex;
  }

  @override
  Widget build(BuildContext context) {
    return ToolScaffold(
      title: 'Hash Generator',
      description: 'Generate cryptographic hashes from text.',
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _inputController,
                        onChanged: (val) => setState(() => _input = val),
                        decoration: const InputDecoration(
                          labelText: 'Input Text',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      children: [
                        const Text('Uppercase'),
                        Switch(
                          value: _uppercase,
                          onChanged: (v) => setState(() => _uppercase = v),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildHashRow('MD5', md5),
                _buildHashRow('SHA-1', sha1),
                _buildHashRow('SHA-224', sha224),
                _buildHashRow('SHA-256', sha256),
                _buildHashRow('SHA-384', sha384),
                _buildHashRow('SHA-512', sha512),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHashRow(String label, Hash algorithm) {
    final hash = _calculateHash(algorithm, _input);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          TextFormField(
            initialValue: hash,
            readOnly: true,
            // Key is critical to update field when hash changes if we use initialValue
            key: ValueKey('${label}_${hash}_$_uppercase'),
            style: const TextStyle(fontFamily: 'monospace'),
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              isDense: true,
              suffixIcon: IconButton(
                icon: const Icon(Icons.copy),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: hash));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('$label copied to clipboard')),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
