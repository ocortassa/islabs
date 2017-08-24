 (focus MAIN))

(defrule move-down-ok 
   (declare (salience 20))    
  ?f2<- (status (time ?i)) 
        (exec (time ?i) (action  go))
  ?f1<- (agentstatus (pos-r ?r) (pos-c ?c)(direction down))
        (cell (pos-r ?r1) (pos-c ?c) (contains empty|debris))
        (test (= ?r1 (+ ?r 1)))
        => (modify  ?f1 (pos-r (+ ?r 1)) (time (+ ?i 1)))
           (modify ?f2 (time (+ ?i 1))))

(defrule move-down-exit     
   (declare (salience 20)) 
  ?f2<- (status (time ?i)) 
        (exec (time ?i) (action  go))
  ?f1<- (agentstatus (pos-r ?r) (pos-c ?c)(direction down))
        (cell (pos-r ?r1) (pos-c ?c) (contains exit))
        (test (= ?r1 (+ ?r 1)))
        => (modify  ?f1 (pos-r (+ ?r 1)) (time (+ ?i 1)))
           (modify  ?f2 (time (+ ?i 1)) (result exit))
            (focus MAIN))

(defrule move-down-bump 
   (declare (salience 20))    
  ?f2<- (status (time ?i)) 
        (exec (time ?i) (action  go))
  ?f1<- (agentstatus (pos-r ?r) (pos-c ?c)(direction down))
        (cell (pos-r ?r1) (pos-c ?c) (contains wall|entry))
        (test (= ?r1 (+ ?r 1)))
        => (modify  ?f1 (time (+ ?i 1)))
           (modify ?f2 (time (+ ?i 1)))
           (assert (percepts (time (+ ?i 1))(pos-r ?r) (pos-c ?c) (direction down)
                             (perc1 bump) (perc2 unknown) (perc3 unknown) (cry unknown)))
            (focus MAIN))




(defrule move-up-bump     
  (declare (salience 20)) 
  ?f2<- (status (time ?i)) 
        (exec (time ?i) (action  go))
  ?f1<- (agentstatus (pos-r ?r) (pos-c ?c) (direction up))
        (cell (pos-r ?r1) (pos-c ?c) (contains wall|entry))
        (test (= ?r1 (- ?r 1)))        => 
           (modify  ?f1 (time (+ ?i 1)))
           (modify  ?f2 (time (+ ?i 1)))
           (assert (percepts (time (+ ?i 1))(pos-r ?r) (pos-c ?c) (direction up)
                             (perc1 bump) (perc2 unknown) (perc3 unknown)(cry unknown)))
            (focus MAIN))


(defrule move-up-ok     
   (declare (salience 20)) 
  ?f2<- (status (time ?i)) 
        (exec (time ?i) (action  go))
  ?f1<- (agentstatus (pos-r ?r) (pos-c ?c)(direction up))
        (cell (pos-r ?r1) (pos-c ?c) (contains empty|debris))
        (test (= ?r1 (- ?r 1)))
        => (modify  ?f1 (pos-r (- ?r 1)) (time (+ ?i 1)))
           (modify  ?f2 (time (+ ?i 1))))
           
(defrule move-up-exit     
   (declare (salience 20)) 
  ?f2<- (status (time ?i)) 
        (exec (time ?i) (action  go))
  ?f1<- (agentstatus (pos-r ?r) (pos-c ?c)(direction up))
        (cell (pos-r ?r1) (pos-c ?c) (contains exit))
        (test (= ?r1 (- ?r 1)))
        => (modify  ?f1 (pos-r (- ?r 1)) (time (+ ?i 1)))
           (modify  ?f2 (time (+ ?i 1)) (result exit))
            (focus MAIN))


(defrule move-left-ok 
   (declare (salience 20))     
   ?f2<- (status (time ?i)) 
        (exec (time ?i) (action  go))
  ?f1<- (agentstatus (pos-r ?r) (pos-c ?c) (direction left)) 
        (cell (pos-r ?r) (pos-c ?c1) (contains empty|debris))
        (test (= ?c1 (- ?c 1)))
        => (modify  ?f1 (pos-c (- ?c 1)) (time (+ ?i 1)))
           (modify ?f2 (time (+ ?i 1))))


