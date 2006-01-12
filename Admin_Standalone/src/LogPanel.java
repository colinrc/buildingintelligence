import java.awt.Color;
import java.awt.Dimension;
import java.text.SimpleDateFormat;
import java.util.Date;

import javax.swing.BorderFactory;
import javax.swing.*;
import javax.swing.text.BadLocationException;
import javax.swing.text.Style;
import javax.swing.text.Document;
import javax.swing.text.StyleConstants;
import javax.swing.text.StyleContext;
import java.awt.BorderLayout;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.event.ItemListener;
import java.awt.event.ItemEvent;
import java.util.regex.*;

public class LogPanel extends JPanel implements ItemListener {
    Style mReceivedLabelStyle;
    Style mLogStyle;
    Style mSentLabelStyle;
	Style mWarningStyle;
    Style mConnectedStyle;
    Style mDisconnectedStyle;
    Style mMessageStyle;
    SimpleDateFormat mDateFormatter;
    boolean mFollowAdditions = true;
    private Admin eLife;
    private JScrollPane scroller;
    private JTextPane logArea;
    private JCheckBox tail;
    private JScrollPane pane;
    private JButton clear;
    private JButton copy;
    private JTextField matchString;
    private JCheckBox filter;
    private JCheckBox invFilter;
    private JCheckBox mmiFilter;
    private Pattern p = null;
    private boolean filtering = false;
    private boolean inverted = false;;
    private boolean mmifiltering = false;
    
