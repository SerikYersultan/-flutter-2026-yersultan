#!/usr/bin/env bash
# Practice 4 — full automated submission.
# Before: exit flutter run (q), phone shows taps>0, counter>0, stopwatch running.
set -e

PROJ=~/projects/reactive_screen
REPO=~/projects/course-repo

echo "========================================================"
echo "  Practice 4 — automated submission"
echo "========================================================"

# ---- 0. sanity ----
cd "$PROJ"
command -v flutter >/dev/null || { echo "flutter not in PATH"; exit 1; }
adb devices | grep -q "device$" || { echo "No adb device. Reconnect USB."; exit 1; }

# ---- 1. dispose test (widget test, no UI) ----
echo
echo "=== [1/5] dispose test ==="
mkdir -p test

# remove the default flutter counter test — it targets the old UI
rm -f test/widget_test.dart

cat > test/dispose_check_test.dart <<'EOF'
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reactive_screen/stopwatch_card.dart';

void main() {
  testWidgets('timer is cancelled on dispose', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: StopwatchCard()));
    await tester.tap(find.text('Start'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpWidget(const MaterialApp(home: SizedBox()));
    await tester.pump(const Duration(seconds: 3));
  });
}
EOF

echo "--- with correct dispose (expect PASS) ---"
flutter test test/dispose_check_test.dart

echo
echo "--- with dispose broken (expect FAIL with setState-after-dispose) ---"
cp lib/stopwatch_card.dart /tmp/stopwatch_card.bak
trap 'cp -f /tmp/stopwatch_card.bak lib/stopwatch_card.dart 2>/dev/null; rm -f test/dispose_check_test.dart' EXIT

python3 - <<'PY'
p = 'lib/stopwatch_card.dart'
s = open(p).read()
old = '  void dispose() {\n    _timer?.cancel();'
new = '  void dispose() {\n    // _timer?.cancel();'
assert old in s, "marker not found in stopwatch_card.dart"
open(p, 'w').write(s.replace(old, new, 1))
PY

if flutter test test/dispose_check_test.dart >/tmp/broken.log 2>&1; then
  echo "WARNING: test still passed with broken dispose - check /tmp/broken.log"
else
  echo "OK: test failed as expected"
  grep -m1 -i "dispose" /tmp/broken.log || true
fi

cp -f /tmp/stopwatch_card.bak lib/stopwatch_card.dart
rm -f test/dispose_check_test.dart
trap - EXIT

# ---- 2. screenshot ----
echo
echo "=== [2/5] screenshot ==="
adb exec-out screencap -p > "$PROJ/screenshot.png"
ls -lh "$PROJ/screenshot.png"
file "$PROJ/screenshot.png"

# ---- 3. format + analyze ----
echo
echo "=== [3/5] format + analyze ==="
cd "$PROJ"
dart format .
flutter analyze

# ---- 4. copy to course-repo ----
echo
echo "=== [4/5] copy to course-repo/practice4/ ==="
rsync -a --delete \
  --exclude='.git' --exclude='build' --exclude='.dart_tool' \
  "$PROJ/" "$REPO/practice4/"

echo "practice4/:"
ls "$REPO/practice4/"
echo "practice4/lib/:"
ls "$REPO/practice4/lib/"

# ---- 5. git push ----
echo
echo "=== [5/5] git commit + push ==="
cd "$REPO"
git add -A
git status --short
git commit -m "Practice 4: A Screen That Reacts (TapCard, TwoWayCounter, StopwatchCard)"
git push

echo
echo "========================================================"
echo "  DONE. Check: https://github.com/SerikYersultan/-flutter-2026-yersultan"
echo "========================================================"
