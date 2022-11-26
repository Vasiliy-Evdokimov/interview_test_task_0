CREATE TABLE [dbo].[ProductsGroups](
	[ID] [smallint] IDENTITY(1,1) NOT NULL,
	[Code] [smallint] NULL,
	[Name] [nvarchar] (100) NULL,
	[Enabled] [bit] NULL
)
GO

CREATE UNIQUE CLUSTERED INDEX [PK_ProductsGroups] ON [dbo].[ProductsGroups]
(
	[ID] ASC
) ON [PRIMARY]
GO

