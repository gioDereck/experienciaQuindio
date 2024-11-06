import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travel_hour/config/config.dart';
import 'package:travel_hour/controllers/font_size_controller.dart';
import 'package:get/get.dart' as getx;
import 'package:easy_localization/easy_localization.dart' as easy;
import 'package:travel_hour/utils/app_colors.dart';
import 'package:travel_hour/widgets/header.dart';

class Conversation {
  final String id;
  final String title;
  final List<Message> messages;

  Conversation({required this.id, required this.title, required this.messages});

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'messages': messages.map((m) => m.toJson()).toList(),
    };
  }

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'],
      title: json['title'],
      messages: (json['messages'] as List)
          .map((m) => Message.fromJson(m))
          .toList(),
    );
  }
}

class Message {
  final bool isUser;
  final String text;
  final List<String> imageUrls;

  Message({
    required this.isUser,
    required this.text,
    required this.imageUrls,
  });

  Map<String, dynamic> toJson() {
    return {
      'isUser': isUser,
      'text': text,
      'imageUrls': imageUrls,
    };
  }

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      isUser: json['isUser'],
      text: json['text'],
      imageUrls: List<String>.from(json['imageUrls']),
    );
  }
}

class ConversationStore {
  static final ConversationStore _singleton = ConversationStore._internal();
  List<Conversation> conversations = [];

  factory ConversationStore() {
    return _singleton;
  }

  ConversationStore._internal();

  Future<void> saveConversations() async {
    final prefs = await SharedPreferences.getInstance();
    final conversationsJson = conversations.map((c) => c.toJson()).toList();
    await prefs.setString('conversations', jsonEncode(conversationsJson));
  }

  Future<void> loadConversations() async {
    final prefs = await SharedPreferences.getInstance();
    final conversationsString = prefs.getString('conversations');
    if (conversationsString != null) {
      final conversationsJson = jsonDecode(conversationsString) as List;
      conversations = conversationsJson
          .map((c) => Conversation.fromJson(c))
          .toList();
    }
  }
}

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    await ConversationStore().loadConversations();
  }

  @override
  Widget build(BuildContext context) {
    return MainChatView(isEnabled: true);
  }
}

class MainChatView extends StatefulWidget {
  final bool isEnabled;

  const MainChatView({
    Key? key,
    required this.isEnabled,
  }) : super(key: key);

  @override
  _MainChatViewState createState() => _MainChatViewState();
}

class _MainChatViewState extends State<MainChatView> {
  Conversation? _currentConversation;
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;
  String? name;
  String? email;
  bool hasSession = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    if (ConversationStore().conversations.isEmpty) {
      _startNewConversation();
    } else {
      _currentConversation = ConversationStore().conversations.last;
    }

