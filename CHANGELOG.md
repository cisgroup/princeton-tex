# Changelog

All notable changes to the `princeton` document class.

This project uses dates and a simple version number recorded in the
`\ProvidesClass` line of `princeton.cls`.

## v1.2 — 2026-09-05

A two-column body mode. Page 1 keeps the wide left margin exactly as before, and
the body from the first section is set in two columns with the long single-line
mark on top.

### Added

- **`columns` option** taking `one` (default) and `two`. Deliberately not named
  `twocolumn`: that name already passes through to the base class, where it
  applies to page 1 as well.
- **`\startcolumns`**, for documents that want body text on page 1 and so need
  to choose the seam themselves. Otherwise the switch fires automatically at the
  first `\section`, which is the real boundary between front matter and body and
  leaves `\makeinfo` and a table of contents in the margin where they belong.
- **`examples/twocolumn.tex`**, built alongside the others.
- **The `theme` value `monticello` is now `classic`.** The typeface is still
  Monticello and is still named that everywhere it is meant, including the
  `fontset` option and the class warnings; only the theme value changed, so the
  option reads as a design register rather than a font name. `theme=monticello`
  is rejected with the valid list.
- **A conformance test.** `examples/testall.tex` and `examples/testall-two.tex`
  share one body, `examples/testall-body.tex`, which exercises every public
  command and environment the class has. The identical markup is compiled in
  both layouts and both engines, which is what makes the no-renaming promise
  testable rather than merely asserted. If you add a public command, add it to
  the shared body.

### Every margin command keeps its name

The promise is that a document switches mode without a single environment being
renamed. What each one becomes on a two-column page:

| Command | One column | Two column |
| --- | --- | --- |
| `\makeinfo`, `margindescription` | margin block | tinted aside across the column |
| `marginfigure` | margin float | ordinary column float |
| `\sidecaption`, `\SideCaption` | margin caption | ordinary caption |
| `largefigure`, `largetable` | widened into the margin | spans both columns |
| `princetonfigure`, both modes | margin or margin-caption figure | ordinary column figure |
| section numbers | hang into the margin | set inline, flush with the column |

`\marginnote` is the single choke point for the first three rows: `\makeinfo`,
`margindescription`, `\marginsection`, `\cvmargin` and sidenotes'
`\sidecaption` all route through it.

### The traps this had to work around

Recorded because each one fails silently and cost real time to find.

- **`\documentclass[twocolumn]{princeton}` was silently broken.** geometry
  double-subtracts the margin column, leaving a 3.31in text block inside a 7.5in
  band. The option now raises a class error pointing at `columns=two`.
- **The order at the seam is absolute.** `\newgeometry` and `\columnsep` must
  both precede `\twocolumn`, which derives `\columnwidth` from `\textwidth` when
  called. Wrong order gives 542pt columns where 258pt was intended, on a page
  LaTeX still believes is two-column.
- **`\marginnote` throws content off the paper** rather than erroring. It sends
  notes to the outer side of the emitting column, so under the class's
  `\reversemarginpar` a left-column note lands at x=8.4in on an 8.5in page.
- **The redefinition needs a long argument.** `{o +m o}`, not `{o m o}`, or
  `\makeinfo` fails with "Paragraph ended before `\marginnote` was complete".
- **`sidenotes` redefines `figure*` and `table*`** into a one-column float
  widened rightward, which runs over the second column. The spanning floats are
  therefore built on the kernel's `\@dblfloat` instead.
- **Starred floats accept only `t` and `p`.** Placement is forced to `[tp]`, so
  an `h` or `b` in a specifier cannot be silently dropped.
- **`\afterpage{\twocolumn}` corrupts the first two-column page**, reproducibly,
  at every page-1 length tested in both engines. `multicol` is also unusable
  here: a `figure[t]` inside `multicols` never appears at all.
- **A caption cannot be typeset inside the aside box.** `princetonfigure`'s f
  mode asks for the margin caption format, which routes the caption through
  `\marginnote`; once that is a box, the caption machinery fails with "Not
  allowed in LR mode". Since `\DeclareCaptionFormat` is preamble-only, the
  environment is replaced at the seam rather than the format.
- **The aside needed 8pt padding, not the 3pt default.** `customdescription`
  outdents its field labels, and at 3pt they were measured beginning 2.47pt
  outside the tint they are supposed to sit in.

### Measurements

