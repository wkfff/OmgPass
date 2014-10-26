unit Logic;
interface

uses Windows, Messages, SysUtils, Variants,TypInfo, Classes, Graphics, Controls,
  StdCtrls, Forms, ImgList, Menus, ComCtrls, ExtCtrls, ToolWin, ClipBrd, Vcl.Buttons,
	{XML}
	Xml.xmldom, Xml.XMLIntf, Xml.Win.msxmldom, Xml.XMLDoc,
	{MyUnits}
    XMLutils, uFieldFrame, uFolderFrame, uFolderFrameInfo,
    uSmartMethods, uSettings,
    {Themes}
    Styles, Themes
  	;
const
	bShowLogAtStart: Boolean = True;
var
	xmlMain: IXMLDocument;          //�������� ��� ��������
    xmlCfg: TSettings;
    LogList: TStringList;           //���������� ��� �����������
	PageList: IXMLNodeList;      	//������ �������
    intCurrentPage: Integer;    	//������� ���������
    intThemeIndex: Integer;         //����� ��������� ����
    intExpandFlag: Integer;    	    //��������� ���������
    								//0 - ���������� ������
                                    //1 - �������� ��������
    iSelected: Integer;             //���� ������ � ���
    bSearchMode: Boolean;           //����� ������
	bLogDocked: Boolean;            //����������� �� ��� � ��������� ������
    DragGhostNode: TTreeNode;       //���������� ����
//    strCurrentBase: String;
    bShowPasswords: Boolean;        //���������� ����������
    bWindowsOnTop: Boolean;          //��� ����
    intTickToExpand: Integer;       //  \
    oldNode: TTreeNode;             //  }�������������� ����� ��� ��������������
    nodeToExpand: TTreeNode;        // /
    lsStoredDocs: TStringList;      //������ ����� ������������� ������

procedure Log(Val: Integer); overload;
procedure Log(Text: String); overload;
procedure Log(Flag: Boolean); overload;
procedure Log(Text: String; Val: variant); overload;
procedure Log(Strs: TStrings); overload;

function InitGlobal: Boolean;
function LoadBase: Boolean;
function CheckVersion: Boolean;
function CheckUpdates: Boolean;
procedure LoadSettings;
procedure SaveSettings;
procedure LoadThemes;
procedure SetTheme(Theme: String);
procedure ClearClipboard;
procedure SetButtonImg(Button: TSpeedButton; List: TImageList; ImgIndex: Integer);
function GeneratePanel(nItem: IXMLNode; Panel: TWinControl; IsEdit: Boolean = False; IsNew: Boolean = False) : Boolean;
function CleaningPanel(Panel: TWinControl; realCln: Boolean=True): Boolean;
function GenerateField(nField: IXMLNode; Panel: TWinControl; IsEdit: Boolean = False; isNew: Boolean = False) : TFieldFrame;
procedure GenerateFolderPanel(nItem: IXMLNode; Panel: TWinControl);
function ParsePagesToTabs(x:IXMLDocument; tabControl: TTabControl) : IXMLNodeList;
procedure ParsePageToTree(pageIndex: Integer; Tree: TTreeView; SearchStr: String = '');
procedure IterateNodesToTree(xn: IXMLNode; ParentNode: TTreeNode; Tree: TTreeView; SearchStr: String = '');
procedure InsertFolder(treeNode: TTreeNode);
procedure EditNode(treeNode: TTreeNode);
function EditItem(var Node: IXMLNode; isNew: Boolean = False): Boolean;
procedure EditDefaultItem;
function EditField(var Node: IXMLNode; isNew: Boolean = False): Boolean;
procedure EditNodeTitle(Node: IXMLNode; Title: String);
procedure DeleteNode(treeNode: TTreeNode; withoutConfirm: Boolean= False);
procedure AddPage();
function CreateClearPage(): IXMLNode;
procedure InsertItem(treeNode: TTreeNode);
procedure SetNodeExpanded(treeNode: TTreeNode);
function GetNodeExpanded(Node: IXMLNode): Boolean;
function GeneratePassword(Len: Integer = 8): String;
procedure DragAndDrop(trgTreeNode: TTreeNode; selTreeNode:  TTreeNode; isCopy: Boolean = False);
procedure DragAndDropVisual(trgTreeNode: TTreeNode; selTreeNode:  TTreeNode);
procedure IterateTree(ParentNode: TTreeNode; Data: Pointer);
procedure CloneNode(treeNode: TTreeNode);
procedure ShowPasswords(Flag: Boolean);
procedure WindowsOnTop(Flag: Boolean; Form: TForm);
function GetFolderInformation(Node: IXMLNode): String;
function CreateNewField(fFmt: eFieldFormat = ffNone; Value: String = ''): IXMLNode;
function ErrorMsg(e: Exception; Method: String = ''; isFatal: Boolean = False): Boolean;
procedure CreateNewBase(x:IXMLDocument; fPath: String);
function IsDocValidate: Boolean;
function GetDocProperty(PropertyName: String; DefValue: Variant): Variant;
function SetDocProperty(PropertyName: String; Value: Variant): Boolean;
function LoadStoredDocs(): TStringList;
procedure ReloadStoredDocs(newFile: String = '');
function SaveStoredDocs: Boolean;


implementation
uses uMain, uLog, uEditItem, uEditField, uGenerator, uAccounts, uStrings;

function GeneratePassword(Len: Integer = 8): String;
begin
   if (not Assigned(frmGenerator)) then frmGenerator:=  TfrmGenerator.Create(nil);
   frmGenerator.UpDown.Position:=Len;
   frmGenerator.btnGenerateClick(nil);
   Result:= frmGenerator.lblResult.Caption;
   FreeAndNil(frmGenerator);
end;
procedure Log(Text: String);
begin
	LogList.Add({TimeToStr(Now) +}'> '+ Text);
    if Assigned(frmLog) then begin
	    frmLog.lbLog.Items.Add({TimeToStr(Now) +}'> '+ Text);
    	frmLog.lbLog.ItemIndex:=frmLog.lbLog.Items.Count-1;
        frmLog.StatusBar1.Panels[1].Text:= 'Lines Count: ' + IntToStr(LogList.Count);
    end;
