/// Defines the error codes that identify a exception returned by Firebase
/// Authentication.
class AuthErrorCode {
  /// This class is not meant to be instantiated or extended.
  /// This constructor prevents instantiation and extension.
  const AuthErrorCode._();

  /// The exception is unknown.
  static const String unknown = 'unknown';

  /// The account already exists with the email address asserted by the
  /// credential.
  static const String accountExistsWithDifferentCredential = 'account-exists-with-different-credential';

  /// The reCAPTCHA response token was invalid, expired, or if the captcha
  /// method was called from a non-whitelisted domain.
  static const String captchaCheckFailed = 'captcha-check-failed';

  /// The account corresponding to the credential already exists, or is already
  /// linked to a Firebase User.
  static const String credentialAlreadyInUse = 'credential-already-in-use';

  /// The email corresponding to the credential already exists.
  static const String emailAlreadyInUse = 'email-already-in-use';

  /// The credential is malformed or has expired.
  static const String invalidCredential = 'invalid-credential';

  /// The email address is not valid.
  static const String invalidEmail = 'invalid-email';

  /// The phone number has an invalid format.
  static const String invalidPhoneNumber = 'invalid-phone-number';

  /// The verification code of the credential is not valid.
  static const String invalidVerificationCode = 'invalid-verification-code';

  /// The verification id of the credential is not valid.
  static const String invalidVerificationId = 'invalid-verification-id';

  /// No user currently signed in.
  static const String noCurrentUser = 'no-current-user';

  /// The user does not have this provider linked or the provider ID given
  /// does not exist.
  static const String noSuchProvider = 'no-such-provider';

  /// The provider is not not enabled in the Firebase Console.
  static const String operationNotAllowed = 'operation-not-allowed';

  /// The provider has already been linked to the user. Even if this is not the
  /// same provider's account that is currently linked to the user.
  static const String providerAlreadyLinked = 'provider-already-linked';

  /// The SMS quota for the Firebase project has been exceeded.
  static const String quotaExceeded = 'quota-exceeded';

  /// The user's last sign-in time does not meet the security threshold.
  static const String requiresRecentLogin = 'requires-recent-login';

  /// The user has been disabled.
  static const String userDisabled = 'user-disabled';

  /// The credentials given does not correspond to the user.
  static const String userMismatch = 'user-mismatch';

  /// No user record found for the given identifier.
  static const String userNotFound = 'user-not-found';

  /// The password is not strong enough.
  static const String weakPassword = 'weak-password';

  /// The password is not correct or when the user associated with the email
  /// does not have a password.
  static const String wrongPassword = 'wrong-password';
}
