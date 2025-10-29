let
    Source = Sql.Database("cl-rds,1433", "Sage50_Mirror"),
    dbo_Worktkt_Header = Source{[Schema="dbo",Item="Worktkt_Header"]}[Data],
    #"Filtered Rows" = Table.SelectRows(dbo_Worktkt_Header, each [Closed] = 0),
    #"Merged JRNLROW" = Table.NestedJoin(#"Filtered Rows", {"PostOrder"}, Shaved_JRNLROW, {"PostOrder"}, "JRNLROW", JoinKind.LeftOuter),
    #"Merged JRNLHDR" = Table.NestedJoin(#"Merged JRNLROW", {"PostOrder"}, Shaved_JRNLHDR, {"PostOrder"}, "JRNLHDR", JoinKind.LeftOuter),
    #"Expanded JRNLHDR" = Table.ExpandTableColumn(#"Merged JRNLHDR", "JRNLHDR", {"CustVendId", "DateDue"}, {"CustomerID", "SO_DateDue"}),
    #"Added Priority" = Table.AddColumn(#"Expanded JRNLHDR", "DemandPriority", each if [SO_DateDue] <> null then [SO_DateDue] else null),
    #"Removed Other Columns" = Table.SelectColumns(#"Added Priority",{"ItemRecordNumber", "Number", "RecordNumber", "QtyToBuild", "Closed", "DateNeededBy", "PostOrder", "CustomerID", "SO_DateDue", "DemandPriority"}),
    #"Sorted Rows" = Table.Sort(#"Removed Other Columns",{{"Number", Order.Descending}})
in
    #"Sorted Rows"
