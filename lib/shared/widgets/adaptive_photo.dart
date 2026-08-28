import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../app/theme.dart';

/// Photos from the wild arrive at wildly different aspect ratios. A fixed
/// band either crops the subject (cover) or strands it in grey margins
/// (contain) — neither is acceptable for a photo of one specific thing.
///
/// Instead the card takes the photo's own shape, clamped only at the extremes
/// so a panorama or a tower can't dominate the screen. Inside the clamp there
/// is no crop at all, which is where nearly every photo lands.
class AdaptivePhoto extends StatefulWidget {
  const AdaptivePhoto({super.key, required this.url});

  final String url;

  /// Tall-portrait and wide-landscape limits for the card.
  static const minRatio = 0.72;
  static const maxRatio = 1.9;
  static const fallbackRatio = 4 / 3;

  @override
  State<AdaptivePhoto> createState() => _AdaptivePhotoState();
}

class _AdaptivePhotoState extends State<AdaptivePhoto> {
  late CachedNetworkImageProvider _provider;
  ImageStreamListener? _listener;
  ImageStream? _stream;
  double? _ratio;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _provider = CachedNetworkImageProvider(widget.url);
    _resolve();
  }

  void _resolve() {
    final listener = ImageStreamListener(
      (info, _) {
        if (!mounted) return;
        setState(() => _ratio = info.image.width / info.image.height);
      },
      onError: (error, stack) {
        if (mounted) setState(() => _failed = true);
      },
    );
    _listener = listener;
    _stream = _provider.resolve(const ImageConfiguration())
      ..addListener(listener);
  }

  @override
  void dispose() {
    if (_listener != null) _stream?.removeListener(_listener!);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ratio = (_ratio ?? AdaptivePhoto.fallbackRatio).clamp(
      AdaptivePhoto.minRatio,
      AdaptivePhoto.maxRatio,
    );

    return AspectRatio(
      aspectRatio: ratio,
      child: Container(
        color: RitualColors.surfaceRaised,
        child: _failed
            ? const Center(
                child: Icon(
                  Icons.image_not_supported_outlined,
                  color: RitualColors.textTertiary,
                ),
              )
            : _ratio == null
            ? const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: RitualColors.textTertiary,
                  ),
                ),
              )
            : Image(
                image: _provider,
                fit: BoxFit.cover,
                width: double.infinity,
              ),
      ),
    );
  }
}
