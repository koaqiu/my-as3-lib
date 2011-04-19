package xBei.UI {

	public class SkinItem extends XMovieClip {
		override public function set enabled(value:Boolean):void {
			super.enabled = value;
			if (value) {
				gotoAndStop("normal");
			}else {
				gotoAndStop("disable");
			}
		}
		public function SkinItem() {
			stop();
		}
	}
}