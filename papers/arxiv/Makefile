# SPDX-License-Identifier: AGPL-3.0-or-later
# Makefile for building arXiv paper

PAPER = bunsenite
LATEX = pdflatex
BIBTEX = bibtex

.PHONY: all clean view

all: $(PAPER).pdf

$(PAPER).pdf: $(PAPER).tex
	$(LATEX) $(PAPER)
	$(LATEX) $(PAPER)

clean:
	rm -f $(PAPER).aux $(PAPER).log $(PAPER).out $(PAPER).pdf
	rm -f $(PAPER).bbl $(PAPER).blg $(PAPER).toc

view: $(PAPER).pdf
	xdg-open $(PAPER).pdf

# For arXiv submission, create a tarball
arxiv: $(PAPER).tex
	tar -cvzf $(PAPER)-arxiv.tar.gz $(PAPER).tex Makefile
	@echo "Created $(PAPER)-arxiv.tar.gz for arXiv submission"
