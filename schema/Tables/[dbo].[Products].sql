CREATE TABLE [dbo].[Products](
	[ID] [smallint] IDENTITY(1,1) NOT NULL,
	[Code] [smallint] NULL,
	[Name] [nvarchar] (100) NULL,
	[GroupID] [smallint] NULL,
	[Enabled] [bit] NULL
)
GO

CREATE UNIQUE CLUSTERED INDEX [PK_Products] ON [dbo].[Products]
(
	[ID] ASC
) ON [PRIMARY]
GO

