package it.unito.di.islabs.ui;

import java.awt.*;
import java.awt.event.*;
import javax.swing.*;
import java.io.*;
import java.util.*;

/** Questa classe offre un'interfaccia grafica per modellare un mondo per RubyRescue.
    Non gestisce errori di modellazione umani.
*/
public class RubyRescueWorldCreation extends JFrame implements ActionListener, MouseListener {
	/** Percorso dell'icona specifica.*/
	private static String wall = "/image/Wall.gif";
	/** Percorso dell'icona specifica.*/
	private  static String exit = "/image/Exit.gif";
	/** Percorso dell'icona specifica.*/
	private  static String entry = "/image/Entry.gif";
	/** Percorso dell'icona specifica.*/
	private  static String debrisNo = "/image/DebrisNo.gif";
	/** Percorso dell'icona specifica.*/
	private  static String debrisYes = "/image/DebrisYes.gif";
	/** Percorso dell'icona specifica.*/
	private  static String nulla = "/image/Null.gif";

	private  static String random = "/image/random.gif";

	/** Scrive il file CLIPS.*/
	private FileWriter out, outClips;

	/** Le varie icone*/
	public static Icon iconWall, iconExit, iconEntry, iconDebrisNo, iconDebrisYes, iconNull, iconRandom;

	/** La matrice di bottoni che servono per modellare il mondo*/
	public JButton[][] cells;

	/** Righe e colonne.*/
	private int nr, nc;

	private RubyRescueWorldExecution rrwe = null;

	private String errorMapMessage = "Controlla bene la mappa";

	private boolean entryOk = true;

	private boolean exitOk = true;

	private boolean perimOk = true;

	private JList list;

	/**Costruttore
	@param r numero di righe
	@param c numero di colonne
	*/
	public RubyRescueWorldCreation(int r, int c) {
		super("Roby-Rescue World Creation");
//		System.gc(); // Richiamo forzato del garbage collector
		nr = r;
		nc = c;
		cells = new JButton[nr][nc];

		/*-------------------- Per la location della finestra ------------------*/
		Toolkit kit = Toolkit.getDefaultToolkit();
		Dimension dim = kit.getScreenSize();
		int h = dim.height;
		int w = dim.width;

		setSize(w , h);

		/*----------------------------------------------------------------------*/

		/*-------------------- Costruzione interfaccia -------------------------*/
		Container container = getContentPane();
		JPanel grid = new JPanel();
		grid.setLayout(new GridLayout(r, c));
		grid.setBorder(BorderFactory.createTitledBorder(BorderFactory.createCompoundBorder(BorderFactory.createLineBorder(Color.WHITE), BorderFactory.createRaisedBevelBorder()), "Mappa"));
		iconWall = new ImageIcon(getClass().getResource(wall).getPath(), "wall");
		iconEntry = new ImageIcon(getClass().getResource(entry).getPath(), "entry");
		iconExit = new ImageIcon(getClass().getResource(exit).getPath(), "exit");
		iconDebrisNo = new ImageIcon(getClass().getResource(debrisNo).getPath(), "debris");
		iconDebrisYes = new ImageIcon(getClass().getResource(debrisYes).getPath(), "debrisYes");
		iconNull = new ImageIcon(getClass().getResource(nulla).getPath(), "empty");

		JButton b;
		for (int i = 0; i < nr; i++) {
			for (int j = 0; j < nc; j++) {
				b = new JButton("", iconNull);
				cells[i][j] = b;
				b.addActionListener(this);
				b.addMouseListener(this);
				grid.add(b);
			}
		}
		Icon iconCreate = new ImageIcon(getClass().getResource("/image/edit.gif").getPath());
		Icon iconOk = new ImageIcon(getClass().getResource("/image/ok.gif").getPath());
		Icon iconRandom = new ImageIcon(getClass().getResource("/image/random.gif").getPath());
		Icon iconClear = new ImageIcon(getClass().getResource("/image/clear.gif").getPath());
		Icon iconExitProgram = new ImageIcon(getClass().getResource("/image/exitProgram.gif").getPath());
		JPanel total = new JPanel();
		total.setLayout(new BorderLayout());
		total.setBorder(BorderFactory.createCompoundBorder(BorderFactory.createLineBorder(Color.WHITE), BorderFactory.createEmptyBorder(18,18,18,18)));
		JPanel controlPanel = new JPanel();
		controlPanel.setLayout(new GridLayout(3, 1));
		controlPanel.setBorder(BorderFactory.createTitledBorder(BorderFactory.createCompoundBorder(BorderFactory.createLineBorder(Color.WHITE), BorderFactory.createRaisedBevelBorder()), "Controllo"));
		JButton resetButton = new JButton("Pulisci", iconClear);
		JButton okButton = new JButton("Fatto", iconOk);
		JButton randomButton = new JButton("Randomize", iconRandom);
		JButton reButton = new JButton("Reimposta", iconCreate);
		okButton.addActionListener(this);
		resetButton.addActionListener(this);
		randomButton.addActionListener(this);
		reButton.addActionListener(this);
		//controlPanel.add(randomButton);
		controlPanel.add(reButton);
		controlPanel.add(resetButton);
		controlPanel.add(okButton);
		JPanel exitPanel = new JPanel();
		JButton exitButton = new JButton("Esci", iconExitProgram);
		exitButton.addActionListener(this);
		exitPanel.add(exitButton);
		total.add(BorderLayout.EAST, controlPanel);
		total.add(BorderLayout.CENTER, grid);
		total.add(BorderLayout.SOUTH, exitPanel);
		container.add(total);
		/*---------------------------------------------------------*/

		/*-------------------- Ultime operazioni ------------------*/
		setDefaultCloseOperation(EXIT_ON_CLOSE);
		setVisible(true);

		ActionEvent event = new ActionEvent(new JButton("Pulisci"), 1211212, "Pulisci (Perimetro)");
		actionPerformed(event);
		/*---------------------------------------------------------*/
	}

