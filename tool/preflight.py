#!/usr/bin/env python3
"""Release preflight for Google Play. Run before every upload:

    python3 tool/preflight.py

Checks the things that make Play reject an upload or that silently cost
revenue (test ads in production). See docs/PLAY_STORE.md for the full list.
Exit code 1 if any blocking check fails.
"""

import glob
import hashlib
import os
import re
import struct
import subprocess
import zipfile

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))
TEST_APP_IDS = {'ca-app-pub-3940256099942544~3347511713', 'ca-app-pub-3940256099942544~1458002511'}
TEST_PUBLISHER = 'ca-app-pub-3940256099942544'
FLUTTER_DEFAULT_ICON_MD5 = '57838d52c318faff743130c3fcfae0c6'
AAB = os.path.join(ROOT, 'build/app/outputs/bundle/release/app-release.aab')

results = []


def check(name, ok, detail='', blocking=True):
    results.append((ok, blocking, name, detail))


def read(path):
    with open(os.path.join(ROOT, path), encoding='utf-8') as f:
        return f.read()


# 1. Upload key (Play rejects bundles signed with the debug key).
check('Upload key configured (android/key.properties)',
      os.path.exists(os.path.join(ROOT, 'android/key.properties')),
      'Create an upload keystore and android/key.properties (see README).')

# 2. Real AdMob IDs (test IDs earn nothing in production).
manifest = read('android/app/src/main/AndroidManifest.xml')
app_ids = re.findall(r'ca-app-pub-\d+~\d+', manifest)
check('AdMob App ID is your own (AndroidManifest.xml)',
      bool(app_ids) and not set(app_ids) & TEST_APP_IDS,
      f'Found {app_ids}. Replace with the App ID from apps.admob.com.')
ads = read('lib/ads/ad_service.dart')
release_ids = re.findall(r"_release\w+ =\s*'([^']+)'", ads)
release_refs = re.findall(r'_release\w+ =\s*(_test\w+);', ads)
check('Release ad unit IDs are your own (lib/ads/ad_service.dart)',
      not release_refs and release_ids and all(TEST_PUBLISHER not in i for i in release_ids),
      'Set _releaseRewarded*/_releaseInterstitial* to your real ad unit IDs.')

# 3. Privacy policy filled in.
privacy = read('PRIVACY.md')
check('Privacy policy has no placeholders (PRIVACY.md)',
      '[YOUR' not in privacy and '[DATE]' not in privacy,
      'Fill in your name, contact email and date, then host it at a public URL.')

# 4. Real app icon.
icon = os.path.join(ROOT, 'android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png')
with open(icon, 'rb') as f:
    md5 = hashlib.md5(f.read()).hexdigest()
check('App icon is not the Flutter default', md5 != FLUTTER_DEFAULT_ICON_MD5,
      'Run python3 tool/generate_icons.py')
check('Adaptive icon present', os.path.exists(os.path.join(
    ROOT, 'android/app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml')))

# 5. Store listing graphics.
check('Store icon 512x512 (store/icon-512.png)', os.path.exists(os.path.join(ROOT, 'store/icon-512.png')))
check('Feature graphic 1024x500 (store/feature-graphic.png)',
      os.path.exists(os.path.join(ROOT, 'store/feature-graphic.png')))
shots = glob.glob(os.path.join(ROOT, 'store/screenshots/*.png'))
check('At least 2 phone screenshots (store/screenshots)', len(shots) >= 2, f'{len(shots)} found')

# 6. Version.
version = re.search(r'^version:\s*(\S+)', read('pubspec.yaml'), re.M).group(1)
check(f'Version {version} (bump +build for every upload)', True, blocking=False)

# 7. Built bundle: signing, target SDK and 16 KB page alignment.
if os.path.exists(AAB):
    try:
        out = subprocess.run(['keytool', '-printcert', '-jarfile', AAB],
                             capture_output=True, text=True).stdout
        check('App bundle is not signed with the debug key',
              'CN=Android Debug' not in out and 'Owner' in out,
              'Build after creating key.properties: flutter build appbundle --release')
    except FileNotFoundError:
        check('App bundle signature (keytool not found)', False, blocking=False)
    with zipfile.ZipFile(AAB) as z:
        bad = []
        for name in z.namelist():
            if not (name.endswith('.so') and ('arm64' in name or 'x86_64' in name)):
                continue
            d = z.read(name)
            phoff = struct.unpack_from('<Q', d, 0x20)[0]
            phentsize, phnum = struct.unpack_from('<HH', d, 0x36)
            for i in range(phnum):
                o = phoff + i * phentsize
                if struct.unpack_from('<I', d, o)[0] == 1 and struct.unpack_from('<Q', d, o + 48)[0] < 16384:
                    bad.append(name)
                    break
        check('Native libraries support 16 KB pages', not bad, ', '.join(bad))
else:
    check('Release bundle built (flutter build appbundle --release)', False,
          'Build it, then re-run preflight to check signing and 16 KB pages.')

print()
failed = 0
for ok, blocking, name, detail in results:
    mark = 'PASS' if ok else ('FAIL' if blocking else 'WARN')
    failed += (not ok and blocking)
    print(f'  [{mark}] {name}')
    if not ok and detail:
        print(f'         -> {detail}')
print()
print('Ready to upload.' if not failed else f'{failed} blocking item(s) left before uploading to Play.')
raise SystemExit(1 if failed else 0)
