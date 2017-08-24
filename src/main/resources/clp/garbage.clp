;; ##------------------------ ROTAZIONI DEL ROBOT --------------------------##
;(defrule AGENT::move-step1
;	(declare (salience -22))
;	(AGENT::action (to_do ~save))
;	(MAIN::status (time ?t))
;	?f <- (movement (step 1))
;	=>	
;	(modify ?f (step 2))
;	(assert (exec (action turnleft) (time ?t) (marks-a-path no)))
;)
;
;(defrule AGENT::move-step2-3
;	(declare (salience -22))
;	(AGENT::action (to_do ~save))
;	(MAIN::status (time ?t))
;	?f <- (movement (step ?x &2|3))
;	=>	
;	(modify ?f (step (+ ?x 1)))
;	(assert (exec (action turnright) (time ?t) (marks-a-path no)))
;)
;
;(defrule AGENT::move-step4
;	(declare (salience -22))
;	(AGENT::action (to_do ~save))
;	(MAIN::status (time ?t))
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
;(deftemplate STANDARD-MOVE::loop-prevention (slot pos-r) (slot pos-c) (slot direction) (slot action) (slot counter))


; Inizio nuova gestione --- Omar 01/10/2005
; Il robot può sfondare i vicoli ciechi logici (la celle ai suoi lati sono già state visitate o sono blocchi)
; la prima volta, la volta successiva che transita nella medesima cella (proveniendo dalla stessa direzione)
; viene fatto ruotare prima verso sx, alla volta successiva a dx e infine viene nuovamente forzato il blocco
; logico fancedolo proseguire nella direzione da cui proviene
; modificato (e corretto) il 28/12/2005

; Regola per gestire i vicoli ciechi logici cioe' le situazioni in cui ho visitato tutte le celle
; adiacenti alla posizione corrente del robot. In questo caso, proseguo nella direzione in cui il 
; robot e' rivolto

;(defrule STANDARD-MOVE::blindalley-logical-first
;	(declare (salience -18))	
;	?f <- (AGENT::movement (step 0))
;	(AGENT::action (to_do ?act))
;	(MAIN::status (time ?t))
;	(AGENT::kpos (time ?t) (pos-r ?r) (pos-c ?c) (direction ?d) (load ?))
;	(not (STANDARD-MOVE::loop-prevention (pos-r ?r) (pos-c ?c) (direction ?d)))
;	(or
;		; direzione UP
;		(and
;			(test (= (str-compare ?d up) 0))
;			(MAIN::exec-path (time ~2) (pos-r ?r1) (pos-c ?c) (module ?act))
;			(test (= (- ?r 1) ?r1))
;			(or 
;				(AGENT::map (pos-r ?r) (pos-c ?c1) (contains wall|entry|exit))
;				(MAIN::exec-path (time ~2) (pos-r ?r) (pos-c ?c1) (module ?act))
;			)				
;			(test (= (- ?c 1) ?c1))			
;			(or 
;				(AGENT::map (pos-r ?r) (pos-c ?c2) (contains wall|entry|exit))
;				(MAIN::exec-path (time ~2) (pos-r ?r) (pos-c ?c2) (module ?act))
;			)				
;			(test (= (+ ?c 1) ?c2))
;	        )
;		; direzione DOWN
;		(and
;			(test (= (str-compare ?d down) 0))
;			(MAIN::exec-path (time ~2) (pos-r ?r1) (pos-c ?c) (module ?act))
;			(test (= (+ ?r 1) ?r1))
;			(or 
;				(AGENT::map (pos-r ?r) (pos-c ?c1) (contains wall|entry|exit))
;				(MAIN::exec-path (time ~2) (pos-r ?r) (pos-c ?c1) (module ?act))
;			)				
;			(test (= (+ ?c 1) ?c1))
;			(or 
;				(AGENT::map (pos-r ?r) (pos-c ?c2) (contains wall|entry|exit))
;				(MAIN::exec-path (time ~2) (pos-r ?r) (pos-c ?c2) (module ?act))
;			)				
;			(test (= (- ?c 1) ?c2))		
;	        )
;		; direzione LEFT
;		(and
;			(test (= (str-compare ?d left) 0))
;			(MAIN::exec-path (time ~2) (pos-r ?r) (pos-c ?c1) (module ?act))
;			(test (= (- ?c 1) ?c1))
;			(or 
;				(AGENT::map (pos-r ?r1) (pos-c ?c) (contains wall|entry|exit))
;				(MAIN::exec-path (time ~2) (pos-r ?r1) (pos-c ?c) (module ?act))
;			)				
;			(test (= (- ?r 1) ?r1))
;			(or 
;				(AGENT::map (pos-r ?r2) (pos-c ?c) (contains wall|entry|exit))
;				(MAIN::exec-path (time ~2) (pos-r ?r2) (pos-c ?c) (module ?act))
;			)				
;			(test (= (+ ?r 1) ?r2))
;	    	)
;		; direzione RIGHT
;		(and
;			(test (= (str-compare ?d right) 0))
;			(MAIN::exec-path (time ~2) (pos-r ?r) (pos-c ?c1) (module ?act))
;			(test (= (+ ?c 1) ?c1))
;			(or 
;				(AGENT::map (pos-r ?r1) (pos-c ?c) (contains wall|entry|exit))
;				(MAIN::exec-path (time ~2) (pos-r ?r1) (pos-c ?c) (module ?act))
;			)				
;			(test (= (+ ?r 1) ?r1))
;			(or 
;				(AGENT::map (pos-r ?r2) (pos-c ?c) (contains wall|entry|exit))
;				(MAIN::exec-path (time ~2) (pos-r ?r2) (pos-c ?c) (module ?act))
;			)				
;			(test (= (- ?r 1) ?r2))
;	    	)
;	)
;	(not (AGENT::move-completed  (time ?)))
;	=>
;	(assert (MAIN::exec (action go)(time ?t)))
;	(assert (AGENT::move-completed (time ?t)))
;	(assert (STANDARD-MOVE::loop-prevention (pos-r ?r) (pos-c ?c) (direction ?d) (action go) (counter 0)))
;	(modify ?f (step 1))
;	(pop-focus)
;)

; OMAR 12/11/2005 - Questa regola si attiva solo quando è già stato sfondato un vicolo cieco logico
; ma non sono stati fatti abbastanza passaggi per cambiare strada (e quindi girare a sinistra)
(defrule STANDARD-MOVE::blindalley-logical-go
	(declare (salience -18))	
	?f <- (AGENT::movement (step 0))
	(AGENT::action (to_do ?act))
	(MAIN::status (time ?t))
	(AGENT::kpos (time ?t) (pos-r ?r) (pos-c ?c) (direction ?d) (load ?))
	?f1 <- (STANDARD-MOVE::loop-prevention (pos-r ?r) (pos-c ?c) (direction ?d) (action go|turnright) (counter ?cnt))
	(test (< ?cnt 2))	
	(or
		; direzione UP
		(and
			(test (= (str-compare ?d up) 0))
			(MAIN::exec-path (time ~2) (pos-r ?r1) (pos-c ?c) (module ?act))
			(test (= (- ?r 1) ?r1))
			(or 
				(AGENT::map (pos-r ?r) (pos-c ?c1) (contains wall|entry|exit))
				(MAIN::exec-path (time ~2) (pos-r ?r) (pos-c ?c1) (module ?act))
			)				
			(test (= (- ?c 1) ?c1))			
			(or 
				(AGENT::map (pos-r ?r) (pos-c ?c2) (contains wall|entry|exit))
				(MAIN::exec-path (time ~2) (pos-r ?r) (pos-c ?c2) (module ?act))
			)				
			(test (= (+ ?c 1) ?c2))
	        )
		; direzione DOWN
		(and
			(test (= (str-compare ?d down) 0))
			(MAIN::exec-path (time ~2) (pos-r ?r1) (pos-c ?c) (module ?act))
			(test (= (+ ?r 1) ?r1))
			(or 
				(AGENT::map (pos-r ?r) (pos-c ?c1) (contains wall|entry|exit))
				(MAIN::exec-path (time ~2) (pos-r ?r) (pos-c ?c1) (module ?act))
			)				
			(test (= (+ ?c 1) ?c1))
			(or 
				(AGENT::map (pos-r ?r) (pos-c ?c2) (contains wall|entry|exit))
				(MAIN::exec-path (time ~2) (pos-r ?r) (pos-c ?c2) (module ?act))
			)				
			(test (= (- ?c 1) ?c2))		
	        )
		; direzione LEFT
		(and
			(test (= (str-compare ?d left) 0))
			(MAIN::exec-path (time ~2) (pos-r ?r) (pos-c ?c1) (module ?act))
			(test (= (- ?c 1) ?c1))
			(or 
				(AGENT::map (pos-r ?r1) (pos-c ?c) (contains wall|entry|exit))
				(MAIN::exec-path (time ~2) (pos-r ?r1) (pos-c ?c) (module ?act))
			)				
			(test (= (- ?r 1) ?r1))
			(or 
				(AGENT::map (pos-r ?r2) (pos-c ?c) (contains wall|entry|exit))
				(MAIN::exec-path (time ~2) (pos-r ?r2) (pos-c ?c) (module ?act))
			)				
			(test (= (+ ?r 1) ?r2))
	    	)
		; direzione RIGHT
		(and
			(test (= (str-compare ?d right) 0))
			(MAIN::exec-path (time ~2) (pos-r ?r) (pos-c ?c1) (module ?act))
			(test (= (+ ?c 1) ?c1))
			(or 
				(AGENT::map (pos-r ?r1) (pos-c ?c) (contains wall|entry|exit))
				(MAIN::exec-path (time ~2) (pos-r ?r1) (pos-c ?c) (module ?act))
			)				
			(test (= (+ ?r 1) ?r1))
			(or 
				(AGENT::map (pos-r ?r2) (pos-c ?c) (contains wall|entry|exit))
				(MAIN::exec-path (time ~2) (pos-r ?r2) (pos-c ?c) (module ?act))
			)				
			(test (= (- ?r 1) ?r2))
	    	)
	)
	(not (AGENT::move-completed  (time ?)))
	=>
	(assert (MAIN::exec (action go)(time ?t)))
	(assert (AGENT::move-completed (time ?t)))
	(modify ?f1 (counter (+ ?cnt 1)))
	(modify ?f (step 1))
	(pop-focus)
)

; Al passo precedente è stato forzato il vicolo cieco, adesso si svolta a sx
(defrule STANDARD-MOVE::blindalley-logical-turnleft
	(declare (salience -18))	
	?f <- (AGENT::movement (step 0))
	(AGENT::action (to_do ?act))
	(MAIN::status (time ?t))
	(AGENT::kpos (time ?t) (pos-r ?r) (pos-c ?c) (direction ?d) (load ?))
	?f1 <- (STANDARD-MOVE::loop-prevention (pos-r ?r) (pos-c ?c) (direction ?d) (action go) (counter ?cnt))
	(test (>= ?cnt 2))
	(or
		; direzione UP
		(and
			(test (= (str-compare ?d up) 0))
			(MAIN::exec-path (time ~2) (pos-r ?r1) (pos-c ?c) (module ?act))
			(test (= (- ?r 1) ?r1))
			(or 
				(AGENT::map (pos-r ?r) (pos-c ?c1) (contains wall|entry|exit))
				(MAIN::exec-path (time ~2) (pos-r ?r) (pos-c ?c1) (module ?act))
			)				
			(test (= (- ?c 1) ?c1))			
			(or 
				(AGENT::map (pos-r ?r) (pos-c ?c2) (contains wall|entry|exit))
				(MAIN::exec-path (time ~2) (pos-r ?r) (pos-c ?c2) (module ?act))
			)				
			(test (= (+ ?c 1) ?c2))
	        )
		; direzione DOWN
		(and
			(test (= (str-compare ?d down) 0))
			(MAIN::exec-path (time ~2) (pos-r ?r1) (pos-c ?c) (module ?act))
			(test (= (+ ?r 1) ?r1))
			(or 
				(AGENT::map (pos-r ?r) (pos-c ?c1) (contains wall|entry|exit))
				(MAIN::exec-path (time ~2) (pos-r ?r) (pos-c ?c1) (module ?act))
			)				
			(test (= (+ ?c 1) ?c1))
			(or 
				(AGENT::map (pos-r ?r) (pos-c ?c2) (contains wall|entry|exit))
				(MAIN::exec-path (time ~2) (pos-r ?r) (pos-c ?c2) (module ?act))
			)				
			(test (= (- ?c 1) ?c2))		
	        )
		; direzione LEFT
		(and
			(test (= (str-compare ?d left) 0))
			(MAIN::exec-path (time ~2) (pos-r ?r) (pos-c ?c1) (module ?act))
			(test (= (- ?c 1) ?c1))
			(or 
				(AGENT::map (pos-r ?r1) (pos-c ?c) (contains wall|entry|exit))
				(MAIN::exec-path (time ~2) (pos-r ?r1) (pos-c ?c) (module ?act))
			)				
			(test (= (- ?r 1) ?r1))
			(or 
				(AGENT::map (pos-r ?r2) (pos-c ?c) (contains wall|entry|exit))
				(MAIN::exec-path (time ~2) (pos-r ?r2) (pos-c ?c) (module ?act))
			)				
			(test (= (+ ?r 1) ?r2))
	    	)
		; direzione RIGHT
		(and
			(test (= (str-compare ?d right) 0))
			(MAIN::exec-path (time ~2) (pos-r ?r) (pos-c ?c1) (module ?act))
			(test (= (+ ?c 1) ?c1))
			(or 
				(AGENT::map (pos-r ?r1) (pos-c ?c) (contains wall|entry|exit))
				(MAIN::exec-path (time ~2) (pos-r ?r1) (pos-c ?c) (module ?act))
			)				
			(test (= (+ ?r 1) ?r1))
			(or 
				(AGENT::map (pos-r ?r2) (pos-c ?c) (contains wall|entry|exit))
				(MAIN::exec-path (time ~2) (pos-r ?r2) (pos-c ?c) (module ?act))
			)				
			(test (= (- ?r 1) ?r2))
	    	)
	)
	(not (AGENT::move-completed  (time ?)))
	=>
	(assert (MAIN::exec (action turnleft)(time ?t)))
	(assert (AGENT::move-completed (time ?t)))
	(modify ?f1 (action turnleft))
	(modify ?f (step 1))
	(pop-focus)
)

; Al passo precedente si è svoltato a sx, adesso si svolta a dx
(defrule STANDARD-MOVE::blindalley-logical-turnright
	(declare (salience -18))	
	?f <- (AGENT::movement (step 0))
	(AGENT::action (to_do ?act))
	(MAIN::status (time ?t))
	(AGENT::kpos (time ?t) (pos-r ?r) (pos-c ?c) (direction ?d) (load ?))
	?f1 <- (STANDARD-MOVE::loop-prevention (pos-r ?r) (pos-c ?c) (direction ?d) (action turnleft))
	(or
		; direzione UP
		(and
			(test (= (str-compare ?d up) 0))
			(MAIN::exec-path (time ~2) (pos-r ?r1) (pos-c ?c) (module ?act))
			(test (= (- ?r 1) ?r1))
			(or 
				(AGENT::map (pos-r ?r) (pos-c ?c1) (contains wall|entry|exit))
				(MAIN::exec-path (time ~2) (pos-r ?r) (pos-c ?c1) (module ?act))
			)				
			(test (= (- ?c 1) ?c1))			
			(or 
				(AGENT::map (pos-r ?r) (pos-c ?c2) (contains wall|entry|exit))
				(MAIN::exec-path (time ~2) (pos-r ?r) (pos-c ?c2) (module ?act))
			)				
			(test (= (+ ?c 1) ?c2))
	        )
		; direzione DOWN
		(and
			(test (= (str-compare ?d down) 0))
			(MAIN::exec-path (time ~2) (pos-r ?r1) (pos-c ?c) (module ?act))
			(test (= (+ ?r 1) ?r1))
			(or 
				(AGENT::map (pos-r ?r) (pos-c ?c1) (contains wall|entry|exit))
				(MAIN::exec-path (time ~2) (pos-r ?r) (pos-c ?c1) (module ?act))
			)				
			(test (= (+ ?c 1) ?c1))
			(or 
				(AGENT::map (pos-r ?r) (pos-c ?c2) (contains wall|entry|exit))
				(MAIN::exec-path (time ~2) (pos-r ?r) (pos-c ?c2) (module ?act))
			)				
			(test (= (- ?c 1) ?c2))		
	        )
		; direzione LEFT
		(and
			(test (= (str-compare ?d left) 0))
			(MAIN::exec-path (time ~2) (pos-r ?r) (pos-c ?c1) (module ?act))
			(test (= (- ?c 1) ?c1))
			(or 
				(AGENT::map (pos-r ?r1) (pos-c ?c) (contains wall|entry|exit))
				(MAIN::exec-path (time ~2) (pos-r ?r1) (pos-c ?c) (module ?act))
			)				
			(test (= (- ?r 1) ?r1))
			(or 
				(AGENT::map (pos-r ?r2) (pos-c ?c) (contains wall|entry|exit))
				(MAIN::exec-path (time ~2) (pos-r ?r2) (pos-c ?c) (module ?act))
			)				
			(test (= (+ ?r 1) ?r2))
	    	)
		; direzione RIGHT
		(and
			(test (= (str-compare ?d right) 0))
			(MAIN::exec-path (time ~2) (pos-r ?r) (pos-c ?c1) (module ?act))
			(test (= (+ ?c 1) ?c1))
			(or 
				(AGENT::map (pos-r ?r1) (pos-c ?c) (contains wall|entry|exit))
				(MAIN::exec-path (time ~2) (pos-r ?r1) (pos-c ?c) (module ?act))
			)				
			(test (= (+ ?r 1) ?r1))
			(or 
				(AGENT::map (pos-r ?r2) (pos-c ?c) (contains wall|entry|exit))
				(MAIN::exec-path (time ~2) (pos-r ?r2) (pos-c ?c) (module ?act))
			)				
			(test (= (- ?r 1) ?r2))
	    	)
	)
	(not (AGENT::move-completed  (time ?)))
	=>
	(assert (MAIN::exec (action turnright)(time ?t)))
	(assert (AGENT::move-completed (time ?t)))
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
;(defrule STANDARD-MOVE::turn-default-first-logical
;	(declare (salience -18))
;	?f <- (AGENT::movement (step 0))
;	(AGENT::action (to_do ?act))
;	(MAIN::status (time ?t))
;	(MAIN::percepts (time ?t) (pos-r ?r)(pos-c ?c)(direction ?d)(perc1 wall|entry|exit)(perc2 ?p2)(perc3 ?p3)(cry ?))
;	(not (STANDARD-MOVE::default-choice-logical (pos-r ?r)(pos-c ?c)))
;	(or
;		(and
;			(test (= (str-compare ?d left) 0))
;			(MAIN::exec-path (time ?) (pos-r ?r1) (pos-c ?c) (module ?act))
;			(MAIN::exec-path (time ?) (pos-r ?r2) (pos-c ?c) (module ?act))
;			(test (= (- ?r 1) ?r1))
;			(test (= (+ ?r 1) ?r2))
;		)
;		(and
;			(test (= (str-compare ?d right) 0))
;			(MAIN::exec-path (time ?) (pos-r ?r1) (pos-c ?c) (module ?act))
;			(MAIN::exec-path (time ?) (pos-r ?r2) (pos-c ?c) (module ?act))
;			(test (= (- ?r 1) ?r1))
;			(test (= (+ ?r 1) ?r2))
;		)
;
;		(and
;			(test (= (str-compare ?d up) 0))
;			(MAIN::exec-path (time ?) (pos-r ?r) (pos-c ?c1) (module ?act))
;			(MAIN::exec-path (time ?) (pos-r ?r) (pos-c ?c2) (module ?act))
;			(test (= (- ?c 1) ?c1))
;			(test (= (+ ?c 1) ?c2))
;		)
;		(and
;			(test (= (str-compare ?d down) 0))
;			(MAIN::exec-path (time ?) (pos-r ?r) (pos-c ?c1) (module ?act))
;			(MAIN::exec-path (time ?) (pos-r ?r) (pos-c ?c2) (module ?act))
;			(test (= (- ?c 1) ?c1))
;			(test (= (+ ?c 1) ?c2))
;		)
;	)
;	(not (AGENT::move-completed  (time ?)))
;	=>
;	(assert (MAIN::exec (action turnleft)(time ?t)))
;	(assert (AGENT::move-completed (time ?t)))
;	(modify ?f (step 1))
;	(assert (STANDARD-MOVE::default-choice-logical (pos-r ?r) (pos-c ?c) (direction ?d) (choice left)))
;	(pop-focus)
;)

; Regola per gestire le scelte successive
; rotazione precedente verso destra --> adesso bisogna andare a sinistra
;(defrule STANDARD-MOVE::turn-default-left-logical
;	(declare (salience -18))
;	?f <- (AGENT::movement (step 0))
;	(AGENT::action (to_do ?act))
;	(MAIN::status (time ?t))
;	(MAIN::percepts (time ?t) (pos-r ?r)(pos-c ?c)(direction ?d)(perc1 wall|entry|exit)(perc2 ?p2)(perc3 ?p3)(cry ?))
;	?f1 <- (STANDARD-MOVE::default-choice-logical (pos-r ?r)(pos-c ?c)(direction ?d)(choice right))
;	(or
;		(and
;			(test (= (str-compare ?d left) 0))
;			(MAIN::exec-path (time ?) (pos-r ?r1) (pos-c ?c) (module ?act))
;			(MAIN::exec-path (time ?) (pos-r ?r2) (pos-c ?c) (module ?act))
;			(test (= (- ?r 1) ?r1))
;			(test (= (+ ?r 1) ?r2))
;		)
;		(and
;			(test (= (str-compare ?d right) 0))
;			(MAIN::exec-path (time ?) (pos-r ?r1) (pos-c ?c) (module ?act))
;			(MAIN::exec-path (time ?) (pos-r ?r2) (pos-c ?c) (module ?act))
;			(test (= (- ?r 1) ?r1))
;			(test (= (+ ?r 1) ?r2))
;		)
;
;		(and
;			(test (= (str-compare ?d up) 0))
;			(MAIN::exec-path (time ?) (pos-r ?r) (pos-c ?c1) (module ?act))
;			(MAIN::exec-path (time ?) (pos-r ?r) (pos-c ?c2) (module ?act))
;			(test (= (- ?c 1) ?c1))
;			(test (= (+ ?c 1) ?c2))
;		)
;		(and
;			(test (= (str-compare ?d down) 0))
;			(MAIN::exec-path (time ?) (pos-r ?r) (pos-c ?c1) (module ?act))
;			(MAIN::exec-path (time ?) (pos-r ?r) (pos-c ?c2) (module ?act))
;			(test (= (- ?c 1) ?c1))
;			(test (= (+ ?c 1) ?c2))
;		)
;	)
;	(not (AGENT::move-completed  (time ?)))
;	=>
;	(assert (MAIN::exec (action turnleft)(time ?t)))
;	(assert (AGENT::move-completed (time ?t)))
;	(modify ?f (step 1))
;	(modify ?f1 (choice left))
;	(pop-focus)
;)

; Regola per gestire le scelte successive
; rotazione precedente verso sinistra --> adesso bisogna andare a destra
;(defrule STANDARD-MOVE::turn-default-right-logical
;	(declare (salience -18))
;	?f <- (AGENT::movement (step 0))
;	(AGENT::action (to_do ?act))
;	(MAIN::status (time ?t))
;	(MAIN::percepts (time ?t) (pos-r ?r)(pos-c ?c)(direction ?d)(perc1 wall|entry|exit)(perc2 ?p2)(perc3 ?p3)(cry ?))
;	?f1 <- (STANDARD-MOVE::default-choice-logical (pos-r ?r)(pos-c ?c)(direction ?d)(choice left))
;	(or
;		(and
;			(test (= (str-compare ?d left) 0))
;			(MAIN::exec-path (time ?) (pos-r ?r1) (pos-c ?c) (module ?act))
;			(MAIN::exec-path (time ?) (pos-r ?r2) (pos-c ?c) (module ?act))
;			(test (= (- ?r 1) ?r1))
;			(test (= (+ ?r 1) ?r2))
;		)
;		(and
;			(test (= (str-compare ?d right) 0))
;			(MAIN::exec-path (time ?) (pos-r ?r1) (pos-c ?c) (module ?act))
;			(MAIN::exec-path (time ?) (pos-r ?r2) (pos-c ?c) (module ?act))
;			(test (= (- ?r 1) ?r1))
;			(test (= (+ ?r 1) ?r2))
;		)
;
;		(and
;			(test (= (str-compare ?d up) 0))
;			(MAIN::exec-path (time ?) (pos-r ?r) (pos-c ?c1) (module ?act))
;			(MAIN::exec-path (time ?) (pos-r ?r) (pos-c ?c2) (module ?act))
;			(test (= (- ?c 1) ?c1))
;			(test (= (+ ?c 1) ?c2))
;		)
;		(and
;			(test (= (str-compare ?d down) 0))
;			(MAIN::exec-path (time ?) (pos-r ?r) (pos-c ?c1) (module ?act))
;			(MAIN::exec-path (time ?) (pos-r ?r) (pos-c ?c2) (module ?act))
;			(test (= (- ?c 1) ?c1))
;			(test (= (+ ?c 1) ?c2))
;		)
;	)
;	(not (AGENT::move-completed  (time ?)))
;	=>
;	(assert (MAIN::exec (action turnright)(time ?t)))
;	(assert (AGENT::move-completed (time ?t)))
;	(modify ?f (step 1))
;	(modify ?f1 (choice right))
;	(pop-focus)
;)


; ---------------- modulo PLAN2 --------------------

;(defmodule PLAN2);(import PLAN ?ALL)(export ?ALL))
(defrule PLAN2::got-solution
	(declare (salience 100))
	(PLAN::solution (value yes))
	=> 
	(assert (PLAN::resolved))
	(pop-focus)
)

; -------------------------- AZIONE go -------------------

;(defrule pick
;   (status ?s on ?x ?y)
;   (status ?s clear ?x ?)
;   (status ?s handempty ? ?)
;   (maxdepth ?d)
;    (test (< ?s ?d))
;      (not (to-do ?s pick ?x ?y)) 
;   => (assert (apply ?s pick ?x ?y)))
(defrule PLAN2::go
	(PLAN::virtual-pos (time ?s) (pos-r ?r) (pos-c ?c) (direction ?dir))
	(or
		(and 
			(test (= (str-compare ?d up) 0))
			(or 
				(AGENT::map (pos-r ?new-r) (pos-c ?new-c) (contains ~wall&~entry))
				(AGENT::unuseful-cell (pos-r ?new-r) (pos-c ?new-c))
			)
			(test (= ?new-r (- ?r 1)))
		)
		
		(and 
			(test (= (str-compare ?d down) 0))
			(or
				(AGENT::map (pos-r ?new-r) (pos-c ?new-c) (contains ~wall&~entry))
				(AGENT::unuseful-cell (pos-r ?new-r) (pos-c ?new-c))
			)
			(test (= ?new-r (+ ?r 1)))
		)
		
		(and 
			(test (= (str-compare ?d left) 0))
			(or
				(AGENT::map (pos-r ?new-r) (pos-c ?new-c) (contains ~wall&~entry))
				(AGENT::unuseful-cell (pos-r ?new-r) (pos-c ?new-c))
			)
			(test (= ?new-c (- ?c 1)))
		)
		
		(and 
			(test (= (str-compare ?d right) 0))
			(or
				(AGENT::map (pos-r ?new-r) (pos-c ?new-c) (contains ~wall&~entry))
				(AGENT::unuseful-cell (pos-r ?new-r) (pos-c ?new-c))
			)
			(test (= ?new-c (+ ?c 1)))
		)
	)
	(PLAN::maxdepth ?d)
	(test (< ?s ?d))
	(not (PLAN::to-do (time ?s) (action go))) 
	=>
	(assert (PLAN::apply (time?s) (pos-r ?new-r) (pos-c ?new-c) (direction ?dir) (action go)))
)

;(defrule apply-pick3
;?f <- (apply ?s pick ?x ?y)
; =>    (retract ?f)
;      (assert (delete ?s on ?x ?y))
;      (assert (delete ?s clear ?x NA))
;      (assert (delete ?s handempty NA NA))
;      (assert (status (+ ?s 1) clear ?y NA))
;      (assert (status (+ ?s 1) holding ?x NA))
;      (assert (current ?s))
;      (assert (news (+ ?s 1)))
;      (focus CHECK)
;      (assert (to-do ?s pick ?x ?y )))
(defrule PLAN2::apply-go
	?f <- (PLAN::apply (time ?s) (pos-r ?r) (pos-c ?c) (direction ?dir) (action go))
	=>
	(retract ?f)
	(assert (PLAN::delete (time ?s) (pos-r ?r) (pos-c ?c) (direction ?dir) (action go)))
	(assert (PLAN::virtual-pos (time (+ ?s 1)) (pos-r ?r) (pos-c ?c) (direction ?dir)))
	(assert (PLAN::current ?s))
	(assert (PLAN::newstate (+ ?s 1)))
	(assert (PLAN::to-do (time ?s) (action go))))
	(set-current-module CHECK) (focus CHECK)
)

