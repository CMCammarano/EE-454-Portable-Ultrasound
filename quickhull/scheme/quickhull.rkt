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
;(define points (list (make-point 6 6) (make-point 8 5) (make-point 7 3) (make-point 9 7) (make-point 4 7) (make-point 5 2) (make-point 1 5) (make-point 6 4) (make-point 3 5) (make-point 2 4) (make-point 5 4) (make-point 6 5) (make-point 4 3) (make-point 9 12) (make-point 1 11)))
(define points (list
(make-point 245 93) (make-point 8 250) (make-point 250 96) (make-point 75 99) (make-point 44 104) (make-point 129 113) (make-point 205 135) (make-point 21 118) (make-point 11 20) (make-point 24 143) (make-point 231 186) (make-point 171 68) (make-point 23 41) (make-point 102 156) (make-point 25 18) (make-point 131 126) 
(make-point 29 16) (make-point 56 236) (make-point 132 195) (make-point 233 91) (make-point 96 155) (make-point 137 69) (make-point 31 46) (make-point 166 165) (make-point 145 208) (make-point 168 120) (make-point 93 33) (make-point 195 220) (make-point 198 32) (make-point 227 122) (make-point 125 33) (make-point 80 219) 
(make-point 50 27) (make-point 173 124) (make-point 165 143) (make-point 75 73) (make-point 228 119) (make-point 252 144) (make-point 136 249) (make-point 99 105) (make-point 162 168) (make-point 65 198) (make-point 139 107) (make-point 136 100) (make-point 19 227) (make-point 122 49) (make-point 75 81) (make-point 99 162) 
(make-point 91 182) (make-point 52 112) (make-point 222 101) (make-point 42 255) (make-point 198 180) (make-point 138 184) (make-point 188 234) (make-point 39 240) (make-point 184 107) (make-point 218 70) (make-point 89 220) (make-point 250 225) (make-point 214 225) (make-point 213 253) (make-point 101 34) (make-point 54 30) 
(make-point 101 79) (make-point 33 132) (make-point 54 29) (make-point 0 244) (make-point 195 90) (make-point 122 216) (make-point 126 6) (make-point 235 174) (make-point 180 44) (make-point 80 209) (make-point 120 80) (make-point 81 202) (make-point 77 110) (make-point 66 203) (make-point 9 50) (make-point 164 14) 
(make-point 80 163) (make-point 224 232) (make-point 241 22) (make-point 4 134) (make-point 130 73) (make-point 80 70) (make-point 107 207) (make-point 166 46) (make-point 81 244) (make-point 41 239) (make-point 55 59) (make-point 227 75) (make-point 1 218) (make-point 162 63) (make-point 53 137) (make-point 184 213) 
(make-point 176 64) (make-point 112 227) (make-point 44 248) (make-point 182 216) (make-point 78 149) (make-point 13 180) (make-point 52 9) (make-point 69 166) (make-point 75 168) (make-point 27 63) (make-point 211 196) (make-point 25 142) (make-point 74 131) (make-point 224 109) (make-point 42 33) (make-point 101 35) 
(make-point 51 239) (make-point 47 207) (make-point 73 61) (make-point 190 109) (make-point 153 240) (make-point 87 235) (make-point 230 78) (make-point 247 234) (make-point 117 47) (make-point 226 201) (make-point 74 7) (make-point 73 28) (make-point 76 69) (make-point 45 118) (make-point 243 29) (make-point 141 19) 
(make-point 147 207) (make-point 7 225) (make-point 110 23) (make-point 132 245) (make-point 196 23) (make-point 117 48) (make-point 77 130) (make-point 56 217) (make-point 198 45) (make-point 45 191) (make-point 30 90) (make-point 18 30) (make-point 249 145) (make-point 251 158) (make-point 255 43) (make-point 162 189) 
(make-point 95 125) (make-point 124 228) (make-point 216 199) (make-point 215 10) (make-point 218 170) (make-point 128 62) (make-point 230 27) (make-point 162 185) (make-point 87 58) (make-point 80 90) (make-point 209 123) (make-point 7 195) (make-point 166 88) (make-point 8 36) (make-point 87 80) (make-point 118 54) 
(make-point 98 106) (make-point 53 65) (make-point 247 94) (make-point 254 109) (make-point 117 180) (make-point 210 128) (make-point 0 46) (make-point 14 37) (make-point 1 148) (make-point 248 198) (make-point 144 66) (make-point 84 174) (make-point 74 86) (make-point 64 122) (make-point 194 39) (make-point 158 174) 
(make-point 218 154) (make-point 167 42) (make-point 138 124) (make-point 156 22) (make-point 81 32) (make-point 136 101) (make-point 72 249) (make-point 139 56) (make-point 13 38) (make-point 26 11) (make-point 70 51) (make-point 154 192) (make-point 253 47) (make-point 46 171) (make-point 163 235) (make-point 47 141) 
(make-point 69 46) (make-point 58 136) (make-point 38 243) (make-point 10 103) (make-point 51 30) (make-point 169 141) (make-point 35 232) (make-point 250 134) (make-point 210 175) (make-point 112 248) (make-point 159 160) (make-point 160 146) (make-point 75 20) (make-point 157 225) (make-point 44 149) (make-point 229 90) 
(make-point 156 219) (make-point 20 179) (make-point 50 50) (make-point 81 47) (make-point 217 49) (make-point 58 242) (make-point 133 248) (make-point 79 127) (make-point 214 191) (make-point 70 40) (make-point 99 104) (make-point 145 140) (make-point 195 149) (make-point 126 34) (make-point 115 15) (make-point 1 182) 
(make-point 43 180) (make-point 94 244) (make-point 151 98) (make-point 60 12) (make-point 139 164) (make-point 74 4) (make-point 70 156) (make-point 142 163) (make-point 9 5) (make-point 242 220) (make-point 77 107) (make-point 29 253) (make-point 54 36) (make-point 130 175) (make-point 85 105) (make-point 107 21) 
(make-point 99 212) (make-point 181 39) (make-point 207 243) (make-point 52 29) (make-point 177 43) (make-point 186 217) (make-point 12 95) (make-point 175 140) (make-point 36 120) (make-point 85 45) (make-point 59 204) (make-point 206 136) (make-point 171 99) (make-point 153 192) (make-point 85 101) (make-point 90 253) 
))
(define hull-points (quickhull points))

(quickhull hull-points)

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