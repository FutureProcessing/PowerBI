let
	Source =
		let
			Table_ReplaceByMerging = (
				SourceTable as table,
				TableWithReplacements as table,
				ColumnToReplace as text,
				ColumnToReplaceWith as text,
				LookupColumn as text
			) =>
				let
					Source = SourceTable,
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
					#"Expand Merged Column",
			FunctionDocumentation = type function (
				SourceTable as (
					type table
						meta [
							Documentation.FieldCaption     = "Source Table",
							Documentation.FieldDescription = "The table in which values will be replaced"
						]
				),
				TableWithReplacements as (
					type table
						meta [
							Documentation.FieldCaption     = "Table with replacements",
							Documentation.FieldDescription = "The table that contains replacement values"
						]
				),
				ColumnToReplace as (
					type text
						meta [
							Documentation.FieldCaption = "Column to replace",
							Documentation.FieldDescription
								= "The column in source table in which we want to replace values",
							Documentation.SampleValues = {"Column1"}
						]
				),
				ColumnToReplaceWith as (
					type text
						meta [
							Documentation.FieldCaption = "Column to replace with",
							Documentation.FieldDescription
								= "The column in replacement table, which values will be used for replacing",
							Documentation.SampleValues = {"ColumnB"}
						]
				),
				LookupColumn as (
					type text
						meta [
							Documentation.FieldCaption = "Lookup column",
							Documentation.FieldDescription
								= "The column in replacement table containing matching values source table (used for merging)",
							Documentation.SampleValues = {"ColumnA"}
						]
				)
			) as table
				meta [
					Documentation.Name = "Table_ReplaceByMerging",
					Documentation.Description
						= "Replace values in a column with matching values from another table by performing a merge"
				]
		in
			Value.ReplaceType(Table_ReplaceByMerging, FunctionDocumentation)
in
	Source