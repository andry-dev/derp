\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{bc}[2023/01/12]

\ProcessOptions\relax

\LoadClass[draft,english,a4paper,bibliography=totocnumbered]{scrartcl}

\RequirePackage{csquotes}
\RequirePackage[english]{babel}
\RequirePackage{graphicx}
\RequirePackage{float}
\RequirePackage[table]{xcolor}
\RequirePackage{array}
% \RequirePackage[a4paper,margin=5em]{geometry}
\RequirePackage{framed}
\RequirePackage[ddmmyyyy]{datetime}
\RequirePackage{tabularx}
\RequirePackage{enumitem}
\RequirePackage{hyperref}
\RequirePackage[toc]{glossaries}
\RequirePackage{cleveref}
\RequirePackage{pgf-pie}
\RequirePackage{todonotes}
\RequirePackage[backend=biber]{biblatex}

\hypersetup{
	colorlinks,
	citecolor=black,
	filecolor=black,
	linkcolor=blue,
	urlcolor=blue
}

\newcounter{challengecounter}
\newcommand{\challenge}[1]{%
	\textbf{C\ref*{#1}}\refstepcounter{challengecounter}\label{#1}%
}
\newcommand{\challengeref}[1]{%
	\hyperref[#1]{C\ref*{#1}}%
}

\newcounter{sequencediagramcounter}
\newcommand{\sd}[1]{%
	\textbf{SD\ref*{#1}}\refstepcounter{sequencediagramcounter}\label{#1}%
}
\newcommand{\sdref}[1]{%
	\hyperref[#1]{[SD\ref*{#1}]}%
}

\newcounter{actorcounter}
\newcommand{\actor}[1]{%
	\textbf{A\ref*{#1}}\refstepcounter{actorcounter}\label{#1}%
}
\newcommand{\actorref}[1]{%
	\hyperref[#1]{A\ref*{#1}}%
}

\newcounter{freqcounter}
\newcommand{\req}[1]{%
	\textbf{FR\ref*{#1}}\refstepcounter{freqcounter}\label{#1}%
}
\newcommand{\reqref}[1]{%
	\hyperref[#1]{[FR\ref*{#1}]}%
}

\newcounter{nfreqcounter}
\newcommand{\nreq}[1]{%
	\textbf{NFR\ref*{#1}}\refstepcounter{nfreqcounter}\label{#1}%
}
\newcommand{\nreqref}[1]{%
	\hyperref[#1]{NFR\ref*{#1}}%
}

\endinput