;(defrule apply-pick1
;		(declare (salience 2))
;        (apply ?s pick ?x ?y)
; ?f <-  (status ?t ? ? ?)
;        (test (> ?t ?s))
; =>     (retract ?f))
(defrule PLAN2::go-delete-to-do
	(declare (salience 1))
	(PLAN::apply (time ?s) (action go))
	?f <- (PLAN::to-do (time ?t))
	(test (> ?t ?s))
	=>
	(retract ?f)
)

;(defrule apply-pick2
;		(declare (salience 1))
;       (apply ?s pick ?x ?y)
;?f <-  (to-do ?t ? ? ?)
;       (test (> ?t ?s))
; =>    (retract ?f))
(defrule PLAN2::go-delete-position
	(declare (salience 2))
	;(apply ?s pick ?x ?y)
	;?f <-  (status ?t ? ? ?)
	(PLAN::apply (time ?s) (action go))
	?f <- (PLAN::virtual-pos (time ?t))
	(test (> ?t ?s))
	=>
	(retract ?f)
)









; -------------------------- AZIONE turnleft -------------------

;(defrule pick
;   (status ?s on ?x ?y)
;   (status ?s clear ?x ?)
;   (status ?s handempty ? ?)
;   (maxdepth ?d)
;    (test (< ?s ?d))
;      (not (to-do ?s pick ?x ?y)) 
;   => (assert (apply ?s pick ?x ?y)))

