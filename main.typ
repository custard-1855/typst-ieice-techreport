// 信学技報の原稿. ビルド: make (= quarto typst compile main.typ)
#import "ieice.typ": ieice, ask, later, warn, algo-block, cmt

#show: ieice.with(
  jtitle: [電子情報通信学会技術研究報告の\ Typstテンプレート],
  etitle: [A Typst Template for IEICE Technical Reports],
  // affil は affiliations のキー. email は省略できる.
  authors: (
    (jname: "電子　太郎", ename: "Taro DENSHI", affil: "A", email: "taro@example.ac.jp"),
    (jname: "情報　花子", ename: "Hanako JOHO", affil: "A", email: "hanako@example.ac.jp"),
    (jname: "通信　次郎", ename: "Jiro TSUSHIN", affil: "B", email: "jiro@example.co.jp"),
  ),
  // 並び順が † の数になる.
  affiliations: (
    A: (
      ja: [○○大学大学院○○研究科 〒100-0000 東京都○○区○○ 1-2-3],
      en: [Graduate School of Example, Example University\ 1-2-3 Example, Example-ku, Tokyo, 100-0000 Japan],
    ),
    B: (
      ja: [株式会社○○ 〒100-0000 東京都○○区○○ 4-5-6],
      en: [Example Corporation\ 4-5-6 Example, Example-ku, Tokyo, 100-0000 Japan],
    ),
  ),
  abstract: [
    電子情報通信学会の技術研究報告 (信学技報) の体裁を, 学会が配布するLaTeXのクラスファイルieice.clsに合わせてTypstで組むテンプレートである. 表題, 著者, 所属, 要旨, キーワードを引数に書くと, 和英の表題ブロック, 2段組の本文, ヘッダとフッタが組まれる. 本文では見出し, 図表, 数式, 脚注, 文献の引用をTypstの標準の書き方で書ける. この文書はその書き方の見本を兼ねる.
  ],
  keywords: ("信学技報", "テンプレート", "Typst", "組版"),
  eabstract: [
    This is a Typst template that reproduces the layout of IEICE technical reports produced with ieice.cls, the LaTeX class file distributed by the institute. Given the title, authors, affiliations, abstract and keywords as arguments, it typesets the bilingual title block, the two-column body, and the header and footer. Headings, figures, tables, equations, footnotes and citations are written in standard Typst syntax. This document also serves as a sample of that syntax.
  ],
  ekeywords: ("IEICE Technical Report", "Template", "Typst", "Typesetting"),
  year: "2026",
  // line-gap: 0.8,   // 行間を詰めてページ数に収める (1.0 が ieice.cls どおり)
  // markers: false,  // #ask[] #later[] #warn[] を消す
)

= まえがき <sec-intro>

このテンプレートは, 版面 (A4, 57字×50行の2段組, 本文9pt) と表題ブロック, 見出し, 図表, 脚注, 文献欄をieice.clsに合わせて組む. 原稿は`main.typ`に書く. 以下, @sec-write で書き方を, @sec-bib で文献の書き方を示す.

= 書き方 <sec-write>

== 句読点と空白 <sec-punct>

原稿では句読点を半角のカンマとピリオド (後ろに半角の空白) で書いてよい. 前後が和文字のとき, 組版で全角の「，」「．」に置き換わる. 英文要旨と文献欄では置き換わらない. 和文と英数字の間に空白を入れる必要はない (Typstが組版で間隔を入れる). ただし参照`@sec-intro`の直後には空白を入れる. 入れないと, 続く和文までラベルの一部として読まれる.

== 見出しと参照

章は`=`, 節は`==`, 項は`===`で書く. 見出しに`<sec-write>`のようにラベルを付けると, `@sec-write`で「@sec-write」, `@sec-punct`で「@sec-punct」と参照できる. 図表と式も同じく, @fig-sample, @tab-sample, @eq-sample のように参照する.

=== 項の見出し

項の見出しは太字にならない.

== 図と表

図は @fig-sample のようにキャプションが下, 表は @tab-sample のようにキャプションが上に付く. どちらも段の上端か下端に置かれる. 2段にまたがる図表は`figure`に`scope: "parent"`を付ける.

#figure(
  image("figs/sample.svg", width: 80%),
  caption: [図の例.],
) <fig-sample>

#figure(
  table(
    columns: (1fr, auto, auto),
    align: (left, right, right),
    table.hline(),
    [条件], [誤差 (%)], [件数],
    table.hline(stroke: 0.4pt),
    [条件A], [17.45], [50,000],
    [条件B], [22.90], [50,000],
    [条件C], [67.39], [48,580],
    table.hline(),
  ),
  caption: [表の例.],
) <tab-sample>

== 数式

別行の数式は左寄せで番号が付く. @eq-sample は平均絶対パーセント誤差の定義である.

$ "MAPE" = 100 / n sum_(i=1)^n abs((hat(y)_i - y_i) / y_i) $ <eq-sample>

ここで $y_i$ は真値, $hat(y)_i$ は予測値, $n$ は件数である.

== 脚注

脚注は`#footnote[]`で書く#footnote[本文中の印は「（注1）」の形になる.].

== 擬似コード

擬似コードは`algo-block`で書き, `figure`の`kind`を`"algorithm"`にする (@alg-sample).

#figure(
  kind: "algorithm",
  supplement: [Algorithm],
  algo-block(
    [*入力*: 数列 $x_1, ..., x_n$ #h(1em) *出力*: 最大値 $m$],
    [$m <- x_1$],
    [*for* $i = 2, ..., n$ *do*],
    [#h(1em) *if* $x_i > m$ *then* $m <- x_i$ #cmt[▷ 更新]],
    [*return* $m$],
  ),
  caption: [最大値の探索.],
) <alg-sample>

== 草稿用のマーカー

書きかけの所には印を付けられる. #ask[要確認の点] #later[後で書く点] #warn[直す点] の3種があり, 赤字で出る. 引数`markers: false`で, 中身ごとすべて消える.

= 文献 <sec-bib>

文献は`refs.bib`にBibTeXで書き, `@kephart2003vision`のように引用する @kephart2003vision. 3件以上の連番は @kephart2003vision @rusek2020routenet @etsi2019zsm002 @ieice-sample のように畳まれる. 文献の中の場所は`@rusek2020routenet[Sec. III]`で @rusek2020routenet[Sec. III] と書く.

和文の文献は`refs_ja.yml`に`language: ja`を付けて書く @ieice-sample. 区切りが「，」「．」になり, 著者が「and」でつながれない.

= むすび

体裁を変えるときは`ieice.typ`を編集する.

#heading(numbering: none)[謝辞]

見出しに番号を付けないときは`#heading(numbering: none)[謝辞]`と書く.

#bibliography(("refs.bib", "refs_ja.yml"))
