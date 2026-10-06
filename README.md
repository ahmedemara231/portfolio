# Ahmed Emara · Portfolio & Studio

A Flutter web workspace with a public portfolio, a content dashboard, and shared models, design tokens, assets, and persistence in `packages/core`. The redesign keeps Firebase/Firestore and the existing Flutter stack.

## Local preview

Run from the workspace root:

```sh
./tools/build_preview.sh
```

Open [the portfolio](http://localhost:4173/) and [the dashboard](http://localhost:4173/admin/). Both apps are served on the same origin and share durable browser storage. Edits update an open portfolio tab and survive reloads. The dashboard identifies this as **Local preview**. This mode does not connect to Firebase or change production data, and has no production authentication requirement. Use it only as a development preview.

Generated preview builds and browser captures live in `.preview`, outside the source diff. To use existing builds, run `python3 tools/preview_server.py`. It uses `.preview/local` when available and falls back to the apps' `build/web` directories. To run each app independently, use the existing Melos scripts; separate origins do not share local browser data. Firebase mode works across different origins.

## Content and editing

The public site presents a compact introduction, four selected projects, experience, three Flutter packages, grouped capabilities, education, and contact. `/projects` contains the full collection and domain filters. `/projects/<slug>` is a shareable case study. Empty contribution, challenge, technology, and outcome sections are omitted.

Shared motion tokens live in `packages/core/lib/src/design/design_system.dart`. `Entrance` reveals content once as it reaches its scroll viewport, then removes its scroll listener. Native button states drive feedback, with a shared browser observer providing immediate press feedback for accessible web buttons. It only affects painting and leaves actions and event handling to Flutter. `MotionSurface` adds card lift and press motion. Gallery changes and filters use `MotionSwap`, while `showContentDialog` gives previews a consistent entrance and keeps dashboard dialogs inside the authenticated navigator. Reduced-motion preferences disable these effects. Outgoing gallery and filter content immediately loses pointer, keyboard, and screen-reader actions, and changing screenshots resets zoom.

The Studio manages profile and contact, CV uploads, availability, all project fields, galleries, verified links, draft/publication state, featured selection and order, experience dates, packages, capabilities, education, credibility, social links, and page metadata. Separate arrows change collection order and featured order. All changes persist; previews can show an unsaved project without publishing it. Editors protect unsaved changes, validate inputs, confirm deletion, and report failed writes.

The dashboard uses the portfolio’s shared typography, warm surfaces, teal accent, and logo. Overview shows the actual published home-page lineup and introduction, plus content counts and recent edits. Project lists show screenshots, publication status, categories, and available store links. Featured work has a project picker that saves selection immediately and keeps drafts private. Grouped editors include unsaved introduction and case-study previews, screenshot viewing and removal with Undo, and named project references for capabilities. Profile & contact and Search & sharing have previews of their saved content. Existing records and unknown fields are retained.

Local uploads are limited to 900 KB per file to respect browser storage quotas. Firebase mode accepts screenshots under 8 MB and PDFs under 5 MB. Draft screenshot uploads use authorized Storage reads, without public download-token URLs. CVs are intentionally public. Existing media URLs remain editable.

The contact form writes to the `messages` collection in the `portfolio-60d78` Firestore database, with validation and a two-minute backend cooldown. It shows success only after Firestore confirms the message and cooldown writes. Explicit local previews store test messages in browser storage instead. The email action always works independently. Replies open your mail client; delivery is handled by that client. This application does not claim to send email itself.

## Firebase mode and production preparation

Firebase is the default backend for both apps, including ordinary `flutter build web` builds. Explicit local previews and local-storage tests use `--dart-define=USE_FIREBASE=false`; production builds omit `USE_EMULATORS`. The existing Firebase project configuration is retained. The dashboard opens directly without an email/password page or an administrator gate. Its URL is publicly accessible. Firebase rules still govern access to documents and uploads; the repository rules require an `admin: true` claim for management operations, and the live backend protects the inbox separately. Anonymous Authentication must be enabled to use the contact form. You can hide the form in Profile & contact and keep the direct email action.

Anonymous Authentication and the contact collections' validation, cooldown, and private-read rules are configured in `portfolio-60d78`. Before deploying the full content rules and redesigned Firebase apps:

1. Review [the audit and discrepancies](docs/content-audit.md).
2. Configure authentication and assign the owner's custom claim.
3. Back up the database. Run the additive migration script in dry-run mode and inspect its plan before applying it. Legacy records need `status`, and projects need stable `slug` fields before the new published-only public queries are used.
4. Review and deploy `firestore.rules` and `storage.rules`. Enable Storage/Firestore rule integration for publication-aware screenshot reads. Configure bucket CORS for the public and dashboard origins if required.
5. Complete or import the reviewed CV content through the dashboard. Migration preserves existing wording and links; it does not silently replace live content with the local fixture.
6. Export published content from Search & sharing, then generate metadata from that export for the production build.

```sh
cd tools/security
npm install
cd ../..
node tools/security/migrate.mjs --project portfolio-60d78
# Review .backups/<timestamp>/before.json and migration-plan.json.
# --apply is the explicit write option; it is never the default.
```

The migration uses application-default administrator credentials. It only adds missing publication, address, and ordering fields, rechecking each document in a transaction. Existing descriptions, links, and unknown fields remain intact. For legacy projects with no featured choices, add `--feature-legacy-projects` to select the first four published projects in their saved order; existing featured choices and drafts are preserved. New draft documents require an explicit status and cannot be read by public queries or direct Firestore requests.

Firebase Hosting configuration for each existing site is retained. Vercel configurations retain the current Flutter outputs and routes; generated project HTML must be copied with the build. No production publishing command was run.

After the preparation above, generate production artifacts explicitly. The existing Melos build scripts now select Firebase mode; the run scripts and local preview use browser storage. The local preview outputs are separate from the hosting directories; checked-in legacy builds are not the redesigned production artifacts.

```sh
(cd apps/portfolio && flutter build web --no-pub --no-wasm-dry-run \
  --dart-define=USE_FIREBASE=true)
(cd apps/dashboard && flutter build web --no-pub --no-wasm-dry-run \
  --dart-define=USE_FIREBASE=true)
python3 tools/export_metadata.py --content /path/to/portfolio-content.json \
  --web-root apps/portfolio/build/web
```

## Firebase Hosting deployment

Both Hosting sites (`portfolio-ce1ae` and `dashboard-93da1`) belong to the Firebase project `portfolio-ce1ae`. The apps use the separate project `portfolio-60d78` for Authentication, Firestore, and Storage. The `.firebaserc` files select the Hosting project by default; the root also defines a `backend` alias for `portfolio-60d78`. When deploying Firestore or Storage rules, explicitly pass `--project portfolio-60d78` (or `--project backend` from the workspace root).

After generating the production artifacts above, deploy the portfolio from the workspace root:

```sh
firebase use default
firebase deploy --only hosting
```

`firebase use default` overrides any active project inherited from a parent directory. The root Hosting configuration serves `apps/portfolio/build/web`. The same commands work from `apps/portfolio`, where the app configuration serves `build/web`.

Deploy the dashboard separately from its directory:

```sh
cd apps/dashboard
firebase use default
firebase deploy --only hosting
```

## Search, sharing, and static fallback

`tools/export_metadata.py` builds semantic HTML fallback pages, route-specific titles/descriptions, Open Graph metadata, canonical links, Person structured data, a sitemap, and robots directives from the same content model. It excludes drafts and escapes user content. The fallback is readable before Flutter starts or if it fails to load. Published-content exports convert hosted screenshot references into public URLs governed by the publication rules, without creating download tokens; supported local image uploads also remain visible in generated pages.

```sh
python3 tools/export_metadata.py --content /path/to/portfolio-content.json
```

Flutter updates browser titles and metadata immediately after edits. Search crawlers and sharing services can use the generated HTML. **Static fallback and social previews require regeneration and a rebuild after public content or publication changes.** They are a snapshot, not server rendering. Previously published fallback pages must be removed when unpublishing a project; the exporter cleans its generated route directory on each run. Flutter's [app-centric web rendering](https://docs.flutter.dev/platform-integration/web/faq#search-engine-optimization-seo) still limits dynamic indexing compared with a server-rendered document site.

## Checks

```sh
dart analyze .
(cd apps/portfolio && flutter test --no-pub --dart-define=USE_FIREBASE=false)
(cd apps/dashboard && flutter test --no-pub --dart-define=USE_FIREBASE=false)
python3 tools/test_metadata.py
node --test tools/security/migration_plan.test.mjs
firebase emulators:exec --project demo-portfolio --only firestore,storage \
  'node --test tools/security/rules.test.mjs'
```

Install `tools/security` dependencies before rule tests. Rule tests cover anonymous and non-admin denial, direct draft access, publication, atomic ordering, message privacy and throttling, and private screenshot reads. Flutter tests cover persistence, case-study compatibility, ordering, editorial layouts from 320 to 1920 pixels, reduced motion, and unsaved editor changes.

Motion tests also cover visibility-triggered reveals, stable tap targets, keyboard activation, canceled presses, and outgoing preview accessibility.

Browser verification uses Playwright and local Chrome. Install `tools/browser` dependencies and run `npm test` there while the preview is running. It exercises actual controls, saves and reloads content, checks public publication behavior, and captures responsive screenshots in `.preview`.

Run `npm run test:projects` for a read-only check of homepage selection, the full project collection, case-study navigation and reload, and mobile content. Set `PORTFOLIO_PREVIEW_URL`, `EXPECTED_PROJECTS`, and `EXPECTED_FEATURED` to check a deployed portfolio; the defaults verify the local fixture with eleven projects and four selections.

Run `npm run test:studio` for the redesigned dashboard workflows: featured selection and persistence, unsaved profile previews, capability references, screenshot viewing and ordering, and compact navigation and editors. Captures are written to `.preview/studio`. The script only accepts a local preview URL.

Run `npm run test:motion` in the same directory to exercise real pointer feedback, gallery and dashboard preview transitions, responsive scrolling, and reduced motion. Animation captures are written to `.preview/motion`.

Run `npm run test:dashboard-access` in `tools/browser` against a dashboard build served at `http://localhost:4185` (or set `DASHBOARD_PREVIEW_URL`) to check direct access from a fresh browser, reloads, mobile navigation, and the absence of login controls. This check does not write data.

Run `node tools/browser/auth_verify.cjs` with the Firebase integration preview to check direct dashboard access, backend-authorized persistence, public updates, metadata exports, anonymous contact submissions, and mobile inbox dialogs. `node tools/browser/media_verify.cjs` checks actual uploads, private draft media, publication, safe deletion, and CV downloads. These integration scripts authenticate the seeded emulator owner programmatically for protected backend operations; there is no dashboard login page. Demo sessions are tab-scoped so public visitors and the owner can be exercised independently on the local shared origin.

Run `npm run test:contact` in `tools/browser` with the Firebase integration preview to verify the contact form creates a document in the emulator's `messages` collection, persists its fields and server timestamp, and reports cooldown rejection without showing success. This check also requires `tools/security` dependencies and removes only the emulator message and cooldown record it creates.

## Local Firebase integration preview

```sh
firebase emulators:start --project demo-portfolio --only firestore,auth,storage
# In another terminal:
FIRESTORE_EMULATOR_HOST=127.0.0.1:8080 \
FIREBASE_AUTH_EMULATOR_HOST=127.0.0.1:9099 \
  node tools/security/seed_emulators.mjs
(cd apps/portfolio && flutter build web --debug --no-pub --no-wasm-dry-run \
  --dart-define=USE_FIREBASE=true --dart-define=USE_EMULATORS=true \
  --output ../../.preview/firebase/portfolio)
(cd apps/dashboard && flutter build web --debug --no-pub --no-wasm-dry-run --base-href /admin/ \
  --dart-define=USE_FIREBASE=true --dart-define=USE_EMULATORS=true \
  --output ../../.preview/firebase/dashboard)
python3 tools/preview_server.py --port 4174 --firebase
```

Only the demo project is used with `USE_EMULATORS=true`. The seed tool refuses to run without emulator environment variables. Demo owner: `studio@example.test`; non-admin: `visitor@example.test`; local password for both: `local-preview-only`. These are local fixture accounts.

Use debug builds for this integration preview. FlutterFire restores emulator sign-in sessions before Firebase initialization only in debug mode; release builds use production Auth initialization. The ordinary local preview and production builds remain release builds.
