package kom.fort.ui.widget {
	import flash.utils.getQualifiedClassName;

	import kom.exceptions.AbstractClassError;
	import kom.fort.ui.ManagedComponent;

	public class Widget extends ManagedComponent {

		public function Widget(name : String = null) {
			super(name);

			if (getQualifiedClassName(this) == "kom.fort.ui.widget::Widget")
				throw new AbstractClassError();
		}
	}
}
