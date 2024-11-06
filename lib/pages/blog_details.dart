import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:line_icons/line_icons.dart';
import 'package:share/share.dart';
import 'package:translator/translator.dart';
import 'package:travel_hour/blocs/bookmark_bloc.dart';
import 'package:travel_hour/blocs/sign_in_bloc.dart';
import 'package:travel_hour/models/blog.dart';
import 'package:travel_hour/pages/comments.dart';
import 'package:travel_hour/services/app_service.dart';
import 'package:travel_hour/utils/next_screen.dart';
import 'package:travel_hour/utils/sign_in_dialog.dart';
import 'package:travel_hour/widgets/WebShareButton.dart';
import 'package:travel_hour/widgets/bookmark_icon.dart';
import 'package:travel_hour/widgets/contact_buttons.dart';
import 'package:travel_hour/widgets/custom_cache_image.dart';
import 'package:travel_hour/widgets/love_count.dart';
import 'package:provider/provider.dart';
import 'package:travel_hour/widgets/love_icon.dart';
import 'package:travel_hour/widgets/speech_button.dart';
import '../widgets/html_body.dart';
import 'package:travel_hour/controllers/font_size_controller.dart';
import 'package:get/get.dart' as getx;
import 'package:easy_localization/easy_localization.dart' as easy;
//import '../utils/platfom_web_utils_loader.dart';

// **Importaciones Añadidas para TTS**
import 'package:flutter_tts/flutter_tts.dart';
import 'package:html/parser.dart' as html_parser;
// import 'dart:js' as js;

class BlogDetails extends StatefulWidget {
  final Blog? blogData;
  final String tag;

  BlogDetails({Key? key, required this.blogData, required this.tag})
      : super(key: key);

  @override
  _BlogDetailsState createState() => _BlogDetailsState();
}

class _BlogDetailsState extends State<BlogDetails> {
  final String collectionName = 'blogs';

  // Instancia de FlutterTts
  FlutterTts flutterTts = FlutterTts();

  // Variables para TTS
  bool isSpeaking = false;

