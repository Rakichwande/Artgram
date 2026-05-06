# ArtGram v2 — Full Firebase Flutter App

Artist-focused social platform with authentication, real-time feed, image uploads, dark mode, and a modular architecture ready for backend migration.

---

## What's new in v2 vs v1

| Feature                     | v1 (UI only) | v2 (this version) |
|-----------------------------|:---:|:---:|
| Dark / light mode toggle    | ✗   | ✓   |
| System theme follow         | ✗   | ✓   |
| Firebase Authentication     | ✗   | ✓   |
| Register screen             | ✗   | ✓   |
| Real-time Firestore feed     | ✗   | ✓   |
| Image picker (gallery)      | ✗   | ✓   |
| Firebase Storage upload     | ✗   | ✓   |
| Profile screen with stats   | ✗   | ✓   |
| Like toggle (Firestore)     | ✗   | ✓   |
| Loading / error states      | ✗   | ✓   |
| Theme persisted on restart  | ✗   | ✓   |
| Post model with copyWith    | ✗   | ✓   |

---

## Project file structure

```
lib/
├── main.dart                    ← App entry, Provider setup, Firebase init
├── firebase_options.dart        ← PLACEHOLDER — replace with flutterfire configure
├── theme/
│   ├── app_colors.dart          ← All colour tokens (light + dark)
│   └── app_theme.dart           ← ThemeData for light and dark
├── providers/
│   └── theme_provider.dart      ← Dark/light toggle with SharedPreferences
├── services/
│   ├── auth_service.dart        ← Firebase Auth wrapper
│   ├── firestore_service.dart   ← Firestore CRUD wrapper
│   └── storage_service.dart     ← Firebase Storage upload wrapper
├── models/
│   └── post_model.dart          ← Post data model (fromFirestore / toMap)
├── screens/
│   ├── splash_screen.dart       ← Auto-navigates after 2.5s, checks auth
│   ├── login_screen.dart        ← Firebase sign-in with validation
│   ├── register_screen.dart     ← Firebase sign-up with validation
│   ├── home_screen.dart         ← Real-time feed + dark mode toggle
│   ├── upload_screen.dart       ← Image picker + Storage + Firestore
│   └── profile_screen.dart      ← User posts + like stats
└── widgets/
    ├── post_card.dart           ← Reusable card with CachedNetworkImage
    └── story_item.dart          ← Reusable story bubble
test/
└── widget_test.dart             ← Basic smoke test
```

---

## STEP-BY-STEP SETUP ON UBUNTU

### Step 1 — Make sure Flutter is installed

```bash
flutter --version
```
If not installed:
```bash
sudo snap install flutter --classic
flutter doctor
```

---

### Step 2 — Create your Flutter project

```bash
cd ~/projects
flutter create artgram
cd artgram
```

---

### Step 3 — Copy the source files in

```bash
# Unzip the downloaded file
unzip ~/Downloads/artgram_v2_src.zip -d ~/Downloads/

# Copy all source files into your project
cp -r ~/Downloads/artgram_v2/lib/* lib/
cp -r ~/Downloads/artgram_v2/test/* test/
cp ~/Downloads/artgram_v2/pubspec.yaml pubspec.yaml
```

---

### Step 4 — Add Android permissions for image picker

Open `android/app/src/main/AndroidManifest.xml` in any text editor:

```bash
nano android/app/src/main/AndroidManifest.xml
```

Add these lines INSIDE the `<manifest>` tag, BEFORE `<application>`:

```xml
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
<uses-permission android:name="android.permission.INTERNET" />
```

Save and close (Ctrl+O, Enter, Ctrl+X in nano).

---

### Step 5 — Set minimum Android SDK version

Open `android/app/build.gradle` in a text editor:

```bash
nano android/app/build.gradle
```

Find `minSdkVersion` and change it to 21:

```gradle
defaultConfig {
    minSdkVersion 21      ← change this line
    targetSdkVersion 34
    ...
}
```