| | Value |
| --- | --- |
| Text block, two column | 542.0pt |
| Column width | 258.0pt, about 54 characters |
| Gutter | 26pt |
| One-column measure, for comparison | 5.4in at a median of 81 characters |

Section numbers were first made to hang into the gutter, and that was measured
safe: a number landed at 308pt in a gutter running 293 to 319pt, never touching
the neighbouring column. It was still wrong. Hanging reads as deliberate against
a 2.1in margin and as a misalignment against a 26pt gutter, so they are now set
inline, flush with the column edge at 36.0pt and 319.0pt.

## v1.1 — 2026-09-05

Adds the Princeton Engineering identity published in October 2024 as a second
theme. The existing look is unchanged and remains the default.

### Added

- **`theme` option** taking `classic` (default) and `engineering`. The
  October 2024 Engineering identity is a different design language, not a
  refresh: a grotesque sans in place of an old-style serif, a different orange,
  department signature lock-ups, and a chevron device.
- **`princeton-identity.sty`**, a new module owning the palette and the text,
  display and maths font resolution for both themes. Colours are named by role
  rather than by hue, because in the Engineering identity the role decides the
  value.
- **`signature` option** selecting which identity lock-up is stamped on the
  page: `engineering` (the default), `university` and `none`.
- **`logo=running`**, a fourth placement alongside `default`, `first` and
  `none`. It puts the full mark on the opening page and the long single-line
  mark on every page after it, so later pages carry the identity without the
  mark competing with the text.
- **Every identity now ships a long single-line mark** as well as a full one,
  and a one-colour `-black` cut of each.
- **`logocolor` option** taking `color` (default) and `black`, selecting the
  one-colour cut of whichever mark is in use. It affects only the mark: the
  theme's own orange on the title and links is untouched. Marks that are
  already monochrome and ship no separate cut, such as the University long
  mark, fall back to their plain file rather than failing.

### Renamed

All marks now follow one scheme, `princeton-mark-<identity>[-long][-black].pdf`,
so the variant is readable from the filename:

| Was | Now |
| --- | --- |
| `princeton-logo.pdf` | `princeton-mark-university.pdf` |
| `princeton-logo-bw.pdf` | `princeton-mark-university-black.pdf` |
| `princeton-logo-long.pdf` | `princeton-mark-university-long.pdf` |
| `princeton-sig-engineering.pdf` | `princeton-mark-engineering.pdf` |

This also removes a real hazard: `princeton-logo-bw.pdf` existed in both this
repository and `princeton-beamer`, and both are symlinked into the same texmf
tree, so which one resolved depended on search order.

The Engineering SVG sources are now committed under the same names as their
PDFs, so `make assets` needs nothing outside the repository.

  A note on provenance, because it is not obvious from the filenames. The mark
  is `SEAS-wShield-wParent-Linear`. The asset pack's Black folder names it
  correctly, but its Full Color folder has no file of that name and carries the
  same artwork as `SEAS-wShield-wParent-2-line` instead. Rendered at 160 dpi
  and compared, the two agree on 99.97% of pixels, so it is an upstream naming
  slip rather than a different lock-up. `make assets` records both paths.
- **`examples/engineering.tex`**, built alongside the other two.
- **`make assets`**, regenerating the signature PDFs from the identity asset
  pack. The pack ships no PDF for any department mark, so the only usable
  vector source is SVG.

### Colour

One orange throughout, by explicit request. The brand orange is used for the
title, hyperlinks and the margin info labels alike:

| Role | Colour | Contrast | Use |
| --- | --- | --- | --- |
| `pu-display` | `#F58025` | 2.63:1 | title, links, margin labels |
| `pu-heading` | black | 21:1 | section headings |
| `pu-rule` | `#AFAFAF` | 2.19:1 | dividers only, never type |

Recorded once and not repeated: the guidelines require WCAG compliance and
permit orange only "providing the type size is above 18pt", and `#F58025`
measures 2.63:1, so at body size it meets neither. A darkened `pu-orange-text`
at `#B35300` and 5.06:1 remains defined in `princeton-identity.sty` for anyone
who wants it, but nothing uses it.

### Sizing

Libre Franklin is loaded at `scaled=0.94`, so a document does not change size
when it changes theme. At 11pt, Monticello's x-height is 5.475pt against Libre
Franklin's unscaled 5.804pt; scaled it is 5.455pt, within 0.4%.

### Licensing

