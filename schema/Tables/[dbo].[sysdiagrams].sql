CREATE TABLE [dbo].[sysdiagrams](
	[name] [sysname] NOT NULL,
	[principal_id] [int] NOT NULL,
	[diagram_id] [int] IDENTITY(1,1) NOT NULL,
	[version] [int] NULL,
	[definition] [varbinary] (max) NULL
)
GO

CREATE UNIQUE CLUSTERED INDEX [PK__sysdiagr__C2B05B61519D9A30] ON [dbo].[sysdiagrams]
(
	[diagram_id] ASC
) ON [PRIMARY]
GO

CREATE UNIQUE NONCLUSTERED INDEX [UK_principal_name] ON [dbo].[sysdiagrams]
(
	[principal_id] ASC,
	[name] ASC
) ON [PRIMARY]
GO

