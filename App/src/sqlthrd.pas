unit sqlthrd;

interface

uses
	Windows, Classes, SysUtils, ADODB, ActiveX, StrUtils;

const
	SQL_LOCAL_SERVER = '(local)';
  SQL_DATE_FORMAT = 'yyyymmdd';
  SQL_DATETIME_FORMAT = 'yyyymmdd hh:nn:ss';

type
	PSQLConnectionParams = ^TSQLConnectionParams;
	TSQLConnectionParams = record
		Server: string;
		DatabaseName: string;
		User: string;
		Password: string;
		ConnectionTimeout: integer;
		CommandTimeout: integer;
		ConnectionString: string;
	end;

  TSQLDataSet = TADODataSet;

	TSQLCommand = class;
	TOnSQLCommandComplete = procedure (Command: TSQLCommand; DS: TSQLDataSet) of object;
	TOnSQLState = procedure (Command: TSQLCommand) of object;

	TCommandType = (ctDataSet,ctCommand);

	TSQLCommand = class(TObject)
	public
		CommandType: TCommandType;
		Command: string;
		Error: string;
		Successful: boolean;
		Description: string;
		ExecuteTime: integer;
		OnSQLCommandComplete: TOnSQLCommandComplete;
	end;

	TSQLThread = class(TThread)
	private
		adoConnection: TadoConnection;
		adoDataSet: TadoDataSet;
		adoCommand: TadoCommand;

		FConnectionParams: TSQLConnectionParams;

		FCommands: TList;
    csCommands: _RTL_CRITICAL_SECTION;
		SQLCommand: TSQLCommand;

		FOnSQLState: TOnSQLState;
		FOnSQLBeforeExec: TOnSQLState;

		procedure AfterConstruction; override;
		procedure BeforeDestruction; override;
		procedure DoExecuted;
		procedure DoBeforeExec;
		function ExecSQLCommand(SQLCommand: TSQLCommand): boolean;
		function SQLConnect: boolean;
    function GetSQLErrors(cnn: TADOConnection): string;
		function MakeConnectionString(Params: PSQLConnectionParams): string;
	protected
		procedure Execute; override;
	public
		State: record
			Connected: boolean;
			Good: longword;
			Bad: longword;
			Error: string;
			QueueSize: integer;
			TotalTime: longword;
		end;

		procedure SetConnectionParams(Params: PSQLConnectionParams);
		function CheckConnection(Params: PSQLConnectionParams; var Error: string): boolean;
		function Connect: boolean;
		procedure Disconnect;
		procedure Add(const Command: string; const Description: string;
      CommandType: TCommandType; SQLDataSetReady: TOnSQLCommandComplete);

		property OnSQLState: TOnSQLState read FOnSQLState write FOnSQLState;
		property OnSQLBeforeExec: TOnSQLState read FOnSQLBeforeExec write FOnSQLBeforeExec;
	end;

implementation

{ TSQLThread }

procedure TSQLThread.AfterConstruction;
begin
  InitializeCriticalSection(csCommands);
	FCommands:=TList.Create;

	State.Connected:=false;
	State.Good:=0;
	State.Bad:=0;
	State.Error:='OK';
	State.QueueSize:=0;
	State.TotalTime:=0;

	FConnectionParams.ConnectionString:='Provider=MSDAOSP.1;Persist Security Info=False';
	FConnectionParams.ConnectionTimeout:=15;
	FConnectionParams.CommandTimeout:=30;

	adoConnection:=TadoConnection.Create(nil);
	adoConnection.ConnectionString:=FConnectionParams.ConnectionString;
	adoConnection.ConnectionTimeout:=FConnectionParams.ConnectionTimeout;
	adoConnection.CommandTimeout:=FConnectionParams.CommandTimeout;
	adoConnection.LoginPrompt:=false;

	adoDataSet:=TadoDataSet.Create(nil);
	adoDataSet.Connection:=adoConnection;
	adoDataSet.CommandTimeout:=FConnectionParams.CommandTimeout;

	adoCommand:=TadoCommand.Create(nil);
	adoCommand.Connection:=adoConnection;
	adoCommand.CommandTimeout:=FConnectionParams.CommandTimeout;
