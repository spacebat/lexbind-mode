;;; lexbind-mode.el --- Puts the value of lexical-binding in the mode line

;; Copyright (C) 2013 Andrew Kirkpatrick

;; Author:     Andrew Kirkpatrick <ubermonk@gmail.com>
;; Maintainer: Andrew Kirkpatrick <ubermonk@gmail.com>
;; URL:        https://github.com/spacebat/lexbind-mode
;; Created:    08 Mar 2013
;; Keywords:   convenience, lisp
;; Version:    0.5

;; This file is not part of GNU Emacs.

;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You may have received a copy of the GNU General Public License
;; along with this program.  If not, see:
;; <http://www.gnu.org/licenses/>.

;;; Commentary:

;; Emacs 24 introduced lexical scope for variables to Emacs
;; Lisp.  However, rather than provide it via a new form, say llet or
;; whatever, the buffer local variable `lexical-binding' was
;; introduced to switch the behaviour of binding forms.  This is an
;; unfortunate situation because the semantics of a piece of code
;; depend on the value of a buffer local variable at the time of
;; evaluation.

;; This minor mode is intended to make it plain what the value of
;; `lexical-binding' is in the buffers used to evaluate Lisp forms.
;; It does this by adding to the mode line the string "(LEX)" to
;; indicate lexical binding is enabled, and "(DYN)" to indicate that
;; lexical binding is disabled and that dynamic binding is in effect.

;; To install, once lexbind-mode.el is located somewhere in your
;; load-path, you can add this to your initialization file:

;; (require 'lexbind-mode)
;; (add-hook 'emacs-lisp-mode-hook 'lexbind-mode)

;;; Code:

;; Local Variables:
;; lexical-binding: t
;; End:

(eval-when-compile
  (require 'cl))

;;;###autoload
(defun lexbind-toggle-lexical-binding (&optional arg)
  "Toggle the variable `lexical-binding' on and off.  Interactive.
When called with a numeric argument, set `lexical-binding' to t
if the argument is positive, nil otherwise.
Optional argument ARG if nil toggles `lexical-binding', positive
enables it, non-positive disables it."
  (interactive)
  (setq lexical-binding (if arg
                            (plusp (prefix-numeric-value arg))
                          (not lexical-binding))))

;;;###autoload
(defun lexbind-modeline-content (&rest args)
  "Generate mode line content to indicate the value of `lexical-binding'.
Optional argument ARGS if provided, the first argument is taken as the value
of `lexical-binding'."
  (let ((lexbind-p (if (plusp (length args))
                       (car args)
                     lexical-binding))

        (pattern "Emacs Lisp lexical-binding is %s"))

    (concat
     " "
     (if lexbind-p
         (propertize
          "(LEX)"
          'help-echo (format pattern "enabled"))
       (propertize
        "(DYN)"
        'help-echo (format pattern "disabled"))))))


;;;###autoload
(define-minor-mode lexbind-mode
  "Toggle Lexbind mode.
Interactively with no argument, this command toggles the mode.
A positive prefix argument enables the mode, any other prefix
argument disables it.  From Lisp, argument omitted or nil enables
the mode, `toggle' toggles the state.

When lexbind mode is enabled, the mode line of a window will
contain the string (LEX) for lexical binding, (DYN) for dynamic
binding, to indicate the state of the lexical-binding variable in
that buffer."

      :init-value nil
      :lighter ""   ; unable to change lighter on a per-buffer basis
      :keymap '(((kbd "C-cM-l") . lexbind-toggle-lexical-binding))
      :group 'lexbind
      :after-hook (progn
                    (setq mode-line-format
                          (append
                           (remove-if (lambda (x)
                                        (eq x 'mode-line-end-spaces))
                                      mode-line-format)
                           '((lexbind-mode
                              (:eval (lexbind-modeline-content))))
                           'mode-line-end-spaces))
                    (force-mode-line-update)))


(provide 'lexbind-mode)

;;; lexbind-mode.el ends here
