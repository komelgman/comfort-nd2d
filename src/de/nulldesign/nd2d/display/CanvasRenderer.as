package de.nulldesign.nd2d.display {

	import com.demonsters.debugger.MonsterDebugger;

	import de.nulldesign.nd2d.utils.StatsObject;

	import flash.display.Stage;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DCompareMode;
	import flash.display3D.Context3DRenderMode;
	import flash.display3D.Context3DTriangleFace;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.utils.getTimer;

	public class CanvasRenderer {
		public var antialiasing : uint = 2;

		protected var _stage : Stage;
		protected var _stage3DID : uint;
		protected var _context : Context3D;
		protected var _camera : Camera2D = new Camera2D(1, 1);
		protected var _canvas : Canvas = null;

		protected var _enableErrorChecking : Boolean;
		protected var _bounds : Rectangle;

		protected var _isHardwareAccelerated : Boolean;
		protected var _isDeviceNotInitialized : Boolean;
		protected var _isDeviceWasLost : Boolean;

		protected var _stats : StatsObject = new StatsObject();

		public function CanvasRenderer(stage : Stage, canvas : Canvas, stage3DID : uint = 0, bounds : Rectangle = null, enableErrorChecking : Boolean = false) {
			_stage = stage;
			_stage3DID = stage3DID;
			_bounds = bounds;
			_enableErrorChecking = enableErrorChecking;
			_isDeviceNotInitialized = true;

			_canvas = canvas;
		}

		public function bindEvents() : void {
			_stage.addEventListener(Event.RESIZE, onStageResizeHandler);
			_stage.stage3Ds[_stage3DID].addEventListener(Event.CONTEXT3D_CREATE, onContext3DCreatedHandler);
			_stage.stage3Ds[_stage3DID].addEventListener(ErrorEvent.ERROR, onContext3DErrorHandler);
		}

		public function requestContext(renderMode : String = Context3DRenderMode.AUTO) : void {
			_stage.stage3Ds[_stage3DID].requestContext3D(renderMode);
		}

		protected function onContext3DCreatedHandler(event : Event) : void {
			// means we got the Event.CONTEXT3D_CREATE for the second time,
			// the device was lost. Reinit everything
			_isDeviceWasLost = !_isDeviceNotInitialized;
			_isDeviceNotInitialized = true;

			initializeContext();
			onStageResizeHandler();
			invalidateCanvas();

			_isDeviceNotInitialized = false;
		}

		protected function initializeContext() : void {
			_context = _stage.stage3Ds[_stage3DID].context3D;
			_context.enableErrorChecking = _enableErrorChecking;
			_context.setCulling(Context3DTriangleFace.NONE);
			_context.setDepthTest(false, Context3DCompareMode.ALWAYS);
			_isHardwareAccelerated = _context.driverInfo.toLowerCase().indexOf("software") == -1;
		}

		protected function onStageResizeHandler(e : Event = null) : void {
			if (!_context) {
				return;
			}

			var rect : Rectangle = _bounds
					? _bounds
					: new Rectangle(0, 0, _stage.stageWidth, _stage.stageHeight);

			_stage.stage3Ds[_stage3DID].x = rect.x;
			_stage.stage3Ds[_stage3DID].y = rect.y;

			_context.configureBackBuffer(rect.width, rect.height, antialiasing, false);
			_camera.resizeCameraStage(rect.width, rect.height);
		}

		protected function invalidateCanvas() : void {
			_canvas.setStageAndCamRef(_stage, _camera);

			if (_isDeviceWasLost) {
				_canvas.handleDeviceLoss();
			}
		}


		protected function onContext3DErrorHandler(event : ErrorEvent) : void {
			throw new Error("The SWF is not embedded properly. The 3D context can't be created. Wrong WMODE? Set it to 'direct'.");
		}

		// http://gafferongames.com/game-physics/fix-your-timestep/
		protected const _timeStep : Number = 1.0 / 60.0;
		protected var _previousTime : Number = 0.0;
		protected var _time : Number = 0.0;
		protected var _accumulator : Number = 0.0;

		public function update() : void {
			if (_isDeviceNotInitialized || (_context.driverInfo == 'Disposed')) {
				return;
			}

			var currentTime : Number = getTimer() / 1000.0;
			var elapsed : Number = currentTime - _previousTime;

			// note: max frame time to avoid spiral of death
			if (elapsed > 0.25) {
				elapsed = 0.25;
			}

			_previousTime = currentTime;
			_accumulator += elapsed;

			while (_accumulator >= _timeStep) {
				_time += _timeStep;
				_canvas.stepNode(_timeStep, _time);
				_accumulator -= _timeStep;
			}

			_context.clear(_canvas.br, _canvas.bg, _canvas.bb, 1.0);
			_canvas.drawNode(_context, _camera, false, _stats);
			_context.present();
		}

		public function setBounds(bounds : Rectangle) : void {
			this._bounds = bounds;
		}

		public function dispose() : void {
			if (_context) {
				_context.dispose();
			}
		}

		public function get stats() : StatsObject {
			return _stats;
		}

		public function get camera() : Camera2D {
			return _camera;
		}

		public function get stage() : Stage {
			return _stage;
		}
	}
}