	/** Metodo per il risettaggio dei parametri (righe e colonne)
	@param r numero di righe
	@param c numero di colonne
	*/
	public void setParameters(int r, int c) {
		nr = r;
		nc = c;
		setVisible(true);
	}

	/** Metodo per la gestione dei bottoni.
	@param e L'evento chiamante.
	*/
	public void actionPerformed(ActionEvent e) {
		JButton b = (JButton)(e.getSource());

		// Traccia il perimetro con dei muri e svuota l'interno della mappa.
		if(b.getText().equals("Pulisci")) {
			for (int i = 0; i < nr; i++) {
				for (int j = 0; j < nc; j++) {
					if ((j == nc - 1) || (j == 0) || (i == 0) || (i == nr - 1)) {
						cells[i][j].setIcon(iconWall);
					} else {
						cells[i][j].setIcon(iconNull);
					}
				}
			}
		}
		// Randomize della mappa
		if(b.getText().equals("Randomize")) {
			int percWall;
			int percExit;
			int percDebris;
			int percSurvivor;
		}
		// Crea il file CLIPS del mondo creato e fa partire l'interfaccia per l'esecuzione di RubyRescue.
		if(b.getText().equals("Fatto")) {
			if (controlMap()) {
				String debrisContent = "";
				String world = "";
				String contains;
				ImageIcon icon;
				try {
					// Le parti STATICHE del programma CLIPS. Le altre vengono aggiornate automaticamente
					FileReader in1 = new FileReader(getClass().getResource("/clp/Parte1.clp").getPath());
					FileReader in3 = new FileReader(getClass().getResource("/clp/Parte3.clp").getPath());
					FileReader in5 = new FileReader(getClass().getResource("/clp/Parte5.clp").getPath());
					FileReader in7 = new FileReader(getClass().getResource("/clp/Parte7.clp").getPath());

					FileReader in1c = new FileReader(getClass().getResource("/clpclips/Parte1.clp").getPath());
					FileReader in3c = new FileReader(getClass().getResource("/clpclips/Parte3.clp").getPath());
					FileReader in5c = new FileReader(getClass().getResource("/clpclips/Parte5.clp").getPath());
					FileReader in7c = new FileReader(getClass().getResource("/clpclips/Parte7.clp").getPath());

					// File di output.
					out = new FileWriter(getClass().getResource("/rules/Ruby.clp").getPath());
					outClips = new FileWriter(getClass().getResource("/rules/RubyClips.clp").getPath());
					// Scrittura parte statica 1.
					int c, cc;
					c = in1.read();
					while (c != -1) {
						out.write(c);
						c = in1.read();
					}
					in1.close();
					cc = in1c.read();
					while (cc != -1) {
						outClips.write(cc);
						cc = in1c.read();
					}
					in1c.close();

					// Scrittura parte dinamica 2. Trasformazione del mondo in codice CLIPS
					out.write("\n;Mondo creato con RubyRescueWorldCreation.java\n");
					Date date = new Date();
					out.write(";Data: "+ date +"\n");
					outClips.write("\n;Mondo creato con RubyRescueWorldCreation.java\n");
					outClips.write(";Data: "+ date +"\n");
					int entryR = 0;
					int entryC = 0;
					String direction = "";
					for (int i = 0; i < nr; i++) {
						for (int j = 0; j < nc; j++) {
							icon = (ImageIcon) (cells[i][j].getIcon());
							contains = icon.getDescription();

							if (contains.equals("entry")) {
								entryR = i;
								entryC = j;
								if (i == 0) {
									direction = "down";
								}
								if (j == 0) {
									direction = "right";
								}
								if (i == (nr - 1)) {
									direction = "up";
								}
								if (j == (nc - 1)) {
									direction = "left";
								}
							}

							if (contains.equals("debris")) {
								debrisContent = debrisContent + "\n(debriscontent (pos-r " + i + ") ";
								debrisContent = debrisContent + "(pos-c " + j + ") ";
								debrisContent = debrisContent + "(person no) ";
								debrisContent = debrisContent + "(digged no))";
							}
							if (contains.equals("debrisYes")) {
								contains = "debris";
								debrisContent = debrisContent + "\n(debriscontent (pos-r " + i + ") ";
								debrisContent = debrisContent + "(pos-c " + j + ") ";
								debrisContent = debrisContent + "(person Person-" + i + "-" + j + ") ";
								debrisContent = debrisContent + "(digged no))";
							}
							world = world + "\n(cell (pos-r " + i + ") ";
							world = world + "(pos-c " + j + ") ";
							world = world + "(contains " + contains + "))";
						}
					}
					world = world + debrisContent;
					out.write(world);
					outClips.write(world);

					// Scrittura parte statica 3.
					c = in3.read();
					while (c != -1) {
						out.write(c);
						c = in3.read();
					}
					in3.close();
					cc = in3c.read();
					while (cc != -1) {
						outClips.write(cc);
						cc = in3c.read();
					}
					in3c.close();

					// Inserimento parte dinamica 4.
					String agentStatus = "(agentstatus (pos-r "+entryR+") (pos-c "+entryC+")";
					agentStatus = agentStatus + "(time 0)(direction "+direction+") (load no)))\n";
					out.write(agentStatus);
					outClips.write(agentStatus);

					// Scrittura parte statica 5
					c = in5.read();
					while (c != -1) {
						out.write(c);
						c = in5.read();
					}
					in5.close();
					cc = in5c.read();
					while (cc != -1) {
						outClips.write(cc);
						cc = in5c.read();
					}
					in5c.close();

					// Scrittura parte dinamica 6.
					String mapEntry = "(assert (map (pos-r "+entryR+")(pos-c "+entryC+")";
					mapEntry = mapEntry + "(contains entry)))\n";
					out.write(mapEntry);
					outClips.write(mapEntry);

					// Scrittura parte statica 7.
					c = in7.read();
					while (c != -1) {
						out.write(c);
						c = in7.read();
					}
					in7.close();
					cc = in7c.read();
					while (cc != -1) {
						outClips.write(cc);
						cc = in7c.read();
					}
					in7c.close();

					// Chiusura file di output.
					out.close();
					outClips.close();

					setVisible(false);

					// Parte l'esecuzione del programma CLIPS
					String titleFrame = e.getActionCommand();
					if (titleFrame.equals("Fatto")) {
						titleFrame = "(mappa non salvata)";
					}
					rrwe = new RubyRescueWorldExecution(cells, titleFrame);
				} catch(Exception eee) {
					System.out.println(eee.getMessage());
				}
			}//if (controlMap == true)
			else {
				JOptionPane op = new JOptionPane();
				op.showMessageDialog(null, errorMapMessage, "Attento", 2);
			}
		}

		// Risettaggio dei parametri del mondo.
		if(b.getText().equals("Reimposta")) {
			setVisible(false);
			new RubyRescueWorldParameters();
		}

		// Uscita.
		if(b.getText().equals("Esci")) {
			System.exit(0);
		}
	}

