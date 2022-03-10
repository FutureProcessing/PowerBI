let
	Source =
		let
			Table_ReplaceUsingDictionary = (
				SourceTable as table,
				ListOfReplaces as list
			) => List.Accumulate(ListOfReplaces, SourceTable, (state, current) => 
			let
					Source = state,
					TableWithReplacements = current{0},
					ColumnToReplace = current{1},
					ColumnToReplaceWith = current{2},
					LookupColumn = current{3},
					#"Merged Queries" = Table.NestedJoin(
						Source,
						ColumnToReplace,
						TableWithReplacements,
						LookupColumn,
						"Merge",
						JoinKind.LeftOuter
					),
					#"Remove Source Column" = Table.RemoveColumns(#"Merged Queries", {ColumnToReplace}),
					#"Expand Merged Column" = Table.ExpandTableColumn(
						#"Remove Source Column",
						"Merge",
						{ColumnToReplaceWith},
						{ColumnToReplace}
					)
				in
					#"Expand Merged Column"
			),
				
			FunctionDocumentation = type function (
				SourceTable as (
					type table
						meta [
							Documentation.FieldCaption     = "Source Table",
							Documentation.FieldDescription = "The table in which values will be replaced"
						]
				),
				ListOfReplaces as (
					type list
						meta [
							Documentation.FieldCaption     = "List of replaces",
							Documentation.FieldDescription = "List of replaces to be performed. The replaces should be in format:
							{TableWithReplacements,ColumnToReplace,ColumnToReplaceWith,LookupColumn}"
						]
				)
			) as table
				meta [
					Documentation.Name = "Table_ReplaceUsingDictionary",
					Documentation.Description
						= "Replace values in columns of <code>Source Table</code> with matching values from dictionary tables",
					Documentation.LongDescription
						= 
						"
							Replace values in columns of <code>Source Table</code> with matching values from dictionary tables.
							<ul></ul>
							The <code>list of replaces</code> contains list of columns to be replaced and their corresponding 
							links to dictionary tables. List elements should be entered in following format:
							<ul>
								<li> <code>Dictionary Table</code>: the table containing values to be replaced </li>
								<li> <code>Column to replace</code>: the name of the column from <code>Source Table</code> to be replaced </li>
								<li> <code>Column to replace with</code>: the column name of <code>Dictionary Table</code> containing values to be replaced </li>
								<li> <code>Lookup column</code>: the column name of <code>Dictionary Table</code> containing matching values from <code>Source Table</code> </li>
							</ul>
						"
				]
		in
			Value.ReplaceType(Table_ReplaceUsingDictionary, FunctionDocumentation)
in
	Source