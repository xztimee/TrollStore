# TrollStore CI/CD Workflow Documentation

## Overview

This document provides comprehensive documentation for the TrollStore GitHub Actions workflow that automates building and releasing TrollStore components.

## Table of Contents

- [Workflow Overview](#workflow-overview)
- [Trigger Conditions](#trigger-conditions)
- [Build Process](#build-process)
- [Required Secrets](#required-secrets)
- [Expected Outputs](#expected-outputs)
- [Usage Guide](#usage-guide)
- [Troubleshooting](#troubleshooting)
- [Performance and Optimization](#performance-and-optimization)

---

## Workflow Overview

The `build-release.yml` workflow automates the complete build and release process for TrollStore, including:

- Building all TrollStore components (fastPathSign, RootHelper, TrollStore app, TrollHelper, TrollStoreLite)
- Creating installer IPAs for iOS 15 and arm64e devices
- Packaging build artifacts
- Uploading artifacts to GitHub Actions
- Creating GitHub releases with attached artifacts

**Workflow File**: `.github/workflows/build-release.yml`

**Runner**: macOS 14 (Apple Silicon) with Xcode 15.4

**Average Build Time**: 
- First run (no cache): 20-25 minutes
- Subsequent runs (with cache): 10-15 minutes

---

## Trigger Conditions

The workflow can be triggered in three ways:

### 1. Manual Trigger (workflow_dispatch)

You can manually trigger the workflow from the GitHub UI:

1. Navigate to **Actions** tab in the repository
2. Select **Build and Release TrollStore** workflow
3. Click **Run workflow** button
4. Select the branch to build from
5. Click **Run workflow**

**Use Case**: Testing builds, creating one-off releases, debugging

### 2. Push to Specific Branches

The workflow automatically triggers on push to:

- `main` - Production releases
- `release` - Release candidates
- `develop` - Development builds

**Use Case**: Continuous integration, automatic builds on code changes

### 3. Version Tags

The workflow triggers when pushing version tags:

- Tag format: `v*.*.*` (e.g., `v2.0.0`, `v2.1.0-beta`)

**Use Case**: Creating versioned releases

```bash
# Example: Create and push a version tag
git tag v2.0.0
git push origin v2.0.0
```

---

## Build Process

The workflow executes the following steps in order:

### 1. Environment Setup
- Sets up Xcode 15.4
- Checks out repository with submodules
- Configures environment variables (THEOS, THEOS_PACKAGE_SCHEME, FINALPACKAGE)

### 2. Dependency Installation
- **Homebrew packages**: dpkg, ldid-procursus, make, openssl@3, libarchive
- **THEOS framework**: Cloned from theos/theos repository
- **iOS SDKs**: iPhoneOS14.5.sdk and iPhoneOS16.5.sdk

### 3. Caching
- Caches Homebrew packages to speed up subsequent builds
- Caches THEOS framework installation
- Cache invalidation based on workflow file changes

### 4. Build Execution
Runs `make all` which builds:
1. fastPathSign exploit tool
2. RootHelper binary
3. TrollStore main application
4. TrollHelper packages (standard + rootless)
5. iOS 15 and arm64e installer IPAs
6. TrollStoreLite packages
7. Final TrollStore.tar archive

### 5. Artifact Collection
Collects all build outputs:
- `TrollStore.tar` from `_build/` directory
- Installer IPAs from `_build/` directory
- DEB packages from `.theos/packages/` directories

### 6. Version Extraction
Extracts version information from:
- Git tags (if triggered by tag push)
- Info.plist CFBundleVersion/CFBundleShortVersionString (fallback)

### 7. Artifact Upload
Uploads artifacts to GitHub Actions with:
- Name format: `trollstore-build-{version}-{commit-sha}`
- Retention: 90 days
- Includes all tar, ipa, and deb files

### 8. Release Creation (Conditional)
Creates GitHub release when:
- Build succeeds AND
- Triggered on `main`, `release` branch, or version tag

Release includes:
- Version tag (from git tag or extracted version)
- Release notes with build information
- All build artifacts attached
- Prerelease flag for beta/rc/alpha versions

---

## Required Secrets

### GITHUB_TOKEN (Automatic)

**Purpose**: Used for creating GitHub releases and uploading artifacts

**Setup**: Automatically provided by GitHub Actions - no configuration needed

**Permissions Required**:
- `contents: write` - For creating releases
- `actions: read` - For workflow execution

**Note**: If the workflow fails to create releases, verify that the repository settings allow GitHub Actions to create releases:
1. Go to **Settings** → **Actions** → **General**
2. Under "Workflow permissions", ensure "Read and write permissions" is selected

### Optional: SIGNING_CERTIFICATE

**Purpose**: Custom code signing certificate (if needed for specific signing requirements)

**Setup**: 
1. Export your signing certificate as a .p12 file
2. Base64 encode the certificate:
   ```bash
   base64 -i certificate.p12 -o certificate.txt
   ```
3. Add as repository secret:
   - Go to **Settings** → **Secrets and variables** → **Actions**
   - Click **New repository secret**
   - Name: `SIGNING_CERTIFICATE`
   - Value: Contents of certificate.txt

**Note**: Currently, the workflow uses `ldid-procursus` for signing, which doesn't require additional certificates. This secret is only needed if you modify the workflow to use custom signing.

---

## Expected Outputs

### Build Artifacts

After a successful build, the following artifacts are created:

#### 1. TrollStore.tar
- **Location**: `_build/TrollStore.tar`
- **Description**: Main TrollStore package containing all components
- **Size**: ~15-20 MB
- **Usage**: Primary distribution package

#### 2. Installer IPAs
- **TrollHelper_iOS15.ipa**: Installer for iOS 15+ devices
- **TrollHelper_arm64e.ipa**: Installer for arm64e devices
- **Location**: `_build/` directory
- **Size**: ~5-8 MB each
- **Usage**: Initial installation on devices

#### 3. DEB Packages
- **TrollHelper packages**: Standard and rootless variants
- **TrollStoreLite packages**: Lite version packages
- **Location**: Various `.theos/packages/` directories
- **Size**: ~2-5 MB each
- **Usage**: Package manager installation

### GitHub Actions Artifacts

**Artifact Name**: `trollstore-build-{version}-{commit-sha}`

**Contents**: All build outputs (tar, ipa, deb files)

**Retention**: 90 days

**Download**: 
1. Go to **Actions** tab
2. Click on the workflow run
3. Scroll to **Artifacts** section
4. Click artifact name to download

### GitHub Releases

**Created When**: Push to main/release branch or version tag

**Release Name**: `TrollStore v{version}`

**Tag Name**: `v{version}`

**Contents**:
- Release notes with build information
- All build artifacts attached
- Prerelease flag for non-stable versions

---

## Usage Guide

### Building a Development Version

1. Push changes to `develop` branch:
   ```bash
   git checkout develop
   git add .
   git commit -m "Your changes"
   git push origin develop
   ```

2. Workflow automatically triggers and builds

3. Download artifacts from Actions tab

### Creating a Release

#### Option 1: Using Version Tags (Recommended)

1. Update version in `TrollStore/Resources/Info.plist`

2. Commit and create version tag:
   ```bash
   git add TrollStore/TrollStore/Resources/Info.plist
   git commit -m "Bump version to 2.0.0"
   git tag v2.0.0
   git push origin main
   git push origin v2.0.0
   ```

3. Workflow triggers and creates GitHub release automatically

#### Option 2: Push to Release Branch

1. Merge changes to `release` or `main` branch:
   ```bash
   git checkout main
   git merge develop
   git push origin main
   ```

2. Workflow triggers and creates release with version from Info.plist

### Manual Build

1. Go to **Actions** tab
2. Select **Build and Release TrollStore**
3. Click **Run workflow**
4. Select branch (e.g., `develop`, `main`)
5. Click **Run workflow** button
6. Monitor build progress in real-time
7. Download artifacts when complete

### Testing Changes

For testing workflow changes without creating releases:

1. Create a feature branch:
   ```bash
   git checkout -b test-workflow-changes
   ```

2. Modify workflow file

3. Push to feature branch:
   ```bash
   git push origin test-workflow-changes
   ```

4. Manually trigger workflow on feature branch

5. Verify build succeeds (no release will be created)

---

## Troubleshooting

### Common Issues and Solutions

#### Issue 1: Build Fails with "Command not found: make"

**Symptom**: Error message indicating `make` command not found

**Cause**: GNU make not in PATH or not installed

**Solution**: 
- Workflow automatically adds GNU make to PATH
- If issue persists, verify Homebrew installation step succeeded
- Check that `/opt/homebrew/opt/make/libexec/gnubin` is in PATH

#### Issue 2: THEOS Framework Not Found

**Symptom**: Error messages about missing THEOS or THEOS not set

**Cause**: THEOS checkout failed or cache corrupted

**Solution**:
1. Check THEOS checkout step in workflow logs
2. Verify network connectivity to github.com
3. Clear cache by changing cache key in workflow file
4. Re-run workflow

#### Issue 3: Missing iOS SDKs

**Symptom**: Compilation errors about missing SDK files

**Cause**: SDK checkout failed or wrong SDK version

**Solution**:
1. Verify SDK checkout step succeeded
2. Check that SDKs are in `$THEOS/sdks/` directory
3. Ensure sparse-checkout includes required SDK versions
4. Re-run workflow

#### Issue 4: Dependency Installation Timeout

**Symptom**: Homebrew installation step times out or hangs

**Cause**: Network issues or Homebrew update running

**Solution**:
- Workflow sets `HOMEBREW_NO_AUTO_UPDATE=1` to prevent updates
- Check GitHub Actions status page for macOS runner issues
- Re-run workflow (cache will speed up subsequent attempts)

#### Issue 5: Build Succeeds but No Artifacts

**Symptom**: Build completes but artifact upload fails or no files found

**Cause**: Build outputs not in expected locations

**Solution**:
1. Check "List collected artifacts" step in logs
2. Verify `_build/` directory exists and contains files
3. Check Makefile targets completed successfully
4. Review "Collect build outputs" step for errors

#### Issue 6: Release Creation Fails

**Symptom**: Build succeeds but release not created

**Cause**: Insufficient permissions or wrong branch

**Solution**:
1. Verify workflow triggered on `main`, `release`, or version tag
2. Check repository settings for Actions permissions
3. Ensure `GITHUB_TOKEN` has `contents: write` permission
4. Verify version extraction succeeded (check logs)

#### Issue 7: Cache Not Working

**Symptom**: Every build takes full time, cache not restored

**Cause**: Cache key mismatch or cache expired

**Solution**:
1. Check cache restore step in logs
2. Verify cache key matches between save and restore
3. Cache expires after 7 days of no access
4. Workflow file changes invalidate cache (by design)

#### Issue 8: Xcode Version Mismatch

**Symptom**: Compilation errors related to SDK or Xcode version

**Cause**: Wrong Xcode version or SDK incompatibility

**Solution**:
1. Verify Xcode 15.4 is installed (check setup step)
2. Ensure iOS SDK versions match Makefile requirements
3. Update workflow to use compatible Xcode version if needed

#### Issue 9: Submodule Checkout Fails

**Symptom**: Missing ChOma or other submodule files

**Cause**: Submodules not initialized or checkout failed

**Solution**:
1. Verify checkout step includes `submodules: recursive`
2. Check submodule URLs are accessible
3. Ensure `.gitmodules` file is correct
4. Re-run workflow

#### Issue 10: Artifact Upload Fails with "No files found"

**Symptom**: Upload artifact step fails with error about missing files

**Cause**: Build failed silently or artifacts not collected

**Solution**:
1. Check build step exit code (should be 0)
2. Review build logs for compilation errors
3. Verify artifact collection steps found files
4. Check `artifacts/` directory contents in logs

### Debugging Failed Builds

When a build fails, the workflow automatically uploads partial artifacts for debugging:

**Artifact Name**: `failed-build-artifacts-{commit-sha}`

**Contents**:
- Partial build outputs from `_build/`
- Object files from `.theos/obj/`
- Any generated packages from `.theos/packages/`

**Retention**: 30 days

**How to Debug**:
1. Download failed build artifacts
2. Review workflow logs for error messages
3. Check compilation errors in build step
4. Verify all dependencies installed correctly
5. Test build locally with same environment

### Getting Help

If you encounter issues not covered here:

1. **Check Workflow Logs**: Detailed logs available in Actions tab
2. **Review Build Output**: Look for specific error messages
3. **Verify Environment**: Ensure all dependencies installed
4. **Test Locally**: Try building with same commands locally
5. **Check GitHub Status**: Verify GitHub Actions service status
6. **Open Issue**: Create issue with workflow logs and error details

---

## Performance and Optimization

### Build Time Breakdown

Typical build times for each phase:

| Phase | First Run | Cached Run |
|-------|-----------|------------|
| Environment Setup | 2-3 min | 2-3 min |
| Dependency Installation | 8-10 min | 1-2 min |
| Build Execution | 8-12 min | 8-12 min |
| Artifact Collection | 1 min | 1 min |
| **Total** | **20-25 min** | **12-18 min** |

### Cache Strategy

The workflow implements caching for:

1. **Homebrew Packages**
   - Cache key includes package list
   - Saves ~5-8 minutes per build
   - Invalidates when workflow file changes

2. **THEOS Framework**
   - Cache key includes THEOS commit reference
   - Saves ~2-3 minutes per build
   - Invalidates when workflow file changes

### Optimization Tips

1. **Avoid Unnecessary Builds**
   - Use branch protection to prevent accidental triggers
   - Consider using `paths` filter to only build on relevant changes

2. **Parallel Builds**
   - Makefile already uses parallel compilation
   - macOS-14 runner has 3 cores available

3. **Cache Management**
   - Caches expire after 7 days of no use
   - Total cache size limit: 10 GB per repository
   - Workflow uses ~2-3 GB of cache

4. **Cost Optimization**
   - macOS runners: 10x multiplier (10 min = 100 billable minutes)
   - Expected cost: 100-250 billable minutes per build
   - Use caching to reduce costs
   - Limit builds to important branches

### Monitoring

Track these metrics to monitor workflow health:

- **Build Success Rate**: Target >95%
- **Build Duration**: Target <15 minutes with cache
- **Cache Hit Rate**: Target >80%
- **Artifact Size**: Monitor for unexpected growth
- **Runner Costs**: Track billable minutes usage

---

## Workflow Configuration Reference

### Environment Variables

| Variable | Value | Purpose |
|----------|-------|---------|
| `THEOS` | `${{ github.workspace }}/theos` | THEOS installation path |
| `THEOS_PACKAGE_SCHEME` | `rootless` | Package scheme for THEOS |
| `FINALPACKAGE` | `1` | Enable final package mode |

### Timeouts

| Step | Timeout | Reason |
|------|---------|--------|
| Entire Job | 60 minutes | Prevent runaway builds |
| Build Step | 45 minutes | Allow time for full compilation |

### Retention Periods

| Artifact Type | Retention | Reason |
|---------------|-----------|--------|
| Successful Build | 90 days | Long-term access |
| Failed Build | 30 days | Debugging only |

---

## Maintenance

### Regular Maintenance Tasks

1. **Update Xcode Version** (Quarterly)
   - Check for new Xcode releases
   - Update `xcode-version` in workflow
   - Test build compatibility

2. **Update Dependencies** (Monthly)
   - Review Homebrew package versions
   - Update THEOS commit reference if needed
   - Test with updated dependencies

3. **Review Cache Strategy** (Monthly)
   - Monitor cache hit rates
   - Adjust cache keys if needed
   - Clean up old caches

4. **Monitor Costs** (Monthly)
   - Review GitHub Actions usage
   - Optimize build frequency if needed
   - Consider self-hosted runners for high volume

### Updating the Workflow

When modifying the workflow:

1. Create feature branch for changes
2. Test on feature branch first
3. Review logs for any issues
4. Merge to main after successful test
5. Monitor first production build closely

### Version History

Track workflow changes in git history:

```bash
# View workflow file history
git log --follow .github/workflows/build-release.yml

# Compare workflow versions
git diff <old-commit> <new-commit> .github/workflows/build-release.yml
```

---

## Additional Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [THEOS Documentation](https://theos.dev/)
- [LuiseStore Repository](https://github.com/xztimee/LuiseStore)
- [Original TrollStore Repository](https://github.com/opa334/TrollStore)
- [GitHub Actions Workflow Syntax](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions)

---

## Support

For workflow-specific issues:
- Check this documentation first
- Review workflow logs in Actions tab
- Open issue with detailed error information

For TrollStore build issues:
- Refer to TrollStore repository documentation
- Check Makefile and build scripts
- Test local build first

---

*Last Updated: December 2024*
*Workflow Version: 1.0*
