package au.com.BI.simulator.gui;


import javax.swing.*;

import au.com.BI.simulator.sims.Helper;
import au.com.BI.simulator.sims.SimulateDevice;
import au.com.BI.simulator.sims.Simulator;
import au.com.BI.simulator.util.Utility;

import java.util.*;


public class ControlType {
	   public final static int ALL=-1;
	   public final static int UNKNOWN=0;
	   public final static int CBUS=1;
	   public final static int RAW=2;
	   public final static int COMFORT=3;
	   public final static int GC100=4;
	   public final static int M1=5;
	   
	   protected JSlider slider = null;
	   protected JLabel light = null;
	   
	   protected boolean hasSlider = false;
	   
	   public final static int COMFORT_INPUT=10;
	   public final static int COMFORT_OUTPUT=11;
	   public final static int COMFORT_COUNTER=12;
	   public final static int COMFORT_CONTROLS=13;

	   public final static int M1_INPUT=20;
	   public final static int M1_OUTPUT=21;
	   public final static int M1_CONTROLS=22;
	   public final static int M1_TEMP=23;
	   
	   private int currentGroupType = UNKNOWN;
	   private int currentSubGroupType = UNKNOWN;
	   
	   protected SimulateDevice sim;
	   
	   public static int OFF = 0;
	   public static int ON = 1;
	   public static int CUSTOM = 2;
	   
	   private String key;
	   private String onString;
	   private String offString;
	   private String selectList = "";
	   private String title;
	   private boolean updatingSlider = false;
	   private boolean isControls = false;

	   protected JButton buttonOn = null;
	   protected JButton buttonOff = null;
	   protected JList list = null;
	   protected Vector controlTitles = null;
	   protected Vector controlCommands = null;
	   protected Vector controlObjects = null;
	   
	   public ControlType (SimulateDevice sim) {
		   this.sim = sim;
		   buttonOn = new JButton ();
		   slider = new JSlider(JSlider.HORIZONTAL,
                   0, 255, 0);
		   buttonOff = new JButton ();
		   controlCommands = new Vector (10);
		   controlTitles = new Vector (10);
		   controlObjects = new Vector(10);
	   }

	   public void addControl (String title, String command) {
		   controlCommands.add(command);
		   controlTitles.add(title);
	   }
	   
	   public JPanel drawPanel (Icon iconOn, Icon iconOff,Helper helper, GUI gui, Simulator simulator) {
		   
		   JPanel eachBox = new JPanel();
		   eachBox.setAlignmentY(SwingConstants.TOP);
		   JLabel name = new JLabel (getTitle());
		   name.setAlignmentY(JComponent.TOP_ALIGNMENT);
		   eachBox.setLayout (new BoxLayout (eachBox, BoxLayout.Y_AXIS));
		   eachBox.setBorder(BorderFactory.createEtchedBorder() );
		   eachBox.add( name);

		   if (this.isControls) {
			   for (int i = 0; i < controlCommands.size(); i ++){
				   try {
				   JButton control = new JButton ();
				   control.setText((String)controlTitles.get(i));
				   control.setActionCommand((String)controlCommands.get(i));
				   control.setEnabled (false);
				   control.addActionListener(new ButtonPressed(ControlType.CUSTOM,helper,simulator,gui,this));
				   control.setAlignmentX(JComponent.CENTER_ALIGNMENT);
				   controlObjects.add(control);
				   eachBox.add(control);
				   } catch (ArrayIndexOutOfBoundsException ex){
					   System.out.println ("Error in configuration for control " + this.getTitle() + " title not present for pair " + i);
				   }
			   }
		   } else {
			   JLabel pic = new JLabel (iconOff);
			   pic.setAlignmentX(JComponent.CENTER_ALIGNMENT);
			   eachBox.add(pic);

			   setLight(pic);
			   
			   if (hasSlider) {
				   setSlider(slider);
				   slider.setMajorTickSpacing(10);
				   slider.setPaintTicks(true);
				   slider.setPaintLabels(false);
				   slider.setSnapToTicks(false);
				   slider.setEnabled(false);
				   slider.addChangeListener(new SliderChanged (helper,simulator,gui,this));
				   slider.setAlignmentX(JComponent.CENTER_ALIGNMENT);
				   eachBox.add(slider);
	
			   } else {
				   buttonOn.setText("On");
				   buttonOn.setActionCommand("ON");
				   buttonOn.setEnabled(false);
				   buttonOn.setAlignmentX(JComponent.CENTER_ALIGNMENT);
				   buttonOn.addActionListener(new ButtonPressed(ControlType.ON,helper,simulator,gui,this));
				   eachBox.add(buttonOn);
			   }
	
	
			   buttonOff.setText("Off");
			   buttonOff.setActionCommand("OFF");
			   buttonOff.setEnabled(false);
			   buttonOff.setAlignmentX(JComponent.CENTER_ALIGNMENT);
			   buttonOff.addActionListener(new ButtonPressed(ControlType.OFF,helper,simulator,gui,this));
			   eachBox.add(buttonOff);
		   }

		   return eachBox;
	   }
	   
