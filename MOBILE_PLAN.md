# Chae — Flutter Mobil Uygulama Planı

> Supabase JS SDK değil, **supabase_flutter** paketi kullanılacak.  
> Tüm örnekler Dart/Flutter'a göredir.

---

## Kurulum

```yaml
# pubspec.yaml
dependencies:
  supabase_flutter: ^2.x.x
  cached_network_image: ^3.x.x
  flutter_secure_storage: ^9.x.x
  go_router: ^14.x.x
```

```dart
// main.dart
await Supabase.initialize(
  url: 'https://xxxx.supabase.co',
  anonKey: 'your-anon-key',
);
```

```dart
// Global erişim
final supabase = Supabase.instance.client;
```

---

## 1. AUTH — Giriş / Kayıt / Çıkış

### 1.1 Email + Şifre ile Kayıt

```dart
final res = await supabase.auth.signUp(
  email: 'user@example.com',
  password: 'password123',
);
// Trigger otomatik profil oluşturur (handle_new_user)
final userId = res.user?.id;
```

### 1.2 Email + Şifre ile Giriş

```dart
final res = await supabase.auth.signInWithPassword(
  email: 'user@example.com',
  password: 'password123',
);
final session = res.session;   // accessToken, refreshToken
final user    = res.user;      // id, email
```

### 1.3 Çıkış

```dart
await supabase.auth.signOut();
```

### 1.4 Oturum Dinleme (stream)

```dart
supabase.auth.onAuthStateChange.listen((data) {
  final event   = data.event;   // AuthChangeEvent
  final session = data.session;

  switch (event) {
    case AuthChangeEvent.signedIn:  // yönlendir: home
    case AuthChangeEvent.signedOut: // yönlendir: login
    case AuthChangeEvent.tokenRefreshed: // session yenilendi
  }
});
```

### 1.5 Mevcut Kullanıcı

```dart
final user = supabase.auth.currentUser;
if (user == null) // giriş yapılmamış
```

### 1.6 Şifre Sıfırlama

```dart
await supabase.auth.resetPasswordForEmail('user@example.com');
```

---

## 2. PROFİL

### 2.1 Kendi profilini çek

```dart
final data = await supabase
    .from('profiles')
    .select('id, username, display_name, avatar_url, bio, role, coins')
    .eq('id', supabase.auth.currentUser!.id)
    .single();

// Model
class Profile {
  final String id, username;
  final String? displayName, avatarUrl, bio;
  final String role;   // user | premium | moderator | admin
  final int coins;
}
```

### 2.2 Profil güncelle

```dart
await supabase
    .from('profiles')
    .update({
      'display_name': 'Yeni İsim',
      'bio': 'Hakkımda...',
    })
    .eq('id', supabase.auth.currentUser!.id);
```

### 2.3 Avatar yükle (S3)

```dart
final bytes = await file.readAsBytes();
final path  = 'avatars/${supabase.auth.currentUser!.id}.jpg';

// Storage yerine doğrudan S3 presigned URL kullan
// Backend API: POST /api/upload { file, folder: 'avatars' }
// Response: { url: 'https://cdn.../avatars/xxx.jpg' }
// Sonra profiles.avatar_url güncelle
```

---

## 3. WEBTOONlar

### 3.1 Liste — Yayındaki webtoonlar

```dart
final data = await supabase
    .from('webtoons')
    .select('''
      id, title, slug, cover_url, status, type,
      avg_rating, rating_count, chapter_count,
      view_count, is_premium, release_day,
      author:authors!webtoons_author_id_fkey(name),
      webtoon_genres(genre:genres(id, name, color))
    ''')
    .eq('is_published', true)
    .order('updated_at', ascending: false)
    .range(0, 19);   // sayfalama: 0–19 = ilk 20
```

### 3.2 Öne çıkanlar

```dart
final data = await supabase
    .from('webtoons')
    .select('id, title, cover_url, banner_url, avg_rating, status, type')
    .eq('is_published', true)
    .eq('is_featured', true)
    .limit(10);
```

### 3.3 Türe göre filtrele

