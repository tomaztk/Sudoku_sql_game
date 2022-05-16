--Sudoku_PJR
--Purpose:	To solve 9x9 Sudoku puzzles within a reasonable time
--Approach:	Use logic first, and when that can go no further, make guesses
--Notes:	* Each cell in a 9x9 Sudoku is the intersection of three sets - Row Column and Block
--			* Guesses are made from the smallest set of possbilities first
--			* When a guess or series of guesses reaches an invalid conclusion, they need to be wound back in a structured manner

	Declare @siCounter As SmallInt = 0
			, @t datetime = getdate()
			, @tiGuess As TinyInt = 0
			, @tiMakeGuesses As TinyInt = 1
			, @tiMinGuessNo As TinyInt = 0
			, @tiMaxGuessNo As TinyInt = 0
			, @tiMaxLenPoss As TinyInt = 0
			, @tiGuessesSoFar As TinyInt = 0
			, @strPuzzle As Char(81)
--Harvested puzzles, simple
	Set @strPuzzle = '000400000004063200809000503090030005040658030600010070901000804005840100000007000'
	Set @strPuzzle = '007400803000206001000085700026000039004000100370000680908620000000108000630009200'
	Set @strPuzzle = '019600430000098000002005100098074001020000080700850620007500800000730000056001970'
	Set @strPuzzle = '023780460000620000060304080001000534280000097439000100010205040000036000056018370'
	Set @strPuzzle = '107608209840050036000000000300106004060000090200305007000000000430060052508209301'
	Set @strPuzzle = '280060079100007006070930080907000605008000700040000090090025060800600002650010047'
	Set @strPuzzle = '600050002010702040000346000084000590509000207032000480000165000020407060300090004'
	Set @strPuzzle = '700200008020405070004080300060508037009000800180607020001070600050903010600004003'
	Set @strPuzzle = '703200104054019380000500000070000805060000030308000090000001000035920460407008903'
	Set @strPuzzle = '800259004040010070000407000302080506580302091607040302000504000060090020700826009'

--Harvested Puzzles, various
	Set @strPuzzle = '000000004020340801310700200100007020000060005065000000900200000052090300070600000'
	Set @strPuzzle = '000043200501002300080000004302000605604100000090000000000700000000090560420860010'
	Set @strPuzzle = '000080007040000100000000090018030500000500302000047906200050049701069200095020001'
	Set @strPuzzle = '029000008030000010000520097070056100000000000006310070760041000050000020800000630' 
	Set @strPuzzle = '056300400010000000000006000000009102020000007481000000090604001100070000507000300'
	Set @strPuzzle = '600000040005002007729000003090040001000060000400080070300000165200400800050000004'

--Puzzle referenced in Aticle, plus the same but with a deliberate mistake
--	Set @strPuzzle = '020300000005040090040201370000000608560800010000000000003000127000070000910000050'
--	Set @strPuzzle = '024300000005040090040201370000000608560800010000000000003000127000070000910000050'

--Some puzzles you won't find in your newspaper
--	Set @strPuzzle = '123456789456789123789123456000000000000000000000000000000000000000000000000000000'
--	Set @strPuzzle = '123456789000000000000000000000000000000000000000000000000000000000000000000000000'
--	Set @strPuzzle = '123000000456000000789000000000123000000456000000789000000000123000000456000000789'
--	Set @strPuzzle = '100000000000000000000000000000000000000000000000000000000000000000000000000000000'
--	Set @strPuzzle = '900000000000000000000000000000000000000000000000000000000000000000000000000000000'

