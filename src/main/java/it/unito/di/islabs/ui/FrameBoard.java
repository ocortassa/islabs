package it.unito.di.islabs.ui;

import java.awt.*;
import java.awt.event.*;
import javax.swing.*;

public class FrameBoard extends JFrame implements ActionListener, Viewer {
	private static JFrame frame = null;
	private static JTextArea area = null;
	private static JScrollPane scrollPane = null;

	public FrameBoard(String title, JTextArea content) {
		super(title);

		//System.gc(); // Richiamo forzato del garbage collector
		if (frame == null) {
			frame = this;
			area = content;
			Container c = getContentPane();
			JPanel total = new JPanel();
			scrollPane = new JScrollPane(content);
			total.setLayout(new BorderLayout());
			total.add(BorderLayout.CENTER, scrollPane);
			JButton exitButton = new JButton("Esci");
			exitButton.addActionListener(this);
			JPanel exitPanel = new JPanel();
			exitPanel.add(exitButton);
			total.add(BorderLayout.SOUTH, exitPanel);
			c.add(total);
			setLocation(200, 200);
			setSize(500, 500);
			content.setSize(500, 500);
			setVisible(true);
		} else {
			frame.setVisible(true);
		}
	}

	public void actionPerformed(ActionEvent e)
	{
		frame.setVisible(false);
	}

	public void updateBoard(String t, boolean r) {
		if (r) {
			area.setText("\n" + t);
		} else {
			area.append("\n" + t);
		}
		JViewport vp = scrollPane.getViewport();
		vp.setViewPosition(new Point(0,vp.getView().getHeight()));
	}

}

