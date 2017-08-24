;; ##------------------------ ROTAZIONI DEL ROBOT --------------------------##
;(defrule move-step1
;	(declare (salience -22))
;	(action (to_do ~save))
;	(status (time ?t))
;	?f <- (movement (step 1))
;	=>	
;	(modify ?f (step 2))
;	(assert (exec (action turnleft) (time ?t) (marks-a-path no)))
;)
;
;(defrule move-step2-3
;	(declare (salience -22))
;	(action (to_do ~save))
;	(status (time ?t))
;	?f <- (movement (step ?x &2|3))
;	=>	
;	(modify ?f (step (+ ?x 1)))
;	(assert (exec (action turnright) (time ?t) (marks-a-path no)))
;)
;
;(defrule move-step4
;	(declare (salience -22))
;	(action (to_do ~save))
;	(status (time ?t))
;	; AGGIUNTA: 
;	; Asserisco che nella cella ho eseguito la rotazione completa.
;	; (cioè ho visto tutto ciò che potevo vedere da quella posizione)
;	;----------------------------------------------------------
;	(kpos (time ?t) (pos-r ?r) (pos-c ?c)) 
;	?f1 <- (map (pos-r ?r) (pos-c ?c) (rotation ?)) 
;	;----------------------------------------------------------
;	?f <- (movement (step 4))
;	=>	
;	(modify ?f (step 0))
;	(modify ?f1 (rotation completed))
;	(assert (exec (action turnleft) (time ?t) (marks-a-path no)))
;)
; ##-----------------------------------------------------------------------##

; Omar 01/10/2005 - Miglioramento della gestione dei loop
; N.B. Nello slot 'action' viene salvato l'ultima mossa compiuta dal robot
;(deftemplate loop-prevention (slot pos-r) (slot pos-c) (slot direction) (slot action) (slot counter))

; Inzio nuova gestione --- Omar 01/10/2005
; Il robot può sfondare i vicoli ciechi logici (la celle ai suoi lati sono già state visitate o sono blocchi)
; la prima volta, la volta successiva che transita nella medesima cella (proveniendo dalla stessa direzione)
; viene fatto ruotare prima verso sx, alla volta successiva a dx e infine viene nuovamente forzato il blocco
; logico fancedolo proseguire nella direzione da cui proviene
; modificato (e corretto) il 28/12/2005

; Regola per gestire i vicoli ciechi logici cioe' le situazioni in cui ho visitato tutte le celle
; adiacenti alla posizione corrente del robot. In questo caso, proseguo nella direzione in cui il 
; robot e' rivolto

