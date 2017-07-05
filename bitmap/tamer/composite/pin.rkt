#lang typed/racket

(require "../../digitama/draw.rkt")
(require "../../constructor.rkt")
(require "../../composite.rkt")
(require "../../paint.rkt")
(require "../../color.rkt")
(require "../../constants.rkt")

(define-values (diameter alpha) (values 192 1/3))
(default-stroke (desc-stroke long-dash #:width 4 #:opacity alpha #:cap 'round))

(define (build-flomap [x : Nonnegative-Fixnum] [y : Nonnegative-Fixnum] [w : Nonnegative-Fixnum] [h : Nonnegative-Fixnum])
  (define c (* 1/2 (+ 1 (sin (magnitude (make-rectangular (- x (/ w 2.0)) (- y (/ h 2.0))))))))
  (values 1.0 c c c))

(define red-circle (bitmap-ellipse diameter #:fill (rgb* 'red alpha)))
(define green-circle (bitmap-ellipse diameter #:fill (rgb* 'green alpha)))
(define blue-circle (bitmap-ellipse diameter #:fill (rgb* 'blue alpha)))
(define yellow-circle (bitmap-ellipse 124 #:border (desc-stroke #:opacity 3/2) #:fill (rgb* 'yellow 1/2)))
(define 3pc (bitmap-pin* 1/8 11/48 0 0 (bitmap-pin* 1/3 0 0 0 red-circle green-circle) blue-circle))

(define sine (bitmap-rectangular 100 100 build-flomap))
(bitmap-pin sine -10 -10 sine)
(bitmap-pin sine 50 0 sine)

3pc
(bitmap-pin 3pc 0 0 yellow-circle 64 64)
(bitmap-pin* 1/8 1/8 0 0 yellow-circle yellow-circle yellow-circle)
(bitmap-cc-superimpose 3pc yellow-circle)