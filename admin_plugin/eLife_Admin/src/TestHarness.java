import java.awt.BorderLayout;
import java.awt.Color;
import java.awt.Container;
import java.awt.Dimension;
import java.awt.Toolkit;

import javax.swing.BoxLayout;
import javax.swing.JFrame;

import org.gjt.sp.jedit.gui.DockableWindowManager;


/*
 * Created on Jan 18, 2005
 *
 * Test harness to test eLife plugin
 */


public class TestHarness extends JFrame {
	protected Container contentsPane;

	/**
	 * 
	 */
	public TestHarness() {
		super ();
	    this.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
	    
		eLife_Admin eLife = new eLife_Admin(this,DockableWindowManager.FLOATING);
	}

	public static void main(String[] args) {
		TestHarness testHarness = new TestHarness ();
	}
}
