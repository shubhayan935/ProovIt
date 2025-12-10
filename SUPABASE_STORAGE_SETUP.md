# Supabase Storage Setup

## Create the Storage Bucket

1. Go to **Storage** in Supabase Dashboard (left sidebar)
2. Click **New bucket**
3. Bucket name: `proof-images`
4. Set to **Public bucket** (checked)
5. Click **Create bucket**

## Set Bucket Policies

Since we're using phone-based auth (not Supabase Auth), set permissive policies.

Go to **Storage** → **Policies** → Select `proof-images` bucket → Click **New Policy**

### Upload Policy
```sql
CREATE POLICY "Anyone can upload proof images"
ON storage.objects FOR INSERT
TO public
WITH CHECK (bucket_id = 'proof-images');
```

### View Policy
```sql
CREATE POLICY "Anyone can view proof images"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'proof-images');
```

### Delete Policy
```sql
CREATE POLICY "Anyone can delete proof images"
ON storage.objects FOR DELETE
TO public
USING (bucket_id = 'proof-images');
```

## How It Works

### Image Upload Flow

1. **User takes photo** → `CameraView`
2. **Photo captured** → Image data converted to JPEG
3. **Upload to Storage** → `ImageUploadService.uploadProofImage()`
   - File stored at: `{userId}/{goalId}/proof_{timestamp}.jpg`
   - Returns storage path
4. **AI Verification** → `AIVerificationService.verifyProof()`
   - Edge Function creates signed URL
   - Sends to OpenAI Vision API
   - Returns verification result
5. **Save to Database** → `ProofsRepository.createProof()`
   - Stores proof with image path
   - Updates verification status
6. **Update Streak** → `StreaksRepository.incrementStreak()`
   - Increments current streak
   - Updates longest streak if needed
7. **Appears in Feed** → Followers see the proof via `proofs_feed` view

### Folder Structure

```
proof-images/
├── {user1-uuid}/
│   ├── {goal1-uuid}/
│   │   ├── proof_1702345678.jpg
│   │   └── proof_1702456789.jpg
│   └── {goal2-uuid}/
│       └── proof_1702567890.jpg
└── {user2-uuid}/
    └── {goal1-uuid}/
        └── proof_1702678901.jpg
```

## Security Considerations

**Important**: Since we're using Twilio for authentication (not Supabase Auth), the storage policies are permissive. In production:

1. **Implement API key validation** in your app
2. **Use service role key** server-side for sensitive operations
3. **Add application-level permission checks**
4. **Consider adding RLS** with custom claims or JWT tokens

## Troubleshooting

### Images not uploading
- Check that bucket name is exactly `proof-images`
- Verify bucket is set to **Public**
- Check storage policies are created
- Look for errors in Xcode console

### Images not appearing in feed
- Check `proofs_feed` view exists
- Verify user has followers
- Check proof was saved with `verified: true`
- Look for errors in database logs

### Edge Function errors
- Verify `OPENAI_API_KEY` is set in Edge Function secrets
- Check `SUPABASE_SERVICE_ROLE_KEY` is set
- View Edge Function logs in Supabase Dashboard
