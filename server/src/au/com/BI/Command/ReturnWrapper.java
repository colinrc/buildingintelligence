package au.com.BI.Command;

import java.util.Vector;


public class ReturnWrapper {
		private Vector <byte[]>outputBytes;
		private Vector <String>outputStrings;
		private Vector <CommandInterface>outputFlash;
		boolean messageIsBytes = false;
		boolean populated = false;
		
		boolean error = false;
		String errorDescription = "";
		public Exception exception = null;
		public boolean queueCommands = false;
		
		int outputCommandType;
		int paramCommandType;
		
		public ReturnWrapper() {
			outputBytes = new Vector<byte[]>();
			outputStrings = new Vector<String>();
			outputFlash = new Vector<CommandInterface>();
		}
		
		public void addCommOutput (byte[] newItem){
			this.messageIsBytes = true;
			outputBytes.add(newItem);
			populated = true;
		}
		
		public void addCommOutput (String newItem){
			this.messageIsBytes = false;
			outputStrings.add(newItem);
			populated = true;
		}
		
		public void addFlashCommand (CommandInterface newItem){
			outputFlash.add(newItem);
			populated = true;
		}

		public boolean isMessageIsBytes() {
			return messageIsBytes;
		}

		public Vector<CommandInterface> getOutputFlash() {
			return outputFlash;
		}

		public Vector getCommOutput() {
			if (messageIsBytes){
				return this.outputBytes;
			} else {
				return this.outputStrings;
			}
		}

		public Vector<byte[]> getCommOutputBytes() {
			return outputBytes;
		}

		public Vector<String> getCommOutputStrings() {
			return outputStrings;
		}

		public Exception getException() {
			return exception;
		}

		public void setException(Exception exception) {
			this.exception = exception;
			populated = true;
		}

		public boolean isError() {
			return error;
		}

		public void setError(boolean error) {
			this.error = error;
			populated = true;
		}

		public String getErrorDescription() {
			return errorDescription;
		}

		public void setErrorDescription(String errorDescription) {
			this.errorDescription = errorDescription;
		}

		public int getOutputCommandType() {
			return outputCommandType;
		}

		public void setOutputCommandType(int outputCommandType) {
			this.outputCommandType = outputCommandType;
		}

		public int getParamCommandType() {
			return paramCommandType;
		}

		public void setParamCommandType(int paramCommandType) {
			this.paramCommandType = paramCommandType;
		}

		public boolean isPopulated() {
			return populated;
		}

		public void setPopulated(boolean populated) {
			this.populated = populated;
		}
		
		public boolean equals (Object toTestWrapper){
    		if (toTestWrapper instanceof au.com.BI.Command.ReturnWrapper ){
    			ReturnWrapper toTest = (ReturnWrapper)toTestWrapper;
    			
				if (toTest.isError() != this.error) return false;
				if (toTest.isPopulated() != this.populated) return false;
				if (toTest.isMessageIsBytes() != this.messageIsBytes) return false;
				if (toTest.getOutputCommandType() != this.getOutputCommandType()) return false;
				if (toTest.getCommOutput().size() != this.getCommOutput().size()) return false;
				if (toTest.getCommOutputBytes().size() != this.getCommOutputBytes().size()) return false;
				if (toTest.getOutputFlash().size() != this.getOutputFlash().size()) return false;
				int index = 0;
				for (String i:toTest.getCommOutputStrings() ) {
					if (!this.outputStrings.get(index).equals(i)) return false;
				}
				index = 0;
				for (byte[] i:toTest.getCommOutputBytes() ) {
					if (!this.outputBytes.get(index).equals(i)) return false;
				}
				index = 0;
				for (CommandInterface i:toTest.getOutputFlash() ) {
					if (!this.getOutputFlash().get(index).equals(i)) return false;
				}
				return true;
    		}
			return false;
		}

		public boolean isQueueCommands() {
			return queueCommands;
		}

		public void setQueueCommands(boolean queueCommands) {
			this.queueCommands = queueCommands;
		}

}