;(defrule blindalley-logical-first
;	(declare (salience -18))	
;	?f <- (movement (step 0))
;	(action (to_do ?act))
;	(status (time ?t))
;	(kpos (time ?t) (pos-r ?r) (pos-c ?c) (direction ?d) (load ?))
;	(not (loop-prevention (pos-r ?r) (pos-c ?c) (direction ?d)))
;	(or
;		; direzione UP
;		(and
;			(test (= (str-compare ?d up) 0))
;			(exec-path (time ~2) (pos-r ?r1) (pos-c ?c) (module ?act))
;			(test (= (- ?r 1) ?r1))
;			(or 
;				(map (pos-r ?r) (pos-c ?c1) (contains wall|entry|exit))
;				(exec-path (time ~2) (pos-r ?r) (pos-c ?c1) (module ?act))
;			)				
;			(test (= (- ?c 1) ?c1))			
;			(or 
;				(map (pos-r ?r) (pos-c ?c2) (contains wall|entry|exit))
;				(exec-path (time ~2) (pos-r ?r) (pos-c ?c2) (module ?act))
;			)				
;			(test (= (+ ?c 1) ?c2))
;	        )
;		; direzione DOWN
;		(and
;			(test (= (str-compare ?d down) 0))
;			(exec-path (time ~2) (pos-r ?r1) (pos-c ?c) (module ?act))
;			(test (= (+ ?r 1) ?r1))
;			(or 
;				(map (pos-r ?r) (pos-c ?c1) (contains wall|entry|exit))
;				(exec-path (time ~2) (pos-r ?r) (pos-c ?c1) (module ?act))
;			)				
;			(test (= (+ ?c 1) ?c1))
;			(or 
;				(map (pos-r ?r) (pos-c ?c2) (contains wall|entry|exit))
;				(exec-path (time ~2) (pos-r ?r) (pos-c ?c2) (module ?act))
;			)				
;			(test (= (- ?c 1) ?c2))		
;	        )
;		; direzione LEFT
;		(and
;			(test (= (str-compare ?d left) 0))
;			(exec-path (time ~2) (pos-r ?r) (pos-c ?c1) (module ?act))
;			(test (= (- ?c 1) ?c1))
;			(or 
;				(map (pos-r ?r1) (pos-c ?c) (contains wall|entry|exit))
;				(exec-path (time ~2) (pos-r ?r1) (pos-c ?c) (module ?act))
;			)				
;			(test (= (- ?r 1) ?r1))
;			(or 
;				(map (pos-r ?r2) (pos-c ?c) (contains wall|entry|exit))
;				(exec-path (time ~2) (pos-r ?r2) (pos-c ?c) (module ?act))
;			)				
;			(test (= (+ ?r 1) ?r2))
;	    	)
;		; direzione RIGHT
;		(and
;			(test (= (str-compare ?d right) 0))
;			(exec-path (time ~2) (pos-r ?r) (pos-c ?c1) (module ?act))
;			(test (= (+ ?c 1) ?c1))
;			(or 
;				(map (pos-r ?r1) (pos-c ?c) (contains wall|entry|exit))
;				(exec-path (time ~2) (pos-r ?r1) (pos-c ?c) (module ?act))
;			)				
;			(test (= (+ ?r 1) ?r1))
;			(or 
;				(map (pos-r ?r2) (pos-c ?c) (contains wall|entry|exit))
;				(exec-path (time ~2) (pos-r ?r2) (pos-c ?c) (module ?act))
;			)				
;			(test (= (- ?r 1) ?r2))
;	    	)
;	)
;	(not (move-completed  (time ?)))
;	=>
;	(assert (exec (action go)(time ?t)))
;	(assert (move-completed (time ?t)))
;	(assert (loop-prevention (pos-r ?r) (pos-c ?c) (direction ?d) (action go) (counter 0)))
;	(modify ?f (step 1))
;	(pop-focus)
;)

