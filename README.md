# ProovIt - Habit Tracking with AI Verification

<div align="center">
  <h3>Turn habits into streaks with AI-powered proof verification</h3>
  <p>A SwiftUI iOS app that helps you build lasting habits by verifying your progress with AI</p>
</div>

## Features

- **AI-Powered Verification**: Upload photos of your completed habits and get instant AI verification
- **Streak Tracking**: Build and maintain streaks for your daily goals
- **Social Feed**: Share your progress and see friends' verified proofs
- **Beautiful Design**: Earthy color palette with smooth animations and modern UI
- **Secure Authentication**: User authentication powered by Supabase
- **Profile & Stats**: Track your achievements and view personal statistics

## Tech Stack

- **Frontend**: SwiftUI (iOS 15+)
- **Backend**: Supabase
  - PostgreSQL database
  - Authentication
  - Storage (for proof images)
  - Edge Functions (serverless)
- **AI**: OpenAI Vision API
- **Architecture**: MVVM + Repository Pattern
- **Design**: Custom design system with earthy theme

## Design System

### Colors
- **Primary Green**: `#3C6E47` - Main actions and highlights
- **Sage Green**: `#A7C4A0` - Secondary elements
- **Sand**: `#D2B47C` - Accents and highlights
- **Beige**: `#F4EEDC` - Background

### Typography
- **H1**: 28pt Semibold - Page titles
- **H2**: 22pt Semibold - Section headers
- **H3**: 18pt Semibold - Card titles
- **Body**: 16pt Regular - Main content
- **Caption**: 12pt Regular - Metadata

## Getting Started

### Prerequisites

- Xcode 15.0+
- iOS 15.0+ target
- Supabase account
- OpenAI API key

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/proovit.git
   cd proovit
   ```

2. **Open in Xcode**
   ```bash
   open SrivastavaShubhayanFinal.xcodeproj
   ```

3. **Add Supabase Swift SDK**
   - In Xcode: File → Add Package Dependencies
   - Enter: `https://github.com/supabase-community/supabase-swift`
   - Select latest version

4. **Set up Supabase Backend**
   - Follow instructions in `SUPABASE_SETUP.md`
   - Run the SQL migration to create tables
   - Create the `proof-images` storage bucket
   - Deploy the `verify-proof` Edge Function

5. **Configure Environment Variables**
   - In Xcode: Product → Scheme → Edit Scheme
   - Go to Run → Arguments → Environment Variables
   - Add:
     - `SUPABASE_URL`: Your Supabase project URL
     - `SUPABASE_ANON_KEY`: Your Supabase anon key

6. **Add Camera Permissions**
   - Follow instructions in `PERMISSIONS_README.md`
   - Add required privacy descriptions to Info.plist

7. **Uncomment Supabase Code**
   - After adding the SDK, uncomment the Supabase client initialization in:
     - `Services/SupabaseClientService.swift`
     - `Repositories/*.swift`
     - `ViewModels/*.swift`

8. **Build and Run**
   - Select a simulator or device
   - Press ⌘+R to build and run

## Project Structure

```
SrivastavaShubhayanFinal/
├── DesignSystem/
│   ├── Theme.swift              # Color palette
│   ├── Typography.swift         # Text styles
│   └── Layout.swift             # Spacing constants
│
├── Models/
│   ├── Profile.swift            # User profile
│   ├── Goal.swift               # Habit goal
│   ├── Streak.swift             # Streak data
│   ├── Proof.swift              # Proof submission
│   └── FeedProof.swift          # Social feed item
│
├── Services/
│   └── SupabaseClientService.swift  # Supabase client singleton
│
├── Repositories/
│   ├── GoalsRepository.swift        # Goals CRUD
│   ├── ProofsRepository.swift       # Proofs CRUD
│   ├── StreaksRepository.swift      # Streak management
│   └── ProfilesRepository.swift     # User profiles
│
├── ViewModels/
│   ├── AppViewModel.swift           # App-wide state
│   ├── AuthViewModel.swift          # Authentication
│   ├── HomeViewModel.swift          # Home screen
│   └── ...
│
├── Views/
│   ├── Shared/
│   │   ├── PrimaryButton.swift      # Reusable button
│   │   └── AppCard.swift            # Card container
│   │
│   ├── Auth/
│   │   └── AuthView.swift           # Login/Signup
│   │
│   ├── Home/
│   │   └── HomeView.swift           # Goals list
│   │
│   ├── Proof/
│   │   ├── ProofCaptureView.swift   # Camera/photo picker
│   │   └── AIResultView.swift       # Verification result
│   │
│   ├── Social/
│   │   └── SocialFeedView.swift     # Friend activity
│   │
│   ├── Profile/
│   │   └── ProfileView.swift        # User profile
│   │
│   └── MainTabView.swift            # Tab navigation
│
└── ProovItApp.swift                 # App entry point
```

