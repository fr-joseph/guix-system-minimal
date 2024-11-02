(define-module (fj systems base-system)
  #:use-module (gnu)
  #:use-module (guix)
  #:use-module (guix channels)
  #:use-module (nongnu packages linux)
  #:use-module (nongnu system linux-initrd)
  #:export (base-system)
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

(define base-system
  (operating-system

    ;; nongnu kernel & firmware
    (kernel linux)
    (initrd microcode-initrd)
    (firmware (list linux-firmware))

    (host-name "host")
    (timezone "America/Denver")
    (locale "en_US.utf8")

    (bootloader (bootloader-configuration
                 (bootloader grub-efi-bootloader)
                 (targets '("/boot/efi"))))

    ;; cryptsetup luksUUID /dev/nvme0n1p2
    (mapped-devices
     (list (mapped-device
            (source (uuid "12345678-1234-1234-1234-123456789abc"))
            (target "main")
            (type luks-device-mapping))))

    (file-systems (cons*
                   (file-system
                     (device (file-system-label "BOOT"))
                     (mount-point "/boot/efi")
                     (type "vfat"))
                   (file-system
                     (device (file-system-label "main"))
                     (dependencies mapped-devices)
                     (mount-point "/")
                     (type "ext4")
                     )
                   %base-file-systems))

    (users (cons (user-account
                  (name "user")
                  (comment "user")
                  (group "users")
                  (home-directory "/home/user")
                  (supplementary-groups '("audio" "lp" "netdev" "video" "wheel")))
                 %base-user-accounts))

    (packages (cons* git tmux neovim %base-packages))

    (services (cons*
               (service dhcp-client-service-type)
               (service ntp-service-type)
               (service openssh-service-type
                        (openssh-configuration
                         (openssh openssh-sans-x)
                         (port-number 2222)))
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
