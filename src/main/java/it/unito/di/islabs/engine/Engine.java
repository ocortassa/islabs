package it.unito.di.islabs.engine;

import it.unito.di.islabs.model.RubyState;
import it.unito.di.islabs.ui.RubyRescueWorldExecution;
import jess.JessException;
import jess.Rete;
import jess.Value;

import java.io.File;
import java.util.Iterator;

public class Engine extends Thread {
    private static boolean halt;
    private static String command;
    private static boolean classFirstLoading;
    private static Rete rete;
    //private static Rete reteDebug;
    private static boolean first;
    private static String old_rValueS = "";
    private static String old_cValueS = "";
    private static String old_dValueS = "";

    private String rValueS = "";
    private String cValueS = "";
    private String dValueS = "";
    private RubyRescueWorldExecution monitor;
    private String action = "null";
    private boolean ok = true;
    private int count;

    static {
        classFirstLoading = true;
        first = true;
        halt = false;
    }


    /**/
    public Engine(RubyRescueWorldExecution m, String a) {
        action = a;

        if (m == null) {
            first = true;
            halt = false;
            old_rValueS = "";
            old_cValueS = "";
            old_dValueS = "";
            ok = false;
        } else {
            monitor = m;
            if (classFirstLoading) {
                //String modifiedPath = analysePath(m.getSourcePath());
                String fileName = getClass().getResource("/rules/Ruby.clp").getPath();
                command = "(batch \"" + fileName + "\")";
                rete = new Rete();
                classFirstLoading = false;
            }
            if (first) {
                clearLoadReset();
                first = false;
            }
            start();
        }
    }


    public void clearLoadReset() {
        try {
            rete.clear();
            rete.executeCommand(command);
            rete.reset();
        } catch (JessException e) {
            System.out.println("Errore nel caricamento del file jess: " + e.getMessage());
            e.printStackTrace();
        }
    }

    public void runOnce() {
        try {
            rete.run(1);
            Iterator activations = rete.listActivations();
            Iterator facts = rete.listFacts();
            monitor.setFacts(facts);
            monitor.setActivations(activations);
        } catch (Exception ero) {
            System.out.println("Errore in runOnce di Engine: " + ero.getMessage());
        }
    }

