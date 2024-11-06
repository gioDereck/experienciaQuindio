import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:translator/translator.dart';
import '../services/app_service.dart';
import '../utils/next_screen.dart';
import 'image_view.dart';
import 'package:travel_hour/controllers/font_size_controller.dart';
import 'package:get/get.dart';

// final String demoText =
//     "<p>Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s</p>" +
//         '''<iframe width="560" height="315" src="https://www.youtube.com/embed/-WRzl9L4z3g" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>''' +
// //'''<video controls src="https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4"></video>''' +
// //'''<iframe src="https://player.vimeo.com/video/226053498?h=a1599a8ee9" width="640" height="360" frameborder="0" allow="autoplay; fullscreen; picture-in-picture" allowfullscreen></iframe>''' +
//         "<p>Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s</p>";

class HtmlBodyWidget extends StatefulWidget {
  final String? content;
  final bool isVideoEnabled;
  final bool isimageEnabled;
  final bool isIframeVideoEnabled;
  final double? fontSize;

  const HtmlBodyWidget({
    Key? key,
    required this.content,
    required this.isVideoEnabled,
    required this.isimageEnabled,
    required this.isIframeVideoEnabled,
    this.fontSize,
    String? translatedContent,
  }) : super(key: key);

  @override
  _HtmlBodyWidgetState createState() => _HtmlBodyWidgetState();
}

