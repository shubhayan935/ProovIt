# ProovIt iOS App - Implementation Guide

## Overview
ProovIt is a habit tracking app with AI-powered proof verification. Users set goals, submit photo proofs, and the AI verifies their completion.

## Architecture
- **Pattern**: MVVM + Repository + Service Layer
- **Backend**: Supabase (Auth, Postgres, Storage, Edge Functions)
- **AI**: OpenAI Vision API for proof verification
- **Design**: Earthy color palette (#3C6E47, #A7C4A0, #D2B47C, #F4EEDC)

---

## Step 1: Add Supabase Swift SDK

1. Open the project in Xcode
2. Go to **File → Add Package Dependencies**
3. Enter URL: `https://github.com/supabase-community/supabase-swift`
4. Select version: Latest
5. Add to target: `SrivastavaShubhayanFinal`

---

## Step 2: Configure Supabase Backend

### A. Create Supabase Project
1. Go to [supabase.com](https://supabase.com)
2. Create a new project (e.g., "proovit-dev")
3. Copy your:
   - Project URL
   - Anon/Public Key
   - Service Role Key (for Edge Functions)

### B. Run Database Migration
1. Go to SQL Editor in Supabase Dashboard
2. Run the SQL from `SUPABASE_SETUP.md`
3. This creates:
   - `profiles`, `goals`, `streaks`, `proofs`, `friendships` tables
   - RLS policies
   - `proofs_feed` view

### C. Create Storage Bucket
1. Go to **Storage** in Supabase Dashboard
2. Create new bucket: `proof-images`
3. Make it public (or configure auth policies)

### D. Deploy Edge Function
1. Install Supabase CLI (if not already):
   ```bash
   brew install supabase/tap/supabase
   ```

2. Login to Supabase:
   ```bash
   supabase login
   ```

3. Link project:
   ```bash
   supabase link --project-ref YOUR_PROJECT_REF
   ```

4. Set secrets:
   ```bash
   supabase secrets set OPENAI_API_KEY=your_openai_api_key
   supabase secrets set SUPABASE_SERVICE_ROLE_KEY=your_service_role_key
   supabase secrets set SUPABASE_URL=your_supabase_url
   ```

5. Deploy function:
   ```bash
   supabase functions deploy verify-proof
   ```

---

## Step 3: Configure Xcode Environment

1. In Xcode, go to **Product → Scheme → Edit Scheme**
2. Select **Run** → **Arguments** → **Environment Variables**
3. Add:
   - `SUPABASE_URL` = `https://YOUR_PROJECT_ID.supabase.co`
   - `SUPABASE_ANON_KEY` = `your_anon_key_here`

---

## Step 4: Uncomment Code After Adding Supabase SDK

After adding the Supabase Swift SDK, uncomment the following in:

### `Services/SupabaseClientService.swift`:
```swift
import Supabase

let client: SupabaseClient

self.client = SupabaseClient(supabaseURL: url, supabaseKey: key)
```

### All Repository files:
Uncomment the actual Supabase query code (currently marked with TODO comments)

---

## Step 5: Project Structure

```
SrivastavaShubhayanFinal/
├── DesignSystem/
│   ├── Theme.swift           # Colors
│   ├── Typography.swift      # Text styles
│   └── Layout.swift          # Spacing
├── Models/
│   ├── Profile.swift
│   ├── Goal.swift
│   ├── Streak.swift
│   ├── Proof.swift
│   └── FeedProof.swift
├── Services/
│   ├── SupabaseClientService.swift
│   └── ProofVerificationService.swift
├── Repositories/
│   ├── GoalsRepository.swift
│   ├── ProofsRepository.swift
│   ├── StreaksRepository.swift
│   └── ProfilesRepository.swift
├── ViewModels/
│   ├── AppViewModel.swift
│   ├── AuthViewModel.swift
│   ├── HomeViewModel.swift
│   ├── ProofCaptureViewModel.swift
│   ├── AIResultViewModel.swift
│   ├── SocialFeedViewModel.swift
│   └── ProfileViewModel.swift
└── Views/
    ├── Shared/
    │   ├── PrimaryButton.swift
    │   └── AppCard.swift
    ├── Auth/
    │   └── AuthView.swift
    ├── Home/
    │   └── HomeView.swift
    ├── Proof/
    │   ├── ProofCaptureView.swift
    │   └── AIResultView.swift
    ├── Social/
    │   └── SocialFeedView.swift
    ├── Profile/
    │   └── ProfileView.swift
    └── MainTabView.swift
```

---

## Step 6: App Flow

1. **Auth**: User signs up/logs in
2. **Home**: Shows today's goals with streaks
3. **Proof Capture**: User taps goal → takes/selects photo
4. **AI Verification**: Photo uploaded → Edge Function verifies → Updates streak
5. **Social Feed**: View friends' verified proofs
6. **Profile**: View stats, logout

---

## Step 7: Testing

### Test the Backend First:
1. Create a test user in Supabase Auth
2. Manually insert a test goal
3. Test the `verify-proof` Edge Function with curl:
```bash
curl -X POST 'https://YOUR_PROJECT_ID.supabase.co/functions/v1/verify-proof' \
  -H 'Authorization: Bearer YOUR_ANON_KEY' \
  -H 'Content-Type: application/json' \
  -d '{"imagePath":"test.jpg","goalTitle":"Drink Water"}'
```

### Then Test the iOS App:
1. Run in simulator
2. Sign up a new user
3. Manually add goals in database
4. Test photo capture flow
5. Verify streak updates

---

## Design System

### Colors:
- Primary Green: `#3C6E47`
- Sage Green: `#A7C4A0`
- Sand: `#D2B47C`
- Beige (Background): `#F4EEDC`

### Typography:
- H1: 28pt, Semibold
- H2: 22pt, Semibold
- H3: 18pt, Semibold
- Body: 16pt, Regular
- Caption: 12pt, Regular

### Spacing:
- XS: 4pt
- SM: 8pt
- MD: 12pt
- LG: 16pt
- XL: 24pt

---

## Git Workflow

After completing each feature:
```bash
git add .
git commit -m "feat: <description>"
git push
```

Example commits:
- `chore: add supabase swift sdk`
- `feat: implement auth flow`
- `feat: add home screen with goals`
- `feat: implement proof capture and ai verification`
- `feat: add social feed`
- `feat: implement profile screen`

---

## Next Steps

1. Add Supabase Swift SDK
2. Set up backend (database, storage, edge function)
3. Configure environment variables
4. Uncomment Supabase client code
5. Implement remaining ViewModels and Views
6. Test end-to-end flow
7. Add error handling and loading states
8. Implement image loading for feed
9. Add goal creation UI
10. Enhance UI/UX with animations

---

## Troubleshooting

### Can't install Supabase CLI:
- Update Command Line Tools: `xcode-select --install`
- Or use Supabase Dashboard directly

### Environment variables not working:
- Restart Xcode after adding them
- Check they're in Run scheme, not Test

### Database errors:
- Check RLS policies in Supabase Dashboard
- Verify user is authenticated

### Edge Function not working:
- Check function logs in Supabase Dashboard
- Verify OpenAI API key is valid
- Test with curl first

---

## Resources

- [Supabase Swift SDK Docs](https://github.com/supabase-community/supabase-swift)
- [Supabase Documentation](https://supabase.com/docs)
- [OpenAI Vision API](https://platform.openai.com/docs/guides/vision)
