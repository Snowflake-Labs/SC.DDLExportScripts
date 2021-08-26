CHANGE LOG
==========

Version 0.0.18

We found a pattern like this:

```sql
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[XXX]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[XXX] AS' 
END
GO

ALTER procedure [dbo].[XXX]
as
	set nocount on
	begin transaction
            --- code omitted
	commit
	return @@identity
```
Because the tools reviews dynamic sql it had to statements for `XXX` one with an empty body and another one with a body.

The tool now recognizes this pattern too.

We also added more logging so this situations can be more properly diagnosed