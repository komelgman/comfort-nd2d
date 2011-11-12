package kom.fort {
	import de.nulldesign.nd2d.display.*;

	import flash.display.Stage;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.display3D.Context3DRenderMode;
	import flash.errors.IllegalOperationError;
	import flash.events.Event;
	import flash.utils.getQualifiedClassName;

	import kom.exceptions.AbstractClassError;
	import kom.fort.ui.screen.ScreenManager;
	import kom.promise.Deferred;
	import kom.promise.IPromise;

	public class AbstractGame {

		protected var _wasStart : Boolean = false;
		protected var _stage : Stage;
		protected var _canvas : Canvas;

		protected var _renderer : CanvasRenderer;

		// default game configuration
		protected var config : Object = {
			frameRate : /* uint */ 60,
			stageAlign : StageAlign.TOP_LEFT,
			stageScaleMode : StageScaleMode.NO_SCALE,

			// screen to show on start
			startScreen: /* string */ 'startScreen',

			// context3d config
			stage3DID : /* uint */ 0,
			bounds : /* Rectangle */ null,
			renderMode : Context3DRenderMode.AUTO,
			enableErrorChecking : /* Boolean */ false
		};


		public function AbstractGame(stage : Stage) {
			if (getQualifiedClassName(this) == "kom.fort::Application")
				throw new AbstractClassError();

			this._stage = stage;
		}

		public function execute() : void {
			if (_wasStart) {
				throw new IllegalOperationError();
			}

			Deferred.parallel(
				loadConfig(),
				loadAssets()
			).done(function() : void {
				initialize().done(function() : void {
					bindEvents();
					requestContext();

					ScreenManager.showScreen(config.startScreen);

					wakeUp();

					_wasStart = true;
				});
			});
		}

		protected function loadConfig() : IPromise {
			var deferred : Deferred = new Deferred();

			// noting by default
			deferred.resolve();

			return deferred.promise;
		}

		protected function loadAssets() : IPromise {
			var deferred : Deferred = new Deferred();

			// noting by default
			deferred.resolve();

			return deferred.promise;
		}

		protected function initialize() : IPromise {
			var deferred : Deferred = new Deferred();

			_stage.frameRate = config.frameRate;
			_stage.align = config.stageAlign;
			_stage.scaleMode = config.stageScaleMode;

			_canvas = new Canvas();
			_renderer = new CanvasRenderer(_stage, _canvas, config.stage3DID, config.bounds, config.enableErrorChecking);

			ScreenManager.init(_stage, _canvas.createLayer());
			// WidgetManager.init(_stage, canvas.createLayer());
			// CursorManager.init(_stage, canvas.createLayer());

			// Input.init(stage);

			deferred.resolve();
			return deferred.promise;
		}

		protected function bindEvents() : void {
			_stage.addEventListener(Event.DEACTIVATE, onAppDeactivateHandler);
			_stage.addEventListener(Event.ACTIVATE, onAppActivateHandler);

			_renderer.bindEvents();
			_canvas.bindEvents();
		}

		protected function requestContext() : void {
			_renderer.requestContext(config.renderMode);
		}

		protected function onAppDeactivateHandler(e : Event) : void {
			sleep();
		}

		protected function onAppActivateHandler(e : Event) : void {
			wakeUp();
		}

		protected function sleep() : void {
			if (_stage.hasEventListener(Event.ENTER_FRAME)) {
				_stage.removeEventListener(Event.ENTER_FRAME, mainLoop);
			}
		}

		protected function wakeUp() : void {
			if (_stage.hasEventListener(Event.ENTER_FRAME)) {
				_stage.removeEventListener(Event.ENTER_FRAME, mainLoop);
			}

			_stage.addEventListener(Event.ENTER_FRAME, mainLoop);
		}

		protected function mainLoop(e : Event) : void {
			_renderer.update();
		}

		// cant stop and free resource on this moment
		// todo: make this
//        public function exit() : void {
//            sleep();
//            _renderer.dispose();
//            _canvas.dispose();
//
//            _renderer = null;
//            _canvas = null;
//        }
	}
}