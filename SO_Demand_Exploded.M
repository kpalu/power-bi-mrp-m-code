let
    Source = Shaved_JRNLROW,
    #"Merged Queries" = Table.NestedJoin(Source, {"PostOrder"}, Shaved_JRNLHDR, {"PostOrder"}, "Shaved_JRNLHDR", JoinKind.LeftOuter),
    #"Expanded Shaved_JRNLHDR" = Table.ExpandTableColumn(#"Merged Queries", "Shaved_JRNLHDR", {"Description", "Reference", "DateDue"}, {"Description", "Reference", "DateDue"}),
    #"Invoked Custom Function" = Table.AddColumn(#"Expanded Shaved_JRNLHDR", "Invoke Custom Function", each fnBOMExplosion([ItemRecordNumber], [Quantity])),
    #"Expanded Invoke Custom Function" = Table.ExpandTableColumn(#"Invoked Custom Function", "Invoke Custom Function", {"ItemRecordNo", "TotalQty", "Level", "ParentRecordNo", "ItemClass"}, {"ItemRecordNo", "TotalQty", "Level", "ParentRecordNo", "ItemClass"}),
    #"Added Custom" = Table.AddColumn(#"Expanded Invoke Custom Function", "SO_Number", each [Reference]),
    #"Sorted Rows" = Table.Sort(#"Added Custom",{{"Reference", Order.Ascending}, {"RowNumber", Order.Ascending}}),
    #"Removed Other Columns" = Table.SelectColumns(#"Sorted Rows",{"Description", "DateDue", "ItemRecordNo", "TotalQty", "Level", "ParentRecordNo", "ItemClass", "SO_Number"}),
    #"Renamed Columns" = Table.RenameColumns(#"Removed Other Columns",{{"Description", "CustomerID"}}),
    #"Sorted Rows1" = Table.Sort(#"Renamed Columns",{{"Level", Order.Ascending}})
in
    #"Sorted Rows1"
