let
    Source = Sql.Database("cl-rds,1433", "Sage50_Mirror"),
    dbo_LineItem = Source{[Schema="dbo",Item="LineItem"]}[Data],
    #"Removed Other Columns" = Table.SelectColumns(dbo_LineItem,{"Category", "ItemClass", "ItemDescription", "ItemID", "ItemRecordNumber", "OrderQty", "ReorderPoint", "StockingUM"})
in
    #"Removed Other Columns"
