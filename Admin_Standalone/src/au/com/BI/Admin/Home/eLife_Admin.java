package au.com.BI.Admin.Home;
import java.awt.BorderLayout;
import java.awt.Color;
import java.awt.Container;
import java.awt.Dimension;
import java.awt.Toolkit;

import javax.swing.BoxLayout;
import javax.swing.JFrame;



/*
 * Created on Jan 18, 2005
 *
 * Test harness to test eLife plugin
 */


public class eLife_Admin extends JFrame {
	protected Container contentsPane;

	/**
	 * 
	 */
	public eLife_Admin() {
		super ();
	    this.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
	    this.setPreferredSize(new Dimension(800,520));
	    this.pack();
	    this.setVisible(true);
		Admin eLife = new Admin(this);
	}

	public static void main(String[] args) {
		eLife_Admin testHarness = new eLife_Admin ();
	}
}
