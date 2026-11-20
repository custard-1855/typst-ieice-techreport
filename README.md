# 信学技報の Typst テンプレート

電子情報通信学会の技術研究報告 (信学技報) の原稿を [Typst](https://typst.app/) で組むテンプレートです。学会が配布する LaTeX のクラスファイル `ieice.cls` (technicalreport) の体裁に合わせてあります。

このテンプレートのサンプル原稿をビルドした PDF: [docs/sample.pdf](docs/sample.pdf)

学会の公式のテンプレートではありません。投稿の前に、学会が配布するテンプレートと見比べて確かめてください。

## 再現している範囲

- A4・2段組・本文 9pt・57字×50行・段間 2字
- 和英の表題ブロック (表題、著者、所属、E-mail、あらまし、キーワード)
- 「信学技報」のヘッダ、1ページ目の注意書きと著作権表示、2ページ目以降のページ番号
- 章・節・項の見出し、図表のキャプション、脚注「（注1）」、左寄せの数式
- 文献欄 (`sieicej.bst` に合わせた `ieice.csl`)。3件以上の連番の引用は「[2]〜[5]」に畳む

寸法は `ieice.cls` と、それで組んだテンプレート PDF (2026年12月版) の実測に合わせてあります。同じ本文を組んで比べると、本文の行位置・見出し・表題ブロック・フッタは 1〜2pt 以内で一致します。残る差は和文の太字のフォントです (このテンプレートはヒラギノ角ゴ W6、pTeX は原ノ味ゴシック Medium)。

## 必要なもの

- [Quarto](https://quarto.org/) 1.9 以降 (Typst 0.14 が同梱されている)、または Typst 0.14 以降
- フォント: Times、ヒラギノ明朝 ProN、ヒラギノ角ゴ ProN、STIX Two Math (どれも macOS に入っている)。Windows では代わりのフォントを入れる ([セットアップ (Windows)](#セットアップ-windows))
- make (Windows では無くてもよい)

## セットアップ (macOS)

1. make を入れる (入っていれば不要)

   ```sh
   xcode-select --install
   ```

2. Quarto か Typst のどちらかを入れる。[Homebrew](https://brew.sh/) なら:

   ```sh
   brew install --cask quarto   # Quarto (Typst が同梱されている)
   brew install typst           # または Typst だけ
   ```

   Quarto は [公式サイトのインストーラ](https://quarto.org/docs/get-started/) からも入れられます。

3. 入ったことを確かめる

   ```sh
   quarto typst --version       # Typst を入れたなら typst --version
   ```

   `typst 0.14` 以降と出れば使えます。動作を確かめてあるのは Typst 0.14.2 (Quarto 1.9.37 に同梱) です。

4. `make check` を使うなら [uv](https://docs.astral.sh/uv/) も入れる (`ieice.csl` を変えないなら不要)

   ```sh
   brew install uv
   ```

フォントは macOS に入っているものだけを使うので、追加のインストールは要りません。

## セットアップ (Windows)

Windows にはヒラギノと Times が無いので、GitHub Actions と同じ代わりのフォント (Noto Serif / Sans CJK JP と Liberation Serif) で組みます。行の折り返しやページ数が Mac と変わることがあります。

> [!WARNING]
> この節の手順は Windows の実機でまだ試していません。うまくいかないところがあれば issue で知らせてください。

1. Quarto か Typst のどちらかを入れる。PowerShell で:

   ```powershell
   winget install --id Posit.Quarto   # Quarto (Typst が同梱されている)
   winget install --id Typst.Typst    # または Typst だけ
   ```

   入れたあと、PowerShell を開き直します。

2. フォントを 3 つダウンロードして展開する

   - Noto Serif CJK JP: [noto-cjk の Releases](https://github.com/notofonts/noto-cjk/releases) の「Serif」の版にある `07_NotoSerifCJKjp.zip`
   - Noto Sans CJK JP: 同じページの「Sans」の版にある `06_NotoSansCJKjp.zip`
   - Liberation Serif: [liberation-fonts の Releases](https://github.com/liberationfonts/liberation-fonts/releases) にある `liberation-fonts-ttf-*.tar.gz` (`tar -xf ファイル名` で展開できる)

   Google Fonts で配られている「Noto Serif JP」「Noto Sans JP」は、フォントの名前が違うので使えません。

3. 展開した `.otf` と `LiberationSerif-*.ttf` を選び、右クリックの「すべてのユーザーに対してインストール」で入れる

4. 入ったことを確かめる

   ```powershell
   quarto typst --version       # Typst を入れたなら typst --version
   quarto typst fonts | Select-String "Noto Serif CJK JP", "Noto Sans CJK JP", "Liberation Serif"
   ```

   `typst 0.14` 以降と、3 つのフォントの名前が出れば使えます。

5. ビルドする。make は使わず、Typst を直接呼びます (Typst を入れたなら `quarto typst` を `typst` に読み替える)

   ```powershell
   quarto typst compile main.typ   # main.pdf を生成
   quarto typst watch main.typ     # 保存するたびに再生成
   ```

   `unknown font family: times` や `hiragino mincho pron` などの警告は、Mac 用のフォントが無いだけなので無視してかまいません。

`make` や `make check` も使いたいときは、[WSL](https://learn.microsoft.com/ja-jp/windows/wsl/install) の Ubuntu に Linux 版の Quarto か Typst を入れ、`sudo apt-get install -y make fonts-noto-cjk fonts-liberation` を実行します。GitHub Actions と同じ環境になります。

## 使い方

1. GitHub で「Use this template」から新しいリポジトリを作る。コマンドなら:

   ```sh
   gh repo create my-report --template custard-1855/typst-ieice-techreport --private --clone
   cd my-report
   ```

2. `main.typ` の先頭 (表題・著者・所属・要旨・キーワード) を書き換え、本文を書く
3. ビルドする

```sh
make          # main.pdf を生成
make watch    # 保存するたびに再生成
make clean    # 生成物を削除
```

`typst` コマンドがあればそれを、無ければ `quarto typst` を使います。`main.typ` 以外の名前にするときは `make DOC=report` のように指定します。

すでにある原稿に入れるだけなら、`ieice.typ` と `ieice.csl` の 2 つを同じディレクトリに置き、`main.typ` の先頭の `#import` と `#show: ieice.with(...)` を写します。

## 書き方

`main.typ` に、以下の書き方の例を一通り入れてあります。

| やりたいこと | 書き方 |
|---|---|
| 章 / 節 / 項 | `= 見出し` / `== 見出し` / `=== 見出し` |
| 番号なしの見出し (謝辞など) | `#heading(numbering: none)[謝辞]` |
| 見出し・図表・式の参照 | `<sec-x>` を付けて `@sec-x` (「3節」「図1」「表1」「式(1)」と出る) |
| 図 | `#figure(image("figs/x.svg"), caption: [...]) <fig-x>` |
| 表 | `#figure(table(...), caption: [...]) <tab-x>` (キャプションは上に付く) |
| 2段にまたがる図表 | `figure` に `scope: "parent"` を付ける |
| 数式 | `$ ... $ <eq-x>` (左寄せ、番号付き) |
| 脚注 | `#footnote[...]` |
| 文献の引用 | `@key`、場所を添えるなら `@key[Sec. III]` |
| 擬似コード | `figure(kind: "algorithm", supplement: [Algorithm], algo-block(...))` |
| 草稿用の赤字の印 | `#ask[要確認]` `#later[後で書く]` `#warn[直す]` |

### 句読点と空白

- 句読点は半角の `, ` `. ` で書けます。前後が和文字のとき、組版で「，」「．」に置き換わります。英文要旨と文献欄では置き換わりません。全角で書いてもそのまま出ます
- 和文と英数字の間に空白を入れる必要はありません。ただし参照 `@sec-x` の直後には空白を入れます (入れないと、続く和文までラベルに読まれる)

### `ieice()` の引数

| 引数 | 内容 |
|---|---|
| `jtitle` / `etitle` | 和文 / 英文の表題。改行は `\` |
| `authors` | `(jname: ..., ename: ..., affil: 所属のキー, email: ...)` の並び。`email` は省略できる |
| `affiliations` | `(キー: (ja: [...], en: [...]))`。並び順が † の数になる |
| `abstract` / `eabstract` | 和文 / 英文の要旨 |
| `keywords` / `ekeywords` | 和文 / 英文のキーワードの並び |
| `year` | フッタの「Copyright ©20xx by IEICE」の年 |
| `line-gap` | 行と行の間の空きの倍率。既定の `1.0` が `ieice.cls` どおり (行送り 20.5Q)。ページ数に収めたいときに `0.8` などにする |
| `markers` | `false` にすると `#ask[]` `#later[]` `#warn[]` を中身ごと消す |

同じドメインの E-mail は所属ごとに `{a,b}@domain` にまとめられます。

### 文献

- 英文の文献は `refs.bib` に BibTeX で書きます
- 和文の文献は `refs_ja.yml` ([hayagriva](https://github.com/typst/hayagriva/blob/main/docs/file-format.md) の YAML) に `language: ja` を付けて書きます。Typst は `.bib` の `language` を文献様式に渡さないためです。著者は `"姓, 名"` で書きます
- 規格文書は `type` に発行元、`number` に文書番号を書きます (`refs.bib` の ETSI の例)
- `.bib` の `volume` は数字でないと出ません (`E100-B` は巻ごと消える)。信学論のような巻は、英文の文献でも `refs_ja.yml` に `language` を付けずに書きます
- `.bib` の `number` は数として読まれ、`NS2025-1` のハイフンが en ダッシュに、`TS 23.501` が `TS23.501` になります。崩れるときは `number` を書かず、番号まで `type` に書きます (`type = {信学技報 NS2025-1}`)
- Web ページの URL は `url` に書きます。`howpublished = {\url{...}}` と書くと `\url{...}` がそのまま出ます。`@misc` に `howpublished` と `note` の両方を書くと `howpublished` が落ちます
- 英文の著者が 12 名以上のときは先頭 3 名 + ", et al." になります。人数は `ieice.csl` の `et-al-min` で変えられます
- `sieicej.bst` と合わせていない細部は `ieice.csl` の冒頭のコメントにあります

`make check` は、`ieice.csl` の出力を `sieicej.bst` の出力 (テンプレート PDF の文献欄など) と照合します。`ieice.csl` を変えたときに実行してください ([uv](https://docs.astral.sh/uv/) が必要)。

## ファイル構成

```
main.typ             原稿 (書き方の見本を兼ねる)
ieice.typ            テンプレート本体
ieice.csl            文献の様式
refs.bib             英文の文献
refs_ja.yml          和文の文献
figs/                図の置き場
csl_check/           ieice.csl の検査 (make check)
Makefile             ビルドのコマンド
.github/workflows/   GitHub Actions で PDF をビルド
CLAUDE.md            Claude Code 向けの指示
docs/sample.pdf      サンプル原稿の PDF (make sample で更新)
```

## GitHub Actions

push するたびに PDF をビルドし、Actions の実行結果の Artifacts (`report`) に保存します。Ubuntu にはヒラギノと Times が無いので、CI では Noto Serif / Sans CJK JP と Liberation Serif で組まれ、行の折り返しやページ数が Mac と変わることがあります。Windows でビルドしたときも同じです。学会のテンプレートに最も近い体裁になるのは Mac でビルドした PDF です。

## 注意

- Mac でビルドすると `unknown font family: noto serif cjk jp` などの警告が出ます。CI 用の代わりのフォントが Mac に無いだけなので無視してかまいません
- `ieice.cls` と `sieicej.bst` は学会の配布物なので、このリポジトリには入れていません
