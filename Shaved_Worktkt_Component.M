let
    Source = Sql.Database("cl-rds,1433", "Sage50_Mirror"),
    dbo_Worktkt_Component = Source{[Schema="dbo",Item="Worktkt_Component"]}[Data],
    #"Filtered Rows" = Table.SelectRows(dbo_Worktkt_Component, each ([Item] <> "0")),
    #"Merged Queries" = Table.NestedJoin(#"Filtered Rows", {"Number"}, Shaved_Worktkt_Header, {"Number"}, "Worktkt_Header", JoinKind.Inner),
    #"Removed Other Columns" = Table.SelectColumns(#"Merged Queries",{"Number", "RecordNumber", "ComponentNo", "Item", "Qty"})
in
    #"Removed Other Columns"
