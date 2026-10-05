# Source review and decisions

The repository is a Dart workspace containing two Flutter web apps. Both use the shared `core` package and the same Firestore project, `portfolio-60d78`. Hosting configuration exists for the public and dashboard Firebase sites and Vercel. Existing collections include profile, projects, experiences, stats, social links, technical and soft skills, tools, about features, experience stats, messages, and activity. There were no checked-in authorization rules, no dashboard login, no gallery storage workflow, and no functioning routing for project case studies. Logout and View Portfolio actions were placeholders. The overview displayed hardcoded analytics.

The original UI was English, with some Arabic project content. No localization delegates, language selector, or translated resource files were present. Arabic project identities and actual Arabic app screenshots are retained. The CV lists Arabic as native and English as B1; the redesign does not invent language fluency.

The CV was found at `Downloads/Ahmed_Emara_Flutter_Developer.pdf` and read in full, including link annotations. An exact copy is bundled for download. Local preview content is normalized from its verified facts plus a read-only review of existing Firestore records. No live data was written.

## Discrepancies

| Item | Existing source | CV / decision for the local redesign |
| --- | --- | --- |
| Professional title | HTML claimed “Senior Flutter Developer” | “Flutter Developer”; no invented senior title. |
| Email | Profile says `emara@gmail.com`; social link says `emara8028@gmail.com` | CV and contact listing use `emara8028@gmail.com`. Live profile left intact. |
| Application total | Live hero and stat say 5+ published apps; seed says 10+ | CV states 20+ production applications. “Production” is kept distinct from “published.” |
| Experience | Unused seed claimed five years and fictitious employers | CV states 3+ years; July 2024–Present at AAIT and June 2023–June 2024 freelance. |
| Project downloads and ratings | Repeated 1K / 5 ratings in live records; seed invents much larger numbers | Legacy fields remain stored and editable, but are not presented as evidence or analytics. |
| Experience outcome | Live entry claims “Reduced codebase by 50%” | CV does not substantiate this. Local experience uses the CV's contribution statements; live record is unchanged. |
| FIX provider App Store | Live FIX Vendor points to `id6758222626`; CV provider link points to `id6788849876` | Both destinations are retained, labeled Vendor and Provider. They are not silently merged. |
| FIX vendor description | A broken URL is embedded in the description | Local copy uses the verified FIX overview. Existing links and document ID are preserved. |
| Broker & Contract Maker | Live projects updated after other records; not listed in the CV | Both are retained in the local collection using their existing purpose and links. No project-specific stack or outcomes are added. |
| Technical skills | Existing record includes AI/MCP and legacy proficiency labels | CV confirms AI-assisted development/MCP. No proficiency labels or percentage bars are displayed. Existing Firebase data is preserved by migration. |

## Visual direction and assets

The portfolio uses Manrope, warm paper, deep green ink, and a controlled teal accent. Its structure follows recruiter scanning order and uses large screenshot compositions, restrained borders, consistent spacing, and inexpensive transform/opacity motion. The dashboard shares the tokens with denser navigation and clear form sections. A light theme is fully implemented; no incomplete dark theme is exposed.

The repository originally contained logos only. The four featured projects are FIX, 2 Days, Be Fit, and Masarat Al-Wefada because each has verified store screenshots and demonstrates a distinct product domain. Store screenshots are compressed to WebP with smaller preview versions. Store-provided device frames remain intact. See `media-sources.json` and the gallery `sourceUrl` fields for provenance. No screenshots were generated or invented.

Other projects use typographic previews until authentic imagery is added. Project-specific contribution, challenge, decision, technology, and outcome sections remain blank when unsubstantiated. The editor provides real persisted controls for them.

Legacy fallback image URLs remain stored, but are hidden until their type is explicitly confirmed as a screenshot or app logo. This prevents unverified decorative imagery from being presented as application work during migration.

The unused seed function with invented template content was removed. The new fixture lives in one shared asset and both apps consume the same persistence interface. Existing collection names, document IDs, verified links, and legacy fields remain compatible. Production migration adds only missing fields and requires explicit execution.
