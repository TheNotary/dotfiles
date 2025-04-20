// Your init script (moved from .coffee)
//
// Atom will evaluate this file each time a new window is opened. It is run
// after packages are loaded/activated and after the previous editor state
// has been restored.
//
// An example hack to log to the console when each text editor is saved.
//
// atom.workspace.observeTextEditors (editor) ->
//   editor.onDidSave ->
//     console.log "Saved! #{editor.getPath()}"


function colorTabsByKind(editor) {
	makeProjectTabSayProjectName();

	var known_types = {
		// Greenish
		"test": {
			"matchers": ["_int.rb", "_test.rb", "_spec.rb"],
			"color": "#ddc9c9",
		},
		// orange/ red
		"job": {
			"matchers": ["_job.rb"],
			"color": "#c9dddd",
		},
		// purple/ blue
		"controller": {
			"matchers": ["_controller.rb"],
			"color": "#e0e0cc",
		},
		// brown/ gold
		"view": {
			"matchers": [".html.erb", ".html"],
			"color": ""
		},
		// special gold
		"config": {
			"matchers": ["routes.rb", "schema.rb"],
			"color": ""
		},
	}
	var tabs = document.querySelectorAll('li.tab.texteditor');

	for(var i=0;i<tabs.length;i++) {
		var file_name = tabs[i].childNodes[0].getAttribute('data-name');
		if (!file_name) continue;
		var ext = file_name.substr(file_name.lastIndexOf('.') + 1);
		var file_type = matchesKnownType(file_name)

		if (!file_type) continue;

		var class_name = 'filetype-' + file_type;

		tabs[i].dataset["filetype"] = file_type;

		if (!tabs[i].classList.contains(class_name)) {
			tabs[i].classList.add(class_name);
		}
	}

	function matchesKnownType(filename) {
	  for (const file_type in known_types) {
	    const { matchers } = known_types[file_type];
	    if (matchers.some(matcher => filename.endsWith(matcher))) {
	      return file_type;
	    }
	  }
	  return false;
	}
}

atom.workspace.onDidOpen(colorTabsByKind);

// Make treeview say the projects actual name, not just the word project...
function makeProjectTabSayProjectName() {
	let treeviewDiv = document.querySelector("atom-workspace atom-panel-container.left atom-pane > ul > li > div")
	let rootDir = atom.workspace.project.rootDirectories[0];

	if (!rootDir) return;

	let rootDirName = rootDir.path.split("/").slice(-1)[0].toUpperCase()
	treeviewDiv.textContent = rootDirName;
}
