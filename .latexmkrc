# latexmk configuration for princeton-tex
#
# Default engine is lualatex, which is what the class is designed for and the
# only engine that can use the Princeton Monticello family. pdfLaTeX is a
# supported second engine and is what CI uses, since it needs no font install.
#
# The class file lives at the repository root while the examples live one level
# down, so put both "." and ".." on TEXINPUTS. That lets a fresh clone build
# without installing anything into TEXMFHOME first, whether latexmk is invoked
# from the root or from examples/.

$ENV{'TEXINPUTS'} = '.:..:' . ($ENV{'TEXINPUTS'} // '');

# 4 = lualatex. Override on the command line with -pdf to use pdfLaTeX.
$pdf_mode = 4;

$lualatex = 'lualatex --interaction=nonstopmode --synctex=1 %O %S';
$pdflatex = 'pdflatex --interaction=nonstopmode --synctex=1 %O %S';

# Enough passes to settle the table of contents and cross-references.
$max_repeat = 5;

# Auxiliary files the standard clean does not know about.
$clean_ext = 'synctex.gz synctex run.xml bbl';
