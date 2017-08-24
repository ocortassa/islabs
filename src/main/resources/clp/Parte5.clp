(set-current-module MAIN) (focus MAIN))

(defrule ENV::move-down-ok 
   (declare (salience 20))    
  ?f2<- (MAIN::status (time ?i)) 
        (MAIN::exec (time ?i) (action  go))
  ?f1<- (ENV::agentstatus (pos-r ?r) (pos-c ?c)(direction down))
        (ENV::cell (pos-r ?r1) (pos-c ?c) (contains empty|debris))
        (test (= ?r1 (+ ?r 1)))
        => (modify  ?f1 (pos-r (+ ?r 1)) (time (+ ?i 1)))
           (modify ?f2 (time (+ ?i 1))))

(defrule ENV::move-down-exit     
   (declare (salience 20)) 
  ?f2<- (MAIN::status (time ?i)) 
        (MAIN::exec (time ?i) (action  go))
  ?f1<- (ENV::agentstatus (pos-r ?r) (pos-c ?c)(direction down))
        (ENV::cell (pos-r ?r1) (pos-c ?c) (contains exit))
        (test (= ?r1 (+ ?r 1)))
        => (modify  ?f1 (pos-r (+ ?r 1)) (time (+ ?i 1)))
           (modify  ?f2 (time (+ ?i 1)) (result exit))
           (set-current-module MAIN) (focus MAIN))

(defrule ENV::move-down-bump 
   (declare (salience 20))    
  ?f2<- (MAIN::status (time ?i)) 
        (MAIN::exec (time ?i) (action  go))
  ?f1<- (ENV::agentstatus (pos-r ?r) (pos-c ?c)(direction down))
        (ENV::cell (pos-r ?r1) (pos-c ?c) (contains wall|entry))
        (test (= ?r1 (+ ?r 1)))
        => (modify  ?f1 (time (+ ?i 1)))
           (modify ?f2 (time (+ ?i 1)))
           (assert (MAIN::percepts (time (+ ?i 1))(pos-r ?r) (pos-c ?c) (direction down)
                             (perc1 bump) (perc2 unknown) (perc3 unknown) (cry unknown)))
           (set-current-module MAIN) (focus MAIN))




(defrule ENV::move-up-bump     
  (declare (salience 20)) 
  ?f2<- (MAIN::status (time ?i)) 
        (MAIN::exec (time ?i) (action  go))
  ?f1<- (ENV::agentstatus (pos-r ?r) (pos-c ?c) (direction up))
        (ENV::cell (pos-r ?r1) (pos-c ?c) (contains wall|entry))
        (test (= ?r1 (- ?r 1)))        => 
           (modify  ?f1 (time (+ ?i 1)))
           (modify  ?f2 (time (+ ?i 1)))
           (assert (MAIN::percepts (time (+ ?i 1))(pos-r ?r) (pos-c ?c) (direction up)
                             (perc1 bump) (perc2 unknown) (perc3 unknown)(cry unknown)))
           (set-current-module MAIN) (focus MAIN))


(defrule ENV::move-up-ok     
   (declare (salience 20)) 
  ?f2<- (MAIN::status (time ?i)) 
        (MAIN::exec (time ?i) (action  go))
  ?f1<- (ENV::agentstatus (pos-r ?r) (pos-c ?c)(direction up))
        (ENV::cell (pos-r ?r1) (pos-c ?c) (contains empty|debris))
        (test (= ?r1 (- ?r 1)))
        => (modify  ?f1 (pos-r (- ?r 1)) (time (+ ?i 1)))
           (modify  ?f2 (time (+ ?i 1))))
           
(defrule ENV::move-up-exit     
   (declare (salience 20)) 
  ?f2<- (MAIN::status (time ?i)) 
        (MAIN::exec (time ?i) (action  go))
  ?f1<- (ENV::agentstatus (pos-r ?r) (pos-c ?c)(direction up))
        (ENV::cell (pos-r ?r1) (pos-c ?c) (contains exit))
        (test (= ?r1 (- ?r 1)))
        => (modify  ?f1 (pos-r (- ?r 1)) (time (+ ?i 1)))
           (modify  ?f2 (time (+ ?i 1)) (result exit))
           (set-current-module MAIN) (focus MAIN))