(defrule move-left-exit     
   (declare (salience 20)) 
  ?f2<- (status (time ?i)) 
        (exec (time ?i) (action  go))
  ?f1<- (agentstatus (pos-r ?r) (pos-c ?c)(direction left))
        (cell (pos-r ?r) (pos-c ?c1) (contains exit))
        (test (= ?c1 (- ?c 1)))
        => (modify  ?f1 (pos-c (- ?c 1)) (time (+ ?i 1)))
           (modify  ?f2 (time (+ ?i 1)) (result exit))
            (focus MAIN))


(defrule move-left-bump 
   (declare (salience 20))     
   ?f2<- (status (time ?i)) 
        (exec (time ?i) (action  go))
  ?f1<- (agentstatus (pos-r ?r) (pos-c ?c) (direction left))
        (cell (pos-r ?r) (pos-c ?c1) (contains wall|entry))
        (test (= ?c1 (- ?c 1)))
        => (modify ?f1 (time (+ ?i 1)))
           (modify ?f2 (time (+ ?i 1)))
           (assert (percepts (time (+ ?i 1))(pos-r ?r) (pos-c ?c) (direction left)
                             (perc1 bump) (perc2 unknown) (perc3 unknown)(cry unknown)))
            (focus MAIN))


(defrule move-right-ok
   (declare (salience 20))      
  ?f2<- (status (time ?i)) 
        (exec (time ?i) (action  go))
  ?f1<- (agentstatus (pos-r ?r) (pos-c ?c) (direction right))
        (cell (pos-r ?r) (pos-c ?c1) (contains empty|debris))
        (test (= ?c1 (+ ?c 1)))
        => (modify  ?f1 (pos-c (+ ?c 1))(time (+ ?i 1)))
           (modify ?f2 (time (+ ?i 1))))

(defrule move-right-exit     
   (declare (salience 20)) 
  ?f2<- (status (time ?i)) 
        (exec (time ?i) (action  go))
  ?f1<- (agentstatus (pos-r ?r) (pos-c ?c)(direction right))
        (cell (pos-r ?r) (pos-c ?c1) (contains exit))
        (test (= ?c1 (+ ?c 1)))
        => (modify  ?f1 (pos-c (+ ?c 1)) (time (+ ?i 1)))
           (modify  ?f2 (time (+ ?i 1)) (result exit))
            (focus MAIN))

(defrule move-right-bump
   (declare (salience 20))      
  ?f2<- (status (time ?i)) 
        (exec (time ?i) (action  go))
  ?f1<- (agentstatus (pos-r ?r) (pos-c ?c) (direction right))
        (cell (pos-r ?r) (pos-c ?c1) (contains wall|entry))
        (test (= ?c1 (+ ?c 1)))
        => (modify ?f1 (time (+ ?i 1)))
           (modify ?f2 (time (+ ?i 1)))
           (assert (percepts (time (+ ?i 1))(pos-r ?r) (pos-c ?c) (direction right)
                             (perc1 bump) (perc2 unknown) (perc3 unknown) (cry unknown)))
            (focus MAIN))


(defrule turnleft1
   (declare (salience 20))      
  ?f2<- (status (time ?i)) 
        (exec (time ?i) (action  turnleft))
  ?f1<- (agentstatus (direction left))
        => (modify  ?f1 (direction down) (time (+ ?i 1)))
           (modify ?f2 (time (+ ?i 1))))

(defrule turnleft2
   (declare (salience 20))      
  ?f2<- (status (time ?i)) 
        (exec (time ?i) (action  turnleft))
  ?f1<- (agentstatus (direction up))
        => (modify  ?f1 (direction left) (time (+ ?i 1)))
           (modify ?f2 (time (+ ?i 1))))

(defrule turnleft3
   (declare (salience 20))      
  ?f2<- (status (time ?i)) 
        (exec (time ?i) (action  turnleft))
  ?f1<- (agentstatus (direction right))
        => (modify  ?f1 (direction up) (time (+ ?i 1)))
           (modify ?f2 (time (+ ?i 1))))

(defrule turnleft4
   (declare (salience 20))      
  ?f2<- (status (time ?i)) 
        (exec (time ?i) (action  turnleft))
  ?f1<- (agentstatus (direction down))
        => (modify  ?f1 (direction right) (time (+ ?i 1)))
           (modify ?f2 (time (+ ?i 1))))

