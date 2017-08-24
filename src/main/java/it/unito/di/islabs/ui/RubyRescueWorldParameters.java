package it.unito.di.islabs.ui;

import java.awt.*;
import java.awt.event.*;
import javax.swing.*;
import java.io.*;
import java.util.*;

import it.unito.di.islabs.engine.Engine;
import it.unito.di.islabs.engine.RegisterThread;

import javax.swing.event.*;

/** GUI per il settaggio dei parametri del mondo.
*/
public class RubyRescueWorldParameters extends JFrame implements ActionListener, ListSelectionListener, WindowListener {
	private String execute = "/image/ok.gif";
	private String delete = "/image/clear.gif";
	private String modify = "/image/edit.gif";
	/** Percorso dell'icona specifica.*/
	private static String wall = "/image/Wallp.gif";
	/** Percorso dell'icona specifica.*/
	private  static String exit = "/image/Exitp.gif";
	/** Percorso dell'icona specifica.*/
	private  static String entry = "/image/Entryp.gif";
	/** Percorso dell'icona specifica.*/
	private  static String debrisNo = "/image/DebrisNop.gif";
	/** Percorso dell'icona specifica.*/
	private  static String debrisYes = "/image/DebrisYesp.gif";
	/** Percorso dell'icona specifica.*/
	private  static String nulla = "/image/Nullp.gif";
	/** Scrive il file CLIPS.*/
	private FileWriter out, outClips;
	/** Le varie icone*/
	public static Icon iconWall, iconExit, iconEntry, iconDebrisNo, iconDebrisYes, iconNull;

	/** Campo di testo per il numero di righe.*/
	private JTextField nrighe = new JTextField();
	/** Campo di testo per il numero di colonne.*/
	private JTextField ncolonne = new JTextField();
	private Icon iconCreate = new ImageIcon(getClass().getResource("/image/edit.gif").getPath());
	private Icon iconImport = new ImageIcon(getClass().getResource("/image/import.gif").getPath());
	private Icon iconDelete = new ImageIcon(getClass().getResource(delete).getPath());
	private Icon iconExecute = new ImageIcon(getClass().getResource(execute).getPath());
	private Icon iconModify = new ImageIcon(getClass().getResource(modify).getPath());
	/** Bottone per l'ok.*/
	private JButton ok = new JButton("Crea mondo", iconCreate);
	/** Si richiama poi la classe di creazione del mondo con i parametri immessi.*/
	private RubyRescueWorldCreation rrwc = null;
	private boolean okDo = false;
	private JList list;
	private JFrame fr;
	private JPanel total2;
	private String lastSelection;
	private int h, w;
	private JFrame anteFrame;
	private JFrame thisFrame;