	public boolean controlMap() {
		entryOk = true;
		perimOk = true;
		exitOk = true;
		int contEntry = 0;
		int contExit = 0;
		JButton b;
		for (int i = 0; i < nr; i++) {
			for (int j = 0; j < nc; j++) {
				b = cells[i][j];
				ImageIcon icon = (ImageIcon) (b.getIcon());
				String desc = icon.getDescription();
				if (desc.equals("entry")) {
					contEntry++;
				}
				if (desc.equals("entry") && (i != 0) && (j != 0) && (j != (nc - 1)) && (i != (nr - 1))) {
					entryOk = false;
				}
				if (desc.equals("exit")) {
					contExit++;
				}
				if (desc.equals("exit") && (i != 0) && (j != 0) && (j != (nc - 1)) && (i != (nr - 1))) {
					exitOk = false;
				}
				if ((i == 0) || (j == 0) || (j == (nc - 1)) || (i == (nr - 1))) {
					if ((desc.equals("debris")) || (desc.equals("debrisYes")) || (desc.equals("empty"))) {
						perimOk = false;
					}
				}
			}
		}
		if ((entryOk) && (exitOk) && (contEntry == 1) && (contExit > 0) && (perimOk)) {
			return true;
		} else {
			String e1 = null,e2 = null,e3 = null,e4 = null,e5 = null;
			errorMapMessage = "";
			if (!(entryOk)) {
				e1 = "- Hai inserito una o pi� entrate all'interno dei bordi";
				//return false;
			}
			if (!(exitOk)) {
				e2 = "- Hai inserito una o pi� uscite all'interno dei bordi";
				//return false;
			}
			if (contEntry == 0) {
				e3 = "- Non hai inserito l'entrata.";
				//return false;
			}
			if (contEntry > 1) {
				e4 = "- Hai inserito pi� di un'entrata.";
				//return false;
			}
			if (contExit == 0) {
				e5 = "- Non hai inserito le uscite.";
				//return false;
			}
			if (!(perimOk)) {
				e1 = "- Il perimetro � inconsistente. Solo muri, entrate e uscite sono accettati";
				//return false;
			}
			errorMapMessage = "Sono stati rilevati i seguenti errori nella costruzione della mappa:\n";
			if (e1 != null) {
				errorMapMessage = errorMapMessage + e1 + "\n";
			}
			if (e2 != null) {
				errorMapMessage = errorMapMessage + e2 + "\n";
			}
			if (e3 != null) {
				errorMapMessage = errorMapMessage + e3 + "\n";
			}
			if (e4 != null) {
				errorMapMessage = errorMapMessage + e4 + "\n";
			}
			if (e5 != null) {
				errorMapMessage = errorMapMessage + e5 + "\n";
			}
		}
		return false;
	}

