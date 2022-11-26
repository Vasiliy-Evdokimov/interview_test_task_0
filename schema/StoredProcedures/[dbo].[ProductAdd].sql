
CREATE PROCEDURE [dbo].[ProductAdd]
	@Code int,
	@Name nvarchar(100),
	@GroupID int
AS
BEGIN
	SET NOCOUNT ON;
	
	insert into Products 
		([Code], [Name], [GroupID], [Enabled]) 
	values
		(@Code, @Name, @GroupID, 1);

	select IDENT_CURRENT('Products') as ID;

END
GO

