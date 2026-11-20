# CLAUDE.md

信学技報 (IEICE technical report) の Typst テンプレート。使い方と書き方は README.md にある。

## 編集

- 原稿は `main.typ`、体裁は `ieice.typ`、文献の様式は `ieice.csl` を編集する
- 変更したら `make` でビルドし、`main.pdf` の全ページを目で確かめる。`typst` が無ければ `quarto typst` が使われる
- `ieice.typ` の寸法は学会配布の `ieice.cls` とテンプレート PDF の実測に合わせてある。根拠は各行のコメントにあるので、値を変えるときはコメントも直す
- `ieice.csl` を変えたら `make check` を通す。期待値は `csl_check/check_csl.py` にある
- Mac で出る `unknown font family` の警告 (TeX Gyre Termes, Liberation Serif, Noto Serif / Sans CJK JP) は、CI 用の代わりのフォントが無いだけなので、フォント指定はそのままにする
- サンプル原稿 (`main.typ`) を変えたら `make sample` で `docs/sample.pdf` を更新する
