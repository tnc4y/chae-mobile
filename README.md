# chae_mobile

Chae mobil uygulamasi (Flutter).

## RevenueCat Kurulumu

Uygulamada RevenueCat SDK entegrasyonu vardir. Premium satin alma ve restore akislari profil ekraninda bulunur.

Gerekli `dart-define` degerleri:

- `REVENUECAT_API_KEY` (test icin tek key kullanmak istersen)
- `REVENUECAT_ANDROID_API_KEY` (opsiyonel, platform bazli)
- `REVENUECAT_IOS_API_KEY` (opsiyonel, platform bazli)
- `REVENUECAT_PREMIUM_ENTITLEMENT_ID` (varsayilan: `premium`)

Ornek calistirma:

```bash
flutter run \
	--dart-define=REVENUECAT_API_KEY=rcb_xxx \
	--dart-define=REVENUECAT_PREMIUM_ENTITLEMENT_ID=premium
```

