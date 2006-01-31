class Objects.Server.Device extends Objects.BaseElement{
	private var device_type:String;
	private var description:String;
	private var active:String;
	private var catalogues:Objects.Server.Catalogues;
	private var connection:XMLNode;
	private var parameters:XMLNode;
	public function getForm():String {
		return "forms.project.device.head";
	}
	public function getName():String {
		return device_type+" : "+description;
	}
	public function getData():Object {
		return new Object({device_type:device_type, description:description, active:active, connection:connection, parameters:parameters});
	}
	public function setData(newData:Object) {
		device_type = newData.device_type;
		description = newData.description;
		active = newData.active;
		connection = newData.connection;
		parameters = newData.parameters;
	}
}