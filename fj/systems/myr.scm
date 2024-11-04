(define-module (fj systems myr)
  #:use-module (gnu)
  #:use-module (guix)
  #:use-module (fj systems base))

(my-system
 #:system
 (operating-system
  (host-name "myr")

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
  )

 #:home
 (home-environment
  (packages (list))
  (services (list))
  ;; (services (cons* (service home-pipewire-service-type)
  ;;                  (service home-video-service-type)
  ;;                  (service home-audio-service-type)
  ;;                  (service home-finance-service-type)
  ;;                  (service home-streaming-service-type)
  ;;                  (service home-games-service-type)
  ;;                  common-home-services))

  )

 )
