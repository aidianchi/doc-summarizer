#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LINTER="$ROOT_DIR/scripts/lint-vault-output"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

mkdir -p "$TMP_DIR/3知识/概念卡" "$TMP_DIR/4归档箱"

cat > "$TMP_DIR/3知识/好总结深度总结.md" <<'MD'
---
title: "好总结深度总结"
date: 2026-05-08
tags: [投资, 价值投资, 巴菲特]
source: "[[好原文]]"
---

# 好总结深度总结

关键判断来自 [[好原文#^para01]]。
MD

cat > "$TMP_DIR/4归档箱/好原文.md" <<'MD'
---
title: 好原文
date: 2026-05-08
tags: [投资, 价值投资]
source: "test"
---

# 好原文

这是一段完整原文。 ^para01

---

## 深度总结

本文的深度总结：[[好总结深度总结]]
MD

cat > "$TMP_DIR/3知识/概念卡/好概念.md" <<'MD'
---
title: 好概念
tags: [概念卡, 投资]
---

# 好概念

## 一句话定义
一个测试概念。

---
*源自：[[好总结深度总结]]*
MD

"$LINTER" "$TMP_DIR" \
  "$TMP_DIR/3知识/好总结深度总结.md" \
  "$TMP_DIR/4归档箱/好原文.md" \
  "$TMP_DIR/3知识/概念卡/好概念.md"

cat > "$TMP_DIR/3知识/坏总结深度总结.md" <<'MD'
---
title: "坏总结深度总结"
tags: [投资]
---

# 坏总结深度总结

残留占位符 [[来源#^para01]]，以及无文件名块链 [[#^para02]]。
MD

if "$LINTER" "$TMP_DIR" "$TMP_DIR/3知识/坏总结深度总结.md" > "$TMP_DIR/bad.out" 2>&1; then
  echo "Expected bad summary to fail lint, but it passed" >&2
  exit 1
fi

grep -q "placeholder" "$TMP_DIR/bad.out"
grep -q "bare block link" "$TMP_DIR/bad.out"
grep -q "missing source" "$TMP_DIR/bad.out"

echo "lint-vault-output tests passed"
