package kom.fort.ui.screen {

	import de.nulldesign.nd2d.display.Node2D;

	import flash.display.Stage;
	import flash.errors.IllegalOperationError;
	import flash.events.Event;

	import kom.fort.ui.InterfaceManager;
	import kom.fort.ui.ManagedComponent;
	import kom.fort.ui.events.ScreenEvent;

	public class ScreenManager {

		/*
		 * Initialization
		 */


		protected static var _manager : InterfaceManager;

		public static function init(stage : Stage, viewport : Node2D) : void {
			_manager = new InterfaceManager(stage, viewport);
		}


		/*
		 * Base functional
		 */


		private static var _currentScreen : Screen = null;
		private static var _previousScreen : Screen = null;
		private static var _nextScreen : Screen = null;

		public static function addScreen(screen : Screen) : void {
			_manager.addComponent(screen as ManagedComponent);
		}

		public static function removeScreen(name : String) : void {
			if (!hasScreen(name)) {
				return;
			}

			if (_currentScreen.getName() == name) {
				throw new IllegalOperationError();
			}

			if (_previousScreen.getName() == name) {
				_previousScreen = null;
			}

			_manager.removeComponent(name);
		}

		public static function hasScreen(name : String) : Boolean {
			return _manager.hasComponent(name);
		}


		public static function showScreen(name : String) : void {
			_nextScreen = getScreen(name);

			switchScreen();
		}

		public static function hideScreen() : void {
			_nextScreen = null;

			switchScreen();
		}

		private static function switchScreen() : void {
			if (_currentScreen == null && _nextScreen == null) {
				throw new IllegalOperationError();
			} else if (_currentScreen == _nextScreen) {
				return;
			} else if (_currentScreen == null) {
				showNextScreen();
			} else if (_nextScreen == null) {
				hideCurrentScreen();
			} else {
				hideCurrentAndShowNextScreen();
			}
		}

		private static function showNextScreen() : void {
			_previousScreen = null;
			_currentScreen = _nextScreen;

			_manager.showComponent(_currentScreen as ManagedComponent);
		}

		private static function hideCurrentScreen() : void {
			_previousScreen = _currentScreen;
			_currentScreen = null;

			if (hasEventListener(ScreenEvent.NO_SCREEN)) {
				dispatchEvent(new ScreenEvent(ScreenEvent.NO_SCREEN));
			}

			_manager.hideComponent(_previousScreen as ManagedComponent);
		}

		private static function hideCurrentAndShowNextScreen() : void {
			_previousScreen = _currentScreen;
			_currentScreen = _nextScreen;

			_manager.switchComponent(_previousScreen as ManagedComponent, _currentScreen as ManagedComponent);
		}


		public static function get currentScreen() : Screen {
			return _currentScreen;
		}

		public static function get previousScreen() : Screen {
			return _previousScreen;
		}

		public static function getScreen(name : String) : Screen {
			return _manager.getComponent(name) as Screen;
		}


		/*
		 * Some helpers
		 */


		public static function addEventListener(type : String, listener : Function, useCapture : Boolean = false, priority : int = 0, useWeakReference : Boolean = false) : void {
			_manager.addEventListener(type, listener, useCapture, priority, useWeakReference);
		}

		public static function removeEventListener(type : String, listener : Function, useCapture : Boolean = false) : void {
			_manager.removeEventListener(type, listener, useCapture);
		}

		public static function dispatchEvent(event : Event) : Boolean {
			return _manager.dispatchEvent(event);
		}

		public static function hasEventListener(type : String) : Boolean {
			return _manager.hasEventListener(type);
		}

		public static function getStage() : Stage {
			return _manager.getStage();
		}

		public static function getViewport() : Node2D {
			return _manager.getViewport();
		}
	}
}