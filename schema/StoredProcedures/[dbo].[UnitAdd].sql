
CREATE PROCEDURE [dbo].[UnitAdd]
	@Code int,
	@Name nvarchar(100),
	@MaxVolume int,
	@ModesXML nvarchar(max),
	@ProductsXML nvarchar(max)
AS
BEGIN
	SET NOCOUNT ON

	BEGIN TRANSACTION

	SET XACT_ABORT ON

	insert into Units ([Code], [Name], [MaxVolume], [Enabled]) 
	values (@Code, @Name, @MaxVolume, 1);

	declare @UnitID int
	set @UnitID = IDENT_CURRENT('Units');

	/* 
	<Modes>
		<Item ID="1" UnitID="1" OrderID="1" Name="AAA" LossesRatio="10"/>
	</Modes>
	*/
	declare @docModes int;
	exec sp_xml_preparedocument @docModes OUTPUT, @ModesXML;

	select [ID], [UnitID], [OrderID], [Name], [LossesRatio]
	into #Modes 
	from openxml(@docModes, '/Modes/Item', 1) 
	with ([ID] int, [UnitID] int, [OrderID] tinyint, [Name] nvarchar(100), [LossesRatio] int);

	exec sp_xml_removedocument @docModes;

	insert into UnitModes ([UnitID], [OrderID], [Name], [LossesRatio])
	select @UnitID, M.[OrderID], M.[Name], M.[LossesRatio]
	from #Modes M;	

	/* 	
	<Products>
		<Item ID="0" UnitID="1" ModeID="1" OrderID="1" ProductID="1" Ratio="10"/>
	</Products>
	*/
	declare @docProducts int;
	exec sp_xml_preparedocument @docProducts OUTPUT, @ProductsXML;

	select ID, UnitID, ModeID, OrderID, ProductID, Ratio 
	into #Products
	from openxml(@docProducts, '/Products/Item', 1)
	with (ID int, UnitID int, ModeID int, OrderID tinyint, ProductID int, Ratio int)

	exec sp_xml_removedocument @docProducts
		
	insert into ModeProducts ([UnitID], [ModeID], [OrderID], [ProductID], [Ratio])
	select @UnitID, UM.ID, P.OrderID, P.ProductID, P.Ratio
	from #Products P
	left join UnitModes UM on (P.ModeID = UM.OrderID) and (UM.UnitID = @UnitID);	

	COMMIT TRANSACTION

	select @UnitID as ID;

END
GO