```dart
// Önce genre ID bul
final genre = await supabase
    .from('genres')
    .select('id')
    .eq('slug', 'action')
    .single();

// Sonra junction tablosu üzerinden filtrele
final data = await supabase
    .from('webtoons')
    .select('*, webtoon_genres!inner(genre_id)')
    .eq('is_published', true)
    .eq('webtoon_genres.genre_id', genre['id'])
    .order('view_count', ascending: false);
```

### 3.4 Arama

```dart
final data = await supabase
    .from('webtoons')
    .select('id, title, cover_url, status, type')
    .eq('is_published', true)
    .ilike('title', '%$query%')   // büyük/küçük harf duyarsız
    .limit(20);
```

### 3.5 Detay sayfası

```dart
final data = await supabase
    .from('webtoons')
    .select('''
      *,
      author:authors!webtoons_author_id_fkey(id, name, avatar_url),
      artist:authors!webtoons_artist_id_fkey(id, name),
      webtoon_genres(genre:genres(id, name, color))
    ''')
    .eq('slug', slug)
    .single();
```

### 3.6 Görüntülenme sayacı artır

```dart
await supabase.rpc('increment_view', params: {
  'table_name': 'webtoons',
  'row_id': webtoonId,
});
// Alternatif: doğrudan update
await supabase
    .from('webtoons')
    .update({'view_count': data['view_count'] + 1})
    .eq('id', webtoonId);
```

---

## 4. BÖLÜMLER

### 4.1 Webtoon'un bölüm listesi

```dart
final data = await supabase
    .from('chapters')
    .select('id, chapter_number, title, is_premium, is_published, '
            'view_count, like_count, comment_count, page_count, '
            'coin_cost, thumbnail_url, published_at')
    .eq('webtoon_id', webtoonId)
    .eq('is_published', true)
    .order('chapter_number', ascending: false);
```

### 4.2 Bölüm sayfaları (okuma ekranı)

```dart
// Önce erişim kontrolü
final chapter = await supabase
    .from('chapters')
    .select('id, is_premium, coin_cost, webtoon_id')
    .eq('id', chapterId)
    .single();

// Premium kontrolü
if (chapter['is_premium']) {
  final profile = await supabase
      .from('profiles')
      .select('role')
      .eq('id', currentUserId)
      .single();

  final hasAccess = ['premium', 'admin', 'moderator'].contains(profile['role']);
  if (!hasAccess) {
    // Kilit açık mı?
    final unlock = await supabase
        .from('chapter_unlocks')
        .select('id')
        .eq('user_id', currentUserId)
        .eq('chapter_id', chapterId)
        .maybeSingle();
    if (unlock == null) throw Exception('Bu bölüm premium');
  }
}

// Sayfaları getir
final pages = await supabase
    .from('chapter_pages')
    .select('id, page_number, image_url, width, height')
    .eq('chapter_id', chapterId)
    .order('page_number');
```

### 4.3 Okuma geçmişi kaydet / güncelle

```dart
await supabase
    .from('reading_history')
    .upsert({
      'user_id':    currentUserId,
      'webtoon_id': webtoonId,
      'chapter_id': chapterId,
      'last_page':  currentPage,
      'progress':   (currentPage / totalPages * 100).toStringAsFixed(1),
      'last_read_at': DateTime.now().toIso8601String(),
    },
    onConflict: 'user_id,chapter_id');
```

### 4.4 Premium bölüm coin ile aç

```dart
// 1) Coin yeterli mi kontrol et
final profile = await supabase
    .from('profiles')
    .select('coins')
    .eq('id', currentUserId)
    .single();

if (profile['coins'] < chapter['coin_cost']) {
  throw Exception('Yetersiz coin');
}

// 2) Unlock kaydı oluştur
await supabase.from('chapter_unlocks').insert({
  'user_id':    currentUserId,
  'chapter_id': chapterId,
  'coins_spent': chapter['coin_cost'],
});

// 3) Coin düş
await supabase.from('profiles').update({
  'coins': profile['coins'] - chapter['coin_cost'],
}).eq('id', currentUserId);

// 4) İşlem kaydı
await supabase.from('coin_transactions').insert({
  'user_id': currentUserId,
  'amount':  -chapter['coin_cost'],
  'balance': profile['coins'] - chapter['coin_cost'],
  'reason':  'chapter_unlock',
  'data':    {'chapter_id': chapterId},
});
```

