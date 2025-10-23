import 'package:flutter/material.dart';
import 'package:flutter_unity_widget/flutter_unity_widget.dart';

class UnityARPage extends StatefulWidget {
  const UnityARPage({super.key});

  @override
  State<UnityARPage> createState() => _UnityARPageState();
}

class _UnityARPageState extends State<UnityARPage> {
  UnityWidgetController? _unityWidgetController;
  bool _isDisposing = false;

  void onUnityCreated(UnityWidgetController controller) {
    _unityWidgetController = controller;
  }

  Future<void> _disposeUnity() async {
    setState(() {
      _isDisposing = true;
    });

    if (_unityWidgetController != null) {
      try {
        await Future.delayed(const Duration(seconds: 1));
        await _unityWidgetController!.pause();
      } catch (e) {
        debugPrint('Error disposing Unity: $e');
      }
      _unityWidgetController = null;
    }

    if (mounted) {
      setState(() {
        _isDisposing = false;
      });
    }
  }

  @override
  void dispose() {
    _disposeUnity();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        await _disposeUnity();
        if (mounted) Navigator.pop(context);
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'BRAVO!',
            style: TextStyle(
              fontSize: 30.0,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.75,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              await _disposeUnity();
              if (mounted) Navigator.pop(context);
            },
          ),
        ),
        body: Stack(
          children: [
            UnityWidget(
              onUnityCreated: onUnityCreated,
              onUnityUnloaded: () {
                debugPrint('Unity scene unloaded');
              },
              onUnityMessage: (message) {
                debugPrint('Unity sent message: ${message.toJson()}');
              },
              onUnitySceneLoaded: (sceneInfo) {
                debugPrint('Unity scene loaded: ${sceneInfo?.name}');
              },
              fullscreen: true,
            ),
            if (_isDisposing)
              Container(
                color: Colors.white,
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