	   public ControlType(String groupType,String subGroupType) {
		  this.setGroupType (groupType,subGroupType);  
	   }
	   
	   private class StatusUpdater implements Runnable  {
		   private int connectionStatus;
		   
		   public StatusUpdater (int connectionStatus) {
			   this.connectionStatus = connectionStatus;
		   }
		   
		   public void run() {
			   // CC do something with it
			   if (connectionStatus == Helper.CONNECTED) {
				   if (isControls){
					   Iterator eachControl = controlObjects.iterator();
					   while (eachControl.hasNext()){
						   JButton control = (JButton)eachControl.next();
						   control.setEnabled(true);
					   }
				   }else {
					   buttonOff.setEnabled(true);
					   if (hasSlider)
						   slider.setEnabled(true);
					   else
						   buttonOn.setEnabled (true);
				   }
			   }  else {
				   if (isControls){
					   Iterator eachControl = controlObjects.iterator();
					   while (eachControl.hasNext()){
						   JButton control = (JButton)eachControl.next();
						   control.setEnabled(false);
					   }
				   }else {
					   buttonOff.setEnabled(false);
					   if (hasSlider)
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
	   
	   public void setGroupType(String typeStr,String subTypeStr) {
		   if (typeStr== null || typeStr.equals("")) {
			   currentGroupType = UNKNOWN;
		   }
		   if (typeStr.equals("ALL")) {
			   currentGroupType = ALL;
		   }
		   if (typeStr.equals("CBUS")) {
			   currentGroupType =  CBUS;
		   }
		   if (typeStr.equals("RAW")) {
			   currentGroupType =  RAW;
		   }
		   if (typeStr.equals("GC100")) {
			   currentGroupType =  GC100;
		   }
		   if (typeStr.equals("COMFORT")) {
			   currentGroupType =  COMFORT;
			   if (subTypeStr.equals("INPUT")) {
				   currentSubGroupType = COMFORT_INPUT;
			   }
			   if (subTypeStr.equals("OUTPUT")) {
				   currentSubGroupType = COMFORT_OUTPUT;
			   }
			   if (subTypeStr.equals("COUNTER")) {
				   currentSubGroupType = COMFORT_COUNTER;
			   }
			   if (subTypeStr.equals("CONTROLS")) {
				   currentSubGroupType = COMFORT_CONTROLS;
				   isControls = true;
			   }
		   }
		   if (typeStr.equals("M1")) {
			   currentGroupType =  M1;
			   if (subTypeStr.equals("INPUT")) {
				   currentSubGroupType = M1_INPUT;
			   }
			   if (subTypeStr.equals("OUTPUT")) {
				   currentSubGroupType = M1_OUTPUT;
			   }
			   if (subTypeStr.equals("CONTROLS")) {
				   currentSubGroupType = M1_CONTROLS;
				   isControls = true;
			   }
			   if (subTypeStr.equals("TEMP")) {
				   currentSubGroupType = M1_TEMP;
				   isControls = true;
			   }
		   }

	   }
	   
	   public String toString () {
		   switch (currentGroupType) {
	   			case ALL :
					return "ALL";
				
		   		case CBUS :
					return "CBUS";
				
		   		case GC100 :
					return "GC100";
				
		   		case RAW :
					return "RAW";
		   
		   		case COMFORT :
					return "COMFORT";
					
					   
		   		case M1 :
					return "M1";

				default :
					return "";
		   }
	   }
	   
	   
	   public String toString (int groupType) {
		   switch (groupType) {
	   			case ALL :
					return "ALL";
				
		   		case CBUS :
					return "CBUS";
				
		   		case RAW :
					return "RAW";
		   
		   		case COMFORT :
					return "COMFORT";


				default :
					return "";
		   }
	   }
	   
	   public int getGroupType () {
		   return currentGroupType;
	   }
	   
	   
	   public int getSubGroupType () {
		   return currentSubGroupType;
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
		return hasSlider;
	}

	public void setHasSlider(boolean hasSlider) {
		this.hasSlider = hasSlider;
	}

	public String getKey() {
		return key;
	}

	public void setKey(String key) {
		if (this.isControls()) {
			String commands[] = key.split(",");
			for (int i = 0; i < commands.length; i ++){
				String parts[] = commands[i].split(":");
				this.addControl(parts[1],parts[0]);
			}
		} else {
			this.key = key;
		}
	}

	public String getOffString() {
		return offString;
	}

	public void setOffString(String offString) {
		this.offString = Utility.parseString(offString);
	}

	public String getOnString() {
		return onString;
	}

	public void setOnString(String onString) {
		this.onString = Utility.parseString(onString);
	}

	public String getTitle() {
		return title;
	}

	public void setTitle(String title) {
		this.title = title;
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
		return isControls;
	}

	public void setControls(boolean isSelection) {
		this.isControls = isSelection;
	}
   }