	public RubyRescueWorldParameters() {
		super("Parametri di costruzione");

		thisFrame = this;
//		System.gc(); // Richiamo forzato del garbage collector
		/*-------------- Per la location della finestra -----------*/
		Toolkit kit = Toolkit.getDefaultToolkit();
		Dimension dim = kit.getScreenSize();
		h = dim.height;
		w = dim.width;
		int sizew = w/3;
		int sizeh = h/3*7/6;
		setSize(sizew, sizeh);
		setLocation((w-sizew)/2 , (h-sizeh)/2);
		/*---------------------------------------------------------*/
		iconWall = new ImageIcon(getClass().getResource(wall).getPath(), "wall");
		iconEntry = new ImageIcon(getClass().getResource(entry).getPath(), "entry");
		iconExit = new ImageIcon(getClass().getResource(exit).getPath(), "exit");
		iconDebrisNo = new ImageIcon(getClass().getResource(debrisNo).getPath(), "debris");
		iconDebrisYes = new ImageIcon(getClass().getResource(debrisYes).getPath(), "debrisYes");
		iconNull = new ImageIcon(getClass().getResource(nulla).getPath(), "empty");
		/*-------------- Costruzione dell'interfaccia--------------*/
		Container container = getContentPane();
		JPanel total = new JPanel();
		total.setLayout(new BorderLayout());
		total.setBorder(BorderFactory.createCompoundBorder(BorderFactory.createLineBorder(Color.WHITE), BorderFactory.createEmptyBorder(0,18,0,18)));
		JPanel leftPanel = new JPanel();
		leftPanel.setLayout(new GridLayout(3, 1));
		JLabel l1 = new JLabel("Numero righe: ");
		JPanel pl1 = new JPanel();
		//leftPanel.add(new JLabel(""));
		pl1.add(l1);
		leftPanel.add(pl1);
		leftPanel.add(new JLabel(""));

		JLabel l2 = new JLabel("Numero colonne: ");
		JPanel pl2 = new JPanel();
		pl2.add(l2);
		leftPanel.add(pl2);

		JPanel centerPanel = new JPanel();
		centerPanel.setLayout(new GridLayout(3, 1));
		centerPanel.add(nrighe);
		centerPanel.add(new JLabel(""));
		centerPanel.add(ncolonne);
		JPanel downPanel = new JPanel();
		downPanel.setLayout(new GridLayout(1, 1));
		downPanel.setBorder(BorderFactory.createEmptyBorder(30,0,0,0));
		//JPanel okPanel = new JPanel();
		//okPanel.setLayout(new GridLayout(1,1));
		//okPanel.add(ok);
		downPanel.add(ok);
		//downPanel.add(new JLabel(""));
		ok.addActionListener(this);
		total.add(BorderLayout.WEST, leftPanel);
		total.add(BorderLayout.CENTER, centerPanel);
		total.add(BorderLayout.SOUTH, downPanel);

		JPanel total2 = new JPanel();
		total2.setLayout(new BorderLayout());
		JPanel panelImport = new JPanel();
		JButton importB = new JButton("Importa mondo", iconImport);
		panelImport.setLayout(new BorderLayout());
		panelImport.add(BorderLayout.CENTER, importB);
		importB.addActionListener(this);
		//total2.add(panelImport);
		total2.add(BorderLayout.SOUTH, panelImport);

		JPanel veryTotal = new JPanel();
		veryTotal.setLayout(new BorderLayout());
		total.setBorder(BorderFactory.createTitledBorder(BorderFactory.createCompoundBorder(BorderFactory.createEmptyBorder(10,10,10,10), BorderFactory.createRaisedBevelBorder()), "Creazione di un nuovo mondo"));
		total2.setBorder(BorderFactory.createTitledBorder(BorderFactory.createCompoundBorder(BorderFactory.createEmptyBorder(10,10,10,10), BorderFactory.createRaisedBevelBorder()), "Ripristino di un mondo salvato"));
		veryTotal.add(BorderLayout.NORTH, total);
		veryTotal.add(BorderLayout.SOUTH, total2);
		container.add(veryTotal);
		/*---------------------------------------------------------*/

		/*-------------------- Ultime operazioni ------------------*/
		setDefaultCloseOperation(EXIT_ON_CLOSE);
		setVisible(true);
		//pack();
		/*---------------------------------------------------------*/
	}

