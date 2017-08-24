package it.unito.di.islabs.ui;

import java.awt.*;
import java.awt.event.*;
import javax.swing.*;
import java.io.*;
import java.util.*;
import jess.*;
import java.lang.management.*;

class JLogoFrame extends JFrame {
	private static int WAIT = 30;
	public JLogoFrame() {
		setUndecorated(true);
		Container ct = getContentPane();
		JPanel total3 = new JPanel(new BorderLayout());
		JLabel logo = new JLabel( new ImageIcon( getClass().getResource("/image/logo.jpg").getPath() ) );
		JProgressBar bar = new JProgressBar(0, 100);
		bar.setString("Caricamento in corso...");
		bar.setStringPainted(true);
		//total3.add(BorderLayout.SOUTH, new JLabel("Caricamento in corso..."));
		total3.add(BorderLayout.CENTER, logo);
		total3.add(BorderLayout.SOUTH, bar);
		ct.add(total3);
		Toolkit kit = Toolkit.getDefaultToolkit();
		Dimension dim = kit.getScreenSize();
		int h = dim.height;
		int w = dim.width;
		pack();

		Dimension cur = getSize();
		setLocation((w - cur.width)/2, (h - cur.height)/2);
		setVisible(true);
		for (int i = 0; i < 100; i++) {
			bar.setValue(i);
			try {
				if ((i % 40) == 0) {
					Thread.sleep(WAIT * 4);
				}
				Thread.sleep(WAIT);
			} catch(Exception eer) {

			}
		}
		setVisible(false);
	}
}