package rw;

import flixel.FlxG;
import flixel.addons.sound.FlxRhythmConductor;
import flixel.addons.ui.FlxUISubState;

class ConductorSubState extends FlxUISubState
{
	public var conductor(get, never):FlxRhythmConductor;

	function get_conductor():FlxRhythmConductor return FlxRhythmConductor.instance;

	function resetConductor()
	{
		FlxRhythmConductor.reset();

		conductor.onBeatHit.add(onBeatHit);
		conductor.onBpmChange.add(onBpmChange);
		conductor.onMeasureHit.add(onMeasureHit);
		conductor.onStepHit.add(onStepHit);
	}

	function onBeatHit(beat:Int, backward:Bool) {}

	function onBpmChange(bpm:Float, backward:Bool) {}

	function onMeasureHit(measure:Float, backward:Bool) {}

	function onStepHit(step:Int, backward:Bool) {}

	public var mouseEnabled:Bool = #if MOBILE_MODE true #else false #end;
	public var mouseVisible:Bool = #if (MOBILE_MODE && !MOBILE_PLATFORM) true #else false #end;

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		FlxG.mouse.enabled = mouseEnabled;
		FlxG.mouse.visible = mouseEnabled && mouseVisible;
	}
}
