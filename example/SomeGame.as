package {
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.KeyboardEvent;

	import kom.fort.AbstractGame;
	import kom.fort.ui.screen.ScreenManager;
	import kom.promise.IPromise;

	import net.hires.debug.Stats;

	import tests.SideScrollerTest;

	public class SomeGame extends AbstractGame {
		public function SomeGame(stage : Stage) {
			super(stage);
		}

		private var stats : Stats = new Stats();

		override protected function initialize() : IPromise {
			return super.initialize().done(function() : void {
				ScreenManager.addScreen(new SideScrollerTest('startScreen'));
				ScreenManager.addScreen(new SideScrollerTest('secondScreen'));

				_stage.addEventListener(KeyboardEvent.KEY_UP, function(e : KeyboardEvent) : void {
					if (ScreenManager.currentScreen.getName() == 'startScreen') {
						ScreenManager.showScreen('secondScreen');
					} else {
						ScreenManager.showScreen('startScreen');
					}
				});

				_stage.addChild(stats);
			});
		}

		override protected function mainLoop(e : Event) : void {
			super.mainLoop(e);
			stats.update(_renderer.stats.totalDrawCalls, _renderer.stats.totalTris);
		}
	}
}
