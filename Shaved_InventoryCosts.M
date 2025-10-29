let
    Source = Sql.Database("cl-rds, 1433", "Sage50_Mirror"),
    dbo_InventoryCosts = Source{[Schema="dbo",Item="InventoryCosts"]}[Data],
    #"Filtered Rows" = Table.SelectRows(dbo_InventoryCosts, each ([JournalType] = 15)),
    #"Sorted Rows" = Table.Sort(#"Filtered Rows",{{"ItemRecNumber", Order.Ascending}, {"TransDate", Order.Descending}}),
    #"Grouped Rows" = Table.Group(#"Sorted Rows", {"ItemRecNumber"}, {{"LatestRow", each _, type table [__RowID=number, ItemRecNumber=nullable number, TransDate=nullable datetime, RowNumber=nullable number, RecordType=nullable number, PostOrderNumber=nullable number, GUID=nullable binary, JournalType=nullable number, PostedFromHere=nullable number, TransAmount=nullable number, Quantity=nullable number, OptAmount=nullable number, OptQty=nullable number, CostAcctRecNumber=nullable number, InvAcctRecNumber=nullable number, RefQuantity=nullable number, IsBegBal=nullable number, LastUpdateCounter=nullable number, MajorType=nullable number, HasAvailableItem=nullable number]}}),
    #"Added Custom" = Table.AddColumn(#"Grouped Rows", "LatestQuantityRow", each Table.First([LatestRow])),
    #"Expanded LatestQuantityRow" = Table.ExpandRecordColumn(#"Added Custom", "LatestQuantityRow", {"Quantity"}, {"Quantity"}),
    #"Renamed Columns" = Table.RenameColumns(#"Expanded LatestQuantityRow",{{"Quantity", "QuantityOnHand"}}),
    #"Removed Columns" = Table.RemoveColumns(#"Renamed Columns",{"LatestRow"}),
    #"Sorted Rows1" = Table.Sort(#"Removed Columns",{{"ItemRecNumber", Order.Ascending}}),
    #"Merged Queries" = Table.NestedJoin(#"Sorted Rows1", {"ItemRecNumber"}, Shaved_LineItem, {"ItemRecordNumber"}, "Shaved_LineItem", JoinKind.LeftOuter),
    #"Expanded Shaved_LineItem" = Table.ExpandTableColumn(#"Merged Queries", "Shaved_LineItem", {"ItemID", "ItemDescription", "ReorderPoint", "OrderQty"}, {"ItemID", "ItemDescription", "ReorderPoint", "OrderQty"}),
    #"Reordered Columns" = Table.ReorderColumns(#"Expanded Shaved_LineItem",{"ItemRecNumber", "ItemID", "ItemDescription", "ReorderPoint", "OrderQty", "QuantityOnHand"}),
    #"Added Custom1" = Table.AddColumn(#"Reordered Columns", "Shortage", each if [QuantityOnHand] < [ReorderPoint] then "Yes" else "No"),
    #"Filtered Rows1" = Table.SelectRows(#"Added Custom1", each true)
in
    #"Filtered Rows1"
