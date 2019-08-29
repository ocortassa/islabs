package it.unito.di.islabs.ui;

import java.awt.*;
import java.awt.event.*;
import javax.swing.*;
import java.io.*;
import java.util.*;

import it.unito.di.islabs.engine.Engine;
import it.unito.di.islabs.engine.RegisterThread;
import jess.*;
import it.unito.di.islabs.model.Cell;
import it.unito.di.islabs.model.RubyState;

/**
 * Classe GUI per l'esecuzione del mondo di Ruby. Fornisce delle funzioni specifiche di
 * CLIPS come "RESET", "RUN", "RUN 1", e permette di visualizzare eventuali messaggi di Ruby.
 */

public class RubyRescueWorldExecution extends JFrame implements ActionListener, WindowListener, MouseListener, ComponentListener {
    /**
     * --- Delay dell'esecuzione della go ---
     */
    //public final String MAP_PATH = getClass().getResource("/maps").getPath();
    public static final String MAP_PATH = System.getProperty("user.home") + "/.islabs/";
    private static final int FACTOR = 100;
    private static final int MAX_DEPTH_PLANNING = 10; // sul codice JESS significa 12

    /**
     * --- Percorsi relativi per le immagini da caricare ---
     */
    private String IMAGE_WALL = "/image/Wall.gif";
    private String IMAGE_EXIT = "/image/Exit.gif";
    private String IMAGE_ENTRY = "/image/Entry.gif";
    private String DEBRIS_NO = "/image/DebrisNo.gif";
    private String DEBRIS_YES = "/image/DebrisYes.gif";
    private String VOID = "/image/Null.gif";
    private String RUBY_UP = "/image/RobotUP.gif";
    private String RUBY_DOWN = "/image/RobotDOWN.gif";
    private String RUBY_LEFT = "/image/RobotLEFT.gif";
    private String RUBY_RIGHT = "/image/RobotRIGHT.gif";
    private String RUBY_UP_ENTRY = "/image/RobotUP_Entry.gif";
    private String RUBY_DOWN_ENTRY = "/image/RobotDOWN_Entry.gif";
    private String RUBY_LEFT_ENTRY = "/image/RobotLEFT_Entry.gif";
    private String RUBY_RIGHT_ENTRY = "/image/RobotRIGHT_Entry.gif";
    private String RUBY_UP_DEBRIS_NO = "/image/RobotDebrisNoUP.gif";
    private String RUBY_RIGHT_DEBRIS_NO = "/image/RobotDebrisNoRIGHT.gif";
    private String RUBY_DOWN_DEBRIS_NO = "/image/RobotDebrisNoDOWN.gif";
    private String RUBY_LEFT_DEBRIS_NO = "/image/RobotDebrisNoLEFT.gif";
    private String RUBY_UP_DEBRIS_YES = "/image/RobotDebrisYesUP.gif";
    private String RUBY_RIGHT_DEBRIS_YES = "/image/RobotDebrisYesRIGHT.gif";
    private String RUBY_DOWN_DEBRIS_YES = "/image/RobotDebrisYesDOWN.gif";
    private String RUBY_LEFT_DEBRIS_YES = "/image/RobotDebrisYesLEFT.gif";
    private String RUBY_STEP = "/image/RobotStep.gif";
    private String DEBRIS_NO_SEEN = "/image/DebrisNoSeen.gif";
    private String RUBY_VIEW = "/image/RubyView.gif";
    private String RUBY_VIEW_DEBRIS_NO = "/image/RubyViewDebrisNo.gif";
    private String RUBY_VIEW_DEBRIS_YES = "/image/RubyViewDebrisYes.gif";
    private String RESET = "/image/reset.gif";
    private String GO = "/image/go.gif";
    private String GO_STEP = "/image/gostep.gif";
    private String CHANGE = "/image/change.gif";
    private String SAVE = "/image/save.gif";
    private String PROMPT = "/image/prompt.gif";
    private String VERIFY = "/image/verify.gif";
    private String STOP = "/image/stop.gif";
    private String EXIT_PROGRAM = "/image/exitProgram.gif";
    private String DEBRIS_YES_VIEWED = "/image/DebrisYesViewed.gif";
    private String USELESS_CELL = "/image/nousefulCell.gif";

    /**
     * --- Icone dell'interfaccia ---
     */
    public Icon iconWall, iconExit, iconEntry, iconDebrisNo, iconDebrisYes, iconNull;
    private Icon iconRubyUP, iconRubyDOWN, iconRubyLEFT, iconRubyRIGHT;
    private Icon iconRubyUPEntry, iconRubyDOWNEntry, iconRubyLEFTEntry, iconRubyRIGHTEntry;
    private Icon iconRubyRIGHTDebrisYes, iconRubyLEFTDebrisYes, iconRubyDOWNDebrisYes, iconRubyUPDebrisYes;
    private Icon iconRubyRIGHTDebrisNo, iconRubyLEFTDebrisNo, iconRubyDOWNDebrisNo, iconRubyUPDebrisNo;
    private Icon iconRubyStep, iconDebrisNoSeen, iconRubyView, iconRubyViewDebrisNo, iconRubyViewDebrisYes;
    private Icon iconExitProgram;
    private Icon iconReset, iconChange, iconSave, iconPrompt, iconGo, iconGoStep, iconVerify, iconStop;
    private Icon iconDebrisYesViewed, iconUnusefulCell;

    /**
     * --- Celle costituenti il mondo in esecuzione (celle correnti, celle di backup) ---
     */
    private JLabel[][] cells, scells;

    /**
     * Per la gestione del dopo-salvataggio del superstite nella mappa
     */
    int personLoadedR;
    int personLoadedC;

    /**
     * --- Mappa delle celle visitate ---
     */
    private boolean[][] visitedCells;

    /**
     * --- Istanze varie relative all'interfaccia grafica ---
     */
    private int nr, nc;
    private JTextArea messageBoard;
    private String lastCommand;
    private Engine engine;
    private String sourcePath;
    private JButton goButton, stopButton, goStepButton, changeButton, verifyButton, resetButton;
    private int entry_r, entry_c;
    private JSpinner spinner;
    private JScrollPane scrollPane, scrollPaneFacts, scrollPaneActivations;
    private JPanel messagePanel;
    private JLabel counterStepMonitor, counterActivationMonitor, counterCellsVisitedMonitor;
    private int counterMatchingStep = 0;
    private int counterStep = 0;
    private int counterCellsPossible = 0;
    private int counterCellsVisited = 0;
    private int counterDebris = 0;
    private int counterSurvivor = 0;
    private JButton newFrameButton;
    private Viewer viewer;
    private ConsolePanel consolePanel;
    private JTextArea areaLog, areaFacts, areaActivations;
    private JScrollPane scrollAreaLog;
    private JPanel centerPanel;
    private boolean personLoaded = false;
    private int h, w;
    private JFrame planningFrame;
    private JProgressBar plaBar = null;

