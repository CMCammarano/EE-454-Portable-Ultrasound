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
(define points (list (make-point 6 6) (make-point 8 5) (make-point 7 3) (make-point 9 7) (make-point 4 7) (make-point 5 2) (make-point 1 5) (make-point 6 4) (make-point 3 5) (make-point 2 4) (make-point 5 4) (make-point 6 5) (make-point 4 3) (make-point 9 12) (make-point 1 11)))
(define hull-points (quickhull points))

;;Draw out points and hull
(define draw-points (lambda (list-of-points)
                      (cond
                        [(empty? list-of-points) #t]
                        [#t (and (draw-solid-disk (make-posn (* 50 (point-x (car list-of-points))) (* 50 (point-y (car list-of-points)))) 3 'black)
                                 (draw-points(cdr list-of-points)))])))

(define find-last-point (lambda (list-of-points)
                          (cond
                             [(= (list-length list-of-points) 1) (car list-of-points)]
                             [#t (find-last-point (cdr list-of-points))])))
                          
                        
(define draw-lines (lambda (hull-points)
                     (cond
                       [(= (list-length hull-points) 1) #t]
                       [#t (and (draw-solid-line (make-posn (* 50 (point-x (car hull-points))) (* 50 (point-y (car hull-points))))
                                                 (make-posn (* 50 (point-x (car (cdr hull-points)))) (* 50 (point-y (car (cdr hull-points)))))
                                                 'black)
                                (draw-lines (cdr hull-points)))])))
                     


(define draw-hull (lambda(points hull-points)
                    (and
                     (start 550 700)
                     (draw-points points)
                     (draw-lines (cons (find-last-point hull-points) hull-points)))))

(draw-hull points hull-points)