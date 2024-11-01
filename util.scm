(define-module (util)
  #:use-module (gnu)
  #:use-module (gnu system)
  #:use-module (guix packages)
  )

;;(use-modules
 ;;(srfi srfi-1)
 ;;(gnu services base)
 ;;(gnu services desktop)
 ;;)

;;(pretty-print (map service-kind %desktop-services))

;; (map
;;  (lambda (x) (display x))
;;  %base-packages)

(define (my-sort-list xs)
  (sort-list xs string<?))

(define (my-print-list xs)
  (map
   (lambda (x)
     (display x)
     (display "\n"))
   xs)
  #t)

(define-public (show-base-packages)
  (my-print-list
   (my-sort-list
    (map
     (lambda (x) (package-name x))
     %base-packages)
    ))
  #t)