    /**
     * Costruttore
     *
     * @param cellsButton Le celle della mappa
     */
    public RubyRescueWorldExecution(JButton[][] cellsButton, String titleFrame) {
        super("Ruby-Rescue World Execution  (Versione motore Jess: 7.0 beta) - " + titleFrame);
        //System.gc(); // Richiamo forzato del garbage collector
        /*---------------- Inizializzazione ----------------------*/

        nc = cellsButton[0].length;
        nr = cellsButton.length;
        cells = new JLabel[nr][nc];
        sourcePath = (new File("")).getAbsolutePath();
        visitedCells = new boolean[nr][nc];
        this.addWindowListener(this);
        counterStep = 0;
		/*--------------------------------------------------------*/

		/*------------ Per la location della finestra ------------*/
        Toolkit kit = Toolkit.getDefaultToolkit();
        Dimension dim = kit.getScreenSize();
        h = dim.height;
        w = dim.width;
        setSize(w, h);
        setLocation(0, 0);

		/*--------------------------------------------------------*/

		/*------------- Costruzione interfaccia --------------------*/
        Container container = getContentPane();
        JPanel grid = new JPanel();
        JPanel gridNumbered = new JPanel();
        gridNumbered.setLayout(new BorderLayout());
        JPanel numberedPanelH = new JPanel();
        numberedPanelH.setLayout(new GridLayout(1, nc));
        for (int i = 0; i < nc; i++)
            numberedPanelH.add(new JLabel("" + i, JLabel.CENTER));
        JPanel numberedPanelV = new JPanel();
        numberedPanelV.setLayout(new GridLayout(nr, 1));
        for (int i = 0; i < nr; i++)
            numberedPanelV.add(new JLabel("" + i));
        gridNumbered.add(BorderLayout.NORTH, numberedPanelH);
        gridNumbered.add(BorderLayout.WEST, numberedPanelV);
        grid.setLayout(new GridLayout(nr, nc));
        gridNumbered.setBorder(BorderFactory.createTitledBorder(BorderFactory.createCompoundBorder(BorderFactory.createLineBorder(Color.WHITE), BorderFactory.createRaisedBevelBorder()), "Mappa"));

		/*---------------- Caricamento delle icone ----------------------*/
        //Icone della mappa.
        iconWall = ResourceLoader.loadImageIcon(getClass(), IMAGE_WALL, "wall");
        iconEntry = ResourceLoader.loadImageIcon(getClass(), IMAGE_ENTRY, "entry");
        iconExit = ResourceLoader.loadImageIcon(getClass(), IMAGE_EXIT, "exit");
        iconDebrisNo = ResourceLoader.loadImageIcon(getClass(), DEBRIS_NO, "debris");
        iconDebrisNoSeen = ResourceLoader.loadImageIcon(getClass(), DEBRIS_NO_SEEN, "debrisNoSeen");
        iconDebrisYes = ResourceLoader.loadImageIcon(getClass(), DEBRIS_YES, "debrisYes");
        iconNull = ResourceLoader.loadImageIcon(getClass(), VOID, "empty");
        //Icone di Ruby sulle entrate.
        iconRubyUPEntry = ResourceLoader.loadImageIcon(getClass(), RUBY_UP_ENTRY, "RubyUPEntry");
        iconRubyDOWNEntry = ResourceLoader.loadImageIcon(getClass(), RUBY_DOWN_ENTRY, "RubyDOWNEntry");
        iconRubyLEFTEntry = ResourceLoader.loadImageIcon(getClass(), RUBY_LEFT_ENTRY, "RubyLEFTEntry");
        iconRubyRIGHTEntry = ResourceLoader.loadImageIcon(getClass(), RUBY_RIGHT_ENTRY, "RubyRIGHTEntry");
        //Icone di Ruby sul passaggio vuoto.
        iconRubyDOWN = ResourceLoader.loadImageIcon(getClass(), RUBY_DOWN, "RubyDOWN");
        iconRubyLEFT = ResourceLoader.loadImageIcon(getClass(), RUBY_LEFT, "RubyLEFT");
        iconRubyUP = ResourceLoader.loadImageIcon(getClass(), RUBY_UP, "RubyUP");
        iconRubyRIGHT = ResourceLoader.loadImageIcon(getClass(), RUBY_RIGHT, "RubyRIGHT");
        //Icone di Ruby sulle macerie senza persona.
        iconRubyRIGHTDebrisNo = ResourceLoader.loadImageIcon(getClass(), RUBY_RIGHT_DEBRIS_NO, "RubyRIGHTDebrisNo");
        iconRubyUPDebrisNo = ResourceLoader.loadImageIcon(getClass(), RUBY_UP_DEBRIS_NO, "RubyUPDebrisNo");
        iconRubyDOWNDebrisNo = ResourceLoader.loadImageIcon(getClass(), RUBY_DOWN_DEBRIS_NO, "RubyDOWNDebrisNo");
        iconRubyLEFTDebrisNo = ResourceLoader.loadImageIcon(getClass(), RUBY_LEFT_DEBRIS_NO, "RubyLEFTDebrisNo");
        //Icone di Ruby sulle macerie con persona.
        iconRubyRIGHTDebrisYes = ResourceLoader.loadImageIcon(getClass(), RUBY_RIGHT_DEBRIS_YES, "RubyRIGHTDebrisYes");
        iconRubyUPDebrisYes = ResourceLoader.loadImageIcon(getClass(), RUBY_UP_DEBRIS_YES, "RubyUPDebrisYes");
        iconRubyDOWNDebrisYes = ResourceLoader.loadImageIcon(getClass(), RUBY_DOWN_DEBRIS_YES, "RubyDOWNDebrisYes");
        iconRubyLEFTDebrisYes = ResourceLoader.loadImageIcon(getClass(), RUBY_LEFT_DEBRIS_YES, "RubyLEFTDebrisYes");
        iconDebrisYesViewed = ResourceLoader.loadImageIcon(getClass(), DEBRIS_YES_VIEWED, "DebrisYesViewed");
        //Icona del passaggio vuoto.
        iconRubyStep = ResourceLoader.loadImageIcon(getClass(), RUBY_STEP, "RubyStep");
        //Icone per i bottoni
        iconReset = ResourceLoader.loadImageIcon(getClass(), RESET);
        iconExitProgram = ResourceLoader.loadImageIcon(getClass(), EXIT_PROGRAM);
        iconGo = ResourceLoader.loadImageIcon(getClass(), GO);
        iconGoStep = ResourceLoader.loadImageIcon(getClass(), GO_STEP);
        iconStop = ResourceLoader.loadImageIcon(getClass(), STOP);
        iconVerify = ResourceLoader.loadImageIcon(getClass(), VERIFY);
        iconChange = ResourceLoader.loadImageIcon(getClass(), CHANGE);
        iconPrompt = ResourceLoader.loadImageIcon(getClass(), PROMPT);
        iconSave = ResourceLoader.loadImageIcon(getClass(), SAVE);
        //Icone per la vista di Ruby
        iconRubyView = ResourceLoader.loadImageIcon(getClass(), RUBY_VIEW, "empty");
        iconRubyViewDebrisNo = ResourceLoader.loadImageIcon(getClass(), RUBY_VIEW_DEBRIS_NO, "debris");
        iconRubyViewDebrisYes = ResourceLoader.loadImageIcon(getClass(), RUBY_VIEW_DEBRIS_YES, "debrisYes");
        // Cella inutile per Ruby
        iconUnusefulCell = ResourceLoader.loadImageIcon(getClass(), USELESS_CELL);

		/*-------- Impostazione dinamica dell'icona di Ruby all'entrata --------*/
        JLabel b = null;
        for (int i = 0; i < nr; i++)
            for (int j = 0; j < nc; j++) {
                ImageIcon icon = (ImageIcon) (cellsButton[i][j].getIcon());
                String iconDesc = icon.getDescription();

                if (iconDesc.equals("debris"))
                    counterDebris++;

                if (iconDesc.equals("debrisYes"))
                    counterSurvivor++;

                if ((iconDesc.equals("debris")) || (iconDesc.equals("debrisYes")) || (iconDesc.equals("empty")) || (iconDesc.equals("IMAGE_ENTRY")))
                    counterCellsPossible++;

                if (iconDesc.equals("IMAGE_ENTRY")) {
                    if (i == 0) {
                        b = new JLabel(iconRubyDOWNEntry);
                        entry_r = i;
                        entry_c = j;
                    }
                    if (j == 0) {
                        b = new JLabel(iconRubyRIGHTEntry);
                        entry_r = i;
                        entry_c = j;
                    }

                    if (i == (nr - 1)) {
                        b = new JLabel(iconRubyUPEntry);
                        entry_r = i;
                        entry_c = j;
                    }

                    if (j == (nc - 1)) {
                        b = new JLabel(iconRubyLEFTEntry);
                        entry_r = i;
                        entry_c = j;
                    }
                } else {
                    b = new JLabel(icon);
                }
                b.setToolTipText("(" + i + ", " + j + ") - " + iconDesc);
                cells[i][j] = b;
                visitedCells[i][j] = false;
                grid.add(b);
            }
        gridNumbered.add(BorderLayout.CENTER, grid);
		/*-------------------------------------------------------------------------*/

		/* Comando per memorizzare la mappa iniziale */
        storeCells();

		/*----------- Proseguimento della costruzione dell'interfaccia ------------*/
        JPanel total = new JPanel();
        total.setLayout(new BorderLayout());
        total.setBorder(BorderFactory.createCompoundBorder(BorderFactory.createLineBorder(Color.WHITE), BorderFactory.createEmptyBorder(18, 18, 18, 18)));
        JPanel controlPanel = new JPanel();
        controlPanel.setLayout(new BorderLayout());
        JPanel worldPanel = new JPanel();
        worldPanel.setBorder(BorderFactory.createTitledBorder(BorderFactory.createCompoundBorder(BorderFactory.createLineBorder(Color.WHITE), BorderFactory.createRaisedBevelBorder()), "World"));
        worldPanel.setLayout(new GridLayout(3, 1));
        resetButton = new JButton("Reset    ", iconReset);
        resetButton.setToolTipText("Esegue una reset del mondo, portando allo stato iniziale");
        changeButton = new JButton("Prompt Jess                    ", iconPrompt);
        changeButton.setToolTipText("Prompt dal quale si interagisce direttamente col motore JESS");
        JButton saveButton = new JButton("Salva questo mondo      ", iconSave);
        saveButton.setToolTipText("Salva il mondo corrente, per poterlo successivamente importare");
        saveButton.addActionListener(this);
        JButton changeWorld = new JButton("Cambia mondo                ", iconChange);
        changeWorld.setToolTipText("Cambia il mondo corrente");
        changeButton.addActionListener(this);
        resetButton.addActionListener(this);
        changeWorld.addActionListener(this);
        worldPanel.add(changeWorld);
        worldPanel.add(saveButton);
        JButton exitButton = new JButton("Esci                                     ", iconExitProgram);
        exitButton.addActionListener(this);
        worldPanel.add(exitButton);
        JPanel execPanel = new JPanel();
        execPanel.setLayout(new GridLayout(2, 1));
        execPanel.setBorder(BorderFactory.createTitledBorder(BorderFactory.createCompoundBorder(BorderFactory.createLineBorder(Color.WHITE), BorderFactory.createRaisedBevelBorder()), "Esecuzione"));
        verifyButton = new JButton("Verify", iconVerify);
        verifyButton.setEnabled(false);
        verifyButton.setToolTipText("Verifica se Ruby riuscira' o meno nel suo intento");
        goStepButton = new JButton("Go Step", iconGoStep);
        goStepButton.setEnabled(false);
        JPanel goStepButtonPanel = new JPanel();
        goStepButtonPanel.setLayout(new GridLayout(1, 2));
        goStepButtonPanel.add(goStepButton);
        goStepButtonPanel.add(resetButton);
        goStepButton.setToolTipText("Esegue un passo di Ruby");
        goButton = new JButton("Go          ", iconGo);
        goButton.setToolTipText("Esegue i passi di Ruby con un determinato delay");
        goButton.setEnabled(false);
        JPanel goButtonPanel = new JPanel();
        goButtonPanel.setLayout(new GridLayout(2, 1));
        goButtonPanel.add(goButton);
        SpinnerNumberModel spinnerTime = new SpinnerNumberModel(1, 0, 10, 1);
        spinner = new JSpinner(spinnerTime);
        JPanel spinnerPanel = new JPanel();
        spinnerPanel.setLayout(new GridLayout(1, 2));
        spinnerPanel.add(new JLabel("1/10 sec"));
        spinnerPanel.add(spinner);
        goButtonPanel.add(spinnerPanel);
        stopButton = new JButton("Stop", iconStop);
        stopButton.setToolTipText("Ferma l'esecuzione della go");
        stopButton.setEnabled(false);
        goStepButton.addActionListener(this);
        goButton.addActionListener(this);
        verifyButton.addActionListener(this);
        stopButton.addActionListener(this);
        execPanel.add(goStepButtonPanel);
        JPanel goStopPanel = new JPanel();
        goStopPanel.setLayout(new GridLayout(1, 2));
        goStopPanel.add(goButtonPanel);
        goStopPanel.add(stopButton);
        execPanel.add(goStopPanel);
        messagePanel = new JPanel();
        messagePanel.setLayout(new BorderLayout());
        messagePanel.setBorder(BorderFactory.createTitledBorder(BorderFactory.createCompoundBorder(BorderFactory.createLineBorder(Color.WHITE), BorderFactory.createRaisedBevelBorder()), "MessaggeBoard"));
        messageBoard = new JTextArea();
        messageBoard.addMouseListener(this);
        Font font = new Font("boardFont", Font.BOLD, 12);
        messageBoard.setFont(font);
        messageBoard.setBackground(Color.WHITE);
        messageBoard.setForeground(Color.BLACK);
        messageBoard.setEnabled(false);
        scrollPane = new JScrollPane(messageBoard, ScrollPaneConstants.VERTICAL_SCROLLBAR_AS_NEEDED, ScrollPaneConstants.HORIZONTAL_SCROLLBAR_AS_NEEDED);
        JPanel panelCounter = new JPanel();
        panelCounter.setLayout(new GridLayout(3, 2));
        panelCounter.setBorder(BorderFactory.createTitledBorder(BorderFactory.createCompoundBorder(BorderFactory.createLineBorder(Color.WHITE), BorderFactory.createRaisedBevelBorder()), ""));
        JLabel counterCellsPossibleMonitor = new JLabel("Celle totali visitabili: " + counterCellsPossible, SwingConstants.CENTER);
        panelCounter.add(counterCellsPossibleMonitor);
        counterCellsVisitedMonitor = new JLabel("Celle totali visitate: " + counterCellsVisited, SwingConstants.CENTER);
        panelCounter.add(counterCellsVisitedMonitor);
        JLabel counterCellsDebrisMonitor = new JLabel("Macerie totali: " + counterDebris, SwingConstants.CENTER);
        panelCounter.add(counterCellsDebrisMonitor);
        JLabel counterCellsSurvivorMonitor = new JLabel("Superstiti totali: " + counterSurvivor, SwingConstants.CENTER);
        panelCounter.add(counterCellsSurvivorMonitor);
        counterStepMonitor = new JLabel("Step numero 0", SwingConstants.CENTER);
        panelCounter.add(counterStepMonitor);
        counterActivationMonitor = new JLabel("Activations 0", SwingConstants.CENTER);
        panelCounter.add(counterActivationMonitor);
        messagePanel.add(BorderLayout.NORTH, panelCounter);
        messagePanel.add(BorderLayout.CENTER, scrollPane);
        newFrameButton = new JButton("Apri in un'altra finestra");
        newFrameButton.addActionListener(this);
        newFrameButton.setEnabled(false);
        JPanel panelMessageBoard = new JPanel();
        panelMessageBoard.setLayout(new GridLayout(1, 1));
        panelMessageBoard.add(newFrameButton);
        messagePanel.add(BorderLayout.SOUTH, panelMessageBoard);
        controlPanel.add(BorderLayout.NORTH, worldPanel);
        controlPanel.add(BorderLayout.SOUTH, execPanel);
        controlPanel.add(BorderLayout.CENTER, messagePanel);
        JPanel exitPanel = new JPanel();
        JPanel totalWithExit = new JPanel();
        totalWithExit.setLayout(new BorderLayout());
        controlPanel.setMinimumSize(new Dimension(150 * h / 1024, 100 * h / 768));
        gridNumbered.setMinimumSize(new Dimension(150 * h / 1024, 100 * h / 768));
        controlPanel.setPreferredSize(new Dimension(100 * h / 1024, 100 * h / 768));
        gridNumbered.setPreferredSize(new Dimension(750 * h / 1024, 800 * h / 768));
        JTabbedPane tabPane = new JTabbedPane();
        JPanel debugPanel = new JPanel();
        debugPanel.setLayout(new BorderLayout());
        JPanel factsPanel = new JPanel();
        factsPanel.setLayout(new BorderLayout());
        factsPanel.setBorder(BorderFactory.createTitledBorder(
                BorderFactory.createCompoundBorder(
                        BorderFactory.createLineBorder(Color.WHITE),
                        BorderFactory.createRaisedBevelBorder()), "Facts"));
        areaFacts = new JTextArea();
        scrollPaneFacts = new JScrollPane(areaFacts,
                ScrollPaneConstants.VERTICAL_SCROLLBAR_AS_NEEDED,
                ScrollPaneConstants.HORIZONTAL_SCROLLBAR_AS_NEEDED);
        JViewport vp2 = scrollPaneFacts.getViewport();
        vp2.setViewPosition(new Point(0, vp2.getView().getHeight()));
        factsPanel.add(BorderLayout.CENTER, scrollPaneFacts);
        JPanel activationsPanel = new JPanel();
        activationsPanel.setLayout(new BorderLayout());
        activationsPanel.setBorder(BorderFactory.createTitledBorder(
                BorderFactory.createCompoundBorder(
                        BorderFactory.createLineBorder(Color.WHITE),
                        BorderFactory.createRaisedBevelBorder()), "Activations"));
        areaActivations = new JTextArea();
        scrollPaneActivations = new JScrollPane(areaActivations,
                ScrollPaneConstants.VERTICAL_SCROLLBAR_AS_NEEDED,
                ScrollPaneConstants.HORIZONTAL_SCROLLBAR_AS_NEEDED);
        JViewport vp3 = scrollPaneActivations.getViewport();
        vp3.setViewPosition(new Point(0, vp3.getView().getHeight()));
        activationsPanel.add(BorderLayout.CENTER, scrollPaneActivations);
        JPanel controlPanel2 = new JPanel();
        controlPanel2.setBorder(BorderFactory.createTitledBorder(
                BorderFactory.createCompoundBorder(
                        BorderFactory.createLineBorder(Color.WHITE),
                        BorderFactory.createRaisedBevelBorder()), "Control"));
        controlPanel2.setLayout(new BorderLayout());
        JButton runOnce = new JButton("Run Once                         ", iconGoStep);
        runOnce.addActionListener(this);
        JButton searchFacts = new JButton("Search into Facts");
        searchFacts.addActionListener(this);
        JButton filterFacts = new JButton("Filter the Facts");
        filterFacts.addActionListener(this);
        JPanel controlPanel3 = new JPanel();
        controlPanel3.setLayout(new GridLayout(2, 1));
        controlPanel3.add(factsPanel);
        controlPanel3.add(activationsPanel);
        controlPanel2.add(BorderLayout.CENTER, runOnce);
        controlPanel2.add(BorderLayout.SOUTH, changeButton);
        debugPanel.add(BorderLayout.CENTER, controlPanel3);
        debugPanel.add(BorderLayout.NORTH, controlPanel2);
        JPanel creditsPanel = new JPanel(new BorderLayout());
        creditsPanel.setBorder(BorderFactory.createTitledBorder
                (BorderFactory.createCompoundBorder(BorderFactory.createEmptyBorder
                        (20, 20, 20, 20), BorderFactory.createRaisedBevelBorder()), ""));
        creditsPanel.setName("Credits");
        JTextArea areaCredits = new JTextArea();
        areaCredits.setEditable(false);
        Font font2 = new Font("boardFont", Font.BOLD, 14);
        areaCredits.setFont(font2);
        areaCredits.setBackground(Color.LIGHT_GRAY);
        areaCredits.setForeground(Color.BLACK);
        creditsPanel.add(BorderLayout.CENTER, areaCredits);
        // Importazione del file di testo credits.txt
        try {
            BufferedReader br = ResourceLoader.loadResource(getClass(),"/credits.txt");
            String s = br.readLine();
            String tot = "";
            while (s != null) {
                tot = tot + "\n" + s;
                s = br.readLine();
            }
            br.close();
            areaCredits.setText(tot);
        } catch (Exception fle) {
        }
        controlPanel.setName("Execution");
        debugPanel.setName("Debug");
        tabPane.add(controlPanel);
        tabPane.add(debugPanel);
        tabPane.add(creditsPanel);
        JSplitPane splitPane = new JSplitPane(JSplitPane.HORIZONTAL_SPLIT, gridNumbered, tabPane);
        splitPane.resetToPreferredSizes();
        totalWithExit.add(BorderLayout.CENTER, splitPane);
        totalWithExit.add(BorderLayout.SOUTH, exitPanel);
        container.add(totalWithExit);
		/*--------------------------------------------------------*/


		/*--------------- Ultime operazioni ----------------------*/
        //setDefaultCloseOperation(EXIT_ON_CLOSE);
        setDefaultCloseOperation(JFrame.DO_NOTHING_ON_CLOSE);
        setVisible(true);
		/*--------------------------------------------------------*/
    }