; La salience più alta serve a fare in modo che a fronte di vicoli ciechi
; si attivi sempre la rotazione a sinistra piuttosto che lasciar decidere
; al motore inferenziale
(defrule PLAN2::turnleft-up
	(declare (salience 1))
	(PLAN::virtual-pos (time ?s) (pos-r ?r) (pos-c ?c) (direction up))
	(or 
		(AGENT::map (pos-r ?r) (pos-c ?c1) (contains ~wall&~entry))
		(AGENT::unuseful-cell (pos-r ?r) (pos-c ?c1))
	)
	(test (= ?c1 (- ?c 1)))
	(PLAN::maxdepth ?d)
	(test (< ?s ?d))
	(not (PLAN::to-do (time ?s) (action turnleft))) 
	=>
	(assert (PLAN::apply (time?s) (pos-r ?r) (pos-c ?c) (direction left) (action turnleft)))
)
		
(defrule PLAN2::turnleft-down
	(PLAN::virtual-pos (time ?s) (pos-r ?r) (pos-c ?c) (direction down))
	(or 
		(AGENT::map (pos-r ?r) (pos-c ?c1) (contains ~wall&~entry))
		(AGENT::unuseful-cell (pos-r ?r) (pos-c ?c1))
	)
	(test (= ?c1 (+ ?c 1)))
	(PLAN::maxdepth ?d)
	(test (< ?s ?d))
	(not (PLAN::to-do (time ?s) (action turnleft))) 
	=>
	(assert (PLAN::apply (time?s) (pos-r ?r) (pos-c ?c) (direction right) (action turnleft)))
)

