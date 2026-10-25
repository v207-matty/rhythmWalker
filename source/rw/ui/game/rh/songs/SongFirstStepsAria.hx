package rw.ui.game.rh.songs;

class SongFirstStepsAria extends RHSong
{
	override public function new()
	{
		super('first steps', aria);
	}

	var bro:RHSprite;
	var lazer:RHSprite;

	override function build()
	{
		super.build();

		game.camGame.bgColor = 0xFF222034;

		game.back.add(new RHSprite('first-steps-aria/stage').scaleToScreen().setCamera(game.camGame));

		game.gameplayElements.add(bro = new RHSprite('first-steps-aria/bro', true, 1280, 720).scaleToScreen().setCamera(game.camGame));
		bro.addAnim('center', [0]);
		bro.addAnim('left', [1]);
		bro.addAnim('right', [2]);

		game.gameplayElements.add(lazer = new RHSprite('first-steps-aria/shots', true, 1280, 720).scaleToScreen().setCamera(game.camGame));
		lazer.addAnim('center', [0]);
		lazer.addAnim('left', [1]);
		lazer.addAnim('right', [2]);
		lazer.visible = false;
	}
}
