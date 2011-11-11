package kom.fort.ui.events {
	import flash.events.Event;

	import kom.fort.ui.*;

	public class UIComponentEvent extends Event {
		public static const SHOW_INIT : String = "showInit";
		public static const SHOW_FINISH : String = "show";
		public static const HIDE_INIT : String = "hideInit";
		public static const HIDE_FINISH : String = "hide";

		protected var _component : ManagedComponent;

		public function UIComponentEvent(event : String, component : ManagedComponent) {
			super(event, true);

			_component = component;
		}

		override public function clone() : Event {
			return new UIComponentEvent(this.type, _component);
		}


		public function get component() : ManagedComponent {
			return _component;
		}
	}
}
