package kom.fort.ui.events {
	import flash.events.Event;

	public class ScreenEvent extends Event {

		public static const NO_SCREEN : String = 'noScreen';

		public function ScreenEvent(event : String) {
			super(event, true);
		}
	}
}
