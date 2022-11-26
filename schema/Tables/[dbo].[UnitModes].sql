CREATE TABLE [dbo].[UnitModes](
	[ID] [smallint] IDENTITY(1,1) NOT NULL,
	[UnitID] [smallint] NULL,
	[OrderID] [tinyint] NULL,
	[Name] [nvarchar] (100) NULL,
	[LossesRatio] [smallint] NULL
)
GO

CREATE UNIQUE CLUSTERED INDEX [PK_UnitModes] ON [dbo].[UnitModes]
(
	[ID] ASC
) ON [PRIMARY]
GO

