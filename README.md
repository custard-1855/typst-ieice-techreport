# 信学技報の Typst テンプレート

電子情報通信学会の技術研究報告 (信学技報) の原稿を [Typst](https://typst.app/) で組むテンプレートです。学会が配布する LaTeX のクラスファイル `ieice.cls` (technicalreport) の体裁に合わせてあります。

このテンプレートのサンプル原稿をビルドした PDF: [docs/sample.pdf](docs/sample.pdf)

## 再現している範囲

- A4・2段組・本文 9pt・57字×50行・段間 2字
- 和英の表題ブロック (表題、著者、所属、E-mail、あらまし、キーワード)
- 「信学技報」のヘッダ、1ページ目の注意書きと著作権表示、2ページ目以降のページ番号
- 章・節・項の見出し、図表のキャプション、脚注「（注1）」、左寄せの数式
- 文献欄 (`sieicej.bst` に合わせた `ieice.csl`)。3件以上の連番の引用は「[2]〜[5]」に畳む

なお、和文の太字のフォントが一致しません (このテンプレートはヒラギノ角ゴ W6、pTeX は原ノ味ゴシック Medium)。

## 必要なもの

- [Quarto](https://quarto.org/) 1.9 以降 (Typst 0.14 が同梱されている)、または Typst 0.14 以降
- フォント: macOS同梱のTimes、ヒラギノ明朝 ProN、ヒラギノ角ゴ ProN、STIX Two Math
  - Windows と Linux では代わりのフォントを導入。各種セットアップを参照
- make
  - Windows では無くてもよい

## セットアップ

| OS | 和文 / 欧文のフォント | ビルド | 手順の検証 |
|---|---|---|---|
| [macOS](#macos) | ヒラギノ / Times | `make` | 済 |
| [Windows](#windows) | Noto CJK JP / Liberation Serif | `quarto typst compile` | 未検証 |
| [Linux / WSL2](#linux--wsl2) | Noto CJK JP / Liberation Serif | `make` | Ubuntu 24.04 と 26.04 のコンテナで済。WSL2 の上では未検証 |

- 学会のテンプレートに最も近い体裁になるのは macOS
- Windows と Linux は、GitHub Actions と同じ代わりのフォントで組む
  - 行の折り返しやページ数が macOS と変わることがある
- 動作を確かめた Typst は 0.14.2 (Quarto 1.9.37 に同梱)
  - Linux では 0.15.1 も確認済み

### macOS

1. make を入れる
   - 入っていれば不要

   ```sh
   xcode-select --install
   ```

2. Quarto か Typst のどちらかを入れる
   - 下のコマンドは [Homebrew](https://brew.sh/) を使う場合
   - Quarto は [公式サイトのインストーラ](https://quarto.org/docs/get-started/) でもよい

   ```sh
   brew install --cask quarto   # Quarto (Typst が同梱されている)
   brew install typst           # または Typst だけ
   ```

3. 入ったことを確かめる
   - `typst 0.14` 以降と出ればよい

   ```sh
   quarto typst --version       # Typst を入れたなら typst --version
   ```

4. `make check` を使うなら [uv](https://docs.astral.sh/uv/) も入れる
   - `ieice.csl` を変えないなら不要

   ```sh
   brew install uv
   ```

フォントの追加は不要です。

### Windows

> [!WARNING]
> この節の手順は Windows の実機でまだ試していません ([#3](https://github.com/custard-1855/typst-ieice-techreport/issues/3))。うまくいかないところがあれば issue で知らせてください。

1. Quarto か Typst のどちらかを入れる
   - PowerShell で実行する
   - 入れたあと、PowerShell を開き直す

   ```powershell
   winget install --id Posit.Quarto   # Quarto (Typst が同梱されている)
   winget install --id Typst.Typst    # または Typst だけ
   ```

2. フォントを 3 つダウンロードして展開する

   | フォント | 入手先 | ファイル |
   |---|---|---|
   | Noto Serif CJK JP | [noto-cjk の Releases](https://github.com/notofonts/noto-cjk/releases) の「Serif」の版 | `07_NotoSerifCJKjp.zip` |
   | Noto Sans CJK JP | 同じページの「Sans」の版 | `06_NotoSansCJKjp.zip` |
   | Liberation Serif | [liberation-fonts の Releases](https://github.com/liberationfonts/liberation-fonts/releases) | `liberation-fonts-ttf-*.tar.gz` |

   - `.tar.gz` は `tar -xf ファイル名` で展開できる
   - Google Fonts の「Noto Serif JP」「Noto Sans JP」は使えない
     - フォントの名前が違うため

3. フォントを入れる
   - 展開した `.otf` と `LiberationSerif-*.ttf` を選ぶ
   - 右クリックの「すべてのユーザーに対してインストール」

4. 入ったことを確かめる
   - `typst 0.14` 以降と、3 つのフォントの名前が出ればよい

   ```powershell
   quarto typst --version       # Typst を入れたなら typst --version
   quarto typst fonts 2>&1 | Select-String "Noto Serif CJK JP", "Noto Sans CJK JP", "Liberation Serif"
   ```

5. ビルドする
   - make は使わず、Typst を直接呼ぶ
   - Typst を入れたなら `quarto typst` を `typst` に読み替える

   ```powershell
   quarto typst compile main.typ   # main.pdf を生成
   quarto typst watch main.typ     # 保存するたびに再生成
   ```

`make` や `make check` も使いたいときは、WSL2 の Ubuntu で [Linux / WSL2](#linux--wsl2) の手順を使います。

### Linux / WSL2

Ubuntu での手順です。

- WSL2 を使う場合の準備
  - PowerShell で `wsl --install` を実行し、Ubuntu を入れる ([Microsoft の説明](https://learn.microsoft.com/ja-jp/windows/wsl/install))
  - 以下の手順は Ubuntu の端末で実行する
  - リポジトリは Ubuntu の側 (`~/` の下) に clone する
- ARM の機械では、手順 2 の `amd64` を `arm64` に、`x86_64` を `aarch64` に読み替える

1. make とフォントを入れる

   ```sh
   sudo apt-get update
   sudo apt-get install -y make curl xz-utils fonts-noto-cjk fonts-liberation
   ```

2. Quarto か Typst のどちらかを入れる

   ```sh
   # Quarto (Typst が同梱されている)
   curl -LO https://github.com/quarto-dev/quarto-cli/releases/download/v1.9.37/quarto-1.9.37-linux-amd64.deb
   sudo apt-get install -y ./quarto-1.9.37-linux-amd64.deb
   ```

   ```sh
   # または Typst だけ
   curl -LO https://github.com/typst/typst/releases/latest/download/typst-x86_64-unknown-linux-musl.tar.xz
   tar -xf typst-x86_64-unknown-linux-musl.tar.xz
   sudo install typst-x86_64-unknown-linux-musl/typst /usr/local/bin/
   ```

3. 入ったことを確かめる
   - `typst 0.14` 以降と、3 つのフォントの名前が出ればよい

   ```sh
   quarto typst --version       # Typst を入れたなら typst --version
   quarto typst fonts 2>&1 | grep -E "Noto (Serif|Sans) CJK JP|Liberation Serif"
   ```

4. `make check` を使うなら [uv](https://docs.astral.sh/uv/) も入れる
   - `ieice.csl` を変えないなら不要
   - 入れたあと、端末を開き直す

   ```sh
   curl -LsSf https://astral.sh/uv/install.sh | sh
   ```

WSL2 では、`explorer.exe .` でリポジトリのフォルダを Windows のエクスプローラーで開き、`main.pdf` を見られます。

## 使い方

1. リポジトリを作る
   - GitHub の「Use this template」から作る
   - コマンドなら次のとおり

   ```sh
   gh repo create my-report --template custard-1855/typst-ieice-techreport --private --clone
   cd my-report
   ```

2. `main.typ` を書く
   - 先頭の表題・著者・所属・要旨・キーワードを書き換える
   - 続けて本文を書く

3. ビルドする
   - `typst` コマンドがあればそれを、無ければ `quarto typst` を使う
   - `main.typ` 以外の名前にするときは `make DOC=report` のように指定する
   - Windows では make の代わりに [Windows](#windows) の手順 5 を使う

   ```sh
   make          # main.pdf を生成
   make watch    # 保存するたびに再生成
   make clean    # 生成物を削除
   ```

すでにある原稿に入れるだけなら、次の 2 つで足ります。

- `ieice.typ` と `ieice.csl` を原稿と同じディレクトリに置く
- `main.typ` の先頭の `#import` と `#show: ieice.with(...)` を写す

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

- 句読点は半角の `, ` `. ` で書ける
  - 前後が和文字のとき、組版で「，」「．」に置き換わる
  - 英文要旨と文献欄では置き換わらない
  - 全角で書いてもそのまま出る
- 和文と英数字の間に空白は要らない
  - ただし、参照 `@sec-x` の直後には空白を入れる (入れないと、続く和文までラベルに読まれる)

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

- 英文の文献: `refs.bib` に BibTeX で書く
  - 著者が 12 名以上のときは、先頭 3 名 + ", et al." になる
  - 人数は `ieice.csl` の `et-al-min` で変えられる
- 和文の文献: `refs_ja.yml` に `language: ja` を付けて書く
  - 形式は [hayagriva](https://github.com/typst/hayagriva/blob/main/docs/file-format.md) の YAML
  - `.bib` に書かないのは、Typst が `.bib` の `language` を文献様式に渡さないため
  - 著者は `"姓, 名"` で書く
- 規格文書: `type` に発行元、`number` に文書番号を書く
  - `refs.bib` の ETSI が例
- `sieicej.bst` と合わせていない細部は、`ieice.csl` の冒頭のコメントにある

`ieice.csl` を変えたときは `make check` を実行します。

- `ieice.csl` の出力を、`sieicej.bst` の出力 (テンプレート PDF の文献欄など) と照合する
- [uv](https://docs.astral.sh/uv/) が必要

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

- push するたびに PDF をビルドする
- PDF は、Actions の実行結果の Artifacts (`report`) に保存される
- フォントは Noto Serif / Sans CJK JP と Liberation Serif
  - Ubuntu にはヒラギノと Times が無いため
  - 行の折り返しやページ数が macOS と変わることがある

## 注意

- `unknown font family` の警告は無視してよい
  - ほかの OS 用のフォントが無いだけで、次のフォントに進む
  - macOS では `noto serif cjk jp` など、Windows と Linux では `times` や `hiragino mincho pron` などが出る
- `ieice.cls` と `sieicej.bst` は学会の配布物なので、このリポジトリには入れていない
