#lang typed/racket/base

(provide (all-defined-out))

(define-type Color (U Symbol Integer FlColor))
(define-predicate color? Color)

(struct paint () #:transparent #:type-name Paint)
(struct flcolor () #:transparent #:type-name FlColor)
(struct rgba flcolor ([red : Flonum] [green : Flonum] [blue : Flonum] [alpha : Flonum])
  #:transparent #:type-name FlRGBA)

(define default-bitmap-density : (Parameterof Positive-Flonum) (make-parameter 2.0))
(define default-bitmap-icon-height : (Parameterof Nonnegative-Flonum) (make-parameter 24.0))
