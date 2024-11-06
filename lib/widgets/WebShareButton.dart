import 'package:flutter/material.dart';
import 'package:travel_hour/config/config.dart';
import 'package:travel_hour/models/blog.dart';
import 'package:travel_hour/widgets/social_share_widget.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:easy_localization/easy_localization.dart' as easy;

class WebShareButton extends StatelessWidget {
  final Blog blogData;

  const WebShareButton({Key? key, required this.blogData}) : super(key: key);

  Future<void> handleWebShare(BuildContext context) async {
    final String shareText = easy.tr('check out this app');
    /*
    if (await _canUseWebShare()) {
      try {
        await _webShare(shareText, blogData.title ?? "Blog", 'https://play.google.com/store/apps/details?id=${sb.packageName}');
        return;
      } catch (e) {
        print('Error sharing: $e');
      }
    }
    */
    _fallbackShare(context, shareText);
  }

  Future<bool> _canUseWebShare() async {
    // Verificar si la API navigator.share() está disponible
    return await canLaunch('web+share:');
  }

  Future<void> _webShare(String text, String title, String url) async {
    final Uri shareUri = Uri.parse(
        'web+share:?text=${Uri.encodeComponent(text)}&title=${Uri.encodeComponent(title)}&url=${Uri.encodeComponent(url)}');
    //print(shareUri);
    if (await canLaunch(shareUri.toString())) {
      await launch(shareUri.toString());
    } else {
      throw 'Could not launch $shareUri';
    }
  }

  void _fallbackShare(BuildContext context, String shareText) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
          content: SocialShareWidget(blogData: blogData, url: Config().url)),
    );
  }

  String encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.share),
      onPressed: () => handleWebShare(context),
    );
  }
}