--	Set @strPuzzle = '809500000000804020400030000960700010004000500070003098000080006010302000000006105'

	Declare @tNumbers As Table (tiNumb TinyInt Primary Key)

	Declare @tPossibles As Table (tiBlock TinyInt
									, tiRow TinyInt
									, tiCol TinyInt
									, tiPoss TinyInt)

	Declare @tGuesses As Table (tiGuessNo TinyInt
									, tiRow TinyInt
									, tiCol TinyInt
									, tiVal TinyInt
									, Possibles nVarChar(9))

	Insert Into @tNumbers (tiNumb)
	Values (1), (2), (3), (4), (5), (6), (7), (8), (9)

	CREATE TABLE #ByCell(tiGuessNo		TinyInt
						, tiRow			TinyInt
						, tiCol			TinyInt
						, tiBlk			TinyInt
						, tiVal			TinyInt
						, RowSetString	nVarChar(9)
						, ColSetString	nVarChar(9)
						, BlkSetString	nVarChar(9)
						, Possibles		nVarChar(9)
						, Primary Key CLUSTERED (tiGuessNo, tiRow, tiCol))

	CREATE UNIQUE NONCLUSTERED INDEX IX0ByCell0Block ON #ByCell (tiGuessNo, tiBlk, tiRow, tiCol)

	Insert Into #ByCell(tiGuessNo
					, tiRow
					, tiCol
					, tiBlk
					, tiVal)
	Select @tiGuess
			, R.tiNumb As RtiNumb
			, C.tiNumb As CtiNumb
			, Floor((R.tiNumb - 1 ) / 3) * 3 + Floor((C.tiNumb - 1 ) / 3) + 1 As Block
			, Cast(SubString(@strPuzzle, C.tiNumb + (R.tiNumb - 1) * 9, 1) as TinyInt) As tiVal
	From @tNumbers As R
		, @tNumbers As C

