\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{princeton}[2026/09/05 v1.2 A class for Princeton University documents]

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

% Color links. When true, links are set as coloured text. When false, they are
% left undecorated via hyperref's hidelinks. Defaults to true: the previous
% default of false combined with the unconditional \hypersetup at the end of
% this file to draw a border box around every link, which was never intended.
\DeclareBoolOption[true]{colorlinks}

% Show today's date in the page footer, when no \version is set. A version
% always implies a date, so this option only matters without one.
\DeclareBoolOption[false]{date}

% Print \@date under the title. Off by default, because the title block
% deliberately carries only pretitle, title and subtitle: the date lives in the
% footer and in the margin info block. Turn this on if you want \date{...} to
% behave the way \maketitle does in a stock class.
\DeclareBoolOption[false]{titledate}

% Spacing between items
\DeclareStringOption[.0ex]{itemsep}[.0ex]

% Format of the sections
\DeclareStringOption[simple]{titleformat}[simple]

% Where the identity mark appears.
%   default  the full mark on every page
%   first    the full mark on the opening page only
%   running  the full mark on the opening page, and the long single-line mark
%            on every page after it
%   none     no mark
\DeclareStringOption[default]{logo}[default]

% Which typeface family to use.
%   auto      Princeton Monticello when the engine and the installed fonts
%             allow it, otherwise the free fallback family. The default.
%   princeton Insist on Monticello. Errors under pdfLaTeX, which cannot load it.
%   free      Always use the free fallback family. This is what CI wants, and
%             what to use when sharing a source tree with someone who does not
%             have the licensed Princeton fonts.
\DeclareStringOption[auto]{fontset}[auto]

% How many columns the body is set in.
%   one  the whole document keeps the wide left margin. The default.
%   two  page 1 keeps the wide left margin, and the body from page 2 onward is
%        set in two columns with the long single-line mark on top.
%
% Deliberately NOT called twocolumn. That name already passes through to the
% base class, where it applies to page 1 as well, which is not what this does.
\DeclareStringOption[one]{columns}[one]

% The inherited twocolumn option is silently broken with this class: geometry
% double-subtracts the margin column and leaves a 3.31in text block inside a
% 7.5in printable band, with no error. Catch it and point at the real option
% rather than letting someone ship a document laid out like that.
\DeclareVoidOption{twocolumn}{%
  \ClassError{princeton}
    {The twocolumn option is not supported by this class}
    {Use columns=two instead. It keeps page 1 one-column with the wide margin
     and sets the body from page 2 in two columns. Passing twocolumn through to
     the base class collapses the text block to 3.31in and does so silently.}%
}

% Which visual identity to use.
%   classic      The University identity this class has always produced:
%                Princeton Monticello, an old-style serif, orange EE7F2D.
%                The default, so existing documents are untouched.
%   engineering  The Princeton Engineering identity published October 2024:
%                Libre Franklin, a grotesque sans, orange F58025, Caslon Doric
%                Condensed Bold for display, and the chevron device.
\DeclareStringOption[classic]{theme}[classic]

% Which identity lock-up to stamp on the page. Only meaningful with
% theme=engineering; the classic theme always uses the University mark.
%   engineering  Princeton + Engineering, the school-level mark. The default.
%   university   the University mark the class has always shipped
%   none         no signature
\DeclareStringOption[engineering]{signature}[engineering]

% Whether the mark is printed in full colour or as one colour.
%   color  the full-colour cut, with the orange. The default.
%   black  the one-colour cut, for monochrome printing or a document that
%          should carry no orange at all.
\DeclareStringOption[color]{logocolor}[color]


% Apply provided options to the parent class (here article)
\DeclareDefaultOption{\PassOptionsToClass{\CurrentOptionKey}{\princeton@class}}

% Process keyval options
% ======================
\ProcessKeyvalOptions*