; OMAR 12/11/2005 - Questa regola si attiva solo quando è già stato sfondato un vicolo cieco logico
; ma non sono stati fatti abbastanza passaggi per cambiare strada (e quindi girare a sinistra)
(defrule blindalley-logical-go
	(declare (salience -18))	
	?f <- (movement (step 0))
	(action (to_do ?act))
	(status (time ?t))
	(kpos (time ?t) (pos-r ?r) (pos-c ?c) (direction ?d) (load ?))
	?f1 <- (loop-prevention (pos-r ?r) (pos-c ?c) (direction ?d) (action go|turnright) (counter ?cnt))
	(test (< ?cnt 2))	
	(or
		; direzione UP
		(and
			(test (= (str-compare ?d up) 0))
			(exec-path (time ~2) (pos-r ?r1) (pos-c ?c) (module ?act))
			(test (= (- ?r 1) ?r1))
			(or 
				(map (pos-r ?r) (pos-c ?c1) (contains wall|entry|exit))
				(exec-path (time ~2) (pos-r ?r) (pos-c ?c1) (module ?act))
			)				
			(test (= (- ?c 1) ?c1))			
			(or 
				(map (pos-r ?r) (pos-c ?c2) (contains wall|entry|exit))
				(exec-path (time ~2) (pos-r ?r) (pos-c ?c2) (module ?act))
			)				
			(test (= (+ ?c 1) ?c2))
	        )
		; direzione DOWN
		(and
			(test (= (str-compare ?d down) 0))
			(exec-path (time ~2) (pos-r ?r1) (pos-c ?c) (module ?act))
			(test (= (+ ?r 1) ?r1))
			(or 
				(map (pos-r ?r) (pos-c ?c1) (contains wall|entry|exit))
				(exec-path (time ~2) (pos-r ?r) (pos-c ?c1) (module ?act))
			)				
			(test (= (+ ?c 1) ?c1))
			(or 
				(map (pos-r ?r) (pos-c ?c2) (contains wall|entry|exit))
				(exec-path (time ~2) (pos-r ?r) (pos-c ?c2) (module ?act))
			)				
			(test (= (- ?c 1) ?c2))		
	        )
		; direzione LEFT
		(and
			(test (= (str-compare ?d left) 0))
			(exec-path (time ~2) (pos-r ?r) (pos-c ?c1) (module ?act))
			(test (= (- ?c 1) ?c1))
			(or 
				(map (pos-r ?r1) (pos-c ?c) (contains wall|entry|exit))
				(exec-path (time ~2) (pos-r ?r1) (pos-c ?c) (module ?act))
			)				
			(test (= (- ?r 1) ?r1))
			(or 
				(map (pos-r ?r2) (pos-c ?c) (contains wall|entry|exit))
				(exec-path (time ~2) (pos-r ?r2) (pos-c ?c) (module ?act))
			)				
			(test (= (+ ?r 1) ?r2))
	    	)
		; direzione RIGHT
		(and
			(test (= (str-compare ?d right) 0))
			(exec-path (time ~2) (pos-r ?r) (pos-c ?c1) (module ?act))
			(test (= (+ ?c 1) ?c1))
			(or 
				(map (pos-r ?r1) (pos-c ?c) (contains wall|entry|exit))
				(exec-path (time ~2) (pos-r ?r1) (pos-c ?c) (module ?act))
			)				
			(test (= (+ ?r 1) ?r1))
			(or 
				(map (pos-r ?r2) (pos-c ?c) (contains wall|entry|exit))
				(exec-path (time ~2) (pos-r ?r2) (pos-c ?c) (module ?act))
			)				
			(test (= (- ?r 1) ?r2))
	    	)
	)
	(not (move-completed  (time ?)))
	=>
	(assert (exec (action go)(time ?t)))
	(assert (move-completed (time ?t)))
	(modify ?f1 (counter (+ ?cnt 1)))
	(modify ?f (step 1))
	(pop-focus)
)

; Al passo precedente è stato forzato il vicolo cieco, adesso si svolta a sx
(defrule blindalley-logical-turnleft
	(declare (salience -18))	
	?f <- (movement (step 0))
	(action (to_do ?act))
	(status (time ?t))
	(kpos (time ?t) (pos-r ?r) (pos-c ?c) (direction ?d) (load ?))
	?f1 <- (loop-prevention (pos-r ?r) (pos-c ?c) (direction ?d) (action go) (counter ?cnt))
	(test (>= ?cnt 2))	
	(or
		; direzione UP
		(and
			(test (= (str-compare ?d up) 0))
			(exec-path (time ~2) (pos-r ?r1) (pos-c ?c) (module ?act))
			(test (= (- ?r 1) ?r1))
			(or 
				(map (pos-r ?r) (pos-c ?c1) (contains wall|entry|exit))
				(exec-path (time ~2) (pos-r ?r) (pos-c ?c1) (module ?act))
			)				
			(test (= (- ?c 1) ?c1))			
			(or 
				(map (pos-r ?r) (pos-c ?c2) (contains wall|entry|exit))
				(exec-path (time ~2) (pos-r ?r) (pos-c ?c2) (module ?act))
			)				
			(test (= (+ ?c 1) ?c2))
	        )
		; direzione DOWN
		(and
			(test (= (str-compare ?d down) 0))
			(exec-path (time ~2) (pos-r ?r1) (pos-c ?c) (module ?act))
			(test (= (+ ?r 1) ?r1))
			(or 
				(map (pos-r ?r) (pos-c ?c1) (contains wall|entry|exit))
				(exec-path (time ~2) (pos-r ?r) (pos-c ?c1) (module ?act))
			)				
			(test (= (+ ?c 1) ?c1))
			(or 
				(map (pos-r ?r) (pos-c ?c2) (contains wall|entry|exit))
				(exec-path (time ~2) (pos-r ?r) (pos-c ?c2) (module ?act))
			)				
			(test (= (- ?c 1) ?c2))		
	        )
		; direzione LEFT
		(and
			(test (= (str-compare ?d left) 0))
			(exec-path (time ~2) (pos-r ?r) (pos-c ?c1) (module ?act))
			(test (= (- ?c 1) ?c1))
			(or 
				(map (pos-r ?r1) (pos-c ?c) (contains wall|entry|exit))
				(exec-path (time ~2) (pos-r ?r1) (pos-c ?c) (module ?act))
			)				
			(test (= (- ?r 1) ?r1))
			(or 
				(map (pos-r ?r2) (pos-c ?c) (contains wall|entry|exit))
				(exec-path (time ~2) (pos-r ?r2) (pos-c ?c) (module ?act))
			)				
			(test (= (+ ?r 1) ?r2))
	    	)
		; direzione RIGHT
		(and
			(test (= (str-compare ?d right) 0))
			(exec-path (time ~2) (pos-r ?r) (pos-c ?c1) (module ?act))
			(test (= (+ ?c 1) ?c1))
			(or 
				(map (pos-r ?r1) (pos-c ?c) (contains wall|entry|exit))
				(exec-path (time ~2) (pos-r ?r1) (pos-c ?c) (module ?act))
			)				
			(test (= (+ ?r 1) ?r1))
			(or 
				(map (pos-r ?r2) (pos-c ?c) (contains wall|entry|exit))
				(exec-path (time ~2) (pos-r ?r2) (pos-c ?c) (module ?act))
			)				
			(test (= (- ?r 1) ?r2))
	    	)
	)
	(not (move-completed  (time ?)))
	=>
	(assert (exec (action turnleft)(time ?t)))
	(assert (move-completed (time ?t)))
	(modify ?f1 (action turnleft))
	(modify ?f (step 1))
	(pop-focus)
)

