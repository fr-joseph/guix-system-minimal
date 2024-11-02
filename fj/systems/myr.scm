(define-module (fj systems myr)
  #:use-module (gnu)
  #:use-module (guix)
  #:use-module (fj systems base-system))

(operating-system
  (inherit base-system)
  (host-name "myr")

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
                (name "fj")
                (comment "fj")
                (group "users")
                (home-directory "/home/fj")
                (supplementary-groups '("audio" "lp" "netdev" "video" "wheel")))
               %base-user-accounts))

  )
