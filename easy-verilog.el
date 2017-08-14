;;; easy-verilog.el --- Improve readability of Verilog

;; Copyright (C) 2016-2019 Free Software Foundation, Inc.

;; Author: Yuriy VG <yuravg@gmail.com>
;; Version: 0.2
;; Keywords: Verilog, tools
;; URL: https://github.com/yuravg/easy-verilog

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; This package provides minor mode for Verilog-mode, URL: http://www.veripool.org/verilog-mode
;; The main function, `easy-verilog-minor-mode'
;; is replace words "begin" and "end" to symbol "{" and "}", and some others characters
;; to improve readability of Verilog.
;; Also replace:
;;  1'b0 to 0 (level low)
;;  1'b1 to 1 (level high)
;;  1'bz to z (level middle)
;;  1'd1 to 1 (digit one)
;;  1'd0 to 0 (digit zero)
;;
;; Suggested setup:
;;  (add-hook 'verilog-mode-hook 'easy-verilog-minor-mode)
;; to adjust easy-verilog-face, you can use this for example:
;;  (set-face-attribute 'easy-verilog-face nil :weight 'bold :foreground "Blue")
;;  (set-face-attribute 'easy-verilog-levels-face nil :weight 'bold)
;;  (set-face-attribute 'easy-verilog-digit-face nil :weight 'bold)
;;
;; * Adjust the foreground of `easy-verilog-face'
;; * Set `easy-verilog-character-begin' to a different character.
;; * Set `easy-verilog-character-end' to a different character.
;; * Adjust the levels foreground of `easy-verilog-levels-face'
;; * Adjust the levels foreground of `easy-verilog-digit-face'
;;

;;; Code:

(require 'font-lock)
(require 'verilog-mode)

(defgroup easy-verilog nil
  "Improve readability of Verilog."
  :group 'programming)

(defface easy-verilog-face
  '((t :weight normal))
  "Face used to highlight char to replace 'begin' and 'end' words"
  :group 'easy-verilog)

(defface easy-verilog-levels-face
  '((t :weight normal))
  "Face used to highlight char to replace levels(1/0)"
  :group 'easy-verilog)

(defface easy-verilog-digit-face
  '((t :weight normal))
  "Face used to highlight char to replace digit(1/0)"
  :group 'easy-verilog)

(defcustom easy-verilog-character-begin ?\{
  "Character to replase word 'begin'."
  :group 'easy-verilog)

(defcustom easy-verilog-character-end ?\}
  "Character to replase word 'end'."
  :group 'easy-verilog)

(defcustom easy-verilog-character-low ?0
  "Character to replase 1'b0."
  :group 'easy-verilog)

(defcustom easy-verilog-character-high ?1
  "Character to replase 1'b1."
  :group 'easy-verilog)

(defcustom easy-verilog-character-middle ?z
  "Character to replase 1'bz."
  :group 'easy-verilog)

(defcustom easy-verilog-character-zero ?0
  "Character to replase 1'd0."
  :group 'easy-verilog)

(defcustom easy-verilog-character-one ?1
  "Character to replase 1'd1."
  :group 'easy-verilog)

(defun easy-verilog--out-comment-p (pos)
  "Indicate whether POS is inside of a string."
  (let ((face (get-text-property pos 'face)))
    (or (not (eq 'font-lock-comment-face face))
		(and (listp face) (memq 'font-lock-string-face face)))))

(defun easy-verilog--out-string-p (pos)
  "Indicate whether POS is inside of a string."
  (let ((face (get-text-property pos 'face)))
    (or (not (eq 'font-lock-string-face face))
		(and (listp face) (memq 'font-lock-string-face face)))))

(defun easy-verilog--mark-verilogs-begin (limit)
  "Position point at end of next 'begin', and set match data.
Search ends at LIMIT."
  (catch 'found
    (while (re-search-forward "\\<begin\\>" limit t)
	  (when (and (easy-verilog--out-comment-p (match-beginning 0))
				 (easy-verilog--out-string-p (match-beginning 0)))
		(throw 'found t)))))

(defun easy-verilog--mark-verilogs-end (limit)
  "Position point at end of next 'end', and set match data.
Search ends at LIMIT."
  (catch 'found
    (while (re-search-forward "\\<end\\>" limit t)
      (when (and (easy-verilog--out-comment-p (match-beginning 0))
				 (easy-verilog--out-string-p (match-beginning 0)))
		(throw 'found t)))))

(defun easy-verilog--mark-verilogs-low (limit)
  "Position point at end of 1'b0, and set match data.
Search ends at LIMIT."
  (catch 'found
    (while (re-search-forward "\\<1'b0\\>" limit t)
      (when (and (easy-verilog--out-comment-p (match-beginning 0))
				 (easy-verilog--out-string-p (match-beginning 0)))
		(throw 'found t)))))

(defun easy-verilog--mark-verilogs-high (limit)
  "Position point at end of 1'b1, and set match data.
Search ends at LIMIT."
  (catch 'found
    (while (re-search-forward "\\<1'b1\\>" limit t)
      (when (and (easy-verilog--out-comment-p (match-beginning 0))
				 (easy-verilog--out-string-p (match-beginning 0)))
		(throw 'found t)))))

(defun easy-verilog--mark-verilogs-middle (limit)
  "Position point at end of 1'bz, and set match data.
Search ends at LIMIT."
  (catch 'found
    (while (re-search-forward "\\<1'bz\\>" limit t)
      (when (and (easy-verilog--out-comment-p (match-beginning 0))
				 (easy-verilog--out-string-p (match-beginning 0)))
		(throw 'found t)))))

(defun easy-verilog--mark-verilogs-zero (limit)
  "Position point at end of 1'd0, and set match data.
Search ends at LIMIT."
  (catch 'found
    (while (re-search-forward "\\<1'd0\\>" limit t)
      (when (and (easy-verilog--out-comment-p (match-beginning 0))
				 (easy-verilog--out-string-p (match-beginning 0)))
		(throw 'found t)))))

(defun easy-verilog--mark-verilogs-one (limit)
  "Position point at end of 1'd1, and set match data.
Search ends at LIMIT."
  (catch 'found
    (while (re-search-forward "\\<1'd1\\>" limit t)
      (when (and (easy-verilog--out-comment-p (match-beginning 0))
				 (easy-verilog--out-string-p (match-beginning 0)))
		(throw 'found t)))))

(defun easy-verilog--compose-begin (start)
  "Compose characters from START to (+ 5 START) into `easy-verilog-character-begin'."
  (compose-region start (+ 5 start) easy-verilog-character-begin))

(defun easy-verilog--compose-end (start)
  "Compose characters from START to (+ 3 START) into `easy-verilog-character-end'."
  (compose-region start (+ 3 start) easy-verilog-character-end))

(defun easy-verilog--compose-low (start)
  "Compose characters from START to (+ 4 START) into `easy-verilog-character-low'."
  (compose-region start (+ 4 start) easy-verilog-character-low))

(defun easy-verilog--compose-high (start)
  "Compose characters from START to (+ 4 START) into `easy-verilog-character-high'."
  (compose-region start (+ 4 start) easy-verilog-character-high))

(defun easy-verilog--compose-middle (start)
  "Compose characters from START to (+ 4 START) into `easy-verilog-character-middle'."
  (compose-region start (+ 4 start) easy-verilog-character-middle))

(defun easy-verilog--compose-zero (start)
  "Compose characters from START to (+ 4 START) into `easy-verilog-character-zero'."
  (compose-region start (+ 4 start) easy-verilog-character-zero))

(defun easy-verilog--compose-one (start)
  "Compose characters from START to (+ 4 START) into `easy-verilog-character-one'."
  (compose-region start (+ 4 start) easy-verilog-character-one))

(defconst easy-verilog--keywords
  '((easy-verilog--mark-verilogs-begin (0 (easy-verilog--compose-begin (match-beginning 0)))
									   (0 'easy-verilog-face append))
	(easy-verilog--mark-verilogs-end (0 (easy-verilog--compose-end (match-beginning 0)))
									 (0 'easy-verilog-face append))
    (easy-verilog--mark-verilogs-low (0 (easy-verilog--compose-low (match-beginning 0)))
                                     (0 'easy-verilog-levels-face append))
    (easy-verilog--mark-verilogs-high (0 (easy-verilog--compose-high (match-beginning 0)))
                                      (0 'easy-verilog-levels-face append))
    (easy-verilog--mark-verilogs-middle (0 (easy-verilog--compose-middle (match-beginning 0)))
                                        (0 'easy-verilog-levels-face append))
    (easy-verilog--mark-verilogs-zero (0 (easy-verilog--compose-zero (match-beginning 0)))
                                      (0 'easy-verilog-digit-face append))
    (easy-verilog--mark-verilogs-one (0 (easy-verilog--compose-one (match-beginning 0)))
                                     (0 'easy-verilog-digit-face append)))
  "Font-lock keyword list used internally.")

;;;###autoload
(define-minor-mode easy-verilog-minor-mode
  "Replace words 'begin' and 'end' to symbol '{' and '}', and some others characters,
 to improve readability of Verilog."
  :lighter " eV"
  :group 'easy-verilog
  (if easy-verilog-minor-mode
      (progn (font-lock-add-keywords nil easy-verilog--keywords)
             (add-to-list (make-local-variable 'font-lock-extra-managed-props) 'composition))
    (font-lock-remove-keywords nil easy-verilog--keywords))
  (if (>= emacs-major-version 25)
      (font-lock-flush)
    (with-no-warnings (font-lock-fontify-buffer))))

(provide 'easy-verilog)
;;; easy-verilog.el ends here