; Al passo precedente si è svoltato a sx, adesso si svolta a dx
(defrule blindalley-logical-turnright
	(declare (salience -18))	
	?f <- (movement (step 0))
	(action (to_do ?act))
	(status (time ?t))
	(kpos (time ?t) (pos-r ?r) (pos-c ?c) (direction ?d) (load ?))
	?f1 <- (loop-prevention (pos-r ?r) (pos-c ?c) (direction ?d) (action turnleft))
	(or
		; direzione UP
		(and
			(test (= (str-compare ?d up) 0))
			(exec-path (time ~2) (pos-r ?r1) (pos-c ?c) (module ?act))
			(test (= (- ?r 1) ?r1))
			(or 
				(map (pos-r ?r) (pos-c ?c1) (contains wall|entry|exit))
				(exec-path (time ~2) (pos-r ?r) (pos-c ?c1) (module ?act))
			)				
			(test (= (- ?c 1) ?c1))			
			(or 
				(map (pos-r ?r) (pos-c ?c2) (contains wall|entry|exit))
				(exec-path (time ~2) (pos-r ?r) (pos-c ?c2) (module ?act))
			)				
			(test (= (+ ?c 1) ?c2))
	        )
		; direzione DOWN
		(and
			(test (= (str-compare ?d down) 0))
			(exec-path (time ~2) (pos-r ?r1) (pos-c ?c) (module ?act))
			(test (= (+ ?r 1) ?r1))
			(or 
				(map (pos-r ?r) (pos-c ?c1) (contains wall|entry|exit))
				(exec-path (time ~2) (pos-r ?r) (pos-c ?c1) (module ?act))
			)				
			(test (= (+ ?c 1) ?c1))
			(or 
				(map (pos-r ?r) (pos-c ?c2) (contains wall|entry|exit))
				(exec-path (time ~2) (pos-r ?r) (pos-c ?c2) (module ?act))
			)				
			(test (= (- ?c 1) ?c2))		
	        )
		; direzione LEFT
		(and
			(test (= (str-compare ?d left) 0))
			(exec-path (time ~2) (pos-r ?r) (pos-c ?c1) (module ?act))
			(test (= (- ?c 1) ?c1))
			(or 
				(map (pos-r ?r1) (pos-c ?c) (contains wall|entry|exit))
				(exec-path (time ~2) (pos-r ?r1) (pos-c ?c) (module ?act))
			)				
			(test (= (- ?r 1) ?r1))
			(or 
				(map (pos-r ?r2) (pos-c ?c) (contains wall|entry|exit))
				(exec-path (time ~2) (pos-r ?r2) (pos-c ?c) (module ?act))
			)				
			(test (= (+ ?r 1) ?r2))
	    	)
		; direzione RIGHT
		(and
			(test (= (str-compare ?d right) 0))
			(exec-path (time ~2) (pos-r ?r) (pos-c ?c1) (module ?act))
			(test (= (+ ?c 1) ?c1))
			(or 
				(map (pos-r ?r1) (pos-c ?c) (contains wall|entry|exit))
				(exec-path (time ~2) (pos-r ?r1) (pos-c ?c) (module ?act))
			)				
			(test (= (+ ?r 1) ?r1))
			(or 
				(map (pos-r ?r2) (pos-c ?c) (contains wall|entry|exit))
				(exec-path (time ~2) (pos-r ?r2) (pos-c ?c) (module ?act))
			)				
			(test (= (- ?r 1) ?r2))
	    	)
	)
	(not (move-completed  (time ?)))
	=>
	(assert (exec (action turnright)(time ?t)))
	(assert (move-completed (time ?t)))
	(modify ?f1 (action turnright) (counter 0))
	(modify ?f (step 1))
	(pop-focus)
)