end;
procedure Log(Val: Integer);
begin
	Log(IntToStr(Val));
end;
procedure Log(Flag: Boolean);
begin
    if Flag then Log('True') else Log('False');
end;
procedure Log(Strs: TStrings);
begin
    LogList.AddStrings(Strs);
    if Assigned(frmLog) then begin
	    frmLog.lbLog.Items.AddStrings(Strs);
    	frmLog.lbLog.ItemIndex:=frmLog.lbLog.Items.Count-1;
        frmLog.StatusBar1.Panels[1].Text:= 'Lines Count: ' + IntToStr(LogList.Count);
    end;
end;
procedure Log(Text: String; Val: variant);
begin
	Log(Text + ' ' + VarToStr(Val));
end;
function CleaningPanel(Panel: TWinControl; realCln: Boolean=True): Boolean;
//������� ��������
var
	i: Integer;
begin
	if realCln then
	    while Panel.ControlCount <> 0 do
    		Panel.Controls[0].Destroy
    else
		for i := 0 to Panel.ControlCount - 1 do
			Panel.Controls[i].Visible:=False;
    result:=true;
    Log('ClearPanel(' + Panel.Name + ') =', result);
end;
procedure SetButtonImg(Button: TSpeedButton; List: TImageList; ImgIndex: Integer);
begin
    if Button is TSpeedButton then begin
        List.GetBitmap(ImgIndex, TSpeedButton(Button).Glyph);
    end;
end;
function GeneratePanel(nItem: IXMLNode; Panel: TWinControl; IsEdit: Boolean = False; IsNew: Boolean = False) : Boolean;
//������ �������� � ������ � �� �����, ������ �����!
//������ ���� �������� ���� ������� ntItem c ������ Field
var i: Integer;
begin
//����
	Log('Start: GeneratePanel(' + GetNodeTitle(nItem) + ' in ' + Panel.Name +')');
    Log('IsEdit', isEdit);
    LogNodeInfo(nItem, 'GeneratePanel');


    //������ ����� � �����������
    //����� ��������� �������
    SendMessage(Panel.Handle, WM_SETREDRAW, Ord(False), 0);
    Panel.Visible:=False;
    //LockWindowUpdate(Panel.Handle);

    //������ ��������
    CleaningPanel(Panel);
    case GetNodeType(nItem) of
        ntFolder, ntPage: begin
            GenerateFolderPanel(nItem, Panel);
        end;
        ntItem, ntDefItem: begin
            //� ��������� ���� �� �����
            for i := nItem.ChildNodes.Count -1 downto 0 do
                GenerateField(nItem.ChildNodes[i], Panel, IsEdit, IsNew);
            //��������� TabOrder
            if isEdit then
                for i := Panel.ControlCount - 1 downto 0 do begin
                    TFieldFrame(Panel.Controls[i]).TabOrder:= Panel.ControlCount - 1 - i;
                    log('TabOrder: ' + TFieldFrame(Panel.Controls[i]).lblTitle.Caption + ' set to ',  TFieldFrame(Panel.Controls[i]).TabOrder);
                end;
        end;
    end;
    //
    Panel.Visible:=True;
    SendMessage(Panel.Handle, WM_SETREDRAW, Ord(True), 0);
    //LockWindowUpdate(0);
    Result:=True;
end;
function GenerateField(nField: IXMLNode; Panel: TWinControl; IsEdit: Boolean = False; IsNew: Boolean = False) : TFieldFrame;
//������ ��������� ���� � ��������,
//� ���� ������ ���� ������ ���� (ntField)
var
	fieldFormat: eFieldFormat;
begin
	//Log('--------------------GenerateField:Start');
    //LogNodeInfo(nField, 'GenerateField');
    fieldFormat:= GetFieldFormat(nField);
    Result:= TFieldFrame.CreateParented(Panel.Handle{, isEdit});
	With Result do begin
		Parent:=Panel;
        Align:=alTop;
        //��������� �����
        lblTitle.Caption:=GetNodeTitle(nField);
//        chkTitle.Caption:=lblTitle.Caption;
        //��������� �����, � ������������ ���� ���� � ������� ��������� ������
        if fieldFormat = ffComment then begin
            textInfo.AutoSize:=False;
            textInfo.Height:=62;
            textInfo.BevelEdges:=[beTop];