class _HtmlBodyWidgetState extends State<HtmlBodyWidget> {
  bool isExpanded = false;
  String translatedWords = '';
  bool isLoading = true;
  double currentWidth = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _translateContent();
  }

  void _translateContent() async {
    final translator = GoogleTranslator();
    String currentLanguageCode = context.locale.languageCode;
    String content = widget.content ?? '';

    try {
      RegExp exp = RegExp(
        r'>(.[^<>]*)<|>([^<>]*?)$|^([^<>]*?)<',
        multiLine: true,
      );

      List<Future<Translation>> translationFutures = [];
      Map<int, String> originalTexts = {};
      Iterable<RegExpMatch> matches = exp.allMatches(content);

      for (var match in matches) {
        String? textToTranslate =
            (match.group(1) ?? match.group(2) ?? match.group(3))?.trim();

        if (textToTranslate != null && textToTranslate.isNotEmpty) {
          originalTexts[match.start] = textToTranslate;
          translationFutures.add(translator.translate(
            textToTranslate,
            to: currentLanguageCode,
          ));
        }
      }

      List<Translation> translations = await Future.wait(translationFutures);
      String translatedContent = content;

      originalTexts.entries.toList()
        ..sort((a, b) => b.key.compareTo(a.key))
        ..asMap().forEach((index, entry) {
          int position = entry.key;
          String originalText = entry.value;
          String translatedText =
              translations[translations.length - 1 - index].text;

          // Encuentra la posición exacta donde hacer el reemplazo
          int startPos = translatedContent.indexOf(originalText, position);
          if (startPos != -1) {
            translatedContent = translatedContent.replaceRange(
              startPos,
              startPos + originalText.length,
              translatedText,
            );
          }
        });

      setState(() {
        translatedWords = translatedContent;
        isLoading = false;
      });
    } catch (error) {
      print("Error en la traducción: $error");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    FontSizeController fontSizeController = Get.find<FontSizeController>();
    TextStyle _textStyleMedium = Theme.of(context).textTheme.bodyMedium!;

    if (isLoading) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 90.0, bottom: 90.0),
          child: SizedBox(
            width: 30,
            height: 30,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: Theme.of(context).primaryColor.withOpacity(0.6),
            ),
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (currentWidth != constraints.maxWidth) {
          // El ancho ha cambiado, actualiza el estado
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() {
              currentWidth = constraints.maxWidth;
            });
          });
        }

        double fontSize = widget.fontSize ?? 17;
        String displayContent = isExpanded
            ? translatedWords
            : _truncateHtml(translatedWords, constraints.maxWidth, fontSize);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Html(
              data: displayContent.isNotEmpty ? displayContent : widget.content,
              // Muestra el contenido original si no hay traducción
              onLinkTap: (url, _, __) {
                AppService().openLinkWithCustomTab(context, url!);
              },
              style: {
                "body": Style(
                    margin: Margins.zero,
                    padding: HtmlPaddings.zero,
                    // fontSize: FontSize(17),
                    lineHeight: LineHeight(1.5),
                    fontFamily: 'Open Sans',
                    // fontWeight: FontWeight.w400,
                    color: Colors.blueGrey[600],
                    fontWeight: fontSizeController
                        .obtainContrastFromBase(FontWeight.w500)),
                "figure":
                    Style(margin: Margins.zero, padding: HtmlPaddings.zero),
                "p,h1,h2,h3,h4,h5,h6": Style(margin: Margins.all(20)),
              },
              extensions: [
                /*
                TagExtension(
                  tagsToExtend: {"iframe"},
                  builder: (ExtensionContext eContext) {
                    final String videoSource = eContext.attributes['src'].toString();
                    if (!widget.isIframeVideoEnabled) return Container();
                    return Container();
                  },
                ),
                */
                /*
                TagExtension(
                  tagsToExtend: {"video"},
                  builder: (ExtensionContext eContext) {
                    final String videoSource = eContext.attributes['src'].toString();
                    if (!widget.isVideoEnabled) return Container();
                    return Container();
                  },
                ),
                */
                TagExtension(
                  tagsToExtend: {"img"},
                  builder: (ExtensionContext eContext) {
                    String imageUrl = eContext.attributes['src'].toString();
                    if (!widget.isimageEnabled) return Container();
                    return InkWell(
                      onTap: () => nextScreen(
                          context, FullScreenImage(imageUrl: imageUrl)),
                      child: CachedNetworkImage(
                        imageUrl: imageUrl,
                        placeholder: (context, url) =>
                            const CircularProgressIndicator(),
                      ),
                    );
                  },
                ),
              ],
            ),
            if (widget.content != null && widget.content!.length > 300)
              Align(
                alignment: Alignment.bottomRight,
                child: Column(
                  children: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          isExpanded = !isExpanded;
                        });
                      },
                      child: Text(
                        isExpanded ? 'see less' : 'see more',
                        style: _textStyleMedium.copyWith(
                          fontWeight: fontSizeController
                              .obtainContrastFromBase(FontWeight.w900),
                          wordSpacing: 1,
                          color: Colors.grey[800],
                        ),
                      ).tr(),
                    ),
                    Container(
                      margin: EdgeInsets.only(bottom: 4, right: 10),
                      height: 3,
                      width: 120,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(40),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }

  String _truncateHtml(String html, double width, double fontSize) {
    double charWidth = fontSize * 0.45;
    int charsPerLine = (width / charWidth).floor();
    RegExp tagExp = RegExp(r'<[^>]*>');

    List<String> paragraphs = html.split(RegExp(r'<\/?p[^>]*>'));

    String firstParagraph = paragraphs.isNotEmpty ? paragraphs[0] : '';
    String secondParagraph =
        paragraphs.isNotEmpty && paragraphs.length > 1 ? paragraphs[1] : '';
    String text = firstParagraph + secondParagraph;

    String plainText = text.replaceAll(tagExp, '');
    int maxChars = charsPerLine * 4;

    String truncatedText;
    if (plainText.length > maxChars) {
      truncatedText = plainText.substring(0, maxChars) + '...';
    } else {
      truncatedText = plainText;
    }

    StringBuffer truncatedHtml = StringBuffer();
    int textIndex = 0;
    int truncatedIndex = 0;

    while (textIndex < html.length) {
      if (textIndex < html.length && html[textIndex] == '<') {
        int tagEnd = html.indexOf('>', textIndex);
        if (tagEnd == -1) break;

        truncatedHtml.write(html.substring(textIndex, tagEnd + 1));
        textIndex = tagEnd + 1;
      } else {
        if (truncatedIndex < truncatedText.length) {
          truncatedHtml.write(truncatedText[truncatedIndex]);
          truncatedIndex++;
        }
        textIndex++;
      }

      if (truncatedIndex >= truncatedText.length) {
        break;
      }
    }

    return truncatedHtml.toString();
  }
}