UpdateSetStrings:
	Update #ByCell
	Set RowSetString = Cast(Val01 As nVarChar(1)) + Cast(Val02 As nVarChar(1)) + Cast(Val03 As nVarChar(1)) 
					+ Cast(Val04 As nVarChar(1)) + Cast(Val05 As nVarChar(1)) + Cast(Val06 As nVarChar(1))
					+ Cast(Val07 As nVarChar(1)) + Cast(Val08 As nVarChar(1)) + Cast(Val09 As nVarChar(1))
	From #ByCell As BC
	Inner Join ( Select tiRow
						, Max(Case When tiCol = 1 Then tiVal Else 0 End) As Val01
						, Max(Case When tiCol = 2 Then tiVal Else 0 End) As Val02
						, Max(Case When tiCol = 3 Then tiVal Else 0 End) As Val03
						, Max(Case When tiCol = 4 Then tiVal Else 0 End) As Val04
						, Max(Case When tiCol = 5 Then tiVal Else 0 End) As Val05
						, Max(Case When tiCol = 6 Then tiVal Else 0 End) As Val06
						, Max(Case When tiCol = 7 Then tiVal Else 0 End) As Val07
						, Max(Case When tiCol = 8 Then tiVal Else 0 End) As Val08
						, Max(Case When tiCol = 9 Then tiVal Else 0 End) As Val09
				From #ByCell
				Where tiGuessNo = @tiGuess
				Group By tiRow) As T On BC.tiRow = T.tiRow
	Where tiGuessNo = @tiGuess

	Update #ByCell
	Set ColSetString = Cast(Val01 As nVarChar(1)) + Cast(Val02 As nVarChar(1)) + Cast(Val03 As nVarChar(1)) 
					+ Cast(Val04 As nVarChar(1)) + Cast(Val05 As nVarChar(1)) + Cast(Val06 As nVarChar(1))
					+ Cast(Val07 As nVarChar(1)) + Cast(Val08 As nVarChar(1)) + Cast(Val09 As nVarChar(1))
	From #ByCell As BC
	Inner Join ( Select tiCol
						, Max(Case When tiRow = 1 Then tiVal Else 0 End) As Val01
						, Max(Case When tiRow = 2 Then tiVal Else 0 End) As Val02
						, Max(Case When tiRow = 3 Then tiVal Else 0 End) As Val03
						, Max(Case When tiRow = 4 Then tiVal Else 0 End) As Val04
						, Max(Case When tiRow = 5 Then tiVal Else 0 End) As Val05
						, Max(Case When tiRow = 6 Then tiVal Else 0 End) As Val06
						, Max(Case When tiRow = 7 Then tiVal Else 0 End) As Val07
						, Max(Case When tiRow = 8 Then tiVal Else 0 End) As Val08
						, Max(Case When tiRow = 9 Then tiVal Else 0 End) As Val09
				From #ByCell
				Where tiGuessNo = @tiGuess
				Group By tiCol) As T On BC.tiCol = T.tiCol
	Where tiGuessNo = @tiGuess

	Update #ByCell
	Set BlkSetString = Cast(Val01 As nVarChar(1)) + Cast(Val02 As nVarChar(1)) + Cast(Val03 As nVarChar(1)) 
					+ Cast(Val04 As nVarChar(1)) + Cast(Val05 As nVarChar(1)) + Cast(Val06 As nVarChar(1))
					+ Cast(Val07 As nVarChar(1)) + Cast(Val08 As nVarChar(1)) + Cast(Val09 As nVarChar(1))
	From #ByCell As BC
	Inner Join (
				Select T1.tiBlk
						, Max(Case When T1.tiRow = T2.tiRowA And T1.tiCol = T2.tiColA Then tiVal Else 0 End) As Val01
						, Max(Case When T1.tiRow = T2.tiRowA And T1.tiCol = T2.tiColB Then tiVal Else 0 End) As Val02
						, Max(Case When T1.tiRow = T2.tiRowA And T1.tiCol = T2.tiColC Then tiVal Else 0 End) As Val03
						, Max(Case When T1.tiRow = T2.tiRowB And T1.tiCol = T2.tiColA Then tiVal Else 0 End) As Val04
						, Max(Case When T1.tiRow = T2.tiRowB And T1.tiCol = T2.tiColB Then tiVal Else 0 End) As Val05
						, Max(Case When T1.tiRow = T2.tiRowB And T1.tiCol = T2.tiColC Then tiVal Else 0 End) As Val06
						, Max(Case When T1.tiRow = T2.tiRowC And T1.tiCol = T2.tiColA Then tiVal Else 0 End) As Val07
						, Max(Case When T1.tiRow = T2.tiRowC And T1.tiCol = T2.tiColB Then tiVal Else 0 End) As Val08
						, Max(Case When T1.tiRow = T2.tiRowC And T1.tiCol = T2.tiColC Then tiVal Else 0 End) As Val09
				From #ByCell As T1
				Inner Join (Select tiBlk
									, Min(tiRow) As tiRowA
									, Avg(tiRow) As tiRowB
									, Max(tiRow) As tiRowC
									, Min(tiCol) As tiColA
									, Avg(tiCol) As tiColB
									, Max(tiCol) As tiColC
							From #ByCell
							Where tiGuessNo = @tiGuess
							Group By tiBlk) As T2 On T1.tiBlk = T2.tiBlk
				Where tiGuessNo = @tiGuess
				Group By T1.tiBlk) As T On BC.tiBlk = T.tiBlk
	Where tiGuessNo = @tiGuess

--Check for Validity				
	If Not Exists (Select * From #ByCell 
					Where (dbo.sfnValidateSudokuSet(RowSetString) = 0
					Or	dbo.sfnValidateSudokuSet(ColSetString) = 0
					Or	dbo.sfnValidateSudokuSet(BlkSetString) = 0)
					And  tiGuessNo = @tiGuess)
	Begin
--So now we have a table variable with Numbers 1 - 9, and a temp table with the puzzle Numbers in.  
--All is ready for some query magic
		Update #ByCell
		Set Possibles = (Case When tiVal = 0 Then dbo.sfnFindPossibles(RowSetString, ColSetString, BlkSetString)
							Else '' End)
		From #ByCell As B
		Where tiGuessNo = @tiGuess

