# URL Configuration Summary

All URLs in the LuiseStore project have been configured for GitHub user: **xztimee**

## Repository URL
`https://github.com/xztimee/LuiseStore`

## Critical URLs

### 1. Auto-Update URL (Most Important!)
**File:** `Shared/LSListControllerShared.m`
```objective-c
NSURL* luiseStoreURL = [NSURL URLWithString:@"https://github.com/xztimee/LuiseStore/releases/latest/download/LuiseStore.tar"];
```

**Purpose:** This is where LuiseStore downloads updates from. When users tap "Update" in the app, it downloads from this URL.

**Requirements:**
- You MUST create a GitHub Release with tag (e.g., `v1.0.0`)
- The release MUST include `LuiseStore.tar` as an asset
- The tar file is automatically created by the build workflow in `_build/LuiseStore.tar`

### 2. Documentation URLs

**Issue Tracker:** `.github/ISSUE_TEMPLATE/bug-report-issue-template.yml`
```
https://github.com/xztimee/LuiseStore/issues
```

**Repository Link:** `.github/workflows/README.md`
```
https://github.com/xztimee/LuiseStore
```

**Release Notes:** `.github/workflows/build-release.yml`
```
https://github.com/xztimee/LuiseStore
```

## How Auto-Update Works

1. User opens LuiseStore app
2. App checks for updates by querying GitHub API
3. If new version available, shows "Update" button
4. User taps "Update"
5. App downloads `LuiseStore.tar` from releases
6. Saves to `/tmp/LuiseStore.tar`
7. Calls `luisestorehelper install-luisestore /tmp/LuiseStore.tar`
8. Helper extracts and installs the update
9. App resprings

## Creating Your First Release

After building successfully:

1. **Build the project:**
   ```bash
   make clean
   make
   ```

2. **Find the tar file:**
   ```
   _build/LuiseStore.tar
   ```

3. **Create a GitHub Release:**
   - Go to: https://github.com/xztimee/LuiseStore/releases/new
   - Tag: `v1.0.0` (or your version)
   - Title: `LuiseStore v1.0.0`
   - Upload `_build/LuiseStore.tar` as an asset
   - Publish release

4. **Test auto-update:**
   - Install LuiseStore on device
   - Open app
   - Should show update available
   - Tap update to test

## Troubleshooting

### Error 169: Extract Failed
- Check that `LuiseStore.tar` is valid
- Verify tar contains `LuiseStore.app` at root level
- Ensure `COPYFILE_DISABLE=1` was set during tar creation

### Update Not Showing
- Verify release is published (not draft)
- Check that `LuiseStore.tar` is attached to release
- Ensure release is marked as "latest"
- Check app can reach GitHub (network/firewall)

### Download Fails
- Verify URL is correct: `https://github.com/xztimee/LuiseStore/releases/latest/download/LuiseStore.tar`
- Check release asset name is exactly `LuiseStore.tar`
- Test URL in browser to confirm it downloads

## Changing Repository Location

If you need to move the repository or change username:

1. Update `Shared/LSListControllerShared.m` (line ~31)
2. Update `.github/ISSUE_TEMPLATE/bug-report-issue-template.yml`
3. Update `.github/workflows/README.md`
4. Update `.github/workflows/build-release.yml`
5. Rebuild and create new release

## Current Configuration Status

✅ All URLs configured for: `xztimee/LuiseStore`
✅ Auto-update URL set
✅ Issue tracker URL set
✅ Documentation URLs set
✅ Build workflow URLs set

**Next Steps:**
1. Push code to GitHub
2. Run build workflow or build locally
3. Create first release with `LuiseStore.tar`
4. Test installation and updates
