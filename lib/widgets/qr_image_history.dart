import 'dart:async';
import 'package:flutter/material.dart';

class QRImageWithRetry extends StatefulWidget {
  final String imageUrl;
  final double size;
  final int maxRetries;
  final Duration retryDelay;

  const QRImageWithRetry({
    Key? key,
    required this.imageUrl,
    required this.size,
    this.maxRetries = 3,
    this.retryDelay = const Duration(seconds: 2),
  }) : super(key: key);

  @override
  State<QRImageWithRetry> createState() => _QRImageWithRetryState();
}

class _QRImageWithRetryState extends State<QRImageWithRetry> {
  late ImageProvider _imageProvider;
  int _retryCount = 0;
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  void _loadImage() {
    _imageProvider = NetworkImage(widget.imageUrl);
    _imageProvider.resolve(ImageConfiguration()).addListener(
      ImageStreamListener(
        (info, synchronousCall) {
          if (mounted) {
            setState(() {
              _hasError = false;
              _errorMessage = null;
            });
          }
        },
        onError: (exception, stackTrace) {
          _handleError(exception);
        },
      ),
    );
  }

  void _handleError(dynamic exception) {
    if (!mounted) return;

    debugPrint('URL de la imagen: ${widget.imageUrl}');
    debugPrint('Tipo de error: ${exception.runtimeType}');

    setState(() {
      _hasError = true;
      _errorMessage = exception.toString();
    });

    if (_retryCount < widget.maxRetries) {
      _retryCount++;
      debugPrint('Reintento $_retryCount de ${widget.maxRetries} para cargar QR: ${widget.imageUrl}');
      debugPrint('Error: $_errorMessage');

      Future.delayed(widget.retryDelay, () {
        if (mounted) {
          _loadImage();
        }
      });
    } else {
      debugPrint('Error final al cargar QR después de ${widget.maxRetries} intentos: $_errorMessage');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.size,
      height: widget.size,
      padding: EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(3),
        child: _hasError
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.qr_code,
                    color: Colors.black87,
                    size: widget.size * 0.6,
                  ),
                  if (_retryCount < widget.maxRetries)
                    SizedBox(
                      width: widget.size * 0.4,
                      height: widget.size * 0.4,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    ),
                ],
              )
            : Image(
                image: _imageProvider,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.qr_code,
                    color: Colors.black87,
                    size: widget.size * 0.8,
                  );
                },
              ),
      ),
    );
  }
}