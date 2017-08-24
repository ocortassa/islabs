;+----------------------------------------------------------------+
;|      Laboratorio di Sistemi Intelligenti - AA 2005/2006        |
;|						Proff. Torasso & Martelli								|
;|																						|
;|					Progetto Ruby Rescue - parte CLIPS				  		|
;|						Cortassa Omar & Di Caro Luigi				  			|
;+----------------------------------------------------------------+

(defmodule MAIN (export ?ALL))

(deftemplate exec (slot action (allowed-values go turnright turnleft dig grasp))
                  (slot time)
                  (slot marks-a-path (allowed-values yes no))
)

(deftemplate status (slot time) (slot result) )

(deftemplate kpos (slot time) (slot pos-r) (slot pos-c) (slot direction) (slot load))

(deftemplate percepts (slot time)
                      (slot pos-r)
                      (slot pos-c)
                      (slot direction)
                      (slot perc1 (allowed-values empty  wall bump exit entry debris unknown))
                      (slot perc2 (allowed-values empty  wall bump exit entry debris unknown))
	              (slot perc3 (allowed-values empty  wall bump exit entry debris unknown))
                      (slot cry (allowed-values yes no unknown)))

(deftemplate perc-dig (slot time)
                       (slot pos-r)
                       (slot pos-c)
                       (slot person (allowed-values yes no fail)))

(deftemplate perc-grasp (slot time)
                       (slot pos-r)
                       (slot pos-c)
                       (slot person))
                       
(deftemplate exec-path (slot time) 
		       (slot pos-r)
		       (slot pos-c)
		       (slot module)
		       (slot direction)
		       (slot action))

(deftemplate last-position (slot time)
			(slot pos-r)
			(slot pos-c)
			(slot direction))

(deffacts init (create)) 

(defrule createworld 
        (create) => 
        (focus ENV))
      
(defrule go-on-agent
   (declare (salience 20))
	?f1 <- (status (time ?i) (result ?x&~exit))
	=> 
   (focus AGENT)
)

(defrule go-on-env
    (declare (salience 20))
	?f1 <- (status (time ?i))
   (exec (time ?i))
   =>
	(focus ENV)
)
        
(defrule go-on-stop
	(declare (salience 20))
	?f1 <- (status (time ?i) (result exit))
	=>
	(focus STOP)
)


; ---------------------------------------------------------------------------------
; MODULO STOP
; ---------------------------------------------------------------------------------

(defmodule STOP (import MAIN ?ALL)(export ?ALL))

(deftemplate counter (slot value (default 0)))

;AGGIUNTA. Per la stampa del numero di step del tragitto del robot.
;--------------------------------------------------------------
(deftemplate step (slot number))
;--------------------------------------------------------------

(defrule print-agent-path-messagge
	(declare (salience 11))
	(status (result exit))
	(not (print-path-completed))
	=> 
	(printout t crlf "---------------------------------------------------------------" crlf)
	(printout t"Tracciamento del cammino                                  ")
	(printout t crlf "---------------------------------------------------------------" crlf)
	(printout t crlf)
	(assert (print-path))
)

;Dopo la visualizzazione del percorso, il programma termina
(defrule success
	(declare (salience 100))
	(status (result exit))
	(print-path-completed)
	=> 
	(printout t crlf "---------------------------------------------------------------" crlf)
	(halt)
)

; ##---------------- VISUALIZZAZIONE DEL PERCORSO -----------------##
;Stampa il percorso compiuto dal robot

(defrule init-counter
	(status (result exit))
	(not (counter (value ?)))
	=>
	(assert (counter (value 0)))
	; AGGIUNTA: asserisco anche la variabile step, per il conteggio effettivo dei passi.
	;--------------------------------------------------------------
	(assert (step (number 1)))
	;--------------------------------------------------------------
)
	
(defrule inc-counter
	(status (result exit))
	?f <- (counter (value ?v))
	=>
	(modify ?f (value (+ ?v 1)))
)
	

(defrule print-path
	(status (result exit))
	?f <- (counter (value ?v))
	(exec (time ?v) (action ?a) (marks-a-path ?)) 
	?f1 <- (kpos (time ?v) (pos-r ?r) (pos-c ?c) (direction ?d) (load ?))
	;?f1 <- (exec-path (time ?v) (pos-r ?r) (pos-c ?c) (module ?) (direction ?d) (action ?a))
	; AGGIUNTA. Stampa il numero di passo, tramite una variabile step che si incrementa.
	; counter matcha con lo stato time delle exec-path, perciò non è sequenziale e non va bene.
	;--------------------------------------------------------------
	?f2 <- (step (number ?step))
	;--------------------------------------------------------------
	=> 
	;--------------------------------------------------------------
	(printout t "Passo " ?step ": ")
	;--------------------------------------------------------------
	(printout t "Ero in (" ?r "," ?c ") in direzione " ?d ", e ho effettuato un'azione di " ?a crlf)
	(modify ?f2 (number (+ ?step 1)))
	(modify ?f (value (+ ?v 1)))
	(retract ?f1)
)


(defrule print-end
	(status (result exit))
	(not (kpos))
	=>
	(assert (print-path-completed))
)
; ##--------------------------------------------------------------------##



; ---------------------------------------------------------------------------------
; MODULO ENV
; ---------------------------------------------------------------------------------

(defmodule ENV (import MAIN ?ALL)(export ?ALL))

(deftemplate cell (slot pos-r)
                  (slot pos-c)
                  (slot contains (allowed-values empty debris wall entry exit)))



(deftemplate agentstatus (slot time) (slot pos-r) (slot pos-c) (slot direction) 
                          (slot load))

(deftemplate debriscontent (slot pos-r)
                          (slot pos-c)
                          (slot person)
                          (slot digged))
                          
(defrule creation
?f1 <- (create) =>
	(assert
