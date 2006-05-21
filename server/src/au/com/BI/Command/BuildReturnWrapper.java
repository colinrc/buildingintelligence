package au.com.BI.Command;

import java.util.Vector;


public class BuildReturnWrapper {
		private Vector <byte[]>outputBytes;
		private Vector <String>outputStrings;
		private Vector <CommandInterface>outputFlash;
		boolean messageIsBytes = false;
		
		boolean error = false;
		String errorDescription = "";
		public Exception exception = null;
		
		int outputCommandType;
		int paramCommandType;
		
		public BuildReturnWrapper() {
			outputBytes = new Vector<byte[]>();
			outputStrings = new Vector<String>();
			outputFlash = new Vector<CommandInterface>();
		}
		
		public void addCommOutput (byte[] newItem){
			this.messageIsBytes = true;
			outputBytes.add(newItem);
		}
		
		public void addCommOutput (String newItem){
			this.messageIsBytes = false;
			outputStrings.add(newItem);
		}
		
		public void addFlashCommand (CommandInterface newItem){
			outputFlash.add(newItem);
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
		}

		public boolean isError() {
			return error;
		}

		public void setError(boolean error) {
			this.error = error;
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

}
