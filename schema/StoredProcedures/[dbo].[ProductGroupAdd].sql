
CREATE PROCEDURE [dbo].[ProductGroupAdd]
	@Code int,
	@Name nvarchar(100)
AS
BEGIN
	SET NOCOUNT ON;
	
	insert into ProductsGroups 
		([Code], [Name], [Enabled]) 
	values
		(@Code, @Name, 1);

	select IDENT_CURRENT('ProductsGroups') as ID;

END
GO