(defrule ENV::move-left-ok 
   (declare (salience 20))     
   ?f2<- (MAIN::status (time ?i)) 
        (MAIN::exec (time ?i) (action  go))
  ?f1<- (ENV::agentstatus (pos-r ?r) (pos-c ?c) (direction left)) 
        (ENV::cell (pos-r ?r) (pos-c ?c1) (contains empty|debris))
        (test (= ?c1 (- ?c 1)))
        => (modify  ?f1 (pos-c (- ?c 1)) (time (+ ?i 1)))
           (modify ?f2 (time (+ ?i 1))))


(defrule ENV::move-left-exit     
   (declare (salience 20)) 
  ?f2<- (MAIN::status (time ?i)) 
        (MAIN::exec (time ?i) (action  go))
  ?f1<- (ENV::agentstatus (pos-r ?r) (pos-c ?c)(direction left))
        (ENV::cell (pos-r ?r) (pos-c ?c1) (contains exit))
        (test (= ?c1 (- ?c 1)))
        => (modify  ?f1 (pos-c (- ?c 1)) (time (+ ?i 1)))
           (modify  ?f2 (time (+ ?i 1)) (result exit))
           (set-current-module MAIN) (focus MAIN))


(defrule ENV::move-left-bump 
   (declare (salience 20))     
   ?f2<- (MAIN::status (time ?i)) 
        (MAIN::exec (time ?i) (action  go))
  ?f1<- (ENV::agentstatus (pos-r ?r) (pos-c ?c) (direction left))
        (ENV::cell (pos-r ?r) (pos-c ?c1) (contains wall|entry))
        (test (= ?c1 (- ?c 1)))
        => (modify ?f1 (time (+ ?i 1)))
           (modify ?f2 (time (+ ?i 1)))
           (assert (MAIN::percepts (time (+ ?i 1))(pos-r ?r) (pos-c ?c) (direction left)
                             (perc1 bump) (perc2 unknown) (perc3 unknown)(cry unknown)))
           (set-current-module MAIN) (focus MAIN))


(defrule ENV::move-right-ok
   (declare (salience 20))      
  ?f2<- (MAIN::status (time ?i)) 
        (MAIN::exec (time ?i) (action  go))
  ?f1<- (ENV::agentstatus (pos-r ?r) (pos-c ?c) (direction right))
        (ENV::cell (pos-r ?r) (pos-c ?c1) (contains empty|debris))
        (test (= ?c1 (+ ?c 1)))
        => (modify  ?f1 (pos-c (+ ?c 1))(time (+ ?i 1)))
           (modify ?f2 (time (+ ?i 1))))

(defrule ENV::move-right-exit     
   (declare (salience 20)) 
  ?f2<- (MAIN::status (time ?i)) 
        (MAIN::exec (time ?i) (action  go))
  ?f1<- (ENV::agentstatus (pos-r ?r) (pos-c ?c)(direction right))
        (ENV::cell (pos-r ?r) (pos-c ?c1) (contains exit))
        (test (= ?c1 (+ ?c 1)))
        => (modify  ?f1 (pos-c (+ ?c 1)) (time (+ ?i 1)))
           (modify  ?f2 (time (+ ?i 1)) (result exit))
           (set-current-module MAIN) (focus MAIN))

(defrule ENV::move-right-bump
   (declare (salience 20))      
  ?f2<- (MAIN::status (time ?i)) 
        (MAIN::exec (time ?i) (action  go))
  ?f1<- (ENV::agentstatus (pos-r ?r) (pos-c ?c) (direction right))
        (ENV::cell (pos-r ?r) (pos-c ?c1) (contains wall|entry))
        (test (= ?c1 (+ ?c 1)))
        => (modify ?f1 (time (+ ?i 1)))
           (modify ?f2 (time (+ ?i 1)))
           (assert (MAIN::percepts (time (+ ?i 1))(pos-r ?r) (pos-c ?c) (direction right)
                             (perc1 bump) (perc2 unknown) (perc3 unknown) (cry unknown)))
           (set-current-module MAIN) (focus MAIN))


(defrule ENV::turnleft1
   (declare (salience 20))      
  ?f2<- (MAIN::status (time ?i)) 
        (MAIN::exec (time ?i) (action  turnleft))
  ?f1<- (ENV::agentstatus (direction left))
        => (modify  ?f1 (direction down) (time (+ ?i 1)))
           (modify ?f2 (time (+ ?i 1))))

