)
; -------------------------- ROTAZIONE INIZIALE -------------------------- 
; Se mi trovo sull'entrata (e do per scontato che lo sono perche' all'inizio ci sono sopra)
; mi giro a dx e poi a sx (solo per ricevere le percezioni di TUTTE le celle davanti all'ingresso)
; ------------------------------------------------------------------------

(defrule discover-entry1
	(status (time 0))
	=>
	(assert (exec (action turnright)(time 0)))
)

(defrule discover-entry2
	(declare (salience 15))
	(status (time 1))
	(percepts (pos-r ?r) (pos-c ?c) (direction ?d))
	=>
	(assert (exec (action turnleft)(time 1)))
	(assert (movement (step 0)))
	(assert (last-position (time 1) (pos-r ?r) (pos-c ?c) (direction ?d)))
)


; ##--------------------- SELEZIONE DEL MODULO DA ATTIVARE ----------------##
(defrule active-explore
	(declare (salience 10))
	(status (time ?t) (result ~exit))
	(action (module explore))
	(movement (step 0))
	(not (exec (time ?t) (action ?)))
	=> 
	 (focus EXPLORE)
)
	
(defrule active-save
	(declare (salience 10))
	(status (time ?t) (result ~exit))
	(action (module save))
	(movement (step 0))
	(not (exec (time ?t) (action ?)))
	=> 
	 (focus SAVE)
)
	
(defrule active-exit
	(declare (salience 10))
	(status (time ?t) (result ~exit))
	(action (module exit))
	(movement (step 0))
	(not (exec (time ?t) (action ?)))
	=> 
	 (focus EXIT)
)

(defrule active-plan
	(declare (salience 10))
	(status (time ?t) (result ~exit))
	(movement (step 0))
	(action (module plan))
	=> 
	 (focus PLAN)
)

(defrule active-exec-plan
	(declare (salience 10))
	(status (time ?t) (result ~exit))
	(movement (step 0))
	(action (module exec-plan))
	=>
	(set-current-module EXEC-PLAN) (focus EXEC-PLAN)
)

; ##-----------------------------------------------------------------------##

; ##------------------------ ROTAZIONI DEL ROBOT --------------------------##
; NUOVA VERSIONE - Omar 06/09/2005

; In questa situazione si controlla se la cella immediatamente alla sx della posizione attuale
; contiene un blocco (wall, entry o exit). In questo caso la rotazione è inutile perchè non
; si scopre nulla di utile
;OMAR 18/01/2006 - gestione celle unuseful
(defrule rotate-left-forbidden
	(declare (salience -20))
	(action (module ~save))
	(status (time ?t))
	?f <- (movement (step 1))
	(percepts (time ?t) (pos-r ?r) (pos-c ?c) (direction ?d))
	;Controllo della situazione della mappa
	(or
		(and 
			(test (= (str-compare ?d up) 0))
			(or 
				(map (pos-r ?r) (pos-c ?c1) (contains wall|entry|exit))
				(unuseful-cell (pos-r ?r) (pos-c ?c1))
			)
			(test (= ?c1 (- ?c 1)))
		)
		
		(and 
			(test (= (str-compare ?d down) 0))
			(or
				(map (pos-r ?r) (pos-c ?c1) (contains wall|entry|exit))
				(unuseful-cell (pos-r ?r) (pos-c ?c1))
			)
			(test (= ?c1 (+ ?c 1)))
		)
		
		(and 
			(test (= (str-compare ?d left) 0))
			(or
				(map (pos-r ?r1) (pos-c ?c) (contains wall|entry|exit))
				(unuseful-cell (pos-r ?r1) (pos-c ?c))
			)
			(test (= ?r1 (+ ?r 1)))
		)
		
		(and 
			(test (= (str-compare ?d right) 0))
			(or
				(map (pos-r ?r1) (pos-c ?c) (contains wall|entry|exit))
				(unuseful-cell (pos-r ?r1) (pos-c ?c))
			)
			(test (= ?r1 (- ?r 1)))
		)
	)
	=>
	;(assert (exec (action turnleft) (time ?t) (marks-a-path no)))
	;(assert (restore-direction (action turnright)))
	(modify ?f (step 2))	;Non viene compiuta alcun mossa di rotazione
)

; In questa situazione si controlla se manca l'ultimea cella del raggio d'azione nella mappa interna al robot 
; in questo caso si evita la rotazione perchè potrebbe essere al di fuori della mappa. Oppure potrebbe
; essere nascosta dietro a un blocco (wall, entry, exit)
;OMAR 18/01/2006 - gestione celle unuseful
(defrule rotate-left-useless
	(declare (salience -21))
	(action (module ~save))
	(status (time ?t))
	?f <- (movement (step 1))
	(percepts (time ?t) (pos-r ?r) (pos-c ?c) (direction ?d))
	;Controllo della situazione della mappa
	(or
		(and 
			(test (= (str-compare ?d up) 0))
			(and
				(map (pos-r ?r) (pos-c ?c1) (contains ~wall&~entry&~exit))
				(not (unuseful-cell (pos-r ?r) (pos-c ?c1)))
			)
			(or
				(map (pos-r ?r) (pos-c ?c2) (contains wall|entry|exit))
				(unuseful-cell (pos-r ?r) (pos-c ?c2))
			)
			(test (= ?c1 (- ?c 1)))
			(test (= ?c2 (- ?c 2)))
		)
		
		(and 
			(test (= (str-compare ?d down) 0))
			(and
				(map (pos-r ?r) (pos-c ?c1) (contains ~wall&~entry&~exit))
				(not (unuseful-cell (pos-r ?r) (pos-c ?c1)))
			)
			(or
				(map (pos-r ?r) (pos-c ?c2) (contains wall|entry|exit))
				(unuseful-cell (pos-r ?r) (pos-c ?c2))
			)
			(test (= ?c1 (+ ?c 1)))
			(test (= ?c2 (+ ?c 2)))
		)
		
		(and 
			(test (= (str-compare ?d left) 0))
			(and
				(map (pos-r ?r1) (pos-c ?c) (contains ~wall&~entry&~exit))
				(not (unuseful-cell (pos-r ?r1) (pos-c ?c)))				
			)
			(or
				(map (pos-r ?r2) (pos-c ?c) (contains wall|entry|exit))
				(unuseful-cell (pos-r ?r2) (pos-c ?c))
			)
			(test (= ?r1 (+ ?r 1)))
			(test (= ?r2 (+ ?r 2)))
		)
		
		(and 
			(test (= (str-compare ?d right) 0))
			(and
				(map (pos-r ?r1) (pos-c ?c) (contains ~wall&~entry&~exit))
				(not (unuseful-cell (pos-r ?r1) (pos-c ?c)))				
			)
			(or
				(map (pos-r ?r2) (pos-c ?c) (contains wall|entry|exit))
				(unuseful-cell (pos-r ?r2) (pos-c ?c))
			)
			(test (= ?r1 (- ?r 1)))
			(test (= ?r2 (- ?r 2)))
		)
	)
	=>
	(modify ?f (step 2))	;Non viene compiuta alcun mossa di rotazione
)

; In questa situazione si controlla se si conosce il contenuto delle 3 celle alla sinistra del robot
; nel caso in cui anche solo una di queste sia sconosciuta, si applica la rotazione, in caso contrario
; si evita perchè fornirebbe informazioni di cui il robot è già in possesso
(defrule rotate-left
	(declare (salience -22))
	(action (module ~save))
	(status (time ?t))
	?f <- (movement (step 1))
	(percepts (time ?t) (pos-r ?r) (pos-c ?c) (direction ?d))
	;Controllo della situazione della mappa
	(or
		(and 
			(test (= (str-compare ?d up) 0))
			(not (and
				(map (pos-r ?r) (pos-c ?c1))
				(map (pos-r ?r) (pos-c ?c2))
				(map (pos-r ?r) (pos-c ?c3))
				(test (= ?c1 (- ?c 1)))
				(test (= ?c2 (- ?c 2)))
				(test (= ?c3 (- ?c 3)))			
			))
		)

		(and 
			(test (= (str-compare ?d down) 0))
			(not (and
				(map (pos-r ?r) (pos-c ?c1))
				(map (pos-r ?r) (pos-c ?c2))
				(map (pos-r ?r) (pos-c ?c3))
				(test (= ?c1 (+ ?c 1)))
				(test (= ?c2 (+ ?c 2)))
				(test (= ?c3 (+ ?c 3)))
			))
		)
		
		(and 
			(test (= (str-compare ?d left) 0))
			(not (and
				(map (pos-r ?r1) (pos-c ?c))
				(map (pos-r ?r2) (pos-c ?c))
				(map (pos-r ?r3) (pos-c ?c))
				(test (= ?r1 (+ ?r 1)))
				(test (= ?r2 (+ ?r 2)))
				(test (= ?r3 (+ ?r 3)))
			))				
		)
		
		(and 
			(test (= (str-compare ?d right) 0))
			(not (and
				(map (pos-r ?r1) (pos-c ?c))
				(map (pos-r ?r2) (pos-c ?c))
				(map (pos-r ?r3) (pos-c ?c))
				(test (= ?r1 (- ?r 1)))
				(test (= ?r2 (- ?r 2)))
				(test (= ?r3 (- ?r 3)))			
			))
		)
	)
	=>
	(assert (exec (action turnleft) (time ?t) (marks-a-path no)))
	(assert (restore-direction (action turnright)))
	
)

; Equivalente alla regola precedente ma considera la rotazione verso destra
;OMAR 18/01/2006 - gestione celle unuseful
(defrule rotate-right-useless
	(declare (salience -21))
	(action (module ~save))
	(status (time ?t))
	?f <- (movement (step 3))
	(percepts (time ?t) (pos-r ?r) (pos-c ?c) (direction ?d))
	;Controllo della situazione della mappa
	(or
		(and 
			(test (= (str-compare ?d down) 0))
			(and
				(map (pos-r ?r) (pos-c ?c1) (contains ~wall&~entry&~exit))
				(not (unuseful-cell (pos-r ?r) (pos-c ?c1)))					
			)
			(or
				(map (pos-r ?r) (pos-c ?c2) (contains wall|entry|exit))
				(unuseful-cell (pos-r ?r) (pos-c ?c2))				
			)
			(test (= ?c1 (- ?c 1)))
			(test (= ?c2 (- ?c 2)))
		)
		
		(and 
			(test (= (str-compare ?d up) 0))
			(and
				(map (pos-r ?r) (pos-c ?c1) (contains ~wall&~entry&~exit))
				(not (unuseful-cell (pos-r ?r) (pos-c ?c1)))					
			)
			(or
				(map (pos-r ?r) (pos-c ?c2) (contains wall|entry|exit))
				(unuseful-cell (pos-r ?r) (pos-c ?c2))				
			)
			(test (= ?c1 (+ ?c 1)))
			(test (= ?c2 (+ ?c 2)))
		)
		
		(and 
			(test (= (str-compare ?d right) 0))
			(and
				(map (pos-r ?r1) (pos-c ?c) (contains ~wall&~entry&~exit))
				(not (unuseful-cell (pos-r ?r1) (pos-c ?c)))					
			)
			(or
				(map (pos-r ?r2) (pos-c ?c) (contains wall|entry|exit))
				(unuseful-cell (pos-r ?r2) (pos-c ?c))				
			)
			(test (= ?r1 (+ ?r 1)))
			(test (= ?r2 (+ ?r 2)))
		)
		
		(and 
			(test (= (str-compare ?d left) 0))
			(and			
				(map (pos-r ?r1) (pos-c ?c) (contains ~wall&~entry&~exit))
				(not (unuseful-cell (pos-r ?r1) (pos-c ?c)))					
			)
			(or
				(map (pos-r ?r2) (pos-c ?c) (contains wall|entry|exit))
				(unuseful-cell (pos-r ?r2) (pos-c ?c))				
			)
			(test (= ?r1 (- ?r 1)))
			(test (= ?r2 (- ?r 2)))
		)
	)
	=>
	(modify ?f (step 4))	;Non viene compiuta alcuna rotazione
)

; Equivalente alla regola precedente ma considera la rotazione verso destra
;OMAR 18/01/2006 - gestione celle unuseful
(defrule rotate-right-forbidden
	(declare (salience -20))
	(action (module ~save))
	(status (time ?t))
	?f <- (movement (step 3))
	(percepts (time ?t) (pos-r ?r) (pos-c ?c) (direction ?d))
	;Controllo della situazione della mappa
	(or
		(and 
			(test (= (str-compare ?d down) 0))
			(or
				(map (pos-r ?r) (pos-c ?c1) (contains wall|entry|exit))
				(unuseful-cell (pos-r ?r) (pos-c ?c1))
			)
			(test (= ?c1 (- ?c 1)))
		)
		
		(and 
			(test (= (str-compare ?d up) 0))
			(or
				(map (pos-r ?r) (pos-c ?c1) (contains wall|entry|exit))
				(unuseful-cell (pos-r ?r) (pos-c ?c1))				
			)
			(test (= ?c1 (+ ?c 1)))
		)
		
		(and 
			(test (= (str-compare ?d right) 0))
			(or
				(map (pos-r ?r1) (pos-c ?c) (contains wall|entry|exit))
				(unuseful-cell (pos-r ?r1) (pos-c ?c))				
			)
			(test (= ?r1 (+ ?r 1)))
		)
		
		(and 
			(test (= (str-compare ?d left) 0))
			(or
				(map (pos-r ?r1) (pos-c ?c) (contains wall|entry|exit))
				(unuseful-cell (pos-r ?r1) (pos-c ?c))				
			)
			(test (= ?r1 (- ?r 1)))
		)
	)
	=>
	;(assert (exec (action turnright) (time ?t) (marks-a-path no)))
	;(assert (restore-direction (action turnleft)))
	(modify ?f (step 4))	;Non viene compiuta alcuna rotazione
)

; Equivalente alla regola precedente ma considera la rotazione verso destra
(defrule rotate-right
	(declare (salience -22))
	(action (module ~save))
	(status (time ?t))
	?f <- (movement (step 3))
	(percepts (time ?t) (pos-r ?r) (pos-c ?c) (direction ?d))
	;Controllo della situazione della mappa
	(or
		(and 
			(test (= (str-compare ?d down) 0))
			(not (and
				(map (pos-r ?r) (pos-c ?c1))
				(map (pos-r ?r) (pos-c ?c2))
				(map (pos-r ?r) (pos-c ?c3))
				(test (= ?c1 (- ?c 1)))
				(test (= ?c2 (- ?c 2)))
				(test (= ?c3 (- ?c 3)))			
			))
		)

		(and 
			(test (= (str-compare ?d up) 0))
			(not (and
				(map (pos-r ?r) (pos-c ?c1))
				(map (pos-r ?r) (pos-c ?c2))
				(map (pos-r ?r) (pos-c ?c3))
				(test (= ?c1 (+ ?c 1)))
				(test (= ?c2 (+ ?c 2)))
				(test (= ?c3 (+ ?c 3)))
			))
		)
		
		(and 
			(test (= (str-compare ?d right) 0))
			(not (and
				(map (pos-r ?r1) (pos-c ?c))
				(map (pos-r ?r2) (pos-c ?c))
				(map (pos-r ?r3) (pos-c ?c))
				(test (= ?r1 (+ ?r 1)))
				(test (= ?r2 (+ ?r 2)))
				(test (= ?r3 (+ ?r 3)))
			))				
		)
		
		(and 
			(test (= (str-compare ?d left) 0))
			(not (and
				(map (pos-r ?r1) (pos-c ?c))
				(map (pos-r ?r2) (pos-c ?c))
				(map (pos-r ?r3) (pos-c ?c))
				(test (= ?r1 (- ?r 1)))
				(test (= ?r2 (- ?r 2)))
				(test (= ?r3 (- ?r 3)))			
			))
		)
	)
	=>
	(assert (exec (action turnright) (time ?t) (marks-a-path no)))
	(assert (restore-direction (action turnleft)))
	
)

(defrule mark-rotation-completed
	(movement (step 4))
	(status (time ?t))
	(kpos (time ?t) (pos-r ?r) (pos-c ?c)) 
	?f <- (map (pos-r ?r) (pos-c ?c) (rotation ~completed)) 
	=>
	(modify ?f (rotation completed))
)

; Questa regola ha il solo compito di incrementare la fase di rotazione del robot
; sulle altre regole, a seconda della fase, è necessario controllare se eseguire la mossa
(defrule increase-step
	(declare (salience -23))
	(action (module ~save))
	(status (time ?t))
	?f <- (movement (step ?s))
	=>
	(modify ?f (step (mod (+ ?s 1) 5)))
)


; Questa regola rileva se deve essere ripristinata la direzione di spostamento del robot
; durante l'esplorazione, nel caso in cui lo sia (cioè sia presente un fatto di tipo "restore-direction")
; viene immediatamente ripristinata la direzione originaria
(defrule restore-step
	(status (time ?t))
	?f <- (restore-direction (action ?d))
	?f1 <- (movement (step ?s))
	=>
	(assert (exec (action ?d) (time ?t) (marks-a-path no)))
	(modify ?f1 (step (mod (+ ?s 1) 5)))	;Incremento del contatore degli step di rotazione
	(retract ?f)
	
)
; ##-----------------------------------------------------------------------##

; -------------------------- COSTRUZIONE DELLA MAPPA -------------------------- 
; Regole per la costruzione dei fatti sulla base delle percezioni che giungono
; dal modulo ENV. Sono costruiti i fatti utili per le operazioni compiute in
; tutti i sotto-moduli
; -----------------------------------------------------------------------------
(defrule build-map-up
	(declare (salience 100))
	(status (time ?t))
	(not (undo-phase (time ?)))
	(percepts (time ?t) (pos-r ?r)(pos-c ?c)(direction up)(perc1 ?p1)(perc2 ?p2)(perc3 ?p3)(cry ?))
	=>
	(assert (map (pos-r (- ?r 1)) (pos-c ?c) (contains ?p1)))
	(assert (map (pos-r (- ?r 2)) (pos-c ?c) (contains ?p2)))
	(assert (map (pos-r (- ?r 3)) (pos-c ?c) (contains ?p3)))
)

(defrule build-map-down
	(declare (salience 100))
	(status (time ?t))
	(not (undo-phase (time ?)))
	(percepts (time ?t) (pos-r ?r)(pos-c ?c)(direction down)(perc1 ?p1)(perc2 ?p2)(perc3 ?p3)(cry ?))
	=>
	(assert (map (pos-r (+ ?r 1)) (pos-c ?c) (contains ?p1)))
	(assert (map (pos-r (+ ?r 2)) (pos-c ?c) (contains ?p2)))
	(assert (map (pos-r (+ ?r 3)) (pos-c ?c) (contains ?p3)))		
)

(defrule build-map-left
	(declare (salience 100))
	(status (time ?t))
	(not (undo-phase (time ?)))
	(percepts (time ?t) (pos-r ?r)(pos-c ?c)(direction left)(perc1 ?p1)(perc2 ?p2)(perc3 ?p3)(cry ?))
	=>
	(assert (map (pos-r ?r) (pos-c (- ?c 1)) (contains ?p1)))
	(assert (map (pos-r ?r) (pos-c (- ?c 2)) (contains ?p2)))
	(assert (map (pos-r ?r) (pos-c (- ?c 3)) (contains ?p3)))		
)

(defrule build-map-right
	(declare (salience 100))
	(status (time ?t))
	(not (undo-phase (time ?)))
	(percepts (time ?t) (pos-r ?r)(pos-c ?c)(direction right)(perc1 ?p1)(perc2 ?p2)(perc3 ?p3)(cry ?))
	=>
	(assert (map (pos-r ?r) (pos-c (+ ?c 1)) (contains ?p1)))
	(assert (map (pos-r ?r) (pos-c (+ ?c 2)) (contains ?p2)))
	(assert (map (pos-r ?r) (pos-c (+ ?c 3)) (contains ?p3)))		
)

; AGGIUNTA PER CANCELLARE LE INCONSISTENZE DELLA MAPPA 
; (Per le celle già visitate, con rotazione completata: quando le ritrovo, le build-map
; le impostano con lo slot (di default) "rotation not-completed". Devo subito cancellarle
; perchè sono inconsistenti con quello che ho già asserito (e che è corretto).
;--------------------------------------------------------------
(defrule clear-map-inconsistency
	(declare (salience 100))
	(map (pos-r ?r) (pos-c ?c) (contains empty|debris) (rotation completed))
	?f <- (map (pos-r ?r) (pos-c ?c) (contains empty|debris) (rotation not-completed))
	=>
	(retract ?f)
)
;--------------------------------------------------------------

; Sostituzione del contenuto della cella "entry" con "wall"
(defrule replace-entry
	(declare (salience 90))
	?f <- (map (pos-r ?r) (pos-c ?c) (contains entry))
	=>
	(modify ?f (contains wall))
	(assert (entry-position (pos-r ?r) (pos-c ?c)))
)

; Pulisce tutti le celle della mappa che contengono "unknown"
(defrule clear-unknown
	(declare (salience 90))
	(status (time ?t))
	;(exec (action ?)(time ?t))
	?f <- (map (pos-r ?) (pos-c ?) (contains unknown))
	=>
	(retract ?f)
)

;Registrazione dello stato del robot (se non ho ancora caricato nessun superstite)
(defrule trace-position-notloaded
	(declare (salience 80))
	;(movement (step 0))
	(status (time ?t))
	(percepts (time ?t) (pos-r ?r)(pos-c ?c)(direction ?d)(perc1 ?p1)(perc2 ?p2)(perc3 ?p3)(cry ?))
	(not (perc-grasp (time ?) (pos-r ?)(pos-c ?) (person ?name)))
	;Inserita questa condizione per evitare di scrivere più volte lo stesso fatto - Omar 09/09/2005
	(not (kpos (time ?t) (pos-r ?r) (pos-c ?c) (direction ?d) (load no)))
	(map (pos-r ?r) (pos-c ?c) (counter ?cnt))
	=>
	(assert (kpos (time ?t) (pos-r ?r) (pos-c ?c) (direction ?d) (load no)))

)

;Registrazione dello stato del robot (se ho già caricato un superstite)
(defrule trace-position-loaded
	(declare (salience 80))
	;(movement (step 0))
	(status (time ?t))
	(percepts (time ?t) (pos-r ?r)(pos-c ?c)(direction ?d)(perc1 ?p1)(perc2 ?p2)(perc3 ?p3)(cry ?))
	(perc-grasp (time ?) (pos-r ?)(pos-c ?) (person ?name))
	(map (pos-r ?r) (pos-c ?c) (counter ?cnt))
	=>
	(assert (kpos (time ?t) (pos-r ?r) (pos-c ?c) (direction ?d) (load yes)))

)


; OMAR 11/11/2005 incremento del contatore dei passaggi sulla cella della mappa
; corretto il 13/01/2006
(defrule inc-counter-path
	(declare (salience 418))
	(status (time ?t))
	(test (> ?t 1))
	(kpos (time ?t) (pos-r ?r) (pos-c ?c) (direction ?d) (load ?))
	?f <- (map (pos-r ?r) (pos-c ?c) (counter ?cnt))
	(action (module ?m))
	(exec (action ?a) (time ?t) (marks-a-path yes))
	;(not (exec-path (time ?t) (pos-r ?r) (pos-c ?c) (module ?m) (direction ?d) (action ?a)))	
	(last-position (pos-r ?r1) (pos-c ?c1))
	(not (and
		(test (= ?r ?r1))
		(test (= ?c ?c1))
	))
	(not (inc-done))
	=>
	(modify ?f (counter (+ ?cnt 1)))
	(assert (inc-done))
)

; Registrazione delle azioni compiute dal robot (durante l'esplorazione)
(defrule write-path
	(declare (salience 410))
	(status (time ?t))
	(test (> ?t 1))
	(kpos (time ?t) (pos-r ?r) (pos-c ?c) (direction ?d) (load ?))
	?f <- (map (pos-r ?r) (pos-c ?c) (counter ?cnt))
	(action (module ?m))
	(exec (action ?a) (time ?t) (marks-a-path yes))
	(not (exec-path (time ?t) (pos-r ?r) (pos-c ?c) (module ?m) (direction ?d) (action ?a)))
	?f1 <- (last-position (pos-r ?) (pos-c ?))
	?f2 <- (inc-done)
	=>
	(assert (exec-path (time ?t) (pos-r ?r) (pos-c ?c) (module ?m) (direction ?d) (action ?a)))
	(retract ?f1)
	(assert (last-position (time ?t) (pos-r ?r) (pos-c ?c) (direction ?d)))
	(retract ?f2)
	(modify ?f (touched ?t))	;OMAR 18/01/2006 Tracciamento ultimo passaggio sulla cella
)

(defrule trace-cry
	(declare (salience 80))
	(status (time ?t))
	(percepts (time ?t) (pos-r ?r)(pos-c ?c)(direction ?)(perc1 ?)(perc2 ?)(perc3 ?)(cry yes))
	=>
	(assert (cry (pos-r ?r) (pos-c ?c)))
)

; Analisi della mappa per scrivere fatti che indicano le posizioni delle macerie da esplorare
(defrule check-for-debris
	(declare (salience 80))
	(map (pos-r ?r) (pos-c ?c) (contains debris))
	(not (debris-position (pos-r ?r) (pos-c ?c) (useful no)))
	=>
	(assert (debris-position (pos-r ?r) (pos-c ?c) (useful yes)))
)

; Analisi della mappa per scrivere fatti che indicano le posizioni delle macerie da esplorare
(defrule check-for-exits
	(declare (salience 80))
	(map (pos-r ?r) (pos-c ?c) (contains exit))
	=>
	(assert (exit-position (pos-r ?r) (pos-c ?c)))
)

; ---------------------- CONTROLLO MACERIE SENZA PERSONE -----------------------------
; Queste regole controllano se associate alle macerie ci sono richieste di aiuto
; (se non ce ne sono, mi salvo l'informazione nello slot "useful"
; ------------------------------------------------------------------------------------

(defrule check-useless-debris-up
	(declare (salience 15))
	(status (time ?t))
	(percepts (time ?t) (pos-r ?r)(pos-c ?c)(direction up)(perc1 debris)(perc2 ?p2)(perc3 ?p3)(cry no))
	(and
		?f <- (debris-position (pos-r ?r1) (pos-c ?c) (useful yes))
		(test (= ?r1 (- ?r 1)))
	)
	=>
	(modify ?f (useful no))	
)


(defrule check-useless-debris-down
	(declare (salience 15))
	(status (time ?t))
	(percepts (time ?t) (pos-r ?r)(pos-c ?c)(direction down)(perc1 debris)(perc2 ?p2)(perc3 ?p3)(cry no))
	(and
		?f <- (debris-position (pos-r ?r1) (pos-c ?c) (useful yes))
		(test (= ?r1 (+ ?r 1)))
	)
	=>
	(modify ?f (useful no))	
)


(defrule check-useless-debris-left
	(declare (salience 15))
	(status (time ?t))
	(percepts (time ?t) (pos-r ?r)(pos-c ?c)(direction left)(perc1 debris)(perc2 ?p2)(perc3 ?p3)(cry no))
	(and
		?f <- 	(debris-position (pos-r ?r) (pos-c ?c1) (useful yes))
		(test (= ?c1 (- ?c 1)))
	)
	=>
	(modify ?f (useful no))	
)

(defrule check-useless-debris-right
	(declare (salience 15))
	(status (time ?t))
	(percepts (time ?t) (pos-r ?r)(pos-c ?c)(direction right)(perc1 debris)(perc2 ?p2)(perc3 ?p3)(cry no))
	(and	
		?f <- 	(debris-position (pos-r ?r) (pos-c ?c1) (useful yes))
		(test (= ?c1 (+ ?c 1)))
	)
	=>
	(modify ?f (useful no))	

)

; ##---------------- GESTIONE PASSAGGIO AL MODULO SAVE -----------------##
; Quando viene rilevata una percezione di cry si deve passare al modulo 
; SAVE che ha il compito di recuperare la persona che ha richiesto aiuto. 
(defrule go-save
	(declare (salience 40))
	(status (time ?t) (result ~exit))
	?f1 <- (movement (step ?s))
	?f <- (action (module explore))
	(cry (pos-r ?) (pos-c ?))
	(not (undo (time ?) (direction ?) (action ?)))	; prima bisogna eliminare tutti gli undo precedenti
	=>
	(modify ?f (module save))
	(modify ?f1 (step 0))
	; (focus MAIN)
)
; ##--------------------------------------------------------------------##


; ##---------------- GESTIONE PASSAGGIO AL MODULO EXIT -----------------##
; Il superstite è stato caricato con successo sul robot, si passa alla fase
; di uscita dalla stanza
(defrule go-exit
	(declare (salience 40))
	(status (time ?t) (result ~exit))
	?f1 <- (movement (step ?s))
	?f <- (action (module save))
	(perc-grasp (time ?t) (pos-r ?)(pos-c ?) (person ?name))	
	(not (undo (time ?) (direction ?) (action ?)))	; prima bisogna eliminare tutti gli undo precedenti
	=>
	(modify ?f (module exit))
	(modify ?f1 (step 1))
)

; Attivazione della pianificazione per raggiungere l'uscita più vicina
(defrule go-plan
	(declare (salience 4000))
	?f2 <- (status (time ?t) (result ?))
	(test (> ?t 2))
	?f1 <- (movement (step ?))
	?f <- (action (module ~plan))
	(not (map (pos-r ?) (pos-c ?) (contains debris|empty) (rotation not-completed)))
	(not (and
		(map (pos-r ?r) (pos-c ?c) (contains debris|empty))
		(not (kpos (time ?) (pos-r ?r) (pos-c ?c)))
	))
	(not (plan-computed))
	
	; 310106
	(or
		(and
			(final-time-to-replanning ?ftr)
			(current-time-to-replanning ?ctr)
			(test (= ?ftr ?ctr))
		)
		(and
			(not (final-time-to-replanning ?))
			(not (current-time-to-replanning ?))
		)
	)
	
	=>
	(modify ?f (module plan))
	(modify ?f1 (step 0))

	(printout t crlf "-------------------------------------------------------------" crlf)
	(printout t "Tutta la mappa è stata esplorata, e nessun superstite ")
	(printout t crlf "e' stato trovato! Ora cerco una via d'uscita" crlf)
	(printout t "-------------------------------------------------------------" crlf crlf)
)

(defrule go-exec-plan
	(to-do (time ?))
	(plan-computed)	
	(ready-to-execute)
	?f <- (action (module plan))
	?f1 <- (movement (step ?))
	=>
	(modify ?f (module exec-plan))
	(modify ?f1 (step 0))
	(printout t crlf "-------------------------------------------------------------" crlf)
	(printout t "Piano completo, posso raggiungere l'uscita" crlf)
	(printout t "-------------------------------------------------------------" crlf crlf)
)
; ##--------------------------------------------------------------------##


; ##---------------- GESTIONE PASSAGGIO AL MODULO MAIN -----------------##
; Ritorna l'esecuzione al MAIN (dopo aver indicato l'azione da compiere)
(defrule go-MAIN
	(declare (salience 400))
	(status (time ?t))
	?f <- (percepts (time ?t) (pos-r ?)(pos-c ?)(direction ?)(perc1 ?)(perc2 ?)(perc3 ?)(cry ?))
	(exec (action ?) (time ?t))
	=> 
	(retract ?f)	; butto via la percezione perchè tanto non mi serve più
	 (focus MAIN)
)
; ##--------------------------------------------------------------------##



; ---------------------------------------------------------------------------------
; MODULO AGENT - Componente EXPLORE

; OBIETTIVO PRINCIPALE: trovare al piu' presto un superstire da salvare
; Esplorare la struttura del mondo sulla base delle percezioni.
; Man mano che procede l'esplorazione, si costruisce la mappa dell'ambiente e si
; salvano le informazioni sulla base delle quali si prendono le decisioni per 
; il comportamento dell'agente

; N.B. E' questo modulo che deve decidere se uscire quando non ha trovato nessuno 
; da salvare (e quindi passare direttamente il controllo al modulo EXIT).
; ---------------------------------------------------------------------------------

(defmodule EXPLORE (import AGENT ?ALL)(export ?ALL))

(deftemplate first-undo (slot action))

; -------------------------- MOVIMENTI DEL ROBOT -------------------------- 
; ##---------------- Movimento frontale verso le macerie ----------------##

; Ci sono macerie nelle percezioni del robot, ceroc immediatamente di raggiungerle (spostamento VERTICALE)
(defrule goto-debris-vertical-forward
	(declare (salience 25))
	(status (time ?t))
	(not (undo (time ?) (direction ?) (action ?)))
	?f <- (movement (step 0))
	(not (exec (action ?) (time ?t)))
	(or 
		(percepts (time ?t) (pos-r ?r)(pos-c ?c)(direction ?d&up|down)(perc1 debris)(perc2 ?)(perc3 ?)(cry yes))
		(percepts (time ?t) (pos-r ?r)(pos-c ?c)(direction ?d&up|down)(perc1 ?)(perc2 debris)(perc3 ?)(cry ?))
		(percepts (time ?t) (pos-r ?r)(pos-c ?c)(direction ?d&up|down)(perc1 ?)(perc2 ?)(perc3 debris)(cry ?))
	)
	; MODIFICA LUIGI 04102005

	(or	
		(and
			(test (= (str-compare ?d up) 0))
			(debris-position (pos-r ?r1) (pos-c ?c) (useful yes))
			(test (= ?r1 (- ?r 1)))
		)
		(and
			(test (= (str-compare ?d up) 0))
			(debris-position (pos-r ?r2) (pos-c ?c) (useful yes))
			(test (= ?r2 (- ?r 2)))
		)
		(and
			(test (= (str-compare ?d up) 0))
			(debris-position (pos-r ?r3) (pos-c ?c) (useful yes))
			(test (= ?r3 (- ?r 3)))
		)	
		(and
			(test (= (str-compare ?d down) 0))
			(debris-position (pos-r ?r1) (pos-c ?c) (useful yes))
			(test (= ?r1 (+ ?r 1)))
		)
		(and
			(test (= (str-compare ?d down) 0))
			(debris-position (pos-r ?r2) (pos-c ?c) (useful yes))
			(test (= ?r2 (+ ?r 2)))
		)
		(and
			(test (= (str-compare ?d down) 0))
			(debris-position (pos-r ?r3) (pos-c ?c) (useful yes))
			(test (= ?r3 (+ ?r 3)))
		)
	)	
	(not (or
		(and
			(debris-position (pos-r ?r) (pos-c ?c1) (useful yes))
			(test (<> ?c1 (- ?c 1)))
		)
		(and
			(debris-position (pos-r ?r) (pos-c ?c2) (useful yes))
			(test (<> ?c2 (- ?c 2)))
		)
		(and
			(debris-position (pos-r ?r) (pos-c ?c3) (useful yes))
			(test (<> ?c3 (- ?c 3)))
		)
		(and
			(debris-position (pos-r ?r) (pos-c ?c4) (useful yes))
			(test (<> ?c4 (+ ?c 1)))
		)
		(and
			(debris-position (pos-r ?r) (pos-c ?c5) (useful yes))
			(test (<> ?c5 (+ ?c 2)))
		)
		(and
			(debris-position (pos-r ?r) (pos-c ?c6) (useful yes))
			(test (<> ?c6 (+ ?c 3)))
		)
	))
	=>
	(assert (exec (action go)(time ?t)))
	(modify ?f (step 1))
	(assert (move-completed (time ?t)))
	
)

; Ci sono macerie nelle percezioni del robot, ceroc immediatamente di raggiungerle (spostamento ORIZZONTALE)
(defrule goto-debris-horizontal-forward
	(declare (salience 25))
	(status (time ?t))
	(not (exec (action ?) (time ?t)))
	(not (undo (time ?) (direction ?) (action ?)))
	?f <- (movement (step 0))
	(or 
		(percepts (time ?t) (pos-r ?r)(pos-c ?c)(direction ?d&left|right)(perc1 debris)(perc2 ?)(perc3 ?)(cry yes))
		(percepts (time ?t) (pos-r ?r)(pos-c ?c)(direction ?d&left|right)(perc1 ?)(perc2 debris)(perc3 ?)(cry ?))
		(percepts (time ?t) (pos-r ?r)(pos-c ?c)(direction ?d&left|right)(perc1 ?)(perc2 ?)(perc3 debris)(cry ?))
	)
	; MODIFICA LUIGI 04102005

	(or	
		(and
			(test (= (str-compare ?d left) 0))
			(debris-position (pos-r ?r) (pos-c ?c1) (useful yes))
			(test (= ?c1 (- ?c 1)))
		)
		(and
			(test (= (str-compare ?d left) 0))
			(debris-position (pos-r ?r) (pos-c ?c2) (useful yes))
			(test (= ?c2 (- ?c 2)))
		)
		(and
			(test (= (str-compare ?d left) 0))
			(debris-position (pos-r ?r) (pos-c ?c3) (useful yes))
			(test (= ?c3 (- ?c 3)))
		)	
		(and
			(test (= (str-compare ?d right) 0))
			(debris-position (pos-r ?r) (pos-c ?c1) (useful yes))
			(test (= ?c1 (+ ?c 1)))
		)
		(and
			(test (= (str-compare ?d right) 0))
			(debris-position (pos-r ?r) (pos-c ?c2) (useful yes))
			(test (= ?c2 (+ ?c 2)))
		)
		(and
			(test (= (str-compare ?d right) 0))
			(debris-position (pos-r ?r) (pos-c ?c3) (useful yes))
			(test (= ?c3 (+ ?c 3)))
		)
	)		
	(not (or
		(and
			(debris-position (pos-r ?r1) (pos-c ?c) (useful yes))
			(test (<> ?r1 (- ?r 1)))
		)
		(and
			(debris-position (pos-r ?r1) (pos-c ?c) (useful yes))
			(test (<> ?r1 (- ?r 2)))
		)
		(and
			(debris-position (pos-r ?r1) (pos-c ?c) (useful yes))
			(test (<> ?r1 (- ?r 3)))
		)
		(and
			(debris-position (pos-r ?r1) (pos-c ?c) (useful yes))
			(test (<> ?r1 (+ ?r 1)))
		)
		(and
			(debris-position (pos-r ?r1) (pos-c ?c) (useful yes))
			(test (<> ?r1 (+ ?r 2)))
		)
		(and
			(debris-position (pos-r ?r1) (pos-c ?c) (useful yes))
			(test (<> ?r1 (+ ?r 3)))
		)
	))
	=>
	(assert (exec (action go)(time ?t)))
	(modify ?f (step 1))
	(assert (move-completed (time ?t)))
	
)

; Si cerca di ragguingere la cella con le macerie nel campo visivo del robot (direzione UP)
(defrule goto-debris-fwd-up
	(declare (salience 20))
	(status (time ?t))
	(test (> ?t 2))
	(movement (step 0))
	;(not (undo (time ?) (direction ?) (action ?)))
	(or 
		(percepts (time ?t) (pos-r ?r)(pos-c ?c)(direction up)(perc1 debris)(perc2 ?)(perc3 ?)(cry yes))
		(percepts (time ?t) (pos-r ?r)(pos-c ?c)(direction up)(perc1 ?)(perc2 debris)(perc3 ?)(cry ?))
		(percepts (time ?t) (pos-r ?r)(pos-c ?c)(direction up)(perc1 ?)(perc2 ?)(perc3 debris)(cry ?))
	)
	(or
		(and
			(debris-position (pos-r ?r1) (pos-c ?c) (useful yes))
			(test (= ?r1 (- ?r 1)))
		)
		(and
			(debris-position (pos-r ?r1) (pos-c ?c) (useful yes))
			(test (= ?r1 (- ?r 2)))
		)
		(and
			(debris-position (pos-r ?r1) (pos-c ?c) (useful yes))
			(test (= ?r1 (- ?r 3)))
		)
	)
	=>
	(assert (exec (action go)(time ?t)))
	(assert (undo (time ?t) (direction down) (action go)))
	(assert (move-completed (time ?t)))	
	
)

; Si cerca di ragguingere la cella con le macerie nel campo visivo del robot (direzione DOWN)
(defrule goto-debris-fwd-down
	(declare (salience 20))
	(status (time ?t))
	(test (> ?t 2))
	(movement (step 0))
	;(not (undo (time ?) (direction ?) (action ?)))
	(or 
		(percepts (time ?t) (pos-r ?r)(pos-c ?c)(direction down)(perc1 debris)(perc2 ?)(perc3 ?)(cry yes))
		(percepts (time ?t) (pos-r ?r)(pos-c ?c)(direction down)(perc1 ?)(perc2 debris)(perc3 ?)(cry ?))
		(percepts (time ?t) (pos-r ?r)(pos-c ?c)(direction down)(perc1 ?)(perc2 ?)(perc3 debris)(cry ?))
	)
	(or
		(and
			(debris-position (pos-r ?r1) (pos-c ?c) (useful yes))
			(test (= ?r1 (+ ?r 1)))
		)
		(and
			(debris-position (pos-r ?r1) (pos-c ?c) (useful yes))
			(test (= ?r1 (+ ?r 2)))
		)
		(and
			(debris-position (pos-r ?r1) (pos-c ?c) (useful yes))
			(test (= ?r1 (+ ?r 3)))
		)
	)
	=>
	(assert (exec (action go)(time ?t)))
	(assert (undo (time ?t) (direction up) (action go)))
	(assert (move-completed (time ?t)))
	
)

; Si cerca di ragguingere la cella con le macerie nel campo visivo del robot (direzione LEFT)
(defrule goto-debris-fwd-left
	(declare (salience 20))
	(status (time ?t))
	(test (> ?t 2))
	(movement (step 0))
	;(not (undo (time ?) (direction ?) (action ?)))
	(or 
		(percepts (time ?t) (pos-r ?r)(pos-c ?c)(direction left)(perc1 debris)(perc2 ?)(perc3 ?)(cry yes))
		(percepts (time ?t) (pos-r ?r)(pos-c ?c)(direction left)(perc1 ?)(perc2 debris)(perc3 ?)(cry ?))
		(percepts (time ?t) (pos-r ?r)(pos-c ?c)(direction left)(perc1 ?)(perc2 ?)(perc3 debris)(cry ?))
	)
	(or
		(and
			(debris-position (pos-r ?r) (pos-c ?c1) (useful yes))
			(test (= ?c1 (- ?c 1)))
		)
		(and
			(debris-position (pos-r ?r) (pos-c ?c1) (useful yes))
			(test (= ?c1 (- ?c 2)))
		)
		(and
			(debris-position (pos-r ?r) (pos-c ?c1) (useful yes))
			(test (= ?c1 (- ?c 3)))
		)
	)
	=>
	(assert (exec (action go)(time ?t)))
	(assert (undo (time ?t) (direction right) (action go)))
	(assert (move-completed (time ?t)))	
	
)

; Si cerca di ragguingere la cella con le macerie nel campo visivo del robot (direzione RIGHT)
(defrule goto-debris-fwd-right
	(declare (salience 20))
	(status (time ?t))
	(test (> ?t 2))
	(movement (step 0))
	;(not (undo (time ?) (direction ?) (action ?)))
	(or 
		(percepts (time ?t) (pos-r ?r)(pos-c ?c)(direction right)(perc1 debris)(perc2 ?)(perc3 ?)(cry yes))
		(percepts (time ?t) (pos-r ?r)(pos-c ?c)(direction right)(perc1 ?)(perc2 debris)(perc3 ?)(cry ?))
		(percepts (time ?t) (pos-r ?r)(pos-c ?c)(direction right)(perc1 ?)(perc2 ?)(perc3 debris)(cry ?))
	)
	(or
		(and
			(debris-position (pos-r ?r) (pos-c ?c1) (useful yes))
			(test (= ?c1 (+ ?c 1)))
		)
		(and
			(debris-position (pos-r ?r) (pos-c ?c1) (useful yes))
			(test (= ?c1 (+ ?c 2)))
		)
		(and
			(debris-position (pos-r ?r) (pos-c ?c1) (useful yes))
			(test (= ?c1 (+ ?c 3)))
		)
	)
	=>
	(assert (exec (action go)(time ?t)))
	(assert (undo (time ?t) (direction left) (action go)))
	(assert (move-completed (time ?t)))
	
)

; ##--------------------------------------------------------------------##

; ##--------------------- Rotazione verso le macerie -------------------##

; Ruoto la direzione del robot alla sua sinistra (perche' probabilmente ci sono delle macerie da esplorare)

(defrule goto-debris-turnright-up
	(declare (salience 10))
	(status (time ?t))
	(test (> ?t 2))
	(not (exec (action ?) (time ?t)))
	(movement (step 0))
	(kpos (time ?t) (pos-r ?r) (pos-c ?c) (direction up) (load no))
	(or
		(and
			(debris-position (pos-r ?r1) (pos-c ?c1) (useful yes))
			(test (= ?r ?r1))
			(test (= ?c1 (+ ?c 1)))
		)
		(and
			(debris-position (pos-r ?r1) (pos-c ?c1) (useful yes))
			(test (= ?r ?r1))
			(test (= ?c1 (+ ?c 2)))
		)
		(and
			(debris-position (pos-r ?r1) (pos-c ?c1) (useful yes))
			(test (= ?r ?r1))
			(test (= ?c1 (+ ?c 3)))
		)				
	)
	=>
	(assert (exec (action turnright)(time ?t)))
	(assert (undo (time ?t) (direction left) (action turnright)))	
	(assert (move-completed (time ?t)))
)

(defrule goto-debris-turnleft-up
	(declare (salience 10))
	(status (time ?t))
	(test (> ?t 2))
	(not (exec (action ?) (time ?t)))
	(movement (step 0))
	(kpos (time ?t) (pos-r ?r) (pos-c ?c) (direction up) (load no))
	(or
		;(and
		;	(debris-position (pos-r ?r1) (pos-c ?c1) (useful yes))
		;	(test (= ?c ?c1))
		;	(test (= ?r1 (- ?r 1)))
		;)
		;(and
		;	(debris-position (pos-r ?r1) (pos-c ?c1) (useful yes))
		;	(test (= ?c ?c1))
		;	(test (= ?r1 (- ?r 2)))
		;)
		;(and
		;	(debris-position (pos-r ?r1) (pos-c ?c1) (useful yes))
		;	(test (= ?c ?c1))
		;	(test (= ?r1 (- ?r 3)))
		;)
		(and
			(debris-position (pos-r ?r1) (pos-c ?c1) (useful yes))
			(test (= ?r ?r1))
			(test (= ?c1 (- ?c 1)))
		)
		(and
			(debris-position (pos-r ?r1) (pos-c ?c1) (useful yes))
			(test (= ?r ?r1))
			(test (= ?c1 (- ?c 2)))
		)
		(and
			(debris-position (pos-r ?r1) (pos-c ?c1) (useful yes))
			(test (= ?r ?r1))
			(test (= ?c1 (- ?c 3)))
		)				
	)
	=>
	(assert (exec (action turnleft)(time ?t)))
	(assert (undo (time ?t) (direction right) (action turnleft)))	
	(assert (move-completed (time ?t)))
)

(defrule goto-debris-turnright-down
	(declare (salience 10))
	(status (time ?t))
	(test (> ?t 2))
	(not (exec (action ?) (time ?t)))
	(movement (step 0))
	(kpos (time ?t) (pos-r ?r) (pos-c ?c) (direction down) (load no))
	(or
		(and
			(debris-position (pos-r ?r1) (pos-c ?c1) (useful yes))
			(test (= ?r ?r1))
			(test (= ?c1 (- ?c 1)))
		)
		(and
			(debris-position (pos-r ?r1) (pos-c ?c1) (useful yes))
			(test (= ?r ?r1))
			(test (= ?c1 (- ?c 2)))
		)
		(and
			(debris-position (pos-r ?r1) (pos-c ?c1) (useful yes))
			(test (= ?r ?r1))
			(test (= ?c1 (- ?c 3)))
		)				
	)
	=>
	(assert (exec (action turnright)(time ?t)))
	(assert (undo (time ?t) (direction right) (action turnright)))	
	(assert (move-completed (time ?t)))
)

(defrule goto-debris-turnleft-down
	(declare (salience 10))
	(status (time ?t))
	(test (> ?t 2))
	(not (exec (action ?) (time ?t)))
	(movement (step 0))
	(kpos (time ?t) (pos-r ?r) (pos-c ?c) (direction down) (load no))
	(or
	;	(and
	;		(debris-position (pos-r ?r1) (pos-c ?c1) (useful yes))
	;		(test (= ?c ?c1))
	;		(test (= ?r1 (- ?r 1)))
	;	)
	;	(and
	;		(debris-position (pos-r ?r1) (pos-c ?c1) (useful yes))
	;		(test (= ?c ?c1))
	;		(test (= ?r1 (- ?r 2)))
	;	)
	;	(and
	;		(debris-position (pos-r ?r1) (pos-c ?c1) (useful yes))
	;		(test (= ?c ?c1))
	;		(test (= ?r1 (- ?r 3)))
	;	)
		(and
			(debris-position (pos-r ?r1) (pos-c ?c1) (useful yes))
			(test (= ?r ?r1))
			(test (= ?c1 (+ ?c 1)))
		)
		(and
			(debris-position (pos-r ?r1) (pos-c ?c1) (useful yes))
			(test (= ?r ?r1))
			(test (= ?c1 (+ ?c 2)))
		)
		(and
			(debris-position (pos-r ?r1) (pos-c ?c1) (useful yes))
			(test (= ?r ?r1))
			(test (= ?c1 (+ ?c 3)))
		)				
	)
	=>
	(assert (exec (action turnleft)(time ?t)))
	(assert (undo (time ?t) (direction left) (action turnleft)))	
	(assert (move-completed (time ?t)))
)

(defrule goto-debris-turnright-right
	(declare (salience 10))
	(status (time ?t))
	(test (> ?t 2))
	(not (exec (action ?) (time ?t)))
	(movement (step 0))
	(kpos (time ?t) (pos-r ?r) (pos-c ?c) (direction right) (load no))
	(or
		(and
			(debris-position (pos-r ?r1) (pos-c ?c1) (useful yes))
			(test (= ?c ?c1))
			(test (= ?r1 (+ ?r 1)))
		)
		(and
			(debris-position (pos-r ?r1) (pos-c ?c1) (useful yes))
			(test (= ?c ?c1))
			(test (= ?r1 (+ ?r 2)))
		)
		(and
			(debris-position (pos-r ?r1) (pos-c ?c1) (useful yes))
			(test (= ?c ?c1))
			(test (= ?r1 (+ ?r 3)))
		)
	)
	=>
	(assert (exec (action turnright)(time ?t)))
	(assert (undo (time ?t) (direction up) (action turnright)))	
	(assert (move-completed (time ?t)))
)

(defrule goto-debris-turnleft-right
	(declare (salience 10))
	(status (time ?t))
	(test (> ?t 2))
	(not (exec (action ?) (time ?t)))
	(movement (step 0))
	(kpos (time ?t) (pos-r ?r) (pos-c ?c) (direction right) (load no))
	(or
		(and
			(debris-position (pos-r ?r1) (pos-c ?c1) (useful yes))
			(test (= ?c ?c1))
			(test (= ?r1 (- ?r 1)))
		)
		(and
			(debris-position (pos-r ?r1) (pos-c ?c1) (useful yes))
			(test (= ?c ?c1))
			(test (= ?r1 (- ?r 2)))
		)
		(and
			(debris-position (pos-r ?r1) (pos-c ?c1) (useful yes))
			(test (= ?c ?c1))
			(test (= ?r1 (- ?r 3)))
		)
		;(and
		;	(debris-position (pos-r ?r1) (pos-c ?c1) (useful yes))
		;	(test (= ?r ?r1))
		;	(test (= ?c1 (- ?c 1)))
		;)
		;(and
		;	(debris-position (pos-r ?r1) (pos-c ?c1) (useful yes))
		;	(test (= ?r ?r1))
		;	(test (= ?c1 (- ?c 2)))
		;)
		;(and
		;	(debris-position (pos-r ?r1) (pos-c ?c1) (useful yes))
		;	(test (= ?r ?r1))
		;	(test (= ?c1 (- ?c 3)))
		;)				
	)
	=>
	(assert (exec (action turnleft)(time ?t)))
	(assert (undo (time ?t) (direction down) (action turnleft)))	
	(assert (move-completed (time ?t)))
)

(defrule goto-debris-turnright-left
	(declare (salience 10))
	(status (time ?t))
	(test (> ?t 2))
	(not (exec (action ?) (time ?t)))
	(movement (step 0))
	(kpos (time ?t) (pos-r ?r) (pos-c ?c) (direction left) (load no))
	(or
		(and
			(debris-position (pos-r ?r1) (pos-c ?c1) (useful yes))
			(test (= ?c ?c1))
			(test (= ?r1 (- ?r 1)))
		)
		(and
			(debris-position (pos-r ?r1) (pos-c ?c1) (useful yes))
			(test (= ?c ?c1))
			(test (= ?r1 (- ?r 2)))
		)
		(and
			(debris-position (pos-r ?r1) (pos-c ?c1) (useful yes))
			(test (= ?c ?c1))
			(test (= ?r1 (- ?r 3)))
		)				
	)
	=>
	(assert (exec (action turnright)(time ?t)))
	(assert (undo (time ?t) (direction down) (action turnright)))	
	(assert (move-completed (time ?t)))
)

(defrule goto-debris-turnleft-left
	(declare (salience 10))
	(status (time ?t))
	(test (> ?t 2))
	(not (exec (action ?) (time ?t)))
	(movement (step 0))
	(kpos (time ?t) (pos-r ?r) (pos-c ?c) (direction left) (load no))
	(or
		(and
			(debris-position (pos-r ?r1) (pos-c ?c1) (useful yes))
			(test (= ?c ?c1))
			(test (= ?r1 (+ ?r 1)))
		)
		(and
			(debris-position (pos-r ?r1) (pos-c ?c1) (useful yes))
			(test (= ?c ?c1))
			(test (= ?r1 (+ ?r 2)))
		)
		(and
			(debris-position (pos-r ?r1) (pos-c ?c1) (useful yes))
			(test (= ?c ?c1))
			(test (= ?r1 (+ ?r 3)))
		)
		;(and
		;	(debris-position (pos-r ?r1) (pos-c ?c1) (useful yes))
		;	(test (= ?r ?r1))
		;	(test (= ?c1 (+ ?c 1)))
		;)
		;(and
		;	(debris-position (pos-r ?r1) (pos-c ?c1) (useful yes))
		;	(test (= ?r ?r1))
		;	(test (= ?c1 (+ ?c 2)))
		;)
		;(and
		;	(debris-position (pos-r ?r1) (pos-c ?c1) (useful yes))
		;	(test (= ?r ?r1))
		;	(test (= ?c1 (+ ?c 3)))
		;)				
	)
	=>
	(assert (exec (action turnleft)(time ?t)))
	(assert (undo (time ?t) (direction up) (action turnleft)))	
	(assert (move-completed (time ?t)))
)
; ##--------------------------------------------------------------------##

; ##------------------ ATTIVAZIONE DELLA FASE DI UNDO ------------------##

;Tracciamento della prima operazione di undo da fare, serve a capire quante inversioni bisogna fare
(defrule trace-first-undo
	(declare (salience 220))
	(not (first-undo (action ?)))
	(not (inversion-completed))
	(movement (step 0))
	(undo (time ?) (direction ?) (action ?a))
	=>
	(assert (first-undo (action ?a)))
)

; Questa regola ha il compito di attivare la fase di undo asserendo il 
; fatto undo-phase
(defrule active-undo-module
	(declare (salience -22))
	(status (time ?t))
	(movement (step 0))
	(undo (time ?) (direction ?) (action ?))
	(not (undo-phase (time ?t)))
	(status (time ?t))
	=>
	(assert (undo-phase (time ?t)))
)


; Questa regola ha il compito di passare immediatamente l'esecuzione 
; al modulo UNDO se è stata attivata la fase di undo
(defrule undo-in-action
	(declare (salience 100))
	(first-undo (action ?))
	;(undo (time ?) (direction ?) (action ?))	
	(status (time ?t))
	?f <- (undo-phase (time ?))
	=>
	(modify ?f (time ?t))
	 (focus UNDO)
)

; Prima di chiudere la fase di undo, se la first-undo indica go come
; prima azione deve essere fatta un'ulteriore inversione
(defrule deactive-undo-module1
	(declare (salience 110))
	(not (undo (time ?) (direction ?) (action ?)))
	(status (time ?t))
	?f <- (undo-phase (time ?))
	(first-undo (action go))
	=>
	(modify ?f (time ?t))
	 (focus UNDO)
)

; Questa regola ha il compito di disattivare la fase di undo, controllando
; se nella WM non ci sono più fatti undo che devono essere annullati
(defrule deactive-undo-module2
	(declare (salience 110))
	(not (undo (time ?) (direction ?) (action ?)))
	?f <- (undo-phase (time ?))
	?f1 <- (first-undo (action ~go))
	?f2 <- (inversion-completed)
	=>
	(retract ?f)
	(retract ?f1)
	(retract ?f2)
)
; ##--------------------------------------------------------------------##

; ##-------------------- ATTIVAZIONE MOVIMENTI STANDARD  ----------------##
; Attivazione dei movimenti standard per il robot
; La strategia e' farlo muovere nella direzione in cui e' rivolto e 
; farlo girare prima che vada a sbattere contro una parete

(defrule go-standard-move
	(declare (salience -30))
	(movement (step 0))
	=>
	(focus STANDARD-MOVE)
)
; ##--------------------------------------------------------------------##


; ##---------------- ELIMINAZIONE DEI FATTI UNDO  -----------------##
; Eliminazione dei fatti undo residui (perche' sono relativi al modulo in cui mi 
; trovavo precedentemente

(defrule clear-first-undo
	(declare (salience 505))
	(status (time ?t))
	(cry (pos-r ?) (pos-c ?))
	?f <- (first-undo (action ?))
	=>
	(retract ?f)
	(assert (move-completed (time ?t)))
	
)

(defrule clear-undo-explore
	(declare (salience 500))
	(status (time ?t))
	(cry (pos-r ?) (pos-c ?))
	?f <- (undo (time ?) (direction ?) (action ?))
	=>
	(retract ?f)
	(assert (move-completed (time ?t)))
	
)
; ##--------------------------------------------------------------------##

; -------------------------- RITORNO AL MODULO AGENT ------------------------------
;Tornare il controllo al modulo AGENT, la mossa da compiere è stata decisa
(defrule back-to-agent-explore
	(declare (salience 200))
	?f <- (move-completed (time ?))
	=>
	(retract ?f)
	(pop-focus)
)
; ---------------------------------------------------------------------------------


; ---------------------------------------------------------------------------------
;				   FINE MODULO EXPLORE
; ---------------------------------------------------------------------------------


; ---------------------------------------------------------------------------------
; MODULO EXPLORE - Componente UNDO
; ---------------------------------------------------------------------------------
; All'interno di questo modulo sono contenute le regole per ripristinare tutte le 
; mosse di undo che sono state inserite nelle fasi precedenti di esecuzione. Una
; volta attivata la fase di "disfacimento" delle operazioni, essa non può essere 
; interrotta fino al suo completamento

; ---------------------------------------------------------------------------------

(defmodule UNDO (import EXPLORE ?ALL)(export ?ALL))


; ##--------------------- Disfare le azioni compiute -------------------##

; Regola per svolgere la seconda inversione nel caso in cui la prima undo sia una go
(defrule invert-again
	(first-undo (action go))
	(not (undo (time ?t) (direction ?d) (action ?)))
	?f <- (inversion-completed)
	(not (second-inversion))
	=>
	(assert (undo-step (step 1)))
	(assert (second-inversion))
	(retract ?f)
	
)

; Questa regola serve per fare in modo che al completamento della seconda inversione
; si possa uscire con successo dalla fase di undo
(defrule set-flag-toremove
	(declare (salience -5))
	(not (undo (time ?t) (direction ?d) (action ?)))
	?f <- (inversion-completed)
	?f1 <- (first-undo (action go))
	?f2 <- (second-inversion)
	=>
	(modify ?f1 (action to-remove))
	(retract ?f2)
	; Omar 01/09/05 - NON deve essere cancellato il flag altrimenti non si attiva la regola per 
	; uscire dal modulo UNDO
	;(retract ?f)
)
	
(defrule clear-flag-inversion
	;(first-undo (action ~go))
	; Omar 01/09/05 - Questa regola non deve essere attivabile quando il flag di first-undo è stato
	; impostato a to-remove, perchè rimuovendo il flag "inversion-completed" si va in loop
	(and 
		(first-undo (action ~go))
		(first-undo (action ~to-remove))
	)
	?f <- (inversion-completed)
	(not (undo (time ?t) (direction ?d) (action ?)))
	=>
	(retract ?f)
)

(defrule undo-action-go-step0
	(declare (salience -21))
	(not (inversion-completed))
	(movement (step 0))
	(undo (time ?) (direction ?) (action go))
	=>
	(assert (undo-step (step 1)))
	
)

(defrule undo-action-go-step1
	(declare (salience 5))
	(status (time ?t))
	(movement (step 0))
	(not (inversion-completed))
	?f <- (undo-step (step 1))
	=>
	(assert (exec (action turnleft) (time ?t)))
	(modify ?f (step 2))
	(assert (move-completed (time ?t)))
	 ; POSSIBILE PROBLEMA 13/09/2005
	(pop-focus)	;devo tornare il controllo al modulo EXPLORE per fare in modo che sia eseguita l'azione
	
)

(defrule undo-action-go-step2
	(declare (salience 5))
	(status (time ?t))
	(movement (step 0))
	(not (inversion-completed))
	?f <- (undo-step (step 2))
	=>
	(assert (exec (action turnleft) (time ?t)))
	(assert (inversion-completed))
	(assert (move-completed (time ?t)))
	(retract ?f)
	(pop-focus)	;devo tornare il controllo al modulo EXPLORE per fare in modo che sia eseguita l'azione
	
)

(defrule undo-action-go
	(declare (salience -22))
	(status (time ?t))
	(movement (step 0))
	(inversion-completed)
	(kpos (pos-r ?r) (pos-c ?c))
	?f1 <- (map (pos-r ?r) (pos-c ?c))	
	?f <- (undo (time ?) (direction ?d) (action go))
	=>
	(assert (exec (action go) (time ?t)))
	(assert (move-completed (time ?t)))
	(retract ?f)
	(modify ?f1 (rotation completed))
	(pop-focus)	;devo tornare il controllo al modulo EXPLORE per fare in modo che sia eseguita l'azione
	
)

(defrule undo-action-turn
	(declare (salience -22))
	(status (time ?t))
	(movement (step 0))
	(kpos (pos-r ?r) (pos-c ?c))
	?f1 <- (map (pos-r ?r) (pos-c ?c))
	?f <- (undo (time ?) (direction ?d) (action ?a&~go))
	=>
	(assert (exec (action ?a) (time ?t)))
	(assert (move-completed (time ?t)))
	(retract ?f)
	(modify ?f1 (rotation completed))
	(pop-focus)	;devo tornare il controllo al modulo EXPLORE per fare in modo che sia eseguita l'azione
	
)
; ---------------------------------------------------------------------------------
;				   FINE MODULO UNDO
; ---------------------------------------------------------------------------------


; ---------------------------------------------------------------------------------
; MODULO AGENT - Componente SAVE

; OBIETTIVO PRINCIPALE: caricare al piu' presto il superstite trovato
; Caricare la persona sul robot facendo il minor numero di mosse possibile
; ---------------------------------------------------------------------------------

(defmodule SAVE (import AGENT ?ALL)(export ?ALL))

(deftemplate survivor (slot pos-r) (slot pos-c))
(deftemplate dig (slot pos-r) (slot pos-c))
;##------------Inserisco le possibilità posizionali del/i superstite/i-----------##

; Tutte le alternative possibili
(defrule set-all-alternatives
	(declare (salience 50))
	(status (time ?t))
	(kpos (time ?t) (pos-r ?r) (pos-c ?c) (direction ?d) (load no))
	(not (alternatives-setted))
	=>
	(assert (survivor (pos-r (+ ?r 1)) (pos-c ?c)))
	(assert (survivor (pos-r (- ?r 1)) (pos-c ?c)))
	(assert (survivor (pos-r ?r) (pos-c (+ ?c 1))))
	(assert (survivor (pos-r ?r) (pos-c (- ?c 1))))
	(assert (alternatives-setted))
)

; Cancella le alternative che la mappa conosciuta puo' escludere
(defrule delete-alternative
	(declare (salience 50))
	?f <- (survivor (pos-r ?r) (pos-c ?c))
	(or
		(map (pos-r ?r) (pos-c ?c) (contains ~debris))
		(debris-position (pos-r ?r) (pos-c ?c) (useful no))
	)
	=>
	(retract ?f)
)
;##-----------------------------------------------------------------------##


; ##--------------------- Rotazione verso le macerie -------------------##

; ATTENZIONE: Visto che nel modulo SAVE si tratta di eseguire al massimo una go
; in una certa direzione (per poi tornare indietro in caso di fail), non mi serve
; tener traccia delle undo delle turn sulla casella in cui sono. Mi giro finchè non
; ho un possibile superstite difronte a me; poi ci vado e se lo trovo vado in EXIT,
; altrimenti compio una INVERSIONE (facendo la retract di quel possibile superstite)
; e la undo-go, e basta! E' vero, mi ritroverò nella posizione contraria a quella
; di partenza...ma va bene così, tanto devo comunque continuare a girarmi su quella
; casella per andare dagli altri possibili superstiti rimasti.

; Ruoto la direzione del robot alla sua sinistra (default)
(defrule goto-survivor-turnleft-up
	(declare (salience 10))
	(status (time ?t))
	(not (exec (action ?) (time ?t)))
	(not (undo (time ?) (direction ?) (action ?)))
	(kpos (time ?t) (pos-r ?r) (pos-c ?c) (direction up) (load no))
	(survivor (pos-r ?r1) (pos-c ?)) 
	(test (<> ?r1 (- ?r 1)))	
	=>
	(assert (exec (action turnleft)(time ?t))) 
	
)

(defrule goto-survivor-turnleft-down
	(declare (salience 10))
	(status (time ?t))
	(not (exec (action ?) (time ?t)))
	(not (undo (time ?) (direction ?) (action ?)))
	(kpos (time ?t) (pos-r ?r) (pos-c ?c) (direction down) (load no))
	(survivor (pos-r ?r1) (pos-c ?))
	(test (<> ?r1 (+ ?r 1)))         
	=>
	(assert (exec (action turnleft)(time ?t)))
)

(defrule goto-survivor-turnleft-left
	(declare (salience 10))
	(status (time ?t))
	(not (exec (action ?) (time ?t)))
	(not (undo (time ?) (direction ?) (action ?)))
	(kpos (time ?t) (pos-r ?r) (pos-c ?c) (direction left) (load no))
	(survivor (pos-r ?) (pos-c ?c1))
	(test (<> ?c1 (- ?c 1)))
	=>
	(assert (exec (action turnleft)(time ?t)))
)

(defrule goto-survivor-turnleft-right
	(declare (salience 10))
	(status (time ?t))
	(not (exec (action ?) (time ?t)))
	(not (undo (time ?) (direction ?) (action ?)))
	(kpos (time ?t) (pos-r ?r) (pos-c ?c) (direction right) (load no))
	(survivor (pos-r ?) (pos-c ?c1))
	(test (<> ?c1 (+ ?c 1)))
	=>
	(assert (exec (action turnleft)(time ?t)))
)
	
; ##--------------------------------------------------------------------##


; ##--------------------- Go verso le macerie --------------------------##

; Si cerca di ragguingere la cella con le macerie (direzione UP)
(defrule goto-survivor-fwd-up
	(declare (salience 20))
	(status (time ?t))
	(not (exec (action ?) (time ?t)))
	(kpos (time ?t) (pos-r ?r) (pos-c ?c) (direction up) (load no))
	(percepts (time ?t) (pos-r ?r)(pos-c ?c)(direction up)(perc1 debris)(perc2 ?)(perc3 ?)(cry yes))
	(survivor (pos-r ?r1) (pos-c ?c)) 
	(test (= ?r1 (- ?r 1)))
	(not (undo (time ?) (direction ?) (action ?)))
	=>
	(assert (exec (action go)(time ?t))) 
	(assert (undo (time ?t) (direction down) (action go)))	
)

; Si cerca di ragguingere la cella con le macerie (direzione DOWN)
(defrule goto-survivor-fwd-down
	(declare (salience 20))
	(status (time ?t))
	(not (exec (action ?) (time ?t)))
	(kpos (time ?t) (pos-r ?r) (pos-c ?c) (direction down) (load no))
	(percepts (time ?t) (pos-r ?r)(pos-c ?c)(direction down)(perc1 debris)(perc2 ?)(perc3 ?)(cry yes))
	(survivor (pos-r ?r1) (pos-c ?c))
	(test (= ?r1 (+ ?r 1)))
	(not (undo (time ?) (direction ?) (action ?)))	
	=>
	(assert (exec (action go)(time ?t)))
	(assert (undo (direction up) (action go) (time ?t)))	
)

; Si cerca di ragguingere la cella con le macerie (direzione LEFT)
(defrule goto-survivor-fwd-left
	(declare (salience 20))
	(status (time ?t))
	(not (exec (action ?) (time ?t)))
	(kpos (time ?t) (pos-r ?r) (pos-c ?c) (direction left) (load no))
	(percepts (time ?t) (pos-r ?r)(pos-c ?c)(direction left)(perc1 debris)(perc2 ?)(perc3 ?)(cry yes))
	(survivor (pos-r ?r) (pos-c ?c1))
	(test (= ?c1 (- ?c 1)))
	(not (undo (time ?) (direction ?) (action ?)))
	=>
	(assert (exec (action go)(time ?t)))
	(assert (undo (time ?t) (direction right) (action go)))	
)

; Si cerca di ragguingere la cella con le macerie (direzione RIGHT)
(defrule goto-survivor-fwd-right
	(declare (salience 20))
	(status (time ?t))
	(not (exec (action ?) (time ?t)))
	(kpos (time ?t) (pos-r ?r) (pos-c ?c) (direction right) (load no))
	(percepts (time ?t) (pos-r ?r)(pos-c ?c)(direction right)(perc1 debris)(perc2 ?)(perc3 ?)(cry yes))
	(survivor (pos-r ?r1) (pos-c ?c1))
	(test (= ?c1 (+ ?c 1)))
	(not (undo (time ?) (direction ?) (action ?)))
	=>
	(assert (exec (action go)(time ?t)))
	(assert (undo (time ?t) (direction left) (action go)))
)

; ##--------------------------------------------------------------------##


; ##------------------Undo delle azioni di visita di debris-------------##
; Simili a quelle di EXPLORE ma senza il fatto movement nelle precondizioni,
; ma con il fatto (not (exec...


(defrule undo-action-go-step0
	(declare (salience -21))
	(not (inversion-completed))
	(status (time ?t))
	(kpos (time ?t) (pos-r ?r) (pos-c ?c) (direction ?))
	?f <- (survivor (pos-r ?r) (pos-c ?c))
	(undo (time ?) (direction ?) (action go))
	=>
	(assert (undo-step (step 1)))
	(retract ?f)
	
)

(defrule undo-action-go-step1
	(declare (salience 5))
	(status (time ?t))
	(not (exec (action ?) (time ?t)))
	(not (inversion-completed))
	?f <- (undo-step (step 1))
	=>
	(assert (exec (action turnleft) (time ?t)))
	(modify ?f (step 2))
	
)

(defrule undo-action-go-step2
	(declare (salience 5))
	(status (time ?t))
	(not (exec (action ?) (time ?t)))
	(not (inversion-completed))
	?f <- (undo-step (step 2))
	=>
	(assert (exec (action turnleft) (time ?t)))
	(assert (inversion-completed))
	(retract ?f)
	
)

(defrule clear-flag-inversion
	(declare (salience -10))
	?f <- (inversion-completed)
	(not (undo (time ?t) (direction ?d) (action ?)))
	=>
	(retract ?f)
)


(defrule undo-action-go
	(declare (salience -10))
	(status (time ?t))
	(not (exec (action ?) (time ?t)))
	(inversion-completed)
	?f <- (undo (time ?) (direction ?d) (action go))
	=>
	(assert (exec (action go) (time ?t)))
	(retract ?f)
	
)

(defrule back-to-agent-save
	(declare (salience -20))
	(status (time ?t))
	(exec (action ?a) (time ?t))
	=>
	(pop-focus)
)

; ##--------------------------------------------------------------------##


; ##-------------Se sono "sopra" il superstite-(vero o falso)-------------##
; Caso in cui 6 sopra un superstite e sentiamo ancora cry. ATT: non è detto
; che il fatto cry yes derivi che il superstite sia proprio lì. Vedi dig-fail.

; Se siamo sopra e sentiamo ancora cry yes, scaviamo
(defrule dig-the-debris
	(declare (salience 50))
	(status (time ?t))
	(not (exec (action ?) (time ?t)))
	(percepts (time ?t) (pos-r ?r)(pos-c ?c)(direction ?)(perc1 ?)(perc2 ?)(perc3 ?)(cry yes))
	(survivor (pos-r ?r) (pos-c ?c))
	(not (dig (pos-r ?r) (pos-c ?c)))
	=>
	(assert (exec (action dig) (time ?t)))
	(assert (dig (pos-r ?r) (pos-c ?c)))
	
)


; Se la dig non è andata a buon fine, dobbiamo tornare indietro (verranno eseguite le undo)
;(defrule dig-fail
;	(declare (salience 100))
;	(status (time ?t))
;	(not (exec (action ?) (time ?t)))
;	(perc-dig (time ?t) (pos-r ?r)(pos-c ?c) (person no))
;	?f <- (survivor (pos-r ?r) (pos-c ?c))
;	=>
;	(retract ?f)
;)

; Se la dig ha avuto successo, eseguiamo una grasp della persona.
(defrule grasp-the-survivor
	(declare (salience 100))
	(status (time ?t))
	(not (exec (action ?) (time ?t)))
	(perc-dig (time ?t) (pos-r ?r)(pos-c ?c) (person yes))
	=>
	(assert (exec (action grasp) (time ?t)))
	
)


; Eliminazione dei fatti undo residui
(defrule clear-undo-save
	(declare (salience 500))
	(status (time ?t))
	(perc-grasp (time ?t) (pos-r ?r)(pos-c ?c) (person ?name))
	?f <- (undo (time ?) (direction ?) (action ?))
	=>
	(retract ?f)
	(pop-focus)
)
; ##--------------------------------------------------------------------##

; ---------------------------------------------------------------------------------
;				   FINE MODULO SAVE
; ---------------------------------------------------------------------------------



; ---------------------------------------------------------------------------------
; MODULO AGENT - Componente EXIT

; Gestione delle operazioni di ricerca dopo aver caricato un superstite a bordo
; OBIETTIVO PRINCIPALE: trovare al piu' presto un'uscita (e concludere il programma)
; ---------------------------------------------------------------------------------

(defmodule EXIT (import AGENT ?ALL)(export ?ALL))


(deftemplate exit-unreachable (slot pos-r) (slot pos-c) (slot direction))


; Regola per valutare se di fronte al robot ci sia un'uscita (senza ostacoli)

; In questa regola viene valutato il risultato delle percezioni per evitare di muoversi
; verso un'uscita che si trova DIETRO un muro. Nel caso in cui l'uscita sia coperta
; da un muro (sulla traiettoria rettilinea tra il robot e l'uscita) vengono attivati
; i movimenti standard per far in modo che il robot eviti di sbattere contro il muro.

;OMAR 19/01/2006 - gestione celle unuseful
(defrule exit-available-front-unreachable
	(declare (salience 100))
	(status (time ?t))
	(kpos (time ?t) (pos-r ?r) (pos-c ?c) (direction ?d) (load ?))
	(exit-position (pos-r ?r1) (pos-c ?c1))
	(or
		(and
			(test (= (str-compare ?d up) 0))
			(test (< ?r1 ?r))
			(test (= ?c ?c1))
		)
		(and
			(test (= (str-compare ?d down) 0))
			(test (> ?r1 ?r))
			(test (= ?c ?c1))
		)
		(and
			(test (= (str-compare ?d left) 0))
			(test (= ?r ?r1))
			(test (< ?c1 ?c))
		)
		(and
			(test (= (str-compare ?d right) 0))
			(test (= ?r ?r1))
			(test (> ?c1 ?c))
		)		
	)
	(or 
		;Omar 09/09/2005
		(percepts (time ?t) (pos-r ?r)(pos-c ?c)(direction ?)(perc1 wall|entry)(perc2 ?)(perc3 ?)(cry ?))
		(percepts (time ?t) (pos-r ?r)(pos-c ?c)(direction ?)(perc1 ?)(perc2 wall|entry)(perc3 ?)(cry ?))
		(percepts (time ?t) (pos-r ?r)(pos-c ?c)(direction ?)(perc1 ?)(perc2 ?)(perc3 wall|entry)(cry ?))
;		(percepts (time ?t) (pos-r ?r)(pos-c ?c)(direction ?)(perc1 wall|entry)(perc2 ~unknown)(perc3 ~unknown)(cry ?))
;		(percepts (time ?t) (pos-r ?r)(pos-c ?c)(direction ?)(perc1 ?)(perc2 wall|entry)(perc3 ~unknown)(cry ?))
;		(percepts (time ?t) (pos-r ?r)(pos-c ?c)(direction ?)(perc1 ?)(perc2 ?)(perc3 wall|entry)(cry ?))

		; Gestione celle inutili
		(and
			(test (= (str-compare ?d left) 0))
			(or
				(and
					(unuseful-cell (pos-r ?r) (pos-c ?c1))
					(test (= ?c1 (- ?c 1)))			
				)
				(and
					(unuseful-cell (pos-r ?r) (pos-c ?c2))
					(test (= ?c2 (- ?c 2)))			
				)
				(and
					(unuseful-cell (pos-r ?r) (pos-c ?c3))
					(test (= ?c3 (- ?c 3)))			
				)
			)				
		)
		(and
			(test (= (str-compare ?d right) 0))
			(or
				(and
					(unuseful-cell (pos-r ?r) (pos-c ?c1))
					(test (= ?c1 (+ ?c 1)))			
				)
				(and
					(unuseful-cell (pos-r ?r) (pos-c ?c2))
					(test (= ?c2 (+ ?c 2)))			
				)
				(and
					(unuseful-cell (pos-r ?r) (pos-c ?c3))
					(test (= ?c3 (+ ?c 3)))			
				)
			)				
		)
		(and
			(test (= (str-compare ?d up) 0))
			(or
				(and
					(unuseful-cell (pos-r ?r1) (pos-c ?c))
					(test (= ?r1 (- ?r 1)))			
				)
				(and
					(unuseful-cell (pos-r ?r2) (pos-c ?c))
					(test (= ?r2 (- ?r 2)))			
				)
				(and
					(unuseful-cell (pos-r ?r3) (pos-c ?c))
					(test (= ?r3 (- ?r 3)))			
				)
			)				
		)
		(and
			(test (= (str-compare ?d down) 0))
			(or
				(and
					(unuseful-cell (pos-r ?r1) (pos-c ?c))
					(test (= ?r1 (+ ?r 1)))			
				)
				(and
					(unuseful-cell (pos-r ?r2) (pos-c ?c))
					(test (= ?r2 (+ ?r 2)))			
				)
				(and
					(unuseful-cell (pos-r ?r3) (pos-c ?c))
					(test (= ?r3 (+ ?r 3)))			
				)
			)				
		)
	)
	=>
	(assert (exit-unreachable (pos-r ?r) (pos-c ?c) (direction ?d)))
)

; Regola per rimuovere il flag che indica un'uscita irrangiungibile dalla posizione attuale
; del robot
(defrule clear-flag-unreachable
	(declare (salience 100))
	?f <- (exit-unreachable (pos-r ?r) (pos-c ?c))
	(percepts (time ?t) (pos-r ?r1)(pos-c ?c1))
	(or
		(test (<> ?r ?r1))
		(test (<> ?c ?c1))
	)
	=> 
	(retract ?f)	
)

;OMAR 19/01/2006 - gestione celle unuseful
(defrule exit-available-front
	(not (exit-unreachable (pos-r ?) (pos-c ?)))
	(status (time ?t))
	(kpos (time ?t) (pos-r ?r) (pos-c ?c) (direction ?d) (load ?))
	(exit-position (pos-r ?r1) (pos-c ?c1))
	(or
		(and
			(test (= (str-compare ?d up) 0))
			(test (< ?r1 ?r))
			(test (= ?c ?c1))
		)
		(and
			(test (= (str-compare ?d down) 0))
			(test (> ?r1 ?r))
			(test (= ?c ?c1))
		)
		(and
			(test (= (str-compare ?d left) 0))
			(test (= ?r ?r1))
			(test (< ?c1 ?c))
		)
		(and
			(test (= (str-compare ?d right) 0))
			(test (= ?r ?r1))
			(test (> ?c1 ?c))
		)		
	)
	(not (or 
		(percepts (time ?t) (pos-r ?r)(pos-c ?c)(direction ?)(perc1 wall|entry)(perc2 ?)(perc3 ?)(cry ?))
		(percepts (time ?t) (pos-r ?r)(pos-c ?c)(direction ?)(perc1 ?)(perc2 wall|entry)(perc3 ?)(cry ?))
		(percepts (time ?t) (pos-r ?r)(pos-c ?c)(direction ?)(perc1 ?)(perc2 ?)(perc3 wall|entry)(cry ?))
		; Gestione celle inutili
		(and
			(test (= (str-compare ?d left) 0))
			(or
				(and
					(unuseful-cell (pos-r ?r) (pos-c ?c1))
					(test (= ?c1 (- ?c 1)))			
				)
				(and
					(unuseful-cell (pos-r ?r) (pos-c ?c2))
					(test (= ?c2 (- ?c 2)))			
				)
				(and
					(unuseful-cell (pos-r ?r) (pos-c ?c3))
					(test (= ?c3 (- ?c 3)))			
				)
			)				
		)
		(and
			(test (= (str-compare ?d right) 0))
			(or
				(and
					(unuseful-cell (pos-r ?r) (pos-c ?c1))
					(test (= ?c1 (+ ?c 1)))			
				)
				(and
					(unuseful-cell (pos-r ?r) (pos-c ?c2))
					(test (= ?c2 (+ ?c 2)))			
				)
				(and
					(unuseful-cell (pos-r ?r) (pos-c ?c3))
					(test (= ?c3 (+ ?c 3)))			
				)
			)				
		)
		(and
			(test (= (str-compare ?d up) 0))
			(or
				(and
					(unuseful-cell (pos-r ?r1) (pos-c ?c))
					(test (= ?r1 (- ?r 1)))			
				)
				(and
					(unuseful-cell (pos-r ?r2) (pos-c ?c))
					(test (= ?r2 (- ?r 2)))			
				)
				(and
					(unuseful-cell (pos-r ?r3) (pos-c ?c))
					(test (= ?r3 (- ?r 3)))			
				)
			)				
		)
		(and
			(test (= (str-compare ?d down) 0))
			(or
				(and
					(unuseful-cell (pos-r ?r1) (pos-c ?c))
					(test (= ?r1 (+ ?r 1)))			
				)
				(and
					(unuseful-cell (pos-r ?r2) (pos-c ?c))
					(test (= ?r2 (+ ?r 2)))			
				)
				(and
					(unuseful-cell (pos-r ?r3) (pos-c ?c))
					(test (= ?r3 (+ ?r 3)))			
				)
			)				
		)		
	))
	=>
	(assert (exec (action go) (time ?t)))	; Proseguo nella direzioni in cui sono rivolto
	(assert (move-completed (time ?t)))
	
)

; Regola per valutare se a sx del robot ci sia un'uscita
;OMAR 19/01/2006 - gestione celle unuseful
(defrule exit-available-left
	(not (exit-unreachable (pos-r ?) (pos-c ?)))
	(status (time ?t))
	(kpos (time ?t) (pos-r ?r) (pos-c ?c) (direction ?d) (load ?))
	(exit-position (pos-r ?r1) (pos-c ?c1))
	(or
		(and
			(test (= (str-compare ?d up) 0))
			(test (= ?r1 ?r))
			(test (> ?c ?c1))
			; Verifica ostacoli sul tragitto verso l'uscita
			(not (and
				(or
					(map (pos-r ?r2) (pos-c ?c2) (contains wall))
					(unuseful-cell (pos-r ?r2) (pos-c ?c2))
				)
				(test (= ?r2 ?r))
				(test (< ?c1 ?c2))
				(test (< ?c2 ?c))
			))
		)
		(and
			(test (= (str-compare ?d down) 0))
			(test (= ?r1 ?r))
			(test (< ?c ?c1))
			; Verifica ostacoli sul tragitto verso l'uscita
			(not (and
				(or
					(map (pos-r ?r2) (pos-c ?c2) (contains wall))
					(unuseful-cell (pos-r ?r2) (pos-c ?c2))
				)
				(test (= ?r2 ?r))
				(test (< ?c2 ?c1))
				(test (< ?c ?c2))
			))
		)
		(and
			(test (= (str-compare ?d left) 0))
			(test (< ?r ?r1))
			(test (= ?c1 ?c))
			; Verifica ostacoli sul tragitto verso l'uscita
			(not (and
				(or
					(map (pos-r ?r2) (pos-c ?c2) (contains wall))
					(unuseful-cell (pos-r ?r2) (pos-c ?c2))
				)
				(test (= ?c2 ?c))
				(test (< ?r2 ?r1))
				(test (< ?r ?r2))
			))
		)
		(and
			(test (= (str-compare ?d right) 0))
			(test (> ?r ?r1))
			(test (= ?c1 ?c))
			; Verifica ostacoli sul tragitto verso l'uscita
			(not (and
				(or
					(map (pos-r ?r2) (pos-c ?c2) (contains wall))
					(unuseful-cell (pos-r ?r2) (pos-c ?c2))
				)				
				(test (= ?c2 ?c))
				(test (< ?r1 ?r2))
				(test (< ?r2 ?r))
			))
		)		
	)
	=>
	(assert (exec (action turnleft) (time ?t)))	; Si prosegue nella stessa direzione
	(assert (move-completed (time ?t)))
)


; Regola per valutare se a dx del robot ci sia un'uscita
;OMAR 19/01/2006 - gestione celle unuseful
(defrule exit-available-right
	(not (exit-unreachable (pos-r ?) (pos-c ?)))
	(status (time ?t))
	(kpos (time ?t) (pos-r ?r) (pos-c ?c) (direction ?d) (load ?))
	(exit-position (pos-r ?r1) (pos-c ?c1))
	(or
		(and
			(test (= (str-compare ?d down) 0))
			(test (= ?r1 ?r))
			(test (> ?c ?c1))
			(not (and
				(or
					(map (pos-r ?r2) (pos-c ?c2) (contains wall))
					(unuseful-cell (pos-r ?r2) (pos-c ?c2))
				)
				(test (= ?r2 ?r))
				(test (< ?c1 ?c2))
				(test (< ?c2 ?c))
			))
		)
		(and
			(test (= (str-compare ?d up) 0))
			(test (= ?r1 ?r))
			(test (< ?c ?c1))
			(not (and
				(or
					(map (pos-r ?r2) (pos-c ?c2) (contains wall))
					(unuseful-cell (pos-r ?r2) (pos-c ?c2))
				)
				(test (= ?r2 ?r))
				(test (< ?c2 ?c1))
				(test (< ?c ?c2))
			))
		)
		(and
			(test (= (str-compare ?d right) 0))
			(test (< ?r ?r1))
			(test (= ?c1 ?c))
			(not (and
				(or
					(map (pos-r ?r2) (pos-c ?c2) (contains wall))
					(unuseful-cell (pos-r ?r2) (pos-c ?c2))
				)
				(test (= ?c2 ?c))
				(test (< ?r2 ?r1))
				(test (< ?r ?r2))
			))
		)
		(and
			(test (= (str-compare ?d left) 0))
			(test (> ?r ?r1))
			(test (= ?c1 ?c))
			(not (and
				(or
					(map (pos-r ?r2) (pos-c ?c2) (contains wall))
					(unuseful-cell (pos-r ?r2) (pos-c ?c2))
				)
				(test (= ?c2 ?c))
				(test (< ?r1 ?r2))
				(test (< ?r2 ?r))
			))
		)		
	)
	=>
	(assert (exec (action turnright) (time ?t)))	; Si prosegue nella stessa direzione
	(assert (move-completed (time ?t)))
)

; Regola per valutare se dietro al robot ci sia un'uscita
;OMAR 19/01/2006 - gestione celle unuseful
(defrule exit-available-rear
	(not (exit-unreachable (pos-r ?) (pos-c ?)))
	(status (time ?t))
	(kpos (time ?t) (pos-r ?r) (pos-c ?c) (direction ?d) (load ?))
	(exit-position (pos-r ?r1) (pos-c ?c1))
	
	(or
		(and
			(test (= (str-compare ?d up) 0))
			(test (> ?r1 ?r))
			(test (= ?c ?c1))
			(not (and
				(or
					(map (pos-r ?r2) (pos-c ?c2) (contains wall))
					(unuseful-cell (pos-r ?r2) (pos-c ?c2))
				)
				(test (= ?c2 ?c))
				(test (< ?r2 ?r1))
				(test (< ?r ?r2))
			))
		)
		(and
			(test (= (str-compare ?d down) 0))
			(test (< ?r1 ?r))
			(test (= ?c ?c1))
			(not (and
				(or
					(map (pos-r ?r2) (pos-c ?c2) (contains wall))
					(unuseful-cell (pos-r ?r2) (pos-c ?c2))
				)
				(test (= ?c2 ?c))
				(test (< ?r1 ?r2))
				(test (< ?r2 ?r))
			))
		)
		(and
			(test (= (str-compare ?d left) 0))
			(test (= ?r ?r1))
			(test (> ?c1 ?c))
			(not (and
				(or
					(map (pos-r ?r2) (pos-c ?c2) (contains wall))
					(unuseful-cell (pos-r ?r2) (pos-c ?c2))
				)
				(test (= ?r2 ?r))
				(test (< ?c2 ?c1))
				(test (< ?c ?c2))
			))
		)
		(and
			(test (= (str-compare ?d right) 0))
			(test (= ?r ?r1))
			(test (< ?c1 ?c))
			(not (and
				(or
					(map (pos-r ?r2) (pos-c ?c2) (contains wall))
					(unuseful-cell (pos-r ?r2) (pos-c ?c2))
				)
				(test (= ?r2 ?r))
				(test (< ?c1 ?c2))
				(test (< ?c2 ?c))
			))
		)		
	)
	=>
	(assert (exec (action turnleft) (time ?t)))	; Scelgo di farlo svoltare a sx, al prossimo passo
	(assert (move-completed (time ?t)))		; si attiverà l'altra regola e quindi completa l'inversione
)

; ##-------------------- ATTIVAZIONE MOVIMENTI STANDARD  ----------------##
; Attivazione dei movimenti standard per il robot, bisogna procedere
; nell'esplorazione perchè non ci sono uscite disponibili


; Luigi - 290106

; Attivazione della pianificazione per raggiungere l'uscita più vicina
(defrule go-plan2
	(declare (salience -100))
	?f2 <- (status (time ?t) (result ?))
	(test (> ?t 2))
	?f1 <- (movement (step ?))
	?f <- (action (module ~plan))
	(not (map (pos-r ?) (pos-c ?) (contains debris|empty) (rotation not-completed)))
	(not (and
		(map (pos-r ?r) (pos-c ?c) (contains debris|empty))
		(not (kpos (time ?) (pos-r ?r) (pos-c ?c)))
	))
	
	; 310106
	(or
		(and
			(final-time-to-replanning ?ttr)
			(current-time-to-replanning ?ttr)
		)
		(and
			(not (final-time-to-replanning ?))
			(not (current-time-to-replanning ?))
		)
	)
	(not (plan-computed))
	=>
	(modify ?f (module plan))
	(modify ?f1 (step 0))
	
	(printout t crlf "-------------------------------------------------------------" crlf)
	(printout t "Tutta la mappa è stata esplorata, e un superstite ")
	(printout t crlf "e' stato trovato! Ora cerco una via d'uscita" crlf)
	(printout t "-------------------------------------------------------------" crlf crlf)
)

(defrule go-standard-move
	(declare (salience -120))
	(not (move-completed (time ?)))
	=>
	(focus STANDARD-MOVE)
)

; ##--------------------------------------------------------------------##

; ##------------------------ RITORNO AL MODULO AGENT -------------------##
; Tornare il controllo al modulo AGENT, la mossa da compiere è stata decisa

; 310106 due regole mutuamente esclusive. Servono per far andare avanti Ruby nel modulo EXIT
; dopo un planning non riuscito. La prima fà avanzare il contatore del tot di mosse da fare
; prima di riattivare il planning, e la seconda lo attiva nel caso il contatore corrente
; sia uguale a quello massimo.

(defrule back-to-agent-exit-wait-replanning
	(declare (salience 210))
	(status (time ?t))
	?f <- (move-completed (time ?))
	?f1 <- (current-time-to-replanning ?ctr)
	(final-time-to-replanning ?ftr)
	(test (< ?ctr ?ftr))
	=>
	(retract ?f)
	(retract ?f1)
	(assert (current-time-to-replanning (+ ?ctr 1)))
	(pop-focus)
)

(defrule back-to-agent-exit-ok-replanning
	(declare (salience 210))
	(status (time ?t))
	?f <- (move-completed (time ?))
	?f1 <- (current-time-to-replanning ?ctr)
	(final-time-to-replanning ?ftr)
	(test (= ?ctr ?ftr))
	?f2 <- (action (module ?))
	=>
	(retract ?f)
	;(retract ?f1)
	;(assert (current-time-to-replanning -1))
	(modify ?f2 (module plan))
	(pop-focus)
)

(defrule back-to-agent-exit
	(declare (salience 200))
	(status (time ?t))
	?f <- (move-completed (time ?))
	=>
	(retract ?f)
	(pop-focus)
)

; ##--------------------------------------------------------------------##

; ---------------------------------------------------------------------------------
;				   FINE MODULO EXIT
; ---------------------------------------------------------------------------------

; ---------------------------------------------------------------------------------
; MODULO AGENT - Componente STANDARD-MOVE
; ---------------------------------------------------------------------------------

; In questo modulo ci sono le regole di movimento del robot. Si tratta di regole
; per evitare che vada a sbattere contro i muri. Inoltre le stesse regole 
; servono nel caso in cui si trovi in un vicolo cieco.
; Attraverso la gestione di 2 livelli di blocco, e' anche possibile gestire
; le situazioni di loop nei movimenti del robot.

(defmodule STANDARD-MOVE (import AGENT ?ALL)(export ?ALL))

; N.B. In choice viene salvato l'ultima scelta compiuta dal robot
(deftemplate default-choice (slot pos-r) (slot pos-c) (slot direction) (slot choice))


; ##--------------------------- MOVIMENTI STANDARD ---------------------##

; Gestione CELLE INUTILI
; Rilevamento delle celle inutili, cioè racchiuse all'interno di un vicolo cieco
; Quando il robot di trova chiuso da 3 lati, viene impostata la cella su cui si trova
; come inutile dato che non può far altro che girarsi indietro. In questo modo una
; volta che è entrato in un vicolo cieco non ci entrerà più.
; ATTENZIONE: le EXIT non devono essere considerate blocchi!

;OMAR 19/01/2006 - gestione celle unuseful
(defrule trace-unuseful-cell
	(declare (salience -5))
	?f <- (movement (step 0))
	(status (time ?t))
	(kpos (time ?t) (pos-r ?r) (pos-c ?c) (direction ?d) (load ?))
	(not (unuseful-cell (pos-r ?r) (pos-c ?c)))
	(not (move-completed  (time ?)))	
	(or
		; direzione UP
		(and
			(test (= (str-compare ?d up) 0))
			(or
				(and
					(or 
						(map (pos-r ?r1) (pos-c ?c) (contains wall|entry))
						(unuseful-cell (pos-r ?r1) (pos-c ?c))				
					)
					(test (= (- ?r 1) ?r1))
				)
				(and
					(or 
						(map (pos-r ?r1) (pos-c ?c) (contains wall|entry))
						(unuseful-cell (pos-r ?r1) (pos-c ?c))				
					)
					(test (= (+ ?r 1) ?r1))
				)
			)
			(or 
				(map (pos-r ?r) (pos-c ?c1) (contains wall|entry))
				(unuseful-cell (pos-r ?r) (pos-c ?c1))				
			)				
			(test (= (- ?c 1) ?c1))			
			(or 
				(map (pos-r ?r) (pos-c ?c2) (contains wall|entry))
				(unuseful-cell (pos-r ?r) (pos-c ?c2))				
			)				
			(test (= (+ ?c 1) ?c2))
	        )
		; direzione DOWN
		(and
			(test (= (str-compare ?d down) 0))
			(or
				(and
					(or 
						(map (pos-r ?r1) (pos-c ?c) (contains wall|entry))
						(unuseful-cell (pos-r ?r1) (pos-c ?c))				
					)
					(test (= (+ ?r 1) ?r1))
				)
				(and
					(or 
						(map (pos-r ?r1) (pos-c ?c) (contains wall|entry))
						(unuseful-cell (pos-r ?r1) (pos-c ?c))				
					)
					(test (= (- ?r 1) ?r1))
				)
			)
			(or 
				(map (pos-r ?r) (pos-c ?c1) (contains wall|entry))
				(unuseful-cell (pos-r ?r) (pos-c ?c1))				
			)				
			(test (= (+ ?c 1) ?c1))
			(or 
				(map (pos-r ?r) (pos-c ?c2) (contains wall|entry))
				(unuseful-cell (pos-r ?r) (pos-c ?c2))				
			)				
			(test (= (- ?c 1) ?c2))		
	        )
		; direzione LEFT
		(and
			(test (= (str-compare ?d left) 0))
			(or
				(and
					(or 
						(map (pos-r ?r) (pos-c ?c1) (contains wall|entry))
						(unuseful-cell (pos-r ?r) (pos-c ?c1))				
					)
					(test (= (- ?c 1) ?c1))
				)
				(and
					(or 
						(map (pos-r ?r) (pos-c ?c2) (contains wall|entry))
						(unuseful-cell (pos-r ?r) (pos-c ?c2))				
					)
					(test (= (+ ?c 1) ?c2))
				)
			)
			(or 
				(map (pos-r ?r1) (pos-c ?c) (contains wall|entry))
				(unuseful-cell (pos-r ?r1) (pos-c ?c))				
			)				
			(test (= (- ?r 1) ?r1))
			(or 
				(map (pos-r ?r2) (pos-c ?c) (contains wall|entry))
				(unuseful-cell (pos-r ?r2) (pos-c ?c))				
			)				
			(test (= (+ ?r 1) ?r2))
	    	)
		; direzione RIGHT
		(and
			(test (= (str-compare ?d right) 0))
			(or
				(and
					(or 
						(map (pos-r ?r) (pos-c ?c1) (contains wall|entry))
						(unuseful-cell (pos-r ?r) (pos-c ?c1))				
					)
					(test (= (+ ?c 1) ?c1))
				)
				(and
					(or 
						(map (pos-r ?r) (pos-c ?c1) (contains wall|entry))
						(unuseful-cell (pos-r ?r) (pos-c ?c1))				
					)
					(test (= (- ?c 1) ?c1))
				)
			)
			(or 
				(map (pos-r ?r1) (pos-c ?c) (contains wall|entry))
				(unuseful-cell (pos-r ?r1) (pos-c ?c))				
			)				
			(test (= (+ ?r 1) ?r1))
			(or 
				(map (pos-r ?r2) (pos-c ?c) (contains wall|entry))
				(unuseful-cell (pos-r ?r2) (pos-c ?c))				
			)				
			(test (= (- ?r 1) ?r2))
	    )
	)
	=>
	; Imposto la cella su cui si trova il robot come cella inutile	
	(assert (unuseful-cell (pos-r ?r) (pos-c ?c)))

)

; GESTIONE DEL BLOCCO FISICO (rappresentato dai muri, dalle entrate)
; Le regole considerano le uscite come muri (e quindi evitano di sbatterci contro) perche'
; se ci si trova a dover applicare questa regole, significa che le regole che pilotano
; il robot verso un'uscita non erano attivabili (e quindi l'uscita va trattata come un muro).

; Fa girare il robot a destra prima di sbattere contro un muro (o un'entrata o un'uscita)
;OMAR 19/01/2006 - gestione celle unuseful
(defrule turn-right-physical
	(declare (salience -10))
	?f <- (movement (step 0))
	(status (time ?t))
	(kpos (time ?t) (pos-r ?r) (pos-c ?c) (direction ?d)) 
	(or
		(percepts (time ?t) (pos-r ?r)(pos-c ?c)(direction ?d)(perc1 wall|entry|exit)(perc2 ?p2)(perc3 ?p3)(cry ?))
		(and
			(test (= (str-compare ?d up) 0))
			(unuseful-cell (pos-r ?r1) (pos-c ?c))
			(test (= (- ?r 1) ?r1))				
		)
		(and
			(test (= (str-compare ?d down) 0))
			(unuseful-cell (pos-r ?r1) (pos-c ?c))
			(test (= (+ ?r 1) ?r1))				
		)
		(and
			(test (= (str-compare ?d left) 0))
			(unuseful-cell (pos-r ?r) (pos-c ?c1))
			(test (= (- ?c 1) ?c1))				
		)
		(and
			(test (= (str-compare ?d right) 0))
			(unuseful-cell (pos-r ?r) (pos-c ?c1))
			(test (= (+ ?c 1) ?c1))				
		)
	)
	(or
		(and
			(test (= (str-compare ?d up) 0))
			(or
				(map (pos-r ?r) (pos-c ?c1) (contains wall|entry|exit))
				(unuseful-cell (pos-r ?r) (pos-c ?c1))				
			)
			(test (= (- ?c 1) ?c1))			
		)
		(and
			(test (= (str-compare ?d down) 0))
			(or
				(map (pos-r ?r) (pos-c ?c1) (contains wall|entry|exit))
				(unuseful-cell (pos-r ?r) (pos-c ?c1))				
			)
			(test (= (+ ?c 1) ?c1))			
		)
		(and
			(test (= (str-compare ?d right) 0))
			(or
				(map (pos-r ?r1) (pos-c ?c) (contains wall|entry|exit))
				(unuseful-cell (pos-r ?r1) (pos-c ?c))				
			)
			(test (= (- ?r 1) ?r1))
		)
		(and
			(test (= (str-compare ?d left) 0))
			(or
				(map (pos-r ?r1) (pos-c ?c) (contains wall|entry|exit))
				(unuseful-cell (pos-r ?r1) (pos-c ?c))				
			)
			(test (= (+ ?r 1) ?r1))
		)	
	)
	(not (move-completed (time ?)))
	=>
	(assert (exec (action turnright)(time ?t)))
	(assert (move-completed (time ?t)))
	(modify ?f (step 1))
	(pop-focus)
)

; Fa girare il robot a sinistra prima di sbattere contro un muro (o un'entrata o un'uscita)
;OMAR 19/01/2006 - gestione celle unuseful
(defrule turn-left-physical
	(declare (salience -10))
	?f <- (movement (step 0))
	(status (time ?t))
	(kpos (time ?t) (pos-r ?r) (pos-c ?c) (direction ?d)) 
	(or
		(percepts (time ?t) (pos-r ?r)(pos-c ?c)(direction ?d)(perc1 wall|entry|exit)(perc2 ?p2)(perc3 ?p3)(cry ?))
		(and
			(test (= (str-compare ?d up) 0))
			(unuseful-cell (pos-r ?r1) (pos-c ?c))
			(test (= (- ?r 1) ?r1))				
		)
		(and
			(test (= (str-compare ?d down) 0))
			(unuseful-cell (pos-r ?r1) (pos-c ?c))
			(test (= (+ ?r 1) ?r1))				
		)
		(and
			(test (= (str-compare ?d left) 0))
			(unuseful-cell (pos-r ?r) (pos-c ?c1))
			(test (= (- ?c 1) ?c1))				
		)
		(and
			(test (= (str-compare ?d right) 0))
			(unuseful-cell (pos-r ?r) (pos-c ?c1))
			(test (= (+ ?c 1) ?c1))				
		)
	)	
	(or
		(and
			(test (= (str-compare ?d left) 0))
			(or
				(map (pos-r ?r1) (pos-c ?c) (contains wall|entry|exit))
				(unuseful-cell (pos-r ?r1) (pos-c ?c))
			)
			(test (= (- ?r 1) ?r1))
		)
		(and
			(test (= (str-compare ?d right) 0))
			(or
				(map (pos-r ?r1) (pos-c ?c) (contains wall|entry|exit))
				(unuseful-cell (pos-r ?r1) (pos-c ?c))
			)		
			(test (= (+ ?r 1) ?r1))
		)
		(and
			(test (= (str-compare ?d up) 0))
			(or
				(map (pos-r ?r) (pos-c ?c1) (contains wall|entry|exit))
				(unuseful-cell (pos-r ?r) (pos-c ?c1))
			)
			(test (= (+ ?c 1) ?c1))			
		)
		(and
			(test (= (str-compare ?d down) 0))
			(or
				(map (pos-r ?r) (pos-c ?c1) (contains wall|entry|exit))
				(unuseful-cell (pos-r ?r) (pos-c ?c1))
			)
			(test (= (- ?c 1) ?c1))			
		)	
	)
	(not (move-completed  (time ?)))
	=>
	(assert (exec (action turnleft)(time ?t)))
	(assert (move-completed  (time ?t)))
	(modify ?f (step 1))
	(pop-focus)
)

; Omar 21/09/2005
; Regola che indica un movimento libero (si ha un blocco davanti ed entrambi i lati liberi). Di default si decide
; che la prima rotazione sarà verso sinistra. Alla successiva occasione di scelta si cambierà la direzione presa
; nella precedente scelta

; Regola per gestire la prima scelta di default (verso sinistra)
;OMAR 19/01/2006 - gestione celle unuseful
(defrule turn-default-first
	(declare (salience -15))
	?f <- (movement (step 0))
	(status (time ?t))
	(kpos (time ?t) (pos-r ?r) (pos-c ?c) (direction ?d)) 	
	(or
		(percepts (time ?t) (pos-r ?r)(pos-c ?c)(direction ?d)(perc1 wall|entry|exit)(perc2 ?p2)(perc3 ?p3)(cry ?))
		(and
			(test (= (str-compare ?d up) 0))
			(unuseful-cell (pos-r ?r1) (pos-c ?c))
			(test (= (- ?r 1) ?r1))				
		)
		(and
			(test (= (str-compare ?d down) 0))
			(unuseful-cell (pos-r ?r1) (pos-c ?c))
			(test (= (+ ?r 1) ?r1))				
		)
		(and
			(test (= (str-compare ?d left) 0))
			(unuseful-cell (pos-r ?r) (pos-c ?c1))
			(test (= (- ?c 1) ?c1))				
		)
		(and
			(test (= (str-compare ?d right) 0))
			(unuseful-cell (pos-r ?r) (pos-c ?c1))
			(test (= (+ ?c 1) ?c1))				
		)
	)
	(not (default-choice (pos-r ?r)(pos-c ?c)))
	(not (move-completed  (time ?)))
	(or
		(and
			(test (= (str-compare ?d left) 0))
			(map (pos-r ?r1) (pos-c ?c) (contains empty|debris))
			(map (pos-r ?r2) (pos-c ?c) (contains empty|debris))
			(or
				(and
					(exec-path (time ~2) (pos-r ?r1) (pos-c ?c) (module ?))
					(exec-path (time ~2) (pos-r ?r2) (pos-c ?c) (module ?))
				)
				(and
					(not (exec-path (time ~2) (pos-r ?r1) (pos-c ?c) (module ?)))
					(not (exec-path (time ~2) (pos-r ?r2) (pos-c ?c) (module ?)))
				)
			)			
			(test (= (- ?r 1) ?r1))
			(test (= (+ ?r 1) ?r2))
		)
		(and
			(test (= (str-compare ?d right) 0))
			(map (pos-r ?r1) (pos-c ?c) (contains empty|debris))
			(map (pos-r ?r2) (pos-c ?c) (contains empty|debris))
			(or
				(and
					(exec-path (time ~2) (pos-r ?r1) (pos-c ?c) (module ?))
					(exec-path (time ~2) (pos-r ?r2) (pos-c ?c) (module ?))
				)
				(and
					(not (exec-path (time ~2) (pos-r ?r1) (pos-c ?c) (module ?)))
					(not (exec-path (time ~2) (pos-r ?r2) (pos-c ?c) (module ?)))
				)
			)
			(test (= (- ?r 1) ?r1))
			(test (= (+ ?r 1) ?r2))
		)

		(and
			(test (= (str-compare ?d up) 0))
			(map (pos-r ?r) (pos-c ?c1) (contains empty|debris))
			(map (pos-r ?r) (pos-c ?c2) (contains empty|debris))
			(or
				(and
					(exec-path (time ~2) (pos-r ?r) (pos-c ?c1) (module ?))
					(exec-path (time ~2) (pos-r ?r) (pos-c ?c2) (module ?))
				)
				(and
					(not (exec-path (time ~2) (pos-r ?r) (pos-c ?c1) (module ?)))
					(not (exec-path (time ~2) (pos-r ?r) (pos-c ?c2) (module ?)))
				)
			)
			(test (= (- ?c 1) ?c1))
			(test (= (+ ?c 1) ?c2))
		)
		(and
			(test (= (str-compare ?d down) 0))
			(map (pos-r ?r) (pos-c ?c1) (contains empty|debris))
			(map (pos-r ?r) (pos-c ?c2) (contains empty|debris))
			(or
				(and
					(exec-path (time ~2) (pos-r ?r) (pos-c ?c1) (module ?))
					(exec-path (time ~2) (pos-r ?r) (pos-c ?c2) (module ?))
				)
				(and
					(not (exec-path (time ~2) (pos-r ?r) (pos-c ?c1) (module ?)))
					(not (exec-path (time ~2) (pos-r ?r) (pos-c ?c2) (module ?)))
				)
			)
			(test (= (- ?c 1) ?c1))
			(test (= (+ ?c 1) ?c2))
		)
	)
	=>
	(assert (exec (action turnleft)(time ?t)))
	(assert (move-completed (time ?t)))
	(modify ?f (step 1))
	(assert (default-choice (pos-r ?r) (pos-c ?c) (direction ?d) (choice left)))
	(pop-focus)
)

; Regola per gestire le scelte successive
; rotazione precedente verso destra --> adesso bisogna andare a sinistra
;OMAR 19/01/2006 - gestione celle unuseful
(defrule turn-default-left
	(declare (salience -15))
	?f <- (movement (step 0))
	(status (time ?t))
	(kpos (time ?t) (pos-r ?r) (pos-c ?c) (direction ?d)) 	
	(or
		(percepts (time ?t) (pos-r ?r)(pos-c ?c)(direction ?d)(perc1 wall|entry|exit)(perc2 ?p2)(perc3 ?p3)(cry ?))
		(and
			(test (= (str-compare ?d up) 0))
			(unuseful-cell (pos-r ?r1) (pos-c ?c))
			(test (= (- ?r 1) ?r1))				
		)
		(and
			(test (= (str-compare ?d down) 0))
			(unuseful-cell (pos-r ?r1) (pos-c ?c))
			(test (= (+ ?r 1) ?r1))				
		)
		(and
			(test (= (str-compare ?d left) 0))
			(unuseful-cell (pos-r ?r) (pos-c ?c1))
			(test (= (- ?c 1) ?c1))				
		)
		(and
			(test (= (str-compare ?d right) 0))
			(unuseful-cell (pos-r ?r) (pos-c ?c1))
			(test (= (+ ?c 1) ?c1))				
		)
	)
	?f1 <- (default-choice (pos-r ?r)(pos-c ?c)(direction ?d)(choice right))
	(or
		(and
			(test (= (str-compare ?d left) 0))
			(map (pos-r ?r1) (pos-c ?c) (contains empty|debris))
			(map (pos-r ?r2) (pos-c ?c) (contains empty|debris))
			(or
				(and
					(exec-path (time ~2) (pos-r ?r1) (pos-c ?c) (module ?))
					(exec-path (time ~2) (pos-r ?r2) (pos-c ?c) (module ?))
				)
				(and
					(not (exec-path (time ~2) (pos-r ?r1) (pos-c ?c) (module ?)))
					(not (exec-path (time ~2) (pos-r ?r2) (pos-c ?c) (module ?)))
				)
			)
			(test (= (- ?r 1) ?r1))
			(test (= (+ ?r 1) ?r2))
		)
		(and
			(test (= (str-compare ?d right) 0))
			(map (pos-r ?r1) (pos-c ?c) (contains empty|debris))
			(map (pos-r ?r2) (pos-c ?c) (contains empty|debris))
			(or
				(and
					(exec-path (time ~2) (pos-r ?r1) (pos-c ?c) (module ?))
					(exec-path (time ~2) (pos-r ?r2) (pos-c ?c) (module ?))
				)
				(and
					(not (exec-path (time ~2) (pos-r ?r1) (pos-c ?c) (module ?)))
					(not (exec-path (time ~2) (pos-r ?r2) (pos-c ?c) (module ?)))
				)
			)			
			(test (= (- ?r 1) ?r1))
			(test (= (+ ?r 1) ?r2))
		)

		(and
			(test (= (str-compare ?d up) 0))
			(map (pos-r ?r) (pos-c ?c1) (contains empty|debris))
			(map (pos-r ?r) (pos-c ?c2) (contains empty|debris))
			(or
				(and
					(exec-path (time ~2) (pos-r ?r) (pos-c ?c1) (module ?))
					(exec-path (time ~2) (pos-r ?r) (pos-c ?c2) (module ?))
				)
				(and
					(not (exec-path (time ~2) (pos-r ?r) (pos-c ?c1) (module ?)))
					(not (exec-path (time ~2) (pos-r ?r) (pos-c ?c2) (module ?)))
				)
			)
			(test (= (- ?c 1) ?c1))
			(test (= (+ ?c 1) ?c2))
		)
		(and
			(test (= (str-compare ?d down) 0))
			(map (pos-r ?r) (pos-c ?c1) (contains empty|debris))
			(map (pos-r ?r) (pos-c ?c2) (contains empty|debris))
			(or
				(and
					(exec-path (time ~2) (pos-r ?r) (pos-c ?c1) (module ?))
					(exec-path (time ~2) (pos-r ?r) (pos-c ?c2) (module ?))
				)
				(and
					(not (exec-path (time ~2) (pos-r ?r) (pos-c ?c1) (module ?)))
					(not (exec-path (time ~2) (pos-r ?r) (pos-c ?c2) (module ?)))
				)
			)
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
;OMAR 19/01/2006 - gestione celle unuseful
(defrule turn-default-right
	(declare (salience -15))
	?f <- (movement (step 0))
	(status (time ?t))
	(kpos (time ?t) (pos-r ?r) (pos-c ?c) (direction ?d)) 	
	(or
		(percepts (time ?t) (pos-r ?r)(pos-c ?c)(direction ?d)(perc1 wall|entry|exit)(perc2 ?p2)(perc3 ?p3)(cry ?))
		(and
			(test (= (str-compare ?d up) 0))
			(unuseful-cell (pos-r ?r1) (pos-c ?c))
			(test (= (- ?r 1) ?r1))				
		)
		(and
			(test (= (str-compare ?d down) 0))
			(unuseful-cell (pos-r ?r1) (pos-c ?c))
			(test (= (+ ?r 1) ?r1))				
		)
		(and
			(test (= (str-compare ?d left) 0))
			(unuseful-cell (pos-r ?r) (pos-c ?c1))
			(test (= (- ?c 1) ?c1))				
		)
		(and
			(test (= (str-compare ?d right) 0))
			(unuseful-cell (pos-r ?r) (pos-c ?c1))
			(test (= (+ ?c 1) ?c1))				
		)
	)
	?f1 <- (default-choice (pos-r ?r)(pos-c ?c)(direction ?d)(choice left))
	(or
		(and
			(test (= (str-compare ?d left) 0))
			(map (pos-r ?r1) (pos-c ?c) (contains empty|debris))
			(map (pos-r ?r2) (pos-c ?c) (contains empty|debris))
			(or
				(and
					(exec-path (time ~2) (pos-r ?r1) (pos-c ?c) (module ?))
					(exec-path (time ~2) (pos-r ?r2) (pos-c ?c) (module ?))
				)
				(and
					(not (exec-path (time ~2) (pos-r ?r1) (pos-c ?c) (module ?)))
					(not (exec-path (time ~2) (pos-r ?r2) (pos-c ?c) (module ?)))
				)
			)
			(test (= (- ?r 1) ?r1))
			(test (= (+ ?r 1) ?r2))
		)
		(and
			(test (= (str-compare ?d right) 0))
			(map (pos-r ?r1) (pos-c ?c) (contains empty|debris))
			(map (pos-r ?r2) (pos-c ?c) (contains empty|debris))
			(or
				(and
					(exec-path (time ~2) (pos-r ?r1) (pos-c ?c) (module ?))
					(exec-path (time ~2) (pos-r ?r2) (pos-c ?c) (module ?))
				)
				(and
					(not (exec-path (time ~2) (pos-r ?r1) (pos-c ?c) (module ?)))
					(not (exec-path (time ~2) (pos-r ?r2) (pos-c ?c) (module ?)))
				)
			)
			(test (= (- ?r 1) ?r1))
			(test (= (+ ?r 1) ?r2))
		)

		(and
			(test (= (str-compare ?d up) 0))
			(map (pos-r ?r) (pos-c ?c1) (contains empty|debris))
			(map (pos-r ?r) (pos-c ?c2) (contains empty|debris))
			(or
				(and
					(exec-path (time ~2) (pos-r ?r) (pos-c ?c1) (module ?))
					(exec-path (time ~2) (pos-r ?r) (pos-c ?c2) (module ?))
				)
				(and
					(not (exec-path (time ~2) (pos-r ?r) (pos-c ?c1) (module ?)))
					(not (exec-path (time ~2) (pos-r ?r) (pos-c ?c2) (module ?)))
				)
			)
			(test (= (- ?c 1) ?c1))
			(test (= (+ ?c 1) ?c2))
		)
		(and
			(test (= (str-compare ?d down) 0))
			(map (pos-r ?r) (pos-c ?c1) (contains empty|debris))
			(map (pos-r ?r) (pos-c ?c2) (contains empty|debris))
			(or
				(and
					(exec-path (time ~2) (pos-r ?r) (pos-c ?c1) (module ?))
					(exec-path (time ~2) (pos-r ?r) (pos-c ?c2) (module ?))
				)
				(and
					(not (exec-path (time ~2) (pos-r ?r) (pos-c ?c1) (module ?)))
					(not (exec-path (time ~2) (pos-r ?r) (pos-c ?c2) (module ?)))
				)
			)
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

; Gestione dei vicoli chiechi logici, vengono sempre sfondati per far proseguire il robot nella direzione 
; in cui sta procedendo
;OMAR 19/01/2006 - gestione celle unuseful
(defrule force-logical-blindalley
	(declare (salience -18))	
	?f <- (movement (step 0))
	(status (time ?t))
	(kpos (time ?t) (pos-r ?r) (pos-c ?c) (direction ?d) (load ?))
	(not (move-completed  (time ?)))	
	(or
		; direzione UP
		(and
			(test (= (str-compare ?d up) 0))
			(exec-path (time ~2) (pos-r ?r1) (pos-c ?c) (module ?))
			(test (= (- ?r 1) ?r1))
			(or 
				(map (pos-r ?r) (pos-c ?c1) (contains wall|entry|exit))
				(exec-path (time ~2) (pos-r ?r) (pos-c ?c1) (module ?))
				(unuseful-cell (pos-r ?r) (pos-c ?c1))				
			)				
			(test (= (- ?c 1) ?c1))			
			(or 
				(map (pos-r ?r) (pos-c ?c2) (contains wall|entry|exit))
				(exec-path (time ~2) (pos-r ?r) (pos-c ?c2) (module ?))
				(unuseful-cell (pos-r ?r) (pos-c ?c2))				
			)				
			(test (= (+ ?c 1) ?c2))
	        )
		; direzione DOWN
		(and
			(test (= (str-compare ?d down) 0))
			(exec-path (time ~2) (pos-r ?r1) (pos-c ?c) (module ?))
			(test (= (+ ?r 1) ?r1))
			(or 
				(map (pos-r ?r) (pos-c ?c1) (contains wall|entry|exit))
				(exec-path (time ~2) (pos-r ?r) (pos-c ?c1) (module ?))
				(unuseful-cell (pos-r ?r) (pos-c ?c1))				
			)				
			(test (= (+ ?c 1) ?c1))
			(or 
				(map (pos-r ?r) (pos-c ?c2) (contains wall|entry|exit))
				(exec-path (time ~2) (pos-r ?r) (pos-c ?c2) (module ?))
				(unuseful-cell (pos-r ?r) (pos-c ?c2))				
			)				
			(test (= (- ?c 1) ?c2))		
	        )
		; direzione LEFT
		(and
			(test (= (str-compare ?d left) 0))
			(exec-path (time ~2) (pos-r ?r) (pos-c ?c1) (module ?))
			(test (= (- ?c 1) ?c1))
			(or 
				(map (pos-r ?r1) (pos-c ?c) (contains wall|entry|exit))
				(exec-path (time ~2) (pos-r ?r1) (pos-c ?c) (module ?))
				(unuseful-cell (pos-r ?r1) (pos-c ?c))				
			)				
			(test (= (- ?r 1) ?r1))
			(or 
				(map (pos-r ?r2) (pos-c ?c) (contains wall|entry|exit))
				(exec-path (time ~2) (pos-r ?r2) (pos-c ?c) (module ?))
				(unuseful-cell (pos-r ?r2) (pos-c ?c))				
			)				
			(test (= (+ ?r 1) ?r2))
	    	)
		; direzione RIGHT
		(and
			(test (= (str-compare ?d right) 0))
			(exec-path (time ~2) (pos-r ?r) (pos-c ?c1) (module ?))
			(test (= (+ ?c 1) ?c1))
			(or 
				(map (pos-r ?r1) (pos-c ?c) (contains wall|entry|exit))
				(exec-path (time ~2) (pos-r ?r1) (pos-c ?c) (module ?))
				(unuseful-cell (pos-r ?r1) (pos-c ?c))				
			)				
			(test (= (+ ?r 1) ?r1))
			(or 
				(map (pos-r ?r2) (pos-c ?c) (contains wall|entry|exit))
				(exec-path (time ~2) (pos-r ?r2) (pos-c ?c) (module ?))
				(unuseful-cell (pos-r ?r2) (pos-c ?c))				
			)				
			(test (= (- ?r 1) ?r2))
	    )
	)
	=>
	(assert (exec (action go)(time ?t)))
	(assert (move-completed (time ?t)))
	(modify ?f (step 1))
	(pop-focus)
)

; AGGIUNTA: uso le exec-path al posto delle kpos, perchè mi dicono anche il modulo in cui ero
; quando sono stato su una cella. Serve per distinguere i blocchi logici di EXPLORE con quelli
; di EXIT.

; Fa girare il robot a destra prima di sbattere contro un muro logico (una cella giá visitata)
;OMAR 19/01/2006 - gestione celle unuseful
(defrule turn-right-logical
	(declare (salience -20))
	?f <- (movement (step 0))
	;(action (module ?act))	
	(kpos (time ?t) (pos-r ?r) (pos-c ?c) (direction ?d) (load ?))
	(status (time ?t))
	(or
		; direzione UP
		(and
			(test (= (str-compare ?d up) 0))
			(exec-path (time ?) (pos-r ?r1) (pos-c ?c) (module ?))
			(test (= (- ?r 1) ?r1))
			(or 
				(map (pos-r ?r) (pos-c ?c1) (contains wall|entry|exit))
				(exec-path (time ?) (pos-r ?r) (pos-c ?c1) (module ?))
				(unuseful-cell (pos-r ?r) (pos-c ?c1))				
			)				
			(test (= (- ?c 1) ?c1))
			(and
				(map (pos-r ?r) (pos-c ?c9) (contains ~wall&~entry&~exit))
				(not (unuseful-cell (pos-r ?r) (pos-c ?c9)))
			)
			(test (= (+ ?c 1) ?c9))
	    )
	    (and
	    	(test (= (str-compare ?d up) 0))
			(exec-path (time ?) (pos-r ?r) (pos-c ?c1) (module ?))
			(test (= (- ?c 1) ?c1))
			(or
				(map (pos-r ?r1) (pos-c ?c) (contains wall|entry|exit))
				(exec-path (time ?) (pos-r ?r1) (pos-c ?c) (module ?))
				(unuseful-cell (pos-r ?r1) (pos-c ?c))
			)
			(test (= (- ?r 1) ?r1))
			(and
				(map (pos-r ?r) (pos-c ?c9) (contains ~wall&~entry&~exit))
				(not (unuseful-cell (pos-r ?r) (pos-c ?c9)))
			)
			(test (= (+ ?c 1) ?c9))
	    )

		; direzione DOWN
		(and
			(test (= (str-compare ?d down) 0))
			(exec-path (time ?) (pos-r ?r1) (pos-c ?c) (module ?))
			(test (= (+ ?r 1) ?r1))
			(or 
				(map (pos-r ?r) (pos-c ?c1) (contains wall|entry|exit))
				(exec-path (time ?) (pos-r ?r) (pos-c ?c1) (module ?))
				(unuseful-cell (pos-r ?r) (pos-c ?c1))
			)				
			(test (= (+ ?c 1) ?c1))
			(and
				(map (pos-r ?r) (pos-c ?c9) (contains ~wall&~entry&~exit))
				(not (unuseful-cell (pos-r ?r) (pos-c ?c9)))
			)
			(test (= (- ?c 1) ?c9))
	    )
	    (and
	    	(test (= (str-compare ?d down) 0))
			(exec-path (time ?) (pos-r ?r) (pos-c ?c1) (module ?))
			(test (= (+ ?c 1) ?c1))
			(or
				(map (pos-r ?r1) (pos-c ?c) (contains wall|entry|exit))
				(exec-path (time ?) (pos-r ?r1) (pos-c ?c) (module ?))
				(unuseful-cell (pos-r ?r1) (pos-c ?c))
			)
			(test (= (+ ?r 1) ?r1))
			(and
				(map (pos-r ?r) (pos-c ?c9) (contains ~wall&~entry&~exit))
				(not (unuseful-cell (pos-r ?r) (pos-c ?c9)))
			)
			(test (= (- ?c 1) ?c9))
	    )

		; direzione LEFT
		(and
			(test (= (str-compare ?d left) 0))
			(exec-path (time ?) (pos-r ?r1) (pos-c ?c) (module ?))
			(test (= (+ ?r 1) ?r1))
			(or 
				(map (pos-r ?r) (pos-c ?c1) (contains wall|entry|exit))
				(exec-path (time ?) (pos-r ?r) (pos-c ?c1) (module ?))
				(unuseful-cell (pos-r ?r) (pos-c ?c1))
			)				
			(test (= (- ?c 1) ?c1))
			(and
				(map (pos-r ?r9) (pos-c ?c) (contains ~wall&~entry&~exit))
				(not (unuseful-cell (pos-r ?r9) (pos-c ?c)))
			)
			(test (= (- ?r 1) ?r9))
	    )
	    (and
	    	(test (= (str-compare ?d left) 0))
			(exec-path (time ?) (pos-r ?r) (pos-c ?c1) (module ?))
			(test (= (- ?c 1) ?c1))
			(or
				(map (pos-r ?r1) (pos-c ?c) (contains wall|entry|exit))
				(exec-path (time ?) (pos-r ?r1) (pos-c ?c) (module ?))
				(unuseful-cell (pos-r ?r1) (pos-c ?c))
			)
			(test (= (+ ?r 1) ?r1))
			(and
				(map (pos-r ?r9) (pos-c ?c) (contains ~wall&~entry&~exit))
				(not (unuseful-cell (pos-r ?r9) (pos-c ?c)))
			)
			(test (= (- ?r 1) ?r9))
	    )

		; direzione RIGHT
		(and
			(test (= (str-compare ?d right) 0))
			(exec-path (time ?) (pos-r ?r1) (pos-c ?c) (module ?))
			(test (= (- ?r 1) ?r1))
			(or 
				(map (pos-r ?r) (pos-c ?c1) (contains wall|entry|exit))
				(exec-path (time ?) (pos-r ?r) (pos-c ?c1) (module ?))
				(unuseful-cell (pos-r ?r) (pos-c ?c1))				
			)				
			(test (= (+ ?c 1) ?c1))
			(and
				(map (pos-r ?r9) (pos-c ?c) (contains ~wall&~entry&~exit))
				(not (unuseful-cell (pos-r ?r9) (pos-c ?c)))
			)
			(test (= (+ ?r 1) ?r9))
	    )
	    (and
	    	(test (= (str-compare ?d right) 0))
			(exec-path (time ?) (pos-r ?r) (pos-c ?c1) (module ?))
			(test (= (+ ?c 1) ?c1))
			(or
				(map (pos-r ?r1) (pos-c ?c) (contains wall|entry|exit))
				(exec-path (time ?) (pos-r ?r1) (pos-c ?c) (module ?))
				(unuseful-cell (pos-r ?r1) (pos-c ?c))				
			)
			(test (= (- ?r 1) ?r1))
			(and
				(map (pos-r ?r9) (pos-c ?c) (contains ~wall&~entry&~exit))
				(not (unuseful-cell (pos-r ?r9) (pos-c ?c)))
			)
			(test (= (+ ?r 1) ?r9))
	    )
	)
	(not (move-completed (time ?)))
	=>
	(assert (exec (action turnright)(time ?t)))
	(assert (move-completed (time ?t)))
	(modify ?f (step 1))
	(pop-focus)	
)

; Fa girare il robot a destra prima di sbattere contro un muro logico (una cella giá visitata)
;OMAR 19/01/2006 - gestione celle unuseful
(defrule turn-left-logical
	(declare (salience -20))
	?f <- (movement (step 0))
	;(action (module ?act))
	(status (time ?t))
	(kpos (time ?t) (pos-r ?r) (pos-c ?c) (direction ?d) (load ?))
	(or
		; direzione RIGHT
		(and
			(test (= (str-compare ?d right) 0))
			(exec-path (time ?) (pos-r ?r1) (pos-c ?c) (module ?))
			(test (= (+ ?r 1) ?r1))
			(or 
				(map (pos-r ?r) (pos-c ?c1) (contains wall|entry|exit))
				(exec-path (time ?) (pos-r ?r) (pos-c ?c1) (module ?))
				(unuseful-cell (pos-r ?r) (pos-c ?c1))
			)				
			(test (= (+ ?c 1) ?c1))
			(and
				(map (pos-r ?r9) (pos-c ?c) (contains ~wall&~entry&~exit))
				(not (unuseful-cell (pos-r ?r9) (pos-c ?c)))
			)
			(test (= (- ?r 1) ?r9))
	    )
	    (and
	    	(test (= (str-compare ?d right) 0))
			(exec-path (time ?) (pos-r ?r) (pos-c ?c1) (module ?))
			(test (= (+ ?c 1) ?c1))
			(or
				(map (pos-r ?r1) (pos-c ?c) (contains wall|entry|exit))
				(exec-path (time ?) (pos-r ?r1) (pos-c ?c) (module ?))
				(unuseful-cell (pos-r ?r1) (pos-c ?c))				
			)
			(test (= (+ ?r 1) ?r1))
			(and
				(map (pos-r ?r9) (pos-c ?c) (contains ~wall&~entry&~exit))
				(not (unuseful-cell (pos-r ?r9) (pos-c ?c)))
			)
			(test (= (- ?r 1) ?r9))
	    )

		; direzione LEFT
		(and
			(test (= (str-compare ?d left) 0))
			(exec-path (time ?) (pos-r ?r1) (pos-c ?c) (module ?))
			(test (= (- ?r 1) ?r1))
			(or 
				(map (pos-r ?r) (pos-c ?c1) (contains wall|entry|exit))
				(exec-path (time ?) (pos-r ?r) (pos-c ?c1) (module ?))
				(unuseful-cell (pos-r ?r) (pos-c ?c1))				
			)				
			(test (= (- ?c 1) ?c1))
			(and
				(map (pos-r ?r9) (pos-c ?c) (contains ~wall&~entry&~exit))
				(not (unuseful-cell (pos-r ?r9) (pos-c ?c)))
			)
			(test (= (+ ?r 1) ?r9))
	    )
	    (and
	    	(test (= (str-compare ?d left) 0))
			(exec-path (time ?) (pos-r ?r) (pos-c ?c1) (module ?))
			(test (= (- ?c 1) ?c1))
			(or
				(map (pos-r ?r1) (pos-c ?c) (contains wall|entry|exit))
				(exec-path (time ?) (pos-r ?r1) (pos-c ?c) (module ?))
				(unuseful-cell (pos-r ?r1) (pos-c ?c))				
			)
			(test (= (- ?r 1) ?r1))
			(and
				(map (pos-r ?r9) (pos-c ?c) (contains ~wall&~entry&~exit))
				(not (unuseful-cell (pos-r ?r9) (pos-c ?c)))
			)
			(test (= (+ ?r 1) ?r9))
	    )

		; direzione DOWN
		(and
			(test (= (str-compare ?d down) 0))
			(exec-path (time ?) (pos-r ?r1) (pos-c ?c) (module ?))
			(test (= (+ ?r 1) ?r1))
			(or 
				(map (pos-r ?r) (pos-c ?c1) (contains wall|entry|exit))
				(exec-path (time ?) (pos-r ?r) (pos-c ?c1) (module ?))
				(unuseful-cell (pos-r ?r) (pos-c ?c1))				
			)				
			(test (= (- ?c 1) ?c1))
			(and
				(map (pos-r ?r) (pos-c ?c9) (contains ~wall&~entry&~exit))
				(not (unuseful-cell (pos-r ?r) (pos-c ?c9)))
			)
			(test (= (+ ?c 1) ?c9))
	    )
	    (and
	    	(test (= (str-compare ?d down) 0))
			(exec-path (time ?) (pos-r ?r) (pos-c ?c1) (module ?))
			(test (= (- ?c 1) ?c1))
			(or
				(map (pos-r ?r1) (pos-c ?c) (contains wall|entry|exit))
				(exec-path (time ?) (pos-r ?r1) (pos-c ?c) (module ?))
				(unuseful-cell (pos-r ?r1) (pos-c ?c))				
			)
			(test (= (+ ?r 1) ?r1))
			(and
				(map (pos-r ?r) (pos-c ?c9) (contains ~wall&~entry&~exit))
				(not (unuseful-cell (pos-r ?r) (pos-c ?c9)))
			)
			(test (= (+ ?c 1) ?c9))
	    )

		; direzione UP
		(and
			(test (= (str-compare ?d up) 0))
			(exec-path (time ?) (pos-r ?r1) (pos-c ?c) (module ?))
			(test (= (- ?r 1) ?r1))
			(or 
				(map (pos-r ?r) (pos-c ?c1) (contains wall|entry|exit))
				(exec-path (time ?) (pos-r ?r) (pos-c ?c1) (module ?))
				(unuseful-cell (pos-r ?r) (pos-c ?c1))				
			)				
			(test (= (+ ?c 1) ?c1))
			(and
				(map (pos-r ?r) (pos-c ?c9) (contains ~wall&~entry&~exit))
				(not (unuseful-cell (pos-r ?r) (pos-c ?c9)))
			)
			(test (= (- ?c 1) ?c9))
	    )
	    (and
	    	(test (= (str-compare ?d up) 0))
			(exec-path (time ?) (pos-r ?r) (pos-c ?c1) (module ?))
			(test (= (+ ?c 1) ?c1))
			(or
				(map (pos-r ?r1) (pos-c ?c) (contains wall|entry|exit))
				(exec-path (time ?) (pos-r ?r1) (pos-c ?c) (module ?))
				(unuseful-cell (pos-r ?r1) (pos-c ?c))				
			)
			(test (= (- ?r 1) ?r1))
			(and
				(map (pos-r ?r) (pos-c ?c9) (contains ~wall&~entry&~exit))
				(not (unuseful-cell (pos-r ?r) (pos-c ?c9)))
			)
			(test (= (- ?c 1) ?c9))
	    )
	)
	(not (move-completed (time ?)))
	=>
	(assert (exec (action turnleft)(time ?t)))
	(assert (move-completed (time ?t)))
	(modify ?f (step 1))
	(pop-focus)
)


; 29/12/2005 - Nuova stretegia anti-loop
; Si contano i passaggi sulle celle della mappa, e se nelle celle adiacenti rispetto a quella davanti
; al robot ci sono meno passaggi, allora si gira verso quella con meno passaggi 
;OMAR 19/01/2006 - gestione celle unuseful
(defrule loop-prevention-right
	(declare (salience -15))
	?f <- (movement (step 0))
	;(action (module ?act))	
	(kpos (time ?t) (pos-r ?r) (pos-c ?c) (direction ?d) (load ?))
	(status (time ?t))
	(or
		; direzione UP
		(and
			(test (= (str-compare ?d up) 0))
			(and
				(map (pos-r ?r1) (pos-c ?c) (contains ~wall&~entry&~exit) (counter ?cnt-f))
				(not (unuseful-cell (pos-r ?r1) (pos-c ?c)))				
			)
			(test (= (- ?r 1) ?r1))
			(or
				(and
					(and
						(map (pos-r ?r) (pos-c ?c1) (contains ~wall&~entry&~exit) (counter ?cnt-l))
						(not (unuseful-cell (pos-r ?r) (pos-c ?c1)))
					)
					(and
						(map (pos-r ?r) (pos-c ?c2) (contains ~wall&~entry&~exit) (counter ?cnt-r))
						(not (unuseful-cell (pos-r ?r) (pos-c ?c2)))
					)
					(test (= (- ?c 1) ?c1))
					(test (= (+ ?c 1) ?c2))
					(test (< ?cnt-r ?cnt-l))			
				)
				(and
					(map (pos-r ?r) (pos-c ?c1) (contains ?) (counter ?cnt-l))
					(and
						(map (pos-r ?r) (pos-c ?c2) (contains ~wall&~entry&~exit) (counter ?cnt-r))
						(not (unuseful-cell (pos-r ?r) (pos-c ?c2)))
					)
					(test (= (- ?c 1) ?c1))
					(test (= (+ ?c 1) ?c2))
				)
			)
			(test (< ?cnt-r (- ?cnt-f 1)))
	    )
		
		; direzione DOWN
		(and
			(test (= (str-compare ?d down) 0))
			(and
				(map (pos-r ?r1) (pos-c ?c) (contains ~wall&~entry&~exit) (counter ?cnt-f))
				(not (unuseful-cell (pos-r ?r1) (pos-c ?c)))
			)
			(test (= (+ ?r 1) ?r1))
			(or
				(and
					(and
						(map (pos-r ?r) (pos-c ?c1) (contains ~wall&~entry&~exit) (counter ?cnt-r))
						(not (unuseful-cell (pos-r ?r) (pos-c ?c1)))
					)
					(and
						(map (pos-r ?r) (pos-c ?c2) (contains ~wall&~entry&~exit) (counter ?cnt-l))
						(not (unuseful-cell (pos-r ?r) (pos-c ?c2)))
					)
					(test (= (- ?c 1) ?c1))
					(test (= (+ ?c 1) ?c2))
					(test (< ?cnt-r ?cnt-l))
				)
				(and
					(and
						(map (pos-r ?r) (pos-c ?c1) (contains ~wall&~entry&~exit) (counter ?cnt-r))
						(not (unuseful-cell (pos-r ?r) (pos-c ?c1)))
					)
					(map (pos-r ?r) (pos-c ?c2) (contains ?) (counter ?cnt-l))
					(test (= (- ?c 1) ?c1))
					(test (= (+ ?c 1) ?c2))
				)
			)		
			(test (< ?cnt-r (- ?cnt-f 1)))
	    )

		; direzione LEFT
		(and
			(test (= (str-compare ?d left) 0))
			(and
				(map (pos-r ?r) (pos-c ?c1) (contains ~wall&~entry&~exit) (counter ?cnt-f))
				(not (unuseful-cell (pos-r ?r) (pos-c ?c1)))
			)
			(test (= (- ?c 1) ?c1))
			(or
				(and
					(and
						(map (pos-r ?r1) (pos-c ?c) (contains ~wall&~entry&~exit) (counter ?cnt-r))
						(not (unuseful-cell (pos-r ?r1) (pos-c ?c)))
					)
					(and
						(map (pos-r ?r2) (pos-c ?c) (contains ~wall&~entry&~exit) (counter ?cnt-l))
						(not (unuseful-cell (pos-r ?r2) (pos-c ?c)))
					)
					(test (= (- ?r 1) ?r1))
					(test (= (+ ?r 1) ?r2))
					(test (< ?cnt-r ?cnt-l))
				)
				(and
					(and
						(map (pos-r ?r1) (pos-c ?c) (contains ~wall&~entry&~exit) (counter ?cnt-r))
						(not (unuseful-cell (pos-r ?r1) (pos-c ?c)))
					)
					(map (pos-r ?r2) (pos-c ?c) (contains ?) (counter ?cnt-l))
					(test (= (- ?r 1) ?r1))
					(test (= (+ ?r 1) ?r2))
				)
			)
			(test (< ?cnt-r (- ?cnt-f 1)))
	    )

		; direzione RIGHT
		(and
			(test (= (str-compare ?d right) 0))
			(and
				(map (pos-r ?r) (pos-c ?c1) (contains ~wall&~entry&~exit) (counter ?cnt-f))
				(not (unuseful-cell (pos-r ?r) (pos-c ?c1)))
			)
			(test (= (+ ?c 1) ?c1))
			(or
				(and
					(and
						(map (pos-r ?r1) (pos-c ?c) (contains ~wall&~entry&~exit) (counter ?cnt-l))
						(not (unuseful-cell (pos-r ?r1) (pos-c ?c)))
					)
					(and
						(map (pos-r ?r2) (pos-c ?c) (contains ~wall&~entry&~exit) (counter ?cnt-r))
						(not (unuseful-cell (pos-r ?r2) (pos-c ?c)))
					)
					(test (= (- ?r 1) ?r1))
					(test (= (+ ?r 1) ?r2))
					(test (< ?cnt-r ?cnt-l))
				)
				(and
					(map (pos-r ?r1) (pos-c ?c) (contains ?) (counter ?cnt-l))
					(and
						(map (pos-r ?r2) (pos-c ?c) (contains ~wall&~entry&~exit) (counter ?cnt-r))
						(not (unuseful-cell (pos-r ?r2) (pos-c ?c)))
					)
					(test (= (- ?r 1) ?r1))
					(test (= (+ ?r 1) ?r2))
				)
			)
			(test (< ?cnt-r (- ?cnt-f 1)))
	    )
	)
	(not (move-completed (time ?)))
	=>
	(assert (exec (action turnright)(time ?t)))
	(assert (move-completed (time ?t)))
	(modify ?f (step 1))
	(pop-focus)
	
)


; Fa girare il robot a destra prima di sbattere contro un muro logico (una cella giá visitata)
;OMAR 19/01/2006 - gestione celle unuseful
(defrule loop-prevention-left
	(declare (salience -15))
	?f <- (movement (step 0))
	;(action (module ?act))
	(status (time ?t))
	(kpos (time ?t) (pos-r ?r) (pos-c ?c) (direction ?d) (load ?))
	(or
		; direzione UP
		(and
			(test (= (str-compare ?d up) 0))
			(and
				(map (pos-r ?r1) (pos-c ?c) (contains ~wall&~entry&~exit) (counter ?cnt-f))
				(not (unuseful-cell (pos-r ?r1) (pos-c ?c)))
			)
			(test (= (- ?r 1) ?r1))
			(or
				(and
					(and
						(map (pos-r ?r) (pos-c ?c1) (contains ~wall&~entry&~exit) (counter ?cnt-l))
						(not (unuseful-cell (pos-r ?r) (pos-c ?c1)))
					)						
					(and
						(map (pos-r ?r) (pos-c ?c2) (contains ~wall&~entry&~exit) (counter ?cnt-r))
						(not (unuseful-cell (pos-r ?r) (pos-c ?c2)))
					)
					(test (= (- ?c 1) ?c1))
					(test (= (+ ?c 1) ?c2))
					(test (<= ?cnt-l ?cnt-r))
				)
				(and
					(and
						(map (pos-r ?r) (pos-c ?c1) (contains ~wall&~entry&~exit) (counter ?cnt-l))
						(not (unuseful-cell (pos-r ?r) (pos-c ?c1)))
					)
					(map (pos-r ?r) (pos-c ?c2) (contains ?) (counter ?cnt-r))
					(test (= (- ?c 1) ?c1))
					(test (= (+ ?c 1) ?c2))
				)
			)
			(test (< ?cnt-l (- ?cnt-f 1)))
	    )
		
		; direzione DOWN
		(and
			(test (= (str-compare ?d down) 0))
			(and
				(map (pos-r ?r1) (pos-c ?c) (contains ~wall&~entry&~exit) (counter ?cnt-f))
				(not (unuseful-cell (pos-r ?r1) (pos-c ?c)))
			)
			(test (= (+ ?r 1) ?r1))
			(or		
				(and
					(and
						(map (pos-r ?r) (pos-c ?c1) (contains ~wall&~entry&~exit) (counter ?cnt-r))
						(not (unuseful-cell (pos-r ?r) (pos-c ?c1)))
					)
					(and
						(map (pos-r ?r) (pos-c ?c2) (contains ~wall&~entry&~exit) (counter ?cnt-l))
						(not (unuseful-cell (pos-r ?r) (pos-c ?c2)))
					)
					(test (= (- ?c 1) ?c1))
					(test (= (+ ?c 1) ?c2))
					(test (<= ?cnt-l ?cnt-r))
				)
				(and
					(map (pos-r ?r) (pos-c ?c1) (contains ?) (counter ?cnt-r))
					(and
						(map (pos-r ?r) (pos-c ?c2) (contains ~wall&~entry&~exit) (counter ?cnt-l))
						(not (unuseful-cell (pos-r ?r) (pos-c ?c2)))
					)
					(test (= (- ?c 1) ?c1))
					(test (= (+ ?c 1) ?c2))
				)
			)
			(test (< ?cnt-l (- ?cnt-f 1)))
	    )

		; direzione LEFT
		(and
			(test (= (str-compare ?d left) 0))
			(and
				(map (pos-r ?r) (pos-c ?c1) (contains ~wall&~entry&~exit) (counter ?cnt-f))
				(not (unuseful-cell (pos-r ?r) (pos-c ?c1)))
			)
			(test (= (- ?c 1) ?c1))
			(or
				(and
					(and
						(map (pos-r ?r1) (pos-c ?c) (contains ~wall&~entry&~exit) (counter ?cnt-r))
						(not (unuseful-cell (pos-r ?r1) (pos-c ?c)))
					)
					(and
						(map (pos-r ?r2) (pos-c ?c) (contains ~wall&~entry&~exit) (counter ?cnt-l))
						(not (unuseful-cell (pos-r ?r2) (pos-c ?c)))
					)
					(test (= (- ?r 1) ?r1))
					(test (= (+ ?r 1) ?r2))
					(test (<= ?cnt-l ?cnt-r))
				)
				(and
					(map (pos-r ?r1) (pos-c ?c) (contains ?) (counter ?cnt-r))
					(and
						(map (pos-r ?r2) (pos-c ?c) (contains ~wall&~entry&~exit) (counter ?cnt-l))
						(not (unuseful-cell (pos-r ?r2) (pos-c ?c)))
					)
					(test (= (- ?r 1) ?r1))
					(test (= (+ ?r 1) ?r2))
				)
			)
			(test (< ?cnt-l (- ?cnt-f 1)))
	    )

		; direzione RIGHT
		(and
			(test (= (str-compare ?d right) 0))
			(and
				(map (pos-r ?r) (pos-c ?c1) (contains ~wall&~entry&~exit) (counter ?cnt-f))
				(not (unuseful-cell (pos-r ?r) (pos-c ?c1)))
			)
			(test (= (+ ?c 1) ?c1))
			(or			
				(and
					(and
						(map (pos-r ?r1) (pos-c ?c) (contains ~wall&~entry&~exit) (counter ?cnt-l))
						(not (unuseful-cell (pos-r ?r1) (pos-c ?c)))
					)
					(and
						(map (pos-r ?r2) (pos-c ?c) (contains ~wall&~entry&~exit) (counter ?cnt-r))
						(not (unuseful-cell (pos-r ?r2) (pos-c ?c)))
					)
					(test (= (- ?r 1) ?r1))
					(test (= (+ ?r 1) ?r2))
					(test (<= ?cnt-l ?cnt-r))			
				)
				(and
					(and
						(map (pos-r ?r1) (pos-c ?c) (contains ~wall&~entry&~exit) (counter ?cnt-l))
						(not (unuseful-cell (pos-r ?r1) (pos-c ?c)))
					)
					(map (pos-r ?r2) (pos-c ?c) (contains ?) (counter ?cnt-r))
					(test (= (- ?r 1) ?r1))
					(test (= (+ ?r 1) ?r2))
				)
			)
			(test (< ?cnt-l (- ?cnt-f 1)))
	    )
	)
	(not (move-completed (time ?)))
	=>
	(assert (exec (action turnleft)(time ?t)))
	(assert (move-completed (time ?t)))
	(modify ?f (step 1))
	(pop-focus)
)
	
; Fa proseguire il robot nella direzione in cui e' rivolto avanzando di un passo
(defrule go-on
	(declare (salience -35))
	?f <- (movement (step 0))
	(status (time ?t))
	(not (exec (action ?) (time ?t)))
	(not (move-completed  (time ?)))
	=>
	(assert (exec (action go) (time ?t) ))
	(assert (move-completed (time ?t)))
	(modify ?f (step 1))
	(pop-focus)
)

; ---------------------------------------------------------------------------------
;				   FINE MODULO STANDARD-MOVE
; ---------------------------------------------------------------------------------

; ---------------------------------------------------------------------------------
; MODULO AGENT - Componente PLAN
; ---------------------------------------------------------------------------------

(defmodule PLAN (import AGENT ?ALL)(export ?ALL))

; Modulo per gestire pianificazione verso uscita

(deftemplate solution (slot value (default no))) 

(deftemplate virtual-pos
	(slot level)
	(slot pos-r)
	(slot pos-c)
	(slot direction)
)

(deftemplate delete
	(slot level)
	(slot pos-r)
	(slot pos-c)
	(slot direction)
)

; OMAR Ho aggiunto gli slot old-... perchè devo tenere traccia della posizione precedente del robot
; per poterla eliminare correttamente mediante i fatti "delete"
(deftemplate apply
	(slot level)
	(slot action)
	(slot pos-r)
	(slot pos-c)
	(slot dir)
	(slot old-r)
	(slot old-c)
	(slot old-dir)
)

(deftemplate node
	(slot level)
	(slot action)
	(slot index)
	(slot ancestor)
)

(deftemplate node-ancestor
	(slot level)
	(slot index)
)

; Pulizia di precedenti planning
;---------------- Luigi 310106 ------ (inizio) -------------------

(defrule clean1
(declare (salience 150))
    ?f <- (virtual-pos)
    (current-time-to-replanning ?t)
    (final-time-to-replanning ?t)
    =>
    (retract ?f)
)

(defrule clean2
(declare (salience 150))
    (current-time-to-replanning ?t)
    (final-time-to-replanning ?t)
    ?f <- (clock-increased)
    =>
    (retract ?f)
)

(defrule clean3
(declare (salience 150))
    ?f <- (solution)
    (current-time-to-replanning ?t)
    (final-time-to-replanning ?t)
    =>
    (retract ?f)
)

(defrule clean4
(declare (salience 150))
    (current-time-to-replanning ?t)
    (final-time-to-replanning ?t)
    ?f <- (node-ancestor)
    =>
    (retract ?f)
)

(defrule clean5
(declare (salience 150))
    (current-time-to-replanning ?t)
    (final-time-to-replanning ?t)
    ?f <- (ancestor ?)    
    =>
    (retract ?f)
)

(defrule clean6
(declare (salience 150))
    (current-time-to-replanning ?t)
    (final-time-to-replanning ?t)
    ?f <- (node)
    =>
    (retract ?f)
)

(defrule clean7
(declare (salience 150))
    (current-time-to-replanning ?t)
    (final-time-to-replanning ?t)
    ?f <- (clock)
    =>
    (retract ?f)
)

(defrule clean8
(declare (salience 150))
    (current-time-to-replanning ?t)
    (final-time-to-replanning ?t)
    ?f <- (maxdepth ?)
    =>
    (retract ?f)
)

(defrule clean9
(declare (salience 150))
    (current-time-to-replanning ?t)
    (final-time-to-replanning ?t)
    ?f <- (resolved)
    =>
    (retract ?f)
)

(defrule clean10
(declare (salience 125))
    ?f1 <- (current-time-to-replanning ?t)
    ?f2 <- (final-time-to-replanning ?t)
    =>
    (retract ?f1)
    (retract ?f2)
)


;---------------- Luigi 020206 ----- (nuovo) -----------------------
(defrule calculate-perimeter1
   	(declare (salience 190))
   	(not (perimeter ?))
   	=>
   	(assert (perimeter 0))
)
   	
(defrule calculate-perimeter2
   	(declare (salience 200))
   	(map (pos-r ?r) (pos-c ?c))
   	?f <- (perimeter ?s)
   	(test (> (+ ?r ?c) ?s))
	=>
	(retract ?f)
	(assert (perimeter (+ ?r ?c)))
)

;---------------- Luigi 310106 ----- (fine) ------- modificata 020206 ----------------

; Inzializzazione della fase di pianificazione
(defrule initialize
	(declare (salience 100))
	(not (maxdepth ?))
	; 020206
	(perimeter ?sbr)
	(percepts (pos-r ?r) (pos-c ?c) (direction ?d)) 
	=>
	(assert (virtual-pos (level 0) (pos-r ?r) (pos-c ?c) (direction ?d)))
	(assert (solution (value no)))
	(assert (maxdepth 0))
	(assert (clock -1))
	(assert (node-ancestor (level 0) (index 0)))
	(assert (maximum-depth 12))
	; 310106
	(assert (final-time-to-replanning ?sbr)) ; numero passi prima del replanning
	(assert (current-time-to-replanning 0))
)

(defrule increase-depth
(declare (salience 50))
    ?f1 <- (maxdepth ?x)
    (not (resolved))
    =>
	(retract ?f1)
	(assert (maxdepth (+ ?x 2)))

	 (focus SIMULATE)
)

; OMAR 29/01/2006
; Imposto un limite alla profondità massima di esplorazione
; della mappa, se non ho raggiunto l'uscita, eseguo comunque il piano che ho
; costruito finora, riattivando nuovamente la pianificazione con
; limite massimo di profondità = 10
(defrule exceed-maximum-depth
	(declare (salience 80))
	(maxdepth ?d)
	(maximum-depth ?d)
	(not (resolved))
	?f <- (action (module ?))
	=>

	(modify ?f (module exit))
	(assert (resolved))
	(pop-focus)
)

(defrule erase-virtual-position
	(declare (salience 75))
	?f <- (virtual-pos (level ?x&~0))
	;(not (resolved))
	=>
	(retract ?f)
)

(defrule erase-node
	(declare (salience 75))
	?f <- (node (level ?))
	;(not (resolved))
	; OMAR 29/01/2006
	; Non devono essere eliminati tutti i nodi dell'albero, ma solo
	; quelli che sono al di sotto della profondità massima
	;(maxdepth ?d)
	;(maximum-depth ?md)
	;(test (< ?d (- ?md 2)))
	=>
	(retract ?f)
)

(defrule erase-ancestor
	(declare (salience 75))
	?f <- (ancestor ?)
	;(not (resolved))
	=>
	(retract ?f)
)

(defrule planning-completed
	(declare (salience 100))
	(resolved)
	(ready-to-execute)	
	=>
	(assert (plan-computed))
	(pop-focus)
)

; Regole per il tracciamento del cammino che porta all'uscita.
; Sulla base dell'albero delle soluzioni, si costruisce una sequenza 
; di fatti to-do

(defrule build-path-step
	(declare (salience 150))
	(resolved)
	?f <- (current ?cur)
	(test (>= ?cur 0))
	(node (level ?cur) (action ?act) (ancestor ?anc))
	=>
	(assert (to-do (time ?cur) (action ?act)))
	(retract ?f)
	(assert (current (- ?cur 1)))
)

(defrule erase-node-unuseful
	(declare (salience 160))
	(resolved)
	(current ?cur)
	(test (>= ?cur 0))
	?f <- (node (level ?l) (action ?act) (ancestor ?anc))
	(test (> ?l ?cur))
	=>
	(retract ?f)
)

(defrule path-completed
	(declare (salience 200))
	(resolved)
	(current -1)
	=>
	(assert (ready-to-execute))
)

; ---------------- modulo SIMULATE --------------------

(defmodule SIMULATE (import PLAN ?ALL)(export ?ALL))
(defrule got-solution
	(declare (salience 100))
	(solution (value yes))
	=> 
	(assert (resolved))
	(pop-focus)
)

(defrule increase-clock
	(declare (salience 20))
	(not (clock-increased))
	?f <- (clock ?cl)
	=>
	(retract ?f)
	(assert (clock (+ ?cl 1)))
	(assert (clock-increased))
)

(defrule go-up
	(virtual-pos (level ?s) (pos-r ?r) (pos-c ?c) (direction up))
	(or 
		(map (pos-r ?r1) (pos-c ?c) (contains ~wall&~entry))
		(unuseful-cell (pos-r ?r1) (pos-c ?c))
	)
	(test (= ?r1 (- ?r 1)))
	(maxdepth ?d)
	(test (< ?s ?d))
	(not (node (level ?s) (action go))) 
	=>
	(assert (apply (level ?s) (action go) (pos-r ?r1) (pos-c ?c) (dir up) (old-r ?r) (old-c ?c) (old-dir up)))
)

(defrule go-down
	(virtual-pos (level ?s) (pos-r ?r) (pos-c ?c) (direction down))
	(or
		(map (pos-r ?r1) (pos-c ?c) (contains ~wall&~entry))
		(unuseful-cell (pos-r ?r1) (pos-c ?c))
	)
	(test (= ?r1 (+ ?r 1)))
	(maxdepth ?d)
	(test (< ?s ?d))
	(not (node (level ?s) (action go))) 
	=>
	(assert (apply (level ?s) (action go) (pos-r ?r1) (pos-c ?c) (dir down) (old-r ?r) (old-c ?c) (old-dir down)))
)

(defrule go-left
	(virtual-pos (level ?s) (pos-r ?r) (pos-c ?c) (direction left))
	(or
		(map (pos-r ?r) (pos-c ?c1) (contains ~wall&~entry))
		(unuseful-cell (pos-r ?r) (pos-c ?c1))
	)
	(test (= ?c1 (- ?c 1)))
	(maxdepth ?d)
	(test (< ?s ?d))
	(not (node (level ?s) (action go))) 
	=>
	(assert (apply (level ?s) (action go) (pos-r ?r) (pos-c ?c1) (dir left) (old-r ?r) (old-c ?c) (old-dir left)))
)

(defrule go-right
	(virtual-pos (level ?s) (pos-r ?r) (pos-c ?c) (direction right))
	(or
		(map (pos-r ?r) (pos-c ?c1) (contains ~wall&~entry))
		(unuseful-cell (pos-r ?r) (pos-c ?c1))
	)
	(test (= ?c1 (+ ?c 1)))
	(maxdepth ?d)
	(test (< ?s ?d))
	(not (node (level ?s) (action go))) 
	=>
	(assert (apply (level ?s) (action go) (pos-r ?r) (pos-c ?c1) (dir right) (old-r ?r) (old-c ?c) (old-dir right)))
)

(defrule apply-go
	?f <- (apply (level ?s) (action go) (pos-r ?nr) (pos-c ?nc) (dir ?dir) (old-r ?or) (old-c ?oc) (old-dir ?od))
	(clock ?cl)
	?f1 <- (clock-increased)
	=>
	(retract ?f)
	(assert (delete (level ?s) (pos-r ?or) (pos-c ?oc) (direction ?od)))
	(assert (virtual-pos (level (+ ?s 1)) (pos-r ?nr) (pos-c ?nc) (direction ?dir)))
	(assert (current ?s))
	(assert (newstate (+ ?s 1)))
	(assert (node (level ?s) (action go) (index ?cl)))
	(retract ?f1)
	 (focus CHECK)
)

(defrule go-delete-position
	(declare (salience 2))
	(apply (level ?s) (action go))
	?f <- (virtual-pos (level ?t))
	(test (> ?t ?s))
	=>
	(retract ?f)
)

(defrule go-delete-node
	(declare (salience 1))
	(apply (level ?s) (action go))
	?f <- (node (level ?t) (index ?cl))
	(test (> ?t ?s))
	=>
	(retract ?f)
)

; - AZIONE turnleft -
(defrule turnleft-up
	(virtual-pos (level ?s) (pos-r ?r) (pos-c ?c) (direction up))
	(or 
		(map (pos-r ?r) (pos-c ?c1) (contains ~wall&~entry))
		(unuseful-cell (pos-r ?r) (pos-c ?c1))
	)
	(test (= ?c1 (- ?c 1)))
	(maxdepth ?d)
	(test (< ?s ?d))
	(not (node (level ?s) (action turnleft))) 
	=>
	(assert (apply (level ?s) (action turnleft) (pos-r ?r) (pos-c ?c) (dir left) (old-r ?r) (old-c ?c) (old-dir up)))
)
		
(defrule turnleft-down
	(virtual-pos (level ?s) (pos-r ?r) (pos-c ?c) (direction down))
	(or 
		(map (pos-r ?r) (pos-c ?c1) (contains ~wall&~entry))
		(unuseful-cell (pos-r ?r) (pos-c ?c1))
	)
	(test (= ?c1 (+ ?c 1)))
	(maxdepth ?d)
	(test (< ?s ?d))
	(not (node (level ?s) (action turnleft))) 
	=>
	(assert (apply (level ?s) (action turnleft) (pos-r ?r) (pos-c ?c) (dir right) (old-r ?r) (old-c ?c) (old-dir down)))
)

(defrule turnleft-left
	(virtual-pos (level ?s) (pos-r ?r) (pos-c ?c) (direction left))
	(or 
		(map (pos-r ?r1) (pos-c ?c) (contains ~wall&~entry))
		(unuseful-cell (pos-r ?r1) (pos-c ?c))
	)
	(test (= ?r1 (+ ?r 1)))
	(maxdepth ?d)
	(test (< ?s ?d))
	(not (node (level ?s) (action turnleft))) 
	=>
	(assert (apply (level ?s) (action turnleft) (pos-r ?r) (pos-c ?c) (dir down) (old-r ?r) (old-c ?c) (old-dir left)))
)

(defrule turnleft-right
	(virtual-pos (level ?s) (pos-r ?r) (pos-c ?c) (direction right))
	(or 
		(map (pos-r ?r1) (pos-c ?c) (contains ~wall&~entry))
		(unuseful-cell (pos-r ?r1) (pos-c ?c))
	)
	(test (= ?r1 (- ?r 1)))
	(maxdepth ?d)
	(maxdepth ?d)
	(test (< ?s ?d))
	(not (node (level ?s) (action turnleft))) 
	=>
	(assert (apply (level ?s) (action turnleft) (pos-r ?r) (pos-c ?c) (dir up) (old-r ?r) (old-c ?c) (old-dir right)))
)

(defrule apply-turnleft
	?f <- (apply (level ?s) (action turnleft) (pos-r ?nr) (pos-c ?nc) (dir ?dir) (old-r ?or) (old-c ?oc) (old-dir ?od))
	?f1 <- (clock-increased)
	(clock ?cl)
	=>
	(retract ?f)
	(assert (delete (level ?s) (pos-r ?or) (pos-c ?oc) (direction ?od)))
	(assert (virtual-pos (level (+ ?s 1)) (pos-r ?nr) (pos-c ?nc) (direction ?dir)))
	(assert (current ?s))
	(assert (newstate (+ ?s 1)))
	(assert (node (level ?s) (action turnleft) (index ?cl)))
	(retract ?f1)
	 (focus CHECK)
)

(defrule turnleft-delete-position
	(declare (salience 2))
	(apply (level ?s) (action turnleft))
	?f <- (virtual-pos (level ?t))
	(test (> ?t ?s))
	=>
	(retract ?f)
)

(defrule turnleft-delete-node
	(declare (salience 1))
	(apply (level ?s) (action turnleft))
	?f <- (node (level ?t) (index ?cl))
	(test (> ?t ?s))
	=>
	(retract ?f)
)

; - AZIONE turnright -
(defrule turnright-up
	(virtual-pos (level ?s) (pos-r ?r) (pos-c ?c) (direction up))
	(or 
		(map (pos-r ?r) (pos-c ?c1) (contains ~wall&~entry))
		(unuseful-cell (pos-r ?r) (pos-c ?c1))
	)
	(test (= ?c1 (+ ?c 1)))
	(maxdepth ?d)
	(test (< ?s ?d))
	(not (node (level ?s) (action turnright))) 
	=>
	(assert (apply (level ?s) (action turnright) (pos-r ?r) (pos-c ?c) (dir right) (old-r ?r) (old-c ?c) (old-dir up)))
)
		
(defrule turnright-down
	(virtual-pos (level ?s) (pos-r ?r) (pos-c ?c) (direction down))
	(or 
		(map (pos-r ?r) (pos-c ?c1) (contains ~wall&~entry))
		(unuseful-cell (pos-r ?r) (pos-c ?c1))
	)
	(test (= ?c1 (- ?c 1)))
	(maxdepth ?d)
	(test (< ?s ?d))
	(not (node (level ?s) (action turnright))) 
	=>
	(assert (apply (level ?s) (action turnright) (pos-r ?r) (pos-c ?c) (dir left) (old-r ?r) (old-c ?c) (old-dir down)))
)

(defrule turnright-left
	(virtual-pos (level ?s) (pos-r ?r) (pos-c ?c) (direction left))
	(or 
		(map (pos-r ?r1) (pos-c ?c) (contains ~wall&~entry))
		(unuseful-cell (pos-r ?r1) (pos-c ?c))
	)
	(test (= ?r1 (- ?r 1)))
	(maxdepth ?d)
	(test (< ?s ?d))
	(not (node (level ?s) (action turnright))) 
	=>
	(assert (apply (level ?s) (action turnright) (pos-r ?r) (pos-c ?c) (dir up) (old-r ?r) (old-c ?c) (old-dir left)))
)

(defrule turnright-right
	(virtual-pos (level ?s) (pos-r ?r) (pos-c ?c) (direction right))
	(or 
		(map (pos-r ?r1) (pos-c ?c) (contains ~wall&~entry))
		(unuseful-cell (pos-r ?r1) (pos-c ?c))
	)
	(test (= ?r1 (+ ?r 1)))
	(maxdepth ?d)
	(maxdepth ?d)
	(test (< ?s ?d))
	(not (node (level ?s) (action turnright))) 
	=>
	(assert (apply (level ?s) (action turnright) (pos-r ?r) (pos-c ?c) (dir down) (old-r ?r) (old-c ?c) (old-dir right)))
)

(defrule apply-turnright
	?f <- (apply (level ?s) (action turnright) (pos-r ?nr) (pos-c ?nc) (dir ?dir) (old-r ?or) (old-c ?oc) (old-dir ?od))
	?f1 <- (clock-increased)
	(clock ?cl)
	=>
	(retract ?f)
	(assert (delete (level ?s) (pos-r ?or) (pos-c ?oc) (direction ?od)))
	(assert (virtual-pos (level (+ ?s 1)) (pos-r ?nr) (pos-c ?nc) (direction ?dir)))
	(assert (current ?s))
	(assert (newstate (+ ?s 1)))
	(assert (node (level ?s) (action turnright) (index ?cl)))
	(retract ?f1)
	 (focus CHECK)
)

(defrule turnright-delete-position
	(declare (salience 2))
	(apply (level ?s) (action turnright))
	?f <- (virtual-pos (level ?t))
	(test (> ?t ?s))
	=>
	(retract ?f)
)

(defrule turnright-delete-node
	(declare (salience 1))
	(apply (level ?s) (action turnright))
	?f <- (node (level ?t) (index ?cl))
	(test (> ?t ?s))
	=>
	(retract ?f)
)

; - gestione vicoli ciechi
(defrule blindalley-up
	(declare (salience -5))
	(virtual-pos (level ?s) (pos-r ?r) (pos-c ?c) (direction up))
	(maxdepth ?d)
	(test (< ?s ?d))
	(not (node (level ?s) (action turnleft))) 
	=>
	(assert (apply (level ?s) (action turnleft) (pos-r ?r) (pos-c ?c) (dir left) (old-r ?r) (old-c ?c) (old-dir up)))
)

(defrule blindalley-down
	(declare (salience -5))
	(virtual-pos (level ?s) (pos-r ?r) (pos-c ?c) (direction down))
	(maxdepth ?d)
	(test (< ?s ?d))
	(not (node (level ?s) (action turnleft))) 
	=>
	(assert (apply (level ?s) (action turnleft) (pos-r ?r) (pos-c ?c) (dir right) (old-r ?r) (old-c ?c) (old-dir up)))
)

(defrule blindalley-left
	(declare (salience -5))
	(virtual-pos (level ?s) (pos-r ?r) (pos-c ?c) (direction left))
	(maxdepth ?d)
	(test (< ?s ?d))
	(not (node (level ?s) (action turnleft))) 
	=>
	(assert (apply (level ?s) (action turnleft) (pos-r ?r) (pos-c ?c) (dir down) (old-r ?r) (old-c ?c) (old-dir up)))
)

(defrule blindalley-right
	(declare (salience -5))
	(virtual-pos (level ?s) (pos-r ?r) (pos-c ?c) (direction right))
	(maxdepth ?d)
	(test (< ?s ?d))
	(not (node (level ?s) (action turnleft))) 
	=>
	(assert (apply (level ?s) (action turnleft) (pos-r ?r) (pos-c ?c) (dir up) (old-r ?r) (old-c ?c) (old-dir up)))
)


; ---------------- modulo CHECK --------------------

(defmodule CHECK (import SIMULATE ?ALL) (export ?ALL))

(defrule trace-new-position
    (declare (salience 100))
    (current ?s)
    (virtual-pos (level ?s) (pos-r ?r) (pos-c ?c) (direction ?dir))
    (not (delete (level ?s) (pos-r ?r) (pos-c ?c) (direction ?dir)))
 	=>
    (assert (virtual-pos (level (+ ?s 1)) (pos-r ?r) (pos-c ?c) (direction ?dir)))
 )

(defrule update-node-ancestor
	(declare (salience 80))
	(not (ancestor-index-updated))
	?f <- (node-ancestor (level ?) (index ?))
	(current ?cur)
	(node (level ?l) (action ?) (index ?idx))
	(test (= ?l (- ?cur 1)))
	=>
	(modify ?f (level ?l)(index ?idx))
	(assert (ancestor-index-updated))
)

(defrule update-todo-ancestor
	(declare (salience 75))
	(not (ancestor-todo-updated))
	(node-ancestor (index ?ai))
	?f <- (node (level ?l))
	(current ?l)
	=>
	(modify ?f (ancestor ?ai))
	(assert (ancestor-todo-updated))
)

(defrule goal-achieved
	(exit-position (pos-r ?) (pos-c ?)) 
	?f <-  (solution (value no))
	=> 
	(modify ?f (value yes))
	(pop-focus)
)

(defrule goal-not-achieved
	(declare (salience 50))
	(newstate ?s)
	(exit-position (pos-r ?r) (pos-c ?c)) 
	(not (virtual-pos (level ?s) (pos-r ?r) (pos-c ?c) (direction ?dir)))
	=>
	(assert (task go-on)) 
	(assert (ancestor (- ?s 1)))
	 (focus NEW)
)

; ---------------- modulo NEW --------------------

(defmodule NEW (import CHECK ?ALL) (export ?ALL))

(defrule remove-index-updated
	(declare (salience 120))
	?f <- (ancestor-index-updated)
	=>
 	(retract ?f)
)

(defrule remove-todo-updated
	(declare (salience 120))
	?f <- (ancestor-todo-updated)
	=>
 	(retract ?f)
)

(defrule check-ancestor
	(declare (salience 50))
	?f1 <- (ancestor ?a) 
	(test (>= ?a 0))
	(newstate ?s)
	(virtual-pos (level ?s) (pos-r ?r) (pos-c ?c) (direction ?dir))
	(not (virtual-pos (level ?a) (pos-r ?r) (pos-c ?c) (direction ?dir)))
	=>
	(assert (ancestor (- ?a 1)))
	(retract ?f1)
	(assert (diff ?a))
)

(defrule all-checked
   (declare (salience 25))
   (diff 0) 
	?f2 <- (newstate ?n)
	?f3 <- (task go-on)
	=>
   (retract ?f2)
   (retract ?f3)
    (focus CLEAN)
)

(defrule already-exist
	?f <- (task go-on)
	=> 
	(retract ?f)
	(assert (remove newstate))	
	 (focus CLEAN)
)

; ---------------- modulo CLEAN --------------------

(defmodule CLEAN (import NEW ?ALL) (export ?ALL))            
       
(defrule erase-delete
(declare (salience 50))
	?f <- (delete (level ?))
	=>
	(retract ?f)
)

(defrule erase-diff
(declare (salience 100))
	?f <- (diff ?)
	=>
	(retract ?f)
)

(defrule erase-position
(declare (salience 25))
	(remove newstate)
	(newstate ?n)
	?f <- (virtual-pos (level ?n))
	=>
	(retract ?f)
)

(defrule erase-flags
	(declare (salience 10))
	?f1 <- (remove newstate)
	?f2 <- (newstate ?n)
	=>
	(retract ?f1)
	(retract ?f2)
)

(defrule done
	?f <- (current ?x)
	=> 
	(retract ?f)
	(pop-focus)
	(pop-focus)
	(pop-focus)
)

; ---------------------------------------------------------------------------------
;				   FINE MODULO PLAN
; ---------------------------------------------------------------------------------

(defmodule EXEC-PLAN (import PLAN ?ALL)(export ?ALL))

; ---------------------------------------------------------------------------------
; MODULO AGENT - Componente EXEC-PLAN
; ---------------------------------------------------------------------------------

; Modulo per eseguire il piano realizzato dall'agente
(defrule execute-step
	(status (time ?t))
	(not (exec (action ?) (time ?t)))
	?f <- (to-do (action ?act))
	=>
	(assert (exec (action ?act) (time ?t)))
	(assert (move-completed (time ?t)))
	(retract ?f)
	(pop-focus)
)

; OMAR 29/01/2006
; Regole per pulire i flag asseriti in precedenti fasi di pianificazione
(defrule erase-position-flag
	(declare (salience 5))
	?f <- (virtual-pos (level ?))
	=>
	(retract ?f)
)

; flag clock
(defrule erase-clock-flags1
	(declare (salience 5))
	?f <- (clock ?)
	=>
	(retract ?f)
)

(defrule erase-clock-flags2
	(declare (salience 5))
	?f <- (clock-increased)
	=>
	(retract ?f)
)

; flag node
(defrule erase-node-flags1
	(declare (salience 5))
	?f <- (node (level ?))
	=>
	(retract ?f)
)

(defrule erase-node-flags2
	(declare (salience 5))
	?f <- (node-ancestor (level ?))
	=>
	(retract ?f)
)

; flag current
(defrule erase-current-flags
	(declare (salience 5))
	?f <- (current ?)
	=>
	(retract ?f)
)

; flag solution
(defrule erase-solution-flags
	(declare (salience 5))
	?f <- (solution (value ?))
	=>
	(retract ?f)
)

; flag depth
(defrule erase-depth-flags1
	(declare (salience 5))
	?f <- (maxdepth ?)
	=>
	(retract ?f)
)

(defrule erase-depth-flags2
	(declare (salience 5))
	?f <- (maximum-depth ?)
	=>
	(retract ?f)
)

; flags
(defrule erase-other-flags1
	(declare (salience 3))
	?f <- (resolved)
	=>
	(retract ?f)
)
; ---------------------------------------------------------------------------------
;				   FINE MODULO EXEC-PLAN
; ---------------------------------------------------------------------------------

