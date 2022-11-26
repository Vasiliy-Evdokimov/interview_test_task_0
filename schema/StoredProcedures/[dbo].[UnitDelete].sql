
CREATE PROCEDURE [dbo].[UnitDelete]
	@UnitID int
AS
BEGIN
	SET NOCOUNT ON

	BEGIN TRANSACTION

	SET XACT_ABORT ON

	delete from ModeProducts where UnitID = @UnitID;
	delete from UnitModes where UnitID = @UnitID;
	delete from Units where ID = @UnitID;

	COMMIT TRANSACTION

	select 0 as ID;

END
GO