(defrule turnright1
   (declare (salience 20))      
  ?f2<- (status (time ?i)) 
        (exec (time ?i) (action  turnright))
  ?f1<- (agentstatus (direction left))
        => (modify  ?f1 (direction up) (time (+ ?i 1)))
           (modify ?f2 (time (+ ?i 1))))

(defrule turnright2
   (declare (salience 20))      
  ?f2<- (status (time ?i)) 
        (exec (time ?i) (action  turnright))
  ?f1<- (agentstatus (direction down))
        => (modify  ?f1 (direction left) (time (+ ?i 1)))
           (modify ?f2 (time (+ ?i 1))))

(defrule turnright3
   (declare (salience 20))      
  ?f2<- (status (time ?i)) 
        (exec (time ?i) (action  turnright))
  ?f1<- (agentstatus (direction right))
        => (modify  ?f1 (direction down) (time (+ ?i 1)))
           (modify ?f2 (time (+ ?i 1))))

(defrule turnright4
   (declare (salience 20))      
  ?f2<- (status (time ?i)) 
        (exec (time ?i) (action  turnright))
  ?f1<- (agentstatus (direction up))
        => (modify  ?f1 (direction right) (time (+ ?i 1)))
           (modify ?f2 (time (+ ?i 1))))


(defrule dig-OK1
   (declare (salience 20))      
        (status (time ?i)) 
        (exec (time ?i) (action  dig))
        (not (OK dig ?i))
        (agentstatus (pos-r ?r) (pos-c ?c)) 
        (cell (pos-r ?r) (pos-c ?c) (contains debris))
  ?f1<- (debriscontent (pos-r ?r) (pos-c ?c) (person ?p&~no))
        => (assert (perc-dig (time (+ ?i 1)) (pos-r ?r) (pos-c ?c) (person yes)))
           (modify ?f1 (digged yes))
           (assert (OK dig ?i)))

(defrule dig-OK2
   (declare (salience 20))      
        (status (time ?i)) 
        (exec (time ?i) (action  dig))
        (not (OK dig ?i))
        (agentstatus (pos-r ?r) (pos-c ?c)) 
        (cell (pos-r ?r) (pos-c ?c) (contains debris))
  ?f1<- (debriscontent (pos-r ?r) (pos-c ?c) (person no))
        => (assert (perc-dig (time (+ ?i 1)) (pos-r ?r) (pos-c ?c) (person no)))
           (modify ?f1 (digged yes))
           (assert (OK dig ?i)))

(defrule dig-KO
   (declare (salience 20))      
        (status (time ?i)) 
        (exec (time ?i) (action  dig))
        (agentstatus (pos-r ?r) (pos-c ?c)) 
        (cell (pos-r ?r) (pos-c ?c) (contains ?d&~debris))
        => (assert (perc-dig (time (+ ?i 1)) (pos-r ?r) (pos-c ?c) (person fail)))
           (assert (KO dig ?i)))

(defrule grasp-OK
   (declare (salience 20))      
        (status (time ?i)) 
        (exec (time ?i) (action  grasp))
        (not (OK grasp ?i))
  ?f2<- (agentstatus (pos-r ?r) (pos-c ?c)(load no))
        (cell (pos-r ?r) (pos-c ?c) (contains debris))
  ?f1<- (debriscontent (pos-r ?r) (pos-c ?c) (person ?p&~no) (digged yes))
     => (assert (perc-grasp (time (+ ?i 1)) (pos-r ?r) (pos-c ?c) (person ?p)))
        (modify ?f1 (person no))
        (modify ?f2 (load ?p))
        (assert (OK grasp ?i)))



(defrule grasp-KO
   (declare (salience 19))      
        (status (time ?i)) 
        (exec (time ?i) (action  grasp))
        (agentstatus (pos-r ?r) (pos-c ?c) (direction ?d) (time ?i))
        (not (OK grasp ?i))
         => 
           (assert (perc-grasp (time (+ ?i 1)) (pos-r ?r) (pos-c ?c) (person fail)))
           (assert (KO grasp ?i)))

(defrule close-OK
   (declare (salience 18))      
  ?f2<- (status (time ?i)) 
        (exec (time ?i) (action  ?a&grasp|dig))
  ?f1<- (agentstatus (time ?i))
  ?f3<- (OK ?a ?i)
         => (modify ?f1 (time (+ ?i 1)))
            (modify ?f2 (time (+ ?i 1)))
            (retract ?f3))

