# ProovIt - Quick Start Guide

## What Was Built

A complete iOS habit tracking app with AI-powered proof verification, featuring:

- **Full SwiftUI App** with 6 main screens
- **Earthy Design System** (colors, typography, components)
- **MVVM Architecture** with Repository pattern
- **Supabase Backend Setup** (schema, RLS policies, Edge Function)
- **Mock Data Integration** (app is fully testable without backend)

## What You Can Do Right Now

### 1. Run the App (2 minutes)

```bash
# Open in Xcode
open SrivastavaShubhayanFinal.xcodeproj

# Press ⌘+R to run
```

The app will launch with mock data and you can:
- Test the login flow (any credentials work)
- View 3 sample goals on the home screen
- Tap a goal and select a photo
- See the AI verification animation (mock result)
- Browse the social feed with sample data
- View the profile with mock stats

### 2. Connect to Real Backend (30-60 minutes)

#### A. Setup Supabase (15 minutes)

1. **Create Project**
   - Go to [supabase.com](https://supabase.com)
   - Create new project
   - Save URL and Anon Key

2. **Run Database Migration**
   - Open SQL Editor in Supabase Dashboard
   - Copy/paste SQL from `SUPABASE_SETUP.md`
   - Execute to create tables, RLS policies, and views

3. **Create Storage Bucket**
   - Go to Storage tab
   - Create bucket: `proof-images`
   - Make public (or configure auth policies)

#### B. Deploy Edge Function (10 minutes)

1. **Install Supabase CLI**
   ```bash
   brew install supabase/tap/supabase
   ```

2. **Deploy Function**
   ```bash
   supabase login
   supabase link --project-ref YOUR_PROJECT_REF
   supabase functions deploy verify-proof
   ```

3. **Set Secrets**
   ```bash
   supabase secrets set OPENAI_API_KEY=your_key
   supabase secrets set SUPABASE_SERVICE_ROLE_KEY=your_key
   supabase secrets set SUPABASE_URL=your_url
   ```

#### C. Add Supabase Swift SDK (5 minutes)

1. In Xcode: **File → Add Package Dependencies**
2. Enter: `https://github.com/supabase-community/supabase-swift`
3. Add to project

#### D. Configure Environment (5 minutes)

1. **Edit Scheme → Run → Environment Variables**
   - Add `SUPABASE_URL`
   - Add `SUPABASE_ANON_KEY`

2. **Add Camera Permissions to Info.plist**
   - See `PERMISSIONS_README.md` for details

#### E. Uncomment Code (5 minutes)

Search for `// TODO: Uncomment` and uncomment Supabase client code in:
- `Services/SupabaseClientService.swift`
- `Repositories/GoalsRepository.swift`
- `ViewModels/AppViewModel.swift`
- `ViewModels/AuthViewModel.swift`

### 3. Build and Test (10 minutes)

1. **Run app** (⌘+R)
2. **Create account** with real email/password
3. **Add goals** (manually in Supabase Dashboard for now)
4. **Test proof capture** with camera/photo
5. **View AI verification** result
6. **Check streak** update in database

## Project Structure Overview

```
SrivastavaShubhayanFinal/
├── DesignSystem/        # Colors, typography, spacing
├── Models/              # Data models (5 structs)
├── Services/            # Supabase client
├── Repositories/        # Data access layer (4 repos)
├── ViewModels/          # Business logic (6 VMs)
├── Views/               # UI screens (6 main + 2 shared)
└── ProovItApp.swift     # App entry point
```

## Key Files

| File | Purpose | Status |
|------|---------|--------|
| `ProovItApp.swift` | Main entry point | ✅ Complete |
| `Views/Auth/AuthView.swift` | Login/signup screen | ✅ Complete |
| `Views/Home/HomeView.swift` | Goals list | ✅ Complete |
| `Views/Proof/ProofCaptureView.swift` | Camera/picker | ✅ Complete |
| `Views/Proof/AIResultView.swift` | Verification result | ✅ Complete |
| `Views/Social/SocialFeedView.swift` | Friend activity | ✅ Complete |
| `Views/Profile/ProfileView.swift` | User profile | ✅ Complete |
| `Services/SupabaseClientService.swift` | Backend client | ⏸️ Needs SDK |
| `SUPABASE_SETUP.md` | Backend schema | ✅ Complete |
| `supabase/functions/verify-proof/` | AI verification | ✅ Complete |

## Design System at a Glance

### Colors
```swift
AppColors.primaryGreen  // #3C6E47 - Buttons, highlights
AppColors.sageGreen     // #A7C4A0 - Subtle accents
AppColors.sand          // #D2B47C - Icons, badges
AppColors.beige         // #F4EEDC - Background
```

### Shared Components
```swift
PrimaryButton(title: "Click me") { /* action */ }
AppCard { /* content */ }
```

## Current App Flow

1. **Launch** → AuthView (if not logged in)
2. **Login/Signup** → Mock auth → MainTabView
3. **Home Tab** → List of 3 mock goals
4. **Tap Goal** → ProofCaptureView
5. **Select Photo** → AIResultView
6. **View Result** → Mock verification (85% confidence)
7. **Add to Streak** → Mock save
8. **Social Tab** → Feed with 3 mock proofs
9. **Profile Tab** → Stats with mock data
10. **Logout** → Back to AuthView

## Next Steps Priority

1. ✅ App structure (DONE)
2. ✅ All UI screens (DONE)
3. ✅ Mock data flow (DONE)
4. ⏭️ Add Supabase SDK
5. ⏭️ Connect real auth
6. ⏭️ Implement actual AI verification
7. ⏭️ Add goal creation UI
8. ⏭️ Implement image upload/download
9. ⏭️ Add error handling
10. ⏭️ Write tests

## Testing Checklist

### Without Backend (Mock Mode)
- [x] App launches successfully
- [x] Can "log in" with any credentials
- [x] Home screen shows 3 goals
- [x] Can navigate to proof capture
- [x] Photo picker opens
- [x] Can select image
- [x] AI verification animation plays
- [x] Result screen shows mock verification
- [x] Social feed displays 3 sample proofs
- [x] Profile shows mock stats
- [x] Can log out
- [x] Returns to login screen

### With Backend (After Setup)
- [ ] Real authentication works
- [ ] Goals load from database
- [ ] Photo uploads to Storage
- [ ] Edge Function returns verification
- [ ] Streak updates in database
- [ ] Feed shows real proofs
- [ ] Profile shows real stats

## Troubleshooting

### App won't build
- Clean build folder: ⇧⌘K
- Delete derived data
- Restart Xcode

### Camera not working in simulator
- Use "Choose from Library" instead
- Or test on real device

### "SUPABASE_URL not configured" error
- Check scheme environment variables
- Restart Xcode after adding them

### Files not showing in Xcode
- Right-click project → Add Files
- Select the folders
- Ensure "Copy items if needed" is checked

## Resources

- **Full Guide**: `IMPLEMENTATION_GUIDE.md`
- **Backend Setup**: `SUPABASE_SETUP.md`
- **Permissions**: `PERMISSIONS_README.md`
- **Main README**: `README.md`

## Support

For questions about:
- **Supabase**: [supabase.com/docs](https://supabase.com/docs)
- **SwiftUI**: [developer.apple.com/swiftui](https://developer.apple.com/swiftui)
- **OpenAI**: [platform.openai.com/docs](https://platform.openai.com/docs)

---

**Ready to start?** Open the project and press ⌘+R! 🚀
