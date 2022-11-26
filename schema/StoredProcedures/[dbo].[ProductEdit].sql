
CREATE PROCEDURE [dbo].[ProductEdit]
	@ID int,
	@Code int,
	@Name nvarchar(100),
	@GroupID int
AS
BEGIN
	SET NOCOUNT ON;
	
	update Products 
	set [Code] = @Code, 
		[Name] = @Name,
		[GroupID] = @GroupID 
	where ID = @ID;

	select @ID as ID;

END
GO

