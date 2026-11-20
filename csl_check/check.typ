// ieice.csl の検査用. ビルドと照合は check_csl.py が行う.
// 行の折り返しで照合がずれないよう, ページを十分に広くしてある.
#import "../ieice.typ": ieice-cite
#set page(width: 120cm, height: auto, margin: 1cm)
#set text(font: ("Times", "Hiragino Mincho ProN"), size: 8pt)
#show cite: ieice-cite

@cornell2024dcase @blackman2016ambient @guerra2023ambient @bouchabou2021survey @hyun2023sound
@mesaros2021sound @schmid2024improving @tarvainen2017mean @xiao2023multi @11036061 @zhou2021domain
@xiao2024fmsg @etsi2019zsm002 @ja-article @knuth1997art @roe2020thesis @roe2019report @ja-book

CITE: @guerra2023ambient @bouchabou2021survey ; @blackman2016ambient @guerra2023ambient @bouchabou2021survey @hyun2023sound ; @hyun2023sound @mesaros2021sound END

#bibliography(("fixture.bib", "fixture_ja.yml"), title: none, style: "../ieice.csl")