(defrule ENV::turnleft2
   (declare (salience 20))      
  ?f2<- (MAIN::status (time ?i)) 
        (MAIN::exec (time ?i) (action  turnleft))
  ?f1<- (ENV::agentstatus (direction up))
        => (modify  ?f1 (direction left) (time (+ ?i 1)))
           (modify ?f2 (time (+ ?i 1))))

(defrule ENV::turnleft3
   (declare (salience 20))      
  ?f2<- (MAIN::status (time ?i)) 
        (MAIN::exec (time ?i) (action  turnleft))
  ?f1<- (ENV::agentstatus (direction right))
        => (modify  ?f1 (direction up) (time (+ ?i 1)))
           (modify ?f2 (time (+ ?i 1))))

(defrule ENV::turnleft4
   (declare (salience 20))      
  ?f2<- (MAIN::status (time ?i)) 
        (MAIN::exec (time ?i) (action  turnleft))
  ?f1<- (ENV::agentstatus (direction down))
        => (modify  ?f1 (direction right) (time (+ ?i 1)))
           (modify ?f2 (time (+ ?i 1))))

(defrule ENV::turnright1
   (declare (salience 20))      
  ?f2<- (MAIN::status (time ?i)) 
        (MAIN::exec (time ?i) (action  turnright))
  ?f1<- (ENV::agentstatus (direction left))
        => (modify  ?f1 (direction up) (time (+ ?i 1)))
           (modify ?f2 (time (+ ?i 1))))

(defrule ENV::turnright2
   (declare (salience 20))      
  ?f2<- (MAIN::status (time ?i)) 
        (MAIN::exec (time ?i) (action  turnright))
  ?f1<- (ENV::agentstatus (direction down))
        => (modify  ?f1 (direction left) (time (+ ?i 1)))
           (modify ?f2 (time (+ ?i 1))))

(defrule ENV::turnright3
   (declare (salience 20))      
  ?f2<- (MAIN::status (time ?i)) 
        (MAIN::exec (time ?i) (action  turnright))
  ?f1<- (ENV::agentstatus (direction right))
        => (modify  ?f1 (direction down) (time (+ ?i 1)))
           (modify ?f2 (time (+ ?i 1))))

(defrule ENV::turnright4
   (declare (salience 20))      
  ?f2<- (MAIN::status (time ?i)) 
        (MAIN::exec (time ?i) (action  turnright))
  ?f1<- (ENV::agentstatus (direction up))
        => (modify  ?f1 (direction right) (time (+ ?i 1)))
           (modify ?f2 (time (+ ?i 1))))


(defrule ENV::dig-OK1
   (declare (salience 20))      
        (MAIN::status (time ?i)) 
        (MAIN::exec (time ?i) (action  dig))
        (not (ENV::OK dig ?i))
        (ENV::agentstatus (pos-r ?r) (pos-c ?c)) 
        (ENV::cell (pos-r ?r) (pos-c ?c) (contains debris))
  ?f1<- (ENV::debriscontent (pos-r ?r) (pos-c ?c) (person ?p&~no))
        => (assert (MAIN::perc-dig (time (+ ?i 1)) (pos-r ?r) (pos-c ?c) (person yes)))
           (modify ?f1 (digged yes))
           (assert (ENV::OK dig ?i)))

(defrule ENV::dig-OK2
   (declare (salience 20))      
        (MAIN::status (time ?i)) 
        (MAIN::exec (time ?i) (action  dig))
        (not (ENV::OK dig ?i))
        (ENV::agentstatus (pos-r ?r) (pos-c ?c)) 
        (ENV::cell (pos-r ?r) (pos-c ?c) (contains debris))
  ?f1<- (ENV::debriscontent (pos-r ?r) (pos-c ?c) (person no))
        => (assert (MAIN::perc-dig (time (+ ?i 1)) (pos-r ?r) (pos-c ?c) (person no)))
           (modify ?f1 (digged yes))
           (assert (ENV::OK dig ?i)))

