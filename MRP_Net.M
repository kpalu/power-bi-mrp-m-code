let
    Source = SO_Demand_Exploded,
    #"Merged Queries" = Table.NestedJoin(Source, {"ItemRecordNo"}, ExplodedRequirements, {"ItemRecordNumber"}, "ExplodedRequirements", JoinKind.LeftOuter),
    #"Expanded ExplodedRequirements" = Table.ExpandTableColumn(#"Merged Queries", "ExplodedRequirements", {"WO_Supply", "LowestWO"}, {"WO_Supply", "LowestWO"}),
    #"Merged Queries1" = Table.NestedJoin(#"Expanded ExplodedRequirements", {"ItemRecordNo"}, Shaved_InventoryCosts, {"ItemRecNumber"}, "Shaved_InventoryCosts", JoinKind.LeftOuter),
    #"Expanded Shaved_InventoryCosts" = Table.ExpandTableColumn(#"Merged Queries1", "Shaved_InventoryCosts", {"QuantityOnHand"}, {"QuantityOnHand"}),
    #"Replaced Nulls" = Table.ReplaceValue(#"Expanded Shaved_InventoryCosts",null,0,Replacer.ReplaceValue,{"TotalQty", "WO_Supply", "QuantityOnHand"}),
    #"Added Custom" = Table.AddColumn(#"Replaced Nulls", "RawNetReq", each [TotalQty] - [WO_Supply] - [QuantityOnHand]),
    #"Changed Type" = Table.TransformColumnTypes(#"Added Custom",{{"RawNetReq", type number}}),
    #"Added GapType" = Table.AddColumn(#"Changed Type", "GapType", each if [RawNetReq] > 0 then if [ItemClass] = "5" then "Labor" else if [ItemClass] = "3" or [ItemClass] = "11" then "Needs WO" else "Needs Purchase" else "Fulfilled"),
    #"Sorted Rows" = Table.Sort(#"Added GapType",{{"DateDue", Order.Ascending}, {"CustomerID", Order.Ascending}, {"Level", Order.Ascending}}),
    #"Self Merge" = Table.NestedJoin(#"Sorted Rows", {"ParentRecordNo"}, #"Sorted Rows", {"ItemRecordNo"}, "Parent", JoinKind.LeftOuter),
    #"Expanded Parent" = Table.ExpandTableColumn(#"Self Merge", "Parent", {"QuantityOnHand", "TotalRequired"}, {"ParentQuantityOnHand", "ParentTotalRequired"}),
    #"Added FulfilledByParent" = Table.AddColumn(#"Expanded Parent", "FulfilledByParent", each if [Level] = 0 then false else [ParentQuantityOnHand] >= [ParentTotalRequired]),
    #"Adjusted NetReq" = Table.AddColumn(#"Added FulfilledByParent", "NetReq", each if [FulfilledByParent] then 0 else [RawNetReq])
in
    #"Adjusted NetReq"
