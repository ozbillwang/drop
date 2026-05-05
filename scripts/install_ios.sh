#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEAM_ID="${TEAM_ID:-XU3NCVBCUZ}"
BUNDLE_ID="${BUNDLE_ID:-com.ozbillwang.drop}"
DEVICE_ID="${DEVICE_ID:-00008150-0004748A0AC0401C}"
CORE_DEVICE_ID="${CORE_DEVICE_ID:-A80C370A-7E87-57F2-8950-4DD439EA9848}"
GODOT_BIN="${GODOT_BIN:-godot}"
TEMPLATE_VERSION="4.6.stable"
TEMPLATE_URL="https://github.com/godotengine/godot/releases/download/4.6-stable/Godot_v4.6-stable_export_templates.tpz"
TEMPLATE_DIR="$HOME/Library/Application Support/Godot/export_templates/$TEMPLATE_VERSION"

cd "$ROOT"

mkdir -p "$TEMPLATE_DIR" build/templates build/ios/manual
if [[ ! -f "$TEMPLATE_DIR/ios.zip" ]]; then
  curl -L --fail -o build/templates/Godot_v4.6-stable_export_templates.tpz "$TEMPLATE_URL"
  rm -rf build/templates/unpacked
  unzip -q -o build/templates/Godot_v4.6-stable_export_templates.tpz -d build/templates/unpacked
  cp -R build/templates/unpacked/templates/* "$TEMPLATE_DIR/"
fi

"$GODOT_BIN" --headless --path "$ROOT" --export-pack "iOS" build/ios/manual/Drop.pck

rm -rf build/ios/template build/ios/xcode build/ios/DerivedData
mkdir -p build/ios/template
unzip -q "$TEMPLATE_DIR/ios.zip" -d build/ios/template
cp -R build/ios/template build/ios/xcode
cp build/ios/manual/Drop.pck build/ios/xcode/data.pck

python3 - <<PY
from pathlib import Path
import shutil

root = Path("build/ios/xcode")
app_dir = root / "godot_apple_embedded"
(app_dir / "godot_apple_embedded-Info.plist").rename(app_dir / "Drop-Info.plist")
(app_dir / "godot_apple_embedded.entitlements").rename(app_dir / "Drop.entitlements")
app_dir.rename(root / "Drop")
(root / "data.pck").rename(root / "Drop.pck")
for name in ["libgodot.ios.release.xcframework", "libgodot.visionos.release.xcframework", "libgodot.visionos.debug.xcframework"]:
    path = root / name
    if path.exists():
        shutil.rmtree(path)
(root / "libgodot.ios.debug.xcframework").rename(root / "Drop.xcframework")

pbx = root / "godot_apple_embedded.xcodeproj/project.pbxproj"
s = pbx.read_text()
repls = {
    "\$binary": "Drop",
    "\$name": "Drop",
    "\$team_id": "$TEAM_ID",
    "\$bundle_identifier": "$BUNDLE_ID",
    "\$code_sign_identity_debug": "Apple Development",
    "\$code_sign_identity_release": "Apple Development",
    "\$code_sign_style_debug": "Automatic",
    "\$code_sign_style_release": "Automatic",
    "\$godot_archs": "arm64",
    "\$valid_archs": "arm64",
    "\$sdkroot": "iphoneos",
    "\$targeted_device_family": "1",
    "\$short_version": "0.1",
    "\$version": "1.0.0",
    "\$provisioning_profile_uuid_debug": "",
    "\$provisioning_profile_uuid_release": "",
    "\$provisioning_profile_specifier_debug": "",
    "\$provisioning_profile_specifier_release": "",
    "\$linker_flags": "",
    "\$os_deployment_target": "IPHONEOS_DEPLOYMENT_TARGET = 14.0;",
    "\$modules_buildfile": "", "\$modules_fileref": "", "\$modules_buildphase": "", "\$modules_buildgrp": "",
    "\$additional_pbx_files": "", "\$additional_pbx_frameworks_build": "", "\$additional_pbx_frameworks_refs": "",
    "\$additional_pbx_resources_build": "", "\$additional_pbx_resources_refs": "",
    "\$pbx_embeded_frameworks": "",
    "\$pbx_launch_screen_build_reference": "D0BCA00118AEBFEB004A7AAE /* Launch Screen.storyboard in Resources */ = {isa = PBXBuildFile; fileRef = D0BCA00018AEBFEB004A7AAE /* Launch Screen.storyboard */; };",
    "\$pbx_launch_screen_file_reference": "D0BCA00018AEBFEB004A7AAE /* Launch Screen.storyboard */ = {isa = PBXFileReference; lastKnownFileType = file.storyboard; path = \\"Launch Screen.storyboard\\"; sourceTree = \\"<group>\\"; };",
    "\$pbx_launch_screen_copy_files": "D0BCA00018AEBFEB004A7AAE /* Launch Screen.storyboard */,",
    "\$pbx_launch_screen_build_phase": "D0BCA00118AEBFEB004A7AAE /* Launch Screen.storyboard in Resources */,",
    "\$pbx_locale_file_reference": "", "\$pbx_locale_build_reference": "",
    "\$moltenvk_buildfile": "D0MV000118AEBFEB004A7AAE /* MoltenVK.xcframework in Frameworks */ = {isa = PBXBuildFile; fileRef = D0MV000018AEBFEB004A7AAE /* MoltenVK.xcframework */; };",
    "\$moltenvk_fileref": "D0MV000018AEBFEB004A7AAE /* MoltenVK.xcframework */ = {isa = PBXFileReference; lastKnownFileType = wrapper.xcframework; name = MoltenVK; path = MoltenVK.xcframework; sourceTree = \\"<group>\\"; };",
    "\$moltenvk_buildphase": "D0MV000118AEBFEB004A7AAE /* MoltenVK.xcframework in Frameworks */,",
    "\$moltenvk_buildgrp": "D0MV000018AEBFEB004A7AAE /* MoltenVK.xcframework */,",
}
for k, v in repls.items():
    s = s.replace(k, v)
