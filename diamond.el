;;; diamond.el --- Emacs interface for Diamond

;; Copyright (C) 2006  Free Software Foundation, Inc.

;; Author: Jason Sayne <jasayne@frdcsa>
;; Keywords: 

;; This file is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.

;; This file is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to
;; the Free Software Foundation, Inc., 59 Temple Place - Suite 330,
;; Boston, MA 02111-1307, USA.

;;; Commentary:

;;

;;; Code:

(defun diamond-run-program (program)
 "Run a program through the diamond interface, which allows Emacs
specific implement of Manager::Dialog if detected, etc."
 (interactive)
 "")

(defun diamond-emacs-open-files (files-or-buffers)
 (interactive)
 ""
 (if (>= (length files-or-buffers) 2)
  (progn
   (delete-other-windows)
   (ffap (nth 0 files-or-buffers))
   (split-window-right)
   (other-window 1)
   (ffap (nth 1 files-or-buffers))
   (other-window 1)
   ))
 (if (>= (length files-or-buffers) 4)
  (progn
   (split-window-below)
   (other-window 1)
   (ffap (nth 2 files-or-buffers))
   (other-window 1)   
   (split-window-below)
   (other-window 1)
   (ffap (nth 3 files-or-buffers))
   (other-window 1))))

(provide 'diamond)
;;; diamond.el ends here
