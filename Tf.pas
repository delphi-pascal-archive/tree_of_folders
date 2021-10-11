unit Tf;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, StdCtrls;

type
  TForm1 = class(TForm)
    TreeView1: TTreeView;
    procedure TreeView1Expanding(Sender: TObject; Node: TTreeNode;
      var AllowExpansion: Boolean);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}
{$R FileCtrl}

procedure NextLevel(ParentNode: TTreeNode);
 function DirectoryName(name: string): boolean;
  begin
   result:=(name<>'.') and (name<>'..');
  end;
var
 sr, srChild: TSearchRec;
 node: TTreeNode;
 path: string;
begin
 node:=ParentNode;
 path:='';
 repeat
  path:=node.Text+'\'+path;
  node:=node.Parent;
 until node=nil;
 if FindFirst(path+'*.*', faDirectory, sr)=0 then
  begin
   repeat
    if (sr.Attr and faDirectory <> 0) and DirectoryName(sr.Name)
     then
      begin
       node:=Form1.TreeView1.Items.AddChild(ParentNode, sr.Name);
       node.ImageIndex:=0;
       node.SelectedIndex:=1;
       node.HasChildren:=false;
       if FindFirst(path+sr.Name+'\*.*', faDirectory, srChild)=0
        then
         begin
          repeat
           if (srChild.Attr and faDirectory<>0)
                             and DirectoryName(srChild.Name)
           then node.HasChildren := true;
          until (FindNext(srChild) <> 0) or node.HasChildren;
        end;
       FindClose(srChild);
      end;
   until FindNext(sr) <> 0;
  end
 else ParentNode.HasChildren:=false;
 FindClose(sr);
end;


procedure TForm1.TreeView1Expanding(Sender: TObject; Node: TTreeNode;
  var AllowExpansion: Boolean);
begin
 TreeView1.Items.BeginUpdate;
 Node.DeleteChildren;
 NextLevel(Node);
 TreeView1.Items.EndUpdate;
end;


procedure TForm1.FormCreate(Sender: TObject);
const
 IconNames: array [0..6] of string = ('CLOSEDFOLDER', 'OPENFOLDER',
    'FLOPPY', 'HARD', 'NETWORK', 'CDROM', 'RAM');
var
 c: char;
 s: string;
 Node: TTreeNode;
 DriveType: integer;
 bm, mask: TBitmap;
 i: integer;
begin
 TreeView1.Items.BeginUpdate;
 TreeView1.Images:=TImageList.CreateSize(16, 16);
 bm:=TBitmap.Create;
 mask:=TBitmap.Create;
 for i:=low(IconNames) to high(IconNames) do
  begin
   bm.Handle:=LoadBitmap(HInstance, PChar(IconNames[i]));
   bm.Width:=16;
   bm.Height:=16;
   mask.Assign(bm);
   mask.Mask(clBlue);
   TreeView1.Images.Add(bm, mask);
  end;
 for c:='A' to 'Z' do
  begin
   s:=c+':';
   DriveType:=GetDriveType(PChar(s));
   if DriveType=1 then continue;
   node:=Form1.TreeView1.Items.AddChild(nil, s);
   case DriveType of
    DRIVE_REMOVABLE: node.ImageIndex:=2;
    DRIVE_FIXED: node.ImageIndex:=3;
    DRIVE_REMOTE: node.ImageIndex:=4;
    DRIVE_CDROM: node.ImageIndex:=5;
    else node.ImageIndex:=6;
   end;
   node.SelectedIndex:=node.ImageIndex;
   node.HasChildren:=true;
  end;
 TreeView1.Items.EndUpdate;
end;

end.
