/*
 * eLife_AdminToolPanel.java
 * part of the eLife_Admin plugin for the jEdit text editor
 */

import java.awt.event.*;

import javax.swing.*;

import org.gjt.sp.jedit.*;
import org.gjt.sp.jedit.gui.*;
import org.gjt.sp.jedit.io.*;
import org.gjt.sp.jedit.textarea.*;
import org.gjt.sp.jedit.msg.PropertiesChanged;
import org.gjt.sp.util.Log;

public class eLife_AdminToolPanel extends JPanel
{
	private eLife_Admin eLife;
	private JLabel label;

	public eLife_AdminToolPanel(eLife_Admin eLife)
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

	private AbstractButton makeCustomButton(String name, ActionListener listener)
	{
		String toolTip = jEdit.getProperty(name.concat(".label"));
		AbstractButton b = new RolloverButton(GUIUtilities.loadIcon(
			jEdit.getProperty(name + ".icon")));
		if(listener != null)
		{
			b.addActionListener(listener);
			b.setEnabled(true);
		}
		else
		{
			b.setEnabled(false);
		}
		b.setToolTipText(toolTip);
		return b;
	}

}

