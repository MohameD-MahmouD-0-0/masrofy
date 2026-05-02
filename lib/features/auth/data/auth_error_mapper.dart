import 'package:firebase_auth/firebase_auth.dart';

String authErrorMessage(Object error) {
  if (error is! FirebaseAuthException) {
    return 'Something went wrong. Please try again.';
  }

  switch (error.code) {
    case 'user-not-found':
      return 'No account was found for this email.';
    case 'wrong-password':
    case 'invalid-credential':
      return 'The email or password is incorrect.';
    case 'invalid-email':
      return 'Please enter a valid email address.';
    case 'email-already-in-use':
      return 'This email is already registered.';
    case 'weak-password':
      return 'Please use a stronger password.';
    case 'network-request-failed':
      return 'Network error. Check your connection and try again.';
    default:
      return error.message ?? 'Authentication failed. Please try again.';
  }
}
