
CREATE PROCEDURE [dbo].[UnitEdit]
	@UnitID int,
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

	update Units 
	set
		[Code] = @Code, 
		[Name] = @Name, 
		[MaxVolume] = @MaxVolume 
	where ID = @UnitID;

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

	delete from UnitModes 
		where 
			(UnitID = @UnitID) and 
			(ID not in (select ID from #Modes));
	
	update UnitModes 
	set
		UnitModes.[OrderID] = #Modes.[OrderID], 
		UnitModes.[Name] = #Modes.[Name],
		UnitModes.[LossesRatio] = #Modes.[LossesRatio]
	from #Modes, UnitModes 
	where 
		(#Modes.ID = UnitModes.ID) and 
		(#Modes.UnitID = UnitModes.UnitID)
	
	insert into UnitModes ([UnitID], [OrderID], [Name], [LossesRatio])
	select @UnitID, M.[OrderID], M.[Name], M.[LossesRatio]
	from #Modes M
	where M.ID = 0;		

	/* 	
	<Products>
		<Item ID="0" ModeID="1" OrderID="1" ProductID="1" Ratio="10"/>
	</Products>
	*/
	declare @docProducts int;
	exec sp_xml_preparedocument @docProducts OUTPUT, @ProductsXML;

	select ID, UnitID, ModeID, OrderID, ProductID, Ratio 
	into #Products
	from openxml(@docProducts, '/Products/Item', 1)
	with (ID int, UnitID int, ModeID int, OrderID tinyint, ProductID int, Ratio int)

	exec sp_xml_removedocument @docProducts

	delete from ModeProducts 
	where 
		(UnitID = @UnitID) and
		(ModeID not in (select ID from UnitModes where UnitID = @UnitID)) and 
		(ID not in (select ID from #Products));

	update ModeProducts 
	set
		ModeProducts.[OrderID] = #Products.[OrderID], 
		ModeProducts.[ProductID] = #Products.[ProductID],
	    ModeProducts.[Ratio] = #Products.[Ratio]
	from #Products, ModeProducts 
	where 
		(#Products.ID = ModeProducts.ID) and 
		(#Products.UnitID = ModeProducts.UnitID)
		
	insert into ModeProducts ([UnitID], [ModeID], [OrderID], [ProductID], [Ratio])
	select @UnitID, UM.ID, P.OrderID, P.ProductID, P.Ratio
	from #Products P
	left join UnitModes UM on (P.ModeID = UM.OrderID) and (UM.UnitID = @UnitID)
	where P.ID = 0;	

	COMMIT TRANSACTION

	select @UnitID as ID;

END
GO

