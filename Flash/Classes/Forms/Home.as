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
		project_path_ti.text = "c:\\ ";		
		if (_global.project.path.length) {
			project_path_ti.text = _global.project.path;
		}
		if(_global.project.project.length) {
			project_name_ti.text = _global.project.project;
		}
		if(_global.project.job.length) {
			job_ti.text = _global.project.job;
		}
		if(_global.project.client_name.length) {
			client_name_ti.text = _global.project.client_name;
		}
		if(_global.project.client_address.length) {
			client_address_ta.text = _global.project.client_address;			
		}
		if(_global.project.integrator.length) {
			integrator_ti.text = _global.project.integrator;
		}
		if(_global.project.company.length) {
			company_ti.text = _global.project.company;
		}
		if(_global.project.company_address.length) {
			company_address_ta.text = _global.project.company_address;
		}
		if(_global.project.phone.length) {
			phone_ti.text = _global.project.phone;
		}
		if(_global.project.fax.length) {
			fax_ti.text = _global.project.fax;
		}
		if(_global.project.mobile.length) {
			mobile_ti.text = _global.project.mobile;
		}
		if(_global.project.email.length) {
			email_ti.text = _global.project.email;
		}
		if(_global.project.notes.length) {
			notes_ta.text = _global.project.notes;
		}		
		save_btn.addEventListener("click", Delegate.create(this, saveProjectDetails));
		path_btn.addEventListener("click", Delegate.create(this, selectFolder));
	}
	public function saveProjectDetails():Void {
			_global.project.project = project_name_ti.text;
			_global.history.setProject(_global.project.project,_global.project.path);
			_global.project.job = job_ti.text;
			_global.project.client_name = client_name_ti.text;
			_global.project.client_address = client_address_ta.text;
			_global.project.integrator = integrator_ti.text;
			_global.project.company = company_ti.text;
			_global.project.company_address = company_address_ta.text;
			_global.project.phone = phone_ti.text;
			_global.project.fax = fax_ti.text;
			_global.project.mobile = mobile_ti.text;
			_global.project.email = email_ti.text;
			_global.project.notes = notes_ta.text;
	}
	public function selectFolder():Void {
		mdm.Dialogs.BrowseFolder.title = "Please select a Folder";
		var tempString = mdm.Dialogs.BrowseFolder.show();
		if (tempString != "false") {
			project_path_ti.text = tempString;
			_global.project.path = tempString;
			_global.history.setProject(_global.project.project,_global.project.path);			
			break;
		}
	}
}