(defrule close-KO
   (declare (salience 18))      
  ?f2<- (status (time ?i)) 
        (exec (time ?i) (action ?a&grasp|dig))
  ?f1<- (agentstatus (pos-r ?r) (pos-c ?c) (time ?i))
  ?f3<- (KO ?a ?i)
         => (modify ?f1 (time (+ ?i 1)))
            (modify ?f2 (time (+ ?i 1)))
            (retract ?f3))

(defrule percept-cry-unknown 
(declare (salience 8))
     (agentstatus (pos-r ?r) (pos-c ?c) (time ?t))
      (cell (pos-r ?r) (pos-c ?c) (contains exit))
  ;   (cell (pos-r ?r) (pos-c ?c) (contains ?x&entry|exit))
     => (assert (percepts (time ?t)(pos-r ?r) (pos-c ?c) (cry unknown)))
        (assert (cry done ?t)))

(defrule percept-cry-yes
(declare (salience 8))
     (agentstatus (pos-r ?r) (pos-c ?c) (time ?t))
    ; (cell (pos-r ?r) (pos-c ?c) (contains ?x&~entry&~exit))
    (cell (pos-r ?r) (pos-c ?c) (contains ~exit))
    (or (and (cell (pos-r ?r) (pos-c ?c) (contains debris))
              (debriscontent (pos-r ?r) (pos-c ?c) (person ~no)))
         (and (cell (pos-r ?r1) (pos-c ?c) (contains debris))
              (test (= ?r1 (+ ?r 1)))
              (debriscontent (pos-r ?r1) (pos-c ?c) (person ~no)))
         (and (cell (pos-r ?r2) (pos-c ?c) (contains debris))
              (test (= ?r2 (- ?r 1)))
              (debriscontent (pos-r ?r2) (pos-c ?c) (person ~no)))
         (and (cell (pos-r ?r) (pos-c ?c1) (contains debris))
              (test (= ?c1 (+ ?c 1)))
              (debriscontent (pos-r ?r) (pos-c ?c1) (person ~no)))
         (and (cell (pos-r ?r) (pos-c ?c2) (contains debris))
              (test (= ?c2 (- ?c 1)))
              (debriscontent (pos-r ?r) (pos-c ?c2) (person ~no))))
     => (assert (percepts (time ?t)(pos-r ?r) (pos-c ?c) (cry yes)))
        (assert (cry done ?t)))


(defrule percept-cry-no
(declare (salience 7))
     (agentstatus (pos-r ?r) (pos-c ?c) (time ?t))
     ;(cell (pos-r ?r) (pos-c ?c) (contains ?x&~entry&~exit))
     (cell (pos-r ?r) (pos-c ?c) (contains ~exit))
     (not (cry done ?t))
     => (assert (percepts (time ?t)(pos-r ?r) (pos-c ?c) (cry no)))
        (assert (cry done ?t)))


(defrule percept-move-down1
(declare (salience 5))
       (agentstatus (pos-r ?r) (pos-c ?c) (time ?t)(direction down))
       (cell (pos-r ?r1) (pos-c ?c) (contains ?x&~empty&~debris))
       (test (= ?r1 (+ ?r 1)))
 ?f <- (percepts (time ?t)(pos-r ?r) (pos-c ?c))
 ?f1<- (cry done ?t)
     => (retract ?f1)
        (modify ?f (direction down) (perc1 ?x) (perc2 unknown) (perc3 unknown))
         (focus MAIN))

(defrule percept-move-down2
(declare (salience 5))
        (agentstatus (pos-r ?r) (pos-c ?c) (time ?t)(direction down))
        (cell (pos-r ?r1) (pos-c ?c) (contains ?x&empty|debris))
        (test (= ?r1 (+ ?r 1)))
        (cell (pos-r ?r2) (pos-c ?c) (contains ?y&~empty&~debris))
        (test (= ?r2 (+ ?r 2)))
 ?f <- (percepts (time ?t)(pos-r ?r) (pos-c ?c))
 ?f1<- (cry done ?t)
     => (retract ?f1)
        (modify ?f  (direction down) (perc1 ?x) (perc2 ?y) (perc3 unknown))
         (focus MAIN))

