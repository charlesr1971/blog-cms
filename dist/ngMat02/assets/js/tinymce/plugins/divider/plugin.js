tinymce.PluginManager.add('divider', function(editor, url) {
  
  var debug = false;

  editor.addButton('divider', {
    title: 'Add ellipsis divider',
    icon: 'icon-ellipsis',
    onclick: function() {
		editor.insertContent('<div class="tinymce-divider-plugin" style="margin:20px 0px;text-align:center;"><span style="display:inline-block;height:36px;line-height:0px;font-size:64px;color:rgb(229,229,229);">...</span></div>');
		var uniqueID = editor.dom.uniqueId();
		var paragraph = document.createElement('p');
		paragraph.setAttribute('id',uniqueID);
		paragraph.setAttribute('class','tinymce-divider-plugin-paragraph');
		paragraph.innerHTML = '&nbsp;';
		var paragraphs = tinymce.activeEditor.dom.select('p');
		tinymce.each(paragraphs,function(obj,ind) {
		  if(obj.getAttribute("id") && obj.getAttribute("id").indexOf('mce_') !== -1){
			tinymce.activeEditor.dom.remove(obj);
		  }
		});
		editor.dom.insertAfter(paragraph,editor.selection.getNode());
		var newParagraph = editor.dom.select('p#' + uniqueID)[0];
		editor.selection.setCursorLocation(newParagraph);
    }
  });

  return {
    getMetadata: function () {
      return  {
        name: "Divider plugin",
        url: ""
      };
    }
  };
  
});