	public void mouseExited(MouseEvent e) 	{
	}
	public void mouseEntered(MouseEvent e) {
	}
	public void mouseClicked(MouseEvent e) {
		int x = e.getButton();
		JButton b = (JButton) (e.getComponent());
		if (x == MouseEvent.BUTTON1) {
			ImageIcon icon = (ImageIcon) (b.getIcon());
			String kind = icon.getDescription();
			if (kind.equals("empty")) {
				b.setIcon(iconWall);
			} else if (kind.equals("wall")) {
				b.setIcon(iconEntry);
			} else if (kind.equals("entry")) {
				b.setIcon(iconExit);
			} else if (kind.equals("exit")) {
				b.setIcon(iconDebrisNo);
			} else if (kind.equals("debris")) {
				b.setIcon(iconDebrisYes);
			} else if (kind.equals("debrisYes")) {
				b.setIcon(iconNull);
			}
		}
		if (x == MouseEvent.BUTTON3) {
			ImageIcon icon = (ImageIcon)(b.getIcon());
			String kind = icon.getDescription();
			if (kind.equals("empty")) {
				b.setIcon(iconDebrisYes);
			} else if (kind.equals("wall")) {
				b.setIcon(iconNull);
			} else if (kind.equals("entry")) {
				b.setIcon(iconWall);
			} else if (kind.equals("exit")) {
				b.setIcon(iconEntry);
			} else if (kind.equals("debrisYes")) {
				b.setIcon(iconDebrisNo);
			} else if (kind.equals("debris")) {
				b.setIcon(iconExit);
			}
		}
	}

	public void mouseReleased(MouseEvent e) {
	}
	public void mousePressed(MouseEvent e) {
	}

}