    public LogPanel(Admin eLife)
    {
		this.eLife = eLife;
		this.setLayout(new BorderLayout());

        mDateFormatter = new SimpleDateFormat("dd/MM/yyyy H:mm:ss");

        logArea = new JTextPane();
        initStyles();
        pane = new JScrollPane(logArea);
		pane.setVerticalScrollBarPolicy(
                JScrollPane.VERTICAL_SCROLLBAR_ALWAYS);
		//pane.setAutoscrolls(true);		
        logArea.setEditable(false);
        logArea.setBorder(BorderFactory.createTitledBorder("eLife Debug Trace"));
        add(pane,BorderLayout.CENTER);
        
        JPanel lastLine = new JPanel();
        
        tail = new JCheckBox ("Tail", true);
		tail.addItemListener(this);
		lastLine.add (tail);
		
        copy = new JButton ("Copy");
        copy.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent evt) {
				int curPos = logArea.getCaretPosition();
				logArea.selectAll();
				logArea.copy();
				logArea.setSelectionStart(1);
				logArea.setSelectionEnd(1);
				logArea.setCaretPosition(curPos);
			}
		});
		lastLine.add (copy);
		
		clear = new JButton ("Clear");
		clear.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent evt) {
				LogPanel.this.clearPanel();
			}
		});
		lastLine.add (clear);

		lastLine.add(Box.createRigidArea(new Dimension(5, 0)));
		
		matchString = new JTextField (35);
		lastLine.add (matchString);
		
        filter = new JCheckBox ("Filter", false);
		filter.addItemListener(this);
		lastLine.add (filter);
		
        invFilter = new JCheckBox ("Inv. ", false);
        invFilter.addItemListener(this);
		lastLine.add (invFilter);
		
        mmiFilter = new JCheckBox ("MMI ", false);
        mmiFilter.addItemListener(this);
		lastLine.add (mmiFilter);
		
        add(lastLine,BorderLayout.SOUTH);
     }
    
    public void itemStateChanged(ItemEvent e) {
        Object source = e.getItemSelectable();

        if (e.getSource().equals(tail) ) {
	        if (e.getStateChange() == ItemEvent.DESELECTED) {
	        		mFollowAdditions = false;
	        }
	        else { 
	        		mFollowAdditions = true; 
	        }
        }
        if (e.getSource().equals(filter) ) {
	        if (e.getStateChange() == ItemEvent.DESELECTED) {
	        		this.filtering = false;
	        		this.matchString.setEnabled(true);
	        }
	        else {
	        		try {
	        			this.invFilter.setSelected(false);
		        		p = Pattern.compile (matchString.getText());	        		
		        		this.matchString.setEnabled(false);
		        		this.inverted = false;
		        		this.filtering = true;
	        		} catch (PatternSyntaxException ex) {
	        			this.eLife.showMessage("Invalid pattern " + ex.getMessage(),JOptionPane.ERROR_MESSAGE);	
	        		}
	        }
        }
        if (e.getSource().equals(invFilter) ) {
	        if (e.getStateChange() == ItemEvent.DESELECTED) {
	        		this.filtering = false;
	        		this.matchString.setEnabled(true);
	        }
	        else {
	        		try {
	        			this.filter.setSelected(false);
		        		p = Pattern.compile (matchString.getText());	        		
		        		this.matchString.setEnabled(false);
		        		this.inverted = true;
		        		this.filtering = true;
	        		} catch (PatternSyntaxException ex) {
	        			this.eLife.showMessage("Invalid pattern " + ex.getMessage(),JOptionPane.ERROR_MESSAGE);	
	        		}
	        }
        }
        if (e.getSource().equals(mmiFilter) ) {
	        if (e.getStateChange() == ItemEvent.DESELECTED) {
	        		this.mmifiltering = false;
	        }
	        else {
	        		this.mmifiltering = true;
	        }
        }
    }
   
   public void clearPanel() {
   		Runnable updateClear = new Runnable () {
   			public void run () { logArea.setText("");}
       	};
    	SwingUtilities.invokeLater(updateClear);
    }
   
	private class AddWarningMessage implements Runnable {
		private Date timestamp;
		private String level;
		private String message;
		private String src;
		
		public AddWarningMessage (Date timestamp, String level, String src, String message) {
			this.message = message;
			this.timestamp = timestamp;
			this.level = level;
			this.src = src;
		}
		
		public void run () {
			try {
	    		Document doc = logArea.getDocument();
	        	doc.insertString(
	        			doc.getLength(), 
		                "Message Received (" + mDateFormatter.format(timestamp) + "):\n",
		                mReceivedLabelStyle);
		
	        	doc.insertString(
	        			doc.getLength(), 
		                level + ":" + src + "\n",
		                mMessageStyle);
	
	        	doc.insertString(
	        			doc.getLength(), 
		                message + "\n\n",
						mWarningStyle);
	
	        	if (mFollowAdditions)
		        {
		            logArea.setCaretPosition(doc.getLength());
		         }
			}
	        catch (BadLocationException ble) {} ;
		}
	}
	
	private class AddReceivedMessage implements Runnable {
		private Date timestamp;
		private String level;
		private String message;
		private String src;
		
		public AddReceivedMessage (Date timestamp, String level, String src, String message) {
			this.message = message;
			this.timestamp = timestamp;
			this.level = level;
			this.src = src;
		}
		
		public void run () {
			try {
		    		Document doc = logArea.getDocument();
		    		int currentCaret = logArea.getCaretPosition();
		        	doc.insertString(
		        			doc.getLength(), 
			                "Message Received (" + mDateFormatter.format(timestamp) + "):\n",
			                mReceivedLabelStyle);
			
		        	doc.insertString(
		        			doc.getLength(), 
			                level + ":" + src + "\n",
			                mMessageStyle);
		
		        	doc.insertString(
		        			doc.getLength(), 
			                message + "\n\n",
							mLogStyle);
		
		        	if (mFollowAdditions)
			    {
		            logArea.setCaretPosition(doc.getLength());
			    }
		        	else {
		        		logArea.setCaretPosition(currentCaret);
		        	}
			}
	        catch (BadLocationException ble) {} ;
		}
	}
	
    public void addReceivedMessage(String time, String level, String src, String message,boolean warning) {
    		Date timeStamp;
    	
	    	if (this.filtering) {
	    		Matcher m = p.matcher(message);
	    		if (m.find()) {
	    			if (inverted) return; // found; inverted so do not display
	    		} else {
	    			if (!inverted) return;	  // not found; not inverted do not display  			
	    		}
	    	}
	    	if (this.mmifiltering) {
	    		if (message.startsWith("Received ip packet : D") )
	    			return;
	    		if (message.startsWith("Processing serial string D") )
	    			return;
	    	}
	    	
	    	try {
	    		long timeStampLong = Long.parseLong(time.trim()); 
	    		timeStamp = new Date (timeStampLong);
	    	} catch (NumberFormatException ex) {
	    		timeStamp = new Date();
	    	}
		if (warning) {
		    	AddWarningMessage add = new AddWarningMessage (timeStamp,level,src,message);
		    	SwingUtilities.invokeLater(add);
		} else {
	    		AddReceivedMessage add = new AddReceivedMessage (timeStamp,level,src,message);
			SwingUtilities.invokeLater(add);			
		}
    }
    
       
    public void connectionEstablished()
    {
		Runnable updateMessage = new Runnable () {
			public void run () {
		        try
		        {          
		    		Document doc = logArea.getDocument();
		        	doc.insertString(
		        			doc.getLength(), 
			                mDateFormatter.format(new Date()) + ":\n",
			                mConnectedStyle);
			
		        	doc.insertString(
		        			doc.getLength(), 
			                "Connection Established" + "\n\n",
			                mMessageStyle);
			        
			        if (mFollowAdditions)
			        {
			            logArea.setCaretPosition(doc.getLength());
			        }
			        
		        }
		        catch (BadLocationException ble) 
		        {
		            ble.printStackTrace();
		        }    

			}
		};
		SwingUtilities.invokeLater(updateMessage);
    }

    public void connectionLost()
    {
		Runnable updateMessage = new Runnable () {
			public void run () {
		        try
		        {          
		    		Document doc = logArea.getDocument();
		        	doc.insertString(
		        			doc.getLength(), 
			                mDateFormatter.format(new Date()) + ":\n",
			                mConnectedStyle);
			
		        	doc.insertString(
		        			doc.getLength(), 
			                "Connection Established" + "\n\n",
			                mMessageStyle);
			        
			        if (mFollowAdditions)
			        {
			            logArea.setCaretPosition(doc.getLength());
			        }
			        
		        }
		        catch (BadLocationException ble) 
		        {
		            ble.printStackTrace();
		        }    

			}
		};
		SwingUtilities.invokeLater(updateMessage);
	}
    
    protected void initStyles() 
    {
        //Initialize styles.
        Style def = StyleContext.getDefaultStyleContext().
                                        getStyle(StyleContext.DEFAULT_STYLE);

        mLogStyle = logArea.addStyle(
                "LogStyle", 
                def);
		
        mWarningStyle = logArea.addStyle(
                "WarningStyle", 
                def);
		
        mReceivedLabelStyle = logArea.addStyle(
                "ReceivedLabelStyle", 
                def);
        mSentLabelStyle = logArea.addStyle(
                "ReceivedLabelStyle", 
                def);
        mConnectedStyle =  logArea.addStyle(
                "ConnectedStyle", 
                def);
        mDisconnectedStyle =  logArea.addStyle(
                "DisconnectedStyle", 
                def);
        mMessageStyle = logArea.addStyle(
                "MessageStyle", 
                def);
        
        StyleConstants.setBold(
                mReceivedLabelStyle, 
                true);        
        StyleConstants.setBold(
                mSentLabelStyle, 
                true);
        StyleConstants.setBold(
                mConnectedStyle, 
                true);        
        StyleConstants.setBold(
                mDisconnectedStyle, 
                true);

        StyleConstants.setUnderline(
                mReceivedLabelStyle, 
                true);
        StyleConstants.setUnderline(
                mSentLabelStyle, 
                true);
        StyleConstants.setUnderline(
                mConnectedStyle, 
                true);
        StyleConstants.setUnderline(
                mDisconnectedStyle, 
                true);
        
        StyleConstants.setFontSize(
                mReceivedLabelStyle, 
                StyleConstants.getFontSize(mReceivedLabelStyle) - 2);
        StyleConstants.setFontSize(
                mSentLabelStyle, 
                StyleConstants.getFontSize(mSentLabelStyle) - 2);
        StyleConstants.setFontSize(
                mConnectedStyle, 
                StyleConstants.getFontSize(mConnectedStyle) - 2);
        StyleConstants.setFontSize(
                mDisconnectedStyle, 
                StyleConstants.getFontSize(mDisconnectedStyle) - 2);

        StyleConstants.setForeground(
                mConnectedStyle,
                Color.red);
        StyleConstants.setForeground(
                mDisconnectedStyle,
                Color.green);
        StyleConstants.setForeground(
                mMessageStyle,
                Color.blue);        
        StyleConstants.setForeground(
                mWarningStyle,
                Color.red);    
    }
}
