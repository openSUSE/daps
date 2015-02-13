;;
;; Docbook XML macros
;;
;; see http://en.opensuse.org/openSUSE:Documentation_Emacs_Docbook_Macros
;; for the latest version
;;
;; A macro package to insert the most often used DocBook snippets. The goal
;; was to find the most efficient shortcut for often used tag combinations.
;; All the code inserted to your documents will be indented correctly and
;; the cursor is placed in a way that you can start typing immediately.
;;
;; The macros require the nxml-mode or, alternatively the psgml-mode (package
;; psgml). When the macros are loaded, you will see a new menu "DocBook"
;; listing all the macros and the corresponding keyboard shortcuts. Of course
;; you can load the macros with M-x <function-name> as well. The function names
;; all start with "docbook-" followed by an element string: docbook-remark,
;; docbook-table, docbook-step, etc.
;;
;; Load in your emacs customization file (e.g. ~/.emacs) with the following
;; command
;; (load "<PATH>/emacs_docbook_macros.el" t t)
;; where <PATH> is to be replaced appropriately
;;
;; This file is also distributed in openSUSE with the daps package. After
;; having installed daps, find it at
;; /usr/share/emacs/site-lisp/docbook_macros.el
;; The latest daps version is available from the repositories at
;; http://download.opensuse.org/repositories/Documentation:/Tools/
;;
;; --------------------------------------------------------------------------
;;
;; Copyright (c) 2010 SUSE LINUX Products GmbH, Nuernberg, Germany.
;; Author: Frank Sundermeyer <fs@suse.de>
;;
;; This program is free software; you can redistribute it and/or modify it under
;; the terms of the GNU General Public License as published by the Free Software
;; Foundation; either version 2 of the License, or (at your option) any later
;; version.
;;
;; This program is distributed in the hope that it will be useful, but WITHOUT
;; ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
;; FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
;; details.
;; You should have received a copy of the GNU General Public License along with
;; this program; if not, write to the Free Software Foundation, Inc., 59 Temple
;; Place, Suite 330, Boston, MA 02111-1307 USA
;;
;; --------------------------------------------------------------------------
;;
;; Feedback is welcome - please leave your comments at
;; http://en.opensuse.org/openSUSE_talk:Documentation_Emacs_Docbook_Macros
;; or contact me via mail
;;

;; Resources for skeleton (almost no useful documentation ;-(( ):
;;
;; http://www.gnu.org/software/emacs/manual/html_mono/autotype.html
;; http://www.emacswiki.org/cgi-bin/emacs-en/SkeletonMode


;; DocBook DOCUMENT
(define-skeleton docbook-docbook
  "Insert a complete docbook file template."
  (setq v1
    (completing-read (format "Root Element [%s]: " v1)
      '("appendix" "article" "book" "chapter" "glossary" "legalnotice" "part" "preface" "refentry" "sect1" "sect2" "sect3" "sect4" "set")
    nil nil nil nil v1))
  '(setq v1 "chapter") ; the default
    "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<!DOCTYPE " str " PUBLIC \"-//OASIS//DTD DocBook XML V4.5//EN\" \"http://www.oasis-open.org/docbook/xml/4.5/docbookx.dtd\" [
  <!ENTITY % entities SYSTEM \"entity-decl.ent\">
  %entities;
]>"\n
    "<" v1 " id=\"" _  "\">"\n
    >"<title></title>"\n
    >"<para>"\n
    >""\n
    -1"</para>"\n
    -1"</" v1 ">"\n
)

;; NovDoc DOCUMENT
(define-skeleton docbook-novdoc
  "Insert a complete novdoc file template."
  (setq v1
    (completing-read (format "Root Element [%s]: " v1)
      '("appendix" "article" "book" "chapter" "glossary" "legalnotice" "part" "preface" "refentry" "sect1" "sect2" "sect3" "sect4" "set")
    nil nil nil nil v1))
  '(setq v1 "chapter") ; the default
    "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<!DOCTYPE " str " PUBLIC \"-//Novell//DTD NovDoc XML V1.0//EN\" \"novdocx.dtd\" [
  <!ENTITY % NOVDOC.DEACTIVATE.IDREF \"INCLUDE\">
  <!ENTITY % entities SYSTEM \"entity-decl.ent\">
  %entities;
]>"\n
    "<" v1 " id=\"" _  "\">"\n
    >"<title></title>"\n
    >"<para>"\n
    >""\n
    -1"</para>"\n
    -1"</" v1 ">"\n
)