(defrule ENV::dig-KO
   (declare (salience 20))      
        (MAIN::status (time ?i)) 
        (MAIN::exec (time ?i) (action  dig))
        (ENV::agentstatus (pos-r ?r) (pos-c ?c)) 
        (ENV::cell (pos-r ?r) (pos-c ?c) (contains ?d&~debris))
        => (assert (MAIN::perc-dig (time (+ ?i 1)) (pos-r ?r) (pos-c ?c) (person fail)))
           (assert (ENV::KO dig ?i)))

(defrule ENV::grasp-OK
   (declare (salience 20))      
        (MAIN::status (time ?i)) 
        (MAIN::exec (time ?i) (action  grasp))
        (not (ENV::OK grasp ?i))
  ?f2<- (ENV::agentstatus (pos-r ?r) (pos-c ?c)(load no))
        (ENV::cell (pos-r ?r) (pos-c ?c) (contains debris))
  ?f1<- (ENV::debriscontent (pos-r ?r) (pos-c ?c) (person ?p&~no) (digged yes))
     => (assert (MAIN::perc-grasp (time (+ ?i 1)) (pos-r ?r) (pos-c ?c) (person ?p)))
        (modify ?f1 (person no))
        (modify ?f2 (load ?p))
        (assert (ENV::OK grasp ?i)))



(defrule ENV::grasp-KO
   (declare (salience 19))      
        (MAIN::status (time ?i)) 
        (MAIN::exec (time ?i) (action  grasp))
        (ENV::agentstatus (pos-r ?r) (pos-c ?c) (direction ?d) (time ?i))
        (not (ENV::OK grasp ?i))
         => 
           (assert (MAIN::perc-grasp (time (+ ?i 1)) (pos-r ?r) (pos-c ?c) (person fail)))
           (assert (ENV::KO grasp ?i)))

(defrule ENV::close-OK
   (declare (salience 18))      
  ?f2<- (MAIN::status (time ?i)) 
        (MAIN::exec (time ?i) (action  ?a&grasp|dig))
  ?f1<- (ENV::agentstatus (time ?i))
  ?f3<- (OK ?a ?i)
         => (modify ?f1 (time (+ ?i 1)))
            (modify ?f2 (time (+ ?i 1)))
            (retract ?f3))

(defrule ENV::close-KO
   (declare (salience 18))      
  ?f2<- (MAIN::status (time ?i)) 
        (MAIN::exec (time ?i) (action ?a&grasp|dig))
  ?f1<- (ENV::agentstatus (pos-r ?r) (pos-c ?c) (time ?i))
  ?f3<- (KO ?a ?i)
         => (modify ?f1 (time (+ ?i 1)))
            (modify ?f2 (time (+ ?i 1)))
            (retract ?f3))

(defrule ENV::percept-cry-unknown 
(declare (salience 8))
     (ENV::agentstatus (pos-r ?r) (pos-c ?c) (time ?t))
      (ENV::cell (pos-r ?r) (pos-c ?c) (contains exit))
  ;   (ENV::cell (pos-r ?r) (pos-c ?c) (contains ?x&entry|exit))
     => (assert (MAIN::percepts (time ?t)(pos-r ?r) (pos-c ?c) (cry unknown)))
        (assert (ENV::cry done ?t)))

(defrule ENV::percept-cry-yes
(declare (salience 8))
     (ENV::agentstatus (pos-r ?r) (pos-c ?c) (time ?t))
    ; (ENV::cell (pos-r ?r) (pos-c ?c) (contains ?x&~entry&~exit))
    (ENV::cell (pos-r ?r) (pos-c ?c) (contains ~exit))
    (or (and (ENV::cell (pos-r ?r) (pos-c ?c) (contains debris))
              (ENV::debriscontent (pos-r ?r) (pos-c ?c) (person ~no)))
         (and (ENV::cell (pos-r ?r1) (pos-c ?c) (contains debris))
              (test (= ?r1 (+ ?r 1)))
              (ENV::debriscontent (pos-r ?r1) (pos-c ?c) (person ~no)))
         (and (ENV::cell (pos-r ?r2) (pos-c ?c) (contains debris))
              (test (= ?r2 (- ?r 1)))
              (ENV::debriscontent (pos-r ?r2) (pos-c ?c) (person ~no)))
         (and (ENV::cell (pos-r ?r) (pos-c ?c1) (contains debris))
              (test (= ?c1 (+ ?c 1)))
              (ENV::debriscontent (pos-r ?r) (pos-c ?c1) (person ~no)))
         (and (ENV::cell (pos-r ?r) (pos-c ?c2) (contains debris))
              (test (= ?c2 (- ?c 1)))
              (ENV::debriscontent (pos-r ?r) (pos-c ?c2) (person ~no))))
     => (assert (MAIN::percepts (time ?t)(pos-r ?r) (pos-c ?c) (cry yes)))
        (assert (ENV::cry done ?t)))