The committed `princeton-mark-*` files are Princeton University trademarks,
converted from the identity asset pack. They are **not** covered by this
repository's MIT licence. Caslon Doric Condensed Bold is a commercial font and
is referenced, never bundled; Libre Franklin is SIL OFL and ships with TeX Live,
so body text renders identically for anyone.

## v1.0 — 2026-09-05

The first versioned release. Everything before this was untagged development
running from January 2023.

### Added

- **pdfLaTeX is now a supported engine.** Fonts resolve in three tiers:
  Princeton Monticello under lualatex or xelatex when installed, and XCharter
  everywhere else. Previously pdfLaTeX silently fell back to Computer Modern.
- **`fontset` option** taking `auto`, `princeton` or `free`. `auto` is the
  tiering above, `free` forces XCharter, and `princeton` insists on Monticello
  and raises an error if it cannot be had.
- **The rest of the Monticello family is now used.** Small caps, oldstyle
  figures, tabular figures and the display cut were all installed but ignored.
  New commands `\textos` and `\texttab` select figure styles, and
  `\princetondisplay` selects the display cut. All of these work in the
  fallback tier too, so documents stay portable between engines.
- **Matched maths.** `newtxmath` is loaded in every tier and every engine.
  Maths previously rendered in Latin Modern against Monticello text.
- **Microtypography.** `microtype` with protrusion and expansion, which matters
  in a narrow measure beside a wide margin.
- **`titledate` option.** `\date` was silently ignored by `\maketitle`, because
  the title block carries only pretitle, title and subtitle. It is now opt-in
  rather than inert. Default off, so existing documents are unchanged.
- **Option validation.** `marginpos`, `titleformat`, `logo` and `fontset` are
  checked against their allowed values, and `itemcolor` against the defined
  colours. Typos previously selected a fall-through branch silently.
- **`logo=none` and `titleformat=fancy`** are now named, supported values
  rather than whatever the fall-through branch happened to do.
- **Build tooling.** `Makefile` and `.latexmkrc` build both examples under both
  engines. `make install` uses `TEXMFHOME` instead of a hardcoded path.
  `make reference` snapshots PDFs for regression diffing.

### Fixed

- **Hyperlinks rendered as bordered boxes, never as coloured text.** hyperref's
  own `colorlinks` defaults to false, and the class set `allcolors`, which only
  applies when it is true, alongside `allbordercolors`, which only applies when
  it is false. The `colorlinks` class option was declared and never read. It is
  now wired up and defaults to true.
- **`largefigure` never applied its margin shift.** It branched on
  `\@ifoddpage`, whose boolean is only set by `\checkoddpage`, which the class
  never called. `largefigure` and `largetable` now share one `adjustwidth`
  mechanism that honours `marginpos`.
- **Full-width floats overflowed the page margin by 3pt**, from a fudge factor
  in the shared margin length that was harmless only while the shift above was
  dead.
- **`\fullfigure` leaked key values between calls.** A second call inherited the
  first one's height, angle and alignment for any key not repeated.
- **`Negative labelwidth` warning** from every `margindescription`, caused by
  deriving label width from a zero left margin.
- **A missing logo graphic** now produces one clear warning and omits the logo,
  instead of failing at every page shipout.

### Changed

- **`datetime` replaced by `datetime2`.** Output is unchanged: `\today` still
  renders as `2026-09-05`.
- **Footer logic deduplicated.** It was written out twice, character for
  character, once per page style.
- **The logo stamp deduplicated**, likewise written out twice.

### Removed

- **`tikz`**, loaded solely to place one node in `\fullfigure` as a workaround
  for a border gap that no longer occurs. Verified at 300 dpi that the
  replacement bleeds to all edges. Saves roughly 0.19s per compile and removes
  a second-pass requirement.
- **`amssymb`**, loaded solely for `\blacktriangleright`, which `newtxmath`
  already provides, and which clashed with it over `\Bbbk`.
- **`ifoddpage`**, whose only use was the dead branch described above.
- **`inputenc`**, unnecessary since UTF-8 became the pdfLaTeX default in 2018.

### Known and deliberately not addressed

- Princeton orange on white measures 2.72:1 contrast. WCAG AA needs 4.5:1 for
  text and 3:1 for large text, so section headings and hyperlinks do not meet
  it. Recorded rather than changed, as a deliberate identity decision.
- The table of contents is still stock `article` inside an otherwise heavily
  styled class.
- There is no bibliography support. The `% Bibliography` section in the class
  remains a placeholder.
