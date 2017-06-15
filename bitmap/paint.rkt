#lang typed/racket/base

(provide (all-defined-out))

(require "color.rkt")

(require "digitama/paint.rkt")
(require "digitama/misc.rkt")
(require "digitama/unsafe/source.rkt")

;;; https://svgwg.org/svg2-draft/painting.html
(define-type CSS-Gradient-Stop-Color (Pairof Real FlRGBA))
(define-type CSS-Linear-Gradient (Vector Real Real Real Real (Listof CSS-Gradient-Stop-Color)))
(define-type CSS-Radial-Gradient (Vector Real Real Real Real Real Real (Listof CSS-Gradient-Stop-Color)))

(struct: stroke : Stroke
  ([color : FlRGBA]
   [width : Flonum]
   [cap : Stroke-Cap-Style]
   [join : Stroke-Join-Style]
   [miterlimit : Flonum]
   [dash : (Vectorof Nonnegative-Flonum)]
   [offset : Flonum]))

(struct: fill : Fill
  ([color : FlRGBA]
   [rule : Fill-Rule-Style]))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define default-stroke : (Parameterof Stroke) (make-parameter (stroke transparent 1.0 'butt 'miter +nan.0 solid-dash 0.0)))
(define default-fill : (Parameterof Fill) (make-parameter (fill black 'nonzero)))

(define desc-stroke : (->* ()
                           (Stroke #:color (Option Color) #:opacity Real #:width (Option Real)
                                   #:cap (Option Symbol) #:join (U Symbol Real False)
                                   #:dash (U Symbol (Vectorof Nonnegative-Flonum) False) #:offset (Option Real))
                           Stroke)
  (lambda [[baseline (default-stroke)] #:color [color #false] #:opacity [opacity 1.0] #:width [width #false]
                                       #:cap [cap #false] #:join [join #false] #:dash [dash #false] #:offset [offset #false]]
    (define-values (linejoin miterlimit)
      (cond [(stroke-line-join-option? join) (values join (stroke-miterlimit baseline))]
            [(real? join) (values 'miter (real->double-flonum join))]
            [else (values (stroke-join baseline) (stroke-miterlimit baseline))]))
    (define-values (dasharray preoffset)
      (cond [(stroke-dash-style? dash) (line-dash->array dash)]
            [else (values (stroke-dash baseline) (stroke-offset baseline))]))
    (define dashoffset : Flonum (if (not offset) preoffset (real->double-flonum offset)))
    (stroke (rgb* (if (not color) (stroke-color baseline) color) opacity)
            (if (real? width) (real->double-flonum width) (stroke-width baseline))
            (if (stroke-line-cap-option? cap) cap (stroke-cap baseline))
            linejoin miterlimit dasharray dashoffset)))

(define desc-fill : (->* () (Fill #:color (Option Color) #:opacity Real #:rule (Option Symbol)) Fill)
  (lambda [[basefill (default-fill)] #:color [color #false] #:opacity [opacity 1.0] #:rule [rule #false]]
    (fill (rgb* (if (not color) (fill-color basefill) color) opacity)
          (if (fill-rule-option? rule) rule (fill-rule basefill)))))