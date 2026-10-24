package rw.ui.menu.options;

class Option
{
	public var text(default, null):Void->String;

	public var onClick(default, null):Void->Void;

	public function new(text:Void->String, onClick:Void->Void)
	{
		this.text = text;
		this.onClick = onClick;
	}
}