//            textInfo.BevelKind:= bkNone;
            textInfo.Multiline:=True;
			textInfo{.Lines}.Text:=
                StringReplace(VarToStr(nField.NodeValue),'|',#13#10,[rfReplaceAll]);
        end else
            textInfo{.Lines}.Text:=VarToStr(nField.NodeValue);
        //����������� ������ ��� ��������������
        textInfo.ReadOnly:=not IsEdit;
        //������������ ����������
		btnSmart.Tag:=NativeInt(textInfo);		        //������ ��������� �� ��������� ����
        btnAdditional.Tag:=NativeInt(textInfo);
		textInfo.Tag:=NativeInt(nField);                //����� � ����� ��������� �� ����
		Tag:=NativeInt(nField);
        //������ ��������� ��� �������������� � ������� ������
        if IsEdit=False then begin
            //�������� ��� ������ ������
            if (fieldFormat = ffPass) then
                if bShowPasswords then
                    textInfo.PasswordChar:=#0
                else
                    textInfo.PasswordChar:=#149;
            //��� ��������� ������ ��� ����������� �� �����������
            if LowerCase(GetAttribute(nField, 'button')) = 'false' then
                btnSmart.Enabled:=false
            else
                case fieldFormat of
                ffWeb: begin
                    btnSmart.OnClick:= clsSmartMethods.Create.OpenURL;
                    SetButtonImg(btnSmart, frmMain.imlField, 1);
                end;
                ffMail: begin
                    btnSmart.OnClick:= clsSmartMethods.Create.OpenMail;
                    SetButtonImg(btnSmart, frmMain.imlField, 2);
                end;
                ffFile: begin
                    btnSmart.OnClick:= clsSmartMethods.Create.AttachedFile;
                    SetButtonImg(btnSmart, frmMain.imlField, 3);
                end;
                else begin
                    btnSmart.OnClick:= clsSmartMethods.Create.CopyToClipboard;
                    SetButtonImg(btnSmart, frmMain.imlField, 0);
                end; //case
            end; //if
            textInfo.Enabled:=False;
            //EnableWindow(textInfo.Handle, False);
            //DisableTextFrame;
        end else begin                                 //����� ��������������
        	case fieldFormat of
                ffPass: begin
        			btnAdditional.Visible:=True;
            		OnResize(nil);
                    btnAdditional.OnClick:= clsSmartMethods.Create.GeneratePass;
                    SetButtonImg(btnAdditional, frmMain.imlField, 5);
                    if isNew then textInfo.Text:=GeneratePassword;
                end;
                ffTitle: lblTitle.Font.Style:=[fsBold];
            end;
        SetButtonImg(btnSmart, frmMain.imlField, 4);
        //btnSmart.OnClick:= clsSmartMethods.Create.EditField;
        //���������� ���� �����
        btnSmart.OnClick:= frmEditItem.StartEditField;
        end;
    end;
    //Log('--------------------GenerateField:End');
end;
procedure GenerateFolderPanel(nItem: IXMLNode; Panel: TWinControl);
begin
if (GetNodeType(nItem) = ntPage) then
    with TFolderFrame.CreateParented(Panel.Handle) do begin
        Parent:=Panel;
        Align:=alTop;
        Tag:=NativeInt(nItem);
    end;
    with TFolderFrameInfo.CreateParented(Panel.Handle) do begin
    Align:=alTop;
        Parent:=Panel;
        lblInfo.Caption:=GetFolderInformation(nItem);
    end;
end;
function ParsePagesToTabs(x:IXMLDocument; tabControl: TTabControl) : IXMLNodeList;
var i: Integer;
tabList: TStringList;
begin
	Log('--------------------ParsePagesToTabs:Start');
    xmlMain.Active:=False;
	xmlMain.Active:=True;
    intExpandFlag:=1;
    tabList:=TStringList.Create;
	tabControl.Tabs.Clear;
	PageList:= NodeByPath(x, 'Root|Data').ChildNodes;
    tabControl.Visible:= (PageList.Count<>0);

    for i := 0 to PageList.Count - 1 do begin
		LogNodeInfo(PageList[i]);
		tabList.Add(GetNodeTitle(PageList[i]));
    end;
    tabControl.Tabs:=tabList;
    if intCurrentPage < tabControl.Tabs.Count then
    	tabControl.TabIndex:=intCurrentPage
    else
       	tabControl.TabIndex:=tabControl.Tabs.Count - 1;
    //frmMain.btnAddPage.Left:=tabControl.TabRect(tabControl.Tabs.Count-1).Width + tabControl.TabRect(tabControl.Tabs.Count-1).Left + 3;
    intExpandFlag:=0;
    Log('--------------------ParsePagesToTabs:End');
end;
procedure ParsePageToTree(pageIndex: Integer; Tree: TTreeView; SearchStr: String = '');
var RootNode: TTreeNode;
begin
	Log('--------------------ParsePageToTree:Start---------------------------');
    if PageList.Count = 0 then begin
        Log('Warning! There is no pages in document');
        Exit;
    end;
    intExpandFlag:=1;
	Tree.Items.Clear;
    RootNode:=Tree.Items.AddChild(nil, GetNodeTitle(PageList[pageIndex]));
    RootNode.ImageIndex:=2;
    RootNode.SelectedIndex:=2;
    RootNode.Data:=Pointer(PageList[pageIndex]);
    Tree.Items.BeginUpdate;
	IterateNodesToTree(PageList[pageIndex], RootNode, Tree, SearchStr);
    Tree.Items.EndUpdate;
    RootNode.Expand(False);
    intCurrentPage:= pageIndex;
    intExpandFlag:=0;
    Log('--------------------ParsePageToTree:End-----------------------------');
end;
procedure IterateNodesToTree(xn: IXMLNode; ParentNode: TTreeNode; Tree: TTreeView; SearchStr: String = '');
var
	ChildTreeNode: TTreeNode;
   	i: Integer;
begin
	Log('--------------------IterateNodesToTree:Start');
    LogNodeInfo(xn);
    For i := 0 to xn.ChildNodes.Count - 1 do
    if (GetNodeType(xn.ChildNodes[i]) = ntFolder) or
       (GetNodeType(xn.ChildNodes[i]) = ntItem) then begin
        ChildTreeNode := Tree.Items.AddChild(ParentNode, GetNodeTitle(xn.ChildNodes[i]));
        ChildTreeNode.Data:=Pointer(xn.ChildNodes[i]);
        IterateNodesToTree(xn.ChildNodes[i], ChildTreeNode, Tree, SearchStr);
        Case GetNodeType(xn.ChildNodes[i]) of
            ntItem: begin
                ChildTreeNode.ImageIndex:=1;
                ChildTreeNode.SelectedIndex:=1;
                ChildTreeNode.DropTarget:=False;
                if (Pos(LowerCase(SearchStr), LowerCase(GetNodeTitle(xn.ChildNodes[i]))) = 0) and
                    (SearchStr <> '') then
                    ChildTreeNode.Delete
                else
                    ChildTreeNode.MakeVisible;
            end;
            ntFolder: begin
                ChildTreeNode.ImageIndex:= 0;
                ChildTreeNode.SelectedIndex:= 0;
                if SearchStr = '' then
                    ChildTreeNode.Expanded:=GetNodeExpanded(xn.ChildNodes[i])
                else
                    if not ChildTreeNode.HasChildren then
                        ChildTreeNode.Delete;
            end;
        end;
    end;
    Log('--------------------IterateNodesToTree:End');
end;
procedure EditNode(treeNode: TTreeNode);
var
	trgNode: IXMLNode;
    //tmpNode: IXMLNode;
begin
	if treeNode.Data = nil then Exit;
    //���� ���� � ������ �������������� �� ������ ��������� ���������
    if TTreeView(treeNode.TreeView).IsEditing then begin
    		TTreeView(treeNode.TreeView).Selected.EndEdit(False);
            Log('EditItem: EndEdit');
            Exit;
    end;
    trgNode:= IXMLNode(treeNode.Data);
    LogNodeInfo(TrgNode, 'EditItem:Target');
	case GetNodeType(TrgNode) of
    ntItem: begin
    	if EditItem(trgNode) then begin
        	treeNode.Data:=Pointer(trgNode);
            treeNode.Text:=GetNodeTitle(trgNode);
            GeneratePanel(trgNode, frmMain.fpMain, False);
            frmMain.tvMain.Selected.Text:=GetNodeTitle(trgNode);
        end;
    end;
    ntFolder, ntPage:
    	treeNode.EditText;
    end;
end;
function EditItem(var Node: IXMLNode; isNew: Boolean = False): Boolean;
var
	//trgNode: IXMLNode;
    tmpNode: IXMLNode;
begin
	Log('EditItem, isNew=' + BoolToStr(isNew, True));
    LogNodeInfo(Node, 'EditItem:InputNode');
	tmpNode:= Node.CloneNode(True);
    LogNodeInfo(tmpNode, 'EditItem:Temp     ');
    if (not Assigned(frmEditItem)) then
        frmEditItem:= TfrmEditItem.Create(frmMain, tmpNode, isNew);
    if frmEditItem.ShowModal=mrOK then begin
        Log('frmEditItem: mrOK');
        LogNodeInfo(tmpNode, 'EditItem:OutNode  ');
        if not isNew then
            Node.ParentNode.ChildNodes.ReplaceNode(Node, tmpNode);
        Node:= tmpNode;
        Result:=True;
    end else begin
        Log('frmEditItem: mrCancel');
        Result:=False;
    end;
    FreeAndNil(frmEditItem);
end;
function EditField(var Node: IXMLNode; isNew: Boolean = False): Boolean;
var
    tmpNode: IXMLNode;
begin
	Log('EditField, isNew=' + BoolToStr(isNew, True));
    LogNodeInfo(Node, 'EditField:InputNode');
	tmpNode:= Node.CloneNode(True);
    LogNodeInfo(tmpNode, 'EditField:Temp     ');
    if (not Assigned(frmEditField)) then
        frmEditField:= TfrmEditField.Create(frmEditItem, tmpNode, isNew);
    if frmEditField.ShowModal=mrOK then begin
        Log('frmEditField: mrOK');
        LogNodeInfo(tmpNode, 'EditField:OutNode  ');
        if not isNew then
            Node.ParentNode.ChildNodes.ReplaceNode(Node, tmpNode);
        Node:= tmpNode;
        Result:=True;
    end else begin
        Log('frmEditField: mrCancel');
        Result:=False;
    end;
    FreeAndNil(frmEditField);
end;
procedure EditNodeTitle(Node: IXMLNode; Title: String);
begin
	SetNodeTitle(Node, Title);
    case GetNodeType(Node) of
    ntItem:
		GeneratePanel(Node, frmMain.fpMain);
    ntFolder:
		Exit;
    ntPage:
        frmMain.tabMain.Tabs[intCurrentPage]:=Title;
    end;
end;
procedure DeleteNode(treeNode: TTreeNode; withoutConfirm: Boolean= False);
var
	Msg: String;
    Node: IXMLNode;
begin
	Log('DeleteNode:' + treeNode.Text);
	Node:=IXMLNode(treeNode.Data);
    case GetNodeType(Node) of
    ntItem:
    	msg:='��������!' + #10#13 + '�� ������������� ������ ������� ������ ' + AnsiQuotedStr(GetNodeTitle(Node), '"') + '?';
    ntFolder:
    	msg:='��������!' + #10#13 + '�� ������������� ������ ������� ����� ' + AnsiQuotedStr(GetNodeTitle(Node), '"') + '?' +
        					#10#13 + '��� �������� � �������� ���� ��������� ����� � �������!';
    ntPage: begin
    	if PageList.Count = 1 then begin
        	MessageBox(Application.Handle, '������ ������� ��������� ��������!', '�������� ������', MB_ICONINFORMATION + MB_SYSTEMMODAL);
        	Exit;
        end;
    	msg:='��������!' + #10#13 + '�� ������������� ������ ������� �������� ' + AnsiQuotedStr(GetNodeTitle(Node), '"') + '?' +
        					#10#13 + '��� �������� � �������� ���� ��������� ����� � �������!!!' +
                            #10#13 + '����������?';
    	end;
    end;
    if not withoutConfirm then
    if MessageBox(Application.Handle, PWideChar(Msg), '�������� ������',
    	 MB_ICONQUESTION + MB_OKCANCEL + MB_DEFBUTTON2 + MB_SYSTEMMODAL) = ID_CANCEL then Exit;
    Log('Deleting confirmed...');
    Node.ParentNode.ChildNodes.Remove(Node);           //returns thmthng
    if GetNodeType(Node) = ntPage then begin
        ParsePagesToTabs(xmlMain, frmMain.tabMain);
        frmMain.tabMainChange(nil);
    end else treeNode.Delete;
end;
procedure AddPage();
begin
	inc(intCurrentPage);
    PageList.Insert(intCurrentPage, CreateClearPage);
    ParsePagesToTabs(xmlMain, frmMain.tabMain);
    frmMain.tabMainChange(nil);
end;
function CreateClearPage(): IXMLNode;
var
	newPageNode: IXMLNode; //okay?
    dItem: IXMLNode;       //defitem
    tField: IXMLNode;      //tempfield..okay?
begin
    newPageNode:=xmlMain.CreateNode('Page');
    newPageNode.Text:=rsNewPageTitle +'_'+ DateToStr(now);
    newPageNode.SetAttributeNS('type', '', 'page');
    dItem:= newPageNode.AddChild('DefItem');
//    dItem.SetAttributeNS('type', '' , 'defitem');
//    dItem.SetAttributeNS('picture', '' , 'item');
//    tField:= dItem.AddChild('Field');
//    tField.SetAttributeNS('name', '', '��������');
//    tField.SetAttributeNS('format', '', 'title');
    //tField.Text:='����� ������';
//    tField:= dItem.AddChild('Field');
//    tField.SetAttributeNS('name', '', '�����');
//    tField.SetAttributeNS('format', '', 'text');
//    tField:= dItem.AddChild('Field');
//    tField.SetAttributeNS('name', '', '������');
//    tField.SetAttributeNS('format', '', 'pass');
//    tField:= dItem.AddChild('Field');
//    tField.SetAttributeNS('name', '', '�����������');
//    tField.SetAttributeNS('format', '', 'comment');
//    SetNodeTitle(dItem, '����� ������');
    dItem.ChildNodes.Add(CreateNewField(ffTitle, rsNewItemTitle));
    dItem.ChildNodes.Add(CreateNewField(ffText));
    dItem.ChildNodes.Add(CreateNewField(ffPass));
    dItem.ChildNodes.Add(CreateNewField(ffWeb));
    dItem.ChildNodes.Add(CreateNewField(ffComment));
    result:=newPageNode;
    //i like spagetti
end;
procedure InsertFolder(treeNode: TTreeNode);
var
	newFolderNode: IXMLNode;
	//newTreeNode: TTreeNode;
begin
	if GetNodeType(IXMLNode(treeNode.Data))=ntItem then begin
        treeNode:=treeNode.Parent;
    end;
    newFolderNode:= IXMLNode(treeNode.Data).AddChild('Folder');
    newFolderNode.Text:= rsNewFolderTitle;
    newFolderNode.SetAttributeNS('type', '', 'folder');
    newFolderNode.SetAttributeNS('picture', '', 'folder');
    if (not treeNode.Expanded) then treeNode.Expand(False);
	With TTreeView(treeNode.TreeView).Items.AddChild(treeNode, rsNewFolderTitle) do begin
		Data:=Pointer(newFolderNode);
        ImageIndex:=0;
        SelectedIndex:=0;
        //Expanded:=True;             //���������� ��� �������� �����
        Selected:=True;
		EditText;
	end;
end;
procedure InsertItem(treeNode: TTreeNode);
var
	i: integer;
	defItem: IXMLNode;
	newItem: IXMLNode;
    destNode: IXMLNode;     //ntFolder;
    newTreeNode: TTreeNode;
begin
	destNode:=IXMLNode(treeNode.Data);
	LogNodeInfo(destNode, 'InsertItem');
	if GetNodeType(destNode) = ntItem then begin
    	destNode:=destNode.ParentNode;
        treeNode:=treeNode.Parent;
    end;
    Log(destNode.NodeName);
	defItem:=PageList[intCurrentPage].ChildNodes.FindNode('DefItem');
    //
	newItem:=destNode.OwnerDocument.CreateNode('Item');
	for i := 0 to defItem.ChildNodes.Count - 1 do
        newItem.ChildNodes.Add(defItem.ChildNodes[i].CloneNode(True));
    for i := 0 to defItem.AttributeNodes.Count - 1 do
        newItem.AttributeNodes.Add(defItem.AttributeNodes[i].CloneNode(True));
    //
    if EditItem(newItem, True) = True then begin
		destNode.ChildNodes.Add(newItem);
		if (not treeNode.Expanded) then treeNode.Expand(False);
    	newTreeNode:=TTreeView(treeNode.TreeView).Items.AddChild(treeNode, GetNodeTitle(newItem));
    	with newTreeNode do begin
            Data:= Pointer(newItem);
            ImageIndex:=1;
            SelectedIndex:=1;
            Selected:=True;
        end;
        //EditText;
    end else newItem._Release;
end;
procedure CloneNode(treeNode: TTreeNode);
var
	Node: IXMLNode;
begin
    Node:=IXMLNode(treeNode.Data);
    case GetNodeType(Node) of
    ntPage:
        Log('Page clone not realised yet...');
    ntFolder: begin
            Log('Clone folder');
            DragAndDropVisual(treeNode.Parent, treeNode);
            DragAndDrop(treeNode.Parent, treeNode, True);
        end;
    ntItem: begin
            Log('Clone item');
            {newNode:= Node.CloneNode(True);
            Node.ParentNode.ChildNodes.Insert(
            Node.ParentNode.ChildNodes.IndexOf(Node), newNode);
            newTreeNode:= TTreeView(TreeNode.TreeView).Items.Insert(
            TreeNode, TreeNode.Text);
            With newTreeNode do begin
                Data:=Pointer(newNode);
                Enabled:=True;
                ImageIndex:=treeNode.ImageIndex;
                SelectedIndex:=treeNode.SelectedIndex;
                Selected:=True;
            end;}
            DragAndDropVisual(treeNode, treeNode);
            DragAndDrop(treeNode, treeNode, True);
        end;
    end;

end;
procedure SetNodeExpanded(treeNode: TTreeNode);
begin
	if intExpandFlag <> 0 then Exit;
    if treeNode.IsFirstNode then Exit;
	SetAttribute(IXMLNode(treeNode.Data), 'expand',
                BoolToStr(treeNode.Expanded, True));
end;
function GetNodeExpanded(Node: IXMLNode): Boolean;
var
	tmp: String;
begin
	tmp:= GetAttribute(Node, 'expand');
    if tmp='' then
    	result:=False
    else
    	result:=StrToBool(tmp);
end;
procedure DragAndDrop(trgTreeNode: TTreeNode; selTreeNode:  TTreeNode; isCopy: Boolean=False);
//����� ���, ����� ����� ���� �����, �� ����� �������.
var
	selNode, trgNode, newNode: IXMLNode;
begin
    selNode:=IXMLNode(selTreeNode.Data);
	//trgNode:=IXMLNode(trgTreeNode.Data);  //���� ��� �� �����, ������ ���� � ��������
    trgNode:=IXMLNode(DragGhostNode.Data);
    newNode:= selNode.CloneNode(True);
    intExpandFlag:=1;
    case GetNodeType(trgNode) of
    ntPage, ntFolder:
    	trgNode.ChildNodes.Add(newNode);
    ntItem:
    	trgNode.ParentNode.ChildNodes.Insert(trgNode.ParentNode.ChildNodes.IndexOf(trgNode), newNode);
    end;
    if GetNodeType(newNode) <> ntItem then begin
        TTreeView(DragGhostNode.TreeView).Items.BeginUpdate;
        IterateNodesToTree(newNode, DragGhostNode, TTreeView(DragGhostNode.TreeView));
        TTreeView(DragGhostNode.TreeView).Items.EndUpdate;
    end;
    With DragGhostNode do begin
        Data:=Pointer(newNode);
        Enabled:=True;
        Selected:=True;
        Expanded:=GetNodeExpanded(newNode);
    end;
    if not isCopy then begin
        selNode.ParentNode.ChildNodes.Remove(selNode);
        selTreeNode.Delete;
    end;
    DragGhostNode:=nil;
    intExpandFlag:=0;

    //�����, ������ ��� ��������� ������������� ������
    //  IterateTree ������ �� �����... ���������� � ������...
    {Logic.ParsePageToTree(Logic.intCurrentPage, frmMain.tvMain);
	rootTreeNode:=selTreeNode.Parent;
    while rootTreeNode.Parent<> nil do rootTreeNode:=rootTreeNode.Parent;
    IterateTree(rootTreeNode, Pointer(newNode));}
end;
procedure DragAndDropVisual(trgTreeNode: TTreeNode; selTreeNode:  TTreeNode);
var
//selNode: IXMLNode;
trgNode: IXMLNode;
begin
    if trgTreeNode = DragGhostNode then Exit;
    if DragGhostNode<> nil then frmMain.tvMain.Items.Delete(DragGhostNode);
    if (selTreeNode= nil) or (trgTreeNode=nil) then Exit;
    //selNode:=IXMLNode(selTreeNode.Data);
    trgNode:=IXMLNode(trgTreeNode.Data);
    //if (selNode= nil) or (trgNode=nil) then Exit;
    case GetNodeType(trgNode) of
    ntPage, ntFolder:
        DragGhostNode:= TTreeView(trgTreeNode.TreeView).Items.AddChild(trgTreeNode, selTreeNode.Text);
    ntItem: 
        DragGhostNode:= TTreeView(trgTreeNode.TreeView).Items.Insert(trgTreeNode, selTreeNode.Text);
    end;
    DragGhostNode.Enabled:=False;
    DragGhostNode.ImageIndex:=selTreeNode.ImageIndex;
    DragGhostNode.SelectedIndex:=selTreeNode.SelectedIndex;
    //��������! � ������� �������� ��������� ������ ����, � �� ���������!
    DragGhostNode.Data:=Pointer(trgNode);
end;
procedure IterateTree(ParentNode: TTreeNode; Data: Pointer);
var
   	i: Integer;
begin
	Log('IterateTree: Start: '+ ParentNode.Text );
    For i := 0 to ParentNode.Count - 1 do
        if ParentNode.Item[i].Data = Data then
        	ParentNode.Item[i].Selected:=True
        else IterateTree(ParentNode.Item[i], Data);
    Log('IterateTree: End');
end;
procedure LoadSettings;
begin
    bShowPasswords:= xmlCfg.GetValue('ShowPasswords', True);
    bWindowsOnTop:= xmlCfg.GetValue('WindowOnTop', False);
    frmMain.mnuShowPass.Checked:= bShowPasswords;
    frmMain.mnuTop.Checked:= bWindowsOnTop;
    WindowsOnTop(bWindowsOnTop, frmMain);

    frmMain.WindowState:= xmlCfg.GetValue('Window', 0, 'Position');
    if frmMain.WindowState = wsMinimized then frmMain.WindowState:= wsNormal;
    if frmMain.WindowState = wsNormal then begin
        frmMain.SetBounds(xmlCfg.GetValue('Left', 0, 'Position'),
            xmlCfg.GetValue('Top', 0, 'Position'),
            xmlCfg.GetValue('Width', 0, 'Position'),
            xmlCfg.GetValue('Height', 0, 'Position'));
        if Boolean(xmlCfg.GetValue('ShowLog', False)) then frmMain.tbtnLogClick(nil);
    end;
    if xmlCfg.GetValue('Page', 0, 'Position') < PageList.Count then
        frmMain.tabMain.TabIndex := xmlCfg.GetValue('Page', 0, 'Position');
    //frmMain.tabMainChange(nil);
    ParsePageToTree(frmMain.tabMain.TabIndex, frmMain.tvMain);

    if GetDocProperty('Selected', 0) < frmMain.tvMain.Items.Count  then
        frmMain.tvMain.Items[GetDocProperty('Selected', 0)].Selected:=True;

    //if xmlCfg.GetValue('TreeWidth', 0, 'Position') <> 0 then
        frmMain.pnlTree.Width:= xmlCfg.GetValue('TreeWidth', 200, 'Position');
end;
procedure SaveSettings;
//��������� �� � ���� ����� ������� �� ���������
begin
    //����� ���������� �������� ����������� � ��������
    if xmlCfg = nil then Exit;
    if bSearchMode then
        SetDocProperty('Selected', iSelected)
    else if frmMain.tvMain.Selected<>nil then
        SetDocProperty('Selected', frmMain.tvMain.Selected.AbsoluteIndex);
    //������ ��������� ����������� � ���� ��������
    if frmMain.WindowState = wsNormal then begin
         xmlCfg.SetValue('Left', frmMain.Left, 'Position');
         xmlCfg.SetValue('Top', frmMain.Top, 'Position');
         xmlCfg.SetValue('Width', frmMain.Width, 'Position');
         xmlCfg.SetValue('Height', frmMain.Height, 'Position');
         xmlCfg.SetValue('ShowLog', BoolToStr(Assigned(frmLog), True));
    end;
    xmlCfg.SetValue('Window', frmMain.WindowState, 'Position');
    xmlCfg.SetValue('Page', intCurrentPage, 'Position');
    xmlCfg.SetValue('TreeWidth', frmMain.pnlTree.Width, 'Position');
    xmlCfg.SetValue('Theme', intThemeIndex);
    xmlCfg.SetValue('ShowPasswords', BoolToStr(bShowPasswords, True));
    xmlCfg.SetValue('WindowOnTop', BoolToStr(bWindowsOnTop, True));
    SaveStoredDocs;
    xmlCfg.Save;
end;
procedure LoadThemes;
var
  	i:Integer;
	newMenuItem: TmenuItem;
begin
try
With TStyleManager.Create do begin
    for i := 0 to Length(StyleNames)-1 do begin
        newMenuItem:= TMenuItem.Create(frmMain.mnuThemes);
        newMenuItem.Caption:= StyleNames[i];
        newMenuItem.RadioItem:=True;
        newMenuItem.OnClick:= frmMain.ThemeMenuClick;
        frmMain.mnuThemes.Insert(i, newMenuItem);
    end;
    if xmlCfg.GetValue('Theme', 0) < frmMain.mnuThemes.Count  then
        frmMain.mnuThemes.Items[xmlCfg.GetValue('Theme', 0)].Click;
end;
finally end;
end;
procedure SetTheme(Theme: String);
//����� ����� ����������
begin
try
    if bSearchMode then frmMain.txtSearchRightButtonClick(nil);
    TStyleManager.TrySetStyle(Theme, False);
finally end;
end;
procedure ShowPasswords(Flag: Boolean);
var
  i: Integer;
  Frame: TFieldFrame;
begin
    Log('ShowPasswords:', Flag);
    Beep;
    for i := 0 to frmMain.fpMain.ControlCount - 1 do begin
        if not (frmMain.fpMain.Controls[i] is TFieldFrame) then Continue;
        Frame:= TFieldFrame(frmMain.fpMain.Controls[i]);
        if GetFieldFormat(IXMLNode(Frame.Tag)) = ffPass then begin
            LogNodeInfo(IXMLNode(Frame.Tag), 'Found password field');
            Frame.textInfo.Visible:=False;
            if Flag then
                Frame.textInfo.PasswordChar:=#0
            else
                Frame.textInfo.PasswordChar:=#149;
            Frame.textInfo.Enabled:=False;
            Frame.textInfo.Visible:=True;
        end;
    end;
end;
procedure ClearClipboard;
begin
    Clipboard.Clear;
    Log ('Clearing clipboard');
end;
procedure WindowsOnTop(Flag: Boolean; Form: TForm);
begin
    Log('Form ' + Form.Name + ' topmost:', Flag);
    if Flag then
        SetWindowPos(Form.Handle, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOMOVE or SWP_NOSIZE or SWP_NOACTIVATE or SWP_SHOWWINDOW)
    else
        SetWindowPos(Form.Handle, HWND_NOTOPMOST, 0, 0, 0, 0, SWP_NOMOVE or SWP_NOSIZE or SWP_NOACTIVATE or SWP_SHOWWINDOW);
end;
function GetFolderInformation(Node: IXMLNode): String;
var
    FoldersCount, ItemsCount: Integer;
//���������!��������� �������!
function IterateFolders(Node: IXMLNode; Full: Boolean): Integer;
var i: Integer;
begin
    for i:= 0 to Node.ChildNodes.Count - 1 do
        if GetNodeType(Node.ChildNodes[i]) = ntFolder then begin
            inc(result);
            if Full then result:= result + IterateFolders(Node.ChildNodes[i], true);
        end;
end;

function IterateItems(Node: IXMLNode; Full: Boolean): Integer;
var i: Integer;
begin
    for i:= 0 to Node.ChildNodes.Count - 1 do begin
        if GetNodeType(Node.ChildNodes[i]) = ntItem then
            inc(result);
        if (GetNodeType(Node.ChildNodes[i]) = ntFolder) and Full then
            result:= result + IterateItems(Node.ChildNodes[i], true);
    end;
end;

begin
    result:= rsInfoTitle  + GetNodeTitle(Node) + #10#13 +
            rsInfoSubfolders + IntToStr(IterateFolders(Node, False)) + #10#13 +
            rsInfoTotalFolders + IntToStr(IterateFolders(Node, True)) + #10#13 +
            rsInfoSubItems + IntToStr(IterateItems(Node, False)) +  #10#13 +
            rsInfoTotalItems + IntToStr(IterateItems(Node, True));
end;
procedure EditDefaultItem;
var
    defItem: IXMLNode;
begin
    LogNodeInfo(PageList[intCurrentPage], 'EditDefaultItem, Page = ');
    defItem:= PageList[intCurrentPage].ChildNodes.FindNode('DefItem');
    LogNodeInfo(defItem, 'EditDefaultItem, DefItem = ');
    if EditItem(defItem) then
        Log ('EditDefaultItem: Ok') else Log ('EditDefaultItem: Cancel');
end;
function CreateNewField(fFmt: eFieldFormat = ffNone; Value: String = ''): IXMLNode;
begin
    Result:=xmlMain.CreateNode('Field');
    if fFmt = ffNone then begin
        SetAttribute(Result, 'name', arrDefFieldNames[Ord(fFmt)]);
        SetAttribute(Result, 'format', arrFieldFormats[Ord(ffText)]);
    end else begin
        SetAttribute(Result, 'name', arrDefFieldNames[Ord(fFmt)]);
        SetAttribute(Result, 'format', arrFieldFormats[Ord(fFmt)]);
    end;
    if Value <> '' then SetNodeValue(Result, Value);
end;
function CheckUpdates: Boolean;
begin
    result:=true;
end;
function CheckVersion: Boolean;
begin
    result:=true;
end;

function InitGlobal: Boolean;
//var i: Integer;
begin
	LogList:= TStringList.Create;
    xmlCfg:=TSettings.Create('..\..\config.xml');
    xmlMain:=TXMLDocument.Create(frmMain);
    lsStoredDocs:= LoadStoredDocs;

	Log('�������������...');
    //LoadThemes;
    if not LoadBase then begin
        Result:=False;
        Exit
    end;
    if not IsDocValidate then Exit;
    ReloadStoredDocs(xmlMain.FileName);

    CheckVersion;
    CheckUpdates;
    ParsePagesToTabs(xmlMain, frmMain.tabMain);
    LoadSettings;
    Result:=True;

//    SetButtonImg(btnAddPage, imlField, 10);
//    SetButtonImg(btnDeletePage, imlField, 12);
//    SetButtonImg(btnTheme, imlTab, 41);

//	frmMain.Caption:= frmMain.Caption +' ['+ GetBaseTitle(xmlMain)+']';
end;

function LoadBase: Boolean;
begin
//FreeAndNil(xmlMain);
    xmlMain.Active:=True;
    xmlMain.Options :=[doNodeAutoIndent, doAttrNull, doAutoSave];
    xmlMain.ParseOptions:=[poValidateOnParse];
if 0=1 {����� �� ������������ ����� ��� ������} then //
    else begin
        if (not Assigned(frmAccounts)) then
            frmAccounts:=  TfrmAccounts.Create(frmMain);
        try
            if frmAccounts.ShowModal = mrOK then begin
                Log ('frmAccounts: mrOK');
                if FileExists(frmAccounts.FFileName) then
                    xmlMain.LoadFromFile(frmAccounts.FFileName)
                else CreateNewBase(xmlMain, frmAccounts.FFileName);
                result:=True;
            end else begin
                Log ('frmAccounts: mrCancel');
                frmMain.WindowState:=wsMinimized;
                Result:=False;
                Exit;
            end;
        except
            on e: Exception do ErrorMsg(e, 'Load Document');
        end;
        FreeAndNil(frmAccounts);
    end;
end;
function ErrorMsg(e: Exception; Method: String = ''; isFatal: Boolean = False): Boolean;
begin
    Log('Error : ' + e.ClassName);
    if Method<>'' then Log('    Procedure: ' + Method);
    Log('    Error Message: ' + e.Message);
    Log('    Except Address: ', IntToHex(Integer(ExceptAddr), 8));
    LogList.SaveToFile('log.txt');
    if isFatal then Application.Terminate;
end;
procedure CreateNewBase(x:IXMLDocument; fPath: String);
var
    rootNode: IxmlNode;
begin
    Log('Create new base!');
    x.FileName:=fPath;
    x.Encoding := 'UTF-8';
    x.Version := '1.0';
    With x.AddChild('Root') do begin
        AddChild('Header');
        AddChild('Data');
    end;
    x.SaveToFile(fPath);
end;
function GetDocProperty(PropertyName: String; DefValue: Variant): Variant;
begin
if (xmlMain.ChildNodes[strRootNode].ChildNodes.FindNode(strHeaderNode) = nil)
or (xmlMain.ChildNodes[strRootNode].ChildNodes[strHeaderNode].ChildNodes.FindNode(PropertyName) = nil)
        then Result:=DefValue
    else Result:=xmlMain.ChildNodes[strRootNode].ChildNodes[strHeaderNode].ChildValues[PropertyName];;
end;
function SetDocProperty(PropertyName: String; Value: Variant): Boolean;
var hNode: IXMLNode;
begin
    hNode:= xmlMain.ChildNodes[strRootNode].ChildNodes.FindNode(strHeaderNode);
    if hNode = nil then
        hNode:=xmlMain.ChildNodes[strRootNode].AddChild(strHeaderNode);
    if hNode.ChildNodes.FindNode(PropertyName) = nil then
        hNode.AddChild(PropertyName);
    hNode.ChildValues[PropertyName]:=Value;
end;
function IsDocValidate: Boolean;
//�������� �� ���������� ����, ������ �������� XML
begin
    try
    if xmlMain.ChildNodes[strRootNode] <> nil then
        if xmlMain.ChildNodes[strRootNode].ChildNodes[strDataNode] <> nil then
            result:=True;
    except
        on e: Exception do ErrorMsg(e, 'Validate Document', True);
    end;
end;

function LoadStoredDocs(): TStringList;
//��������� ������ ��������� ������ �� ������� � ������
var i: Integer;
begin
    Result:=TStringList.Create;
    for i := 0 to Integer(xmlCfg.GetValue('Count', 0, 'Files')) - 1 do begin
        Result.Add(xmlCfg.GetValue('File_' + IntToStr(i), '', 'Files'));
    end;
end;
procedure ReloadStoredDocs(newFile: String);
//��������� ���� � ������ ������ ���������
//��������� ��� �� �������� ������ ���� �� ��� ��� ���
var i: Integer;
begin
    //������ ���!
//    if lsStoredDocs.Find(newFile, i) then lsStoredDocs.Delete(i);
    for i := lsStoredDocs.Count - 1 downto 0 do begin
        if lsStoredDocs.Strings[i] = newFile then
            lsStoredDocs.Delete(i);
    end;
    lsStoredDocs.Insert(0, newFile);
end;
function SaveStoredDocs: Boolean;
//��������� ������ ������ � ������
var i: Integer;
begin
    xmlCfg.SetValue('Count', lsStoredDocs.Count, 'Files');
    for i := 0 to lsStoredDocs.Count - 1 do begin
        xmlCfg.SetValue('File_' + IntToStr(i), lsStoredDocs.Strings[i], 'Files');
    end;
end;

end.
