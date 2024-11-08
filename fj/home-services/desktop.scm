(define-module (fj home-services desktop)
  #:use-module (gnu)
  #:use-module (gnu home services)
  #:use-module (gnu packages)
  #:use-module (gnu services)
  #:use-module (guix gexp)
  #:export (my-home-desktop-service-type))

(use-package-modules compression curl fonts freedesktop gimp glib gnome gnome-xyz
                     gstreamer kde-frameworks linux music package-management
                     password-utils pdf pulseaudio shellutils ssh syncthing video
                     web-browsers wget wm xdisorg xorg)

(define (my-home-desktop-profile-service config)
  (list sway
        swayidle
        swaylock
        waybar
        mako
        grimshot ;; grimshot --notify copy area
        network-manager-applet

        xorg-server-xwayland

        flatpak
        shared-mime-info
        xdg-dbus-proxy
        xdg-desktop-portal
        xdg-desktop-portal-gtk
        xdg-desktop-portal-wlr
        xdg-utils
        (list glib "bin")

        ;; appearance
        ;; matcha-theme
        ;; papirus-icon-theme
        ;; breeze-icons ;; For KDE apps
        ;; gnome-themes-extra
        ;; adwaita-icon-theme

        ;; font
        font-awesome ; full suite of pictographic icons for easy SVG
        font-fira-code
        font-google-noto ; unicode support
        font-google-noto-emoji ; emoji support
        font-liberation ; basic fonts
        fontconfig ; fc-cache, fc-list

        ;; audio/media
        alsa-utils
        mpv
        ;; pavucontrol ; try use `emacs-pulseaudio-control' instead
        yt-dlp

        ;; graphics
        gimp-next
        ))

(define (my-home-desktop-environment-variables config)
  '(("_JAVA_AWT_WM_NONREPARENTING" . "1")))

(define my-home-desktop-service-type
  (service-type (name 'my-home-desktop)
                (description "my desktop environment service.")
                (extensions
                 (list (service-extension
                        home-profile-service-type
                        my-home-desktop-profile-service)
                       (service-extension
                        home-environment-variables-service-type
                        my-home-desktop-environment-variables)))
                (default-value #f)))
