package it.unito.di.islabs.ui;

import java.io.File;
import java.io.FilenameFilter;

public class RubyRescueWorldFileFilter implements FilenameFilter {
	public boolean accept(File f, String s) {
		String sub = s.substring(s.length()-3, s.length());
		return sub.equals("rub");
	}
}