(defrule percept-move-down3
(declare (salience 5))
       (agentstatus (pos-r ?r) (pos-c ?c) (time ?t)(direction down))
       (cell (pos-r ?r1) (pos-c ?c) (contains ?x&empty|debris))
       (test (= ?r1 (+ ?r 1)))
       (cell (pos-r ?r2) (pos-c ?c) (contains ?y&empty|debris))
       (test (= ?r2 (+ ?r 2)))
       (cell (pos-r ?r3) (pos-c ?c) (contains ?z))
       (test (= ?r3 (+ ?r 3)))
 ?f <- (percepts (time ?t)(pos-r ?r) (pos-c ?c))
 ?f1<- (cry done ?t)
     => (retract ?f1)
         (modify ?f (direction down) (perc1 ?x) (perc2 ?y) (perc3 ?z))
          (focus MAIN))

(defrule percept-move-up1
(declare (salience 5))
     (agentstatus (pos-r ?r) (pos-c ?c) (time ?t)(direction up))
     (cell (pos-r ?r1) (pos-c ?c) (contains ?x&~empty&~debris))
     (test (= ?r1 (- ?r 1)))
 ?f <- (percepts (time ?t)(pos-r ?r) (pos-c ?c))
?f1<- (cry done ?t)
     => (retract ?f1)
        (modify ?f (direction up) (perc1 ?x) (perc2 unknown) (perc3 unknown))
         (focus MAIN))

(defrule percept-move-up2
(declare (salience 5))
     (agentstatus (pos-r ?r) (pos-c ?c) (time ?t)(direction up))
     (cell (pos-r ?r1) (pos-c ?c) (contains ?x&empty|debris))
     (test (= ?r1 (- ?r 1)))
     (cell (pos-r ?r2) (pos-c ?c) (contains ?y&~empty&~debris))
     (test (= ?r2 (- ?r 2)))
?f <- (percepts (time ?t)(pos-r ?r) (pos-c ?c))
   ?f1<- (cry done ?t)
     => (retract ?f1)
        (modify ?f  (direction up) (perc1 ?x) (perc2 ?y) (perc3 unknown))
         (focus MAIN))

(defrule percept-move-up3
(declare (salience 5))
     (agentstatus (pos-r ?r) (pos-c ?c) (time ?t)(direction up))
     (cell (pos-r ?r1) (pos-c ?c) (contains ?x&empty|debris))
     (test (= ?r1 (- ?r 1)))
     (cell (pos-r ?r2) (pos-c ?c) (contains ?y&empty|debris))
     (test (= ?r2 (- ?r 2)))
     (cell (pos-r ?r3) (pos-c ?c) (contains ?z))
     (test (= ?r3 (- ?r 3)))
?f <- (percepts (time ?t)(pos-r ?r) (pos-c ?c))
?f1<- (cry done ?t)
     => (retract ?f1)
        (modify ?f (direction up) (perc1 ?x) (perc2 ?y) (perc3 ?z))
         (focus MAIN))


(defrule percept-move-left1
(declare (salience 5))
     (agentstatus (pos-c ?c) (pos-r ?r) (time ?t)(direction left))
     (cell (pos-c ?c1) (pos-r ?r) (contains ?x&~empty&~debris))
     (test (= ?c1 (- ?c 1)))
  ?f <- (percepts (time ?t)(pos-r ?r) (pos-c ?c))
  ?f1<- (cry done ?t)
     => (retract ?f1)
         (modify ?f (direction left) (perc1 ?x) (perc2 unknown) (perc3 unknown))
         (focus MAIN))

(defrule percept-move-left2
(declare (salience 5))
     (agentstatus (pos-c ?c) (pos-r ?r) (time ?t)(direction left))
     (cell (pos-c ?c1) (pos-r ?r) (contains ?x&empty|debris))
     (test (= ?c1 (- ?c 1)))
     (cell (pos-c ?c2) (pos-r ?r)  (contains ?y&~empty&~debris))
     (test (= ?c2 (- ?c 2)))
   ?f <- (percepts (time ?t)(pos-r ?r) (pos-c ?c))
    ?f1<- (cry done ?t)
     => (retract ?f1)
         (modify ?f  (direction left) (perc1 ?x) (perc2 ?y) (perc3 unknown))
         (focus MAIN))

