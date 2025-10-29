let
    Source = Sql.Database("cl-rds,1433", "Sage50_Mirror"),
    dbo_JRNLHDR = Source{[Schema="dbo",Item="JRNLHDR"]}[Data],
    #"Removed Other Columns" = Table.SelectColumns(dbo_JRNLHDR,{"JrnlKey_Journal", "CustVendId", "PostOrder", "Description", "Reference", "DateDue", "POSOisClosed"}),
    #"Filtered Rows" = Table.SelectRows(#"Removed Other Columns", each [JrnlKey_Journal] = 11 and [POSOisClosed] = 0),
    #"Changed Type" = Table.TransformColumnTypes(#"Filtered Rows",{{"DateDue", type date}})
in
    #"Changed Type"
