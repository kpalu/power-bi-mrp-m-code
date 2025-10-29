let
    Source = Shaved_Worktkt_Header,
    #"Grouped Rows" = Table.Group(Source, {"ItemRecordNumber"}, {{"WO_Supply", each List.Sum([QtyToBuild]), type nullable number}, {"LowestWO", each List.Min([Number]), type nullable number}, {"DemandPriority", each List.First([DemandPriority]), type nullable date}})
in
    #"Grouped Rows"
