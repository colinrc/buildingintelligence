package au.com.BI.Admin.GUI;
/*
 * eLife_AdminToolPanel.java
 * part of the eLife_Admin plugin for the jEdit text editor
 */

import au.com.BI.Admin.Home.Admin;
import javax.swing.*;


public class eLife_AdminToolPanel extends JPanel
{
	private Admin eLife;
	private JLabel label;

	public eLife_AdminToolPanel(Admin eLife)
	{
		setLayout(new BoxLayout(this,BoxLayout.X_AXIS));
		this.eLife = eLife;

		Box labelBox = new Box(BoxLayout.Y_AXIS);
		labelBox.add(Box.createGlue());

		label = new JLabel("eLife");

		labelBox.add(label);
		labelBox.add(Box.createGlue());

		add(labelBox);

		add(Box.createGlue());


	}


	void propertiesChanged()
	{

	}

}

