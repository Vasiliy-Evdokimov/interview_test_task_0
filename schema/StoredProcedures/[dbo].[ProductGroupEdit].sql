
CREATE PROCEDURE [dbo].[ProductGroupEdit]
	@ID int,
	@Code int,
	@Name nvarchar(100)
AS
BEGIN
	SET NOCOUNT ON;
	
	update ProductsGroups 
	set [Code] = @Code, 
		[Name] = @Name 
	where ID = @ID;

	select @ID as ID;

END
GO

