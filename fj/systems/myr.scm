(define-module (fj systems myr)
  #:use-module (fj systems base)
  #:use-module (gnu)
  #:use-module (gnu home)
  #:use-module (guix channels)
  #:use-module (fj home-services core)
  #:export (myr-os)
  )

(use-modules (fj systems base))

(define myr-os
  (my-system
   #:%username "fj"
   #:%system
   (operating-system
    (host-name "myr")

    ;; cryptsetup luksUUID /dev/nvme0n1p2
    (mapped-devices
     (list (mapped-device
            (source (uuid "0943eb64-ac84-44a4-8915-aa90e49dc1e2"))
            (target "main")
            (type luks-device-mapping))))

    (bootloader (bootloader-configuration
                 (bootloader grub-efi-bootloader)
                 (targets '("/boot/efi"))))

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
    )

   #:%home
   (home-environment
    (packages (list))
    (services my-core-home-services)
    )))

myr-os