s = s.replace("\\n\\t\\t\\t\\tASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;", "")
pbx.write_text(s)

info = root / "Drop/Drop-Info.plist"
s = info.read_text()
for k, v in {
    "\$signature": "????",
    "\$docs_in_place": "<false/>",
    "\$docs_sharing": "<false/>",
    "\$required_device_capabilities": "<string>arm64</string>",
    "\$camera_usage_description": "",
    "\$photolibrary_usage_description": "",
    "\$microphone_usage_description": "",
    "\$interface_orientations": "<string>UIInterfaceOrientationLandscapeLeft</string>\\n\\t\\t<string>UIInterfaceOrientationLandscapeRight</string>",
    "\$ipad_interface_orientations": "<string>UIInterfaceOrientationLandscapeLeft</string>\\n\\t\\t<string>UIInterfaceOrientationLandscapeRight</string>",
    "\$additional_plist_content": "",
    "\$plist_launch_screen_name": "<key>UILaunchStoryboardName</key>\\n\\t<string>Launch Screen</string>",
}.items():
    s = s.replace(k, v)
info.write_text(s)

ent = root / "Drop/Drop.entitlements"
ent.write_text(ent.read_text().replace("\$entitlements_full", ""))

storyboard = root / "Drop/Launch Screen.storyboard"
s = storyboard.read_text().replace("\$launch_screen_image_mode", "scaleAspectFit")
s = s.replace("\$launch_screen_background_color", 'red="0" green="0" blue="0" alpha="1"')
storyboard.write_text(s)

dummy = root / "Drop/dummy.cpp"
dummy.write_text("void godot_apple_embedded_plugins_initialize() {}\\nvoid godot_apple_embedded_plugins_deinitialize() {}\\n")
PY

xcodebuild \
  -project build/ios/xcode/godot_apple_embedded.xcodeproj \
  -scheme Drop \
  -configuration Debug \
  -destination "id=$DEVICE_ID" \
  -derivedDataPath build/ios/DerivedData \
  -allowProvisioningUpdates \
  -allowProvisioningDeviceRegistration \
  DEVELOPMENT_TEAM="$TEAM_ID" \
  PRODUCT_BUNDLE_IDENTIFIER="$BUNDLE_ID" \
  CODE_SIGN_STYLE=Automatic \
  build

xcrun devicectl device install app \
  --device "$CORE_DEVICE_ID" \
  "$ROOT/build/ios/DerivedData/Build/Products/Debug-iphoneos/Drop.app"

xcrun devicectl device process launch \
  --device "$CORE_DEVICE_ID" \
  "$BUNDLE_ID"
