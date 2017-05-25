CKEDITOR.editorConfig = function(config) {
  config.forcePasteAsPlainText = true;
  config.removeDialogTabs = 'link:advanced';
  config.toolbar = [
    {
      name: 'clipboard',
      items: ['Cut', 'Copy', 'Paste', '-', 'Undo', 'Redo']
    }, {
      name: 'basicstyles',
      items: ['NumberedList', 'BulletedList', 'Bold', 'Italic', '-', 'RemoveFormat']
    }, {
      name: 'links',
      items: ['Link', 'Unlink']
    }
  ];
  return true;
};