end;

procedure TSQLThread.BeforeDestruction;
begin
  EnterCriticalSection(csCommands);
	while FCommands.Count>0 do
	begin
		TSQLCommand(FCommands[0]).Free;
		FCommands.Delete(0);
	end;
	FCommands.Free;
  LeaveCriticalSection(csCommands);

  DeleteCriticalSection(csCommands);
	
	if adoDataSet.Active then adoDataSet.Active:=false;
	adoDataSet.Free;
	adoCommand.Free;
	adoConnection.Free;
end;

procedure TSQLThread.DoExecuted;
begin
	if Assigned(FOnSQLState) then FOnSQLState(SQLCommand);

	if Assigned(SQLCommand.OnSQLCommandComplete)then
	begin
		if SQLCommand.CommandType=ctDataSet
			then SQLCommand.OnSQLCommandComplete(SQLCommand, adoDataSet)
			else SQLCommand.OnSQLCommandComplete(SQLCommand, nil);
	end;
end;

procedure TSQLThread.Execute;
begin
	ActiveX.CoInitialize(nil);

	while not Terminated do
	begin
		while not Terminated and (FCommands.Count>0) do
		begin
      EnterCriticalSection(csCommands);
			SQLCommand:=FCommands[0];
			FCommands.Delete(0);
      LeaveCriticalSection(csCommands);

			Synchronize(DoBeforeExec);

			if not ExecSQLCommand(SQLCommand) then
			begin
				try inc(State.Bad); except State.Bad:=0; end;
			end;

			try inc(State.Good); except State.Good:=0; end;

			SQLCommand.Error:=State.Error;
			State.QueueSize:=FCommands.Count;
			try
				State.TotalTime:=State.TotalTime+SQLCommand.ExecuteTime;
			except
				State.TotalTime:=0;
			end;

			Synchronize(DoExecuted);
			if adoDataSet.Active then adoDataSet.Close;
			SQLCommand.Free;
		end;
		if not Terminated then Suspend;
	end;

  ActiveX.CoUninitialize;
end;

function TSQLThread.ExecSQLCommand(SQLCommand: TSQLCommand):boolean;
begin
	Result:=false;
	if SQLConnect then
	begin
		if SQLCommand.CommandType = ctDataSet then
		begin
			adoDataSet.Parameters.Clear;
			adoDataSet.CommandText:=SQLCommand.Command;
			SQLCommand.ExecuteTime:=GetTickCount;
			try
				adoDataSet.Active:=true;
			except
				SQLCommand.ExecuteTime:=GetTickCount-SQLCommand.ExecuteTime;
        State.Error:=GetSQLErrors(adoConnection);
				Disconnect;
				exit;
			end;
			SQLCommand.ExecuteTime:=GetTickCount-SQLCommand.ExecuteTime;
		end else
		if SQLCommand.CommandType=ctCommand then
		begin
			adoCommand.Parameters.Clear;
			adoCommand.CommandText:=SQLCommand.Command;
			SQLCommand.ExecuteTime:=GetTickCount;
			try
				adoCommand.Execute;
			except
				SQLCommand.ExecuteTime:=GetTickCount-SQLCommand.ExecuteTime;
        State.Error:=GetSQLErrors(adoConnection);
				Disconnect;
				exit;
			end;
			SQLCommand.ExecuteTime:=GetTickCount-SQLCommand.ExecuteTime;
		end;
		
		SQLCommand.Successful:=true;
		State.Error:='OK';
		Result:=true;
	end;
end;