    /**
     * Metodo per la memorizzazione della mappa iniziale. E' un backup.
     */
    public void storeCells() {
        scells = new JLabel[nr][nc];
        for (int i = 0; i < nr; i++)
            for (int j = 0; j < nc; j++) {
                ImageIcon icon = (ImageIcon) (cells[i][j].getIcon());
                scells[i][j] = new JLabel(icon);
            }
        scells[entry_r][entry_c].setIcon(iconEntry);
    }

    /**
     * Metodo per il recupero della mappa iniziale.
     */
    public void fetchCells() {
        for (int i = 0; i < nr; i++)
            for (int j = 0; j < nc; j++) {
                ImageIcon icon = (ImageIcon) (scells[i][j].getIcon());
                cells[i][j].setIcon(icon);
            }
        repaint();
    }

    /**
     * Metodo per il settaggio dell'icona su un cella.
     */
    public void set(int x, int y, Icon icon) {
        cells[x][y].setIcon(icon);
        repaint();
    }

    /**
     * Metodo per trovare l'originale contenuto di una cella.
     */
    public String getOriginalCellContent(int i, int j) {
        ImageIcon icon = (ImageIcon) (scells[i][j].getIcon());
        return icon.getDescription();
    }

    /**
     * Metodo per il recupero del timer impostato.
     */
    public int getStepTime() {

        return ((Integer) (spinner.getModel().getValue())).intValue() * FACTOR;

    }

