let
    Source = Sql.Database("cl-rds,1433", "Sage50_Mirror"),
    dbo_JRNLROW = Source{[Schema="dbo",Item="JRNLROW"]}[Data],
    #"Removed Other Columns" = Table.SelectColumns(dbo_JRNLROW,{"PostOrder", "RowNumber", "ItemRecordNumber", "Journal", "POSOIsClosed", "StockingQuantity", "StockingQtyReceived", "RowDescription", "Quantity", "JournalRowEx"}),
    #"Filtered Rows" = Table.SelectRows(#"Removed Other Columns", each [POSOIsClosed] = 0 and [ItemRecordNumber] <> 0 and [Journal] = 11)
in
    #"Filtered Rows"
