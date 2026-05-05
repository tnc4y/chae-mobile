class Env {
  static const supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://tlkcgilleixktrelhsba.supabase.co',
  );
  static const supabaseAnon = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRsa2NnaWxsZWl4a3RyZWxoc2JhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzc4OTg2MTgsImV4cCI6MjA5MzQ3NDYxOH0.3T31V0vT9gYKFSPl9LQysF_ldH86tZhOmej1ZEmlpSk',
  );
  static const cdnBase = String.fromEnvironment(
    'CDN_BASE_URL',
    defaultValue: 'https://chae-webtoon.s3.eu-north-1.amazonaws.com',
  );

  static const revenueCatApiKey = String.fromEnvironment(
    'REVENUECAT_API_KEY',
    defaultValue: 'test_OSjnJHreTtYohVagZtgitYxtZIU',
  );

  static const revenueCatAndroidApiKey = String.fromEnvironment(
    'REVENUECAT_ANDROID_API_KEY',
    defaultValue: '',
  );

  static const revenueCatIosApiKey = String.fromEnvironment(
    'REVENUECAT_IOS_API_KEY',
    defaultValue: '',
  );

  static const revenueCatPremiumEntitlementId = String.fromEnvironment(
    'REVENUECAT_PREMIUM_ENTITLEMENT_ID',
    defaultValue: 'premium',
  );
}
