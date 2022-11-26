CREATE TABLE [dbo].[ModeProducts](
	[ID] [smallint] IDENTITY(1,1) NOT NULL,
	[UnitID] [smallint] NULL,
	[ModeID] [smallint] NULL,
	[OrderID] [tinyint] NULL,
	[ProductID] [smallint] NULL,
	[Ratio] [smallint] NULL
)
GO

CREATE UNIQUE CLUSTERED INDEX [PK_ModeProducts] ON [dbo].[ModeProducts]
(
	[ID] ASC
) ON [PRIMARY]
GO