--Counter keeps note of how many times this loops
--Not required to solve the puzzle, but it gives an indication of how much work has gone into solving it
		Set @siCounter = @siCounter + 1

StartPossibles:
--Possibles in #ByCell populated, now to get on with @tPossibles
		Delete From @tPossibles
		Insert Into @tPossibles(tiBlock, tiRow, tiCol, tiPoss)

		Select tiBlk, tiRow, tiCol, Cast(SubString(Possibles, 1, 1) As TinyInt) As Poss
		From #ByCell As C
		Where Len(IsNull(C.Possibles, '')) >= 1
		And tiGuessNo = @tiGuess
		Union All
		Select tiBlk, tiRow, tiCol, Cast(SubString(Possibles, 2, 1) As TinyInt) As Poss
		From #ByCell As C
		Where Len(IsNull(C.Possibles, '')) >= 2
		And tiGuessNo = @tiGuess
		Union All
		Select tiBlk, tiRow, tiCol, Cast(SubString(Possibles, 3, 1) As TinyInt) As Poss
		From #ByCell As C
		Where Len(IsNull(C.Possibles, '')) >= 3
		And tiGuessNo = @tiGuess
		Union All
		Select tiBlk, tiRow, tiCol, Cast(SubString(Possibles, 4, 1) As TinyInt) As Poss
		From #ByCell As C
		Where Len(IsNull(C.Possibles, '')) >= 4
		And tiGuessNo = @tiGuess
		Union All
		Select tiBlk, tiRow, tiCol, Cast(SubString(Possibles, 5, 1) As TinyInt) As Poss
		From #ByCell As C
		Where Len(IsNull(C.Possibles, '')) >= 5
		And tiGuessNo = @tiGuess
		Union All
		Select tiBlk, tiRow, tiCol, Cast(SubString(Possibles, 6, 1) As TinyInt) As Poss
		From #ByCell As C
		Where Len(IsNull(C.Possibles, '')) >= 6
		And tiGuessNo = @tiGuess
		Union All
		Select tiBlk, tiRow, tiCol, Cast(SubString(Possibles, 7, 1) As TinyInt) As Poss
		From #ByCell As C
		Where Len(IsNull(C.Possibles, '')) >= 7
		And tiGuessNo = @tiGuess
		Union All
		Select tiBlk, tiRow, tiCol, Cast(SubString(Possibles, 8, 1) As TinyInt) As Poss
		From #ByCell As C
		Where Len(IsNull(C.Possibles, '')) >= 8
		And tiGuessNo = @tiGuess
		Union All
		Select tiBlk, tiRow, tiCol, Cast(SubString(Possibles, 9, 1) As TinyInt) As Poss
		From #ByCell As C
		Where Len(IsNull(C.Possibles, '')) = 9
		And tiGuessNo = @tiGuess