    /**
     * Metodo per la modifica del mappa corrente. Richiamato ad ogni passo.
     *
     * @param state Memorizza tutte le nuovi impostazioni dell'agente. Il nuovo stato.
     */
    public void modifyWorld(RubyState state) {
        int x = state.getPositionX();
        int y = state.getPositionY();
        boolean l = state.getLoaded();
        String d = state.getDirection();
        int visited = state.getVisited();
        java.util.List<Cell> listUnusefulCells = state.getUnusefulCells();
        ImageIcon oldIcon = (ImageIcon) (cells[x][y].getIcon());
        String desc = oldIcon.getDescription();
		/* Recupero del backup con reset grafico. */
        fetchCells();
		/* Impostazione dell'entrata */
        if ((x != entry_r) || (y != entry_c)) {
            set(entry_r, entry_c, iconExit);
            repaint();
        }
		/* Impostazione delle celle gi� visitate. */
        counterCellsVisited = 0;
        for (int i = 0; i < nr; i++)
            for (int j = 0; j < nc; j++) {

                if ((i == x) && (j == y)) {
                    (cells[i][j]).setToolTipText("(" + i + ", " + j + ") - " + desc + ", visited: " + visited);
                }


                if (visitedCells[i][j]) {
                    counterCellsVisited++;
                    if (getOriginalCellContent(i, j).equals("debris")) {
                        set(i, j, iconDebrisNoSeen);
                    } else if (getOriginalCellContent(i, j).equals("debrisYes")) {
                        set(i, j, iconDebrisYesViewed);
                        if ((i == x) && (j == y) && (!(personLoaded))) {
                            //scells[i][j].setIcon(iconDebrisNo);
                            personLoadedR = i;
                            personLoadedC = j;
                            personLoaded = true;
                        }
                    } else {
                        set(i, j, iconRubyStep);
                    }
                }
                int percTemp = (int) (counterCellsVisited * 100 / counterCellsPossible);
                String tempVisited = "Celle totali visitate: " + counterCellsVisited + " (" + percTemp + "%)";
                counterCellsVisitedMonitor.setText(tempVisited);
            }

        // Impostazioni celle unuseful
        Iterator it = listUnusefulCells.iterator();
        while (it.hasNext()) {
            Cell unuseful = (Cell) (it.next());
            int unusefulR = unuseful.getRow();
            int unusefulC = unuseful.getColumn();
            cells[unusefulR][unusefulC].setIcon(iconUnusefulCell);
        }

        // Impostazione del Robot.
        if (d.equals("down")) {
            cells[x][y].setIcon(iconRubyDOWN);
            visitedCells[x][y] = true; /* Settaggio sulla visita della cella. */
            if ((desc.equals("debris")) || (desc.equals("RubyLEFTDebrisNo")) || (desc.equals("RubyRIGHTDebrisNo"))) // DebrisNo
                set(x, y, iconRubyDOWNDebrisNo);
            if ((desc.equals("debrisYes")) || (desc.equals("RubyLEFTDebrisYes")) || (desc.equals("RubyRIGHTDebrisYes"))) // DebrisYes
                set(x, y, iconRubyDOWNDebrisYes);
            if (desc.equals("IMAGE_ENTRY")) // Entrata
            {
                visitedCells[x][y] = false;
            }

            // Impostazioni della vista di Ruby
            try {
                int tempx = x + 1;
                int tempCount = 0;
                while ((tempx < nr) && (tempCount < 3)) {
                    ImageIcon tempView = (ImageIcon) (cells[tempx][y].getIcon());
                    String tempDesc = tempView.getDescription();
                    if (tempDesc.equals("IMAGE_WALL")) break;
                    if (tempDesc.equals("empty"))
                        cells[tempx][y].setIcon(iconRubyView);
                    if (tempDesc.equals("debris"))
                        cells[tempx][y].setIcon(iconRubyViewDebrisNo);
                    if (tempDesc.equals("debrisYes"))
                        cells[tempx][y].setIcon(iconRubyViewDebrisYes);
                    tempx++;
                    tempCount++;
                }
            } catch (Exception rrwemw) {
                System.out.println("Eccezione controllata in RRWE ModifyWorld");
            }
        }
        if (d.equals("up")) {
            cells[x][y].setIcon(iconRubyUP);
            visitedCells[x][y] = true;
            if ((desc.equals("debris")) || (desc.equals("RubyLEFTDebrisNo")) || (desc.equals("RubyRIGHTDebrisNo"))) // DebrisNo
                set(x, y, iconRubyUPDebrisNo);
            if ((desc.equals("debrisYes")) || (desc.equals("RubyLEFTDebrisYes")) || (desc.equals("RubyRIGHTDebrisYes"))) // DebrisYes
                set(x, y, iconRubyUPDebrisYes);
            if (desc.equals("IMAGE_ENTRY")) // Entrata
            {
                visitedCells[x][y] = false;
            }
            // Impostazioni della vista di Ruby
            try {
                int tempx = x - 1;
                int tempCount = 0;
                while ((tempx >= 0) && (tempCount < 3)) {
                    ImageIcon tempView = (ImageIcon) (cells[tempx][y].getIcon());
                    String tempDesc = tempView.getDescription();
                    if (tempDesc.equals("IMAGE_WALL")) break;
                    if (tempDesc.equals("empty"))
                        cells[tempx][y].setIcon(iconRubyView);
                    if (tempDesc.equals("debris"))
                        cells[tempx][y].setIcon(iconRubyViewDebrisNo);
                    if (tempDesc.equals("debrisYes"))
                        cells[tempx][y].setIcon(iconRubyViewDebrisYes);
                    tempx--;
                    tempCount++;
                }
            } catch (Exception rrwemw) {
                System.out.println("Eccezione controllata in RRWE ModifyWorld");
            }
        }
        if (d.equals("left")) {
            set(x, y, iconRubyLEFT);
            visitedCells[x][y] = true;
            if ((desc.equals("debris")) || (desc.equals("RubyUPDebrisNo")) || (desc.equals("RubyDOWNDebrisNo"))) // DebrisNo
                set(x, y, iconRubyLEFTDebrisNo);
            if ((desc.equals("debrisYes")) || (desc.equals("RubyUPDebrisYes")) || (desc.equals("RubyDOWNDebrisYes"))) // DebrisYes
                set(x, y, iconRubyLEFTDebrisYes);
            if (desc.equals("IMAGE_ENTRY")) // Entrata
            {
                visitedCells[x][y] = false;
            }
            // Impostazioni della vista di Ruby
            try {
                int tempy = y - 1;
                int tempCount = 0;
                while ((tempy >= 0) && (tempCount < 3)) {
                    ImageIcon tempView = (ImageIcon) (cells[x][tempy].getIcon());
                    String tempDesc = tempView.getDescription();
                    if (tempDesc.equals("IMAGE_WALL")) break;
                    if (tempDesc.equals("empty"))
                        cells[x][tempy].setIcon(iconRubyView);
                    if (tempDesc.equals("debris"))
                        cells[x][tempy].setIcon(iconRubyViewDebrisNo);
                    if (tempDesc.equals("debrisYes"))
                        cells[x][tempy].setIcon(iconRubyViewDebrisYes);
                    tempy--;
                    tempCount++;
                }
            } catch (Exception rrwemw) {
                System.out.println("Eccezione controllata in RRWE ModifyWorld");
            }
        }
        if (d.equals("right")) {
            set(x, y, iconRubyRIGHT);
            visitedCells[x][y] = true;
            if ((desc.equals("debris")) || (desc.equals("RubyUPDebrisNo")) || (desc.equals("RubyDOWNDebrisNo"))) // DebrisNo
                set(x, y, iconRubyRIGHTDebrisNo);
            if ((desc.equals("debrisYes")) || (desc.equals("RubyUPDebrisYes")) || (desc.equals("RubyDOWNDebrisYes"))) // DebrisYes
                set(x, y, iconRubyRIGHTDebrisYes);
            if (desc.equals("IMAGE_ENTRY")) // Entrata
            {
                visitedCells[x][y] = false;
            }
            // Impostazioni della vista di Ruby
            try {
                int tempy = y + 1;
                int tempCount = 0;
                while ((tempy < nc) && (tempCount < 3)) {
                    ImageIcon tempView = (ImageIcon) (cells[x][tempy].getIcon());
                    String tempDesc = tempView.getDescription();
                    if (tempDesc.equals("IMAGE_WALL")) break;
                    if (tempDesc.equals("empty"))
                        cells[x][tempy].setIcon(iconRubyView);
                    if (tempDesc.equals("debris"))
                        cells[x][tempy].setIcon(iconRubyViewDebrisNo);
                    if (tempDesc.equals("debrisYes"))
                        cells[x][tempy].setIcon(iconRubyViewDebrisYes);
                    tempy++;
                    tempCount++;
                }
            } catch (Exception rrwemw) {
                System.out.println("Eccezione controllata in RRWE ModifyWorld");
            }
        }
        if (l) // Se � carico
        {
            if (d.equals("right"))
                set(x, y, iconRubyRIGHTDebrisYes);
            if (d.equals("up"))
                set(x, y, iconRubyUPDebrisYes);
            if (d.equals("down"))
                set(x, y, iconRubyDOWNDebrisYes);
            if (d.equals("left"))
                set(x, y, iconRubyLEFTDebrisYes);
            // Se ho gi� preso il superstite e non sono sopra quella cella, la rappresento
            // come un debris vuoto.
            if ((x != personLoadedR) || (y != personLoadedC)) {
                set(personLoadedR, personLoadedC, iconDebrisNoSeen);
                visitedCells[x][y] = true;
            }
        }
        if ((x != entry_r) || (y != entry_c))
            set(entry_r, entry_c, iconEntry);
    }