---

## 5. FAVORİLER (Bookmark)

### 5.1 Favori mi kontrol et

```dart
final data = await supabase
    .from('favorites')
    .select('id')
    .eq('user_id', currentUserId)
    .eq('webtoon_id', webtoonId)
    .maybeSingle();

final isFavorite = data != null;
```

### 5.2 Favori ekle

```dart
await supabase.from('favorites').insert({
  'user_id':   currentUserId,
  'webtoon_id': webtoonId,
  'notify_new_chapter': true,
});
```

### 5.3 Favoriden çıkar

```dart
await supabase
    .from('favorites')
    .delete()
    .eq('user_id', currentUserId)
    .eq('webtoon_id', webtoonId);
```

### 5.4 Favori listesi

```dart
final data = await supabase
    .from('favorites')
    .select('''
      id, created_at, notify_new_chapter,
      webtoon:webtoons(id, title, cover_url, status, chapter_count, avg_rating)
    ''')
    .eq('user_id', currentUserId)
    .order('created_at', ascending: false);
```

---

## 6. PUANLAMA

### 6.1 Kullanıcının puanı

```dart
final data = await supabase
    .from('ratings')
    .select('score')
    .eq('user_id', currentUserId)
    .eq('webtoon_id', webtoonId)
    .maybeSingle();
// null ise henüz puan vermemiş
```

### 6.2 Puan ver / güncelle

```dart
await supabase.from('ratings').upsert({
  'user_id':    currentUserId,
  'webtoon_id': webtoonId,
  'score':      userScore,   // 1–10
}, onConflict: 'user_id,webtoon_id');
// Trigger otomatik avg_rating ve rating_count günceller
```

---

## 7. YORUMLAR

### 7.1 Webtoon yorumları (sayfalı)

```dart
final data = await supabase
    .from('comments')
    .select('''
      id, content, is_spoiler, is_pinned,
      like_count, reply_count, created_at,
      user:profiles!comments_user_id_fkey(username, display_name, avatar_url)
    ''')
    .eq('webtoon_id', webtoonId)
    .eq('is_deleted', false)
    .isFilter('parent_id', null)    // sadece ana yorumlar
    .order('is_pinned', ascending: false)
    .order('created_at', ascending: false)
    .range(page * 20, page * 20 + 19);
```

### 7.2 Yorum yanıtları

```dart
final replies = await supabase
    .from('comments')
    .select('''
      id, content, is_spoiler, like_count, created_at,
      user:profiles!comments_user_id_fkey(username, display_name, avatar_url)
    ''')
    .eq('parent_id', commentId)
    .eq('is_deleted', false)
    .order('created_at');
```

### 7.3 Yorum yaz

```dart
await supabase.from('comments').insert({
  'user_id':    currentUserId,
  'webtoon_id': webtoonId,
  'content':    content,
  'is_spoiler': isSpoiler,
  'parent_id':  parentId,    // null ise ana yorum, dolu ise yanıt
});
```

### 7.4 Bölüm yorumları

```dart
// Aynı yapı, 'comments' yerine 'chapter_comments' tablosu
// ve 'webtoon_id' yerine 'chapter_id' kullan
final data = await supabase
    .from('chapter_comments')
    .select('''
      id, content, is_spoiler, like_count, reply_count, created_at,
      user:profiles!chapter_comments_user_id_fkey(username, display_name, avatar_url)
    ''')
    .eq('chapter_id', chapterId)
    .eq('is_deleted', false)
    .isFilter('parent_id', null)
    .order('created_at', ascending: false)
    .range(page * 20, page * 20 + 19);
```

### 7.5 Yorum like / unlike

```dart
// Like ekle
await supabase.from('comment_likes').insert({
  'user_id':    currentUserId,
  'comment_id': commentId,
});
// Trigger: comments.like_count otomatik artar

// Unlike
await supabase
    .from('comment_likes')
    .delete()
    .eq('user_id', currentUserId)
    .eq('comment_id', commentId);
```

### 7.6 Bölüm yorum like'ı

