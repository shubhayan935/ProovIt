# Required iOS Permissions

## Camera and Photo Library Access

This app requires camera and photo library access for proof capture functionality.

### Add to Info.plist:

1. Open `Info.plist` in Xcode
2. Add the following keys:

```xml
<key>NSCameraUsageDescription</key>
<string>ProovIt needs access to your camera to capture proof photos for your goals</string>

<key>NSPhotoLibraryUsageDescription</key>
<string>ProovIt needs access to your photo library to select proof images</string>

<key>NSPhotoLibraryAddUsageDescription</key>
<string>ProovIt would like to save proof photos to your library</string>
```

Or in the Info.plist editor:
- **Privacy - Camera Usage Description**: "ProovIt needs access to your camera to capture proof photos for your goals"
- **Privacy - Photo Library Usage Description**: "ProovIt needs access to your photo library to select proof images"
- **Privacy - Photo Library Additions Usage Description**: "ProovIt would like to save proof photos to your library"
