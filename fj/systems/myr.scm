(define-module (fj systems myr)
  #:use-module (gnu)
  #:use-module (guix)
  #:use-module (guix channels)
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
          (source (uuid "0943eb64-ac84-44a4-8915-aa90e49dc1e2"))
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

    (sudoers-file (plain-file "sudoers" "\
root ALL=(ALL) ALL
%wheel ALL=(ALL) NOPASSWD: ALL\n"))

  )
