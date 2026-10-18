package ui.dialogue;

typedef DialogueLineData = {
    speaker:Int,
    ?text:String,
    
    ?events:Array<DialogueEventData>,
}