## App Flow

1. **Authentication**
   - User signs up or logs in
   - Session managed by Supabase Auth

2. **Home Screen**
   - View today's goals
   - See current streaks
   - Tap goal to log proof

3. **Proof Capture**
   - Take photo or choose from library
   - Submit for AI verification

4. **AI Verification**
   - Photo uploaded to Supabase Storage
   - Edge Function calls OpenAI Vision API
   - Returns verification result with confidence score

5. **Streak Update**
   - If verified, proof is saved
   - Streak counter increments
   - Achievement unlocked

6. **Social Feed**
   - View verified proofs from friends
   - See their progress and streaks

7. **Profile**
   - View personal statistics
   - See achievements
   - Manage account

## Database Schema

### Tables
- **profiles**: User information
- **goals**: Habit goals
- **streaks**: Streak tracking per goal
- **proofs**: Submitted proof photos
- **friendships**: User connections

### Views
- **proofs_feed**: Joined view for social feed

See `SUPABASE_SETUP.md` for complete schema with RLS policies.

## Edge Function

The `verify-proof` function:
1. Receives image path and goal title
2. Creates signed URL for image
3. Calls OpenAI Vision API with custom prompt
4. Analyzes if image matches goal description
5. Returns verification result with confidence score

## Current Status

**Implemented:**
- Complete UI/UX with earthy design
- All screens and navigation
- Mock data and interactions
- Camera and photo picker integration
- Design system and reusable components
- Project structure and architecture

**To Complete:**
1. Add Supabase Swift SDK via SPM
2. Set up Supabase backend (database, storage, functions)
3. Uncomment Supabase client code
4. Connect real authentication
5. Implement actual proof verification
6. Add image loading for feed
7. Implement goal creation UI
8. Add error handling and loading states
9. Write unit tests
10. Polish animations and transitions

## Documentation

- **IMPLEMENTATION_GUIDE.md**: Complete setup and implementation guide
- **SUPABASE_SETUP.md**: Backend configuration instructions
- **PERMISSIONS_README.md**: iOS permissions setup

## Testing

The app currently runs with mock data. To test:

1. **Run in Simulator**
   - Open in Xcode
   - Select iPhone simulator
   - Press ⌘+R

2. **Test Auth Flow**
   - Click "Sign Up" or "Log In"
   - Any credentials work (mock mode)

3. **Test Proof Capture**
   - Tap any goal
   - Choose "Choose from Library"
   - Select an image
   - View mock AI verification

4. **Test Navigation**
   - Switch between tabs
   - Navigate through screens
   - Test back navigation

## Future Enhancements

- [ ] Real-time notifications
- [ ] Custom goal creation UI
- [ ] Weekly/monthly stats
- [ ] Achievement system expansion
- [ ] Friend search and invites
- [ ] Comments on proofs
- [ ] Goal templates library
- [ ] Dark mode support
- [ ] iPad optimization
- [ ] Apple Watch companion app

## Contributing

This is a student project for TAC342. For questions or suggestions, please open an issue.

## License

This project is for educational purposes.

## Acknowledgments

- Design inspired by modern habit tracking apps
- Color palette based on earthy, natural themes
- Architecture follows iOS best practices
- Built with ❤️ at USC

---

**ProovIt** - Because consistency is key 🔥
