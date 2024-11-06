import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:travel_hour/config/config.dart';
import 'package:travel_hour/models/blog.dart';
import 'package:travel_hour/utils/snacbar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:easy_localization/easy_localization.dart' as easy;
import 'package:flutter/services.dart';

class SocialShareWidget extends StatelessWidget {
  final Blog blogData;
  final String url;
  final String startAt;
  
  const SocialShareWidget({
    Key? key,
    required this.blogData,
    required this.url,
    this.startAt = '',
  }) : super(key: key);

  void _shareOnPlatform(String platform) async {
    String shareUrl = '';
    
    switch (platform) {
      case 'whatsapp':
        shareUrl = 'https://api.whatsapp.com/send?text=$url';
        break;
      case 'email':
        final subject = easy.tr("email_plataform_subject") + (blogData.title ?? "Blog");
        final body = easy.tr("email_platform_body") + Config().url;
        shareUrl = 'mailto:?subject=$subject&body=$body';
        break;
    }
    
    if (await canLaunch(shareUrl)) {
      await launch(shareUrl);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: const Text(
            'Compartir',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ).tr(),
        ),
        const SizedBox(height: 4),
        Container(
          margin: EdgeInsets.only(top: 8, bottom: 8),
          height: 3,
          width: 150,
          decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(40)),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Column(
              children: [
                _buildSocialButton(
                  'whatsapp',
                  const Color(0xFF25D366),
                  Ionicons.logo_whatsapp,
                ),
                const SizedBox(height: 4),
                const Text(
                  'WhatsApp',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Column(
              children: [
                _buildSocialButton(
                  'email',
                  Colors.red,
                  Icons.email,
                ),
                const SizedBox(height: 4),
                const Text(
                  'email',
                  style: TextStyle(fontSize: 12),
                ).tr(),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        url,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: url));
                        openSnacbar(context, easy.tr('URL copiada al portapapeles'));
                      },
                      child: const Text(
                        'copy',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ).tr(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        if (startAt.isNotEmpty) ...[
          const SizedBox(height: 16),
          Row(
            children: [
              const Text('Iniciar en'),
              const SizedBox(width: 8),
              Text(
                startAt,
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildSocialButton(String platform, Color color, IconData icon) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        onPressed: () => _shareOnPlatform(platform),
        tooltip: platform == 'whatsapp' ? 'Whatsapp' : 'Correo',
        iconSize: 28,
      ),
    );
  }
}