;; ANNOTATION
;(defvar docbook-annotation-default "warning")
(define-skeleton docbook-annotation
  "Insert a docbook annotation template."
  (setq v1
    (completing-read (format "Annotation type [%s]: " v1)
      '("important" "note" "tip" "warning")
    nil 't nil nil v1))
  '(setq v1 "warning") ; the default
  \n >
  >"<" str ">"\n
  >"<title>" _ "</title>"\n
  >"<para>"\n
  > ""\n
  -1"</para>"\n
  -1"</" v1 ">"\n
  \n
)

;; CALLOUT
(define-skeleton docbook-callout
  "Insert a docbook <callout> template."
  nil
  \n >
  >"<callout arearefs=\"" (skeleton-read "arearefs: ") "\">"\n
  >"<para>"\n
  > _ \n
  -1"</para>"\n
  -1"</callout>"\n
  \n
)

;; EMPHASIS
(define-skeleton docbook-emphasis
  "Insert a docbook <emphasis role=?>."
  (setq v1
	(completing-read (format "Role [%s]: " v1)
			 '("bold" "italic")
			 nil 't v1))
  '(setq v1 "bold")
  \n
  >"<emphasis role=\"" str "\"\>" _ "</emphasis>"
  \n
)

;; ULINK
(define-skeleton docbook-ulink
  "Insert a docbook <ulink url=\"?\">name</ulink>."
  nil
  \n
  >"<ulink url=\"" (setq v1 (skeleton-read "Url: ")) "\">"
  (setq v1 (skeleton-read "Name: ")) "</ulink>"
  \n
)

;; PROGRAMLISTING
(define-skeleton docbook-programlisting
  "Insert a docbook programlisting template."
  nil
  \n
 >"<programlisting><!\\[CDATA\\["\n
 > _ \n
 >"\\]\\]>"\n
 >"</programlisting>"\n
 \n
)

;; FOOTNOTE
(define-skeleton docbook-footnote
  "Insert a docbook footnote."
  nil
  >"<footnote>"\n
  >"<para>" (setq v1 (skeleton-read "Footnote: ")) "</para>"\n
  >"</footnote>"\n
  \n
)

;; COMMENT
(define-skeleton docbook-comment
  "Insert a docbook comment template."
  nil
  \n
  "<!-- " user-login-name (format-time-string " %Y-%m-%d") ":
     " _ "
-->
")

;; FIGURE
(define-skeleton docbook-figure
  "Insert a docbook <figure>."
  nil
  >"<figure>"\n
  >"<title>" (skeleton-read "Title: ") "</title>"\n
  >"<mediaobject>"\n
  >"<imageobject role=\"fo\">"\n
  >"<imagedata fileref=\"" (setq v1 (skeleton-read "Filename: ")) "\" width=\"75%\" format=\"png\"/>"\n
  -1"</imageobject>"\n
  >"<imageobject role=\"html\">"\n
  >"<imagedata fileref=\""v1"\" width=\"75%\" format=\"png\"/>"\n
  -1"</imageobject>"\n
  -1"</mediaobject>"\n
  -1"</figure>"\n
  \n
)

;;INDEXTERM
(define-skeleton docbook-indexterm
  "Insert a docbook <indexterm>."
  nil
  >"<indexterm>"\n
  '(while (= (length v1) 0)
    (setq v1 (skeleton-read "Primary: ")))
  >"<primary>" v1 "</primary>"
  '(setq v1 "")
  '(setq v1 (skeleton-read "Secondary [Enter to skip]: "))
  '(if (> (length v1) 0)
       (progn
	 (newline-and-indent)
	 (insert "<secondary>" v1 "</secondary>")
	 (setq v2 (skeleton-read "Tertiary [Enter to skip]: "))
	 (if (> (length v2) 0)
	     (progn
	       (newline-and-indent)
	       (insert "<tertiary>" v2 "</tertiary>")))))
  \n
  -1"</indexterm>"\n
  \n
)

;; KEYCOMBO
(define-skeleton docbook-keycombo
  "Insert a docbook <keycombo> template; optionally specify a function for the first keycap."
  nil
  "<keycombo> "
  '(setq v1
    (completing-read "Special key (Enter to skip): "
      '("alt" "control" "shift" "meta" "escape")
      nil 't nil nil v1))
  (if (> (length v1) 0)
      (insert "<keycap function=\"" v1 "\"/> "))
  "<keycap>" _ "</keycap> "
  (if (= (length v1) 0)
      (insert "<keycap></keycap> "))
  "</keycombo> "
)

;; LISTITEM
(define-skeleton docbook-listitem
  "Insert a docbook <listitem> template."
  nil
  \n
  >"<listitem>"\n
  >"<para>"\n
  > _ \n
  -1"</para>"\n
  -1"</listitem>"\n
)

;; MENUCHOICE
(define-skeleton docbook-menuchoice
  "Insert a docbook <menuchoice> template."
  nil
  "<menuchoice> "
  "<guimenu>" _ "</guimenu> "
  "<guimenu></guimenu> "
  "</menuchoice> ")

;; QANDAENTRY
(define-skeleton docbook-qandaentry
  "Insert a docbook <pandaentry> template."
  nil
  \n
  >"<qandaentry>"\n
  >"<question>"\n
  >"<para>"\n
  > _ \n
  -1"</para>"\n
  -1"</question>"\n
  >"<answer>"\n
  >"<para>"\n
  > \n
  -1"</para>"\n
  -1"</answer>"\n
  -1"</qandaentry>"\n
)

;; REMARK
(define-skeleton docbook-remark
  "Insert a docbook <remark>."
  (setq v1
    (completing-read (format "Remark condition [%s]: " v1)
      '("trans" "structural" "clarity" "generic" "layout" "needinfo")
    nil nil nil nil v1))
  '(setq v1 "clarity")
  \n
  >"<remark condition=\"" str "\">"\n
  >(format-time-string "%Y-%m-%d") " - " user-login-name ": " _ \n
  -1"</remark>"\n
  \n
)

;; SECT
(define-skeleton docbook-sect
  "Insert a docbook <sect?> template."
  (setq v1
    (completing-read (format "Section level [%s]: " v1)
      '("1" "2" "3" "4")
    nil 't nil nil v1))
  '(setq v1 "1")
  \n
  >"<sect" str " id=\"" _ "\">"\n
  >"<title></title>"\n
  >"<para>"\n
  > _
  \n
  -1"</para>"\n
  -1"</sect" v1 ">"\n
  \n
)

;; STEP
(define-skeleton docbook-step
  "Insert a docbook <step> template."
  nil
  \n
  >"<step>"\n
  >"<para>"\n
  > _ \n
  -1"</para>"\n
  -1"</step>"\n
  \n
)

;; TABLE
; only 2 local variables in skeletons, so there does not seem to be a way
; not to use global variables ...
;
(defvar docbook-table-count "")
(defvar docbook-table-cols "")
(defvar docbook-table-colwidth "")
(define-skeleton docbook-table
  "Insert a docbook <step> table."
  \n >
  >"<table>"\n
  >"<title>" _ "</title>"\n
  '(setq docbook-table-cols (skeleton-read "Number of columns [2]: "))
  '(if (= (length docbook-table-cols) 0)
      (setq docbook-table-cols "2"))
  >"<tgroup cols=\"" docbook-table-cols "\">"\n
  '(setq
       docbook-table-cols (string-to-number docbook-table-cols)
       docbook-table-colwidth (/ 100  docbook-table-cols)
       docbook-table-count 1)
  '(while (<= docbook-table-count docbook-table-cols)
     (insert "<colspec colnum=\"" (number-to-string docbook-table-count) "\" colname=\"" (number-to-string docbook-table-count) "\" colwidth=\"" (number-to-string docbook-table-colwidth) "*\"/>")
     (newline-and-indent)
     (setq docbook-table-count (1+ docbook-table-count)))
  >"<thead>"\n
  >"<row>"\n
  '(setq docbook-table-count 1)
  '(while (<= docbook-table-count docbook-table-cols)
     (indent-according-to-mode)
     (insert "<entry><para></para></entry>")
     (newline-and-indent)
     (setq docbook-table-count (1+ docbook-table-count)))
  -1"</row>"\n
  -1"</thead>"\n
  >"<tbody>"\n
  >"<row>"\n
  '(setq docbook-table-count 1)
  '(while (<= docbook-table-count docbook-table-cols)
    (insert "<entry><para></para></entry>")
    (newline-and-indent)
    (setq docbook-table-count (1+ docbook-table-count)))
  -1"</row>"\n
  -1"</tbody>"\n
  -1"</tgroup>"\n
  -1"</table>"\n
  ; reset the global variables
  ;
  '(setq docbook-table-count "")
  '(setq docbook-table-cols "")
  '(setq docbook-table-colwidth "")
)

;; VARLISTENTRY
(define-skeleton docbook-varlistentry
  "Insert a docbook <varlistentry> template."
  nil
  \n
  >"<varlistentry>"\n
  >"<term>" _ "</term>"\n
  >"<listitem>"\n
  >"<para>"\n
  > \n
  -1"</para>"\n
  -1"</listitem>"\n
  -1"</varlistentry>"\n
)

;;----------------------------------------
;; Keyboard shortcuts and menu

;; keyboard shortcuts
(defun docbook-key-bindings ()
  (local-set-key (kbd "C-c C-c a") 'docbook-annotation)
  (local-set-key (kbd "C-c C-c c") 'docbook-callout)
  (local-set-key (kbd "C-c C-c d") 'docbook-docbook)
  (local-set-key (kbd "C-c C-c e") 'docbook-emphasis)
  (local-set-key (kbd "C-c C-c f") 'docbook-figure)
;;  (local-set-key (kbd "C-c C-c f") 'docbook-footnote)
  (local-set-key (kbd "C-c C-c i") 'docbook-indexterm)
  (local-set-key (kbd "C-c C-c k") 'docbook-keycombo)
  (local-set-key (kbd "C-c C-c l") 'docbook-listitem)
  (local-set-key (kbd "C-c C-c m") 'docbook-menuchoice)
  (local-set-key (kbd "C-c C-c n") 'docbook-novdoc)
  (local-set-key (kbd "C-c C-c p") 'docbook-step)
;;  (local-set-key (kbd "C-c C-c p") 'docbook-programlisting)
  (local-set-key (kbd "C-c C-c q") 'docbook-qandaentry)
  (local-set-key (kbd "C-c C-c r") 'docbook-remark)
  (local-set-key (kbd "C-c C-c s") 'docbook-sect)
  (local-set-key (kbd "C-c C-c t") 'docbook-table)
  (local-set-key (kbd "C-c C-c u") 'docbook-ulink)
  (local-set-key (kbd "C-c C-c v") 'docbook-varlistentry)
)
;; menu
(defun docbook-menu (modemapname)
  (require 'easymenu)
  (easy-menu-define docbook-macros modemapname "DocBook Marcos"
    '("DocBook"
       ["Insert DocBook page template"  docbook-docbook t]
       ["Insert NovDoc page template"  docbook-novdoc t]
       "--"
       ["Insert annotation" docbook-annotation t]
       ["Insert callout" docbook-callout t]
       ["Insert comment" docbook-comment t]
       ["Insert empahsis" docbook-emphasis t]
       ["Insert figure" docbook-figure t]
       ["Insert footnote" docbook-footnote t]
       ["Insert indexterm" docbook-indexterm t]
       ["Insert keycombo" docbook-keycombo t]
       ["Insert listitem" docbook-listitem t]
       ["Insert menuchoice" docbook-menuchoice t]
       ["Insert programlisting" docbook-programlisting t]
       ["Insert qandaentry" docbook-qandaentry t]
       ["Insert remark" docbook-remark t]
       ["Insert sect" docbook-sect t]
       ["Insert step" docbook-step t]
       ["Insert table" docbook-table t]
       ["Insert ulink" docbook-ulink t]
       ["Insert varlistentry" docbook-varlistentry t]
    )
  )
  (easy-menu-add docbook-macros modemapname)
)


;;Add key-bindings and menu for psgml mode
(add-hook 'sgml-mode-hook
  '(lambda ()
     (docbook-key-bindings)
     (docbook-menu sgml-mode-map)
  )
)

;;Add key-bindings and menu for nxml mode
(add-hook 'nxml-mode-hook
  '(lambda ()
     (docbook-key-bindings)
     (docbook-menu nxml-mode-map)
  )
)

;;Two custom functions for nxml:
;; nxml-jump-opening-tag (C-c C-c <up>)  :
;;   Jump to the openening tag that fits the context at point and put
;;   the cursor at the beginning of the tag name.
;;
;; nxml-jump-closing-tag (C-c C-c <down>):
;;   Jump to the closing tag that fits the context at point and put
;;   the cursor at the beginning of the tag name.
;;
(add-hook 'nxml-mode-hook      
  '(lambda ()     
     (autoload 'sgml-skip-tag-forward "sgml-mode"
  "Skip to end of tag or matching closing tag if present.
With prefix argument ARG, repeat this ARG times.
Return t if after a closing tag." t)
     ;; Custom functions for nxml
     ;;
     (defun nxml-jump-opening-tag nil
       "Jump to the openening tag that fits the context at point and put the cursor at the beginning of the tag name."
       (interactive)
       (nxml-backward-up-element)
       (forward-char)
       )
     (defun nxml-jump-closing-tag nil
       "Jump to the closing tag that fits the context at point and put the cursor at the beginning of the tag name."
       (interactive)
       (nxml-backward-up-element)
       (sgml-skip-tag-forward 1)
       (backward-word)
       )
     (define-key nxml-mode-map (kbd "C-c C-c <up>") 'nxml-jump-opening-tag)
     (define-key nxml-mode-map (kbd "C-c C-c <down>") 'nxml-jump-closing-tag)
  )
)
