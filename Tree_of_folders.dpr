program Tree_of_folders;

uses
  Forms,
  Tf in 'Tf.pas' {Form1};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
