$WebURL = "http://portal.contoso.com/sites/stuff" 
$DocLibName = "Docs" 
$FilePath = "C:\Docs\stuff\Secret Sauce.docx"
$Web = Get-SPWeb $WebURL 
$List = $Web.GetFolder($DocLibName) 
$Files = $List.Files
$FileName = $FilePath.Substring($FilePath.LastIndexOf("\")+1)
$File= Get-ChildItem $FilePath
$Files.Add($DocLibName +"/" + $FileName,$File.OpenRead(),$false) 
$web.Dispose()