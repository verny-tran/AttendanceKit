package org.main;

import java.awt.BorderLayout;
import java.awt.Dimension;
import java.awt.Font;

import javax.swing.JLabel;
import javax.swing.JPanel;

public class MainComponent extends JPanel {

    private static final long serialVersionUID = 7685549583249940652L;
    private GUI parent;
    private JLabel tagID;
    private String status;
    private Reader reader;

    public MainComponent(GUI g) {
        super();
        this.parent = g;
        setPreferredSize(new Dimension(540, 240));
        setLayout(new BorderLayout());

        this.status = "Currently not reading...";
        this.tagID = new JLabel(status);
        this.tagID.setFont(new Font("SF Mono", Font.PLAIN, 30));
        this.tagID.setHorizontalAlignment(JLabel.CENTER);
        add(tagID);
        this.reader = new Reader(this);
    }

    void updateLabel(String s) {
        this.tagID.setText(s);
    }
}