    final sp = await SharedPreferences.getInstance();
    final username = sp.getString('name');
    final uid = sp.getString('uid');
    if (mounted) {
      setState(() {
        email = sp.getString('email');
        name = username?.split(" ")[0];
        hasSession = uid != null;
      });
    }
  }

  bool get _canSendMessages =>
      _currentConversation != null &&
      ((ConversationStore().conversations.isNotEmpty &&
              _currentConversation == ConversationStore().conversations.last) ||
          !ConversationStore().conversations.contains(_currentConversation));

   void _startNewConversation() {
    setState(() {
      final newConversation = Conversation(
        id: DateTime.now().toString(),
        title: '${easy.tr('conversation_label')} ${ConversationStore().conversations.length + 1}',
        messages: [],
      );
      ConversationStore().conversations.add(newConversation);
      _currentConversation = newConversation;
      ConversationStore().saveConversations();
    });
  }

   void _selectConversation(Conversation conversation) {
    setState(() {
      _currentConversation = conversation;
    });
  }

  Future<void> _sendMessage() async {
    if (_controller.text.trim().isEmpty) return;
    
    setState(() {
      final newMessage = Message(
        isUser: true,
        text: _controller.text,
        imageUrls: [],
      );

      _currentConversation!.messages.add(newMessage);
      _isLoading = true;
    });

    await ConversationStore().saveConversations();

    String authToken = '104|tERTv6JWIjAWFRuhf6iBc4rokKdmq35kStO7kpsib114af9d';
    String apiUrl = '${Config().url}/api/send-assistant/message';
    Uri uri = WebUri(apiUrl);
    var request = http.MultipartRequest('POST', uri);

    request.fields['email'] = email ?? '';
    request.fields['message'] = _controller.text;
    request.headers['Content-Type'] = 'multipart/form-data';
    request.headers['Authorization'] = 'Bearer $authToken';

    _controller.clear();
    
    try {
      var response = await request.send();
      final data = jsonDecode(await response.stream.bytesToString());
      String status = data['status'];

      if (response.statusCode == 200 && status.toLowerCase() == "success") {
        setState(() {
          final responseMessage = Message(
            isUser: false,
            text: data['message']['message'],
            imageUrls: [],
          );
          _currentConversation!.messages.add(responseMessage);
          _isLoading = false;
        });
        
        await ConversationStore().saveConversations();
      } else {
        throw Exception('Error en la respuesta del servidor');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('easy_to_send_message').tr()),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    FontSizeController fontSizeController = getx.Get.find<FontSizeController>();
    TextStyle _textStyleLarge = Theme.of(context).textTheme.bodyLarge!;
    TextStyle _textStyleMedium = Theme.of(context).textTheme.bodyMedium!;

    return RawKeyboardListener(
      focusNode: FocusNode(),
      onKey: (RawKeyEvent event) {
        if (event is RawKeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.enter &&
            !event.isShiftPressed) {
          _sendMessage();
        }
      },
      child: Scaffold(
        drawer: widget.isEnabled ? _buildDrawer(_textStyleLarge, _textStyleMedium, fontSizeController) : null,
        body: Column(
          children: [
            Header(withoutSearch: true),
            Container(
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Builder(
                    builder: (context) => IconButton(
                      icon: Icon(Icons.menu, color: Colors.black),
                      onPressed: widget.isEnabled
                          ? () => Scaffold.of(context).openDrawer()
                          : null,
                    ),
                  ),
                  Text(
                    hasSession 
                      ? easy.tr('chat with assistant', namedArgs: {'name_ia': Config().nameIa})
                      : Config().nameIa,
                    style: _textStyleMedium.copyWith(
                      color: Colors.black,
                      fontWeight: fontSizeController.obtainContrastFromBase(FontWeight.bold),
                    ),
                  ).tr(),
                  IconButton(
                    icon: Icon(Icons.keyboard_arrow_left, color: Colors.black),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _buildChatArea(_textStyleMedium),
            ),
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer(TextStyle _textStyleLarge, TextStyle _textStyleMedium, FontSizeController fontSizeController) {
    return Container(
      width: MediaQuery.of(context).size.width * (
          MediaQuery.of(context).size.width >= 600 ? 0.43 : 0.8),
      child: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.white),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.chat, color: CustomColors.primaryColor, size: 30),
                      SizedBox(width: 10),
                      Text(
                        'Chat',
                        style: _textStyleLarge.copyWith(
                          color: Colors.black,
                          fontWeight: fontSizeController
                              .obtainContrastFromBase(FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(Icons.add, color: CustomColors.primaryColor),
                    onPressed: () {
                      Navigator.pop(context);
                      _startNewConversation();
                    },
                  ),
                ],
              ),
            ),
            ...ConversationStore().conversations.map((conversation) {
              bool isCurrentConversation = _currentConversation?.id == conversation.id;
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 8), // Añadido padding horizontal
                decoration: BoxDecoration(
                  color: isCurrentConversation ? CustomColors.primaryColor.withOpacity(0.1) : null,
                  border: Border(
                    left: BorderSide(
                      color: isCurrentConversation ? CustomColors.primaryColor : Colors.transparent,
                      width: 4,
                    ),
                  ),
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8), // Añadido padding al contenido
                  leading: Icon(
                    isCurrentConversation ? Icons.chat : Icons.chat_bubble_outline,
                    color: isCurrentConversation ? CustomColors.primaryColor : Colors.grey,
                  ),
                  title: Text(
                    conversation.title,
                    style: _textStyleMedium.copyWith(
                      color: isCurrentConversation ? CustomColors.primaryColor : Colors.black,
                      fontWeight: isCurrentConversation ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  subtitle: Text(
                    isCurrentConversation ? easy.tr('actual_chat') : easy.tr('click_to_see'),
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: isCurrentConversation ? CustomColors.primaryColor : Colors.grey,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _selectConversation(conversation);
                  },
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      /*
                      if (isCurrentConversation)
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: CustomColors.primaryColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            easy.tr('active'),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      */
                      SizedBox(width: 8),
                      IconButton(
                        icon: Icon(
                          Icons.delete,
                          color: Colors.red,
                        ),
                        onPressed: () async {
                          setState(() {
                            ConversationStore().conversations.remove(conversation);
                            if (_currentConversation == conversation) {
                              _currentConversation = ConversationStore().conversations.isNotEmpty 
                                  ? ConversationStore().conversations.last 
                                  : null;
                            }
                          });
                          await ConversationStore().saveConversations();
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildChatArea(TextStyle _textStyleMedium) {
  if (_currentConversation != null && _currentConversation!.messages.isNotEmpty) {
    return ListView.builder(
      reverse: true,
      padding: EdgeInsets.symmetric(vertical: 20),
      itemCount: _currentConversation!.messages.length + (_isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (_isLoading && index == 0) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [CircularProgressIndicator()],
          );
        }

        final messageIndex = _currentConversation!.messages.length - 1 - (_isLoading ? index - 1 : index);
        final message = _currentConversation!.messages[messageIndex];
        return _buildMessageBubble(message);
      },
    );
  } else {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: Image.asset(
              'assets/images/imgpsh_fullsize_anim.jfif',
              width: 200,
              height: 200,
            ),
          ),
          SizedBox(height: 20),
          Text(
            hasSession 
              ? easy.tr('how can I help you today', namedArgs: {'user_name': name ?? ''})
              : easy.tr('how can I help you today no session'),
            style: _textStyleMedium,
          ),
        ],
      ),
    );
  }
}

  Widget _buildMessageInput() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(30),
              ),
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: easy.tr('message_placeholder'),
                  border: InputBorder.none,
                ),
                enabled: _canSendMessages,
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          SizedBox(width: 10),
          Container(
            decoration: BoxDecoration(
              color: _canSendMessages ? Colors.green : Colors.grey,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(Icons.arrow_upward, color: Colors.white),
              onPressed: _canSendMessages ? _sendMessage : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Message message) {
    final bool isUser = message.isUser;
    FontSizeController fontSizeController = getx.Get.find<FontSizeController>();
    TextStyle _textStyleMedium = Theme.of(context).textTheme.bodyMedium!;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser)
            CircleAvatar(
              backgroundColor: Colors.blue,
              child: Text('A', style: _textStyleMedium.copyWith(color: Colors.white)),
            ),
          if (isUser)
            CircleAvatar(
              backgroundColor: Colors.green,
              child: Text('U', style: _textStyleMedium.copyWith(color: Colors.white)),
            ),
          SizedBox(width: 10),
          Flexible(
            child: Column(
              crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Text(
                  isUser ? easy.tr('YOU') : easy.tr('ASSISTANT', namedArgs: {'name_ia': Config().nameIa}).toUpperCase(),
                  style: _textStyleMedium.copyWith(
                    fontWeight: fontSizeController.obtainContrastFromBase(FontWeight.bold),
                    color: Colors.black,
                  ),
                ),
                if (message.text.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.green[100] : Colors.blue[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      message.text,
                      style: _textStyleMedium,
                    ),
                  ),
                if (message.imageUrls.isNotEmpty)
                  ...message.imageUrls.map<Widget>((imageUrl) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.network(
                        imageUrl,
                        width: 150,
                        height: 150,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 150,
                            height: 150,
                            color: Colors.grey[300],
                            child: Icon(Icons.error),
                          );
                        },
                      ),
                    );
                  }).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}