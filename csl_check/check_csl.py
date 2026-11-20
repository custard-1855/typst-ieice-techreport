"""ieice.csl の出力を sieicej.bst の出力と照合する.

英文の期待値は学会配布のテンプレート PDF (2026年12月版) の文献欄 (bst で組んだもの) を写したもの.
規格文書と和文の期待値は sieicej.bst の techreport / article を手で追ったもの.
リポジトリのルートから: make check (= uv run --with pymupdf python csl_check/check_csl.py)
"""
import re
import shutil
import subprocess
import sys
from pathlib import Path

import pymupdf

HERE = Path(__file__).parent
# typst があればそれを, 無ければ Quarto 同梱の typst を使う
TYPST = ["typst"] if shutil.which("typst") else ["quarto", "typst"]

EXPECTED = {
    1: "S. Cornell, J. Ebbers, C. Douwes, I. Martín-Morató, M. Harju, A. Mesaros, and R. Serizel, "
       "“DCASE 2024 task 4: Sound event detection with heterogeneous data and missing labels,” arXiv:2406.08056, 2024.",
    2: "S. Blackman, C. Matlo, C. Bobrovitskiy, A. Waldoch, M.L. Fang, P. Jackson, A. Mihailidis, L. Nygård, A. Astell, "
       "and A. Sixsmith, “Ambient assisted living technologies for aging well: a scoping review,” "
       "Journal of Intelligent Systems, vol.25, no.1, pp.55–69, 2016.",
    3: "B.M.V. Guerra, E. Torti, E. Marenzi, M. Schmid, S. Ramat, F. Leporati, and G. Danese, "
       "“Ambient assisted living for frail people through human activity recognition: state-of-the-art, challenges "
       "and future directions,” Frontiers in neuroscience, vol.17, p.1256682, 2023.",
    4: "D. Bouchabou, S.M. Nguyen, C. Lohr, B. LeDuc, and I. Kanellos, “A survey of human activity recognition in "
       "smart homes based on IoT sensors algorithms: Taxonomies, challenges, and opportunities with deep learning,” "
       "Sensors, vol.21, no.18, p.6037, 2021.",
    5: "S.H. Hyun, “Sound-event detection of water-usage activities using transfer learning,” Sensors, vol.24, no.1, p.22, 2023.",
    6: "A. Mesaros, T. Heittola, T. Virtanen, and M.D. Plumbley, “Sound event detection: A tutorial,” "
       "IEEE Signal Processing Magazine, vol.38, no.5, pp.67–83, 2021.",
    7: "F. Schmid, P. Primus, T. Morocutti, J. Greif, and G. Widmer, “Improving audio spectrogram transformers for sound "
       "event detection through multi-stage training,” arXiv:2408.00791, 2024.",
    8: "A. Tarvainen and H. Valpola, “Mean teachers are better role models: Weight-averaged consistency targets improve "
       "semi-supervised deep learning results,” Advances in Neural Information Processing Systems, vol.30, pp.1195–1204, 2017.",
    9: "S. Xiao, X. Zhang, and P. Zhang, “Multi-dimensional frequency dynamic convolution with confident mean teacher "
       "for sound event detection,” Proc. ICASSP, pp.1–5, 2023.",
    10: "Z. Niu, Q. Wu, and Y. Hu, “SAT-SED: Semi-Supervised Sound Event Detection by Pseudo-Labeling with Self-Adaptive "
        "Threshold Strategy,” 2025 IEEE 6th International Seminar on Artificial Intelligence, Networking and Information "
        "Technology (AINIT), pp.1743–1748, 2025.",
    11: "K. Zhou, Y. Yang, Y. Qiao, and T. Xiang, “Domain generalization with mixstyle,” Proc. ICLR, pp.1–15, 2021.",
    12: "Y. Xiao, H. Yin, J. Bai, and R.K. Das, “FMSG-JLESS submission for DCASE 2024 task4 on sound event detection "
        "with heterogeneous training dataset and potentially missing labels,” arXiv:2407.00291, 2024.",
    13: "ETSI, “Zero-touch network and Service Management (ZSM); Reference Architecture,” Group Specification "
        "ETSI GS ZSM 002 V1.1.1, European Telecommunications Standards Institute, Aug. 2019.",
    14: "竹本志恩，川原亮一，“ネットワーク性能予測モデルの分析，” 信学論 (B)，vol.J100-B，no.1，pp.1–10，2017．",
}
# ieice.cls の citesort: 並べ替え, "],\,[" で区切り, 3件以上の連番は "]〜[" で畳む
EXPECTED_CITES = "[3], [4] ; [2]〜[5] ; [5], [6]"


def normalize(s: str) -> str:
    # 行は折り返さない (check.typ のページ幅). 細い空白は残す.
    return re.sub(r"[ \n]+", " ", s).strip()


def main() -> int:
    pdf = HERE / "check.pdf"
    subprocess.run([*TYPST, "compile", "--root", str(HERE.parent), str(HERE / "check.typ"), str(pdf)],
                   check=True)
    text = "".join(page.get_text() for page in pymupdf.open(pdf))
    fails = 0

    cites = normalize(text.split("CITE:")[1].split("END")[0])
    if cites.replace(" ", "") != EXPECTED_CITES.replace(" ", "") or " " not in text:
        print(f"NG cite\n  got:  {cites!r}\n  want: {EXPECTED_CITES!r}")
        fails += 1

    body = text.split("END")[1]
    entries = {int(m.group(1)): normalize(m.group(2))
               for m in re.finditer(r"^\[(\d+)\]\s*(.*?)(?=^\[\d+\]|\Z)", body, re.S | re.M)}
    for n, want in EXPECTED.items():
        got = entries.get(n, "")
        if got != want:
            print(f"NG [{n}]\n  got:  {got}\n  want: {want}")
            fails += 1
    print(f"{len(EXPECTED) + 1 - fails}/{len(EXPECTED) + 1} OK")
    return 1 if fails else 0


if __name__ == "__main__":
    sys.exit(main())
