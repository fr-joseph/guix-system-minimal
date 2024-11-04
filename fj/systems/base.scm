(define-module (fj systems base)
  #:use-module (gnu)
  #:use-module (guix)
  #:use-module (guix channels)
  #:use-module (nongnu packages linux)
  #:use-module (nongnu system linux-initrd)
  #:export (my-system)
  )

(use-service-modules networking ssh)
(use-package-modules package-management ssh tmux version-control vim)

  ;; Channels that should be available to /run/current-system/profile/bin/guix
(define my-channels
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

(define* (my-system #:key system home)
  (operating-system
   (inherit system)

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
                 (name "user")
                 (comment "user")
                 (group "users")
                 (home-directory "/home/user")
                 (supplementary-groups '("audio" "lp" "netdev" "video" "wheel")))
                %base-user-accounts))

   (sudoers-file (plain-file "sudoers" "\
root ALL=(ALL) ALL
%wheel ALL=(ALL) NOPASSWD: ALL\n"))

   ;; minimal system packages
   (packages (cons* git tmux neovim %base-packages))

   (services (append
              (operating-system-user-services system)
              (list
               ;; set up my home configuration
               (service guix-home-service-type
                        `(("fj" ,home)))
               (service dhcp-client-service-type)
               (service ntp-service-type)
               (service openssh-service-type
                        (openssh-configuration
                         (openssh openssh-sans-x)
                         (port-number 2222)))
               )
              (modify-services %base-services
                               (guix-service-type
                                config => (guix-configuration
                                           (inherit config)
                                           (channels my-channels)
                                           (guix (guix-for-channels my-channels)))))
              ))

   ;; resolve .local host names with mDNS
   (name-service-switch %mdns-host-lookup-nss)

   ))
