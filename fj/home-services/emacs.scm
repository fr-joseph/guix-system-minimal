(define-module (fj home-services emacs)
  #:use-module (gnu packages)
  #:use-module (gnu packages emacs)
  #:use-module (gnu packages emacs-xyz)
  #:use-module (gnu packages gnupg)
  #:use-module (gnu packages mail)
  #:use-module (gnu packages version-control)
  #:use-module (gnu packages rust-apps)
  #:use-module (gnu home services)
  #:use-module (gnu services)
  #:use-module (gnu services configuration)
  #:use-module (guix gexp)
  #:use-module (guix transformations)
  #:export (my-home-emacs-config-service-type))

(define (my-home-emacs-config-profile-service config)
  (list
   emacs-next-pgtk

   ;; ((options->transformation
   ;;   ;; 2.3.0 does not include the `box :style none` fix
   ;;   '((with-commit . "emacs-doom-themes=3b2422b208d28e8734b300cd3cc6a7f4af5eba55")))
   ;;  emacs-doom-themes)

   emacs-a
   emacs-ace-window
   emacs-alert
   emacs-all-the-icons-dired
   emacs-auth-source-pass
   emacs-avy
   emacs-beframe
   emacs-buffer-env
   emacs-consult
   emacs-corfu
   emacs-daemons
   emacs-default-text-scale
   emacs-denote
   emacs-eat
   emacs-embark
   emacs-emojify
   emacs-esh-autosuggest
   emacs-eshell-syntax-highlighting
   emacs-eshell-toggle
   emacs-exec-path-from-shell
   emacs-flycheck
   emacs-flymake-shellcheck
   emacs-geiser
   emacs-git-gutter
   emacs-git-gutter-fringe
   emacs-git-link
   emacs-guix
   emacs-helpful
   emacs-keycast
   emacs-kind-icon
   emacs-marginalia
   emacs-markdown-mode
   emacs-minions
   emacs-mood-line
   emacs-mpv
   emacs-no-littering
   emacs-orderless
   emacs-org
   emacs-org-appear
   emacs-org-modern
   emacs-password-store
   emacs-pcmpl-args
   emacs-pinentry
   emacs-popper
   emacs-posframe
   emacs-pulseaudio-control
   emacs-rainbow-delimiters
   emacs-rainbow-mode
   emacs-request
   emacs-skewer-mode
   emacs-smartparens
   emacs-super-save
   emacs-tldr
   emacs-tmr
   emacs-tracking
   emacs-vertico
   emacs-visual-fill-column
   emacs-vterm
   emacs-web-mode
   emacs-wgrep
   emacs-ws-butler
   emacs-xterm-color
   emacs-yaml-mode
   emacs-yasnippet
   emacs-yasnippet-snippets
   isync
   pinentry-emacs
   ripgrep ; for consult-ripgrep

   ;; end
   ))

(define my-home-emacs-config-service-type
  (service-type (name 'my-home-emacs-config)
                (description "my personal emacs config")
                (extensions
                 (list (service-extension
                        home-profile-service-type
                        my-home-emacs-config-profile-service)))
                (default-value #f)))
