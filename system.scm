;; -*- mode: scheme; -*-

(define-module (system)
  #:use-module (gnu)
  )

(use-service-modules networking ssh)
(use-package-modules ssh)

(operating-system

 ;; nongnu kernel & firmware
 (kernel linux)
 (initrd microcode-initrd)
 (firmware (list linux-firmware))

 (host-name "myr")
 (timezone "America/Denver")
 (locale "en_US.utf8")

 (bootloader (bootloader-configuration
	      (bootloader grub-efi-bootloader)
	      (targets '("/boot/efi"))))

 ;; cryptsetup luksUUID /dev/nvme0n1p2
 (mapped-devices
  (list (mapped-device
	 (source (uuid "0be699f5-67bc-4e27-88e5-b47a0335dd8c"))
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

 (packages (cons* tmux vim %base-packages))

 (services (append (list
		    (service dhcp-client-service-type)
		    (service ntp-service-type)
                    (service openssh-service-type
                             (openssh-configuration
                              (openssh openssh-sans-x)
                              (port-number 2222))))
                   %base-services))

 ;; resolve .local host names with mDNS
 (name-service-switch %mdns-host-lookup-nss)

 )