	/** Metodo per la gestione dei bottoni.
		@param e L'evento chiamante.
	*/
	public void actionPerformed(ActionEvent e) {
		try {
			JButton b = (JButton)(e.getSource());
			String text = b.getText();
			if (text.equals("Crea mondo")) {
				String nrString = nrighe.getText();
				String ncString = ncolonne.getText();
				int nr = Integer.parseInt(nrString);
				int nc = Integer.parseInt(ncString);
				setVisible(false);

				if (rrwc == null) {
				/* Se � la prima volta, si costruisce il mondo con i paramentri immessi. */
					rrwc = new RubyRescueWorldCreation(nr, nc);
				} else {
				/* Se � gi� stato creato il mondo, si tratta di un aggiornamento dei parametri. */
					rrwc.setParameters(nr, nc);
				}
			} else if (text.equals("Cancella")) {
				if (list.getSelectedValue() != null) {
					JOptionPane op = new JOptionPane();
					int rrr = op.showConfirmDialog(this, " Si vuole veramente eliminare il mondo selezionato?", "Attenzione!", JOptionPane.WARNING_MESSAGE);
					if (rrr == JOptionPane.YES_OPTION) {
						//fr.setVisible(false);
						File file = new File(RubyRescueWorldExecution.MAP_PATH + list.getSelectedValue().toString());
						file.delete();

						file = new File(RubyRescueWorldExecution.MAP_PATH);
						String[] items = new String[1];
						FilenameFilter filter = new RubyRescueWorldFileFilter();
						items = file.list(filter);

						//Ordinamento files alfabetico
						String[]  itemsT = null;
						if (items.length > 0) {
							itemsT = new String[items.length];
							String min = items[0];
							int ytemp = 0;
							for (int u = 0; u < items.length; u++) {
								for (int y = 0; y < items.length; y++) {
									if ((items[y]).compareTo(min) < 0) {
										min = items[y];
										ytemp = y;
									}
								}
								items[ytemp] = "zzzzzzzzzzz";
								itemsT[u] = min;
								min = items[ytemp];
							}
							list.setListData(itemsT);
						} else {
							list.setListData(items);
						}
						list.setVisibleRowCount(10);
						list.setPrototypeCellValue("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa");
					}
				} else {
					JOptionPane op = new JOptionPane();
					op.showMessageDialog(this, "   Selezionare prima un mondo.", "Attenzione!", JOptionPane.WARNING_MESSAGE);
				}
			} else if (text.equals("Indietro")) {
				fr.setVisible(false);
				if (anteFrame != null) {
					anteFrame.setVisible(false);
				}
				new RubyRescueWorldParameters();
				Engine engine = new Engine(null, "changeWorld");
			} else if (text.equals("Esegui")) {
				if (list.getSelectedValue() != null) {
					try {
						setVisible(false);
						fr.setVisible(false);
						File file = new File(RubyRescueWorldExecution.MAP_PATH + list.getSelectedValue().toString());
						BufferedReader in = new BufferedReader(new FileReader(file));
						String line = in.readLine();
						StringTokenizer t = new StringTokenizer(line);
						int r = Integer.parseInt(t.nextToken());
						int c = Integer.parseInt(t.nextToken());
						anteFrame.setVisible(false);
						rrwc = new RubyRescueWorldCreation(r, c);
						int i = 0;
						while(i < r) {
							line = in.readLine();
							t = new StringTokenizer(line);
							int j = 0;
							while (j < c) {
								String cell = t.nextToken();
								if (cell.equals("wall")) {
									rrwc.cells[i][j].setIcon(rrwc.iconWall);
								}
								if (cell.equals("entry")) {
									rrwc.cells[i][j].setIcon(rrwc.iconEntry);
								}
								if (cell.equals("exit")) {
									rrwc.cells[i][j].setIcon(rrwc.iconExit);
								}
								if (cell.equals("empty")) {
									rrwc.cells[i][j].setIcon(rrwc.iconNull);
								}
								if (cell.equals("debris")) {
									rrwc.cells[i][j].setIcon(rrwc.iconDebrisNo);
								}
								if (cell.equals("debrisYes")) {
									rrwc.cells[i][j].setIcon(rrwc.iconDebrisYes);
								}
								j++;
							}
							i++;
							System.out.println("");
						}
						in.close();
						ActionEvent ev = new ActionEvent(new JButton("Fatto"), 12943, list.getSelectedValue().toString());
						rrwc.actionPerformed(ev);
						RegisterThread reg = new RegisterThread(this);
					} catch(Exception ax) {
						System.out.println("Errore in RRWCreation: " + ax.getMessage());
					}
				} else {
					JOptionPane op = new JOptionPane();
					op.showMessageDialog(this, "   Selezionare prima un mondo.", "Attenzione!", JOptionPane.WARNING_MESSAGE);
				}
			} else if (text.equals("Modifica")) {
				if (list.getSelectedValue() != null) {
					try {
						setVisible(false);
						fr.setVisible(false);
						File file = new File(RubyRescueWorldExecution.MAP_PATH + list.getSelectedValue().toString());
						BufferedReader in = new BufferedReader(new FileReader(file));
						String line = in.readLine();
						StringTokenizer t = new StringTokenizer(line);
						int r = Integer.parseInt(t.nextToken());
						int c = Integer.parseInt(t.nextToken());
						anteFrame.setVisible(false);
						rrwc = new RubyRescueWorldCreation(r, c);
						int i = 0;
						while(i < r) {
							line = in.readLine();
							t = new StringTokenizer(line);
							int j = 0;
							while (j < c) {
								String cell = t.nextToken();

								if (cell.equals("wall"))
									rrwc.cells[i][j].setIcon(rrwc.iconWall);
								if (cell.equals("entry"))
									rrwc.cells[i][j].setIcon(rrwc.iconEntry);
								if (cell.equals("exit"))
									rrwc.cells[i][j].setIcon(rrwc.iconExit);
								if (cell.equals("empty"))
									rrwc.cells[i][j].setIcon(rrwc.iconNull);
								if (cell.equals("debris"))
									rrwc.cells[i][j].setIcon(rrwc.iconDebrisNo);
								if (cell.equals("debrisYes"))
									rrwc.cells[i][j].setIcon(rrwc.iconDebrisYes);
								j++;
							}
							i++;
							System.out.println("");
						}
						in.close();

						RegisterThread reg = new RegisterThread(this);
					} catch(Exception ax) {
						System.out.println("Errore in RRWCreation: " + ax.getMessage());
					}
				} else {
					JOptionPane op = new JOptionPane();
					op.showMessageDialog(this, "   Selezionare prima un mondo.", "Attenzione!", JOptionPane.WARNING_MESSAGE);
				}
			} else { //Importa mondo
				fr = new JFrame("Importa mondo");
				fr.addWindowListener(this);
				Container c = fr.getContentPane();
				total2 = new JPanel();
				total2.setLayout(new BorderLayout());
				JPanel centerPanel = new JPanel();
				centerPanel.setLayout(new GridLayout(1, 2));
				centerPanel.setBorder(BorderFactory.createTitledBorder(
					BorderFactory.createCompoundBorder(
						BorderFactory.createEmptyBorder(20,20,20,20),
							BorderFactory.createEtchedBorder()),
								"Mondi nella directory principale del programma"));
				File file = new File( RubyRescueWorldExecution.MAP_PATH );
				String[] items = new String[1];
				FilenameFilter filter = new RubyRescueWorldFileFilter();
				items = file.list(filter);

				//Ordinamento files alfabetico
				String[]  itemsT = null;
				if (items.length > 0) {
					itemsT = new String[items.length];
					String min = items[0];
					int ytemp = 0;
					for (int u = 0; u < items.length; u++) {
						for (int y = 0; y < items.length; y++) {
							if ((items[y]).compareTo(min) < 0) {
								min = items[y];
								ytemp = y;
							}
						}
						items[ytemp] = "zzzzzzzzzzz";
						itemsT[u] = min;
						min = items[ytemp];
					}
					list = new JList(itemsT);
				} else {
					list = new JList(items);
				}
				list.setVisibleRowCount(10);
				list.setPrototypeCellValue("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa");
				list.addListSelectionListener(this);
				JScrollPane scrollList = new JScrollPane(list);

				//centerPanel.add(new JLabel());
				centerPanel.add(scrollList);
				JPanel buttonPanel = new JPanel();
				JButton modifyButton = new JButton("Modifica", iconModify);
				modifyButton.addActionListener(this);
				JButton deleteButton = new JButton("Cancella", iconDelete);
				deleteButton.addActionListener(this);
				JButton executeButton = new JButton("Esegui", iconExecute);
				executeButton.addActionListener(this);
				JButton returnButton = new JButton("Indietro");
				returnButton.addActionListener(this);

				buttonPanel.setLayout(new GridLayout(4, 3));
				buttonPanel.add(new JLabel());
				buttonPanel.add(modifyButton);
				buttonPanel.add(new JLabel());
				buttonPanel.add(new JLabel());
				buttonPanel.add(executeButton);
				buttonPanel.add(new JLabel());
				buttonPanel.add(new JLabel());
				buttonPanel.add(deleteButton);
				buttonPanel.add(new JLabel());
				buttonPanel.add(new JLabel());
				buttonPanel.add(returnButton);
				buttonPanel.add(new JLabel());
				centerPanel.add(buttonPanel);
				//centerPanel.add(new JLabel());
				total2.add(BorderLayout.NORTH, centerPanel);
				JPanel emptyPanel = new JPanel();
				emptyPanel.setBorder(BorderFactory.createTitledBorder(
					BorderFactory.createCompoundBorder(
						BorderFactory.createEmptyBorder(20,20,10,20),
							BorderFactory.createEtchedBorder()),
								"Anteprima"));
				total2.add(BorderLayout.CENTER, emptyPanel);
				c.add(total2);
				fr.setSize(w, h);
				fr.setVisible(true);
			}
		} catch(StringIndexOutOfBoundsException exc) { /* Gestione input scorretti. */
			JOptionPane op = new JOptionPane();
			if (exc.getMessage() != null) {
				op.showMessageDialog(this, "   Nessuna mappa salvata.", "Attenzione!", JOptionPane.WARNING_MESSAGE);
			}
		} catch(NumberFormatException exc) { /* Gestione input scorretti. */
			JOptionPane op = new JOptionPane();
			if (exc.getMessage() != null) {
				op.showMessageDialog(this, "   L'input non � corretto.", "Attenzione!", JOptionPane.WARNING_MESSAGE);
			}
		}
	}