(defrule PLAN2::turnleft-left
	(PLAN::virtual-pos (time ?s) (pos-r ?r) (pos-c ?c) (direction left))
	(or 
		(AGENT::map (pos-r ?r1) (pos-c ?c) (contains ~wall&~entry))
		(AGENT::unuseful-cell (pos-r ?r1) (pos-c ?c))
	)
	(test (= ?r1 (+ ?r 1)))
	(PLAN::maxdepth ?d)
	(test (< ?s ?d))
	(not (PLAN::to-do (time ?s) (action turnleft))) 
	=>
	(assert (PLAN::apply (time?s) (pos-r ?r) (pos-c ?c) (direction down) (action turnleft)))
)

(defrule PLAN2::turnleft-right
	(PLAN::virtual-pos (time ?s) (pos-r ?r) (pos-c ?c) (direction right))
	(or 
		(AGENT::map (pos-r ?r1) (pos-c ?c) (contains ~wall&~entry))
		(AGENT::unuseful-cell (pos-r ?r1) (pos-c ?c))
	)
	(test (= ?r1 (- ?r 1)))
	(PLAN::maxdepth ?d)
	(PLAN::maxdepth ?d)
	(test (< ?s ?d))
	(not (PLAN::to-do (time ?s) (action turnleft))) 
	=>
	(assert (PLAN::apply (time?s) (pos-r ?r) (pos-c ?c) (direction up) (action turnleft)))
)

