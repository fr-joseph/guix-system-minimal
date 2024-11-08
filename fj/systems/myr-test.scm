(define-module (fj systems myr-test)
  #:use-module (gnu)
  #:use-module (gnu system)
  #:use-module (gnu services)
  #:use-module (srfi srfi-1)
  #:use-module (ice-9 pretty-print)
  #:use-module (fj systems myr)
  )

(define-public rot
  (filter (lambda (svc)
    (eq?
      (service-type-name (service-kind svc))
      'rottlog
    ))
  (operating-system-services myr-os)
  )
)

(define-public xall
  (operating-system-services myr-os)
)

(define-public xuniq
  (delete-duplicates
    xall
  )
)

(define-public (svc-name s)
  (symbol->string
    (service-type-name (service-kind s))
  )
)

(define-public (svc-name= x y)
  (string=
    (svc-name x)
    (svc-name y)
  )
)

(define-public xuniq2
  (delete-duplicates
    xall
    svc-name=
  )
)

(define-public (svc-name<? x y)
  (string<?
    (svc-name x)
    (svc-name y)
  )
)

(define-public (show-all x)
  (map 
    (lambda (s)
      (display s)
      (newline)
      (newline)
    )
    (sort-list x svc-name<?)
  )
)

(define-public (get-svc x)
	       (filter (lambda (y)
			 (string= x (svc-name y))
			 )
		       xall
		       )
	       )

(define-public (show-svc x)
	       (pretty-print (get-svc x) #:display? #t)
	       )