function TSQLThread.SQLConnect:boolean;
begin
	if adoConnection.ConnectionString<>FConnectionParams.ConnectionString then
	begin
		if adoConnection.Connected then adoConnection.Connected:=false;
		adoConnection.ConnectionString:=FConnectionParams.ConnectionString;
	end;

	if adoConnection.ConnectionTimeout<>FConnectionParams.ConnectionTimeout then
	begin
		adoConnection.ConnectionTimeout:=FConnectionParams.ConnectionTimeout;
	end;

	if adoConnection.CommandTimeout<>FConnectionParams.CommandTimeout then
	begin
		adoConnection.CommandTimeout:=FConnectionParams.CommandTimeout;
		adoDataSet.CommandTimeout:=FConnectionParams.CommandTimeout;
		adoCommand.CommandTimeout:=FConnectionParams.CommandTimeout;
	end;

	if not adoConnection.Connected then
	begin
		try
			adoConnection.Connected:=true;
			FConnectionParams.ConnectionString:=adoConnection.ConnectionString;
		except
      State.Error:=GetSQLErrors(adoConnection);
		end;
	end;

	State.Connected:=adoConnection.Connected;
	Result:=adoConnection.Connected;
end;

function TSQLThread.Connect: boolean;
begin
	Result:=SQLConnect;
end;

procedure TSQLThread.Disconnect;
begin
	adoConnection.Connected:=false;
	State.Connected:=false;
end;

procedure TSQLThread.DoBeforeExec;
begin
	if Assigned(FOnSQLBeforeExec) then FOnSQLBeforeExec(SQLCommand);
end;

procedure TSQLThread.Add(const Command, Description: string;
  CommandType: TCommandType; SQLDataSetReady: TOnSQLCommandComplete);
var SQLCommand:TSQLCommand;
begin
  if Terminated then exit;

//LogDebug.Add('sql: '+Command);

	SQLCommand:=TSQLCommand.Create;
	SQLCommand.Command:=Command;
	SQLCommand.Description:=Description;
	SQLCommand.CommandType:=CommandType;
	SQLCommand.Error:='OK';
	SQLCommand.Successful:=false;
	SQLCommand.ExecuteTime:=0;
	SQLCommand.OnSQLCommandComplete:=SQLDataSetReady;

  EnterCriticalSection(csCommands);
	FCommands.Add(SQLCommand);
  LeaveCriticalSection(csCommands);

	State.QueueSize:=FCommands.Count;
	if Suspended then Resume;
end;

procedure TSQLThread.SetConnectionParams(Params: PSQLConnectionParams);
begin
	FConnectionParams:=Params^;
	FConnectionParams.ConnectionString:=MakeConnectionString(@FConnectionParams);
end;

function TSQLThread.MakeConnectionString(Params: PSQLConnectionParams): string;
begin
	Result:='Provider=SQLOLEDB.1;'+
		'Persist Security Info=True;'+
		'Data Source='+AnsiQuotedStr(Params^.Server,'"')+';'+
		'Initial Catalog='+AnsiQuotedStr(Params^.DatabaseName,'"')+';'+
		'User ID='+AnsiQuotedStr(Params^.User,'"')+';'+
		'Password='+AnsiQuotedStr(Params^.Password,'"')+';';
end;

function TSQLThread.CheckConnection(Params: PSQLConnectionParams; var Error: string): boolean;
var cnn: TADOConnection;
begin
	Error:='';
	Result:=true;

	cnn:=TADOConnection.Create(nil);
	cnn.ConnectionString:=MakeConnectionString(Params);
	cnn.ConnectionTimeout:=Params^.ConnectionTimeout;
	cnn.LoginPrompt:=false;

	try
		cnn.Connected:=true;
		cnn.Connected:=false;
	except
    Error:=GetSQLErrors(cnn);
		Result:=false;
	end;

	cnn.Free;
	cnn:=nil;
end;

function TSQLThread.GetSQLErrors(cnn: TADOConnection): string;
var i: integer;
begin
	Result:='';
	for i:=0 to cnn.Errors.Count-1 do
	begin
		if i > 0 then Result:=Result+#13#10;
		Result:=Result+cnn.Errors[i].Description;
	end;
end;

end.
