;+----------------------------------------------------------------+
;|      Laboratorio di Sistemi Intelligenti - AA 2005/2006        |
;|  				Proff. Torasso & Martelli					  |
;|																  |
;|				Progetto Ruby Rescue - parte JESS				  |
;|					Cortassa Omar & Di Caro Luigi				  |
;+----------------------------------------------------------------+


(defmodule ENV)
(defmodule AGENT)
(defmodule STOP)
(defmodule SAVE)
(defmodule EXPLORE)
(defmodule EXIT)
(defmodule UNDO)
(defmodule STANDARD-MOVE)
(defmodule PLAN)
(defmodule SIMULATE)
(defmodule CHECK)
(defmodule NEW)
(defmodule CLEAN)
(defmodule EXEC-PLAN)


(deftemplate MAIN::exec (slot action)
                  (slot time)
                  (slot marks-a-path (default yes))
)

(deftemplate MAIN::status (slot time) (slot result) )

(deftemplate MAIN::percepts (slot time)
                      (slot pos-r)
                      (slot pos-c)
                      (slot direction)
                      (slot perc1)
                      (slot perc2)
	              (slot perc3)
                      (slot cry))

(deftemplate MAIN::perc-dig (slot time)
                       (slot pos-r)
                       (slot pos-c)
                       (slot person))

(deftemplate MAIN::perc-grasp (slot time)
                       (slot pos-r)
                       (slot pos-c)
                       (slot person))
                       
(deftemplate MAIN::exec-path (slot time) 
		       (slot pos-r)
		       (slot pos-c)
		       (slot module)
		       (slot direction)
		       (slot action))

(deftemplate MAIN::last-position (slot time)
			(slot pos-r)
			(slot pos-c)
			(slot direction))

(deffacts MAIN::init (create)) 

(defrule MAIN::createworld
	;(declare (auto-focus TRUE))
	(MAIN::create)
	=>
	(set-current-module ENV) (focus ENV)
)

(defrule MAIN::go-on-agent
	(declare (salience 20))
	?f1 <-  (MAIN::status (time ?i) (result ?x&~exit)) 
	=>
	(set-current-module AGENT) (focus AGENT)
)

(defrule MAIN::go-on-env
	(declare (salience 20))
	?f1 <-  (MAIN::status (time ?i))
	(MAIN::exec (time ?i))
	=>
	(set-current-module ENV) (focus ENV)
)
        
(defrule MAIN::go-on-stop
	(declare (salience 20))
	?f1 <- (MAIN::status (time ?i) (result exit))
	=>
	(set-current-module STOP)(focus STOP)
)


; ---------------------------------------------------------------------------------
; MODULO STOP
; ---------------------------------------------------------------------------------

;AGGIUNTA. Per la stampa del numero di step del tragitto del robot.
;--------------------------------------------------------------
(deftemplate STOP::step (slot number))
;--------------------------------------------------------------

(deftemplate STOP::counter (slot value (default 0)))

(defrule STOP::print-agent-path-messagge
	(declare (salience 101))
	(MAIN::status (result exit))
	(not (STOP::print-path-completed))
	=> 
	(printout t crlf "---------------------------------------------------------------" crlf)
	(printout t"Tracciamento del cammino                                  ")
	(printout t crlf "---------------------------------------------------------------" crlf)
	(printout t crlf)
	(assert (STOP::print-path))
)

(defrule STOP::success
	(declare (salience 100))
	(MAIN::status (result exit))
	(STOP::print-path-completed)
	=> 
	(printout t crlf "---------------------------------------------------------------" crlf)
	(halt)
)


; ##---------------- VISUALIZZAZIONE DEL PERCORSO -----------------##

;Stampa il percorso compiuto dal robot
(defrule STOP::init-counter
	(MAIN::status (result exit))
	(not (STOP::counter (value ?)))
	=>
	(assert (STOP::counter (value 0)))
	; AGGIUNTA: asserisco anche la variabile step, per il conteggio effettivo dei passi.
	;--------------------------------------------------------------
	(assert (STOP::step (number 1)))
	;--------------------------------------------------------------
)
	
(defrule STOP::inc-counter
	(MAIN::status (result exit))
	?f <- (STOP::counter (value ?v))
	=>
	(modify ?f (value (+ ?v 1)))
	(set-current-module MAIN) (focus MAIN)
)
	

(defrule STOP::print-path
	(MAIN::status (result exit))
	?f <- (STOP::counter (value ?v))
	(MAIN::exec (time ?v) (action ?a) (marks-a-path yes)) 
	?f1 <- (MAIN::exec-path (time ?v) (pos-r ?r) (pos-c ?c) (module ?) (direction ?d) (action ?a))
	; AGGIUNTA. Stampa il numero di passo, tramite una variabile step che si incrementa.
	; counter matcha con lo stato time delle exec-path, perciò non è sequenziale e non va bene.
	;--------------------------------------------------------------
	?f2 <- (STOP::step (number ?step))
	;--------------------------------------------------------------
	=> 
	;--------------------------------------------------------------
	(printout t "Passo " ?step ": ")
	;--------------------------------------------------------------
	(printout t "Ero in (" ?r "," ?c ") in direzione " ?d ", e ho effettuato un'azione di " ?a crlf)
	(store stepOk print)
	;(store finish ok)
	(store step-counter ?v)
	(store step-r ?r)
	(store step-c ?c)
	(store step-d ?d)
	(store step-a ?a)
	(modify ?f2 (number (+ ?step 1)))
	(modify ?f (value (+ ?v 1)))
	(retract ?f1)
	(set-current-module MAIN) (focus MAIN)
)


(defrule STOP::print-end
	(MAIN::status (result exit))
	(not (MAIN::exec-path (time ?) (pos-r ?) (pos-c ?) (module ?) (direction ?) (action ?)))
	=>
	(assert (STOP::print-path-completed))
	(store finish ok)
	(store stop ok)
	(set-current-module MAIN) (focus MAIN)
)
; ##--------------------------------------------------------------------##



; INIZIA QUI VIRTUALMENTE IL MODULO ENV
(deftemplate ENV::cell (slot pos-r)
                  	(slot pos-c)
                  	(slot contains (default empty)))



(deftemplate ENV::agentstatus (slot time) (slot pos-r) (slot pos-c) (slot direction) 
                          (slot load))

(deftemplate ENV::debriscontent (slot pos-r)
                          (slot pos-c)
                          (slot person)
                          (slot digged))
 

                         
(defrule ENV::creation
?f1 <- (create) =>
     (assert