;(defrule apply-pick3
;?f <- (apply ?s pick ?x ?y)
; =>    (retract ?f)
;      (assert (delete ?s on ?x ?y))
;      (assert (delete ?s clear ?x NA))
;      (assert (delete ?s handempty NA NA))
;      (assert (status (+ ?s 1) clear ?y NA))
;      (assert (status (+ ?s 1) holding ?x NA))
;      (assert (current ?s))
;      (assert (news (+ ?s 1)))
;      (focus CHECK)
;      (assert (to-do ?s pick ?x ?y )))
(defrule PLAN2::apply-turnleft
	?f <- (PLAN::apply (time ?s) (pos-r ?r) (pos-c ?c) (direction ?dir) (action turnleft))
	=>
	(retract ?f)
	(assert (PLAN::delete (time ?s) (pos-r ?r) (pos-c ?c) (direction ?dir) (action turnleft)))
	(assert (PLAN::virtual-pos (time (+ ?s 1)) (pos-r ?r) (pos-c ?c) (direction ?dir)))
	(assert (PLAN::current ?s))
	(assert (PLAN::newstate (+ ?s 1)))
	(assert (PLAN::to-do (time ?s) (action turnleft))))
	(set-current-module CHECK) (focus CHECK)
)

;(defrule apply-pick1
;		(declare (salience 2))
;        (apply ?s pick ?x ?y)
; ?f <-  (status ?t ? ? ?)
;        (test (> ?t ?s))
; =>     (retract ?f))
(defrule PLAN2::turnleft-delete-to-do
	(declare (salience 1))
	(PLAN::apply (time ?s) (action turnleft))
	?f <- (PLAN::to-do (time ?t))
	(test (> ?t ?s))
	=>
	(retract ?f)
)

