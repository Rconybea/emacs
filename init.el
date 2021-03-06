; note: on Roland-laptop-14,  used System Preferences|Keyboard|Modifier Keys to set capslock -> control

;; ----- list of packages we will be requiring -----

(defvar roland/packages '(autopair icicles yasnippet))

;; ----- bootstrap package lists -----

(message "rc: configuring package archives")

(require 'package)
(dolist (source '(("marmalade" . "http://marmalade-repo.org/packages/")
                  ("elpa" . "http://elpa.gnu.org/packages/")
				  ;;("elpa" . "http://tromey.com/elpa/")
				  ("melpa" . "http://melpa.milkbox.net/packages/")
				  ))
  (add-to-list 'package-archives source t))
(package-initialize)

(when (not package-archive-contents)
  (package-refresh-contents))

;; ----- install missing packages -----

(message "rc: installing any missing packages from roland/packages")

(dolist (p roland/packages)
  (when (not (package-installed-p p))
	(package-install p)))

;; ----- at this point all our packages should be installed ------

;; ----- configure autopair -----

(require 'autopair)
(autopair-global-mode 1)
(setq autopair-autowrap t)

;; ----- configure icicles -----

(require 'icicles)
;; activate icicles (souped-up autocomplete)
(icy-mode 1)

;; ------ toggle between a file h/foo.hpp and src/foo.cpp -----

(defun my-goto-h-file-knight ()
  "Toggle between header and sources files of the same name"
  (interactive)
  (let ((h-file ""))
    (when (string-match "\\.cpp$" (buffer-file-name))
	  (message "file name is %s../h/%s.hpp" default-directory (file-name-sans-extension (buffer-name)))
	  (setq h-file (format "%s../h/%s.hpp" default-directory (file-name-sans-extension (buffer-name))))
	  (if (not (file-exists-p h-file))
		  (let ()
			(message "file name is %s%s.hpp" default-directory (file-name-sans-extension (buffer-name)))
			(setq h-file (format "%s%s.hpp" default-directory (file-name-sans-extension (buffer-name))))
			)
		)
	  (if (not (file-exists-p h-file))
		  (let ()
			(message "file name is %s%s.h" default-directory (file-name-sans-extension (buffer-name)))
			(setq h-file (format "%s%s.h" default-directory (file-name-sans-extension (buffer-name))))))
	  )
    (when (string-match "\\.hpp$" (buffer-file-name))
	  (message "file name is %s../src/%s.cpp" default-directory (file-name-sans-extension (buffer-name)))
      (setq h-file (format "%s../src/%s.cpp" default-directory (file-name-sans-extension (buffer-name))))
	  (if (not (file-exists-p h-file))
		  (let ()
			(message "file name is %s%s.cpp" default-directory (file-name-sans-extension (buffer-name)))
			(setq h-file (format "%s%s.cpp" default-directory (file-name-sans-extension (buffer-name))))))
	  (if (not (file-exists-p h-file))
		  (let ()
			(message "file name is %s%s.c" default-directory (file-name-sans-extension (buffer-name)))
			(setq h-file (format "%s%s.c" default-directory (file-name-sans-extension (buffer-name))))))
	  )
    (when (string-match "\\.h$" (buffer-file-name))
	  (message "file name is %s../src/%s.cpp" default-directory (file-name-sans-extension (buffer-name)))
      (setq h-file (format "%s../src/%s.cpp" default-directory (file-name-sans-extension (buffer-name))))
	  (if (not (file-exists-p h-file))
		  (let ()
			(message "file name is %s%s.cpp" default-directory (file-name-sans-extension (buffer-name)))
			(setq h-file (format "%s%s.cpp" default-directory (file-name-sans-extension (buffer-name))))))
	  (if (not (file-exists-p h-file))
		  (let ()
			(message "file name is %s%s.c" default-directory (file-name-sans-extension (buffer-name)))
			(setq h-file (format "%s%s.c" default-directory (file-name-sans-extension (buffer-name))))))
	  )
	(when (file-exists-p h-file)
	  (find-file h-file)
	  (switch-to-buffer (file-name-nondirectory h-file))))
  )
(global-set-key "\C-x\C-h" 'my-goto-h-file-knight)

;; ----- start emacs server -----

(server-start)

;; ----- key bindings -----

(message "rc: establish custom key bindings")

;; compilation..
(global-set-key (kbd "C-c k") 'compile)

;; expand dynamic abbreviations
(global-set-key (kbd "C-<return>") 'hippie-expand)
(global-set-key (kbd "M-<return>") 'hippie-expand) ;; <--- preferred binding
(global-set-key (kbd "A-<return>") 'hippie-expand)
;; looks like C-; is supposed to toggle interpretation of option key in aquamacs
;;(global-set-key (kbd "C-;") 'hippie-expand)

;; make C-x C-m equivalent to M-x
(global-set-key "\C-x\C-m" 'execute-extended-command)
;; using this key-sequence instead of C-w..
(global-set-key "\C-x\C-k" 'kill-region)
;; ..because we want to use C-w for backward-kill-word 
(global-unset-key "\C-w")
(global-set-key "\C-w" 'backward-kill-word)

;; same as ESC C-s
(global-set-key "\M-s" 'isearch-forward-regexp)
;; same as ESC C-r
(global-set-key "\M-r" 'isearch-backward-regexp)

;; use M-x qrr instead of M-x query-replace-regexp
(defalias 'qrr 'query-replace-regexp)

;; ----- grab some more screen real estate -----

(message "rc: disable scroll bars / toolbar")

;; disable scrollbars, toolbars -- would rather have the screen real estate
(if (fboundp 'scroll-bar-mode)
    (scroll-bar-mode -1))
(if (fboundp 'tool-bar-mode)
    (tool-bar-mode -1))
;; don't need to disable menubars on OSX,  since they don't consume pixels (being shared across programs)
;; how do we recognize that we're running in aquamacs
;;(if (fboundp 'menu-bar-mode)
;;    (menu-bar-mode -1))

;; ----- prevent help popping up in a new frame -----

(message "rc: disable help creating new frames")

;; open *help* in current fram [this works if we're using 'one-buffer-one-frame-mode]
;; from www.emacswiki.org/emacs/AquamacsFAQ#toc1
(setq obof-other-frame-regexps (remove "\\*Help\\*" obof-other-frame-regexps))
(add-to-list 'obof-same-frame-regexps "\\*Help\\*")
(add-to-list 'obof-same-frame-switching-regexps "\\*Help\\*")

;; ----- customization for c++ programming -----

(message "rc: setup custom variables for c++ programming")

;; substatement-open is the syntactic context when a substatement (e.g. body of if- or while-) 
;; begins with an opening brace
;; you can find the syntactic context for the start of the current line using C-c C-s
;;
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(auto-compression-mode t nil (jka-compr))
 '(c-basic-offset 4)
 '(c-offsets-alist (quote ((substatement-open . 0))))
 '(case-fold-search t)
 '(current-language-environment "ASCII")
 '(ecb-options-version "2.40")
 '(global-font-lock-mode t nil (font-lock))
 '(send-mail-function (quote sendmail-send-it))
 '(show-paren-mode t nil (paren))
 '(tab-width 4)
 '(transient-mark-mode t))

;; ----- souped-up buffer switching -----

(iswitchb-mode 1)
;;(iswitchb-default-keybindings)

;; ----- yas snippets -----

;;(require 'yas-snippets)
(yas-global-mode 1)

;; ----- compute line# and col# -----

(global-linum-mode 1)
(setq column-number-mode t)

