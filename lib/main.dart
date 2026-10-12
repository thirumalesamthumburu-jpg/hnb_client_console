import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://benmsdcykymxqceibdok.supabase.co',
    publishableKey: 'sb_publishable_0IaqK3nfqsPjlGCftwFJKQ_VZvXZAqX',
  );

  runApp(const ClientApp());
}

final supabase = Supabase.instance.client;

final GoRouter _router = GoRouter(
  routes: [
    GoRoute(
      path: '/:clientId',
      builder: (context, state) {
        final clientId = state.pathParameters['clientId'] ?? 'client1';
        return ClientDashboard(clientId: clientId);
      },
    ),
    GoRoute(
      path: '/',
      builder: (context, state) => const ClientDashboard(clientId: 'client1'),
    ),
  ],
);

class ClientApp extends StatelessWidget {
  const ClientApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
      title: 'HNB Cherished Memories',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E7D32),
          primary: const Color(0xFF2E7D32),
          secondary: const Color(0xFF81C784),
          surface: Colors.white,
        ),
        scaffoldBackgroundColor: const Color(0xFFF8FAF8),
      ),
    );
  }
}

class ClientDashboard extends StatefulWidget {
  final String clientId;
  const ClientDashboard({super.key, required this.clientId});

  @override
  State<ClientDashboard> createState() => _ClientDashboardState();
}

