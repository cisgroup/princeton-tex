\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{princeton}[2023/01/15 A class for Princeton University documents]

% A toolbox of programming facilities
% https://ctan.org/pkg/etoolbox
\RequirePackage{etoolbox}

% Enable options in key value format for package options
% https://ctan.org/pkg/kvoptions
\RequirePackage{kvoptions}

% Enalbe if-then-else statements
% https://ctan.org/pkg/ifthen
\RequirePackage{ifthen}

% Option declarations
% ===================
\SetupKeyvalOptions{%
  family=princeton,
  prefix=princeton@
}

% Definition of the parent class
\DeclareStringOption[article]{class}[article]

% Position of the margin
\DeclareStringOption[left]{marginpos}[left]

% Color of the items
\DeclareStringOption[pu-gray]{itemcolor}[pu-gray]

% Draft document
\DeclareBoolOption[false]{draft}

% Spacing between items
\DeclareStringOption[-.5ex]{itemsep}[-.5ex]

% Format of the sections
\DeclareStringOption[simple]{titleformat}[simple]


% Apply provided options to the parent class (here article)
\DeclareDefaultOption{\PassOptionsToClass{\CurrentOptionKey}{\princeton@class}}

% Process keyval options
% ======================
\ProcessKeyvalOptions*

% Margin position
\ifthenelse
  {\equal{\princeton@marginpos}{left}}
  {\reversemarginpar} % reverse the margin to the left of the page
  {}

% TODO Process further options

% Load parent class
% -----------------
\LoadClass{\princeton@class}

% Load required packages
% ======================
\RequirePackage{parskip}  % disable indent
\RequirePackage{graphicx} % Images

% Class variables
% ===============

