import 'dart:async';
import 'package:core/core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Form(
              key: form,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const PortfolioBrand(),
                  const SizedBox(height: 48),
                  const Eyebrow('Portfolio Studio'),
                  const SizedBox(height: 12),
                  const Text(
                    'Welcome back.',
                    style: TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Sign in to maintain your work and the story around it.',
                    style: TextStyle(color: Design.muted, height: 1.7),
                  ),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: email,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [
                      AutofillHints.username,
                      AutofillHints.email,
                    ],
                    decoration: const InputDecoration(labelText: 'Email'),
                    validator: (v) => v != null && v.contains('@')
                        ? null
                        : 'Enter your email address.',
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: password,
                    obscureText: obscure,
                    autofillHints: const [AutofillHints.password],
                    onFieldSubmitted: (_) => signIn(),
                    decoration: InputDecoration(
                      labelText: 'Password',
                      suffixIcon: IconButton(
                        tooltip: obscure ? 'Show password' : 'Hide password',
                        onPressed: () => setState(() => obscure = !obscure),
                        icon: Icon(
                          obscure
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                      ),
                    ),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Enter your password.' : null,
                  ),
                  const SizedBox(height: 20),
                  if (error != null)
                    Semantics(
                      liveRegion: true,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text(
                          error!,
                          style: const TextStyle(color: Design.error),
                        ),
                      ),
                    ),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
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
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
