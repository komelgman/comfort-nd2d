package {

	import com.demonsters.debugger.MonsterDebugger;

	import flash.display.Sprite;
	import flash.events.Event;

	[Frame(factoryClass="kom.bine.Preloader")]
	[SWF(width="800", height="600", backgroundColor="#F0F0F0")]
	public class Main extends Sprite {

		public function Main() {
			if (stage) {
				init();
			} else {
				addEventListener(Event.ADDED_TO_STAGE, init);
			}
		}

		private function init(e : Event = null) : void {
			if (e) {
				removeEventListener(Event.ADDED_TO_STAGE, init);
			}

			MonsterDebugger.initialize(this);

			(new SomeGame(stage)).execute();
		}
	}
}