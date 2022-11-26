CREATE TABLE [dbo].[Units](
	[ID] [smallint] IDENTITY(1,1) NOT NULL,
	[Code] [int] NULL,
	[Name] [nvarchar] (100) NULL,
	[MaxVolume] [int] NULL,
	[Enabled] [bit] NULL
)
GO

CREATE UNIQUE CLUSTERED INDEX [PK_Units] ON [dbo].[Units]
(
	[ID] ASC
) ON [PRIMARY]
GO

