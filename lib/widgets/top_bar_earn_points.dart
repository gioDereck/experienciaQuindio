import 'package:flutter/material.dart';
import 'package:travel_hour/config/config.dart';
import 'package:travel_hour/pages/earn_points.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:travel_hour/services/drag_scroll.dart';

class TopBarEarnPoints extends StatefulWidget {
  final List<CityBadge> badges;
  final int? currentPoints;
  final int totalPoints;
  final String? heroTagPrefix; // Añadido para manejar tags únicos

  const TopBarEarnPoints({
    Key? key,
    required this.badges,
    required this.currentPoints,
    required this.totalPoints,
    this.heroTagPrefix,
  }) : super(key: key);

  @override
  State<TopBarEarnPoints> createState() => _TopBarEarnPointsState();
}

class _TopBarEarnPointsState extends State<TopBarEarnPoints>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late AnimationController _animationController;
  late Animation<double> _heightAnimation;
  bool _isExpanded = true;
  bool _isSmallScreen = false;
  bool _isAnimating = false;

  // Alturas ajustadas para mejor responsividad
  final double _expandedHeight = 333.0;
  final double _collapsedHeight = 72.0;
  final double _minScreenHeight = 330.0;

  @override
  void initState() {
    super.initState();
    _initializeAnimation();
    _setupScrollController();
  }

  void _initializeAnimation() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _heightAnimation = Tween<double>(
      begin: _expandedHeight,
      end: _collapsedHeight,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    )..addStatusListener(_handleAnimationStatus);
  }

  void _handleAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed ||
        status == AnimationStatus.dismissed) {
      if (mounted) {
        setState(() => _isAnimating = false);
      }
    }
  }

  void _setupScrollController() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients && widget.badges.isNotEmpty) {
        final scrollPosition = _scrollController.position.maxScrollExtent / 2;
        _scrollController.animateTo(
          scrollPosition,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    if (_isAnimating) return;

    setState(() {
      _isAnimating = true;
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.reverse();
      } else {
        _animationController.forward();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _isSmallScreen = MediaQuery.of(context).size.height < _minScreenHeight;
  }

  Widget _buildBadgeItem(CityBadge badge) {
    String heroTag = '${widget.heroTagPrefix ?? ''}badge_${badge.name}';
    
    return Container(
      width: 120,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Hero(
            tag: heroTag,
            child: ClipOval(
              child: Image.network(
                '${Config().media_url}${badge.image}',
                width: 120,
                height: 120,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => _buildErrorContainer(),
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return _buildLoadingContainer();
                },
              ),
            ),
          ),
          const SizedBox(height: 8),
          _buildBadgeLabel(badge.name),
        ],
      ),
    );
  }

  Widget _buildErrorContainer() {
    return Container(
      width: 120,
      height: 120,
      color: Colors.grey[300],
      child: const Icon(Icons.error),
    );
  }

  Widget _buildLoadingContainer() {
    return Container(
      width: 120,
      height: 120,
      color: Colors.grey[300],
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildBadgeLabel(String name) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        name,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildContent() {
    if (widget.badges.isEmpty) {
      return _buildEmptyBadgesMessage();
    }

    return Expanded(
      child: ScrollConfiguration(
        behavior: CustomScrollBehavior(),
        child: SingleChildScrollView(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          dragStartBehavior: DragStartBehavior.down,
          child: Row(
            children: widget.badges.map(_buildBadgeItem).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyBadgesMessage() {
    String imageUrl = _getLocalizedMessageImage();
    
    return Expanded(
      child: Center(
        child: Image.network(
          imageUrl,
          fit: BoxFit.contain,
          height: MediaQuery.of(context).size.width < 400 ? 200 : 200,
          width: MediaQuery.of(context).size.width < 400 ? 250 : 350,
          errorBuilder: (context, error, stackTrace) {
            return const Center(
              child: Text('Error al cargar la imagen'),
            );
          },
        ),
      ),
    );
  }

  String _getLocalizedMessageImage() {
    String basePath = '${Config().media_url}/uploads/2024/09/app/collectible_destinations/badges/';
    switch (context.locale.languageCode) {
      case 'en':
        return '${basePath}mensaje_ingles.png';
      case 'fr':
        return '${basePath}mensaje_frances.png';
      default:
        return '${basePath}mensaje_esp.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _heightAnimation,
      builder: (context, child) {
        return Container(
          height: _heightAnimation.value + 10,
          width: double.infinity,
          child: Stack(
            children: [
              Container(
                height: _heightAnimation.value,
                width: double.infinity,
                decoration: _buildBackgroundDecoration(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildTopBar(),
                    if (_heightAnimation.value > _collapsedHeight) ...[
                      _buildContent(),
                      _buildBottomSection(),
                    ],
                  ],
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _buildCollapseButton(),
              ),
            ],
          ),
        );
      },
    );
  }

  BoxDecoration _buildBackgroundDecoration() {
    return BoxDecoration(
      image: DecorationImage(
        image: NetworkImage(
          '${Config().media_url}/uploads/2024/09/app/collectible_destinations/earn_points/fondo_1.jpg',
        ),
        fit: BoxFit.fill,
        colorFilter: ColorFilter.mode(
          Colors.black.withOpacity(0.5),
          BlendMode.darken,
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return SizedBox(
      height: _collapsedHeight,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildBackButton(),
                _buildPointsCounter(),
              ],
            ),
          ),
          if (_isSmallScreen) _buildCompactCollapseButton(),
        ],
      ),
    );
  }

  Widget _buildBackButton() {
    return Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(
        color: Color(0xFF8CC63F),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
    );
  }

  Widget _buildPointsCounter() {
    String heroTag = '${widget.heroTagPrefix ?? ''}points_counter';
    
    return Hero(
      tag: heroTag,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${widget.currentPoints ?? 0}/${widget.totalPoints}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            const Image(
              image: AssetImage("assets/images/copa.png"),
              width: 32,
              height: 32,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSection() {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF8CC63F),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: _buildLocalizedBottomImage(),
    );
  }

  Widget _buildLocalizedBottomImage() {
    String imageUrl = _getLocalizedBottomImage();
    
    return Image.network(
      imageUrl,
      height: 60,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return const SizedBox(
          height: 60,
          child: Center(
            child: Text('Error al cargar la imagen'),
          ),
        );
      },
    );
  }

  String _getLocalizedBottomImage() {
    String basePath = '${Config().media_url}/uploads/2024/09/';
    switch (context.locale.languageCode) {
      case 'en':
        return '${basePath}game/collect_game_eng_1.png';
      case 'fr':
        return '${basePath}game/collect_game_frances.png';
      default:
        return '${basePath}app/collectible_destinations/earn_points/texto_central.png';
    }
  }

  Widget _buildCompactCollapseButton() {
    return Center(
      child: Container(
        width: 40,
        height: 20,
        decoration: BoxDecoration(
          color: const Color(0xFF8CC63F),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: !_isAnimating ? _toggleExpanded : null,
            borderRadius: BorderRadius.circular(10),
            child: Icon(
              _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              color: Colors.white,
              size: 16,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCollapseButton() {
    return Container(
      width: double.infinity,
      height: 20,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Barra extendida
          Container(
            height: 20,
            color: const Color(0xFF8CC63F),
          ),
          // Botón central con bordes redondeados
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Container(
                  height: 20,
                  decoration: const BoxDecoration(
                    color: Color(0xFF8CC63F),
                  ),
                ),
              ),
              Container(
                width: 80,
                height: 20,
                decoration: const BoxDecoration(
                  color: Color(0xFF8CC63F),
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(10),
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: !_isAnimating ? _toggleExpanded : null,
                    child: Icon(
                      _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  height: 20,
                  decoration: const BoxDecoration(
                    color: Color(0xFF8CC63F),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}