;(defrule apply-pick2
;		(declare (salience 1))
;       (apply ?s pick ?x ?y)
;?f <-  (to-do ?t ? ? ?)
;       (test (> ?t ?s))
; =>    (retract ?f))
(defrule PLAN2::turnleft-delete-position
	(declare (salience 2))
	;(apply ?s pick ?x ?y)
	;?f <-  (status ?t ? ? ?)
	(PLAN::apply (time ?s) (action turnleft))
	?f <- (PLAN::virtual-pos (time ?t))
	(test (> ?t ?s))
	=>
	(retract ?f)
)


; -------------------------- AZIONE turnright -------------------

;(defrule pick
;   (status ?s on ?x ?y)
;   (status ?s clear ?x ?)
;   (status ?s handempty ? ?)
;   (maxdepth ?d)
;    (test (< ?s ?d))
;      (not (to-do ?s pick ?x ?y)) 
;   => (assert (apply ?s pick ?x ?y)))
(defrule PLAN2::turnright-up
	(PLAN::virtual-pos (time ?s) (pos-r ?r) (pos-c ?c) (direction up))
	(or 
		(AGENT::map (pos-r ?r) (pos-c ?c1) (contains ~wall&~entry))
		(AGENT::unuseful-cell (pos-r ?r) (pos-c ?c1))
	)
	(test (= ?c1 (+ ?c 1)))
	(PLAN::maxdepth ?d)
	(test (< ?s ?d))
	(not (PLAN::to-do (time ?s) (action turnright))) 
	=>
	(assert (PLAN::apply (time?s) (pos-r ?r) (pos-c ?c) (direction right) (action turnleft)))
)
		
