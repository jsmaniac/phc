#lang racket
(require "../subtemplate.rkt"
         phc-toolkit/untyped
         rackunit)

#|
(define-syntax (tst stx)
  (syntax-case stx ()
    [(_ tt)
     #`'#,(find-subscript-binder #'tt #f)]))

(check-false (syntax-case #'(a b) ()
               [(_ x)
                (tst x)]))

(check-equal? (syntax-parse
                  #'(a b c)
                [(_ x yᵢ)
                 (list (tst x)
                       (tst wᵢ))])
              '(#f yᵢ))

|#

(check-equal? (syntax->datum (syntax-parse #'(a b c d)
                               [(_ xⱼ zᵢ …)
                                (subtemplate foo)]))
              'foo)

#;(let ()
  (syntax-parse #'a #;(syntax-parse #'(a b c d)
                  [(_ xⱼ zᵢ …)
                   (list (subtemplate ([xⱼ wⱼ] foo [zᵢ pᵢ] …))
                         (subtemplate ([xⱼ wⱼ] foo [zᵢ pᵢ] …)))])
    [_ #;(([x1 w1] foo1 [z1 p1] [zz1 pp1])
      ([x2 w2] foo2 [z2 p2] [zz2 pp2]))
     (check free-identifier=? #'x1 #'x2)]))

(syntax-parse (syntax-parse #'(a b c d)
                  [(_ xⱼ zᵢ …)
                   (list (subtemplate ([xⱼ wⱼ] foo [zᵢ pᵢ] …))
                         (subtemplate ([xⱼ wⱼ] foo [zᵢ pᵢ] …)))])
    [(([x1 w1] foo1 [z1 p1] [zz1 pp1])
      ([x2 w2] foo2 [z2 p2] [zz2 pp2]))
     (check free-identifier=? #'x1 #'x2)
     (check free-identifier=? #'w1 #'w2)
     (check free-identifier=? #'foo1 #'foo2)
     (check free-identifier=? #'z1 #'z2)
     (check free-identifier=? #'p1 #'p2)
     (check free-identifier=? #'zz1 #'zz2)
     (check free-identifier=? #'pp1 #'pp2)

     (check free-identifier=? #'x1 #'b)
     (check free-identifier=? #'z1 #'c)
     (check free-identifier=? #'zz1 #'d)
   
     (check free-identifier=? #'x2 #'b)
     (check free-identifier=? #'z2 #'c)
     (check free-identifier=? #'zz2 #'d)

     ;; The *1 are all different:
     (check free-identifier=? #'x1 #'x1)
     (check (∘ not free-identifier=?) #'x1 #'w1)
     (check (∘ not free-identifier=?) #'x1 #'foo1)
     (check (∘ not free-identifier=?) #'x1 #'z1)
     (check (∘ not free-identifier=?) #'x1 #'p1)
     (check (∘ not free-identifier=?) #'x1 #'zz1)
     (check (∘ not free-identifier=?) #'x1 #'pp1)
   
     (check (∘ not free-identifier=?) #'w1 #'x1)
     (check free-identifier=? #'w1 #'w1)
     (check (∘ not free-identifier=?) #'w1 #'foo1)
     (check (∘ not free-identifier=?) #'w1 #'z1)
     (check (∘ not free-identifier=?) #'w1 #'p1)
     (check (∘ not free-identifier=?) #'w1 #'zz1)
     (check (∘ not free-identifier=?) #'w1 #'pp1)

     (check (∘ not free-identifier=?) #'foo1 #'x1)
     (check (∘ not free-identifier=?) #'foo1 #'w1)
     (check free-identifier=? #'foo1 #'foo1)
     (check (∘ not free-identifier=?) #'foo1 #'z1)
     (check (∘ not free-identifier=?) #'foo1 #'p1)
     (check (∘ not free-identifier=?) #'foo1 #'zz1)
     (check (∘ not free-identifier=?) #'foo1 #'pp1)

     (check (∘ not free-identifier=?) #'z1 #'x1)
     (check (∘ not free-identifier=?) #'z1 #'w1)
     (check (∘ not free-identifier=?) #'z1 #'foo1)
     (check free-identifier=? #'z1 #'z1)
     (check (∘ not free-identifier=?) #'z1 #'p1)
     (check (∘ not free-identifier=?) #'z1 #'zz1)
     (check (∘ not free-identifier=?) #'z1 #'pp1)

     (check (∘ not free-identifier=?) #'p1 #'x1)
     (check (∘ not free-identifier=?) #'p1 #'w1)
     (check (∘ not free-identifier=?) #'p1 #'foo1)
     (check (∘ not free-identifier=?) #'p1 #'z1)
     (check free-identifier=? #'p1 #'p1)
     (check (∘ not free-identifier=?) #'p1 #'zz1)
     (check (∘ not free-identifier=?) #'p1 #'pp1)

     (check (∘ not free-identifier=?) #'zz1 #'x1)
     (check (∘ not free-identifier=?) #'zz1 #'w1)
     (check (∘ not free-identifier=?) #'zz1 #'foo1)
     (check (∘ not free-identifier=?) #'zz1 #'z1)
     (check (∘ not free-identifier=?) #'zz1 #'p1)
     (check free-identifier=? #'zz1 #'zz1)
     (check (∘ not free-identifier=?) #'zz1 #'pp1)

     (check (∘ not free-identifier=?) #'pp1 #'x1)
     (check (∘ not free-identifier=?) #'pp1 #'w1)
     (check (∘ not free-identifier=?) #'pp1 #'foo1)
     (check (∘ not free-identifier=?) #'pp1 #'z1)
     (check (∘ not free-identifier=?) #'pp1 #'p1)
     (check (∘ not free-identifier=?) #'pp1 #'zz1)
     (check free-identifier=? #'pp1 #'pp1)

     ;; The *2 are all different:
     (check free-identifier=? #'x2 #'x2)
     (check (∘ not free-identifier=?) #'x2 #'w2)
     (check (∘ not free-identifier=?) #'x2 #'foo2)
     (check (∘ not free-identifier=?) #'x2 #'z2)
     (check (∘ not free-identifier=?) #'x2 #'p2)
     (check (∘ not free-identifier=?) #'x2 #'zz2)
     (check (∘ not free-identifier=?) #'x2 #'pp2)
   
     (check (∘ not free-identifier=?) #'w2 #'x2)
     (check free-identifier=? #'w2 #'w2)
     (check (∘ not free-identifier=?) #'w2 #'foo2)
     (check (∘ not free-identifier=?) #'w2 #'z2)
     (check (∘ not free-identifier=?) #'w2 #'p2)
     (check (∘ not free-identifier=?) #'w2 #'zz2)
     (check (∘ not free-identifier=?) #'w2 #'pp2)

     (check (∘ not free-identifier=?) #'foo2 #'x2)
     (check (∘ not free-identifier=?) #'foo2 #'w2)
     (check free-identifier=? #'foo2 #'foo2)
     (check (∘ not free-identifier=?) #'foo2 #'z2)
     (check (∘ not free-identifier=?) #'foo2 #'p2)
     (check (∘ not free-identifier=?) #'foo2 #'zz2)
     (check (∘ not free-identifier=?) #'foo2 #'pp2)

     (check (∘ not free-identifier=?) #'z2 #'x2)
     (check (∘ not free-identifier=?) #'z2 #'w2)
     (check (∘ not free-identifier=?) #'z2 #'foo2)
     (check free-identifier=? #'z2 #'z2)
     (check (∘ not free-identifier=?) #'z2 #'p2)
     (check (∘ not free-identifier=?) #'z2 #'zz2)
     (check (∘ not free-identifier=?) #'z2 #'pp2)

     (check (∘ not free-identifier=?) #'p2 #'x2)
     (check (∘ not free-identifier=?) #'p2 #'w2)
     (check (∘ not free-identifier=?) #'p2 #'foo2)
     (check (∘ not free-identifier=?) #'p2 #'z2)
     (check free-identifier=? #'p2 #'p2)
     (check (∘ not free-identifier=?) #'p2 #'zz2)
     (check (∘ not free-identifier=?) #'p2 #'pp2)

     (check (∘ not free-identifier=?) #'zz2 #'x2)
     (check (∘ not free-identifier=?) #'zz2 #'w2)
     (check (∘ not free-identifier=?) #'zz2 #'foo2)
     (check (∘ not free-identifier=?) #'zz2 #'z2)
     (check (∘ not free-identifier=?) #'zz2 #'p2)
     (check free-identifier=? #'zz2 #'zz2)
     (check (∘ not free-identifier=?) #'zz2 #'pp2)

     (check (∘ not free-identifier=?) #'pp2 #'x2)
     (check (∘ not free-identifier=?) #'pp2 #'w2)
     (check (∘ not free-identifier=?) #'pp2 #'foo2)
     (check (∘ not free-identifier=?) #'pp2 #'z2)
     (check (∘ not free-identifier=?) #'pp2 #'p2)
     (check (∘ not free-identifier=?) #'pp2 #'zz2)
     (check free-identifier=? #'pp2 #'pp2)])

(syntax-parse (syntax-parse #'(a b c)
                [(xᵢ …)
                 (define flob (quasisubtemplate (zᵢ …)))
                 (quasisubtemplate (yᵢ …
                                    #,flob
                                    zᵢ …))])
  [(a1 b1 c1 (a2 b2 c2) a3 b3 c3)
   (check free-identifier=? #'a2 #'a3)
   (check free-identifier=? #'b2 #'b3)
   (check free-identifier=? #'c2 #'c3)
   (check (∘ not free-identifier=?) #'a1 #'a2)
   (check (∘ not free-identifier=?) #'b1 #'b2)
   (check (∘ not free-identifier=?) #'c1 #'c2)])

(syntax-parse (syntax-parse #'(a b c)
                [(xᵢ …)
                 (quasisubtemplate (yᵢ …
                                    #,(quasisubtemplate (zᵢ …))
                                    zᵢ …))])
  [(a1 b1 c1 (a2 b2 c2) a3 b3 c3)
   (check free-identifier=? #'a2 #'a3)
   (check free-identifier=? #'b2 #'b3)
   (check free-identifier=? #'c2 #'c3)
   (check (∘ not free-identifier=?) #'a1 #'a2)
   (check (∘ not free-identifier=?) #'b1 #'b2)
   (check (∘ not free-identifier=?) #'c1 #'c2)])

(syntax-parse (syntax-parse #'(a b c)
                [(xᵢ …)
                 (define flob (syntax-parse #'d [d (quasisubtemplate (zᵢ …))]))
                 (quasisubtemplate (yᵢ …
                                    #,flob
                                    zᵢ …))])
  [(a1 b1 c1 (a2 b2 c2) a3 b3 c3)
   (check free-identifier=? #'a2 #'a3)
   (check free-identifier=? #'b2 #'b3)
   (check free-identifier=? #'c2 #'c3)
   (check (∘ not free-identifier=?) #'a1 #'a2)
   (check (∘ not free-identifier=?) #'b1 #'b2)
   (check (∘ not free-identifier=?) #'c1 #'c2)])

(syntax-parse (syntax-parse #'(a b c)
                [(xᵢ …)
                 (quasisubtemplate (yᵢ …
                                    #,(syntax-parse #'d
                                        [d (quasisubtemplate (zᵢ …))])
                                    zᵢ …))])
  [(a1 b1 c1 (a2 b2 c2) a3 b3 c3)
   (check free-identifier=? #'a2 #'a3)
   (check free-identifier=? #'b2 #'b3)
   (check free-identifier=? #'c2 #'c3)
   (check (∘ not free-identifier=?) #'a1 #'a2)
   (check (∘ not free-identifier=?) #'b1 #'b2)
   (check (∘ not free-identifier=?) #'c1 #'c2)])

(syntax-parse (syntax-parse #'(a b c)
                [(xᵢ …)
                 (quasisubtemplate (yᵢ …
                                    #,(syntax-parse #'d
                                        [d (quasisubtemplate (zᵢ …))])
                                    #,(syntax-parse #'d
                                        [d (quasisubtemplate (zᵢ …))])
                                    zᵢ …))])
  [(a1 b1 c1 (a2 b2 c2) (a3 b3 c3) a4 b4 c4)
   (check free-identifier=? #'a2 #'a3)
   (check free-identifier=? #'b2 #'b3)
   (check free-identifier=? #'c2 #'c3)
   
   (check free-identifier=? #'a3 #'a4)
   (check free-identifier=? #'b3 #'b4)
   (check free-identifier=? #'c3 #'c4)
   
   (check free-identifier=? #'a2 #'a4)
   (check free-identifier=? #'b2 #'b4)
   (check free-identifier=? #'c2 #'c4)
   
   (check (∘ not free-identifier=?) #'a1 #'a2)
   (check (∘ not free-identifier=?) #'b1 #'b2)
   (check (∘ not free-identifier=?) #'c1 #'c2)])

(syntax-parse (syntax-parse #'(a b c)
                [(xᵢ …)
                 (quasisubtemplate (yᵢ …
                                    #,(syntax-parse #'d
                                        [d (quasisubtemplate (kᵢ …))])
                                    #,(syntax-parse #'d
                                        [d (quasisubtemplate (kᵢ …))])
                                    zᵢ …))])
  [(a1 b1 c1 (a2 b2 c2) (a3 b3 c3) a4 b4 c4)
   (check free-identifier=? #'a2 #'a3)
   (check free-identifier=? #'b2 #'b3)
   (check free-identifier=? #'c2 #'c3)
   
   (check (∘ not free-identifier=?) #'a1 #'a2)
   (check (∘ not free-identifier=?) #'b1 #'b2)
   (check (∘ not free-identifier=?) #'c1 #'c2)

   (check (∘ not free-identifier=?) #'a2 #'a4)
   (check (∘ not free-identifier=?) #'b2 #'b4)
   (check (∘ not free-identifier=?) #'c2 #'c4)

   (check (∘ not free-identifier=?) #'a3 #'a4)
   (check (∘ not free-identifier=?) #'b3 #'b4)
   (check (∘ not free-identifier=?) #'c3 #'c4)])

#;(map syntax->datum
       (syntax-parse #'(a b c)
         [(xᵢ …)
          (list (syntax-parse #'(d)
                  [(pᵢ …) #`(#,(quasisubtemplate (xᵢ … pᵢ … zᵢ …))
                             #,(quasisubtemplate (xᵢ … pᵢ … zᵢ …)))])
                (syntax-parse #'(e)
                  [(pᵢ …) (quasisubtemplate (xᵢ … pᵢ … zᵢ …))]))]))

#;(syntax->datum
   (syntax-parse #'(a b c)
     [(xᵢ …)
      (quasisubtemplate (yᵢ …
                         #,(syntax-parse #'(d)
                             [(pᵢ …) (quasisubtemplate (pᵢ … zᵢ …))])
                         ;; GIVES WRONG ID (re-uses the one above, shouldn't):
                         #,(syntax-parse #'(e)
                             [(pᵢ …) (quasisubtemplate (pᵢ … zᵢ …))])
                         wᵢ …))]))

(syntax-parse (syntax-parse #'(a b c)
                [(xᵢ …)
                 (quasisubtemplate (yᵢ …
                                    #,(syntax-parse #'d
                                        [zᵢ (quasisubtemplate (zᵢ))])
                                    #,(syntax-parse #'d
                                        [zᵢ (quasisubtemplate (zᵢ))])
                                    zᵢ …))])
  [(y yy yyy (d1) (d2) z zz zzz)
   (check free-identifier=? #'d1 #'d2)
   
   (check (∘ not free-identifier=?) #'y #'yy)
   (check (∘ not free-identifier=?) #'y #'yyy)
   (check (∘ not free-identifier=?) #'y #'d1)
   (check (∘ not free-identifier=?) #'y #'d2)
   (check (∘ not free-identifier=?) #'y #'z)
   (check (∘ not free-identifier=?) #'y #'zz)
   (check (∘ not free-identifier=?) #'y #'zzz)

   (check (∘ not free-identifier=?) #'yy #'y)
   (check (∘ not free-identifier=?) #'yy #'yyy)
   (check (∘ not free-identifier=?) #'yy #'d1)
   (check (∘ not free-identifier=?) #'yy #'d2)
   (check (∘ not free-identifier=?) #'yy #'z)
   (check (∘ not free-identifier=?) #'yy #'zz)
   (check (∘ not free-identifier=?) #'yy #'zzz)

   (check (∘ not free-identifier=?) #'yyy #'y)
   (check (∘ not free-identifier=?) #'yyy #'yy)
   (check (∘ not free-identifier=?) #'yyy #'d1)
   (check (∘ not free-identifier=?) #'yyy #'d2)
   (check (∘ not free-identifier=?) #'yyy #'z)
   (check (∘ not free-identifier=?) #'yyy #'zz)
   (check (∘ not free-identifier=?) #'yyy #'zzz)

   (check (∘ not free-identifier=?) #'d1 #'y)
   (check (∘ not free-identifier=?) #'d1 #'yy)
   (check (∘ not free-identifier=?) #'d1 #'yyy)
   ;(check (∘ not free-identifier=?) #'d1 #'d2)
   (check (∘ not free-identifier=?) #'d1 #'z)
   (check (∘ not free-identifier=?) #'d1 #'zz)
   (check (∘ not free-identifier=?) #'d1 #'zzz)

   (check (∘ not free-identifier=?) #'d2 #'y)
   (check (∘ not free-identifier=?) #'d2 #'yy)
   (check (∘ not free-identifier=?) #'d2 #'yyy)
   ;(check (∘ not free-identifier=?) #'d2 #'d1)
   (check (∘ not free-identifier=?) #'d2 #'z)
   (check (∘ not free-identifier=?) #'d2 #'zz)
   (check (∘ not free-identifier=?) #'d2 #'zzz)

   (check (∘ not free-identifier=?) #'z #'y)
   (check (∘ not free-identifier=?) #'z #'yy)
   (check (∘ not free-identifier=?) #'z #'yyy)
   (check (∘ not free-identifier=?) #'z #'d1)
   (check (∘ not free-identifier=?) #'z #'d2)
   (check (∘ not free-identifier=?) #'z #'zz)
   (check (∘ not free-identifier=?) #'z #'zzz)

   (check (∘ not free-identifier=?) #'zz #'y)
   (check (∘ not free-identifier=?) #'zz #'yy)
   (check (∘ not free-identifier=?) #'zz #'yyy)
   (check (∘ not free-identifier=?) #'zz #'d1)
   (check (∘ not free-identifier=?) #'zz #'d2)
   (check (∘ not free-identifier=?) #'zz #'z)
   (check (∘ not free-identifier=?) #'zz #'zzz)

   (check (∘ not free-identifier=?) #'zzz #'y)
   (check (∘ not free-identifier=?) #'zzz #'yy)
   (check (∘ not free-identifier=?) #'zzz #'yyy)
   (check (∘ not free-identifier=?) #'zzz #'d1)
   (check (∘ not free-identifier=?) #'zzz #'d2)
   (check (∘ not free-identifier=?) #'zzz #'z)
   (check (∘ not free-identifier=?) #'zzz #'zz)])

(syntax-parse (syntax-parse #'(a b c d)
                [(_ xⱼ zᵢ …)
                 (list (subtemplate ([xⱼ wⱼ] foo [zᵢ pᵢ] …))
                       (subtemplate ([xⱼ wⱼ] foo [zᵢ pᵢ] …)))])
  [(([x1 w1] foo1 [z1 p1] [zz1 pp1])
    ([x2 w2] foo2 [z2 p2] [zz2 pp2]))
   (check free-identifier=? #'x1 #'b)
   (check free-identifier=? #'foo1 #'foo)
   (check free-identifier=? #'z1 #'c)
   (check free-identifier=? #'zz1 #'d)
   
   (check free-identifier=? #'x2 #'b)
   (check free-identifier=? #'foo2 #'foo)
   (check free-identifier=? #'z2 #'c)
   (check free-identifier=? #'zz2 #'d)

   (check free-identifier=? #'x1 #'x2)
   (check free-identifier=? #'w1 #'w2)
   (check free-identifier=? #'foo1 #'foo2)
   (check free-identifier=? #'z1 #'z2)
   (check free-identifier=? #'p1 #'p2)
   (check free-identifier=? #'zz1 #'zz2)
   (check free-identifier=? #'pp1 #'pp2)
   
   (check (∘ not free-identifier=?) #'x1 #'w1)
   (check (∘ not free-identifier=?) #'x1 #'p1)
   (check (∘ not free-identifier=?) #'x1 #'pp1)
   (check (∘ not free-identifier=?) #'w1 #'x1)
   (check (∘ not free-identifier=?) #'w1 #'p1)
   (check (∘ not free-identifier=?) #'w1 #'pp1)
   (check (∘ not free-identifier=?) #'p1 #'x1)
   (check (∘ not free-identifier=?) #'p1 #'w1)
   (check (∘ not free-identifier=?) #'p1 #'pp1)])

(syntax-parse (syntax-parse #'()
                [()
                 (syntax-parse #'(a b)
                   [(zᵢ …)
                    (list (syntax-parse #'(e)
                            [(xⱼ) (subtemplate ([xⱼ wⱼ] foo [zᵢ pᵢ] …))])
                          (syntax-parse #'(e) ;; TODO: same test with f
                            [(xⱼ) (subtemplate ([xⱼ wⱼ] foo [zᵢ pᵢ] …))]))])])
  [(([x1 w1] foo1 [z1 p1] [zz1 pp1])
    ([x2 w2] foo2 [z2 p2] [zz2 pp2]))
   (check free-identifier=? #'x1 #'e)
   (check free-identifier=? #'foo1 #'foo)
   (check free-identifier=? #'z1 #'a)
   (check free-identifier=? #'zz1 #'b)
   
   (check free-identifier=? #'x2 #'e)
   (check free-identifier=? #'foo2 #'foo)
   (check free-identifier=? #'z2 #'a)
   (check free-identifier=? #'zz2 #'b)

   (check free-identifier=? #'x1 #'x2)
   (check (∘ not free-identifier=?) #'w1 #'w2) ;; yes above, no here.
   (check free-identifier=? #'foo1 #'foo2)
   (check free-identifier=? #'z1 #'z2)
   (check free-identifier=? #'p1 #'p2)
   (check free-identifier=? #'zz1 #'zz2)
   (check free-identifier=? #'pp1 #'pp2)
   
   (check (∘ not free-identifier=?) #'x1 #'w1)
   (check (∘ not free-identifier=?) #'x1 #'p1)
   (check (∘ not free-identifier=?) #'x1 #'pp1)
   (check (∘ not free-identifier=?) #'w1 #'x1)
   (check (∘ not free-identifier=?) #'w1 #'p1)
   (check (∘ not free-identifier=?) #'w1 #'pp1)
   (check (∘ not free-identifier=?) #'p1 #'x1)
   (check (∘ not free-identifier=?) #'p1 #'w1)
   (check (∘ not free-identifier=?) #'p1 #'pp1)])

(syntax-parse (syntax-parse #'()
                [()
                 (syntax-parse #'(a b)
                   [(zᵢ …)
                    (list (syntax-parse #'(e)
                            [(xⱼ) (subtemplate ([xⱼ wⱼ] foo [zᵢ pᵢ] …))])
                          (syntax-parse #'(f) ;; above: was e, not f
                            [(xⱼ) (subtemplate ([xⱼ wⱼ] foo [zᵢ pᵢ] …))]))])])
  [(([x1 w1] foo1 [z1 p1] [zz1 pp1])
    ([x2 w2] foo2 [z2 p2] [zz2 pp2]))
   (check free-identifier=? #'x1 #'e)
   (check free-identifier=? #'foo1 #'foo)
   (check free-identifier=? #'z1 #'a)
   (check free-identifier=? #'zz1 #'b)
   
   (check free-identifier=? #'x2 #'f) ;; above: was e, not f
   (check free-identifier=? #'foo2 #'foo)
   (check free-identifier=? #'z2 #'a)
   (check free-identifier=? #'zz2 #'b)

   (check (∘ not free-identifier=?) #'x1 #'x2) ;; yes above, no here.
   (check (∘ not free-identifier=?) #'w1 #'w2) ;; yes above above, no here.
   (check free-identifier=? #'foo1 #'foo2)
   (check free-identifier=? #'z1 #'z2)
   (check free-identifier=? #'p1 #'p2)
   (check free-identifier=? #'zz1 #'zz2)
   (check free-identifier=? #'pp1 #'pp2)
   
   (check (∘ not free-identifier=?) #'x1 #'w1)
   (check (∘ not free-identifier=?) #'x1 #'p1)
   (check (∘ not free-identifier=?) #'x1 #'pp1)
   (check (∘ not free-identifier=?) #'w1 #'x1)
   (check (∘ not free-identifier=?) #'w1 #'p1)
   (check (∘ not free-identifier=?) #'w1 #'pp1)
   (check (∘ not free-identifier=?) #'p1 #'x1)
   (check (∘ not free-identifier=?) #'p1 #'w1)
   (check (∘ not free-identifier=?) #'p1 #'pp1)])

(syntax-parse (syntax-parse #'()
                [()
                 (syntax-parse #'(a b)
                   [(zᵢ …)
                    (list (syntax-parse #'(c d)
                            [(xᵢ …)
                             (subtemplate ([xᵢ wᵢ] … foo [zᵢ pᵢ] …))])
                          (syntax-parse #'(cc dd)
                            [(xᵢ …)
                             (subtemplate ([xᵢ wᵢ] … foo [zᵢ pᵢ] …))]))])])
  [(([x1 w1] [xx1 ww1] foo1 [z1 p1] [zz1 pp1])
    ([x2 w2] [xx2 ww2] foo2 [z2 p2] [zz2 pp2]))
   (check free-identifier=? #'x1 #'c)
   (check free-identifier=? #'xx1 #'d)
   (check free-identifier=? #'foo1 #'foo)
   (check free-identifier=? #'z1 #'a)
   (check free-identifier=? #'zz1 #'b)
   
   (check free-identifier=? #'x2 #'cc)
   (check free-identifier=? #'xx2 #'dd)
   (check free-identifier=? #'foo2 #'foo)
   (check free-identifier=? #'z2 #'a)
   (check free-identifier=? #'zz2 #'b)

   (check (∘ not free-identifier=?) #'x1 #'x2)
   (check (∘ not free-identifier=?) #'xx1 #'xx2)
   (check free-identifier=? #'w1 #'w2)
   (check free-identifier=? #'ww1 #'ww2)
   (check free-identifier=? #'foo1 #'foo2)
   (check free-identifier=? #'z1 #'z2)
   (check free-identifier=? #'p1 #'p2)
   (check free-identifier=? #'zz1 #'zz2)
   (check free-identifier=? #'pp1 #'pp2)
   
   (check (∘ not free-identifier=?) #'x1 #'xx1)
   (check (∘ not free-identifier=?) #'x1 #'w1)
   (check (∘ not free-identifier=?) #'x1 #'p1)
   (check (∘ not free-identifier=?) #'x1 #'pp1)
   (check (∘ not free-identifier=?) #'xx1 #'x1)
   (check (∘ not free-identifier=?) #'xx1 #'w1)
   (check (∘ not free-identifier=?) #'xx1 #'p1)
   (check (∘ not free-identifier=?) #'xx1 #'pp1)
   (check (∘ not free-identifier=?) #'w1 #'xx1)
   (check (∘ not free-identifier=?) #'w1 #'x1)
   (check (∘ not free-identifier=?) #'w1 #'p1)
   (check (∘ not free-identifier=?) #'w1 #'pp1)
   (check (∘ not free-identifier=?) #'p1 #'xx1)
   (check (∘ not free-identifier=?) #'p1 #'x1)
   (check (∘ not free-identifier=?) #'p1 #'w1)
   (check (∘ not free-identifier=?) #'p1 #'pp1)])

(check-exn #px"incompatible ellipsis match counts for template"
           (λ ()
             (syntax-parse #'()
               [()
                (syntax-parse #'(a b)
                  [(zᵢ …)
                   (list (syntax-parse #'(c) ;; one here, two above and below
                           [(xᵢ …)
                            (subtemplate ([xᵢ wᵢ] … foo [zᵢ pᵢ] …))])
                         (syntax-parse #'(cc dd)
                           [(xᵢ …)
                            (subtemplate ([xᵢ wᵢ] … foo [zᵢ pᵢ] …))]))])])))

;; Test for arrows, with two maximal candidates tᵢ and zᵢ :
(syntax-parse (syntax-parse #'()
                [()
                 (syntax-parse #'([a b] [aa bb])
                   [([tᵢ …] [zᵢ …])
                    (list (syntax-parse #'(c d)
                            [(xᵢ …)
                             (subtemplate ([xᵢ wᵢ] … tᵢ … foo [zᵢ pᵢ] …))])
                          (syntax-parse #'(cc dd)
                            [(xᵢ …)
                             (subtemplate ([xᵢ wᵢ] … tᵢ … foo [zᵢ pᵢ] …))]))])])
  [_ 'TODO])