/*
 * Created on 29/08/2006
 *
 * 
 * Copyright Building Intelligence 2006
 */
package au.com.BI.Comms;
import gnu.io.CommPortIdentifier;
import gnu.io.SerialPort;
import java.awt.GridBagConstraints;
import java.awt.GridBagLayout;
import java.awt.Toolkit;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.util.Enumeration;
import javax.swing.JButton;
import javax.swing.JComboBox;
import javax.swing.JFrame;
import javax.swing.JLabel;
/**
 * @author David
 *
 * 
 * 
 */
public class PortSelector extends JFrame implements ActionListener {
	JComboBox portSelector;
	JComboBox baudSelector;
	JComboBox stopBitsSelector;
	JComboBox dataBitsSelector;
	JComboBox paritySelector;
	JComboBox flowSelector;
	JButton connect;
	ComControl coms;
	GridBagLayout lm;
	public PortSelector(ComControl coms) {
		this.coms = coms;
		this.setTitle("Connection Settings");
		lm = new GridBagLayout();
		this.setLayout(lm);
		GridBagConstraints c = new GridBagConstraints();
		Enumeration ports = CommPortIdentifier.getPortIdentifiers();
		portSelector = new JComboBox();
		while (ports.hasMoreElements()) {
			String tempName = ((CommPortIdentifier) ports.nextElement()).getName();
			if(!tempName.startsWith("LPT")){
				portSelector.addItem(tempName);
			}			
		}
		c.fill = GridBagConstraints.HORIZONTAL;
		c.anchor = GridBagConstraints.CENTER;
		c.gridx = 0;
		c.gridy = 0;
		add(new JLabel("Com Port:"), c);
		c.gridx = 1;
		add(portSelector, c);
		c.gridy = 1;
		c.gridx = 0;
		add(new JLabel("Baud Rate:"), c);
		baudSelector = new JComboBox();
		baudSelector.addItem("19200");
		baudSelector.addItem("110");
		baudSelector.addItem("300");
		baudSelector.addItem("600");
		baudSelector.addItem("1200");
		baudSelector.addItem("2400");
		baudSelector.addItem("4800");
		baudSelector.addItem("9600");
		baudSelector.addItem("38400");
		baudSelector.addItem("57600");
		baudSelector.addItem("115200");
		baudSelector.addItem("230400");
		c.gridx = 1;
		add(baudSelector, c);
		c.gridy = 2;
		c.gridx = 0;
		add(new JLabel("DataBits:"), c);
		dataBitsSelector = new JComboBox();
		dataBitsSelector.addItem("8");
		dataBitsSelector.addItem("5");
		dataBitsSelector.addItem("6");
		dataBitsSelector.addItem("7");
		c.gridx = 1;
		add(dataBitsSelector, c);
		c.gridx = 0;
		c.gridy = 3;
		add(new JLabel("StopBits:"), c);
		stopBitsSelector = new JComboBox();
		stopBitsSelector.addItem("1");
		stopBitsSelector.addItem("1.5");
		stopBitsSelector.addItem("2");
		c.gridx = 1;
		add(stopBitsSelector, c);
		c.gridy = 4;
		c.gridx = 0;
		add(new JLabel("Parity:"), c);
		paritySelector = new JComboBox();
		paritySelector.addItem("N");
		paritySelector.addItem("EVEN");
		paritySelector.addItem("ODD");
		paritySelector.addItem("MARK");
		paritySelector.addItem("SPACE");
		c.gridx = 1;
		add(paritySelector, c);
		c.gridy = 5;
		c.gridx = 0;
		c.gridwidth = 2;
		connect = new JButton("Connect");
		connect.addActionListener(this);
		add(connect, c);
		this.setBounds(
			(Toolkit.getDefaultToolkit().getScreenSize().width - 600) / 2,
			(Toolkit.getDefaultToolkit().getScreenSize().height - 300) / 2,
			600,
			300);
		this.setVisible(true);
	}
	public void actionPerformed(ActionEvent e) {
		if (e.getSource().equals(connect)) {
			String comPort = (String) portSelector.getSelectedItem();
			int dataBits, baud, stopBits, parity;
			baud = Integer.parseInt((String) baudSelector.getSelectedItem());
			String tempData = (String) dataBitsSelector.getSelectedItem();
			if (tempData.equals("8")) {
				dataBits = SerialPort.DATABITS_8;
			} else if (tempData.equals("5")) {
				dataBits = SerialPort.DATABITS_5;
			} else if (tempData.equals("6")) {
				dataBits = SerialPort.DATABITS_6;
			} else {
				dataBits = SerialPort.DATABITS_7;
			}
			String tempStop = (String) stopBitsSelector.getSelectedItem();
			if (tempStop.equals("1")) {
				stopBits = SerialPort.STOPBITS_1;
			} else if (tempStop.equals("1.5")) {
				stopBits = SerialPort.STOPBITS_1_5;
			} else {
				stopBits = SerialPort.STOPBITS_2;
			}
			String tempParity = (String) paritySelector.getSelectedItem();
			if (tempParity.equals("N")) {
				parity = SerialPort.PARITY_NONE;
			} else if (tempParity.equals("EVEN")) {
				parity = SerialPort.PARITY_EVEN;
			} else if (tempParity.equals("ODD")) {
				parity = SerialPort.PARITY_ODD;
			} else if (tempParity.equals("SPACE")) {
				parity = SerialPort.PARITY_SPACE;
			} else {
				parity = SerialPort.PARITY_MARK;
			}
			coms.start(comPort, baud, dataBits, stopBits, parity);
			this.dispose();
		}
	}
}
