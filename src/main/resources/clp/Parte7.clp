)
; -------------------------- ROTAZIONE INIZIALE -------------------------- 
; Se mi trovo sull'entrata (e do per scontato che lo sono perche' all'inizio ci sono sopra)
; mi giro a dx e poi a sx (solo per ricevere le percezioni di TUTTE le celle davanti all'ingresso)
; ------------------------------------------------------------------------

(defrule AGENT::discover-entry1
	(MAIN::status (time 0))
	=>
	(assert (MAIN::exec (action turnright)(time 0)))
)

(defrule AGENT::discover-entry2
	(declare (salience 15))
	(MAIN::status (time 1))
	(MAIN::percepts (pos-r ?r) (pos-c ?c) (direction ?d))
	=>
	(assert (MAIN::exec (action turnleft)(time 1)))
	(assert (AGENT::movement (step 0)))
	(assert (MAIN::last-position (time 1) (pos-r ?r) (pos-c ?c) (direction ?d)))
)


; ##--------------------- SELEZIONE DEL MODULO DA ATTIVARE ----------------##
(defrule AGENT::active-explore
	(declare (salience 10))
	(MAIN::status (time ?t) (result ~exit))
	(AGENT::action (module explore))
	(AGENT::movement (step 0))
	(not (MAIN::exec (time ?t) (action ?)))
	=> 
	(set-current-module EXPLORE) (focus EXPLORE)
)
	
(defrule AGENT::active-save
	(declare (salience 10))
	(MAIN::status (time ?t) (result ~exit))
	(AGENT::action (module save))
	(AGENT::movement (step 0))
	(not (MAIN::exec (time ?t) (action ?)))
	=> 
	(set-current-module SAVE) (focus SAVE)
)
	
(defrule AGENT::active-exit
	(declare (salience 10))
	(MAIN::status (time ?t) (result ~exit))
	(AGENT::action (module exit))
	(AGENT::movement (step 0))
	(not (MAIN::exec (time ?t) (action ?)))
	=> 
	(set-current-module EXIT) (focus EXIT)
)

(defrule AGENT::active-plan
	(declare (salience 10))
	(MAIN::status (time ?t) (result ~exit))
	(AGENT::movement (step 0))
	(AGENT::action (module plan))
	=> 
	(set-current-module PLAN) (focus PLAN)
)

(defrule AGENT::active-exec-plan
	(declare (salience 10))
	(MAIN::status (time ?t) (result ~exit))
	(AGENT::movement (step 0))
	(AGENT::action (module exec-plan))
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
(defrule AGENT::rotate-left-forbidden
	(declare (salience -20))
	(AGENT::action (module ~save))
	(MAIN::status (time ?t))
	?f <- (AGENT::movement (step 1))
	(MAIN::percepts (time ?t) (pos-r ?r) (pos-c ?c) (direction ?d))
	;Controllo della situazione della mappa
	(or
		(and 
			(test (= (str-compare ?d up) 0))
			(or 
				(AGENT::map (pos-r ?r) (pos-c ?c1) (contains wall|entry|exit))
				(AGENT::unuseful-cell (pos-r ?r) (pos-c ?c1))
			)
			(test (= ?c1 (- ?c 1)))
		)
		
		(and 
			(test (= (str-compare ?d down) 0))
			(or
				(AGENT::map (pos-r ?r) (pos-c ?c1) (contains wall|entry|exit))
				(AGENT::unuseful-cell (pos-r ?r) (pos-c ?c1))
			)
			(test (= ?c1 (+ ?c 1)))
		)
		
		(and 
			(test (= (str-compare ?d left) 0))
			(or
				(AGENT::map (pos-r ?r1) (pos-c ?c) (contains wall|entry|exit))
				(AGENT::unuseful-cell (pos-r ?r1) (pos-c ?c))
			)
			(test (= ?r1 (+ ?r 1)))
		)
		
		(and 
			(test (= (str-compare ?d right) 0))
			(or
				(AGENT::map (pos-r ?r1) (pos-c ?c) (contains wall|entry|exit))
				(AGENT::unuseful-cell (pos-r ?r1) (pos-c ?c))
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
(defrule AGENT::rotate-left-useless
	(declare (salience -21))
	(AGENT::action (module ~save))
	(MAIN::status (time ?t))
	?f <- (AGENT::movement (step 1))
	(MAIN::percepts (time ?t) (pos-r ?r) (pos-c ?c) (direction ?d))
	;Controllo della situazione della mappa
	(or
		(and 
			(test (= (str-compare ?d up) 0))
			(and
				(AGENT::map (pos-r ?r) (pos-c ?c1) (contains ~wall&~entry&~exit))
				(not (AGENT::unuseful-cell (pos-r ?r) (pos-c ?c1)))
			)
			(or
				(AGENT::map (pos-r ?r) (pos-c ?c2) (contains wall|entry|exit))
				(AGENT::unuseful-cell (pos-r ?r) (pos-c ?c2))
			)
			(test (= ?c1 (- ?c 1)))
			(test (= ?c2 (- ?c 2)))
		)
		
		(and 
			(test (= (str-compare ?d down) 0))
			(and
				(AGENT::map (pos-r ?r) (pos-c ?c1) (contains ~wall&~entry&~exit))
				(not (AGENT::unuseful-cell (pos-r ?r) (pos-c ?c1)))
			)
			(or
				(AGENT::map (pos-r ?r) (pos-c ?c2) (contains wall|entry|exit))
				(AGENT::unuseful-cell (pos-r ?r) (pos-c ?c2))
			)
			(test (= ?c1 (+ ?c 1)))
			(test (= ?c2 (+ ?c 2)))
		)
		
		(and 
			(test (= (str-compare ?d left) 0))
			(and
				(AGENT::map (pos-r ?r1) (pos-c ?c) (contains ~wall&~entry&~exit))
				(not (AGENT::unuseful-cell (pos-r ?r1) (pos-c ?c)))				
			)
			(or
				(AGENT::map (pos-r ?r2) (pos-c ?c) (contains wall|entry|exit))
				(AGENT::unuseful-cell (pos-r ?r2) (pos-c ?c))
			)
			(test (= ?r1 (+ ?r 1)))
			(test (= ?r2 (+ ?r 2)))
		)
		
		(and 
			(test (= (str-compare ?d right) 0))
			(and
				(AGENT::map (pos-r ?r1) (pos-c ?c) (contains ~wall&~entry&~exit))
				(not (AGENT::unuseful-cell (pos-r ?r1) (pos-c ?c)))				
			)
			(or
				(AGENT::map (pos-r ?r2) (pos-c ?c) (contains wall|entry|exit))
				(AGENT::unuseful-cell (pos-r ?r2) (pos-c ?c))
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
(defrule AGENT::rotate-left
	(declare (salience -22))
	(AGENT::action (module ~save))
	(MAIN::status (time ?t))
	?f <- (AGENT::movement (step 1))
	(MAIN::percepts (time ?t) (pos-r ?r) (pos-c ?c) (direction ?d))
	;Controllo della situazione della mappa
	(or
		(and 
			(test (= (str-compare ?d up) 0))
			(not (and
				(AGENT::map (pos-r ?r) (pos-c ?c1))
				(AGENT::map (pos-r ?r) (pos-c ?c2))
				(AGENT::map (pos-r ?r) (pos-c ?c3))
				(test (= ?c1 (- ?c 1)))
				(test (= ?c2 (- ?c 2)))
				(test (= ?c3 (- ?c 3)))			
			))
		)

		(and 
			(test (= (str-compare ?d down) 0))
			(not (and
				(AGENT::map (pos-r ?r) (pos-c ?c1))
				(AGENT::map (pos-r ?r) (pos-c ?c2))
				(AGENT::map (pos-r ?r) (pos-c ?c3))
				(test (= ?c1 (+ ?c 1)))
				(test (= ?c2 (+ ?c 2)))
				(test (= ?c3 (+ ?c 3)))
			))
		)
		
		(and 
			(test (= (str-compare ?d left) 0))
			(not (and
				(AGENT::map (pos-r ?r1) (pos-c ?c))
				(AGENT::map (pos-r ?r2) (pos-c ?c))
				(AGENT::map (pos-r ?r3) (pos-c ?c))
				(test (= ?r1 (+ ?r 1)))
				(test (= ?r2 (+ ?r 2)))
				(test (= ?r3 (+ ?r 3)))
			))				
		)
		
		(and 
			(test (= (str-compare ?d right) 0))
			(not (and
				(AGENT::map (pos-r ?r1) (pos-c ?c))
				(AGENT::map (pos-r ?r2) (pos-c ?c))
				(AGENT::map (pos-r ?r3) (pos-c ?c))
				(test (= ?r1 (- ?r 1)))
				(test (= ?r2 (- ?r 2)))
				(test (= ?r3 (- ?r 3)))			
			))
		)
	)
	=>
	(assert (MAIN::exec (action turnleft) (time ?t) (marks-a-path no)))
	(assert (AGENT::restore-direction (action turnright)))
	
)

; Equivalente alla regola precedente ma considera la rotazione verso destra
;OMAR 18/01/2006 - gestione celle unuseful
(defrule AGENT::rotate-right-useless
	(declare (salience -21))
	(AGENT::action (module ~save))
	(MAIN::status (time ?t))
	?f <- (AGENT::movement (step 3))
	(MAIN::percepts (time ?t) (pos-r ?r) (pos-c ?c) (direction ?d))
	;Controllo della situazione della mappa
	(or
		(and 
			(test (= (str-compare ?d down) 0))
			(and
				(AGENT::map (pos-r ?r) (pos-c ?c1) (contains ~wall&~entry&~exit))
				(not (AGENT::unuseful-cell (pos-r ?r) (pos-c ?c1)))					
			)
			(or
				(AGENT::map (pos-r ?r) (pos-c ?c2) (contains wall|entry|exit))
				(AGENT::unuseful-cell (pos-r ?r) (pos-c ?c2))				
			)
			(test (= ?c1 (- ?c 1)))
			(test (= ?c2 (- ?c 2)))
		)
		
		(and 
			(test (= (str-compare ?d up) 0))
			(and
				(AGENT::map (pos-r ?r) (pos-c ?c1) (contains ~wall&~entry&~exit))
				(not (AGENT::unuseful-cell (pos-r ?r) (pos-c ?c1)))					
			)
			(or
				(AGENT::map (pos-r ?r) (pos-c ?c2) (contains wall|entry|exit))
				(AGENT::unuseful-cell (pos-r ?r) (pos-c ?c2))				
			)
			(test (= ?c1 (+ ?c 1)))
			(test (= ?c2 (+ ?c 2)))
		)
		
		(and 
			(test (= (str-compare ?d right) 0))
			(and
				(AGENT::map (pos-r ?r1) (pos-c ?c) (contains ~wall&~entry&~exit))
				(not (AGENT::unuseful-cell (pos-r ?r1) (pos-c ?c)))					
			)
			(or
				(AGENT::map (pos-r ?r2) (pos-c ?c) (contains wall|entry|exit))
				(AGENT::unuseful-cell (pos-r ?r2) (pos-c ?c))				
			)
			(test (= ?r1 (+ ?r 1)))
			(test (= ?r2 (+ ?r 2)))
		)
		
		(and 
			(test (= (str-compare ?d left) 0))
			(and			
				(AGENT::map (pos-r ?r1) (pos-c ?c) (contains ~wall&~entry&~exit))
				(not (AGENT::unuseful-cell (pos-r ?r1) (pos-c ?c)))					
			)
			(or
				(AGENT::map (pos-r ?r2) (pos-c ?c) (contains wall|entry|exit))
				(AGENT::unuseful-cell (pos-r ?r2) (pos-c ?c))				
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
(defrule AGENT::rotate-right-forbidden
	(declare (salience -20))
	(AGENT::action (module ~save))
	(MAIN::status (time ?t))
	?f <- (AGENT::movement (step 3))
	(MAIN::percepts (time ?t) (pos-r ?r) (pos-c ?c) (direction ?d))
	;Controllo della situazione della mappa
	(or
		(and 
			(test (= (str-compare ?d down) 0))
			(or
				(AGENT::map (pos-r ?r) (pos-c ?c1) (contains wall|entry|exit))
				(AGENT::unuseful-cell (pos-r ?r) (pos-c ?c1))
			)
			(test (= ?c1 (- ?c 1)))
		)
		
		(and 
			(test (= (str-compare ?d up) 0))
			(or
				(AGENT::map (pos-r ?r) (pos-c ?c1) (contains wall|entry|exit))
				(AGENT::unuseful-cell (pos-r ?r) (pos-c ?c1))				
			)
			(test (= ?c1 (+ ?c 1)))
		)
		
		(and 
			(test (= (str-compare ?d right) 0))
			(or
				(AGENT::map (pos-r ?r1) (pos-c ?c) (contains wall|entry|exit))
				(AGENT::unuseful-cell (pos-r ?r1) (pos-c ?c))				
			)
			(test (= ?r1 (+ ?r 1)))
		)
		
		(and 
			(test (= (str-compare ?d left) 0))
			(or
				(AGENT::map (pos-r ?r1) (pos-c ?c) (contains wall|entry|exit))
				(AGENT::unuseful-cell (pos-r ?r1) (pos-c ?c))				
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
(defrule AGENT::rotate-right
	(declare (salience -22))
	(AGENT::action (module ~save))
	(MAIN::status (time ?t))
	?f <- (AGENT::movement (step 3))
	(MAIN::percepts (time ?t) (pos-r ?r) (pos-c ?c) (direction ?d))
	;Controllo della situazione della mappa
	(or
		(and 
			(test (= (str-compare ?d down) 0))
			(not (and
				(AGENT::map (pos-r ?r) (pos-c ?c1))
				(AGENT::map (pos-r ?r) (pos-c ?c2))
				(AGENT::map (pos-r ?r) (pos-c ?c3))
				(test (= ?c1 (- ?c 1)))
				(test (= ?c2 (- ?c 2)))
				(test (= ?c3 (- ?c 3)))			
			))
		)

		(and 
			(test (= (str-compare ?d up) 0))
			(not (and
				(AGENT::map (pos-r ?r) (pos-c ?c1))
				(AGENT::map (pos-r ?r) (pos-c ?c2))
				(AGENT::map (pos-r ?r) (pos-c ?c3))
				(test (= ?c1 (+ ?c 1)))
				(test (= ?c2 (+ ?c 2)))
				(test (= ?c3 (+ ?c 3)))
			))
		)
		
		(and 
			(test (= (str-compare ?d right) 0))
			(not (and
				(AGENT::map (pos-r ?r1) (pos-c ?c))
				(AGENT::map (pos-r ?r2) (pos-c ?c))
				(AGENT::map (pos-r ?r3) (pos-c ?c))
				(test (= ?r1 (+ ?r 1)))
				(test (= ?r2 (+ ?r 2)))
				(test (= ?r3 (+ ?r 3)))
			))				
		)
		
		(and 
			(test (= (str-compare ?d left) 0))
			(not (and
				(AGENT::map (pos-r ?r1) (pos-c ?c))
				(AGENT::map (pos-r ?r2) (pos-c ?c))
				(AGENT::map (pos-r ?r3) (pos-c ?c))
				(test (= ?r1 (- ?r 1)))
				(test (= ?r2 (- ?r 2)))
				(test (= ?r3 (- ?r 3)))			
			))
		)
	)
	=>
	(assert (MAIN::exec (action turnright) (time ?t) (marks-a-path no)))
	(assert (AGENT::restore-direction (action turnleft)))
	
)

(defrule AGENT::mark-rotation-completed
	(AGENT::movement (step 4))
	(MAIN::status (time ?t))
	(AGENT::kpos (time ?t) (pos-r ?r) (pos-c ?c)) 
	?f <- (AGENT::map (pos-r ?r) (pos-c ?c) (rotation ~completed)) 
	=>
	(modify ?f (rotation completed))
)

; Questa regola ha il solo compito di incrementare la fase di rotazione del robot
; sulle altre regole, a seconda della fase, è necessario controllare se eseguire la mossa
(defrule AGENT::increase-step
	(declare (salience -23))
	(AGENT::action (module ~save))
	(MAIN::status (time ?t))
	?f <- (AGENT::movement (step ?s))
	=>
	(modify ?f (step (mod (+ ?s 1) 5)))
)


; Questa regola rileva se deve essere ripristinata la direzione di spostamento del robot
; durante l'esplorazione, nel caso in cui lo sia (cioè sia presente un fatto di tipo "restore-direction")
; viene immediatamente ripristinata la direzione originaria
(defrule AGENT::restore-step
	(MAIN::status (time ?t))
	?f <- (AGENT::restore-direction (action ?d))
	?f1 <- (AGENT::movement (step ?s))
	=>
	(assert (MAIN::exec (action ?d) (time ?t) (marks-a-path no)))
	(modify ?f1 (step (mod (+ ?s 1) 5)))	;Incremento del contatore degli step di rotazione
	(retract ?f)
	
)
; ##-----------------------------------------------------------------------##

; -------------------------- COSTRUZIONE DELLA MAPPA -------------------------- 
; Regole per la costruzione dei fatti sulla base delle percezioni che giungono
; dal modulo ENV. Sono costruiti i fatti utili per le operazioni compiute in
; tutti i sotto-moduli
; -----------------------------------------------------------------------------
(defrule AGENT::build-map-up
	(declare (salience 100))
	(MAIN::status (time ?t))
	(not (AGENT::undo-phase (time ?)))
	(MAIN::percepts (time ?t) (pos-r ?r)(pos-c ?c)(direction up)(perc1 ?p1)(perc2 ?p2)(perc3 ?p3)(cry ?))
	=>
	(assert (AGENT::map (pos-r (- ?r 1)) (pos-c ?c) (contains ?p1)))
	(assert (AGENT::map (pos-r (- ?r 2)) (pos-c ?c) (contains ?p2)))
	(assert (AGENT::map (pos-r (- ?r 3)) (pos-c ?c) (contains ?p3)))
)

(defrule AGENT::build-map-down
	(declare (salience 100))
	(MAIN::status (time ?t))
	(not (AGENT::undo-phase (time ?)))
	(MAIN::percepts (time ?t) (pos-r ?r)(pos-c ?c)(direction down)(perc1 ?p1)(perc2 ?p2)(perc3 ?p3)(cry ?))
	=>
	(assert (AGENT::map (pos-r (+ ?r 1)) (pos-c ?c) (contains ?p1)))
	(assert (AGENT::map (pos-r (+ ?r 2)) (pos-c ?c) (contains ?p2)))
	(assert (AGENT::map (pos-r (+ ?r 3)) (pos-c ?c) (contains ?p3)))		
)

(defrule AGENT::build-map-left
	(declare (salience 100))
	(MAIN::status (time ?t))
	(not (AGENT::undo-phase (time ?)))
	(MAIN::percepts (time ?t) (pos-r ?r)(pos-c ?c)(direction left)(perc1 ?p1)(perc2 ?p2)(perc3 ?p3)(cry ?))
	=>
	(assert (AGENT::map (pos-r ?r) (pos-c (- ?c 1)) (contains ?p1)))
	(assert (AGENT::map (pos-r ?r) (pos-c (- ?c 2)) (contains ?p2)))
	(assert (AGENT::map (pos-r ?r) (pos-c (- ?c 3)) (contains ?p3)))		
)

(defrule AGENT::build-map-right
	(declare (salience 100))
	(MAIN::status (time ?t))
	(not (AGENT::undo-phase (time ?)))
	(MAIN::percepts (time ?t) (pos-r ?r)(pos-c ?c)(direction right)(perc1 ?p1)(perc2 ?p2)(perc3 ?p3)(cry ?))
	=>
	(assert (AGENT::map (pos-r ?r) (pos-c (+ ?c 1)) (contains ?p1)))
	(assert (AGENT::map (pos-r ?r) (pos-c (+ ?c 2)) (contains ?p2)))
	(assert (AGENT::map (pos-r ?r) (pos-c (+ ?c 3)) (contains ?p3)))		
)

; AGGIUNTA PER CANCELLARE LE INCONSISTENZE DELLA MAPPA 
; (Per le celle già visitate, con rotazione completata: quando le ritrovo, le build-map
; le impostano con lo slot (di default) "rotation not-completed". Devo subito cancellarle
; perchè sono inconsistenti con quello che ho già asserito (e che è corretto).
;--------------------------------------------------------------
(defrule AGENT::clear-map-inconsistency
	(declare (salience 100))
	(AGENT::map (pos-r ?r) (pos-c ?c) (contains empty|debris) (rotation completed))
	?f <- (AGENT::map (pos-r ?r) (pos-c ?c) (contains empty|debris) (rotation not-completed))
	=>
	(retract ?f)
)
;--------------------------------------------------------------

; Sostituzione del contenuto della cella "entry" con "wall"
(defrule AGENT::replace-entry
	(declare (salience 90))
	?f <- (AGENT::map (pos-r ?r) (pos-c ?c) (contains entry))
	=>
	(modify ?f (contains wall))
	(assert (AGENT::entry-position (pos-r ?r) (pos-c ?c)))
)

; Pulisce tutti le celle della mappa che contengono "unknown"
(defrule AGENT::clear-unknown
	(declare (salience 90))
	(MAIN::status (time ?t))
	;(exec (action ?)(time ?t))
	?f <- (AGENT::map (pos-r ?) (pos-c ?) (contains unknown))
	=>
	(retract ?f)
)

;Registrazione dello stato del robot (se non ho ancora caricato nessun superstite)
(defrule AGENT::trace-position-notloaded
	(declare (salience 80))
	;(movement (step 0))
	(MAIN::status (time ?t))
	(MAIN::percepts (time ?t) (pos-r ?r)(pos-c ?c)(direction ?d)(perc1 ?p1)(perc2 ?p2)(perc3 ?p3)(cry ?))
	(not (MAIN::perc-grasp (time ?) (pos-r ?)(pos-c ?) (person ?name)))
	;Inserita questa condizione per evitare di scrivere più volte lo stesso fatto - Omar 09/09/2005
	(not (AGENT::kpos (time ?t) (pos-r ?r) (pos-c ?c) (direction ?d) (load no)))
	(AGENT::map (pos-r ?r) (pos-c ?c) (counter ?cnt))
	=>
	(assert (AGENT::kpos (time ?t) (pos-r ?r) (pos-c ?c) (direction ?d) (load no)))
	;memorizzo la nuova posizione e la prendo con Java.
	(store stepOk trace)
	(store status ?t)
	(store pos-r ?r)
	(store pos-c ?c)
	(store direction ?d)
	(store loaded no)
	(store counter (+ ?cnt 1))
)

;Registrazione dello stato del robot (se ho già caricato un superstite)
(defrule AGENT::trace-position-loaded
	(declare (salience 80))
	;(movement (step 0))
	(MAIN::status (time ?t))
	(MAIN::percepts (time ?t) (pos-r ?r)(pos-c ?c)(direction ?d)(perc1 ?p1)(perc2 ?p2)(perc3 ?p3)(cry ?))
	(MAIN::perc-grasp (time ?) (pos-r ?)(pos-c ?) (person ?name))
	(AGENT::map (pos-r ?r) (pos-c ?c) (counter ?cnt))
	=>
	(assert (AGENT::kpos (time ?t) (pos-r ?r) (pos-c ?c) (direction ?d) (load yes)))
	;memorizzo la nuova posizione e la prendo con Java.
	(store stepOk trace)
	(store status ?t)
	(store pos-r ?r)
	(store pos-c ?c)
	(store direction ?d)
	(store loaded yes)
	(store counter (+ ?cnt 1))
)


; OMAR 11/11/2005 incremento del contatore dei passaggi sulla cella della mappa
; corretto il 13/01/2006
(defrule AGENT::inc-counter-path
	(declare (salience 418))
	(MAIN::status (time ?t))
	(test (> ?t 1))
	(AGENT::kpos (time ?t) (pos-r ?r) (pos-c ?c) (direction ?d) (load ?))
	?f <- (AGENT::map (pos-r ?r) (pos-c ?c) (counter ?cnt))
	(AGENT::action (module ?m))
	(MAIN::exec (action ?a) (time ?t) (marks-a-path yes))
	;(not (MAIN::exec-path (time ?t) (pos-r ?r) (pos-c ?c) (module ?m) (direction ?d) (action ?a)))	
	?f1 <- (MAIN::last-position (pos-r ?r1) (pos-c ?c1))
	(not (and
		(test (= ?r ?r1))
		(test (= ?c ?c1))
	))
	(not (AGENT::inc-done))
	=>
	(modify ?f (counter (+ ?cnt 1)))
	;(retract ?f1)
	(assert (AGENT::inc-done))
)

; Registrazione delle azioni compiute dal robot (durante l'esplorazione)
(defrule AGENT::write-path
	(declare (salience 410))
	(MAIN::status (time ?t))
	(test (> ?t 1))
	(AGENT::kpos (time ?t) (pos-r ?r) (pos-c ?c) (direction ?d) (load ?))
	?f <- (AGENT::map (pos-r ?r) (pos-c ?c) (counter ?cnt))
	(AGENT::action (module ?m))
	(MAIN::exec (action ?a) (time ?t) (marks-a-path yes))
	(not (MAIN::exec-path (time ?t) (pos-r ?r) (pos-c ?c) (module ?m) (direction ?d) (action ?a)))
	?f1 <- (MAIN::last-position (pos-r ?) (pos-c ?))
	?f2 <- (AGENT::inc-done)
	=>
	(assert (MAIN::exec-path (time ?t) (pos-r ?r) (pos-c ?c) (module ?m) (direction ?d) (action ?a)))
	(retract ?f1)
	(assert (MAIN::last-position (time ?t) (pos-r ?r) (pos-c ?c) (direction ?d)))
	(retract ?f2)
	(modify ?f (touched ?t))	;OMAR 18/01/2006 Tracciamento ultimo passaggio sulla cella
)

(defrule AGENT::trace-cry
	(declare (salience 80))
	(MAIN::status (time ?t))
	(MAIN::percepts (time ?t) (pos-r ?r)(pos-c ?c)(direction ?)(perc1 ?)(perc2 ?)(perc3 ?)(cry yes))
	=>
	(assert (AGENT::cry (pos-r ?r) (pos-c ?c)))
)

; Analisi della mappa per scrivere fatti che indicano le posizioni delle macerie da esplorare
(defrule AGENT::check-for-debris
	(declare (salience 80))
	(AGENT::map (pos-r ?r) (pos-c ?c) (contains debris))
	(not (AGENT::debris-position (pos-r ?r) (pos-c ?c) (useful no)))
	=>
	(assert (AGENT::debris-position (pos-r ?r) (pos-c ?c) (useful yes)))
)

; Analisi della mappa per scrivere fatti che indicano le posizioni delle macerie da esplorare
(defrule AGENT::check-for-exits
	(declare (salience 80))
	(AGENT::map (pos-r ?r) (pos-c ?c) (contains exit))
	=>
	(assert (AGENT::exit-position (pos-r ?r) (pos-c ?c)))
)

; ---------------------- CONTROLLO MACERIE SENZA PERSONE -----------------------------
; Queste regole controllano se associate alle macerie ci sono richieste di aiuto
; (se non ce ne sono, mi salvo l'informazione nello slot "useful"
; ------------------------------------------------------------------------------------

(defrule AGENT::check-useless-debris-up
	(declare (salience 15))
	(MAIN::status (time ?t))
	(MAIN::percepts (time ?t) (pos-r ?r)(pos-c ?c)(direction up)(perc1 debris)(perc2 ?p2)(perc3 ?p3)(cry no))
	(and
		?f <- (AGENT::debris-position (pos-r ?r1) (pos-c ?c) (useful yes))
		(test (= ?r1 (- ?r 1)))
	)
	=>
	(modify ?f (useful no))	
)


(defrule AGENT::check-useless-debris-down
	(declare (salience 15))
	(MAIN::status (time ?t))
	(MAIN::percepts (time ?t) (pos-r ?r)(pos-c ?c)(direction down)(perc1 debris)(perc2 ?p2)(perc3 ?p3)(cry no))
	(and
		?f <- (AGENT::debris-position (pos-r ?r1) (pos-c ?c) (useful yes))
		(test (= ?r1 (+ ?r 1)))
	)
	=>
	(modify ?f (useful no))	
)


(defrule AGENT::check-useless-debris-left
	(declare (salience 15))
	(MAIN::status (time ?t))
	(MAIN::percepts (time ?t) (pos-r ?r)(pos-c ?c)(direction left)(perc1 debris)(perc2 ?p2)(perc3 ?p3)(cry no))
	(and
		?f <- 	(AGENT::debris-position (pos-r ?r) (pos-c ?c1) (useful yes))
		(test (= ?c1 (- ?c 1)))
	)
	=>
	(modify ?f (useful no))	
)

(defrule AGENT::check-useless-debris-right
	(declare (salience 15))
	(MAIN::status (time ?t))
	(MAIN::percepts (time ?t) (pos-r ?r)(pos-c ?c)(direction right)(perc1 debris)(perc2 ?p2)(perc3 ?p3)(cry no))
	(and	
		?f <- 	(AGENT::debris-position (pos-r ?r) (pos-c ?c1) (useful yes))
		(test (= ?c1 (+ ?c 1)))
	)
	=>
	(modify ?f (useful no))	

)

; ##---------------- GESTIONE PASSAGGIO AL MODULO SAVE -----------------##
; Quando viene rilevata una percezione di cry si deve passare al modulo 
; SAVE che ha il compito di recuperare la persona che ha richiesto aiuto. 
(defrule AGENT::go-save
	(declare (salience 40))
	(MAIN::status (time ?t) (result ~exit))
	?f1 <- (AGENT::movement (step ?s))
	?f <- (AGENT::action (module explore))
	(AGENT::cry (pos-r ?) (pos-c ?))
	(not (AGENT::undo (time ?) (direction ?) (action ?)))	; prima bisogna eliminare tutti gli undo precedenti
	=>
	(modify ?f (module save))
	(modify ?f1 (step 0))
	;(set-current-module MAIN) (focus MAIN)
)
; ##--------------------------------------------------------------------##


; ##---------------- GESTIONE PASSAGGIO AL MODULO EXIT -----------------##
; Il superstite è stato caricato con successo sul robot, si passa alla fase
; di uscita dalla stanza
(defrule AGENT::go-exit
	(declare (salience 40))
	(MAIN::status (time ?t) (result ~exit))
	?f1 <- (AGENT::movement (step ?s))
	?f <- (AGENT::action (module save))
	(MAIN::perc-grasp (time ?t) (pos-r ?)(pos-c ?) (person ?name))	
	(not (AGENT::undo (time ?) (direction ?) (action ?)))	; prima bisogna eliminare tutti gli undo precedenti
	=>
	(modify ?f (module exit))
	(modify ?f1 (step 1))
)

; Attivazione della pianificazione per raggiungere l'uscita più vicina
(defrule AGENT::go-plan
	(declare (salience 4000))
	?f2 <- (MAIN::status (time ?t) (result ?))
	(test (> ?t 2))
	?f1 <- (AGENT::movement (step ?))
	?f <- (AGENT::action (module ~plan))
	(not (AGENT::map (pos-r ?) (pos-c ?) (contains debris|empty) (rotation not-completed)))
	(not (and
		(AGENT::map (pos-r ?r) (pos-c ?c) (contains debris|empty))
		(not (AGENT::kpos (time ?) (pos-r ?r) (pos-c ?c)))
	))
	(not (PLAN::plan-computed))
	
	; 310106
	(or
		(and
			(PLAN::final-time-to-replanning ?ftr)
			(PLAN::current-time-to-replanning ?ctr)
			(test (= ?ftr ?ctr))
		)
		(and
			(not (PLAN::final-time-to-replanning ?))
			(not (PLAN::current-time-to-replanning ?))
		)
	)
	
	=>
	(modify ?f (module plan))
	(modify ?f1 (step 0))
	(store planning start)
	(printout t crlf "-------------------------------------------------------------" crlf)
	(printout t "Tutta la mappa è stata esplorata, e nessun superstite ")
	(printout t crlf "e' stato trovato! Ora cerco una via d'uscita" crlf)
	(printout t "-------------------------------------------------------------" crlf crlf)
)

(defrule AGENT::go-exec-plan
	(AGENT::to-do (time ?))
	(PLAN::plan-computed)	
	(PLAN::ready-to-execute)
	?f <- (AGENT::action (module plan))
	?f1 <- (AGENT::movement (step ?))
	=>
	(modify ?f (module exec-plan))
	(modify ?f1 (step 0))
	(store planning end)
	(printout t crlf "-------------------------------------------------------------" crlf)
	(printout t "Piano completo, posso raggiungere l'uscita" crlf)
	(printout t "-------------------------------------------------------------" crlf crlf)
)
; ##--------------------------------------------------------------------##


; ##---------------- GESTIONE PASSAGGIO AL MODULO MAIN -----------------##
; Ritorna l'esecuzione al MAIN (dopo aver indicato l'azione da compiere)
(defrule AGENT::go-MAIN
	(declare (salience 400))
	(MAIN::status (time ?t))
	?f <- (MAIN::percepts (time ?t) (pos-r ?)(pos-c ?)(direction ?)(perc1 ?)(perc2 ?)(perc3 ?)(cry ?))
	(MAIN::exec (action ?) (time ?t))
	=> 
	(retract ?f)	; butto via la percezione perchè tanto non mi serve più
	(set-current-module MAIN) (focus MAIN)
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

;(defmodule EXPLORE)

(deftemplate EXPLORE::first-undo (slot action))

; -------------------------- MOVIMENTI DEL ROBOT -------------------------- 
; ##---------------- Movimento frontale verso le macerie ----------------##

; Ci sono macerie nelle percezioni del robot, ceroc immediatamente di raggiungerle (spostamento VERTICALE)
(defrule EXPLORE::goto-debris-vertical-forward
	(declare (salience 25))
	(MAIN::status (time ?t))
	(not (AGENT::undo (time ?) (direction ?) (action ?)))
	?f <- (AGENT::movement (step 0))
	(not (MAIN::exec (action ?) (time ?t)))
	(or 
		(MAIN::percepts (time ?t) (pos-r ?r)(pos-c ?c)(direction ?d&up|down)(perc1 debris)(perc2 ?)(perc3 ?)(cry yes))
		(MAIN::percepts (time ?t) (pos-r ?r)(pos-c ?c)(direction ?d&up|down)(perc1 ?)(perc2 debris)(perc3 ?)(cry ?))
		(MAIN::percepts (time ?t) (pos-r ?r)(pos-c ?c)(direction ?d&up|down)(perc1 ?)(perc2 ?)(perc3 debris)(cry ?))
	)
	; MODIFICA LUIGI 04102005

	(or	
		(and
			(test (= (str-compare ?d up) 0))
			(AGENT::debris-position (pos-r ?r1) (pos-c ?c) (useful yes))
			(test (= ?r1 (- ?r 1)))
		)
		(and
			(test (= (str-compare ?d up) 0))
			(AGENT::debris-position (pos-r ?r2) (pos-c ?c) (useful yes))
			(test (= ?r2 (- ?r 2)))
		)
		(and
			(test (= (str-compare ?d up) 0))
			(AGENT::debris-position (pos-r ?r3) (pos-c ?c) (useful yes))
			(test (= ?r3 (- ?r 3)))
		)	
		(and
			(test (= (str-compare ?d down) 0))
			(AGENT::debris-position (pos-r ?r1) (pos-c ?c) (useful yes))
			(test (= ?r1 (+ ?r 1)))
		)
		(and
			(test (= (str-compare ?d down) 0))
			(AGENT::debris-position (pos-r ?r2) (pos-c ?c) (useful yes))
			(test (= ?r2 (+ ?r 2)))
		)
		(and
			(test (= (str-compare ?d down) 0))
			(AGENT::debris-position (pos-r ?r3) (pos-c ?c) (useful yes))
			(test (= ?r3 (+ ?r 3)))
		)
	)	
	(not (or
		(and
			(AGENT::debris-position (pos-r ?r) (pos-c ?c1) (useful yes))
			(test (<> ?c1 (- ?c 1)))
		)
		(and
			(AGENT::debris-position (pos-r ?r) (pos-c ?c2) (useful yes))
			(test (<> ?c2 (- ?c 2)))
		)
		(and
			(AGENT::debris-position (pos-r ?r) (pos-c ?c3) (useful yes))
			(test (<> ?c3 (- ?c 3)))
		)
		(and
			(AGENT::debris-position (pos-r ?r) (pos-c ?c4) (useful yes))
			(test (<> ?c4 (+ ?c 1)))
		)
		(and
			(AGENT::debris-position (pos-r ?r) (pos-c ?c5) (useful yes))
			(test (<> ?c5 (+ ?c 2)))
		)
		(and
			(AGENT::debris-position (pos-r ?r) (pos-c ?c6) (useful yes))
			(test (<> ?c6 (+ ?c 3)))
		)
	))
	=>
	(assert (MAIN::exec (action go)(time ?t)))
	(modify ?f (step 1))
	(assert (AGENT::move-completed (time ?t)))
	
)

; Ci sono macerie nelle percezioni del robot, ceroc immediatamente di raggiungerle (spostamento ORIZZONTALE)
(defrule EXPLORE::goto-debris-horizontal-forward
	(declare (salience 25))
	(MAIN::status (time ?t))
	(not (MAIN::exec (action ?) (time ?t)))
	(not (AGENT::undo (time ?) (direction ?) (action ?)))
	?f <- (AGENT::movement (step 0))
	(or 
		(MAIN::percepts (time ?t) (pos-r ?r)(pos-c ?c)(direction ?d&left|right)(perc1 debris)(perc2 ?)(perc3 ?)(cry yes))
		(MAIN::percepts (time ?t) (pos-r ?r)(pos-c ?c)(direction ?d&left|right)(perc1 ?)(perc2 debris)(perc3 ?)(cry ?))
		(MAIN::percepts (time ?t) (pos-r ?r)(pos-c ?c)(direction ?d&left|right)(perc1 ?)(perc2 ?)(perc3 debris)(cry ?))
	)
	; MODIFICA LUIGI 04102005

	(or	
		(and
			(test (= (str-compare ?d left) 0))
			(AGENT::debris-position (pos-r ?r) (pos-c ?c1) (useful yes))
			(test (= ?c1 (- ?c 1)))
		)
		(and
			(test (= (str-compare ?d left) 0))
			(AGENT::debris-position (pos-r ?r) (pos-c ?c2) (useful yes))
			(test (= ?c2 (- ?c 2)))
		)
		(and
			(test (= (str-compare ?d left) 0))
			(AGENT::debris-position (pos-r ?r) (pos-c ?c3) (useful yes))
			(test (= ?c3 (- ?c 3)))
		)	
		(and
			(test (= (str-compare ?d right) 0))
			(AGENT::debris-position (pos-r ?r) (pos-c ?c1) (useful yes))
			(test (= ?c1 (+ ?c 1)))
		)
		(and
			(test (= (str-compare ?d right) 0))
			(AGENT::debris-position (pos-r ?r) (pos-c ?c2) (useful yes))
			(test (= ?c2 (+ ?c 2)))
		)
		(and
			(test (= (str-compare ?d right) 0))
			(AGENT::debris-position (pos-r ?r) (pos-c ?c3) (useful yes))
			(test (= ?c3 (+ ?c 3)))
		)
	)		
	(not (or
		(and
			(AGENT::debris-position (pos-r ?r1) (pos-c ?c) (useful yes))
			(test (<> ?r1 (- ?r 1)))
		)
		(and
			(AGENT::debris-position (pos-r ?r1) (pos-c ?c) (useful yes))
			(test (<> ?r1 (- ?r 2)))
		)
		(and
			(AGENT::debris-position (pos-r ?r1) (pos-c ?c) (useful yes))
			(test (<> ?r1 (- ?r 3)))
		)
		(and
			(AGENT::debris-position (pos-r ?r1) (pos-c ?c) (useful yes))
			(test (<> ?r1 (+ ?r 1)))
		)
		(and
			(AGENT::debris-position (pos-r ?r1) (pos-c ?c) (useful yes))
			(test (<> ?r1 (+ ?r 2)))
		)
		(and
			(AGENT::debris-position (pos-r ?r1) (pos-c ?c) (useful yes))
			(test (<> ?r1 (+ ?r 3)))
		)
	))
	=>
	(assert (MAIN::exec (action go)(time ?t)))
	(modify ?f (step 1))
	(assert (AGENT::move-completed (time ?t)))
	
)

; Si cerca di ragguingere la cella con le macerie nel campo visivo del robot (direzione UP)
(defrule EXPLORE::goto-debris-fwd-up
	(declare (salience 20))
	(MAIN::status (time ?t))
	(test (> ?t 2))
	(AGENT::movement (step 0))
	;(not (AGENT::undo (time ?) (direction ?) (action ?)))
	(or 
		(MAIN::percepts (time ?t) (pos-r ?r)(pos-c ?c)(direction up)(perc1 debris)(perc2 ?)(perc3 ?)(cry yes))
		(MAIN::percepts (time ?t) (pos-r ?r)(pos-c ?c)(direction up)(perc1 ?)(perc2 debris)(perc3 ?)(cry ?))
		(MAIN::percepts (time ?t) (pos-r ?r)(pos-c ?c)(direction up)(perc1 ?)(perc2 ?)(perc3 debris)(cry ?))
	)
	(or
		(and
			(AGENT::debris-position (pos-r ?r1) (pos-c ?c) (useful yes))
			(test (= ?r1 (- ?r 1)))
		)
		(and
			(AGENT::debris-position (pos-r ?r1) (pos-c ?c) (useful yes))
			(test (= ?r1 (- ?r 2)))
		)
		(and
			(AGENT::debris-position (pos-r ?r1) (pos-c ?c) (useful yes))
			(test (= ?r1 (- ?r 3)))
		)
	)
	=>
	(assert (MAIN::exec (action go)(time ?t)))
	(assert (AGENT::undo (time ?t) (direction down) (action go)))
	(assert (AGENT::move-completed (time ?t)))	
	
)

; Si cerca di ragguingere la cella con le macerie nel campo visivo del robot (direzione DOWN)
(defrule EXPLORE::goto-debris-fwd-down
	(declare (salience 20))
	(MAIN::status (time ?t))
	(test (> ?t 2))
	(AGENT::movement (step 0))
	;(not (AGENT::undo (time ?) (direction ?) (action ?)))
	(or 
		(MAIN::percepts (time ?t) (pos-r ?r)(pos-c ?c)(direction down)(perc1 debris)(perc2 ?)(perc3 ?)(cry yes))
		(MAIN::percepts (time ?t) (pos-r ?r)(pos-c ?c)(direction down)(perc1 ?)(perc2 debris)(perc3 ?)(cry ?))
		(MAIN::percepts (time ?t) (pos-r ?r)(pos-c ?c)(direction down)(perc1 ?)(perc2 ?)(perc3 debris)(cry ?))
	)
	(or
		(and
			(AGENT::debris-position (pos-r ?r1) (pos-c ?c) (useful yes))
			(test (= ?r1 (+ ?r 1)))
		)
		(and
			(AGENT::debris-position (pos-r ?r1) (pos-c ?c) (useful yes))
			(test (= ?r1 (+ ?r 2)))
		)
		(and
			(AGENT::debris-position (pos-r ?r1) (pos-c ?c) (useful yes))
			(test (= ?r1 (+ ?r 3)))
		)
	)
	=>
	(assert (MAIN::exec (action go)(time ?t)))
	(assert (AGENT::undo (time ?t) (direction up) (action go)))
	(assert (AGENT::move-completed (time ?t)))
	
)

; Si cerca di ragguingere la cella con le macerie nel campo visivo del robot (direzione LEFT)
(defrule EXPLORE::goto-debris-fwd-left
	(declare (salience 20))
	(MAIN::status (time ?t))
	(test (> ?t 2))
	(AGENT::movement (step 0))
	;(not (AGENT::undo (time ?) (direction ?) (action ?)))
	(or 
		(MAIN::percepts (time ?t) (pos-r ?r)(pos-c ?c)(direction left)(perc1 debris)(perc2 ?)(perc3 ?)(cry yes))
		(MAIN::percepts (time ?t) (pos-r ?r)(pos-c ?c)(direction left)(perc1 ?)(perc2 debris)(perc3 ?)(cry ?))
		(MAIN::percepts (time ?t) (pos-r ?r)(pos-c ?c)(direction left)(perc1 ?)(perc2 ?)(perc3 debris)(cry ?))
	)
	(or
		(and
			(AGENT::debris-position (pos-r ?r) (pos-c ?c1) (useful yes))
			(test (= ?c1 (- ?c 1)))
		)
		(and
			(AGENT::debris-position (pos-r ?r) (pos-c ?c1) (useful yes))
			(test (= ?c1 (- ?c 2)))
		)
		(and
			(AGENT::debris-position (pos-r ?r) (pos-c ?c1) (useful yes))
			(test (= ?c1 (- ?c 3)))
		)
	)
	=>
	(assert (MAIN::exec (action go)(time ?t)))
	(assert (AGENT::undo (time ?t) (direction right) (action go)))
	(assert (AGENT::move-completed (time ?t)))	
	
)

; Si cerca di ragguingere la cella con le macerie nel campo visivo del robot (direzione RIGHT)
(defrule EXPLORE::goto-debris-fwd-right
	(declare (salience 20))
	(MAIN::status (time ?t))
	(test (> ?t 2))
	(AGENT::movement (step 0))
	;(not (AGENT::undo (time ?) (direction ?) (action ?)))
	(or 
		(MAIN::percepts (time ?t) (pos-r ?r)(pos-c ?c)(direction right)(perc1 debris)(perc2 ?)(perc3 ?)(cry yes))
		(MAIN::percepts (time ?t) (pos-r ?r)(pos-c ?c)(direction right)(perc1 ?)(perc2 debris)(perc3 ?)(cry ?))
		(MAIN::percepts (time ?t) (pos-r ?r)(pos-c ?c)(direction right)(perc1 ?)(perc2 ?)(perc3 debris)(cry ?))
	)
	(or
		(and
			(AGENT::debris-position (pos-r ?r) (pos-c ?c1) (useful yes))
			(test (= ?c1 (+ ?c 1)))
		)
		(and
			(AGENT::debris-position (pos-r ?r) (pos-c ?c1) (useful yes))
			(test (= ?c1 (+ ?c 2)))
		)
		(and
			(AGENT::debris-position (pos-r ?r) (pos-c ?c1) (useful yes))
			(test (= ?c1 (+ ?c 3)))
		)
	)
	=>
	(assert (MAIN::exec (action go)(time ?t)))
	(assert (AGENT::undo (time ?t) (direction left) (action go)))
	(assert (AGENT::move-completed (time ?t)))
	
)

; ##--------------------------------------------------------------------##

; ##--------------------- Rotazione verso le macerie -------------------##

; Ruoto la direzione del robot alla sua sinistra (perche' probabilmente ci sono delle macerie da esplorare)

(defrule EXPLORE::goto-debris-turnright-up
	(declare (salience 10))
	(MAIN::status (time ?t))
	(test (> ?t 2))
	(not (MAIN::exec (action ?) (time ?t)))
	(AGENT::movement (step 0))
	(AGENT::kpos (time ?t) (pos-r ?r) (pos-c ?c) (direction up) (load no))
	(or
		(and
			(AGENT::debris-position (pos-r ?r1) (pos-c ?c1) (useful yes))
			(test (= ?r ?r1))
			(test (= ?c1 (+ ?c 1)))
		)
		(and
			(AGENT::debris-position (pos-r ?r1) (pos-c ?c1) (useful yes))
			(test (= ?r ?r1))
			(test (= ?c1 (+ ?c 2)))
		)
		(and
			(AGENT::debris-position (pos-r ?r1) (pos-c ?c1) (useful yes))
			(test (= ?r ?r1))
			(test (= ?c1 (+ ?c 3)))
		)				
	)
	=>
	(assert (MAIN::exec (action turnright)(time ?t)))
	(assert (AGENT::undo (time ?t) (direction left) (action turnright)))	
	(assert (AGENT::move-completed (time ?t)))
)

(defrule EXPLORE::goto-debris-turnleft-up
	(declare (salience 10))
	(MAIN::status (time ?t))
	(test (> ?t 2))
	(not (MAIN::exec (action ?) (time ?t)))
	(AGENT::movement (step 0))
	(AGENT::kpos (time ?t) (pos-r ?r) (pos-c ?c) (direction up) (load no))
	(or
		;(and
		;	(AGENT::debris-position (pos-r ?r1) (pos-c ?c1) (useful yes))
		;	(test (= ?c ?c1))
		;	(test (= ?r1 (- ?r 1)))
		;)
		;(and
		;	(AGENT::debris-position (pos-r ?r1) (pos-c ?c1) (useful yes))
		;	(test (= ?c ?c1))
		;	(test (= ?r1 (- ?r 2)))
		;)
		;(and
		;	(AGENT::debris-position (pos-r ?r1) (pos-c ?c1) (useful yes))
		;	(test (= ?c ?c1))
		;	(test (= ?r1 (- ?r 3)))
		;)
		(and
			(AGENT::debris-position (pos-r ?r1) (pos-c ?c1) (useful yes))
			(test (= ?r ?r1))
			(test (= ?c1 (- ?c 1)))
		)
		(and
			(AGENT::debris-position (pos-r ?r1) (pos-c ?c1) (useful yes))
			(test (= ?r ?r1))
			(test (= ?c1 (- ?c 2)))
		)
		(and
			(AGENT::debris-position (pos-r ?r1) (pos-c ?c1) (useful yes))
			(test (= ?r ?r1))
			(test (= ?c1 (- ?c 3)))
		)				
	)
	=>
	(assert (MAIN::exec (action turnleft)(time ?t)))
	(assert (AGENT::undo (time ?t) (direction right) (action turnleft)))	
	(assert (AGENT::move-completed (time ?t)))
)

(defrule EXPLORE::goto-debris-turnright-down
	(declare (salience 10))
	(MAIN::status (time ?t))
	(test (> ?t 2))
	(not (MAIN::exec (action ?) (time ?t)))
	(AGENT::movement (step 0))
	(AGENT::kpos (time ?t) (pos-r ?r) (pos-c ?c) (direction down) (load no))
	(or
		(and
			(AGENT::debris-position (pos-r ?r1) (pos-c ?c1) (useful yes))
			(test (= ?r ?r1))
			(test (= ?c1 (- ?c 1)))
		)
		(and
			(AGENT::debris-position (pos-r ?r1) (pos-c ?c1) (useful yes))
			(test (= ?r ?r1))
			(test (= ?c1 (- ?c 2)))
		)
		(and
			(AGENT::debris-position (pos-r ?r1) (pos-c ?c1) (useful yes))
			(test (= ?r ?r1))
			(test (= ?c1 (- ?c 3)))
		)				
	)
	=>
	(assert (MAIN::exec (action turnright)(time ?t)))
	(assert (AGENT::undo (time ?t) (direction right) (action turnright)))	
	(assert (AGENT::move-completed (time ?t)))
)

(defrule EXPLORE::goto-debris-turnleft-down
	(declare (salience 10))
	(MAIN::status (time ?t))
	(test (> ?t 2))
	(not (MAIN::exec (action ?) (time ?t)))
	(AGENT::movement (step 0))
	(AGENT::kpos (time ?t) (pos-r ?r) (pos-c ?c) (direction down) (load no))
	(or
	;	(and
	;		(AGENT::debris-position (pos-r ?r1) (pos-c ?c1) (useful yes))
	;		(test (= ?c ?c1))
	;		(test (= ?r1 (- ?r 1)))
	;	)
	;	(and
	;		(AGENT::debris-position (pos-r ?r1) (pos-c ?c1) (useful yes))
	;		(test (= ?c ?c1))
	;		(test (= ?r1 (- ?r 2)))
	;	)
	;	(and
	;		(AGENT::debris-position (pos-r ?r1) (pos-c ?c1) (useful yes))
	;		(test (= ?c ?c1))
	;		(test (= ?r1 (- ?r 3)))
	;	)
		(and
			(AGENT::debris-position (pos-r ?r1) (pos-c ?c1) (useful yes))
			(test (= ?r ?r1))
			(test (= ?c1 (+ ?c 1)))
		)
		(and
			(AGENT::debris-position (pos-r ?r1) (pos-c ?c1) (useful yes))
			(test (= ?r ?r1))
			(test (= ?c1 (+ ?c 2)))
		)
		(and
			(AGENT::debris-position (pos-r ?r1) (pos-c ?c1) (useful yes))
			(test (= ?r ?r1))
			(test (= ?c1 (+ ?c 3)))
		)				
	)
	=>
	(assert (MAIN::exec (action turnleft)(time ?t)))
	(assert (AGENT::undo (time ?t) (direction left) (action turnleft)))	
	(assert (AGENT::move-completed (time ?t)))
)

(defrule EXPLORE::goto-debris-turnright-right
	(declare (salience 10))
	(MAIN::status (time ?t))
	(test (> ?t 2))
	(not (MAIN::exec (action ?) (time ?t)))
	(AGENT::movement (step 0))
	(AGENT::kpos (time ?t) (pos-r ?r) (pos-c ?c) (direction right) (load no))
	(or
		(and
			(AGENT::debris-position (pos-r ?r1) (pos-c ?c1) (useful yes))
			(test (= ?c ?c1))
			(test (= ?r1 (+ ?r 1)))
		)
		(and
			(AGENT::debris-position (pos-r ?r1) (pos-c ?c1) (useful yes))
			(test (= ?c ?c1))
			(test (= ?r1 (+ ?r 2)))
		)
		(and
			(AGENT::debris-position (pos-r ?r1) (pos-c ?c1) (useful yes))
			(test (= ?c ?c1))
			(test (= ?r1 (+ ?r 3)))
		)
	)
	=>
	(assert (MAIN::exec (action turnright)(time ?t)))
	(assert (AGENT::undo (time ?t) (direction up) (action turnright)))	
	(assert (AGENT::move-completed (time ?t)))
)

(defrule EXPLORE::goto-debris-turnleft-right
	(declare (salience 10))
	(MAIN::status (time ?t))
	(test (> ?t 2))
	(not (MAIN::exec (action ?) (time ?t)))
	(AGENT::movement (step 0))
	(AGENT::kpos (time ?t) (pos-r ?r) (pos-c ?c) (direction right) (load no))
	(or
		(and
			(AGENT::debris-position (pos-r ?r1) (pos-c ?c1) (useful yes))
			(test (= ?c ?c1))
			(test (= ?r1 (- ?r 1)))
		)
		(and
			(AGENT::debris-position (pos-r ?r1) (pos-c ?c1) (useful yes))
			(test (= ?c ?c1))
			(test (= ?r1 (- ?r 2)))
		)
		(and
			(AGENT::debris-position (pos-r ?r1) (pos-c ?c1) (useful yes))
			(test (= ?c ?c1))
			(test (= ?r1 (- ?r 3)))
		)
		;(and
		;	(AGENT::debris-position (pos-r ?r1) (pos-c ?c1) (useful yes))
		;	(test (= ?r ?r1))
		;	(test (= ?c1 (- ?c 1)))
		;)
		;(and
		;	(AGENT::debris-position (pos-r ?r1) (pos-c ?c1) (useful yes))
		;	(test (= ?r ?r1))
		;	(test (= ?c1 (- ?c 2)))
		;)
		;(and
		;	(AGENT::debris-position (pos-r ?r1) (pos-c ?c1) (useful yes))
		;	(test (= ?r ?r1))
		;	(test (= ?c1 (- ?c 3)))
		;)				
	)
	=>
	(assert (MAIN::exec (action turnleft)(time ?t)))
	(assert (AGENT::undo (time ?t) (direction down) (action turnleft)))	
	(assert (AGENT::move-completed (time ?t)))
)

(defrule EXPLORE::goto-debris-turnright-left
	(declare (salience 10))
	(MAIN::status (time ?t))
	(test (> ?t 2))
	(not (MAIN::exec (action ?) (time ?t)))
	(AGENT::movement (step 0))
	(AGENT::kpos (time ?t) (pos-r ?r) (pos-c ?c) (direction left) (load no))
	(or
		(and
			(AGENT::debris-position (pos-r ?r1) (pos-c ?c1) (useful yes))
			(test (= ?c ?c1))
			(test (= ?r1 (- ?r 1)))
		)
		(and
			(AGENT::debris-position (pos-r ?r1) (pos-c ?c1) (useful yes))
			(test (= ?c ?c1))
			(test (= ?r1 (- ?r 2)))
		)
		(and
			(AGENT::debris-position (pos-r ?r1) (pos-c ?c1) (useful yes))
			(test (= ?c ?c1))
			(test (= ?r1 (- ?r 3)))
		)				
	)
	=>
	(assert (MAIN::exec (action turnright)(time ?t)))
	(assert (AGENT::undo (time ?t) (direction down) (action turnright)))	
	(assert (AGENT::move-completed (time ?t)))
)

(defrule EXPLORE::goto-debris-turnleft-left
	(declare (salience 10))
	(MAIN::status (time ?t))
	(test (> ?t 2))
	(not (MAIN::exec (action ?) (time ?t)))
	(AGENT::movement (step 0))
	(AGENT::kpos (time ?t) (pos-r ?r) (pos-c ?c) (direction left) (load no))
	(or
		(and
			(AGENT::debris-position (pos-r ?r1) (pos-c ?c1) (useful yes))
			(test (= ?c ?c1))
			(test (= ?r1 (+ ?r 1)))
		)
		(and
			(AGENT::debris-position (pos-r ?r1) (pos-c ?c1) (useful yes))
			(test (= ?c ?c1))
			(test (= ?r1 (+ ?r 2)))
		)
		(and
			(AGENT::debris-position (pos-r ?r1) (pos-c ?c1) (useful yes))
			(test (= ?c ?c1))
			(test (= ?r1 (+ ?r 3)))
		)
		;(and
		;	(AGENT::debris-position (pos-r ?r1) (pos-c ?c1) (useful yes))
		;	(test (= ?r ?r1))
		;	(test (= ?c1 (+ ?c 1)))
		;)
		;(and
		;	(AGENT::debris-position (pos-r ?r1) (pos-c ?c1) (useful yes))
		;	(test (= ?r ?r1))
		;	(test (= ?c1 (+ ?c 2)))
		;)
		;(and
		;	(AGENT::debris-position (pos-r ?r1) (pos-c ?c1) (useful yes))
		;	(test (= ?r ?r1))
		;	(test (= ?c1 (+ ?c 3)))
		;)				
	)
	=>
	(assert (MAIN::exec (action turnleft)(time ?t)))
	(assert (AGENT::undo (time ?t) (direction up) (action turnleft)))	
	(assert (AGENT::move-completed (time ?t)))
)
; ##--------------------------------------------------------------------##

; ##------------------ ATTIVAZIONE DELLA FASE DI UNDO ------------------##

;Tracciamento della prima operazione di undo da fare, serve a capire quante inversioni bisogna fare
(defrule EXPLORE::trace-first-undo
	(declare (salience 220))
	(not (EXPLORE::first-undo (action ?)))
	(not (MAIN::inversion-completed))
	(AGENT::movement (step 0))
	(AGENT::undo (time ?) (direction ?) (action ?a))
	=>
	(assert (EXPLORE::first-undo (action ?a)))
)

; Questa regola ha il compito di attivare la fase di undo asserendo il 
; fatto undo-phase
(defrule EXPLORE::active-undo-module
	(declare (salience -22))
	(MAIN::status (time ?t))
	(AGENT::movement (step 0))
	(AGENT::undo (time ?) (direction ?) (action ?))
	(not (AGENT::undo-phase (time ?t)))
	(MAIN::status (time ?t))
	=>
	(assert (AGENT::undo-phase (time ?t)))
)


; Questa regola ha il compito di passare immediatamente l'esecuzione 
; al modulo UNDO se è stata attivata la fase di undo
(defrule EXPLORE::undo-in-action
	(declare (salience 100))
	(EXPLORE::first-undo (action ?))
	;(undo (time ?) (direction ?) (action ?))	
	(MAIN::status (time ?t))
	?f <- (AGENT::undo-phase (time ?))
	=>
	(modify ?f (time ?t))
	(set-current-module UNDO) (focus UNDO)
)

; Prima di chiudere la fase di undo, se la first-undo indica go come
; prima azione deve essere fatta un'ulteriore inversione
(defrule EXPLORE::deactive-undo-module1
	(declare (salience 110))
	(not (AGENT::undo (time ?) (direction ?) (action ?)))
	(MAIN::status (time ?t))
	?f <- (AGENT::undo-phase (time ?))
	(EXPLORE::first-undo (action go))
	=>
	(modify ?f (time ?t))
	(set-current-module UNDO) (focus UNDO)
)

; Questa regola ha il compito di disattivare la fase di undo, controllando
; se nella WM non ci sono più fatti undo che devono essere annullati
(defrule EXPLORE::deactive-undo-module2
	(declare (salience 110))
	(not (AGENT::undo (time ?) (direction ?) (action ?)))
	?f <- (AGENT::undo-phase (time ?))
	?f1 <- (EXPLORE::first-undo (action ~go))
	?f2 <- (MAIN::inversion-completed)
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

(defrule EXPLORE::go-standard-move
	(declare (salience -30))
	(AGENT::movement (step 0))
	=>
	(focus STANDARD-MOVE)
)
; ##--------------------------------------------------------------------##


; ##---------------- ELIMINAZIONE DEI FATTI UNDO  -----------------##
; Eliminazione dei fatti undo residui (perche' sono relativi al modulo in cui mi 
; trovavo precedentemente

(defrule EXPLORE::clear-first-undo
	(declare (salience 505))
	(MAIN::status (time ?t))
	(AGENT::cry (pos-r ?) (pos-c ?))
	?f <- (EXPLORE::first-undo (action ?))
	=>
	(retract ?f)
	(assert (AGENT::move-completed (time ?t)))
	
)

(defrule EXPLORE::clear-undo-explore
	(declare (salience 500))
	(MAIN::status (time ?t))
	(AGENT::cry (pos-r ?) (pos-c ?))
	?f <- (AGENT::undo (time ?) (direction ?) (action ?))
	=>
	(retract ?f)
	(assert (AGENT::move-completed (time ?t)))
	
)
; ##--------------------------------------------------------------------##

; -------------------------- RITORNO AL MODULO AGENT ------------------------------
;Tornare il controllo al modulo AGENT, la mossa da compiere è stata decisa
(defrule EXPLORE::back-to-agent-explore
	(declare (salience 200))
	?f <- (AGENT::move-completed (time ?))
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

;(defmodule UNDO)


; ##--------------------- Disfare le azioni compiute -------------------##

; Regola per svolgere la seconda inversione nel caso in cui la prima undo sia una go
(defrule UNDO::invert-again
	(EXPLORE::first-undo (action go))
	(not (AGENT::undo (time ?t) (direction ?d) (action ?)))
	?f <- (MAIN::inversion-completed)
	(not (UNDO::second-inversion))
	=>
	(assert (AGENT::undo-step (step 1)))
	(assert (UNDO::second-inversion))
	(retract ?f)
	
)

; Questa regola serve per fare in modo che al completamento della seconda inversione
; si possa uscire con successo dalla fase di undo
(defrule UNDO::set-flag-toremove
	(declare (salience -5))
	(not (AGENT::undo (time ?t) (direction ?d) (action ?)))
	?f <- (MAIN::inversion-completed)
	?f1 <- (EXPLORE::first-undo (action go))
	?f2 <- (UNDO::second-inversion)
	=>
	(modify ?f1 (action to-remove))
	(retract ?f2)
	; Omar 01/09/05 - NON deve essere cancellato il flag altrimenti non si attiva la regola per 
	; uscire dal modulo UNDO
	;(retract ?f)
)
	
(defrule UNDO::clear-flag-inversion
	;(first-undo (action ~go))
	; Omar 01/09/05 - Questa regola non deve essere attivabile quando il flag di first-undo è stato
	; impostato a to-remove, perchè rimuovendo il flag "inversion-completed" si va in loop
	(and 
		(EXPLORE::first-undo (action ~go))
		(EXPLORE::first-undo (action ~to-remove))
	)
	?f <- (MAIN::inversion-completed)
	(not (AGENT::undo (time ?t) (direction ?d) (action ?)))
	=>
	(retract ?f)
)

(defrule UNDO::undo-action-go-step0
	(declare (salience -21))
	(not (MAIN::inversion-completed))
	(AGENT::movement (step 0))
	(AGENT::undo (time ?) (direction ?) (action go))
	=>
	(assert (AGENT::undo-step (step 1)))
	
)

(defrule UNDO::undo-action-go-step1
	(declare (salience 5))
	(MAIN::status (time ?t))
	(AGENT::movement (step 0))
	(not (MAIN::inversion-completed))
	?f <- (AGENT::undo-step (step 1))
	=>
	(assert (MAIN::exec (action turnleft) (time ?t)))
	(modify ?f (step 2))
	(assert (AGENT::move-completed (time ?t)))
	 ; POSSIBILE PROBLEMA 13/09/2005
	(pop-focus)	;devo tornare il controllo al modulo EXPLORE per fare in modo che sia eseguita l'azione
	
)

(defrule UNDO::undo-action-go-step2
	(declare (salience 5))
	(MAIN::status (time ?t))
	(AGENT::movement (step 0))
	(not (MAIN::inversion-completed))
	?f <- (AGENT::undo-step (step 2))
	=>
	(assert (MAIN::exec (action turnleft) (time ?t)))
	(assert (MAIN::inversion-completed))
	(assert (AGENT::move-completed (time ?t)))
	(retract ?f)
	(pop-focus)	;devo tornare il controllo al modulo EXPLORE per fare in modo che sia eseguita l'azione
	
)

(defrule UNDO::undo-action-go
	(declare (salience -22))
	(MAIN::status (time ?t))
	(AGENT::movement (step 0))
	(MAIN::inversion-completed)
	(AGENT::kpos (pos-r ?r) (pos-c ?c))
	?f1 <- (AGENT::map (pos-r ?r) (pos-c ?c))	
	?f <- (AGENT::undo (time ?) (direction ?d) (action go))
	=>
	(assert (MAIN::exec (action go) (time ?t)))
	(assert (AGENT::move-completed (time ?t)))
	(retract ?f)
	(modify ?f1 (rotation completed))
	(pop-focus)	;devo tornare il controllo al modulo EXPLORE per fare in modo che sia eseguita l'azione
	
)

(defrule UNDO::undo-action-turn
	(declare (salience -22))
	(MAIN::status (time ?t))
	(AGENT::movement (step 0))
	(AGENT::kpos (pos-r ?r) (pos-c ?c))
	?f1 <- (AGENT::map (pos-r ?r) (pos-c ?c))
	?f <- (AGENT::undo (time ?) (direction ?d) (action ?a&~go))
	=>
	(assert (MAIN::exec (action ?a) (time ?t)))
	(assert (AGENT::move-completed (time ?t)))
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

;(defmodule SAVE)

(deftemplate SAVE::survivor (slot pos-r) (slot pos-c))
(deftemplate SAVE::dig (slot pos-r) (slot pos-c))
;##------------Inserisco le possibilità posizionali del/i superstite/i-----------##

; Tutte le alternative possibili
(defrule SAVE::set-all-alternatives
	(declare (salience 50))
	(MAIN::status (time ?t))
	(AGENT::kpos (time ?t) (pos-r ?r) (pos-c ?c) (direction ?d) (load no))
	(not (SAVE::alternatives-setted))
	=>
	(assert (SAVE::survivor (pos-r (+ ?r 1)) (pos-c ?c)))
	(assert (SAVE::survivor (pos-r (- ?r 1)) (pos-c ?c)))
	(assert (SAVE::survivor (pos-r ?r) (pos-c (+ ?c 1))))
	(assert (SAVE::survivor (pos-r ?r) (pos-c (- ?c 1))))
	(assert (SAVE::alternatives-setted))
)

; Cancella le alternative che la mappa conosciuta puo' escludere
(defrule SAVE::delete-alternative
	(declare (salience 50))
	?f <- (SAVE::survivor (pos-r ?r) (pos-c ?c))
	(or
		(AGENT::map (pos-r ?r) (pos-c ?c) (contains ~debris))
		(AGENT::debris-position (pos-r ?r) (pos-c ?c) (useful no))
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
(defrule SAVE::goto-survivor-turnleft-up
	(declare (salience 10))
	(MAIN::status (time ?t))
	(not (MAIN::exec (action ?) (time ?t)))
	(not (AGENT::undo (time ?) (direction ?) (action ?)))
	(AGENT::kpos (time ?t) (pos-r ?r) (pos-c ?c) (direction up) (load no))
	(SAVE::survivor (pos-r ?r1) (pos-c ?)) 
	(test (<> ?r1 (- ?r 1)))	
	=>
	(assert (MAIN::exec (action turnleft)(time ?t))) 
	
)

(defrule SAVE::goto-survivor-turnleft-down
	(declare (salience 10))
	(MAIN::status (time ?t))
	(not (MAIN::exec (action ?) (time ?t)))
	(not (AGENT::undo (time ?) (direction ?) (action ?)))
	(AGENT::kpos (time ?t) (pos-r ?r) (pos-c ?c) (direction down) (load no))
	(SAVE::survivor (pos-r ?r1) (pos-c ?))
	(test (<> ?r1 (+ ?r 1)))         
	=>
	(assert (MAIN::exec (action turnleft)(time ?t)))
)

(defrule SAVE::goto-survivor-turnleft-left
	(declare (salience 10))
	(MAIN::status (time ?t))
	(not (MAIN::exec (action ?) (time ?t)))
	(not (AGENT::undo (time ?) (direction ?) (action ?)))
	(AGENT::kpos (time ?t) (pos-r ?r) (pos-c ?c) (direction left) (load no))
	(SAVE::survivor (pos-r ?) (pos-c ?c1))
	(test (<> ?c1 (- ?c 1)))
	=>
	(assert (MAIN::exec (action turnleft)(time ?t)))
)

(defrule SAVE::goto-survivor-turnleft-right
	(declare (salience 10))
	(MAIN::status (time ?t))
	(not (MAIN::exec (action ?) (time ?t)))
	(not (AGENT::undo (time ?) (direction ?) (action ?)))
	(AGENT::kpos (time ?t) (pos-r ?r) (pos-c ?c) (direction right) (load no))
	(SAVE::survivor (pos-r ?) (pos-c ?c1))
	(test (<> ?c1 (+ ?c 1)))
	=>
	(assert (MAIN::exec (action turnleft)(time ?t)))
)
	
; ##--------------------------------------------------------------------##


; ##--------------------- Go verso le macerie --------------------------##

; Si cerca di ragguingere la cella con le macerie (direzione UP)
(defrule SAVE::goto-survivor-fwd-up
	(declare (salience 20))
	(MAIN::status (time ?t))
	(not (MAIN::exec (action ?) (time ?t)))
	(AGENT::kpos (time ?t) (pos-r ?r) (pos-c ?c) (direction up) (load no))
	(MAIN::percepts (time ?t) (pos-r ?r)(pos-c ?c)(direction up)(perc1 debris)(perc2 ?)(perc3 ?)(cry yes))
	(SAVE::survivor (pos-r ?r1) (pos-c ?c)) 
	(test (= ?r1 (- ?r 1)))
	(not (AGENT::undo (time ?) (direction ?) (action ?)))
	=>
	(assert (MAIN::exec (action go)(time ?t))) 
	(assert (AGENT::undo (time ?t) (direction down) (action go)))	
)

; Si cerca di ragguingere la cella con le macerie (direzione DOWN)
(defrule SAVE::goto-survivor-fwd-down
	(declare (salience 20))
	(MAIN::status (time ?t))
	(not (MAIN::exec (action ?) (time ?t)))
	(AGENT::kpos (time ?t) (pos-r ?r) (pos-c ?c) (direction down) (load no))
	(MAIN::percepts (time ?t) (pos-r ?r)(pos-c ?c)(direction down)(perc1 debris)(perc2 ?)(perc3 ?)(cry yes))
	(SAVE::survivor (pos-r ?r1) (pos-c ?c))
	(test (= ?r1 (+ ?r 1)))
	(not (AGENT::undo (time ?) (direction ?) (action ?)))	
	=>
	(assert (MAIN::exec (action go)(time ?t)))
	(assert (AGENT::undo (direction up) (action go) (time ?t)))	
)

; Si cerca di ragguingere la cella con le macerie (direzione LEFT)
(defrule SAVE::goto-survivor-fwd-left
	(declare (salience 20))
	(MAIN::status (time ?t))
	(not (MAIN::exec (action ?) (time ?t)))
	(AGENT::kpos (time ?t) (pos-r ?r) (pos-c ?c) (direction left) (load no))
	(MAIN::percepts (time ?t) (pos-r ?r)(pos-c ?c)(direction left)(perc1 debris)(perc2 ?)(perc3 ?)(cry yes))
	(SAVE::survivor (pos-r ?r) (pos-c ?c1))
	(test (= ?c1 (- ?c 1)))
	(not (AGENT::undo (time ?) (direction ?) (action ?)))
	=>
	(assert (MAIN::exec (action go)(time ?t)))
	(assert (AGENT::undo (time ?t) (direction right) (action go)))	
)

; Si cerca di ragguingere la cella con le macerie (direzione RIGHT)
(defrule SAVE::goto-survivor-fwd-right
	(declare (salience 20))
	(MAIN::status (time ?t))
	(not (MAIN::exec (action ?) (time ?t)))
	(AGENT::kpos (time ?t) (pos-r ?r) (pos-c ?c) (direction right) (load no))
	(MAIN::percepts (time ?t) (pos-r ?r)(pos-c ?c)(direction right)(perc1 debris)(perc2 ?)(perc3 ?)(cry yes))
	(SAVE::survivor (pos-r ?r1) (pos-c ?c1))
	(test (= ?c1 (+ ?c 1)))
	(not (AGENT::undo (time ?) (direction ?) (action ?)))
	=>
	(assert (MAIN::exec (action go)(time ?t)))
	(assert (AGENT::undo (time ?t) (direction left) (action go)))
)

; ##--------------------------------------------------------------------##


; ##------------------Undo delle azioni di visita di debris-------------##
; Simili a quelle di EXPLORE ma senza il fatto movement nelle precondizioni,
; ma con il fatto (not (exec...


(defrule SAVE::undo-action-go-step0
	(declare (salience -21))
	(not (MAIN::inversion-completed))
	(MAIN::status (time ?t))
	(AGENT::kpos (time ?t) (pos-r ?r) (pos-c ?c) (direction ?))
	?f <- (SAVE::survivor (pos-r ?r) (pos-c ?c))
	(AGENT::undo (time ?) (direction ?) (action go))
	=>
	(assert (AGENT::undo-step (step 1)))
	(retract ?f)
	
)

(defrule SAVE::undo-action-go-step1
	(declare (salience 5))
	(MAIN::status (time ?t))
	(not (MAIN::exec (action ?) (time ?t)))
	(not (MAIN::inversion-completed))
	?f <- (AGENT::undo-step (step 1))
	=>
	(assert (MAIN::exec (action turnleft) (time ?t)))
	(modify ?f (step 2))
	
)

(defrule SAVE::undo-action-go-step2
	(declare (salience 5))
	(MAIN::status (time ?t))
	(not (MAIN::exec (action ?) (time ?t)))
	(not (MAIN::inversion-completed))
	?f <- (AGENT::undo-step (step 2))
	=>
	(assert (MAIN::exec (action turnleft) (time ?t)))
	(assert (MAIN::inversion-completed))
	(retract ?f)
	
)

(defrule SAVE::clear-flag-inversion
	(declare (salience -10))
	?f <- (MAIN::inversion-completed)
	(not (AGENT::undo (time ?t) (direction ?d) (action ?)))
	=>
	(retract ?f)
)

(defrule SAVE::undo-action-go
	(declare (salience -10))
	(MAIN::status (time ?t))
	(not (MAIN::exec (action ?) (time ?t)))
	(MAIN::inversion-completed)
	?f <- (AGENT::undo (time ?) (direction ?d) (action go))
	=>
	(assert (MAIN::exec (action go) (time ?t)))
	(retract ?f)
	
)

(defrule SAVE::back-to-agent-save
	(declare (salience -20))
	(MAIN::status (time ?t))
	(MAIN::exec (action ?a) (time ?t))
	=>
	(pop-focus)
)

; ##--------------------------------------------------------------------##


; ##-------------Se sono "sopra" il superstite-(vero o falso)-------------##
; Caso in cui 6 sopra un superstite e sentiamo ancora cry. ATT: non è detto
; che il fatto cry yes derivi che il superstite sia proprio lì. Vedi dig-fail.

; Se siamo sopra e sentiamo ancora cry yes, scaviamo
(defrule SAVE::dig-the-debris
	(declare (salience 50))
	(MAIN::status (time ?t))
	(not (MAIN::exec (action ?) (time ?t)))
	(MAIN::percepts (time ?t) (pos-r ?r)(pos-c ?c)(direction ?)(perc1 ?)(perc2 ?)(perc3 ?)(cry yes))
	(SAVE::survivor (pos-r ?r) (pos-c ?c))
	(not (SAVE::dig (pos-r ?r) (pos-c ?c)))
	=>
	(assert (MAIN::exec (action dig) (time ?t)))
	(assert (SAVE::dig (pos-r ?r) (pos-c ?c)))
	
)


; Se la dig non è andata a buon fine, dobbiamo tornare indietro (verranno eseguite le undo)
;(defrule SAVE::dig-fail
;	(declare (salience 100))
;	(MAIN::status (time ?t))
;	(not (MAIN::exec (action ?) (time ?t)))
;	(MAIN::perc-dig (time ?t) (pos-r ?r)(pos-c ?c) (person no))
;	?f <- (SAVE::survivor (pos-r ?r) (pos-c ?c))
;	=>
;	(retract ?f)
;)

; Se la dig ha avuto successo, eseguiamo una grasp della persona.
(defrule SAVE::grasp-the-survivor
	(declare (salience 100))
	(MAIN::status (time ?t))
	(not (MAIN::exec (action ?) (time ?t)))
	(MAIN::perc-dig (time ?t) (pos-r ?r)(pos-c ?c) (person yes))
	=>
	(assert (MAIN::exec (action grasp) (time ?t)))
	
)


; Eliminazione dei fatti undo residui
(defrule SAVE::clear-undo-save
	(declare (salience 500))
	(MAIN::status (time ?t))
	(MAIN::perc-grasp (time ?t) (pos-r ?r)(pos-c ?c) (person ?name))
	?f <- (AGENT::undo (time ?) (direction ?) (action ?))
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

;(defmodule EXIT)


(deftemplate EXIT::exit-unreachable (slot pos-r) (slot pos-c) (slot direction))


; Regola per valutare se di fronte al robot ci sia un'uscita (senza ostacoli)

; In questa regola viene valutato il risultato delle percezioni per evitare di muoversi
; verso un'uscita che si trova DIETRO un muro. Nel caso in cui l'uscita sia coperta
; da un muro (sulla traiettoria rettilinea tra il robot e l'uscita) vengono attivati
; i movimenti standard per far in modo che il robot eviti di sbattere contro il muro.

;OMAR 19/01/2006 - gestione celle unuseful
(defrule EXIT::exit-available-front-unreachable
	(declare (salience 100))
	(MAIN::status (time ?t))
	(AGENT::kpos (time ?t) (pos-r ?r) (pos-c ?c) (direction ?d) (load ?))
	(AGENT::exit-position (pos-r ?r1) (pos-c ?c1))
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
		(MAIN::percepts (time ?t) (pos-r ?r)(pos-c ?c)(direction ?)(perc1 wall|entry)(perc2 ?)(perc3 ?)(cry ?))
		(MAIN::percepts (time ?t) (pos-r ?r)(pos-c ?c)(direction ?)(perc1 ?)(perc2 wall|entry)(perc3 ?)(cry ?))
		(MAIN::percepts (time ?t) (pos-r ?r)(pos-c ?c)(direction ?)(perc1 ?)(perc2 ?)(perc3 wall|entry)(cry ?))
;		(MAIN::percepts (time ?t) (pos-r ?r)(pos-c ?c)(direction ?)(perc1 wall|entry)(perc2 ~unknown)(perc3 ~unknown)(cry ?))
;		(MAIN::percepts (time ?t) (pos-r ?r)(pos-c ?c)(direction ?)(perc1 ?)(perc2 wall|entry)(perc3 ~unknown)(cry ?))
;		(MAIN::percepts (time ?t) (pos-r ?r)(pos-c ?c)(direction ?)(perc1 ?)(perc2 ?)(perc3 wall|entry)(cry ?))

		; Gestione celle inutili
		(and
			(test (= (str-compare ?d left) 0))
			(or
				(and
					(AGENT::unuseful-cell (pos-r ?r) (pos-c ?c1))
					(test (= ?c1 (- ?c 1)))			
				)
				(and
					(AGENT::unuseful-cell (pos-r ?r) (pos-c ?c2))
					(test (= ?c2 (- ?c 2)))			
				)
				(and
					(AGENT::unuseful-cell (pos-r ?r) (pos-c ?c3))
					(test (= ?c3 (- ?c 3)))			
				)
			)				
		)
		(and
			(test (= (str-compare ?d right) 0))
			(or
				(and
					(AGENT::unuseful-cell (pos-r ?r) (pos-c ?c1))
					(test (= ?c1 (+ ?c 1)))			
				)
				(and
					(AGENT::unuseful-cell (pos-r ?r) (pos-c ?c2))
					(test (= ?c2 (+ ?c 2)))			
				)
				(and
					(AGENT::unuseful-cell (pos-r ?r) (pos-c ?c3))
					(test (= ?c3 (+ ?c 3)))			
				)
			)				
		)
		(and
			(test (= (str-compare ?d up) 0))
			(or
				(and
					(AGENT::unuseful-cell (pos-r ?r1) (pos-c ?c))
					(test (= ?r1 (- ?r 1)))			
				)
				(and
					(AGENT::unuseful-cell (pos-r ?r2) (pos-c ?c))
					(test (= ?r2 (- ?r 2)))			
				)
				(and
					(AGENT::unuseful-cell (pos-r ?r3) (pos-c ?c))
					(test (= ?r3 (- ?r 3)))			
				)
			)				
		)
		(and
			(test (= (str-compare ?d down) 0))
			(or
				(and
					(AGENT::unuseful-cell (pos-r ?r1) (pos-c ?c))
					(test (= ?r1 (+ ?r 1)))			
				)
				(and
					(AGENT::unuseful-cell (pos-r ?r2) (pos-c ?c))
					(test (= ?r2 (+ ?r 2)))			
				)
				(and
					(AGENT::unuseful-cell (pos-r ?r3) (pos-c ?c))
					(test (= ?r3 (+ ?r 3)))			
				)
			)				
		)
	)
	=>
	(assert (EXIT::exit-unreachable (pos-r ?r) (pos-c ?c) (direction ?d)))
)

; Regola per rimuovere il flag che indica un'uscita irrangiungibile dalla posizione attuale
; del robot
(defrule EXIT::clear-flag-unreachable
	(declare (salience 100))
	?f <- (EXIT::exit-unreachable (pos-r ?r) (pos-c ?c))
	(MAIN::percepts (time ?t) (pos-r ?r1)(pos-c ?c1))
	(or
		(test (<> ?r ?r1))
		(test (<> ?c ?c1))
	)
	=> 
	(retract ?f)	
)

;OMAR 19/01/2006 - gestione celle unuseful
(defrule EXIT::exit-available-front
	(not (EXIT::exit-unreachable (pos-r ?) (pos-c ?)))
	(MAIN::status (time ?t))
	(AGENT::kpos (time ?t) (pos-r ?r) (pos-c ?c) (direction ?d) (load ?))
	(AGENT::exit-position (pos-r ?r1) (pos-c ?c1))
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
		(MAIN::percepts (time ?t) (pos-r ?r)(pos-c ?c)(direction ?)(perc1 wall|entry)(perc2 ?)(perc3 ?)(cry ?))
		(MAIN::percepts (time ?t) (pos-r ?r)(pos-c ?c)(direction ?)(perc1 ?)(perc2 wall|entry)(perc3 ?)(cry ?))
		(MAIN::percepts (time ?t) (pos-r ?r)(pos-c ?c)(direction ?)(perc1 ?)(perc2 ?)(perc3 wall|entry)(cry ?))
		; Gestione celle inutili
		(and
			(test (= (str-compare ?d left) 0))
			(or
				(and
					(AGENT::unuseful-cell (pos-r ?r) (pos-c ?c1))
					(test (= ?c1 (- ?c 1)))			
				)
				(and
					(AGENT::unuseful-cell (pos-r ?r) (pos-c ?c2))
					(test (= ?c2 (- ?c 2)))			
				)
				(and
					(AGENT::unuseful-cell (pos-r ?r) (pos-c ?c3))
					(test (= ?c3 (- ?c 3)))			
				)
			)				
		)
		(and
			(test (= (str-compare ?d right) 0))
			(or
				(and
					(AGENT::unuseful-cell (pos-r ?r) (pos-c ?c1))
					(test (= ?c1 (+ ?c 1)))			
				)
				(and
					(AGENT::unuseful-cell (pos-r ?r) (pos-c ?c2))
					(test (= ?c2 (+ ?c 2)))			
				)
				(and
					(AGENT::unuseful-cell (pos-r ?r) (pos-c ?c3))
					(test (= ?c3 (+ ?c 3)))			
				)
			)				
		)
		(and
			(test (= (str-compare ?d up) 0))
			(or
				(and
					(AGENT::unuseful-cell (pos-r ?r1) (pos-c ?c))
					(test (= ?r1 (- ?r 1)))			
				)
				(and
					(AGENT::unuseful-cell (pos-r ?r2) (pos-c ?c))
					(test (= ?r2 (- ?r 2)))			
				)
				(and
					(AGENT::unuseful-cell (pos-r ?r3) (pos-c ?c))
					(test (= ?r3 (- ?r 3)))			
				)
			)				
		)
		(and
			(test (= (str-compare ?d down) 0))
			(or
				(and
					(AGENT::unuseful-cell (pos-r ?r1) (pos-c ?c))
					(test (= ?r1 (+ ?r 1)))			
				)
				(and
					(AGENT::unuseful-cell (pos-r ?r2) (pos-c ?c))
					(test (= ?r2 (+ ?r 2)))			
				)
				(and
					(AGENT::unuseful-cell (pos-r ?r3) (pos-c ?c))
					(test (= ?r3 (+ ?r 3)))			
				)
			)				
		)		
	))
	=>
	(assert (MAIN::exec (action go) (time ?t)))	; Proseguo nella direzioni in cui sono rivolto
	(assert (AGENT::move-completed (time ?t)))
	
)

; Regola per valutare se a sx del robot ci sia un'uscita
;OMAR 19/01/2006 - gestione celle unuseful
(defrule EXIT::exit-available-left
	(not (EXIT::exit-unreachable (pos-r ?) (pos-c ?)))
	(MAIN::status (time ?t))
	(AGENT::kpos (time ?t) (pos-r ?r) (pos-c ?c) (direction ?d) (load ?))
	(AGENT::exit-position (pos-r ?r1) (pos-c ?c1))
	(or
		(and
			(test (= (str-compare ?d up) 0))
			(test (= ?r1 ?r))
			(test (> ?c ?c1))
			; Verifica ostacoli sul tragitto verso l'uscita
			(not (and
				(or
					(AGENT::map (pos-r ?r2) (pos-c ?c2) (contains wall))
					(AGENT::unuseful-cell (pos-r ?r2) (pos-c ?c2))
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
					(AGENT::map (pos-r ?r2) (pos-c ?c2) (contains wall))
					(AGENT::unuseful-cell (pos-r ?r2) (pos-c ?c2))
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
					(AGENT::map (pos-r ?r2) (pos-c ?c2) (contains wall))
					(AGENT::unuseful-cell (pos-r ?r2) (pos-c ?c2))
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
					(AGENT::map (pos-r ?r2) (pos-c ?c2) (contains wall))
					(AGENT::unuseful-cell (pos-r ?r2) (pos-c ?c2))
				)				
				(test (= ?c2 ?c))
				(test (< ?r1 ?r2))
				(test (< ?r2 ?r))
			))
		)		
	)
	=>
	(assert (MAIN::exec (action turnleft) (time ?t)))	; Si prosegue nella stessa direzione
	(assert (AGENT::move-completed (time ?t)))
)


; Regola per valutare se a dx del robot ci sia un'uscita
;OMAR 19/01/2006 - gestione celle unuseful
(defrule EXIT::exit-available-right
	(not (EXIT::exit-unreachable (pos-r ?) (pos-c ?)))
	(MAIN::status (time ?t))
	(AGENT::kpos (time ?t) (pos-r ?r) (pos-c ?c) (direction ?d) (load ?))
	(AGENT::exit-position (pos-r ?r1) (pos-c ?c1))
	(or
		(and
			(test (= (str-compare ?d down) 0))
			(test (= ?r1 ?r))
			(test (> ?c ?c1))
			(not (and
				(or
					(AGENT::map (pos-r ?r2) (pos-c ?c2) (contains wall))
					(AGENT::unuseful-cell (pos-r ?r2) (pos-c ?c2))
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
					(AGENT::map (pos-r ?r2) (pos-c ?c2) (contains wall))
					(AGENT::unuseful-cell (pos-r ?r2) (pos-c ?c2))
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
					(AGENT::map (pos-r ?r2) (pos-c ?c2) (contains wall))
					(AGENT::unuseful-cell (pos-r ?r2) (pos-c ?c2))
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
					(AGENT::map (pos-r ?r2) (pos-c ?c2) (contains wall))
					(AGENT::unuseful-cell (pos-r ?r2) (pos-c ?c2))
				)
				(test (= ?c2 ?c))
				(test (< ?r1 ?r2))
				(test (< ?r2 ?r))
			))
		)		
	)
	=>
	(assert (MAIN::exec (action turnright) (time ?t)))	; Si prosegue nella stessa direzione
	(assert (AGENT::move-completed (time ?t)))
)

; Regola per valutare se dietro al robot ci sia un'uscita
;OMAR 19/01/2006 - gestione celle unuseful
(defrule EXIT::exit-available-rear
	(not (EXIT::exit-unreachable (pos-r ?) (pos-c ?)))
	(MAIN::status (time ?t))
	(AGENT::kpos (time ?t) (pos-r ?r) (pos-c ?c) (direction ?d) (load ?))
	(AGENT::exit-position (pos-r ?r1) (pos-c ?c1))
	
	(or
		(and
			(test (= (str-compare ?d up) 0))
			(test (> ?r1 ?r))
			(test (= ?c ?c1))
			(not (and
				(or
					(AGENT::map (pos-r ?r2) (pos-c ?c2) (contains wall))
					(AGENT::unuseful-cell (pos-r ?r2) (pos-c ?c2))
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
					(AGENT::map (pos-r ?r2) (pos-c ?c2) (contains wall))
					(AGENT::unuseful-cell (pos-r ?r2) (pos-c ?c2))
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
					(AGENT::map (pos-r ?r2) (pos-c ?c2) (contains wall))
					(AGENT::unuseful-cell (pos-r ?r2) (pos-c ?c2))
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
					(AGENT::map (pos-r ?r2) (pos-c ?c2) (contains wall))
					(AGENT::unuseful-cell (pos-r ?r2) (pos-c ?c2))
				)
				(test (= ?r2 ?r))
				(test (< ?c1 ?c2))
				(test (< ?c2 ?c))
			))
		)		
	)
	=>
	(assert (MAIN::exec (action turnleft) (time ?t)))	; Scelgo di farlo svoltare a sx, al prossimo passo
	(assert (AGENT::move-completed (time ?t)))		; si attiverà l'altra regola e quindi completa l'inversione
)

; ##-------------------- ATTIVAZIONE MOVIMENTI STANDARD  ----------------##
; Attivazione dei movimenti standard per il robot, bisogna procedere
; nell'esplorazione perchè non ci sono uscite disponibili


; Luigi - 290106

; Attivazione della pianificazione per raggiungere l'uscita più vicina
(defrule EXIT::go-plan2
	(declare (salience -100))
	?f2 <- (MAIN::status (time ?t) (result ?))
	(test (> ?t 2))
	?f1 <- (AGENT::movement (step ?))
	?f <- (AGENT::action (module ~plan))
	(not (AGENT::map (pos-r ?) (pos-c ?) (contains debris|empty) (rotation not-completed)))
	(not (and
		(AGENT::map (pos-r ?r) (pos-c ?c) (contains debris|empty))
		(not (AGENT::kpos (time ?) (pos-r ?r) (pos-c ?c)))
	))
	
	; 310106
	(or
		(and
			(PLAN::final-time-to-replanning ?ttr)
			(PLAN::current-time-to-replanning ?ttr)
		)
		(and
			(not (PLAN::final-time-to-replanning ?))
			(not (PLAN::current-time-to-replanning ?))
		)
	)
	(not (PLAN::plan-computed))
	=>
	(modify ?f (module plan))
	(modify ?f1 (step 0))
	(store planning start)
	(printout t crlf "-------------------------------------------------------------" crlf)
	(printout t "Tutta la mappa è stata esplorata, e un superstite ")
	(printout t crlf "e' stato trovato! Ora cerco una via d'uscita" crlf)
	(printout t "-------------------------------------------------------------" crlf crlf)
)

(defrule EXIT::go-standard-move
	(declare (salience -120))
	(not (AGENT::move-completed (time ?)))
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

(defrule EXIT::exit-wait-replanning
	(declare (salience 210))
	(MAIN::status (time ?t))
	?f <- (AGENT::move-completed (time ?))
	?f1 <- (PLAN::current-time-to-replanning ?ctr)
	(PLAN::final-time-to-replanning ?ftr)
	(test (< ?ctr ?ftr))
	=>
	(retract ?f)
	(retract ?f1)
	(assert (PLAN::current-time-to-replanning (+ ?ctr 1)))
	(pop-focus)
)

(defrule EXIT::exit-ok-replanning
	(declare (salience 210))
	(MAIN::status (time ?t))
	?f <- (AGENT::move-completed (time ?))
	?f1 <- (PLAN::current-time-to-replanning ?ctr)
	(PLAN::final-time-to-replanning ?ftr)
	(test (= ?ctr ?ftr))
	?f2 <- (AGENT::action (module ?))
	=>
	(retract ?f)
	;(retract ?f1)
	;(assert (PLAN::current-time-to-replanning -1))
	(modify ?f2 (module plan))
	(pop-focus)
)

(defrule EXIT::back-to-agent-exit
	(declare (salience 200))
	(MAIN::status (time ?t))
	?f <- (AGENT::move-completed (time ?))
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

; N.B. In choice viene salvato l'ultima scelta compiuta dal robot
(deftemplate STANDARD-MOVE::default-choice (slot pos-r) (slot pos-c) (slot direction) (slot choice))


; ##--------------------------- MOVIMENTI STANDARD ---------------------##

; Gestione CELLE INUTILI
; Rilevamento delle celle inutili, cioè racchiuse all'interno di un vicolo cieco
; Quando il robot di trova chiuso da 3 lati, viene impostata la cella su cui si trova
; come inutile dato che non può far altro che girarsi indietro. In questo modo una
; volta che è entrato in un vicolo cieco non ci entrerà più.
; ATTENZIONE: le EXIT non devono essere considerate blocchi!

;OMAR 19/01/2006 - gestione celle unuseful
(defrule STANDARD-MOVE::trace-unuseful-cell
	(declare (salience -5))
	?f <- (AGENT::movement (step 0))
	(MAIN::status (time ?t))
	(AGENT::kpos (time ?t) (pos-r ?r) (pos-c ?c) (direction ?d) (load ?))
	(not (AGENT::unuseful-cell (pos-r ?r) (pos-c ?c)))
	(not (AGENT::move-completed  (time ?)))	
	(or
		; direzione UP
		(and
			(test (= (str-compare ?d up) 0))
			(or
				(and
					(or 
						(AGENT::map (pos-r ?r1) (pos-c ?c) (contains wall|entry))
						(AGENT::unuseful-cell (pos-r ?r1) (pos-c ?c))				
					)
					(test (= (- ?r 1) ?r1))
				)
				(and
					(or 
						(AGENT::map (pos-r ?r1) (pos-c ?c) (contains wall|entry))
						(AGENT::unuseful-cell (pos-r ?r1) (pos-c ?c))				
					)
					(test (= (+ ?r 1) ?r1))
				)
			)
			(or 
				(AGENT::map (pos-r ?r) (pos-c ?c1) (contains wall|entry))
				(AGENT::unuseful-cell (pos-r ?r) (pos-c ?c1))				
			)				
			(test (= (- ?c 1) ?c1))			
			(or 
				(AGENT::map (pos-r ?r) (pos-c ?c2) (contains wall|entry))
				(AGENT::unuseful-cell (pos-r ?r) (pos-c ?c2))				
			)				
			(test (= (+ ?c 1) ?c2))
	        )
		; direzione DOWN
		(and
			(test (= (str-compare ?d down) 0))
			(or
				(and
					(or 
						(AGENT::map (pos-r ?r1) (pos-c ?c) (contains wall|entry))
						(AGENT::unuseful-cell (pos-r ?r1) (pos-c ?c))				
					)
					(test (= (+ ?r 1) ?r1))
				)
				(and
					(or 
						(AGENT::map (pos-r ?r1) (pos-c ?c) (contains wall|entry))
						(AGENT::unuseful-cell (pos-r ?r1) (pos-c ?c))				
					)
					(test (= (- ?r 1) ?r1))
				)
			)
			(or 
				(AGENT::map (pos-r ?r) (pos-c ?c1) (contains wall|entry))
				(AGENT::unuseful-cell (pos-r ?r) (pos-c ?c1))				
			)				
			(test (= (+ ?c 1) ?c1))
			(or 
				(AGENT::map (pos-r ?r) (pos-c ?c2) (contains wall|entry))
				(AGENT::unuseful-cell (pos-r ?r) (pos-c ?c2))				
			)				
			(test (= (- ?c 1) ?c2))		
	        )
		; direzione LEFT
		(and
			(test (= (str-compare ?d left) 0))
			(or
				(and
					(or 
						(AGENT::map (pos-r ?r) (pos-c ?c1) (contains wall|entry))
						(AGENT::unuseful-cell (pos-r ?r) (pos-c ?c1))				
					)
					(test (= (- ?c 1) ?c1))
				)
				(and
					(or 
						(AGENT::map (pos-r ?r) (pos-c ?c2) (contains wall|entry))
						(AGENT::unuseful-cell (pos-r ?r) (pos-c ?c2))				
					)
					(test (= (+ ?c 1) ?c2))
				)
			)
			(or 
				(AGENT::map (pos-r ?r1) (pos-c ?c) (contains wall|entry))
				(AGENT::unuseful-cell (pos-r ?r1) (pos-c ?c))				
			)				
			(test (= (- ?r 1) ?r1))
			(or 
				(AGENT::map (pos-r ?r2) (pos-c ?c) (contains wall|entry))
				(AGENT::unuseful-cell (pos-r ?r2) (pos-c ?c))				
			)				
			(test (= (+ ?r 1) ?r2))
	    	)
		; direzione RIGHT
		(and
			(test (= (str-compare ?d right) 0))
			(or
				(and
					(or 
						(AGENT::map (pos-r ?r) (pos-c ?c1) (contains wall|entry))
						(AGENT::unuseful-cell (pos-r ?r) (pos-c ?c1))				
					)
					(test (= (+ ?c 1) ?c1))
				)
				(and
					(or 
						(AGENT::map (pos-r ?r) (pos-c ?c1) (contains wall|entry))
						(AGENT::unuseful-cell (pos-r ?r) (pos-c ?c1))				
					)
					(test (= (- ?c 1) ?c1))
				)
			)
			(or 
				(AGENT::map (pos-r ?r1) (pos-c ?c) (contains wall|entry))
				(AGENT::unuseful-cell (pos-r ?r1) (pos-c ?c))				
			)				
			(test (= (+ ?r 1) ?r1))
			(or 
				(AGENT::map (pos-r ?r2) (pos-c ?c) (contains wall|entry))
				(AGENT::unuseful-cell (pos-r ?r2) (pos-c ?c))				
			)				
			(test (= (- ?r 1) ?r2))
	    )
	)
	=>
	; Imposto la cella su cui si trova il robot come cella inutile	
	(assert (AGENT::unuseful-cell (pos-r ?r) (pos-c ?c)))
	
	; Luigi 21/01/2006
	(store unusefulCellR ?r)
	(store unusefulCellC ?c)
)

; GESTIONE DEL BLOCCO FISICO (rappresentato dai muri, dalle entrate)
; Le regole considerano le uscite come muri (e quindi evitano di sbatterci contro) perche'
; se ci si trova a dover applicare questa regole, significa che le regole che pilotano
; il robot verso un'uscita non erano attivabili (e quindi l'uscita va trattata come un muro).

; Fa girare il robot a destra prima di sbattere contro un muro (o un'entrata o un'uscita)
;OMAR 19/01/2006 - gestione celle unuseful
(defrule STANDARD-MOVE::turn-right-physical
	(declare (salience -10))
	?f <- (AGENT::movement (step 0))
	(MAIN::status (time ?t))
	(AGENT::kpos (time ?t) (pos-r ?r) (pos-c ?c) (direction ?d)) 
	(or
		(MAIN::percepts (time ?t) (pos-r ?r)(pos-c ?c)(direction ?d)(perc1 wall|entry|exit)(perc2 ?p2)(perc3 ?p3)(cry ?))
		(and
			(test (= (str-compare ?d up) 0))
			(AGENT::unuseful-cell (pos-r ?r1) (pos-c ?c))
			(test (= (- ?r 1) ?r1))				
		)
		(and
			(test (= (str-compare ?d down) 0))
			(AGENT::unuseful-cell (pos-r ?r1) (pos-c ?c))
			(test (= (+ ?r 1) ?r1))				
		)
		(and
			(test (= (str-compare ?d left) 0))
			(AGENT::unuseful-cell (pos-r ?r) (pos-c ?c1))
			(test (= (- ?c 1) ?c1))				
		)
		(and
			(test (= (str-compare ?d right) 0))
			(AGENT::unuseful-cell (pos-r ?r) (pos-c ?c1))
			(test (= (+ ?c 1) ?c1))				
		)
	)
	(or
		(and
			(test (= (str-compare ?d up) 0))
			(or
				(AGENT::map (pos-r ?r) (pos-c ?c1) (contains wall|entry|exit))
				(AGENT::unuseful-cell (pos-r ?r) (pos-c ?c1))				
			)
			(test (= (- ?c 1) ?c1))			
		)
		(and
			(test (= (str-compare ?d down) 0))
			(or
				(AGENT::map (pos-r ?r) (pos-c ?c1) (contains wall|entry|exit))
				(AGENT::unuseful-cell (pos-r ?r) (pos-c ?c1))				
			)
			(test (= (+ ?c 1) ?c1))			
		)
		(and
			(test (= (str-compare ?d right) 0))
			(or
				(AGENT::map (pos-r ?r1) (pos-c ?c) (contains wall|entry|exit))
				(AGENT::unuseful-cell (pos-r ?r1) (pos-c ?c))				
			)
			(test (= (- ?r 1) ?r1))
		)
		(and
			(test (= (str-compare ?d left) 0))
			(or
				(AGENT::map (pos-r ?r1) (pos-c ?c) (contains wall|entry|exit))
				(AGENT::unuseful-cell (pos-r ?r1) (pos-c ?c))				
			)
			(test (= (+ ?r 1) ?r1))
		)	
	)
	(not (AGENT::move-completed (time ?)))
	=>
	(assert (MAIN::exec (action turnright)(time ?t)))
	(assert (AGENT::move-completed (time ?t)))
	(modify ?f (step 1))
	(pop-focus)
)

; Fa girare il robot a sinistra prima di sbattere contro un muro (o un'entrata o un'uscita)
;OMAR 19/01/2006 - gestione celle unuseful
(defrule STANDARD-MOVE::turn-left-physical
	(declare (salience -10))
	?f <- (AGENT::movement (step 0))
	(MAIN::status (time ?t))
	(AGENT::kpos (time ?t) (pos-r ?r) (pos-c ?c) (direction ?d)) 
	(or
		(MAIN::percepts (time ?t) (pos-r ?r)(pos-c ?c)(direction ?d)(perc1 wall|entry|exit)(perc2 ?p2)(perc3 ?p3)(cry ?))
		(and
			(test (= (str-compare ?d up) 0))
			(AGENT::unuseful-cell (pos-r ?r1) (pos-c ?c))
			(test (= (- ?r 1) ?r1))				
		)
		(and
			(test (= (str-compare ?d down) 0))
			(AGENT::unuseful-cell (pos-r ?r1) (pos-c ?c))
			(test (= (+ ?r 1) ?r1))				
		)
		(and
			(test (= (str-compare ?d left) 0))
			(AGENT::unuseful-cell (pos-r ?r) (pos-c ?c1))
			(test (= (- ?c 1) ?c1))				
		)
		(and
			(test (= (str-compare ?d right) 0))
			(AGENT::unuseful-cell (pos-r ?r) (pos-c ?c1))
			(test (= (+ ?c 1) ?c1))				
		)
	)	
	(or
		(and
			(test (= (str-compare ?d left) 0))
			(or
				(AGENT::map (pos-r ?r1) (pos-c ?c) (contains wall|entry|exit))
				(AGENT::unuseful-cell (pos-r ?r1) (pos-c ?c))
			)
			(test (= (- ?r 1) ?r1))
		)
		(and
			(test (= (str-compare ?d right) 0))
			(or
				(AGENT::map (pos-r ?r1) (pos-c ?c) (contains wall|entry|exit))
				(AGENT::unuseful-cell (pos-r ?r1) (pos-c ?c))
			)		
			(test (= (+ ?r 1) ?r1))
		)
		(and
			(test (= (str-compare ?d up) 0))
			(or
				(AGENT::map (pos-r ?r) (pos-c ?c1) (contains wall|entry|exit))
				(AGENT::unuseful-cell (pos-r ?r) (pos-c ?c1))
			)
			(test (= (+ ?c 1) ?c1))			
		)
		(and
			(test (= (str-compare ?d down) 0))
			(or
				(AGENT::map (pos-r ?r) (pos-c ?c1) (contains wall|entry|exit))
				(AGENT::unuseful-cell (pos-r ?r) (pos-c ?c1))
			)
			(test (= (- ?c 1) ?c1))			
		)	
	)
	(not (AGENT::move-completed  (time ?)))
	=>
	(assert (MAIN::exec (action turnleft)(time ?t)))
	(assert (AGENT::move-completed  (time ?t)))
	(modify ?f (step 1))
	(pop-focus)
)

; Omar 21/09/2005
; Regola che indica un movimento libero (si ha un blocco davanti ed entrambi i lati liberi). Di default si decide
; che la prima rotazione sarà verso sinistra. Alla successiva occasione di scelta si cambierà la direzione presa
; nella precedente scelta

; Regola per gestire la prima scelta di default (verso sinistra)
;OMAR 19/01/2006 - gestione celle unuseful
(defrule STANDARD-MOVE::turn-default-first
	(declare (salience -15))
	?f <- (AGENT::movement (step 0))
	(MAIN::status (time ?t))
	(AGENT::kpos (time ?t) (pos-r ?r) (pos-c ?c) (direction ?d)) 	
	(or
		(MAIN::percepts (time ?t) (pos-r ?r)(pos-c ?c)(direction ?d)(perc1 wall|entry|exit)(perc2 ?p2)(perc3 ?p3)(cry ?))
		(and
			(test (= (str-compare ?d up) 0))
			(AGENT::unuseful-cell (pos-r ?r1) (pos-c ?c))
			(test (= (- ?r 1) ?r1))				
		)
		(and
			(test (= (str-compare ?d down) 0))
			(AGENT::unuseful-cell (pos-r ?r1) (pos-c ?c))
			(test (= (+ ?r 1) ?r1))				
		)
		(and
			(test (= (str-compare ?d left) 0))
			(AGENT::unuseful-cell (pos-r ?r) (pos-c ?c1))
			(test (= (- ?c 1) ?c1))				
		)
		(and
			(test (= (str-compare ?d right) 0))
			(AGENT::unuseful-cell (pos-r ?r) (pos-c ?c1))
			(test (= (+ ?c 1) ?c1))				
		)
	)
	(not (STANDARD-MOVE::default-choice (pos-r ?r)(pos-c ?c)))
	(not (AGENT::move-completed  (time ?)))
	(or
		(and
			(test (= (str-compare ?d left) 0))
			(AGENT::map (pos-r ?r1) (pos-c ?c) (contains empty|debris))
			(AGENT::map (pos-r ?r2) (pos-c ?c) (contains empty|debris))
			(or
				(and
					(MAIN::exec-path (time ~2) (pos-r ?r1) (pos-c ?c) (module ?))
					(MAIN::exec-path (time ~2) (pos-r ?r2) (pos-c ?c) (module ?))
				)
				(and
					(not (MAIN::exec-path (time ~2) (pos-r ?r1) (pos-c ?c) (module ?)))
					(not (MAIN::exec-path (time ~2) (pos-r ?r2) (pos-c ?c) (module ?)))
				)
			)			
			(test (= (- ?r 1) ?r1))
			(test (= (+ ?r 1) ?r2))
		)
		(and
			(test (= (str-compare ?d right) 0))
			(AGENT::map (pos-r ?r1) (pos-c ?c) (contains empty|debris))
			(AGENT::map (pos-r ?r2) (pos-c ?c) (contains empty|debris))
			(or
				(and
					(MAIN::exec-path (time ~2) (pos-r ?r1) (pos-c ?c) (module ?))
					(MAIN::exec-path (time ~2) (pos-r ?r2) (pos-c ?c) (module ?))
				)
				(and
					(not (MAIN::exec-path (time ~2) (pos-r ?r1) (pos-c ?c) (module ?)))
					(not (MAIN::exec-path (time ~2) (pos-r ?r2) (pos-c ?c) (module ?)))
				)
			)
			(test (= (- ?r 1) ?r1))
			(test (= (+ ?r 1) ?r2))
		)

		(and
			(test (= (str-compare ?d up) 0))
			(AGENT::map (pos-r ?r) (pos-c ?c1) (contains empty|debris))
			(AGENT::map (pos-r ?r) (pos-c ?c2) (contains empty|debris))
			(or
				(and
					(MAIN::exec-path (time ~2) (pos-r ?r) (pos-c ?c1) (module ?))
					(MAIN::exec-path (time ~2) (pos-r ?r) (pos-c ?c2) (module ?))
				)
				(and
					(not (MAIN::exec-path (time ~2) (pos-r ?r) (pos-c ?c1) (module ?)))
					(not (MAIN::exec-path (time ~2) (pos-r ?r) (pos-c ?c2) (module ?)))
				)
			)
			(test (= (- ?c 1) ?c1))
			(test (= (+ ?c 1) ?c2))
		)
		(and
			(test (= (str-compare ?d down) 0))
			(AGENT::map (pos-r ?r) (pos-c ?c1) (contains empty|debris))
			(AGENT::map (pos-r ?r) (pos-c ?c2) (contains empty|debris))
			(or
				(and
					(MAIN::exec-path (time ~2) (pos-r ?r) (pos-c ?c1) (module ?))
					(MAIN::exec-path (time ~2) (pos-r ?r) (pos-c ?c2) (module ?))
				)
				(and
					(not (MAIN::exec-path (time ~2) (pos-r ?r) (pos-c ?c1) (module ?)))
					(not (MAIN::exec-path (time ~2) (pos-r ?r) (pos-c ?c2) (module ?)))
				)
			)
			(test (= (- ?c 1) ?c1))
			(test (= (+ ?c 1) ?c2))
		)
	)
	=>
	(assert (MAIN::exec (action turnleft)(time ?t)))
	(assert (AGENT::move-completed (time ?t)))
	(modify ?f (step 1))
	(assert (STANDARD-MOVE::default-choice (pos-r ?r) (pos-c ?c) (direction ?d) (choice left)))
	(pop-focus)
)

; Regola per gestire le scelte successive
; rotazione precedente verso destra --> adesso bisogna andare a sinistra
;OMAR 19/01/2006 - gestione celle unuseful
(defrule STANDARD-MOVE::turn-default-left
	(declare (salience -15))
	?f <- (AGENT::movement (step 0))
	(MAIN::status (time ?t))
	(AGENT::kpos (time ?t) (pos-r ?r) (pos-c ?c) (direction ?d)) 	
	(or
		(MAIN::percepts (time ?t) (pos-r ?r)(pos-c ?c)(direction ?d)(perc1 wall|entry|exit)(perc2 ?p2)(perc3 ?p3)(cry ?))
		(and
			(test (= (str-compare ?d up) 0))
			(AGENT::unuseful-cell (pos-r ?r1) (pos-c ?c))
			(test (= (- ?r 1) ?r1))				
		)
		(and
			(test (= (str-compare ?d down) 0))
			(AGENT::unuseful-cell (pos-r ?r1) (pos-c ?c))
			(test (= (+ ?r 1) ?r1))				
		)
		(and
			(test (= (str-compare ?d left) 0))
			(AGENT::unuseful-cell (pos-r ?r) (pos-c ?c1))
			(test (= (- ?c 1) ?c1))				
		)
		(and
			(test (= (str-compare ?d right) 0))
			(AGENT::unuseful-cell (pos-r ?r) (pos-c ?c1))
			(test (= (+ ?c 1) ?c1))				
		)
	)
	?f1 <- (STANDARD-MOVE::default-choice (pos-r ?r)(pos-c ?c)(direction ?d)(choice right))
	(or
		(and
			(test (= (str-compare ?d left) 0))
			(AGENT::map (pos-r ?r1) (pos-c ?c) (contains empty|debris))
			(AGENT::map (pos-r ?r2) (pos-c ?c) (contains empty|debris))
			(or
				(and
					(MAIN::exec-path (time ~2) (pos-r ?r1) (pos-c ?c) (module ?))
					(MAIN::exec-path (time ~2) (pos-r ?r2) (pos-c ?c) (module ?))
				)
				(and
					(not (MAIN::exec-path (time ~2) (pos-r ?r1) (pos-c ?c) (module ?)))
					(not (MAIN::exec-path (time ~2) (pos-r ?r2) (pos-c ?c) (module ?)))
				)
			)
			(test (= (- ?r 1) ?r1))
			(test (= (+ ?r 1) ?r2))
		)
		(and
			(test (= (str-compare ?d right) 0))
			(AGENT::map (pos-r ?r1) (pos-c ?c) (contains empty|debris))
			(AGENT::map (pos-r ?r2) (pos-c ?c) (contains empty|debris))
			(or
				(and
					(MAIN::exec-path (time ~2) (pos-r ?r1) (pos-c ?c) (module ?))
					(MAIN::exec-path (time ~2) (pos-r ?r2) (pos-c ?c) (module ?))
				)
				(and
					(not (MAIN::exec-path (time ~2) (pos-r ?r1) (pos-c ?c) (module ?)))
					(not (MAIN::exec-path (time ~2) (pos-r ?r2) (pos-c ?c) (module ?)))
				)
			)			
			(test (= (- ?r 1) ?r1))
			(test (= (+ ?r 1) ?r2))
		)

		(and
			(test (= (str-compare ?d up) 0))
			(AGENT::map (pos-r ?r) (pos-c ?c1) (contains empty|debris))
			(AGENT::map (pos-r ?r) (pos-c ?c2) (contains empty|debris))
			(or
				(and
					(MAIN::exec-path (time ~2) (pos-r ?r) (pos-c ?c1) (module ?))
					(MAIN::exec-path (time ~2) (pos-r ?r) (pos-c ?c2) (module ?))
				)
				(and
					(not (MAIN::exec-path (time ~2) (pos-r ?r) (pos-c ?c1) (module ?)))
					(not (MAIN::exec-path (time ~2) (pos-r ?r) (pos-c ?c2) (module ?)))
				)
			)
			(test (= (- ?c 1) ?c1))
			(test (= (+ ?c 1) ?c2))
		)
		(and
			(test (= (str-compare ?d down) 0))
			(AGENT::map (pos-r ?r) (pos-c ?c1) (contains empty|debris))
			(AGENT::map (pos-r ?r) (pos-c ?c2) (contains empty|debris))
			(or
				(and
					(MAIN::exec-path (time ~2) (pos-r ?r) (pos-c ?c1) (module ?))
					(MAIN::exec-path (time ~2) (pos-r ?r) (pos-c ?c2) (module ?))
				)
				(and
					(not (MAIN::exec-path (time ~2) (pos-r ?r) (pos-c ?c1) (module ?)))
					(not (MAIN::exec-path (time ~2) (pos-r ?r) (pos-c ?c2) (module ?)))
				)
			)
			(test (= (- ?c 1) ?c1))
			(test (= (+ ?c 1) ?c2))
		)
	)
	(not (AGENT::move-completed  (time ?)))
	=>
	(assert (MAIN::exec (action turnleft)(time ?t)))
	(assert (AGENT::move-completed (time ?t)))
	(modify ?f (step 1))
	(modify ?f1 (choice left))
	(pop-focus)
)

; Regola per gestire le scelte successive
; rotazione precedente verso sinistra --> adesso bisogna andare a destra
;OMAR 19/01/2006 - gestione celle unuseful
(defrule STANDARD-MOVE::turn-default-right
	(declare (salience -15))
	?f <- (AGENT::movement (step 0))
	(MAIN::status (time ?t))
	(AGENT::kpos (time ?t) (pos-r ?r) (pos-c ?c) (direction ?d)) 	
	(or
		(MAIN::percepts (time ?t) (pos-r ?r)(pos-c ?c)(direction ?d)(perc1 wall|entry|exit)(perc2 ?p2)(perc3 ?p3)(cry ?))
		(and
			(test (= (str-compare ?d up) 0))
			(AGENT::unuseful-cell (pos-r ?r1) (pos-c ?c))
			(test (= (- ?r 1) ?r1))				
		)
		(and
			(test (= (str-compare ?d down) 0))
			(AGENT::unuseful-cell (pos-r ?r1) (pos-c ?c))
			(test (= (+ ?r 1) ?r1))				
		)
		(and
			(test (= (str-compare ?d left) 0))
			(AGENT::unuseful-cell (pos-r ?r) (pos-c ?c1))
			(test (= (- ?c 1) ?c1))				
		)
		(and
			(test (= (str-compare ?d right) 0))
			(AGENT::unuseful-cell (pos-r ?r) (pos-c ?c1))
			(test (= (+ ?c 1) ?c1))				
		)
	)
	?f1 <- (STANDARD-MOVE::default-choice (pos-r ?r)(pos-c ?c)(direction ?d)(choice left))
	(or
		(and
			(test (= (str-compare ?d left) 0))
			(AGENT::map (pos-r ?r1) (pos-c ?c) (contains empty|debris))
			(AGENT::map (pos-r ?r2) (pos-c ?c) (contains empty|debris))
			(or
				(and
					(MAIN::exec-path (time ~2) (pos-r ?r1) (pos-c ?c) (module ?))
					(MAIN::exec-path (time ~2) (pos-r ?r2) (pos-c ?c) (module ?))
				)
				(and
					(not (MAIN::exec-path (time ~2) (pos-r ?r1) (pos-c ?c) (module ?)))
					(not (MAIN::exec-path (time ~2) (pos-r ?r2) (pos-c ?c) (module ?)))
				)
			)
			(test (= (- ?r 1) ?r1))
			(test (= (+ ?r 1) ?r2))
		)
		(and
			(test (= (str-compare ?d right) 0))
			(AGENT::map (pos-r ?r1) (pos-c ?c) (contains empty|debris))
			(AGENT::map (pos-r ?r2) (pos-c ?c) (contains empty|debris))
			(or
				(and
					(MAIN::exec-path (time ~2) (pos-r ?r1) (pos-c ?c) (module ?))
					(MAIN::exec-path (time ~2) (pos-r ?r2) (pos-c ?c) (module ?))
				)
				(and
					(not (MAIN::exec-path (time ~2) (pos-r ?r1) (pos-c ?c) (module ?)))
					(not (MAIN::exec-path (time ~2) (pos-r ?r2) (pos-c ?c) (module ?)))
				)
			)
			(test (= (- ?r 1) ?r1))
			(test (= (+ ?r 1) ?r2))
		)

		(and
			(test (= (str-compare ?d up) 0))
			(AGENT::map (pos-r ?r) (pos-c ?c1) (contains empty|debris))
			(AGENT::map (pos-r ?r) (pos-c ?c2) (contains empty|debris))
			(or
				(and
					(MAIN::exec-path (time ~2) (pos-r ?r) (pos-c ?c1) (module ?))
					(MAIN::exec-path (time ~2) (pos-r ?r) (pos-c ?c2) (module ?))
				)
				(and
					(not (MAIN::exec-path (time ~2) (pos-r ?r) (pos-c ?c1) (module ?)))
					(not (MAIN::exec-path (time ~2) (pos-r ?r) (pos-c ?c2) (module ?)))
				)
			)
			(test (= (- ?c 1) ?c1))
			(test (= (+ ?c 1) ?c2))
		)
		(and
			(test (= (str-compare ?d down) 0))
			(AGENT::map (pos-r ?r) (pos-c ?c1) (contains empty|debris))
			(AGENT::map (pos-r ?r) (pos-c ?c2) (contains empty|debris))
			(or
				(and
					(MAIN::exec-path (time ~2) (pos-r ?r) (pos-c ?c1) (module ?))
					(MAIN::exec-path (time ~2) (pos-r ?r) (pos-c ?c2) (module ?))
				)
				(and
					(not (MAIN::exec-path (time ~2) (pos-r ?r) (pos-c ?c1) (module ?)))
					(not (MAIN::exec-path (time ~2) (pos-r ?r) (pos-c ?c2) (module ?)))
				)
			)
			(test (= (- ?c 1) ?c1))
			(test (= (+ ?c 1) ?c2))
		)
	)
	(not (AGENT::move-completed  (time ?)))
	=>
	(assert (MAIN::exec (action turnright)(time ?t)))
	(assert (AGENT::move-completed (time ?t)))
	(modify ?f (step 1))
	(modify ?f1 (choice right))
	(pop-focus)
)

; Gestione dei vicoli chiechi logici, vengono sempre sfondati per far proseguire il robot nella direzione 
; in cui sta procedendo
;OMAR 19/01/2006 - gestione celle unuseful
(defrule STANDARD-MOVE::force-logical-blindalley
	(declare (salience -18))	
	?f <- (AGENT::movement (step 0))
	(MAIN::status (time ?t))
	(AGENT::kpos (time ?t) (pos-r ?r) (pos-c ?c) (direction ?d) (load ?))
	(not (AGENT::move-completed  (time ?)))	
	(or
		; direzione UP
		(and
			(test (= (str-compare ?d up) 0))
			(MAIN::exec-path (time ~2) (pos-r ?r1) (pos-c ?c) (module ?))
			(test (= (- ?r 1) ?r1))
			(or 
				(AGENT::map (pos-r ?r) (pos-c ?c1) (contains wall|entry|exit))
				(MAIN::exec-path (time ~2) (pos-r ?r) (pos-c ?c1) (module ?))
				(AGENT::unuseful-cell (pos-r ?r) (pos-c ?c1))				
			)				
			(test (= (- ?c 1) ?c1))			
			(or 
				(AGENT::map (pos-r ?r) (pos-c ?c2) (contains wall|entry|exit))
				(MAIN::exec-path (time ~2) (pos-r ?r) (pos-c ?c2) (module ?))
				(AGENT::unuseful-cell (pos-r ?r) (pos-c ?c2))				
			)				
			(test (= (+ ?c 1) ?c2))
	        )
		; direzione DOWN
		(and
			(test (= (str-compare ?d down) 0))
			(MAIN::exec-path (time ~2) (pos-r ?r1) (pos-c ?c) (module ?))
			(test (= (+ ?r 1) ?r1))
			(or 
				(AGENT::map (pos-r ?r) (pos-c ?c1) (contains wall|entry|exit))
				(MAIN::exec-path (time ~2) (pos-r ?r) (pos-c ?c1) (module ?))
				(AGENT::unuseful-cell (pos-r ?r) (pos-c ?c1))				
			)				
			(test (= (+ ?c 1) ?c1))
			(or 
				(AGENT::map (pos-r ?r) (pos-c ?c2) (contains wall|entry|exit))
				(MAIN::exec-path (time ~2) (pos-r ?r) (pos-c ?c2) (module ?))
				(AGENT::unuseful-cell (pos-r ?r) (pos-c ?c2))				
			)				
			(test (= (- ?c 1) ?c2))		
	        )
		; direzione LEFT
		(and
			(test (= (str-compare ?d left) 0))
			(MAIN::exec-path (time ~2) (pos-r ?r) (pos-c ?c1) (module ?))
			(test (= (- ?c 1) ?c1))
			(or 
				(AGENT::map (pos-r ?r1) (pos-c ?c) (contains wall|entry|exit))
				(MAIN::exec-path (time ~2) (pos-r ?r1) (pos-c ?c) (module ?))
				(AGENT::unuseful-cell (pos-r ?r1) (pos-c ?c))				
			)				
			(test (= (- ?r 1) ?r1))
			(or 
				(AGENT::map (pos-r ?r2) (pos-c ?c) (contains wall|entry|exit))
				(MAIN::exec-path (time ~2) (pos-r ?r2) (pos-c ?c) (module ?))
				(AGENT::unuseful-cell (pos-r ?r2) (pos-c ?c))				
			)				
			(test (= (+ ?r 1) ?r2))
	    	)
		; direzione RIGHT
		(and
			(test (= (str-compare ?d right) 0))
			(MAIN::exec-path (time ~2) (pos-r ?r) (pos-c ?c1) (module ?))
			(test (= (+ ?c 1) ?c1))
			(or 
				(AGENT::map (pos-r ?r1) (pos-c ?c) (contains wall|entry|exit))
				(MAIN::exec-path (time ~2) (pos-r ?r1) (pos-c ?c) (module ?))
				(AGENT::unuseful-cell (pos-r ?r1) (pos-c ?c))				
			)				
			(test (= (+ ?r 1) ?r1))
			(or 
				(AGENT::map (pos-r ?r2) (pos-c ?c) (contains wall|entry|exit))
				(MAIN::exec-path (time ~2) (pos-r ?r2) (pos-c ?c) (module ?))
				(AGENT::unuseful-cell (pos-r ?r2) (pos-c ?c))				
			)				
			(test (= (- ?r 1) ?r2))
	    )
	)
	=>
	(assert (MAIN::exec (action go)(time ?t)))
	(assert (AGENT::move-completed (time ?t)))
	(modify ?f (step 1))
	(pop-focus)
)

; AGGIUNTA: uso le exec-path al posto delle kpos, perchè mi dicono anche il modulo in cui ero
; quando sono stato su una cella. Serve per distinguere i blocchi logici di EXPLORE con quelli
; di EXIT.

; Fa girare il robot a destra prima di sbattere contro un muro logico (una cella giá visitata)
;OMAR 19/01/2006 - gestione celle unuseful
(defrule STANDARD-MOVE::turn-right-logical
	(declare (salience -20))
	?f <- (AGENT::movement (step 0))
	;(AGENT::action (module ?act))	
	(AGENT::kpos (time ?t) (pos-r ?r) (pos-c ?c) (direction ?d) (load ?))
	(MAIN::status (time ?t))
	(or
		; direzione UP
		(and
			(test (= (str-compare ?d up) 0))
			(MAIN::exec-path (time ?) (pos-r ?r1) (pos-c ?c) (module ?))
			(test (= (- ?r 1) ?r1))
			(or 
				(AGENT::map (pos-r ?r) (pos-c ?c1) (contains wall|entry|exit))
				(MAIN::exec-path (time ?) (pos-r ?r) (pos-c ?c1) (module ?))
				(AGENT::unuseful-cell (pos-r ?r) (pos-c ?c1))				
			)				
			(test (= (- ?c 1) ?c1))
			(and
				(AGENT::map (pos-r ?r) (pos-c ?c9) (contains ~wall&~entry&~exit))
				(not (AGENT::unuseful-cell (pos-r ?r) (pos-c ?c9)))
			)
			(test (= (+ ?c 1) ?c9))
	    )
	    (and
	    	(test (= (str-compare ?d up) 0))
			(MAIN::exec-path (time ?) (pos-r ?r) (pos-c ?c1) (module ?))
			(test (= (- ?c 1) ?c1))
			(or
				(AGENT::map (pos-r ?r1) (pos-c ?c) (contains wall|entry|exit))
				(MAIN::exec-path (time ?) (pos-r ?r1) (pos-c ?c) (module ?))
				(AGENT::unuseful-cell (pos-r ?r1) (pos-c ?c))
			)
			(test (= (- ?r 1) ?r1))
			(and
				(AGENT::map (pos-r ?r) (pos-c ?c9) (contains ~wall&~entry&~exit))
				(not (AGENT::unuseful-cell (pos-r ?r) (pos-c ?c9)))
			)
			(test (= (+ ?c 1) ?c9))
	    )

		; direzione DOWN
		(and
			(test (= (str-compare ?d down) 0))
			(MAIN::exec-path (time ?) (pos-r ?r1) (pos-c ?c) (module ?))
			(test (= (+ ?r 1) ?r1))
			(or 
				(AGENT::map (pos-r ?r) (pos-c ?c1) (contains wall|entry|exit))
				(MAIN::exec-path (time ?) (pos-r ?r) (pos-c ?c1) (module ?))
				(AGENT::unuseful-cell (pos-r ?r) (pos-c ?c1))
			)				
			(test (= (+ ?c 1) ?c1))
			(and
				(AGENT::map (pos-r ?r) (pos-c ?c9) (contains ~wall&~entry&~exit))
				(not (AGENT::unuseful-cell (pos-r ?r) (pos-c ?c9)))
			)
			(test (= (- ?c 1) ?c9))
	    )
	    (and
	    	(test (= (str-compare ?d down) 0))
			(MAIN::exec-path (time ?) (pos-r ?r) (pos-c ?c1) (module ?))
			(test (= (+ ?c 1) ?c1))
			(or
				(AGENT::map (pos-r ?r1) (pos-c ?c) (contains wall|entry|exit))
				(MAIN::exec-path (time ?) (pos-r ?r1) (pos-c ?c) (module ?))
				(AGENT::unuseful-cell (pos-r ?r1) (pos-c ?c))
			)
			(test (= (+ ?r 1) ?r1))
			(and
				(AGENT::map (pos-r ?r) (pos-c ?c9) (contains ~wall&~entry&~exit))
				(not (AGENT::unuseful-cell (pos-r ?r) (pos-c ?c9)))
			)
			(test (= (- ?c 1) ?c9))
	    )

		; direzione LEFT
		(and
			(test (= (str-compare ?d left) 0))
			(MAIN::exec-path (time ?) (pos-r ?r1) (pos-c ?c) (module ?))
			(test (= (+ ?r 1) ?r1))
			(or 
				(AGENT::map (pos-r ?r) (pos-c ?c1) (contains wall|entry|exit))
				(MAIN::exec-path (time ?) (pos-r ?r) (pos-c ?c1) (module ?))
				(AGENT::unuseful-cell (pos-r ?r) (pos-c ?c1))
			)				
			(test (= (- ?c 1) ?c1))
			(and
				(AGENT::map (pos-r ?r9) (pos-c ?c) (contains ~wall&~entry&~exit))
				(not (AGENT::unuseful-cell (pos-r ?r9) (pos-c ?c)))
			)
			(test (= (- ?r 1) ?r9))
	    )
	    (and
	    	(test (= (str-compare ?d left) 0))
			(MAIN::exec-path (time ?) (pos-r ?r) (pos-c ?c1) (module ?))
			(test (= (- ?c 1) ?c1))
			(or
				(AGENT::map (pos-r ?r1) (pos-c ?c) (contains wall|entry|exit))
				(MAIN::exec-path (time ?) (pos-r ?r1) (pos-c ?c) (module ?))
				(AGENT::unuseful-cell (pos-r ?r1) (pos-c ?c))
			)
			(test (= (+ ?r 1) ?r1))
			(and
				(AGENT::map (pos-r ?r9) (pos-c ?c) (contains ~wall&~entry&~exit))
				(not (AGENT::unuseful-cell (pos-r ?r9) (pos-c ?c)))
			)
			(test (= (- ?r 1) ?r9))
	    )

		; direzione RIGHT
		(and
			(test (= (str-compare ?d right) 0))
			(MAIN::exec-path (time ?) (pos-r ?r1) (pos-c ?c) (module ?))
			(test (= (- ?r 1) ?r1))
			(or 
				(AGENT::map (pos-r ?r) (pos-c ?c1) (contains wall|entry|exit))
				(MAIN::exec-path (time ?) (pos-r ?r) (pos-c ?c1) (module ?))
				(AGENT::unuseful-cell (pos-r ?r) (pos-c ?c1))				
			)				
			(test (= (+ ?c 1) ?c1))
			(and
				(AGENT::map (pos-r ?r9) (pos-c ?c) (contains ~wall&~entry&~exit))
				(not (AGENT::unuseful-cell (pos-r ?r9) (pos-c ?c)))
			)
			(test (= (+ ?r 1) ?r9))
	    )
	    (and
	    	(test (= (str-compare ?d right) 0))
			(MAIN::exec-path (time ?) (pos-r ?r) (pos-c ?c1) (module ?))
			(test (= (+ ?c 1) ?c1))
			(or
				(AGENT::map (pos-r ?r1) (pos-c ?c) (contains wall|entry|exit))
				(MAIN::exec-path (time ?) (pos-r ?r1) (pos-c ?c) (module ?))
				(AGENT::unuseful-cell (pos-r ?r1) (pos-c ?c))				
			)
			(test (= (- ?r 1) ?r1))
			(and
				(AGENT::map (pos-r ?r9) (pos-c ?c) (contains ~wall&~entry&~exit))
				(not (AGENT::unuseful-cell (pos-r ?r9) (pos-c ?c)))
			)
			(test (= (+ ?r 1) ?r9))
	    )
	)
	(not (AGENT::move-completed (time ?)))
	=>
	(assert (MAIN::exec (action turnright)(time ?t)))
	(assert (AGENT::move-completed (time ?t)))
	(modify ?f (step 1))
	(pop-focus)	
)

; Fa girare il robot a destra prima di sbattere contro un muro logico (una cella giá visitata)
;OMAR 19/01/2006 - gestione celle unuseful
(defrule STANDARD-MOVE::turn-left-logical
	(declare (salience -20))
	?f <- (AGENT::movement (step 0))
	;(AGENT::action (module ?act))
	(MAIN::status (time ?t))
	(AGENT::kpos (time ?t) (pos-r ?r) (pos-c ?c) (direction ?d) (load ?))
	(or
		; direzione RIGHT
		(and
			(test (= (str-compare ?d right) 0))
			(MAIN::exec-path (time ?) (pos-r ?r1) (pos-c ?c) (module ?))
			(test (= (+ ?r 1) ?r1))
			(or 
				(AGENT::map (pos-r ?r) (pos-c ?c1) (contains wall|entry|exit))
				(MAIN::exec-path (time ?) (pos-r ?r) (pos-c ?c1) (module ?))
				(AGENT::unuseful-cell (pos-r ?r) (pos-c ?c1))
			)				
			(test (= (+ ?c 1) ?c1))
			(and
				(AGENT::map (pos-r ?r9) (pos-c ?c) (contains ~wall&~entry&~exit))
				(not (AGENT::unuseful-cell (pos-r ?r9) (pos-c ?c)))
			)
			(test (= (- ?r 1) ?r9))
	    )
	    (and
	    	(test (= (str-compare ?d right) 0))
			(MAIN::exec-path (time ?) (pos-r ?r) (pos-c ?c1) (module ?))
			(test (= (+ ?c 1) ?c1))
			(or
				(AGENT::map (pos-r ?r1) (pos-c ?c) (contains wall|entry|exit))
				(MAIN::exec-path (time ?) (pos-r ?r1) (pos-c ?c) (module ?))
				(AGENT::unuseful-cell (pos-r ?r1) (pos-c ?c))				
			)
			(test (= (+ ?r 1) ?r1))
			(and
				(AGENT::map (pos-r ?r9) (pos-c ?c) (contains ~wall&~entry&~exit))
				(not (AGENT::unuseful-cell (pos-r ?r9) (pos-c ?c)))
			)
			(test (= (- ?r 1) ?r9))
	    )

		; direzione LEFT
		(and
			(test (= (str-compare ?d left) 0))
			(MAIN::exec-path (time ?) (pos-r ?r1) (pos-c ?c) (module ?))
			(test (= (- ?r 1) ?r1))
			(or 
				(AGENT::map (pos-r ?r) (pos-c ?c1) (contains wall|entry|exit))
				(MAIN::exec-path (time ?) (pos-r ?r) (pos-c ?c1) (module ?))
				(AGENT::unuseful-cell (pos-r ?r) (pos-c ?c1))				
			)				
			(test (= (- ?c 1) ?c1))
			(and
				(AGENT::map (pos-r ?r9) (pos-c ?c) (contains ~wall&~entry&~exit))
				(not (AGENT::unuseful-cell (pos-r ?r9) (pos-c ?c)))
			)
			(test (= (+ ?r 1) ?r9))
	    )
	    (and
	    	(test (= (str-compare ?d left) 0))
			(MAIN::exec-path (time ?) (pos-r ?r) (pos-c ?c1) (module ?))
			(test (= (- ?c 1) ?c1))
			(or
				(AGENT::map (pos-r ?r1) (pos-c ?c) (contains wall|entry|exit))
				(MAIN::exec-path (time ?) (pos-r ?r1) (pos-c ?c) (module ?))
				(AGENT::unuseful-cell (pos-r ?r1) (pos-c ?c))				
			)
			(test (= (- ?r 1) ?r1))
			(and
				(AGENT::map (pos-r ?r9) (pos-c ?c) (contains ~wall&~entry&~exit))
				(not (AGENT::unuseful-cell (pos-r ?r9) (pos-c ?c)))
			)
			(test (= (+ ?r 1) ?r9))
	    )

		; direzione DOWN
		(and
			(test (= (str-compare ?d down) 0))
			(MAIN::exec-path (time ?) (pos-r ?r1) (pos-c ?c) (module ?))
			(test (= (+ ?r 1) ?r1))
			(or 
				(AGENT::map (pos-r ?r) (pos-c ?c1) (contains wall|entry|exit))
				(MAIN::exec-path (time ?) (pos-r ?r) (pos-c ?c1) (module ?))
				(AGENT::unuseful-cell (pos-r ?r) (pos-c ?c1))				
			)				
			(test (= (- ?c 1) ?c1))
			(and
				(AGENT::map (pos-r ?r) (pos-c ?c9) (contains ~wall&~entry&~exit))
				(not (AGENT::unuseful-cell (pos-r ?r) (pos-c ?c9)))
			)
			(test (= (+ ?c 1) ?c9))
	    )
	    (and
	    	(test (= (str-compare ?d down) 0))
			(MAIN::exec-path (time ?) (pos-r ?r) (pos-c ?c1) (module ?))
			(test (= (- ?c 1) ?c1))
			(or
				(AGENT::map (pos-r ?r1) (pos-c ?c) (contains wall|entry|exit))
				(MAIN::exec-path (time ?) (pos-r ?r1) (pos-c ?c) (module ?))
				(AGENT::unuseful-cell (pos-r ?r1) (pos-c ?c))				
			)
			(test (= (+ ?r 1) ?r1))
			(and
				(AGENT::map (pos-r ?r) (pos-c ?c9) (contains ~wall&~entry&~exit))
				(not (AGENT::unuseful-cell (pos-r ?r) (pos-c ?c9)))
			)
			(test (= (+ ?c 1) ?c9))
	    )

		; direzione UP
		(and
			(test (= (str-compare ?d up) 0))
			(MAIN::exec-path (time ?) (pos-r ?r1) (pos-c ?c) (module ?))
			(test (= (- ?r 1) ?r1))
			(or 
				(AGENT::map (pos-r ?r) (pos-c ?c1) (contains wall|entry|exit))
				(MAIN::exec-path (time ?) (pos-r ?r) (pos-c ?c1) (module ?))
				(AGENT::unuseful-cell (pos-r ?r) (pos-c ?c1))				
			)				
			(test (= (+ ?c 1) ?c1))
			(and
				(AGENT::map (pos-r ?r) (pos-c ?c9) (contains ~wall&~entry&~exit))
				(not (AGENT::unuseful-cell (pos-r ?r) (pos-c ?c9)))
			)
			(test (= (- ?c 1) ?c9))
	    )
	    (and
	    	(test (= (str-compare ?d up) 0))
			(MAIN::exec-path (time ?) (pos-r ?r) (pos-c ?c1) (module ?))
			(test (= (+ ?c 1) ?c1))
			(or
				(AGENT::map (pos-r ?r1) (pos-c ?c) (contains wall|entry|exit))
				(MAIN::exec-path (time ?) (pos-r ?r1) (pos-c ?c) (module ?))
				(AGENT::unuseful-cell (pos-r ?r1) (pos-c ?c))				
			)
			(test (= (- ?r 1) ?r1))
			(and
				(AGENT::map (pos-r ?r) (pos-c ?c9) (contains ~wall&~entry&~exit))
				(not (AGENT::unuseful-cell (pos-r ?r) (pos-c ?c9)))
			)
			(test (= (- ?c 1) ?c9))
	    )
	)
	(not (AGENT::move-completed (time ?)))
	=>
	(assert (MAIN::exec (action turnleft)(time ?t)))
	(assert (AGENT::move-completed (time ?t)))
	(modify ?f (step 1))
	(pop-focus)
)


; 29/12/2005 - Nuova stretegia anti-loop
; Si contano i passaggi sulle celle della mappa, e se nelle celle adiacenti rispetto a quella davanti
; al robot ci sono meno passaggi, allora si gira verso quella con meno passaggi 
;OMAR 19/01/2006 - gestione celle unuseful
(defrule STANDARD-MOVE::loop-prevention-right
	(declare (salience -15))
	?f <- (AGENT::movement (step 0))
	;(AGENT::action (module ?act))	
	(AGENT::kpos (time ?t) (pos-r ?r) (pos-c ?c) (direction ?d) (load ?))
	(MAIN::status (time ?t))
	(or
		; direzione UP
		(and
			(test (= (str-compare ?d up) 0))
			(and
				(AGENT::map (pos-r ?r1) (pos-c ?c) (contains ~wall&~entry&~exit) (counter ?cnt-f))
				(not (AGENT::unuseful-cell (pos-r ?r1) (pos-c ?c)))				
			)
			(test (= (- ?r 1) ?r1))
			(or
				(and
					(and
						(AGENT::map (pos-r ?r) (pos-c ?c1) (contains ~wall&~entry&~exit) (counter ?cnt-l))
						(not (AGENT::unuseful-cell (pos-r ?r) (pos-c ?c1)))
					)
					(and
						(AGENT::map (pos-r ?r) (pos-c ?c2) (contains ~wall&~entry&~exit) (counter ?cnt-r))
						(not (AGENT::unuseful-cell (pos-r ?r) (pos-c ?c2)))
					)
					(test (= (- ?c 1) ?c1))
					(test (= (+ ?c 1) ?c2))
					(test (< ?cnt-r ?cnt-l))			
				)
				(and
					(AGENT::map (pos-r ?r) (pos-c ?c1) (contains ?) (counter ?cnt-l))
					(and
						(AGENT::map (pos-r ?r) (pos-c ?c2) (contains ~wall&~entry&~exit) (counter ?cnt-r))
						(not (AGENT::unuseful-cell (pos-r ?r) (pos-c ?c2)))
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
				(AGENT::map (pos-r ?r1) (pos-c ?c) (contains ~wall&~entry&~exit) (counter ?cnt-f))
				(not (AGENT::unuseful-cell (pos-r ?r1) (pos-c ?c)))
			)
			(test (= (+ ?r 1) ?r1))
			(or
				(and
					(and
						(AGENT::map (pos-r ?r) (pos-c ?c1) (contains ~wall&~entry&~exit) (counter ?cnt-r))
						(not (AGENT::unuseful-cell (pos-r ?r) (pos-c ?c1)))
					)
					(and
						(AGENT::map (pos-r ?r) (pos-c ?c2) (contains ~wall&~entry&~exit) (counter ?cnt-l))
						(not (AGENT::unuseful-cell (pos-r ?r) (pos-c ?c2)))
					)
					(test (= (- ?c 1) ?c1))
					(test (= (+ ?c 1) ?c2))
					(test (< ?cnt-r ?cnt-l))
				)
				(and
					(and
						(AGENT::map (pos-r ?r) (pos-c ?c1) (contains ~wall&~entry&~exit) (counter ?cnt-r))
						(not (AGENT::unuseful-cell (pos-r ?r) (pos-c ?c1)))
					)
					(AGENT::map (pos-r ?r) (pos-c ?c2) (contains ?) (counter ?cnt-l))
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
				(AGENT::map (pos-r ?r) (pos-c ?c1) (contains ~wall&~entry&~exit) (counter ?cnt-f))
				(not (AGENT::unuseful-cell (pos-r ?r) (pos-c ?c1)))
			)
			(test (= (- ?c 1) ?c1))
			(or
				(and
					(and
						(AGENT::map (pos-r ?r1) (pos-c ?c) (contains ~wall&~entry&~exit) (counter ?cnt-r))
						(not (AGENT::unuseful-cell (pos-r ?r1) (pos-c ?c)))
					)
					(and
						(AGENT::map (pos-r ?r2) (pos-c ?c) (contains ~wall&~entry&~exit) (counter ?cnt-l))
						(not (AGENT::unuseful-cell (pos-r ?r2) (pos-c ?c)))
					)
					(test (= (- ?r 1) ?r1))
					(test (= (+ ?r 1) ?r2))
					(test (< ?cnt-r ?cnt-l))
				)
				(and
					(and
						(AGENT::map (pos-r ?r1) (pos-c ?c) (contains ~wall&~entry&~exit) (counter ?cnt-r))
						(not (AGENT::unuseful-cell (pos-r ?r1) (pos-c ?c)))
					)
					(AGENT::map (pos-r ?r2) (pos-c ?c) (contains ?) (counter ?cnt-l))
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
				(AGENT::map (pos-r ?r) (pos-c ?c1) (contains ~wall&~entry&~exit) (counter ?cnt-f))
				(not (AGENT::unuseful-cell (pos-r ?r) (pos-c ?c1)))
			)
			(test (= (+ ?c 1) ?c1))
			(or
				(and
					(and
						(AGENT::map (pos-r ?r1) (pos-c ?c) (contains ~wall&~entry&~exit) (counter ?cnt-l))
						(not (AGENT::unuseful-cell (pos-r ?r1) (pos-c ?c)))
					)
					(and
						(AGENT::map (pos-r ?r2) (pos-c ?c) (contains ~wall&~entry&~exit) (counter ?cnt-r))
						(not (AGENT::unuseful-cell (pos-r ?r2) (pos-c ?c)))
					)
					(test (= (- ?r 1) ?r1))
					(test (= (+ ?r 1) ?r2))
					(test (< ?cnt-r ?cnt-l))
				)
				(and
					(AGENT::map (pos-r ?r1) (pos-c ?c) (contains ?) (counter ?cnt-l))
					(and
						(AGENT::map (pos-r ?r2) (pos-c ?c) (contains ~wall&~entry&~exit) (counter ?cnt-r))
						(not (AGENT::unuseful-cell (pos-r ?r2) (pos-c ?c)))
					)
					(test (= (- ?r 1) ?r1))
					(test (= (+ ?r 1) ?r2))
				)
			)
			(test (< ?cnt-r (- ?cnt-f 1)))
	    )
	)
	(not (AGENT::move-completed (time ?)))
	=>
	(assert (MAIN::exec (action turnright)(time ?t)))
	(assert (AGENT::move-completed (time ?t)))
	(modify ?f (step 1))
	(pop-focus)
	
)


; Fa girare il robot a destra prima di sbattere contro un muro logico (una cella giá visitata)
;OMAR 19/01/2006 - gestione celle unuseful
(defrule STANDARD-MOVE::loop-prevention-left
	(declare (salience -15))
	?f <- (AGENT::movement (step 0))
	;(AGENT::action (module ?act))
	(MAIN::status (time ?t))
	(AGENT::kpos (time ?t) (pos-r ?r) (pos-c ?c) (direction ?d) (load ?))
	(or
		; direzione UP
		(and
			(test (= (str-compare ?d up) 0))
			(and
				(AGENT::map (pos-r ?r1) (pos-c ?c) (contains ~wall&~entry&~exit) (counter ?cnt-f))
				(not (AGENT::unuseful-cell (pos-r ?r1) (pos-c ?c)))
			)
			(test (= (- ?r 1) ?r1))
			(or
				(and
					(and
						(AGENT::map (pos-r ?r) (pos-c ?c1) (contains ~wall&~entry&~exit) (counter ?cnt-l))
						(not (AGENT::unuseful-cell (pos-r ?r) (pos-c ?c1)))
					)						
					(and
						(AGENT::map (pos-r ?r) (pos-c ?c2) (contains ~wall&~entry&~exit) (counter ?cnt-r))
						(not (AGENT::unuseful-cell (pos-r ?r) (pos-c ?c2)))
					)
					(test (= (- ?c 1) ?c1))
					(test (= (+ ?c 1) ?c2))
					(test (<= ?cnt-l ?cnt-r))
				)
				(and
					(and
						(AGENT::map (pos-r ?r) (pos-c ?c1) (contains ~wall&~entry&~exit) (counter ?cnt-l))
						(not (AGENT::unuseful-cell (pos-r ?r) (pos-c ?c1)))
					)
					(AGENT::map (pos-r ?r) (pos-c ?c2) (contains ?) (counter ?cnt-r))
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
				(AGENT::map (pos-r ?r1) (pos-c ?c) (contains ~wall&~entry&~exit) (counter ?cnt-f))
				(not (AGENT::unuseful-cell (pos-r ?r1) (pos-c ?c)))
			)
			(test (= (+ ?r 1) ?r1))
			(or		
				(and
					(and
						(AGENT::map (pos-r ?r) (pos-c ?c1) (contains ~wall&~entry&~exit) (counter ?cnt-r))
						(not (AGENT::unuseful-cell (pos-r ?r) (pos-c ?c1)))
					)
					(and
						(AGENT::map (pos-r ?r) (pos-c ?c2) (contains ~wall&~entry&~exit) (counter ?cnt-l))
						(not (AGENT::unuseful-cell (pos-r ?r) (pos-c ?c2)))
					)
					(test (= (- ?c 1) ?c1))
					(test (= (+ ?c 1) ?c2))
					(test (<= ?cnt-l ?cnt-r))
				)
				(and
					(AGENT::map (pos-r ?r) (pos-c ?c1) (contains ?) (counter ?cnt-r))
					(and
						(AGENT::map (pos-r ?r) (pos-c ?c2) (contains ~wall&~entry&~exit) (counter ?cnt-l))
						(not (AGENT::unuseful-cell (pos-r ?r) (pos-c ?c2)))
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
				(AGENT::map (pos-r ?r) (pos-c ?c1) (contains ~wall&~entry&~exit) (counter ?cnt-f))
				(not (AGENT::unuseful-cell (pos-r ?r) (pos-c ?c1)))
			)
			(test (= (- ?c 1) ?c1))
			(or
				(and
					(and
						(AGENT::map (pos-r ?r1) (pos-c ?c) (contains ~wall&~entry&~exit) (counter ?cnt-r))
						(not (AGENT::unuseful-cell (pos-r ?r1) (pos-c ?c)))
					)
					(and
						(AGENT::map (pos-r ?r2) (pos-c ?c) (contains ~wall&~entry&~exit) (counter ?cnt-l))
						(not (AGENT::unuseful-cell (pos-r ?r2) (pos-c ?c)))
					)
					(test (= (- ?r 1) ?r1))
					(test (= (+ ?r 1) ?r2))
					(test (<= ?cnt-l ?cnt-r))
				)
				(and
					(AGENT::map (pos-r ?r1) (pos-c ?c) (contains ?) (counter ?cnt-r))
					(and
						(AGENT::map (pos-r ?r2) (pos-c ?c) (contains ~wall&~entry&~exit) (counter ?cnt-l))
						(not (AGENT::unuseful-cell (pos-r ?r2) (pos-c ?c)))
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
				(AGENT::map (pos-r ?r) (pos-c ?c1) (contains ~wall&~entry&~exit) (counter ?cnt-f))
				(not (AGENT::unuseful-cell (pos-r ?r) (pos-c ?c1)))
			)
			(test (= (+ ?c 1) ?c1))
			(or			
				(and
					(and
						(AGENT::map (pos-r ?r1) (pos-c ?c) (contains ~wall&~entry&~exit) (counter ?cnt-l))
						(not (AGENT::unuseful-cell (pos-r ?r1) (pos-c ?c)))
					)
					(and
						(AGENT::map (pos-r ?r2) (pos-c ?c) (contains ~wall&~entry&~exit) (counter ?cnt-r))
						(not (AGENT::unuseful-cell (pos-r ?r2) (pos-c ?c)))
					)
					(test (= (- ?r 1) ?r1))
					(test (= (+ ?r 1) ?r2))
					(test (<= ?cnt-l ?cnt-r))			
				)
				(and
					(and
						(AGENT::map (pos-r ?r1) (pos-c ?c) (contains ~wall&~entry&~exit) (counter ?cnt-l))
						(not (AGENT::unuseful-cell (pos-r ?r1) (pos-c ?c)))
					)
					(AGENT::map (pos-r ?r2) (pos-c ?c) (contains ?) (counter ?cnt-r))
					(test (= (- ?r 1) ?r1))
					(test (= (+ ?r 1) ?r2))
				)
			)
			(test (< ?cnt-l (- ?cnt-f 1)))
	    )
	)
	(not (AGENT::move-completed (time ?)))
	=>
	(assert (MAIN::exec (action turnleft)(time ?t)))
	(assert (AGENT::move-completed (time ?t)))
	(modify ?f (step 1))
	(pop-focus)
)
	
; Fa proseguire il robot nella direzione in cui e' rivolto avanzando di un passo
(defrule STANDARD-MOVE::go-on
	(declare (salience -35))
	?f <- (AGENT::movement (step 0))
	(MAIN::status (time ?t))
	(not (MAIN::exec (action ?) (time ?t)))
	(not (AGENT::move-completed  (time ?)))
	=>
	(assert (MAIN::exec (action go) (time ?t) ))
	(assert (AGENT::move-completed (time ?t)))
	(modify ?f (step 1))
	(pop-focus)
)

; ---------------------------------------------------------------------------------
;				   FINE MODULO STANDARD-MOVE
; ---------------------------------------------------------------------------------

; ---------------------------------------------------------------------------------
; MODULO AGENT - Componente PLAN
; ---------------------------------------------------------------------------------

; Modulo per gestire pianificazione verso uscita

(deftemplate PLAN::solution (slot value (default no))) 

(deftemplate PLAN::virtual-pos
	(slot level)
	(slot pos-r)
	(slot pos-c)
	(slot direction)
)

(deftemplate PLAN::delete
	(slot level)
	(slot pos-r)
	(slot pos-c)
	(slot direction)
)

; OMAR Ho aggiunto gli slot old-... perchè devo tenere traccia della posizione precedente del robot
; per poterla eliminare correttamente mediante i fatti "delete"
(deftemplate PLAN::apply
	(slot level)
	(slot action)
	(slot pos-r)
	(slot pos-c)
	(slot dir)
	(slot old-r)
	(slot old-c)
	(slot old-dir)
)

(deftemplate PLAN::node
	(slot level)
	(slot action)
	(slot index)
	(slot ancestor)
)

(deftemplate PLAN::node-ancestor
	(slot level)
	(slot index)
)

; Pulizia di precedenti planning
;---------------- Luigi 310106 ------ (inizio) -------------------

(defrule PLAN::clean1
(declare (salience 150))
    ?f <- (PLAN::virtual-pos)
    (PLAN::current-time-to-replanning ?t)
    (PLAN::final-time-to-replanning ?t)
    =>
    (retract ?f)
)

(defrule PLAN::clean2
(declare (salience 150))
    (PLAN::current-time-to-replanning ?t)
    (PLAN::final-time-to-replanning ?t)
    ?f <- (PLAN::clock-increased)
    =>
    (retract ?f)
)

(defrule PLAN::clean3
(declare (salience 150))
    ?f <- (PLAN::solution)
    (PLAN::current-time-to-replanning ?t)
    (PLAN::final-time-to-replanning ?t)
    =>
    (retract ?f)
)

(defrule PLAN::clean4
(declare (salience 150))
    (PLAN::current-time-to-replanning ?t)
    (PLAN::final-time-to-replanning ?t)
    ?f <- (PLAN::node-ancestor)
    =>
    (retract ?f)
)

(defrule PLAN::clean5
(declare (salience 150))
    (PLAN::current-time-to-replanning ?t)
    (PLAN::final-time-to-replanning ?t)
    ?f <- (PLAN::ancestor ?)    
    =>
    (retract ?f)
)

(defrule PLAN::clean6
(declare (salience 150))
    (PLAN::current-time-to-replanning ?t)
    (PLAN::final-time-to-replanning ?t)
    ?f <- (PLAN::node)
    =>
    (retract ?f)
)

(defrule PLAN::clean7
(declare (salience 150))
    (PLAN::current-time-to-replanning ?t)
    (PLAN::final-time-to-replanning ?t)
    ?f <- (PLAN::clock)
    =>
    (retract ?f)
)

(defrule PLAN::clean8
(declare (salience 150))
    (PLAN::current-time-to-replanning ?t)
    (PLAN::final-time-to-replanning ?t)
    ?f <- (PLAN::maxdepth ?)
    =>
    (retract ?f)
)

(defrule PLAN::clean9
(declare (salience 150))
    (PLAN::current-time-to-replanning ?t)
    (PLAN::final-time-to-replanning ?t)
    ?f <- (PLAN::resolved)
    =>
    (retract ?f)
)

(defrule PLAN::clean10
(declare (salience 125))
    ?f1 <- (PLAN::current-time-to-replanning ?t)
    ?f2 <- (PLAN::final-time-to-replanning ?t)
    =>
    (retract ?f1)
    (retract ?f2)
)


;---------------- Luigi 020206 ----- (nuovo) -----------------------
(defrule PLAN::calculate-perimeter1
   	(declare (salience 190))
   	(not (PLAN::perimeter ?))
   	=>
   	(assert (PLAN::perimeter 0))
)
   	
(defrule PLAN::calculate-perimeter2
   	(declare (salience 200))
   	(AGENT::map (pos-r ?r) (pos-c ?c))
   	?f <- (PLAN::perimeter ?s)
   	(test (> (+ ?r ?c) ?s))
	=>
	(retract ?f)
	(assert (PLAN::perimeter (+ ?r ?c)))
)

;---------------- Luigi 310106 ----- (fine) ------- modificata 020206 ----------------

; Inzializzazione della fase di pianificazione
(defrule PLAN::initialize
	(declare (salience 100))
	(not (PLAN::maxdepth ?))
	; 020206
	(PLAN::perimeter ?sbr)
	(MAIN::percepts (pos-r ?r) (pos-c ?c) (direction ?d)) 
	=>
	(assert (PLAN::virtual-pos (level 0) (pos-r ?r) (pos-c ?c) (direction ?d)))
	(assert (PLAN::solution (value no)))
	(assert (PLAN::maxdepth 0))
	(assert (PLAN::clock -1))
	(assert (PLAN::node-ancestor (level 0) (index 0)))
	(assert (PLAN::maximum-depth 12))
	; 310106
	(assert (PLAN::final-time-to-replanning ?sbr)) ; numero passi prima del replanning
	(assert (PLAN::current-time-to-replanning 0))
)

(defrule PLAN::increase-depth
(declare (salience 50))
    ?f1 <- (PLAN::maxdepth ?x)
    (not (PLAN::resolved))
    =>
	(retract ?f1)
	(assert (PLAN::maxdepth (+ ?x 2)))
	(store planningDepth (+ ?x 2))
	(set-current-module SIMULATE) (focus SIMULATE)
)

(defrule PLAN::erase-virtual-position
	(declare (salience 75))
	?f <- (PLAN::virtual-pos (level ?x&~0))
	;(not (PLAN::resolved))
	=>
	(retract ?f)
)

(defrule PLAN::erase-node
	(declare (salience 75))
	?f <- (PLAN::node (level ?))
	;(not (PLAN::resolved))
	; OMAR 29/01/2006
	; Non devono essere eliminati tutti i nodi dell'albero, ma solo
	; quelli che sono al di sotto della profondità massima
	;(PLAN::maxdepth ?d)
	;(PLAN::maximum-depth ?md)
	;(test (< ?d (- ?md 2)))
	=>
	(retract ?f)
)

(defrule PLAN::erase-ancestor
	(declare (salience 75))
	?f <- (PLAN::ancestor ?)
	;(not (PLAN::resolved))
	=>
	(retract ?f)
)

(defrule PLAN::planning-completed
	(declare (salience 100))
	(PLAN::resolved)
	(PLAN::ready-to-execute)	
	=>
	(assert (PLAN::plan-computed))
	(pop-focus)
)

; Regole per il tracciamento del cammino che porta all'uscita.
; Sulla base dell'albero delle soluzioni, si costruisce una sequenza 
; di fatti to-do

(defrule PLAN::build-path-step
	(declare (salience 150))
	(PLAN::resolved)
	?f <- (PLAN::current ?cur)
	(test (>= ?cur 0))
	(PLAN::node (level ?cur) (action ?act) (ancestor ?anc))
	=>
	(assert (AGENT::to-do (time ?cur) (action ?act)))
	(retract ?f)
	(assert (PLAN::current (- ?cur 1)))
)

(defrule PLAN::erase-node-unuseful
	(declare (salience 160))
	(PLAN::resolved)
	(PLAN::current ?cur)
	(test (>= ?cur 0))
	?f <- (PLAN::node (level ?l) (action ?act) (ancestor ?anc))
	(test (> ?l ?cur))
	=>
	(retract ?f)
)

(defrule PLAN::path-completed
	(declare (salience 200))
	(PLAN::resolved)
	(PLAN::current -1)
	=>
	(assert (PLAN::ready-to-execute))
)

; ---------------- modulo SIMULATE --------------------

;(defmodule SIMULATE);(import PLAN ?ALL)(export ?ALL))
(defrule SIMULATE::got-solution
	(declare (salience 100))
	(PLAN::solution (value yes))
	=> 
	(assert (PLAN::resolved))
	(pop-focus)
)

; OMAR 29/01/2006
; Imposto un limite alla profondità massima di esplorazione
; della mappa, se non ho raggiunto l'uscita, eseguo comunque il piano che ho
; costruito finora, riattivando nuovamente la pianificazione con
; limite massimo di profondità = 10
(defrule SIMULATE::exceed-maximum-depth
	(declare (salience 80))
	(PLAN::maxdepth ?d)
	(PLAN::maximum-depth ?d)
	(not (PLAN::resolved))
	?f <- (AGENT::action (module ?))
	=>
	(store planning end)
	(modify ?f (module exit))
	(assert (PLAN::resolved))
	(pop-focus)
)

(defrule SIMULATE::increase-clock
	(declare (salience 20))
	(not (PLAN::clock-increased))
	?f <- (PLAN::clock ?cl)
	=>
	(retract ?f)
	(assert (PLAN::clock (+ ?cl 1)))
	(assert (PLAN::clock-increased))
)

(defrule SIMULATE::go-up
	(PLAN::virtual-pos (level ?s) (pos-r ?r) (pos-c ?c) (direction up))
	(or 
		(AGENT::map (pos-r ?r1) (pos-c ?c) (contains ~wall&~entry))
		(AGENT::unuseful-cell (pos-r ?r1) (pos-c ?c))
	)
	(test (= ?r1 (- ?r 1)))
	(PLAN::maxdepth ?d)
	(test (< ?s ?d))
	(not (PLAN::node (level ?s) (action go))) 
	=>
	(assert (PLAN::apply (level ?s) (action go) (pos-r ?r1) (pos-c ?c) (dir up) (old-r ?r) (old-c ?c) (old-dir up)))
)

(defrule SIMULATE::go-down
	(PLAN::virtual-pos (level ?s) (pos-r ?r) (pos-c ?c) (direction down))
	(or
		(AGENT::map (pos-r ?r1) (pos-c ?c) (contains ~wall&~entry))
		(AGENT::unuseful-cell (pos-r ?r1) (pos-c ?c))
	)
	(test (= ?r1 (+ ?r 1)))
	(PLAN::maxdepth ?d)
	(test (< ?s ?d))
	(not (PLAN::node (level ?s) (action go))) 
	=>
	(assert (PLAN::apply (level ?s) (action go) (pos-r ?r1) (pos-c ?c) (dir down) (old-r ?r) (old-c ?c) (old-dir down)))
)

(defrule SIMULATE::go-left
	(PLAN::virtual-pos (level ?s) (pos-r ?r) (pos-c ?c) (direction left))
	(or
		(AGENT::map (pos-r ?r) (pos-c ?c1) (contains ~wall&~entry))
		(AGENT::unuseful-cell (pos-r ?r) (pos-c ?c1))
	)
	(test (= ?c1 (- ?c 1)))
	(PLAN::maxdepth ?d)
	(test (< ?s ?d))
	(not (PLAN::node (level ?s) (action go))) 
	=>
	(assert (PLAN::apply (level ?s) (action go) (pos-r ?r) (pos-c ?c1) (dir left) (old-r ?r) (old-c ?c) (old-dir left)))
)

(defrule SIMULATE::go-right
	(PLAN::virtual-pos (level ?s) (pos-r ?r) (pos-c ?c) (direction right))
	(or
		(AGENT::map (pos-r ?r) (pos-c ?c1) (contains ~wall&~entry))
		(AGENT::unuseful-cell (pos-r ?r) (pos-c ?c1))
	)
	(test (= ?c1 (+ ?c 1)))
	(PLAN::maxdepth ?d)
	(test (< ?s ?d))
	(not (PLAN::node (level ?s) (action go))) 
	=>
	(assert (PLAN::apply (level ?s) (action go) (pos-r ?r) (pos-c ?c1) (dir right) (old-r ?r) (old-c ?c) (old-dir right)))
)

(defrule SIMULATE::apply-go
	?f <- (PLAN::apply (level ?s) (action go) (pos-r ?nr) (pos-c ?nc) (dir ?dir) (old-r ?or) (old-c ?oc) (old-dir ?od))
	(PLAN::clock ?cl)
	?f1 <- (PLAN::clock-increased)
	=>
	(retract ?f)
	(assert (PLAN::delete (level ?s) (pos-r ?or) (pos-c ?oc) (direction ?od)))
	(assert (PLAN::virtual-pos (level (+ ?s 1)) (pos-r ?nr) (pos-c ?nc) (direction ?dir)))
	(assert (PLAN::current ?s))
	(assert (PLAN::newstate (+ ?s 1)))
	(assert (PLAN::node (level ?s) (action go) (index ?cl)))
	(retract ?f1)
	(set-current-module CHECK) (focus CHECK)
)

(defrule SIMULATE::go-delete-position
	(declare (salience 2))
	(PLAN::apply (level ?s) (action go))
	?f <- (PLAN::virtual-pos (level ?t))
	(test (> ?t ?s))
	=>
	(retract ?f)
)

(defrule SIMULATE::go-delete-node
	(declare (salience 1))
	(PLAN::apply (level ?s) (action go))
	?f <- (PLAN::node (level ?t) (index ?cl))
	(test (> ?t ?s))
	=>
	(retract ?f)
)

; - AZIONE turnleft -
(defrule SIMULATE::turnleft-up
	(PLAN::virtual-pos (level ?s) (pos-r ?r) (pos-c ?c) (direction up))
	(or 
		(AGENT::map (pos-r ?r) (pos-c ?c1) (contains ~wall&~entry))
		(AGENT::unuseful-cell (pos-r ?r) (pos-c ?c1))
	)
	(test (= ?c1 (- ?c 1)))
	(PLAN::maxdepth ?d)
	(test (< ?s ?d))
	(not (PLAN::node (level ?s) (action turnleft))) 
	=>
	(assert (PLAN::apply (level ?s) (action turnleft) (pos-r ?r) (pos-c ?c) (dir left) (old-r ?r) (old-c ?c) (old-dir up)))
)
		
(defrule SIMULATE::turnleft-down
	(PLAN::virtual-pos (level ?s) (pos-r ?r) (pos-c ?c) (direction down))
	(or 
		(AGENT::map (pos-r ?r) (pos-c ?c1) (contains ~wall&~entry))
		(AGENT::unuseful-cell (pos-r ?r) (pos-c ?c1))
	)
	(test (= ?c1 (+ ?c 1)))
	(PLAN::maxdepth ?d)
	(test (< ?s ?d))
	(not (PLAN::node (level ?s) (action turnleft))) 
	=>
	(assert (PLAN::apply (level ?s) (action turnleft) (pos-r ?r) (pos-c ?c) (dir right) (old-r ?r) (old-c ?c) (old-dir down)))
)

(defrule SIMULATE::turnleft-left
	(PLAN::virtual-pos (level ?s) (pos-r ?r) (pos-c ?c) (direction left))
	(or 
		(AGENT::map (pos-r ?r1) (pos-c ?c) (contains ~wall&~entry))
		(AGENT::unuseful-cell (pos-r ?r1) (pos-c ?c))
	)
	(test (= ?r1 (+ ?r 1)))
	(PLAN::maxdepth ?d)
	(test (< ?s ?d))
	(not (PLAN::node (level ?s) (action turnleft))) 
	=>
	(assert (PLAN::apply (level ?s) (action turnleft) (pos-r ?r) (pos-c ?c) (dir down) (old-r ?r) (old-c ?c) (old-dir left)))
)

(defrule SIMULATE::turnleft-right
	(PLAN::virtual-pos (level ?s) (pos-r ?r) (pos-c ?c) (direction right))
	(or 
		(AGENT::map (pos-r ?r1) (pos-c ?c) (contains ~wall&~entry))
		(AGENT::unuseful-cell (pos-r ?r1) (pos-c ?c))
	)
	(test (= ?r1 (- ?r 1)))
	(PLAN::maxdepth ?d)
	(PLAN::maxdepth ?d)
	(test (< ?s ?d))
	(not (PLAN::node (level ?s) (action turnleft))) 
	=>
	(assert (PLAN::apply (level ?s) (action turnleft) (pos-r ?r) (pos-c ?c) (dir up) (old-r ?r) (old-c ?c) (old-dir right)))
)

(defrule SIMULATE::apply-turnleft
	?f <- (PLAN::apply (level ?s) (action turnleft) (pos-r ?nr) (pos-c ?nc) (dir ?dir) (old-r ?or) (old-c ?oc) (old-dir ?od))
	?f1 <- (PLAN::clock-increased)
	(PLAN::clock ?cl)
	=>
	(retract ?f)
	(assert (PLAN::delete (level ?s) (pos-r ?or) (pos-c ?oc) (direction ?od)))
	(assert (PLAN::virtual-pos (level (+ ?s 1)) (pos-r ?nr) (pos-c ?nc) (direction ?dir)))
	(assert (PLAN::current ?s))
	(assert (PLAN::newstate (+ ?s 1)))
	(assert (PLAN::node (level ?s) (action turnleft) (index ?cl)))
	(retract ?f1)
	(set-current-module CHECK) (focus CHECK)
)

(defrule SIMULATE::turnleft-delete-position
	(declare (salience 2))
	(PLAN::apply (level ?s) (action turnleft))
	?f <- (PLAN::virtual-pos (level ?t))
	(test (> ?t ?s))
	=>
	(retract ?f)
)

(defrule SIMULATE::turnleft-delete-node
	(declare (salience 1))
	(PLAN::apply (level ?s) (action turnleft))
	?f <- (PLAN::node (level ?t) (index ?cl))
	(test (> ?t ?s))
	=>
	(retract ?f)
)

; - AZIONE turnright -
(defrule SIMULATE::turnright-up
	(PLAN::virtual-pos (level ?s) (pos-r ?r) (pos-c ?c) (direction up))
	(or 
		(AGENT::map (pos-r ?r) (pos-c ?c1) (contains ~wall&~entry))
		(AGENT::unuseful-cell (pos-r ?r) (pos-c ?c1))
	)
	(test (= ?c1 (+ ?c 1)))
	(PLAN::maxdepth ?d)
	(test (< ?s ?d))
	(not (PLAN::node (level ?s) (action turnright))) 
	=>
	(assert (PLAN::apply (level ?s) (action turnright) (pos-r ?r) (pos-c ?c) (dir right) (old-r ?r) (old-c ?c) (old-dir up)))
)
		
(defrule SIMULATE::turnright-down
	(PLAN::virtual-pos (level ?s) (pos-r ?r) (pos-c ?c) (direction down))
	(or 
		(AGENT::map (pos-r ?r) (pos-c ?c1) (contains ~wall&~entry))
		(AGENT::unuseful-cell (pos-r ?r) (pos-c ?c1))
	)
	(test (= ?c1 (- ?c 1)))
	(PLAN::maxdepth ?d)
	(test (< ?s ?d))
	(not (PLAN::node (level ?s) (action turnright))) 
	=>
	(assert (PLAN::apply (level ?s) (action turnright) (pos-r ?r) (pos-c ?c) (dir left) (old-r ?r) (old-c ?c) (old-dir down)))
)

(defrule SIMULATE::turnright-left
	(PLAN::virtual-pos (level ?s) (pos-r ?r) (pos-c ?c) (direction left))
	(or 
		(AGENT::map (pos-r ?r1) (pos-c ?c) (contains ~wall&~entry))
		(AGENT::unuseful-cell (pos-r ?r1) (pos-c ?c))
	)
	(test (= ?r1 (- ?r 1)))
	(PLAN::maxdepth ?d)
	(test (< ?s ?d))
	(not (PLAN::node (level ?s) (action turnright))) 
	=>
	(assert (PLAN::apply (level ?s) (action turnright) (pos-r ?r) (pos-c ?c) (dir up) (old-r ?r) (old-c ?c) (old-dir left)))
)

(defrule SIMULATE::turnright-right
	(PLAN::virtual-pos (level ?s) (pos-r ?r) (pos-c ?c) (direction right))
	(or 
		(AGENT::map (pos-r ?r1) (pos-c ?c) (contains ~wall&~entry))
		(AGENT::unuseful-cell (pos-r ?r1) (pos-c ?c))
	)
	(test (= ?r1 (+ ?r 1)))
	(PLAN::maxdepth ?d)
	(PLAN::maxdepth ?d)
	(test (< ?s ?d))
	(not (PLAN::node (level ?s) (action turnright))) 
	=>
	(assert (PLAN::apply (level ?s) (action turnright) (pos-r ?r) (pos-c ?c) (dir down) (old-r ?r) (old-c ?c) (old-dir right)))
)

(defrule SIMULATE::apply-turnright
	?f <- (PLAN::apply (level ?s) (action turnright) (pos-r ?nr) (pos-c ?nc) (dir ?dir) (old-r ?or) (old-c ?oc) (old-dir ?od))
	?f1 <- (PLAN::clock-increased)
	(PLAN::clock ?cl)
	=>
	(retract ?f)
	(assert (PLAN::delete (level ?s) (pos-r ?or) (pos-c ?oc) (direction ?od)))
	(assert (PLAN::virtual-pos (level (+ ?s 1)) (pos-r ?nr) (pos-c ?nc) (direction ?dir)))
	(assert (PLAN::current ?s))
	(assert (PLAN::newstate (+ ?s 1)))
	(assert (PLAN::node (level ?s) (action turnright) (index ?cl)))
	(retract ?f1)
	(set-current-module CHECK) (focus CHECK)
)

(defrule SIMULATE::turnright-delete-position
	(declare (salience 2))
	(PLAN::apply (level ?s) (action turnright))
	?f <- (PLAN::virtual-pos (level ?t))
	(test (> ?t ?s))
	=>
	(retract ?f)
)

(defrule SIMULATE::turnright-delete-node
	(declare (salience 1))
	(PLAN::apply (level ?s) (action turnright))
	?f <- (PLAN::node (level ?t) (index ?cl))
	(test (> ?t ?s))
	=>
	(retract ?f)
)

; - gestione vicoli ciechi
(defrule SIMULATE::blindalley-up
	(declare (salience -5))
	(PLAN::virtual-pos (level ?s) (pos-r ?r) (pos-c ?c) (direction up))
	(PLAN::maxdepth ?d)
	(test (< ?s ?d))
	(not (PLAN::node (level ?s) (action turnleft))) 
	=>
	(assert (PLAN::apply (level ?s) (action turnleft) (pos-r ?r) (pos-c ?c) (dir left) (old-r ?r) (old-c ?c) (old-dir up)))
)

(defrule SIMULATE::blindalley-down
	(declare (salience -5))
	(PLAN::virtual-pos (level ?s) (pos-r ?r) (pos-c ?c) (direction down))
	(PLAN::maxdepth ?d)
	(test (< ?s ?d))
	(not (PLAN::node (level ?s) (action turnleft))) 
	=>
	(assert (PLAN::apply (level ?s) (action turnleft) (pos-r ?r) (pos-c ?c) (dir right) (old-r ?r) (old-c ?c) (old-dir up)))
)

(defrule SIMULATE::blindalley-left
	(declare (salience -5))
	(PLAN::virtual-pos (level ?s) (pos-r ?r) (pos-c ?c) (direction left))
	(PLAN::maxdepth ?d)
	(test (< ?s ?d))
	(not (PLAN::node (level ?s) (action turnleft))) 
	=>
	(assert (PLAN::apply (level ?s) (action turnleft) (pos-r ?r) (pos-c ?c) (dir down) (old-r ?r) (old-c ?c) (old-dir up)))
)

(defrule SIMULATE::blindalley-right
	(declare (salience -5))
	(PLAN::virtual-pos (level ?s) (pos-r ?r) (pos-c ?c) (direction right))
	(PLAN::maxdepth ?d)
	(test (< ?s ?d))
	(not (PLAN::node (level ?s) (action turnleft))) 
	=>
	(assert (PLAN::apply (level ?s) (action turnleft) (pos-r ?r) (pos-c ?c) (dir up) (old-r ?r) (old-c ?c) (old-dir up)))
)


; ---------------- modulo CHECK --------------------

;(defmodule CHECK);(import SIMULATE ?ALL) (export ?ALL))

(defrule CHECK::trace-new-position
    (declare (salience 100))
    (PLAN::current ?s)
    (PLAN::virtual-pos (level ?s) (pos-r ?r) (pos-c ?c) (direction ?dir))
    (not (PLAN::delete (level ?s) (pos-r ?r) (pos-c ?c) (direction ?dir)))
 	=>
    (assert (PLAN::virtual-pos (level (+ ?s 1)) (pos-r ?r) (pos-c ?c) (direction ?dir)))
 )

(defrule CHECK::update-node-ancestor
	(declare (salience 80))
	(not (PLAN::ancestor-index-updated))
	?f <- (PLAN::node-ancestor (level ?) (index ?))
	(PLAN::current ?cur)
	(PLAN::node (level ?l) (action ?) (index ?idx))
	(test (= ?l (- ?cur 1)))
	=>
	(modify ?f (level ?l)(index ?idx))
	(assert (PLAN::ancestor-index-updated))
)

(defrule CHECK::update-todo-ancestor
	(declare (salience 75))
	(not (PLAN::ancestor-todo-updated))
	(PLAN::node-ancestor (index ?ai))
	?f <- (PLAN::node (level ?l))
	(PLAN::current ?l)
	=>
	(modify ?f (ancestor ?ai))
	(assert (PLAN::ancestor-todo-updated))
)

(defrule CHECK::goal-achieved
	(AGENT::exit-position (pos-r ?) (pos-c ?)) 
	?f <-  (PLAN::solution (value no))
	=> 
	(modify ?f (value yes))
	(pop-focus)
)

(defrule CHECK::goal-not-achieved
	(declare (salience 50))
	(PLAN::newstate ?s)
	(AGENT::exit-position (pos-r ?r) (pos-c ?c)) 
	(not (PLAN::virtual-pos (level ?s) (pos-r ?r) (pos-c ?c) (direction ?dir)))
	=>
	(assert (PLAN::task go-on)) 
	(assert (PLAN::ancestor (- ?s 1)))
	(set-current-module NEW) (focus NEW)
)

; ---------------- modulo NEW --------------------

;(defmodule NEW);(import CHECK ?ALL) (export ?ALL))

(defrule NEW::remove-index-updated
	(declare (salience 120))
	?f <- (PLAN::ancestor-index-updated)
	=>
 	(retract ?f)
)

(defrule NEW::remove-todo-updated
	(declare (salience 120))
	?f <- (PLAN::ancestor-todo-updated)
	=>
 	(retract ?f)
)

(defrule NEW::check-ancestor
	(declare (salience 50))
	?f1 <- (PLAN::ancestor ?a) 
	(test (>= ?a 0))
	(PLAN::newstate ?s)
	(PLAN::virtual-pos (level ?s) (pos-r ?r) (pos-c ?c) (direction ?dir))
	(not (PLAN::virtual-pos (level ?a) (pos-r ?r) (pos-c ?c) (direction ?dir)))
	=>
	(assert (PLAN::ancestor (- ?a 1)))
	(retract ?f1)
	(assert (PLAN::diff ?a))
)

(defrule NEW::all-checked
   (declare (salience 25))
   (PLAN::diff 0) 
	?f2 <- (PLAN::newstate ?n)
	?f3 <- (PLAN::task go-on)
	=>
   (retract ?f2)
   (retract ?f3)
   (set-current-module CLEAN) (focus CLEAN)
)

(defrule NEW::already-exist
	?f <- (PLAN::task go-on)
	=> 
	(retract ?f)
	(assert (PLAN::remove newstate))	
	(set-current-module CLEAN) (focus CLEAN)
)

; ---------------- modulo CLEAN --------------------

;(defmodule CLEAN);(import NEW ?ALL))          
       
(defrule CLEAN::erase-delete
(declare (salience 50))
	?f <- (PLAN::delete (level ?))
	=>
	(retract ?f)
)

(defrule CLEAN::erase-diff
(declare (salience 100))
	?f <- (PLAN::diff ?)
	=>
	(retract ?f)
)

(defrule CLEAN::erase-position
(declare (salience 25))
	(PLAN::remove newstate)
	(PLAN::newstate ?n)
	?f <- (PLAN::virtual-pos (level ?n))
	=>
	(retract ?f)
)

(defrule CLEAN::erase-flags
	(declare (salience 10))
	?f1 <- (PLAN::remove newstate)
	?f2 <- (PLAN::newstate ?n)
	=>
	(retract ?f1)
	(retract ?f2)
)

(defrule CLEAN::done
	?f <- (PLAN::current ?x)
	=> 
	(retract ?f)
	(pop-focus)
	(pop-focus)
	(pop-focus)
)

; ---------------------------------------------------------------------------------
;				   FINE MODULO PLAN
; ---------------------------------------------------------------------------------

; ---------------------------------------------------------------------------------
; MODULO AGENT - Componente EXEC-PLAN
; ---------------------------------------------------------------------------------

; Modulo per eseguire il piano realizzato dall'agente
(defrule EXEC-PLAN::execute-step
	(MAIN::status (time ?t))
	(not (MAIN::exec (action ?) (time ?t)))
	?f <- (AGENT::to-do (action ?act))
	=>
	(assert (MAIN::exec (action ?act) (time ?t)))
	(assert (AGENT::move-completed (time ?t)))
	(retract ?f)
	(pop-focus)
)

; OMAR 29/01/2006
; Regole per pulire i flag asseriti in precedenti fasi di pianificazione
;(defrule EXEC-PLAN::erase-position-flag
;	(declare (salience 5))
;	?f <- (PLAN::virtual-pos (level ?))
;	=>
;	(retract ?f)
;)

; flag clock
;(defrule EXEC-PLAN::erase-clock-flags1
;	(declare (salience 5))
;	?f <- (PLAN::clock ?)
;	=>
;	(retract ?f)
;)

;(defrule EXEC-PLAN::erase-clock-flags2
;	(declare (salience 5))
;	?f <- (PLAN::clock-increased)
;	=>
;	(retract ?f)
;)

; flag node
;(defrule EXEC-PLAN::erase-node-flags1
;	(declare (salience 5))
;	?f <- (PLAN::node (level ?))
;	=>
;	(retract ?f)
;)

;(defrule EXEC-PLAN::erase-node-flags2
;	(declare (salience 5))
;	?f <- (PLAN::node-ancestor (level ?))
;	=>
;	(retract ?f)
;)

; flag current
;(defrule EXEC-PLAN::erase-current-flags
;	(declare (salience 5))
;	?f <- (PLAN::current ?)
;	=>
;	(retract ?f)
;)

; flag solution
;(defrule EXEC-PLAN::erase-solution-flags
;	(declare (salience 5))
;	?f <- (PLAN::solution (value ?))
;	=>
;	(retract ?f)
;)

; flag depth
;(defrule EXEC-PLAN::erase-depth-flags1
;	(declare (salience 5))
;	?f <- (PLAN::maxdepth ?)
;	=>
;	(retract ?f)
;)

;(defrule EXEC-PLAN::erase-depth-flags2
;	(declare (salience 5))
;	?f <- (PLAN::maximum-depth ?)
;	=>
;	(retract ?f)
;)

; flags
;(defrule EXEC-PLAN::erase-other-flags1
;	(declare (salience 3))
;	?f <- (PLAN::resolved)
;	=>
;	(retract ?f)
;)

; ---------------------------------------------------------------------------------
;				   FINE MODULO EXEC-PLAN
; ---------------------------------------------------------------------------------

; ---------------------------------------------------------------------------------
;					MAIN EFFETTIVO
; ---------------------------------------------------------------------------------
(defmodule MAIN2)

(defrule MAIN2::createworld 
        (MAIN::create)
        => 
        (pop-focus)
)