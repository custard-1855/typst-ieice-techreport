// 電子情報通信学会 技術研究報告 (ieice.cls の technicalreport) を Typst で再現するテンプレート.
// 寸法は学会配布の ieice.cls (本文 9pt・行送り 20.5Q・57字×50行・段間 2字) と, それで組んだテンプレート PDF
// (2026年12月版) の実測に合わせてある. 使い方は main.typ と README.md を参照.

// ---- 単位と寸法 ----------------------------------------------------------
#let tp = 0.99626pt          // TeX の pt (1/72.27 in). Typst の pt は 1/72 in.
#let Q = 0.25mm              // 級

#let size-normal = 9 * tp    // 本文
#let size-small = 8 * tp     // 図表, 文献
#let size-footnote = 7 * tp  // 脚注, 1ページ目の学会名
#let size-tiny = 5 * tp      // 本文中の脚注の印
#let size-large = 10 * tp    // 要旨
#let size-Large = 10.95 * tp // 章見出し
#let size-LARGE = 12 * tp    // 著者名

#let zw = size-normal        // 本文の全角幅
// 本文の行送り. ieice.cls は 20.5Q (14.53pt). line-gap は行と行の間の空きの倍率 (ieice() の引数. 1.0 が ieice.cls どおり)
#let line-pitch(line-gap) = size-normal + line-gap * (20.5 * Q - size-normal)

// 和文は明朝, 欧文は Times. 太字の和文はゴシックにする (ieice.cls と同じ).
// 2つ目以降は macOS 以外 (CI の Ubuntu など) での代わり. 無いフォントは警告が出るだけで飛ばされる.
#let latin = ("Times", "TeX Gyre Termes", "Liberation Serif").map(f => (name: f, covers: "latin-in-cjk"))
#let fonts-serif = (..latin, "Hiragino Mincho ProN", "Noto Serif CJK JP")
#let fonts-gothic = (..latin, "Hiragino Kaku Gothic ProN", "Noto Sans CJK JP")
// 数式と等幅の中の和文は明朝で組む. 和文フォントを並べておかないと, Typst が手近なフォント (Mac では Klee や Osaka) に落とす.
#let fonts-math = ("STIX Two Math", "New Computer Modern Math", "Hiragino Mincho ProN", "Noto Serif CJK JP")
#let fonts-mono = ("DejaVu Sans Mono", "Hiragino Mincho ProN", "Noto Serif CJK JP")

// ---- 小物 ----------------------------------------------------------------

// 均等割り: 文字列を幅 width に均等に配置する. box を使うとベースラインがずれるので字間を計算して入れる.
#let kintou(width, body) = context {
  let s = if type(body) == str { body } else if body.has("text") { body.text } else { none }
  if s == none or s.clusters().len() < 2 { return body }
  let cs = s.clusters()
  let gap = (width.to-absolute() - cs.map(c => measure(c).width).sum()) / (cs.len() - 1)
  cs.join(h(gap))
}

// 見出しの字取り: 4.5 字以下なら 5 字幅に均等割りする (ieice.cls の \@secjidori).
#let jidori(body) = context {
  if measure(body).width > 4.5em.to-absolute() { body } else { kintou(5em, body) }
}

#let dagger(n) = "†" * n
#let mark(n) = super(size: 0.73em, baseline: -0.36em, dagger(n))

// 引用: 3件以上の連番を "[2]〜[5]" にする (ieice.cls の citesort). 畳む処理は ieice.csl が行うが,
// hayagriva は CSL の citation-range-delimiter を読めず "–" を出すので, ここで置き換える
// ("]–[" は別々のテキストに分かれていて一致しない. 引用の中の "–" はこれしかない).
#let ieice-cite(it) = {
  show "–": "〜"
  it
}

// 英文著者名の連結: "A and B", "A, B, and C".
#let join-en(names) = {
  if names.len() <= 2 { names.join(" and ") } else { names.slice(0, -1).join(", ") + ", and " + names.last() }
}

