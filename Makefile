# Makefile for princeton-tex
#
#   make            build the example with both engines
#   make lua        lualatex only (Princeton Monticello when installed)
#   make pdf        pdfLaTeX only (free fallback family, what CI uses)
#   make reference  refresh the regression baseline in baseline/
#   make install    symlink the class into TEXMFHOME, portably
#   make clean      remove build output
#
# Builds go to build/lua and build/pdf so the two engines never collide, and so
# nothing lands next to the sources.

ROOT       := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))
EXDIR      := $(ROOT)/examples
BUILD      := $(ROOT)/build
REFDIR     := $(ROOT)/baseline
DOCS       := example

TEXMFHOME  := $(shell kpsewhich -var-value TEXMFHOME)
INSTALLDIR := $(TEXMFHOME)/tex/latex/princeton

LATEXMK    := latexmk

# Let a fresh clone build without installing anything first.
export TEXINPUTS := .:$(ROOT):$(EXDIR):

LUA_PDFS := $(DOCS:%=$(BUILD)/lua/%.pdf)
PDF_PDFS := $(DOCS:%=$(BUILD)/pdf/%.pdf)

.PHONY: all lua pdf reference assets install uninstall clean distclean help

# Regenerate the Engineering mark PDFs from the identity asset pack.
#
# The pack ships no PDF for these marks: the only vector source is SVG, fully
# outlined with no font dependencies. Point ASSETPACK at wherever you unzipped
# it:
#
#   make assets ASSETPACK="/path/to/Princeton Engineering Visual Identity Assets"
#
# The upstream filenames are recorded because they do not match each other, and
# that looks like a mistake otherwise. The pack's Full Color folder has no file
# named SEAS-wShield-wParent-Linear and carries the same artwork as -2-line
# instead: rendered at 160 dpi and compared, the two agree on 99.97% of pixels,
# so it is an upstream naming slip, not a different mark.
#
# Requires rsvg-convert (brew install librsvg).
ASSETPACK := $(HOME)/Downloads/Princeton Engineering Visual Identity Assets
LOGOSRC   := $(ASSETPACK)/01 Engineering and Department Identity Logomarks/Princeton Engineering

assets:
	@test -d "$(LOGOSRC)" || { \
	  echo "Asset pack not found at:"; echo "  $(LOGOSRC)"; \
	  echo "Pass ASSETPACK=... to point at it."; exit 1; }
	@command -v rsvg-convert >/dev/null || { \
	  echo "rsvg-convert not installed (brew install librsvg)"; exit 1; }
	rsvg-convert -f pdf -o princeton-mark-engineering.pdf \
	  "$(LOGOSRC)/Full Color/SEAS-wShield-wParent-2-line.svg"
	rsvg-convert -f pdf -o princeton-mark-engineering-black.pdf \
	  "$(LOGOSRC)/Black/SEAS-wShield-wParent-Linear.svg"
	rsvg-convert -f pdf -o princeton-mark-engineering-long.pdf \
	  "$(LOGOSRC)/Full Color/SEAS-wShield-Linear-FullName.svg"
	rsvg-convert -f pdf -o princeton-mark-engineering-long-black.pdf \
	  "$(LOGOSRC)/Black/SEAS-wShield-Linear-FullName.svg"
	@echo "Regenerated Engineering mark PDFs."

all: lua pdf

lua: $(LUA_PDFS)
pdf: $(PDF_PDFS)

$(BUILD)/lua/%.pdf: $(EXDIR)/%.tex $(ROOT)/princeton.cls
	@mkdir -p $(BUILD)/lua
	$(LATEXMK) -lualatex -outdir=$(BUILD)/lua $<

$(BUILD)/pdf/%.pdf: $(EXDIR)/%.tex $(ROOT)/princeton.cls
	@mkdir -p $(BUILD)/pdf
	$(LATEXMK) -pdf -outdir=$(BUILD)/pdf $<

# Snapshot current output as the regression baseline. Run this deliberately,
# never as a side effect of a build, or the baseline tracks the bug.
#
# Forces a clean rebuild first, rather than depending on `all`. latexmk's
# incremental logic can leave a PDF in place that predates a class edit, and a
# baseline captured from that is worse than no baseline: every later comparison
# then reports drift that does not exist. This cost real time to diagnose once.
reference:
	@$(MAKE) --no-print-directory clean
	@$(MAKE) --no-print-directory all
	@mkdir -p $(REFDIR)
	@for eng in lua pdf; do \
	  for doc in $(DOCS); do \
	    cp $(BUILD)/$$eng/$$doc.pdf $(REFDIR)/$$doc-$$eng.pdf; \
	    echo "  baseline: baseline/$$doc-$$eng.pdf"; \
	  done; \
	done

install:
	@mkdir -p $(INSTALLDIR)
	ln -sf $(ROOT)/princeton.cls $(INSTALLDIR)/princeton.cls
	ln -sf $(ROOT)/princeton-identity.sty $(INSTALLDIR)/princeton-identity.sty
	@for f in $(ROOT)/princeton-mark-*.pdf; do \
	  ln -sf "$$f" "$(INSTALLDIR)/$$(basename $$f)"; done
	@echo "Installed into $(INSTALLDIR)"

uninstall:
	rm -f $(INSTALLDIR)/princeton.cls $(INSTALLDIR)/princeton-identity.sty
	rm -f $(INSTALLDIR)/princeton-mark-*.pdf
	-rmdir $(INSTALLDIR)

clean:
	rm -rf $(BUILD)

distclean: clean
	rm -rf $(REFDIR)

help:
	@echo "targets: all lua pdf reference install uninstall clean distclean"
	@echo "TEXMFHOME resolves to: $(TEXMFHOME)"