--Clear out where there are matches in other parts of the three way relationship
		If Exists (Select T.*
					From #ByCell
					Inner Join (Select tiBlock, tiPoss, Max(tiRow) As MaxRow From @tPossibles Group By tiBlock, tiPoss Having Count(*) <=3 And Min(tiRow) = Max(tiRow)) As T On tiRow = MaxRow
					Where tiBlk <> tiBlock
					And tiGuessNo = @tiGuess
					And CharIndex(Cast(TiPoss As nVarChar(1)), Possibles, 1) > 0)
		Or Exists (Select T.*
					From #ByCell
					Inner Join (Select tiBlock, tiPoss, Max(tiCol) As MaxCol From @tPossibles Group By tiBlock, tiPoss Having Count(*) <=3 And Min(tiCol) = Max(tiCol)) As T On tiCol = MaxCol
					Where tiBlk <> tiBlock
					And tiGuessNo = @tiGuess
					And CharIndex(Cast(TiPoss As nVarChar(1)), Possibles, 1) > 0)
		Or Exists (Select T.*
					From #ByCell
					Inner Join (Select tiRow, tiPoss, Max(tiBlock) As MaxBlock From @tPossibles Group By tiRow, tiPoss Having Count(*) <= 3 And Min(tiBlock) = Max(tiBlock)) As T On #ByCell.tiBlk = MaxBlock
					Where #ByCell.tiRow <> T.tiRow
					And tiGuessNo = @tiGuess
					And CharIndex(Cast(TiPoss As nVarChar(1)), Possibles, 1) > 0)
		Or Exists (Select T.*
					From #ByCell
					Inner Join (Select tiCol, tiPoss, Max(tiBlock) As MaxBlock From @tPossibles Group By tiCol, tiPoss Having Count(*) <= 3 And Min(tiBlock) = Max(tiBlock)) As T On #ByCell.tiBlk = MaxBlock
					Where #ByCell.tiCol <> T.tiCol
					And tiGuessNo = @tiGuess
					And CharIndex(Cast(TiPoss As nVarChar(1)), Possibles, 1) > 0)
		Begin
			If Exists (Select T.*
						From #ByCell
						Inner Join (Select tiBlock, tiPoss, Max(tiRow) As MaxRow From @tPossibles Group By tiBlock, tiPoss Having Count(*) <=3 And Min(tiRow) = Max(tiRow)) As T On tiRow = MaxRow
						Where tiBlk <> tiBlock
						And tiGuessNo = @tiGuess
						And CharIndex(Cast(TiPoss As nVarChar(1)), Possibles, 1) > 0)
			Begin			
				Update #ByCell
				Set Possibles = dbo.sfnRemoveExtraneousChars(Possibles, tiPoss)
				From #ByCell
				Inner Join (Select tiBlock, tiPoss, Max(tiRow) As MaxRow From @tPossibles Group By tiBlock, tiPoss Having Count(*) <=3 And Min(tiRow) = Max(tiRow)) As T On tiRow = MaxRow
				Where tiBlk <> tiBlock
				And tiGuessNo = @tiGuess
				And CharIndex(Cast(TiPoss As nVarChar(1)), Possibles, 1) > 0
			End
			If Exists (Select T.*
						From #ByCell
						Inner Join (Select tiBlock, tiPoss, Max(tiCol) As MaxCol From @tPossibles Group By tiBlock, tiPoss Having Count(*) <=3 And Min(tiCol) = Max(tiCol)) As T On tiCol = MaxCol
						Where tiBlk <> tiBlock
						And tiGuessNo = @tiGuess
						And CharIndex(Cast(TiPoss As nVarChar(1)), Possibles, 1) > 0)
			Begin
				Update #ByCell
				Set Possibles = dbo.sfnRemoveExtraneousChars(Possibles, tiPoss)
				From #ByCell
				Inner Join (Select tiBlock, tiPoss, Max(tiCol) As MaxCol From @tPossibles Group By tiBlock, tiPoss Having Count(*) <=3 And Min(tiCol) = Max(tiCol)) As T On tiCol = MaxCol
				Where tiBlk <> tiBlock
				And tiGuessNo = @tiGuess
				And CharIndex(Cast(TiPoss As nVarChar(1)), Possibles, 1) > 0
			End
			If Exists (Select T.*
						From #ByCell
						Inner Join (Select tiRow, tiPoss, Max(tiBlock) As MaxBlock From @tPossibles Group By tiRow, tiPoss Having Count(*) <= 3 And Min(tiBlock) = Max(tiBlock)) As T On #ByCell.tiBlk = MaxBlock
						Where #ByCell.tiRow <> T.tiRow
						And tiGuessNo = @tiGuess
						And CharIndex(Cast(TiPoss As nVarChar(1)), Possibles, 1) > 0)
			Begin
				Update #ByCell
				Set Possibles = dbo.sfnRemoveExtraneousChars(Possibles, tiPoss)
				From #ByCell
				Inner Join (Select tiRow, tiPoss, Max(tiBlock) As MaxBlock From @tPossibles Group By tiRow, tiPoss Having Count(*) <= 3 And Min(tiBlock) = Max(tiBlock)) As T On #ByCell.tiBlk = MaxBlock
				Where #ByCell.tiRow <> T.tiRow
				And tiGuessNo = @tiGuess
				And CharIndex(Cast(TiPoss As nVarChar(1)), Possibles, 1) > 0
			End
			If Exists (Select T.*
						From #ByCell
						Inner Join (Select tiCol, tiPoss, Max(tiBlock) As MaxBlock From @tPossibles Group By tiCol, tiPoss Having Count(*) <= 3 And Min(tiBlock) = Max(tiBlock)) As T On #ByCell.tiBlk = MaxBlock
						Where #ByCell.tiCol <> T.tiCol
						And tiGuessNo = @tiGuess
						And CharIndex(Cast(TiPoss As nVarChar(1)), Possibles, 1) > 0)
			Begin
				Update #ByCell
				Set Possibles = dbo.sfnRemoveExtraneousChars(Possibles, tiPoss)
				From #ByCell
				Inner Join (Select tiCol, tiPoss, Max(tiBlock) As MaxBlock From @tPossibles Group By tiCol, tiPoss Having Count(*) <= 3 And Min(tiBlock) = Max(tiBlock)) As T On #ByCell.tiBlk = MaxBlock
				Where #ByCell.tiCol <> T.tiCol
				And tiGuessNo = @tiGuess
				And CharIndex(Cast(TiPoss As nVarChar(1)), Possibles, 1) > 0
			End

