# iRent - Dokumentasi Project

## Tentang Project

**iRent** adalah aplikasi mobile berbasis Flutter untuk sistem penyewaan iPhone dengan manajemen lengkap. Aplikasi ini dikembangkan untuk tugas kuliah (bukan untuk keperluan komersial) dengan backend API yang terhubung ke `https://backend.nekoyama.my.id`.

**Versi:** 0.8.5-beta+1

**Target Pengguna:**
- **User Biasa** - Dapat menyewa iPhone, melihat katalog produk, membuat order, dan memberikan testimoni
- **Admin** - Mengelola user, data iPhone, rental aktif, dan pesanan

---

## Teknologi Stack

### Framework & Language
- **Flutter** (SDK ^3.10.3)
- **Dart**

### State Management
- **flutter_riverpod** ^2.6.1 - Reactive state management

### HTTP & Networking
- **dio** ^5.7.0 - HTTP client
- **pretty_dio_logger** ^1.4.0 - Logger untuk debugging API
- **http** ^1.1.0 - HTTP requests

### Local Storage
- **shared_preferences** ^2.3.3 - Penyimpanan data lokal (token, user info)

### UI Components & Styling
- **cached_network_image** ^3.4.1 - Caching gambar dari network
- **carousel_slider** ^5.0.0 - Image carousel/slider
- **shimmer** ^3.0.0 - Loading skeleton effect
- **fluttertoast** ^9.0.0 - Toast notifications
- **google_fonts** ^6.2.1 - Custom fonts

### Forms & Utilities
- **intl** ^0.19.0 - Internationalization & date formatting
- **image_picker** ^1.1.2 - Pick image dari galeri/kamera
- **package_info_plus** ^8.0.0 - Info aplikasi (versi, build number)
- **version** ^3.0.0 - Version comparison

### File Operations
- **path_provider** ^2.1.0 - Akses direktori sistem
- **flutter_downloader** ^1.11.0 - Download file manager
- **open_file** ^3.3.0 - Buka/install file
- **url_launcher** ^6.1.0 - Buka URL/link eksternal

---

## Struktur Project

```
lib/
├── config/              # Konfigurasi aplikasi
├── models/              # Model data (class blueprint)
├── providers/           # State management (Riverpod)
├── screens/             # Halaman UI aplikasi
│   ├── admin/          # Panel admin
│   ├── auth/           # Autentikasi & verifikasi
│   ├── home/           # Halaman utama
│   ├── order/          # Pemesanan rental
│   ├── product/        # Katalog produk iPhone
│   ├── profile/        # Profil user
│   ├── rental/         # Rental aktif
│   ├── testimonial/    # Testimoni pelanggan
│   └── updater/        # Auto update aplikasi
├── services/            # Layanan backend & utility
├── theme/               # Tema & styling
├── widgets/             # Komponen UI reusable
└── main.dart            # Entry point aplikasi
```

---

## Detail Struktur Folder `lib/`

### 1. `config/` - Konfigurasi Aplikasi

**File:**
- `api_config.dart` - Konfigurasi endpoint API

**Isi `api_config.dart`:**
Berisi konstanta untuk base URL dan semua endpoint API seperti:
- Auth: `/api/auth/register`, `/api/auth/login`, `/api/auth/logout`
- User: `/api/user/profile`, `/api/user/update`
- iPhone: `/api/iphone`, `/api/iphone/{id}`
- Order: `/api/order`, `/api/order/user`, `/api/order/track/{code}`
- Rental: `/api/rental/user`
- Testimonial: `/api/testimonial`
- Admin: `/api/admin/user`, `/api/admin/iphone`, dll

**Digunakan oleh:** Semua service yang berkomunikasi dengan backend API

---

### 2. `models/` - Model Data

**File:**
- `user_model.dart` - Model data user
- `iphone_model.dart` - Model data iPhone
- `order_model.dart` - Model pesanan rental
- `rental_model.dart` - Model rental aktif
- `testimonial_model.dart` - Model testimoni
- `overdue_model.dart` - Model keterlambatan
- `overdue_rental_model.dart` - Model rental yang terlambat

