import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lokai/models/ai_model.dart';
import 'package:lokai/providers/model_manager_provider.dart';
import 'package:lokai/services/model_manager.dart';

/// A card widget that allows downloading and managing an AI model
class ModelDownloadCard extends ConsumerStatefulWidget {
  final String url;
  final String name;
  final String description;
  final String version;
  final String checksum;
  
  const ModelDownloadCard({
    super.key,
    required this.url,
    required this.name,
    required this.description,
    required this.version,
    required this.checksum,
  });

  @override
  ConsumerState<ModelDownloadCard> createState() => _ModelDownloadCardState();
}

class _ModelDownloadCardState extends ConsumerState<ModelDownloadCard> {
  bool _isDownloading = false;
  double _progress = 0;
  String _downloadedSize = '0 KB';
  String _totalSize = '0 KB';
  String? _errorMessage;
  
  Future<void> _downloadModel() async {
    final modelManager = ref.read(modelManagerProvider);
    
    setState(() {
      _isDownloading = true;
      _progress = 0;
      _errorMessage = null;
    });
    
    try {
      await modelManager.installModel(
        url: widget.url,
        name: widget.name,
        description: widget.description,
        version: widget.version,
        expectedChecksum: widget.checksum,
        onProgress: (progress) {
          setState(() {
            _progress = progress.progress;
            _downloadedSize = progress.formattedDownloaded;
            _totalSize = progress.formattedTotal;
          });
        },
      );
      
      // Refresh providers
      ref.refresh(diskSpaceProvider);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Model ${widget.name} downloaded successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to download model: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDownloading = false;
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Card(
      margin: const EdgeInsets.all(8),
      elevation: 2,
      color: isDarkMode ? const Color(0xFF3E3F4B) : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.name,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.description,
              style: TextStyle(
                color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Version: ${widget.version}',
              style: TextStyle(
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            if (_isDownloading) ...[
              LinearProgressIndicator(value: _progress),
              const SizedBox(height: 8),
              Text(
                'Downloading: $_downloadedSize / $_totalSize (${(_progress * 100).toStringAsFixed(1)}%)',
                style: TextStyle(
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ] else if (_errorMessage != null) ...[
              Text(
                'Error: $_errorMessage',
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _downloadModel,
                child: const Text('Retry Download'),
              ),
            ] else ...[
              ElevatedButton(
                onPressed: _downloadModel,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Download Model'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