class _ClientDashboardState extends State<ClientDashboard> {
  Future<void> _downloadMedia(BuildContext context, String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open file for download.')),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error downloading: $e')),
      );
    }
  }

  void _openVideoModal(BuildContext context, String youtubeUrl, String title, String description) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black87,
      builder: (context) {
        return _VideoPlayerDialog(
          youtubeUrl: youtubeUrl,
          title: title,
          description: description,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 600;
    final crossAxisCount = width > 1100 ? 3 : (width > 650 ? 2 : 1);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // 1. Top Welcome Banner
          FutureBuilder<Map<String, dynamic>?>(
            future: supabase
                .from('client_profiles')
                .select()
                .eq('client_id', widget.clientId)
                .maybeSingle(),
            builder: (context, snapshot) {
              final profile = snapshot.data;
              final String name = profile?['name'] ?? widget.clientId.toUpperCase();
              final String designation = profile?['designation'] ?? 'VIP Client Guest';
              final String? photoUrl = profile?['photo_url'];

              return SliverAppBar.large(
                expandedHeight: isMobile ? 380 : 400,
                pinned: true,
                backgroundColor: const Color(0xFF1B5E20),
                title: Text(
                  'Welcome, $name • Cherished Memories ✨',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                centerTitle: true,
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: const EdgeInsets.only(bottom: 12),
                  background: Stack(
                    children: [
                      const Positioned.fill(
                        child: _AnimatedBannerBackground(),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 16 : 32,
                          vertical: 12,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(height: 20),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: const Color(0xFF81C784).withOpacity(0.6), width: 1),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.auto_awesome, size: 12, color: Color(0xFF81C784)),
                                  SizedBox(width: 6),
                                  Text(
                                    '"Moments fade, but memories stay forever"',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),

                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF81C784), Color(0xFF4CAF50)],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 14,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(3),
                              child: CircleAvatar(
                                radius: isMobile ? 36 : 42,
                                backgroundColor: Colors.white,
                                backgroundImage: (photoUrl != null && photoUrl.isNotEmpty)
                                    ? NetworkImage(photoUrl)
                                    : null,
                                child: (photoUrl == null || photoUrl.isEmpty)
                                    ? Text(
                                  name.isNotEmpty ? name[0].toUpperCase() : 'H',
                                  style: TextStyle(
                                    color: const Color(0xFF2E7D32),
                                    fontSize: isMobile ? 26 : 32,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                                    : null,
                              ),
                            ),
                            const SizedBox(height: 8),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('🎉 ', style: TextStyle(fontSize: 18)),
                                Flexible(
                                  child: Text(
                                    'Welcome, $name',
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: isMobile ? 20 : 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Icon(Icons.verified, size: 16, color: Color(0xFF81C784)),
                                const Text(' ✨', style: TextStyle(fontSize: 16)),
                              ],
                            ),
                            const SizedBox(height: 2),

                            Text(
                              designation.toUpperCase(),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Color(0xFFA5D6A7),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.0,
                              ),
                            ),
                            const SizedBox(height: 6),

                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.white.withOpacity(0.2)),
                              ),
                              child: const Text(
                                '✨ HNB OFFICIAL CLIENT VISIT • 16-10-2026 ✨',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Color(0xFFE8F5E9),
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),

                            const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _HeaderStatChip(
                                  icon: Icons.photo_library_outlined,
                                  label: 'Photos',
                                  value: 'Gallery',
                                ),
                                SizedBox(width: 8),
                                _HeaderStatChip(
                                  icon: Icons.videocam_outlined,
                                  label: 'Videos',
                                  value: 'Highlights',
                                ),
                                SizedBox(width: 8),
                                _HeaderStatChip(
                                  icon: Icons.celebration_outlined,
                                  label: 'Event',
                                  value: 'Cherished',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // 2. Section Header: Highlights
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(isMobile ? 18 : 28, 28, isMobile ? 18 : 28, 14),
              child: const _SectionHeader(
                icon: Icons.star_rounded,
                title: 'Featured Event Highlights',
                subtitle: 'Curated milestones & key event moments',
              ),
            ),
          ),

          // 3. Carousel
          FutureBuilder<List<Map<String, dynamic>>>(
            future: supabase
                .from('event_highlights')
                .select()
                .order('display_order', ascending: true),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverToBoxAdapter(
                  child: SizedBox(
                    height: 200,
                    child: Center(child: CircularProgressIndicator(color: Color(0xFF2E7D32))),
                  ),
                );
              }
              final highlights = snapshot.data ?? [];
              if (highlights.isEmpty) {
                return const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    child: Text(
                      'No highlights curated yet.',
                      style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                    ),
                  ),
                );
              }

              return SliverToBoxAdapter(
                child: _HighlightsCarousel(highlights: highlights, isMobile: isMobile),
              );
            },
          ),

          // 4. Section Header: Moments & Posters
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(isMobile ? 18 : 28, 32, isMobile ? 18 : 28, 14),
              child: const _SectionHeader(
                icon: Icons.photo_library_rounded,
                title: 'Cherished Moments & Posters',
                subtitle: 'Captured photos & commemorative posters',
              ),
            ),
          ),

          // 5. Photos Grid
          FutureBuilder<List<Map<String, dynamic>>>(
            future: supabase
                .from('moments')
                .select()
                .eq('client_name', widget.clientId)
                .order('created_at', ascending: false),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: CircularProgressIndicator(color: Color(0xFF2E7D32))),
                );
              }
              final list = snapshot.data ?? [];
              if (list.isEmpty) {
                return const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Center(
                      child: Text(
                        'No photo memories found.',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: isMobile ? 1.2 : 1.3,
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final data = list[index];
                    return _BeautifiedPhotoCard(
                      index: index,
                      momentData: data,
                      onDownload: () => _downloadMedia(context, data['media_url'] ?? ''),
                    );
                  }, childCount: list.length),
                ),
              );
            },
          ),

          // 6. Section Header: Video Gallery
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(isMobile ? 18 : 28, 32, isMobile ? 18 : 28, 14),
              child: const _SectionHeader(
                icon: Icons.video_collection_rounded,
                title: 'Exclusive Video Gallery',
                subtitle: 'Flashmobs, celebrations & video showcases',
              ),
            ),
          ),

          // 7. Video Grid
          FutureBuilder<List<Map<String, dynamic>>>(
            future: supabase
                .from('videos')
                .select()
                .eq('client_name', widget.clientId)
                .order('created_at', ascending: false),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverToBoxAdapter(
                  child: SizedBox(
                    height: 180,
                    child: Center(child: CircularProgressIndicator(color: Color(0xFF2E7D32))),
                  ),
                );
              }
              final videos = snapshot.data ?? [];
              if (videos.isEmpty) {
                return const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    child: Text(
                      'No videos uploaded yet.',
                      style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: isMobile ? 1.2 : 1.3,
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final video = videos[index];
                    final youtubeUrl = video['youtube_url'] ?? '';
                    final title = video['title'] ?? 'HNB Highlight Video';
                    final description = video['description'] ?? 'Flashmobs & Special Events';

                    return _VideoThumbnailCard(
                      index: index,
                      youtubeUrl: youtubeUrl,
                      title: title,
                      description: description,
                      onTap: () => _openVideoModal(context, youtubeUrl, title, description),
                    );
                  }, childCount: videos.length),
                ),
              );
            },
          ),

          // 8. Footer
          SliverToBoxAdapter(
            child: Container(
              margin: EdgeInsets.fromLTRB(
                isMobile ? 16 : 24,
                24,
                isMobile ? 16 : 24,
                48,
              ),
              padding: EdgeInsets.all(isMobile ? 18 : 28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE0E0E0)),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Icon(Icons.format_quote_rounded, size: 32, color: Color(0xFF81C784)),
                  const SizedBox(height: 8),
                  const Text(
                    '"Great things in business are never done by one person. They are done by a team of people working together with passion and shared vision."',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1B5E20),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Divider(color: Color(0xFFE0E0E0)),
                  const SizedBox(height: 10),
                  Text(
                    '© 2026 HNB Cherished Moments. All rights reserved.',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Animated Banner Background
class _AnimatedBannerBackground extends StatefulWidget {
  const _AnimatedBannerBackground();

  @override
  State<_AnimatedBannerBackground> createState() => _AnimatedBannerBackgroundState();
}

class _AnimatedBannerBackgroundState extends State<_AnimatedBannerBackground>
    with TickerProviderStateMixin {
  late AnimationController _motionController;
  late AnimationController _flashController;
  late Animation<double> _floatAnim;
  late Animation<double> _pulseAnim;
  late Animation<double> _flashAnim;

  @override
  void initState() {
    super.initState();

    _motionController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);

    _floatAnim = Tween<double>(begin: -8.0, end: 12.0).animate(
      CurvedAnimation(parent: _motionController, curve: Curves.easeInOut),
    );

    _pulseAnim = Tween<double>(begin: 0.90, end: 1.10).animate(
      CurvedAnimation(parent: _motionController, curve: Curves.easeInOut),
    );

    _flashController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    _flashAnim = Tween<double>(begin: -1.5, end: 2.5).animate(
      CurvedAnimation(parent: _flashController, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _motionController.dispose();
    _flashController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2E7D32), Color(0xFF1B5E20), Color(0xFF0D3B12)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          AnimatedBuilder(
            animation: _motionController,
            builder: (context, child) {
              final floatVal = _floatAnim.value;
              final scaleVal = _pulseAnim.value;

              return Stack(
                children: [
                  Positioned(
                    top: -20 + floatVal,
                    right: -20,
                    child: Transform.scale(
                      scale: scaleVal,
                      child: Container(
                        width: 170,
                        height: 170,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.08),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 70 - floatVal,
                    left: -30,
                    child: Transform.scale(
                      scale: 2.0 - scaleVal,
                      child: Container(
                        width: 130,
                        height: 130,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF81C784).withOpacity(0.14),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -20 + floatVal,
                    right: 40,
                    child: Transform.scale(
                      scale: scaleVal,
                      child: Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.06),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 30 + (floatVal * 0.5),
                    left: 25,
                    child: Transform.scale(scale: scaleVal, child: const Text('⭐', style: TextStyle(fontSize: 17))),
                  ),
                  Positioned(
                    top: 60 - (floatVal * 0.5),
                    right: 35,
                    child: Transform.scale(scale: scaleVal, child: const Text('✨', style: TextStyle(fontSize: 19))),
                  ),
                  Positioned(
                    bottom: 70 + floatVal,
                    left: 20,
                    child: Transform.scale(scale: scaleVal, child: const Text('🌟', style: TextStyle(fontSize: 16))),
                  ),
                  Positioned(
                    bottom: 40 - floatVal,
                    right: 25,
                    child: Transform.scale(scale: scaleVal, child: const Text('✨', style: TextStyle(fontSize: 17))),
                  ),
                ],
              );
            },
          ),
          AnimatedBuilder(
            animation: _flashController,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment(_flashAnim.value - 1, -0.5),
                    end: Alignment(_flashAnim.value, 0.5),
                    colors: [
                      Colors.transparent,
                      Colors.white.withOpacity(0.08),
                      Colors.transparent,
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// Section Header Component
class _SectionHeader extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  State<_SectionHeader> createState() => _SectionHeaderState();
}

class _SectionHeaderState extends State<_SectionHeader> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFA5D6A7), width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF81C784).withOpacity(0.3),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: Icon(widget.icon, color: const Color(0xFF2E7D32), size: 18),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B5E20),
                      letterSpacing: -0.2,
                    ),
                  ),
                  Text(
                    widget.subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          height: 2,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(1),
            gradient: LinearGradient(
              colors: [
                const Color(0xFF2E7D32),
                const Color(0xFF81C784).withOpacity(0.4),
                Colors.transparent,
              ],
              stops: const [0.0, 0.4, 1.0],
            ),
          ),
        ),
      ],
    );
  }
}

