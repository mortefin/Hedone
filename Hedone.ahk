^m::
ExitApp
Return


^l::
ClauseExaminer = WordProblem
AreThoughtsDisabled = 0
FoundQuote = 0
UseStringFragment = 0
RunCount = 0
ShowFindCon = 0
ShowFindWords = 0
ShowFindAltWords = 0
ShowCalculateHowMany = 0
ShowIdentifyWordClass = 0
ShowAddConnectionToFile = 0
Gosub, FindShowThoughtsVars
  ;sets some variables
FileRead, ConceptsFile, Concepts.txt
ConceptsFile2 = %ConceptsFile%☻
FileDelete, Temp.txt
FileRead, TempFile, Temp.txt
TempFile2 = %TempFile%☻
  ;loads file data
Mode = None
        Menu, Tray, Icon, Hedoneface.ico
	dlg := "♥Hedone♥: Hello. What do you want?`n"
	logdlg := "♥Hedone♥: Hello.`n"
	gui, add, edit, r20 w500 vOut ReadOnly hwndOutHWND,%dlg%
	Gui, Add, edit, r1 wp vIn
	Gui, Add, Button, default w1 h1 hidden gAction!
        Gui, Add, CheckBox, vShowFindCon gShowThoughts, Show FindConnections
        Gui, Add, CheckBox, x160 y310 vShowFindWords gShowThoughts, Show FindWords
        Gui, Add, CheckBox, x320 y310 vShowFindAltWords gShowThoughts, Show FindAltWords
        Gui, Add, CheckBox, x10 y330 vShowCalculateHowMany gShowThoughts, Show CalculateHowMany
        Gui, Add, CheckBox, x160 y330 vShowIdentifyWordClass gShowThoughts, Show IdentifyWordClass
        Gui, Add, CheckBox, x320 y330 vShowAddConnectionToFile gShowThoughts, Show AddConnectionToFile
        Gui, Add, CheckBox, x10 y350 vAreThoughtsDisabled gDisableThoughts, Disable thoughts
	Gui, Show
	GuiControl, Focus, In
        Gui, Color, ffeaf7
  ;Hedone's GUI
return

DisableThoughts:
Return

Action!:
	GuiControlGet, PTEXT,, In
	line := ""
	dlg := dlg name "♡User♡: " PTEXT "`n"
	logdlg := logdlg name "User: " PTEXT "`n"
	;PTEXT := RegExReplace(PTEXT,"[^\w ]"," ")
        Answer := "Invalid"
  ;Action! is triggered whenever the user sends text.
  ;The player's text is saved as %PTEXT%
  ;Hedone's text is %Answer%
