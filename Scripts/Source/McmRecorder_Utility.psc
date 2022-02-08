scriptName McmRecorder_Utility hidden

; From https://www.creationkit.com/index.php?title=User:Sclerocephalus#A_short_function_for_sorting_arrays
Function SortStringArray (string[] myArray)
    int index1
    int index2 = myArray.Length - 1
	while (index2 > 0)
		index1 = 0
		while (index1 < index2)
			if (MyArray [index1] > myArray[index1 + 1])
				string swapDummy = myArray[index1]
				myArray[index1] = myArray[index1 + 1]
				myArray[index1 + 1] = swapDummy
			endIf
			index1 += 1
		endWhile
		index2 -= 1
	endWhile
endFunction
