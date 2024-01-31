(TeX-add-style-hook
 "template"
 (lambda ()
   (TeX-add-to-alist 'LaTeX-provided-class-options
                     '(("tufte-book" "notoc")))
   (TeX-add-to-alist 'LaTeX-provided-package-options
                     '(("inputenc" "utf8") ("fontenc" "T1")))
   (TeX-run-style-hooks
    "latex2e"
    "$listings-path$"
    "$listings-unicode-path$"
    "tufte-book"
    "tufte-book10"
    "changepage"
    "fancyhdr"
    "fontenc"
    "geometry"
    "hyperref"
    "natbib"
    "bibentry"
    "optparams"
    "paralist"
    "placeins"
    "ragged2e"
    "setspace"
    "textcase"
    "textcomp"
    "titlesec"
    "titletoc"
    "xcolor"
    "xifthen"
    "morefloats"
    "inputenc"
    "fontspec"
    "xeCJK"
    "graphicx"
    "float"
    "longtable"
    "booktabs"
    "array"
    "calc"
    "etoolbox"
    "amsfonts"
    "amssymb"
    "amsmath"
    "unicode-math"
    "xurl"
    "marginfix")
   (TeX-add-symbols
    '("CSLIndent" 1)
    '("CSLRightInline" 1)
    '("CSLLeftMargin" 1)
    '("CSLBlock" 1)
    '("passthrough" 1)
    '("href" 2)
    '("smallcapsspacing" 1)
    '("allcapsspacing" 1)
    "tightlist"
    "maxwidth"
    "maxheight"
    "cleardoublepage")
   (LaTeX-add-environments
    '("CSLReferences" 2))
   (LaTeX-add-lengths
    "cslhangindent"
    "csllabelwidth"))
 :latex)

