VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "ThisWorkbook"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = True
Sub Every():
'Define necessary variables
Dim sheet As Worksheet
Dim row As Integer
Dim dummyrow As Integer
Dim Arng As Range
Dim Brng As Range
Dim LastRow As Long
Dim LastTicker As Long
Dim MinDate As Long
Dim MaxDate As Long
Dim List As Object

'Loop throuh Sheets
For Each sheet In ActiveWorkbook.Worksheets

'Count the Rows
LastRow = sheet.Cells(Rows.Count, 2).End(xlUp).row

'Find out the beginning & end of year Dates and define ranges
Set Arng = sheet.Range("A1:A" & LastRow)
Set Brng = sheet.Range("B1:B" & LastRow)
MinDate = Application.WorksheetFunction.Min(Brng)
MaxDate = Application.WorksheetFunction.Max(Brng)

'Format individual Sheet Titles
sheet.Range("A1").Value = "Ticker"
sheet.Range("B1").Value = "Date"
sheet.Range("C1").Value = "Open"
sheet.Range("D1").Value = "High"
sheet.Range("E1").Value = "Low"
sheet.Range("F1").Value = "Close"
sheet.Range("G1").Value = "Vol"
sheet.Range("J1").Value = "Yearly Change"
sheet.Range("K1").Value = "Percent Change"
sheet.Range("L1").Value = "Total Stock Volume"
sheet.Range("P1").Value = "Ticker"
sheet.Range("Q1").Value = "Value"
sheet.Range("O2").Value = "Greatest % Increase"
sheet.Range("O3").Value = "Greatest % Decrease"
sheet.Range("O4").Value = "Greatest Total Volume"

'Dummy Row for lookups with an autofill
    sheet.Range("H2").Formula = "=A2&B2"
    Range("H2").Select
    Selection.AutoFill Destination:=Range("H2:H" & LastRow)
    

'Copy & Paste Unique Tickers by filtering the list for only unique values and then copying it to the new destination
    Arng.AdvancedFilter Action:=xlFilterCopy, CopyToRange:=sheet.Range( _
        "I1"), Unique:=True

'Count the tickers
LastTicker = sheet.Cells(Rows.Count, 9).End(xlUp).row

'Add Calculation formulas with a for loop (I could Autofill it with some '$' hardcoding, but this is hard enough to read as-is.)
For row = 2 To LastTicker

'Calculate the desired figures. This is done in two ways. The first is to Index/Match to find the beginning and end of year, based on the MIN/MAX values grabbed earlier.
'To cope with stocks that doesn't start on the beginning or end of the year, it contains an IFNA function, and will look for the opening value with a VLOOKUP, or the closing value with a LOOKUP function, or both.
'If this were going to deal with messier spreadsheets, or be used commercially we would want to sort the table by date first, and then ticker, but as these sheets begin in order, this is unecessary.
'Note that the INDEX/MATCH could, in theory, be replaced by just a VLOOKUP & a LOOKUP, with the data in the current form, and would eliminate the need for the dummy column,
'But that solution would be far more prone to errors, which in the current version would be limited to be possible only for the potentially mis-sorted beginning and end dates for partial year tickers.
sheet.Range("J" & row).Formula = "=IFNA(INDEX(A2:H" & LastRow & ",MATCH(I" & row & "&" & MaxDate & ",H2:H" & LastRow & ",0),6),LOOKUP(2,1/(A2:A" & LastRow & "=I" & row & "),F2:F" & LastRow & "))-IFNA(INDEX(A2:H" & LastRow & ",MATCH(I" & row & "&" & MinDate & ",H2:H" & LastRow & ",0),3),VLOOKUP(I" & row & ",A2:C" & LastRow & ",3,0))"
sheet.Range("K" & row).Formula = "=(IFNA(INDEX(A2:H" & LastRow & ",MATCH(I" & row & "&" & MaxDate & ",H2:H" & LastRow & ",0),6),LOOKUP(2,1/(A2:A" & LastRow & "=I" & row & "),F2:F" & LastRow & "))-IFNA(INDEX(A2:H" & LastRow & ",MATCH(I" & row & "&" & MinDate & ",H2:H" & LastRow & ",0),3),VLOOKUP(I" & row & ",A2:C" & LastRow & ",3,0)))/IFNA(INDEX(A2:H" & LastRow & ",MATCH(I" & row & "&" & MinDate & ",H2:H" & LastRow & ",0),3),VLOOKUP(I" & row & ",A2:C" & LastRow & ",3,0))"
sheet.Range("L" & row).Formula = "=SUMIF(A:A,I" & row & ",G:G)"

'Sorta Conditional Formatting
    If sheet.Range("J" & row).Value > 0 Then
        sheet.Range("J" & row).Interior.ColorIndex = 4
    ElseIf sheet.Range("J" & row).Value < 0 Then
        sheet.Range("J" & row).Interior.ColorIndex = 3
    End If

Next row

' Calculate Mins/Maxs for top stuff
sheet.Range("Q2").Formula = "=MAX(K2:K" & LastTicker & ")"
sheet.Range("Q3").Formula = "=MIN(K2:K" & LastTicker & ")"
sheet.Range("Q4").Formula = "=MAX(L2:L" & LastTicker & ")"

'Add tickers for the min/maxes
sheet.Range("P2").Formula = "=Index(I2:K" & LastTicker & ",MATCH(Q2,K2:K" & LastTicker & ",0),1)"
sheet.Range("P3").Formula = "=Index(I2:K" & LastTicker & ",MATCH(Q3,K2:K" & LastTicker & ",0),1)"
sheet.Range("P4").Formula = "=Index(I2:L" & LastTicker & ",MATCH(Q4,L2:L" & LastTicker & ",0),1)"


'Eliminate our dummy row by copying and pasting the values of our ugly calculations so as not to mess up our formulas and hen delete the dummy
Range("J2:K" & LastTicker).Select
    Selection.Copy
    Selection.PasteSpecial Paste:=xlPasteValues, Operation:=xlNone, SkipBlanks _
        :=False, Transpose:=False
    Application.CutCopyMode = False

    Range("H2").Select
    Selection.ClearContents
    Selection.AutoFill Destination:=Range("H2:H" & LastRow)

'Do prettier formats because we are not animals.
sheet.Range("J2:J" & LastTicker).NumberFormat = "* #,##0.00;* (#,##0.00)"
sheet.Range("K2:K" & LastTicker).NumberFormat = "0.0%"
sheet.Range("L2:L" & LastTicker).NumberFormat = "* #,##0;* (#,##0)"
sheet.Columns("A:G,I:L,O:Q").AutoFit

Next sheet

End Sub