(defrule ENV::percept-cry-no
(declare (salience 7))
     (ENV::agentstatus (pos-r ?r) (pos-c ?c) (time ?t))
     ;(ENV::cell (pos-r ?r) (pos-c ?c) (contains ?x&~entry&~exit))
     (ENV::cell (pos-r ?r) (pos-c ?c) (contains ~exit))
     (not (ENV::cry done ?t))
     => (assert (MAIN::percepts (time ?t)(pos-r ?r) (pos-c ?c) (cry no)))
        (assert (ENV::cry done ?t)))


(defrule ENV::percept-move-down1
(declare (salience 5))
       (ENV::agentstatus (pos-r ?r) (pos-c ?c) (time ?t)(direction down))
       (ENV::cell (pos-r ?r1) (pos-c ?c) (contains ?x&~empty&~debris))
       (test (= ?r1 (+ ?r 1)))
 ?f <- (MAIN::percepts (time ?t)(pos-r ?r) (pos-c ?c))
 ?f1<- (ENV::cry done ?t)
     => (retract ?f1)
        (modify ?f (direction down) (perc1 ?x) (perc2 unknown) (perc3 unknown))
        (set-current-module MAIN) (focus MAIN))

(defrule ENV::percept-move-down2
(declare (salience 5))
        (ENV::agentstatus (pos-r ?r) (pos-c ?c) (time ?t)(direction down))
        (ENV::cell (pos-r ?r1) (pos-c ?c) (contains ?x&empty|debris))
        (test (= ?r1 (+ ?r 1)))
        (ENV::cell (pos-r ?r2) (pos-c ?c) (contains ?y&~empty&~debris))
        (test (= ?r2 (+ ?r 2)))
 ?f <- (MAIN::percepts (time ?t)(pos-r ?r) (pos-c ?c))
 ?f1<- (ENV::cry done ?t)
     => (retract ?f1)
        (modify ?f  (direction down) (perc1 ?x) (perc2 ?y) (perc3 unknown))
        (set-current-module MAIN) (focus MAIN))

(defrule ENV::percept-move-down3
(declare (salience 5))
       (ENV::agentstatus (pos-r ?r) (pos-c ?c) (time ?t)(direction down))
       (ENV::cell (pos-r ?r1) (pos-c ?c) (contains ?x&empty|debris))
       (test (= ?r1 (+ ?r 1)))
       (ENV::cell (pos-r ?r2) (pos-c ?c) (contains ?y&empty|debris))
       (test (= ?r2 (+ ?r 2)))
       (ENV::cell (pos-r ?r3) (pos-c ?c) (contains ?z))
       (test (= ?r3 (+ ?r 3)))
 ?f <- (MAIN::percepts (time ?t)(pos-r ?r) (pos-c ?c))
 ?f1<- (ENV::cry done ?t)
     => (retract ?f1)
         (modify ?f (direction down) (perc1 ?x) (perc2 ?y) (perc3 ?z))
         (set-current-module MAIN) (focus MAIN))

(defrule ENV::percept-move-up1
(declare (salience 5))
     (ENV::agentstatus (pos-r ?r) (pos-c ?c) (time ?t)(direction up))
     (ENV::cell (pos-r ?r1) (pos-c ?c) (contains ?x&~empty&~debris))
     (test (= ?r1 (- ?r 1)))
 ?f <- (MAIN::percepts (time ?t)(pos-r ?r) (pos-c ?c))
?f1<- (ENV::cry done ?t)
     => (retract ?f1)
        (modify ?f (direction up) (perc1 ?x) (perc2 unknown) (perc3 unknown))
        (set-current-module MAIN) (focus MAIN))

