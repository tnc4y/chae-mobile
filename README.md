# Chae Mobile

Chae'nin Flutter ile yazilmis mobil uygulamasi.

## Ozet

- Backend olarak Supabase kullanir.
- Kullanicinin profili, favorileri, yorumlari ve bildirimleri Supabase'ten gelir.
- Yeni bolum bildirimleri uygulama ici bildirim olarak `notifications` tablosuna yazilir.
- Premium satin alma akisi RevenueCat ile calisir.

## Gereksinimler

- Flutter 3.6+
- Supabase projesi
- RevenueCat test API key

## Calistirma

```bash
flutter pub get
flutter run --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=... --dart-define=REVENUECAT_API_KEY=rcb_xxx
```

## RevenueCat

Uygulama test modunda tek bir RevenueCat API key ile calisir.

Gerekli `dart-define` degerleri:

- `REVENUECAT_API_KEY` (test icin tek key)
- `REVENUECAT_PREMIUM_ENTITLEMENT_ID` (varsayilan: `premium`)

Opsiyonel platform anahtarlari da desteklenir:

- `REVENUECAT_ANDROID_API_KEY`
- `REVENUECAT_IOS_API_KEY`

Premium akislar:

- Profil ekraninda satin alma
- Satin alimi geri yukleme
- RevenueCat entitlement kontrolu

## Bildirimler

Yeni bolumler favorilerde `notify_new_chapter = true` olan kullanicilar icin `notifications` tablosuna eklenir.

Bu bildirimler uygulama ici Bildirimler ekraninda gorunur.

## Notlar

- Firebase push altyapisi bu projede kullanilmiyor.
- `README` sadece mevcut Supabase tabanli akisi anlatir.

