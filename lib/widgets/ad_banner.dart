import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../services/firestore_service.dart';
import '../models/models.dart';

class AdBanner extends StatefulWidget {
  final String slotName;
  final double height;
  
  const AdBanner({
    Key? key,
    required this.slotName,
    this.height = 120,
  }) : super(key: key);
  
  @override
  State<AdBanner> createState() => _AdBannerState();
}

class _AdBannerState extends State<AdBanner> {
  final FirestoreService _firestoreService = FirestoreService();
  List<AdSlot> _ads = [];
  int _currentAdIndex = 0;
  
  @override
  void initState() {
    super.initState();
    _loadAds();
  }
  
  Future<void> _loadAds() async {
    final ads = await _firestoreService.getAdSlots(widget.slotName);
    if (mounted) {
      setState(() {
        _ads = ads;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (_ads.isEmpty) {
      // Reserve space but don't show anything
      return SizedBox(height: widget.height);
    }
    
    final ad = _ads[_currentAdIndex % _ads.length];
    
    return Container(
      height: widget.height,
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: () {
          _openAdUrl(context, ad.targetUrl);
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: CachedNetworkImage(
            imageUrl: ad.imageUrl,
            fit: BoxFit.cover,
            placeholder: (context, url) => const Center(
              child: CircularProgressIndicator(),
            ),
            errorWidget: (context, url, error) => const Center(
              child: Icon(Icons.error),
            ),
          ),
        ),
      ),
    );
  }
  
  void _openAdUrl(BuildContext context, String url) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AdWebViewScreen(url: url),
      ),
    );
  }
}

class AdWebViewScreen extends StatefulWidget {
  final String url;
  
  const AdWebViewScreen({Key? key, required this.url}) : super(key: key);
  
  @override
  State<AdWebViewScreen> createState() => _AdWebViewScreenState();
}

class _AdWebViewScreenState extends State<AdWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            setState(() => _isLoading = true);
          },
          onPageFinished: (url) {
            setState(() => _isLoading = false);
          },
          onWebResourceError: (error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${error.description}')),
            );
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Advertisement'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _controller.reload(),
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
