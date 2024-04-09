package org.main;

import org.util.FirebaseConfiguration;

import javax.swing.*;
import java.awt.*;

public class GUI extends JFrame {
    public GUI() {
        super();
        setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        setTitle("RFID Dashboard");
        setLocationRelativeTo(null);
        add(new MainComponent(this));
        pack();
        setVisible(true);
    }
    private static final long serialVersionUID = 8824695393479125574L;

    public static void main(String[] args) {
        EventQueue.invokeLater(GUI::new);

        new FirebaseConfiguration().initFirebase();
    }
}