% https://tex.stackexchange.com/questions/552491/custom-commands-like-title-and-authors
\newcommand{\pretitle}[1]{\def\princeton@pretitle{#1}}
\newcommand{\subtitle}[1]{\def\princeton@subtitle{#1}}
\newcommand{\titlesize}[1]{\def\princeton@titlesize{#1}}
\newcommand{\email}[1]{\def\princeton@email{#1}}
\newcommand{\address}[1]{\def\princeton@address{#1}}
\newcommand{\version}[1]{\def\princeton@version{#1}}

% initialize variables
\titlesize{\huge}
\pretitle{}
\subtitle{}
\email{}
\address{}
\version{}

% Fix to access author and title in the whole class
% https://tex.stackexchange.com/questions/61495/access-title-and-author-in-custom-class
\def\title#1{\gdef\@title{#1}\gdef\princeton@title{#1}}
\def\author#1{\gdef\@author{#1}\gdef\princeton@author{#1}}
\let\princeton@title\@empty
\let\princeton@author\@empty

% Set length
\newlength{\droptitle}
\setlength{\droptitle}{-.75in}

\newlength{\boarder}
\setlength{\boarder}{.5in}

\newlength{\princeton@marginparwidth}
\setlength{\princeton@marginparwidth}{1.7in}

\newlength{\princeton@marginparsep}
\setlength{\princeton@marginparsep}{.2in}


% Maketitle
% =========
% Redefine standard maketitle command
\def\@maketitle{%
  \newpage
  \let \footnote \thanks
  \vspace*{\droptitle}
  \ifdefempty{\princeton@pretitle}{}%
  {{\Large\bf \princeton@pretitle}\\}%
  %
  {\princeton@titlesize\bf \@title \par}%
  %
  \ifdefempty{\princeton@subtitle}{}%
  {{\Large\bf \princeton@subtitle \par}}%
  \vskip .7em%
}

% Fonts
% =====
\RequirePackage{iftex}

% Whether to use fontspec for font selection (XeTeX and LuaTeX)
% defaults to false
\newbool{fontspec}

% Check what compiler is running so we know how to handle fonts later
\ifXeTeX \booltrue{fontspec}\else\fi
\ifLuaTeX\booltrue{fontspec}\else\fi

% Set fonts.
% Carlito is a free clone of Calibri; "lining" option for "normal" digits.
% STIX 2 is an advanced open font, broadly compatible with Times New Roman. 
% it also has great math rendering.
\ifbool{fontspec}{ % XeLaTeX or LuaLaTeX, advanced font handling
  \RequirePackage{fontspec}
  \defaultfontfeatures{Ligatures=TeX}
  \setmainfont[
    BoldFont={PrincetonMontiBD},
    ItalicFont={PrincetonMonti Italic},
    BoldItalicFont={PrincetonMontiBD Italic}
    ]{PrincetonMonti}
  % \setmainfont{STIX Two Text}
  % \setmathfont{STIX Two Math}
  % \setsansfont{\ifbool{calibri}{Calibri}{Carlito}}
}{ % Ye goode olde LaTeX and PDFLaTeX
  \RequirePackage[utf8]{inputenc}
  \RequirePackage[T1]{fontenc}
  % \RequirePackage{stix2}
  % \RequirePackage[lining]{carlito}
}


% Geometry
% ========
\RequirePackage[%
  paper=letterpaper,
  top=\boarder,
  bottom=\boarder,
  inner=\boarder,
  outer=\boarder,
  % headheight=34pt,
  marginparwidth=\princeton@marginparwidth,
  marginparsep=\princeton@marginparsep,
  % asymmetric,
  % reversemarginpar,
  includemp,
  % showframe,
  includeheadfoot
  ]{geometry}


% Logo
% ====
\RequirePackage{eso-pic}

\AddToShipoutPictureFG{
  \AtPageUpperLeft{%
    \put(\LenToUnit{\boarder},\LenToUnit{-\boarder}){%
      \raisebox{-\height}{%
        \includegraphics[width=1.5in]{princeton-logo}
      }%
    }%
  }%
}


% Header and footer
% =================
\RequirePackage{fancyhdr} % Header and footer

\pagestyle{fancy}
% Clear the header and footer
\fancyhead{}
\fancyfoot{}
% Set new variables
\fancyhead[L]{}
\fancyhead[R]{}
  \fancyfoot[R]{\ifthenelse{\boolean{princeton@draft}}{\textbf{DRAFT - }}{} \ifdefempty{\princeton@version}{}{\today-\princeton@version ~-~}\thepage}%
% Disable line in the header
\renewcommand{\headrulewidth}{0pt}

% Redefine plain style, which is used for titlepage and chapter beginnings
% From https://tex.stackexchange.com/a/30230/828
\fancypagestyle{plain}{%
  \renewcommand{\headrulewidth}{0pt}%
  \fancyhf{}%
  \fancyfoot[R]{\ifthenelse{\boolean{princeton@draft}}{\textbf{DRAFT - }}{} \ifdefempty{\princeton@version}{}{\today-\princeton@version ~-~}\thepage}%
}



% Colors
% ======
\RequirePackage{xcolor}   % load colors

\definecolor{pu-orange}{HTML}{EE7F2D}
\definecolor{pu-gray}{gray}{0.6}


% Sections
% ========
\RequirePackage{titlesec} % Section format

% Section numbers in the margin
% https://tex.stackexchange.com/questions/523000/titlesec-right-justified-section-number-in-margin
\newcommand{\marginsecnumber}[1]{%
  \makebox[0pt][r]{#1\hspace{6pt}}%
}

\ifthenelse{\equal{\princeton@titleformat}{simple}}
{% Simple spacing
  \titleformat{\section}
  {\normalfont\large\bfseries\color{pu-orange}}
  {\scriptsize\marginsecnumber\thesection}
  {0pt}
  {}

  \titleformat{\subsection}
  {\normalfont\normalsize\bfseries\color{black}}
  {\scriptsize\marginsecnumber\thesubsection}
  {0pt}
  {}

  \titleformat{\subsubsection}[runin]
  {\normalfont\normalsize\it\bfseries\color{black}}
  {\scriptsize\marginsecnumber\thesubsubsection}
  {0pt}
  {}

  \titlespacing{\section}{0pt}{12pt plus 4pt minus 2pt}{4pt plus 2pt minus 2pt}
  \titlespacing{\subsection}{0pt}{8pt plus 4pt minus 2pt}{2pt plus 2pt minus 2pt}
  
}
{% Fancy Spacing
  \titleformat{\section}
  {\normalfont\Large\it\color{pu-orange}}
  {\small\marginsecnumber\thesection}
  {0pt}
  {}[\vskip-12pt{\makebox[\linewidth][l]{\color{pu-orange}\rule{0.99\textwidth}{1.2pt}}}]

  \titleformat{\subsection}
  {\normalfont\large\bfseries\color{pu-orange}}
  {\scriptsize\marginsecnumber\thesubsection}
  {0pt}
  {}

  \titleformat{\subsubsection}
  {\normalfont\normalsize\bfseries\color{black}}
  {\scriptsize\marginsecnumber\thesubsubsection}
  {0pt}
  {}

  \titlespacing{\subsubsection}{0pt}{8pt plus 4pt minus 2pt}{2pt plus 2pt minus 2pt}
}

% Enumeration
% ===========
\RequirePackage{enumitem}
\RequirePackage{amssymb} % load library to access blacktriangleright
% Fix spacing of items
% \setitemize{itemsep=-1ex}
\setlist[enumerate]{topsep=0pt,itemsep=\princeton@itemsep,partopsep=1ex,parsep=1ex}
\setlist[itemize]{topsep=0pt,itemsep=\princeton@itemsep,partopsep=1ex,parsep=1ex}

% Change bullet point to colorful triangle
\renewcommand\labelitemi{\color{\princeton@itemcolor}$\blacktriangleright$}

% Datetime
% ========
\RequirePackage[yyyymmdd]{datetime}
\renewcommand{\dateseparator}{-}

% Margin
% ======
\RequirePackage{marginnote} % Notes in the margin

% Make margin notes left aligned
\renewcommand*{\raggedleftmarginnote}{}


% Make info
\newcommand{\makeinfo}{
\marginnote{%
  \footnotesize

  \ifdefempty{\princeton@author}{}%
  {
    \textcolor{pu-orange}{\textit{Author}}\newline
    \textbf{\princeton@author}
    \ifdefempty{\princeton@email}{}
    {\newline\href{mailto:\princeton@email}{\princeton@email}}%
  }%

  \ifdefempty{\princeton@address}{}%
  {
    \textcolor{pu-orange}{\textit{Address}}\newline
    \princeton@address
  }%

  \ifdefempty{\princeton@version}{}%
  {
    \textcolor{pu-orange}{\textit{Version}}\newline
    \today-\princeton@version
    \ifthenelse{\boolean{princeton@draft}}{\newline \textbf{DRAFT}}{}
  }%


}
}

% Margin description environment
% ------------------------------

% Create custom description environment
\newenvironment{customdescription}{%
  \footnotesize\setlist[description]{style=nextline,leftmargin=0pt}
   \renewcommand\descriptionlabel[1]{\hspace{\labelsep}\textcolor{pu-orange}{\textit{##1}}}
   \begin{description}%
}{%
   \end{description}%
}


% Create margin environment with custom description
\NewDocumentEnvironment{margindescription}{ b }{%
    \marginnote{%
    \begin{customdescription}
    #1
    \end{customdescription}
    }%
}{}

% Figures
% =======
\RequirePackage{sidenotes} % Figures and tables in the margin
\RequirePackage{ifoddpage}

% NOTE: Seems sidenotes is not working probably for figure* environment with the oneside layout option and left aligned margins

% https://tex.stackexchange.com/questions/170248/wrong-position-of-caption-in-odd-page-with-sidenotes-in-figure

% https://tex.stackexchange.com/questions/633593/caption-of-sidenote-packages-figure-widefigure-has-wrong-margin-or-width-in

\newlength{\xtramargin}
\setlength{\xtramargin}{\dimexpr \marginparsep +\marginparwidth +3pt}

\newenvironment{largefigure}[1][ht]
{\begin{figure*}[#1]\@ifoddpage{\hspace{-\xtramargin}}{}}
  {\end{figure*}}


\RequirePackage{keyval}
\RequirePackage{tikz}

% https://tex.stackexchange.com/questions/34312/how-to-create-a-command-with-key-values

% Initialize length values
\newlength{\fullfigure@height}

% Definition of key values
\define@key{fullfigure}{height}{\setlength\fullfigure@height{#1}}
\define@key{fullfigure}{angle}{\def\fullfigure@angle{#1}}
\define@key{fullfigure}{anchor}{\def\fullfigure@anchor{#1}}
\define@key{fullfigure}{align}{\def\fullfigure@align{#1}}

% Set default key values
\setkeys{fullfigure}{anchor=south,height=3in,angle=0,align=b}%

% Create full figure command
\newcommand{\fullfigure}[2][]{%
  % \begingroup%
  \setkeys{fullfigure}{#1}% Set new keys
  \AddToShipoutPictureBG*{% * i.e. only on current page
    \ifthenelse{\equal{\fullfigure@align}{b}}% if
    {% then
      % NOTE: \AtPageLowerLeft has a gap at the border hence use tikz
      % https://tex.stackexchange.com/questions/474007/unwanted-white-space-between-picture-drawn-by-tikz-and-page-border
      \begin{tikzpicture}[remember picture,overlay]
        \node[anchor=south west, inner sep=0pt] at (current page.south west)
        {\includegraphics[width=\paperwidth,
          height=\fullfigure@height,
          angle=\fullfigure@angle]{#2}};%
      \end{tikzpicture}
    }{% else
      \AtPageUpperLeft{%
        \raisebox{-\height}{%
          \includegraphics[width=\paperwidth,
          height=\fullfigure@height,
          angle=\fullfigure@angle]{#2}%
        }%
      }%
    } % endif
  }% 
  % \endgroup%
}%

% Bibliography  
% ============

% Hyper references
% ================
\RequirePackage[draft=false]{hyperref}