    /**
     * Metodo per la cura del feedback sul planning dell'agente (start)
     */
    public void startPlanning() {
        if (planningFrame != null)
            planningFrame.setVisible(false);
        planningFrame = new JFrame();
        planningFrame.setUndecorated(true);
        planningFrame.setSize(w / 3, h / 11);
        planningFrame.setLocation(w / 3, h / 2);
        Container cpf = planningFrame.getContentPane();
        JPanel planningPanel = new JPanel();
        planningPanel.setLayout(new BorderLayout());
        planningPanel.setBorder(BorderFactory.createCompoundBorder(BorderFactory.createLineBorder(Color.WHITE), BorderFactory.createRaisedBevelBorder()));

        plaBar = new JProgressBar(1, MAX_DEPTH_PLANNING);
        plaBar.setStringPainted(true);
        plaBar.setString("Depth: ");
        planningPanel.add(BorderLayout.CENTER, new JLabel("Planning per l'uscita dalla mappa...", JLabel.CENTER));
        planningPanel.add(BorderLayout.SOUTH, plaBar);
        cpf.add(planningPanel);
        planningFrame.setVisible(true);
    }

    /**
     * Metodo per la cura del feedback sul planning dell'agente (stop)
     */
    public void setPlanningDepth(String d) {
        int intDepth = Integer.parseInt(d);

        if (intDepth > MAX_DEPTH_PLANNING) {
            planningFrame.setVisible(false);
        } else {
            plaBar.setString("Depth: " + d);
            plaBar.setValue(intDepth);
        }
    }