**Fungsi:**
Model class untuk parsing JSON dari API dan menyediakan struktur data yang type-safe. Setiap model memiliki:
- Property sesuai response API
- Factory method `fromJson()` untuk parsing JSON
- Method `toJson()` untuk serialisasi (jika diperlukan)

**Contoh `user_model.dart`:**
```dart
class UserModel {
  final int id;
  final String name;
  final String username;
  final String? email;
  final String phone;
  final String nik;
  final String role;
  final String status;
  final double penalty;
  // ... properties lainnya
}
```

**Digunakan oleh:** Provider dan Screen untuk type-safe data handling

---

### 3. `providers/` - State Management (Riverpod)

**File:**
- `auth_provider.dart` - Autentikasi & session management
- `iphone_provider.dart` - Data iPhone & katalog
- `order_provider.dart` - Pemesanan rental
- `rental_provider.dart` - Rental aktif user
- `testimonial_provider.dart` - Testimoni pelanggan
- `admin_provider.dart` - CRUD operations untuk admin

**Fungsi:**
Provider menggunakan Riverpod untuk reactive state management. Berisi business logic dan komunikasi dengan API.

**Detail Provider:**

#### `auth_provider.dart`
- **State:** `AuthState` (isLoading, isAuthenticated, user, error)
- **Methods:**
  - `checkAuth()` - Cek status autentikasi saat app start
  - `register()` - Registrasi user baru
  - `login()` - Login & simpan token
  - `logout()` - Logout & clear data
  - `getProfile()` - Ambil data profil user
  - `updateProfile()` - Update data profil
  - `changePassword()` - Ganti password

#### `iphone_provider.dart`
- Fetch daftar iPhone tersedia
- Fetch detail iPhone by ID
- Filter & search iPhone

#### `order_provider.dart`
- Buat order baru
- Ambil riwayat order user
- Track order by code
- Upload bukti transfer

#### `rental_provider.dart`
- Ambil daftar rental aktif user
- Detail rental
- Status rental

#### `testimonial_provider.dart`
- Ambil daftar testimoni
- Submit testimoni baru

#### `admin_provider.dart`
- CRUD users (admin panel)
- CRUD iPhone (admin panel)
- Kelola orders & rentals
- Soft delete users

**Digunakan oleh:** Screens untuk mendapatkan data dan melakukan aksi

---

### 4. `screens/` - Halaman UI

#### `screens/auth/` - Autentikasi
- `login_screen.dart` - Form login (username + password)
- `register_screen.dart` - Form registrasi user baru
- `verification_screen.dart` - Verifikasi nomor HP via OTP
- `forgot_password_screen.dart` - Reset password yang lupa

**Alur:**
1. User baru → Register → Verifikasi HP → Login
2. User lama → Login langsung

#### `screens/home/` - Halaman Utama
- Home screen dengan bottom navigation
- Tab: Home, Orders, Rentals, Profile
- Custom drawer untuk navigasi

#### `screens/product/` - Katalog iPhone
- Daftar iPhone tersedia untuk disewa
- Detail spesifikasi iPhone
- Harga sewa per hari
- Fitur search & filter

#### `screens/order/` - Pemesanan
- Form order baru (pilih durasi, tanggal)
- Riwayat order user
- Upload bukti transfer
- Track order by code

#### `screens/rental/` - Rental Aktif
- Daftar rental yang sedang berjalan
- Detail rental (tanggal sewa, deadline, dll)
- Status rental (active, completed, overdue)

#### `screens/profile/` - Profil User
- Lihat & edit profil
- Lihat penalty/denda
- Change password
- Upload foto profil

#### `screens/testimonial/` - Testimoni
- Lihat testimoni dari user lain
- Submit testimoni setelah rental selesai
- Rating & review

