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
	private var save_btn:Button;
	public function init():Void {
		var changeListener:Object = new Object();
		if(!_global.project.path.length){
			_global.setPath();
		}
		changeListener.change = function(eventObject:Object) {
		    _global.unSaved = true;
		};
		project_name_ti.addEventListener("change", changeListener);
		project_path_ti.addEventListener("change", changeListener);
		job_ti.addEventListener("change", changeListener);
		client_name_ti.addEventListener("change", changeListener);
		client_address_ta.addEventListener("change", changeListener);
		integrator_ti.addEventListener("change", changeListener);
		company_ti.addEventListener("change", changeListener);
		company_address_ta.addEventListener("change", changeListener);
		phone_ti.addEventListener("change", changeListener);
		fax_ti.addEventListener("change", changeListener);
		mobile_ti.addEventListener("change", changeListener);
		email_ti.addEventListener("change", changeListener);
		notes_ta.addEventListener("change", changeListener);
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
			
			// merik uber hack
			if (integrator_ti.text == "Merik") _root.setAdvancedMode();
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
		save_btn.addEventListener("click", Delegate.create(this, save));
		path_btn.addEventListener("click", Delegate.create(this, _global.setPath));
	}
	public function save():Void {
		//_global.history.changed("Project Details", "Project Name", "Name of project", _global.project.project, project_name_ti.text);
		_global.project.project = project_name_ti.text;
		//_global.history.setProject(_global.project.project, _global.project.path);
		//_global.history.changed("Project Details", "Job Number", "Reference number of project", _global.project.job, job_ti.text);
		_global.project.job = job_ti.text;
		//_global.history.changed("Project Details", "Client Name", "Customer Name", _global.project.client_name, client_name_ti.text);
		_global.project.client_name = client_name_ti.text;
		//_global.history.changed("Project Details", "Client Address", "Customer Address", _global.project.client_address, client_address_ta.text);
		_global.project.client_address = client_address_ta.text;
		//_global.history.changed("Project Details", "Integrator Name", "Integrator Name", _global.project.integrator, integrator_ti.text);
		_global.project.integrator = integrator_ti.text;
		//_global.history.changed("Project Details", "Company Name", "Company Name", _global.project.company, company_ti.text);
		_global.project.company = company_ti.text;
		//_global.history.changed("Project Details", "Company Address", "Company Address", _global.project.company_address, company_address_ta.text);
		_global.project.company_address = company_address_ta.text;
		//_global.history.changed("Project Details", "Company Phone", "Company Phone", _global.project.phone, phone_ti.text);
		_global.project.phone = phone_ti.text;
		//_global.history.changed("Project Details", "Company Fax", "Company Fax", _global.project.fax, fax_ti.text);
		_global.project.fax = fax_ti.text;
		//_global.history.changed("Project Details", "Company Mobile", "Company Mobile", _global.project.mobile, mobile_ti.text);
		_global.project.mobile = mobile_ti.text;
		//_global.history.changed("Project Details", "Company Email", "Company Email", _global.project.email, email_ti.text);
		_global.project.email = email_ti.text;
		//_global.history.changed("Project Details", "Additional", "Additional Notes", _global.project.notes, notes_ta.text);
		_global.project.notes = notes_ta.text;
		//_global.history.changed("Project Details", "Server IP", "Sever IP address", _global.project.ipAddress, ipAddress_ti.text);
		_global.saveFile("Project");		
	}
}