```dart
// 'chapter_comment_likes' tablosu, 'chapter_comment_id' field
await supabase.from('chapter_comment_likes').insert({
  'user_id':              currentUserId,
  'chapter_comment_id':   commentId,
});
```

### 7.7 Yorum sil (soft delete)

```dart
await supabase
    .from('comments')
    .update({
      'is_deleted': true,
      'deleted_at': DateTime.now().toIso8601String(),
    })
    .eq('id', commentId)
    .eq('user_id', currentUserId);  // sadece kendi yorumu
```

### 7.8 Yorum şikayet et

```dart
await supabase.from('reports').insert({
  'reporter_id': currentUserId,
  'reason':      'inappropriate',  // spam | inappropriate | spoiler | harassment | other
  'description': 'Açıklama...',
  'comment_id':  commentId,         // veya chapter_comment_id veya webtoon_id
});
```

---

## 8. BÖLÜM LIKE

```dart
// Like
await supabase.from('chapter_likes').insert({
  'user_id':    currentUserId,
  'chapter_id': chapterId,
});

// Unlike
await supabase
    .from('chapter_likes')
    .delete()
    .eq('user_id', currentUserId)
    .eq('chapter_id', chapterId);

// Like var mı?
final liked = await supabase
    .from('chapter_likes')
    .select('id')
    .eq('user_id', currentUserId)
    .eq('chapter_id', chapterId)
    .maybeSingle();
```

---

## 9. BİLDİRİMLER

### 9.1 Okunmamış bildirim sayısı

```dart
final data = await supabase
    .from('notifications')
    .select('id', const FetchOptions(count: CountOption.exact))
    .eq('user_id', currentUserId)
    .eq('is_read', false);

final count = data.count;
```

### 9.2 Bildirim listesi

```dart
final data = await supabase
    .from('notifications')
    .select('id, type, title, message, data, is_read, created_at')
    .eq('user_id', currentUserId)
    .order('created_at', ascending: false)
    .limit(50);
```

### 9.3 Bildirimi okundu yap

```dart
await supabase
    .from('notifications')
    .update({'is_read': true})
    .eq('id', notificationId)
    .eq('user_id', currentUserId);
// Trigger: read_at otomatik set edilir

// Tümünü okundu yap
await supabase
    .from('notifications')
    .update({'is_read': true})
    .eq('user_id', currentUserId)
    .eq('is_read', false);
```

---

## 10. ABONELIK

### 10.1 Aktif abonelik var mı?

```dart
final data = await supabase
    .from('subscriptions')
    .select('id, plan, status, expires_at')
    .eq('user_id', currentUserId)
    .eq('status', 'active')
    .gte('expires_at', DateTime.now().toIso8601String())
    .maybeSingle();

final isPremium = data != null;
```

---

## 11. GERÇEK ZAMANLI (Realtime)

### 11.1 Yeni bölüm bildirimi (tüm kullanıcılar)

```dart
final channel = supabase
    .channel('public:chapters')
    .onPostgresChanges(
      event: PostgresChangeEvent.insert,
      schema: 'public',
      table: 'chapters',
      filter: PostgresChangeFilter(
        type: FilterType.eq,
        column: 'webtoon_id',
        value: webtoonId,
      ),
      callback: (payload) {
        // Yeni bölüm eklendi, listeyi yenile
        refreshChapters();
      },
    )
    .subscribe();

// Temizle
await supabase.removeChannel(channel);
```

### 11.2 Canlı yorum stream'i

```dart
final channel = supabase
    .channel('comments:$webtoonId')
    .onPostgresChanges(
      event: PostgresChangeEvent.insert,
      schema: 'public',
      table: 'comments',
      filter: PostgresChangeFilter(
        type: FilterType.eq,
        column: 'webtoon_id',
        value: webtoonId,
      ),
      callback: (payload) {
        final newComment = payload.newRecord;
        addCommentToList(newComment);
      },
    )
    .subscribe();
```

---

## 12. HATA YÖNETİMİ

