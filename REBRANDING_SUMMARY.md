# LuiseStore Rebranding Summary

This document summarizes all changes made during the rebranding from TrollStore to LuiseStore.

## Completed Changes

### 1. Bundle Identifiers
- ✅ `com.opa334.TrollStore` → `com.luisepog.luisestore`
- ✅ `com.opa334.TrollStoreLite` → `com.luisepog.luisestorelite`
- ✅ `com.opa334.TrollHelper` → `com.luisepog.luisehelper`

### 2. Directory Names
- ✅ `TrollStore/` → `LuiseStore/`
- ✅ `TrollStoreLite/` → `LuiseStoreLite/`
- ✅ `TrollHelper/` → Kept as `TrollHelper/` (internal component)

### 3. Class Prefixes
- ✅ `TS*` classes → `LS*` classes
- ✅ `TSH*` classes → `LSH*` classes
- ✅ All header and implementation files renamed

### 4. Preprocessor Directives
- ✅ `TROLLSTORE_LITE` → `LUISESTORE_LITE`
- ✅ All conditional compilation updated

### 5. Binary Names
- ✅ `trollstorehelper` → `luisestorehelper`
- ✅ `trollstorehelper_lite` → `luisestorehelper_lite`
- ✅ `TrollHelper` → `LuiseHelper` (in packages)

### 6. String References
- ✅ All user-facing strings updated
- ✅ File paths and markers updated
- ✅ Preference keys updated
- ✅ URL schemes kept as `apple-magnifier` (for compatibility)

### 7. Build System
- ✅ Makefile updated for new names
- ✅ Control files updated
- ✅ Package names updated
- ✅ GitHub Actions workflow updated

### 8. Documentation
- ✅ README.md updated
- ✅ CREDITS.md created
- ✅ SETUP.md created for fork setup
- ✅ Issue templates updated

### 9. Makefile Fixes
- ✅ Fixed `COPYFILE_DISABLE` export issue
- ✅ Removed verbose flag from tar command

## Known Issues Fixed

### Error 169: Extract Failure
**Problem:** `luisestorehelper returned 169` during installation

**Root Cause:** The `extract()` function in `RootHelper/unarchive.m` was failing to extract the tar file.

**Fix Applied:** 
- Changed `export COPYFILE_DISABLE=1` to `COPYFILE_DISABLE=1` in tar command
- This ensures macOS resource forks are not included in the tar file

## Files with Remaining TrollStore References

These files intentionally keep TrollStore references for credits/compatibility:

1. **LICENSE** - Original copyright and attribution
2. **CREDITS.md** - Full credits to original authors
3. **README.md** - Credits section
4. **.gitmodules** - ChOma submodule (original library)
5. **LSInstallationController.m** - ldid download URL (opa334's tool)

## Repository URLs

All repository URLs have been updated to use GitHub username: **xztimee**

Updated files:
- `.github/ISSUE_TEMPLATE/bug-report-issue-template.yml`
- `.github/workflows/README.md`
- `.github/workflows/build-release.yml`

## Testing Checklist

- [ ] Build completes successfully
- [ ] LuiseStore.tar is created correctly
- [ ] Installation works without error 169
- [ ] App launches and shows "LuiseStore" branding
- [ ] Settings show correct bundle identifiers
- [ ] Persistence helper works
- [ ] App installation/uninstallation works
- [ ] URL scheme works (apple-magnifier://)

## Migration Notes

### For Users
- LuiseStore is fully compatible with TrollStore
- Existing TrollStore installations can be updated
- All features remain the same

### For Developers
- Fork this repository
- Update placeholder URLs (see SETUP.md)
- Build using the standard THEOS workflow
- Test thoroughly before release

## Version Information

- **Original TrollStore Version:** Based on TrollStore 2.x
- **LuiseStore Version:** 1.0.0 (initial fork)
- **iOS Support:** 14.0 beta 2 - 16.6.1, 16.7 RC, 17.0

## Contact

For issues specific to LuiseStore, please use the issue tracker at:
`https://github.com/xztimee/LuiseStore/issues`

For issues with the original TrollStore, visit:
`https://github.com/opa334/TrollStore/issues`
