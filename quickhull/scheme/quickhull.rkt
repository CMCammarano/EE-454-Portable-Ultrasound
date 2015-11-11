;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-advanced-reader.ss" "lang")((modname quickhull) (read-case-sensitive #t) (teachpacks ((lib "draw.rkt" "teachpack" "htdp"))) (htdp-settings #(#t constructor repeating-decimal #t #t none #f ((lib "draw.rkt" "teachpack" "htdp")) #f)))
(define-struct point (x y))
(define-struct line (point-A point-B))

(define cross-product (lambda (a-point a-line)
                        (-
                         (*
                          (- (point-x(line-point-A a-line)) (point-x a-point)) (- (point-y(line-point-B a-line)) (point-y a-point)))
                         (*
                          (- (point-y(line-point-A a-line)) (point-y a-point)) (- (point-x(line-point-B a-line)) (point-x a-point))))))
(define cross-map (lambda (list-of-points a-line)
                    (cond
                      [(empty? list-of-points) empty]
                      [#t (cons ( cross-product (car list-of-points) a-line) (cross-map (cdr list-of-points) a-line))])))

(define packed-filter-crossed (lambda (list-of-crossed)
                        (cond
                          [(empty? list-of-crossed) empty]
                          [(> (car list-of-crossed) 0) (cons (car list-of-crossed) (packed-filter-crossed (cdr list-of-crossed)))]
                          [#t (packed-filter-crossed (cdr list-of-crossed))])))

(define packed-filter-points (lambda (list-of-points list-of-crossed)
                               (cond
                                 [(empty? list-of-points) empty]
                                 [(> (car list-of-crossed) 0) (cons (car list-of-points) (packed-filter-points (cdr list-of-points) (cdr list-of-crossed)))]
                                 [#t (packed-filter-points (cdr list-of-points) (cdr list-of-crossed))])))
                               

(define list-length (lambda (a-list)
                      (cond
                        [(empty? a-list) 0]
                        [#t (+ 1 (list-length (cdr a-list)))])))


(define flatten
  (lambda (list-of-points)
    (cond
      [(empty? list-of-points) empty]
      [(list? (car list-of-points)) (append (flatten (car list-of-points)) (flatten (cdr list-of-points)))]
      [#t (cons (car list-of-points) (flatten (cdr list-of-points)))])))

(define hsplit (lambda (list-of-points a-line)
                 (cond
                   [#t
                    (local ((define crossed (cross-map list-of-points a-line))
                           (define packed-crossed (packed-filter-crossed crossed))
                            (define packed-points (packed-filter-points list-of-points crossed)))
                      (cond
                        [(< (list-length packed-crossed) 2) (cons (line-point-A a-line) packed-points)]
                        [#t
                         (local ((define point-max (foldr (lambda (a-point old-point)
                                                            (cond
                                                              [(> (cross-product a-point a-line) (cross-product old-point a-line)) a-point]
                                                              [#t old-point])) (car list-of-points) (cdr list-of-points))))
                           (cond
                             [#t (flatten (list (hsplit packed-points (make-line (line-point-A a-line) point-max))(hsplit packed-points (make-line point-max (line-point-B a-line)))))]))]))])))

(define find-min-x (lambda (list-of-points)
                     (foldr (lambda (a-point old-point)
                              (cond
                                [(< (point-x a-point) (point-x old-point)) a-point]
                                [#t old-point]))
                            (car points) (cdr points))))

(define find-max-x (lambda (list-of-points)
                     (foldr (lambda (a-point old-point)
                              (cond
                                [(> (point-x a-point) (point-x old-point)) a-point]
                                [#t old-point]))
                            (car points) (cdr points))))

(define quickhull (lambda (list-of-points)
                    (cond
                      [#t
                       (local ((define xmin (find-min-x list-of-points))
                               (define xmax (find-max-x list-of-points)))
                         (cond
                           [#t
                            (flatten (list (hsplit list-of-points (make-line xmin xmax)) (hsplit list-of-points (make-line xmax xmin))))]))])))

;;Test cases
(define points (list
(make-point 98 211) (make-point 239 196) (make-point 5 113) (make-point 132 63) (make-point 234 133) (make-point 28 93) (make-point 101 130) (make-point 9 76) (make-point 28 155) (make-point 151 208) (make-point 185 158) (make-point 94 163) (make-point 192 18) (make-point 188 49) (make-point 141 193) (make-point 62 129) 
(make-point 197 164) (make-point 131 161) (make-point 244 155) (make-point 57 89) (make-point 231 192) (make-point 72 203) (make-point 169 19) (make-point 26 235) (make-point 193 40) (make-point 186 169) (make-point 108 210) (make-point 155 197) (make-point 14 203) (make-point 133 36) (make-point 181 66) (make-point 114 199) 
(make-point 43 82) (make-point 210 133) (make-point 229 62) (make-point 41 245) (make-point 167 45) (make-point 76 17) (make-point 40 255) (make-point 179 117) (make-point 164 253) (make-point 110 164) (make-point 216 203) (make-point 254 103) (make-point 200 143) (make-point 206 221) (make-point 183 166) (make-point 234 202) 
(make-point 158 71) (make-point 101 233) (make-point 252 20) (make-point 141 247) (make-point 74 118) (make-point 30 68) (make-point 96 74) (make-point 17 99) (make-point 202 79) (make-point 160 30) (make-point 118 82) (make-point 221 17) (make-point 249 111) (make-point 151 116) (make-point 139 234) (make-point 147 49) 
))




(define start-time current-seconds)
(define hull-points (quickhull points))
(define end-time current-seconds)
hull-points

;;Draw out points and hull
(define draw-points (lambda (list-of-points)
                      (cond
                        [(empty? list-of-points) #t]
                        [#t (and (draw-solid-disk (make-posn (+ 20 (* 3 (point-x (car list-of-points)))) (+ 20 (* 3 (point-y (car list-of-points))))) 3 'black)
                                 (draw-points(cdr list-of-points)))])))

(define find-last-point (lambda (list-of-points)
                          (cond
                             [(= (list-length list-of-points) 1) (car list-of-points)]
                             [#t (find-last-point (cdr list-of-points))])))
                          
                        
(define draw-lines (lambda (hull-points)
                     (cond
                       [(= (list-length hull-points) 1) #t]
                       [#t (and (draw-solid-line (make-posn (+ 20 (* 3 (point-x (car hull-points)))) (+ 20 (* 3 (point-y (car hull-points)))))
                                                 (make-posn (+ 20 (* 3 (point-x (car (cdr hull-points))))) (+ 20 (* 3 (point-y (car (cdr hull-points))))))
                                                 'black)
                                (draw-lines (cdr hull-points)))])))
                     


(define draw-hull (lambda(points hull-points)
                    (and
                     (start 800 1400)
                     (draw-points points)
                     (draw-lines (cons (find-last-point hull-points) hull-points)))))

(draw-hull points hull-points)