(defrule PLAN2::turnright-down
	(PLAN::virtual-pos (time ?s) (pos-r ?r) (pos-c ?c) (direction down))
	(or 
		(AGENT::map (pos-r ?r) (pos-c ?c1) (contains ~wall&~entry))
		(AGENT::unuseful-cell (pos-r ?r) (pos-c ?c1))
	)
	(test (= ?c1 (- ?c 1)))
	(PLAN::maxdepth ?d)
	(test (< ?s ?d))
	(not (PLAN::to-do (time ?s) (action turnright))) 
	=>
	(assert (PLAN::apply (time?s) (pos-r ?r) (pos-c ?c) (direction left) (action turnleft)))
)

(defrule PLAN2::turnright-left
	(PLAN::virtual-pos (time ?s) (pos-r ?r) (pos-c ?c) (direction left))
	(or 
		(AGENT::map (pos-r ?r1) (pos-c ?c) (contains ~wall&~entry))
		(AGENT::unuseful-cell (pos-r ?r1) (pos-c ?c))
	)
	(test (= ?r1 (- ?r 1)))
	(PLAN::maxdepth ?d)
	(test (< ?s ?d))
	(not (PLAN::to-do (time ?s) (action turnright))) 
	=>
	(assert (PLAN::apply (time?s) (pos-r ?r) (pos-c ?c) (direction up) (action turnleft)))
)

