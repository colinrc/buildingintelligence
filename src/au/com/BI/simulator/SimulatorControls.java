/*
 * Created on 24/05/2006
 *
 * 
 * Copyright Building Intelligence 2006
 */
package au.com.BI.simulator;
import java.awt.GridBagConstraints;
import java.awt.GridBagLayout;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.event.MouseAdapter;
import java.awt.event.MouseEvent;

import javax.swing.JButton;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JPanel;
import javax.swing.JScrollPane;
import javax.swing.JTextArea;

import au.com.BI.Command.Command;
import au.com.BI.Serial.SerialHandler;
/**
 * @author David
 *
 * 
 * 
 */
public class SimulatorControls extends JFrame implements ActionListener {
	private JTextArea networkTraffic;
	private JTextArea serialTraffic;
	private JPanel outgoing;
	private JButton PIROn;
	private JButton Temp20;
	private JButton Temp25;
	private JButton Light0;
	private JButton Light100;
	private JPanel incoming;
	private JButton B1Off;
	private JButton B1Green;
	private JButton B1Yellow;
	private JButton B2Off;
	private JButton B2Green;
	private JButton B2Yellow;
	private JButton B3Off;
	private JButton B3Green;
	private JButton B3Yellow;
	private JButton B4Off;
	private JButton B4Green;
	private JButton B4Yellow;
	private JButton eManOn;
	private JButton eManOff;
	private JButton wheelOn;
	private JButton wheelOff;
	private JButton wheelButtonOn;
	private JButton wheelButtonOff;
	private JButton BacklightOn;
	private JButton BacklightOff;
	private JButton getTemp;
	private JButton getLight;
	private GridBagLayout lm;
	private SimulatorWindow simulator;
	private String temp = "20";
	private String light = "0";
	private JLabel networkLab;
	private JLabel serialLab;
	private JLabel outboundLab;
	private JLabel inboundLab;
	//private ServerHandler serverHandle;
	private SerialHandler serialHandle;
	/**
	 * 
	 */
	public SimulatorControls(SimulatorWindow simulator) {
		super();
		this.simulator = simulator;
		this.setTitle("Control");
		this.setBounds(0, 0, 800, 600);
		//serverHandle = inServerHandler;
		addWindowListener(new java.awt.event.WindowAdapter() {
			public void windowClosed(java.awt.event.WindowEvent evt) {
				formWindowClosed(evt);
			}
			public void windowClosing(java.awt.event.WindowEvent evt) {
				exitForm(evt);
			}
		});
		this.setResizable(false);
		networkTraffic = new JTextArea(5,20);
		networkTraffic.setEditable(false);
		JScrollPane scrollPane = new JScrollPane(networkTraffic,
									   JScrollPane.VERTICAL_SCROLLBAR_ALWAYS,
									   JScrollPane.HORIZONTAL_SCROLLBAR_ALWAYS);
		serialTraffic = new JTextArea(5,20);
		serialTraffic.setEditable(false);
		JScrollPane scrollPane2 = new JScrollPane(serialTraffic,
									   JScrollPane.VERTICAL_SCROLLBAR_ALWAYS,
									   JScrollPane.HORIZONTAL_SCROLLBAR_ALWAYS);
		outgoing = new JPanel(new GridBagLayout());
		networkLab = new JLabel("Network Traffic:");
		serialLab = new JLabel("Serial Traffic:");
		inboundLab = new JLabel("Received RXTX Commands:");
		outboundLab = new JLabel("Internal RXTX Events:");
		PIROn = new JButton("Trigger PIR");
		PIROn.addMouseListener(new MouseAdapter(){
			public void mousePressed(MouseEvent e){
				outgoingSerial("PIROn");
			}
			public void mouseReleased(MouseEvent e){
				outgoingSerial("PIROff");
			}
		});
		
		Temp20 = new JButton("Set Temp 20");
		Temp20.setActionCommand("t20");
		Temp20.addActionListener(this);
		Temp25 = new JButton("Set Temp 25");
		Temp25.setActionCommand("t25");
		Temp25.addActionListener(this);
		Light0 = new JButton("Set Light 0");
		Light0.setActionCommand("l0");
		Light0.addActionListener(this);
		Light100 = new JButton("Set Light 100");
		Light100.setActionCommand("l100");
		Light100.addActionListener(this);
		incoming = new JPanel(new GridBagLayout());
		B1Off = new JButton("B1 Off");
		B1Off.setActionCommand("iB1Off");
		B1Off.addActionListener(this);
		B1Green = new JButton("B1 Green");
		B1Green.setActionCommand("iB1Green");
		B1Green.addActionListener(this);
		B1Yellow = new JButton("B1 Yellow");
		B1Yellow.setActionCommand("iB1Yellow");
		B1Yellow.addActionListener(this);
		B2Off = new JButton("B2 Off");
		B2Off.setActionCommand("iB2Off");
		B2Off.addActionListener(this);
		B2Green = new JButton("B2 Green");
		B2Green.setActionCommand("iB2Green");
		B2Green.addActionListener(this);
		B2Yellow = new JButton("B2 Yellow");
		B2Yellow.setActionCommand("iB2Yellow");
		B2Yellow.addActionListener(this);
		B3Off = new JButton("B3 Off");
		B3Off.setActionCommand("iB3Off");
		B3Off.addActionListener(this);
		B3Green = new JButton("B3 Green");
		B3Green.setActionCommand("iB3Green");
		B3Green.addActionListener(this);
		B3Yellow = new JButton("B3 Yellow");
		B3Yellow.setActionCommand("iB3Yellow");
		B3Yellow.addActionListener(this);
		B4Off = new JButton("B4 Off");
		B4Off.setActionCommand("iB4Off");
		B4Off.addActionListener(this);
		B4Green = new JButton("B4 Green");
		B4Green.setActionCommand("iB4Green");
		B4Green.addActionListener(this);
		B4Yellow = new JButton("B4 Yellow");
		B4Yellow.setActionCommand("iB4Yellow");
		B4Yellow.addActionListener(this);
		eManOn = new JButton("eMan On");
		eManOn.setActionCommand("ieManOn");
		eManOn.addActionListener(this);
		eManOff = new JButton("eMan Off");
		eManOff.setActionCommand("ieManOff");
		eManOff.addActionListener(this);
		wheelOn = new JButton("wheel On");
		wheelOn.setActionCommand("iwheelOn");
		wheelOn.addActionListener(this);
		wheelOff = new JButton("wheel Off");
		wheelOff.setActionCommand("iwheelOff");
		wheelOff.addActionListener(this);
		wheelButtonOn = new JButton("Wheel Button On");
		wheelButtonOn.setActionCommand("iwheelButtonOn");
		wheelButtonOn.addActionListener(this);
		wheelButtonOff = new JButton("Wheel Button Off");
		wheelButtonOff.setActionCommand("iwheelButtonOff");
		wheelButtonOff.addActionListener(this);
		BacklightOn = new JButton("Backlight On");
		BacklightOn.setActionCommand("iBacklightOn");
		BacklightOn.addActionListener(this);
		BacklightOff = new JButton("Backlight Off");
		BacklightOff.setActionCommand("iBacklightOff");
		BacklightOff.addActionListener(this);
		getTemp = new JButton("Poll Temp");
		getTemp.setActionCommand("getTemp");
		getTemp.addActionListener(this);
		getLight = new JButton("Poll Light");
		getLight.setActionCommand("getLight");
		getLight.addActionListener(this);
		lm = new GridBagLayout();
		this.setLayout(lm);
		GridBagConstraints c = new GridBagConstraints();
		c.gridwidth = GridBagConstraints.REMAINDER;
		c.fill = GridBagConstraints.BOTH;
		c.weightx = 1.0;
		c.weighty = 1.0;
		add(networkLab, c);
		add(scrollPane, c);
		add(serialLab, c);
		add(scrollPane2, c);
		c.fill = GridBagConstraints.BOTH;
		c.gridx = GridBagConstraints.RELATIVE;
		c.weighty = 0.20;
		c.weightx = 0.20;
		c.gridwidth = 5;
		outgoing.add(PIROn,c);
		outgoing.add(Temp20,c);
		outgoing.add(Temp25,c);
		outgoing.add(Light0,c);
		outgoing.add(Light100,c);
		c.weighty = 0.20;
		c.weightx = 1.00;
		c.gridwidth = 1;
		c.gridheight = 1;
		c.fill = GridBagConstraints.BOTH;
		c.gridwidth = GridBagConstraints.REMAINDER;
		this.add(outboundLab,c);
		this.add(outgoing,c);
		c.fill = GridBagConstraints.BOTH;
		c.weighty = 0.20;
		c.weightx = 0.20;
		c.gridwidth = 5;
		c.gridheight = 5;
		incoming.add(B1Off,c);
		incoming.add(B1Green,c);
		incoming.add(B1Yellow,c);
		incoming.add(B2Off,c);
		c.gridwidth = GridBagConstraints.REMAINDER;
		incoming.add(B2Green,c);
		c.gridwidth = 5;
		incoming.add(B2Yellow,c);
		incoming.add(B3Off,c);
		incoming.add(B3Green,c);
		incoming.add(B3Yellow,c);
		c.gridwidth = GridBagConstraints.REMAINDER;
		incoming.add(B4Off,c);
		c.gridwidth = 5;
		incoming.add(B4Green,c);
		incoming.add(B4Yellow,c);
		incoming.add(eManOn,c);
		incoming.add(eManOff,c);
		c.gridwidth = GridBagConstraints.REMAINDER;
		incoming.add(wheelOn,c);
		c.gridwidth = 5;
		incoming.add(wheelOff,c);
		incoming.add(wheelButtonOn,c);
		incoming.add(wheelButtonOff,c);
		incoming.add(BacklightOn,c);
		c.gridwidth = GridBagConstraints.REMAINDER;
		incoming.add(BacklightOff,c);
		c.gridwidth = 5;
		incoming.add(getTemp,c);
		incoming.add(getLight,c);
		c.gridheight =GridBagConstraints.REMAINDER;
		c.weighty = 1.0;
		c.weightx = 1.00;
		c.gridwidth = 1;
		c.gridheight = 1;
		c.gridwidth = GridBagConstraints.REMAINDER;
		c.fill = GridBagConstraints.BOTH;
		this.add(inboundLab,c);
		this.add(incoming,c);
	}
	private void formWindowClosed(java.awt.event.WindowEvent evt) {
		System.exit(0);
	}
	/** Exit the Application */
	private void exitForm(java.awt.event.WindowEvent evt) {
		this.dispose();
	}
	public void actionPerformed(ActionEvent e) {
		String prefix;
		String message; 
		prefix = e.getActionCommand().substring(0,1);
		message = e.getActionCommand().substring(1);
		if(prefix.equals("o")){
			outgoingSerial(message);
		} else if(prefix.equals("l")){
			light = message;
			variableSerial("LightLevel:"+message);
		} else if(prefix.equals("t")){
			temp = message;
			variableSerial("Temperature:"+message);
		}else if(e.getActionCommand().equals("getTemp")){
			incomingSerial(e.getActionCommand());
			outgoingSerial("Temp:"+temp);
		}else if(e.getActionCommand().equals("getLight")){
			incomingSerial(e.getActionCommand());
			outgoingSerial("Light:"+light);
		}else{
			incomingSerial(message);
		}
		
	}

	public void outgoingSerial(String inString){
		serialTraffic.append("Sent message: "+inString+"\n");
		serialHandle.processMessage(inString);
	}
	public void variableSerial(String inString){
		serialTraffic.append("Variable set: "+inString+"\n");
	}
	public void appendNetwork(String inString){
		networkTraffic.append(inString+"\n");
	}
	public void incomingSerial(String inString){
		serialTraffic.append("Received message: "+inString+"\n");
		simulator.receiveMessage(inString);
	}
	public void setSerialHandler(SerialHandler inSerialHandler){
		serialHandle = inSerialHandler;
	}
}