(defrule ENV::percept-move-up2
(declare (salience 5))
     (ENV::agentstatus (pos-r ?r) (pos-c ?c) (time ?t)(direction up))
     (ENV::cell (pos-r ?r1) (pos-c ?c) (contains ?x&empty|debris))
     (test (= ?r1 (- ?r 1)))
     (ENV::cell (pos-r ?r2) (pos-c ?c) (contains ?y&~empty&~debris))
     (test (= ?r2 (- ?r 2)))
?f <- (MAIN::percepts (time ?t)(pos-r ?r) (pos-c ?c))
   ?f1<- (ENV::cry done ?t)
     => (retract ?f1)
        (modify ?f  (direction up) (perc1 ?x) (perc2 ?y) (perc3 unknown))
        (set-current-module MAIN) (focus MAIN))

(defrule ENV::percept-move-up3
(declare (salience 5))
     (ENV::agentstatus (pos-r ?r) (pos-c ?c) (time ?t)(direction up))
     (ENV::cell (pos-r ?r1) (pos-c ?c) (contains ?x&empty|debris))
     (test (= ?r1 (- ?r 1)))
     (ENV::cell (pos-r ?r2) (pos-c ?c) (contains ?y&empty|debris))
     (test (= ?r2 (- ?r 2)))
     (ENV::cell (pos-r ?r3) (pos-c ?c) (contains ?z))
     (test (= ?r3 (- ?r 3)))
?f <- (MAIN::percepts (time ?t)(pos-r ?r) (pos-c ?c))
?f1<- (ENV::cry done ?t)
     => (retract ?f1)
        (modify ?f (direction up) (perc1 ?x) (perc2 ?y) (perc3 ?z))
        (set-current-module MAIN) (focus MAIN))


(defrule ENV::percept-move-left1
(declare (salience 5))
     (ENV::agentstatus (pos-c ?c) (pos-r ?r) (time ?t)(direction left))
     (ENV::cell (pos-c ?c1) (pos-r ?r) (contains ?x&~empty&~debris))
     (test (= ?c1 (- ?c 1)))
  ?f <- (MAIN::percepts (time ?t)(pos-r ?r) (pos-c ?c))
  ?f1<- (ENV::cry done ?t)
     => (retract ?f1)
         (modify ?f (direction left) (perc1 ?x) (perc2 unknown) (perc3 unknown))
        (set-current-module MAIN) (focus MAIN))

(defrule ENV::percept-move-left2
(declare (salience 5))
     (ENV::agentstatus (pos-c ?c) (pos-r ?r) (time ?t)(direction left))
     (ENV::cell (pos-c ?c1) (pos-r ?r) (contains ?x&empty|debris))
     (test (= ?c1 (- ?c 1)))
     (ENV::cell (pos-c ?c2) (pos-r ?r)  (contains ?y&~empty&~debris))
     (test (= ?c2 (- ?c 2)))
   ?f <- (MAIN::percepts (time ?t)(pos-r ?r) (pos-c ?c))
    ?f1<- (ENV::cry done ?t)
     => (retract ?f1)
         (modify ?f  (direction left) (perc1 ?x) (perc2 ?y) (perc3 unknown))
        (set-current-module MAIN) (focus MAIN))

(defrule ENV::percept-move-left3
(declare (salience 5))
     (ENV::agentstatus (pos-r ?r) (pos-c ?c) (time ?t)(direction left))
     (ENV::cell (pos-c ?c1) (pos-r ?r) (contains ?x&empty|debris))
     (test (= ?c1 (- ?c 1)))
     (ENV::cell (pos-c ?c2) (pos-r ?r) (contains ?y&empty|debris))
     (test (= ?c2 (- ?c 2)))
     (ENV::cell (pos-c ?c3) (pos-r ?r) (contains ?z))
     (test (= ?c3 (- ?c 3)))
 ?f <- (MAIN::percepts (time ?t)(pos-r ?r) (pos-c ?c))
  ?f1<- (ENV::cry done ?t)
     => (retract ?f1)
         (modify ?f (direction left) (perc1 ?x) (perc2 ?y) (perc3 ?z))
        (set-current-module MAIN) (focus MAIN))