	public void valueChanged(ListSelectionEvent e) {
		if (! ( ( ( (list.getSelectedValue() ).toString()).equals(lastSelection)))) {
			if (anteFrame != null) {
				anteFrame.setVisible(false);
			}
			lastSelection = list.getSelectedValue().toString();
			int i = 0, j = 0;
			try {
				File file = new File(RubyRescueWorldExecution.MAP_PATH + list.getSelectedValue().toString());
				BufferedReader in = new BufferedReader(new FileReader(file));
				String line = in.readLine();
				StringTokenizer t = new StringTokenizer(line);
				int r = Integer.parseInt(t.nextToken());
				int c = Integer.parseInt(t.nextToken());

				JPanel antePanel = new JPanel();
				antePanel.setLayout(new GridLayout(r, c));
				i = 0;
				while(i < r) {
					line = in.readLine();
					t = new StringTokenizer(line);
					j = 0;
					while (j < c) {
						String cell = t.nextToken();
						JLabel lb = new JLabel("");
						antePanel.add(lb);
						if (cell.equals("wall")) {
							lb.setIcon(iconWall);
						}
						if (cell.equals("entry")) {
							lb.setIcon(iconEntry);
						}
						if (cell.equals("exit")) {
							lb.setIcon(iconExit);
						}
						if (cell.equals("empty")) {
							lb.setIcon(iconNull);
						}
						if (cell.equals("debris")) {
							lb.setIcon(iconDebrisNo);
						}
						if (cell.equals("debrisYes")) {
							lb.setIcon(iconDebrisYes);
						}
						j++;
					}
					i++;
					System.out.println("");
				}
				in.close();
				anteFrame = new JFrame("Anteprima: " + list.getSelectedValue().toString());
				anteFrame.setUndecorated(true);
				anteFrame.getContentPane().add(antePanel);
				anteFrame.pack();
				int dimX = anteFrame.getSize().width;
				int dimY = anteFrame.getSize().height;
				int locX = (w / 2) - (dimX/2);
				int locY = (150*h/768) + (h / 2) - (dimY/2);
				anteFrame.setLocation(locX, locY);
				anteFrame.setVisible(true);
			} catch(Exception ax) {
				System.out.println("Errore in RRWPar: " + ax.getMessage() +", " + i + ", " + j);
			}
		}
	}

	public void windowDeactivated(WindowEvent e) {
		//if (anteFrame != null)
		//	anteFrame.setVisible(false);
	}

	public void windowActivated(WindowEvent e) {
	}

	public void windowDeiconified(WindowEvent e) {
		if (anteFrame != null) {
			anteFrame.setVisible(true);
		}
	}

	public void windowIconified(WindowEvent e) {
		if (anteFrame != null) {
			anteFrame.setVisible(false);
		}
	}

	public void windowClosed(WindowEvent e) {

	}

	public void windowOpened(WindowEvent e) {
		thisFrame.setVisible(false);
	}

	public void windowClosing(WindowEvent e) {
		thisFrame.setVisible(true);
		if (anteFrame != null) {
			anteFrame.setVisible(false);
		}
	}

}