// E-mail 行: 所属ごとにまとめ, 同じドメインなら {a,b}@domain にたたむ.
#let email-line(authors, affil-keys) = {
  let parts = ()
  for (i, key) in affil-keys.enumerate() {
    let mails = authors.filter(a => a.affil == key and a.at("email", default: none) != none).map(a => a.email)
    if mails.len() == 0 { continue }
    let domains = mails.map(m => m.split("@").last()).dedup()
    let body = if mails.len() > 1 and domains.len() == 1 {
      "{" + mails.map(m => m.split("@").first()).join(",") + "}@" + domains.first()
    } else { mails.join(", ") }
    parts.push(dagger(i + 1) + body)
  }
  if parts.len() > 0 { [E-mail: #parts.join(", ")] }
}

// ---- 表題ブロック ---------------------------------------------------------
// 行の上下端をベースラインにして, 要素間の v() をベースライン間の距離として指定する.
// 値は テンプレート PDF の実測 (ベースライン間, pt).

#let title-block(
  jtitle, etitle, authors, affiliations, abstract, keywords, eabstract, ekeywords, cvs,
) = {
  let affil-keys = affiliations.keys()
  let affil-index(key) = affil-keys.position(k => k == key) + 1

  set par(first-line-indent: 0pt, justify: false, spacing: 0pt)
  set text(top-edge: "baseline", bottom-edge: "baseline")
  set block(spacing: 0pt)
  set align(left)

  let affil-lines(lang) = {
    set text(size: 10.5 * tp)
    set par(leading: 15 * tp)
    for (i, key) in affil-keys.enumerate() {
      [#dagger(i + 1)#h(0.15em)#affiliations.at(key).at(lang)\ ]
    }
    email-line(authors, affil-keys)
  }

  let abstract-box(label, body, size, pitch) = {
    set text(size: size)
    set par(leading: pitch, justify: true)
    [#text(font: fonts-gothic, weight: "bold", label)#h(1em)#body]
  }

  let content = {
    // 学会名
    v(6.1pt)
    pad(x: 8mm, {
      set text(size: size-footnote)
      set par(leading: 3mm)
      grid(
        columns: (1fr, 1fr),
        align: (left, right),
        [一般社団法人#h(1em)電子情報通信学会\ THE INSTITUTE OF ELECTRONICS,\ INFORMATION AND COMMUNICATION ENGINEERS],
        [信学技報\ IEICE Technical Report],
      )
    })

    // 和文
    v(30.7pt)
    align(center, {
      set text(size: 16 * tp)
      set par(leading: 23 * tp)
      jtitle
    })
    v(27.0pt)
    align(center, text(size: size-LARGE, authors
      .map(a => [#a.jname#mark(affil-index(a.affil))])
      .join(h(1.4em))))
    v(22.2pt)
    align(center, affil-lines("ja"))
    v(23.0pt)
    abstract-box("あらまし", abstract, size-large, 22 * Q)
    v(15.6pt)
    abstract-box("キーワード", keywords.join("，"), size-large, 22 * Q)

    // 英文. 字間は伸縮させない (pTeX の \kanjiskip は和文字の間にしか入らない)
    set text(lang: "en")
    set par(justification-limits: (tracking: (min: 0em, max: 0em)))
    v(44.7pt)
    align(center, {
      set text(size: 16 * tp)
      set par(leading: 23 * tp)
      etitle
    })
    v(27.0pt)
    align(center, text(size: size-LARGE, join-en(authors.map(a => [#a.ename#mark(affil-index(a.affil))]))))
    v(22.2pt)
    align(center, affil-lines("en"))
    v(23.1pt)
    abstract-box("Abstract", eabstract, size-large, 22 * Q)
    v(14.6pt)
    abstract-box("Key words", ekeywords.join(", "), size-large, 22 * Q)
  }

  // 本文の行が表題の下で行送りの格子に乗るよう, 高さを行送りの整数倍に切り上げる
  // (ieice.cls の \@maketitle と同じ: 最終行の深さと 1 行分の空きを足して切り上げ).
  context {
    let h = measure(content, width: page.width - 2 * (210mm - 57 * zw) / 2).height
    let n = calc.floor((h + 2.2pt + 22 * Q) / cvs) + 1
    block(height: n * cvs, width: 100%, content)
  }
}

// ---- 草稿用のマーカー ----------------------------------------------------
// [?] 要確認・疑問, [>] 後で書く・今後やる, [!] 既知のずれ・要修正. 紙面に赤字で出す.
// ieice() の引数 markers を false にすると, マーカーを中身ごと消す (人に渡す版で使う).
#let show-markers = state("show-markers", true)
#let marker(sym, body) = context if show-markers.get() {
  text(fill: rgb("#c00000"), font: fonts-gothic)[\[#sym\]#body]
}
// 擬似コード. figure(kind: "algorithm", supplement: [Algorithm], ...) の中に置く.
// algo-block(head, ..lines): head は番号なしの行 (入力・出力), lines は 1 から番号を振る
#let algo-block(head, ..lines) = block(width: 100%, stroke: (top: 0.6pt, bottom: 0.6pt), inset: (y: 3pt))[
  #set par(leading: 0.5em)
  #table(
    columns: (1.3em, 1fr), align: (right, left), inset: (x: 3pt, y: 1.6pt),
    [], head,
    ..lines.pos().enumerate().map(((i, body)) => (text(fill: luma(120))[#(i + 1)], body)).flatten(),
  )
]
#let cmt(body) = [#h(0.6em)#body]   // 擬似コードの行末コメント

#let ask(body) = marker("?", body)
#let later(body) = marker(">", body)
#let warn(body) = marker("!", body)

// ---- 本体 ----------------------------------------------------------------

#let ieice(
  jtitle: [],
  etitle: [],
  // ((jname, ename, affil, email), ...). affil は affiliations のキー.
  authors: (),
  // (キー: (ja: [...], en: [...]), ...). 並び順が † の数になる.
  affiliations: (:),
  abstract: [],
  keywords: (),
  eabstract: [],
  ekeywords: (),
  // フッタの "Copyright ©20xx by IEICE" の年
  year: "20xx",
  // 行と行の間の空きの倍率. 1.0 が ieice.cls どおり (行送り 20.5Q). ページ数に収めたいときに 0.8 などにする
  line-gap: 1.0,
  // false にすると #ask[] #later[] #warn[] を消す
  markers: true,
  body,
) = {
  set document(title: jtitle)
  show-markers.update(markers)
  let cvs = line-pitch(line-gap)
  let par-gap = cvs - size-normal

  // 版面: 本文 57 字 × 50 行, 2 段組, 段間 2 字. 上端と下端は ieice.cls の \topmargin の計算どおり.
  set page(
    paper: "a4",
    margin: (x: (210mm - 57 * zw) / 2, top: 43.84pt, bottom: 77pt),
    columns: 2,
    footer-descent: 0pt,
    footer: context {
      set text(size: size-normal, top-edge: "baseline", bottom-edge: "baseline")
      set par(first-line-indent: 0pt)
      v(26.07pt)
      if counter(page).get().first() == 1 {
        [This article is a technical report without peer review, and its polished and/or extended version may be published elsewhere.]
        place(right, dx: -9 * tp, dy: 3.5mm)[Copyright ©#year by IEICE]
      } else {
        align(right)[— #counter(page).display() —]
      }
    },
  )
  set columns(gutter: 2 * zw)

  set text(
    font: fonts-serif,
    size: size-normal,
    lang: "ja",
    region: "jp",
    top-edge: 0.88em,
    bottom-edge: -0.12em,
  )
  set par(justify: true, leading: par-gap, spacing: par-gap, first-line-indent: (amount: 1em, all: true),
    // 字間の伸縮は ieice.cls の \kanjiskip (0zw plus .1zw minus .025zw) に合わせる. 既定 (伸縮なし) のままだと
    // Typst は約物の後ろを半角近くまで詰めて行を合わせ, pTeX より1行に1字多く入る.
    justification-limits: (tracking: (min: -0.025em, max: 0.1em)))
  set block(spacing: par-gap)

  // 和文中の ", " ". " を "，" "．" にする. 英文は触らない. 対象は (a) 前後どちらかが和文字,
  // (b) 閉じ括弧か % の直後で, 次が大文字か括弧 (例: "(67.39%). M.Exp", "(−1.41pp). (4)"), または段落の終わり,
  // (c) テキストの切れ目の先頭 (引用の直後. 例: "[5]. 1サンプル". 引用は別の要素なので "]" とは一致しない).
  let cjk = "[\p{Han}\p{Hiragana}\p{Katakana}\x{3000}-\x{303F}\x{FF00}-\x{FFEF}]"
  // lang が en の所 (英文要旨, 文献) では置き換えない ("60%. Because" が "60%．Because" になっていた).
  show regex(cjk + "[,.] ?|[,.] ?" + cjk + "|[)%][,.] ?[A-Z(]|[)%]\.$|^[,.] "): it => context {
    if text.lang == "en" { return it }
    let cs = it.text.clusters()
    cs.map(c => if c == "," { "，" } else if c == "." { "．" } else if c == " " { "" } else { c }).join()
  }

  show strong: set text(font: fonts-gothic)

  // 見出し. 章: "1." 番号, 11pt 太字, 2 行取り. 節: "2. 1" 番号, 本文サイズ太字, 1 行取り.
  set heading(numbering: (..n) => {
    let n = n.pos().map(str)
    if n.len() == 1 { n.first() + "." } else { n.join(".\u{2009}") }
  })
  show heading: set text(font: fonts-gothic, weight: "bold", size: size-normal)
  show heading: set par(first-line-indent: 0pt, justify: false)
  show heading.where(level: 1): it => {
    if it.numbering == none {
      // 文献・謝辞など: 中央, 本文サイズ, 均等割り
      block(width: 100%, above: par-gap, below: 0.15 * cvs + par-gap, sticky: true, align(center, jidori(it.body)))
    } else {
      set text(size: size-Large, top-edge: "baseline", bottom-edge: "baseline")
      set par(leading: cvs)
      block(width: 100%, above: par-gap, below: par-gap, sticky: true, {
        v(15.19pt)
        h(1em)
        counter(heading).display(it.numbering)
        h(1em)
        jidori(it.body)
        v(2 * cvs - par-gap - 15.19pt)
      })
    }
  }
  // 章見出しの直後の節見出しは, pTeX では章の後ろの .5\Cvs が効かず, 章のベースラインから 16.71pt に来る
  // (テンプレート PDF の「2. 関連研究」→「2. 1 行動認識」の実測. 本文が続くときは 1.5 行 = 21.79pt).
  // 後ろの行も同じだけ上にずれたまま進む (節→本文は 1 行).
  show heading.where(level: 2): it => context {
    let prev = query(selector(heading).before(here())).filter(h => h.location() != it.location())
    let after-chapter = if prev.len() > 0 and prev.last().level == 1 {
      let p = prev.last().location().position()
      let q = here().position()
      p.page == q.page and calc.abs(p.x - q.x) < 1cm and q.y - p.y < 2.5 * cvs
    } else { false }
    let pull = if after-chapter { 1.5 * cvs - 16.71pt } else { 0pt }
    // block の above を減らしても, 章の block の below (par-gap) と大きい方が採られて効かない
    block(above: par-gap, below: par-gap, sticky: true, {
      v(-pull, weak: false)
      h(1em)
      counter(heading).display(it.numbering)
      h(1em)
      jidori(it.body)
    })
  }
  show heading.where(level: 3): it => block(above: par-gap, below: par-gap, sticky: true, {
    set text(font: fonts-serif, weight: "regular")
    h(1em)
    counter(heading).display(it.numbering)
    h(1em)
    it.body
  })

  // 参照: 見出しは "3節" "3.2節" (IEICE 和文論文は章ではなく節), 図表は "図1" "表1" (番号との間を空けない).
  show ref: it => {
    let el = it.element
    if el == none { return it }
    if el.func() == heading {
      let n = counter(heading).at(el.location())
      link(el.location(), n.map(str).join(".") + "節")
    } else if el.func() == figure {
      // Algorithm だけ番号の前を空ける ("Algorithm 1". 図表は "図1")
      let sep = if el.kind == "algorithm" { h(0.25em) } else { none }
      link(el.location(), [#el.supplement#sep#numbering(el.numbering, ..el.counter.at(el.location()))])
    } else if el.func() == math.equation {
      link(el.location(), [式#numbering(el.numbering, ..counter(math.equation).at(el.location()))])
    } else { it }
  }

  // 図表: 中身とキャプションは 8pt. 図はキャプションが下 (間 1mm), 表は上 (間 3pt).
  set figure(gap: 1mm, placement: auto)
  show figure: set text(size: size-small)
  show figure: set par(leading: 18 * Q - size-small, first-line-indent: 0pt)
  show figure.where(kind: table): set figure.caption(position: top)
  show figure.where(kind: table): set figure(gap: 3 * tp)
  // 擬似コード (kind: "algorithm") は表と同じくキャプションを上に置く
  show figure.where(kind: "algorithm"): set figure.caption(position: top)
  show figure.where(kind: "algorithm"): set figure(gap: 3 * tp)
  show figure.caption: it => layout(size => {
    let head = [#it.supplement#h(0.25em)#context it.counter.display(it.numbering)#h(1em)]
    let full = [#head#it.body]
    if measure(full).width > size.width {
      set align(left)
      par(justify: true, hanging-indent: measure(head).width, full)
    } else {
      align(center, full)
    }
  })
  set table(stroke: none, inset: (x: 0.5em, y: 2pt))

  // 脚注: 本文中は "（注1）", 脚注側は "（注1）：".
  // 本文中の印は \tiny (5pt) の上付きで, 括弧の外側の空きを半角ずつ詰める (ieice.cls の \@makefnmark).
  // 寸法は文字の大きさで決め打つ: super の中の em は本文の 9pt で解決されるため.
  // baseline も決め打つ: 既定 (auto) はフォントごとの上付きの位置を使い, 数字 (Times) だけ 2pt ほど下がる.
  // 3.27pt はテンプレート PDF の実測 (本文と印のベースラインの差). typographic: true だと数字だけさらに縮む.
  set footnote(numbering: n => [#h(-0.5 * size-tiny)（注#h(0.1 * size-tiny)#n）#h(-0.5 * size-tiny)])
  show footnote: set super(typographic: false, size: size-tiny, baseline: -3.27 * tp)
  set footnote.entry(separator: line(length: 100%, stroke: 0.1mm), indent: 0pt)
  show footnote.entry: it => {
    let n = counter(footnote).at(it.note.location()).first()
    set text(size: size-footnote)
    set par(first-line-indent: 0pt, leading: 16 * Q - size-footnote)
    // 「注」と番号の間は \kern.1zw. 和欧間の自動の空き (1/4 字) は入れない.
    { set text(cjk-latin-spacing: none); [（注#h(0.1em)#n）：] }
    it.note.body
  }

  // 数式: 左寄せ (ieice の雛形は amsmath の fleqn)
  show math.equation: set text(font: fonts-math)
  show raw: set text(font: fonts-mono)
  set math.equation(numbering: "(1)")
  show math.equation.where(block: true): set align(left)
  show math.equation.where(block: true): it => pad(left: 2 * zw, it)

  // 文献: 8pt, 行送り 15Q. 様式は学会配布の sieicej.bst に合わせた ieice.csl.
  set bibliography(title: [文献], style: "ieice.csl")
  show cite: ieice-cite
  show bibliography: set text(size: size-small, lang: "en")
  show bibliography: set par(justification-limits: (tracking: (min: 0em, max: 0em)))
  show bibliography: set par(leading: 15 * Q - size-small, spacing: 15 * Q - size-small, first-line-indent: 0pt)

  place(top, float: true, scope: "parent", clearance: 0pt,
    title-block(jtitle, etitle, authors, affiliations, abstract, keywords, eabstract, ekeywords, cvs))

  body
}
