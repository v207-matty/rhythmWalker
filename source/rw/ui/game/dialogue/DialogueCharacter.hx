package rw.ui.game.dialogue;

import rw.ui.objects.RWSprite;

class DialogueCharacter extends RWSprite
{
	override public function new(portrait:String)
	{
		super(null);
		switchPortrait(portrait);
	}

	public function switchPortrait(portrait:String)
	{
		if (portrait == null) visible = false;
		else loadGraphic(Paths.getImagePath('game/cutscenes/dialogue/portraits/$portrait'));

		setGraphicSize(256, 256);
		updateHitbox();
	}
}