#### `screens/admin/` - Panel Admin
- `admin_dashboard_screen.dart` - Dashboard overview (statistik, grafik)
- `manage_users_screen.dart` - Kelola user (view, edit, soft delete)
- `manage_iphones_screen.dart` - Kelola data iPhone (CRUD)
- `manage_orders_screen.dart` - Approve/reject order, lihat semua order
- `manage_rentals_screen.dart` - Kelola rental aktif, extend rental, dll

**Akses:** Hanya user dengan role 'admin'

#### `screens/updater/` - Auto Update
- Cek update dari GitHub releases
- Download APK terbaru
- Install update otomatis
- Release notes

---

### 5. `services/` - Layanan Backend

#### `api_service.dart` - HTTP Client Service
**Fungsi:**
- Setup Dio dengan base URL dan timeout
- Interceptor untuk menambahkan Authorization header (Bearer token) ke setiap request
- Interceptor untuk handle error 401 (Unauthorized) → auto logout
- Logger untuk debugging API calls
- Wrapper methods: `get()`, `post()`, `put()`, `delete()`
- Error handling & parsing

**Flow:**
1. Provider call API method
2. ApiService check token dari StorageService
3. Add token ke header: `Authorization: Bearer {token}`
4. Send request
5. Jika response 401 → clear token & redirect login

#### `storage_service.dart` - Local Storage Service
**Fungsi:**
Menyimpan data penting secara lokal menggunakan SharedPreferences

**Data yang disimpan:**
- `auth_token` - JWT token autentikasi
- `user_id` - ID user yang login
- `user_role` - Role user (user/admin)
- `username` - Username

**Methods:**
- `saveToken(String token)` - Simpan auth token
- `getToken()` - Ambil auth token
- `saveUserId(int userId)` - Simpan user ID
- `getUserId()` - Ambil user ID
- `saveUserRole(String role)` - Simpan role
- `getUserRole()` - Ambil role
- `saveUsername(String username)` - Simpan username
- `getUsername()` - Ambil username
- `clearAll()` - Hapus semua data (saat logout)
- `isLoggedIn()` - Cek apakah ada token tersimpan

#### `update_service.dart` - Auto Update Service
**Fungsi:**
- Cek versi terbaru dari GitHub API
- Compare dengan versi aplikasi saat ini
- Download APK dari GitHub releases
- Parse release notes
- Trigger install APK

**Flow:**
1. Splash screen → cek update
2. Jika ada update → tampilkan dialog
3. User klik download → download APK
4. Selesai download → install otomatis

---

### 6. `theme/` - Tema & Styling

**File:**
- `colors.dart` - Palet warna aplikasi
- `text_styles.dart` - Style text (font size, weight, dll)
- `theme.dart` - ThemeData utama (lightTheme, darkTheme)

**Fungsi:**
Centralized styling untuk konsistensi UI di seluruh aplikasi. Menggunakan Google Fonts untuk typography.

**Digunakan oleh:** Semua widget & screen untuk styling konsisten

---

### 7. `widgets/` - Komponen UI Reusable

**Struktur:**
- `widgets/auth/` - Form components untuk login/register
- `widgets/home/` - Custom drawer, app bar, cards
- `widgets/product/` - Product card, filter chips
- `widgets/order/` - Order card, status badge
- `widgets/rental/` - Rental card, status indicator
- `widgets/common/` - Generic widgets (buttons, inputs, loading, error states)

