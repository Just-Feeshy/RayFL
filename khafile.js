let project = new Project('My Project');

const fs = require('fs');

const BUILD_DIR = 'build';
const INDEX_HTML = 'index.html';

project.addShaders('shaders/**');
project.addAssets('assets/**.png');
project.addSources('source');
project.addParameter('-dce full'); // Dead Code Elimination (Haxe, do your thing!)
project.buildPath = BUILD_DIR;

if(platform === Platform.HTML5) {
    project.addDefine('js-es6');
}
function copy_callback(err) {
    if (err) throw err;
}

const BUILD_INDEX = BUILD_DIR + '/html5/' + INDEX_HTML;
if (platform == Platform.HTML5 && fs.existsSync(BUILD_INDEX)) {
    fs.copyFile(INDEX_HTML, BUILD_INDEX, copy_callback);
}

resolve(project);
