import 'package:flutter/material.dart';
import 'package:invoiceapp/constrains/Colors.dart';

class Welcome extends StatefulWidget {
  const Welcome({super.key});

  @override
  State<Welcome> createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> with TickerProviderStateMixin {
  late AnimationController _backgroundController;
  late AnimationController _contentController;
  late AnimationController _buttonController;

  late Animation<double> _backgroundAnimation;
  late Animation<double> _logoAnimation;
  late Animation<double> _titleAnimation;
  late Animation<double> _subtitleAnimation;
  late Animation<double> _buttonAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers
    _backgroundController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _contentController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Setup animations
    _backgroundAnimation = CurvedAnimation(
      parent: _backgroundController,
      curve: Curves.easeInOut,
    );

    _logoAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _contentController,
      curve: const Interval(0.0, 0.3, curve: Curves.elasticOut),
    ));

    _titleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _contentController,
      curve: const Interval(0.3, 0.6, curve: Curves.easeOutBack),
    ));

    _subtitleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _contentController,
      curve: const Interval(0.6, 0.9, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _buttonController,
      curve: Curves.elasticOut,
    ));

    _buttonAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _buttonController,
      curve: Curves.elasticOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _contentController,
      curve: Curves.easeOutBack,
    ));

    // Start animations
    _startAnimations();
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _backgroundController.forward();

    await Future.delayed(const Duration(milliseconds: 800));
    _contentController.forward();

    await Future.delayed(const Duration(milliseconds: 1800));
    _buttonController.forward();
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _contentController.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final safePadding = MediaQuery.of(context).padding;

    return Scaffold(
      body: AnimatedBuilder(
        animation: _backgroundController,
        builder: (context, child) {
          return Stack(
            children: [
              // White background
              Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.white,
              ),

              // Animated blue background
              AnimatedBuilder(
                animation: _backgroundAnimation,
                builder: (context, child) {
                  final animationValue = _backgroundAnimation.value;
                  final containerHeight = screenHeight * animationValue;

                  return Positioned(
                    top: screenHeight - containerHeight,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: containerHeight,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppColors.primary.withValues(alpha: 0.8),
                            AppColors.primary,
                          ],
                        ),
                        borderRadius: BorderRadius.only(
                          topLeft:
                              Radius.circular(50 * (1 - animationValue) + 20),
                          topRight:
                              Radius.circular(50 * (1 - animationValue) + 20),
                        ),
                      ),
                    ),
                  );
                },
              ),

              // Content with SafeArea
              Positioned.fill(
                child: SafeArea(
                  minimum: const EdgeInsets.all(16),
                  child: AnimatedBuilder(
                    animation: _contentController,
                    builder: (context, child) {
                      return LayoutBuilder(
                        builder: (context, constraints) {
                          final availableHeight = constraints.maxHeight;
                          final availableWidth = constraints.maxWidth;

                          return SingleChildScrollView(
                            physics: const ClampingScrollPhysics(),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minHeight: availableHeight,
                                maxWidth: availableWidth,
                              ),
                              child: IntrinsicHeight(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: availableWidth > 400 ? 32 : 16,
                                    vertical: 16,
                                  ),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      // Top spacer
                                      SizedBox(height: availableHeight * 0.05),

                                      // App logo with animation
                                      AnimatedBuilder(
                                        animation: _logoAnimation,
                                        builder: (context, child) {
                                          final logoSize =
                                              (availableWidth * 0.22)
                                                  .clamp(70.0, 100.0);
                                          final iconSize = logoSize * 0.5;

                                          return Transform.scale(
                                            scale: _logoAnimation.value *
                                                _scaleAnimation.value,
                                            child: Opacity(
                                              opacity: _logoAnimation.value,
                                              child: Container(
                                                width: logoSize,
                                                height: logoSize,
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          logoSize * 0.2),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black
                                                          .withValues(
                                                              alpha: 0.1),
                                                      blurRadius: 20,
                                                      offset:
                                                          const Offset(0, 8),
                                                    ),
                                                  ],
                                                ),
                                                child: Icon(
                                                  Icons.receipt_long_rounded,
                                                  size: iconSize,
                                                  color: AppColors.primary,
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),

                                      // Title section
                                      AnimatedBuilder(
                                        animation: _titleAnimation,
                                        builder: (context, child) {
                                          return Transform.translate(
                                            offset: Offset(
                                                0,
                                                50 *
                                                    (1 -
                                                        _titleAnimation.value)),
                                            child: Opacity(
                                              opacity: _titleAnimation.value,
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  ConstrainedBox(
                                                    constraints: BoxConstraints(
                                                      maxWidth:
                                                          availableWidth * 0.9,
                                                    ),
                                                    child: FittedBox(
                                                      fit: BoxFit.scaleDown,
                                                      child: Text(
                                                        "Billora",
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.w900,
                                                          fontSize:
                                                              (availableWidth *
                                                                      0.13)
                                                                  .clamp(32.0,
                                                                      56.0),
                                                          letterSpacing: 1.5,
                                                          shadows: [
                                                            Shadow(
                                                              color: Colors
                                                                  .black
                                                                  .withValues(
                                                                      alpha:
                                                                          0.3),
                                                              offset:
                                                                  const Offset(
                                                                      1, 2),
                                                              blurRadius: 4,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Container(
                                                    width: 50,
                                                    height: 3,
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              2),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),

                                      // Subtitle section
                                      AnimatedBuilder(
                                        animation: _subtitleAnimation,
                                        builder: (context, child) {
                                          return Transform.translate(
                                            offset: Offset(
                                                0,
                                                30 *
                                                    (1 -
                                                        _subtitleAnimation
                                                            .value)),
                                            child: Opacity(
                                              opacity: _subtitleAnimation.value,
                                              child: ConstrainedBox(
                                                constraints: BoxConstraints(
                                                  maxWidth:
                                                      availableWidth * 0.85,
                                                ),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Text(
                                                      "Professional Invoice Maker",
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontSize:
                                                            (availableWidth *
                                                                    0.055)
                                                                .clamp(
                                                                    16.0, 22.0),
                                                        letterSpacing: 0.5,
                                                      ),
                                                      textAlign:
                                                          TextAlign.center,
                                                      maxLines: 2,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                    SizedBox(
                                                        height:
                                                            availableHeight *
                                                                0.02),
                                                    Text(
                                                      "Create beautiful invoices in seconds\nManage clients, track payments\nGrow your business effortlessly",
                                                      style: TextStyle(
                                                        color: Colors.white
                                                            .withValues(
                                                                alpha: 0.9),
                                                        height: 1.4,
                                                        fontSize:
                                                            (availableWidth *
                                                                    0.038)
                                                                .clamp(
                                                                    12.0, 16.0),
                                                        fontWeight:
                                                            FontWeight.w400,
                                                      ),
                                                      textAlign:
                                                          TextAlign.center,
                                                      maxLines: 4,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),

                                      // Feature highlights
                                      AnimatedBuilder(
                                        animation: _subtitleAnimation,
                                        builder: (context, child) {
                                          return Opacity(
                                            opacity: _subtitleAnimation.value,
                                            child: ConstrainedBox(
                                              constraints: BoxConstraints(
                                                maxWidth: availableWidth * 0.8,
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: [
                                                  Expanded(
                                                      child: _buildFeatureItem(
                                                          Icons.speed, "Fast")),
                                                  Expanded(
                                                      child: _buildFeatureItem(
                                                          Icons.palette,
                                                          "Beautiful")),
                                                  Expanded(
                                                      child: _buildFeatureItem(
                                                          Icons.trending_up,
                                                          "Smart")),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),

                                      // Get Started button
                                      SlideTransition(
                                        position: _slideAnimation,
                                        child: ScaleTransition(
                                          scale: _buttonAnimation,
                                          child: ConstrainedBox(
                                            constraints: BoxConstraints(
                                              maxWidth: availableWidth * 0.85,
                                              minWidth: 200,
                                            ),
                                            child: Container(
                                              height: (availableHeight * 0.065)
                                                  .clamp(48.0, 60.0),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(25),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withValues(
                                                            alpha: 0.15),
                                                    blurRadius: 12,
                                                    offset: const Offset(0, 4),
                                                  ),
                                                ],
                                              ),
                                              child: Material(
                                                color: Colors.transparent,
                                                child: InkWell(
                                                  borderRadius:
                                                      BorderRadius.circular(25),
                                                  onTap: () {
                                                    Navigator.pushNamed(context,
                                                        "/businessName");
                                                  },
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 24),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Flexible(
                                                          child: Text(
                                                            "Let's Get Started",
                                                            style: TextStyle(
                                                              color: AppColors
                                                                  .primary,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700,
                                                              fontSize:
                                                                  (availableWidth *
                                                                          0.045)
                                                                      .clamp(
                                                                          14.0,
                                                                          18.0),
                                                              letterSpacing:
                                                                  0.3,
                                                            ),
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            maxLines: 1,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            width: 8),
                                                        Icon(
                                                          Icons
                                                              .arrow_forward_rounded,
                                                          color:
                                                              AppColors.primary,
                                                          size:
                                                              (availableWidth *
                                                                      0.05)
                                                                  .clamp(16.0,
                                                                      20.0),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),

                                      // Bottom spacer
                                      SizedBox(height: availableHeight * 0.03),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),

              // Optimized floating particles
              if (screenWidth > 300 &&
                  screenHeight > 600) // Only show on reasonable screen sizes
                ...List.generate(3, (index) {
                  // Reduced from 5 to 3 particles
                  return AnimatedBuilder(
                    animation: _contentController,
                    builder: (context, child) {
                      final delay = index * 0.3;
                      final animationValue =
                          (_contentController.value - delay).clamp(0.0, 1.0);

                      // Safe positioning calculations
                      final baseLeft = screenWidth * (0.15 + index * 0.25);
                      final baseTop = screenHeight * (0.2 + index * 0.15);
                      final movement = 20 * animationValue;

                      final leftPosition =
                          baseLeft + (movement * (index.isEven ? 1 : -1));
                      final topPosition = baseTop + movement;

                      // Ensure particles stay well within bounds
                      final safeLeft =
                          leftPosition.clamp(20.0, screenWidth - 40);
                      final safeTop = topPosition.clamp(safePadding.top + 50,
                          screenHeight - safePadding.bottom - 50);

                      return Positioned(
                        left: safeLeft,
                        top: safeTop,
                        child: Opacity(
                          opacity: animationValue * 0.4,
                          child: Container(
                            width: 5 + index.toDouble(),
                            height: 5 + index.toDouble(),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.6),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String label) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final containerSize = (constraints.maxWidth * 0.8).clamp(35.0, 45.0);
        final iconSize = containerSize * 0.45;
        final fontSize = (constraints.maxWidth * 0.25).clamp(10.0, 12.0);

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: containerSize,
              height: containerSize,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(containerSize * 0.25),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: iconSize,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontWeight: FontWeight.w500,
                fontSize: fontSize,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        );
      },
    );
  }
}