    public void runStep() {
        int temp = 0;
        try {
            /* Esecuzione di passi finche' Ruby non decide la mossa */
            boolean again = true;
            Value okValue = null;
            String kind = "";
            while (again) {
                rete.run(1);
                monitor.IncrCounterMatching();
				/*Se s� � eseguito un passo logico, ci si ferma */

                // Planning
                Value pValue = rete.fetch("planning");
                Value depthValue = null;
                if (pValue != null) {
                    String planning = (pValue).toString();
                    pValue = null;
                    if (planning.equals("start")) {
                        monitor.startPlanning();
                        // planning all'inizio vale "start". Alla fine "end".

                        boolean planComputed = false;

                        while (!(planComputed)) {
                            rete.run(3); // si cicla --> la var. planning vale "start".
                            depthValue = rete.fetch("planningDepth");
                            if (depthValue != null)
                                monitor.setPlanningDepth(depthValue.toString());

                            pValue = rete.fetch("planning");
                            if (pValue != null) {
                                if ((pValue.toString()).equals("end")) {
                                    planComputed = true;
                                }
                            }
                        }

                        monitor.stopPlanning();
                        rete.clearStorage();
                        pValue = null; // per uscire dal ciclo.
                    }
                }

                okValue = rete.fetch("stepOk");
                if (okValue != null) {
                    if (temp == 0) {
                        monitor.IncrCounterStep();
                        temp++;
                    }

                    kind = okValue.toString();
                    if (kind.equals("trace")) {
                        rValueS = (rete.fetch("pos-r")).toString();
                        cValueS = (rete.fetch("pos-c")).toString();
                        dValueS = (rete.fetch("direction")).toString();
                        again = ((rValueS.equals(old_rValueS)) && (cValueS.equals(old_cValueS)) && (dValueS.equals(old_dValueS)));
						/* Con questo metodo, elimino ripetizioni di situazioni. */
						/* Memorizzo i parametri per le future posizioni. Serve solo per la grafica.*/
                        old_rValueS = rValueS;
                        old_cValueS = cValueS;
                        old_dValueS = dValueS;
                    } else {
                        again = false;
                    }
                }
            }


            if (kind.equals("trace")) {
				/*Fetch dei parametri sul mondo e memorizzazione*/
                RubyState rubyState = new RubyState();
                Value rValue = rete.fetch("pos-r");
                Value cValue = rete.fetch("pos-c");
                Value dValue = rete.fetch("direction");
                Value lValue = rete.fetch("loaded");
                Value counterValue = rete.fetch("counter");
                // 21/01/2006
                Value urValue = rete.fetch("unusefulCellR");
                Value ucValue = rete.fetch("unusefulCellC");

                if ((urValue != null) && (ucValue != null)) {
                    String urString = (urValue).toString();
                    String ucString = (ucValue).toString();

                    int ur = Integer.parseInt(urString);
                    int uc = Integer.parseInt(ucString);

                    rubyState.addUnusefulCell(ur, uc);
                }

                if ((rValue != null) && (cValue != null)) {
                    String rString = (rValue).toString();
                    String cString = (cValue).toString();

                    int r = Integer.parseInt(rString);
                    int c = Integer.parseInt(cString);

                    rubyState.setPosition(r, c);
                }
                if (counterValue != null) {
                    String counterString = (counterValue).toString();
                    int counter = Integer.parseInt(counterString);
                    rubyState.setVisited(counter);
                }
                if (lValue != null) {
                    String loadedString = (lValue).toString();
                    boolean loaded;
                    if (loadedString.equals("no"))
                        loaded = false;
                    else loaded = true;
                    rubyState.setLoaded(loaded);
                }
                if (dValue != null) {
                    String direction = (dValue).toString();
                    rubyState.setDirection(direction);
                }


				/*Pulizia delle memorizzazioni*/
                rete.clearStorage();

				/*Settaggio della nuova mappa*/
                monitor.setMap(rubyState); // L'ultimo giro rubyState � vuoto...

                try {
                    Thread.sleep(monitor.getStepTime());
                } catch (Exception exc) {
                    System.out.println("Errore in ENGINE");
                }
            } else {
                // Si stampa il percorso tutto insieme!
                boolean again2 = true;
                count = 0;

                monitor.rubyToExit();
				/*while (again2)
				{
					rete.run(1);
					Value finishValue = rete.fetch("finish");
					if (finishValue == null)
					{
						Value rValue = rete.fetch("step-r");
						if (rValue != null)
						{
							Value cValue = rete.fetch("step-c");
							Value dValue = rete.fetch("step-d");
							Value aValue = rete.fetch("step-a");
							String r = (rValue).toString();
							String c = (cValue).toString();
							String d = (dValue).toString();
							String a = (aValue).toString();
							if (count == 0)
							{
								monitor.setBoard("TRACCIAMENTO DEL CAMMINO\n", true);

							}
							monitor.setBoard("Ero in ("  + r +  ", " + c + ") in direzione "+ d +", e ho effettuato un'azione di "+ a);

						}
						rete.clearStorage();
						count++;
					}
					else
					{
						again2 = false;
						halt = true;
					}
				}*/
            }
        } catch (Exception e) {
            System.out.println("Errore in Engine runStep: " + e.getMessage());
        }
    }


    /**
     * Questo metodo tratta tutte le possibili azioni sul motore Jess.
     */
    public void run() {
        while (ok) {
            try {

                if (action.equals("run")) {
                    if (!(halt)) {
                        runStep();
                    } else {
                        halt = false;
                        ok = false;
                    }
                } else if (action.equals("stop")) {
                    halt = true;
                    ok = false;
                } else if (action.equals("reset")) {
                    rete.clearStorage();
                    clearLoadReset();
                    monitor.setMap(null);
                    monitor.setBoard("Reset eseguita");
                    ok = false;
                } else if (action.equals("runStep")) {
                    runStep();
                    ok = false;
                } else if (action.equals("runOnce")) {
                    runOnce();
                    ok = false;
                } else if (action.equals("changeWorld")) {
                    first = true;
                    halt = false;
                    old_rValueS = "";
                    old_cValueS = "";
                    old_dValueS = "";
                    ok = false;
                } else {// � un comando da eseguire
                    try {
                        rete.executeCommand(action);
                        monitor.setConsolePanel();
                        monitor.setBoard("Comando accettato: " + action);
                    } catch (Exception e) {
                        System.out.println("comando non accettato");
                        monitor.setBoard("Comando non accettato: " + action);
                    }
                    ok = false;
                }
            } catch (Exception eee) {
                eee.printStackTrace();
            }
        }//while

    }
	/**/

    public String analysePath(String p) {
        //Duplicazione spazi vuoti
        //String temp = "";
        String[] dir = p.split(" ");
        StringBuilder noSpace = new StringBuilder("");
        for (int i = 0; i < dir.length; i++) {
            if (i != (dir.length - 1)) {
                noSpace.append( dir[i] ).append(" ");
            } else {
                noSpace.append(dir[i]);
            }
        }

        //Duplicazione \
        String s = File.separator;
        dir = noSpace.toString().split("\\\\");
        StringBuilder dupli = new StringBuilder("");
        for (int i = 0; i < dir.length; i++) {
            dupli.append( dir[i] ).append(s).append(s);
        }
        return dupli.toString();
    }
}