(defrule PLAN2::turnright-right
	(PLAN::virtual-pos (time ?s) (pos-r ?r) (pos-c ?c) (direction right))
	(or 
		(AGENT::map (pos-r ?r1) (pos-c ?c) (contains ~wall&~entry))
		(AGENT::unuseful-cell (pos-r ?r1) (pos-c ?c))
	)
	(test (= ?r1 (+ ?r 1)))
	(PLAN::maxdepth ?d)
	(PLAN::maxdepth ?d)
	(test (< ?s ?d))
	(not (PLAN::to-do (time ?s) (action turnright))) 
	=>
	(assert (PLAN::apply (time?s) (pos-r ?r) (pos-c ?c) (direction down) (action turnleft)))
)

;(defrule apply-pick3
;?f <- (apply ?s pick ?x ?y)
; =>    (retract ?f)
;      (assert (delete ?s on ?x ?y))
;      (assert (delete ?s clear ?x NA))
;      (assert (delete ?s handempty NA NA))
;      (assert (status (+ ?s 1) clear ?y NA))
;      (assert (status (+ ?s 1) holding ?x NA))
;      (assert (current ?s))
;      (assert (news (+ ?s 1)))
;      (focus CHECK)
;      (assert (to-do ?s pick ?x ?y )))
(defrule PLAN2::apply-turnright
	?f <- (PLAN::apply (time ?s) (pos-r ?r) (pos-c ?c) (direction ?dir) (action turnright))
	=>
	(retract ?f)
	(assert (PLAN::delete (time ?s) (pos-r ?r) (pos-c ?c) (direction ?dir) (action turnright)))
	(assert (PLAN::virtual-pos (time (+ ?s 1)) (pos-r ?r) (pos-c ?c) (direction ?dir)))
	(assert (PLAN::current ?s))
	(assert (PLAN::newstate (+ ?s 1)))
	(assert (PLAN::to-do (time ?s) (action turnright))))
	((set-current-module CHECK) (focus CHECK)
)

;(defrule apply-pick1
;		(declare (salience 2))
;        (apply ?s pick ?x ?y)
; ?f <-  (status ?t ? ? ?)
;        (test (> ?t ?s))
; =>     (retract ?f))
(defrule PLAN2::turnright-delete-to-do
	(declare (salience 1))
	(PLAN::apply (time ?s) (action turnright))
	?f <- (PLAN::to-do (time ?t))
	(test (> ?t ?s))
	=>
	(retract ?f)
)

;(defrule apply-pick2
;		(declare (salience 1))
;       (apply ?s pick ?x ?y)
;?f <-  (to-do ?t ? ? ?)
;       (test (> ?t ?s))
; =>    (retract ?f))
(defrule PLAN2::turnright-delete-position
	(declare (salience 2))
	;(apply ?s pick ?x ?y)
	;?f <-  (status ?t ? ? ?)
	(PLAN::apply (time ?s) (action turnright))
	?f <- (PLAN::virtual-pos (time ?t))
	(test (> ?t ?s))
	=>
	(retract ?f)
)
