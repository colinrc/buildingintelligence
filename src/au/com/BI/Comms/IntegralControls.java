/*
 * Created on 24/05/2006
 *
 * 
 * Copyright Building Intelligence 2006
 */
package au.com.BI.Comms;
import java.awt.GridBagConstraints;
import java.awt.GridBagLayout;
import java.awt.Toolkit;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import javax.swing.JButton;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JPanel;
import javax.swing.JScrollPane;
import javax.swing.JTextArea;
import javax.swing.JTextField;
/**
 * @author David
 *
 * 
 * 
 */
public class IntegralControls extends JFrame implements ActionListener {
	private JTextArea outTraffic;
	private JTextArea inTraffic;
	private JPanel incoming;
	/*LIGHT Controls*/
	private JButton L1Off;
	private JButton L1Blue;
	private JButton L1Yellow;
	private JButton L1Query;
	private JButton L2Off;
	private JButton L2Blue;
	private JButton L2Yellow;
	private JButton L2Query;
	private JButton L3Off;
	private JButton L3Blue;
	private JButton L3Yellow;
	private JButton L3Query;
	/*Button Controls*/
	private JButton K1Query;
	private JButton K2Query;
	private JButton K3Query;
	/*Brightness Controls*/
	private JTextField B0Value; /*LCD*/
	private JButton B0Change;
	private JTextField B1Value; /*Buttons*/
	private JButton B1Change;
	/*Audio Controls*/
	private JButton A1Off;
	private JButton A1On;
	private JButton A2Off;
	private JTextField A2Value;
	private JButton A2Change;
	private JButton A2Inc;
	private JButton A2Dec;
	private JButton A3Off;
	private JTextField A3Value;
	private JButton A3Change;
	private JButton A3Inc;
	private JButton A3Dec;
	/*Environment Controls*/
	private JButton E0Query;
	private JButton E1Query;
	private JButton E2Query;
	private JButton E3On;
	private JButton E3Off;
	private JButton E3Query;
	/*PIR Controls*/
	private JButton P0Query;
	/*System Controls*/
	private JButton Z0Query;
	private GridBagLayout lm;
	private JLabel toLab;
	private JLabel fromLab;
	private JLabel inboundLab;
	private JScrollPane scrollPane;
	private JScrollPane scrollPane2;
	private ComControl serialHandle;
	/**
	 * 
	 */
	public IntegralControls() {
		this.setTitle("Integral Controls");
		this.setBounds(
			0,
			0,
			Toolkit.getDefaultToolkit().getScreenSize().width,
			Toolkit.getDefaultToolkit().getScreenSize().height);
		addWindowListener(new java.awt.event.WindowAdapter() {
			public void windowClosed(java.awt.event.WindowEvent evt) {
				formWindowClosed(evt);
			}
			public void windowClosing(java.awt.event.WindowEvent evt) {
				exitForm(evt);
			}
		});
		this.setResizable(false);
		this.setState(JFrame.MAXIMIZED_BOTH);
		outTraffic = new JTextArea(5, 20);
		outTraffic.setEditable(false);
		scrollPane =
			new JScrollPane(
				outTraffic,
				JScrollPane.VERTICAL_SCROLLBAR_ALWAYS,
				JScrollPane.HORIZONTAL_SCROLLBAR_ALWAYS);
		inTraffic = new JTextArea(5, 20);
		inTraffic.setEditable(false);
		scrollPane2 =
			new JScrollPane(
				inTraffic,
				JScrollPane.VERTICAL_SCROLLBAR_ALWAYS,
				JScrollPane.HORIZONTAL_SCROLLBAR_ALWAYS);
		incoming = new JPanel();
		incoming.setLayout(new GridBagLayout());
		toLab = new JLabel("Traffic to Board:");
		fromLab = new JLabel("Traffic from Board:");
		inboundLab = new JLabel("RXTX Commands:");
		/*LIGHT Controls*/
		L1Off = new JButton("L1 Off");
		L1Off.setActionCommand("L1 O");
		L1Off.addActionListener(this);
		L1Blue = new JButton("L1 Blue");
		L1Blue.setActionCommand("L1 B");
		L1Blue.addActionListener(this);
		L1Yellow = new JButton("L1 Yellow");
		L1Yellow.setActionCommand("L1 Y");
		L1Yellow.addActionListener(this);
		L1Query = new JButton("L1 Query");
		L1Query.setActionCommand("L1 ?");
		L1Query.addActionListener(this);
		L2Off = new JButton("L2 Off");
		L2Off.setActionCommand("L2 O");
		L2Off.addActionListener(this);
		L2Blue = new JButton("L2 Blue");
		L2Blue.setActionCommand("L2 B");
		L2Blue.addActionListener(this);
		L2Yellow = new JButton("L2 Yellow");
		L2Yellow.setActionCommand("L2 Y");
		L2Yellow.addActionListener(this);
		L2Query = new JButton("L2 Query");
		L2Query.setActionCommand("L2 ?");
		L2Query.addActionListener(this);
		L3Off = new JButton("L3 Off");
		L3Off.setActionCommand("L3 O");
		L3Off.addActionListener(this);
		L3Blue = new JButton("L3 Blue");
		L3Blue.setActionCommand("L3 B");
		L3Blue.addActionListener(this);
		L3Yellow = new JButton("L3 Yellow");
		L3Yellow.setActionCommand("L3 Y");
		L3Yellow.addActionListener(this);
		L3Query = new JButton("L3 Query");
		L3Query.setActionCommand("L3 ?");
		L3Query.addActionListener(this);
		/*Button Controls*/
		K1Query = new JButton("Key 1 Query");
		K1Query.setActionCommand("K1 ?");
		K1Query.addActionListener(this);
		K2Query = new JButton("Key 2 Query");
		K2Query.setActionCommand("K2 ?");
		K2Query.addActionListener(this);
		K3Query = new JButton("Key 3 Query");
		K3Query.setActionCommand("K3 ?");
		K3Query.addActionListener(this);
		/*Brightness Controls*/
		B0Value = new JTextField();
		B0Change = new JButton("LCD Bright Change");
		B0Change.addActionListener(this);
		B1Value = new JTextField();
		B1Change = new JButton("Halo Bright Change");
		B1Change.addActionListener(this);
		/*Audio Controls*/
		A1Off = new JButton("O/Board Spk Off");
		A1Off.setActionCommand("A1 O");
		A1Off.addActionListener(this);
		A1On = new JButton("O/Board Spk On");
		A1On.setActionCommand("A1 I");
		A1On.addActionListener(this);
		A2Off = new JButton("TO intercom Off");
		A2Off.setActionCommand("A2 O");
		A2Off.addActionListener(this);
		A2Value = new JTextField();
		A2Change = new JButton("TO intercom Change");
		A2Change.addActionListener(this);
		A2Inc = new JButton("TO intercom +");
		A2Inc.setActionCommand("A2 +");
		A2Inc.addActionListener(this);
		A2Dec = new JButton("TO intercom -");
		A2Dec.setActionCommand("A2 -");
		A2Dec.addActionListener(this);
		A3Off = new JButton("FROM intercom Off");
		A3Off.setActionCommand("A3 O");
		A3Off.addActionListener(this);
		/*A3Min = new JButton("FROM intercom Min");
		A3Min.setActionCommand("A3 1");
		A3Min.addActionListener(this);*/
		A3Value = new JTextField();
		A3Change = new JButton("FROM intercom Change");
		//A3Change.setActionCommand("A3 99");
		A3Change.addActionListener(this);
		A3Inc = new JButton("FROM intercom +");
		A3Inc.setActionCommand("A3 +");
		A3Inc.addActionListener(this);
		A3Dec = new JButton("FROM intercom -");
		A3Dec.setActionCommand("A3 -");
		A3Dec.addActionListener(this);
		/*Environment Controls*/
		E0Query = new JButton("Query Light");
		E0Query.setActionCommand("E0 ?");
		E0Query.addActionListener(this);
		E1Query = new JButton("Query Room Temp");
		E1Query.setActionCommand("E1 ?");
		E1Query.addActionListener(this);
		E2Query = new JButton("Query Case Temp");
		E2Query.setActionCommand("E2 ?");
		E2Query.addActionListener(this);		
		E3On = new JButton("Case Fan On");
		E3On.setActionCommand("E3 I");
		E3On.addActionListener(this);
		E3Off = new JButton("Case Fan Off");
		E3Off.setActionCommand("E3 O");
		E3Off.addActionListener(this);				
		E3Query = new JButton("Query Fan Temp");
		E3Query.setActionCommand("E3 ?");
		E3Query.addActionListener(this);
		/*PIR Controls*/
		P0Query = new JButton("Query PIR");
		P0Query.setActionCommand("P0 ?");
		P0Query.addActionListener(this);
		/*System Controls*/
		Z0Query = new JButton("Query HW Rev");
		Z0Query.setActionCommand("Z0 ?");
		Z0Query.addActionListener(this);
		lm = new GridBagLayout();
		this.setLayout(lm);
		GridBagConstraints c = new GridBagConstraints();
		c.gridwidth = GridBagConstraints.REMAINDER;
		c.fill = GridBagConstraints.BOTH;
		c.weightx = 1.0;
		c.weighty = 1.0;
		add(toLab, c);
		add(scrollPane, c);
		add(fromLab, c);
		add(scrollPane2, c);
		c.fill = GridBagConstraints.BOTH;
		c.gridx = GridBagConstraints.RELATIVE;
		c.weighty = 1.0;
		c.weightx = 1.0;
		c.gridheight = 1;
		c.gridwidth = 1;
		c.weightx = 0.25;
		/*NEW Row*/
		c.gridy = 0;
		c.gridx = 0;
		incoming.add(L1Off, c);
		c.gridx = 1;
		incoming.add(L1Blue, c);
		c.gridx = 2;
		incoming.add(L1Yellow, c);
		c.gridx = 3;
		incoming.add(L1Query, c);
		/*NEW Row*/
		c.gridy = 1;
		c.gridx = 0;
		incoming.add(L2Off, c);
		c.gridx = 1;
		incoming.add(L2Blue, c);
		c.gridx = 2;
		incoming.add(L2Yellow, c);
		c.gridx = 3;
		incoming.add(L2Query, c);
		/*NEW Row*/
		c.gridy = 2;
		c.gridx = 0;
		incoming.add(L3Off, c);
		c.gridx = 1;
		incoming.add(L3Blue, c);
		c.gridx = 2;
		incoming.add(L3Yellow, c);
		c.gridx = 3;
		incoming.add(L3Query, c);
		/*NEW Row*/
		c.gridy = 3;
		c.gridx = 0;
		incoming.add(new JLabel("LCD Bright Value:"), c);		
		c.gridx = 1;
		incoming.add(B0Value, c);
		c.gridx = 2;
		incoming.add(B0Change, c);
		c.gridx = 3;
		incoming.add(new JLabel("Halo Bright Value:"), c);
		c.gridx = 4;
		incoming.add(B1Value, c);
		c.gridx = 5;
		incoming.add(B1Change, c);
		/*NEW Row*/
		c.gridy = 4;
		c.gridx = 0;
		incoming.add(A1Off, c);
		c.gridx = 1;
		incoming.add(A1On, c);
		/*NEW Row*/
		c.gridy = 5;
		c.gridx = 0;
		incoming.add(A2Off, c);
		c.gridx = 1;
		incoming.add(new JLabel("FROM intercom Value:"), c);
		c.gridx = 2;
		incoming.add(A2Value, c);
		c.gridx = 3;
		incoming.add(A2Change, c);
		c.gridx = 4;
		incoming.add(A2Inc, c);
		c.gridx = 5;
		incoming.add(A2Dec, c);
		/*NEW Row*/
		c.gridy = 6;
		c.gridx = 0;
		incoming.add(A3Off, c);
		c.gridx = 1;
		incoming.add(new JLabel("TO intercom Value:"), c);
		c.gridx = 2;
		incoming.add(A3Value, c);
		c.gridx = 3;
		incoming.add(A3Change, c);
		c.gridx = 4;
		incoming.add(A3Inc, c);
		c.gridx = 5;
		incoming.add(A3Dec, c);
		/*NEW Row*/
		c.gridy = 7;
		c.gridx = 0;
		incoming.add(K1Query, c);
		c.gridx = 1;
		incoming.add(K2Query, c);
		c.gridx = 2;
		incoming.add(K3Query, c);
		c.gridx = 3;
		incoming.add(P0Query, c);
		c.gridx = 4;
		incoming.add(Z0Query, c);
		/*NEW Row*/
		c.gridy = 8;
		c.gridx = 0;
		incoming.add(E0Query, c);
		c.gridx = 1;
		incoming.add(E1Query, c);
		c.gridx = 2;
		incoming.add(E2Query, c);
		c.gridy = 9;
		c.gridx = 0;
		incoming.add(E3On,c);
		c.gridx = 1;
		incoming.add(E3Off,c);
		c.gridx = 2;
		incoming.add(E3Query, c);
		/*NEW Row*/
		c.gridy = 10;
		c.gridx = 0;
		c.gridwidth = GridBagConstraints.REMAINDER;
		c.gridheight = 1;
		c.gridy = 4;
		add(inboundLab, c);
		c.gridheight = 8;
		c.gridy = 5;
		add(incoming, c);
	}
	private void formWindowClosed(java.awt.event.WindowEvent evt) {
		System.exit(0);
	}
	/** Exit the Application */
	private void exitForm(java.awt.event.WindowEvent evt) {
		this.dispose();
	}
	public void actionPerformed(ActionEvent e) {
		if(e.getSource().equals(B0Change)){
			outgoingSerial("B0 "+this.B0Value.getText());
		} else if(e.getSource().equals(B1Change)){
			outgoingSerial("B1 "+this.B1Value.getText());
		} else if(e.getSource().equals(A2Change)){
			outgoingSerial("A2 "+this.A2Value.getText());
		} else if(e.getSource().equals(A3Change)){
			outgoingSerial("A3 "+this.A3Value.getText());
		} else{
			outgoingSerial(e.getActionCommand());
		}		
	}
	public void outgoingSerial(String inString) {
		outTraffic.append("Sent message: " + inString + "\n");
		scrollPane.getVerticalScrollBar().setValue(
			scrollPane.getVerticalScrollBar().getMaximum()
				- scrollPane.getVerticalScrollBar().getVisibleAmount());
		serialHandle.sendMessage(inString);
	}
	public void incomingSerial(String inString) {
		inTraffic.append("Received message: " + inString + "\n");
		scrollPane2.getVerticalScrollBar().setValue(
			scrollPane2.getVerticalScrollBar().getMaximum()
				- scrollPane2.getVerticalScrollBar().getVisibleAmount());
	}
	public void setSerialHandler(ComControl inSerialHandler) {
		serialHandle = inSerialHandler;
	}
}