    /**
     * Metodo per la cura del feedback sul planning dell'agente (stop)
     */
    public void stopPlanning() {
        planningFrame.setVisible(false);
    }

    /**
     * Metodo per il settaggio della messageBoard
     */
    public void setBoard(String s) {
        messageBoard.setText(messageBoard.getText() + "\n" + s);
        JViewport vp = scrollPane.getViewport();
        vp.setViewPosition(new Point(0, vp.getView().getHeight()));
        messageBoard.setVisible(true);
        messageBoard.repaint();
        repaint();
        if (viewer != null)
            viewer.updateBoard(s, false);
    }

    /**
     * Metodo per il settaggio della messageBoard con ripetizione.
     */
    public void setBoard(String s, boolean replace) {
        if (replace)
            messageBoard.setText("\n" + s);
        else
            messageBoard.setText(messageBoard.getText() + "\n" + s);
        JViewport vp = scrollPane.getViewport();
        vp.setViewPosition(new Point(0, vp.getView().getHeight()));
        messageBoard.setVisible(true);
        messageBoard.repaint();
        repaint();
        if (viewer != null)
            viewer.updateBoard(s, replace);
    }

    /**
     * Metodo per il prelevamento del path del sorgente
     */
    public String getSourcePath() {
        return sourcePath;
    }

    /**
     * Azioni eseguite all'uscita di Ruby dalla mappa.
     */
    public void rubyToExit() {
        if (planningFrame != null) {
            planningFrame.setVisible(false);
        }
        engine = new Engine(this, "stop");
        goButton.setEnabled(false);
        stopButton.setEnabled(false);
        resetButton.setEnabled(true);
        goStepButton.setEnabled(false);
        JOptionPane opPane = new JOptionPane();
        int r = opPane.showConfirmDialog(null, "Ruby � arrivato all'uscita. Provare un nuovo mondo?,", "Fine", JOptionPane.YES_NO_OPTION);
        if (r == JOptionPane.YES_OPTION) {
            JButton cm = new JButton("Cambia mondo                ");
            ActionEvent event = new ActionEvent(cm, 111111, "Cambia mondo                ");
            this.actionPerformed(event);
        }

		/*if (viewer != null)
		{
			viewer.updateBoard("\nWORLD\n--------------------\n", false);
			String s = "";
			for (int i = 0; i < nr; i++)
			{
				for (int j = 0; j < nc; j++)
				{
					ImageIcon icon = (ImageIcon)(scells[i][j].getIcon());
					String iconDesc = icon.getDescription();
					s = s + "  " + iconDesc + "  ";
				}
				s = s + "\n";
			}
			viewer.updateBoard(s, false);
			viewer.updateBoard("--------------------\n", false);
		}
		else
		{
			JTextArea areaSuppl = new JTextArea(messageBoard.getText());
			FrameBoard frameBoard = new FrameBoard("MessageBoard esterna", areaSuppl);
			viewer = frameBoard;
			viewer.updateBoard("\nWORLD\n--------------------\n", false);
			String s = "";
			for (int i = 0; i < nr; i++)
			{
				for (int j = 0; j < nc; j++)
				{
					ImageIcon icon = (ImageIcon)(scells[i][j].getIcon());
					String iconDesc = icon.getDescription();
					s = s + "  " + iconDesc + "  ";
				}
				s = s + "\n";
			}
			viewer.updateBoard(s, false);
			viewer.updateBoard("--------------------\n", false);
		}*/
    }