; fine nuova gestione --- Omar 01/10/2005 (corretta il 28/12/2005)

; Omar 28/12/2005
; Gestione dei default logici: di default si decide
; che la prima rotazione sarà verso sinistra. Alla successiva occasione di scelta si cambierà la direzione presa
; nella precedente scelta

; Regola per gestire la prima scelta di default (verso sinistra)
;(defrule turn-default-first-logical
;	(declare (salience -18))
;	?f <- (movement (step 0))
;	(status (time ?t))
;	(action (to_do ?act))
;	(percepts (time ?t) (pos-r ?r)(pos-c ?c)(direction ?d)(perc1 wall|entry|exit)(perc2 ?p2)(perc3 ?p3)(cry ?))
;	(not (default-choice-logical (pos-r ?r)(pos-c ?c)(direction ?d)))
;	(or
;		(and
;			(test (= (str-compare ?d left) 0))
;			(exec-path (time ?) (pos-r ?r1) (pos-c ?c1) (module ?act))
;			(exec-path (time ?) (pos-r ?r2) (pos-c ?c1) (module ?act))
;			(test (= (- ?r 1) ?r1))
;			(test (= (+ ?r 1) ?r2))
;		)
;		(and
;			(test (= (str-compare ?d right) 0))
;			(exec-path (time ?) (pos-r ?r1) (pos-c ?c1) (module ?act))
;			(exec-path (time ?) (pos-r ?r2) (pos-c ?c1) (module ?act))
;			(test (= (- ?r 1) ?r1))
;			(test (= (+ ?r 1) ?r2))
;		)
;
;		(and
;			(test (= (str-compare ?d up) 0))
;			(exec-path (time ?) (pos-r ?r) (pos-c ?c1) (module ?act))
;			(exec-path (time ?) (pos-r ?r) (pos-c ?c2) (module ?act))
;			(test (= (- ?c 1) ?c1))
;			(test (= (+ ?c 1) ?c2))
;		)
;		(and
;			(test (= (str-compare ?d down) 0))
;			(exec-path (time ?) (pos-r ?r) (pos-c ?c1) (module ?act))
;			(exec-path (time ?) (pos-r ?r) (pos-c ?c2) (module ?act))
;			(test (= (- ?c 1) ?c1))
;			(test (= (+ ?c 1) ?c2))
;		)
;	)
;	(not (move-completed  (time ?)))
;	=>
;	(assert (exec (action turnleft)(time ?t)))
;	(assert (move-completed (time ?t)))
;	(modify ?f (step 1))
;	(assert (default-choice-logical (pos-r ?r) (pos-c ?c) (direction ?d) (choice left)))
;	(pop-focus)
;)

