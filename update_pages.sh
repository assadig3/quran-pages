#!/bin/bash
set -e

BRANCH="main"
PAGES_DIR="pages"

# تأكد أننا داخل ريبو
[ -d ".git" ] || { echo "❌ شغّل السكربت من داخل quran-pages"; exit 1; }

echo "🔄 تحديث الفرع..."
git fetch origin >/dev/null 2>&1 || true
git checkout "$BRANCH"
git pull --rebase origin "$BRANCH"

# تحقّق سريع
COUNT=$(ls "$PAGES_DIR"/page_*.webp 2>/dev/null | wc -l)
if [ "$COUNT" -ne 604 ]; then
  echo "❌ عدد الملفات داخل $PAGES_DIR هو $COUNT وليس 604."
  exit 1
fi
echo "✅ تم التحقق: 604 صورة."

echo "📤 إضافة ورفع التغييرات..."
git add "$PAGES_DIR"
if git diff --cached --quiet; then
  echo "ℹ️ لا تغييرات مرصودة — إجبار تحديث الطوابع الزمنية..."
  find "$PAGES_DIR" -name 'page_*.webp' -exec touch {} \;
  git add "$PAGES_DIR"
fi
git commit -m "Add/Update Quran pages (604 files)"
git push origin "$BRANCH"

# إنشاء Tag لتجاوز الكاش
TAG="v$(date +%Y%m%d%H%M%S)"
git tag "$TAG"
git push origin "$TAG"

echo "🎉 تم الرفع وإنشاء التاج: $TAG"
echo "🔗 مثال jsDelivr:"
echo "https://cdn.jsdelivr.net/gh/assadig3/quran-pages@$TAG/pages/page_1.webp"