--Need to do that stuff recursively a few times, so back to the beginning of that bit
			Goto StartPossibles
		End
--That may have loosened stuff up a bit, so need to action any new possibilities
		If Exists (Select * from #ByCell Where tiGuessNo = @tiGuess And Len(IsNull(Possibles, '')) = 1)
		Or Exists(Select tiBlock, tiPoss From @tPossibles Group By tiBlock, tiPoss Having Count(*) = 1)
		Or Exists(Select tiRow, tiPoss From @tPossibles Group By tiRow, tiPoss Having Count(*) = 1)
		Or Exists(Select tiCol, tiPoss From @tPossibles Group By tiCol, tiPoss Having Count(*) = 1)
		Begin
--If that has cut any possibles down to single characters, we need to work on them
			If Exists (Select * from #ByCell Where tiGuessNo = @tiGuess And Len(IsNull(Possibles, '')) = 1)
			Begin
				Update #ByCell
				Set tiVal = Cast(Possibles As TinyInt)
					, Possibles = ''
				From #ByCell
				Where tiGuessNo = @tiGuess 
				And Len(IsNull(Possibles, '')) = 1
			End
--Now we search for single Possibilities within a block
			If Exists(Select tiBlock, tiPoss From @tPossibles Group By tiBlock, tiPoss Having Count(*) = 1)
			Begin
				Update #ByCell
				Set tiVal = T.tiPoss
					, Possibles = ''
				From #ByCell
				Inner Join (Select tiBlock, tiPoss From @tPossibles Group By tiBlock, tiPoss Having Count(*) = 1) As T On tiBlk = T.tiBlock
				Where tiGuessNo = @tiGuess 
				And CharIndex(Cast(T.tiPoss as nVarChar(1)), Possibles, 1) > 0
			End
--Now we search for single Possibilities within a Row
			If Exists(Select tiRow, tiPoss From @tPossibles Group By tiRow, tiPoss Having Count(*) = 1)
			Begin
				Update #ByCell
				Set tiVal = T.tiPoss
					, Possibles = ''
				From #ByCell
				Inner Join (Select tiRow, tiPoss From @tPossibles Group By tiRow, tiPoss Having Count(*) = 1) As T On #ByCell.tiRow = T.tiRow
				Where tiGuessNo = @tiGuess 
				And CharIndex(Cast(T.tiPoss as nVarChar(1)), Possibles, 1) > 0
			End
--and finally we do the same for columns
			If Exists(Select tiCol, tiPoss From @tPossibles Group By tiCol, tiPoss Having Count(*) = 1)
			Begin
				Update #ByCell
				Set tiVal = T.tiPoss
					, Possibles = ''
				From #ByCell
				Inner Join (Select tiCol, tiPoss From @tPossibles Group By tiCol, tiPoss Having Count(*) = 1) As T On #ByCell.tiCol = T.tiCol
				Where tiGuessNo = @tiGuess 
				And CharIndex(Cast(T.tiPoss as nVarChar(1)), Possibles, 1) > 0
			End
--Now gotta clear things up and start another iteration of thinking deep thoughts
			Goto UpdateSetStrings
		End
--Nothing else of a logical nature to do, so we check we are still OK
--Check for Validity				
		If Not Exists (Select * From #ByCell 
						Where tiGuessNo = @tiGuess 
						And (dbo.sfnValidateSudokuSet(RowSetString) = 0
						Or	dbo.sfnValidateSudokuSet(ColSetString) = 0
						Or	dbo.sfnValidateSudokuSet(BlkSetString) = 0))
		Begin
			If Not Exists (Select * from #ByCell Where tiGuessNo = @tiGuess And tiVal = 0)
			Begin
				Select 'Its a Winner, Dude.' As Status, Cast(@siCounter As nVarchar(3)) + ' iterations, ' + Cast(@tiGuess as nVarChar(2)) + ' guesses in ' + convert(varchar,datediff(ms,@t,getdate())) + ' ms' As PerfStats
--Select * from @tGuesses

			End
			Else
			Begin
				If @tiMakeGuesses = 1
				Begin
--All the easy Stuff done, now for some guessing
					Set @tiGuess = @tiGuess + 1

					Insert Into @tGuesses (tiGuessNo, tiRow, tiCol, tiVal, Possibles)
					Select Top 1 @tiGuess
						, B.tiRow
						, B.tiCol
						, Substring(B.Possibles, (Select Count(*) As SoFar From @tGuesses Where tiRow = B.tiRow and tiCol = B.tiCol) + 1, 1)
						, B.Possibles
					From #ByCell As B
					Left Join @tGuesses As G1 On --B.tiGuessNo = G1.tiGuessNo and 
												B.tiRow = G1.tiRow And B.tiCol = G1.tiCol
					Where B.tiGuessNo = @tiGuess - 1
					And Len(B.Possibles) > 0
					And Len(B.Possibles) > (Select Count(*) As SoFar From @tGuesses Where tiRow = B.tiRow and tiCol = B.tiCol)
					And G1.tiRow Is Null
					Order By Len(B.Possibles)
						, B.tiRow
						, B.tiCol

					Insert Into #ByCell(tiGuessNo
									, tiRow
									, tiCol
									, tiBlk
									, tiVal
									, RowSetString
									, ColSetString
									, BlkSetString
									, Possibles)
					Select @tiGuess
							, tiRow
							, tiCol
							, tiBlk
							, tiVal
							, RowSetString
							, ColSetString
							, BlkSetString
							, Possibles
					From #ByCell As B
					Where B.tiGuessNo = @tiGuess - 1

					Update #ByCell
					Set tiVal = G.tiVal
					From #ByCell
					Inner Join @tGuesses As G On #ByCell.tiGuessNo = G.tiGuessNo And #ByCell.tiRow = G.tiRow And #ByCell.tiCol = G.tiCol

--Just in case it gets stuck in a loop, we will curtail the number of guesses
					If @tiGuess <= 50
					Begin			
						Goto UpdateSetStrings
					End
				End
			End
		End
		Else
		Begin
			Select 'I dont know how to say this, but something has gone wrong.' As Status, Cast(@siCounter As nVarchar(3)) + ' iterations, ' + Cast(@tiGuess as nVarChar(2)) + ' guesses in ' + convert(varchar,datediff(ms,@t,getdate())) + ' ms' As PerfStats
		End
	End
	Else
	Begin
		If @tiGuess > 0
		Begin
			If @tiMakeGuesses = 1
			Begin
--Roll back prior guesses, and carry on
				If Exists (Select tiRow, tiCol, Min(tiGuessNo) As MinGuessNo, Max(tiGuessNo) As MaxGuessNo, Max(Len(Possibles)) As MaxLenPoss, Count(*) As SoFar From @tGuesses As G2 Group By tiRow, tiCol Having Max(Len(Possibles)) - Count(*) > 0)
				Begin
					Set @tiGuess = @tiGuess + 1

					Select Top 1 @tiMinGuessNo = MinGuessNo, @tiMaxGuessNo = MaxGuessNo, @tiMaxLenPoss = MaxLenPoss, @tiGuessesSoFar = SoFar From (Select tiRow, tiCol, Min(tiGuessNo) As MinGuessNo, Max(tiGuessNo) As MaxGuessNo, Max(Len(Possibles)) As MaxLenPoss, Count(*) As SoFar From @tGuesses As G2 Group By tiRow, tiCol Having Max(Len(Possibles)) - Count(*) > 0) As T Order By MaxGuessNo Desc
--Select * from @tGuesses
--Gotta remove any redundant guesses
					Delete From @tGuesses Where tiGuessNo > @tiMaxGuessNo

					Insert Into @tGuesses (tiGuessNo, tiRow, tiCol, tiVal, Possibles)
					Select Top 1 @tiGuess
						, tiRow
						, tiCol
						, SubString(Possibles, @tiGuessesSoFar + 1, 1)
						, Possibles
					From @tGuesses As G
					Where tiGuessNo Between @tiMinGuessNo And @tiMaxGuessNo 
					And Len(Possibles) = @tiMaxLenPoss

					Insert Into #ByCell(tiGuessNo
									, tiRow
									, tiCol
									, tiBlk
									, tiVal
									, RowSetString
									, ColSetString
									, BlkSetString
									, Possibles)
					Select @tiGuess
							, tiRow
							, tiCol
							, tiBlk
							, tiVal
							, RowSetString
							, ColSetString
							, BlkSetString
							, Possibles
					From #ByCell As B
					Where B.tiGuessNo = @tiMaxGuessNo - 1

					Update #ByCell
					Set tiVal = G.tiVal
					From #ByCell
					Inner Join @tGuesses As G On #ByCell.tiGuessNo = G.tiGuessNo And #ByCell.tiRow = G.tiRow And #ByCell.tiCol = G.tiCol

					Goto UpdateSetStrings
				End
				Else
				Begin
					Select 'That didnt work out too well, Dude.' As Status, Cast(@siCounter As nVarchar(3)) + ' iterations, ' + Cast(@tiGuess as nVarChar(2)) + ' guesses in ' + convert(varchar,datediff(ms,@t,getdate())) + ' ms' As PerfStats
				End
			End
		End
		Else
		Begin
			Select 'A bit of finger trouble, perhaps?  Check your typing in of the puzzle.' As Status, Cast(@siCounter As nVarchar(3)) + ' iterations, ' + Cast(@tiGuess as nVarChar(2)) + ' guesses in ' + convert(varchar,datediff(ms,@t,getdate())) + ' ms' As PerfStats
		End
	End

--ThatsAllForNowFolks
--Need to tidy up and go home
	Select Substring(@strPuzzle, (tiRow -1) * 9 + 1, 9) As Puzzle, Max(RowSetString) As Solution From #ByCell Where tiGuessNo = @tiGuess Group By tiRow Order By tiRow
	Drop Table #ByCell
--	Select convert(varchar,datediff(ms,@t,getdate())) + ' ms' As TimeTaken