    /**
     * Metodo per il settaggio della nuova mappa in seguito ad uno spostamento.
     *
     * @param state Indica un oggetto che descrive lo stato corrente di Ruby.
     */
    public void setMap(RubyState state) {
        if (state == null) {
			/* Recupero del backup della mappa */
            fetchCells();
        } else {
            int x = state.getPositionX();
            int y = state.getPositionY();
            boolean l = state.getLoaded();
            String d = state.getDirection();
            int visited = state.getVisited();

			/* Settaggio della messageBoard */
            if (l)
                setBoard("Posizione (" + x + ", " + y + "), in direzione " + d + ", carico");
            else
                setBoard("Posizione (" + x + ", " + y + "), in direzione " + d + ", scarico");

			/* Settaggio nuovo stato di Ruby nella mappa */
            modifyWorld(state);
        }
    }

    /**
     * Incrementa il contatore dello step.
     */
    public void IncrCounterStep() {
        counterStep += 1;
        counterStepMonitor.setText("Step numero: " + counterStep);
    }

    /**
     * Incrementa il contatore delle attivazioni.
     */
    public void IncrCounterMatching() {
        counterMatchingStep += 1;
        counterActivationMonitor.setText("Attivazioni: " + counterMatchingStep);
    }

    /**
     * Per il debug. Imposta la finestra con tutti i fatti della WM.
     */
    public void setFacts(Iterator f) {
        areaFacts.setText("");
        while (f.hasNext()) {
            Fact f1 = (Fact) (f.next());
            areaFacts.append("F-" + f1.getFactId() + ", " + f1 + "\n");

        }
        JViewport vpf = scrollPaneFacts.getViewport();
        vpf.setViewPosition(new Point(0, vpf.getView().getHeight()));
    }

    /**
     * Per il debug. Imposta la finestra con tutte le attivazioni dell'agenda.
     */
    public void setActivations(Iterator a) {
        areaActivations.setText("");
        int i = 0;
        while (a.hasNext()) {
            Activation a1 = (Activation) (a.next());
            areaActivations.append("Rule " + i + ": " + a1 + "\n");
            i++;
        }
    }

    /**
     * Metodo per la gestione dei bottoni.
     *
     * @param e L'evento chiamante.
     */
    public void actionPerformed(ActionEvent e) {
        JButton b = (JButton) (e.getSource());

		/*----------------Interazione con JESS--------------------*/
        if (b.getText().equals("Run Once                         ")) {
            engine = new Engine(this, "runOnce");
        }
        if (b.getText().equals("Go          ")) {
            stopButton.setEnabled(true);
            goButton.setEnabled(false);
            goStepButton.setEnabled(false);
            verifyButton.setEnabled(false);
            resetButton.setEnabled(false);
            engine = new Engine(this, "run");
            // Procedere con l'esecuzione (un passo ogni tot secondi, per la visualizzazione).
        }
        if (b.getText().equals("Stop")) {
            goButton.setEnabled(true);
            stopButton.setEnabled(false);
            verifyButton.setEnabled(false);
            resetButton.setEnabled(true);
            goStepButton.setEnabled(true);
            engine = new Engine(this, "stop");
            // Fermare l'esecuzione della Go.
        }
        if (b.getText().equals("Go Step")) {
            engine = new Engine(this, "runStep");
            verifyButton.setEnabled(false);
			/* Procedere con l'esecuzione di un passo, ma 'logico'.
			   Attenzione, non � un "run 1", ma un "run X" che permette a Ruby
			   di eseguire un'azione. Probabilmente quando compare una exec-path.
			   (Le exec segnano anche gli step di rotazione).*/
        }
        if (b.getText().equals("Verify")) {
            engine = new Engine(this, "verify");
            verifyButton.setEnabled(false);
        }
        if (b.getText().equals("Cambia mondo                ")) {
            JOptionPane op = new JOptionPane();
            int rrr = op.showConfirmDialog(this, " Si � sicuri di cambiare il mondo corrente?.", "Attenzione!", JOptionPane.WARNING_MESSAGE);
            if (rrr == JOptionPane.YES_OPTION) {
                new RubyRescueWorldParameters();
                engine = new Engine(this, "changeWorld");
                setVisible(false);
                new RegisterThread(this);
            }
        }

        if (b.getText().equals("Prompt Jess                    ")) {
            verifyButton.setEnabled(false);
            JFrame fl = new JFrame("Prompt di Jess");
            fl.addComponentListener(this);
            Container cfl = fl.getContentPane();
            JPanel total = new JPanel();
            total.setLayout(new BorderLayout());
            total.setBorder(BorderFactory.createTitledBorder
                    (BorderFactory.createCompoundBorder(BorderFactory.createEmptyBorder
                            (10, 10, 10, 10), BorderFactory.createRaisedBevelBorder()), ""));
            centerPanel = new JPanel();
            areaLog = new JTextArea();
            Font font = new Font("boardFont", Font.BOLD, 12);
            areaLog.setFont(font);
            areaLog.setBackground(Color.WHITE);
            areaLog.setForeground(Color.BLACK);
            scrollAreaLog = new JScrollPane(areaLog);
            centerPanel.add(scrollAreaLog);
            total.add(BorderLayout.CENTER, centerPanel);
            final JTextField field = new JTextField();
            final RubyRescueWorldExecution rrwe = this;
            field.addActionListener(new ActionListener() {
                public void actionPerformed(ActionEvent e) {
                    clearLog();
                    String command = field.getText();
                    engine = new Engine(rrwe, command);
                }
            });
            total.add(BorderLayout.SOUTH, field);
            JPanel upP = new JPanel();
            upP.setLayout(new GridLayout(1, 4));

            JButton b1 = new JButton("Facts *");
            b1.addActionListener(this);
            upP.add(b1);
            b1 = new JButton("Facts AGENT");
            b1.addActionListener(this);
            upP.add(b1);
            b1 = new JButton("Agenda");
            b1.addActionListener(this);
            upP.add(b1);
            b1 = new JButton("Run 1");
            b1.addActionListener(this);
            upP.add(b1);
            total.add(BorderLayout.NORTH, upP);
            cfl.add(total);
            //fl.pack();
            fl.setSize(w, h);
            fl.setVisible(true);
        }
        if (b.getText().equals("Apri in un'altra finestra")) {
            JTextArea areaSuppl = new JTextArea(messageBoard.getText());
            FrameBoard frameBoard = new FrameBoard("MessageBoard esterna", areaSuppl);
            viewer = frameBoard;
        }
        if (b.getText().equals("Salva questo mondo      ")) {
            JOptionPane op = new JOptionPane();
            String result = op.showInputDialog(null, "Nome da assegnare al mondo?", "Salvataggio del mondo", JOptionPane.QUESTION_MESSAGE);
            if (result != null) {
                this.setTitle("Roby-Rescue World Execution  (Versione motore Jess: 7.0 beta) - " + result + ".rub");
                File f = new File(MAP_PATH + result + ".rub");
                String s = nr + " " + nc + "\n";
                for (int i = 0; i < nr; i++) {
                    for (int j = 0; j < nc; j++) {
                        ImageIcon icon = (ImageIcon) (scells[i][j].getIcon());
                        String iconDesc = icon.getDescription();
                        s = s + "  " + iconDesc + "  ";
                    }
                    s = s + "\n";
                }
                try {
                    FileWriter out = new FileWriter(f);
                    out.write(s);
                    out.close();
                    op.showMessageDialog(null, "Mondo salvato correttamente!", "Salvataggio del mondo", JOptionPane.PLAIN_MESSAGE);
                } catch (Exception eux) {
                    System.out.println("Errore in RubyWorldExecution (salvataggio del mondo) " + eux.getMessage());
                    op.showMessageDialog(null, "Errore nel salvataggio. Prova con un altro nome", "Salvataggio del mondo", JOptionPane.ERROR_MESSAGE);
                }
            }
        }
        if (b.getText().equals("Reset    ")) {
            verifyButton.setEnabled(true);
            goButton.setEnabled(true);
            goStepButton.setEnabled(true);
            changeButton.setEnabled(true);
            newFrameButton.setEnabled(true);
            for (int i = 0; i < nr; i++)
                for (int j = 0; j < nc; j++) {
                    visitedCells[i][j] = false;
                    cells[i][j].setToolTipText("");
                }
            engine = new Engine(this, "reset");
            setBoard("", true);
            counterStep = 0;
            counterMatchingStep = 0;
            counterStepMonitor.setText("Step numero: " + counterStep);
            counterActivationMonitor.setText("Attivazioni: " + counterMatchingStep);
            counterCellsVisitedMonitor.setText("Celle totali visitate: 0");
            RubyState.eraseUnusefulCells();

            // Si esegue il comando "reset" di CLIPS/JESS.
        }
		/*--------------------------------------------------------*/
        if (b.getText().equals("Agenda")) {
            clearLog();
            engine = new Engine(this, "(agenda)");
        }
        if (b.getText().equals("Facts *")) {
            clearLog();
            engine = new Engine(this, "(facts *)");
        }
        if (b.getText().equals("Facts AGENT")) {
            clearLog();
            engine = new Engine(this, "(facts AGENT)");
        }
        if (b.getText().equals("Run 1")) {
            clearLog();
            engine = new Engine(this, "(run 1)");
        }
        if (b.getText().equals("Reset")) {
            clearLog();
            engine = new Engine(this, "(reset)");
        }
        // Uscita.
        if (b.getText().equals("Esci                                     ")) {
            //System.IMAGE_EXIT(0);
            windowClosing(null);
        }
    }