// Stat Chip
class _HeaderStatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _HeaderStatChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: const Color(0xFF81C784)),
          const SizedBox(width: 5),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 8,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Highlights Carousel
class _HighlightsCarousel extends StatefulWidget {
  final List<Map<String, dynamic>> highlights;
  final bool isMobile;

  const _HighlightsCarousel({required this.highlights, required this.isMobile});

  @override
  State<_HighlightsCarousel> createState() => _HighlightsCarouselState();
}

class _HighlightsCarouselState extends State<_HighlightsCarousel> {
  late final PageController _pageController;
  Timer? _timer;
  int _currentPage = 0;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      viewportFraction: widget.isMobile ? 0.92 : 0.82,
      initialPage: 0,
    );

    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!mounted || widget.highlights.isEmpty || _isHovered) return;

      if (_currentPage < widget.highlights.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }

      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: SizedBox(
        height: widget.isMobile ? 250 : 300,
        child: PageView.builder(
          controller: _pageController,
          itemCount: widget.highlights.length,
          onPageChanged: (index) => setState(() => _currentPage = index),
          itemBuilder: (context, index) {
            final item = widget.highlights[index];

            return AnimatedBuilder(
              animation: _pageController,
              builder: (context, child) {
                double value = 1.0;
                if (_pageController.position.haveDimensions) {
                  value = (_pageController.page! - index).abs();
                  value = (1 - (value * 0.12)).clamp(0.88, 1.0);
                }
                return Transform.scale(
                  scale: value,
                  child: child,
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: Card(
                  elevation: 4,
                  shadowColor: Colors.black12,
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: const Color(0xFF81C784).withOpacity(0.3), width: 1),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        item['image_url'] ?? '',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Center(
                          child: Icon(Icons.broken_image, size: 40, color: Colors.grey),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.black.withOpacity(0.8), Colors.transparent],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                item['title'] ?? 'Key Milestone',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                item['description'] ?? 'HNB Official Visit Highlight',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// Photo Flex Card
class _BeautifiedPhotoCard extends StatefulWidget {
  final int index;
  final Map<String, dynamic> momentData;
  final VoidCallback onDownload;

  const _BeautifiedPhotoCard({
    required this.index,
    required this.momentData,
    required this.onDownload,
  });

  @override
  State<_BeautifiedPhotoCard> createState() => _BeautifiedPhotoCardState();
}

class _BeautifiedPhotoCardState extends State<_BeautifiedPhotoCard> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  bool _isLiked = false;
  bool _isHovered = false;
  late int _likesCount;

  @override
  void initState() {
    super.initState();
    _likesCount = widget.momentData['likes'] ?? 0;

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );

    Future.delayed(Duration(milliseconds: (widget.index * 60).clamp(0, 600)), () {
      if (mounted) _animController.forward();
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _toggleLike() async {
    setState(() {
      _isLiked = !_isLiked;
      _likesCount += _isLiked ? 1 : -1;
      if (_likesCount < 0) _likesCount = 0;
    });

    final momentId = widget.momentData['id'];
    if (momentId != null) {
      try {
        await supabase
            .from('moments')
            .update({'likes': _likesCount})
            .eq('id', momentId);
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaUrl = widget.momentData['media_url'] ?? '';
    final comment = widget.momentData['comment'] ?? '';

    return FadeTransition(
      opacity: _fadeAnimation,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          transform: _isHovered ? (Matrix4.identity()..translate(0, -3, 0)) : Matrix4.identity(),
          child: Card(
            elevation: _isHovered ? 6 : 3,
            shadowColor: Colors.black12,
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: const Color(0xFF81C784).withOpacity(0.3), width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        mediaUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: Colors.grey.shade100,
                          child: const Center(
                            child: Icon(Icons.broken_image, size: 36, color: Colors.grey),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 10,
                        right: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.white.withOpacity(0.25)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.verified, size: 11, color: Color(0xFF81C784)),
                              SizedBox(width: 4),
                              Text(
                                'Moment',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(10, 24, 10, 8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.black.withOpacity(0.75),
                                Colors.transparent,
                              ],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                          ),
                          child: Text(
                            comment.isNotEmpty ? comment : 'Cherished memory from HNB visit ✨',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  color: Colors.white,
                  child: Row(
                    children: [
                      InkWell(
                        onTap: _toggleLike,
                        borderRadius: BorderRadius.circular(10),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                                child: Icon(
                                  _isLiked ? Icons.favorite : Icons.favorite_border_rounded,
                                  key: ValueKey<bool>(_isLiked),
                                  size: 18,
                                  color: _isLiked ? Colors.redAccent : Colors.grey.shade600,
                                ),
                              ),
                              if (_likesCount > 0) ...[
                                const SizedBox(width: 4),
                                Text(
                                  '$_likesCount',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: _isLiked ? Colors.redAccent : Colors.grey.shade700,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      const Spacer(),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7D32),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: widget.onDownload,
                        icon: const Icon(Icons.download, size: 11),
                        label: const Text('Download', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Video Thumbnail Card
class _VideoThumbnailCard extends StatefulWidget {
  final int index;
  final String youtubeUrl;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _VideoThumbnailCard({
    required this.index,
    required this.youtubeUrl,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  State<_VideoThumbnailCard> createState() => _VideoThumbnailCardState();
}

class _VideoThumbnailCardState extends State<_VideoThumbnailCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final videoId = YoutubePlayerController.convertUrlToId(widget.youtubeUrl) ?? '';
    final thumbnailUrl = videoId.isNotEmpty
        ? 'https://img.youtube.com/vi/$videoId/hqdefault.jpg'
        : '';

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        transform: _isHovered ? (Matrix4.identity()..translate(0, -3, 0)) : Matrix4.identity(),
        child: Card(
          elevation: _isHovered ? 6 : 3,
          shadowColor: Colors.black12,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: const Color(0xFF81C784).withOpacity(0.3), width: 1),
          ),
          child: InkWell(
            onTap: widget.onTap,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      thumbnailUrl.isNotEmpty
                          ? Image.network(
                        thumbnailUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(color: Colors.black12),
                      )
                          : Container(color: Colors.black12),
                      Container(
                        color: Colors.black.withOpacity(0.25),
                      ),
                      Center(
                        child: AnimatedScale(
                          scale: _isHovered ? 1.10 : 1.0,
                          duration: const Duration(milliseconds: 300),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: const BoxDecoration(
                              color: Color(0xFF2E7D32),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 6,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 26,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: Color(0xFF1B5E20),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Video Player Modal Dialog with strict related videos
class _VideoPlayerDialog extends StatefulWidget {
  final String youtubeUrl;
  final String title;
  final String description;

  const _VideoPlayerDialog({
    required this.youtubeUrl,
    required this.title,
    required this.description,
  });

  @override
  State<_VideoPlayerDialog> createState() => _VideoPlayerDialogState();
}

class _VideoPlayerDialogState extends State<_VideoPlayerDialog> {
  YoutubePlayerController? _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    final videoId = YoutubePlayerController.convertUrlToId(widget.youtubeUrl) ?? '';
    if (videoId.isNotEmpty) {
      _controller = YoutubePlayerController.fromVideoId(
        videoId: videoId,
        autoPlay: true,
        params: const YoutubePlayerParams(
          showControls: true,
          showFullscreenButton: true,
          mute: false,
          strictRelatedVideos: true, // Restricts related videos to the same channel
        ),
      );

      _controller?.listen((value) {
        if (value.playerState == PlayerState.playing ||
            value.playerState == PlayerState.cued) {
          if (mounted && _isLoading) {
            setState(() {
              _isLoading = false;
            });
          }
        }
      });

      // Fallback timer
      Future.delayed(const Duration(milliseconds: 3000), () {
        if (mounted && _isLoading) {
          setState(() {
            _isLoading = false;
          });
        }
      });
    } else {
      _isLoading = false;
    }
  }

  @override
  void dispose() {
    _controller?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final dialogWidth = width > 800 ? 760.0 : width * 0.92;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Center(
        child: Container(
          width: dialogWidth,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Colors.black45,
                blurRadius: 20,
                offset: Offset(0, 8),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: const Color(0xFF1B5E20),
                child: Row(
                  children: [
                    const Icon(Icons.play_circle_fill_rounded, color: Color(0xFF81C784), size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _controller != null
                        ? YoutubePlayer(controller: _controller!)
                        : Container(
                      color: Colors.black,
                      child: const Center(
                        child: Text(
                          'Invalid Video URL',
                          style: TextStyle(color: Colors.redAccent),
                        ),
                      ),
                    ),
                    if (_isLoading)
                      AnimatedOpacity(
                        opacity: _isLoading ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 300),
                        child: Container(
                          color: const Color(0xFF0F172A),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(
                                color: Color(0xFF81C784),
                                strokeWidth: 3,
                              ),
                              SizedBox(height: 12),
                              Text(
                                'Loading Video...',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (widget.description.isNotEmpty)
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(14.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      widget.description,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}