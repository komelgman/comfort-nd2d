package kom.fort {
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.media.Sound;
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;

	import kom.exceptions.AbstractClassError;
	import kom.promise.IPromise;

	public class AbstractAssetsManager {

		protected var sounds : Dictionary = new Dictionary();
		protected var bitmaps : Dictionary = new Dictionary();
		protected var clips : Dictionary = new Dictionary();
		protected var modules : Dictionary = new Dictionary();

		public function AbstractAssetsManager() {
			if (getQualifiedClassName(this) == "kom.fort::AbstractAssetsManager")
				throw new AbstractClassError();
		}


		protected function registerSound(name : String, definition : Class) : void {
			registerAsset(sounds, name, definition);
		}

		protected function registerBitmap(name : String, definition : Class) : void {
			registerAsset(bitmaps, name, definition);
		}

		protected function registerClip(name : String, definition : Class) : void {
			registerAsset(clips, name, definition);
		}

//        protected function registerModule(name : String, definition : Class) : void {
//            registerAsset(modules,  name,  definition);
//        }

		protected function registerAsset(category : Dictionary, name : String, definition : Class) : void {
			if (name in category) {
				throw new ArgumentError();
			}

			category[name] = definition;
		}

		public function loadModule(name : String) : IPromise {
			return null;
		}

		public function createSound(name : String) : Sound {
			return new sounds[name]();
		}

		public function createBitmap(name : String) : Bitmap {
			return new bitmaps[name]();
		}

		public function createClip(name : String, ...args) : DisplayObject {
			return new clips[name](args);
		}
	}
}