(defrule percept-move-left3
(declare (salience 5))
     (agentstatus (pos-r ?r) (pos-c ?c) (time ?t)(direction left))
     (cell (pos-c ?c1) (pos-r ?r) (contains ?x&empty|debris))
     (test (= ?c1 (- ?c 1)))
     (cell (pos-c ?c2) (pos-r ?r) (contains ?y&empty|debris))
     (test (= ?c2 (- ?c 2)))
     (cell (pos-c ?c3) (pos-r ?r) (contains ?z))
     (test (= ?c3 (- ?c 3)))
 ?f <- (percepts (time ?t)(pos-r ?r) (pos-c ?c))
  ?f1<- (cry done ?t)
     => (retract ?f1)
         (modify ?f (direction left) (perc1 ?x) (perc2 ?y) (perc3 ?z))
         (focus MAIN))

(defrule percept-move-right1
(declare (salience 5))
     (agentstatus (pos-c ?c) (pos-r ?r) (time ?t)(direction right))
     (cell (pos-c ?c1) (pos-r ?r) (contains ?x&~empty&~debris))
     (test (= ?c1 (+ ?c 1)))
   ?f <- (percepts (time ?t)(pos-r ?r) (pos-c ?c))
    ?f1<- (cry done ?t)
     => (retract ?f1)
;         (modify ?f (direction left) (perc1 ?x) (perc2 unknown) (perc3 unknown))
         (modify ?f (direction right) (perc1 ?x) (perc2 unknown) (perc3 unknown))
         (focus MAIN))

(defrule percept-move-right2
(declare (salience 5))
     (agentstatus (pos-c ?c) (pos-r ?r) (time ?t)(direction right))
     (cell (pos-c ?c1) (pos-r ?r) (contains ?x&empty|debris))
     (test (= ?c1 (+ ?c 1)))
     (cell (pos-c ?c2) (pos-r ?r)  (contains ?y&~empty&~debris))
     (test (= ?c2 (+ ?c 2)))
 ?f <- (percepts (time ?t)(pos-r ?r) (pos-c ?c))
    ?f1<- (cry done ?t)
     => (retract ?f1)
         (modify ?f  (direction right) (perc1 ?x) (perc2 ?y) (perc3 unknown))
         (focus MAIN))

(defrule percept-move-right3
(declare (salience 5))
     (agentstatus (pos-r ?r) (pos-c ?c) (time ?t)(direction right))
     (cell (pos-c ?c1) (pos-r ?r) (contains ?x&empty|debris))
     (test (= ?c1 (+ ?c 1)))
     (cell (pos-c ?c2) (pos-r ?r) (contains ?y&empty|debris))
     (test (= ?c2 (+ ?c 2)))
     (cell (pos-c ?c3) (pos-r ?r) (contains ?z))
     (test (= ?c3 (+ ?c 3)))
?f <- (percepts (time ?t)(pos-r ?r) (pos-c ?c))
  ?f1<- (cry done ?t)
     => (retract ?f1)
         (modify ?f (direction right) (perc1 ?x) (perc2 ?y) (perc3 ?z))
         (focus MAIN))

(defrule done
    (status (time ?t))
     =>  (focus MAIN))




; ---------------------------------------------------------------------------------
; MODULO AGENT
; ---------------------------------------------------------------------------------

(defmodule AGENT (import MAIN ?ALL)(export ?ALL))

(deftemplate action (slot module))

(deftemplate movement (slot step))

; AGGIUNTA slot rotation per indicare celle visitate, con o senza rotazione.
(deftemplate map (slot pos-r)
                 		(slot pos-c)
                 		(slot contains)
                 		(slot rotation (default not-completed))                 		
                 		(slot counter (default 0))
                 		(slot touched (default 0))	;OMAR 18/01/2005
)

(deftemplate cry (slot pos-r) (slot pos-c))

(deftemplate undo-step (slot step))

(deftemplate undo (slot time) (slot direction) (slot action))

(deftemplate debris-position (slot pos-r) (slot pos-c) (slot useful))

(deftemplate exit-position (slot pos-r) (slot pos-c))

(deftemplate entry-position (slot pos-r) (slot pos-c))

(deftemplate unuseful-cell (slot pos-r) (slot pos-c))	;OMAR 18/01/2005 Tracciamento celle inutili

(deftemplate move-completed (slot time))

(deftemplate to-do (slot time) (slot action))	;OMAR 30/01/2006 

; lo slot tempo è necessario per fare in modo che la regola matchi anche in passi di esecuzione successivi
(deftemplate undo-phase (slot time))	

(deftemplate restore-direction (slot action))

(defrule beginagent
    (declare (salience 10))
    (status (time 0))
    => 
    (assert (action (module explore)))