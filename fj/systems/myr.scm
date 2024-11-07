(define-module (fj systems myr)
  #:use-module (gnu)
  #:use-module (guix)
  #:use-module (guix channels)
  #:use-module (fj systems base)
  #:use-module (fj home-services core)
  #:use-module (fj home-services desktop)
  #:use-module (fj home-services emacs)
  #:use-module (fj home-services pipewire)
  )

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
  (services (cons*
             (service my-home-desktop-service-type)
             (service my-home-emacs-config-service-type)
             (service my-home-pipewire-service-type)
             my-core-home-services))

  ))
