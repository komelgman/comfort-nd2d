package kom.fort.ui.widget {
	import flash.events.Event;

	import kom.fort.ui.ManagedComponent;
	import kom.fort.ui.events.ScreenEvent;
	import kom.fort.ui.events.UIComponentEvent;
	import kom.fort.ui.screen.ScreenManager;

	public class PinnedWidget extends Widget {
		private var _screens : Array;
		private var _hideOnNoScreen : Boolean;

		public function PinnedWidget(name : String, screens : Array, hideOnNoScreen : Boolean = true) {
			super(name);

			_screens = screens;
			_hideOnNoScreen = hideOnNoScreen;

			bindEvents();
		}

		private function bindEvents() : void {
			if (_hideOnNoScreen) {
				ScreenManager.addEventListener(ScreenEvent.NO_SCREEN, needHideHandler, false, 0, true)
			}

			ScreenManager.addEventListener(UIComponentEvent.HIDE_INIT, needHideHandler, false, 0, true);
			ScreenManager.addEventListener(UIComponentEvent.SHOW_INIT, needShowHandler, false, 0, true);
		}

		private function needHideHandler(event : Event) : void {
			if (!this.visible) {
				return;
			}

			if (event.type == ScreenEvent.NO_SCREEN) {
				WidgetManager.hideWidget(this.getName());
				return;
			}

			if (event is UIComponentEvent) {
				var component : ManagedComponent = (event as UIComponentEvent).component;

				if (_screens.indexOf(component.getName()) != -1) {
					WidgetManager.hideWidget(this.getName());
				}
			}
		}

		private function needShowHandler(event : Event) : void {
			if (visible) {
				return;
			}

			if (event is UIComponentEvent) {
				var component : ManagedComponent = (event as UIComponentEvent).component;

				if (_screens.indexOf(component.getName()) != -1) {
					WidgetManager.showWidget(this.getName());
				}
			}
		}
	}
}