    public void windowDeactivated(WindowEvent e) {
    }

    public void windowActivated(WindowEvent e) {
    }

    public void windowDeiconified(WindowEvent e) {
    }

    public void windowIconified(WindowEvent e) {
    }

    public void windowClosed(WindowEvent e) {
    }

    public void windowOpened(WindowEvent e) {
    }

    public void componentMoved(ComponentEvent e) {
    }

    public void componentHidden(ComponentEvent e) {
    }

    public void componentShown(ComponentEvent e) {
    }

    public void mouseExited(MouseEvent e) {
    }

    public void mouseEntered(MouseEvent e) {
    }

    public void mouseClicked(MouseEvent e) {
    }

    public void mouseReleased(MouseEvent e) {
    }

    /**
     * Metodo per la gestione dell'uscita dall'applicazione.
     */
    public void windowClosing(WindowEvent e) {
        JOptionPane opPane = new JOptionPane();
        int r = opPane.showConfirmDialog(null, "Vuoi veramente uscire?", "Uscita", JOptionPane.YES_NO_OPTION);
        if (r == JOptionPane.YES_OPTION) {
            System.exit(0);
        }
    }

    /**
     * Metodo per la gestione del resize della GUI.
     */
    public void componentResized(ComponentEvent e) {
        Dimension sizeScroll = messagePanel.getSize();
        Point locScroll = messagePanel.getLocation();
        scrollPane.setLocation(22, 50);
        scrollPane.setSize(sizeScroll.width - 75, sizeScroll.height - 115);
        scrollPaneFacts.setLocation(22, 50);
        scrollPaneFacts.setSize(sizeScroll.width - 75, sizeScroll.height - 115);
        scrollPaneActivations.setLocation(22, 50);
        scrollPaneActivations.setSize(sizeScroll.width - 75, sizeScroll.height - 115);

        try {
            sizeScroll = centerPanel.getSize();
            locScroll = centerPanel.getLocation();
            scrollAreaLog.setLocation(0, 0);
            scrollAreaLog.setSize(sizeScroll.width, sizeScroll.height);
        } catch (Exception badula) {
        }
    }

    /**
     * Metodo per la gestione delle azioni del mouse.
     */
    public void mousePressed(MouseEvent e) {
        int bu = e.getButton();
        if (bu == MouseEvent.BUTTON3) {
            JPopupMenu menu = new JPopupMenu();
            JMenuItem itemClearText = new JMenuItem("Pulisci");
            JMenuItem itemRefresh = new JMenuItem("Refresh");
            itemClearText.addActionListener(new ActionListener() {
                public void actionPerformed(ActionEvent e) {
                    messageBoard.setText("");
                }
            });
            itemClearText.addActionListener(new ActionListener() {
                public void actionPerformed(ActionEvent e) {
                    messageBoard.repaint();
                }
            });
            menu.add(itemClearText);
            menu.add(itemRefresh);
            menu.show(e.getComponent(), e.getX(), e.getY());
        }
    }

    /**
     * Metodo per la gestione del prompt java su file di log.
     */
    public void setConsolePanel() {
        try {
            BufferedReader br = new BufferedReader(new FileReader(new File("RubyExecution.log")));
            String s = br.readLine();
            String tot = "";
            while (s != null) {
                tot = tot + "\n" + s;
                s = br.readLine();
            }
            br.close();
            areaLog.setText(tot);
            JViewport vp = scrollAreaLog.getViewport();
            vp.setViewPosition(new Point(0, vp.getView().getHeight()));
        } catch (Exception fle) {
        }
    }

    /**
     * Metodo per la cancellazione del file di log.
     */
    public void clearLog() {
        try {
            File log = new File("RubyExecution.log");
            log.delete();
            log.createNewFile();
        } catch (Exception ede) {
            System.out.println(ede.getMessage());
        }
    }

    /**
     * Metodo per far partire l'esecuzione del programma.
     */
    public static void main(String[] args) {
        JLogoFrame intro = new JLogoFrame();
        File log = new File("RubyExecution.log");
        try {
            PrintStream stream = new PrintStream(log);
            System.setOut(stream);
        } catch (Exception log_e) {
            System.out.println("Errore nella creazione del file di log. " + log_e.getMessage());
        }
        new RubyRescueWorldParameters();
    }
}