---

### Step 6 — Create your Firebase project

1. Go to https://console.firebase.google.com
2. Click **"Add project"**
3. Name it `artgram` → Continue
4. Disable Google Analytics (not needed yet) → Create project

Inside the project:
- Click **Authentication** → Get started → Enable **Email/Password**
- Click **Firestore Database** → Create database → Start in **test mode** → Choose your region
- Click **Storage** → Get started → Start in **test mode**

---

### Step 7 — Connect Firebase to Flutter (FlutterFire CLI)

Run these commands in your terminal:

```bash
# Install the FlutterFire CLI
dart pub global activate flutterfire_cli

# Make sure it's on your PATH
export PATH="$PATH":"$HOME/.pub-cache/bin"

# Connect your Flutter project to Firebase
# Run this from INSIDE your artgram project folder
cd ~/projects/artgram
flutterfire configure
```

When prompted:
- Select your `artgram` Firebase project
- Select `android` (uncheck others for now with spacebar)
- Press Enter to confirm

This command **automatically replaces** `lib/firebase_options.dart` with your real keys.

---

### Step 8 — Install all packages

```bash
cd ~/projects/artgram
flutter pub get
```

---

### Step 9 — Run the app

```bash
flutter run
```

---

### Step 10 — Set up Firestore security rules (important)

In the Firebase console → Firestore → Rules tab, replace the default rules:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /posts/{postId} {
      allow read: if true;
      allow write: if request.auth != null;
    }
  }
}
```

Click **Publish**.

---

### Step 11 — Set up Storage security rules

In Firebase console → Storage → Rules tab:

```
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /posts/{userId}/{fileName} {
      allow read: if true;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

Click **Publish**.

---

## Firestore data structure

When a user uploads a post, this document is created in the `posts` collection:

```json
{
  "userId":         "firebase_user_uid",
  "username":       "john",
  "avatarInitials": "JO",
  "imageUrl":       "https://firebasestorage.googleapis.com/...",
  "caption":        "My latest oil painting",
  "likes":          0,
  "comments":       0,
  "timestamp":      "2024-01-15T10:30:00Z"
}
```

---

## Design tokens

| Token            | Light mode  | Dark mode   |
|-----------------|------------|------------|
| Background       | `#FAF7F2`  | `#1A1917`  |
| Surface (cards)  | `#FFFFFF`  | `#242220`  |
| Rose accent      | `#C97B6E`  | `#E8907F`  |
| Border           | `#E8E3DC`  | `#3A3632`  |
| Text primary     | `#1C1A18`  | `#F5F2EE`  |
| Text secondary   | `#6B6560`  | `#A09890`  |

---

## How to migrate to FastAPI later

All Firebase logic is isolated in 3 files. To switch backends:

1. **`lib/services/auth_service.dart`** — Replace `_auth.signInWithEmailAndPassword(...)` with `http.post('https://yourapi.com/auth/login', ...)`
2. **`lib/services/firestore_service.dart`** — Replace `_posts.snapshots()` with `http.get('https://yourapi.com/posts')`
3. **`lib/services/storage_service.dart`** — Replace `ref.putFile(...)` with a multipart `http.post` to your upload endpoint
4. **`lib/models/post_model.dart`** — Replace `PostModel.fromFirestore(doc)` with `PostModel.fromJson(response.body)`

No changes needed in any screen or widget file.

---

## Common errors and fixes

| Error | Fix |
|-------|-----|
| `firebase_options.dart` has placeholder values | Run `flutterfire configure` |
| `minSdkVersion` too low | Set to 21 in `android/app/build.gradle` |
| Image picker permission denied | Add READ_MEDIA_IMAGES to AndroidManifest.xml |
| Firestore permission denied | Update Firestore rules (Step 10) |
| `dart pub global` not on PATH | Run `export PATH="$PATH":"$HOME/.pub-cache/bin"` |
| Gradle timeout | Run `flutter clean` then `flutter run` |
