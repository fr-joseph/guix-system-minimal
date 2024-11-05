(define-module (fj systems base)
  #:use-module (gnu)
  #:use-module (guix)
  #:use-module (guix channels)
  #:use-module (nongnu packages linux)
  #:use-module (nongnu system linux-initrd)
	#:use-module (srfi srfi-1) ; for `delete'
  #:export (my-system)
  )

(use-service-modules networking ssh)
(use-package-modules package-management ssh tmux version-control)

  ;; Channels that should be available to /run/current-system/profile/bin/guix
(define %my-channels
  (append
   (list
    (channel
     (name 'nonguix)
     (url "https://gitlab.com/nonguix/nonguix")
     (introduction
      (make-channel-introduction
       "897c1a470da759236cc11798f4e0a5f7d4d59fbc"
       (openpgp-fingerprint
        "2A39 3FFF 68F4 EF7A 3D29  12AF 6F51 20A0 22FB B2D5")))))
   %default-channels))

;; remove wireless, and editors that I don't use
(define %my-base-packages
  (delete nano ; no, ty
  (delete nvi ; vi clone
  (delete mg ; mini-emacs
  (delete iw ; wireless tools
  (delete wireless-tools ; deprecated wireless tools
          %base-packages))))))

(define %my-packages
  (cons*
   ;; things I want on every system
   bat
   curl
   emacs-no-x-toolkit
   fd
   git
   just
   plocate
   ripgrep
   tmux
   trash-cli
   unzip
   zip
   zoxide
   ;; end
   %my-base-packages))

(define %my-services
  (list
   (service dhcp-client-service-type)
   (service openssh-service-type
            (openssh-configuration
             (openssh openssh-sans-x)
             (port-number 2222)))
   (simple-service
    'my-etc-hosts
    hosts-service-type
    (list ;; (host ADDRESS CANONICAL-NAME [ALIASES])
		 (host "192.168.0.10"  "archive"   '("archive.ds"))
		 (host "192.168.0.128" "salt"      '())
		 (host "192.168.0.2"   "baptist"   '("dbsrv.ds"
							                           "dbsrv.gocamerica.net"
							                           "baptist.ds"
							                           "baptist.gocamerica.net"
							                           "secure.dormitionskete.net"))
		 (host "192.168.0.5"   "dormition" '("dormition.ds"))
		 (host "192.168.0.86"  "WD01"      '("WD01.ds"))
		 (host "74.208.16.226" "ionos"     '("ionos.production"))
     ))
   (service ntp-service-type)
   ))

(define* (my-system #:key %username %system %home)
  (operating-system
   (inherit %system)

   ;; nongnu kernel & firmware
   (kernel linux)
   (initrd microcode-initrd)
   (firmware (list linux-firmware))

   (timezone "America/Denver")
   (locale "en_US.utf8")

   (bootloader (bootloader-configuration
                (bootloader grub-efi-bootloader)
                (targets '("/boot/efi"))))

   (users (cons (user-account
                 (name %username)
                 (comment %username)
                 (group "users")
                 (home-directory (string-append "/home/" %username))
                 (supplementary-groups '("audio" "lp" "netdev" "video" "wheel")))
                %base-user-accounts))

   (sudoers-file (plain-file "sudoers" "\
root ALL=(ALL) ALL
%wheel ALL=(ALL) NOPASSWD: ALL\n"))

   ;; minimal system packages
   (packages %my-packages)

   (services (append
              (operating-system-user-services %system)
              (list (service guix-home-service-type `((,%username ,%home))))
              %my-services
              (modify-services %base-services
                               (guix-service-type
                                config => (guix-configuration
                                           (inherit config)
                                           (channels %my-channels)
                                           (guix (guix-for-channels %my-channels)))))
              ))

   ;; resolve .local host names with mDNS
   (name-service-switch %mdns-host-lookup-nss)

   ))
