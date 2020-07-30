///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
/////////////                                                                 /////////////
/////////////    Title: Power BI Dataset Connector for Power BI               ///////////// 
/////////////    Created by: Jakub Pierzchała (jakub.pierzchala@gmail.com)    ///////////// 
/////////////                                                                 ///////////// 
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////

section PowerBIDatasets;

TestDataset = "49cd2b3c-2e27-4201-856a-98515aa8b29c";

//
// Exported function(s)
//

[DataSource.Kind="PowerBIDataset"]
shared PowerBIDataset.DAXQuery = Value.ReplaceType(DAXQuery, DAXQueryType);

DAXQueryType = type function
(
    DatasetID as 
    ( type text meta
        [
            Documentation.FieldCaption = "Dataset ID",
            Documentation.FieldDescription = "Dataset ID to run the DAX query against",
            DataSource.Path = false
        ]
    ),
    Query as 
    ( type text meta
        [
            Documentation.FieldCaption = "Query",
            Documentation.FieldDescription = "DAX Query to execute against the dataset",
            Formatting.IsMultiLine = true,
            Formatting.IsCode = true,
            DataSource.Path = false
        ]
    )
) as table meta 
[                  
        Documentation.Name = "PowerBIDataset.DAXQuery",
        Documentation.LongDescription = "Executes Dax Query against a Dataset",
        Documentation.Examples = 
        {[
            Description = "Execute a DAX Query against a PowerBI Service Dataset",
            Code = "=PowerBIDataset.DAXQuery(""DatasetID"", ""Query"")",
            Result = "Result of a DAX Query as table"
        ]}
]; 

DAXQuery = (DatasetID as text, Query as text) =>
let
    Source =    OleDb.DataSource
                (
                    "Provider=MSOLAP;
                    Data Source=https://analysis.windows.net/powerbi/api;
                    ;
                    Initial Catalog="&DatasetID&"; 
                    Location=https://wabi-north-europe-redirect.analysis.windows.net/xmla?vs=sobe_wowvirtualserver&db="&DatasetID&";",
                    [Query=Query]
                ),
    #"Strip Table Name" = StripTableNameFromColumnNames(Source)
in
    #"Strip Table Name";

[DataSource.Kind="PowerBIDataset"]
shared PowerBIDataset.Table = Value.ReplaceType(Table, TableType);

TableType = type function
(
    DatasetID as 
    ( type text meta
        [
            Documentation.FieldCaption = "Dataset ID",
            Documentation.FieldDescription = "Dataset ID to get the list of fields and tables from",
            DataSource.Path = false
        ]
    ),
    Table as 
    ( type text meta
        [
            Documentation.FieldCaption = "Table Name",
            Documentation.FieldDescription = "Table name to obtain from the dataset",
            DataSource.Path = false
        ]
    )
) as table meta 
[                  
        Documentation.Name = "PowerBIDataset.Table",
        Documentation.LongDescription = "Gets a table from the dataset",
        Documentation.Examples = 
        {[
            Description = "Get a table from dataset",
            Code = "=PowerBIDataset.DAXQuery(""DatasetID"", ""Table"")",
            Result = "Full table from the dataset"
        ]}
]; 

Table = (DatasetID as text, Table as text) =>
let
    Source = DAXQuery(DatasetID, "evaluate "&Table)
in
    Source;

[DataSource.Kind="PowerBIDataset"]
shared PowerBIDataset.GetDatasetTablesAndFields =    Value.ReplaceType(GetDatasetTablesAndFields, GetDatasetTablesAndFieldsType);

 GetDatasetTablesAndFieldsType = type function 
 (
        DatasetID as 
        ( type text meta
            [
                Documentation.FieldCaption = "Dataset ID",
                Documentation.FieldDescription = "Dataset ID to get the list of fields and tables from",
                DataSource.Path = false
            ]
        )
) as table meta 
[                  
        Documentation.Name = "PowerBIDataset.GetDatasetTablesAndFields",
        Documentation.LongDescription = "Gets the list of all tables and columns from the dataset",
        Documentation.Examples = 
        {[
            Description = "Gets the list of all tables and columns from the dataset",
            Code = "=PowerBIDataset.GetDatasetTablesAndFields(""DatasetID"")",
            Result = "Table with all Tables and Columns from the dataset"
        ]}
]; 

GetDatasetTablesAndFields = (DatasetID as text) =>
let
    Source = OleDb.DataSource("Provider=MSOLAP.8;Data Source=https://analysis.windows.net/powerbi/api;;Initial Catalog="&DatasetID&";Location=https://wabi-north-europe-redirect.analysis.windows.net/xmla?vs=sobe_wowvirtualserver&db="&DatasetID&";MDX Compatibility= 1; MDX Missing Member Mode= Error; Safety Options= 2; Update Isolation Level= 2; Locale Identifier= 1033", [Query="select * from $SYSTEM.DBSCHEMA_COLUMNS"]),
    #"Filtered Rows" = Table.SelectRows(Source, each ([TABLE_SCHEMA] = "Model") and ([COLUMN_OLAP_TYPE] = "ATTRIBUTE")),
    #"Removed Other Columns" = Table.SelectColumns(#"Filtered Rows",{"TABLE_NAME", "COLUMN_NAME"}),
    #"Uppercased Text" = Table.TransformColumns(#"Removed Other Columns",{{"TABLE_NAME", each Text.End(_, Text.Length(_)-1), type text}}),
    #"Filtered Rows1" = Table.SelectRows(#"Uppercased Text", each not Text.StartsWith([TABLE_NAME], "LocalDateTable") and not Text.StartsWith([TABLE_NAME], "DateTable")),
    #"Filtered Rows2" = Table.SelectRows(#"Filtered Rows1", each not Text.StartsWith([COLUMN_NAME], "RowNumber")),
    #"Renamed Columns" = Table.RenameColumns(#"Filtered Rows2",{{"TABLE_NAME", "Table"}, {"COLUMN_NAME", "Column"}})
in
    #"Renamed Columns";

//
// Helper function(s)
//

StripTableNameFromColumnNames = (Table as table) =>
let
    Source = Table.TransformColumnNames(Table, each if Text.Contains(_,"[") then Text.BetweenDelimiters(_,"[","]") else _)
in
    Source;

//
// Data Source definition
//
PowerBIDataset = 
[
    TestConnection = (dataSourcePath) => { "PowerBIDataset.GetDatasetTablesAndFields", TestDataset },
    Authentication = 
    [
		UsernamePassword = []
    ],
    Label = "PowerBI Dataset Connector"
];