#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
flutter pub get
(cd apps/portfolio && flutter build web --no-pub --no-wasm-dry-run --dart-define=USE_FIREBASE=false --output ../../.preview/local/portfolio)
(cd apps/dashboard && flutter build web --no-pub --no-wasm-dry-run --dart-define=USE_FIREBASE=false --base-href /admin/ --output ../../.preview/local/dashboard)
python3 tools/export_metadata.py --web-root .preview/local/portfolio
python3 tools/preview_server.py --port "${PORTFOLIO_PREVIEW_PORT:-4173}"
