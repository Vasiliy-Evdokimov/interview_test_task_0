
CREATE PROCEDURE [dbo].[AddProductToMode]
	@UnitID int,
	@Name nvarchar(100),
	@LossesRatio int,
	@ProductsXML nvarchar(max)
AS
BEGIN
	SET NOCOUNT ON

	BEGIN TRANSACTION

	SET XACT_ABORT ON
	
	declare @docProducts int;
	exec sp_xml_preparedocument @docProducts OUTPUT, @ProductsXML;

	select ID, UnitID, ModeID, OrderID, ProductID, Ratio 
	into #Products
	from openxml(@docProducts, '/Products/Item', 1)
	with (ID int, UnitID int, ModeID int, OrderID tinyint, ProductID int, Ratio int)

	exec sp_xml_removedocument @docProducts

	declare @OrderID tinyint;
	select @OrderID = max(OrderID) from UnitModes where UnitID = @UnitID;
	if @OrderID is null set @OrderID = 0;
	set @OrderID = @OrderID + 1;

	insert into UnitModes ([UnitID], [OrderID], [Name], [LossesRatio])
	values (@UnitID, @OrderID, @Name, @LossesRatio);

	declare @ModeID int
	set @ModeID = IDENT_CURRENT('UnitModes');
	
	insert into ModeProducts ([UnitID], [ModeID], [OrderID], [ProductID], [Ratio])
	select @UnitID, @ModeID, OrderID, ProductID, Ratio
	from #Products

	COMMIT TRANSACTION

END
GO

