package au.com.BI.simulator.gui;


import javax.swing.*;
import au.com.BI.simulator.sims.Simulator;
import au.com.BI.simulator.sims.Helper;
import au.com.BI.simulator.sims.SimulateDevice;

import java.util.*;
import static au.com.BI.simulator.conf.Control.*;
import au.com.BI.simulator.conf.Control;

public class GUIPanel {
	   protected JSlider slider = null;
	   protected JLabel light = null;
	   
	   protected SimulateDevice sim;	   
	   private String selectList = "";
	   private boolean updatingSlider = false;

	   protected JButton buttonOn = null;
	   protected JButton buttonOff = null;
	   protected JList list = null;
	   protected Vector<javax.swing.JComponent> controlObjects = null;
	   protected Control control;
	   
	   public GUIPanel (SimulateDevice sim, Control control) {
		   this.sim = sim;
		   buttonOn = new JButton ();
		   slider = new JSlider(JSlider.HORIZONTAL,
                   0, 255, 0);
		   buttonOff = new JButton ();
		   controlObjects = new Vector<javax.swing.JComponent>(10);
		   this.control = control;
	   }
	   
	   public JPanel drawPanel (Icon iconOn, Icon iconOff,Helper helper, GUI gui, Simulator simulator) {
		   
		   JPanel eachBox = new JPanel();
		   eachBox.setAlignmentY(SwingConstants.TOP);
		   JLabel name = new JLabel (getTitle());
		   name.setAlignmentY(JComponent.TOP_ALIGNMENT);
		   eachBox.setLayout (new BoxLayout (eachBox, BoxLayout.Y_AXIS));
		   eachBox.setBorder(BorderFactory.createEtchedBorder() );
		   eachBox.add( name);

		   if (this.isControls()) {
			    Map<String,String> eachControl = control.getControlKeyPairs();
			   for (String key: eachControl.keySet()) {
				   JButton jButton = new JButton ();
				   jButton.setText(eachControl.get(key));
				   jButton.setActionCommand(key);
				   jButton.setEnabled (true);
				   jButton.addActionListener(new ButtonPressed(ControlStates.CUSTOM,helper,simulator,gui,this,control));
				   jButton.setAlignmentX(JComponent.CENTER_ALIGNMENT);
				   controlObjects.add(jButton);
				   eachBox.add(jButton);
			   }
		   } else {
			   JLabel pic = new JLabel (iconOff);
			   pic.setAlignmentX(JComponent.CENTER_ALIGNMENT);
			   eachBox.add(pic);

			   setLight(pic);
			   
			   if (this.isHasSlider()){
				   setSlider(slider);
				   slider.setMajorTickSpacing(10);
				   slider.setPaintTicks(true);
				   slider.setPaintLabels(false);
				   slider.setSnapToTicks(false);
				   slider.setEnabled(true);
				   slider.addChangeListener(new SliderChanged (helper,simulator,gui,this,control));
				   slider.setAlignmentX(JComponent.CENTER_ALIGNMENT);
				   eachBox.add(slider);
	
			   } else {
				   buttonOn.setText("On");
				   buttonOn.setActionCommand("ON");
				   buttonOn.setEnabled(true);
				   buttonOn.setAlignmentX(JComponent.CENTER_ALIGNMENT);
				   buttonOn.addActionListener(new ButtonPressed(ControlStates.ON,helper,simulator,gui,this,control));
				   eachBox.add(buttonOn);
			   }
	
	
			   buttonOff.setText("Off");
			   buttonOff.setActionCommand("OFF");
			   buttonOff.setEnabled(true);
			   buttonOff.setAlignmentX(JComponent.CENTER_ALIGNMENT);
			   buttonOff.addActionListener(new ButtonPressed(ControlStates.OFF,helper,simulator,gui,this,control));
			   eachBox.add(buttonOff);
		   }

		   return eachBox;
	   }
	   
	   public GUIPanel (Control control) {
		   this.control = control;
	   }
	   
	   private class StatusUpdater implements Runnable  {
		   private int connectionStatus;
		   
		   public StatusUpdater (int connectionStatus) {
			   this.connectionStatus = connectionStatus;
		   }
		   
		   public void run() {
			   // CC do something with it
			   if (connectionStatus == Helper.CONNECTED) {
				   if (isControls()){
					   Iterator eachControl = controlObjects.iterator();
					   while (eachControl.hasNext()){
						   JButton control = (JButton)eachControl.next();
						   control.setEnabled(true);
					   }
				   }else {
					   buttonOff.setEnabled(true);
					   if (isHasSlider())
						   slider.setEnabled(true);
					   else
						   buttonOn.setEnabled (true);
				   }
			   }  else {
				   if (isControls()){
					   Iterator eachControl = controlObjects.iterator();
					   while (eachControl.hasNext()){
						   JButton jButton = (JButton)eachControl.next();
						   jButton.setEnabled(false);
					   }
				   }else {
					   buttonOff.setEnabled(false);
					   if (isHasSlider())
						   slider.setEnabled(false);
					   else
						   buttonOn.setEnabled (false);
				   }
			   }
		   }
	   }
	   
	   public void changeStatus (int connectionStatus){
			  StatusUpdater updater = new StatusUpdater (connectionStatus);
		      SwingUtilities.invokeLater(updater);   
	   }
	   

	public JLabel getLight() {
		return light;
	}

	public void setLight(JLabel light) {
		this.light = light;
	}

	public JSlider getSlider() {
		return slider;
	}

	public void setSlider(JSlider slider) {
		this.slider = slider;
	}

	public boolean isHasSlider() {
		if (control != null )
			return control.isHasSlider();
		else
			return false;
	}

	public String getKey() {
		if (control != null)
			return control.getKey();
		else 
			return "";
	}

	public String getOffString() {
		if (control != null)
			return control.getKeyOff();
		else 
			return "";
	}

	public String getOnString() {
		if (control != null)
			return control.getKeyOn();
		else 
			return "";
	}

	public String getTitle() {
		if (control != null)
			return control.getTitle();
		else 
			return "";
	}

	public SimulateDevice getSim() {
		return sim;
	}

	public void setSim(SimulateDevice sim) {
		this.sim = sim;
	}

	public boolean isUpdatingSlider() {
		return updatingSlider;
	}

	public void setUpdatingSlider(boolean updatingSlider) {
		this.updatingSlider = updatingSlider;
	}

	public String getSelectList() {
		return selectList;
	}

	public void setSelectList(String selectList) {
		this.selectList = selectList;
	}

	public boolean isControls() {
		if (control != null) {
			return control.isControls();
		} else {
			return false;
		}
	}

	public Control getControl() {
		return control;
	}

	public void setControl(Control control) {
		this.control = control;
	}

   }