package it.unito.di.islabs.ui;

import javax.swing.*;
import java.awt.Image;
import java.awt.Toolkit;
import java.io.*;

public class ResourceLoader {

    public static Image loadImage(Class clazz, String imagePath) {
        // getClass().getResource("/image/logo.jpg").getPath() );
        // getClass().getResource("/image/logo.jpg").getPath() );
        return Toolkit.getDefaultToolkit().getImage(clazz.getResource(imagePath));
    }

    public static ImageIcon loadImageIcon(Class clazz, String imagePath) {
        return loadImageIcon(clazz, imagePath, "");
    }

    public static ImageIcon loadImageIcon(Class clazz, String imagePath, String label) {
        if (label != null && label.length() > 0) {
            return new ImageIcon(Toolkit.getDefaultToolkit().getImage(clazz.getResource(imagePath)), label);
        } else {
            return new ImageIcon(Toolkit.getDefaultToolkit().getImage(clazz.getResource(imagePath)));
        }
    }

    public static BufferedReader loadResource(Class clazz, String resourcePath) {
        InputStream in = clazz.getResourceAsStream(resourcePath);
        return new BufferedReader(new InputStreamReader(in));
    }

    public static String getRubyDataFile() {
        return getDataFile("Ruby.clp");
    }

    public static String getDataFile(String fileName) {
        return System.getProperty("java.io.tmpdir") + File.separator + fileName;
    }

    public static File createRubyDataFile() {
        return new File( getRubyDataFile() );
    }

    public static File createRubyClipsDataFile() {
        return new File(getDataFile("RubyClips.clp"));
    }


}
