class AppConstants {
  static String appName = 'Conecta Quindío';
  static String baseCurrency = '';
  static String baseCurrencySymbol = '';
  static String adUnitId = '';
  static String adMobAppId = '';
  static bool isAdAvailable = true;
  static bool isPlanAvailable = true;

  static const String token = '';
  static const String googleMapApikey =
      'AIzaSyBY5fqHDVdAiWD6dLVGDLiaW1iqo_WV2qA';

  // Base URL
  static const String baseUri = 'https://conect-quin-ia.igni-soft.com/api/';

  // End Point
  static const String onboardingUri = 'app/steps';
  static const String registerUri = 'register';
  static const String loginUri = 'login';
  static const String socialLoginUri = 'social-login';

  static const String getCodeUri = 'recovery-pass/get-email';
  static const String codeValidationUri = 'recovery-pass/get-code';
  static const String resetPasswordUri = 'update-pass';

  static const String twoFaUri = '2FA-security';
  static const String enableTwoFaUri = '2FA-security/enable';
  static const String disableTwoFaUri = '2FA-security/disable';

  static const String twoFaVerifyUri = 'twoFA-Verify';
  static const String emailVerifyUri = 'mail-verify';
  static const String smsVerifyUri = 'sms-verify';
  static const String resendCodeUri = 'resend-code';

  static const String profileInfoUri = 'profile';
  static const String profileUpdateUri = 'profile/update';
  static const String passwordUpdateUri = 'password/update';
  static const String deleteAccountUri = 'user/account/delete';

  static const String kycUri = 'get-kyc/setting';
  static const String kycSubmissionUri = 'kyc-submit';
  static const String kycListUri = 'kyc-submit/list';

  static const String ticketListUri = 'support-ticket/list';
  static const String createTicketUri = 'support-ticket/create';
  static const String ticketViewUri = 'support-ticket/view';
  static const String ticketReplyUri = 'support-ticket/reply';

  static const String travelCompanionUri = 'get/travel-partner';
  static const String tripBudgetUri = 'get/trip-budget';
  static const String travelPreferencesUri = 'get/travel-preferences';
  static const String createItineraryUri = 'trip-explore';
  static const String saveItineraryUri = 'trip-explore/save';
  static const String itineraryExploreUri = 'explore-list';
  static const String upcomingItineraryExploreUri = 'upcoming/explore-list';

  static const String chatTitleUri = 'title/list';
  static const String deleteMessageUri = 'title/delete';
  static const String editTitleUri = 'title/update';
  static const String sendMessageUri = 'send-assistant/message';
  static const String messageDetailsUri = 'chat/details';

  static const String prepaidPlanUri = 'prepaid/plan';
  static const String subscriptionPlanUri = 'subscription/plan';

  static const String paymentGatewayUri = 'get/gateways';
  static const String freePlanUri = 'free-plan';
  static const String prepaidPaymentUri = 'prepaid/payment';
  static const String subscriptionPaymentUri = 'subscription/payment';
  static const String paymentDoneUri = 'payment-done';
  static const String manualPaymentUri = 'manual-payment';
  static const String cardPaymentUri = 'card-payment';
  static const String otherPaymentUri = 'show-other-payment';

  static const String getManualPaymentUri = 'manual-payment/request';
  static const String subscriptionListUri = 'subscription/list';
  static const String cancelSubscriptionUri = 'subscription/cancel';
  static const String renewSubscriptionUri = 'subscription/renew';

  static const String createArticleUri = 'article-create';
  static const String updateArticleUri = 'article-update';
  static const String articleListUri = 'article-list';
  static const String popularDestinationUri = 'popular-destination';

  static const String socialLiteUri = 'socialite-config';
  static const String userInfoUri = 'user/info';
  static const String languageUri = 'language';
  static const String appConfigUri = 'app/settings';

  static void updateConstantsFromApi(Map<String, dynamic> apiData) {
    if (apiData.containsKey("siteTitle") &&
        apiData.containsKey("primaryColor")) {
      appName = apiData["siteTitle"];
    }
  }
}