(defrule ENV::percept-move-right1
(declare (salience 5))
     (ENV::agentstatus (pos-c ?c) (pos-r ?r) (time ?t)(direction right))
     (ENV::cell (pos-c ?c1) (pos-r ?r) (contains ?x&~empty&~debris))
     (test (= ?c1 (+ ?c 1)))
   ?f <- (MAIN::percepts (time ?t)(pos-r ?r) (pos-c ?c))
    ?f1<- (ENV::cry done ?t)
     => (retract ?f1)
;         (modify ?f (direction left) (perc1 ?x) (perc2 unknown) (perc3 unknown))
         (modify ?f (direction right) (perc1 ?x) (perc2 unknown) (perc3 unknown))
        (set-current-module MAIN) (focus MAIN))

(defrule ENV::percept-move-right2
(declare (salience 5))
     (ENV::agentstatus (pos-c ?c) (pos-r ?r) (time ?t)(direction right))
     (ENV::cell (pos-c ?c1) (pos-r ?r) (contains ?x&empty|debris))
     (test (= ?c1 (+ ?c 1)))
     (ENV::cell (pos-c ?c2) (pos-r ?r)  (contains ?y&~empty&~debris))
     (test (= ?c2 (+ ?c 2)))
 ?f <- (MAIN::percepts (time ?t)(pos-r ?r) (pos-c ?c))
    ?f1<- (ENV::cry done ?t)
     => (retract ?f1)
         (modify ?f  (direction right) (perc1 ?x) (perc2 ?y) (perc3 unknown))
        (set-current-module MAIN) (focus MAIN))

(defrule ENV::percept-move-right3
(declare (salience 5))
     (ENV::agentstatus (pos-r ?r) (pos-c ?c) (time ?t)(direction right))
     (ENV::cell (pos-c ?c1) (pos-r ?r) (contains ?x&empty|debris))
     (test (= ?c1 (+ ?c 1)))
     (ENV::cell (pos-c ?c2) (pos-r ?r) (contains ?y&empty|debris))
     (test (= ?c2 (+ ?c 2)))
     (ENV::cell (pos-c ?c3) (pos-r ?r) (contains ?z))
     (test (= ?c3 (+ ?c 3)))
?f <- (MAIN::percepts (time ?t)(pos-r ?r) (pos-c ?c))
  ?f1<- (ENV::cry done ?t)
     => (retract ?f1)
         (modify ?f (direction right) (perc1 ?x) (perc2 ?y) (perc3 ?z))
        (set-current-module MAIN) (focus MAIN))

(defrule ENV::done
    (MAIN::status (time ?t))
     => (set-current-module MAIN) (focus MAIN))




; ---------------------------------------------------------------------------------
; MODULO AGENT
; ---------------------------------------------------------------------------------

;(defmodule AGENT)

(deftemplate AGENT::action (slot module))
(deftemplate AGENT::kpos (slot time) (slot pos-r) (slot pos-c) (slot direction) (slot load))
(deftemplate AGENT::movement (slot step))

; AGGIUNTA slot rotation per indicare celle visitate, con o senza rotazione.
(deftemplate AGENT::map (slot pos-r)
                 		(slot pos-c)
                 		(slot contains)
                 		(slot rotation (default not-completed))                 		
                 		(slot counter (default 0))
                 		(slot touched (default 0))	;OMAR 18/01/2005
)

(deftemplate AGENT::cry (slot pos-r) (slot pos-c))

(deftemplate AGENT::undo-step (slot step))

(deftemplate AGENT::undo (slot time) (slot direction) (slot action))

(deftemplate AGENT::debris-position (slot pos-r) (slot pos-c) (slot useful))

(deftemplate AGENT::exit-position (slot pos-r) (slot pos-c))

(deftemplate AGENT::entry-position (slot pos-r) (slot pos-c))

(deftemplate AGENT::unuseful-cell (slot pos-r) (slot pos-c))	;OMAR 18/01/2005 Tracciamento celle inutili

(deftemplate AGENT::move-completed (slot time))

(deftemplate AGENT::to-do (slot time) (slot action))	;OMAR 30/01/2006 

; lo slot tempo è necessario per fare in modo che la regola matchi anche in passi di esecuzione successivi
(deftemplate AGENT::undo-phase (slot time))	

(deftemplate AGENT::restore-direction (slot action))

(defrule AGENT::beginagent
    (declare (salience 10))
    (MAIN::status (time 0))
    => 
    (assert (AGENT::action (module explore)))