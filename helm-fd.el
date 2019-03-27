;;; helm-fd.el --- helm extension for fd             -*- lexical-binding: t; -*-

;; Copyright (C) 2019  Wang Kai

;; Author: Wang Kai <kaiwkx@gmail.com>
;; Keywords: files, matching

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;;

;;; Code:


(require 'helm)
(require 'helm-lib)
(require 'helm-files)
(require 'helm-source)

(defcustom helm-fd-executable "fd"
  "Default executable for fd"
  :type 'stringp
  :group 'helm-fd)

(defcustom helm-fd-command-args (list "--hidden" "--color" "never")
  "Default fd args"
  :type 'list
  :group 'helm-fd)

(defun helm-fd--do-fd-candidate-process ()
  (let* ((cmd-args (append (cons helm-fd-executable helm-fd-command-args)
                           (list (replace-regexp-in-string "\s+" ".*" helm-pattern))))
         (proc (apply 'start-file-process "helm-fd" helm-buffer cmd-args)))
    (prog1 proc
      (set-process-sentinel
       (get-buffer-process helm-buffer)
       #'(lambda (process event)
           (helm-process-deferred-sentinel-hook
            process event (helm-default-directory)))))))

(defvar helm-fd-source
  (helm-build-async-source "fd results"
    :candidates-process 'helm-fd--do-fd-candidate-process
    :requires-pattern 2
    :action 'helm-find-file-or-marked
    :candidate-number-limit 9999))

;;;###autoload
(defun helm-fd ()
  (interactive)
  (helm :sources 'helm-fd-source
        :buffer "*helm-fd*"))

(provide 'helm-fd)
;;; helm-fd.el ends here
