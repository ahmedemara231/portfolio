import 'dart:async';
import 'package:core/core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'studio_widgets.dart';

class AuthGate extends StatefulWidget {
  final Widget child;
  const AuthGate({super.key, required this.child});
  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late final StreamSubscription<User?> subscription;
  User? user;
  bool checking = true, authorized = false, failed = false;
  int verification = 0;

  @override
  void initState() {
    super.initState();
    subscription = FirebaseAuth.instance.idTokenChanges().listen(
      verify,
      onError: (_) {
        if (mounted) {
          verification++;
          FocusManager.instance.primaryFocus?.unfocus();
          setState(() {
            authorized = false;
            checking = false;
            failed = true;
          });
        }
      },
    );
  }

  Future<void> verify(User? next) async {
    if (!mounted) return;
    final request = ++verification;
    final sameUser = user?.uid == next?.uid;
    if (!sameUser || next == null) {
      FocusManager.instance.primaryFocus?.unfocus();
    }
    setState(() {
      user = next;
      checking = next != null;
      failed = false;
      if (!sameUser || next == null) authorized = false;
    });
    if (next == null) return;
    try {
      final token = await next.getIdTokenResult();
      if (!mounted || request != verification) return;
      if (authorized != (token.claims?['admin'] == true)) {
        FocusManager.instance.primaryFocus?.unfocus();
      }
      setState(() {
        authorized = token.claims?['admin'] == true;
        checking = false;
      });
    } catch (_) {
      if (!mounted || request != verification) return;
      FocusManager.instance.primaryFocus?.unfocus();
      setState(() {
        authorized = false;
        checking = false;
        failed = true;
      });
    }
  }

  @override
  void dispose() {
    verification++;
    subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // A stable outer app owns focus; this guard owns all private navigation.
    if (authorized) {
      return KeyedSubtree(key: ValueKey(user!.uid), child: widget.child);
    }
    final Widget screen;
    if (checking) {
      screen = const Scaffold(body: Center(child: CircularProgressIndicator()));
    } else if (user == null && !failed) {
      screen = const SignInScreen();
    } else {
      screen = Scaffold(
        body: Center(
          child: StateMessage(
            title: failed
                ? 'Unable to verify access'
                : 'Administrator access required',
            message: failed
                ? 'Sign in again to refresh your session.'
                : 'This account is signed in, but it does not have permission to manage the portfolio.',
            action: TextButton(
              onPressed: () => FirebaseAuth.instance.signOut(),
              child: const Text('Sign out'),
            ),
          ),
        ),
      );
    }
    return screen;
  }
}

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});
  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final form = GlobalKey<FormState>();
  final email = TextEditingController(), password = TextEditingController();
  bool busy = false, obscure = true;
  String? error;
  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  Future<void> signIn() async {
    if (!form.currentState!.validate() || busy) return;
    FocusScope.of(context).unfocus();
    setState(() {
      busy = true;
      error = null;
    });
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.text.trim(),
        password: password.text,
      );
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(
          () => error = switch (e.code) {
            'too-many-requests' =>
              'Too many attempts. Please wait and try again.',
            'network-request-failed' => 'Check your connection and try again.',
            _ => 'Unable to sign in. Check your email and password.',
          },
        );
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(
            MediaQuery.sizeOf(context).width < 600 ? 20 : 48,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1080),
            child: LayoutBuilder(
              builder: (context, c) {
                final login = StudioPanel(
                  padding: EdgeInsets.all(c.maxWidth < 500 ? 24 : 32),
                  child: Form(
                    key: form,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Eyebrow('Portfolio Studio'),
                        const SizedBox(height: 16),
                        const Text(
                          'Welcome back.',
                          style: TextStyle(
                            fontSize: 38,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -1.2,
                            height: 1.15,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Sign in to maintain your work and the story around it.',
                          style: Design.bodyType,
                        ),
                        const SizedBox(height: 32),
                        TextFormField(
                          controller: email,
                          enabled: !busy,
                          keyboardType: TextInputType.emailAddress,
                          autofillHints: const [
                            AutofillHints.username,
                            AutofillHints.email,
                          ],
                          decoration: const InputDecoration(labelText: 'Email'),
                          validator: (value) =>
                              value != null &&
                                  RegExp(
                                    r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
                                  ).hasMatch(value.trim())
                              ? null
                              : 'Enter your email address.',
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: password,
                          enabled: !busy,
                          obscureText: obscure,
                          autofillHints: const [AutofillHints.password],
                          onFieldSubmitted: (_) => signIn(),
                          decoration: InputDecoration(
                            labelText: 'Password',
                            suffixIcon: IconButton(
                              tooltip: obscure
                                  ? 'Show password'
                                  : 'Hide password',
                              onPressed: busy
                                  ? null
                                  : () => setState(() => obscure = !obscure),
                              icon: Icon(
                                obscure
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                            ),
                          ),
                          validator: (value) => value == null || value.isEmpty
                              ? 'Enter your password.'
                              : null,
                        ),
                        const SizedBox(height: 24),
                        if (error != null)
                          Semantics(
                            liveRegion: true,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 18),
                              child: Text(
                                error!,
                                style: const TextStyle(
                                  color: Design.error,
                                  height: 1.6,
                                ),
                              ),
                            ),
                          ),
                        FilledButton(
                          onPressed: busy ? null : signIn,
                          child: busy
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('Sign in'),
                        ),
                        const SizedBox(height: 18),
                        const Text(
                          'Administrator access is required to manage content.',
                          style: Design.captionType,
                        ),
                      ],
                    ),
                  ),
                );
                if (c.maxWidth < 850) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const PortfolioBrand(),
                      const SizedBox(height: 28),
                      login,
                    ],
                  );
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 48),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const PortfolioBrand(),
                            const SizedBox(height: 48),
                            const Text(
                              'A studio for\nyour work.',
                              style: TextStyle(
                                fontSize: 60,
                                height: 1.1,
                                letterSpacing: -2.4,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              'Keep your introduction current, curate your strongest projects, and share the experience behind them.',
                              style: Design.bodyType,
                            ),
                            const SizedBox(height: 36),
                            const Divider(),
                            const SizedBox(height: 22),
                            const Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: [
                                StatusPill('Private drafts', active: false),
                                StatusPill('Real previews'),
                                StatusPill('Published content'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(child: login),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    ),
  );
}
