import mx.controls.*;
import mx.utils.Delegate;
class Forms.Home extends Forms.BaseForm {
	private var project_name_ti:TextInput;
	private var project_path_ti:TextInput;
	private var path_btn:Button;
	private var job_ti:TextInput;
	private var client_name_ti:TextInput;
	private var client_address_ta:TextArea;
	private var integrator_ti:TextInput;
	private var company_ti:TextInput;
	private var company_address_ta:TextArea;
	private var phone_ti:TextInput;
	private var fax_ti:TextInput;
	private var mobile_ti:TextInput;
	private var email_ti:TextInput;
	private var notes_ta:TextArea;
	private var ipAddress_ti:TextInput;
	private var serverPort_ti:TextInput;
	private var monitorPort_ti:TextInput;
	private var save_btn:Button;
	private var connect_btn:Button;
	private var disconnect_btn:Button;
	public function init():Void {
		project_path_ti.text = "c:\\ ";
		if (_global.project.path.length) {
			project_path_ti.text = _global.project.path;
		}
		if (_global.project.project.length) {
			project_name_ti.text = _global.project.project;
		}
		if (_global.project.job.length) {
			job_ti.text = _global.project.job;
		}
		if (_global.project.client_name.length) {
			client_name_ti.text = _global.project.client_name;
		}
		if (_global.project.client_address.length) {
			client_address_ta.text = _global.project.client_address;
		}
		if (_global.project.integrator.length) {
			integrator_ti.text = _global.project.integrator;
		}
		if (_global.project.company.length) {
			company_ti.text = _global.project.company;
		}
		if (_global.project.company_address.length) {
			company_address_ta.text = _global.project.company_address;
		}
		if (_global.project.phone.length) {
			phone_ti.text = _global.project.phone;
		}
		if (_global.project.fax.length) {
			fax_ti.text = _global.project.fax;
		}
		if (_global.project.mobile.length) {
			mobile_ti.text = _global.project.mobile;
		}
		if (_global.project.email.length) {
			email_ti.text = _global.project.email;
		}
		if (_global.project.notes.length) {
			notes_ta.text = _global.project.notes;
		}
		ipAddress_ti.restrict = "0-9.";
		ipAddress_ti.maxChars = 15;
		monitorPort_ti.restrict = "0-9";
		monitorPort_ti.maxChars = 5;
		serverPort_ti.restrict = "0-9";
		serverPort_ti.maxChars = 5;		
		if (_global.project.ipAddress.length) {
			ipAddress_ti.text = _global.project.ipAddress;
		}
		if (_global.project.serverPort.length) {
			serverPort_ti.text = _global.project.serverPort;
		}
		if (_global.project.monitorPort.length) {
			monitorPort_ti.text = _global.project.monitorPort;
		}
		save_btn.addEventListener("click", Delegate.create(this, saveProjectDetails));
		path_btn.addEventListener("click", Delegate.create(this, selectFolder));
		connect_btn.addEventListener("click", Delegate.create(this, connect));
		disconnect_btn.addEventListener("click", Delegate.create(this, disconnect));
	}
	public function connect():Void {
		_global.history.changed("Project Details", "Server IP", "Sever IP address", _global.project.ipAddress, ipAddress_ti.text);
		_global.project.ipAddress = ipAddress_ti.text;
		_global.history.changed("Project Details", "Server Port", "Server Port Number", _global.project.serverPort, serverPort_ti.text);
		_global.project.serverPort = serverPort_ti.text;
		_global.history.changed("Project Details", "Monitor Port", "Monitor Port Number", _global.project.monitorPort, monitorPort_ti.text);
		_global.project.monitorPort = monitorPort_ti.text;
		_global.server.setServerAddress("", _global.project.ipAddress, parseInt(_global.project.serverPort), parseInt(_global.project.monitorPort));
		_global.server.makeConnections();
	}
	public function disconnect():Void {
		_global.server.disconnect();
	}
	public function saveProjectDetails():Void {
		_global.history.changed("Project Details", "Project Name", "Name of project", _global.project.project, project_name_ti.text);
		_global.project.project = project_name_ti.text;
		_global.history.setProject(_global.project.project, _global.project.path);
		_global.history.changed("Project Details", "Job Number", "Reference number of project", _global.project.job, job_ti.text);
		_global.project.job = job_ti.text;
		_global.history.changed("Project Details", "Client Name", "Customer Name", _global.project.client_name, client_name_ti.text);
		_global.project.client_name = client_name_ti.text;
		_global.history.changed("Project Details", "Client Address", "Customer Address", _global.project.client_address, client_address_ta.text);
		_global.project.client_address = client_address_ta.text;
		_global.history.changed("Project Details", "Integrator Name", "Integrator Name", _global.project.integrator, integrator_ti.text);
		_global.project.integrator = integrator_ti.text;
		_global.history.changed("Project Details", "Company Name", "Company Name", _global.project.company, company_ti.text);
		_global.project.company = company_ti.text;
		_global.history.changed("Project Details", "Company Address", "Company Address", _global.project.company_address, company_address_ta.text);
		_global.project.company_address = company_address_ta.text;
		_global.history.changed("Project Details", "Company Phone", "Company Phone", _global.project.phone, phone_ti.text);
		_global.project.phone = phone_ti.text;
		_global.history.changed("Project Details", "Company Fax", "Company Fax", _global.project.fax, fax_ti.text);
		_global.project.fax = fax_ti.text;
		_global.history.changed("Project Details", "Company Mobile", "Company Mobile", _global.project.mobile, mobile_ti.text);
		_global.project.mobile = mobile_ti.text;
		_global.history.changed("Project Details", "Company Email", "Company Email", _global.project.email, email_ti.text);
		_global.project.email = email_ti.text;
		_global.history.changed("Project Details", "Additional", "Additional Notes", _global.project.notes, notes_ta.text);
		_global.project.notes = notes_ta.text;
		_global.history.changed("Project Details", "Server IP", "Sever IP address", _global.project.ipAddress, ipAddress_ti.text);
		_global.project.ipAddress = ipAddress_ti.text;
		_global.history.changed("Project Details", "Server Port", "Server Port Number", _global.project.serverPort, serverPort_ti.text);
		_global.project.serverPort = serverPort_ti.text;
		_global.history.changed("Project Details", "Monitor Port", "Monitor Port Number", _global.project.monitorPort, monitorPort_ti.text);
		_global.project.monitorPort = monitorPort_ti.text;
	}
	public function selectFolder():Void {
		mdm.Dialogs.BrowseFolder.title = "Please select a Folder";
		var tempString = mdm.Dialogs.BrowseFolder.show();
		if (tempString != "false") {
			project_path_ti.text = tempString;
			_global.history.changed("Project Details", "Project Path", "Directory of project", _global.project.path, tempString);
			_global.project.path = tempString;
			_global.history.setProject(_global.project.project, _global.project.path);
		}
	}
}
