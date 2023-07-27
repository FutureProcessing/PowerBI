using TabularEditor.TOMWrapper;
using System.Collections.Generic;

/*
 * Title:
 * DAX SUMMARIZE Statement Generator for Tabular Editor 3
 * 
 * Overview:
 * This C# script generates a `SUMMARIZE` DAX expression for a particular table in the model loaded into Tabular Editor 3.
 * It customizes the generated `SUMMARIZE` statement to include all columns not just from the specified table, but also
 * from all tables that are related to it via 'one' side of active relationships, all the way down the relationship chain.
 *
 * This can be extremely useful for debugging and analysis purposes in Microsoft's Power BI software, especially when
 * dealing with complex data models with a high number of tables and relationships.
 * 
 * How it works:
 * - The script takes as input a string representing the name of the table for which to generate the `SUMMARIZE` statement.
 * - It uses the `GetRelatedTables` function to recursively collect all tables that are related to the input table via
 *   'one' side of active relationships.
 * - For each related table, it collects all columns and appends them to the `SUMMARIZE` statement.
 * - To avoid infinite recursion (which could occur if there are cyclical relationships in your model), the script includes
 *   a mechanism to keep track of which tables have already been visited during the execution of the `GetRelatedTables` function.
 *
 * How to use:
 * 1. Open Tabular Editor 3.
 * 2. Load your data model.
 * 3. Go to File > Open > C# script and select this script.
 * 4. Replace "YourTableName" in the `tableName` variable with the actual name of the table you are interested in (the name is case-sensitive).
 * 5. Run the script by pressing F5 or by clicking the "Play" button.
 * 6. The script will output a `SUMMARIZE` statement for the specified table and all related tables in the output pane.
 */

string tableName = "Payments"; // replace with your table name

List<Table> GetRelatedTables(Table t, HashSet<Table> visitedTables = null)
{
    visitedTables = visitedTables ?? new HashSet<Table>();
    if (visitedTables.Contains(t)) return new List<Table>();

    visitedTables.Add(t);

    var relatedTables = Model.Relationships
        .Where(r => r.IsActive && // Only consider active relationships
                   ((r.FromTable == t && r.ToCardinality == RelationshipEndCardinality.One) ||
                   (r.ToTable == t && r.FromCardinality == RelationshipEndCardinality.One)))
        .Select(r => r.FromTable == t ? r.ToColumn.Table : r.FromColumn.Table)
        .Distinct()
        .ToList();

    for (int i = 0; i < relatedTables.Count; i++)
    {
        var relatedRelatedTables = GetRelatedTables(relatedTables[i], visitedTables);
        foreach (var relatedRelatedTable in relatedRelatedTables)
        {
            if (!relatedTables.Contains(relatedRelatedTable))
                relatedTables.Add(relatedRelatedTable);
        }
    }

    return relatedTables;
}

var t = Model.Tables[tableName];
if (t == null)
{
    Console.WriteLine("Table not found");
    return;
}

var dax = $"SUMMARIZE('{t.Name}', ";
var columns = t.Columns.Select(c => $"'{t.Name}'[{c.Name}]").ToList();

var relatedTables = GetRelatedTables(t);

foreach (var relatedTable in relatedTables)
{
    var relatedColumns = relatedTable.Columns.Select(c => $"'{relatedTable.Name}'[{c.Name}]");
    columns.AddRange(relatedColumns);
}

dax += string.Join(", ", columns) + ")";
dax.Output();
