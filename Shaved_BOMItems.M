let
    Source = Sql.Database("cl-rds,1433", "Sage50_Mirror"),
    dbo_BOMItems = Source{[Schema="dbo",Item="BOMItems"]}[Data],
    #"Changed Type" = Table.TransformColumnTypes(dbo_BOMItems,{{"RevisionNumber", Int64.Type}}),
    #"Grouped Rows" = Table.Group(#"Changed Type", {"AssemblyRecordNo"}, {{"AllRows", each _, type table [__RowID=number, RecordNumber=nullable number, AssemblyRecordNo=nullable number, EffectiveDate=nullable datetime, ComponentNumber=nullable number, RevisionNumber=nullable number, GUID=nullable binary, QtyRequired=nullable number, ComponentRecordNo=nullable number, LastUpdateCounter=nullable number]}, {"MaxRevision", each List.Max([RevisionNumber]), type nullable number}}),
    #"Changed Type1" = Table.TransformColumnTypes(#"Grouped Rows",{{"MaxRevision", Int64.Type}}),
    #"Added Custom" = Table.AddColumn(#"Changed Type1", "LatestBOM", each Table.SelectRows([AllRows], (innerRow) => innerRow[RevisionNumber] = [MaxRevision])),
    #"Expanded LatestBOM" = Table.ExpandTableColumn(#"Added Custom", "LatestBOM", {"EffectiveDate", "ComponentNumber", "RevisionNumber", "QtyRequired", "ComponentRecordNo"}, {"EffectiveDate", "ComponentNumber", "RevisionNumber", "QtyRequired", "ComponentRecordNo"}),
    #"Removed Columns" = Table.RemoveColumns(#"Expanded LatestBOM",{"AllRows", "MaxRevision"}),
    #"Sorted Rows" = Table.Sort(#"Removed Columns",{{"AssemblyRecordNo", Order.Ascending}, {"ComponentNumber", Order.Ascending}})
in
    #"Sorted Rows"
