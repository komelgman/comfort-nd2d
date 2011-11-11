package kom.fort.box2d {
	import flash.utils.getQualifiedClassName;

	import kom.exceptions.AbstractClassError;

	public class Box2DConnector {
		protected var _objectType : String;

		public function Box2DConnector(objectType : String) {
			if (getQualifiedClassName(this) == "kom.fort.box2d::Box2DConnector")
				throw new AbstractClassError();

			_objectType = objectType;
		}

		public function getObjectType() : String {
			return _objectType;
		}

		public virtual function update(dt : Number) : void {
		}

		public virtual function contact(another : Box2DConnector) : void {
		}
	}
}