# make       : main.pdf を生成
# make watch : 保存するたびに再生成
# make sample: docs/sample.pdf を更新
# make check : ieice.csl の出力を期待値と照合 (uv が必要)

DOC ?= main
# typst があればそれを, 無ければ Quarto 同梱の typst を使う
TYPST ?= $(shell command -v typst >/dev/null 2>&1 && echo typst || echo quarto typst)

all: $(DOC).pdf

$(DOC).pdf: $(DOC).typ ieice.typ ieice.csl $(wildcard sections/*.typ) $(wildcard figs/*) $(wildcard *.bib) $(wildcard *.yml)
	$(TYPST) compile $(DOC).typ

watch:
	$(TYPST) watch $(DOC).typ

sample: $(DOC).pdf
	cp $(DOC).pdf docs/sample.pdf

check:
	uv run --with pymupdf python csl_check/check_csl.py

clean:
	rm -f $(DOC).pdf

.PHONY: all watch sample check clean