```dart
try {
  final data = await supabase.from('webtoons').select().single();
} on PostgrestException catch (e) {
  switch (e.code) {
    case 'PGRST116': // single() ama kayıt yok
      throw NotFoundException('Webtoon bulunamadı');
    case '42501':    // RLS: yetki yok
      throw UnauthorizedException('Bu içeriğe erişim yetkiniz yok');
    case '23505':    // unique constraint (zaten favori eklenmiş gibi)
      throw AlreadyExistsException('Zaten ekli');
    default:
      throw ServerException(e.message);
  }
} on AuthException catch (e) {
  throw UnauthorizedException(e.message);
}
```

---

## 13. SAYFALAMA PAKETİ — Cursor Tabanlı

```dart
// İlk sayfa
List<Map<String, dynamic>> items = await supabase
    .from('webtoons')
    .select('id, title, cover_url, updated_at')
    .eq('is_published', true)
    .order('updated_at', ascending: false)
    .limit(20);

// Sonraki sayfa (cursor: son elemanın updated_at'i)
final lastItem   = items.last;
final nextPage   = await supabase
    .from('webtoons')
    .select('id, title, cover_url, updated_at')
    .eq('is_published', true)
    .lt('updated_at', lastItem['updated_at'])  // cursor
    .order('updated_at', ascending: false)
    .limit(20);
```

---

## 14. OKUMA EKRANI MİMARİSİ

```
WebtoonType  │  Görünüm              │  Flutter Widget
─────────────┼───────────────────────┼───────────────────────────
webtoon      │  Dikey scroll         │  ListView.builder (lazy)
manhwa       │  Dikey scroll         │  ListView.builder (lazy)
manga        │  Yatay kitap          │  PageView (RTL)
manhua       │  Dikey scroll         │  ListView.builder
```

```dart
// Webtoon okuyucu
ListView.builder(
  itemCount: pages.length,
  itemBuilder: (ctx, i) => CachedNetworkImage(
    imageUrl: pages[i]['image_url'],
    fit: BoxFit.fitWidth,
    placeholder: (ctx, url) => AspectRatio(
      aspectRatio: 3 / 4,
      child: Container(color: Colors.grey[900]),
    ),
  ),
)

// Manga okuyucu (RTL)
PageView.builder(
  reverse: true,   // sağdan sola
  itemCount: (pages.length / 2).ceil(),
  itemBuilder: (ctx, spreadIndex) {
    final right = pages[spreadIndex * 2];
    final left  = spreadIndex * 2 + 1 < pages.length
        ? pages[spreadIndex * 2 + 1] : null;
    return Row(children: [
      Expanded(child: CachedNetworkImage(imageUrl: right['image_url'])),
      if (left != null)
        Expanded(child: CachedNetworkImage(imageUrl: left['image_url'])),
    ]);
  },
)
```

---

## 15. EKRAN AKIŞI

```
Splash
  └─► Auth kontrol
        ├─► Giriş yok  ──► Login / Register
        └─► Giriş var  ──► Home

Home
  ├─ Öne çıkanlar (featured webtoons)
  ├─ Devam ediyor (favorites + son okunan bölüm)
  ├─ Yeni bölümler
  └─ Keşfet (tür filtresi)

Webtoon Detay
  ├─ Bölüm listesi
  ├─ Yorumlar (tab)
  ├─ Puan ver
  └─ Favori ekle/çıkar

Okuma Ekranı (webtoon/manga)
  ├─ Sayfa yükleme
  ├─ Geçmiş kaydet
  └─ Bölüm yorumları

Profil
  ├─ Favoriler
  ├─ Okuma geçmişi
  ├─ Bildirimler
  └─ Abonelik
```

---

## 16. ENVIRONMENT

```dart
// lib/config/env.dart
class Env {
  static const supabaseUrl    = String.fromEnvironment('SUPABASE_URL');
  static const supabaseAnon   = String.fromEnvironment('SUPABASE_ANON_KEY');
  static const cdnBase        = String.fromEnvironment('CDN_BASE_URL');
}

// Çalıştırma
// flutter run --dart-define=SUPABASE_URL=https://xxx.supabase.co \
//             --dart-define=SUPABASE_ANON_KEY=xxx \
//             --dart-define=CDN_BASE_URL=https://cdn.chae.app
```

---

*Son güncelleme: 2026-05-05*