% Option validation
% =================
% Every string option below is consumed by an \ifthenelse chain whose final
% branch is reached by falling through. Without validation a typo therefore
% selects that final branch silently: titleformat=fnacy quietly produced the
% fancy headings, and logo=nolgo quietly produced no logo at all. Check the
% values up front instead, so a mistake is reported rather than guessed at.
%
% #1 option name, #2 the value given, #3 comma separated list of valid values.
\newcommand{\princeton@checkoption}[3]{%
  % \ifx against an \edef-expanded copy of the value, rather than \ifthenelse
  % with \equal, so the comparison is a plain token-list test with no package
  % machinery in the loop body. The flag is global for the same reason: it
  % cannot be lost to a group introduced by anything the body expands to.
  \gdef\princeton@option@ok{0}%
  \edef\princeton@option@given{#2}%
  \@for\princeton@option@val:=#3\do{%
    \ifx\princeton@option@val\princeton@option@given
      \gdef\princeton@option@ok{1}%
    \fi
  }%
  \ifnum\princeton@option@ok=0\relax
    \ClassError{princeton}
      {Unknown value '#2' for class option #1}
      {Valid values for #1 are: #3.}%
  \fi
}

\princeton@checkoption{marginpos}{\princeton@marginpos}{left,right}
\princeton@checkoption{titleformat}{\princeton@titleformat}{simple,cv,fancy}
\princeton@checkoption{logo}{\princeton@logo}{default,first,running,none}
\princeton@checkoption{fontset}{\princeton@fontset}{auto,princeton,free}
\princeton@checkoption{theme}{\princeton@theme}{classic,engineering}
\princeton@checkoption{signature}{\princeton@signature}{engineering,university,none}
\princeton@checkoption{logocolor}{\princeton@logocolor}{color,black}
\princeton@checkoption{columns}{\princeton@columns}{one,two}

% Margin position
\ifthenelse
  {\equal{\princeton@marginpos}{left}}
  {\reversemarginpar} % reverse the margin to the left of the page
  {}

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
\setlength{\princeton@marginparsep}{.4in}


% Maketitle
% =========
% Redefine standard maketitle command
\def\@maketitle{%
  \newpage
  \let \footnote \thanks
  \vspace*{\droptitle}
  % \princeton@titlefont and princeton@titlecolor come from princeton-identity
  % and follow the theme. Under classic they are \bfseries and black, which
  % is what this block always used. Under engineering they are the Caslon Doric
  % display face and the brand orange, which the guidelines permit here because
  % the title is the largest type on the page.
  \ifdefempty{\princeton@pretitle}{}%
  {{\Large\princeton@titlefont \princeton@pretitle}\\}%
  %
  {\princeton@titlesize\princeton@titlefont
   \color{princeton@titlecolor}\@title \par}%
  %
  \ifdefempty{\princeton@subtitle}{}%
  {{\Large\princeton@titlefont \princeton@subtitle \par}}%
  %
  % \date is a standard LaTeX command that users reasonably expect \maketitle
  % to honour, but this class deliberately keeps the title block to pretitle,
  % title and subtitle, and puts the date in the footer and the margin info
  % block instead. Rather than leave \date silently inert, make it opt-in.
  \ifthenelse{\boolean{princeton@titledate}}
    {\ifdefempty{\@date}{}{{\normalsize\@date \par}}}
    {}%
  \vskip .7em%
}

% Identity: palette and fonts
% ===========================
% Both are decided by the theme option, so they live together in one module.
% It reads \princeton@theme and \princeton@fontset, which are set and validated
% above, and defines the pu-* colours plus the text, display and maths fonts.
% See princeton-identity.sty for the reasoning, including why colours are named
% by role rather than by hue.
%
% Check for the module before requiring it. As of v1.1 the class is no longer a
% single file, so an installation that predates the split has princeton.cls on
% the search path but not its companions, and the kernel's own report for that
% is "File `princeton-identity.sty' not found", which does not say what to do.
\IfFileExists{princeton-identity.sty}
  {}
  {\ClassError{princeton}
    {princeton-identity.sty not found}
    {As of v1.1 this class ships companion files alongside princeton.cls.
     Run 'make install' in the repository to symlink them into TEXMFHOME, or
     put the repository root on TEXINPUTS.}}
\RequirePackage{princeton-identity}

% Microtypography
% ===============
% Character protrusion and font expansion. This matters more here than in a
% normal class: the text block is a narrow measure beside a wide margin, and a
% narrow measure is exactly where ragged edges and loose lines are most
% visible. Both features work under pdfLaTeX and lualatex.
%
% Loaded after the text font is selected, which microtype requires in order to
% pick up the right protrusion lists.
%
% verbose=silent demotes microtype's warnings to log-only info. It is used for
% one specific and unactionable case: building the protrusion list, microtype
% probes accented characters that Monticello does not contain, and reports
% "Unknown slot number of character" for each. Checked with otfinfo, the font
% really does lack U+0104 and U+0102 while carrying U+00C1, so the messages are
% correct but not something a document author can act on. Forty-seven of them
% per run buried every other warning. The information is still in the .log.
\RequirePackage[protrusion=true,expansion=true,verbose=silent]{microtype}


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

% Every identity has two marks: a full one for the opening page, and a long
% single-line one compact enough to run across later pages without competing
% with the text. Files follow one scheme,
%
%   princeton-mark-<identity>[-long][-black].pdf
%
% so the variant is readable from the filename. The -black cuts are shipped for
% documents that need a one-colour mark; the class uses the full-colour ones.
%
% Widths are per mark because the aspect ratios are not comparable. The full
% marks are all near 3.5:1, but the long ones are 5.62:1 for Engineering and
% 14.74:1 for the University, whose long cut is a genuinely thin single rule of
% type. One width for both would leave one of them illegible.
%
%   identity     full   long
%   engineering  3.25:1 5.62:1   shield + PRINCETON + ENGINEERING
%   university   3.66:1 14.74:1  the mark the class has always shipped
\def\princeton@markfile@engineering{princeton-mark-engineering}
\def\princeton@markwidth@engineering{1.5in}
\def\princeton@longfile@engineering{princeton-mark-engineering-long}
\def\princeton@longwidth@engineering{1.5in}
\def\princeton@markfile@university{princeton-mark-university}
\def\princeton@markwidth@university{1.5in}
\def\princeton@longfile@university{princeton-mark-university-long}
\def\princeton@longwidth@university{2.0in}
\def\princeton@markfile@none{}
\def\princeton@markwidth@none{1.5in}
\def\princeton@longfile@none{}
\def\princeton@longwidth@none{1.5in}

% The classic theme always uses the University mark: its whole point is that
% it produces what the class always produced, so signature does not apply.
\ifthenelse{\equal{\princeton@theme}{engineering}}
  {\edef\princeton@whichmark{\princeton@signature}}
  {\def\princeton@whichmark{university}}

\edef\princeton@markfile{\csname princeton@markfile@\princeton@whichmark\endcsname}
\edef\princeton@markwidth{\csname princeton@markwidth@\princeton@whichmark\endcsname}
\edef\princeton@longfile{\csname princeton@longfile@\princeton@whichmark\endcsname}
\edef\princeton@longwidth{\csname princeton@longwidth@\princeton@whichmark\endcsname}

% logocolor=black swaps each mark for its one-colour cut, which is the same
% filename with -black appended.
%
% The existence test is not defensive padding. Some marks are already
% monochrome and ship no separate cut: the University long mark, for one, is a
% single line of near-black type with no orange in it at all. Falling back to
% the plain name means logocolor=black works for those too, instead of failing
% on a file that would only ever have been a duplicate.
\ifthenelse{\equal{\princeton@logocolor}{black}}{%
  \ifdefempty{\princeton@markfile}{}{%
    \IfFileExists{\princeton@markfile-black.pdf}
      {\edef\princeton@markfile{\princeton@markfile-black}}{}}%
  \ifdefempty{\princeton@longfile}{}{%
    \IfFileExists{\princeton@longfile-black.pdf}
      {\edef\princeton@longfile{\princeton@longfile-black}}{}}%
}{}

% One stamp macro, parameterised by file and width, so the full and long marks
% share a single placement rule and cannot drift apart.
\newcommand{\princeton@stamp}[2]{%
  \AtPageUpperLeft{%
    \put(\LenToUnit{\boarder},\LenToUnit{-\boarder}){%
      \raisebox{-\height}{%
        \includegraphics[width=#2]{#1}%
      }%
    }%
  }%
}
\newcommand{\princeton@logostamp}{%
  \princeton@stamp{\princeton@markfile}{\princeton@markwidth}}
\newcommand{\princeton@longstamp}{%
  \princeton@stamp{\princeton@longfile}{\princeton@longwidth}}

% The graphic is reached through TEXINPUTS rather than a \graphicspath, so a
% fresh clone that has not been installed into TEXMFHOME cannot see it. Test
% once here, rather than letting every single page fail at shipout with a
% missing-file error that does not name the real cause.
\newbool{princeton@haslogo}
\ifdefempty{\princeton@markfile}
  {}% signature=none: nothing to find, and nothing to warn about
  {\IfFileExists{\princeton@markfile.pdf}{\booltrue{princeton@haslogo}}{}}

\ifbool{princeton@haslogo}
  {}
  {\ifthenelse{\equal{\princeton@logo}{none}}
    {}% no logo was wanted anyway, so nothing to report
    {\ifdefempty{\princeton@markfile}
      {}% signature=none, likewise deliberate
      {\ClassWarningNoLine{princeton}
        {\princeton@markfile.pdf not found, so the mark is omitted.\MessageBreak
         Run 'make install', or put the repository root on TEXINPUTS}}}}

% logo=running needs to tell the first shipout page from the rest. \thepage is
% the wrong test: a document with roman front matter restarts it, and the mark
% would then reappear at full size partway through. Counting shipouts instead
% is independent of whatever the page counter is doing.
\newcounter{princeton@shipout}
\setcounter{princeton@shipout}{0}

\ifbool{princeton@haslogo}{%
  \ifthenelse{\equal{\princeton@logo}{default}}
    {\AddToShipoutPictureFG{\princeton@logostamp}}% full mark, every page
    {\ifthenelse{\equal{\princeton@logo}{first}}
      {\AddToShipoutPictureFG*{\princeton@logostamp}}% full mark, first page only
      {\ifthenelse{\equal{\princeton@logo}{running}}
        {% full mark on the opening page, long mark on every page after it
         \AddToShipoutPictureFG{%
           \stepcounter{princeton@shipout}%
           \ifnum\value{princeton@shipout}=1\relax
             \princeton@logostamp
           \else
             \princeton@longstamp
           \fi}}
        {}}}% logo=none, validated above, so nothing else can reach here
}{}


% Header and footer
% =================
\RequirePackage{fancyhdr} % Header and footer

% The footer content, defined once and shared by both page styles below. It
% was previously written out twice, character for character, so any change to
% the draft marker, the version stamp or the date had to be made in two places
% and stayed correct only by luck.
%
% Reading order: an optional DRAFT marker, then either a version stamp or a
% bare date or nothing, then the page number. A version always implies a date,
% which is why the date option is consulted only when no version is set.
\newcommand{\princeton@footer}{%
  \ifthenelse{\boolean{princeton@draft}}
    {\textbf{DRAFT -}}
    {}%
  \ifdefempty{\princeton@version}
    {\ifthenelse{\boolean{princeton@date}}{\today ~-~}{}}
    {\today-\princeton@version ~-~}%
  \thepage
}

\pagestyle{fancy}
% Clear the header and footer
\fancyhead{}
\fancyfoot{}
% Set new variables
\fancyhead[L]{}
\fancyhead[R]{}
\fancyfoot[R]{\princeton@footer}%
% Disable line in the header
\renewcommand{\headrulewidth}{0pt}

% Redefine plain style, which is used for titlepage and chapter beginnings
% From https://tex.stackexchange.com/a/30230/828
\fancypagestyle{plain}{%
  \renewcommand{\headrulewidth}{0pt}%
  \fancyhf{}%
  \fancyfoot[R]{\princeton@footer}%
}



% Colors
% ======
% xcolor and the whole pu-* palette now come from princeton-identity, loaded
% above, because the values depend on the theme. The role colours available
% here are pu-display, pu-heading, pu-link and pu-rule, alongside the literal
% pu-orange and pu-gray. Prefer the role names: under theme=engineering the
% brand orange fails WCAG AA below 18pt, and the role split is what keeps it
% off small type.


% Sections
% ========
\RequirePackage{titlesec} % Section format

% Section numbers in the margin
% https://tex.stackexchange.com/questions/523000/titlesec-right-justified-section-number-in-margin
\newcommand{\marginsecnumber}[1]{%
  \makebox[0pt][r]{#1\hspace{6pt}}%
}

% Section title in the margin
% https://tex.stackexchange.com/questions/291973/titlesec-chapter-in-top-margin

\newcommand{\marginsection}[1]{%
  \marginnote{
    \smash{
      \makebox[0pt][l]{%
        \parbox[t]{\marginparwidth}{%
          \raggedright#1%
        }%
      }%
    }%
  }%
}%

\ifthenelse{\equal{\princeton@titleformat}{simple}}
{% Simple spacing
  \titleformat{\section}
  {\normalfont\large\bfseries\color{pu-heading}}
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
{% Else If CV
  \ifthenelse{\equal{\princeton@titleformat}{cv}}
  {% CV spacing
    \titleformat{\section}
    {\normalfont\large\bfseries\color{pu-heading}}
    {\scriptsize\marginsecnumber\thesection}
    {0pt}
    {}

    \titleformat{\subsection}[leftmargin]
    {\normalfont\normalsize\bfseries\color{black}}
    {}
    {0pt}
    {\marginsection}

    \titleformat{\subsubsection}
    {\normalfont\normalsize\it\color{black}}
    {\scriptsize\marginsecnumber\thesubsubsection}
    {0pt}
    {}

    \titlespacing{\section}{0pt}{12pt plus 4pt minus 2pt}{4pt plus 2pt minus 2pt}
    \titlespacing{\subsection}{0pt}{8pt plus 4pt minus 2pt}{2pt plus 2pt minus 2pt}
    \titlespacing{\subsubsection}{0pt}{8pt plus 4pt minus 2pt}{4pt plus 2pt minus 2pt}
    \titlespacing{\paragraph}{0pt}{4pt}{2pt}
    
  }% Else: titleformat=fancy. The option validator above restricts the value to
   % simple, cv or fancy, so this branch is reached only by an explicit
   % titleformat=fancy rather than by any unrecognised string.
  {% Fancy Spacing
    \titleformat{\section}
    {\normalfont\Large\it\color{pu-display}}
    {\small\marginsecnumber\thesection}
    {0pt}
    {}[\vskip-12pt{\makebox[\linewidth][l]{\color{pu-display}\rule{0.99\textwidth}{1.2pt}}}]

    \titleformat{\subsection}
    {\normalfont\large\bfseries\color{pu-heading}}
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
}

% Enumeration
% ===========
\RequirePackage{enumitem}
% amssymb is no longer loaded. It was pulled in solely for \blacktriangleright,
% which newtxmath already provides, and loading it after newtxmath clashes over
% \Bbbk which both packages define.
% Fix spacing of items
% \setitemize{itemsep=-1ex}
\setlist[enumerate]{topsep=0pt,itemsep=\princeton@itemsep,partopsep=1ex,parsep=1ex}
\setlist[itemize]{topsep=0pt,itemsep=\princeton@itemsep,partopsep=1ex,parsep=1ex}

% The itemcolor option names a colour rather than choosing from a fixed list,
% so it cannot be validated up front with the other options. Check it here,
% where xcolor is loaded and the colour would otherwise fail at first use with
% an error that does not mention the class option responsible.
\@ifundefined{\string\color@\princeton@itemcolor}
  {\ClassError{princeton}
    {Unknown colour '\princeton@itemcolor' for class option itemcolor}
    {The colour must be defined before the class uses it. The class provides
     pu-orange and pu-gray, and xcolor's own named colours are available.}}
  {}

% Change bullet point to colorful triangle
\renewcommand\labelitemi{\color{\princeton@itemcolor}$\blacktriangleright$}

% Datetime
% ========
% datetime2 replaces the older datetime package, which its own maintainer
% supersedes. The iso style reproduces exactly what yyyymmdd plus a dash
% separator produced before, so \today still renders as 2026-09-05 and the
% footer's \today-\version stamp is unchanged.
\RequirePackage[useregional=false]{datetime2}
\DTMsetstyle{iso}

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
    \textcolor{pu-link}{\textit{Author}}\newline
    \textbf{\princeton@author}
    \ifdefempty{\princeton@email}{}
    {\newline\href{mailto:\princeton@email}{\princeton@email}}%
  }%

  \ifdefempty{\princeton@address}{}%
  {
    \textcolor{pu-link}{\textit{Address}}\newline
    \princeton@address
  }%

  \ifdefempty{\princeton@version}{}%
  {
    \textcolor{pu-link}{\textit{Version}}\newline
    \today-\princeton@version
    \ifthenelse{\boolean{princeton@draft}}{\newline \textbf{DRAFT}}{}
  }%


}
}

% Margin description environment
% ------------------------------

% Create custom description environment
%
% labelwidth is pinned to 0pt on purpose. enumitem otherwise derives it from
% leftmargin, which is 0pt here, and arrives at a negative width: every use of
% margindescription emitted "Package enumitem Warning: Negative labelwidth".
% With style=nextline the label sits on its own line and its width is not used
% for positioning, so 0pt is both silent and correct.
\newenvironment{customdescription}{%
  \footnotesize\setlist[description]{style=nextline,leftmargin=0pt,labelwidth=0pt}
   \renewcommand\descriptionlabel[1]{\hspace{\labelsep}\textcolor{pu-link}{\textit{##1}}}
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
% ifoddpage is no longer needed: the odd/even shift it guarded never actually
% fired, and largefigure/largetable now widen with adjustwidth instead.

% NOTE: Seems sidenotes is not working probably for figure* environment with the oneside layout option and left aligned margins

% https://tex.stackexchange.com/questions/170248/wrong-position-of-caption-in-odd-page-with-sidenotes-in-figure

% https://tex.stackexchange.com/questions/633593/caption-of-sidenote-packages-figure-widefigure-has-wrong-margin-or-width-in

% Exactly the width of the margin column plus its separation, with no fudge
% factor. This is the distance a full-width float has to move to reach the page
% margin, so any padding added here shows up as overflow past the page border.
% The former +3pt was harmless only because the shift it fed never actually
% fired; once largefigure really widened it pushed the float 3pt off the page.
\newlength{\xtramargin}
\setlength{\xtramargin}{\dimexpr \marginparsep +\marginparwidth}

% Widen the enclosing content by the margin column (marginparwidth +
% marginparsep) on whichever side the margin actually sits, so that a float and
% its caption together span the whole page body. Shared by largefigure and
% largetable so the two behave identically.
%
% The widening uses adjustwidth (loaded by sidenotes via changepage) rather than
% figure* plus a raw \hspace. The older \hspace approach was guarded by
% \@ifoddpage, which branches on a boolean that only \checkoddpage sets. The
% class never called \checkoddpage, so the boolean kept its \newif default of
% false and the shift never fired: largefigure silently behaved as a plain
% figure*. adjustwidth also shifts multi-line content as a whole, which a
% leading \hspace cannot do, and it honours the marginpos option.
\newenvironment{princeton@widen}
  {\ifthenelse{\equal{\princeton@marginpos}{left}}%
     {\begin{adjustwidth}{-\xtramargin}{0pt}}%
     {\begin{adjustwidth}{0pt}{-\xtramargin}}}%
  {\end{adjustwidth}}

% Full-width figure. From Org mode, use it on a figure with
%   #+ATTR_LATEX: :float largefigure
\newenvironment{largefigure}[1][ht]
  {\begin{figure}[#1]\begin{princeton@widen}}
  {\end{princeton@widen}\end{figure}}

% Full-width table, the exact analogue of largefigure. From Org mode, use it on
% a table with
%   #+ATTR_LATEX: :float largetable
\newenvironment{largetable}[1][htbp]
  {\begin{table}[#1]\begin{princeton@widen}}
  {\end{princeton@widen}\end{table}}


\RequirePackage{keyval}
% tikz is no longer loaded. It was pulled in for a single node in \fullfigure,
% working around an \AtPageLowerLeft border gap that no longer occurs.

\RequirePackage{caption}

\newlength{\figureoffset}
\setlength{\figureoffset}{-1.5em}

\DeclareCaptionFormat{margin}{\marginnote{#1#2#3}[\figureoffset]}


\captionsetup{font=footnotesize,labelfont=bf}
\captionsetup[figure]{name=Fig.}
\captionsetup[table]{name=Tab.}


% fix side caption
% https://tex.stackexchange.com/questions/620891/sidecaption-and-capion-text
\NewDocumentCommand{\SideCaption}{sO{#3}mO{-2\baselineskip}}{%
  \IfBooleanTF{#1}
   {% \sidecaption*
    \IfNoValueTF{#4}{\sidecaption*{#3}}{\sidecaption*[#4]{#3}}%
   }
   {% \sidecaption
    \IfNoValueTF{#4}{\sidecaption[#2]{#3}}{\sidecaption[#2][#4]{#3}}%
   }%
 }

% Create custom figure environment

\NewDocumentEnvironment{princetonfigure}{O{htbp}O{f}o}
{%
  \IfValueT{#3}{\setlength{\figureoffset}{#3}}
  \ifthenelse{\equal{#2}{m}}{%
    \begin{marginfigure}
      \captionsetup{font=footnotesize,labelfont=bf,name=Fig.}
    }{%
      \begin{figure}[#1]
        \captionsetup{format=margin}
      }
    }%
    {%
      \ifthenelse{\equal{#2}{m}}{%
      \end{marginfigure}
    }{%
      \vspace{-2\baselineskip}
    \end{figure}
  }%
}%


% https://tex.stackexchange.com/questions/34312/how-to-create-a-command-with-key-values

% Initialize length values
\newlength{\fullfigure@height}

% Definition of key values
\define@key{fullfigure}{height}{\setlength\fullfigure@height{#1}}
\define@key{fullfigure}{angle}{\def\fullfigure@angle{#1}}
\define@key{fullfigure}{anchor}{\def\fullfigure@anchor{#1}}
\define@key{fullfigure}{align}{\def\fullfigure@align{#1}}

% Default key values. The whole \setkeys call lives inside the macro because
% \setkeys does not expand its argument, so passing a macro holding only the
% key list would be read as one undefined key name.
\newcommand{\princeton@fullfigure@reset}{%
  \setkeys{fullfigure}{anchor=south,height=3in,angle=0,align=b}%
}
\princeton@fullfigure@reset

% Create full figure command
\newcommand{\fullfigure}[2][]{%
  % Reset to defaults first. \setkeys has no group of its own, so without this
  % a second \fullfigure silently inherits the height, angle and alignment of
  % the first one for every key the caller does not repeat.
  \princeton@fullfigure@reset
  \setkeys{fullfigure}{#1}% Set new keys
  \AddToShipoutPictureBG*{% * i.e. only on current page
    \ifthenelse{\equal{\fullfigure@align}{b}}% if
    {% then: anchor to the foot of the page
      % This used to draw a TikZ node at (current page.south west), because
      % \AtPageLowerLeft was said to leave a white gap at the paper edge. That
      % is no longer true: measured at 300 dpi, this version bleeds to the
      % bottom, left and right edges with zero blank pixels, exactly as the
      % TikZ version did. Dropping it removes the whole TikZ dependency, which
      % the class loaded for this single node and which cost about 0.19s of
      % every compile, and removes the "remember picture" second-pass
      % requirement along with it.
      \AtPageLowerLeft{%
        \put(0,0){%
          \includegraphics[width=\paperwidth,
          height=\fullfigure@height,
          angle=\fullfigure@angle]{#2}%
        }%
      }%
    }{% else: anchor to the head of the page
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

% CV commands
% ===========
\newcommand{\cvmargin}[1]{
  \noindent\marginnote{\textit{\footnotesize{#1}}}\ignorespaces%
}

\def\namedlabel#1#2{\begingroup
    #2%
    \def\@currentlabel{#2}%
    \phantomsection\label{#1}\endgroup
}

\newcommand{\cvinfo}[1]{\hfill {\footnotesize \textbf{#1}}}
\newcommand{\cvinfoit}[1]{\hfill {\footnotesize \textit{#1}}}
\newcommand{\cvlabel}[1]{\makebox[0pt][r]{\scriptsize[\namedlabel{cv:#1}{#1}]\hspace{6pt}}\ignorespaces}
\newcommand{\cvitem}[2]{\cvmargin{#1}\cvlabel{#2}}
%\newcommand{\cvref}[1]{\scriptsize[\ref{itm:#1}]}

\NewDocumentCommand{\cvref}{O{none} m O{\normalsize}}{%
  {#3%
  \ifthenelse{\equal{#1}{none}}{%
    \ref{cv:#2}%
  }{%
    \ifthenelse{\equal{#1}{left}}{%
      [\ref{cv:#2}%
    }{%
      \ifthenelse{\equal{#1}{right}}{%
        \ref{cv:#2}]%
      }{%
        [\ref{cv:#2}]%
      }%
    }%
  }%
  }%
}% end NewDocumentCommand
% Two-column body
% ===============
% columns=two keeps page 1 exactly as it is, wide left margin and all, and sets
% the body from the first section onward in two columns.
%
% The seam is the delicate part. \twocolumn derives \columnwidth from \textwidth
% at the moment it is called, so the geometry and the gutter must both be in
% place BEFORE it runs. Doing it the other way round does not error: it produces
% full-page-width single lines on a page LaTeX still believes is two-column.
% Measured, wrong order gives \columnwidth 542pt where it should be 266pt.
%
% \newgeometry reclaims the 2.1in margin column as body width. Collapsing
% marginparwidth matters as well as includemp: geometry otherwise subtracts the
% margin strip a second time.
\newcommand{\princeton@gotwocolumn}{%
  \newgeometry{top=\boarder,bottom=\boarder,left=\boarder,right=\boarder,
               includeheadfoot,marginparwidth=0pt,marginparsep=0pt}%
  % 26pt rather than the 10pt default. The section numbers hang about 9.7pt to
  % the left of their column, and at 10pt they land on the neighbouring column.
  \setlength{\columnsep}{26pt}%
  \princeton@twocolumnfixes
  \twocolumn
}

% Column-spanning floats, defined on the KERNEL float machinery rather than on
% figure*/table*. sidenotes redefines both of those into a one-column float
% widened rightward by the margin strip, which on a two-column page runs the
% float straight over the second column. \@dblfloat is what figure* is built
% from in article.cls and is untouched by sidenotes.
\newenvironment{princeton@dblfigure}[1][tp]{\@dblfloat{figure}[#1]}{\end@dblfloat}
\newenvironment{princeton@dbltable}[1][tp]{\@dblfloat{table}[#1]}{\end@dblfloat}

% An aside: what a margin note becomes when there is no margin. A tinted block
% the width of the column, set in the same small size the margin used.
% fboxsep is 8pt rather than the 3pt default, and that is load-bearing, not
% taste. customdescription outdents its field labels: measured, "Created" began
% 2.47pt to the LEFT of the tint at the default padding, so the labels hung
% outside the box they are supposed to sit in. 8pt clears the outdent with room
% to spare and reads better in a tinted block anyway.
\newcommand{\princeton@aside}[1]{%
  \par\addvspace{\medskipamount}%
  \begingroup
    \setlength{\fboxsep}{8pt}%
    \noindent\colorbox{pu-gray!20}{%
      \begin{minipage}{\dimexpr\columnwidth-2\fboxsep\relax}%
        \footnotesize #1\par
      \end{minipage}%
    }%
  \endgroup
  \par\addvspace{\medskipamount}%
}

% Everything that has to change because there is no longer a margin to put
% things in. Kept separate from the geometry so each piece can be tested alone.
\newcommand{\princeton@twocolumnfixes}{%
  % \marginnote is the single choke point. \makeinfo, margindescription,
  % \marginsection, \cvmargin and sidenotes' \sidecaption all route through it,
  % so redefining it here fixes them together.
  %
  % Left unfixed it does not error, it throws content off the paper: marginnote
  % sends a note to the outer side of the emitting column, and with the class's
  % \reversemarginpar a note from the left column lands at x=8.4in on an 8.5in
  % page. Silently.
  %
  % The +m is not optional. With a short m argument \makeinfo fails with
  % "Paragraph ended before \marginnote was complete": its body contains blank
  % lines, so the argument has to be allowed to span paragraphs.
  \RenewDocumentCommand{\marginnote}{o +m o}{\princeton@aside{##2}}%
  %
  % A side caption has nowhere to go, so it becomes an ordinary caption. The
  % signature matches sidenotes' own {s o o m}, so no call site changes.
  \RenewDocumentCommand{\sidecaption}{s o o m}{%
    \IfNoValueTF{##2}{\caption{##4}}{\caption[##2]{##4}}}%
  \RenewDocumentCommand{\SideCaption}{s o m o}{%
    \IfNoValueTF{##2}{\caption{##3}}{\caption[##2]{##3}}}%
  %
  % A margin figure becomes an ordinary column-width float. Same name, same
  % optional argument, so nothing in the document is renamed.
  \RenewDocumentEnvironment{marginfigure}{o}{\begin{figure}}{\end{figure}}%
  %
  % Full-width now means spanning both columns. Placement is forced to [tp]:
  % the kernel's double-float route honours only t and p, so an h or b in a
  % specifier is silently dropped and the float would drift unpredictably.
  \renewenvironment{largefigure}[1][tp]%
    {\begin{princeton@dblfigure}[tp]}{\end{princeton@dblfigure}}%
  \renewenvironment{largetable}[1][tp]%
    {\begin{princeton@dbltable}[tp]}{\end{princeton@dbltable}}%
  %
  % princetonfigure asks for the margin caption format in its f mode, and that
  % format routes the caption through \marginnote. Once \marginnote is a boxed
  % aside, the caption machinery ends up inside an LR box and fails with
  % "Not allowed in LR mode" followed by undefined \caption@ internals.
  %
  % The margin format cannot be redeclared here: \DeclareCaptionFormat is
  % preamble-only and errors after \begin{document}. So replace the environment
  % instead. Both modes become an ordinary column figure, and the signature is
  % unchanged so no call site moves.
  \RenewDocumentEnvironment{princetonfigure}{O{tbp}O{f}o}
    {\begin{figure}[##1]\captionsetup{font=footnotesize,labelfont=bf,name=Fig.}}
    {\end{figure}}%
  %
  % titleformat=cv puts subsection TITLES in the margin, via \marginsection and
  % so via \marginnote. The redefinition above catches it, which stops it going
  % off the paper, but a heading rendered as a tinted block is not a heading.
  % Re-declare it as an ordinary block heading instead.
  %
  % This works only because \titleformat may be re-issued after
  % \begin{document}, unlike \DeclareCaptionFormat, which cannot.
  \ifthenelse{\equal{\princeton@titleformat}{cv}}
    {\titleformat{\subsection}
       {\normalfont\normalsize\bfseries\color{pu-heading}}
       {\scriptsize\marginsecnumber\thesubsection}
       {0pt}
       {}}
    {}%
  %
  % CV entry commands. Neither survives losing the margin, and they fail in
  % different ways, so they need separate treatment rather than riding on the
  % \marginnote redefinition above.
  %
  % \cvlabel hangs a bracketed key with \makebox[0pt][r], the same trick as the
  % section numbers. Measured in the left column it landed at x=0.39pt: the
  % paper edge, 35.6pt outside the column. Set it inline.
  %
  % \cvmargin does route through \marginnote, so it did not break, but turning
  % a two-word date range into a full-width tinted aside is far too heavy for
  % what it is. Set it inline and italic, ahead of the entry.
  \renewcommand{\cvmargin}[1]{{\itshape\footnotesize ##1}\quad\ignorespaces}%
  \renewcommand{\cvlabel}[1]{%
    {\scriptsize[\namedlabel{cv:##1}{##1}]}\hspace{6pt}\ignorespaces}%
  %
  % Section numbers are set inline, in both columns.
  %
  % Hanging them is the whole point in one column, where they sit in a 2.1in
  % margin and read as deliberate. There is no margin here. Hanging into the
  % gutter instead was measured to be safe (a number lands at 308pt in a gutter
  % running 293 to 319pt, so it never touches the neighbouring column) but it
  % reads as a misalignment rather than a design: the number floats in white
  % space belonging to neither column. Inline is the honest answer.
  \renewcommand{\marginsecnumber}[1]{##1\hspace{6pt}}%
}

% The author-facing escape hatch, for documents that want body text on page 1
% and so need to choose the seam themselves.
%
% A no-op under columns=one. The option says how many columns the document has;
% a stray \startcolumns in a one-column document should not silently override
% it, which is what happens if this fires unconditionally. Warn instead, so a
% shared body can carry the command and still be built either way.
\newcommand{\startcolumns}{%
  \ifthenelse{\equal{\princeton@columns}{two}}
    {\ifboolexpr{ bool {princeton@switched} or bool {princeton@frontmatter} }
       {}
       {\booltrue{princeton@switched}\princeton@gotwocolumn}}
    {\ClassWarningNoLine{princeton}
      {\string\startcolumns\space ignored: this document is columns=one.
       \MessageBreak Pass columns=two to the class to enable two-column body}}%
}

% \tableofcontents, \listoffigures and \listoftables all typeset their heading
% with \section*, so the hook below sees them as the first section and switches
% there. That put the switch before any body text: page 1 held nothing but the
% title block, and the contents list opened page 2 already in two columns.
%
% Suppress the switch while any of them is running. They belong to the front
% matter, which is exactly what page 1 is for.
\newbool{princeton@frontmatter}
\newcommand{\princeton@guardfront}[1]{%
  \pretocmd{#1}{\booltrue{princeton@frontmatter}}{}{}%
  \apptocmd{#1}{\boolfalse{princeton@frontmatter}}{}{}%
}
\princeton@guardfront{\tableofcontents}
\princeton@guardfront{\listoffigures}
\princeton@guardfront{\listoftables}

% Automatic seam. The switch fires once, at the first \section.
%
% Not at the end of \maketitle, which is where it first looks like it belongs:
% \makeinfo and \tableofcontents are written after \maketitle and belong to the
% front matter, and switching before them would push the author block into a
% column on page 2. The first section is the real boundary between front matter
% and body, and it keeps the promise for the normal case where the front matter
% fits on one page.
%
% Not \afterpage either. \afterpage{\twocolumn} corrupts the top of the first
% two-column page 100% of the time, at every page-1 length tested, in both
% engines.
\newbool{princeton@switched}
\ifthenelse{\equal{\princeton@columns}{two}}
  {\pretocmd{\section}{\startcolumns}{}{%
     \ClassWarningNoLine{princeton}
       {Could not hook the two-column switch onto \string\section.\MessageBreak
        Write \string\startcolumns\space where the body should begin}}}
  {}

% Bibliography
% ============

% Hyper references
% ================
\RequirePackage[draft=false]{hyperref}

% hyperref's own colorlinks defaults to FALSE, and when it is false links are
% decorated with a drawn border (\@pdfborder = "0 0 1") rather than coloured
% text. Setting allcolors alone therefore had no effect at all, while
% allbordercolors put an orange box around every link. Drive hyperref from the
% class option instead, so colorlinks=true means what it says.
\ifthenelse{\boolean{princeton@colorlinks}}
  {\hypersetup{colorlinks=true, allcolors=pu-link}}
  {\hypersetup{hidelinks}}