; Regola per gestire le scelte successive
; rotazione precedente verso destra --> adesso bisogna andare a sinistra
(defrule turn-default-left-logical
	(declare (salience -18))
	?f <- (movement (step 0))
	(action (to_do ?act))
	(status (time ?t))
	(percepts (time ?t) (pos-r ?r)(pos-c ?c)(direction ?d)(perc1 wall|entry|exit)(perc2 ?p2)(perc3 ?p3)(cry ?))
	?f1 <- (default-choice-logical (pos-r ?r)(pos-c ?c)(direction ?d)(choice right))
	(or
		(and
			(test (= (str-compare ?d left) 0))
			(exec-path (time ?) (pos-r ?r1) (pos-c ?c1) (module ?act))
			(exec-path (time ?) (pos-r ?r2) (pos-c ?c1) (module ?act))
			(test (= (- ?r 1) ?r1))
			(test (= (+ ?r 1) ?r2))
		)
		(and
			(test (= (str-compare ?d right) 0))
			(exec-path (time ?) (pos-r ?r1) (pos-c ?c1) (module ?act))
			(exec-path (time ?) (pos-r ?r2) (pos-c ?c1) (module ?act))
			(test (= (- ?r 1) ?r1))
			(test (= (+ ?r 1) ?r2))
		)

		(and
			(test (= (str-compare ?d up) 0))
			(exec-path (time ?) (pos-r ?r) (pos-c ?c1) (module ?act))
			(exec-path (time ?) (pos-r ?r) (pos-c ?c2) (module ?act))
			(test (= (- ?c 1) ?c1))
			(test (= (+ ?c 1) ?c2))
		)
		(and
			(test (= (str-compare ?d down) 0))
			(exec-path (time ?) (pos-r ?r) (pos-c ?c1) (module ?act))
			(exec-path (time ?) (pos-r ?r) (pos-c ?c2) (module ?act))
			(test (= (- ?c 1) ?c1))
			(test (= (+ ?c 1) ?c2))
		)
	)
	(not (move-completed  (time ?)))
	=>
	(assert (exec (action turnleft)(time ?t)))
	(assert (move-completed (time ?t)))
	(modify ?f (step 1))
	(modify ?f1 (choice left))
	(pop-focus)
)

; Regola per gestire le scelte successive
; rotazione precedente verso sinistra --> adesso bisogna andare a destra
(defrule turn-default-right-logical
	(declare (salience -18))
	(action (to_do ?act))
	?f <- (movement (step 0))
	(status (time ?t))
	(percepts (time ?t) (pos-r ?r)(pos-c ?c)(direction ?d)(perc1 wall|entry|exit)(perc2 ?p2)(perc3 ?p3)(cry ?))
	?f1 <- (default-choice-logical (pos-r ?r)(pos-c ?c)(direction ?d)(choice left))
	(or
		(and
			(test (= (str-compare ?d left) 0))
			(exec-path (time ?) (pos-r ?r1) (pos-c ?c1) (module ?act))
			(exec-path (time ?) (pos-r ?r2) (pos-c ?c1) (module ?act))
			(test (= (- ?r 1) ?r1))
			(test (= (+ ?r 1) ?r2))
		)
		(and
			(test (= (str-compare ?d right) 0))
			(exec-path (time ?) (pos-r ?r1) (pos-c ?c1) (module ?act))
			(exec-path (time ?) (pos-r ?r2) (pos-c ?c1) (module ?act))
			(test (= (- ?r 1) ?r1))
			(test (= (+ ?r 1) ?r2))
		)

		(and
			(test (= (str-compare ?d up) 0))
			(exec-path (time ?) (pos-r ?r) (pos-c ?c1) (module ?act))
			(exec-path (time ?) (pos-r ?r) (pos-c ?c2) (module ?act))
			(test (= (- ?c 1) ?c1))
			(test (= (+ ?c 1) ?c2))
		)
		(and
			(test (= (str-compare ?d down) 0))
			(exec-path (time ?) (pos-r ?r) (pos-c ?c1) (module ?act))
			(exec-path (time ?) (pos-r ?r) (pos-c ?c2) (module ?act))
			(test (= (- ?c 1) ?c1))
			(test (= (+ ?c 1) ?c2))
		)
	)
	(not (move-completed  (time ?)))
	=>
	(assert (exec (action turnright)(time ?t)))
	(assert (move-completed (time ?t)))
	(modify ?f (step 1))
	(modify ?f1 (choice right))
	(pop-focus)
)
