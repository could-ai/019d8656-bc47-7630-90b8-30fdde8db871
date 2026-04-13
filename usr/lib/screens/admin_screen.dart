import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/news_provider.dart';
import '../models/news_article.dart';
import '../integrations/supabase.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _summary = '';
  String _category = 'Local';
  String _source = 'Admin';
  bool _isBreaking = false;

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      try {
        await SupabaseConfig.client.from('news_articles').insert({
          'title': _title,
          'summary': _summary,
          'category': _category,
          'source': _source,
          'is_breaking': _isBreaking,
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('News added successfully')),
          );
          context.read<NewsProvider>().fetchArticles(refresh: true);
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) => value!.isEmpty ? 'Required' : null,
                onSaved: (value) => _title = value!,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Summary'),
                validator: (value) => value!.isEmpty ? 'Required' : null,
                onSaved: (value) => _summary = value!,
                maxLines: 3,
              ),
              DropdownButtonFormField<String>(
                value: _category,
                decoration: const InputDecoration(labelText: 'Category'),
                items: ['Local', 'Rajasthan', 'India', 'Jobs', 'Sports', 'Entertainment']
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (value) => setState(() => _category = value!),
              ),
              SwitchListTile(
                title: const Text('Is Breaking News?'),
                value: _isBreaking,
                onChanged: (value) => setState(() => _isBreaking = value),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                child: const Text('Add News'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