**Keuntungan:**
- DRY (Don't Repeat Yourself)
- Konsistensi UI
- Mudah maintenance
- Reusable across screens

---

### 8. `main.dart` - Entry Point

**Fungsi:**
- Inisialisasi FlutterDownloader
- Inisialisasi date formatting (locale Indonesia)
- Setup ProviderScope untuk Riverpod
- Define routing/navigation
- Splash screen logic

**Routes:**
- `/` - Splash screen (cek login + update)
- `/login` - Login screen
- `/verify-phone` - Verifikasi OTP
- `/home` - Home screen
- `/update` - Update screen

**Splash Screen Logic:**
1. Cek update dari GitHub
2. Cek autentikasi via AuthProvider
3. Jika ada update → navigate to UpdateScreen
4. Jika sudah login → navigate to HomeScreen
5. Jika belum login → navigate to LoginScreen

---

## Alur Kerja Aplikasi

### 1. Startup Flow
```
App Launch
  → main.dart
  → SplashScreen
  → Check for updates (GitHub API)
  → AuthProvider.checkAuth()
  → StorageService.isLoggedIn()
  → If logged in: HomeScreen
  → If not: LoginScreen
```

### 2. Authentication Flow
```
Login
  → Input username & password
  → AuthProvider.login()
  → ApiService.post('/api/auth/login')
  → Response: { token, user }
  → StorageService.saveToken(token)
  → StorageService.saveUserId(user.id)
  → StorageService.saveUserRole(user.role)
  → Navigate to HomeScreen
```

### 3. API Request Flow
```
Screen calls Provider method
  → Provider calls ApiService
  → ApiService checks token (StorageService.getToken())
  → Add Authorization header
  → Send HTTP request
  → Parse response
  → Update Provider state
  → UI auto-updates (Riverpod reactive)
```

### 4. Order Flow (User)
```
User browses iPhones
  → Select iPhone
  → Click "Sewa"
  → Fill order form (duration, dates)
  → Submit order
  → OrderProvider.createOrder()
  → Upload bukti transfer
  → Wait admin approval
  → Track order status
```

### 5. Admin Approval Flow
```
Admin login
  → Navigate to Manage Orders
  → View pending orders
  → Check payment proof
  → Approve/Reject order
  → AdminProvider.updateOrderStatus()
  → Notification to user
  → If approved: Create rental record
```

### 6. Logout Flow
```
User clicks Logout
  → AuthProvider.logout()
  → ApiService.post('/api/auth/logout')
  → StorageService.clearAll()
  → Clear all local data
  → Navigate to LoginScreen
```

---

## Autentikasi & Keamanan

### Token Management
- **Type:** JWT (JSON Web Token)
- **Storage:** SharedPreferences (local device)
- **Header:** `Authorization: Bearer {token}`
- **Lifetime:** Server-defined (biasanya 24 jam - 7 hari)

### Security Features
1. **Token expiry handling** - Auto logout jika token expired (401 response)
2. **Secure storage** - Token disimpan di local storage (tidak di memory)
3. **Role-based access** - Admin panel hanya bisa diakses user dengan role 'admin'
4. **Password validation** - Minimum length, complexity (di form)
5. **Phone verification** - OTP via SMS untuk verifikasi nomor HP

### Protected Routes
- Home, Order, Rental, Profile → Requires login
- Admin panel → Requires role='admin'
- Login, Register → Public access

---

## API Integration

### Base URL
```
https://backend.nekoyama.my.id
```

### Authentication Endpoints
- `POST /api/auth/register` - Registrasi user baru
- `POST /api/auth/login` - Login
- `POST /api/auth/logout` - Logout
- `POST /api/auth/send-verification-code` - Kirim OTP
- `POST /api/auth/verify-code` - Verifikasi OTP
- `POST /api/auth/forgot-password` - Request reset password
- `POST /api/auth/reset-password` - Reset password

### User Endpoints
- `GET /api/user/profile` - Get profil user
- `PUT /api/user/update` - Update profil
- `POST /api/user/upload-profile-photo` - Upload foto profil

### iPhone Endpoints
- `GET /api/iphone` - List semua iPhone
- `GET /api/iphone/{id}` - Detail iPhone by ID

### Order Endpoints
- `POST /api/order` - Buat order baru
- `GET /api/order/user` - List order user
- `GET /api/order/track/{code}` - Track order by code

### Rental Endpoints
- `GET /api/rental/user` - List rental aktif user

### Testimonial Endpoints
- `GET /api/testimonial` - List testimonial
- `POST /api/testimonial` - Submit testimonial

### Admin Endpoints
- `GET /api/admin/user` - List semua user
- `GET /api/admin/user/{id}` - Detail user
- `DELETE /api/admin/user/{id}/soft-delete` - Soft delete user
- `GET /api/admin/iphone` - List iPhone (admin)
- `GET /api/admin/iphone/all` - List semua iPhone termasuk deleted
- `POST /api/admin/iphone` - Tambah iPhone baru
- `PUT /api/admin/iphone/{id}` - Update iPhone
- `DELETE /api/admin/iphone/{id}` - Delete iPhone
- Dan endpoints admin lainnya...

---

## State Management dengan Riverpod

### Provider Types Used
1. **StateNotifierProvider** - Untuk complex state (AuthState, OrderState, dll)
2. **Provider** - Untuk service instances (ApiService, StorageService)
3. **FutureProvider** - Untuk async data loading

### State Structure
Setiap provider memiliki state class dengan properties:
- `isLoading` - Loading indicator
- `data` - Data dari API
- `error` - Error message (jika ada)

### Reactive UI
Widget menggunakan `ConsumerWidget` atau `Consumer` untuk:
- Watch state changes
- Auto rebuild saat state berubah
- No manual setState() needed

### Example
```dart
final authState = ref.watch(authProvider);

if (authState.isLoading) {
  return CircularProgressIndicator();
}

if (authState.error != null) {
  return Text('Error: ${authState.error}');
}

return Text('Welcome ${authState.user?.name}');
```

---

## Error Handling

### API Errors
1. **Network error** - No internet connection
2. **401 Unauthorized** - Token expired → auto logout
3. **403 Forbidden** - No permission
4. **404 Not Found** - Resource tidak ditemukan
5. **500 Server Error** - Backend error
6. **Validation errors** - Input tidak valid

### Error Display
- **Toast** - Untuk quick error messages (Fluttertoast)
- **Dialog** - Untuk error yang perlu user action
- **Inline message** - Di form fields untuk validation errors
- **Error screen** - Untuk critical errors

### Error Recovery
- Retry mechanism untuk network errors
- Auto logout untuk authentication errors
- Fallback UI untuk data loading errors

---

## Testing

### Test Files
- `test/widget_test.dart` - Widget tests

### Test Coverage
Dapat ditambahkan:
- Unit tests untuk models
- Unit tests untuk providers
- Integration tests untuk flows
- Widget tests untuk UI components

---

## Build & Deployment

### Development Build
```bash
flutter run
```

### Release Build (APK)
```bash
flutter build apk --release
```

### Release Build (App Bundle)
```bash
flutter build appbundle --release
```

### Auto Update via GitHub
1. Build release APK
2. Create GitHub release dengan tag version
3. Upload APK ke release assets
4. Update service akan detect & prompt user
5. User download & install otomatis

---

## Maintenance & Future Improvements

### Potential Enhancements
1. **Push notifications** - Untuk update order status
2. **In-app chat** - Support customer service
3. **Payment gateway integration** - Otomatis payment tanpa upload bukti
4. **Geolocation** - Tracking pengiriman iPhone
5. **Dark mode** - Theme switching
6. **Multilingual** - Support bahasa Inggris
7. **Analytics** - Track user behavior
8. **Crash reporting** - Firebase Crashlytics

### Known Limitations
- Manual approval untuk order (admin harus cek manual)
- Payment via transfer manual (belum terintegrasi payment gateway)
- Notifikasi hanya via refresh (belum real-time push notification)
- Single platform (Android only, belum iOS)

---

## Lisensi & Credits

Project ini dibuat untuk keperluan tugas kuliah dan **bukan untuk bisnis komersial**.

**Developer:** Kiznaiverr
**Repository:** https://github.com/Kiznaiverr/iRent
**Backend API:** https://backend.nekoyama.my.id
**Website:** https://iphone.nekoyama.my.id

---

## Kontak

Untuk pertanyaan atau kontribusi, silakan buka issue di GitHub repository atau hubungi developer.

---

**Last Updated:** December 16, 2025
**Version:** 0.8.5-beta+1
