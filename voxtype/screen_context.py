#!/usr/bin/env python3
"""Collect on-screen vocabulary for dictation cleanup.

Started in the background by ptt.sh when Right Ctrl goes down, so it runs while
you talk: screenshot the focused window, OCR it (parallel strips, ~1.5s), pull
out unusual terms (file names, identifiers, names), write them to
$XDG_RUNTIME_DIR/voxtype-ptt/context.json, then pre-load the cleanup LLM's prompt
cache with them. cleanup.py reads the file after transcription.

Everything stays local; the screenshot lives on tmpfs and is deleted right away.
"""
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile
from collections import Counter
from concurrent.futures import ThreadPoolExecutor

RUN = os.path.join(os.environ.get("XDG_RUNTIME_DIR", "/tmp"), "voxtype-ptt")
CTX = os.path.join(RUN, "context.json")
PENDING = os.path.join(RUN, "context.pending")
STRIPS = 8          # parallel single-threaded tesseract runs (faster than its own threading)
MAX_TERMS = 60
COMMON_WORDS = "/usr/share/dict/cracklib-small"

EDGE_PUNCT = "()[]{}<>\"'`,;:!?*“”‘’|"
CLEAN_TOKEN = re.compile(r"[A-Za-z0-9_.\-+@#~]+")
IDENT = re.compile(r"[a-z][A-Z]|_|\.[A-Za-z]{1,6}$|[A-Za-z]\d|\d[A-Za-z]|[A-Za-z]-[A-Za-z]")


def sh(cmd, **kw):
    return subprocess.run(cmd, capture_output=True, text=True, **kw)


def active_window():
    try:
        w = json.loads(sh(["hyprctl", "activewindow", "-j"], timeout=2).stdout or "{}")
        (x, y), (wd, ht) = w["at"], w["size"]
        return f"{x},{y} {wd}x{ht}", w.get("class", ""), w.get("title", "")
    except Exception:
        return None, "", ""


def ocr(geom, tmp):
    """Return [(word, confidence)] for the focused window."""
    shot = os.path.join(tmp, "shot.ppm")
    # Logical-pixel capture (-s 1): text is still large enough, and 1.67x fewer pixels.
    # PPM/PGM throughout: no PNG encode/decode between steps.
    if sh(["grim", "-s", "1", "-t", "ppm", "-g", geom, shot], timeout=5).returncode:
        return []
    # Tesseract wants dark text on light; invert dark themes (mean of a thumbnail is plenty)
    mean = float(sh(["magick", shot, "-colorspace", "gray", "-resize", "64x64!",
                     "-format", "%[fx:mean]", "info:"]).stdout or 1)
    sh(["magick", shot, "-colorspace", "gray", *(["-negate"] if mean < 0.5 else []),
        "-crop", f"1x{STRIPS}+0+14@", "+repage", os.path.join(tmp, "s_%02d.pgm")])
    strips = sorted(f for f in os.listdir(tmp) if f.startswith("s_"))
    env = {**os.environ, "OMP_THREAD_LIMIT": "1"}

    def run(f):
        tsv = sh(["tesseract", os.path.join(tmp, f), "stdout", "--psm", "11", "-l", "eng",
                  "-c", "tessedit_do_invert=0", "tsv"], env=env, timeout=10).stdout
        words = []
        for line in tsv.splitlines()[1:]:
            cols = line.split("\t")
            if len(cols) == 12 and cols[11].strip():
                words.append((cols[11], float(cols[10])))
        return words

    with ThreadPoolExecutor(len(strips) or 1) as pool:
        return [w for ws in pool.map(run, strips) for w in ws]


def load_common():
    try:
        with open(COMMON_WORDS) as f:
            return {w.strip().lower() for w in f}
    except OSError:
        return set()


MIN_CONF = 60       # tesseract word confidence; below this it's mostly garbage


def extract_terms(words, title):
    common = load_common()
    counts, casing, score = Counter(), {}, {}
    pieces = []
    text = " ".join(w for w, conf in words if conf >= MIN_CONF)
    for raw in (text + " " + title).split():
        for part in raw.strip(EDGE_PUNCT).split("/"):      # paths: score each component
            pieces.append(part.strip(EDGE_PUNCT).rstrip("."))
    title_words = {p.strip(EDGE_PUNCT).rstrip(".").lower() for p in title.split()}

    for tok in pieces:
        if not (3 <= len(tok) <= 40) or not CLEAN_TOKEN.fullmatch(tok):
            continue                                        # garbled OCR (?, ;, ligatures...)
        if not re.search(r"[A-Za-z]{2}", tok):
            continue
        digits = sum(c.isdigit() for c in tok)
        if digits / len(tok) > 0.4:
            continue                                        # hashes, ids, numbers
        low = tok.lower()
        if IDENT.search(tok):
            s = 3                                           # Dictation.qml, snake_case, camelCase, int8
        elif tok[0].isupper() and low not in common:
            s = 2                                           # proper nouns: Parakeet, Hyprland
        elif low not in common and tok.isalpha() and len(tok) >= 4:
            s = 1                                           # rare words: voxtype, tesseract
        else:
            continue
        counts[low] += 1
        score[low] = max(score.get(low, 0), s)
        casing.setdefault(low, Counter())[tok] += 1

    terms = []
    for low, n in counts.items():
        # Seen once: keep only file names and title words. One-off "identifiers"
        # and rare words are mostly OCR noise (JUALU_TLLC_LtEillajsaw).
        is_file = re.search(r"\.[A-Za-z]{1,6}$", low) is not None
        if n < 2 and not is_file and low not in title_words:
            continue
        terms.append((score[low], n, casing[low].most_common(1)[0][0]))
    terms.sort(key=lambda t: (-t[0], -t[1]))
    return [t for _, _, t in terms[:MAX_TERMS]]


def main():
    os.makedirs(RUN, exist_ok=True)
    open(PENDING, "w").close()
    tmp = tempfile.mkdtemp(dir=RUN)
    terms, wclass, title = [], "", ""
    try:
        geom, wclass, title = active_window()
        if geom:
            terms = extract_terms(ocr(geom, tmp), title)
        with open(CTX + ".tmp", "w") as f:
            json.dump({"terms": terms, "class": wclass, "title": title}, f)
        os.replace(CTX + ".tmp", CTX)
    finally:
        shutil.rmtree(tmp, ignore_errors=True)
        try:
            os.remove(PENDING)
        except OSError:
            pass
    # Pre-load the LLM prompt cache so cleanup only has to read the transcript
    sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
    sys.dont_write_bytecode = True      # no __pycache__ in the dotfiles repo
    try:
        import cleanup
        cleanup.prewarm(terms)
    except Exception:
        pass
    if "--print" in sys.argv:
        print(json.dumps({"class": wclass, "title": title, "terms": terms}, indent=1))


if __name__ == "__main__":
    main()
