package kom.fort.ui.screen {
	import flash.utils.getQualifiedClassName;

	import kom.exceptions.AbstractClassError;
	import kom.fort.ui.ManagedComponent;

	public class Screen extends ManagedComponent {

		public function Screen(name : String = null) {
			super(name);

			if (getQualifiedClassName(this) == "kom.fort.ui.screen::Screen")
				throw new AbstractClassError();
		}
	}
}