  // Variables para la Traducción
  String? translatedDescription;
  bool isTranslationLoading = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 0)).then((value) async {
      // context.read<AdsBloc>().initiateAds();
    });
  }

  handleLoveClick() {
    bool _guestUser = context.read<SignInBloc>().guestUser;

    if (_guestUser == true) {
      openSignInDialog(context);
    } else {
      context
          .read<BookmarkBloc>()
          .onLoveIconClick(collectionName, widget.blogData!.timestamp);
    }
  }

  handleBookmarkClick() {
    bool _guestUser = context.read<SignInBloc>().guestUser;

    if (_guestUser == true) {
      openSignInDialog(context);
    } else {
      context
          .read<BookmarkBloc>()
          .onBookmarkIconClick(collectionName, widget.blogData!.timestamp);
    }
  }

  handleShare() {
    final String checkLabel = easy.tr('check out this app');

    final String _shareTextAndroid = '${widget.blogData!.title}, ' + checkLabel;
    final String _shareTextiOS = '${widget.blogData!.title}, ' + checkLabel;

    if (Platform.isAndroid) {
      Share.share(_shareTextAndroid);
    } else {
      Share.share(_shareTextiOS);
    }
  }

  // **Método para Extraer Texto Limpio de HTML**
  String _extractTextFromHtml(String htmlString) {
    final document = html_parser.parse(htmlString);
    return html_parser.parse(document.body?.text).documentElement?.text ?? '';
  }

  // **Método para Traducir la Descripción**
  Future<void> _translateDescription(String lang) async {
    final translator = GoogleTranslator();
    String content = widget.blogData?.description.toString() ?? '';

    try {
      String plainText = _extractTextFromHtml(content);
      Translation translation = await translator.translate(plainText, to: lang);
      setState(() {
        translatedDescription = translation.text;
        isTranslationLoading = false;
      });
      //print('Descripción traducida: $translatedDescription');
    } catch (e) {
      print('Error en la traducción: $e');
      setState(() {
        translatedDescription =
            _extractTextFromHtml(content); // Fallback al texto original
        isTranslationLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final SignInBloc sb = context.watch<SignInBloc>();
    final Blog d = widget.blogData!;

    FontSizeController fontSizeController = getx.Get.find<FontSizeController>();
    TextStyle _textStyleLarge = Theme.of(context).textTheme.bodyLarge!;
    TextStyle _textStyleMedium = Theme.of(context).textTheme.bodyMedium!;

    List<String> parts = d.date!.split(" ");
    parts[1] = easy.tr(parts[1]);
    String formattedDate = "${parts[0]} ${parts[1]} ${parts[2]}";

    final translator = GoogleTranslator();
    Future<String>? _translatedTitle;

    String title = d.title!;
    _translatedTitle = translator
        .translate(title, from: 'es', to: context.locale.languageCode)
        .then((result) => result.text)
        .catchError((error) {
      print('Translation error: $error');
      return title;
    });

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      floatingActionButton: ContactButtons(
        withoutAssistant: false,
        uniqueId: 'blogPage',
      ),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(top: 20, bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              Container(
                                  height: 35,
                                  width: 35,
                                  decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(5)),
                                  child: kIsWeb
                                      ? WebShareButton(
                                          blogData: widget.blogData!)
                                      : IconButton(
                                          padding: EdgeInsets.all(0),
                                          icon: Icon(
                                            Icons.share,
                                            size: 22,
                                          ),
                                          onPressed: () {
                                            handleShare();
                                          },
                                        )),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Icon(
                                    CupertinoIcons.time,
                                    size: 18,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(
                                    width: 3,
                                  ),
                                  Text(
                                    formattedDate,
                                    style: _textStyleMedium.copyWith(
                                        color: Colors.grey[700]),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              FutureBuilder<String>(
                                future: _translatedTitle,
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return Container(
                                      height: 40,
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  Colors.grey[400]!),
                                        ),
                                      ),
                                    );
                                  } else if (snapshot.hasError) {
                                    return Text(
                                      d.title!,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                      style: _textStyleLarge.copyWith(
                                          fontWeight: fontSizeController
                                              .obtainContrastFromBase(
                                                  FontWeight.w600),
                                          color: Colors.grey[800],
                                          letterSpacing: -0.7,
                                          wordSpacing: 1),
                                    );
                                  }
                                  return Text(
                                    snapshot.data ?? d.title!,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                    style: _textStyleLarge.copyWith(
                                        fontWeight: fontSizeController
                                            .obtainContrastFromBase(
                                                FontWeight.w600),
                                        color: Colors.grey[800],
                                        letterSpacing: -0.7,
                                        wordSpacing: 1),
                                  );
                                },
                              ),
                              Container(
                                margin: EdgeInsets.only(top: 8, bottom: 8),
                                height: 3,
                                width: 150,
                                decoration: BoxDecoration(
                                    color: Theme.of(context).primaryColor,
                                    borderRadius: BorderRadius.circular(40)),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  TextButton.icon(
                                    style: ButtonStyle(
                                      backgroundColor:
                                          WidgetStateProperty.resolveWith(
                                              (states) => Colors.grey[200]),
                                      padding: WidgetStateProperty.resolveWith(
                                          (states) => EdgeInsets.all(10)),
                                    ),
                                    onPressed: () => AppService()
                                        .openLinkWithCustomTab(
                                            context, d.sourceUrl!),
                                    icon: Icon(Feather.external_link,
                                        size: 20,
                                        color: Theme.of(context).primaryColor),
                                    label: _getSourceName(d),
                                  ),
                                  Spacer(),
                                  IconButton(
                                      icon: BuildLoveIcon(
                                          collectionName: collectionName,
                                          uid: sb.uid,
                                          timestamp: d.timestamp),
                                      onPressed: () {
                                        handleLoveClick();
                                      }),
                                  IconButton(
                                      icon: BuildBookmarkIcon(
                                          collectionName: collectionName,
                                          uid: sb.uid,
                                          timestamp: d.timestamp),
                                      onPressed: () {
                                        handleBookmarkClick();
                                      }),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Hero(
                    tag:
                        'blog_${d.timestamp}', // Usar un ID único basado en el timestamp
                    child: Container(
                        height: 250,
                        width: double.infinity,
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(0),
                            child: CustomCacheImage(
                                imageUrl: d.thumbnailImagelUrl))),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 20, left: 20, right: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        LoveCount(
                            collectionName: collectionName,
                            timestamp: d.timestamp),
                        SizedBox(
                          width: 15,
                        ),
                        TextButton.icon(
                            style: ButtonStyle(
                                backgroundColor:
                                    WidgetStateProperty.resolveWith((states) =>
                                        Theme.of(context).primaryColor)),
                            onPressed: () {
                              nextScreen(
                                  context,
                                  CommentsPage(
                                      collectionName: collectionName,
                                      timestamp: d.timestamp));
                            },
                            icon: Icon(
                              Feather.message_circle,
                              color: Colors.white,
                            ),
                            label: Text(
                              'comments',
                              style: _textStyleMedium.copyWith(
                                  color: Colors.white),
                            ).tr())
                      ],
                    ),
                  ),

                  // **Agregar el botón de Speak/Stop aquí**
                  SpeechButton(
                    text: translatedDescription,
                    defaultLanguage: 'es-ES',
                    speechRate: 0.5,
                    pitch: 1.0,
                  ),

                  // **HtmlBodyWidget Modificado para Usar la Descripción Traducida**
                  HtmlBodyWidget(
                    content: d.description.toString(),
                    translatedContent:
                        translatedDescription, // **Añadido para TTS**
                    isIframeVideoEnabled: true,
                    isVideoEnabled: true,
                    isimageEnabled: true,
                    fontSize: null,
                  ),

                  SizedBox(
                    height: 30,
                  )
                ],
              ),
            ),
          ),
          Positioned(
            top: 20,
            left: 15,
            child: SafeArea(
              child: CircleAvatar(
                backgroundColor:
                    Theme.of(context).primaryColor.withOpacity(0.9),
                child: IconButton(
                  icon: Icon(
                    LineIcons.arrowLeft,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Text _getSourceName(Blog d) {
    FontSizeController fontSizeController = getx.Get.find<FontSizeController>();
    TextStyle _textStyleMedium = Theme.of(context).textTheme.bodyMedium!;

    return Text(
      d.sourceUrl!.contains('www')
          ? d.sourceUrl!.replaceAll('https://www.', '').split('.').first
          : d.sourceUrl!.replaceAll('https://', '').split('.').first,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: _textStyleMedium.copyWith(
          color: Colors.grey[900],
          fontWeight:
              fontSizeController.obtainContrastFromBase(FontWeight.w500)),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Obtener el idioma del contexto
    final String lang = context.locale.languageCode;
    final String? countryCode = context.locale.countryCode;
    String localeTag = countryCode != null ? '$lang-$countryCode' : lang;

    // Llamar al método de traducción si aún no se ha traducido
    if (translatedDescription == null) {
      _translateDescription(localeTag);
    }
  }
}