SCtext = %PTEXT%
Gosub, SimplifyCharacters
  ;replaces weird characters (example, ”) with normal ones the code can recognize (example, ")
PTEXT = %SCtext%

SubjectOfNextClause =
RunCount++
If RunCount = 1
  ;if it's the first message the user sent, or if the user just reset the script
{
GoalUnderstood = 0
If PTEXT contains Task
{
If PTEXT not contains New
{
Answer = OK, I will do a task. Which task?
Gosub, HedoneSend
Context = PickTask
GoalUnderstood = 1
Return
}
}
If PTEXT contains New
{
Answer = OK, you will tell me how to do something new. What is it called?
Gosub, HedoneSend
Context = NameNewTask
GoalUnderstood = 1
}
If PTEXT contains Perm
{
Answer = OK, I will save what's said to my Concepts.txt file.
Gosub, HedoneSend
Context = General
GoalUnderstood = 1
}
If PTEXT contains Word Problem,Temp
{
Answer = OK, I will store what's said to a temporary file. If it is a question, I will answer it.
Gosub, HedoneSend
Context = WordProblem
GoalUnderstood = 1
}
If GoalUnderstood = 0
{
Gosub, SemanticParsing
  ;gets the subject, etc
LoopFW4 := 0
Loop, %ActionCount%
{
LoopFW4++
CurrentAction = % Action%LoopFW4%
If CurrentAction = read
{
BookFileName := StrReplace(Object1, " ")
Answer = OK, you will read "%Object1%" to me. Go ahead, read it.
Gosub, HedoneSend
Context = Read
GoalUnderstood = 1
}
}
}
If GoalUnderstood = 0
{
Answer = I have no idea what you want me to do. Try again.
Gosub, HedoneSend
RunCount = 0
}
}

If RunCount > 1
  ;
  ;
  ;if it's not the first message the user sent
  ;
  ;
{
If PTEXT = reset
{
Answer = OK, I will reset.
Gosub, HedoneSend
Answer = Hello. What do you want?
Gosub, HedoneSend
RunCount = 0
Return
}
If Context = PickTask
{
FileNameForSemParse = Concepts
Gosub, CreateAllFilesVar
ConceptForDwOC = ⚶TasksIHave
Gosub, DirectwordsOfConcept
  ;gets all the tasks Hedone knows
LoopPT := 0
Loop, %DirectwordCount%
{
LoopPT++
CurrentDirect = % Directword%LoopPT%
;Thoughts = (Context = PickTask) Now seeing if PTEXT(%PTEXT%) contains CurrentDirect(%CurrentDirect%)
;Gosub, HedoneThink
If PTEXT contains %CurrentDirect%
{
ChosenTask = %CurrentDirect%
Break
}
}
If ChosenTask =
{
Answer = I do not know that task. Try again.
Gosub, HedoneSend
}
Else
{
Answer = OK, I will do task "%ChosenTask%". Go ahead, tell me something and I'll respond to it appropriately. 
Gosub, HedoneSend
Context = CustomTask
ChosenTask := StrReplace(ChosenTask, " ")
Return
}
}
  ;END of PickTask
If Context = CustomTask
{
Gosub, CustomTask
}
If Context = General
{
Answer = I'll save the parsed information to my Concepts.txt semantic net file.
Gosub, HedoneSend
FileNameForSemParse = Concepts
ClauseExaminer = WordProblem
Gosub, SentenceParse
Return
}
If Context = NameNewTask
{
TaskName := StrReplace(PTEXT, " ")
  ;gets rid of spaces
Answer = OK, I will store what you say to a file named "%Taskname%☥Task.txt". Go ahead, explain the Task.
Gosub, HedoneSend
Context = NewTask
FileNameForSemParse = %Taskname%☥Task
Return
}
If Context = NewTask
{
Answer = I'm not going to parse that, but you are explaining the Task %TaskName%.
Gosub, HedoneSend
ClauseExaminer = WordProblem
Gosub, SentenceParse
Return
}
If Context = WordProblem
{
Answer = I'll save the parsed information to my Temp.txt semantic network.
Gosub, HedoneSend
FileNameForSemParse = Temp
ClauseExaminer = WordProblem
Gosub, SentenceParse
Return
}
If Context = Read
{
Answer = I'll save the parsed information to a few %BookFileName% semantic networks.
Gosub, HedoneSend
ClauseExaminer = Read
  ;"ReadClauseExaminer" decides what to do with each clause SentenceParse finds
BookFileName := StrReplace(Object1, " ")
Gosub, SentenceParse
Return
}
}
Return

CustomTask:
SendCount++
FileNameForSemParse = %ChosenTask%☥Task
Gosub, CreateAllFilesVar
ConceptForFCC = message
Gosub, FindConnectionsOfConcept
ConString = %wordsOfwordFCC%
Gosub, GetNumsFromConString
LoopPT := 0
Loop, %ConCount%
{
LoopPT++
CurrentConPT = % ConNum%LoopPT%
if CurrentConPT contains ☠⚙First☠
{
if CurrentConPT contains ☠⚙After☠
{
If SendCount > 1
{
Thoughts = (CustomTask) The connection "%CurrentConPT%" is true of this message, because this message is not the first.
Gosub, HedoneThink
TheFirst = not the first
Gosub, AdjectiveIsTrue
}
}
Else
{
If SendCount = 1
{
Thoughts = (CustomTask) The connection "%CurrentConPT%" is true of this message, because this message is first.
Gosub, HedoneThink
TheFirst = the first
Gosub, AdjectiveIsTrue
}
}
}
}
  ;checks to see if AllCons says anything about the first message
Return

AdjectiveIsTrue:
Constring = %CurrentConPT%
Gosub, GetNumsFromComplexConstring
LoopPTC := 0
Loop, %CConcount%
{
LoopPTC++
CurrentCConPT = % CConNum%LoopPTC%
ConceptForFCC = %CurrentCConPT%
Gosub, FindConnectionsOFConcept
Thoughts = (CustomTask) Connections of %CurrentCCONPT% are %WordsOFWordFCC%, aka %ConsOfWordFCC%
Gosub, HedoneThink
If CurrentCCONpt contains ⚙
{
Continue
}
If WordsOfWordFCC contains verb
{
Continue
}
If WordsOfWordFCC contains tense
{
Continue
}
Answer = This is %thefirst% message you sent, so it is a %CurrentcConPT%. Noted.
Gosub, HedoneSend
}
Return

ReadClauseExaminer:
BookFileNameQuotes = %BookFileName%☥Quotes
BookFileNameConcepts = %BookFileName%☥Concepts
If PTEXT contains ",“,”
{
FileNameForSemParse = %BookFileNameQuotes%
FileRead, %FileNameForSemParse%File, %FileNameForSemParse%.txt
%FileNameForSemParse%File2 = % FileNameForSemParse%File%☻
  ;decides which file to save to
Thoughts = (ReadClauseExaminer) "%PTEXT%" contains a quotation mark, I will assume it contains a quote. I will store the connection to a file named "%FileNameForSemParse%☥Quotes".
Gosub, HedoneThink
Fullstring = %PTEXT%
First = "
Last = "
Gosub, FindFirstToLast
SavedQuote = %FirstToLast%
PTEXT := StrReplace(PTEXT, FirstToLast)
Gosub, SemanticParsing
QuoteForAQTF = %SavedQuote%
Gosub, AddQuoteToFile
Gosub, HedoneSend
}
Else
{
FileNameForSemParse = %BookFileNameConcepts%
FileRead, %FileNameForSemParse%File, %FileNameForSemParse%.txt
%FileNameForSemParse%File2 = % FileNameForSemParse%File%☻
  ;decides which file to save to
Thoughts = (ReadClauseExaminer) " %PTEXT% " does not contain a quotation mark.
Gosub, HedoneThink
Gosub, SemanticParsing
Gosub, AddConnectionToFile
}
Return

WordProblemClauseExaminer:
Gosub, SemanticParsing
If FindHowMany = 1
{
GoSub, CalculateHowMany
FileDelete, TempBackup.txt
FileAppend, %FileVarContents%, TempBackup.txt, UTF-8
FileDelete, Temp.txt
FileRead, TempFile, Temp.txt
TempFile2 = %TempFile%☻
}
Else
{
If OnlyOneConnection = 1
{
Gosub, OnlyOneConnection
}
Else
{
GoSub, AddConnectionToFile
  ;attaches the subjects to the objects, in the file
}
}
Gosub, HedoneSend
Return

SemanticParsing:
TellCons = 1
 MainThoughts =
OnlyOneConnection = 0
 FoundQuote = 0
 FindHowMany = 0
 ConIsHypothetical = 0
 ClauseFound = 0
 UseConceptsFile = 0
 Loopnum1 := 0
 Loop, %WordCount%
 {
 Loopnum1++
 ConsForWord%Loopnum1% =
 }
 Loopnumwtf := 0
 LoopnumAdj := 0
 Loop, %SubjectCount%
 {
 Loopnumwtf++
  CurrentAdjCount = % AdjCountForSub%LoopNumwtf%
  Loop, %CurrentAdjCount%
  {
  LoopnumAdj++
  Adj%LoopnumAdj%OfSubject%Loopnumwtf% =
  }
 AdjCountForSub%LoopNumwtf% =
 PrevClauseSubject%Loopnumwtf% = % Subject%Loopnumwtf%
 Subject%Loopnumwtf% =
 }
 Loopnum3 := 0
 SubjectCount = 1
 Loop, %ActionCount%
 {
 Loopnum3++
 Action%Loopnum3% =
 }
 LoopnumAdj := 0
 LoopnumObj := 0
 Loop, %ObjectCount%
 {
 LoopnumObj++
  CurrentAdjCount = % AdjCountForObj%LoopNumObj%
  Loop, %CurrentAdjCount%
  {
  LoopnumAdj++
  SavedAdj%LoopnumAdj% = % Adj%LoopnumAdj%OfObject1
  Adj%LoopnumAdj%OfObject%LoopnumObj% =
  }
 SavedAdjCount = %AdjCountForObj1%
 AdjCountForObj%LoopNumObj% =
 }
 Loopnum := 0
 Loop, %ObjectCount%
 {
 Loopnum++
 Object%Loopnum% =
 }
 ObjectCount = 1
 ActionCount =
 WordNumVar := 0
 categtrue = 0
 FoundVerb = 0
  ;resets variables
If FileNameForSemParse !=
{
IfNotExist, %FileNameForSemParse%.txt
{
Thoughts = "%FileNameForSemParse%".txt does not exist, so I will create it now.
Gosub, HedoneThink
FileAppend, , %FileNameForSemParse%.txt, UTF-8
FileRead, %FileNameForSemParse%File, %FileNameForSemParse%.txt
%FileNameForSemParse%File2 = %TempFile%☻
}
}
  ;creates the "FileNameForSemParse" file, if it doesn't exist
FileVarName = %FileNameForSemParse%file
FileVarContents := %FileNameForSemParse%file
Gosub, CreateAllFilesVar
  ;creates a variable named "AllFiles2" which contains data from the temp file and the concepts file.
Gosub, FindWords
  ;Turns the message into words
Gosub, FindAltWords
  ;Finds the concepts, multi-word concepts, plural multi-words and plural words in the message and adjusts the variables accordingly. Also finds punctuation.
Gosub, DefineProforms
Gosub, FindConnections
  ;Gets the full constrings (all the connections the concept has) of the concepts
GoSub, TurnCOWintoWords
  ;turn the concept's constring into actual words
Thoughts = I will now examine the sentence. There are %WordCount% words to check.
Gosub, HedoneThink
Gosub, IdentifyWordClass
  ;Assigns various roles to the words, depending on which word class they are. Gets the subjects, action and objects from the message.
Gosub, ThinkSubjectsEtc
Return

  ;START of small gosubs

SimplifyCharacters:
SCtext := StrReplace(SCtext, "“", """")
SCtext := StrReplace(SCtext, "”", """")
Return

OnlyOneConnection:
MainThoughts = (OnlyOneConnection)
LoopnumOOC := 0
StringToAdd = ☠
Loop, %ActionCount%
{
LoopnumOOC++
CurrentAct = % Action%LoopnumOOC%
WordToFind = %CurrentAct%
Gosub, GetNumOfWord
StringToAdd = %StringToAdd%%wordnum%☠
}
LoopnumOOC := 0
Loop, %ObjectCount%
{
LoopnumOOC++
CurrentObj = % Object%LoopnumOOC%
WordToFind = %CurrentObj%
Gosub, GetNumOfWord
StringToAdd = %StringToAdd%%wordnum%☠
  LoopnumOOC2 := 0
  CurrentAdjCount = % AdjCountForObj%LoopNumOOC%
  Loop, %CurrentAdjCount%
  {
  LoopNumOOC2++
  CurrentAdj = % Adj%LoopnumOOC2%OfObject%LoopNumOOC%
  WordToFind = %CurrentAdj%
  Gosub, GetNumOfWord
  StringToAdd = %StringToAdd%%wordnum%☠
  }
  ;gets the StringToAdd
}
StringToAdd = %StringToAdd%☆
ConceptForACTC = %Subject1%
ConnectionForACTC = %StringToAdd%
Gosub, AddConToConcept
Return

UseConceptsFile:
StoredFileVarContents = %FileVarContents%
StoredFileVarName = %FileVarName%
StoredFileNameForSemParse = %FileNameForSemParse%
FileVarContents = %ConceptsFile%
FileVarName = Conceptsfile
FileNameForSemParse = Concepts
Return

RevertUseConceptsFile:
FileVarContents = %StoredFileVarContents%
FileVarName = %StoredFileVarName%
FileNameForSemParse = %StoredFileNameForSemParse%
Return

AddConToConcept:
WordNeedingCons = %ConceptForACTC%
Gosub, ConsOfWordInFileForSemParse
DoesConnectionAlreadyExist := InStr(FileVarContents, ConnectionForACTC)
If DoesConnectionAlreadyExist != 0
{
Thoughts = (AddConToConcept) "%ConceptForACTC%" already has "%ConnectionForACTC%" in the "%FileNameForSemParse%" file so I will not add the connection.
Gosub, HedoneThink
Answer = "%ConceptForACTC%" already has "%ConnectionForACTC%" in the "%FileNameForSemParse%" file so I will not add the connection.
}
Else
{
Thoughts = (AddConToConcept) I will add "%ConnectionForACTC%" to "%ConceptForACTC%" in the "%FileNameForSemParse%" file.
Gosub, HedoneThink
CurrentSubject = ☻%ConceptForACTC%☆
NewSubject = %CurrentSubject%%ConnectionForACTC%
FileVarContents := StrReplace(FileVarContents, CurrentSubject, NewSubject, SubjectIsInFile)
  ;replaces the old subject (excluding the constring) with the same subject, adding the connection
If SubjectIsInFile = 0
{
Thoughts = (AddConToConcept) Concept "%ConceptForACTC%" not in file. Adding to file.
Gosub, HedoneThink
FileVarContents = %FileVarContents%%NewSubject%
}
%FileVarName% = %FileVarContents%
%FileVarName%2 = %FileVarContents%☻
FileDelete, %FileNameForSemParse%.txt
FileAppend, %FileVarContents%, %FileNameForSemParse%.txt, UTF-8
  ;updates the file
Gosub, CreateAllFilesVar
}
Return

CreateFileVarFiles:
FileRead, %FileNameForSemParse%File, %FileNameForSemParse%.txt
FilevarContents := %FileNameForSemParse%File
FileVarName = %FileNameForSemParse%File
%FileVarName% = %FileVarContents%
%FileVarName%2 = %FileVarContents%☻
Return

CreateAllFilesVar:
Gosub, CreateFileVarFiles
WorthlessString := StrReplace(%FileVarName%2, "☻",, ConceptCount)
ConceptCount--
LoopNumCAF := 0
LoopNumCAF2 := 1
AllFiles2 = %ConceptsFile2%
Loop, %ConceptCount%
{
LoopNumCAF++
LoopNumCAF2++
ConceptStart := InStr(%FileVarName%2, "☻",,, LoopNumCAF)
ConceptStart++
ConceptEnd := InStr(%FileVarName%2, "☆",, ConceptStart)
Length := ConceptEnd - ConceptStart
CurrentConcept := SubStr(%FileVarName%2, ConceptStart, Length)
ConsEnd := InStr(%FileVarName%2, "☻",,, LoopNumCAF2)
Length := ConsEnd - ConceptEnd
CurrentConstring := SubStr(%FileVarName%2, ConceptEnd, Length)
AltConcept = ☻%CurrentConcept%☆
AltConceptWithConstring = ☻%CurrentConcept%%CurrentConstring%
AllFiles2 := StrReplace(AllFiles2, AltConcept, AltConceptWithConstring)
}
Return

FindConnectionsOfConcept:
RealWordcount = %WordCount%
Realword1 = %Word1%
RealConsOfWord1 = %ConsOfWord1%
RealWordsOfWord1 = %WordsOfWord1%
Wordcount = 1
Word1 = %ConceptForFCC%
RealMainThoughts = %MainThoughts%
Gosub, FindConnections
Gosub, TurnCOWintowords
MainThoughts = %RealMainThoughts%
ConsOfWordFCC = %ConsOfWord1%
WordsOfWordFCC = %WordsOfWord1%
ConsOfWord1 = %RealConsOfWord1%
WordsOfWord1 = %RealWordsOfWord1%
Word1 = %Realword1%
Wordcount = %RealWordCount%
Return
  ;gets the connections of a single concept

AltFindConnectionsOfConcept:
LoopAFC := 0
Loop, %WordCount%
{
LoopAFC++
Realword%LoopAFC% = % Word%LoopAFC%
RealConsOfWord%LoopAFC% = % ConsOfWord%LoopAFC%
RealWordsOfWord%LoopAFC% = % WordsOfWord%LoopAFC%
}
RealWordcount = %WordCount%
Realword1 = %Word1%
Wordcount = 1
Word1 = %ConceptForFCC%
RealMainThoughts = %MainThoughts%
Gosub, FindConnections
Tellcons = 0
Gosub, TurnCOWintowords
Wordcount = %RealWordCount%
ConsOfWordFCC = %ConsOfWord1%
WordsOfWordFCC = %WordsOfWord1%
LoopAFC := 0
Loop, %WordCount%
{
LoopAFC++
word%LoopAFC% = % RealWord%LoopAFC%
ConsOfWord%LoopAFC% = % RealConsOfWord%LoopAFC%
WordsOfWord%LoopAFC% = % RealWordsOfWord%LoopAFC%
}
MainThoughts = %RealMainThoughts%
Return
  ;gets the connections of a single concept

DefineProforms:
LoopnumDP := 0
Loop, %WordCount%
{
LoopNumDP++
WordNeedingCons = % Word%LoopNumDP%
Gosub, ConsOfWord
  ;gets the direct connections of the word
constringwew = ☆%constring%
If constringwew contains ☆148☆
  ;148 is proform
{
If constringwew contains ☆68☆
   ;68 is adverb
{
;word%LoopNumDP% = here
constringwew = ☆%constring%
}
}
}
Return

CalculateHowMany:
MainThoughts = (CalculateHowMany)
NumberIsMoney = 0
If Action1 = be
{
Gosub, HowManySubjAreObj
}
Else
{
LoopnumCHM := 0
Loop, %ActionCount%
{
LoopnumCHM++
CurrentAction = % Action%LoopnumCHM%
Thoughts = (CalculateHowMany) Current action is %CurrentAction%, it is number %LoopnumCHM%.
Gosub, HedoneThink
WordForFWN = %CurrentAction%
Gosub, FindWordNumber
CurrentWOW = % WordsOfWord%FoundWordNumber%
If CurrentWOW contains ☆be☆
{
Continue
}
If CurrentWOW contains ☆future tense☆
{
Continue
}
ActionToUse = %CurrentAction%
WordForFWN = %CurrentAction%
Gosub, FindWordNumber
WOWCurrentAction = % WordsOfWord%FoundWordNumber%
}
  ;decides which action to use
If WOWCurrentAction contains ☆create☆
{
ConceptForHME = %Subject1%
Gosub, HowManyExists
Return
}
If Object1 =
{
Gosub, HowManySubjVerb
Return
}
Gosub, HowManySubjVerbObj
}
Return

HowManyExistsInner:
NumOfCon = 0
WordForFWN = %ConceptForHMEI%
Gosub, FindWordnumber
If FoundWordNumber = 0
{
ConceptForFCC = %WordForFWN%
Gosub, FindConnectionsOfConcept
FoundWordNumber = FCC
}
WordsOfWord = % WordsOfWord%FoundWordNumber%
Constring := SubStr(WordsOfWord, 2)
Gosub, GetNumsFromConstring
LoopnumZ := 0
Loop, %ConCount%
{
LoopnumZ++
CurrentCon = % ConNum%LoopnumZ%
CurrentCon = ☆%CurrentCon%☆
Fullstring = %CurrentCon%
If CurrentCon contains ☆☰
{
First = ☆☰
Last = ☆
Gosub, FindFirstToLast
Flength = StrLen(FirstToLast)
Flength--
FirstToLast := SubStr(FirstToLast, 3, Flength)
NumOfCon := FirstToLast + NumOfCon
Thoughts = %MainThoughts%(HowManyExists)  There are "%NumOfCon%" "%ConceptForHMEI%".
Gosub, HedoneThink
}
  ;if there is a direct connection to a number in the concept's constring, the number is added to the total.
If CurrentCon contains ☠☰
{
First = ☠☰
Last = ☠
Gosub, FindFirstToLast
Flength = StrLen(FirstToLast)
Flength--
RealFTL = %FirstToLast%
FirstToLast := SubStr(FirstToLast, 3, Flength)
If CurrentCon contains ☠there☠
{
NumOfCon := FirstToLast + NumOfCon
Thoughts = %MainThoughts%(HowManyExists) There are "%NumOfCon%" "%ConceptForHMEI%".
Gosub, HedoneThink
}
Else
{
Thoughts = (HowManyExists) There are "%NumOfCon%" "%ConceptForHMEI%", the number found is not "there" so I will not add it.
Gosub, HedoneThink
}
  ;if there is a complex connection in the concept's expanded constring, and also a "there", it will add the number in the constring to the total.
}
}
Return

HowManyExists:
LoopVC := 0
Loop, %VariableCount%
{
LoopVC++
Variable%LoopVC% =
}
Variablecount = 0
SkullConcept = ☠%ConceptForHME%☠
NumOfCon = 0
FinalNumOfCon = 0
Thoughts = (HowManyExists) Now seeing how many "%ConceptForHME%" exists at this location, or will exist.
Gosub, HedoneThink
ConceptForHMEI = %ConceptForHME%
Gosub, HowManyExistsInner
  ;looks for numbers in the concept's constring
FinalNumOfCon = %NumOfCon%
ConceptForGIR = %ConceptForHME%
Loop,
{
Gosub, GetImmediateReferences
  ;gets the references of a concept, starting with conceptforHME, then the reference to that concept, then the reference to that reference, etc etc
If WordforGIRreference1 =
{
Break
}
ConceptForHMEI = %WordForGIRreference1%
Gosub, HowManyExistsInner
  ;looks for numbers in the concept's constring
If GIRreference1 contains ☠176☠
  ;176 is "split"
{
Thoughts = (HowManyExists) This reference contains the word "split", so I will figure out what I should divide by what.
Gosub, HedoneThink
Constring = %GIRreference1%
Gosub, GetNumsFromComplexConstring
LoopnumA := 0
Loop, %cConCount%
{
LoopnumA++
Currentcon = % cConNum%LoopnumA%
NumToFind = %CurrentCon%
Gosub, GetWordOfNum
ConceptForHMEI = %WordOfNum%
Gosub, HowManyexistsInner
If NumOfCon != 0
{
Thoughts = (HowManyExists) "%ConceptForHMEI%" is now variable "%VariableCount%", there are "%NumOfcon%" of them.
Gosub, HedoneThink
VariableCount++
Variable%VariableCount% = %ConceptForHMEI%
VariableNum%VariableCount% = %NumOfCon%
}
}
If VariableCount != 0
{
SplitResult := (VariableNum1/VariableNum2)
Thoughts = (HowManyExists) "%Variablenum1%" "%Variable1% divided by "%Variablenum2%" "%Variable2%" is "%SplitResult%."
Gosub, HedoneThink
FinalNumOfCon = %SplitResult%
}
}
ConceptForGIR = %WordForGIRreference1%
}
Answer = There are "%FinalNumOfCon%" "%ConceptForHME%"
Return

HowManySubjVerb:
Thoughts = %MainThoughts% Now seeing how many %Subject1%s %ActionToUse%
Gosub, HedoneThink
WordForFWN = %Subject1%
Gosub, FindWordNumber
WordsOfSub = % WordsOfWord%FoundWordNumber%
If WordsOfSub contains ☠%ActionToUse%☠
{
First = ☆
Last = ☆
StringFragment = %ActionToUse%
Fullstring = %WordsOfSub%
UseStringFragment = 1
Gosub, FindBetweenFirstLast
If BetweenFirstLast contains ☰
{
Fullstring = %BetweenFirstLast%
First = ☰
Last = ☠
Gosub, FindFirstToLast
TheNumber = %FirstToLast%
TheNumber := StrReplace(TheNumber, "☠")
TheNumber := StrReplace(TheNumber, "☰")
If TheNumber contains $
{
NumberIsMoney = 1
TheNumber := StrReplace(TheNumber, "$")
}
If Adj1OfSubject1 contains 1,2,3,4,5,6,7,8,9,0
{
TheNumber := (TheNumber*Adj1OfSubject1)
}
}
Answer = The answer is %TheNumber%
}
Else
{
Answer = Invalid question, "%Subject1%" does not "%ActionToUse%".
}
Return

HowManySubjVerbObj:
SubjObj1 = Subject
SubjObj2 = Object
Answer = No, "%Subject1%" does not "%Action1%" "%Object1%".
YesOrNo = no
NumOfSubject = 0
NumOfObject = 0
Thoughts = %MainThoughts% Now starting "how many subjects VERB the object"
Gosub, HedoneThink
SkullObject = ☠%Object1%☠
SkullAct = ☠%Action1%☠
LoopNumSO := 0
Loop, 2
{
LoopNumSO++
CurrentBJ = % SubjObj%LoopNumSO%
  ;"suBJect or oBJect"
If CurrentBJ = Subject
{
WordForFWN = %Subject1%
}
If CurrentBJ = Object
{
WordForFWN = %Object1%
}
Gosub, FindWordnumber
If FoundWordNumber = 0
{
ConceptForFCC = %WordForFWN%
Gosub, FindConnectionsOfConcept
FoundWordNumber = FCC
}
WordsOf%CurrentBJ% = % WordsOfWord%FoundWordNumber%
ConString = % WordsOf%CurrentBJ%
Thoughts = ConString for the "%CurrentBJ%" is "%ConString%", word for FindWordNumber is "%WordForFWN%" and the foundWN is "%FoundWordNumber%"
Gosub, HedoneThink
Gosub, GetNumsFromConstring
LoopnumZ := 0
Loop, %ConCount%
{
LoopnumZ++
CurrentCon = % ConNum%LoopnumZ%
CurrentCon = ☆%CurrentCon%☆
Fullstring = %CurrentCon%
If CurrentCon contains ☆☰
{
First = ☆☰
Last = ☆
Gosub, FindFirstToLast
Flength = StrLen(FirstToLast)
Flength--
FirstToLast := SubStr(FirstToLast, 3, Flength)
CurrentNum = % NumOf%CurrentBJ%
NumOf%CurrentBJ% := FirstToLast + NumOf%CurrentBJ%
Thoughts = There are "%NumOfSubject%" of the subject and "%NumOfObject%" of the object, number found was "%FirstToLast%"
Gosub, HedoneThink
}
If CurrentCon contains ☠☰
{
First = ☠☰
Last = ☠
Gosub, FindFirstToLast
Flength = StrLen(FirstToLast)
Flength--
RealFTL = %FirstToLast%
FirstToLast := SubStr(FirstToLast, 3, Flength)
If CurrentCon contains ☠there☠
{
NumOf%CurrentBJ% := FirstToLast + NumOf%CurrentBJ%
Thoughts = There are "%NumOfSubject%" of the subject and "%NumOfObject%" of the object, number found was "%FirstToLast%"
Gosub, HedoneThink
}
Else
{
Thoughts = There are "%NumOfSubject%" of the subject and "%NumOfObject%" of the object, the number found is not "there" so I will not add it.
Gosub, HedoneThink
}
}
}
}

If WordsOfSubject contains %SkullObject%
{
First = ☆
Last = ☆
FullString = %WordsOfSubject%
StringFragment = %SkullObject%
UseStringFragment = 1
Gosub, FindBetweenFirstLast
FullComplexCon = %BetweenFirstLast%
Thoughts = %MainThoughts% Object found, in complex connection "%FullComplexCon%".
Gosub, HedoneThink
If FullComplexCon contains %SkullAct%
{
YesOrNo = Yes
If FullComplexCon contains 1,2,3,4,5,6,7,8,9,0
{
Loopnum := -1
Loop,
{
Loopnum++
NumberPos := InStr(FullComplexCon, LoopNum)
If NumberPos != 0
{
First = ☠
Last = ☠
FullString = %FullComplexCon%
StringFragment = %LoopNum%
UseStringFragment = 1
Gosub, FindBetweenFirstLast
NumOfSubject := BetweenFirstLast + NumOfSubject
Break
}
}
}
}
}
If NumOfSubject != 0
{
If NumOfSubject < %NumOfObject%
{
Thoughts = The object-number is higher, so I'll assume I should divide the number of objects by the number of subjects.
Gosub, HedoneThink
Result := NumOfObject / NumOfSubject
Answer = The answer is "%Result%". I divided %NumOfObject% %Object1%s by %NumOfSubject% %Subject1%s.
}
Else
{
Result := NumofSubject / NumOfObject
Answer = The answer is "%Result%". I divided %NumOfSubject% %Subject1%s by %NumOfObject% %Object1%s.
}
}
Else
{
If YesOrNo = Yes
{
Answer = Yes, "%Subject1%" "%Action1%" "%Object1%".
}
}
Return

HowManySubjAreObj:
Thoughts = %MainThoughts% Now starting "how many subjects ARE the object"
Gosub, HedoneThink
SkullObject = ☠%Object1%☠
WordForFWN = %Subject1%
Gosub, FindWordnumber
WordsOfSubject = % WordsOfWord%FoundWordNumber%
If WordsOfSubject contains %SkullObject%
{
First = ☆
Last = ☆
FullString = %WordsOfSubject%
StringFragment = %SkullObject%
UseStringFragment = 1
Gosub, FindBetweenFirstLast
FullComplexCon = %BetweenFirstLast%
Thoughts = %MainThoughts% Object found, in complex connection "%FullComplexCon%".
Gosub, HedoneThink
If FullComplexCon contains 1,2,3,4,5,6,7,8,9,0
{
Loopnum := -1
Loop,
{
Loopnum++
NumberPos := InStr(FullComplexCon, LoopNum)
If NumberPos != 0
{
First = ☠
Last = ☠
FullString = %FullComplexCon%
StringFragment = %LoopNum%
UseStringFragment = 1
Gosub, FindBetweenFirstLast
TheNumber = %BetweenFirstLast%
Break
}
}
TheNumber := StrReplace(TheNumber, "☰")
Answer = "%TheNumber%" "%Subject1%"s are "%Object1%".
}
}
Else
{
StarObject = ☆%Object1%☆
If WordsOfSubject contains %StarObject%
  ;if the subject IS the object
{
Answer = "%Subject1%" is "%Object1%".
}
Else
{
Answer = "%Subject1%" is not "%Object1%".
}
}
Return

FindBetweenFirstLast:
If UseStringFragment = 1
{
FragPos := InStr(FullString, StringFragment)
LastPos := InStr(FullString, Last,, FragPos)
FileLength := StrLen(FullString)
Offset := FragPos - FileLength
FirstPos := InStr(FullString, First,, Offset)
}
Else
{
LastPos := InStr(FullString, Last)
FirstPos := InStr(FullString, First)
}
FirstPos++
LastLength := StrLen(Last)
Length := LastPos - FirstPos
BetweenFirstLast := SubStr(FullString, FirstPos, Length)
Thoughts = %MainThoughts%(FindBetweenFirstLast) Found: "%BetweenFirstLast%"
Gosub, HedoneThink
UseStringFragment = 0
Return

FindFirstToLast:
FirstPos := InStr(FullString, First)
FirstPos++
LastPos := InStr(FullString, Last,, FirstPos)
FirstPos--
LastLength := StrLen(Last)
Length := LastPos - FirstPos
Length := Length + LastLength
FirstToLast := SubStr(FullString, FirstPos, Length)
Thoughts = %MainThoughts%(FindFirstToLast) Found: "%FirstToLast%" in "%FullString%". FirstPos is "%FirstPos%" and lastpos is "%LastPos%"
Gosub, HedoneThink
Return

ShowThoughts:
Gui, Submit, NoHide
Gosub, FindShowThoughtsVars
StartVar = (START)
EndVar = (END)
Loopnum := 0
NewDLG = %LOGdlg%
Loop, 6
{
Loopnum++
CurrentShowVar = % ShowVar%Loopnum%
  ;the variable that's 1 when the checkbox is checked and 0 when not. 1 means "show me these thoughts"
CurrentContVar = % ContVar%Loopnum%
  ;example: (ShowFindConnections)
LoopNum2 := 0
WorthlessString := StrReplace(lOGdlg, StartVar,, StartCount)
Loop, %StartCount%
{
LoopNum2++
StartPos := InStr(lOGdlg, StartVar,,, LoopNum2)
StartPos--
EndPos := InStr(lOGdlg, EndVar,,, LoopNum2)
EndPos := EndPos + 5
Length := EndPos - StartPos
CurrentString := SubStr(lOGdlg, StartPos, Length)
  ;gets the next string
If CurrentShowVar = 0
  ;if the thought shouldn't be seen
{
If CurrentString contains %CurrentContVar%
  ;if the current string is a thought that shouldn't be seen
{
NewDLG := StrReplace(NewDLG, CurrentString)
  ;removes the string
}
}
}
}
dlg = %NewDLG%
NewDLG =
dlg := StrReplace(dlg, StartVar)
dlg := StrReplace(dlg, EndVar)
  ;removes the (START)s and (END)s from the dlg, and changes dlg to the edited logdlg
GuiControl,,In,
GuiControl,,Out,%dlg%
SendMessage, 0x115, 7, 0,, ahk_id %outHWND%
  ;sends it to the ui
Return

DirectwordsOfConcept:
wordNeedingCons = %ConceptForDwOC%
Gosub, ConsOfword
Gosub, GetNumsFromConstring
DirectwordCount = %ConCount%
LoopD := 0
Loop, %ConCount%
{
LoopD++
NumToFind = % ConNum%LoopD%
Gosub, GetwordOfNum
Directword%LoopD% = %wordOfNum%
}
Return

SentenceParse:
If PTEXT not contains .
{
PTEXT = %PTEXT%.
}
SentenceCount := 0
Loopnum := 0
StartPosSP := 1
SubStrStart := 1
PuncPos1 = PeriodPos
PuncPos2 = QuestionPos
Loop,
{
Loopnum++
PeriodPos := InStr(PTEXT, .,, StartPosSP)
QuestionPos := InStr(PTEXT, "?",, StartPosSP)
  ;finds the location of the closest period and ?
If PeriodPos = 0
{
PeriodPos := StrLen(PTEXT) + 1
}
If QuestionPos = 0
{
QuestionPos := StrLen(PTEXT) + 1
}
PTEXTLength := StrLen(PTEXT)
PTEXTLength++
If PeriodPos = %PTEXTLength%
{
If QuestionPos = %PTEXTLength%
{
Thoughts = (SentenceParse) No further questionmarks or periods found.
Gosub, HedoneThink
Break
}
}
If PeriodPos > QuestionPos
  ;if the question mark comes first
{
PuncPos = %QuestionPos%
}
Else
{
BeforePeriodPos := PeriodPos - 1
AfterPeriodPos := PeriodPos + 1
BeforePeriod := SubStr(PTEXT, BeforePeriodPos, 1)
AfterPeriod := SubStr(PTEXT, AfterPeriodPos, 1)
If AfterPeriod contains 0,1,2,3,4,5,6,7,8,9
{
If BeforePeriod contains 0,1,2,3,4,5,6,7,8,9
{
  ;if there's a number before and after the period (meaning it's a decimal)
StartPosSP := PeriodPos + 2
Continue
}
}
PuncPos = %PeriodPos%
}
StartPosSP := PuncPos + 2
Length := PuncPos - SubStrStart
SentenceCount++
Sentence%SentenceCount% := SubStr(PTEXT, SubStrStart, Length)
  ;saves the Sentence as Sentence%number%
ThisSentence = % Sentence%SentenceCount%
SubStrStart = %StartPosSP%
RealPTEXT = %PTEXT%
PTEXT = %ThisSentence%
Thoughts = (SentenceParse) Now parsing "%ThisSentence%", clause number "%SentenceCount%", using %ClauseExaminer%ClauseExaminer.
Gosub, HedoneThink
Gosub, %ClauseExaminer%ClauseExaminer
If ClauseFound = 1
{
ClauseWordPos := InStr(PTEXT, StartOfClause)
PTEXT := SubStr(PTEXT, ClauseWordPos)
  ;removes everything in PTEXT before the first word of the clause
Thoughts = (SentenceParse) Now parsing the clause I found earlier, "%PTEXT%", using %ClauseExaminer%ClauseExaminer.
Gosub, HedoneThink
Gosub, %ClauseExaminer%ClauseExaminer
}
PTEXT = %RealPTEXT%
}
Return

FindShowThoughtsVars:
ShowVar1 = %ShowFindCon%
ShowVar2 = %ShowFindWords%
ShowVar3 = %ShowFindAltWords%
ShowVar4 = %CalculateHowMany%
ShowVar5 = %ShowIdentifyWordClass%
ShowVar6 = %ShowAddConnectionToFile%
ContVar1 = (FindConnections)
ContVar2 = (FindWords)
ContVar3 = (FindAltWords)
ContVar4 = (CalculateHowMany)
ContVar5 = (IdentifyWordClass)
ContVar6 = (AddConnectionToFile)
Return

AddQuoteToFile:
FileVarName = %FileNameForSemParse%file
FileVarContents := %FileNameForSemParse%file
MainThoughts = (AddQuoteToFile)
Thoughts = (AddQuoteToFile) Now seeing if "%Subject1%" is in the "%FileNameForSemParse%" file
Gosub, HedoneThink
NewSubject = ☻%Subject1%☆
FileVarContents = %FileVarContents%
Thoughts = (AddConnectionToFile) The contents of the file are %FileVarContents% and the name is %FileVarName%
GoSub, HedoneThink ;AddCons
PosOfWord := InStr(FileVarContents, NewSubject)
If PosOfWord = 0
{
Thoughts = (AddQuoteToFile) "%Subject1%" is not in my "%FileNameForSemParse%" file, so I will add it.
Gosub, HedoneThink
%FileVarName% = %FileVarContents%%NewSubject%
%FileVarName%2 = %FileVarContents%%NewSubject%☻
FileVarContents = %FileVarContents%%NewSubject%
FileDelete, %FileNameForSemParse%.txt
FileAppend, %FileVarContents%, %FileNameForSemParse%.txt, UTF-8
Gosub, CreateAllFilesVar
}
Else
{
Thoughts = (AddQuoteToFile) "%Subject1%" is in my "%FileNameForSemParse%" file.
Gosub, HedoneThink
}
WordToFind = %Action1%
Gosub, GetNumOfWord
ConnectionForACTC = %Wordnum%☆☄%QuoteForAQTF%☆
ConceptForACTC = %Subject1%
Gosub, AddConToConcept
Return

ChangeWordClasses:
LoopCWC := 0
Loop, %SubjectCount%
{
LoopCWC++
CurrentSubjectCWC = % Subject%LoopCWC%
WordForFWN = %Object1%
Gosub, FindWordNumber
CurrentObjectLocation = %FoundWordNumber%
CurrentSubjectStarsCWC = ☆%CurrentSubjectCWC%☆
If CurrentSubjectStarsCWC contains ☆there☆
{
CurrentWordsOFWord = % WordsOfWord%CurrentObjectLocation%
NumberOfThingThere := StrReplace(Adj1OfObject1, ☰)
Thoughts = MainThoughts(ChangeWordClasses) Because the subject is "there", I will switch the subject with the object. I will then look to see if it "has" any number of things. If it does, I will save "☠☰num☠there☠" as a connection to that thing, multiplying num by "%NumberOfThingThere%".
Gosub, HedoneThink
Subject1 = %Object1%
Object1 = %CurrentSubjectCWC%
Constring = %CurrentWordsOfWord%
Gosub, GetNumsFromConstring
LoopCWC2 := 0
Loop, %ConCount%
{
LoopCWC2++
CurrentConCWC = % ConNum%LoopCWC2%
If CurrentConCWC contains ☰
{
Constring = %CurrentConCWC%
Gosub, GetNumsFromComplexConstring
LoopCWC3 := 0
HasHas = 0
NumberOfConcept =
FoundConceptCWC =
Loop, %CCONCount%
{
LoopCWC3++
CurrentCCON = % CCONNUM%LoopCWC3%
If CurrentCCON = has
{
HasHas = 1
Continue
}
If CurrentCCON contains ☰
{
NumberOfConcept := StrReplace(CurrentCCON, "☰")
NumberOfConcept := NumberOfConcept * NumberOfThingThere
Continue
}
FoundConceptCWC = %CurrentCCON%
}
  ;end of CCON loop
If FoundConceptCWC !=
{
If NumberOfConcept !=
{
If HasHas = 1
{
  ;if a number, "has" and concept was found in the connection
WordToFind = There
Gosub, GetNumOfWord
ConnectionForACTC = ☠☰%NumberOfConcept%☠%Wordnum%☠☆
ConceptForACTC = %FoundConceptCWC%
Gosub, AddConToConcept
}
}
}

}
}
}
}
Return

AddConnectionToFile:
FileVarName = %FileNameForSemParse%file
FileVarContents := %FileNameForSemParse%file
MainThoughts = (AddConnectionToFile)
Gosub, ChangeWordClasses
if Object1 !=
{
Gosub, AddCons
}
Else
{
If WordNumVar = 1
{
Thoughts = (AddConnectionToFile) Now seeing if %Subject1% is in the "%FileNameForSemParse%" file
Gosub, HedoneThink
NewSubject = ☻%Subject1%☆
FileVarContents = %FileVarContents%
Thoughts = (AddConnectionToFile) The contents of the file are %FileVarContents% and the name is %FileVarName%
GoSub, HedoneThink ;AddCons
PosOfWord := InStr(FileVarContents, NewSubject)
If PosOfWord = 0
{
%FileVarName% = %FileVarContents%%NewSubject%
%FileVarName%2 = %FileVarContents%%NewSubject%☻
FileVarContents = %FileVarContents%%NewSubject%
FileDelete, %FileNameForSemParse%.txt
FileAppend, %FileVarContents%, %FileNameForSemParse%.txt, UTF-8
Gosub, CreateAllFilesVar
}
Else
{
Thoughts = (AddConnectionToFile) "%Subject1%" is already in my "%FileNameForSemParse%" file.
}
}
Else
{
If Object1 =
{
Thoughts = (AddConnectionToFile) I don't know the object. I will assume the object is the last word, %CurrentWord%
Gosub, HedoneThink
ObjectCount++
Object%ObjectCount% = %CurrentWord%
Gosub, AddCons
}
Else
{
NewSubject = ☻%Subject%☆
PosOfWord := InStr(%FileNameForSemParse%File, NewSubject)
If PosOfWord = 0
{
Answer = Subject is not in "%FileNameForSemParse%" file. Adding new concept to file.
NewSubject = ☻%PTEXT%☆
ThisFile = % FileNameForSemParse%File%
%FileNameForSemParse%file = %ThisFile%%NewSubject%
%FileNameForSemParse%file2 = %ThisFile%%NewSubject%☻
FileDelete, %FileNameForSemParse%.txt
FileAppend, %ThisFile%, %FileNameForSemParse%.txt, UTF-8
Gosub, CreateAllFilesVar
}
Else
{
Answer = This concept is in my "%FileNameForSemParse%" file.
}
}
}
}
Return

TurnConstringIntoWords:
FirstLetter := SubStr(ConstringForCIW, 1, 1)
If FirstLetter = ☆
{
ConstringForCIW := SubStr(ConstringForCIW, 2)
}
If ConstringForCIW not contains ☆
{
ConstringForCIW = %ConstringForCIW%☆
}
RealWordcount = %WordCount%
WordCount = 1
Realword1 = %Word1%
Word1 = WordstringWord
RealConsOfWord1 = %ConsOfWord1%
RealWordsOfWord1 = %WordsOfWord1%
ConsOfWord1 = %ConstringForCIW%
Tellcons = 0
Gosub, TurnCOWintowords
Word1 = %RealWord1%
Wordstring = %WordsOfWord1%
WordsOfWord1 = %RealWordsOfWord1%
ConsOfWord1 = %RealConsOfWord1%
Wordcount = %RealWordcount%
Thoughts = %MainThoughts%(TurnConstringIntoWords) Words of constring %ConstringForCIW% are %Wordstring%.
Gosub, HedoneThink
Return

GetImmediateReferences:
WordForGIRReference1 =
NumForGIRReference1 =
GIRReference1 =
WordToFind = %ConceptForGIR%
Gosub, GetNumOfWord
SkullConGIR = ☠%wordnum%☠
StarConGIR = ☆%wordnum%☆
RefPosSkull := InStr(AllFiles2, SkullConGIR)
RefPosStar := InStr(AllFiles2, StarConGIR)
If RefPosSkull != 0
{
NextSmilePos := InStr(AllFiles2, "☻",, RefPosSkull)
StarAfterSmilePos := InStr(AllFiles2, "☆",, NextSmilePos)
LengthGIR := StarAfterSmilePos - NextSmilePos
NextConcept := SubStr(AllFiles2, NextSmilePos, LengthGIR)
  ;finds the concept after the one with the reference
WordToFind := SubStr(NextConcept, 2)
Gosub, GetNumOfWord
Wordnum--
NumForGIRReference1 = %Wordnum%
NumToFind = %wordnum%
Gosub, GetWordOfNum
WordForGIRReference1 = %WordOfNum%
FullString = %AllFiles2%
First = ☆
Last = ☆
StringFragment = %SkullConGIR%
UseStringFragment = 1
Gosub, FindBetweenFirstLast
GIRReference1 = %BetweenFirstLast%
ConstringForCIW = %GIRReference1%
Gosub, TurnConstringIntoWords
Thoughts = (GetImmediateReferences) Complex reference to "%ConceptForGIR%" found, it is "%Wordstring%" (%GIRReference1%), the owner is "%WordForGIRReference1%".
Gosub, HedoneThink
}
Else
{
If RefPosStar != 0
{
NextSmilePos := InStr(AllFiles2, "☻",, RefPosStar)
StarAfterSmilePos := InStr(AllFiles2, "☆",, NextSmilePos)
LengthGIR := StarAfterSmilePos - NextSmilePos
NextConcept := SubStr(AllFiles2, NextSmilePos, LengthGIR)
  ;finds the concept after the one with the reference
WordToFind := SubStr(NextConcept, 2)
Thoughts = Wordtofind is %WordToFind%
Gosub, HedoneThink
Gosub, GetNumOfWord
Wordnum--
NumForGIRReference1 = %Wordnum%
NumToFind = %wordnum%
Gosub, GetWordOfNum
WordForGIRReference1 = %WordOfNum%
GIRReference1 = %StarConGIR%
Thoughts = (GetImmediateReferences) Direct reference to "%ConceptForGIR%" found, it is "%GIRReference1%", the owner is "%WordForGIRReference1%".
Gosub, HedoneThink
}
Else
{
Thoughts = (GetImmediateReferences) No references to "%ConceptForGIR%" found.
Gosub, HedoneThink
}
}
Return
  ;gets the immediate references (connections in the file where the concept is referenced) of the concept %ConceptForGIR%. Returns %Reference[num]%, %ConceptOfReference[num]% and %ReferenceCount%

FindQuoteMarks:
If CurrentWord contains "
{
WorthlessString := StrReplace(CurrentWord, """",, QuoteCount)
If QuoteCount = 1
{
If FoundQuote = 0
{
Thoughts = %MainThoughts% "%CurrentWord%" has 1 quotation mark. I will assume this is the first word in a multi-word concept, because no other quote has been found
Gosub, HedoneThink
ConsToAdd = % ConsForWord%LoopNumFAW%
ConsForWord%LoopNumFAW% = %ConsToAdd%☠36☠131☠☆
WordWithQuote = %CurrentWord%
Word%LoopNumFAW% := StrReplace(CurrentWord, """")
CurrentWord = % Word%LoopNumFAW%
FoundQuote = 1
}
Else if FoundQuote = 1
{
FullString = %PTEXT%
First = %WordWithQuote%
Last = %CurrentWord%
Gosub, FindFirstToLast
Word%LoopNumFAW% := StrReplace(CurrentWord, """")
CurrentWord = % Word%LoopNumFAW%
NoQuoteFTL := StrReplace(FirstToLast, """")
Thoughts = %MainThoughts% "%CurrentWord%" had 1 quotation mark. I will assume this is the last word in a multi-word concept, because another quote was found earlier. The multi-word concept is "%NoQuoteFTL%".
Gosub, HedoneThink
AltFTL = ☻%NoQuoteFTL%☆
MultiWordPos := InStr(ConceptsFile2, AltFTL)
If MultiWordPos = 0
{
StringToAdd = %AltFTL%
UseConceptsFile = 1
Gosub, AddToFile
}
FoundQuote = 0
}
}
Else
{
Thoughts = %MainThoughts% "%CurrentWord%" has multiple quotation marks, I will add "has quotation marks" to its connections in FindConnections.
Gosub, HedoneThink
ConsToAdd = % ConsForWord%LoopNumFAW%
ConsForWord%LoopNumFAW% = %ConsToAdd%☠36☠132☠☆
}
}
Gosub, FindMultiWordConcepts
Return

LoopingFindQuoteMarks:
Loop,
{
LoopNumFAW := 0
Loop, %WordCount%
{
LoopNumFAW++
CurrentWord = % word%LoopNumFAW%
Gosub, FindQuoteMarks
 ;finds quotation marks
If FMWFoundMultiWord = 1
{
Break
}
}
If FMWFoundMultiWord = 0
{
Return
}
}
Return

FindAltWords:
MainThoughts = (FindAltWords)
Gosub, LoopingFindQuoteMarks
Gosub, FindMultiWordConcepts
  ;checks for multi-word concepts
FindPlurals = 1
Gosub, FindMultiWordConcepts
  ;checks for plural multi-word concepts
LoopNumFAW := 0
Thoughts = (FindAltWords) There are "%WordCount%" words to check.
Gosub, HedoneThink ;FindPlurals
Loop, %WordCount%
{
LoopNumFAW++
CurrentWord = % word%LoopNumFAW%
Thoughts = (FindAltWords) Current word is word"%LoopNumFAW%" ("%CurrentWord%")
Gosub, HedoneThink ;FindPlurals
WordToFind = ☻%CurrentWord%☆
PosOfWord := InStr(ConceptsFile2, WordToFind)
If PosOfWord = 0
  ;if the word isn't in the concepts file
{
PluralEnd1 = s
PluralEnd2 = es
PluralEnd3 = 
Punc1 = .
Punc2 = ,
Punc3 = ?
Punc4 = !
Punc5 =
HasPunc1 = ☠36☠39☠☆
HasPunc2 = ☠36☠40☠☆
HasPunc3 = ☠36☠44☠☆
HasPunc4 = ☠36☠45☠☆
HasPunc5 =
PluralCon1 = 35☆
PluralCon2 = 35☆
PluralCon3 =
PuncLoopNum := 0
Loop, 5
{
PuncLoopNum++
CurrentPunc = % Punc%PuncLoopNum%
CurrentHasPunc = % HasPunc%PuncLoopNum%
  ;switches to the next punctuation
PluralLoopNum := 0
Loop, 3
{
PluralLoopNum++
If PluralLoopNum = 3
{
If PuncLoopNum = 5
{
Break 2
}
}
CurrentPluralCon = % PluralCon%PluralLoopNum%
CurrentPluralEnd = % PluralEnd%PluralLoopNum%
EndLetters = %CurrentPluralEnd%%CurrentPunc%
  ;switches to the next plural
Gosub, CheckEndLetters
If Word%LoopNumFAW% != %CurrentWord%
  ;if CheckEndLetters changed the word
{
ConsToAdd = % ConsForWord%LoopNumFAW%
ConsForWord%LoopNumFAW% = %ConsToAdd%%CurrentPluralCon%%CurrentHasPunc%
  ;adds "has whatever punctuation the word has" and/or "is plural" to the word's constring
ConsVar = % ConsForWord%LoopNumFAW%
Thoughts = (FindAltWords) I will add %ConsVar% to the word's constring, in FindConnections.
Gosub, HedoneThink ;FindCon
If CurrentPunc = ?
{
Thoughts = (FindAltWords) This word has a "?", so I will use the clause to answer the question.
Gosub, HedoneThink
FindHowMany = 1
}
Break 2
}
}
}
  ;checks for all possible punctuation/plural combinations
Thoughts = (FindAltWords) Word"%LoopNumFAW%" is now "%CurrentWord%"
Gosub, HedoneThink ;FindPlurals
Word%LoopNumFAW% = %CurrentWord%
  ;changes the word to be the word it should be
}
  ;end of "if posofword = 0". 
}
Return

CheckEndLetters:
EndLetterCount := StrLen(EndLetters)
LengthMinusEL := StrLen(CurrentWord)
Loop, %EndLetterCount%
{
LengthMinusEL--
}
WordWithoutEL := SubStr(CurrentWord, 1, LengthMinusEL)
AltWordWithoutEL = ☻%WordWithoutEL%☆
LengthMinusEL++
WordEndLetters := SubStr(CurrentWord, LengthMinusEL, EndLetterCount)
If WordEndLetters = %EndLetters%
  ;If the word ends in EndLetters
{
WordIsInFile := InStr(ConceptsFile2, AltWordWithoutEL)
if WordIsInFile != 0
  ;if the new word is in the file
{
Thoughts = %MainThoughts%(CheckEndLetters) %CurrentWord%, without "%EndLetters%", was found in the file. the current word no longer has "%EndLetters%" at the end.
Gosub, HedoneThink
CurrentWord = %WordWithoutEL%
%ConceptNum%IsAlt = 1
}
}
Return
  ;checks to see if %CurrentWord% ends in %EndLetters%. If it does, without %EndLetters%, to see if it exists in the file without the endletters. If it does, CurrentWord has those EndLetters taken off.

CheckRelationship:
CRvalue = 0
If WordForCR =
{
Thoughts = %MainThoughts%(CheckRelationship) Subroutine cannot run, as WordForCR is not set.
Gosub, HedoneThink
Return
}
If CRword1 =
{
Thoughts = %MainThoughts%(CheckRelationship) Subroutine cannot run, as CRword1 is not set.
Gosub, HedoneThink
Return
}
LoopNumCR := 0
CurrentCRnumber = 0
Thoughts = %MainThoughts%(CheckRelationship)
Loop,
{
LoopNumCR++
CurrentCRword = % CRword%LoopnumCR%
Thoughts = %Thoughts% CRword"%LoopnumCR%" is "%CurrentCRword%",
If CRword%LoopNumCR% =
{
LoopNumCR--
CRcount = %LoopNumCR%
Thoughts = %Thoughts% and the word being checked is "%WordForCR%".
Gosub, HedoneThink
Break
}
}
WordForFWN = %WordForCR%
Gosub, FindWordNumber
ConString = % WordsOfWord%FoundWordNumber%
Gosub, GetNumsFromConstring
LoopNumCR := 0
Loop, %ConCount%
{
LoopNumCR++
CurrentCon = % ConNum%LoopNumCR%
  ;gets the next connection
Thoughts = %MainThoughts%(CheckRelationship) Now checking "%CurrentCon%"
Gosub, HedoneThink
If CurrentCon not contains ☠
{
Continue
}
  ;skips the connection, if it's not a complex connection
Else
{
Thoughts = %MainThoughts%(CheckRelationship) Found a complex connection, it is "%CurrentCon%"
Gosub, HedoneThink
If CurrentCon contains %CRword1%
{
LoopNumCR2 := 0
CRvalue = 1
Loop, %CRcount%
{
LoopNumCR2++
CurrentCRWord = % CRword%LoopNumCR2%
If CurrentCon not contains %CurrentCRWord%
{
Thoughts = %MainThoughts%(CheckRelationship) "%CurrentCRword%" not found, in "%CurrentCon%". I will check the next complex connection.
Gosub, HedoneThink
CRvalue = 0
Break
}
}
If CRvalue = 1
{
Thoughts = %MainThoughts%(CheckRelationship) All CRwords were found in that complex connection. Ending subroutine, with CRvalue set to 1.
Gosub, HedoneThink
Gosub, ClearCheckRelationshipVars
Return
}
}
}
}
Gosub, ClearCheckRelationshipVars
Return
  ;Needs %WordForCR% and %CRword[number]% (as many words as wanted). If they're in the same complex connection, CRvalue is 1, otherwise it's 0.

AddDirectConnectionsToConcept:
LoopnumADC := 0
Thoughts = %MainThoughts%(AddDirectConnectionsToConcept) Added 
Loop,
{
LoopnumADC++
CurrentConcept = % ConceptADC%LoopnumADC%
Thoughts = %Thoughts% "%CurrentConcept%"
If CurrentConcept =
{
LoopnumADC--
ConceptCountADC = %LoopnumADC%
Break
}
}
Thoughts = %Thoughts% to %ConceptForADC%
Gosub, HedoneThink
LoopnumADC := 0
Loop, %ConceptCountADC%
{
LoopnumADC++
CurrentConcept = % ConceptADC%LoopnumADC%
WordToFind = %CurrentConcept%
Gosub, GetNumOfWord
ConsToAddADC = %ConsToAddADC%%wordnum%☆
}
ConceptForACTC = %ConceptForADC%
ConnectionForACTC = %ConsToAddADC%
Gosub, UseConceptsFile
Gosub, AddConToConcept
Gosub, RevertUseConceptsFile
Return

ClearCheckRelationshipVars:
LoopnumCCRV := 0
Loop, %CRcount%
{
LoopnumCCRV++
CRword%LoopNumCCRV% =
}
Return

IdentifyWordClass:
MainThoughts = (IdentifyWordClass)
QuestionWordFound = 0
Loop, %WordCount%
{
MultiWordConcept = 0
Num3 := 0
CanBeObjSubj = 0
CanBeAdj = 0
WordNumVar++
NextWordNum := WordNumVar + 1
LastWordNum := WordNumVar - 1
ConsForWord%WordNumVar% =
ThisWord =
CurrentWord = % Word%WordNumVar%
WordForCR = %CurrentWord%
Thoughts = (IdentifyWordClass) (New Word) The current word is %CurrentWord%, it is number %WordNumVar%
Gosub, HedoneThink
Num2 := WordNumVar
Num2--
Thoughts = (IdentifyWordClass) The word "%CurrentWord%" is now being identified.
Gosub, HedoneThink
If WordsOfWord%NextWordNum% contains ☆of☆
{
Thoughts = (IdentifyWordClass) The next word is "of", so this is the first word of a three-word multi-word concept.
Gosub, HedoneThink
ConceptADC1 = % Word%WordNumVar%
NextWordNum++
ConceptADC2 = % Word%NextWordNum%
WordToFindP1 = % Word%WordNumVar%
WordToFindP2 = of
WordToFindP3 = % Word%NextWordNum%
WordToFind = %WordToFindP1% %WordToFindP2% %WordToFindP3%
Gosub, GetNumOfWord
Gosub, FindMultiWordConcepts
NextWordNum--
ConceptForADC = % Word%WordNumVar%
Gosub, AddDirectConnectionsToConcept
CurrentWord = % Word%WordNumVar%
CanBeObjSubj = 1
}
If WordsOfWord%WordNumVar% contains ☆question word☆
{
Thoughts = question word found.
Gosub, HedoneThink
QuestionWordFound = 1
QuestionWordNum = %WordNumVar%
}
If WordsOfWord%WordNumVar% contains ☆preposition☆
{
 ThisWord = preposition
 If WordsOfWord%LastWordNum% contains ☆noun☆
 {
 If WordsOfWord%NextWordNum% contains ☆noun☆
 {
 If FoundVerb = 0
 {
 AdjCountForSubj%SubjectCount%++
 CurrentAdjCount = % AdjCountForSubj%SubjectCount%
 Adj%CurrentAdjCount%OfSubject%SubjectCount% = % Subject%SubjectCount%
 AdjCountForSubj%SubjectCount%++
 CurrentAdjCount = % AdjCountForSubj%SubjectCount%
 Adj%CurrentAdjCount%OfSubject%SubjectCount% = % Word%WordNumVar%
 }
Else
 {
 AdjCountForObj%ObjectCount%++
 CurrentAdjCount = % AdjCountForObj%ObjectCount%
 Adj%CurrentAdjCount%OfObject%ObjectCount% = % Object%ObjectCount%
 AdjCountForObj%ObjectCount%++
 CurrentAdjCount = % AdjCountForObj%ObjectCount%
 Adj%CurrentAdjCount%OfObject%ObjectCount% = % Word%WordNumVar%
 }
Thoughts = %MainThoughts% The previous and next words are nouns, so I turned this word and the former into adjectives.
Gosub, HedoneThink
 }
 }
CanBeAdj = 1
}
If WordsOfWord%WordNumVar% contains ☆conjunction☆
{
 ThisWord = conjunction
WordForCR = % Word%LastWordNum%
 CRword1 = Has
 CRword2 = Comma
 Gosub, CheckRelationship
 If CRvalue = 1
  ;if the previous word had a comma
 {
StartOfClause = % Word%WordNumVar%
WordCount = %LastWordNum%
ClauseFound = 1
 Thoughts = (IdentifyWordClass) This word is a conjunction that comes after a comma, so it's the beginning of a new clause. I will ignore this word and everything that comes after it. WordCount is now %WordCount%. I'll run SemanticParsing again in SentenceParse to understand the clause.
FindHowMany = 0
 Gosub, HedoneThink
 Break
 }
WordForCR = % Word%WordNumVar%
 If WordsOfWord%WordNumVar% contains ☆if☆
 {
 Thoughts = (IdentifyWordClass) This clause is a hypothetical. I will do nothing.
 Gosub, HedoneThink
 ConIsHypothetical = 1
 }
If WordsOfWord%WordNumVar% contains ☆and☆
   {
 If FoundVerb = 0
   {
 SubjectCount++
 Thoughts = (IdentifyWordClass) SubjectCount is now "%SubjectCount%"
 Gosub, HedoneThink
   }
Else
   {
 ObjectCount++
 Thoughts = (IdentifyWordClass) ObjectCount is now "%ObjectCount%"
 Gosub, HedoneThink
   }
   }
}
If WordsOfWord%WordNumVar% contains ☆verb☆
{
 ThisWord = verb
 FoundVerb = 1
 ActionCount++
 If WordsOfWord%WordNumVar% contains ☆be☆
 {
 Action%ActionCount% = be
 }
 Else
 {
 Action%ActionCount% = %CurrentWord%
 }
 If QuestionWordFound = 1
 {
 If Subject1 =
 {
  ;if a question word was found and no subject was found
Thoughts = Question word was found, and there is no subject. This is not an action.
Gosub, HedoneThink
 Action%Actioncount% =
 FoundVerb = 0
 ActionCount--
 QuestionWordNum++
 If WordsOfWord%QuestionWordNum% contains ☆many☆
 {
Thoughts = The word after the question word means "many", so this clause's object is the subject of the last clause.
Gosub, HedoneThink
  Object%ObjectCount% = %PrevClauseSubject1%
 }
 QuestionWordNum--
} 
 }
}
If WordsOfWord%WordNumVar% contains ☆noun☆
{
 ThisWord = noun
CanBeObjSubj = 1
}
If WordsOfWord%WordNumVar% contains ☆adjective☆
{
 ThisWord = adjective
CanBeAdj = 1
}
If Word%WordNumVar% contains 0,1,2,3,4,5,6,7,8,9
{
If Word%WordNumVar% not contains a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z
{
ThisWord = number
CanBeAdj = 1
}
}
If WordsOfWord%WordNumVar% contains ☆adverb☆
{
 ThisWord = adverb
If WordsOfWord%WordNumVar% contains ☆proform☆
{
 CanBeObjSubj = 1
}
WordForCR = % Word%LastWordNum%
 CRword1 = Has
 CRword2 = Comma
 Gosub, CheckRelationship
 If CRvalue = 1
 {
StartOfClause = % Word%WordNumVar%
WordCount = %LastWordNum%
ClauseFound = 1
 Thoughts = (IdentifyWordClass) This word is an adverb that comes after a comma, so it's the beginning of a new clause. I will ignore this word and everything that comes after it. WordCount is now %WordCount%. I'll run SemanticParsing again in SentenceParse to understand the clause.
FindHowMany = 0
 Gosub, HedoneThink
 Break
 }
If WordsOfWord%WordNumVar% not contains ☆location☆,☆proform☆,☆question word☆
{
 ActionCount++
 Action%ActionCount% = %CurrentWord%
}
WordForCR = % Word%WordNumVar%
}
If WordsOfWord%WordNumVar% contains ☆determiner☆
{
 ThisWord = determiner
 If WordsOfWord%WordNumVar% contains ☆demonstrative☆
{
If Object1 !=
{
NextWordNum := WordNumVar + 1
StartOfClause = % Word%NextWordNum%
WordCount = %LastWordNum%
ClauseFound = 1
FindHowMany = 0
 Thoughts = (IdentifyWordClass) This word is a demonstrative-determiner, so it's the beginning of a new clause.
Gosub, HedoneThink
Break
}
}
 If WordsOfWord%WordNumVar% not contains ☆a☆,☆an☆
{
 If WordsOfWord%LastWordNum% contains ☆adverb☆
{
 Thoughts = (IdentifyWordClass) This is a determiner, and the last word was an adverb. I'll assume this means "how many". I will use the subject and the object to figure out how many of the subject verbs the object.
 Gosub, HedoneThink
 FindHowMany = 1
}
}
}
If WordsOfWord%WordNumVar% contains ☆pronoun☆
{
 ThisWord = pronoun
CanBeObjSubj = 1
}
if ThisWord =
{
 ThisWord = unknown
  Thoughts = (IdentifyWordClass) The word "%CurrentWord%" has no category.
  Gosub, HedoneThink
CanBeObjSubj = 1
}
 Thoughts = (IdentifyWordClass) "%CurrentWord%" is a "%ThisWord%"
 Gosub, HedoneThink
If CanBeAdj = 1
{
 If FoundVerb = 1
 {
 AdjCountForObj%ObjectCount%++
 CurrentAdjCount = % AdjCountForObj%ObjectCount%
 Adj%CurrentAdjCount%OfObject%ObjectCount% = %CurrentWord%
 CurrentAdj = % Adj%CurrentAdjCount%OfObject%ObjectCount%
 Thoughts = (IdentifyWordClass) Current word is object "%objectCount%"'s "%CurrentAdjCount%"th adjective.
 Gosub, HedoneThink
 }
 Else
 {
 AdjCountForSub%SubjectCount%++
 CurrentAdjCount = % AdjCountForSub%SubjectCount%
 Adj%CurrentAdjCount%OfSubject%SubjectCount% = %CurrentWord%
 CurrentAdj = % Adj%CurrentAdjCount%OfSubject%SubjectCount%
 Thoughts = (IdentifyWordClass) Current word is subject "%SubjectCount%"'s "%CurrentAdjCount%" adjective.
 Gosub, HedoneThink
 }
}
If CanBeObjSubj = 1
{
 If FoundVerb = 1
 {
 Thoughts = (IdentifyWordClass) %CurrentWord% is the object, because a verb was found
 Gosub, HedoneThink
 Object%ObjectCount% = %CurrentWord%
 }
 Else
 {
 Thoughts = (IdentifyWordClass) %CurrentWord% is the subject because no verb has been found
 Gosub, HedoneThink
 Subject%SubjectCount% = %CurrentWord%
 }
}
}
if Subject1 =
{
Thoughts = (IdentifyWordClass) I don't know the subject. I will assume the subject is the first word, "%Word1%".
Gosub, HedoneThink
Subject1 = %Word1%
}
Return
  ;finds the subjects, actions and objects in the sentence, based on what the word class is.

TurnCOWintoWords:
Numb := 0
Loop, %WordCount%
{
Numb++
ConString = % ConsOfWord%Numb%
Gosub, GetWordsFromConString
AllWords := StrReplace(AllWords, "☠☠", "☠")
TheWord = % Word%Numb%
WordsOfWord%Numb% = %AllWords%
TheCons = % WordsOfWord%Numb%
If TellCons = 1
{
 Thoughts = (TurnCOWintoWords) the cons of "%TheWord%" are "%TheCons%"
 Gosub, HedoneThink
 Thoughts = %MainThoughts%(TurnCOWintoWords) and the constring is "%ConString%"
 Gosub, HedoneThink
}
}
TellCons = 1
Return
  ;TurnCOWintoWords gets the connected words of each word, saving them as WordsOfWord1, 2, 3, etc

GetWordsFromConString:
Constring := StrReplace(Constring, "☠☠", "☠")
  ;gets rid of double-skulls
Numgwc := 0
AllWords =
Gosub, GetNumsFromConString
Loop, %ConCount%
{
Numgwc++
CurrentCon = % ConNum%Numgwc%
if CurrentCon contains ☠
{
AllWords = %AllWords%☆
LoopNumSkull := 0
LoopNumSkull2 := 1
Loop,
{
LoopNumSkull++
LoopNumSkull2++
FirstSkullPos := InStr(CurrentCon, "☠",,, LoopNumSkull)
SecondSkullPos := InStr(CurrentCon, "☠",,, LoopNumSkull2)
FirstSkullPos++
SecondSkullPos--
SkullLength := SecondSkullPos - FirstSkullPos
SkullLength++
SkullNum := SubStr(CurrentCon, FirstSkullPos, SkullLength)
If SkullNum =
{
 ;Thoughts = %MainThoughts%(GetWordsFromConstring) SkullNum%LoopNumSkull% not found. Ending search.
 ;Gosub, HedoneThink ;GetWords
Break
}
NumtoFind = %SkullNum%
Gosub, GetWordOfNum
SkullWord = %WordOfNum%
If SkullNum contains ☰
{
SkullWord := SkullNum
}
 ;Thoughts = %MainThoughts%(GetWordsFromConstring) SkullNum"%LoopNumSkull%" found. It is "%SkullNum%", the word is "%SkullWord%".
 ;Gosub, HedoneThink ;GetWords
WordNum%Num% = %SkullWordNums%☠%SkullWord%
SkullWordNums = % WordNum%Numgwc%
AllWords = %AllWords%☠%SkullWord%
}
WordNum%Numgwc% = %SkullWordNums%☠
AllWords = %AllWords%☠
}
Else
{
If CurrentCon not contains ☰
{
ConBegin := InStr(ConceptsFile2, "☻",,, ConNum%Numgwc%)
ConBegin++
  ;finds the comma of the word
ConEnd := InStr(ConceptsFile2, "☆",, ConBegin)
  ;finds the period after the comma
ConLength := ConEnd - ConBegin
WordNum%Numgwc% := SubStr(ConceptsFile2, ConBegin, ConLength)
ThisWord = % WordNum%Numgwc%
AllWords = %AllWords%☆%ThisWord%
}
Else
{
AllWords = %AllWords%☆%CurrentCon%
}
}
}
AllWords = %AllWords%☆
Return

GetNumOfWord:
If WordToFind contains ☠
{
Thoughts = %MainThoughts%(GetNumOfWord) "%WordToFind%" is not a word, it is a complex connection. I will set WordNum to INVALID. Ending subroutine.
Gosub, HedoneThink
Wordnum = INVALID
Return
}
If WordToFind contains ☰
{
Thoughts = %MainThoughts%(GetNumOfWord) "%WordToFind%" is not a word, it is a number, and I already knew that. Wordnum is now %WordToFind%".
Gosub, HedoneThink
Wordnum = %WordToFind%
Return
}
IsANumber = 0
RealWordToFind = %WordToFind%
WordToFind = ☻%WordToFind%☆
PosOfWord := InStr(ConceptsFile, WordToFind)
If PosOfWord = 0
  ;if the concept is not in the concepts file
{
If WordToFind not contains 0,1,2,3,4,5,6,7,8,9,"
{
  ;if it has no numbers
UseConceptsFile = 1
StringToAdd = %WordToFind%
Gosub, AddToFile
}
Else
{
If WordToFind not contains a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z
{
  ;if it has numbers but no letters and is not in the file
Thoughts = %MainThoughts%(GetNumOfWord) The concept "%WordToFind%" has no letters, but has numbers, so it is a number. I will put an ☰ before the number, and say the wordnum is that. Also, I will add "number" to the constring.
Gosub, HedoneThink
WordForFWN = %RealWordToFind%
Gosub, FindWordNumber
ConsToAdd = % ConsForWord%FoundWordNumber%
ConsForWord%FoundWordNumber% = %ConsToAdd%16☆
WordNum = ☰%RealWordtoFind%
IsANumber = 1
}
Else
{
  ;if it has numbers and letters
UseConceptsFile = 1
StringToAdd = %WordToFind%
Gosub, AddToFile
}
}
}
  ;end of "if the concept is not in the file"
If IsANumber = 0
{
OriginToWord := SubStr(ConceptsFile, 1, PosOfWord)
WorthlessString := StrReplace(OriginToWord, "☻",, WordNum)
}
Return
  ;Gets the number of commas for the word %WordToFind%, saved as %WordNum%, creating it if needed. If it's a number, %wordnum% is saved as %☰"number"% and sets %IsANumber% to 1.

FindWordNumber:
LoopnumFWN := 0
Loop, %WordCount%
{
LoopnumFWN++
CurrentWordFWN = % Word%LoopNumFWN%
If CurrentWordFWN = %WordForFWN%
{
FoundWordNumber = %LoopnumFWN%
Thoughts = %MainThoughts%(FindWordNumber) "%WordForFWN%" is number "%FoundWordNumber%"
Gosub, HedoneThink
Return
}
}
FoundWordNumber = 0
Return
  ;finds the number (Example: "i love pie" has "pie" as the third word) of word %WordForFWN%, saved as %FoundWordNumber%

ThinkSubjectsEtc:
Loopnum := 0
Thoughts = The subjects/etc are:
Loop, %SubjectCount%
{
Loopnum++
CurrentSub = % Subject%Loopnum%
If Adj1OfSubject%Loopnum% !=
{
Thoughts = %Thoughts% (Adj-Sub)
CurrentAdjCount = % AdjCountForSub%Loopnum%
LoopnumAdj := 0
Loop, %CurrentAdjCount%
{
LoopnumAdj++
CurrentAdj = % Adj%LoopnumAdj%OfSubject%Loopnum%
Thoughts = %Thoughts%%CurrentAdj%-
}
Thoughts = %Thoughts%%CurrentSub%
}
Else
{
Thoughts = %Thoughts% (Sub)%CurrentSub%
}
}
Loopnum := 0
Loop, %ActionCount%
{
LoopNum++
CurrentAct = % Action%Loopnum%
Thoughts = %Thoughts% (Act)%CurrentAct%
}
Loopnum := 0
Loop, %ObjectCount%
{
Loopnum++
CurrentObj = % Object%Loopnum%
If Adj1OfObject%Loopnum% !=
{
Thoughts = %Thoughts% (Adj-Obj)
CurrentAdjCount = % AdjCountForObj%Loopnum%
LoopnumAdj := 0
Loop, %CurrentAdjCount%
{
LoopnumAdj++
CurrentAdj = % Adj%LoopnumAdj%OfObject%Loopnum%
Thoughts = %Thoughts%%CurrentAdj%-
}
Thoughts = %Thoughts%%CurrentObj%
}
Else
{
Thoughts = %Thoughts% (Obj)%CurrentObj%
}
}
Gosub, HedoneThink
Return
  ;tells the user what the subjects, actions, adjectives and objects are.

AddCons:
ActNum =
Num5 := 0
 Thoughts = %MainThoughts%(AddCons) There are %SubjectCount% subjects.
 Gosub, HedoneThink ;AddCons
LoopNumAC := 0
Answer = Noted.
ObjectIsComplex = 0
Loop, %SubjectCount%
{
LoopNumAC++
CurrentSubject = % Subject%LoopNumAC%
Answer = %Answer% %CurrentSubject%
SubjectWord = %CurrentSubject%
CurrentSubject = ☻%CurrentSubject%☆
  ;looks for subjects
If Adj1OfSubject1 =
{
 Thoughts = %MainThoughts%(AddCons) Subject has no adjective.
AdjNum =
 Gosub, HedoneThink ;AddCons
}
Else
{
CurrentAdjCount = %AdjCountForSub1%
 Thoughts = %MainThoughts%(AddCons) Subject1 has %CurrentAdjCount% adjectives.
 Gosub, HedoneThink ;AddCons
AdjNum = ☠
LoopnumAdj := 0
Loop, %CurrentAdjCount%
{
LoopnumAdj++
CurrentAdj = % Adj%LoopnumAdj%OfSubject1
 Thoughts = %MainThoughts%(AddCons) Adjective "%LoopNumAdj%" of Subject1 is "%CurrentAdj%".
 Gosub, HedoneThink ;AddCons
WordToFind = %CurrentAdj%
GoSub, GetNumOfWord
SubjAdjNum = %SubjAdjNum%%AdjNum%⚙%WordNum%☠
}
ObjectIsComplex = 1
}
  ;looks for subject-adjectives
ActLoopNum := 0
 Thoughts = %MainThoughts%(AddCons) Now looking for actions
 Gosub, HedoneThink ;AddCons
Loop, %ActionCount%
{
ActLoopNum++
CurrentAction = % Action%ActLoopNum%
 Thoughts = %MainThoughts%(AddCons) Current action is "%CurrentAction%"
 Gosub, HedoneThink ;AddCons
Answer = %Answer% %CurrentAction%
WordToFind = %CurrentAction%
GoSub, GetNumOfWord
If CurrentAction != be
{
ObjectIsComplex = 1
ActNum = %ActNum%☠%WordNum%
}
Else
{
}
}
ActNum = %ActNum%☠
 Thoughts = %MainThoughts%(AddCons) ActNum is %ActNum%
 Gosub, HedoneThink ;AddCons
  ;gets the number of the actions
Num5 := 0
Loop, %ObjectCount%
{
Num5++
CurrentObject = % Object%Num5%
  ;makes "CurrentObject" the next value in the %object% array.
If CurrentObject =
{
 Thoughts = %MainThoughts%(AddCons) There is no object"%Num5%". Skipping concept.
 Gosub, HedoneThink ;AddCons
Continue
}
 Thoughts = %MainThoughts%(AddCons) Object is "%CurrentObject%", it is object number "%Num5%"
 Gosub, HedoneThink ;AddCons
If Adj1OfObject%Num5% =
{
 Thoughts = %MainThoughts%(AddCons) Object has no adjective.
AdjNum =
 Gosub, HedoneThink ;AddCons
}
Else
{
CurrentAdjCount = % AdjCountForObj%Num5%
AdjNum = ☠
LoopnumAdj := 0
Loop, %CurrentAdjCount%
{
LoopnumAdj++
CurrentAdj = % Adj%LoopnumAdj%OfObject%Num5%
WordToFind = %CurrentAdj%
GoSub, GetNumOfWord
AdjNum = %AdjNum%%WordNum%☠
}
ObjectIsComplex = 1
}
  ;gets the number of the adjective, if there is one
Answer = %Answer% %CurrentObject%
WordToFind = %CurrentObject%
GoSub, GetNumOfWord
;If ConIsHypothetical = 1
;{
;Thoughts = %MainThoughts%(AddCons) This connection is a hypothetical, so I will add an H' before the connection.
;GoSub, HedoneThink ;AddCons
;Con = H'%ActNum%%AdjNum%%WordNum%☆
;}
;Else
;{
If ObjectIsComplex = 1
{
Con = %SubjAdjNum%%ActNum%%AdjNum%☠%WordNum%☠☆
RealConstring = %ConString%
Constring = %Con%
Gosub, GetWordsFromConstring
Constring = %RealConstring%
Thoughts = (AddCons) Con being added is "%Con%", aka "%AllWords%"
Gosub, HedoneThink
Con := StrReplace(Con, "☠☠", "☠")
Con := StrReplace(Con, "☠☠", "☠")
}
Else
{
Con = %WordNum%☆
}
;}
  ;gets the number of the object and attaches the action to it
Con := StrReplace(Con, CurrentSubject, NewSubject)
StarsCon = ☆%Con%
WordNeedingCons = %SubjectWord%
Gosub, ConsOfWord
Thoughts = %MainThoughts%(AddCons) the connection being added is %StarsCon%, its constring prior is %ConString%
GoSub, HedoneThink ;AddCons
StarsConstring = ☆%ConString%
PosOfWord := InStr(StarsConString, StarsCon)
If PosOfWord != 0
  ;if the con is in the subject's constring
{
Answer = I already knew that.
}
Else
{
SubjectPos := InStr(FileVarContents, CurrentSubject)
If SubjectPos = 0
{
Thoughts = %MainThoughts%(AddCons) Subject "%CurrentSubject%" not found in the "%FileVarName%" variable. Adding to file.
GoSub, HedoneThink ;AddCons
StringToAdd = %CurrentSubject%
Gosub, AddToFile
}
NewSubject = %CurrentSubject%%Con%
FileVarContents := StrReplace(FileVarContents, CurrentSubject, NewSubject)
  ;replaces the old subject (excluding the constring) with the same subject, adding the connection
%FileVarName% = %FileVarContents%
%FileVarName%2 = %FileVarContents%☻
FileDelete, %FileNameForSemParse%.txt
FileAppend, %FileVarContents%, %FileNameForSemParse%.txt, UTF-8
  ;updates the file
Gosub, CreateAllFilesVar
Thoughts = %MainThoughts%(AddCons) File "%FileNameForSemParse%" has been updated. New subject is "%NewSubject%", old subject is "%CurrentSubject%"
GoSub, HedoneThink ;AddCons
}
}
}
Return

AddToFile:
If UseConceptsFile = 1
{
thoughts = %MainThoughts% (AddToFile) Now adding "%StringToAdd%" to concepts file
Gosub, HedoneThink
StoredFileVarContents = %FileVarContents%
StoredFileVarName = %FileVarName%
StoredFileNameForSemParse = %FileNameForSemParse%
FileVarContents = %ConceptsFile%
FileVarName = Conceptsfile
FileNameForSemParse = Concepts
}
FileVarContents = %FileVarContents%%StringToAdd%
%FileVarName% = %FileVarContents%
%FileVarName%2 = %FileVarContents%☻
FileDelete, %FileNameForSemParse%.txt
FileAppend, %FileVarContents%, %FileNameForSemParse%.txt, UTF-8
If UseConceptsFile = 1
{
FileVarContents = %StoredFileVarContents%
FileVarName = %StoredFileVarName%
FileNameForSemParse = %StoredFileNameForSemParse%
}
Gosub, CreateAllFilesVar
UseConceptsFile = 0
Return


FindMultiWordConcepts:
FMWFoundMultiWord = 0
CurrNum := 0
NothingCount := 0
Loop, %WordCount%
{
CurrNum++
CurrentWord = % Word%CurrNum%
MultiWord = %CurrentWord%
PrevNum = %CurrNum%
Loop, %CurrNum%
{
PrevNum--
If PrevNum = 0
{
Break
}
PrevWord = % Word%PrevNum%
MultiWord = %PrevWord% %MultiWord%
RealMultiWord = %MultiWord%
if FindPlurals = 1
{
CurrentWord = %MultiWord%
EndLetters = s
Gosub, CheckEndLetters
EndLetters = es
Gosub, CheckEndLetters
MultiWord = %CurrentWord%
}
AltMultiWord = ☻%MultiWord%☆
FoundPos := InStr(AllFiles2, AltMultiWord)
If FoundPos != 0
  ;if the multiword is in Hedone's Concepts file
{
FMWFoundMultiWord = 1
Word%PrevNum% = %RealMultiWord%
NumOfWords := CurrNum - PrevNum
PriorWordCount = %WordCount%
WordCount := WordCount - NumOfWords
Thoughts = %MainThoughts%(FindMultiWordConcepts) Word"%PrevNum%" is now "%RealMultiWord%". The new WordCount is "%WordCount%".
Gosub, HedoneThink ;FindMultiWordConcepts
Wrongnum = %CurrNum%
CorrectNum = %CurrNum%
CorrectNum := CorrectNum - NumOfWords
Loop,
{
WrongNum++
CorrectNum++
If Word%WrongNum% =
{
Break
  ;if the word doesn't exist, Hedone breaks the loop
}
CurrentWords = % WordsOfWord%WrongNum%
CurrentCons = % ConsOfWord%WrongNum%
ConsOfWord%CorrectNum% = %CurrentCons%
WordsOfWord%CorrectNum% = %CurrentWords%
Word%CorrectNum% = % Word%WrongNum%
ConsForWord%CorrectNum% = % ConsForWord%WrongNum%
ConsForWord%WrongNum% =
Thoughts = %MainThoughts%(FindMultiWordConcepts) Word"%WrongNum%" is now Word"%CorrectNum%".
Gosub, HedoneThink ;FindMultiWordConcepts
}
  ;goes through all the words that come after the changed word, and decreases their word-number by the number of words removed from wordcount.
}
}
}
FindPlurals = 0
Return

GetNumsFromComplexConstring:
FirstLetter := SubStr(Constring, 1, 1)
If FirstLetter != ☆
{
Constring = ☆%Constring%
}
ConVar := 0
ConVar2 := 1
LoopNumGNFCC := 0
WorthlessString := StrReplace(ConString, "☠",, cConCount)
  ;gets the concount
cConCount--
 Thoughts = %MainThoughts%(GetNumsFromComplexConstring) There are %cConCount% connections to find.
 Gosub, HedoneThink ;GetNums
Loop, %cConCount%
{
LoopNumGNFCC++
ConVar++
ConVar2++
ConBegin := InStr(ConString, "☠",,, ConVar)
ConBegin++
ConEnd := InStr(ConString, "☠",,, ConVar2)
ConLength := ConEnd - ConBegin
cConNum%LoopNumGNFCC% := SubStr(ConString, ConBegin, ConLength)
ThisCCon = % cConNum%LoopNumGNFCC%
 Thoughts = %MainThoughts%(GetNumsFromComplexConstring) Found connection %ThisCCon%
 Gosub, HedoneThink ;GetNums
}
Return
  ;gets %cConCount%, cConNum%1%, cConNum%2% etc from %ConString%

FindConnections:
MainThoughts = (FindConnections)
LoopFC := 0
Loop, %ComplexConCount%
{
LoopFC++
ComplexConFC%ComplexConCount% =
}
LoopFC := 0
ComplexConCount = 0
Loop, %WordCount%
{
  ;one loop for every word in the clause
LoopFC++
LoopCCCFC := 0
Loop,
{
LoopCCCFC++
If ComplexConFC%LoopFC% =
{
Break
}
ComplexConFC%LoopCCCFC% =
}
LoopCCCFC := 0
CurrentWordFC = % Word%LoopFC%
WordToFind = %CurrentWordFC%
Gosub, GetNumOfWord
ConsOfWord%LoopFC% = 
ConsOfCurrentWord = 
ConsOfCurrentWordStars = 
ComplexConsToFind =
 Thoughts = (FindConnections) GETTING CONS FOR NEW CONCEPT: "%CurrentWordFC%"
 Gosub, HedoneThink
ConsToAdd = % ConsForWord%LoopFC%
ConsForWord%LoopFC% =
If CurrentWordFC contains a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z
{
}
Else
{
If CurrentWordFC contains 1,2,3,4,5,6,7,8,9,0
{
Thoughts = %MainThoughts%(GetNumOfWord) The word is a number. I will put an ☰ before the number, and say the wordnum is that. Also, I will add "number" to the constring.
Gosub, HedoneThink
ConsToAdd = ☰%CurrentWordFC%☆16☆%ConsToAdd%
}
}
WordNeedingCons = %CurrentWordFC%
Gosub, ConsOfWord
If Constring !=
{
ConsToFind = %Constring%☆%ConsToAdd%
}
Else
{
If ConsToAdd !=
{
ConsToFind = %ConsToAdd%
}
}
  ;ensures ConsToFind doesn't start with a star
WordToFind = %CurrentWordFC%
Gosub, GetNumOfWord
ConsOfWord%LoopFC% = %Wordnum%☆
ConsOfCurrentWord = % ConsOfWord%LoopFC%
ConsOfCurrentWordStars = ☆%ConsOfCurrentWord%
  ;adds the word to its constring
ConsToFind = ☥First☆%ConsToFind%%ConsToAdd%
ComplexConsSplit = 0
ComplexConCount := 0
IsForComplex = 0
Loop,
{
  ;one loop for the first "ConsToFind", then more, if the cons have cons, and if those cons have cons, etc etc
Constring = %ConsToFind%
Gosub, GetWordsFromConstring
 Thoughts = (FindConnections) ConsToFind is %ConsToFind% (%AllWords%)
 Gosub, HedoneThink
If ConsToFind contains ☥First
{
IsTheFirstConsToFind = 1
}
Else
{
IsTheFirstConsToFind = 0
}
  ;
  ;below is code for "If ConsToFind is empty"
  ;
If ConsToFind =
{
 Thoughts = (FindConnections) ConsToFind does not exist.
 Gosub, HedoneThink
If ComplexConsSplit = 0
{
If ComplexConsToFind =
{
 Thoughts = (FindConnections) All cons have been found, and there are no complex cons to find.
 Gosub, HedoneThink
Break
}
 Thoughts = (FindConnections) All normal cons have been found, now doing complex cons "%ComplexConsToFind%"
 Gosub, HedoneThink
Constring = %ComplexConsToFind%
Gosub, GetNumsFromConstring
LoopFC5 := 0
Loop, %ConCount%
{
LoopFC5++
ComplexConFC%LoopFC5% = % ConNum%LoopFC5%
}
TotalComplexCons = %LoopFC5%
IsNewComplexCon = 1
ComplexConCount = 1
ComplexConsSplit = 1
CurrentComplexCon = % ComplexConFC%ComplexConCount%
 Thoughts = (FindConnections) Now doing complex con "%CurrentComplexCon%"
 Gosub, HedoneThink
}
Else
{
  ;if the first complex connection was already done
ConsOfWord%LoopFC% = %CurrentComplexCon%☆%ConsOfCurrentWord%
ConsOfCurrentWord = % ConsOfWord%LoopFC%
ConsOfCurrentWordStars = ☆%ConsOfCurrentWord%
 Thoughts = (FindConnections) Added the current ComplexCon to ConsOfCurrentWord, ConsOfCurrentWord is now "%ConsOfCurrentWord%"
 Gosub, HedoneThink
If ComplexConCount = %TotalComplexCons%
{
 Thoughts = (FindConnections) This was ComplexCon "%ComplexConCount%", and there are "%TotalComplexCons%" total, so all cons have been found, complex and simple.
 Gosub, HedoneThink
Break
}
ComplexConCount++
CurrentComplexCon = % ComplexConFC%ComplexConCount%
If CurrentComplexCon =
{
 Thoughts = (FindConnections) This ComplexCon doesn't exist, so all cons have been found, complex and simple.
 Gosub, HedoneThink
Break
}
 Thoughts = (FindConnections) Now doing complex con "%CurrentComplexCon%"
 Gosub, HedoneThink
}
  ;code above gets the CurrentComplexCon, code below splits it into its cons and adds them to ConsToFind
Constring = %CurrentComplexCon%
Gosub, GetNumsFromComplexConstring
LoopFC6 := 0
Loop, %cConCount%
{
LoopFC6++
CurrentWordnum1 = % cConNum%LoopFC6%
ConsToFind = %CurrentWordnum1%☆%ConsToFind%
}
 Thoughts = (FindConnections) I added all cons from the complex con to ConsToFind, it is now "%ConsToFind%"
 Gosub, HedoneThink
IsForComplex = 1
}
  ;
  ;above is code for "If ConsToFind is empty"
  ;
Constring = %ConsToFind%
Gosub, GetNumsFromConstring
ConsToFind =
  ;turns ConsToFind into variables, for the ConCount loop, then deletes the ConsToFind variable.
LoopFC2 := 0
 Thoughts = (FindConnections) ConCount is %ConCount%
 Gosub, HedoneThink
Loop, %ConCount%
{
  ;One loop for every con in ConsToFind. In this loop, Hedone decides if each con should be added to the constring, and gets the cons of each con, to add to ConsToFind.
LoopFC2++
CurrentCon = % ConNum%LoopFC2%
NumToFind = %CurrentCon%
Gosub, GetWordOfNum
CurrentConStars = ☆%CurrentCon%☆
CurrentConWord = %WordOFNum%
CurrentConWordStars = ☆%WordOFNum%☆
 Thoughts = (FindConnections) Now looking for connections of the connection "%CurrentCon%" ("%WordOfNum%") and deciding if it should be added to the word's constring
 Gosub, HedoneThink
If IsForComplex = 1
{
If CurrentConWordStars contains ☆noun☆,☆verb☆,☆adjective☆,☆conjunction☆,☆adverb☆
{
 Thoughts = (FindConnections) Skip. This connection is a word class, those shouldn't be in complex connections.
 Gosub, HedoneThink
Continue
}
If CurrentComplexCon contains ☠%CurrentCon%☠
{
 Thoughts = (FindConnections) Skip. This connection is already in CurrentComplexCon ("%CurrentComplexCon%")
 Gosub, HedoneThink
Continue
}
}
If CurrentCon contains ☠
{
ComplexConsToFind = %CurrentCon%☆%ComplexConsToFind%
 Thoughts = (FindConnections) This connection is complex, "ComplexConsToFind" is now "%ComplexConsToFind%".
 Gosub, HedoneThink
Continue
}
If CurrentCon =
{
 Thoughts = (FindConnections) Skip. This con does not exist.
Continue
}
If CurrentCon contains ☥,☻
{
 Thoughts = (FindConnections) Skip. The ankh or smiley means it isn't a real connection.
 Gosub, HedoneThink
Continue
}
If ConsOfCurrentWordStars contains %CurrentConStars%
{
 Thoughts = (FindConnections) Skip. This connection is already in ConsOfCurrentWord.
 Gosub, HedoneThink
Continue
}
If CurrentConWordStars contains ☆Word Class☆
{
If IsTheFirstConsToFind = 0
{
 Thoughts = (FindConnections) Skip. This connection is "word class", and is not a direct connection.
 Gosub, HedoneThink
Continue
}
}
  ;all "if"s have been passed without problem, meaning the con should be added to the constring
If IsForComplex = 1
{
OldComplexCon = %CurrentComplexCon%
CurrentComplexCon = %CurrentCon%☠%CurrentComplexCon%
CurrentComplexConSkull = ☠%CurrentComplexCon%
ConsOfCurrentWord = % ConsOfWord%LoopFC%
ConsOfWord%LoopFC% := StrReplace(ConsOfCurrentWord, OldComplexCon, CurrentComplexCon, , 1)
ConsOfCurrentWord = % ConsOfWord%LoopFC%
ConsOfCurrentWordStars = ☆%ConsOfCurrentWord%
 Thoughts = (FindConnections) This con is for a complex con. ConsOFWord is now "%ConsOfCurrentWord%"
 Gosub, HedoneThink
}
Else
{
  ;if currentcon is not for a complex con
ConsOfWord%LoopFC% = %CurrentCon%☆%ConsOfCurrentWord%
ConsOfCurrentWord = % ConsOfWord%LoopFC%
ConsOfCurrentWordStars = ☆%ConsOfCurrentWord%
 Thoughts = (FindConnections) Con "%CurrentConWord%" has been added, ConsOfWord is now "%ConsOfCurrentWord%"
 Gosub, HedoneThink
  ;if a con gets past those IF statements, it is added to the word's final constring.
}
WordNum = %CurrentCon%
Gosub, GetConnections
If WordCons !=
{
ConsToFind = %WordCons%%ConsToFind%
 Thoughts = (FindConnections) Currentcon's cons added to ConsToFind, ConsToFind is now "%ConsToFind%"
 Gosub, HedoneThink
}
}
}
}
Return
  ;FindConnections gets the cons of a word and all the cons of the cons it has, plus the cons of those cons, Each child has 2 skittles and 16 pencils. If there are 53 children,tc

GetReferencesToCon:
NumToFind = %ConNeedingRefs%
StarNumGRTC = ☆%ConNeedingRefs%☆
Gosub, GetWordOfNum
ConNeedingRefsStars = ☆%ConNeedingRefs%☆
ConNeedingRefsSkulls = ☠%ConNeedingRefs%☠
StarWordOfNum = ☆%WordOfNum%☆
If StarWordOfNum contains ☆noun☆,☆verb☆,☆determiner☆,☆adjective☆,☆preposition☆,☆adverb☆,☰
{
Thoughts = %MainThoughts%(GetReferencesToCon) This concept (%WordOfNum%) is a word class, or number, so I will end this subroutine now.
Gosub, HedoneThink
Return
}
  ;checks to see if it's a word class, if it is, it ends here.
WorthlessString := StrReplace(AllFiles2, ConNeedingRefsStars,, SimpleReferenceCount)
WorthlessString := StrReplace(AllFiles2, ConNeedingRefsSkulls,, ComplexReferenceCount)
TotalReferenceCount := SimpleReferenceCount + ComplexReferenceCount
Thoughts = %MainThoughts%(GetReferencesToCon) Now finding the "%SimpleReferenceCount%" simple and "%ComplexReferenceCount%" complex refs to "%WordOfNum%" (num "%ConNeedingRefs%" ), and their parents. TotalReferenceCount is "%TotalReferenceCount%"
Gosub, HedoneThink
LoopGRTC:= 0
Loop, %SimpleReferenceCount%
{
LoopGRTC++
CurrentConPos := InStr(AllFiles2, ConNeedingRefsStars, , , LoopGRTC)
NextSmileposGRTC := InStr(AllFiles2, "☻", , CurrentConPos)
StarAfterSmilePosGRTC := InStr(AllFiles2, "☆", , NextSmileposGRTC)
NextSmilePosGRTC++
Length := StarAfterSmilePosGRTC - NextSmileposGRTC
WordToFind := SubStr(AllFiles2, NextSmilePosGRTC, Length)
Gosub, GetNumOfWord
Wordnum--
NumToFind = %Wordnum%
Gosub, GetWordOfNum
CurrentReferenceWord = %WordOFNum%
  ;gets the wordnum of the parent and sets it as the next reference
ParentOfRef%LoopGRTC%Num = %NumToFind%
ParentOfRef%LoopGRTC%Word = %WordOFNum%
Ref%LoopGRTC%IsComplex = 0
Thoughts = %MainThoughts%(GetReferencesToCon) Parent of reference %LoopGRTC% is "%CurrentReferenceWord%".
;Gosub, HedoneThink
}
Loop, %ComplexReferenceCount%
{
LoopGRTC++
CurrentConPos := InStr(AllFiles2, ConNeedingRefsSkulls, , , LoopGRTC)
NextSmileposGRTC := InStr(AllFiles2, "☻", , CurrentConPos)
StarAfterSmilePosGRTC := InStr(AllFiles2, "☆", , NextSmileposGRTC)
NextSmilePosGRTC++
Length := StarAfterSmilePosGRTC - NextSmileposGRTC
WordToFind := SubStr(AllFiles2, NextSmilePosGRTC, Length)
Gosub, GetNumOfWord
Wordnum--
NumToFind = %Wordnum%
Gosub, GetWordOfNum
CurrentReferenceWord = %WordOFNum%
CurrentReferenceWordSmile = ☻%WordOFNum%☆
ParentOfRef%LoopGRTC%Num = %NumToFind%
ParentOfRef%LoopGRTC%Word = %WordOFNum%
  ;gets the wordnum of the parent and sets it as the next reference
NextStarposGRTC := InStr(AllFiles2, "☆", , CurrentConPos)
NegativeConPosGRTC := CurrentConPos - StrLen(AllFiles2)
PreviousStarposGRTC := InStr(AllFiles2, "☆", , NegativeConPosGRTC)
PreviousStarPosGRTC++
Length := NextStarPosGRTC - PreviousStarPosGRTC
FullRef := SubStr(AllFiles2, PreviousStarPosGRTC, Length)
Ref%LoopGRTC% := SubStr(AllFiles2, PreviousStarPosGRTC, Length)
  ;gets the full reference
Ref%LoopGRTC%IsComplex = 1
Thoughts = %MainThoughts%(GetReferencesToCon) Parent of complex reference %LoopGRTC% is "%CurrentReferenceWord%", the full reference is "%FullRef%"
;Gosub, HedoneThink
}
If BlacklistGRC contains %StarNumGRTC%
{
Thoughts = %MainThoughts%(GetReferencesToCon) This concept is blacklisted, so I will say it has no references.
SimpleReferenceCount = 0
ComplexReferenceCount = 0
TotalReferenceCount = 0
Gosub, HedoneThink
}
Return
  ;gets the references to a single concept
Return

GetWordOfNum:
FirstSymbol =
If NumToFind contains ☰
{
WordOfNum = %NumToFind%
Return
}
if NumToFind contains ⚙
{
NumToFind := StrReplace(NumToFind, "⚙")
FirstSymbol = ⚙
}
CommaPos := InStr(AllFiles2, "☻",,, NumToFind)
CommaPos++
PeriodPos := InStr(AllFiles2, "☆",, CommaPos)
Length := PeriodPos - CommaPos
WordOfNum := SubStr(AllFiles2, CommaPos, Length)
WordOfNum = %FirstSymbol%%WordOfNum%
Return
  ;gets the word of word-number %NumToFind%

GetFullConnection:
StartPos := InStr(TheCons, ConStart)
StartPos++
EndPos := InStr(TheCons, "☆",, StartPos)
StartPos--
Length := EndPos - StartPos
FullCon := SubStr(TheCons, StartPos, Length)
  ;%TheCons% must contain the constring the desired connection is in. %ConStart% must contain the beginning of the con (ex: ☆23☠). Constring must begin with a period. Returns %FullCon%, with the full connection

ConsOfWordInFileForSemParse:
FileVarContents2 = %FileVarContents%☻
AltWord = ☻%WordNeedingCons%☆
WordStartPos := InStr(FileVarContents2, AltWord)
  ;Gets the position of the word's comma
ConStartPos := InStr(FileVarContents2, "☆",, WordStartPos)
WordStartPos++
ConStartPos++
ConEndPos := InStr(FileVarContents2, "☻",, WordStartPos)
  ;Gets the starting and end positions of the word's connections
DirectConLength := ConEndPos - ConStartPos
ConString := SubStr(FileVarContents2, ConStartPos, DirectConLength)
Thoughts = %MainThoughts%(ConsOfWord) The ConString of word "%WordNeedingCons%" is "%ConString%".
Gosub, HedoneThink
Return
  ;ConsOfWord Gets the direct connections for the word %WordNeedingCons%, stored as %ConString%. No period, at the start.


ConsOfWord:
FileVarContents2 = %FileVarContents%
AltWord = ☻%WordNeedingCons%☆
WordStartPos := InStr(AllFiles2, AltWord)
  ;Gets the position of the word's comma
ConStartPos := InStr(AllFiles2, "☆",, WordStartPos)
WordStartPos++
ConStartPos++
ConEndPos := InStr(AllFiles2, "☻",, WordStartPos)
  ;Gets the starting and end positions of the word's connections
DirectConLength := ConEndPos - ConStartPos
ConString := SubStr(AllFiles2, ConStartPos, DirectConLength)
Thoughts = %MainThoughts%(ConsOfWord) The ConString of word "%WordNeedingCons%" is "%ConString%".
Gosub, HedoneThink
Return
  ;ConsOfWord Gets the direct connections for the word %WordNeedingCons%, stored as %ConString%. No period, at the start.


GetNumsFromConString:
FirstChar := SubStr(ConString, 1, 1)
If FirstChar = ☆
{
RealConstring = %ConString%
ConString := SubStr(ConString, 2)
}
  ;ensures the first letter is not a star
ConVar := 0
ConVar2 := 1
WorthlessString := StrReplace(ConString, "☆",, ConCount)
  ;gets the concount
ConEnd := InStr(ConString, "☆",,, ConVar2)
ConEnd--
ConNum1 := SubStr(ConString, 1, ConEnd)
Loop, %ConCount%
{
ConVar++
ConVar2++
ConBegin := InStr(ConString, "☆",,, ConVar)
ConBegin++
ConEnd := InStr(ConString, "☆",,, ConVar2)
ConLength := ConEnd - ConBegin
ConNum%ConVar2% := SubStr(ConString, ConBegin, ConLength)
CurrentCon = % ConNum%ConVar%
}
Constring = %RealConstring%
Return
  ;gets %ConCount%, ConNum%1%, ConNum%2% etc from %ConString%

GetConnections:
ConConsComma := InStr(AllFiles2, "☻",,, WordNum)
  ;gets the position of the comma of the connection
ConConsBegin := InStr(AllFiles2, "☆",, ConConsComma, 1)
ConConsBegin++
ConConsEnd := InStr(AllFiles2, "☻",, ConConsBegin, 1)
ConConsLength := ConConsEnd - ConConsBegin
WordCons := SubStr(AllFiles2, ConConsBegin, ConConsLength)
Return
  ;GetConnections retrieves the connections of word number %WordNum%, storing them as variable %WordCons%, starting with no period.

FindWords:
PrevWordCount = %WordCount%
Num6 := 0
FWNumLoop := 0
PreFWNumLoop := -1
SpaceNum0 := 1
LengthOfAllWords := 0
LastLetterReached = 0
WordCount := 0
Loop,
{
FWNumLoop++
If Word%FWNumLoop% =
{
Break
}
Else
{
Word%FWNumLoop% =
}
}
FWNumLoop := 0
  ;Erases all past words
Loop,
{
PreFWNumLoop++
FWNumLoop++
WordCount++
SpaceNum%FWNumLoop% := InStr(PTEXT, " ",, 1, FWNumLoop)
SpaceNum%FWNumLoop%--
if SpaceNum%FWNumLoop% = -1
{
SpaceNum%FWNumLoop% := StrLen(PTEXT)
LastLetterReached = 1
}
  ;Gets location of the last letter in the word
WordLength := SpaceNum%FWNumLoop% - LengthOfAllWords
  ;Gets the length of the word
Word%FWNumLoop% := SubStr(PTEXT, SpaceNum%PreFWNumLoop%, WordLength)
  ;Saves the word as Word(number)
WordVar = % Word%FWNumLoop%
 Thoughts = (FindWords) Word %FWNumLoop% is %WordVar%
 Gosub, HedoneThink ;FindWords
LengthOfAllWords := LengthOfAllWords + WordLength + 1
  ;Saves the length of all the words already saved
SpaceNum%FWNumLoop%++
SpaceNum%FWNumLoop%++
  ;get the first letter of the next word
If LastLetterReached = 1
{
Break
}
}
Return
  ;FindWords turns the words the user sends into variables. Word1, Word2, etc

HedoneSend:
dlg := dlg "♥Hedone♥" ": " Answer "`n"
GuiControl,,In,
GuiControl,,Out,%dlg%
SendMessage, 0x115, 7, 0,, ahk_id %outHWND%
  ;sends Hedone's text
LogAnswer = %Answer%(END)
logdlg := logdlg "(START)Hedone" ": " LogAnswer "`n"
FileDelete, ChatLog.txt
FileAppend, %logdlg%, ChatLog.txt, UTF-8
  ;saves it in the chatlog
Answer = INVALID.
return

HedoneThink:
If AreThoughtsDisabled = 1
{
Return
}
Gui, Submit, NoHide
Loopnum := 0
Loop, 6
{
Loopnum++
CurrentContVar = % ContVar%Loopnum%
CurrentShowVar = % ShowVar%Loopnum%
If Thoughts contains %CurrentContVar%
{
If CurrentShowVar = 1
  ;if the checkbox is checked
{
Break
}
Else
{
LogThoughts = %Thoughts%(END)
logdlg := logdlg "(START)  (Thinking)" ": " LogThoughts "`n"
GuiControl,,In,
FileDelete, ChatLog.txt
FileAppend, %logdlg%, ChatLog.txt, UTF-8
  ;if the checkbox is unchecked, change the logdlg but not the real dlg
Return
}
}
}
dlg := dlg "  (Thinking)" ": " Thoughts "`n"
GuiControl,,In,
GuiControl,,Out,%dlg%
SendMessage, 0x115, 7, 0,, ahk_id %outHWND%
  ;sends Hedone's thoughts
LogThoughts = %Thoughts%(END)
logdlg := logdlg "(START)  (Thinking)" ": " LogThoughts "`n"
GuiControl,,In,
FileDelete, ChatLog.txt
FileAppend, %logdlg%, ChatLog.txt, UTF-8

Return