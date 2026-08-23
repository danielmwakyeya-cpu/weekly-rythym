import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:local_auth/local_auth.dart';
import '../theme/app_theme.dart';

class LockScreen extends StatefulWidget {
  final AppColors colors;
  final Widget destination;

  const LockScreen({
    super.key,
    required this.colors,
    required this.destination,
  });

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> with SingleTickerProviderStateMixin {
  final LocalAuthentication _auth = LocalAuthentication();
  bool _isAuthenticating = false;
  String _statusMessage = 'Authenticate to unlock';
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) => _authenticate());
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _authenticate() async {
    if (_isAuthenticating) return;
    setState(() {
      _isAuthenticating = true;
      _statusMessage = 'Authenticating...';
    });

    try {
      final canAuth = await _auth.canCheckBiometrics || await _auth.isDeviceSupported();
      if (!canAuth) {
        _proceedToApp();
        return;
      }

      final didAuth = await _auth.authenticate(
        localizedReason: 'Unlock Weekly Rhythm',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );

      if (didAuth) {
        _proceedToApp();
      } else {
        setState(() {
          _isAuthenticating = false;
          _statusMessage = 'Authentication failed. Tap to retry.';
        });
      }
    } catch (e) {
      setState(() {
        _isAuthenticating = false;
        _statusMessage = 'Tap to authenticate';
      });
    }
  }

  void _proceedToApp() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => widget.destination,
        transitionsBuilder: (_, anim, __, child) {
          return FadeTransition(opacity: anim, child: child);
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors;

    return Scaffold(
      backgroundColor: colors.ink,
      body: GestureDetector(
        onTap: _isAuthenticating ? null : _authenticate,
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Lock icon with pulse
              ScaleTransition(
                scale: _pulseAnimation,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        colors.terracotta.withOpacity(0.3),
                        colors.plum,
                      ],
                    ),
                    border: Border.all(color: colors.terracotta.withOpacity(0.5), width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: colors.terracotta.withOpacity(0.2),
                        blurRadius: 30,
                      ),
                    ],
                  ),
                  child: Icon(
                    _isAuthenticating ? Icons.fingerprint : Icons.lock_outline_rounded,
                    size: 44,
                    color: colors.cream.withOpacity(0.8),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              Text(
                'Weekly Rhythm',
                style: GoogleFonts.fraunces(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: colors.cream,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                _statusMessage,
                style: GoogleFonts.workSans(
                  fontSize: 14,
                  color: colors.muted,
                ),
              ),

              if (!_isAuthenticating) ...[
                const SizedBox(height: 24),
                TextButton.icon(
                  onPressed: _authenticate,
                  icon: Icon(Icons.fingerprint, color: colors.terracotta),
                  label: Text(
                    'Tap to Unlock',
                    style: GoogleFonts.workSans(
                      color: colors.terracotta,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
