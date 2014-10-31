unit uStrings;
interface
const
    //xmlMain
    strDefaultExt = 'xml';
    strRootNode = 'Root';
    strHeaderNode = 'Header';
    strDataNode = 'Data';
    strFolderNode = 'Folder';
    strItemNode = 'Item';
    //


resourcestring
    rsTypes ='Title|Text|Pass|Link|Memo|Date|Mail|File';
    rsTitleDefName = 'Title';
    rsTextDefName = 'Login';
    rsPassDefName = 'Password';
    rsCommentDefName = 'Comment';
    rsLinkDefName = 'Website';
    rsDateDefName = 'Date';
    rsMailDefName = 'Mail';
    rsFileDefName = 'File';
    //�������� ����� ������, �����, ��������
    rsNewItemTitle = 'New item';
    rsNewFolderTitle = 'New folder';
    rsNewPageTitle = 'New Page';
    //����� ����� � ���� ������
    rsSearchText = 'Search';
    //���� ���� ��� �����
    rsInfoTitle =           'Title: ';
    rsInfoSubfolders =      'Subfolders:       ';
    rsInfoTotalFolders =    'Total folders:    ';
    rsInfoSubItems =        'Subitems:         ';
    rsInfoTotalItems =      'Total items:      ';
    //MessageBoxes
    rsDelFieldConfirmationText = 'Confirm to delete field "%s"?' + #10#13 + 'Value will be deleted too';
    rsDelFieldConfirmationCaption = 'Deleting field';
    rsCantDelTitleField = 'Can''t delete title of record';
    rsFieldNotSelected = 'Field not selected';
    rsDemo = 'Sorry, you''ve reached the limit of the records count for the test version of program';
    rsDocumentIsEmpty = 'Hmm... It looks like your document is empty!' + #10#13 + 'Would you like add new page?';
    //
    //
    const arrFieldFormats: array[0..8] of String = ('title',
                                                'text',
                                                'pass',
                                                'web',
                                                'comment',
                                                'date',
                                                'mail',
                                                'file',
                                                '');

    const arrNodeTypes: array[0..9] of String = ('root',
                                                'header',
                                                'data',
                                                'page',
                                                'folder',
                                                'deffolder',
                                                'item',
                                                'defitem',
                                                'field',
                                                '');

    const arrDefFieldNames: array[0..8] of String = ('Title',
                                                    'Login',
                                                    'Password',
                                                    'Website',
                                                    'Comment',
                                                    'Date',
                                                    'Mail',
                                                    'File',
                                                    'Text or Login');
    //��������� ������
    rsFrmAccountsCaption = 'Document manager';
    rsFrmAccountsCaptionOpen = 'Open base';
    rsFrmAccountsCaptionChange = 'Change base';
    rsFrmEditItemCaption = 'Edit record';
    rsFrmEditItemCaptionNew = 'New record';
    rsFrmEditFieldCaption = 'Edit field properties';
    rsFrmEditFieldCaptionNew = 'New field...';

    //��������� ��������
    rsClose = 'Close';
    rsCancel = 'Cancel';
    rsOK = 'OK';
    rsExit = 'Exit';
    rsOpen = 'Open';

    //frmAccounts
    rsSaveDialogFilter = 'Omg!Pass XML|*.xml|Omg!Pass Crypted|*.opwd';
    rsOpenDialogFilter = 'Omg!Pass XML|*.xml|Omg!Pass Crypted|*.opwd|All files|*.*';
    rsFileNotFoundMsg = 'File not found on the stored path!' +
                         #10#13 + 'Would you like to create a new document' +
                         #10#13 + '%s ?';
    rsSaveDialogFileExists = 'You have selected an existing file:' + #10#13 + '%s' + #10#13+ 'Overwrite it?';
    rsSaveDialogTitle = 'Save new database as...';
    rsOpenDialogTitle = 'Open database...';
    //frmMain

    //
implementation
end.
