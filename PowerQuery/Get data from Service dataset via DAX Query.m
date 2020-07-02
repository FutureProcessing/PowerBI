/*This query can be used to run DAX queries against PowerBI Service dataset for which you have "Build" permission. 
The GUID used in Initial Catalog and Location parameters can be obtained by either looing at the URL when in dataset settings or by inspecting the "Analyze in Excel" .odc connection file*/

let
    Source =    OleDb.DataSource
                (
                    "Provider=MSOLAP;
                    Data Source=https://analysis.windows.net/powerbi/api;
                    ;
                    Initial Catalog=abcdefgh-ijkl-mnop-qrst-uvwxyz123456; 
                    Location=https://wabi-north-europe-redirect.analysis.windows.net/xmla?vs=sobe_wowvirtualserver&db=abcdefgh-ijkl-mnop-qrst-uvwxyz123456;",
                    [Query="
                        EVALUATE

                        ROW(""DAX TABLE"", ""DAX QUERY GOES HERE"")
                    "]
                ),
    #"Strip table name from column names" = Table.TransformColumnNames(Source, each if Text.Contains(_,"[") then Text.BetweenDelimiters(_,"[","]") else _)
in
    #"Strip table name from column names"